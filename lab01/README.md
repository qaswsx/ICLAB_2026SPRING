# Lab01 — Design Rule Check Accelerator

本次 Lab 實作 **Design Rule Check Accelerator (DRCA)**。  
根據輸入的 layout shapes 與 `drc_sel`，檢查指定 layer 是否違反 **minimum width** 或 **minimum spacing**，最後輸出 violation 數量。

---

## Specification

Layout 座標限制在 **16 × 16 grid**，共包含 7 種 layer：

`CO / OD / PO / M1 / NP / PP / NW`

每個 shape 由 layer type 與矩形的兩個角落座標組成。

主要限制：

- Clock period < 20 ns
- Total cell area < 800,000
- Function Validity：70%
- Performance：30%

Performance 計算方式：

`Cycle Time × Area`

---

## Design

### Shape Decode

先將每個 shape 拆成：

- Layer type
- `(x1, y1)`
- `(x2, y2)`

再依照 `drc_sel` 選出目前需要檢查的 layer。

### Bitmap

由於座標範圍只有 0 ~ 15，因此我將矩形轉換成 **16 × 16 bitmap**。

```text
Rectangle
   ↓
Row Bitmap
   ↓
Column Bitmap
```

透過 row 與 column 兩個方向分別檢查，可以共用大部分的判斷邏輯。

### Width Check

Width violation 是檢查連續的 `1` 是否小於指定寬度。

```text
010       → width = 1
0110      → width = 2
01110     → width = 3
```

若 X、Y 方向都違反規則，會分別計算 violation。

### Spacing Check

Spacing 是判斷兩個 shape 中間連續的 `0` 是否太短。

```text
101       → spacing = 1
1001      → spacing = 2
10001     → spacing = 3
```

只考慮水平與垂直方向的 spacing，不計算單純的 diagonal distance。

---

## Result

| Item | Result |
|---|---:|
| Demo | 1 |
| CT | 9.46 |
| Area | 212089.6 |
| Perf | 2006367.616 |
| Score | 92.97 |
| Rank | 27 |

---

## 心得

這次 Lab 最大的重點是如何處理幾何資訊。

如果直接使用 rectangle 座標做大量比較，判斷條件會相當複雜。  
因此我將 layout 轉成 bitmap，再利用 bit pattern 判斷 width 與 spacing，讓整體邏輯更容易整理。

因為是comb circuit，所以優化主要在簡化邏輯，盡量讓 CT 壓的小一點，簡化邏輯的同時 Area 可能也會跟著變小。
