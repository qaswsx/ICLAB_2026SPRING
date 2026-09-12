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

### SystemVerilog Datatype

在 `Usertype.sv` 中使用 `enum / struct / union` 定義 action、warning、dessert type、order mode 與輸入資料格式。

主要 datatype：

```text
Action
Warn_Msg
Dessert_Type
Order_Mode
Date
Data_Dir
Data
```

另外自行定義 FSM：

```text
IDLE
 ↓
GET_IN
 ↓
READ_DRAM
 ↓
CALC
 ↓
WRITE_DRAM
```

### Input Collection

Pattern 使用 7 組 valid signal 傳送不同類型的 input。

DSS 先將 action 保存，再依 operation 接收需要的參數：

```text
Make and Sell
→ Type → Mode → Date → Data No.

Restock
→ Date → Data No. → 5 Ingredients

Hire Staff
→ Staff → Date → Data No.

Pay Day
→ Date → Data No.

Check Valid Date
→ Date → Data No.
```

收到 `data_no_valid` 後即可開始送出 AXI read address，不需要再多等一個 state。

### AXI4-Lite / DRAM Access

一般 operation 需要讀取同一間 shop 的兩個 64-bit words：

```text
Word 0
Flour / Butter / Date / Milk / Sugar

Word 1
Fruit / Sales / Staff / Balance / Level
```

第一個 read address 為：

```text
{DRAM Base, Data No., 4'b0000}
```

第一筆 address handshake 完成後，直接接著送第二筆：

```text
{DRAM Base, Data No., 4'b1000}
```

`Check Valid Date` 只需要第一個 word 的日期，因此只讀一筆 DRAM data。

更新資料時也是相同概念，依 operation 決定是否需要寫回第二個 word，避免不必要的 DRAM access。

### Shared Arithmetic Datapath

五種 action 並沒有各自做一套 arithmetic hardware，而是依照 `calc_cnt` 共用相同 datapath。

主要共用：

```text
Stock Add / Sub
Balance Add / Sub
Multiplier
Divider
Warning Logic
```

例如原料增減共用 `stock_eng`：

```text
Current Stock
     +
Requested Amount
     ↓
Shared Add / Sub
     ↓
Overflow / Underflow
     ↓
Final Stock
```

Make and Sell 用 subtraction 檢查庫存是否足夠；Restock 則用 addition 並做 saturation 到 4095。

### Multiplier Reuse

價格、補貨成本、招募費與薪資都會用到乘法，因此沒有為每一個公式各放一顆 multiplier。

設計使用同一組 multiplication datapath，透過 `mul_a_r / mul_b_r` 在不同 `calc_cnt` 切換 operand。

8-bit multiplier operand 另外拆成 high / low 4 bits：

```text
A × B[3:0]
A × B[7:4]
```

先產生兩個 partial products，再將 high part 左移 4 bits 相加：

```text
Low Partial Product
        +
High Partial Product << 4
        ↓
Full Product
```

同一組 datapath會重複使用在：

- Dessert Price
- Restock Cost
- Hire Staff Cost
- Salary

### Shift Optimization

Order Mode 的倍率固定為 1、4、8，因此不另外使用 multiplier：

```text
Single     → original
Family Set → << 2
Party Pack → << 3
```

補貨 unit cost 中的固定倍率也盡量使用 shift 與 add 組合，降低額外 multiplier 的使用量。

### Make and Sell

依照 dessert type 逐項取得五種 ingredient 的需求量，再搭配 order mode 產生實際需求。

五種 ingredient 共用同一組 stock engine，以 `calc_cnt` 依序檢查：

```text
Flour
 ↓
Butter
 ↓
Milk
 ↓
Sugar
 ↓
Fruit
```

如果任何一項不足，就提早結束後續計算並輸出 `Stock_Warn`。

Sales 達到升級門檻時需要：

```text
New Level = Level + Sales / Threshold
Sales     = Sales % Threshold
```

這裡沒有直接使用 `/` 與 `%`，而是使用多 cycle shift / compare / subtract 的方式逐 bit 計算 quotient 與 remainder。

### Restock

Restock 需要同時處理兩種數量：

```text
Requested Quantity
Actual Added Quantity
```

如果 stock 超過 4095，DRAM 最後仍更新到 4095，但 balance 只扣除真正能加入的數量。

因此每個 ingredient 會依序計算：

```text
Requested Cost
      ↓
Saturate Stock
      ↓
Actual Added Quantity
      ↓
Actual Cost
```

Requested Cost 用來判斷原始 restock request 是否付得起；Actual Cost 則用來更新最後 balance。

### Hire Staff / Pay Day

Hire Staff 與 Pay Day 共用大部分 cost datapath。

Hire Staff：

```text
Recruitment Fee
      ↓
Check Balance
      ↓
Update Staff
```

若 staff 超過 100，最後會 saturation 到 100，但只計算實際新增人數的費用。

Pay Day：

```text
Salary per Staff
      ↓
× Staff Count
      ↓
Check Balance
```

若 balance 不足，則執行 penalty：

```text
Level - 10
Staff / 2
Sales = 0
```

### Warning Priority

所有 warning 最後共用同一套 priority logic：

```text
Date_Warn
   ↓
No_Staff_Warn
   ↓
Stock_Warn
   ↓
Balance_Warn
   ↓
Restock_Warn
   ↓
Staff_Warn
   ↓
No_Warn
```

只要發生 warning，`complete` 就保持為 0。

Date warning 也會在讀完 DRAM 後提早判斷，若日期錯誤就不進入後續 CALC。

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
