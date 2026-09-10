`ifdef RTL
    `define CYCLE_TIME_clk1 20.1
    `define CYCLE_TIME_clk2 11.3
    `define CYCLE_TIME_clk3 34.7
`endif
`ifdef Period_1
    `define CYCLE_TIME_clk1 34.7
    `define CYCLE_TIME_clk2 20.1
    `define CYCLE_TIME_clk3 11.3
`endif
`ifdef Period_2
    `define CYCLE_TIME_clk1 11.3
    `define CYCLE_TIME_clk2 20.1
    `define CYCLE_TIME_clk3 34.7
`endif
`ifdef Period_3
    `define CYCLE_TIME_clk1 20.1
    `define CYCLE_TIME_clk2 11.3
    `define CYCLE_TIME_clk3 34.7
`endif
`ifdef GATE
    `define CYCLE_TIME_clk1 20.1
    `define CYCLE_TIME_clk2 11.3
    `define CYCLE_TIME_clk3 34.7
`endif

module PATTERN(
    output reg         clk1,
    output reg         clk2,
    output reg         clk3,

    output reg         rst_n,
    
    // AXI4-Lite Monitor (clk2)
    input      [31:0]  ar_addr_clk2, 
    input              ar_valid_clk2, 
    input              ar_ready_clk2,
    input      [63:0]  r_data_clk2,  
    input              r_valid_clk2, 
    input              r_ready_clk2,

    // AXI4-Lite Monitor (clk3)
    input      [31:0]  ar_addr_clk3, 
    input              ar_valid_clk3, 
    input              ar_ready_clk3,
    input      [63:0]  r_data_clk3,  
    input              r_valid_clk3, 
    input              r_ready_clk3,

    output reg         in_mode_valid,
    output reg         in_mode,
    output reg         in_valid,
    output reg [1:0]   in_bank,
    output reg [5:0]   in_src_row,
    
    input              out_valid,
    input [63:0]       out_data
);

//---------------------------------------------------------------------
//   PARAMETER & VARIABLE DECLARATION
//---------------------------------------------------------------------
real    CYCLE_clk1 = `CYCLE_TIME_clk1;
real    CYCLE_clk2 = `CYCLE_TIME_clk2;
real    CYCLE_clk3 = `CYCLE_TIME_clk3;

integer total_latency;
integer latency;
integer i, b, c, pat, pat_num = 100;
integer delay_cycles;
integer mode_rand; 

reg [63:0] golden_DRAM [0:65535];
parameter DRAM_p_r = "../00_TESTBED/DRAM_init.dat";
initial $readmemh(DRAM_p_r, golden_DRAM);

reg [63:0] golden_ans_queue [0:1024]; 
integer expected_cycles;
integer ans_idx;
integer out_cnt;

reg signed [63:0] dummy_result; 

reg current_mode; 
reg check_en;
reg busy_flag; 

reg [1:0] saved_bank [0:3];
reg [5:0] saved_src_row [0:3];
reg [5:0] guass_target_row;

// GUASS Variables (替換 SystemVerilog 的 longint 為 128-bit 防止變異數溢位)
reg signed [127:0] g_sum, g_mu, g_var_sum, g_variance, g_N, g_val, g_diff;
reg [63:0] g_word;

// 🌟 宣告給 PATTERN 專用的模擬 Stack 陣列 (新增 tb_stack_state)
reg [15:0] tb_stack_r_ptr [0:7];
reg signed [63:0] tb_stack_l_val [0:7];
reg [1:0] tb_stack_op [0:7];
reg tb_stack_state [0:7]; 

// 將 OP 轉成字串方便閱讀的 function
function [31:0] get_op_str;
    input [1:0] op;
    begin
        case (op)
            2'b00: get_op_str = " ADD";
            2'b01: get_op_str = " SUB";
            2'b10: get_op_str = " MUL";
            2'b11: get_op_str = " SRA";
            default: get_op_str = " UNK";
        endcase
    end
endfunction

//---------------------------------------------------------------------
//   CLOCK GENERATION
//---------------------------------------------------------------------
initial clk1 = 0; always #(CYCLE_clk1/2.0) clk1 = ~clk1;
initial clk2 = 0; always #(CYCLE_clk2/2.0) clk2 = ~clk2;
initial clk3 = 0; always #(CYCLE_clk3/2.0) clk3 = ~clk3;

//---------------------------------------------------------------------
//   FAIL & PASS TASKS 
//---------------------------------------------------------------------
task YOU_PASS_task; begin
    $display("*************************************************************************");
    $display("* Congratulations!                                                      *");
    $display("* Your execution cycles = %5d cycles                                    *", total_latency);
    $display("* Your clk1 period      = %.1f ns                                       *", CYCLE_clk1);
    $display("* Total Latency         = %.1f ns                                       *", total_latency*CYCLE_clk1);
    // 🌟 新增這一行：印出平均每個 Pattern 花費的 Cycle 數
    $display("* Average Latency       = %9.1f cycles/pattern                      *", total_latency / $itor(pat_num));
    $display("*************************************************************************");
    $finish;
end endtask

task FAIL_task; begin
    $display("*************************************************************************");
    $display("* FAIL!                                                                    *");
    $display("*************************************************************************");
    $finish;
end endtask

task print_fail_and_finish;
    input [8*50:1] fail_msg; 
    begin
        $display("\n=========================================================================");
        $display("  %s", fail_msg);
        $display("=========================================================================\n");
        FAIL_task();
    end
endtask

task fail_MAIN_1; begin print_fail_and_finish("SPEC FAIL: RESET"); end endtask
task fail_MAIN_2; begin print_fail_and_finish("SPEC FAIL: TIMEOUT > 20000"); end endtask
task fail_MAIN_3; begin print_fail_and_finish("SPEC FAIL: OUT_VALID PROTOCOL / EXTRA OUT_VALID"); end endtask
task fail_MAIN_4; begin print_fail_and_finish("SPEC FAIL: WRONG ANSWER"); end endtask
task fail_AXI;    begin print_fail_and_finish("SPEC FAIL: AXI PROTOCOL VIOLATION"); end endtask

//---------------------------------------------------------------------
//   SIMULATION FLOW
//---------------------------------------------------------------------
initial begin
    rst_n = 1'b1;
    in_mode_valid = 1'b0;
    in_mode = 1'd0;
    in_valid = 1'b0;
    in_bank = 2'd0;
    in_src_row = 6'd0;
    total_latency = 0;
    check_en = 1'b0;
    busy_flag = 1'b0;
    
    reset_task();
    
    check_en = 1'b1;
    repeat(3) @(negedge clk1);

    for (pat = 0; pat < pat_num; pat = pat + 1) begin
        delay_cycles = $urandom_range(2, 4);
        repeat(delay_cycles) @(negedge clk1);
        
        generate_input_task();
        wait_out_valid_task();

        $display("\033[1;32m[PASS] Pattern %03d / %03d passed! (Mode: %s) | Latency: %5d cycles \033[0m", pat + 1, pat_num, (current_mode==0)?"CALC":"GUASS", latency);
    end
    
    YOU_PASS_task();
end

//---------------------------------------------------------------------
//   BACKGROUND CHECKS (AXI & Main Protocol)
//---------------------------------------------------------------------
// --- CLK2 Domain Checks & Transaction Queue ---
reg ar_valid_clk2_d, r_valid_clk2_d;
reg ar_ready_clk2_d, r_ready_clk2_d;
reg [31:0] ar_addr_clk2_d;
reg [63:0] r_data_clk2_d;

integer clk2_q_size = 0;
reg [31:0] clk2_ar_q [0:255];
integer clk2_timer_q [0:255]; 
integer clk2_push = 0;
integer clk2_pop = 0;
integer ar_wait_clk2 = 0, r_wait_clk2 = 0;
reg [31:0] clk2_exp_addr;
integer clk2_q_idx, clk2_q_offset;

