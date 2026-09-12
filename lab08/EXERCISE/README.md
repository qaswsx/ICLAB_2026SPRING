# Lab08 — Coupling Network

本次 Lab 實作 **Coupling Network**，包含 Forward 與 Backward 兩種 operation。  
輸入兩個 4 × 4 matrix `A / B` 與四組 4 × 4 coupling matrices `F1 / H1 / F2 / H2`，依照 `task_num` 完成 coupling network 的前向或反向運算。

另外需要加入 **Clock Gating**，並利用 JasperGold SEC 驗證加入 clock gating 前後的功能一致。

---

## Specification

兩種 operation：

- Task 0：Forward Coupling
- Task 1：Backward Coupling

Input：

- `task_num`：1 bit
- `A / B`：4 × 4，8-bit
- `F1 / H1 / F2 / H2`：4 × 4，4-bit
- Input 共 97 cycles

Output：

- `OUT_A / OUT_B`
- 連續輸出 32 cycles
- `out_data`：12 bits

主要限制：

- Clock period：15 ns
- Execution latency ≤ 200 cycles
- Total Area ≤ 600,000
- 禁止 Memory
- 禁止 DesignWare IP
- Clock Gating power reduction ≥ 10%
- Functionality：80%
- Performance：20%

Clock Gating Power Reduction：

`(Power_CG_OFF - Power_CG_ON) / Power_CG_OFF ≥ 10%`

Performance 計算方式：

`Total Latency × (Total Power with CG)² × Area`

---

## Design

整體只有 `IDLE / CALC` 兩個 state，主要由 `cnt / calc_cnt` 排程，並讓部分 input 與 calculation overlap。  
`A_flat / B_flat` 重複利用來保存 matrix 與部分 coefficient，X1 / Y1 / X2 / Y2 共用同一組 4-lane MAC。  
Modulo 15 使用 shift / add / compare，Backward division 只用一組 `DIV_8_BY_4` 重複計算。  

---

## Result

| Item | Result |
|---|---:|
| Demo | First demo |
| CT | 15 ns |
| Latency | 100 |
| Area | 115205.1 |
| Power (CG OFF) | 0.005227 |
| Power (CG ON) | 0.003048 |
| Power Reduction | 41.69% |
| Perf | 107.0290401 |
| Score | 93.98 |
| Rank | 26 |

---

## 心得

這次 Lab 除了 coupling network 本身之外，最大的重點是 **硬體共用與 Clock Gating**。

因為不能使用 memory，所以如果直接把 A、B、F1、H1、F2、H2 全部各自存成 register array，Area 會很大。因此我將 A / B register 擴成 12 bits，除了存原本的 8-bit matrix data，也利用高 4 bits 保存部分 coupling coefficient，再搭配 `buf_cur` 直接使用正在輸入的 coefficient，減少額外 storage。

運算部分則讓 X1、Y1、X2、Y2 共用同一組 MAC，Pointwise Multiplication、XOR 與 Divider 也盡量在不同 stage 重複使用。Modulo 15 的運算也沒有直接使用一般乘法與除法，而是利用 modulo 特性搭配 shift、add 與比較完成。

Clock Gating 則沒有直接用少數幾顆 gate 控制大量 register，而是對 A / B 的每個 element 分別產生 gated clock，只在真正需要更新時打開 clock，降低 unnecessary switching。

除了 clock gating 外，還可以做 data gating，我的 power 不算低，因為我不太會壓 power 可以去看其他大神的。主要是在做 CG 前就要先想辦法讓 power 夠低，因為加 CG 降的 power 有限，可能還會增加 delay、area。
