// // // // `define CYCLE_TIME  20.0

// // // // module PATTERN(
// // // //     // output signals
// // // //     clk,
// // // //     rst_n,
// // // //     i_valid,
// // // //     i_iter,
// // // //     i_mode,
// // // //     i_data,
// // // //     i_weight,
	
// // // //     // input signals
// // // //     o_valid,
// // // //     o_data
// // // // );

// // // // // ========================================
// // // // // I/O declaration
// // // // // ========================================
// // // // // Output
// // // // output reg          clk;
// // // // output reg          rst_n;
// // // // output reg          i_valid;
// // // // output reg    [2:0] i_iter;
// // // // output reg    [1:0] i_mode;
// // // // output reg    [7:0] i_data;
// // // // output reg    [3:0] i_weight;

// // // // // Input
// // // // input               o_valid;
// // // // input         [7:0] o_data;

// // // // // ========================================
// // // // // clock
// // // // // ========================================
// // // // real CYCLE = `CYCLE_TIME;
// // // // initial clk = 1'b0;
// // // // always	#(CYCLE/2.0) clk = ~clk; //clock

// // // // // ========================================
// // // // // integer & parameter
// // // // // ========================================
// // // // parameter PAT_NUM     = 30; 
// // // // parameter IMG_PER_PAT = 10;  
// // // // parameter TOTAL_IMG   = PAT_NUM * IMG_PER_PAT;

// // // // integer pat_idx;
// // // // integer img_idx;
// // // // integer global_img_idx;

// // // // integer out_cnt;
// // // // integer latency;
// // // // integer total_latency;
// // // // integer i;
// // // // integer wait_cycles;
// // // // integer gap;

// // // // // ========== file path ==========
// // // // parameter IMAGE_FILE = "../00_TESTBED/image.dat";
// // // // parameter WEIGHT_FILE = "../00_TESTBED/weight.dat";
// // // // parameter ITER_FILE = "../00_TESTBED/iter.dat";
// // // // parameter GOLD_FILE = "../00_TESTBED/golden.dat";
// // // // parameter MODE_FILE = "../00_TESTBED/mode.dat";


// // // // // ========================================
// // // // // wire & reg
// // // // // ========================================
// // // // reg [3:0] weight_mem [0:(1312 * PAT_NUM) - 1];           
// // // // reg [7:0] image_mem  [0:(4096 * TOTAL_IMG) - 1];    
// // // // reg [2:0] iter_mem   [0:TOTAL_IMG - 1];
// // // // reg [1:0] mode_mem   [0:TOTAL_IMG - 1];
// // // // reg [7:0] golden_mem [0:(4096 * TOTAL_IMG) - 1];


// // // // //================================================================
// // // // // design
// // // // //================================================================
// // // // initial begin
// // // //     i_valid  = 1'b0;
// // // //     i_iter   = 3'dx;
// // // //     i_mode   = 2'dx;
// // // //     i_data   = 8'dx;
// // // //     i_weight = 4'dx;
// // // //     rst_n = 1'd1;

// // // //     load_test_data;
// // // //     total_latency = 0;
    
// // // //     for (pat_idx = 0; pat_idx < PAT_NUM; pat_idx = pat_idx + 1) begin
// // // //         reset_signal_task;

// // // //         weight_task(pat_idx);
        
// // // //         for (img_idx = 0; img_idx < IMG_PER_PAT; img_idx = img_idx + 1) begin
// // // //             global_img_idx = pat_idx * IMG_PER_PAT + img_idx;
            
// // // //             image_task(global_img_idx); 

// // // //             wait_check_ans(global_img_idx);
            
// // // //         end
// // // //         $display("\033[0;32mPass Pattern NO.%d (1 Reset + 1 Weight + 10 Images)\033[m", pat_idx);
// // // //     end
    
// // // //     $display("=================================================");
// // // //     $display("  Congratulations! All patterns passed!          ");
// // // //     $display("\033[0;32m All %d patterns (%d images) passed! Total Latency = %d\033[m", PAT_NUM, TOTAL_IMG, total_latency);
// // // //     $display("=================================================");
// // // //     $finish;
// // // // end

// // // // //================================================================
// // // // // Output monitoring and checking
// // // // //================================================================

// // // // // Check out signal when out_valid is low
// // // // always @(negedge clk) begin	
// // // // 	if(o_valid === 0 && (o_data !== 8'b0)) begin
// // // //         $display("---------------------------------------------------------------------------------------------");
// // // //         $display("             FAIL! The output signals should be 0 when o_valid is pulled down.                   ");
// // // //         $display("                               Time: %0t, o_data = %0d", $time, o_data);
// // // //         $display("---------------------------------------------------------------------------------------------");
// // // //         repeat(2) #CYCLE;
// // // //         $finish;
// // // //     end
// // // // end

// // // // // I/O_valid overlap check
// // // // always @(negedge clk) begin	
// // // // 	if(o_valid === 1 && (i_valid === 1)) begin
// // // //         $display("---------------------------------------------------------------------------------------------");
// // // //         $display("             FAIL! The o_valid should not be high when i_valid is high.                ");
// // // //         $display("---------------------------------------------------------------------------------------------");
// // // //         $finish;
// // // // 	end
// // // // end



// // // // //================================================================
// // // // // task
// // // // //================================================================

// // // // task reset_signal_task; 
// // // // begin 
// // // //     i_valid  = 1'b0;
// // // //     i_iter   = 3'dx;
// // // //     i_mode   = 2'dx;
// // // //     i_data   = 8'dx;
// // // //     i_weight = 4'dx;
// // // //     force clk = 0;

// // // //     #(CYCLE);   rst_n = 0;
// // // //     #(CYCLE*3); rst_n = 1;
    
// // // //     if((o_valid !== 0) || (o_data !== 0)) begin
// // // //         $display("---------------------------------------------------------------------------------------------");
// // // //         $display("            FAIL! Output signals should be 0 after reset at %4t.", $time);
// // // //         $display("                            o_valid = %b, o_data = %0d", o_valid, o_data);
// // // //         $display("---------------------------------------------------------------------------------------------");
// // // //         $finish;
// // // //     end
    
// // // //     #(CYCLE * $urandom_range(2, 5));
// // // //     release clk;
// // // // end 
// // // // endtask

