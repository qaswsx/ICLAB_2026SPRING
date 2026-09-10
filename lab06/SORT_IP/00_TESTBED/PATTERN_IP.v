// // // // `ifdef RTL
// // // //     `define CYCLE_TIME 20.0
// // // // `endif
// // // // `ifdef GATE
// // // //     `define CYCLE_TIME 20.0
// // // // `endif

// // // // module PATTERN #(parameter IP_WIDTH = 8)(
// // // //     //Output Port
// // // //     IN_character,
// // // // 	IN_weight,
// // // //     //Input Port
// // // // 	OUT_character
// // // // );
// // // // // ========================================
// // // // // Input & Output
// // // // // ========================================
// // // // output reg [IP_WIDTH*4-1:0] IN_character;
// // // // output reg [IP_WIDTH*5-1:0] IN_weight;

// // // // input [IP_WIDTH*4-1:0] OUT_character;

// // // // // ========================================
// // // // // Pattern Start
// // // // // ========================================



// // // // endmodule

// // // `ifdef RTL
// // //     `define CYCLE_TIME 20.0
// // // `endif
// // // `ifdef GATE
// // //     `define CYCLE_TIME 20.0
// // // `endif

// // // module PATTERN #(parameter IP_WIDTH = 8)(
// // //     //Output Port
// // //     output reg [IP_WIDTH*4-1:0] IN_character,
// // //     output reg [IP_WIDTH*5-1:0] IN_weight,
// // //     //Input Port
// // //     input [IP_WIDTH*4-1:0] OUT_character
// // // );

// // // // ========================================
// // // // Integer / Reg Declarations
// // // // ========================================
// // // integer i, p;
// // // integer total_patterns = 1000;  // 測試 1000 筆隨機測資
// // // integer error_count = 0;

// // // reg [4:0] weight_map [0:15];    // 用來記錄每個字元對應的權重 (當作 Golden Data)
// // // reg [3:0] char_out_array [0:IP_WIDTH-1];
// // // reg [4:0] weight_out_array [0:IP_WIDTH-1];

// // // // ========================================
// // // // Pattern Start
// // // // ========================================
// // // initial begin
// // //     // 1. 初始化 IN_character (根據規格，這是一個固定的連續數列)
// // //     IN_character = 0;
// // //     for (i = 0; i < IP_WIDTH; i = i + 1) begin
// // //         // 把 0 放在 LSB，IP_WIDTH-1 放在 MSB
// // //         IN_character[i*4 +: 4] = i;
// // //     end

// // //     $display("========================================");
// // //     $display("   Start SORT_IP Simulation (%0d bits)  ", IP_WIDTH);
// // //     $display("========================================");

// // //     // 2. 開始跑隨機測資
// // //     for (p = 0; p < total_patterns; p = p + 1) begin
        
// // //         // 產生隨機的 5-bit 權重 (0~31)
// // //         for (i = 0; i < IP_WIDTH; i = i + 1) begin
// // //             weight_map[i] = {$random} % 32; 
// // //             IN_weight[i*5 +: 5] = weight_map[i];
// // //         end

// // //         // 3. 等待組合邏輯運算穩定 (Soft IP 必須在 1 cycle 內算完)
// // //         #(`CYCLE_TIME);

// // //         // 4. 呼叫 Task 來檢查答案是否正確
// // //         check_output();
// // //     end

// // //     // 5. 輸出最終結果
// // //     if (error_count == 0) begin
// // //         $display("=================================================");
// // //         $display("    Congratulations! All %0d patterns PASS!    ", total_patterns);
// // //         $display("=================================================");
// // //     end else begin
// // //         $display("=================================================");
// // //         $display("    Simulation FAILED with %0d errors.         ", error_count);
// // //         $display("=================================================");
// // //     end
// // //     $finish;
// // // end

// // // // ========================================
// // // // Check Task (自動驗證邏輯)
// // // // ========================================
// // // task check_output;
// // //     integer k;
// // //     reg [3:0] c1, c2;
// // //     reg [4:0] w1, w2;
// // //     reg pass;
// // // begin
// // //     pass = 1;

// // //     // 將輸出的連續 bit 拆解成 Array，方便比對
// // //     for (k = 0; k < IP_WIDTH; k = k + 1) begin
// // //         char_out_array[k] = OUT_character[k*4 +: 4];
// // //         weight_out_array[k] = weight_map[char_out_array[k]]; // 查表找出該字元原本的權重
// // //     end

