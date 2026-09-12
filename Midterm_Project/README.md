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


## Design

整體採用 **multi-cycle FSM**，兩個 core 共用 ALU、Multiplier、Data AXI 與主要 control，透過 `thread_id` 切換目前執行的 core。  
Instruction 使用一顆 **64 × 16 shared SRAM cache**，cache miss 時一次 burst 讀取 32 筆 instruction，兩個 core 用最高 address bit 分區。  
如果同一個 Instruction Counter 發生 STORE / LOAD dependence，會調整兩個 core 的執行順序，確保 LOAD 讀到最新資料。  
MULT 不直接放 16 × 16 multiplier，而是使用同一顆 **9 × 9 signed multiplier** 分四次計算 partial products，再 shift / accumulate 成 32-bit result。

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
