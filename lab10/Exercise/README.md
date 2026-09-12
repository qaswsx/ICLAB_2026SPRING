# Lab10 — Coverage & Assertion

本次 Lab 延續 Lab09 的 **Dessert Shop Simulator (DSS)**，主要使用 SystemVerilog 完成驗證環境。

需要自行撰寫：

- `PATTERN.sv`：產生 10000 組 pattern、計算 Golden Answer，並檢查 DSS output
- `CHECKER.sv`：建立 Functional Coverage 與 SVA Assertions

---

## Specification

Pattern 數量固定為：

`10000 patterns`

Coverage 共 7 項：

- 8 種 Dessert Type，每種至少 100 次
- 3 種 Order Mode，每種至少 100 次
- Dessert Type × Order Mode Cross Coverage，每個組合至少 100 次
- 7 種 Warning，每種至少 40 次
- 5 種 Action 的所有 Transition，每種 transition 至少 200 次
- Restock Amount `[0:2047]` 切成 128 bins，每個 bin 至少 5 次
- Complete 至少 1500 次

Assertion 共 9 項：

- Reset 後所有 output 為 0
- 每個 operation latency < 1000 cycles
- `complete = 1` 時必須為 `No_Warn`
- Input valid 間隔必須為 1 ~ 4 cycles
- 所有 input valid 不可 overlap
- `out_valid` 只能維持 1 cycle
- 下一筆 operation 必須在 `out_valid` 結束後 1 ~ 4 cycles 進入
- Input value 與 Date 必須合法
- `AR_VALID` 與 `AW_VALID` 不可同時為 High

評分：

- Coverage：40%
- Assertion：60%

---

## PATTERN

### Constrained Random

使用 `Randomizer` class 搭配 constraint 產生合法 input：

```text
Action
Dessert Type
Order Mode
Date
DRAM No.
Restock Amount
Hire Staff Number
Valid Delay
```

Date constraint 直接限制不同月份的合法日期，Restock Amount 限制在 `[0:2047]`，Staff 則限制在 `[1:30]`。

但這次沒有單純只靠 random pattern 撐 coverage，而是搭配大量 directed pattern。

### Directed Coverage

PATTERN 會依照 `patcount` 分成不同 phase：

```text
Pattern 0 ~ 5199
    ↓
Action Transition + Warning Directed Pattern

Pattern 5200 ~ 6399
    ↓
Dessert Type × Order Mode Directed Pattern

Pattern 6400 ~ 9999
    ↓
Random Safe Pattern
```

前半段利用固定的 action sequence，讓五種 Action 的 transition 可以平均被 hit。

```text
Make → Make
Make → Restock
Make → Hire Staff
...
Check Valid Date → Check Valid Date
```

Dessert Type 與 Order Mode 則將 8 × 3 共 24 種組合輪流產生，確保 cross coverage 可以收滿。

### Warning Generation

為了確保每種 warning 都能被 hit，不是只隨機挑 shop，而是直接搜尋目前的 `golden_DRAM`。

例如：

```text
find_make_safe_shop
find_make_stock_warn_shop
find_no_staff_shop
find_hire_staff_warn_shop
find_hire_balance_warn_shop
find_payday_balance_warn_shop
find_cvd_date_warn_shop
```

先根據目前 DRAM 內容找出能產生指定結果的 shop，再將該 `Data No.` 送給 DUT。

這樣即使前面的 operations 已經改變 DRAM 狀態，後面的 directed pattern 仍然可以根據最新的 Golden DRAM 找到適合的測資。

### Restock Coverage

Restock Amount 需要覆蓋 128 bins。

我直接依照 bin index 產生對應數值：

```text
Bin 0   → 8
Bin 1   → 24
Bin 2   → 40
...
Bin 127
```

五種 ingredient 使用不同 offset 輪流 hit bins，再搜尋可以安全執行該組 Restock Amount 的 shop。

### Golden Model

PATTERN 內部維護一份：

`golden_DRAM`

