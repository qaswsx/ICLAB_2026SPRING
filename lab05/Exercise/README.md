# Lab05 — Diffusion Model

本次 Lab 實作 **W4A8 Diffusion Model (DM)**。  
輸入為 64 × 64 grayscale noisy image，依序經過 Down Sampling Convolution、Transformer、Up Sampling Convolution、Interpolation 與 Denoise，並依照 `i_iter` 重複執行 1 ~ 7 次。

---

## Specification

主要限制：

- Weight：4-bit signed
- Activation / Image：8-bit
- Input Image：64 × 64 grayscale
- Iteration：1 ~ 7
- Interpolation：3 modes
- Clock period ≤ 20 ns
- 每個 iteration latency ≤ 150,000 cycles
- Total Area ≤ 9,000,000
- Non-Comb Area ≤ 1,000,000
- 必須使用 SRAM
- 禁止使用 DesignWare IP
- Function Validity：70%
- Performance：30%

Goal：

- Average Latency < 800,000 ns / iteration
- Performance < 8.0 × 10^18

Performance 計算方式：

`Total Area × Non-Comb Area × Total Latency`

其中：

`Total Latency = Clock Period × Latency (1 iteration)`

---

## Design

使用 15-state FSM 控制 `Down Conv → QKV → Attention → FFN → Up Conv → Interpolation → Denoise`。  
總共使用 **5 顆 SRAM、3 種規格** 保存 weight、image 與 intermediate data，並重複利用 SRAM，Q 則在需要時重新計算。  
主要矩陣運算共用一組 16-way MAC，固定倍率的 normalization / interpolation 大量使用 shift、bit slicing 與 add。  
SRAM read、MAC 與 summation 之間加入 pipeline FF，讓較長的 arithmetic path 分段。

---

### SRAM

因為 activation 與 weight 的資料量很大，所以主要資料都放在 SRAM，而不是全部使用 register。

總共使用 **5 顆 SRAM，3 種規格**：

| SRAM | Number | Usage |
|---|---:|---|
| `SRAM_82X64` | 1 | 儲存全部 weights |
| `SRAM_512X64` | 1 | 儲存 64 × 64 input / denoised image |
| `SRAM_256X128` | 3 | K、V、feature map / intermediate result |
| **Total** | **5** | **3 types** |

SRAM 也盡量重複利用：

- `ds_sram` 依序存放 Down Conv、Attention、FFN 的結果
- `v_sram` 在 Attention 完成後重新拿來存 Up Conv output，提供 Interpolation 使用
- `image_sram` 在每次 denoise 後直接寫回新的 image，下一個 iteration 繼續使用

另外沒有另外配置 Q SRAM，而是每次 Attention 處理一個 query 時重新計算 Q，只保留目前的 Q vector，減少 memory area。

## Result

| Item | Result |
|---|---:|
| Demo | 1 |
| CT | 6.1 |
| Latency | 97146 cycles |
| Total Area | 2445163.059526 |
| Non-Comb Area | 209958.438362 |
| Perf | 3.04226E+17 |
| Score | 96.67 |
| Rank | 8 |

---

## 心得

這次 Lab 最大的難點是 **資料量非常大**，如果直接把 weight、feature map 和 image 全部存在 register，Area 會直接爆掉，因此 SRAM 的配置與重複利用變得非常重要。

在硬體資源上，我只做一組 16-way shared MAC，讓 Down Conv、QKV、Attention、FFN 與 Up Conv 共用相同的 multiplier 與 accumulator，而不是每個 stage 都各放一套硬體。

Transformer 的資料量也很大，因此 K、V 使用 SRAM 保存，但 Q 不另外配置 SRAM，而是在需要處理該 query 時重新計算，用 latency 換取較小的 memory area。

另外題目中很多 normalization 都是固定 2 的次方，因此大量使用 shift、bit slicing 與加法取代除法或額外 multiplier，Interpolation 也用 shift-add 完成。

這次因為 Perf 會看 Non-comb area，也就是非 SRAM 的 area，所以我開了 5 顆，並且盡量讓他們都共用不要浪費。然後這次的整個 flow 也都在 pdf 寫得很清楚，只是順序有點亂而已，如果想要的話是也可以像 lab4 用刻的，但我懶了XD。然後這次我也記得把運算盡量用 shift 來代替，也可以省不少面積。