// // // // task load_test_data;
// // // // begin
// // // //     $readmemh(IMAGE_FILE, image_mem);
// // // //     $readmemh(WEIGHT_FILE, weight_mem);
// // // //     $readmemh(GOLD_FILE, golden_mem);
// // // //     $readmemh(ITER_FILE, iter_mem);
// // // //     $readmemh(MODE_FILE, mode_mem);
// // // // end
// // // // endtask

// // // // task weight_task; 
// // // //     input integer p_idx;
// // // // begin
// // // //     wait_cycles = $urandom_range(2, 5);
// // // //     repeat(wait_cycles) @(negedge clk);

// // // //     for (i = 0; i < 1312; i = i + 1) begin
// // // //         i_valid  = 1'b1;
// // // //         i_weight = weight_mem[p_idx * 1312 + i]; 
// // // //         @(negedge clk);
// // // //     end
// // // //     i_valid  = 1'b0;
// // // //     i_weight = 4'dx;
// // // // end 
// // // // endtask

// // // // task image_task; 
// // // //     input integer g_idx; 
// // // // begin
// // // //     if (g_idx == 0) begin
// // // //         gap = $urandom_range(1, 3);
// // // //     end 
// // // //     else begin
// // // //         gap = $urandom_range(0, 2); 
// // // //     end
// // // //     repeat(gap) @(negedge clk);
    
// // // //     for (i = 0; i < 4096; i = i + 1) begin
// // // //         i_valid = 1'b1;

// // // //         i_data  = image_mem[g_idx * 4096 + i];
        
// // // //         if (i == 0) begin
// // // //             i_iter = iter_mem[g_idx];
// // // //             i_mode = mode_mem[g_idx];
// // // //         end else begin
// // // //             i_iter = 3'dx;
// // // //             i_mode = 2'dx;
// // // //         end
        
// // // //         @(negedge clk);
// // // //     end
// // // //     i_valid = 1'b0;
// // // //     i_data  = 8'dx;
// // // //     i_iter  = 3'dx;
// // // //     i_mode  = 2'dx;
// // // // end 
// // // // endtask



// // // // task wait_check_ans; 
// // // //     input integer g_idx;
// // // // begin
// // // //     latency = 0;
// // // //     out_cnt = 0;
// // // //     while (out_cnt < 4096) begin
// // // //         if (o_valid === 1'b1) begin
// // // //             if (o_data !== golden_mem[g_idx * 4096 + out_cnt]) begin
// // // //                 $display("=================================================");
// // // //                 $display("\033[0;31m[ERROR] Output mismatch at Global Image %d, Pixel %d! \033[m", g_idx, out_cnt);
// // // //                 $display("Expected: %d, but got: %d", golden_mem[g_idx * 4096 + out_cnt], o_data);
// // // //                 $display("=================================================");
// // // //                 $finish;
// // // //             end
// // // //             out_cnt = out_cnt + 1;
// // // //         end else begin
// // // //             latency = latency + 1;
            
// // // //             if (latency > 150000 * iter_mem[g_idx]) begin
// // // //                 $display("=================================================");
// // // //                 $display("\033[0;31m[ERROR] Latency strictly exceeded 150,000 cycles at Image %d! \033[m", g_idx);
// // // //                 $display("=================================================");
// // // //                 $finish;
// // // //             end
// // // //         end
// // // //         @(negedge clk);
// // // //     end

// // // //     if (o_valid === 1'b1) begin
// // // //         $display("=================================================");
// // // //         $display("\033[0;31m[ERROR] o_valid should be pulled down after 4096 outputs at Image %d! \033[m", g_idx);
// // // //         $display("=================================================");
// // // //         $finish;
// // // //     end
    
// // // //     total_latency = total_latency + latency;
// // // // end 
// // // // endtask

// // // // endmodule



// // `define CYCLE_TIME  6.4

// // module PATTERN(
// //     // output signals
// //     clk,
// //     rst_n,
// //     i_valid,
// //     i_iter,
// //     i_mode,
// //     i_data,
// //     i_weight,
    
// //     // input signals
// //     o_valid,
// //     o_data
// // );

// // // ========================================
// // // I/O declaration
// // // ========================================
// // // Output
// // output reg          clk;
// // output reg          rst_n;
// // output reg          i_valid;
// // output reg    [2:0] i_iter;
// // output reg    [1:0] i_mode;
// // output reg    [7:0] i_data;
// // output reg    [3:0] i_weight;

// // // Input
// // input               o_valid;
// // input         [7:0] o_data;

// // // ========================================
// // // clock
// // // ========================================
// // real CYCLE = `CYCLE_TIME;
// // initial clk = 1'b0;
// // always  #(CYCLE/2.0) clk = ~clk; //clock

// // // ========================================
// // // integer & parameter
// // // ========================================
// // parameter PAT_NUM     = 30; 
// // parameter IMG_PER_PAT = 10;  
// // parameter TOTAL_IMG   = PAT_NUM * IMG_PER_PAT;

// // integer pat_idx;
// // integer img_idx;
// // integer global_img_idx;

// // integer out_cnt;
// // integer latency;
// // integer total_latency;
// // integer max_lat; 
// // integer i;
// // integer wait_cycles;
// // integer gap;

// // // ========== file path ==========
// // parameter IMAGE_FILE = "../00_TESTBED/image.dat";
// // parameter WEIGHT_FILE = "../00_TESTBED/weight.dat";
// // parameter ITER_FILE = "../00_TESTBED/iter.dat";
// // parameter GOLD_FILE = "../00_TESTBED/golden.dat";
// // parameter MODE_FILE = "../00_TESTBED/mode.dat";


// // // ========================================
// // // wire & reg
// // // ========================================
// // reg [3:0] weight_mem [0:(1312 * PAT_NUM) - 1];           
// // reg [7:0] image_mem  [0:(4096 * TOTAL_IMG) - 1];    
// // reg [2:0] iter_mem   [0:TOTAL_IMG - 1];
// // reg [1:0] mode_mem   [0:TOTAL_IMG - 1];
// // reg [7:0] golden_mem [0:(4096 * TOTAL_IMG) - 1];


