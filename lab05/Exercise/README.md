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

### Shared MAC

主要運算共用一組 `PURE_MAC_16`，內含 16 組 multiplier。

```text
16 Inputs
   ↓
16 Parallel Multipliers
   ↓
Shared Accumulator
```

這組 MAC 會依照 FSM state 切換輸入，重複使用在：

- Down Sampling Convolution
- Q / K / V Linear Transformation
- Attention × V
- FFN
- Up Sampling Convolution

因此不需要為每個 stage 各自配置一套 multiplier。

Q × K 的 dot product 則另外使用 16 組 8-bit multiplier，先將 16 個乘積 register 起來，再做 summation。

### Down / Up Sampling Convolution

Down Sampling 使用 3 × 3 kernel、stride 4，將 64 × 64 image 轉成 16 × 16 × 16 feature map。

每次將同一個 pixel broadcast 給 16 個 output channels，使用 shared MAC 同時計算 16 個 channel，再累加 9 個 kernel positions。

Up Sampling 則將 16 input channels 合併成 1 output channel，一樣共用同一組 MAC datapath。

### Transformer

Transformer 包含：

```text
Linear Q / K / V
      ↓
Q × Kᵀ
      ↓
SoftMax
      ↓
Attention × V
      ↓
FFN
```

K 與 V 會先存入 SRAM，Q 則在每個 query 開始時重新計算。

SoftMax 不使用複雜的 exponential，而是依照題目規定使用 clipping、shift 與 fixed-point mapping 完成。

Attention 與 FFN 的 matrix multiplication 也共用前面的 16-way MAC。

### Shift Optimization

這次有大量固定倍率的 normalization，因此盡量直接用 shift / bit slicing 取代除法與部分乘法。

```text
Conv Normalization     → >> 6
Linear Normalization   → >> 4
Interpolation / 4      → >>> 2
× 2                    → << 1
× 3                    → x + (x << 1)
Noise Scaling          → >> 3
```

Interpolation 不直接使用 multiplier，而是先算相鄰 pixel 的 difference，再利用 shift 與加法產生 1/4、2/4、3/4 的 interpolation result。

### Pipeline / FF

為了降低 critical path，在 SRAM read、MAC 與較長的 arithmetic path 中間加入 pipeline FF。

Down Sampling 使用多級 valid / step pipeline：

```text
SRAM Read
   ↓
  FF
   ↓
Pixel Select
   ↓
  FF
   ↓
Shared MAC
   ↓
Accumulator
```

`PURE_MAC_16` 的 multiplier output 本身也會先 register，再送往後續 accumulator。

Q × K datapath 則是：

```text
16 Multiplications
       ↓
      FF
       ↓
   Summation
       ↓
      FF
```

Up Sampling 一樣使用多級 `valid_d1 ~ valid_d5` 對齊 SRAM、MAC 與 accumulator 的 latency。

Interpolation 則先將 `current / left / right / up / down` pixel 全部打一層 FF，再進行 difference、shift、clipping 與 denoise，最後再用兩級 valid pipeline 對齊 image SRAM 的讀取資料。

### Iterative Denoise

Interpolation 完成後，noise 會先右移 3 bits，再從目前的 image 中扣除：

`Denoised = Image - (Noise >> 3)`

如果還不是最後一個 iteration，8 個 denoised pixels 會重新 pack 成 64 bits 寫回 `image_sram`。

最後一個 iteration 則直接透過 `o_valid / o_data` 輸出，不需要再額外存一份完整 image。

---

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

這次因為 Perf 會看 Non-comb area，也就是非 SRAM 的 area，所以我開了 5 顆，並且盡量讓他們都共用不要浪費。然後這次的整個 flow 也都在 pdf 寫得很清楚，只是順序有點亂而已，如果想要的話是也可以像 lab4 用刻的，但我懶了XD。
