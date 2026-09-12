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

整體使用 `IDLE → LOAD → DOWN → CMP → OUT` 五個 states。  
16 張 image 全部存在一顆 **4096 × 8 SRAM**，收到 command 後只把兩張 target image 讀到 `matrix0 / matrix1`，SRAM output 先經過 `mem0_dout_ff` 對齊 read latency。  
OP0 在 output stage 做 `(A+B)>>1`，OP1 做 absolute difference；OP2 交換兩張 image 並比較 pixel sum，OP3 則找每個 row 的 maximum。  
四種 operation 最後共用同一套 output control，連續輸出 256 pixels。

---

## 心得

這次 OT 的資料量是 16 張 16 × 16 image，如果全部直接使用 register 儲存會需要很多面積，因此主要使用一顆 4096 × 8 SRAM 保存完整 image data，每次只讀出 command 指定的兩張 image 做運算。

四種 operation 也盡量共用同一套資料讀取與 output flow。OP 0 與 OP 1 直接在輸出時運算；OP 2 才額外使用 SRAM write 完成 image swap；OP 3 則只需要一組 row maximum register。

Average 直接使用 shift 完成除以 2，SRAM output 也先打一層 FF 對齊 read latency，讓後面的 matrix loading 與 sum accumulation 比較好控制。