// // //================================================================
// // // design
// // //================================================================
// // initial begin
// //     i_valid  = 1'b0;
// //     i_iter   = 3'dx;
// //     i_mode   = 2'dx;
// //     i_data   = 8'dx;
// //     i_weight = 4'dx;
// //     rst_n = 1'd1;

// //     load_test_data;
// //     total_latency = 0;
    
// //     for (pat_idx = 0; pat_idx < PAT_NUM; pat_idx = pat_idx + 1) begin
// //         reset_signal_task;

// //         weight_task(pat_idx);
        
// //         for (img_idx = 0; img_idx < IMG_PER_PAT; img_idx = img_idx + 1) begin
// //             global_img_idx = pat_idx * IMG_PER_PAT + img_idx;
            
// //             image_task(global_img_idx); 

// //             wait_check_ans(global_img_idx);
            
// //             // ✨ 新增：每算完一張圖 (一個 Iteration 任務) 就印出 Pass 與當次 Latency
// //             $display("\033[0;36m    -> [Image %3d] Pass! (i_iter = %0d) | Latency = %0d cycles \033[m", global_img_idx, iter_mem[global_img_idx], latency);
// //         end
// //         $display("\033[0;32mPass Pattern NO.%d (1 Reset + 1 Weight + 10 Images)\033[m\n", pat_idx);
// //     end
    
// //     $display("=================================================");
// //     $display("  Congratulations! All patterns passed!          ");
// //     $display("\033[0;32m All %d patterns (%d images) passed! Total Latency = %d\033[m", PAT_NUM, TOTAL_IMG, total_latency);
// //     $display("=================================================");
// //     $finish;
// // end

// // //================================================================
// // // Output monitoring and checking
// // //================================================================

// // // Check out signal when out_valid is low
// // always @(negedge clk) begin 
// //     if(o_valid === 0 && (o_data !== 8'b0)) begin
// //         $display("---------------------------------------------------------------------------------------------");
// //         $display("             FAIL! The output signals should be 0 when o_valid is pulled down.                   ");
// //         $display("                               Time: %0t, o_data = %0d", $time, o_data);
// //         $display("---------------------------------------------------------------------------------------------");
// //         repeat(2) #CYCLE;
// //         $finish;
// //     end
// // end

// // // I/O_valid overlap check
// // always @(negedge clk) begin 
// //     if(o_valid === 1 && (i_valid === 1)) begin
// //         $display("---------------------------------------------------------------------------------------------");
// //         $display("             FAIL! The o_valid should not be high when i_valid is high.                ");
// //         $display("---------------------------------------------------------------------------------------------");
// //         $finish;
// //     end
// // end



// // //================================================================
// // // task
// // //================================================================

// // task reset_signal_task; 
// // begin 
// //     i_valid  = 1'b0;
// //     i_iter   = 3'dx;
// //     i_mode   = 2'dx;
// //     i_data   = 8'dx;
// //     i_weight = 4'dx;
// //     force clk = 0;

// //     #(CYCLE);   rst_n = 0;
// //     #(CYCLE*3); rst_n = 1;
    
// //     if((o_valid !== 0) || (o_data !== 0)) begin
// //         $display("---------------------------------------------------------------------------------------------");
// //         $display("            FAIL! Output signals should be 0 after reset at %4t.", $time);
// //         $display("                            o_valid = %b, o_data = %0d", o_valid, o_data);
// //         $display("---------------------------------------------------------------------------------------------");
// //         $finish;
// //     end
    
// //     #(CYCLE * $urandom_range(2, 5));
// //     release clk;
// // end 
// // endtask

// // task load_test_data;
// // begin
// //     $readmemh(IMAGE_FILE, image_mem);
// //     $readmemh(WEIGHT_FILE, weight_mem);
// //     $readmemh(GOLD_FILE, golden_mem);
// //     $readmemh(ITER_FILE, iter_mem);
// //     $readmemh(MODE_FILE, mode_mem);
// // end
// // endtask

// // task weight_task; 
// //     input integer p_idx;
// // begin
// //     wait_cycles = $urandom_range(2, 5);
// //     repeat(wait_cycles) @(negedge clk);

// //     for (i = 0; i < 1312; i = i + 1) begin
// //         i_valid  = 1'b1;
// //         i_weight = weight_mem[p_idx * 1312 + i]; 
// //         @(negedge clk);
// //     end
// //     i_valid  = 1'b0;
// //     i_weight = 4'dx;
// // end 
// // endtask

// // task image_task; 
// //     input integer g_idx; 
// // begin
// //     if (g_idx == 0) begin
// //         gap = $urandom_range(1, 3);
// //     end 
// //     else begin
// //         gap = $urandom_range(0, 2); 
// //     end
// //     repeat(gap) @(negedge clk);
    
// //     for (i = 0; i < 4096; i = i + 1) begin
// //         i_valid = 1'b1;

// //         i_data  = image_mem[g_idx * 4096 + i];
        
// //         if (i == 0) begin
// //             i_iter = iter_mem[g_idx];
// //             i_mode = mode_mem[g_idx];
// //         end else begin
// //             i_iter = 3'dx;
// //             i_mode = 2'dx;
// //         end
        
// //         @(negedge clk);
// //     end
// //     i_valid = 1'b0;
// //     i_data  = 8'dx;
// //     i_iter  = 3'dx;
// //     i_mode  = 2'dx;
// // end 
// // endtask



// // task wait_check_ans; 
// //     input integer g_idx;
// // begin
// //     latency = 0;
// //     out_cnt = 0;
    
// //     // 動態計算每張圖真正的 Latency 上限
// //     max_lat = 150000 * iter_mem[g_idx]; 

// //     while (out_cnt < 4096) begin
// //         if (o_valid === 1'b1) begin
// //             if (o_data !== golden_mem[g_idx * 4096 + out_cnt]) begin
// //                 $display("=================================================");
// //                 $display("\033[0;31m[ERROR] Output mismatch at Global Image %d, Pixel %d! \033[m", g_idx, out_cnt);
// //                 $display("Expected: %d, but got: %d", golden_mem[g_idx * 4096 + out_cnt], o_data);
// //                 $display("=================================================");
// //                 $finish;
// //             end
// //             out_cnt = out_cnt + 1;
// //         end else begin
// //             latency = latency + 1;
            
