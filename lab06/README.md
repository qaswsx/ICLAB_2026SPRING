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

### SORT_IP

`SORT_IP` 使用 **combinational sorting network**，並利用 `generate` 針對不同 `IP_WIDTH` 建立對應的 comparator network。

我先將 weight 與 character ID 合併：

```text
{ Weight, Character ID }
```

再直接使用整組數值比較，因此一次 comparison 就可以同時完成：

1. Weight 大小排序
2. Weight 相同時的 character priority

```text
Input
  ↓
Comparator Layer 1
  ↓
Comparator Layer 2
  ↓
...
  ↓
Sorted Characters
```

`IP_WIDTH = 8` 時使用 6 層 comparator network，其餘 3 ~ 7 也各自建立對應的 sorting network，整個 Soft IP 為 combinational design，不需要額外的 clock cycle。

### Initial Sort

Top Design 收完 8 個 weights 後，先使用：

```verilog
SORT_IP #(.IP_WIDTH(7))
```

排序前 7 個 characters，再將最後輸入的 `V` 依 weight 插入正確位置。

這樣可以直接在第 8 筆輸入進來的同時保存 `V`，不需要再多等一個 cycle 才開始後續運算。

### Huffman Tree

排序完成後，整個 Huffman Tree 沒有使用 FSM 一輪一輪建立，而是直接展開成 **7 個 combinational stages**。

每一個 stage 都做：

```text
取出最小兩個 Nodes
        ↓
      Merge
        ↓
記錄 Left / Right Child
        ↓
將 New Subtree 插回 Sorted List
```

總共有 8 個 leaf nodes，因此依序經過 7 次 merge 後得到完整 Huffman Tree。

每個 node 使用：

```text
{ Weight, Node ID }
```

來表示。

Character 與 subtree 都有固定 ID，因此當 weight 相同時，可以直接利用 ID 完成題目要求的 priority，不需要再另外增加複雜的 tie-breaking logic。

另外較大的 node 放在 left child，較小的 node 放在 right child，最後分別對應 Huffman code 的 `0` 與 `1`。

### Huffman Code Tracing

Tree 建好後，不另外儲存每個 character 的完整 code。

輸出某個 character 前，直接從 leaf 往 root trace：

```text
Target Character
      ↓
Compare Left / Right Root
      ↓
Left  → 0
Right → 1
      ↓
Move to Parent
      ↓
Huffman Code
```

`out_mode = 0` 時依序輸出：

`I → L → O → V → E`

`out_mode = 1` 時依序輸出：

`I → C → L → A → B`

最後使用 shift register 將每個 character 的 Huffman code 一個 bit 一個 bit送到 `out_code`。

### Low Latency Design

Huffman Tree 的 7 次 merge 全部直接展開成 combinational logic，而不是每次 merge 花一個 cycle。

因此 input 結束後，不需要再花多個 cycles 建 tree，下一個 cycle就可以開始輸出第一個 Huffman code bit。

```text
8-cycle Input
     ↓
Initial Sort
     ↓
7-stage Combinational Huffman Tree
     ↓
Code Trace
     ↓
Output
```

這種做法主要是以較長的 combinational path 換取非常低的 execution latency。

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