每次 operation 前先從 Golden DRAM 取出 shop data，再依照 Lab09 的規格自行計算：

```text
Input
  ↓
Golden Model
  ↓
Golden Complete / Warning
  ↓
Update Golden DRAM
  ↓
Compare DUT Output
```

支援完整的：

- Make and Sell
- Restock
- Hire Staff
- Pay Day
- Check Valid Date

如果 DUT 的 `complete` 或 `warn_msg` 與 Golden Answer 不同，就立即輸出 Wrong Answer 並停止 simulation。

另外也檢查 `out_valid / complete` 是否只維持一個 cycle。

---

## CHECKER

### Functional Coverage

CHECKER 共建立 7 組 covergroup。

| Coverage |內容 |
|---|---|
| SPEC1 | Dessert Type |
| SPEC2 | Order Mode |
| SPEC3 | Dessert Type × Order Mode |
| SPEC4 | Warning Message |
| SPEC5 | Action Transition |
| SPEC6 | Restock Amount |
| SPEC7 | Complete |

Dessert Type 與 Order Mode 不會在同一個 cycle 輸入，因此先使用 `Type_and_mode` class 保存前面的 Dessert Type，再在 `mode_valid` 時做 Cross Coverage。

```text
type_valid
    ↓
Save Dessert Type
    ↓
mode_valid
    ↓
Type × Mode Cross
```

Action 則使用 transition bins：

```text
[Make_and_Sell : Check_Valid_Date]
                ↓
[Make_and_Sell : Check_Valid_Date]
```

直接涵蓋所有 5 × 5 action transitions。

### Assertions

SVA 主要檢查 protocol 與 timing specification。

```text
Assertion 1 → Reset
Assertion 2 → Latency < 1000 cycles
Assertion 3 → Complete → No_Warn
Assertion 4 → Input valid interval / sequence
Assertion 5 → Input valid signals cannot overlap
Assertion 6 → out_valid behavior
Assertion 7 → Next operation interval
Assertion 8 → Legal input / date
Assertion 9 → AR_VALID and AW_VALID cannot overlap
```

不同 Action 的 input sequence 分別定義成 sequence，例如 Make and Sell：

```text
Action
  ↓ 1~4 cycles
Dessert Type
  ↓ 1~4 cycles
Order Mode
  ↓ 1~4 cycles
Date
  ↓ 1~4 cycles
Data No.
```

Restock 則會再接五次 `restock_valid`。

使用 `$onehot0` 檢查七個 input valid signals，確保同一個 cycle 最多只有一個 valid 為 High。

Date assertion 會依照月份分別限制：

```text
February        → 1 ~ 28
Apr/Jun/Sep/Nov → 1 ~ 30
Other Months    → 1 ~ 31
```

---

## Result

| Item | Result |
|---|---:|
| Demo | First demo |
| Pattern | 10000 |
| Coverage | 100% |
| Assertion | Pass |
| Score | 100 |
| Rank | First demo |

---

## 心得

這次 Lab 最大的重點是 **不能只靠 random pattern**。

一開始如果完全 random，很難保證 Warning、Action Transition、Restock Amount 與 Type × Mode Cross 都能達到指定 hit 次數，因此後來將 pattern 分成不同 phase，利用 directed pattern 先把難 hit 的 coverage 補滿，最後再搭配 random pattern。

另外因為每次 operation 都會修改 DRAM，不能只在一開始找一次特定 case，所以我直接維護 `golden_DRAM`，每個 pattern 都根據最新 DRAM 狀態搜尋能產生指定 warning 的 shop，讓 directed test 在跑到後面時仍然有效。

CHECKER 的部分則把 Lab09 的 protocol 規格全部轉成 SVA。這次比較熟悉 `covergroup / coverpoint / cross / transition bins`，以及 `##[1:4]`、`$onehot0` 等 assertion 寫法。

整體來說，這次最大的收穫是學到 Verification 不只是增加 pattern 數量，而是要根據 **Coverage Hole** 主動設計測資，並利用 Assertion 即時抓出違反 protocol 的行為。