// //             if (latency > max_lat) begin
// //                 $display("=================================================");
// //                 $display("\033[0;31m[ERROR] Latency strictly exceeded %0d cycles at Image %d! \033[m", max_lat, g_idx);
// //                 $display("=================================================");
// //                 $finish;
// //             end
// //         end
// //         @(negedge clk);
// //     end

// //     if (o_valid === 1'b1) begin
// //         $display("=================================================");
// //         $display("\033[0;31m[ERROR] o_valid should be pulled down after 4096 outputs at Image %d! \033[m", g_idx);
// //         $display("=================================================");
// //         $finish;
// //     end
    
// //     total_latency = total_latency + latency;
// // end 
// // endtask

// // endmodule

// // // `define CYCLE_TIME 20.0

// // // module PATTERN(
// // //     output reg        clk,
// // //     output reg        rst_n,
// // //     output reg        i_valid,
// // //     output reg  [2:0] i_iter,
// // //     output reg  [1:0] i_mode,
// // //     output reg  [7:0] i_data,
// // //     output reg  [3:0] i_weight,
// // //     input             o_valid,
// // //     input       [7:0] o_data
// // // );

// // // // ========================================
// // // // Parameter & Variables
// // // // ========================================
// // // localparam NUM_PATTERNS = 10;
// // // localparam IMG_SIZE     = 4096;
// // // localparam WT_SIZE      = 1312;

// // // real CYCLE = `CYCLE_TIME;

// // // reg [3:0] wt_mem    [0:WT_SIZE-1];
// // // reg [7:0] img_in    [0:(NUM_PATTERNS*IMG_SIZE)-1];
// // // reg [4:0] param_in  [0:NUM_PATTERNS-1]; 
// // // reg [7:0] img_out   [0:(NUM_PATTERNS*IMG_SIZE)-1];

// // // integer p_idx;
// // // integer i;
// // // integer delay_cycles;
// // // integer out_cnt;
// // // integer latency_cnt;
// // // integer total_latency;

// // // // ========================================
// // // // Clock
// // // // ========================================
// // // initial clk = 1'b0;
// // // always #(CYCLE/2.0) clk = ~clk;

// // // // ========================================
// // // // Strict Spec Checks
// // // // ========================================
// // // always @(negedge clk) begin
// // //     // [Spec 11] All output signals should be reset to 0 after the reset signal is asserted.
// // //     if (!rst_n) begin
// // //         if (o_valid !== 1'b0 || o_data !== 8'd0) begin
// // //             $display("[SPEC ERROR] rst_n 為低電位時，o_valid 與 o_data 必須歸零！");
// // //             $finish;
// // //         end
// // //     end
    
// // //     // [Spec 23] o_data should be low when o_valid is low.
// // //     if (rst_n && !o_valid && o_data !== 8'd0) begin
// // //         $display("[SPEC ERROR] o_data 必須在 o_valid 為低電位時保持 0 (目前為 %h)", o_data);
// // //         $finish;
// // //     end

// // //     // [Spec 21] o_valid cannot overlap with i_valid at any time.
// // //     if (i_valid && o_valid) begin
// // //         $display("[SPEC ERROR] i_valid 與 o_valid 不可同時為高電位！");
// // //         $finish;
// // //     end
// // // end

// // // // ========================================
// // // // Main Flow
// // // // ========================================
// // // initial begin
// // //     $readmemh("../00_TESTBED/weights.dat", wt_mem);
// // //     $readmemh("../00_TESTBED/img_in.dat", img_in);
// // //     $readmemh("../00_TESTBED/param_in.dat", param_in);
// // //     $readmemh("../00_TESTBED/img_out.dat", img_out);

// // //     total_latency = 0;
// // //     reset_task;
// // //     send_weight_task;

// // //     for (p_idx = 0; p_idx < NUM_PATTERNS; p_idx = p_idx + 1) begin
// // //         // [Spec 18, 26] 1~3 negative edge delay before next input
// // //         delay_cycles = $urandom_range(1, 3);
// // //         repeat(delay_cycles) @(negedge clk);
        
// // //         send_img_task(p_idx);
// // //         wait_and_check_output_task(p_idx);
// // //     end

// // //     $display("\n=========================================================");
// // //     $display(" Congratulations! All %0d Patterns Passed! ", NUM_PATTERNS);
// // //     $display(" Total Calculated Latency: %0d cycles", total_latency);
// // //     $display("=========================================================\n");
// // //     $finish;
// // // end

// // // // ========================================
// // // // Tasks
// // // // ========================================
// // // task reset_task; begin
// // //     rst_n    = 1'b1;
// // //     i_valid  = 1'b0;
// // //     i_iter   = 3'dx;
// // //     i_mode   = 2'dx;
// // //     i_data   = 8'dx;
// // //     i_weight = 4'dx;

// // //     #(1.0); 
// // //     rst_n = 1'b0; 
// // //     #(CYCLE * 2.0);
// // //     rst_n = 1'b1;         
// // //     @(negedge clk);       
// // // end endtask

// // // task send_weight_task; begin
// // //     for (i = 0; i < WT_SIZE; i = i + 1) begin
// // //         i_valid  = 1'b1;
// // //         i_weight = wt_mem[i];
// // //         i_data   = 8'dx;
// // //         i_iter   = 3'dx;
// // //         i_mode   = 2'dx;
// // //         @(negedge clk);
// // //     end
// // //     i_valid  = 1'b0;
// // //     i_weight = 4'dx;
// // // end endtask

// // // task send_img_task(input integer p_id); begin
// // //     reg [2:0] cur_iter;
// // //     reg [1:0] cur_mode;
    
// // //     cur_iter = param_in[p_id][4:2];
// // //     cur_mode = param_in[p_id][1:0];

// // //     for (i = 0; i < IMG_SIZE; i = i + 1) begin
// // //         i_valid = 1'b1;
// // //         i_data  = img_in[p_id * IMG_SIZE + i];
        
// // //         if (i == 0) begin
// // //             i_iter = cur_iter;
// // //             i_mode = cur_mode;
// // //         end else begin
// // //             i_iter = 3'dx;
// // //             i_mode = 2'dx;
// // //         end
// // //         @(negedge clk);
// // //     end
// // //     i_valid = 1'b0;
// // //     i_data  = 8'dx;
// // //     i_iter  = 3'dx;
// // //     i_mode  = 2'dx;
// // // end endtask

