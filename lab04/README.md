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

整體以 `global_cnt` 搭配 local counter 排程，Convolution / Deconvolution 共用同一組 MAC，總共使用 **66 顆、6 種 DesignWare FP IP**。  
MAC 在 multiplier 與 adder tree 各級之間插入 FF，Encoder 另外在 Convolution 進 Max Pooling 前擋一層 `pool_in_reg`。  
Decoder 的流程方向相反，Unpooling 與 Activation 的結果會直接寫回 `image_reg`，因此利用 `image_reg` 當 stage register，不再重複插 FF。  
Max Pooling / Min-Max Scaling 也共用 comparator，ReLU / Leaky ReLU 則走較簡單的 fast path。

---

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

還有就是其實 Latnecy 應該可以再少一點，我好像多切了一拍，但我那時候已經數到頭昏眼花了，所以再切 pipeline 前可以先想好要開幾顆 IP，什麼樣的 IP，還有要在哪裡檔 FF，這樣就會比較輕鬆。
