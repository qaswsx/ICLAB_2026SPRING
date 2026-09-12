# Lab07 — Harvester with Clock Domain Crossing

本次 Lab 實作 **Harvester with Clock Domain Crossing**。  
大部分是拿 lab3 的來改。
系統分成 `clk1 / clk2 / clk3` 三個 clock domain，除了完成 CALC 與 GAUSS 運算之外，也需要自行設計 Handshake、Asynchronous FIFO 與 DRAM interface，處理跨時脈資料傳輸。

---

## Specification

系統分成三個主要模組：

- `CLK_1_MODULE`：接收 input，將 command 傳到 clk2，並接收最後結果
- `CLK_2_MODULE`：執行 CALC / GAUSS 與產生 AXI read request
- `CLK_3_MODULE`：接收 AXI request，控制實體 DRAM

CDC 使用方式：

```text
clk1 → clk2 : Handshake
clk2 → clk1 : FIFO (Output Result)
clk2 → clk3 : FIFO (AXI Read Address)
clk3 → clk2 : FIFO (AXI Read Data)
```

主要限制：

- CALC：Prefix Expression Tree
- GAUSS：1024 words 的 Mean / Variance / 1σ Filter
- Execution latency ≤ 90,000 clk1 cycles
- Each module area ≤ 7,500,000
- 禁止 DesignWare IP
- FIFO 必須使用 TA 提供的 Dual-Port SRAM
- 必須通過 Jasper Gold CDC Verification
- Functionality：70%
- Jasper Gold：25%
- Performance：5%

Gate-level clock period：

```text
clk1 = 20.1 ns
clk2 = 11.3 ns
clk3 = 34.7 ns
```

Performance Goal：

- Average Latency ≤ 8000 cycles
- Area ≤ 1,200,000

本次 **Area Goal 有達成，但 Average Latency 沒有達成**。

---

## Design

### Clock Domain Crossing

整體資料流：

```text
PATTERN
   │
   │ clk1
   ↓
CLK_1_MODULE
   │
   │ Handshake
   ↓
CLK_2_MODULE
   │
   ├── FIFO → clk1 : Result
   │
   ├── FIFO → clk3 : AXI Read Address
   │
   └── FIFO ← clk3 : AXI Read Data
   ↓
CLK_3_MODULE
   ↓
DRAM
```

### Handshake

`clk1 → clk2` 的 command 使用 request / acknowledge handshake。

Source 會先將 `{mode, bank, row}` 存入 `sdata`，再送出 `sreq`，經過 `NDFF_syn` 同步到 destination domain。

```text
sready
   ↓
Lock Data
   ↓
sreq
   ↓
NDFF
   ↓
dreq
   ↓
dvalid
   ↓
dack
   ↓
NDFF
   ↓
sack
```

這裡主要用來傳送每個 pattern 的 4 組 command，因此資料量不大。

### Asynchronous FIFO

其餘大量資料都使用 asynchronous FIFO。

FIFO 使用：

- Binary Read / Write Pointer
- Gray Code Pointer
- `NDFF_BUS_syn`
- Dual-Port SRAM
- Full / Empty Detection

```text
Write Pointer
    ↓
 Gray Code
    ↓
NDFF_BUS
    ↓
Read Domain
```

FIFO depth 為 64，pointer 使用 7 bits，其中最高 bit 用來判斷 wrap-around。

`wfull` 透過同步後的 read pointer 與 write Gray pointer 比較，`rempty` 則比較 read pointer 與同步後的 write pointer。

### CALC

CALC mode 依序處理四棵 Prefix Expression Tree。

首先一次送出四個 root read request，再將 root 存入 `root_buf`。

```text
4 Roots
   ↓
Root Buffer
   ↓
Tree Traversal
   ↓
64-bit ALU
   ↓
4 Results
```

走訪 tree 時使用 depth-8 stack 保存：

- Operator
- Right Pointer
- Left Value
- Traversal State

支援：

- ADD
- SUB
- MULT
- Arithmetic Shift Right

ADD / SUB 共用同一條 adder datapath。

### GAUSS

GAUSS mode 需要掃描 4 Banks 共 1024 筆資料。

第一遍：

```text
1024 Data
   ↓
Valid Number Check
   ↓
Sum / Sum of Square / Count
   ↓
Mean / Variance
```

除法沒有使用 DesignWare IP，而是使用逐 bit divider，分別計算 mean 與 variance 所需的除法。

第二遍再重新讀取 1024 筆資料：

```text
Data
 ↓
|Data - Mean|
 ↓
Square
 ↓
Compare Variance
 ↓
Output if within 1σ
```

只有 valid numeric data 會參與統計，最後一個 position 則一定會送出，讓 PATTERN 可以判斷輸出結束。

### AXI / DRAM

`CLK_2_MODULE` 可以連續送出多筆 read address request，使用 `ar_inflight_cnt` 控制 outstanding 數量。

`CLK_3_MODULE` 內部建立 request queue，並分別記錄四個 bank 的狀態：

```text
CLOSED
  ↓
ACT_WAIT
  ↓
OPEN
  ↓
PRE_WAIT
```

每個 bank 各自追蹤：

- Active Row
- tRCD
- tRAS
- Precharge timing
- In-flight Read

因此不同 bank 可以交錯執行 ACT / READ / PRE，利用 bank interleaving 隱藏 DRAM latency。

### FIFO Latency

這次 latency 沒有達到 8000 cycles 的 Goal，主要問題出現在 FIFO read control 太保守。

在 `CLK_1_MODULE`、`CLK_2_MODULE` 與 `CLK_3_MODULE` 中，我都額外加入 `empty` pipeline 與 `wait_cnt`，確認 SRAM output 穩定後才讀下一筆資料。

例如：

```text
FIFO Not Empty
     ↓
Wait Counter
     ↓
Read Data
     ↓
rinc
     ↓
Counter Reset
```

這種寫法功能上比較保守，但每讀一筆 FIFO data 都會重新付一次等待時間，沒有把 asynchronous FIFO 做成連續的 pipelined read。

GAUSS 需要讀取大量資料，而且總共需要掃描 1024 筆兩次，因此 FIFO throughput 會直接影響整體 latency。

相較之下，Handshake 每個 pattern 只傳 4 組 command，對總 latency 的影響較小。

---

## Result

| Item | Result |
|---|---:|
| Demo | First Demo |
| Clock | 20.1 / 11.3 / 34.7 ns |
| Latency | 未達 Average 8000 cycles Goal |
| Area | 達成 ≤ 1,200,000 Goal |
| Score | 95 |
| Rank | First demo |

---

## 心得

這次 Lab 最大的難點是 **Clock Domain Crossing 與 DRAM latency**。

除了 CALC 與 GAUSS 本身的運算之外，還需要同時處理三個不同 clock domain，因此 command、AXI address、DRAM data 與 output result 都不能直接跨 clock 傳輸。

我使用 Handshake 傳送少量 command，並使用 asynchronous FIFO 搭配 Gray pointer、`NDFF_BUS_syn` 與 Dual-Port SRAM 傳送大量資料。

DRAM 部分則建立 per-bank FSM，讓不同 bank 的 ACT / READ / PRE 可以互相 overlap，並支援多筆 outstanding read request。

我這次應該是 clk3 寫太爛，所以 latency 壓不下來，但因為都寫好了，要改可能要整個架構大改，我就放棄了。所以大家寫這個 lab 前要盡量先想好架構，以免後面優化的時候要大改。
