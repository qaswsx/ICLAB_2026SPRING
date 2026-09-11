# Lab04 — Convolution and Deconvolution Network Accelerator

本次 Lab 實作 **Convolution and Deconvolution Network Accelerator (CDNA)**。  
輸入 8 × 8、2 channels 的 image，先經過 Min-Max Scaling，再依序完成 Convolution、Max Pooling、Activation、Unpooling 與 Deconvolution，最後重建回 8 × 8、2 channels 的 output。

---

## Specification

輸入支援：

- Padding：Zero Padding / Replication Padding
- Activation：Sigmoid / Tanh / ReLU / Leaky ReLU
- Input Image：8 × 8 × 2 channels
- Kernel：3 × 3
- Weight：144 筆
- Output：128 cycles
- IEEE-754 single precision floating point
- Latency ≤ 1200 cycles
- Area ≤ 10,000,000
- Clock period ≤ 50 ns
- Function Validity：70%
- Performance：30%

Performance 計算方式：

`Area × (Computation Time)²`

其中：

`Computation Time = Latency × Clock Period`

---

## Design

### Counter-Based Control

整體控制沒有使用傳統 FSM，而是以 `global_cnt` 作為主要排程依據。

依照不同 cycle range 開啟 Normalization、Convolution、Pooling、Unpooling 與 Deconvolution，並搭配 `conv_cnt`、`pool_cnt`、`unpool_cnt` 等 local counter 控制 pixel position、channel 與目前的運算 index。

```text
global_cnt
    ↓
Stage Enable
    ↓
Normalization / Conv / Pool / Unpool / Deconv / Activation
```

由於整個 encoder-decoder 的執行順序固定，因此直接使用 counter 排程，可以省掉較複雜的 FSM state transition。

### Min-Max Scaling

輸入 image 會先分別找出兩個 channel 的 maximum 與 minimum，再做 Min-Max Scaling：

```text
(pixel - min) / (max - min)
```

兩個 channel 共用 normalization datapath，並共用 comparator 追蹤 max / min，減少重複的 floating-point IP。

### Convolution / Deconvolution

Convolution 與 Deconvolution 使用相同的 3 × 3 MAC datapath。

```text
3×3 Image Window
      ↓
36 FP Multipliers
      ↓
Adder Tree
      ↓
2 Output Channels
```

一次平行計算兩個 input channels 與兩個 output channels，共使用 36 顆 floating-point multiplier。

L1 Convolution、L2 Convolution、Deconvolution 1 與 Deconvolution 2 共用同一組 MAC datapath，只依照目前 stage 切換對應的 weight。

### Pipeline / FF Placement

因為 floating-point IP 的 combinational path 很長，所以主要在大型運算之間加入 FF，把 critical path 切短。

Convolution / Deconvolution 的 MAC pipeline：

```text
Padding / image_reg
        ↓
      FF
 (mul / conv_mul)
        ↓
   DW_fp_mult
        ↓
      FF
    (mul_ff)
        ↓
 DW_fp_sum3 L1
        ↓
      FF
  (add_s1_reg)
        ↓
 DW_fp_sum3 L2
        ↓
      FF
   (ch*_reg)
        ↓
   DW_fp_add
```

Encoder 上半部的資料流是：

```text
Convolution
    ↓
   FF
(pool_in_reg)
    ↓
Max Pooling
    ↓
Activation Pipeline
```

也就是 **Convolution 做完、進 Max Pooling 前會再擋一層 FF**。  
Pooling 後不另外再多塞一層 dedicated FF，因為 Activation 本身入口就有 register。

Activation 的慢路徑則是：

```text
Activation Input
      ↓
     FF
      ↓
 DW_fp_exp
      ↓
     FF
      ↓
 DW_fp_add
      ↓
     FF
      ↓
 DW_fp_div
      ↓
     FF
```

Decoder 下半部的順序相反，因此主要利用 `image_reg` 當 stage 之間的 storage：