always @(negedge clk2) begin
    if (rst_n && check_en) begin
        // Update Timers for all outstanding requests
        if (clk2_q_size > 0) begin
            for (clk2_q_offset = 0; clk2_q_offset < clk2_q_size; clk2_q_offset = clk2_q_offset + 1) begin
                clk2_q_idx = (clk2_pop + clk2_q_offset) % 256;
                clk2_timer_q[clk2_q_idx] = clk2_timer_q[clk2_q_idx] + 1;
                if (clk2_timer_q[clk2_q_idx] > 500) begin
                    $display("\n[AXI ERROR] clk2 R channel handshake timeout (>500 cycles) for ADDR: %h", clk2_ar_q[clk2_q_idx]); 
                    fail_AXI();
                end
            end
        end

        // R Channel Handshake (Pop & Check)
        if (r_valid_clk2 && r_ready_clk2) begin
            if (clk2_q_size == 0 && !(ar_valid_clk2 && ar_ready_clk2)) begin
                $display("\n[AXI ERROR] clk2 R channel handshake without prior AR (outstanding == 0)"); fail_AXI();
            end else begin
                if (clk2_q_size == 0) clk2_exp_addr = ar_addr_clk2;
                else clk2_exp_addr = clk2_ar_q[clk2_pop];

                if (r_data_clk2 !== golden_DRAM[clk2_exp_addr[15:0]]) begin
                    $display("\n[AXI ERROR] clk2 R_DATA mismatch or Out-of-Order!");
                    $display("Expected Data for ADDR %h is %h, Got: %h", clk2_exp_addr, golden_DRAM[clk2_exp_addr[15:0]], r_data_clk2);
                    fail_AXI();
                end

                if (clk2_q_size > 0) begin
                    clk2_pop = (clk2_pop + 1) % 256;
                    clk2_q_size = clk2_q_size - 1;
                end
            end
        end

        // AR Channel Handshake (Push)
        if (ar_valid_clk2 && ar_ready_clk2) begin
            if (!(r_valid_clk2 && r_ready_clk2 && clk2_q_size == 0)) begin
                if (clk2_q_size >= 256) begin
                    $display("\n[AXI ERROR] clk2 Outstanding Queue Overflow (>256)!"); fail_AXI();
                end
                clk2_ar_q[clk2_push] = ar_addr_clk2;
                clk2_timer_q[clk2_push] = 0;
                clk2_push = (clk2_push + 1) % 256;
                clk2_q_size = clk2_q_size + 1;
            end
        end

        // Validation Checks
        if (ar_valid_clk2 && (ar_addr_clk2 > 32'd65535 || ^ar_addr_clk2 === 1'bx)) begin
            $display("\n[AXI ERROR] clk2 AR_ADDR %h out of range/invalid", ar_addr_clk2); fail_AXI();
        end
        if (r_valid_clk2 && (^r_data_clk2 === 1'bx || ^r_data_clk2 === 1'bz)) begin
            $display("\n[AXI ERROR] clk2 R_DATA cannot be X/Z when R_VALID is high (Got: %h)", r_data_clk2); fail_AXI();
        end
        if (!ar_valid_clk2 && ar_addr_clk2 !== 32'b0) begin
            $display("\n[AXI ERROR] clk2 AR_ADDR must be 0 when AR_VALID is low"); fail_AXI();
        end
        if (!r_valid_clk2 && r_data_clk2 !== 64'b0) begin
            $display("\n[AXI ERROR] clk2 R_DATA must be 0 when R_VALID is low"); fail_AXI();
        end

        // Stability Checks
        if (ar_valid_clk2_d && !ar_ready_clk2_d) begin
            if (!ar_valid_clk2 || ar_addr_clk2 !== ar_addr_clk2_d) begin
                $display("\n[AXI ERROR] clk2 AR channel unstable"); fail_AXI();
            end
        end
        if (r_valid_clk2_d && !r_ready_clk2_d) begin
            if (!r_valid_clk2 || r_data_clk2 !== r_data_clk2_d) begin
                $display("\n[AXI ERROR] clk2 R channel unstable"); fail_AXI();
            end
        end
        
        // Handshake Timeouts
        if (ar_valid_clk2 && !ar_ready_clk2) ar_wait_clk2 = ar_wait_clk2 + 1; else ar_wait_clk2 = 0;
        if (ar_wait_clk2 > 500) begin $display("\n[AXI ERROR] clk2 AR_READY timeout"); fail_AXI(); end
        
        if (r_valid_clk2 && !r_ready_clk2) r_wait_clk2 = r_wait_clk2 + 1; else r_wait_clk2 = 0;
        if (r_wait_clk2 > 500) begin $display("\n[AXI ERROR] clk2 R_READY timeout"); fail_AXI(); end

        // History Update
        ar_valid_clk2_d = ar_valid_clk2; ar_addr_clk2_d = ar_addr_clk2; ar_ready_clk2_d = ar_ready_clk2;
        r_valid_clk2_d = r_valid_clk2;   r_data_clk2_d = r_data_clk2;   r_ready_clk2_d = r_ready_clk2;
    end else begin
        ar_valid_clk2_d = 0; r_valid_clk2_d = 0; clk2_q_size = 0;
        ar_ready_clk2_d = 0; r_ready_clk2_d = 0; clk2_push = 0; clk2_pop = 0;
        ar_wait_clk2 = 0; r_wait_clk2 = 0;
    end
end

// --- CLK3 Domain Checks & Transaction Queue ---
reg ar_valid_clk3_d, r_valid_clk3_d;
reg ar_ready_clk3_d, r_ready_clk3_d;
reg [31:0] ar_addr_clk3_d;
reg [63:0] r_data_clk3_d;

integer clk3_q_size = 0;
reg [31:0] clk3_ar_q [0:255];
integer clk3_timer_q [0:255];
integer clk3_push = 0;
integer clk3_pop = 0;
integer ar_wait_clk3 = 0, r_wait_clk3 = 0;
reg [31:0] clk3_exp_addr;
integer clk3_q_idx, clk3_q_offset;

always @(negedge clk3) begin
    if (rst_n && check_en) begin
        // Update Timers for all outstanding requests
        if (clk3_q_size > 0) begin
            for (clk3_q_offset = 0; clk3_q_offset < clk3_q_size; clk3_q_offset = clk3_q_offset + 1) begin
                clk3_q_idx = (clk3_pop + clk3_q_offset) % 256;
                clk3_timer_q[clk3_q_idx] = clk3_timer_q[clk3_q_idx] + 1;
                if (clk3_timer_q[clk3_q_idx] > 500) begin
                    $display("\n[AXI ERROR] clk3 R channel handshake timeout (>500 cycles) for ADDR: %h", clk3_ar_q[clk3_q_idx]); 
                    fail_AXI();
                end
            end
        end

        // R Channel Handshake (Pop & Check)
        if (r_valid_clk3 && r_ready_clk3) begin
            if (clk3_q_size == 0 && !(ar_valid_clk3 && ar_ready_clk3)) begin
                $display("\n[AXI ERROR] clk3 R channel handshake without prior AR (outstanding == 0)"); fail_AXI();
            end else begin
                // Support 0-cycle response
                if (clk3_q_size == 0) clk3_exp_addr = ar_addr_clk3;
                else clk3_exp_addr = clk3_ar_q[clk3_pop];

                if (r_data_clk3 !== golden_DRAM[clk3_exp_addr[15:0]]) begin
                    $display("\n[AXI ERROR] clk3 R_DATA mismatch or Out-of-Order!");
                    $display("Expected Data for ADDR %h is %h, Got: %h", clk3_exp_addr, golden_DRAM[clk3_exp_addr[15:0]], r_data_clk3);
                    fail_AXI();
                end

                if (clk3_q_size > 0) begin
                    clk3_pop = (clk3_pop + 1) % 256;
                    clk3_q_size = clk3_q_size - 1;
                end
            end
        end

        // AR Channel Handshake (Push)
        if (ar_valid_clk3 && ar_ready_clk3) begin
            if (!(r_valid_clk3 && r_ready_clk3 && clk3_q_size == 0)) begin
                if (clk3_q_size >= 256) begin
                    $display("\n[AXI ERROR] clk3 Outstanding Queue Overflow (>256)!"); fail_AXI();
                end
                clk3_ar_q[clk3_push] = ar_addr_clk3;
                clk3_timer_q[clk3_push] = 0;
                clk3_push = (clk3_push + 1) % 256;
                clk3_q_size = clk3_q_size + 1;
            end
        end

        if (ar_valid_clk3 && (ar_addr_clk3 > 32'd65535 || ^ar_addr_clk3 === 1'bx)) begin
            $display("\n[AXI ERROR] clk3 AR_ADDR %h out of range/invalid", ar_addr_clk3); fail_AXI();
        end
        if (r_valid_clk3 && (^r_data_clk3 === 1'bx || ^r_data_clk3 === 1'bz)) begin
            $display("\n[AXI ERROR] clk3 R_DATA cannot be X/Z when R_VALID is high (Got: %h)", r_data_clk3); fail_AXI();
        end
        if (!ar_valid_clk3 && ar_addr_clk3 !== 32'b0) begin
            $display("\n[AXI ERROR] clk3 AR_ADDR must be 0 when AR_VALID is low"); fail_AXI();
        end
        if (!r_valid_clk3 && r_data_clk3 !== 64'b0) begin
            $display("\n[AXI ERROR] clk3 R_DATA must be 0 when R_VALID is low"); fail_AXI();
        end

        if (ar_valid_clk3_d && !ar_ready_clk3_d) begin
            if (!ar_valid_clk3 || ar_addr_clk3 !== ar_addr_clk3_d) begin
                $display("\n[AXI ERROR] clk3 AR channel unstable"); fail_AXI();
            end
        end
        if (r_valid_clk3_d && !r_ready_clk3_d) begin
            if (!r_valid_clk3 || r_data_clk3 !== r_data_clk3_d) begin
                $display("\n[AXI ERROR] clk3 R channel unstable"); fail_AXI();
            end
        end
        
        if (ar_valid_clk3 && !ar_ready_clk3) ar_wait_clk3 = ar_wait_clk3 + 1; else ar_wait_clk3 = 0;
        if (ar_wait_clk3 > 500) begin $display("\n[AXI ERROR] clk3 AR_READY timeout"); fail_AXI(); end
        
        if (r_valid_clk3 && !r_ready_clk3) r_wait_clk3 = r_wait_clk3 + 1; else r_wait_clk3 = 0;
        if (r_wait_clk3 > 500) begin $display("\n[AXI ERROR] clk3 R_READY timeout"); fail_AXI(); end

        ar_valid_clk3_d = ar_valid_clk3; ar_addr_clk3_d = ar_addr_clk3; ar_ready_clk3_d = ar_ready_clk3;
        r_valid_clk3_d = r_valid_clk3;   r_data_clk3_d = r_data_clk3;   r_ready_clk3_d = r_ready_clk3;
    end else begin
        ar_valid_clk3_d = 0; r_valid_clk3_d = 0; clk3_q_size = 0;
        ar_ready_clk3_d = 0; r_ready_clk3_d = 0; clk3_push = 0; clk3_pop = 0;
        ar_wait_clk3 = 0; r_wait_clk3 = 0; 
    end
end

// --- Global Output / Idle & Overlap Monitor ---
always @(negedge clk1) begin
    if (check_en) begin
        if (out_valid === 1'b0 && out_data !== 64'b0) begin
            $display("\n[ERROR MAIN-3] out_data must be 0 when out_valid is 0! (out_data = %h)", out_data);
            fail_MAIN_3();
        end
        if (!busy_flag && out_valid === 1'b1) begin
            $display("\n[ERROR MAIN-3] Extra out_valid detected! System should be idle.");
            fail_MAIN_3();
        end
        // Input phase overlap check
        if ((in_mode_valid || in_valid) && out_valid === 1'b1) begin
            $display("\n[ERROR MAIN-3] out_valid MUST NOT be HIGH during input phase!");
            fail_MAIN_3();
        end
    end
end

//=======================================================================
// TASKS
//=======================================================================
task reset_task; begin
    force clk1 = 0; force clk2 = 0; force clk3 = 0;
    rst_n = 1'b1;
    busy_flag = 0;
    #(CYCLE_clk3);
    rst_n = 1'b0;
    #(CYCLE_clk3*3);

    // 嚴格的 Reset 檢查：僅檢查 DUT 驅動的 Master Outputs 與系統 Outputs
    if (out_valid !== 1'b0 || out_data !== 64'b0 ||
        ar_valid_clk2 !== 1'b0 || ar_addr_clk2 !== 32'b0 || r_ready_clk2 !== 1'b0 ||
        ar_valid_clk3 !== 1'b0 || ar_addr_clk3 !== 32'b0 || r_ready_clk3 !== 1'b0) begin
        
        $display("\n[ERROR MAIN-1] All DUT outputs MUST be reset to 0!");
        $display("out_valid: %b, out_data: %h", out_valid, out_data);
        $display("clk2 -> ar_valid: %b, ar_addr: %h, r_ready: %b", ar_valid_clk2, ar_addr_clk2, r_ready_clk2);
        $display("clk3 -> ar_valid: %b, ar_addr: %h, r_ready: %b", ar_valid_clk3, ar_addr_clk3, r_ready_clk3);
        fail_MAIN_1(); 
    end

    #(CYCLE_clk3);
    rst_n = 1'b1;
    #(CYCLE_clk3);
    release clk1; release clk2; release clk3;
end endtask

task automatic eval_tree_task;
    input  [15:0] ptr;
    output signed [63:0] result; 
    
    reg [63:0] node;
    reg [1:0] opcode;
    reg signed [63:0] left_val, right_val;
    begin
        node = golden_DRAM[ptr];
        
        if (node[63] == 1'b0) begin
            result = $signed({{33{node[62]}}, node[62:32]}); 
        end else begin
            opcode = node[33:32];
            eval_tree_task(node[31:16], left_val);
            eval_tree_task(node[15:0], right_val);
            
            case (opcode)
                2'b00: result = left_val + right_val;
                2'b01: result = left_val - right_val;
                2'b10: result = left_val * right_val;
                2'b11: result = left_val >>> right_val[5:0];
            endcase
        end
    end
endtask

task generate_input_task; begin
    mode_rand = $urandom_range(0, 1);
    current_mode = mode_rand[0];
    busy_flag = 1; 
    
    in_mode = current_mode;
    in_mode_valid = 1'b1;
    @(negedge clk1);
    in_mode_valid = 1'b0;
    in_mode = 1'd0; 

    if (current_mode == 1'b0) begin 
        expected_cycles = 4;
        for (i = 0; i < 4; i = i + 1) begin
            in_valid = 1'b1;
            saved_bank[i] = $urandom_range(0, 3);
            saved_src_row[i] = $urandom_range(0, 63);
            in_bank = saved_bank[i];
            in_src_row = saved_src_row[i];
            
            eval_tree_task({saved_bank[i], saved_src_row[i], 8'd0}, golden_ans_queue[i]);
            @(negedge clk1);
        end
        in_valid = 1'b0;
        in_bank = 2'd0;
        in_src_row = 6'd0;
    end 
    else begin 
        guass_target_row = $urandom_range(0, 63);
        for (i = 0; i < 4; i = i + 1) begin
            in_valid = 1'b1;
            in_bank = i[1:0]; 
            in_src_row = guass_target_row;
            @(negedge clk1);
        end
        in_valid = 1'b0;
        in_bank = 2'd0;
        in_src_row = 6'd0;

        g_N = 0; g_sum = 0;
        for (b = 0; b < 4; b = b + 1) begin
            for (c = 0; c < 256; c = c + 1) begin
                g_word = golden_DRAM[{b[1:0], guass_target_row, c[7:0]}];
                if (g_word[63] == 1'b0) begin
                    g_val = g_word[62:32];
                    g_sum = g_sum + g_val;
                    g_N = g_N + 1;
                end
            end
        end
        if (g_N > 0) g_mu = g_sum / g_N; else g_mu = 0;

        g_var_sum = 0;
        for (b = 0; b < 4; b = b + 1) begin
            for (c = 0; c < 256; c = c + 1) begin
                g_word = golden_DRAM[{b[1:0], guass_target_row, c[7:0]}];
                if (g_word[63] == 1'b0) begin
                    g_val = g_word[62:32];
                    if (g_val > g_mu) g_diff = g_val - g_mu;
                    else g_diff = g_mu - g_val;
                    g_var_sum = g_var_sum + (g_diff * g_diff);
                end
            end
        end
        if (g_N > 0) g_variance = g_var_sum / g_N; else g_variance = 0;

        ans_idx = 0;
        for (b = 0; b < 4; b = b + 1) begin
            for (c = 0; c < 256; c = c + 1) begin
                g_word = golden_DRAM[{b[1:0], guass_target_row, c[7:0]}];
                if (g_word[63] == 1'b0) begin
                    g_val = g_word[62:32];
                    if (g_val > g_mu) g_diff = g_val - g_mu;
                    else g_diff = g_mu - g_val;
                    
                    if ((g_diff * g_diff) <= g_variance) begin
                        golden_ans_queue[ans_idx] = g_word;
                        ans_idx = ans_idx + 1;
                    end else if (b == 3 && c == 255) begin
                        golden_ans_queue[ans_idx] = g_word;
                        ans_idx = ans_idx + 1;
                    end
                end else if (b == 3 && c == 255) begin
                    golden_ans_queue[ans_idx] = g_word;
                    ans_idx = ans_idx + 1;
                end
            end
        end
        expected_cycles = ans_idx;
    end
end endtask

task wait_out_valid_task; 
    integer k; 
begin
    latency = 0;
    out_cnt = 0;
    
    while (out_cnt < expected_cycles) begin
        latency = latency + 1;
        
        if (out_valid === 1'b1) begin
            if (out_data !== golden_ans_queue[out_cnt]) begin 
                $display("\n=========================================================================");
                $display(" ❌ [ERROR MAIN-4] Wrong Answer Detected!");
                $display(" Mode       : %s", (current_mode==0) ? "CALC" : "GUASS");
                $display(" Output Idx : %0d / %0d", out_cnt, expected_cycles - 1);
                $display(" Expected   : %h", golden_ans_queue[out_cnt]);
                $display(" Got        : %h", out_data);
                $display("-------------------------------------------------------------------------");
                
                if (current_mode == 1'b0) begin // CALC
                    $display(" 🌲 [CALC Debug Info - Tree Structure]");
                    $display(" Failed Tree Root: Bank %0d, Row %0d", saved_bank[out_cnt], saved_src_row[out_cnt]);
                    $display(" Tree Execution Trace:");
                    
                    // --- 陣列初始化 ---
                    for (k = 0; k < 8; k = k + 1) begin
                        tb_stack_r_ptr[k] = 16'd0;
                        tb_stack_l_val[k] = 64'd0;
                        tb_stack_op[k]    = 2'b00;
                        tb_stack_state[k] = 1'b0; // 初始化 stack_state
                    end
                    // 呼叫遞迴時傳入 dummy_result 接值
                    print_tree_task({saved_bank[out_cnt], saved_src_row[out_cnt], 8'd0}, 0, 0, dummy_result);
                    
                end else begin // GUASS
                    $display(" 📊 [GUASS Debug Info]");
                    $display(" Target Row : %0d", guass_target_row);
                    $display(" Total Valid: %0d", g_N);
                    $display(" Mean (mu)  : %0d", g_mu);
                    $display(" Variance   : %0d", g_variance);
                    $display("\n 📦 Expected Output Queue (All valid data):");
                    for (k = 0; k < expected_cycles; k = k + 1) begin
                        if (k == out_cnt)
                            $display("   [%0d] %h  <-- 💥 YOU FAILED HERE", k, golden_ans_queue[k]);
                        else
                            $display("   [%0d] %h", k, golden_ans_queue[k]);
                    end
                end
                $display("=========================================================================\n");
                fail_MAIN_4();
            end
            out_cnt = out_cnt + 1;
        end
        
        if (latency > 2000000) begin
            $display("\n=========================================================================");
            $display(" ⏳ [ERROR MAIN-2] Execution latency exceeded 20000 cycles!");
            $display(" Mode       : %s", (current_mode==0) ? "CALC" : "GUASS");
            
            if (current_mode == 1'b0) begin
                $display(" Tree Inputs: B%0d_R%0d, B%0d_R%0d, B%0d_R%0d, B%0d_R%0d",
                    saved_bank[0], saved_src_row[0], saved_bank[1], saved_src_row[1],
                    saved_bank[2], saved_src_row[2], saved_bank[3], saved_src_row[3]);
            end else begin
                $display(" Target Row : %0d", guass_target_row);
            end
            $display("=========================================================================\n");
            fail_MAIN_2();
        end 
        @(negedge clk1);
    end
    
    if (out_valid === 1'b1) begin
        $display("\n[ERROR MAIN-3] out_valid should pull LOW immediately after completing the specific cycles!");
        fail_MAIN_3();
    end
    
    busy_flag = 0; 
    total_latency = total_latency + latency;
end endtask

//---------------------------------------------------------------------
//   ULTIMATE DEBUG TOOL: RECURSIVE TREE PRINTER (完整 Stack 狀態版)
//---------------------------------------------------------------------
task automatic print_tree_task;
    input  [15:0] ptr;
    input  integer depth;
    input  integer sp; // 模擬 RTL 當下的 stack_push 深度
    output signed [63:0] result; 
    
    reg [63:0] node;
    reg [1:0] opcode;
    reg signed [63:0] left_val, right_val;
    integer s;
    begin
        // 🚨 終極防護：避免 X 或是 FFFF 造成無限遞迴卡死模擬器
        if (ptr === 16'hFFFF || ^ptr === 1'bx) begin
            for (s = 0; s < depth; s = s + 1) $write("    ");
            $display("|-> 🚨 [INVALID PTR] %04x", ptr);
            result = 64'd0;
        end else begin
            node = golden_DRAM[ptr];
            
            // 防護：如果 DRAM 裡面是 X (未初始化)，強制停止
            if (^node === 1'bx) begin
                for (s = 0; s < depth; s = s + 1) $write("    ");
                $display("|-> 🚨 [UNINITIALIZED] Addr: %04x", ptr);
                result = 64'd0;
            end else begin
            
                // 印出樹狀結構的縮排
                for (s = 0; s < depth; s = s + 1) begin
                    $write("    ");
                end
                
                if (node[63] == 1'b0) begin
                    // Number 節點
                    result = $signed({{33{node[62]}}, node[62:32]});
                    $display("|-> Num: %10d  [Addr: %04x] \n        => STATE: [%4d, %4d, %4d, %4d, %4d, %4d, %4d, %4d] \n        => OP   : [%4s, %4s, %4s, %4s, %4s, %4s, %4s, %4s] \n        => R_PTR: [%04x, %04x, %04x, %04x, %04x, %04x, %04x, %04x] \n        => L_VAL: [%4d, %4d, %4d, %4d, %4d, %4d, %4d, %4d] \n        [Golden: %016x]", 
                             result, ptr,
                             tb_stack_state[0], tb_stack_state[1], tb_stack_state[2], tb_stack_state[3],
                             tb_stack_state[4], tb_stack_state[5], tb_stack_state[6], tb_stack_state[7],
                             get_op_str(tb_stack_op[0]), get_op_str(tb_stack_op[1]), get_op_str(tb_stack_op[2]), get_op_str(tb_stack_op[3]),
                             get_op_str(tb_stack_op[4]), get_op_str(tb_stack_op[5]), get_op_str(tb_stack_op[6]), get_op_str(tb_stack_op[7]),
                             tb_stack_r_ptr[0], tb_stack_r_ptr[1], tb_stack_r_ptr[2], tb_stack_r_ptr[3],
                             tb_stack_r_ptr[4], tb_stack_r_ptr[5], tb_stack_r_ptr[6], tb_stack_r_ptr[7],
                             tb_stack_l_val[0], tb_stack_l_val[1], tb_stack_l_val[2], tb_stack_l_val[3],
                             tb_stack_l_val[4], tb_stack_l_val[5], tb_stack_l_val[6], tb_stack_l_val[7],
                             node);
                end else begin
                    opcode = node[33:32];
                    
                    // PATTERN 模擬 RTL 行為：把右子樹地址與 OP 推入對應的層數，並把狀態設為 0
                    tb_stack_r_ptr[sp] = node[15:0];
                    tb_stack_op[sp]    = opcode;
                    tb_stack_state[sp] = 1'b0; // 準備探索左子樹，狀態為 0
                    
                    // 遞迴探索左子樹 (會回傳算完的數值給 left_val)
                    print_tree_task(node[31:16], depth + 1, sp + 1, left_val);
                    
                    // 🌟 左邊探索完畢，將算出來的值塞進 stack_l_val 裡面！
                    tb_stack_l_val[sp] = left_val;
                    // 🌟 準備去右子樹了，將 stack_state 更新為 1
                    tb_stack_state[sp] = 1'b1;
                    
                    // 遞迴探索右子樹
                    print_tree_task(node[15:0], depth + 1, sp + 1, right_val);
                    
                    // 模擬 ALU 把左右算完並回傳給上一層
                    case (opcode)
                        2'b00: result = left_val + right_val;
                        2'b01: result = left_val - right_val;
                        2'b10: result = left_val * right_val;
                        2'b11: result = left_val >>> right_val[5:0];
                    endcase
                end
            end
        end
    end
endtask

endmodule








// `ifdef RTL
// 	`define CYCLE_TIME_clk1 20.1
// 	`define CYCLE_TIME_clk2 11.3
// 	`define CYCLE_TIME_clk3 34.7
// `endif
// `ifdef Period_1
// 	`define CYCLE_TIME_clk1 34.7
// 	`define CYCLE_TIME_clk2 20.1
// 	`define CYCLE_TIME_clk3 11.3
// `endif
// `ifdef Period_2
// 	`define CYCLE_TIME_clk1 11.3
// 	`define CYCLE_TIME_clk2 20.1
// 	`define CYCLE_TIME_clk3 34.7
// `endif
// `ifdef Period_3
// 	`define CYCLE_TIME_clk1 20.1
// 	`define CYCLE_TIME_clk2 11.3
// 	`define CYCLE_TIME_clk3 34.7
// `endif

// `ifdef GATE
//     `define CYCLE_TIME_clk1 20.1
// 	`define CYCLE_TIME_clk2 11.3
// 	`define CYCLE_TIME_clk3 34.7
// `endif
// module PATTERN(
//     output reg      clk1,
//     output reg      clk2,
//     output reg      clk3,

//     output reg      rst_n,
//     // AXI4-Lite Master
//     input      [31:0]  ar_addr_clk2, 
//     input              ar_valid_clk2, 
//     input              ar_ready_clk2,
//     input       [63:0] r_data_clk2,  
//     // input       [1:0]  r_resp_clk2, 
//     input              r_valid_clk2, 
//     input              r_ready_clk2,

//     input      [31:0]  ar_addr_clk3, 
//     input              ar_valid_clk3, 
//     input              ar_ready_clk3,
//     input       [63:0] r_data_clk3,  
//     // input       [1:0]  r_resp_clk3, 
//     input              r_valid_clk3, 
//     input              r_ready_clk3,

//     output reg       in_mode_valid,
//     output reg       in_mode,
//     output reg       in_valid,
//     output reg [1:0] in_bank,
//     output reg [5:0] in_src_row,
    
//     input             out_valid,
//     input [63:0]      out_data
// );


// // Golden Memory for Verification
// reg [63:0] golden_dram [0:65535];
// parameter DRAM_p_r = "../00_TESTBED/DRAM_init.dat";
// initial $readmemh(DRAM_p_r, golden_dram);

// //================================================================
// // parameters & integer
// //================================================================

// real	CYCLE_clk1 = `CYCLE_TIME_clk1;
// real	CYCLE_clk2 = `CYCLE_TIME_clk2;
// real	CYCLE_clk3 = `CYCLE_TIME_clk3;
// real    total_CYCLE = CYCLE_clk1 + CYCLE_clk2 + CYCLE_clk3;

// // ========== Parameter ==========
// integer pat_idx;
// integer total_latency;
// integer latency_cnt;

// integer    golden_out_cnt;   
// integer    out_rcv_cnt;

// parameter PAT_NUM = 100;

// //================================================================
// // wire & registers 
// //================================================================
// reg [63:0] golden_out_arr [0:1023];

// reg [9:0] ar_timeout_cnt_clk2, ar_timeout_cnt_clk3;
// reg [31:0] ar_addr_reg_clk2, ar_addr_reg_clk3;
// reg        ar_valid_reg_clk2, ar_valid_reg_clk3, ar_ready_reg_clk2, ar_ready_reg_clk3;

// reg [9:0] r_ready_timeout_cnt_clk2, r_ready_timeout_cnt_clk3;
// reg [9:0] ar_to_r_timeout_cnt_clk2;
// reg [7:0] outstanding_cnt_clk2, outstanding_cnt_clk3;
// reg [63:0] r_data_reg_clk2, r_data_reg_clk3;
// reg r_valid_reg_clk2, r_valid_reg_clk3, r_ready_reg_clk2, r_ready_reg_clk3;

// reg [31:0] ar_fifo_clk2 [0:1023];
// reg [9:0]  ar_wr_ptr_clk2;
// reg [9:0]  ar_rd_ptr_clk2;

// reg [31:0] ar_fifo_clk3 [0:1023];
// reg [9:0]  ar_wr_ptr_clk3;
// reg [9:0]  ar_rd_ptr_clk3;

// reg [63:0] g_sum;
// reg [63:0] g_mean;
// reg [127:0] g_var_sum;
// reg [127:0] g_var;
// reg [31:0] g_N;
// reg [63:0] g_val;
// reg [63:0] g_diff;
// reg [63:0] dram_data;

// // =================================================================
// // Hierarchical Signals for Hidden Checker
// // =================================================================
// wire [3:0]  dram_cmd   = TESTBED.u_DRAM.dram_cmd;
// wire [1:0]  dram_ba    = TESTBED.u_DRAM.dram_ba;
// wire [10:0] dram_addr  = TESTBED.u_DRAM.dram_addr;
// wire        dram_valid = TESTBED.u_DRAM.dram_valid;

// wire ar_fire_clk2   = ar_valid_clk2 && ar_ready_clk2;
// wire r_fire_clk2    = r_valid_clk2  && r_ready_clk2;
// wire ar_fire_clk3   = ar_valid_clk3 && ar_ready_clk3;
// wire r_fire_clk3    = r_valid_clk3  && r_ready_clk3;
// wire dram_read_fire = (dram_cmd === 4'b0101);
// wire dram_pre_fire  = (dram_cmd === 4'b0010);
// wire dram_act_fire  = (dram_cmd === 4'b0011);

// integer clk3_cnt;
// reg       bank_state    [0:3];  // 0: IDLE, 1: OPEN
// reg [5:0] bank_open_row [0:3];
// integer   bank_act_time [0:3];
// integer   bank_pre_time [0:3];
// integer   dram_i;

// parameter CDC_Q_DEPTH = 1024;
// reg [15:0] cdc_ar_q [0:CDC_Q_DEPTH-1];
// integer    cdc_q_head, cdc_q_tail;
// integer    cdc_q_enq_cnt, cdc_q_deq_cnt;
// wire signed [31:0] cdc_q_cnt = cdc_q_enq_cnt - cdc_q_deq_cnt;

// parameter Q_DEPTH = 1024;
// reg [15:0] ar_q_addr    [0:Q_DEPTH-1];
// reg        ar_q_matched [0:Q_DEPTH-1];
// integer    ar_q_age     [0:Q_DEPTH-1];
// integer    ar_q_head, ar_q_tail, ar_q_cnt;
// integer    q_i, search_idx, ar_q_cnt_delta;
// reg        match_found;
// //---------------------------------------------------------------------
// //  CLOCK
// //---------------------------------------------------------------------
// initial begin 
//     clk1 = 0;
//     clk2 = 0;
//     clk3 = 0;
// end
// always #(CYCLE_clk1/2.0) clk1 = ~clk1;
// always #(CYCLE_clk2/2.0) clk2 = ~clk2;
// always #(CYCLE_clk3/2.0) clk3 = ~clk3;


// //---------------------------------------------------------------------
// //  SIMULATION
// //---------------------------------------------------------------------
// initial begin
//     rst_n = 1'b0;
//     force clk1 = 0;
//     force clk2 = 0;
//     force clk3 = 0;
//     in_mode_valid = 1'b0;
//     in_mode = 1'bx;
//     in_valid = 1'b0;
//     in_bank = 1'bx;
//     in_src_row = 1'bx;

//     total_latency = 0;

//     reset_signal_task;
    
//     for (pat_idx = 0; pat_idx < PAT_NUM; pat_idx = pat_idx + 1) begin
//         generate_golden_task(); 
        
//         drive_input_task();     
        
//         wait_and_check_task();
//         check_cdc_ar_queue_empty_task();

//         $display("\033[1;32mPASS PATTERN NO.%4d\033[m | Mode: %s | Latency: %5d | Avg Latency: %5.2f", 
//           pat_idx, 
//           (current_mode == 0) ? "CALC " : "GUASS", 
//           latency_cnt, 
//           (total_latency * 1.0 / (pat_idx + 1))
//         );

//         repeat($urandom_range(2, 4)) @(negedge clk1);
//     end

//     YOU_PASS_task();
// end

// // =======================================
// // Monitors
// // =======================================

// // ========= CLK2 AXI =========
// // ------ AR Channel -------
// // Timeout check1
// always @(posedge clk2 or negedge rst_n) begin
//     if (!rst_n) begin
//         ar_timeout_cnt_clk2 <= 0;
//     end else begin
//         if (ar_valid_clk2 && !ar_ready_clk2) begin
//             ar_timeout_cnt_clk2 <= ar_timeout_cnt_clk2 + 1;
//         end else begin
//             ar_timeout_cnt_clk2 <= 0;
//         end
//     end
// end

// always @(negedge clk2) begin
//     if (ar_timeout_cnt_clk2 > 500) YOU_FAIL_AXI_task("Timeout Check1 FAIL : ar_ready_clk2 timeout (>500 cycles)");
// end


// always @(posedge clk2 or negedge rst_n) begin
//     if (!rst_n) begin
//         ar_valid_reg_clk2 <= 1'b0;
//         ar_ready_reg_clk2 <= 1'b0;
//         ar_addr_reg_clk2  <= 32'd0;
//     end else begin
//         ar_valid_reg_clk2 <= ar_valid_clk2;
//         ar_ready_reg_clk2 <= ar_ready_clk2;
//         // New transaction starts when valid rises, OR immediately after a handshake
//         if (ar_valid_clk2 && (!ar_valid_reg_clk2 || ar_ready_reg_clk2)) begin
//             ar_addr_reg_clk2 <= ar_addr_clk2;
//         end
//     end
// end

// always @(negedge clk2) begin
//     if (rst_n) begin
//         // 1. Reset check
//         if (!ar_valid_clk2 && (ar_addr_clk2 !== 32'b0)) begin
//             YOU_FAIL_AXI_task("AXI FAIL : ar_addr_clk2 not reset to 0 when ar_valid is low");
//         end
//         // 2. Range check 
//         if (ar_valid_clk2 && (ar_addr_clk2 > 65535)) begin
//             YOU_FAIL_AXI_task("AXI FAIL : ar_addr_clk2 out of range (0~65535)");
//         end
//         // 3. Stability: in-transaction means last cycle had valid=1 and handshake didn't complete
//         if (ar_valid_reg_clk2 && !ar_ready_reg_clk2) begin
//             if (!ar_valid_clk2) begin
//                 YOU_FAIL_AXI_task("AXI FAIL : ar_valid_clk2 deasserted before ar_ready");
//             end
//             if (ar_addr_clk2 !== ar_addr_reg_clk2) begin
//                 YOU_FAIL_AXI_task("AXI FAIL : ar_addr_clk2 not stable");
//             end
//         end
//     end
// end

// //------ R Channel -------
// //  Outstanding Tracker
// always @(posedge clk2 or negedge rst_n) begin
//     if (!rst_n) begin
//         outstanding_cnt_clk2 <= 0;
//     end else begin
//         case ({ar_fire_clk2, r_fire_clk2})
//             2'b10: outstanding_cnt_clk2 <= outstanding_cnt_clk2 + 1;
//             2'b01: outstanding_cnt_clk2 <= outstanding_cnt_clk2 - 1;
//         endcase
//     end
// end

// always @(posedge clk2 or negedge rst_n) begin
//     if (!rst_n) begin
//         r_ready_timeout_cnt_clk2 <= 0; // timeout check1
//         ar_to_r_timeout_cnt_clk2 <= 0; // timeout check2
//     end else begin
//         if (r_valid_clk2 && !r_ready_clk2) begin
//             r_ready_timeout_cnt_clk2 <= r_ready_timeout_cnt_clk2 + 1;
//         end else begin
//             r_ready_timeout_cnt_clk2 <= 0;
//         end

//         if (outstanding_cnt_clk2 > 0 && !r_fire_clk2) begin
//             ar_to_r_timeout_cnt_clk2 <= ar_to_r_timeout_cnt_clk2 + 1;
//         end else if (r_fire_clk2) begin
//             ar_to_r_timeout_cnt_clk2 <= 0; 
//         end
//     end
// end

// always @(negedge clk2) begin
//     if (r_ready_timeout_cnt_clk2 > 500) 
//         YOU_FAIL_AXI_task("AXI FAIL : r_ready_clk2 timeout (>500 cycles)");
//     if (ar_to_r_timeout_cnt_clk2 > 500) 
//         YOU_FAIL_AXI_task("AXI FAIL : CLK2 R channel timeout (>500 cycles after AR)");
// end

// always @(posedge clk2 or negedge rst_n) begin
//     if (!rst_n) begin
//         r_valid_reg_clk2 <= 1'b0;
//         r_ready_reg_clk2 <= 1'b0;
//         r_data_reg_clk2  <= 64'd0;
//     end else begin
//         r_valid_reg_clk2 <= r_valid_clk2;
//         r_ready_reg_clk2 <= r_ready_clk2;
//         if (r_valid_clk2 && (!r_valid_reg_clk2 || r_ready_reg_clk2)) begin
//             r_data_reg_clk2 <= r_data_clk2;
//         end
//     end
// end

// always @(negedge clk2) begin
//     if (rst_n) begin
//         // 1. Reset check
//         if (!r_valid_clk2 && (r_data_clk2 !== 64'b0)) begin
//             YOU_FAIL_AXI_task("AXI FAIL : r_data_clk2 not reset to 0 when r_valid is low");
//         end
//         // 2. Stability
//         if (r_valid_reg_clk2 && !r_ready_reg_clk2) begin
//             if (!r_valid_clk2) begin
//                 YOU_FAIL_AXI_task("AXI FAIL : r_valid_clk2 deasserted before r_ready");
//             end
//             if (r_data_clk2 !== r_data_reg_clk2) begin
//                 YOU_FAIL_AXI_task("AXI FAIL : r_data_clk2 not stable");
//             end
//         end
//     end
// end

// // ========= CLK3 AXI =========
// // ------ AR Channel -------
// always @(posedge clk3 or negedge rst_n) begin
//     if (!rst_n) begin
//         ar_timeout_cnt_clk3 <= 0;
//     end else begin
//         if (ar_valid_clk3 && !ar_ready_clk3) begin
//             ar_timeout_cnt_clk3 <= ar_timeout_cnt_clk3 + 1;
//         end else begin
//             ar_timeout_cnt_clk3 <= 0;
//         end
//     end
// end

// always @(negedge clk3) begin
//     if (ar_timeout_cnt_clk3 > 500) YOU_FAIL_AXI_task("Timeout Check1 FAIL: ar_ready_clk3 timeout (>500 cycles)");
// end

// // =================================================================
// // clk2 to clk3 AR Sequence Checker
// // =================================================================
// always @(posedge clk2 or negedge rst_n) begin
//     if (!rst_n) begin
//         cdc_q_tail    <= 0;
//         cdc_q_enq_cnt <= 0;
//     end else if (ar_fire_clk2) begin
//         if (cdc_q_cnt >= CDC_Q_DEPTH) begin
//             YOU_FAIL_AXI_task("CDC SEQUENCE FAIL: clk2 to clk3 AR queue overflow.");
//         end
//         cdc_ar_q[cdc_q_tail] <= ar_addr_clk2[15:0];
//         cdc_q_tail           <= (cdc_q_tail + 1) % CDC_Q_DEPTH;
//         cdc_q_enq_cnt        <= cdc_q_enq_cnt + 1;
//     end
// end

// always @(posedge clk3 or negedge rst_n) begin
//     if (!rst_n) begin
//         cdc_q_head    <= 0;
//         cdc_q_deq_cnt <= 0;
//     end else if (ar_fire_clk3) begin
//         if (cdc_q_cnt <= 0) begin
//             YOU_FAIL_AXI_task("CDC SEQUENCE FAIL: clk3 issued AR request but clk2 queue is empty.");
//         end else if (ar_addr_clk3[15:0] !== cdc_ar_q[cdc_q_head]) begin
//             $display("[Pattern Debug] CDC AR expected=%h, got=%h, head=%0d, tail=%0d",
//                      cdc_ar_q[cdc_q_head], ar_addr_clk3[15:0], cdc_q_head, cdc_q_tail);
//             YOU_FAIL_AXI_task("CDC SEQUENCE FAIL: clk3 AR address does not match clk2 AR address.");
//         end
//         cdc_q_head    <= (cdc_q_head + 1) % CDC_Q_DEPTH;
//         cdc_q_deq_cnt <= cdc_q_deq_cnt + 1;
//     end
// end


// always @(posedge clk3 or negedge rst_n) begin
//     if (!rst_n) begin
//         ar_valid_reg_clk3 <= 1'b0;
//         ar_ready_reg_clk3 <= 1'b0;
//         ar_addr_reg_clk3  <= 32'd0;
//     end else begin
//         ar_valid_reg_clk3 <= ar_valid_clk3;
//         ar_ready_reg_clk3 <= ar_ready_clk3;
//         if (ar_valid_clk3 && (!ar_valid_reg_clk3 || ar_ready_reg_clk3)) begin
//             ar_addr_reg_clk3 <= ar_addr_clk3;
//         end
//     end
// end

// always @(negedge clk3) begin
//     if (rst_n) begin
//         if (!ar_valid_clk3 && (ar_addr_clk3 !== 32'b0)) begin
//             YOU_FAIL_AXI_task("AXI FAIL: ar_addr_clk3 not reset to 0 when ar_valid is low");
//         end
//         if (ar_valid_clk3 && (ar_addr_clk3 > 65535)) begin
//             YOU_FAIL_AXI_task("AXI FAIL: ar_addr_clk3 out of range (0~65535)");
//         end
//         if (ar_valid_reg_clk3 && !ar_ready_reg_clk3) begin
//             if (!ar_valid_clk3) begin
//                 YOU_FAIL_AXI_task("AXI FAIL: ar_valid_clk3 deasserted before ar_ready");
//             end
//             if (ar_addr_clk3 !== ar_addr_reg_clk3) begin
//                 YOU_FAIL_AXI_task("AXI FAIL: ar_addr_clk3 not stable");
//             end
//         end
//     end
// end


// //------ R Channel -------
// //  Outstanding Tracker
// always @(posedge clk3 or negedge rst_n) begin
//     if (!rst_n) begin
//         outstanding_cnt_clk3 <= 0;
//     end else begin
//         case ({ar_fire_clk3, r_fire_clk3})
//             2'b10: outstanding_cnt_clk3 <= outstanding_cnt_clk3 + 1;
//             2'b01: outstanding_cnt_clk3 <= outstanding_cnt_clk3 - 1;
//         endcase
//     end
// end

// always @(posedge clk3 or negedge rst_n) begin
//     if (!rst_n) begin
//         r_ready_timeout_cnt_clk3 <= 0; // timeout check1
//     end else begin
//         if (r_valid_clk3 && !r_ready_clk3) begin
//             r_ready_timeout_cnt_clk3 <= r_ready_timeout_cnt_clk3 + 1;
//         end else begin
//             r_ready_timeout_cnt_clk3 <= 0;
//         end
//     end
// end

// always @(negedge clk3) begin
//     if (r_ready_timeout_cnt_clk3 > 500) 
//         YOU_FAIL_AXI_task("AXI FAIL : r_ready_clk3 timeout (>500 cycles)");
// end

// always @(posedge clk3 or negedge rst_n) begin
//     if (!rst_n) begin
//         r_valid_reg_clk3 <= 1'b0;
//         r_ready_reg_clk3 <= 1'b0;
//         r_data_reg_clk3  <= 64'd0;
//     end else begin
//         r_valid_reg_clk3 <= r_valid_clk3;
//         r_ready_reg_clk3 <= r_ready_clk3;
//         if (r_valid_clk3 && (!r_valid_reg_clk3 || r_ready_reg_clk3)) begin
//             r_data_reg_clk3 <= r_data_clk3;
//         end
//     end
// end

// always @(negedge clk3) begin
//     if (rst_n) begin
//         // 1. Reset check
//         if (!r_valid_clk3 && (r_data_clk3 !== 64'b0)) begin
//             YOU_FAIL_AXI_task("AXI FAIL : r_data_clk3 not reset to 0 when r_valid is low");
//         end
//         // 2. Stability
//         if (r_valid_reg_clk3 && !r_ready_reg_clk3) begin
//             if (!r_valid_clk3) begin
//                 YOU_FAIL_AXI_task("AXI FAIL : r_valid_clk3 deasserted before r_ready");
//             end
//             if (r_data_clk3 !== r_data_reg_clk3) begin
//                 YOU_FAIL_AXI_task("AXI FAIL : r_data_clk3 not stable");
//             end
//         end
//     end
// end

// // =================================================================
// // 1. Physical DRAM State & Timing Checker
// // =================================================================
// always @(posedge clk3 or negedge rst_n) begin
//     if (!rst_n) begin
//         clk3_cnt <= 0;
//         for (dram_i = 0; dram_i < 4; dram_i = dram_i + 1) begin
//             bank_state[dram_i]    <= 0;
//             bank_open_row[dram_i] <= 6'b0;
//             bank_act_time[dram_i] <= -100;
//             bank_pre_time[dram_i] <= -100;
//         end
//     end else begin
//         clk3_cnt <= clk3_cnt + 1;

//         if (dram_act_fire) begin
//             if (bank_state[dram_ba] == 1) begin
//                 YOU_FAIL_AXI_task("DRAM TIMING FAIL: Row Miss Penalty! Issued ACT to an already OPEN bank without PRE.");
//             end
//             if (clk3_cnt - bank_pre_time[dram_ba] < 3) begin
//                 YOU_FAIL_AXI_task("DRAM TIMING FAIL: t_RP violation! ACT issued too soon after PRE (< 3 cycles).");
//             end
//             bank_state[dram_ba]    <= 1;
//             bank_open_row[dram_ba] <= dram_addr[5:0];
//             bank_act_time[dram_ba] <= clk3_cnt;
//         end else if (dram_read_fire) begin
//             if (bank_state[dram_ba] == 0) begin
//                 YOU_FAIL_AXI_task("DRAM TIMING FAIL: Issued READ to an IDLE bank (Not OPEN).");
//             end
//             if (clk3_cnt - bank_act_time[dram_ba] < 2) begin
//                 YOU_FAIL_AXI_task("DRAM TIMING FAIL: t_RCD violation! READ issued too soon after ACT (< 2 cycles).");
//             end

//             // $display("[Pattern Debug] DRAM READ at Bank=%0d, Row=%0d, Col=%0d", dram_ba, bank_open_row[dram_ba], dram_addr[7:0]);
//         end else if (dram_cmd === 4'b0100) begin
//             if (bank_state[dram_ba] == 0) begin
//                 YOU_FAIL_AXI_task("DRAM TIMING FAIL: Issued WRITE to an IDLE bank (Not OPEN).");
//             end
//             if (clk3_cnt - bank_act_time[dram_ba] < 2) begin
//                 YOU_FAIL_AXI_task("DRAM TIMING FAIL: t_RCD violation! WRITE issued too soon after ACT (< 2 cycles).");
//             end
//         end else if (dram_pre_fire) begin
//             if (bank_state[dram_ba] == 0) begin
//                 YOU_FAIL_AXI_task("DRAM TIMING FAIL: Issued PRE to an IDLE bank.");
//             end
//             if (clk3_cnt - bank_act_time[dram_ba] < 5) begin
//                 YOU_FAIL_AXI_task("DRAM TIMING FAIL: t_RAS violation! PRE issued too soon after ACT (< 5 cycles).");
//             end
//             bank_state[dram_ba]    <= 0;
//             bank_pre_time[dram_ba] <= clk3_cnt;
//         end
//     end
// end

// // =================================================================
// // 2. AXI-to-DRAM 1:1 Mapping & Outstanding Age Checker (Bypass Match)
// // =================================================================
// reg bypass_match;

// always @(posedge clk3 or negedge rst_n) begin
//     if (!rst_n) begin
//         ar_q_head <= 0;
//         ar_q_tail <= 0;
//         ar_q_cnt  <= 0;
//         for (q_i = 0; q_i < Q_DEPTH; q_i = q_i + 1) begin
//             ar_q_addr[q_i]    <= 16'd0;
//             ar_q_matched[q_i] <= 1'b0;
//             ar_q_age[q_i]     <= 0;
//         end
//     end else begin
//         ar_q_cnt_delta = 0;
//         match_found    = 1'b0;
//         bypass_match   = 1'b0;

//         // Age Update & Timeout Check
//         for (q_i = 0; q_i < ar_q_cnt; q_i = q_i + 1) begin
//             search_idx = (ar_q_head + q_i) % Q_DEPTH;
//             ar_q_age[search_idx] = ar_q_age[search_idx] + 1;
//             if (ar_q_age[search_idx] > 500) begin
//                 YOU_FAIL_AXI_task("TIMEOUT FAIL: Outstanding AR request age exceeded 500 cycles!");
//             end
//         end

//         // Match: Physical DRAM READ before enqueue, so same-cycle AR can bypass.
//         if (dram_read_fire) begin
//             match_found = 0;

//             // 1. First search existing unmatched AR entries.
//             for (q_i = 0; q_i < ar_q_cnt; q_i = q_i + 1) begin
//                 search_idx = (ar_q_head + q_i) % Q_DEPTH;
//                 if (!match_found && !ar_q_matched[search_idx]) begin
//                     if (ar_q_addr[search_idx] == {dram_ba, bank_open_row[dram_ba], dram_addr[7:0]}) begin
//                         ar_q_matched[search_idx] <= 1'b1;
//                         match_found = 1;
//                     end
//                 end
//             end

//             // 2. If no queued AR matches, check the AR entering this same cycle.
//             if (!match_found && ar_fire_clk3) begin
//                 if (ar_addr_clk3[15:0] == {dram_ba, bank_open_row[dram_ba], dram_addr[7:0]}) begin
//                     bypass_match = 1'b1;
//                     match_found  = 1;
//                 end
//             end

//             if (!match_found) begin
//                 $display("[Pattern Debug] DRAM READ mapping Bank=%0d, Row=%0d, Col=%0d, Addr=%h",
//                          dram_ba, bank_open_row[dram_ba], dram_addr[7:0],
//                          {dram_ba, bank_open_row[dram_ba], dram_addr[7:0]});
//                 YOU_FAIL_AXI_task("STRICT MAPPING FAIL: Issued DRAM READ without a matching/unmatched AXI AR request!");
//             end
//         end

//         // Enqueue: AXI AR Handshake
//         if (ar_fire_clk3) begin
//             if (ar_q_cnt == Q_DEPTH) YOU_FAIL_AXI_task("PATTERN INTERNAL: AR Tracking Queue Overflow!");
//             ar_q_addr[ar_q_tail]    <= ar_addr_clk3[15:0];
//             ar_q_matched[ar_q_tail] <= bypass_match;
//             ar_q_age[ar_q_tail]     <= 0;
//             ar_q_tail               <= (ar_q_tail + 1) % Q_DEPTH;
//             ar_q_cnt_delta          = ar_q_cnt_delta + 1;
//         end

//         // Dequeue: AXI R Handshake
//         if (r_fire_clk3) begin
//             if (ar_q_cnt == 0) YOU_FAIL_AXI_task("STRICT MAPPING FAIL: Unexpected R channel response (Queue Empty)!");

//             if (!ar_q_matched[ar_q_head] && !(ar_fire_clk3 && bypass_match && ar_q_cnt == 0)) begin
//                 YOU_FAIL_AXI_task("STRICT MAPPING FAIL: AXI R response returned BEFORE physical DRAM READ was matched! (Fake Data)");
//             end

//             ar_q_head      <= (ar_q_head + 1) % Q_DEPTH;
//             ar_q_cnt_delta = ar_q_cnt_delta - 1;
//         end

//         ar_q_cnt <= ar_q_cnt + ar_q_cnt_delta;
//     end
// end

// // ======== Output =========
// always @(negedge clk1) begin
//     if (rst_n) begin
//         if (out_valid === 1'bx || out_valid === 1'bz) begin
//             YOU_FAIL_MAIN_task("MAIN FAIL: out_valid contains X or Z");
//         end
//         if (out_valid) begin
//             if (^out_data === 1'bx) begin
//                 YOU_FAIL_MAIN_task("MAIN FAIL: out_data contains X or Z when out_valid is high");
//             end
//         end
//     end
// end


// // ======== CLK2 In-Order Tracker ========
// always @(posedge clk2 or negedge rst_n) begin
//     if (!rst_n) begin
//         ar_wr_ptr_clk2 <= 0;
//     end else if (ar_fire_clk2) begin
//         ar_fifo_clk2[ar_wr_ptr_clk2] <= ar_addr_clk2;
//         ar_wr_ptr_clk2 <= ar_wr_ptr_clk2 + 1;
//     end
// end

// always @(posedge clk2 or negedge rst_n) begin
//     if (!rst_n) begin
//         ar_rd_ptr_clk2 <= 0;
//     end else if (r_fire_clk2) begin
//         ar_rd_ptr_clk2 <= ar_rd_ptr_clk2 + 1;
//     end
// end

// always @(negedge clk2) begin
//     if (rst_n) begin
//         if (r_valid_clk2) begin
//             if (ar_rd_ptr_clk2 == ar_wr_ptr_clk2) begin
//                 YOU_FAIL_AXI_task("AXI FAIL: Unexpected R channel response on CLK2 (No pending AR)");
//             end
//             else if (r_data_clk2 !== golden_dram[ar_fifo_clk2[ar_rd_ptr_clk2]]) begin
//                 $display("EXPECTED: %h, GET: %h at ADDR: %d", golden_dram[ar_fifo_clk2[ar_rd_ptr_clk2]], r_data_clk2, ar_fifo_clk2[ar_rd_ptr_clk2]);
//                 YOU_FAIL_AXI_task("AXI FAIL: CLK2 R channel data does not match golden DRAM (In-Order Error)");
//             end
//         end
//     end
// end

// // ======== CLK2 In-Order Tracker ========
// always @(posedge clk3 or negedge rst_n) begin
//     if (!rst_n) begin
//         ar_wr_ptr_clk3 <= 0;
//     end else if (ar_fire_clk3) begin
//         ar_fifo_clk3[ar_wr_ptr_clk3] <= ar_addr_clk3;
//         ar_wr_ptr_clk3 <= ar_wr_ptr_clk3 + 1;
//     end
// end

// always @(posedge clk3 or negedge rst_n) begin
//     if (!rst_n) begin
//         ar_rd_ptr_clk3 <= 0;
//     end else if (r_fire_clk3) begin
//         ar_rd_ptr_clk3 <= ar_rd_ptr_clk3 + 1;
//     end
// end

// always @(negedge clk3) begin
//     if (rst_n) begin
//         if (r_valid_clk3) begin
//             if (ar_rd_ptr_clk3 == ar_wr_ptr_clk3) begin
//                 YOU_FAIL_AXI_task("AXI FAIL: Unexpected R channel response on CLK3 (No pending AR)");
//             end
//             else if (r_data_clk3 !== golden_dram[ar_fifo_clk3[ar_rd_ptr_clk3]]) begin
//                 YOU_FAIL_AXI_task("AXI FAIL: CLK3 R channel data does not match golden DRAM (In-Order Error)");
//             end
//         end
//     end
// end

// // =======================================
// // Tasks
// // =======================================
// task reset_signal_task; // 
//     integer reset_error;
// begin
//     reset_error = 0;
//     #(total_CYCLE); rst_n = 1'b0;

//     #(total_CYCLE * 3); rst_n = 1'b1;
    
//     if (out_valid !== 1'b0) begin $display("[Reset Error] out_valid = %b, expected 0", out_valid); reset_error = 1; end
//     if (out_data !== 64'b0) begin $display("[Reset Error] out_data = %h, expected 0", out_data); reset_error = 1; end

//     // ---------AXI----------  I'm not sure whether AXI needs to be reset to zero.
//     if (ar_valid_clk2 !== 1'b0) begin $display("[Reset Error] ar_valid_clk2 = %b, expected 0", ar_valid_clk2); reset_error = 1; end
//     if (ar_addr_clk2 !== 32'b0) begin $display("[Reset Error] ar_addr_clk2 = %h, expected 0", ar_addr_clk2); reset_error = 1; end
//     if (ar_ready_clk2 !== 1'b0) begin $display("[Reset Error] ar_ready_clk2 = %b, expected 0", ar_ready_clk2); reset_error = 1; end
//     if (r_ready_clk2 !== 1'b0)  begin $display("[Reset Error] r_ready_clk2 = %b, expected 0", r_ready_clk2); reset_error = 1; end
//     if (r_valid_clk2 !== 1'b0)  begin $display("[Reset Error] r_valid_clk2 = %b, expected 0", r_valid_clk2); reset_error = 1; end
//     if (r_data_clk2 !== 64'b0)  begin $display("[Reset Error] r_data_clk2 = %h, expected 0", r_data_clk2); reset_error = 1; end

//     if (ar_valid_clk3 !== 1'b0) begin $display("[Reset Error] ar_valid_clk3 = %b, expected 0", ar_valid_clk3); reset_error = 1; end
//     if (ar_addr_clk3 !== 32'b0) begin $display("[Reset Error] ar_addr_clk3 = %h, expected 0", ar_addr_clk3); reset_error = 1; end
//     if (ar_ready_clk3 !== 1'b0) begin $display("[Reset Error] ar_ready_clk3 = %b, expected 0", ar_ready_clk3); reset_error = 1; end
//     if (r_ready_clk3 !== 1'b0)  begin $display("[Reset Error] r_ready_clk3 = %b, expected 0", r_ready_clk3); reset_error = 1; end
//     if (r_valid_clk3 !== 1'b0)  begin $display("[Reset Error] r_valid_clk3 = %b, expected 0", r_valid_clk3); reset_error = 1; end
//     if (r_data_clk3 !== 64'b0)  begin $display("[Reset Error] r_data_clk3 = %h, expected 0", r_data_clk3); reset_error = 1; end
//     // -----------------------

//     if (reset_error) begin
//         $display("---------------------------------------------------------------------------------------------");
//         $display("                                                                                             ");
//         $display("             FAIL! Output and AXI(?) signals should be 0 after reset at %4t.                     ", $time);
//         $display("                                                                                             ");
//         $display("---------------------------------------------------------------------------------------------");
//         $finish;
//     end

//     #(total_CYCLE * 2);
//     release clk1;
//     release clk2;
//     release clk3;
//     repeat(2) @(negedge clk1);
// end 
// endtask

// reg current_mode;
// reg [1:0] current_banks [0:3];
// reg [5:0] current_rows  [0:3];

// task generate_golden_task; 
//     integer i, j;
//     integer out_idx;

//     reg duplicate;


// begin
//     golden_out_cnt = 0;
//     //current_mode = 1'b1; 
//     current_mode = pat_idx % 2; 
//     //current_mode = $urandom_range(0, 1);     
//     for (i = 0; i < 4; i = i + 1) begin
//         duplicate = 1;
//         while (duplicate) begin
//             current_banks[i] = $urandom_range(0, 3);
//             current_rows[i]  = $urandom_range(0, 63);
//             duplicate = 0;
//             for (j = 0; j < i; j = j + 1) begin
//                 if (current_banks[i] == current_banks[j] && current_rows[i] == current_rows[j]) begin
//                     duplicate = 1;
//                 end
//             end
//         end
//     end



//     if (current_mode == 1'b0) begin
//         for (i = 0; i < 4; i = i + 1) begin
//             golden_out_arr[i] = eval_tree({current_banks[i], current_rows[i], 8'd0});
//         end
//         golden_out_cnt = 4;
//     end else begin
//         g_sum = 0;
//         g_N = 0;
        
//         for (i = 0; i < 4; i = i + 1) begin
//             for (j = 0; j < 256; j = j + 1) begin
//                 dram_data = golden_dram[{current_banks[i], current_rows[i], j[7:0]}];
//                 if (dram_data[63] == 1'b0) begin 
//                     g_val = dram_data[62:32];
//                     g_sum = g_sum + g_val;
//                     g_N = g_N + 1;
//                 end
//             end
//         end
        
//         // Mean 
//         g_mean = (g_N > 0) ? (g_sum / g_N) : 0;   // Truncation ?
        
//         // Variance
//         g_var_sum = 0;
//         for (i = 0; i < 4; i = i + 1) begin
//             for (j = 0; j < 256; j = j + 1) begin
//                 dram_data = golden_dram[{current_banks[i], current_rows[i], j[7:0]}];
//                 if (dram_data[63] == 1'b0) begin
//                     g_val = dram_data[62:32];
//                     g_diff = (g_val > g_mean) ? (g_val - g_mean) : (g_mean - g_val);
//                     g_var_sum = g_var_sum + (g_diff * g_diff);
//                 end
//             end
//         end
//         g_var = (g_N > 0) ? (g_var_sum / g_N) : 0;  // Truncation ?
        
//         //  (X - μ)² <= σ²
//         out_idx = 0;
//         for (i = 0; i < 4; i = i + 1) begin
//             for (j = 0; j < 256; j = j + 1) begin
//                 dram_data = golden_dram[{current_banks[i], current_rows[i], j[7:0]}];
 
//                 if (i == 3 && j == 255) begin
//                     golden_out_arr[out_idx] = dram_data;
//                     out_idx = out_idx + 1;
//                 end
//                 else if (dram_data[63] == 1'b0) begin
//                     g_val = dram_data[62:32];
//                     g_diff = (g_val > g_mean) ? (g_val - g_mean) : (g_mean - g_val);
//                     if ((g_diff * g_diff) <= g_var) begin
//                         golden_out_arr[out_idx] = dram_data; 
//                         out_idx = out_idx + 1;
//                     end
//                 end
//             end
//         end
//         golden_out_cnt = out_idx;
//     end
// end 
// endtask

// task drive_input_task; begin
//     integer i;
    
//     in_mode_valid = 1'b1;
//     in_mode = current_mode;
//     @(negedge clk1);
    
//     in_mode_valid = 1'b0;
//     in_mode = 1'bx;
    
//     for (i = 0; i < 4; i = i + 1) begin
//         in_valid = 1'b1;
//         in_bank = current_banks[i];
//         in_src_row = current_rows[i];
//         @(negedge clk1);
//     end
    
//     in_valid = 1'b0;
//     in_bank = 2'bx;
//     in_src_row = 6'bx;
//     latency_cnt = 0;
// end 
// endtask

// task wait_and_check_task; 

// reg [63:0] cur_g_val;
// reg [63:0] cur_g_diff;
// reg [127:0] cur_g_diff_sq;
// begin
//     out_rcv_cnt = 0;
    
    
//     while (out_rcv_cnt < golden_out_cnt) begin
//         if (out_valid) begin
//             if (out_data !== golden_out_arr[out_rcv_cnt]) begin
//                 //FAIL_IMG;
//                 $display("========================================");
//                 $display(" PATTERN %0d FAILED (Mode: %s)", pat_idx, current_mode ? "GUASS" : "CALC");
//                 $display(" EXPECTED DATA[%0d] : %h", out_rcv_cnt, golden_out_arr[out_rcv_cnt]);
//                 $display(" RECEIVED DATA[%0d] : %h", out_rcv_cnt, out_data);
//                 if (current_mode == 1'b1) begin
//                     // --- GAUSS Mode Debug Info ---
//                     cur_g_val = out_data[62:32];
//                     cur_g_diff = (cur_g_val > g_mean) ? (cur_g_val - g_mean) : (g_mean - cur_g_val);
//                     cur_g_diff_sq = cur_g_diff * cur_g_diff;
                    
//                     $display("  [GAUSS Stats]");
//                     $display("  Count (N)    : %0d", g_N);
//                     $display("  Mean (mu)    : %0d", g_mean);
//                     $display("  Var  (sig^2) : %0d", g_var);
//                     $display("  Current Val  : %0d (from bits [62:32])", cur_g_val);
//                     $display("  (Val-mu)^2   : %0d", cur_g_diff_sq);
//                     $display("  Threshold    : (Val-mu)^2 <= sig^2 is %s", (cur_g_diff_sq <= g_var) ? "TRUE" : "FALSE");
//                     if (out_rcv_cnt == golden_out_cnt - 1) 
//                         $display("  NOTE: This was the LAST POSITION, must be output regardless of sigma! ");
//                 end else begin
//                     // --- CALC Mode Debug Info ---
//                     $display("  [CALC Tree Info]");
//                     $display("  Failed Tree Index : %0d (of 4)", out_rcv_cnt);
//                     $display("  Root Location     : Bank %0d, Row %0d, Col 0", current_banks[out_rcv_cnt], current_rows[out_rcv_cnt]);
//                     $display("  Root Absolute Addr: %h", {current_banks[out_rcv_cnt], current_rows[out_rcv_cnt], 8'd0});
//                 end
//                 $display("========================================");
//                 YOU_FAIL_MAIN_task("MAIN FAIL: out_data mismatch!");
//             end
//             out_rcv_cnt = out_rcv_cnt + 1;
//         end
        
//         latency_cnt = latency_cnt + 1;
//         if (latency_cnt > 900000) begin
//             YOU_FAIL_MAIN_task("MAIN FAIL: Execution latency exceeded 900,000 cycles!");
//         end
        
//         @(negedge clk1);
//     end
    
//     if (out_valid) begin
//          YOU_FAIL_MAIN_task("MAIN FAIL: out_valid remains high but all expected data received!");
//     end
    
//     total_latency = total_latency + latency_cnt;
// end 
// endtask

// task check_cdc_ar_queue_empty_task; begin
//     if (cdc_q_cnt != 0) begin
//         $display("[Pattern Debug] CDC AR queue not empty after pattern. pending=%0d, head=%0d, tail=%0d",
//                  cdc_q_cnt, cdc_q_head, cdc_q_tail);
//         YOU_FAIL_AXI_task("CDC SEQUENCE FAIL: clk2 AR request was not forwarded to clk3.");
//     end
// end endtask

// function automatic signed [63:0] eval_tree;
//     input [15:0] ptr;

//     reg [63:0] node_data;
//     reg [1:0]  opcode;
//     reg [15:0] left_ptr, right_ptr;
//     reg signed [63:0] left_val, right_val;

// begin
//     node_data = golden_dram[ptr];

//     if (node_data[63] == 1'b0) begin
//         eval_tree = $signed({{33{node_data[62]}}, node_data[62:32]});

//     end else begin

//         opcode = node_data[33:32];
//         left_ptr = node_data[31:16];
//         right_ptr = node_data[15:0];

//         left_val = eval_tree(left_ptr);
//         right_val = eval_tree(right_ptr);

//         case (opcode)
//             2'b00: eval_tree = left_val + right_val;
//             2'b01: eval_tree = left_val - right_val;
//             2'b10: eval_tree = left_val * right_val;
//             2'b11: eval_tree = left_val >>> right_val[5:0];
//             default: eval_tree = 64'd0;
//         endcase
//     end
// end
// endfunction

// task YOU_PASS_task; begin
//     //PASS_IMG;
//     $display("*************************************************************************");
//     $display("*                         Congratulations!                              *");
//     $display("*                Your execution cycles = %5d cycles                   *", total_latency);
//     $display("*                Your clock period = %.1f ns                            *", CYCLE_clk1);
//     $display("*                Total Latency = %.1f ns                                 *", total_latency*CYCLE_clk1);
//     $display("*************************************************************************");
//     $finish;
// end 
// endtask



// task YOU_FAIL_task; begin
//     $display("*                              FAIL!                                    *");
//     $display("*                    Error message from PATTERN.v                       *");
// end endtask

// task YOU_FAIL_AXI_task(input string msg); begin
//     $display("*************************************************************************");
//     $display("*                         SPEC AXI FAIL                                  *");
//     $display("*            %s                                        ", msg);
//     $display("*************************************************************************");
//     $finish;
// end 
// endtask

// task YOU_FAIL_MAIN_task(input string msg); begin
//     $display("*************************************************************************");
//     $display("*                         SPEC MAIN FAIL                                 *");
//     $display("*            %s                                        ", msg);
//     $display("*************************************************************************");
//     $finish;
// end 
// endtask

// task FAIL_IMG; begin
//     $display("FAIL");
// end
// endtask


// task PASS_IMG;begin
//     $display("PASS");
// end
// endtask

// endmodule