// // // task wait_and_check_output_task(input integer p_id); begin
// // //     reg [2:0] cur_iter;
// // //     reg [7:0] exp_data;
    
// // //     cur_iter    = param_in[p_id][4:2];
// // //     out_cnt     = 0;
// // //     latency_cnt = 0;

// // //     // Wait until all 4096 outputs are received
// // //     while (out_cnt < IMG_SIZE) begin
// // //         @(negedge clk);
        
// // //         // [Spec 3] Calculate latency: only cycles where o_valid is low are counted.
// // //         if (!o_valid) begin
// // //             latency_cnt = latency_cnt + 1;
// // //         end

// // //         if (latency_cnt > (150000 * cur_iter)) begin
// // //             $display("[ERROR] Pattern %0d: Latency 超時！允許最大週期為 %0d，但已達 %0d。", 
// // //                      p_id, 150000 * cur_iter, latency_cnt);
// // //             $finish;
// // //         end

// // //         if (o_valid) begin
// // //             exp_data = img_out[p_id * IMG_SIZE + out_cnt];
// // //             if (o_data !== exp_data) begin
// // //                 $display("[ERROR] Pattern %0d: 輸出錯誤 @ 序列 %0d。 預期: %h, 實際: %h", 
// // //                          p_id, out_cnt, exp_data, o_data);
// // //                 $finish;
// // //             end
// // //             out_cnt = out_cnt + 1;
// // //         end
// // //     end

// // //     // [Spec 3] If o_valid pulls high immediately after i_valid falls, latency is 1
// // //     if (latency_cnt == 0) latency_cnt = 1;

// // //     total_latency = total_latency + latency_cnt;
// // //     $display("Pattern %0d Passed! (Iter=%0d, Mode=%0d, Latency=%0d cycles)", 
// // //              p_id, cur_iter, param_in[p_id][1:0], latency_cnt);
// // // end endtask

// // // endmodule

// `define CYCLE_TIME  6.1

// module PATTERN(
//     // output signals
//     clk,
//     rst_n,
//     i_valid,
//     i_iter,
//     i_mode,
//     i_data,
//     i_weight,
	
//     // input signals
//     o_valid,
//     o_data
// );

// // ========================================
// // I/O declaration
// // ========================================
// // Output
// output reg          clk;
// output reg          rst_n;
// output reg          i_valid;
// output reg    [2:0] i_iter;
// output reg    [1:0] i_mode;
// output reg    [7:0] i_data;
// output reg    [3:0] i_weight;

// // Input
// input               o_valid;
// input         [7:0] o_data;

// // ========================================
// // clock
// // ========================================
// real CYCLE = `CYCLE_TIME;
// initial clk = 1'b0;
// always	#(CYCLE/2.0) clk = ~clk; //clock

// // ========================================
// // integer & parameter
// // ========================================
// parameter TOTAL_IMG   = 300; 
// parameter DEBUG_MODE  = 1;

// integer global_img_idx;
// integer out_cnt, latency, total_latency, i, wait_cycles, gap;

// integer total_iter;
// real avg_latency_ns;

// parameter IMAGE_FILE  = "../00_TESTBED/image.dat";
// parameter WEIGHT_FILE = "../00_TESTBED/weight.dat";
// parameter ITER_FILE   = "../00_TESTBED/iter.dat";
// parameter GOLD_FILE   = "../00_TESTBED/golden.dat";
// parameter MODE_FILE   = "../00_TESTBED/mode.dat";

// reg [3:0]   weight_mem [0:1311];   
// reg [127:0] debug_w_word, debug_i_word;
// reg [7:0]   image_mem  [0:(4096 * TOTAL_IMG) - 1];    
// reg [2:0]   iter_mem   [0:TOTAL_IMG - 1];
// reg [1:0]   mode_mem   [0:TOTAL_IMG - 1];
// reg [7:0]   golden_mem [0:(4096 * TOTAL_IMG) - 1];

// //================================================================
// // design (Black-Box Verification Flow)
// //================================================================
// initial begin
//     i_valid  = 1'b0; i_iter   = 3'dx;
//     i_mode   = 2'dx;
//     i_data   = 8'dx; i_weight = 4'dx; rst_n = 1'd1;

//     load_test_data;
//     total_latency = 0;
//     total_iter    = 0;

//     if (DEBUG_MODE) $display("\n\033[0;34m=== Starting Simulation: Global Reset & Weight Load ===\033[m");
//     reset_signal_task;
//     weight_task;

//     for (global_img_idx = 0; global_img_idx < TOTAL_IMG; global_img_idx = global_img_idx + 1) begin
//         if (DEBUG_MODE) $display("\n\033[0;34m=== Loading Image %d ===\033[m", global_img_idx);
//         image_task(global_img_idx);
        
//         if (DEBUG_MODE) $display("\033[0;33m[PATTERN] Waiting for DM output... (Image %d)\033[m", global_img_idx);
//         wait_check_ans(global_img_idx);
        
//         $display("\033[0;32m  -> Pass Image %d\033[m", global_img_idx);
//         total_iter = total_iter + iter_mem[global_img_idx];
//     end
    
//     avg_latency_ns = (total_latency * CYCLE) / total_iter;
    
//     $display("\033[0;32m=================================================\033[m");
//     $display("\033[0;32m  Congratulations! All %d images passed!         \033[m", TOTAL_IMG);
//     $display("\033[0;32m-------------------------------------------------\033[m");
//     $display("\033[0;33m  [Performance Report]\033[m");
//     $display("  Total Latency : %d cycles", total_latency);
//     $display("  Total Iters   : %d iterations", total_iter);
//     $display("  Avg Latency   : %.2f ns / iter", avg_latency_ns);
    
//     if (avg_latency_ns < 800000.0) begin
//         $display("\033[1;32m  Status        : [PASS] Exceeds Goal (< 800K ns)!\033[m");
//     end else if (avg_latency_ns < 3000000.0) begin
//         $display("\033[1;33m  Status        : [PASS] Meets Baseline (< 3M ns).\033[m");
//     end else begin
//         $display("\033[1;31m  Status        : [FAIL] Too Slow (> 3M ns).\033[m");
//     end
//     $display("\033[0;32m=================================================\033[m");
//     $finish;
// end

