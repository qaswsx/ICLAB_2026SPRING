# Midterm Project — Customized ISA Processor

本次 Midterm Project 實作 **Dual-Core Customized ISA Processor (DCCPU)**。  
系統包含兩個 16-bit CPU cores、兩個 Instruction DRAM 與一個共用 Data DRAM，並透過 AXI4 介面完成 instruction fetch 與 Load / Store。

兩個 core 支援 R-type、MULT、I-type 與 J-type 指令，並需要依照相同 Instruction Counter 的規則處理兩個 core 的執行順序與 memory dependence。

---

## Specification

主要限制：

- Dual-Core
- Data width：16 bits
- Register：8 × 16-bit / core
- 2 個 Instruction DRAM
- 1 個 shared Data DRAM
- AXI4 interface
- Clock period ≤ 20 ns
- Stall 不可連續超過 2,000 cycles（Function）
- Stall 不可連續超過 100,000 cycles（Performance）
- Total Area < 4,000,000
- 必須使用 SRAM
- 禁止 DesignWare IP
- RTL / Synthesis / Gate Correctness：60%
- Performance：30%
- PATTERN：10%

支援指令：

`ADD / SUB / AND / OR / NAND / NOR / XOR / SLT / MULT / ADDI / SUBI / LOAD / STORE / BEQ / JUMP`

Performance 計算方式：

`Total Cycle × Clock Period × Area²`

---

## PATTERN

Midterm Project 另外需要自行完成 `PATTERN.v`。

PATTERN 需要同時具備：

- 產生兩個 Instruction DRAM 與一個 Data DRAM 的內容
- 依照 instruction 自行計算 Golden Answer
- 檢查兩個 core 的 registers
- 每 50 個 instructions 檢查 Data DRAM
- 支援 debugging

---

## Design

### Multi-Cycle FSM

這份設計沒有使用 5-stage pipeline，而是採用 **multi-cycle FSM**。

```text
Fetch Instruction
      ↓
Decode / Read Register
      ↓
Execute
      ↓
Load / Store / MULT
      ↓
Write Back
      ↓
Finish Two Cores
```

主要 states 包含：

`FETCH_ADDR / FETCH_DATA / EXECUTE / MULT_WAIT / DATA_READ / DATA_WRITE / EXEC_DONE`

兩個 core 共用同一套 execution datapath，透過 `thread_id` 切換目前執行的 core。

這樣可以避免兩個 core 各自配置完整 ALU、Multiplier 與 Data AXI controller，降低 area。

### Shared Instruction Cache

Instruction 不會每次都直接到 DRAM 讀取，而是使用一顆 **64 × 16 SRAM** 作為 shared instruction cache。

每次 cache miss 時，AXI 一次 burst 讀取 32 筆 instructions：

```text
Instruction DRAM
      ↓
32-word AXI Burst
      ↓
Shared 64 × 16 SRAM
      ↓
Instruction Register
```

SRAM address 的最高 bit 使用 `thread_id`：

```text
{ thread_id, instruction address }
```

因此同一顆 SRAM 的前後兩半分別給 Core 1 與 Core 2 使用。

兩個 core 各自保留 `cache_tag` 與 `cache_valid`，當 PC 落在目前 cache line 時直接從 SRAM 取 instruction，減少高 latency DRAM access。

### Dual-Core Scheduling

兩個 core 在相同 Instruction Counter 下，需要完成兩條 instruction 後才一起將 `stall_1`、`stall_2` 拉低。

```text
Fetch Core 1 + Core 2
        ↓
Decide Execute Order
        ↓
Execute First Core
        ↓
Execute Second Core
        ↓
stall_1 = stall_2 = 0
```

一般情況先執行 Core 1。

如果其中一個 core 是 STORE，則調整 execution order，讓 STORE 在另一個 core 的 LOAD 前完成，確保 LOAD 可以取得最新的 Data DRAM value。

### Shared ALU

ALU 也盡量共用硬體。

ADD、SUB、ADDI、SUBI、SLT 與 Load / Store address calculation 共用同一條 add / subtract datapath：

```text
rs
 ↓
Shared Add / Sub
 ↓
ALU Result / Memory Address / SLT
```

AND / OR 則先共用一組 bitwise datapath，再利用 inversion 產生 NAND / NOR。

因此不需要為每一種 instruction 各自放一套 arithmetic hardware。

### MULT

16 × 16 signed multiplication沒有直接使用一顆完整的 16-bit multiplier。

我將 operand 拆成 high / low 8 bits：

```text
A = {A_high, A_low}
B = {B_high, B_low}
```

再用 **同一顆 9 × 9 signed multiplier** 分四次計算：

```text
A_low  × B_low
A_high × B_low
A_low  × B_high
A_high × B_high
```

最後依照位置 shift 後累加成 32-bit result。

```text
9×9 Multiplier
     ↓
Partial Product
     ↓
Shift
     ↓
Accumulator
     ↓
32-bit Result
```

這樣用多幾個 cycles 換取較小的 multiplier area。

最後將高 16 bits 寫入 `rd`，低 16 bits 寫入 `rl`。

### AXI Data Access

Load / Store 透過共用 Data AXI interface 存取 Data DRAM。

Load：

```text
Address Calculation
      ↓
AR Channel
      ↓
R Channel
      ↓
Register Write Back
```

Store：

```text
Address Calculation
      ↓
AW Channel
      ↓
W Channel
      ↓
B Response
```

Memory address calculation 也直接共用前面的 Add / Sub datapath。

---

## Result

| Item | Result |
|---|---:|
| Demo | 1 |
| CT | 3.8 |
| Latency | 135203 |
| Area | 131812.5 |
| Perf | 8.92654E+15 |
| Score | 103.95 |
| Rank | 3 |

---

## 心得

這次 Project 最大的難點是 **Dual-Core、AXI 與 Data Dependence** 要同時處理。

兩個 core 雖然各自有 PC、register file 與 instruction，但如果各自做一整套 execution hardware，area 會非常大，因此最後讓兩個 core 共用 ALU、Multiplier、Data AXI 與主要 FSM，再依照 `thread_id` 輪流執行。

Instruction DRAM 的 latency 很高，所以加入 shared instruction cache。兩個 core 共用同一顆 SRAM，只用最高 address bit 區分 core，再搭配各自的 tag / valid，減少重複 SRAM 的 area。

MULT 也是主要的 area 優化之一。原本如果直接使用完整 16 × 16 multiplier，面積會比較大，因此改成一顆 9 × 9 multiplier 分四次計算 partial products，用 latency 換 area。

另外因為只有一個 Data DRAM，同一個 Instruction Counter 下如果一個 core STORE、另一個 core LOAD，就必須先完成 STORE，再讓 LOAD 讀取，否則可能讀到舊資料。

這題的 Perf 是 `Total Cycle × Clock Period × Area²`，Area 的影響非常大，因此除了降低 DRAM latency，也花很多時間在 **SRAM 共用、Datapath 共用與 Multiplier 縮小**，在 latency 與 area 之間做取捨。

並且我這次只開一顆 64 × 16 的 SRAM，照理來說應該開更大的啦，但我試了 128 × 16、256 × 16，area 都會太大且 latency 沒有少很多所以才開 64 × 16。

然後 Memory 的部分大家真的要仔細看要把那些 .lib、.v 放到對的 library，不然 demo 出來可能自己這邊過了但助教那邊沒過，我就是這樣被扣了 naming error，也感謝英椅大助只算我 naming error。愛英椅。
