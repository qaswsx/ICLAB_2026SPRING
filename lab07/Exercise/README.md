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

`clk1 → clk2` 的 command 使用 Handshake，其餘大量資料使用 Gray-code Asynchronous FIFO 搭配 Dual-Port SRAM 傳輸。  
CALC 使用 depth-8 stack 走訪 Prefix Expression Tree；GAUSS 則掃描 1024 筆資料計算 Mean / Variance 與 1σ filter。  
`CLK_3_MODULE` 以 per-bank state 與 request queue 控制 DRAM，利用 bank interleaving 隱藏 latency。  
FIFO read side 因額外加入 wait counter，每讀一筆都重新等待，throughput 偏低，也成為 Average Latency 沒達 Goal 的主要原因。

---

## Result

| Item | Result |
|---|---:|
| Demo | First Demo |
| Clock | 20.1 / 11.3 / 34.7 ns |
| Latency | 1475607 |
| Area | 1169767 |
| Score | 95 |
| Rank | First demo |

---

## 心得

這次 Lab 最大的難點是 **Clock Domain Crossing 與 DRAM latency**。

除了 CALC 與 GAUSS 本身的運算之外，還需要同時處理三個不同 clock domain，因此 command、AXI address、DRAM data 與 output result 都不能直接跨 clock 傳輸。

我使用 Handshake 傳送少量 command，並使用 asynchronous FIFO 搭配 Gray pointer、`NDFF_BUS_syn` 與 Dual-Port SRAM 傳送大量資料。

DRAM 部分則建立 per-bank FSM，讓不同 bank 的 ACT / READ / PRE 可以互相 overlap，並支援多筆 outstanding read request。

我這次應該是 clk3 寫太爛，所以 latency 壓不下來，但因為都寫好了，要改可能要整個架構大改，我就放棄了。所以大家寫這個 lab 前要盡量先想好架構，以免後面優化的時候要大改。
