# Lab02 — Mini Image Signal Processor

本次 Lab 實作 **Mini Image Signal Processor (ISP)**。  
輸入為 16 × 16 的 Bayer RAW image，依序完成 BLC、LSC、DPC、Demosaicing 與 CCM，最後輸出完整 RGB image。

---

## Specification

ISP 處理流程：

`BLC → LSC → DPC → Demosaicing → CCM`

主要限制：

- Image size：16 × 16
- Input：12-bit Bayer RAW
- Clock period ≤ 20 ns
- Latency ≤ 1500 cycles
- Total cell area ≤ 2,500,000
- Function Validity：70%
- Performance：30%

Performance 計算方式：

`Cycle Time × Total Latency × Area²`

---

## Design

### BLC & LSC

BLC 依照 Bayer pixel 的位置使用不同 black level 做修正。

LSC 則先儲存四組 6 × 6 gain table，再依 pixel 座標取出鄰近四個 gain，完成 bilinear interpolation。

```text
RAW Pixel
   ↓
BLC
   ↓
LSC
```

為了降低運算複雜度，LSC 的 interpolation 直接轉成固定係數運算。

### DPC

DPC 使用 5 × 5 window，分別建立：

- Horizontal
- Vertical
- Diagonal 1
- Diagonal 2

四個方向各自計算 median 與 SAD，選出最平滑的方向作為 Target。

```text
5×5 Window
   ↓
4 Directions
   ↓
Median + SAD
   ↓
Select Target
```

若中心 pixel 與 Target 差距超過 threshold，則以 Target 取代。

### Demosaicing

DPC 完成後，再利用 3 × 3 neighborhood 補出 Bayer RAW 缺少的 RGB channel。

不同 R / G / B 位置使用不同鄰近 pixel 做平均，邊界則使用 reflect padding。

### CCM

最後使用 3 × 3 Color Correction Matrix 修正 RGB。

在 RTL 中將三個 channel 可共用的計算先合併，減少重複的乘法與加法邏輯。

---

## Result

| Item | Result |
|---|---:|
| Demo | 1 |
| CT | 4.4 |
| Area | 684623 |
| Latency | 26100 |
| Perf | 5.38265E+16 |
| Score | 96.40 |
| Rank | 13 |

---

## 心得

這次 Lab 主要難點是 DPC 的 5 × 5 window 與資料流控制，因此使用 line buffer 保存前面的 pixel，讓每個 cycle 都能取得需要的鄰近資料。

裡面的乘法可以都用移位和加法算出一樣的值，但我當時沒想到，聽了 BEST CODE 才知道。然後因為開始有 Latency ，所以也要開始對 CT 與 Latency 做取捨，Latency 應該可以利用 retiming 再壓低一點。這份 Lab2 題目把步驟寫得很清楚，一步一步照著刻就好了。