// // //     // 從 MSB 檢查到 LSB，確認是不是由大排到小
// // //     for (k = IP_WIDTH-1; k > 0; k = k - 1) begin
// // //         c1 = char_out_array[k];   // 較高位的字元 (期望權重較大)
// // //         c2 = char_out_array[k-1]; // 較低位的字元 (期望權重較小)
// // //         w1 = weight_out_array[k];
// // //         w2 = weight_out_array[k-1];

// // //         if (w1 < w2) begin
// // //             pass = 0; // 排序錯誤 (前面比後面小)
// // //         end else if (w1 == w2) begin
// // //             // 【平手判定 (Tie-Breaker)】
// // //             // 根據規定，權重相同時必須依據字元優先度來排
// // //             // 這裡預設字元編號越大 (例如 4 > 3)，優先度越高。
// // //             // 若你的硬體設計邏輯不同 (例如 0 優先度最高)，請把這裡的 `<` 改成 `>`
// // //             if (c1 < c2) begin
// // //                 pass = 0;
// // //             end
// // //         end
// // //     end

// // //     // 如果發生錯誤，印出波形數值方便 Debug
// // //     if (!pass) begin
// // //         $display("ERROR at pattern %0d", p);
// // //         $display("IN_weight : %h", IN_weight);
// // //         $display("OUT_char  : %h", OUT_character);
// // //         error_count = error_count + 1;
        
// // //         // 錯超過 10 筆就提早結束，避免洗畫面
// // //         if (error_count >= 10) begin
// // //             $display("Too many errors. Stopping simulation.");
// // //             $finish;
// // //         end
// // //     end
// // // end
// // // endtask

// // // endmodule

// // `define CYCLE_TIME 20

// // module PATTERN #(parameter IP_WIDTH = 8)(
// //     //Output Port
// //     IN_character,
// // 	IN_weight,
// //     //Input Port
// // 	OUT_character
// // );
// // // ========================================
// // // Input & Output
// // // ========================================
// // output reg [IP_WIDTH*4-1:0] IN_character;
// // output reg [IP_WIDTH*5-1:0] IN_weight;

// // input [IP_WIDTH*4-1:0] OUT_character;

// // // ========================================
// // // Parameter
// // // ========================================
// // real CYCLE = `CYCLE_TIME;
// // parameter PARRTRN_NUM = 30000;
// // integer i_pat, j_ip, k_ip;
// // integer t;
// // reg [3:0] character [0:IP_WIDTH-1];
// // reg [4:0] weight [0:IP_WIDTH-1];
// // reg [3:0] character_temp;
// // reg [4:0] weight_temp;

// // // String control
// // // Should use %0s
// // reg[9*8:1]  reset_color       = "\033[1;0m";
// // reg[10*8:1] txt_black_prefix  = "\033[1;30m";
// // reg[10*8:1] txt_red_prefix    = "\033[1;31m";
// // reg[10*8:1] txt_green_prefix  = "\033[1;32m";
// // reg[10*8:1] txt_yellow_prefix = "\033[1;33m";
// // reg[10*8:1] txt_blue_prefix   = "\033[1;34m";

// // reg[10*8:1] bkg_black_prefix  = "\033[40;1m";
// // reg[10*8:1] bkg_red_prefix    = "\033[41;1m";
// // reg[10*8:1] bkg_green_prefix  = "\033[42;1m";
// // reg[10*8:1] bkg_yellow_prefix = "\033[43;1m";
// // reg[10*8:1] bkg_blue_prefix   = "\033[44;1m";
// // reg[10*8:1] bkg_white_prefix  = "\033[47;1m";

// // //================================================================
// // // design
// // //================================================================

// // initial begin
// //     i_pat = 0;
// //     IN_character = 0;
// //     IN_weight = 0;

// //     for(i_pat = 0; i_pat < PARRTRN_NUM; i_pat = i_pat + 1) begin
// //         // input_task
// //         // intialize
// //         IN_character = 0;
// //         IN_weight = 0;
// //         // $display("PATTERN  No.%d", i_pat);

// //         for(j_ip = 0; j_ip < IP_WIDTH; j_ip = j_ip + 1) begin
// //             IN_character = IN_character << 4;
// //             IN_character = IN_character + (IP_WIDTH - j_ip - 1);
// //             // $display("IN_character[%1d] = %1d", IP_WIDTH - j_ip - 1, IP_WIDTH - j_ip - 1);
// //             character[j_ip] = IP_WIDTH - j_ip - 1;
// //         end
        