// always @(negedge clk) begin 
//     if(o_valid === 0 && (o_data !== 8'b0)) begin
//         $display("\033[0;31m---------------------------------------------------------------------------------------------\033[m");
//         $display("\033[0;31m             FAIL! The output signals should be 0 when o_valid is pulled down.                   \033[m");
//         $display("\033[0;31m                               Time: %0t, o_data = %0d\033[m", $time, o_data);
//         $display("\033[0;31m---------------------------------------------------------------------------------------------\033[m");
//         repeat(2) #CYCLE;
//         $finish;
//     end
//     if(o_valid === 1 && (i_valid === 1)) begin
//         $display("\033[0;31m---------------------------------------------------------------------------------------------\033[m");
//         $display("\033[0;31m             FAIL! The o_valid should not be high when i_valid is high.                \033[m");
//         $display("\033[0;31m---------------------------------------------------------------------------------------------\033[m");
//         $finish;
//     end
// end

// // ============================================================================
// // Tasks Definition
// // ============================================================================
// task reset_signal_task; 
// begin 
//     i_valid  = 1'b0; i_iter   = 3'dx;
//     i_mode   = 2'dx;
//     i_data   = 8'dx; i_weight = 4'dx; force clk = 0;

//     #(CYCLE);
//     rst_n = 0;
//     #(CYCLE*3); rst_n = 1;
    
//     if((o_valid !== 0) || (o_data !== 0)) begin
//         $display("\033[0;31m---------------------------------------------------------------------------------------------\033[m");
//         $display("\033[0;31m            FAIL! Output signals should be 0 after reset at %4t.\033[m", $time);
//         $display("\033[0;31m                            o_valid = %b, o_data = %0d\033[m", o_valid, o_data);
//         $display("\033[0;31m---------------------------------------------------------------------------------------------\033[m");
//         $finish;
//     end
//     #(CYCLE * $urandom_range(2, 5));
//     release clk;
// end 
// endtask

// task load_test_data;
// begin
//     $readmemh(IMAGE_FILE, image_mem);
//     $readmemh(WEIGHT_FILE, weight_mem);
//     $readmemh(GOLD_FILE, golden_mem);
//     $readmemh(ITER_FILE, iter_mem);
//     $readmemh(MODE_FILE, mode_mem);
// end
// endtask

// task weight_task; 
// begin
//     wait_cycles = $urandom_range(2, 5);
//     repeat(wait_cycles) @(negedge clk);
//     for (i = 0; i < 1312; i = i + 1) begin
//         i_valid  = 1'b1;
//         i_weight = weight_mem[i]; 
//         debug_w_word = {i_weight, debug_w_word[127:4]};
//         @(negedge clk);
//     end
//     i_valid  = 1'b0; i_weight = 4'dx;
// end 
// endtask

// task image_task; 
//     input integer g_idx;
// begin
//     if (g_idx == 0) gap = $urandom_range(1, 3);
//     else            gap = $urandom_range(0, 2);
    
//     repeat(gap) @(negedge clk);
//     for (i = 0; i < 4096; i = i + 1) begin
//         i_valid = 1'b1;
//         i_data  = image_mem[g_idx * 4096 + i];
//         if (i == 0) begin
//             i_iter = iter_mem[g_idx];
//             i_mode = mode_mem[g_idx];
//         end else begin
//             i_iter = 3'dx;
//             i_mode = 2'dx;
//         end
//         debug_i_word = {i_data, debug_i_word[127:8]};
//         @(negedge clk);
//     end
//     i_valid = 1'b0; i_data  = 8'dx; i_iter  = 3'dx; i_mode  = 2'dx;
// end 
// endtask

// task wait_check_ans; 
//     input integer g_idx;
//     integer expected_val, actual_val, diff;
//     integer max_latency;
// begin
//     latency = 0; out_cnt = 0;
//     max_latency = iter_mem[g_idx] * 150000;
    
//     while (out_cnt < 4096) begin
//         if (o_valid === 1'b1) begin
//             expected_val = golden_mem[g_idx * 4096 + out_cnt];
//             actual_val   = o_data;
//             if (actual_val !== expected_val) begin
//                 diff = actual_val - expected_val;
//                 $display("\033[0;31m=================================================\033[m");
//                 $display("\033[0;31m[ERROR] Mismatch at Image %d, Pixel %d! \033[m", g_idx, out_cnt);
//                 $display("\033[0;31m        Expected: %3d (0x%02X) \033[m", expected_val, expected_val);
//                 $display("\033[0;31m        Actual  : %3d (0x%02X) \033[m", actual_val, actual_val);
//                 $display("\033[0;31m        Diff    : %d \033[m", diff);
//                 $display("\033[0;31m=================================================\033[m");
//                 $finish;
//             end
//             out_cnt = out_cnt + 1;
//         end else begin
//             latency = latency + 1;
//             if (latency > max_latency) begin
//                 $display("\033[0;31m=================================================\033[m");
//                 $display("\033[0;31m[ERROR] Latency strictly exceeded %d cycles at Image %d (iter=%d)! \033[m", max_latency, g_idx, iter_mem[g_idx]);
//                 $display("\033[0;31m=================================================\033[m");
//                 $finish;
//             end
//         end
//         @(negedge clk);
//     end
    
//     @(negedge clk);
//     if (o_valid === 1'b1) begin
//         $display("\033[0;31m=================================================\033[m");
//         $display("\033[0;31m[ERROR] o_valid should be pulled down after 4096 outputs! \033[m");
//         $display("\033[0;31m=================================================\033[m");
//         $finish;
//     end
//     total_latency = total_latency + latency;
// end 
// endtask
// endmodule

`define CYCLE_TIME  20.0

// if you want to check anwser for every iteration
// remind to: 
// (1) use pattern_gen_vXXX_iter.py to generate right output.txt
// (2) open this macro
// (3) use current_iter_check & current_iter_img (inside RTL design) to debug
//`define ITERATION_CHECK  


