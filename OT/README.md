# OT — OT_DESIGN

本次 OT 實作一個簡單的 **Image Operation Accelerator**。  
系統先接收 16 張 16 × 16 的 8-bit image，全部存入 SRAM，再依照 `in_cmd` 指定的 operation 與 target image 執行運算，最後輸出一張 16 × 16 image。

---

## Specification

從 code 與 PATTERN 可以確認：

- Image 數量：16
- Image size：16 × 16
- Pixel：8-bit unsigned
- Initial input：4096 pixels
- Command：10 bits
- Output：256 pixels
- Pattern number：100
- Pattern 使用 Clock period：20 ns
- Latency limit：2000 cycles

Command format：

```text
in_cmd[9:8]  → Operation
in_cmd[7:4]  → Target 0
in_cmd[3:0]  → Target 1
```

四種 operation：

```text
OP 0 → Pixel-wise Average
OP 1 → Absolute Difference
OP 2 → Swap Images + Sum Comparison
OP 3 → Row Maximum
```

---

## Design

### FSM

整體使用 5-state FSM：

```text
IDLE
 ↓
LOAD
 ↓
DOWN
 ↓
CMP
 ↓
OUT
```

- `LOAD`：等待 command
- `DOWN`：從 SRAM 讀出兩張 target images
- `CMP`：依照不同 operation 做額外處理
- `OUT`：連續輸出 256 個 pixels

其中 `DOWN / CMP / OUT` 各自使用 counter 控制 SRAM address 與 `(x, y)` position。

### SRAM

16 張 image 全部存在一顆 **4096 × 8 SRAM**：

```text
16 Images
×
256 Pixels
=
4096 Words
```

每張 image 使用 256 個連續 addresses，因此 target image 的起始位置可以直接用：

```text
target << 8
```

取得。

每次收到 command 後，只把兩張需要處理的 image 從 SRAM 讀到 `matrix0` 與 `matrix1`，不需要同時把 16 張 image 全部放在 register。

SRAM 的 output 會先經過一層 `mem0_dout_ff`，再寫進 matrix 與累加 sum，用來對齊 SRAM read latency。

```text
SRAM
 ↓
mem0_dout_ff
 ↓
matrix0 / matrix1
 ↓
Operation
```

### OP 0 — Average

對兩張 target images 做 pixel-wise average：

```text
(A + B) >> 1
```

使用右移 1 bit 完成除以 2，不需要 divider。

### OP 1 — Absolute Difference

逐 pixel 計算兩張 image 的 absolute difference：

```text
|A - B|
```

先比較兩個 pixel 的大小，再使用 subtraction，因此不需要額外處理 signed absolute value。

### OP 2 — Swap & Compare

這個 operation 會先交換兩張 target images 在 SRAM 中的位置。

```text
Image A ──→ Address B
Image B ──→ Address A
```

在 `DOWN` 階段讀取 image 的同時，也會分別累加 `sum0` 與 `sum1`。

接著在 `CMP` 階段花 512 cycles 將兩張 image 寫回對方原本的 SRAM address，完成 swap。

最後比較兩張 image 的 total pixel sum，輸出總和較大的那張 image。

```text
Read A / B
    ↓
Calculate Sum
    ↓
Swap in SRAM
    ↓
Compare Sum
    ↓
Output Larger-Sum Image
```

### OP 3 — Row Maximum

對 Target 0 的每一個 row 找出最大 pixel。

```text
16 Pixels / Row
       ↓
     Maximum
       ↓
Fill Entire Row
```

使用 `max0[0:15]` 分別保存 16 個 rows 的 maximum value。

比較完成後，將每個 row 的 16 個 pixels 都改成該 row 的 maximum，再輸出 16 × 16 result。

### Output

所有 operation 最後統一進入 `OUT` state。

```text
out_x : 0 ~ 15
out_y : 0 ~ 15
```

連續輸出 256 cycles。

OP 0 與 OP 1 不需要額外修改 matrix，可以直接在 output stage 做 average / absolute difference。

OP 2 與 OP 3 則先在 `CMP` stage 完成 memory swap 或 row maximum，再由同一套 output control 輸出。

---

---

## 心得

這次 OT 的資料量是 16 張 16 × 16 image，如果全部直接使用 register 儲存會需要很多面積，因此主要使用一顆 4096 × 8 SRAM 保存完整 image data，每次只讀出 command 指定的兩張 image 做運算。

四種 operation 也盡量共用同一套資料讀取與 output flow。OP 0 與 OP 1 直接在輸出時運算；OP 2 才額外使用 SRAM write 完成 image swap；OP 3 則只需要一組 row maximum register。

Average 直接使用 shift 完成除以 2，SRAM output 也先打一層 FF 對齊 read latency，讓後面的 matrix loading 與 sum accumulation 比較好控制。