// //         for(k_ip = 0; k_ip < IP_WIDTH; k_ip = k_ip + 1) begin
// //             IN_weight = IN_weight << 5;
// //             t = $urandom_range(0, 31);
// //             IN_weight = IN_weight + t;
// //             // $display("IN_weight[%1d] = %1d", IP_WIDTH - k_ip - 1, t);
// //             weight[k_ip] = t;
// //         end

// //         // $display("--------------------");

// //         // bubble sort
// //         for(j_ip = 0; j_ip < IP_WIDTH - 1; j_ip = j_ip + 1) begin
// //             // Last i elements are already in place, so we don't need to check them
// //             for(k_ip = 0; k_ip < IP_WIDTH - j_ip - 1; k_ip = k_ip + 1) begin
// //                 if (weight[k_ip] < weight[k_ip + 1]) begin
// //                     // Swap weight[k_ip] and weight[k_ip + 1]
// //                     weight_temp = weight[k_ip];
// //                     weight[k_ip] = weight[k_ip + 1];
// //                     weight[k_ip + 1] = weight_temp;

// //                     // Swap character[k_ip] and character[k_ip + 1]
// //                     character_temp = character[k_ip];
// //                     character[k_ip] = character[k_ip + 1];
// //                     character[k_ip + 1] = character_temp;
// //                 end
// //             end
// //         end

// //         #CYCLE;

// //         // check_ans_task
// //         if(IP_WIDTH === 8) begin
// //             if(OUT_character[31:28] !== character[0]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[31:28] = %1d, it should be %1d", OUT_character[31:28], character[0]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end

// //             if(OUT_character[27:24] !== character[1]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[27:24] = %1d, it should be %1d", OUT_character[27:24], character[1]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end

// //             if(OUT_character[23:20] !== character[2]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[23:20] = %1d, it should be %1d", OUT_character[23:20], character[2]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end

// //             if(OUT_character[19:16] !== character[3]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[19:16] = %1d, it should be %1d", OUT_character[19:16], character[3]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end

// //             if(OUT_character[15:12] !== character[4]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[15:12] = %1d, it should be %1d", OUT_character[15:12], character[4]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end

// //             if(OUT_character[11:8] !== character[5]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[11:8] = %1d, it should be %1d", OUT_character[11:8], character[5]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end

// //             if(OUT_character[7:4] !== character[6]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[7:4] = %1d, it should be %1d", OUT_character[7:4], character[6]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end

// //             if(OUT_character[3:0] !== character[7]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[3:0] = %1d, it should be %1d", OUT_character[3:0], character[7]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end
// //         end else if(IP_WIDTH === 7) begin
// //             if(OUT_character[27:24] !== character[0]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[27:24] = %1d, it should be %1d", OUT_character[27:24], character[0]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end

// //             if(OUT_character[23:20] !== character[1]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[23:20] = %1d, it should be %1d", OUT_character[23:20], character[1]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end

// //             if(OUT_character[19:16] !== character[2]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[19:16] = %1d, it should be %1d", OUT_character[19:16], character[2]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end

// //             if(OUT_character[15:12] !== character[3]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[15:12] = %1d, it should be %1d", OUT_character[15:12], character[3]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end

// //             if(OUT_character[11:8] !== character[4]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[11:8] = %1d, it should be %1d", OUT_character[11:8], character[4]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end

// //             if(OUT_character[7:4] !== character[5]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[7:4] = %1d, it should be %1d", OUT_character[7:4], character[5]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end

// //             if(OUT_character[3:0] !== character[6]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[3:0] = %1d, it should be %1d", OUT_character[3:0], character[6]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end
// //         end else if(IP_WIDTH === 6) begin
// //             if(OUT_character[23:20] !== character[0]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[23:20] = %1d, it should be %1d", OUT_character[23:20], character[0]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end

// //             if(OUT_character[19:16] !== character[1]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[19:16] = %1d, it should be %1d", OUT_character[19:16], character[1]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end

// //             if(OUT_character[15:12] !== character[2]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[15:12] = %1d, it should be %1d", OUT_character[15:12], character[2]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end

// //             if(OUT_character[11:8] !== character[3]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[11:8] = %1d, it should be %1d", OUT_character[11:8], character[3]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end

// //             if(OUT_character[7:4] !== character[4]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[7:4] = %1d, it should be %1d", OUT_character[7:4], character[4]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end

// //             if(OUT_character[3:0] !== character[5]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[3:0] = %1d, it should be %1d", OUT_character[3:0], character[5]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end
// //         end else if(IP_WIDTH === 5) begin
// //             if(OUT_character[19:16] !== character[0]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[19:16] = %1d, it should be %1d", OUT_character[19:16], character[0]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end

