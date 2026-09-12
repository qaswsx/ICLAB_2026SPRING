# Lab09 — Dessert Shop Simulator

本次 Lab 使用 **SystemVerilog** 實作 **Dessert Shop Simulator (DSS)**。  
每間甜點店的原料、日期、銷售量、員工數、餘額與等級皆存放在 DRAM，DSS 透過 AXI4-Lite 讀取指定店家資料，依照不同 action 完成運算後再更新 DRAM。

支援五種 operation：

- Make and Sell
- Restock
- Hire Staff
- Pay Day
- Check Valid Date

---

## Specification

主要限制：

- Clock period ≤ 20 ns
- 每個 operation latency < 1000 cycles
- Total Area < 400,000
- 禁止 SRAM
- 禁止 DesignWare IP
- 使用 SystemVerilog datatype
- DRAM 透過 AXI4-Lite 存取
- Function：70%
- Performance：30%

Performance 計算方式：

`Area × Latency × Cycle Time`

每筆 shop data 由兩個 64-bit DRAM words 組成，內容包含：

```text
Flour / Butter / Milk / Sugar / Fruit
Date
Sales
Staff
Balance
Level
```

---

## Design

使用 `IDLE → GET_IN → READ_DRAM → CALC → WRITE_DRAM` FSM，依不同 action 收集所需 input。  
透過 AXI4-Lite 讀取 shop data，五種 action 共用 stock / balance / multiplier / divider datapath，固定倍率則盡量改用 shift。  
Warning 與 DRAM update 依 action 規則集中處理，AXI read / write 完全依照 VALID / READY handshake 前進。  
Make and Sell 的升級除法使用 multi-cycle shift / compare / subtract，用 latency 換較小的硬體。

---

## Result

| Item | Result |
|---|---:|
| Demo | Second demo |
| CT | 3.3|
| Latency | 803894 |
| Area | 110699.2 |
| Perf | 2.94E+11 |
| Score | 70 |
| Rank | 1 (2nd demo) |

---

## 心得

這次 Lab 最大的難點是 **不同 action 的規則很多，而且每種 action 都會修改不同的 DRAM field**。

如果每種 operation 都各自做一套計算硬體，Area 很容易變大，因此我主要利用 `calc_cnt` 排程，讓 stock add/sub、balance add/sub 與 multiplier 在不同 action 間共用。

乘法也沒有直接為每種公式配置不同 multiplier，而是將 operand 切成 high / low 4 bits 計算 partial product，再讓 Dessert Price、Restock、Hire Staff 與 Pay Day 重複使用同一條 datapath。

Make and Sell 的升級計算需要除法與餘數，我也沒有直接使用 divider，而是拆成多個 cycle 使用 shift、compare 與 subtract 完成，用 latency 換取較小的 combinational hardware。

另外 AXI4-Lite 的 DRAM latency 在 demo 時會改變，因此 read / write control 都必須完全依照 VALID / READY handshake 前進，不能假設固定 latency。

第一次寫 SV，寫得偏爛，在 lab10 出來前可以先用普通 verilog 寫一個簡單的 PATTERN 驗驗看 DESIGN。 然後這份 lab 不小心露看了一個地方，就進入 2de 了 qq，重點是我還試了 6 份自己跟朋友的 PATTERN，結果錯在一個很白癡的地方，妳各位題目要看清楚阿。