```text
Activation
    ↓
 image_reg
    ↓
Unpooling
    ↓
 image_reg
    ↓
Padding
    ↓
Deconvolution
    ↓
Activation
```

Unpooling 的結果會直接寫回 `image_reg`，下一層 Deconvolution 再從 `image_reg` 讀取，因此這裡不需要再額外插一組 dedicated FF，避免重複增加 register 與 latency。

### Max Pooling & Unpooling

Max Pooling 使用 2 × 2 window 取最大值，同時記錄最大值所在的位置。

這些 position information 會保留下來，Decoder 做 Unpooling 時再將數值放回原本的位置，其餘位置補 0。

Max Pooling 使用的 comparator 也與輸入階段尋找 max / min 的 comparator 共用。

### Activation

支援四種 activation：

- Sigmoid
- Tanh
- ReLU
- Leaky ReLU

Sigmoid 與 Tanh 使用 `DW_fp_exp`、`DW_fp_add` 與 `DW_fp_div` 計算。

ReLU 與 Leaky ReLU 不使用額外的 floating-point multiplier，而是直接利用 IEEE-754 的 sign 與 exponent 做判斷與縮放。

另外針對 ReLU / Leaky ReLU 設計 fast path，可以跳過 Sigmoid / Tanh 使用的 Exp 與 Div pipeline，降低 latency。

### DesignWare IP

| IP Type | Number | Usage |
|---|---:|---|
| `DW_fp_mult` | 36 | Convolution / Deconvolution multiplication |
| `DW_fp_sum3` | 16 | MAC adder tree |
| `DW_fp_add` | 7 | Convolution、Normalization、Activation |
| `DW_fp_cmp` | 2 | Max / Min tracking、Max Pooling |
| `DW_fp_div` | 3 | Min-Max Scaling、Sigmoid / Tanh |
| `DW_fp_exp` | 2 | Sigmoid / Tanh |
| **Total** | **66** | **6 types** |

---

## Result

| Item | Result |
|---|---:|
| Demo | 1 |
| CT | 31.5 |
| Latency | 6224 |
| Area | 6655195.927 |
| Perf | 2.55812E+17 |
| Score | 99.65 |
| Rank | 2 |

---

## 心得

這次 Lab 所有運算都要用 IP，單顆 IP 的 area 和 delay 都比一般整數運算大很多，因此 IP 數量、硬體共用與 pipeline 的安排會直接影響 performance。

Convolution 與 Deconvolution 的計算方式相同，所以我讓四個 convolution stages 共用同一組 36 顆 multiplier 與 adder tree，而不是每一層各放一套硬體。

在 timing 上，主要做法是在 floating-point 運算之間插入 FF。MAC 內部在 multiplier 與每層 adder tree 之間都切 pipeline，Encoder 則在 Convolution 輸出進入 Max Pooling 前再擋一層 FF。Decoder 因為資料流方向相反，Unpooling 與 Activation 的結果本來就會寫回 `image_reg`，因此直接利用 `image_reg` 當 stage register，避免再重複插入額外 FF。

另外也盡量共用其他 IP，例如 Max Pooling 與 Min-Max Scaling 共用 comparator，Normalization 的兩個 channel 共用同一套 datapath。

Activation 則將 ReLU / Leaky ReLU 與 Sigmoid / Tanh 分開處理，簡單的 activation 直接利用 bit operation 完成並走 fast path，避免經過不必要的 Exp 與 Div，降低 latency。

這題主要就是在 **Latency、Area、IP 數量與 Pipeline Depth** 之間做取捨，盡量讓 IP 可以被不同 stage 重複使用。

然後我這份比較特別是沒有寫 FSM，全程用數 Counter，我自己覺得如果想要摸清楚整個 flow，可以嘗試看看這個 lab 自己刻 Counter，雖然有點累就是了，但可以很清楚地看看這條路徑走了多長，需不需要切 Pipeline，我覺得對後面的 Lab 也是有幫助，當然如果你是大神就另當別論，畢竟我是小菜雞。