// //             if(OUT_character[15:12] !== character[1]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[15:12] = %1d, it should be %1d", OUT_character[15:12], character[1]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end

// //             if(OUT_character[11:8] !== character[2]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[11:8] = %1d, it should be %1d", OUT_character[11:8], character[2]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end

// //             if(OUT_character[7:4] !== character[3]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[7:4] = %1d, it should be %1d", OUT_character[7:4], character[3]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end

// //             if(OUT_character[3:0] !== character[4]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[3:0] = %1d, it should be %1d", OUT_character[3:0], character[4]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end
// //         end else if(IP_WIDTH === 4) begin
// //             if(OUT_character[15:12] !== character[0]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[15:12] = %1d, it should be %1d", OUT_character[15:12], character[0]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end

// //             if(OUT_character[11:8] !== character[1]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[11:8] = %1d, it should be %1d", OUT_character[11:8], character[1]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end

// //             if(OUT_character[7:4] !== character[2]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[7:4] = %1d, it should be %1d", OUT_character[7:4], character[2]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end

// //             if(OUT_character[3:0] !== character[3]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[3:0] = %1d, it should be %1d", OUT_character[3:0], character[3]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end
// //         end else if(IP_WIDTH === 3) begin
// //             if(OUT_character[11:8] !== character[0]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[11:8] = %1d, it should be %1d", OUT_character[11:8], character[0]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end

// //             if(OUT_character[7:4] !== character[1]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[7:4] = %1d, it should be %1d", OUT_character[7:4], character[1]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end

// //             if(OUT_character[3:0] !== character[2]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[3:0] = %1d, it should be %1d", OUT_character[3:0], character[2]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end
// //         end else if(IP_WIDTH === 2) begin

// //             if(OUT_character[7:4] !== character[0]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[7:4] = %1d, it should be %1d", OUT_character[7:4], character[0]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end

// //             if(OUT_character[3:0] !== character[1]) begin
// //                 $display("==========================================================================");
// //                 $display("    Out is not correct at %-12d ps ", $time*1000);
// //                 $display("OUT_character[3:0] = %1d, it should be %1d", OUT_character[3:0], character[1]);
// //                 $display("==========================================================================");
// //                 #CYCLE;
// //                 $finish;
// //             end
// //         end else begin
// //             $display("==========================================================================");
// //             $display("    IP_WIDTH is not correct at %-12d ps ", $time*1000);
// //             $display("==========================================================================");
// //             #CYCLE;
// //             $finish;
// //         end
    
// //         $display("%0sPASS PATTERN NO.%d%0s",txt_blue_prefix, i_pat, reset_color);
// //     end


// //     $display("\033[1;35m For IP_WIDTH =  %1d \033[1;0m", IP_WIDTH);
// //     $display("\033[1;35m Pass All PATTERN, Congratulation! \033[1;0m");
// // end

// // endmodule















// `define CYCLE_TIME 20.0

// module PATTERN #(parameter IP_WIDTH = 8)(
//     //Output Port
//     IN_character,
//     IN_weight,
//     //Input Port
//     OUT_character
// );
// // ========================================
// // Input & Output
// // ========================================
// output reg [IP_WIDTH*4-1:0] IN_character;
// output reg [IP_WIDTH*5-1:0] IN_weight;

// input [IP_WIDTH*4-1:0] OUT_character;

// // ========================================
// // Parameter & Variables
// // ========================================
// real CYCLE = `CYCLE_TIME;
// parameter PATTERN_NUM = 1000;
// integer i_pat, j_ip, k_ip;
// integer t, ans_tmp;

// // 檔案指標與讀取暫存
// integer fin, fout, scan_in, scan_ans;
// reg [3:0] golden_char [0:IP_WIDTH-1]; 

// // String control
// reg[9*8:1]  reset_color       = "\033[1;0m";
// reg[10*8:1] txt_black_prefix  = "\033[1;30m";
// reg[10*8:1] txt_red_prefix    = "\033[1;31m";
// reg[10*8:1] txt_green_prefix  = "\033[1;32m";
// reg[10*8:1] txt_yellow_prefix = "\033[1;33m";
// reg[10*8:1] txt_blue_prefix   = "\033[1;34m";

// //================================================================
// // design
// //================================================================

// initial begin
//     i_pat = 0;
//     IN_character = 0;
//     IN_weight = 0;

//     // 開啟 Input 與 Output 測資檔案
//     fin  = $fopen("../00_TESTBED/input_ip7.txt", "r");
//     fout = $fopen("../00_TESTBED/output_ip7.txt", "r");

