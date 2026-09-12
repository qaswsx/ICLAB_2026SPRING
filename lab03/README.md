# Lab03 — Tree Harvester

本次 Lab 實作 **Tree Harvester**，透過 AXI4-Lite 存取四個 DRAM banks，支援 `READ / WRITE / CALC / SORT` 四種 operation。

除了 HARVESTER 外，也需要自行完成 DRAM Controller，將 AXI4-Lite request 轉成 ACT、READ、WRITE、PRE 等 DRAM command。

---

## Specification

主要限制：

- 4 DRAM Banks
- Data width：64 bits
- Clock period ≤ 40 ns
- 每個 operation latency ≤ 10,000 cycles
- HARVESTER、DRAM_CTRL area 各 ≤ 7,500,000
- Test Bench：45%
- Design Functionality：30%
- Performance：25%

Performance 計算方式：

`Cycle Time × Total Latency × Area²`

其中：

`Area = HARVESTER Area + DRAM_CTRL Area`

---

## PATTERN

這次除了 design 之外，也需要自行完成 `PATTERN.v`，負責產生 random pattern、計算 golden answer，並檢查 design 是否符合規格。

PATTERN 會隨機產生 READ / WRITE / CALC / SORT 四種 operation，其中比例約為 `1 : 1 : 3 : 3`。

Golden answer 也直接在 PATTERN 內計算：

- READ：直接從 golden DRAM 取得資料
- WRITE：產生 random data 並同步更新 golden DRAM
- CALC：使用 recursive task 計算 Prefix Expression Tree
- SORT：將 1024 筆資料依 value 排序，value 相同時再比較原始 address

另外也需要檢查 MAIN 與 AXI specification，例如 reset、latency、output cycle、DRAM correctness，以及 AXI 的 stability、dependency、address range 與 timeout。

```text
Random Pattern
     ↓
Golden Calculation
     ↓
Run Design
     ↓
Output / DRAM Check
     ↓
AXI Protocol Check
```

---

## Design

`PATTERN.v` 負責產生 READ / WRITE / CALC / SORT 測資、Golden Answer 與 AXI specification checking。  
`DRAM_CTRL` 以 queue 搭配 bank / row 狀態控制 DRAM，並利用 bank interleaving 與 outstanding request 減少等待。  
CALC 使用 depth-8 stack 走訪 Prefix Expression Tree；SORT 則將 1024 筆資料拆成小區塊排序後再 merge，並善用 DRAM Row 63 暫存中間資料。

---

## Result

| Item | Result |
|---|---:|
| Demo | 1 |
| CT | 5.7 |
| Latency | 660996 |
| Area | 76394.1 + 1130178 |
| Perf | 5.48504E+18 |
| Score | 103 |
| Rank | 1 |

---

## 心得

這次 Lab 最大的難點不是單純的運算，而是 **DRAM access latency**。

因此優化重點放在 bank interleaving、outstanding request 與 sorting flow，盡量讓 DRAM 的等待時間可以和其他操作重疊，減少 idle cycle。

CALC 的部分也很麻煩，走訪 Prefix Expression Tree 時，除了要一路往下讀節點，還需要記住尚未處理的 right pointer，因此使用 stack 保存 operator、pointer 與中間結果。

SORT 一共有 1024 筆資料，如果全部存在內部硬體會造成很大的 area，因此改成將資料拆成小區塊排序，再逐步 merge。同時善用 DRAM 的 **Row 63 作為 temporary buffer**，避免所有中間資料都放在內部 register / memory。一開始忘記可以使用 Row 63，合成後 area 一直超過 **10,000,000**，本來要放棄了，後來隊友提醒我可以把部分暫存資料搬到 DRAM 後才明顯下降，感謝我的隊友。

除了降低 latency，這題的 perf 也會受到 area 影響，因此設計時也盡量共用硬體，例如 WRITE 與 SORT 共用 local buffer、READ / WRITE 共用 DRAM controller 的 bank control，以及 CALC 的 ADD / SUB 共用同一條 datapath，在 latency 與 area 之間做取捨。