module PATTERN(
    // output signals
    clk,
    rst_n,
    i_valid,
    i_iter,
    i_mode,
    i_data,
    i_weight,
	
    // input signals
    o_valid,
    o_data
);

// ========================================
// I/O declaration
// ========================================
// Output
output reg          clk;
output reg          rst_n;
output reg          i_valid;
output reg    [2:0] i_iter;
output reg    [1:0] i_mode;
output reg    [7:0] i_data;
output reg    [3:0] i_weight;

// Input
input               o_valid;
input         [7:0] o_data;



// ========================================
// clock
// ========================================
real CYCLE = `CYCLE_TIME;
initial clk = 1'b0;
always	#(CYCLE/2.0) clk = ~clk; //clock

// ========================================
// integer & parameter
// ========================================

integer e_time; // elapse time
integer inFile, outFile, ERR;  // file ptr
reg [1023:0] str_buf;
reg [31:0] instr_buf;


integer latency, total_latency;
integer PATNUM, __pat_num, IMGNUM, __img_num;
integer x, y, layer, ch, i, j;

integer total_iter, iter;
real avg_latency;


reg done_rst;
reg in_param_flag;

// ========================================
// wire & reg
// ========================================

// weights
reg [3:0] dsamp_conv_wt[0:15][0:2][0:2];  //[channel][y][x]
reg [3:0] usamp_conv_wt[0:15][0:2][0:2];  //[channel][y][x]

reg [3:0] Q_LT_mat[0:15][0:15];
reg [3:0] K_LT_mat[0:15][0:15];
reg [3:0] V_LT_mat[0:15][0:15];
reg [3:0] ff_LT_mat[0:15][0:15];

reg [7:0] in_image[0:63][0:63];


// output [channel][y][x]
reg [7:0] golden_output[0:63][0:63];


//================================================================
// design
//================================================================
 
// clock initialize
initial begin
    //clk = 0;
    e_time = 0;
end
//always #(CYCLE/2) clk = ~clk;
always #(1) e_time = e_time + 1;


// simulation loop
initial begin
    inFile  = $fopen("../00_TESTBED/input.txt", "r");
    outFile = $fopen("../00_TESTBED/output.txt", "r");

    ERR = $fscanf(inFile, "%d", PATNUM);
    ERR = $fscanf(inFile, "%d", IMGNUM);

    // reset only once @ begining
    total_latency = 0;
    total_iter = 0;

    
    for(__pat_num=0; __pat_num<PATNUM; __pat_num=__pat_num+1) begin
        $display("\n\n[Proceeding PATTERN # %3d] %10d", __pat_num, e_time);
        
        done_rst = 0;

        i_valid = 0;
        i_iter = 'bx;
        i_mode = 'bx;
        i_data = 'bx;
        i_weight = 'bx;

        rst_n = 1;  force clk = 0;

        reset_task;
        input_param_task;

        for(__img_num=0; __img_num<IMGNUM; __img_num=__img_num+1) begin
            
            latency = 0;
            iter = 0;

            //@(negedge clk);
            //@(negedge clk);
            //註解調因為會等1~3個，所以你的design要能容忍只有1個cycle

            input_image_task;
            wait_output_task;
            check_golden_task;

            avg_latency = latency*1.0 / instr_buf[4:2];
            total_iter = total_iter + instr_buf[4:2];

            pass_img_task;

            total_latency = total_latency + latency;
        end
    end

    avg_latency = total_latency*1.0 / total_iter;
    YOU_PASS_task;
end


// ==================================================== //
//          ALWAYS CHECKING I/O RULE
// ==================================================== //
always @(negedge clk) begin
    if(done_rst) begin
        if(o_valid === 0 && o_data !== 0) begin
            $display("\033[31m [DEBUG] %10d  out_data != 0 while out_valid = 0 \033[0m", e_time);
            #(`CYCLE_TIME); $finish;
        end

    end
end
always @(*) begin
    if(ERR == 0) begin
        $display("\033[31m [DEBUG] fail to read txt \033[0m", e_time);
        #(`CYCLE_TIME); $finish;
    end

    if(done_rst) begin
        if(o_valid === 1 && i_valid === 1) begin
            $display("\033[31m [DEBUG] %10d  out_valid = 1 overlap with i_valid = 1 \033[0m", e_time);
            #(`CYCLE_TIME); $finish;
        end
    end
end


// value checker for every iteration
`ifdef ITERATION_CHECK

always @(posedge TESTBED.u_DM.current_iter_check) begin
    
    ERR = $fscanf(outFile, "%s", str_buf);
    for(y=0; y<64; y=y+1) begin
        for(x=0; x<64; x=x+1) begin
            ERR = $fscanf(outFile, "%d", golden_output[y][x]);
        end
    end

    for(y=0; y<64; y=y+1) begin
        for(x=0; x<64; x=x+1) begin
            if(TESTBED.u_DM.current_iter_img[y][x] != golden_output[y][x]) begin
                $display("\033[31m [DEBUG] %10d  wrong iteration result \033[0m", e_time);
                $display("\033[31m Expected: %3d, Get: %3d  @pat=%4d, image=%4d:  iter=%2d, row=%2d, col=%2d \033[0m", golden_output[y][x], o_data, __pat_num, __img_num, iter, y, x);
                #(`CYCLE_TIME); $finish;
            end
        end
    end
end

`endif



task reset_task;
begin
    #(100);
    rst_n = 0;
    #(200);

    if(o_valid !== 0 && o_data !== 0)begin
        $display("\033[31m [DEBUG] %10d  out_valid / out_data not reset. \033[0m", e_time);
        #(`CYCLE_TIME); $finish;
    end
    done_rst = 1;
    #(100);

    rst_n = 1;
    release clk; 
end
endtask


