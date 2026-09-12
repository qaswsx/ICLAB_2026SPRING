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

### Counter-Based Scheduling

整體只使用 `IDLE / CALC` 兩個 state，主要流程由 `cnt` 與 `calc_cnt` 排程。

```text
Input
  ↓
cnt
  ↓
Stage Control
  ↓
X1 / Y1
  ↓
Mid Result
  ↓
X2 / Y2
  ↓
Output
```

由於 Input 固定連續輸入 97 cycles，因此不需要為每個 operation 再切很多 FSM states。

在前 32 cycles 收完 A、B 後就開始進入 CALC，後面的 F1 / H1 / F2 / H2 一邊輸入、一邊進行運算，盡量讓 input 與 calculation overlap，避免額外 idle cycle。

### Register Reuse

A 與 B 各使用 16 個 12-bit register：

```text
A_flat[0:15]
B_flat[0:15]
```

低 8 bits 用來存 matrix data，高 4 bits 在 Backward mode 時可以再拿來保存部分 4-bit coupling coefficient。

因此不需要另外為所有 `F1 / H1 / F2 / H2` 建立完整 register array。

其餘 coupling coefficient 則使用 `buf_cur` 保存目前正在使用的 4-bit input，直接配合 counter 進行計算。

```text
8-bit Matrix Data
        +
4-bit Coefficient
        ↓
  12-bit Register
```

### Shared MAC

主要矩陣運算共用同一組 4-lane `MAC`。

```text
4 Matrix Elements
       ↓
   Shared MAC
       ↓
4 Parallel Results
```

同一組 MAC 會依照目前 `calc_cnt` 切換輸入，重複使用在：

- X1
- Y1
- X2
- Y2

並透過 `psum_x / psum_y` 累加每一個 row 的 matrix multiplication result。

另外 Pointwise Multiplication 使用 4 組 `4 × 8` multiplier，Forward / Backward 不同 stage 也共用同一組 datapath。

### Modulo 15

X path 需要：

```text
Matrix Multiplication
        ↓
     mod 15
        ↓
       + 1
```

為了降低硬體複雜度，沒有直接使用大型 multiplier 再做 `% 15`。

12-bit input 會先拆成三組 4-bit：

```text
[11:8] + [7:4] + [3:0]
```

利用 `16 ≡ 1 (mod 15)` 的特性先做 modulo reduction。

乘法部分則將 multiplier 拆成 bit-wise partial products：

```text
A
A × 2
A × 4
A × 8
```

每一步都先做 modulo 15，再依 multiplier bit 相加，因此 X path 可以使用 shift、add 與比較完成 modular multiplication。

最後再透過 `MOD_15_PLUS_1` 完成 `mod 15 + 1`。

### Backward Division

Backward mode 需要 element-wise division。

整個 design 只使用 **1 組 `DIV_8_BY_4`**，再依照 `cc_lsb` 逐 element 重複使用：

```text
Numerator
    ↓
8-bit / 4-bit Divider
    ↓
Quotient
    ↓
Write Back A / B
```

Divider 使用 combinational restoring division，以 shift、compare 與 subtract 逐 bit 產生 quotient，不使用 DesignWare IP。

### XOR / Pointwise Operation

Forward / Backward 中間結果需要 XOR 與 pointwise multiplication。

設計中使用：

- 4 組 `MULT_4X8`
- 4 組 `XOR_12X8`

並依照目前 stage 切換 input，因此不需要為 X1 / X2 或 Forward / Backward 各放一套硬體。

```text
cg_en = 0
   ↓
Clock Gating Disabled

cg_en = 1
   ↓
Enable Condition
   ↓
GATED_OR
   ↓
Register Clock
```

這樣可以避免大量不需要更新的 register 持續 switching，同時也避免用一顆 clock gate 同時驅動太多 DFF 造成過大的 fanout。

### Sequential Equivalence Checking

Clock Gating 不能改變 design 的 functional behavior，因此除了原本不含 clock gating 的版本，也需要驗證加入 clock gating 後的版本。

```text
Original RTL
     ↓
Clock Gating RTL
     ↓
JasperGold SEC
     ↓
Sequentially Equivalent
```

當 `cg_en = 0` 時，加入 clock gating 的 design 應該與原始 RTL 行為相同；開啟 `cg_en` 後，也必須確認 clock gating 不會影響最後的 `out_valid / out_data`。

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
