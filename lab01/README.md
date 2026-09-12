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

- 先將 rectangle 依 `drc_sel` 篩出指定 layer，再轉成 **16 × 16 bitmap**。
- 分別從 row / column 兩個方向檢查 width 與 spacing。
- Width 以連續 `1` 判斷，Spacing 以兩個 shape 中間連續 `0` 判斷。
- 透過 bitmap 與 bit pattern 簡化原本複雜的 rectangle 座標比較。

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