task input_param_task;
begin
    @(negedge clk);
    i_valid = 1;

    // elim input.txt str
    ERR = $fscanf(inFile, "%s", str_buf);

    // elim output.txt str
    ERR = $fscanf(outFile, "%s", str_buf); 

    // read input params from input.txt
    for(ch=0; ch<16; ch=ch+1) begin
        ERR = $fscanf(inFile, "%s", str_buf); 
        for(y=0; y<3; y=y+1) begin
            for(x=0; x<3; x=x+1) begin
                ERR = $fscanf(inFile, "%d", dsamp_conv_wt[ch][y][x]);
            end
        end
    end
    for(ch=0; ch<16; ch=ch+1) begin
        ERR = $fscanf(inFile, "%s", str_buf); 
        for(y=0; y<3; y=y+1) begin
            for(x=0; x<3; x=x+1) begin
                ERR = $fscanf(inFile, "%d", usamp_conv_wt[ch][y][x]);
            end
        end
    end
    ERR = $fscanf(inFile, "%s", str_buf); 
    for(y=0; y<16; y=y+1) begin
        for(x=0; x<16; x=x+1) begin
            ERR = $fscanf(inFile, "%d", Q_LT_mat[y][x]);
        end
    end
    ERR = $fscanf(inFile, "%s", str_buf); 
    for(y=0; y<16; y=y+1) begin
        for(x=0; x<16; x=x+1) begin
            ERR = $fscanf(inFile, "%d", K_LT_mat[y][x]);
        end
    end
    ERR = $fscanf(inFile, "%s", str_buf); 
    for(y=0; y<16; y=y+1) begin
        for(x=0; x<16; x=x+1) begin
            ERR = $fscanf(inFile, "%d", V_LT_mat[y][x]);
        end
    end
    ERR = $fscanf(inFile, "%s", str_buf); 
    for(y=0; y<16; y=y+1) begin
        for(x=0; x<16; x=x+1) begin
            ERR = $fscanf(inFile, "%d", ff_LT_mat[y][x]);
        end
    end


    //  output params to RTL
    for(ch=0; ch<16; ch=ch+1) begin
        for(y=0; y<3; y=y+1) begin
            for(x=0; x<3; x=x+1) begin
                i_weight = dsamp_conv_wt[ch][y][x];
                @(negedge clk);
            end
        end
    end
    for(y=0; y<16; y=y+1) begin
        for(x=0; x<16; x=x+1) begin
            i_weight = Q_LT_mat[y][x];
            @(negedge clk);
        end
    end
    for(y=0; y<16; y=y+1) begin
        for(x=0; x<16; x=x+1) begin
            i_weight = K_LT_mat[y][x];
            @(negedge clk);
        end
    end
    for(y=0; y<16; y=y+1) begin
        for(x=0; x<16; x=x+1) begin
            i_weight = V_LT_mat[y][x];
            @(negedge clk);
        end
    end
    for(y=0; y<16; y=y+1) begin
        for(x=0; x<16; x=x+1) begin
            i_weight = ff_LT_mat[y][x];
            @(negedge clk);
        end
    end
    for(ch=0; ch<16; ch=ch+1) begin
        for(y=0; y<3; y=y+1) begin
            for(x=0; x<3; x=x+1) begin
                i_weight = usamp_conv_wt[ch][y][x];
                @(negedge clk);
            end
        end
    end


    i_valid = 0;
    i_weight = 'bx;

end
endtask


task input_image_task;
begin
    @(negedge clk);
    i_valid = 1;

    ERR = $fscanf(inFile, "%s", str_buf); 
    ERR = $fscanf(inFile, "%s", str_buf); 
    ERR = $fscanf(inFile, "%8h", instr_buf);
    i_mode = instr_buf[1:0];
    i_iter = instr_buf[4:2];


    for(y=0; y<64; y=y+1) begin
        for(x=0; x<64; x=x+1) begin
            ERR = $fscanf(inFile, "%d", in_image[y][x]);

            i_data = in_image[y][x];
            @(negedge clk);

            if(y==0 && x==0) begin
                i_iter = 'bx;
                i_mode = 'bx;
            end
        end
    end

    i_valid = 0;
    i_data = 'bx;


    ERR = $fscanf(outFile, "%s", str_buf);
    ERR = $fscanf(outFile, "%s", str_buf);
end
endtask


task wait_output_task;
begin
    while(o_valid !== 1) begin
        latency = latency + 1;

        if(latency > 150_000 * instr_buf[4:2]) begin
            $display("\033[31m [DEBUG] %10d  avg latency exceed 150,000 \033[0m", e_time);
            #(`CYCLE_TIME); $finish;
        end
        @(negedge clk);
    end
end
endtask


task check_golden_task;
begin
    //ERR = $fscanf(outFile, "%s", str_buf);

    for(y=0; y<64; y=y+1) begin
        for(x=0; x<64; x=x+1) begin
            ERR = $fscanf(outFile, "%d", golden_output[y][x]);
        end
    end

    for(y=0; y<64; y=y+1) begin
        for(x=0; x<64; x=x+1) begin
                
            if(o_valid !== 1) begin
                $display("\033[31m [DEBUG] %10d  o_valid = 0 too early \033[0m", e_time);
                $display("\033[31m @pat=%4d, image=%4d:  row=%2d, col=%2d \033[0m", __pat_num, __img_num, y, x);
                #(`CYCLE_TIME); $finish;
            end
                
            if(o_data !== golden_output[y][x]) begin
                $display("\033[31m [DEBUG] %10d  wrong output \033[0m", e_time);
                $display("\033[31m Expected: %3d, Get: %3d  @pat=%4d, image=%4d:  row=%2d, col=%2d \033[0m", golden_output[y][x], o_data, __pat_num, __img_num, y, x);
                #(`CYCLE_TIME); $finish;
            end

            @(negedge clk);
        end
    end

    @(negedge clk);
    if(o_valid !== 0) begin
        $display("\033[31m [DEBUG] %10d  o_valid = 0 too late \033[0m", e_time);
        $display("\033[31m @pat=%4d, image=%4d:  row=%2d, col=%2d \033[0m", __pat_num, __img_num, y, x);
        #(`CYCLE_TIME); $finish;
    end
    @(negedge clk);
end
endtask


task pass_img_task;
begin
    $display("\033[32m elapse %10d, image=%1d  |  CN=%5d,  avgCN=%7.2f  \033[0m", e_time, __img_num, latency, avg_latency);
end
endtask


task YOU_PASS_task; begin
    $display("*************************************************************************");
    $display("*                         Congratulations!                              *");
    $display("*      Your execution cycles = %5d cycles, avg cycles = %7.2f       *", total_latency, avg_latency);
    $display("*************************************************************************");
    $finish;
end 
endtask



endmodule