//     if (fin == 0 || fout == 0) begin
//         $display("%0s[ERROR] 無法開啟 input.txt 或 output.txt，請檢查路徑！%0s", txt_red_prefix, reset_color);
//         $finish;
//     end

//     for(i_pat = 0; i_pat < PATTERN_NUM; i_pat = i_pat + 1) begin
//         // intialize
//         IN_character = 0;
//         IN_weight = 0;

//         // 產生預設的 IN_character
//         for(j_ip = 0; j_ip < IP_WIDTH; j_ip = j_ip + 1) begin
//             IN_character = IN_character << 4;
//             IN_character = IN_character + (IP_WIDTH - j_ip - 1);
//         end
        
//         // 讀取 Input Weight
//         for(k_ip = 0; k_ip < IP_WIDTH; k_ip = k_ip + 1) begin
//             scan_in = $fscanf(fin, "%d", t);
//             if (scan_in == -1) begin
//                 // $display("%0s[INFO] Input 測資已讀到檔尾，總共跑了 %0d 筆，提早結束！%0s", txt_yellow_prefix, i_pat, reset_color);
//                 // 為了不破壞你原本的乾淨畫面，把檔尾提示藏起來，直接跳出迴圈
//                 disable test_loop; 
//             end
            
//             IN_weight = IN_weight << 5;
//             IN_weight = IN_weight + t;
//         end

//         // 讀取 Output Golden 答案
//         for(j_ip = 0; j_ip < IP_WIDTH; j_ip = j_ip + 1) begin
//             scan_ans = $fscanf(fout, "%d", ans_tmp);
//             if (scan_ans == -1) begin
//                 $display("%0s[ERROR] Output 測資提早結束，與 Input 數量不吻合！%0s", txt_red_prefix, reset_color);
//                 $finish;
//             end
//             golden_char[j_ip] = ans_tmp[3:0];
//         end

//         #CYCLE;

//         // Check Answer (動態切片比對法)
//         for(j_ip = 0; j_ip < IP_WIDTH; j_ip = j_ip + 1) begin
//             if (OUT_character[((IP_WIDTH - j_ip)*4 - 1) -: 4] !== golden_char[j_ip]) begin
//                 $display("==========================================================================");
//                 $display("%0s    Out is not correct at %-12d ps %0s", txt_red_prefix, $time*1000, reset_color);
//                 $display("OUT_character[%0d:%0d] = %1d, it should be %1d", 
//                           ((IP_WIDTH - j_ip)*4 - 1), 
//                           ((IP_WIDTH - j_ip)*4 - 4), 
//                           OUT_character[((IP_WIDTH - j_ip)*4 - 1) -: 4], 
//                           golden_char[j_ip]);
//                 $display("==========================================================================");
//                 #CYCLE;
//                 $finish;
//             end
//         end
    
//         // 🌟 這裡幫你加回來了！對齊你想要的格式：PASS PATTERN NO.      數字
//         $display("PASS PATTERN NO.      %0d", i_pat); 
//     end
    
//     // 用 block name 來跳出迴圈的標籤
//     begin : test_loop end

//     $display("\033[1;35m For IP_WIDTH =  %1d \033[1;0m", IP_WIDTH);
//     $display("\033[1;35m Pass All PATTERN, Congratulation! \033[1;0m");
//     $finish;
// end

// endmodule
























`ifdef RTL
    `define CYCLE_TIME 20.0
`endif
`ifdef GATE
    `define CYCLE_TIME 20.0
`endif

module PATTERN #(parameter IP_WIDTH = 8)(
    //Output Port
    IN_character,
	IN_weight,
    //Input Port
	OUT_character
);
// ========================================
// Input & Output
// ========================================
output reg [IP_WIDTH*4-1:0] IN_character;
output reg [IP_WIDTH*5-1:0] IN_weight;

input [IP_WIDTH*4-1:0] OUT_character;


