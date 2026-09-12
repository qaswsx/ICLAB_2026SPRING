# Lab06 — Huffman Code Operation

本次 Lab 實作 **Huffman Code Operation (HT)**。  
輸入 A、B、C、E、I、L、O、V 八個字元的 weight，先利用自己設計的 `SORT_IP` 排序，再建立 Huffman Tree，最後依照 `out_mode` 輸出 `ILOVE` 或 `ICLAB` 對應的 Huffman code。

---

## Specification

主要限制：

- Input：8 個 characters 的 3-bit weight
- Clock period ≤ 20 ns
- Execution latency ≤ 2000 cycles
- Total cell area ≤ 2,000,000
- 禁止 Look-Up Table
- 禁止 DesignWare IP
- Top Design 必須使用自行設計的 `SORT_IP`
- `SORT_IP` 支援 `IP_WIDTH = 3 ~ 8`
- `SORT_IP` 必須使用 `generate`
- `SORT_IP` 必須在 1 cycle 內完成 sorting

評分：

- Function Validity：50%
- Performance：30%
- Soft IP：20%

Performance 計算方式：

`Area × Total Latency × Cycle Time`

其中 `Total Latency` 為所有 patterns latency 的總和。

---

## Design

`SORT_IP` 使用 `generate` 建立 combinational sorting network，直接比較 `{Weight, Character ID}` 同時處理 weight 與 priority。  
Top 先排序前 7 個 characters，再把最後輸入的 `V` 插入正確位置。  
Huffman Tree 的 7 次 merge 全部展開成 combinational stages，Tree 建好後再從 leaf 往 root trace code，最後逐 bit 輸出。

---

## Result

| Item | Result |
|---|---:|
| Demo | 1 |
| CT | 10.6 |
| Latency | 2000 |
| Area | 33825.96 |
| Perf | 717110352 |
| Score | 99.62 |
| Rank | 2 |

---

## 心得

這次 Lab 除了 Huffman Tree 本身之外，最大的重點是需要自己設計可以參數化的 `SORT_IP`。

一開始 sorting 如果用一般逐筆比較的方式，會需要很多 cycles，因此最後直接使用 combinational sorting network，並把 weight 和 character ID 綁在一起比較，讓 weight sorting 與相同 weight 的 priority 可以一次完成。

Top Design 的 Huffman Tree 也沒有使用 FSM 一次做一個 merge，而是直接把 7 個 merge stages 全部展開。這讓 input 結束後下一個 cycle就可以開始輸出，將 latency 壓到很低。

代價是 combinational path 會變長，而且 comparator、MUX 與 adder 的數量也會增加，因此這題主要是在 **Latency、Area 與 Critical Path** 之間做取捨。