`protected
)g#4#]KP#<Sg1TCSb.M5CC>@OYC^Y^^;g_0G=/JT\])8Da=>E]=]))[25Z#WLg<-
QV<&HOQJY&f+LVT:^Za\Ue4Y<Zd\W)W#FO/P-a9F[@I:ISZH[Z,4E?0X4B6[,&SP
b\)@@#EcMa_?2UZb)a7GIM4GUR6V:[.@Tb]5W-8#LPJY9J->6+V-604Q:U#6^,T3
W^/?S^B<\e.PY5.5&b7d_aN0(;#V@,bT\/G9(#>e.E))B9G8fUNf(-]FY==PSA0b
Rb3;:&KD-U)\ZTZ=?^19;C-.GO,@M3A13>=&K3^<3U6.AgaW(d9U(6N#6B5E+1]K
Jf091e>eMQT=Y;&@&e>;P9=@YcgA/B@S_;EGbU(<#/@cWd=,_:J2aR,VgQ6<E]&8
K/c,?<>_Z\cCGO#6#.5VH:]QB37XD)9II@3[+C:VFP8LFI_);&@1WA,abBO7F#0E
E0(4FCNL@RH0(1c)f1<-b3R<-)SL]c1ULW##9MWgP-&;IR3I_)/8V1<9A_W-cZQ6
RI?FLJgcXBSQEg4P=\CG<:1M4HI9<UcHgJ9c+Cbe=)RE@Q\U_8[dF-N6[TRecKdL
Q+Y.-D=H8)Q3M7@eI\JCJZ4bb];-3fa4+]J&Y?D(:OE0f#5-WCRZ+\7b>Y1VJ_H:
AWT^9N0]7UMY6SdOW,Ea(eP<<Qg9.?+bGKI3cEF,5ISO8>Hbc>65A9USeU78Ff=4
D5;d3#\AM5:42YZTdTaSgEW<08O6?KBOYAfV:QRHcHH&Z7GN#IR/4Y?((KQ;<4Vf
g&EY,eEB(a@8VV39]W-Oe]RAe2PV+BdR?4-gB3P+6WP55c>+UD;AU//1YE0._@6b
69R>7<8IBCb=^4ROg+K-HRW\I-HbRO_GcT?X3Z2@62>JWP)KdT?5RCSA0(Pc;.PL
=-K.?#QT8MZe0(2WORG,PSf+W_)+aGX(8QE.g+,M>\)ZaE]>7RBT:UR3R?>#C:LS
1I#HF4SGF&OT87XEWBDWLO=CaQ9>P+&\aEEe,K/_2F+1S#4VdId&=XFbFU;8G8TX
58&^dc,\JF/F./F<3[LESf9QgWL-eGbQ2>>K]YYAJY3.>W+OK631Fc)N(J9(3M4I
T<N0YAU]g;>Y-D]<X)G];U^EK@d.Tc?&:F)][f&&f;.:XS&GU/Ma0B;[/-1B47R[
/SI)4E=>:R,WFFPT/fI=G25@\W443:WUAIH;S]6RZfE0c@2V;-d:f-ge2aQ\9@0N
YUKX8T&\\I77MUQg+P#3_+.8(O&0-3AW,7aC+>]QB_9^[c<D-<6URd40J1a<;TXA
FI[2^V)90XAU0EM(=HQVNLfL2;Db]ZMa)#g<TIO4dNO8;6-HcAI+fA<,N^?=Te\(
KU)SZ(8Z-ObZ(R8&bX08[_Y^Y(;156Fe:OT<CT_XZJ-W4CD7KL8VF1L,::XK?E)8
9Z-QB-6-P;I^\_b.]8]TGB2baLDe\4PI3&,><4<__1:Q7Jf2+=EBgWD5GXMG9Z,c
@\eb7I(=GW8)baT/Q5OVUMPKg\&1]Tc5W^D5IdLLU^<;W1O@=@5.GV,2.+[=KF^U
9T_9T^?)-SW:7R\+OEA.YU7U6Cd\GD7#B,,4O,UW51WL+#Q1FY;g092DHJ7Y;;S]
c\eN=5V;L27K#bNWE1(g8ZMH7+Jg&D6C]Xgf6A6MDK;eAQ\&W@R]e<#UAEA^be<D
=KKYT#C.(UI]^O3@/T#:gOYZV#8,O_WPN;1+&5#NF]4d00RB8H1b_gW2L/cgNQA@
a81&3BfQE]B&DMTC-U_-QAH>/7VVdY?R;]bLH>.&>>W8RC1C;RT4R^_>FeJIHN])
J>aKWP6-5>#0J>4#4U[d)MYQ,8d_,^&5@FQVX;3VP>12(;,>-A5LWVOT72+XPKN2
J_V)DWBIRFRIBAea0,=,.-5#c=J_,N]1.;AN;.5>4;Edd/IWdV)3(3-+]](])WG_
I37C&;3)_#WQ2N0/]#8)XBX;L(,]cC3FCBE/P[5Je;=f;HQdNP?(#HcVEcP-?[>X
3:]XWQ4P&3L/97?;b]H&4:T\1WIfUQcU83F[C;=S+HH@7CF:)g-W<;f]5ca9S;VC
PVGg2eZ[);/K=ENX0RT5N0bJG.6AU@CDQ6-W[:W3?MEU)1H@RUeH:R3T(IW9@=[6
0A.;]S)-K^UdfD,N(#)9:++BOR5WEW>\=P:D-d8A1--5Lc9Bb5>OM;#W>M0;6;Ie
Y8+W<XQBSe:e>@C+V>Q2M7G:2;0FIQf-a=RS<<[QJ+I1Z3S^U6RA>&Ze2N0.S,1Z
F#81Z6<#UM=V+0F;6AZF1H/(=HbEe#Y/R\3A\?<2(^SWU/bSGWN/T5.;=,]62R&S
:-3G0M)V4OJV6S#[(ZS6]fM][HM5]Z0E_?=Z0RZ?<I6@HVPc5HGfWPJ9#.6KV0Ge
XEgbOf&)R]PYb552-P67Z&U,1+[ZYSU#3#FP)Q==PW)A)61A/6(^[<9+]F;VN<:(
2AYYO3B^&(&a:8.Z&G\AHR;=c.KIHf\8Y)Fe([;WH\6_RdQR0/J._G52D8AAG_c7
&RF\<&PU2aeb?6[4.U1[XRK#V@6HGgb.XHO=EDSH+7:)La&D/>=GF(5;UK?63>Y)
>A1c>M,(7fFa;f1VO@[G)E8U-f)aM8].-Z>fA(O^@HZ#X]BL]QFOF.^4:6c-F7fb
gb;EL6MeM&W-)IA6U/YD;\0)6QW]EE1>&1-Q)U3ZN:5(/=(ZE-ISKP66c:1bFHL8
99#,NL[WR0AABZca929QD+8;<ALX_CFI+fb0;dCA8MK&bGe-^LQ6Af;c8Od5Z7Ya
GL>PB1Nf=GPdc,4<[AgJ+6?HbBB_MAI1ReWW3afWU02O9)661[f#=fP_NI9G5(Z+
T9_/D7<P(VdQK6Oc0C,;eR1^eTWLJ&.Zc[E5NfZ<a0F.]4FNP[J#MOQ[F=(gFBL>
(8[[5/EV445+e(<ec<f-Z#(>;#HU;7.=DD<X7@F?@;G,0^7EcY34c?facJH9fb;0
7D:\+@ZYZ3UQ8@BbL:6^ae#c\5T-CP<M8ABK2U<\QLH-F9X1FV-X[,NBd+&c64fO
dU_?U^2cL>0YTX7SLdXU7H8K;_9=79IcMb@gOD^=X=-=#84bZD4E[g6P2e=a?_=^
[0T;JV3GG0F94#?]/LEQ?H8f/^LZC^dceb:.J?FZW^CGb(/GXTP,aL\@S<(D=A.1
eOE?+Te(;I<7TN4@W=]Y7XQXdT&gY5R#R@dd\?BRUaSb<_^MNOC2,.NK/KTYf8MS
+/12RI#E4b7];Y&8NK5VBd[,,^:(JSTPf2DA0&01gb^&C[&7.65-S_;RV(Qbda<Q
aN6[5SHLOa&GD6dL6I5A@SGBI.@;_Y([>F\[S7g.GG]@<3N:KEd7EEgB<R-H)]27
E;Ye]S?]JMb78X:;SWBDI[,G;I\MI_B/TK98&>P6>_d696SecWCIOQ17R:@JC7V,
)Ca<fXT=<#R(:GW/?H#<=.KRO8MTE?=3TOYSZPG#NI^Q,]MGOCPD,62fSUZS1W^d
b08bPFBQg2R\6D_K@d-_THQFBNbC5P-B[B>)9L_<eJ1f_MEMA:B3JUPgeLN7_FY:
K:^#[J.5GKC@0ccf];@g@H/@<)f@2\f][a(]Q^<D.,:#F99[HL)RZ-FON7B@AfY,
U+=/][[X5cc_H9)D68fg>_XQc^He[5IJ[V.:g3BbE=QV-.O0TQRDD+Y]6D40KW0^
&f:75M;bc3e(=4Ge&0<F6Ca;,P\V9R/&#^5[2SB8?RUcZGQbC.KMKd)1Xb-3bJTY
VHS^E_2P:R)/>7TX2.+bO.;Q+>K28OgC?gK->SO\+)Kg]Y((\1J3XU4gV44(,L=E
R4U@\>VU0eK2](:S56eY5?PG(;^FTLM84LbFWZQCOIb[3=?[;,37OU;\bP<ZGS58
I4,XR>(_?O;eL6eIcaFU6?>8FB97@6@CQ.>2F58JQK_e96/(-VZSQYRB=:E8bF_+
dV:(K<VXg]/]Nc=E&<A7GWAWP>MQO5b9P<QZ/O8(8^7Z??aFT)5;gQO6TC<5H,G1
IEcLV^7]/1I#9D0XfFZS>Ab_#ac463&&59;IZOQA\DFX30?Z_(QMZb/<\&-SNE#1
^KVe/cL\dcDA9&7Pf;JD-6JN;,Q97>=@G?D>R,:D?E0EE>-RfbG0M7HR_1V>b4SN
SPW_R6fRW44=R2ddEPC7#VUK>/WO,+BdKN.RGLT?:-E:IcJ]H>4E[[ZPQ,,M(XO@
-UbK?Z\Lc4O^DIPA:08fdgA1S=;L]NP_^1SKaI0ADI_(XB1\ZMI&4[T8Q7\)[M5&
95;]/^3^I]/P=_)P9c>@6aAf[GV)[G7<,M8d]TaXY88?1PYTR6&54T?\MbWK:I_f
U?P]O)_+9]]3X;4TgeUL^&^Z8/=f<,R^H_XfP[^+?OGb1Le0@(K:c^?VTa8NG:,:
G2XY#+.FaY+I0KZXg+D9e69-N^+\\(LL)PHD#4)P)Z-^^:/@EdO/H-CA(MAA&Td3
78XdXO\bC6Y4M9X?K2L4=5XKa1cd)@ggS]ed.2,P5HPc?+ReT[1T@Gb7fTdc_+eB
6<WS#KOK#a]9edTV7a9d[F=)c-?fTX7KY=PbHdc[DaZGZ[bV&KDg<H7,,8F:<,;T
JVS-[@MK-JBOe6L3c#N<EOTX8CWQKV&HT;BE^3R4cNaJVCaPf59FV&SJ+cCT=]V[
,<aP6/8;\c.LUS#8#43_0H0):;C:@eCS.SO&BR>U[1BULSLN@P>,7L(.@4@TBN79
=69bdJ&9\@+RaEAT0Q^U-T=8C/W9V3U0CM&Y:WOa<2#H)0]DeMSDIA0X,a(1X,b7
,/,VDJJ/]N^R?37^<M3/IQ+?;M1ZT=>U.GYLKFG_,-PC\C;^HWU&+&P[d:N6Z-gg
T9JP,?<D_#VMO&D;9GYH,?^^C=:-K?J.V>#U>,1B=1BRT.Q.70V8.<2WNETXYgf4
T6H>G28H79[3,X-\>SXb#SRQ6-P12US,M)]1MfLN.@<(+S3Xc_Yfb#AE:TECMM/a
3CIg6cDA.cKgNV-=?J332UP21BXX_0TJ7H;^POHK^E/g48&M1<gTV^g8E+IQYa,7
=2fNIdFMWMb0=?Z3OOZ#+V=S[;SUeTPGSN#]/B9^cUW6acYR)PEdI896E3&9ZDUJ
I?Kd-,FX[a\90Z?2=50K2-c]BBD<9bd3J6>OCg<4^Y,Q6@0NN9<?#@bOMXbP5FJH
XLg/V9K87J+>,GV.<PK).(3,+H&J&L,L?A80TM7O1Lb?.ZOS]?ICFKZe#^I3IgK5
b>eeZMW[cVg-H=(#=4a5E(NMZ3X76V]XdXK=I+0E\5EPRPZ9R1=A4a198B0cYF>&
;#b\FIa,?f^(;ZRT9?gCN(ATJFF<;JCYIG;?1G93dGUN)#>2bFNEQ,Y7H89FYL)e
a^+N1IZ]EFJW76>d[g1H\LeM]14\[a\(H[O<_A0d/3]VdTYgZ2U=-F-I0N8daLQP
7PZeW;V/ab\SUQd9HZUMfgX=X7P.RIR;[0B9IRO4?C3f7@GNGKIZe&7fHTZEg6+=
c[QaAP&HHF#=_P;#)\6&YMdc??P?7]O;1_05V)A#QLf\g-UP)b?4BS^\aK?g;N])
98M8MOHHU@-A&H,EDGQg1XROC&OFCfb,5f_1UeG.=2-5I/b&(<.[2U^\O$
`endprotected
endmodule