`include "../00_TESTBED/DRAM_MAP_define.v"
`include "../00_TESTBED/pseudo_DRAM_inst1.v"
`include "../00_TESTBED/pseudo_DRAM_inst2.v"
`include "../00_TESTBED/pseudo_DRAM_data.v"

`ifdef RTL
	`define CYCLE_TIME 3.8
`elsif GATE
	`define CYCLE_TIME 3.8
`elsif CHIP
    `define CYCLE_TIME 3.8
`elsif POST
    `define CYCLE_TIME 3.8
`endif

`define DESIGN_INSTANCE u_DCCPU

`ifdef FUNC
`define PAT_NUM 1
`define flag_debug 0 // 1: Simulate, 0: .dat 
`define MAX_WAIT_READY_CYCLE 2000
`endif
`ifdef PERF
`define PAT_NUM 2
`define flag_debug 1 // 1: Simulate, 0: .dat 
`define MAX_WAIT_READY_CYCLE 100000
`endif

module PATTERN(
// Output
     clk,
     rst_n,
// Input
     stall_1,
     stall_2,
//===== AXI-4 Instruction1 DRAM =====
     arid_s_inf_inst_1,
     araddr_s_inf_inst_1,
     arlen_s_inf_inst_1,
     arsize_s_inf_inst_1,
     arburst_s_inf_inst_1,
     arvalid_s_inf_inst_1,
     arready_s_inf_inst_1,
     rid_s_inf_inst_1,
     rdata_s_inf_inst_1,
     rresp_s_inf_inst_1,
     rlast_s_inf_inst_1,
     rvalid_s_inf_inst_1,
     rready_s_inf_inst_1,
     awid_s_inf_inst_1,
     awaddr_s_inf_inst_1,
     awsize_s_inf_inst_1,
     awburst_s_inf_inst_1,
     awlen_s_inf_inst_1,
     awvalid_s_inf_inst_1,
     awready_s_inf_inst_1,
     wdata_s_inf_inst_1,
     wlast_s_inf_inst_1,
     wvalid_s_inf_inst_1,
     wready_s_inf_inst_1,
     bid_s_inf_inst_1,
     bresp_s_inf_inst_1,
     bvalid_s_inf_inst_1,
     bready_s_inf_inst_1,
//===== AXI-4 Instruction2 DRAM =====
     arid_s_inf_inst_2,
     araddr_s_inf_inst_2,
     arlen_s_inf_inst_2,
     arsize_s_inf_inst_2,
     arburst_s_inf_inst_2,
     arvalid_s_inf_inst_2,
     arready_s_inf_inst_2,
     rid_s_inf_inst_2,
     rdata_s_inf_inst_2,
     rresp_s_inf_inst_2,
     rlast_s_inf_inst_2,
     rvalid_s_inf_inst_2,
     rready_s_inf_inst_2,
     awid_s_inf_inst_2,
     awaddr_s_inf_inst_2,
     awsize_s_inf_inst_2,
     awburst_s_inf_inst_2,
     awlen_s_inf_inst_2,
     awvalid_s_inf_inst_2,
     awready_s_inf_inst_2,
     wdata_s_inf_inst_2,
     wlast_s_inf_inst_2,
     wvalid_s_inf_inst_2,
     wready_s_inf_inst_2,
     bid_s_inf_inst_2,
     bresp_s_inf_inst_2,
     bvalid_s_inf_inst_2,
     bready_s_inf_inst_2,
//===== AXI-4 Data DRAM =====
     arid_s_inf_data,
     araddr_s_inf_data,
     arlen_s_inf_data,
     arsize_s_inf_data,
     arburst_s_inf_data,
     arvalid_s_inf_data,
     arready_s_inf_data,
     rid_s_inf_data,
     rdata_s_inf_data,
     rresp_s_inf_data,
     rlast_s_inf_data,
     rvalid_s_inf_data,
     rready_s_inf_data,
     awid_s_inf_data,
     awaddr_s_inf_data,
     awsize_s_inf_data,
     awburst_s_inf_data,
     awlen_s_inf_data,
     awvalid_s_inf_data,
     awready_s_inf_data,
     wdata_s_inf_data,
     wlast_s_inf_data,
     wvalid_s_inf_data,
     wready_s_inf_data,
     bid_s_inf_data,
     bresp_s_inf_data,
     bvalid_s_inf_data,
     bready_s_inf_data
);

output reg clk;
output reg rst_n;

input wire stall_1;
input wire stall_2;

parameter ID_WIDTH=4, ADDR_WIDTH=32, DATA_WIDTH=16, BURST_LEN=7;

// --- Instruction1 DRAM IO ---
input wire [ID_WIDTH-1:0]    arid_s_inf_inst_1;
input wire [ADDR_WIDTH-1:0]  araddr_s_inf_inst_1;
input wire [BURST_LEN-1:0]   arlen_s_inf_inst_1;
input wire [2:0]             arsize_s_inf_inst_1;
input wire [1:0]             arburst_s_inf_inst_1;
input wire                   arvalid_s_inf_inst_1;
output wire                  arready_s_inf_inst_1;

output wire [ID_WIDTH-1:0]   rid_s_inf_inst_1;
output wire [DATA_WIDTH-1:0] rdata_s_inf_inst_1;
output wire [1:0]            rresp_s_inf_inst_1;
output wire                  rlast_s_inf_inst_1;
output wire                  rvalid_s_inf_inst_1;
input wire                   rready_s_inf_inst_1;

input wire [ID_WIDTH-1:0]    awid_s_inf_inst_1;
input wire [ADDR_WIDTH-1:0]  awaddr_s_inf_inst_1;
input wire [2:0]             awsize_s_inf_inst_1;
input wire [1:0]             awburst_s_inf_inst_1;
input wire [BURST_LEN-1:0]   awlen_s_inf_inst_1;
input wire                   awvalid_s_inf_inst_1;
output wire                  awready_s_inf_inst_1;

input wire [DATA_WIDTH-1:0]  wdata_s_inf_inst_1;
input wire                   wlast_s_inf_inst_1;
input wire                   wvalid_s_inf_inst_1;
output wire                  wready_s_inf_inst_1;

output wire [ID_WIDTH-1:0]   bid_s_inf_inst_1;
output wire [1:0]            bresp_s_inf_inst_1;
output wire                  bvalid_s_inf_inst_1;
input wire                   bready_s_inf_inst_1;

// --- Instruction2 DRAM IO ---
input wire [ID_WIDTH-1:0]    arid_s_inf_inst_2;
input wire [ADDR_WIDTH-1:0]  araddr_s_inf_inst_2;
input wire [BURST_LEN-1:0]   arlen_s_inf_inst_2;
input wire [2:0]             arsize_s_inf_inst_2;
input wire [1:0]             arburst_s_inf_inst_2;
input wire                   arvalid_s_inf_inst_2;
output wire                  arready_s_inf_inst_2;

output wire [ID_WIDTH-1:0]   rid_s_inf_inst_2;
output wire [DATA_WIDTH-1:0] rdata_s_inf_inst_2;
output wire [1:0]            rresp_s_inf_inst_2;
output wire                  rlast_s_inf_inst_2;
output wire                  rvalid_s_inf_inst_2;
input wire                   rready_s_inf_inst_2;

input wire [ID_WIDTH-1:0]    awid_s_inf_inst_2;
input wire [ADDR_WIDTH-1:0]  awaddr_s_inf_inst_2;
input wire [2:0]             awsize_s_inf_inst_2;
input wire [1:0]             awburst_s_inf_inst_2;
input wire [BURST_LEN-1:0]   awlen_s_inf_inst_2;
input wire                   awvalid_s_inf_inst_2;
output wire                  awready_s_inf_inst_2;

input wire [DATA_WIDTH-1:0]  wdata_s_inf_inst_2;
input wire                   wlast_s_inf_inst_2;
input wire                   wvalid_s_inf_inst_2;
output wire                  wready_s_inf_inst_2;

output wire [ID_WIDTH-1:0]   bid_s_inf_inst_2;
output wire [1:0]            bresp_s_inf_inst_2;
output wire                  bvalid_s_inf_inst_2;
input wire                   bready_s_inf_inst_2;

// --- Data DRAM IO ---
input wire [ID_WIDTH-1:0]    arid_s_inf_data;
input wire [ADDR_WIDTH-1:0]  araddr_s_inf_data;
input wire [BURST_LEN-1:0]   arlen_s_inf_data;
input wire [2:0]             arsize_s_inf_data;
input wire [1:0]             arburst_s_inf_data;
input wire                   arvalid_s_inf_data;
output wire                  arready_s_inf_data;

output wire [ID_WIDTH-1:0]   rid_s_inf_data;
output wire [DATA_WIDTH-1:0] rdata_s_inf_data;
output wire [1:0]            rresp_s_inf_data;
output wire                  rlast_s_inf_data;
output wire                  rvalid_s_inf_data;
input wire                   rready_s_inf_data;

input wire [ID_WIDTH-1:0]    awid_s_inf_data;
input wire [ADDR_WIDTH-1:0]  awaddr_s_inf_data;
input wire [2:0]             awsize_s_inf_data;
input wire [1:0]             awburst_s_inf_data;
input wire [BURST_LEN-1:0]   awlen_s_inf_data;
input wire                   awvalid_s_inf_data;
output wire                  awready_s_inf_data;

input wire [DATA_WIDTH-1:0]  wdata_s_inf_data;
input wire                   wlast_s_inf_data;
input wire                   wvalid_s_inf_data;
output wire                  wready_s_inf_data;

output wire [ID_WIDTH-1:0]   bid_s_inf_data;
output wire [1:0]            bresp_s_inf_data;
output wire                  bvalid_s_inf_data;
input wire                   bready_s_inf_data;

// ########################################### Pseudo DRAM Instances
pseudo_DRAM_data #(4, 32, 16, 7) DRAM_data (
    .clk(clk),
    .rst_n(rst_n),
    .awid_s_inf(awid_s_inf_data),
    .awaddr_s_inf(awaddr_s_inf_data),
    .awsize_s_inf(awsize_s_inf_data),
    .awburst_s_inf(awburst_s_inf_data),
    .awlen_s_inf(awlen_s_inf_data),
    .awvalid_s_inf(awvalid_s_inf_data),
    .awready_s_inf(awready_s_inf_data),
    .wdata_s_inf(wdata_s_inf_data),
    .wlast_s_inf(wlast_s_inf_data),
    .wvalid_s_inf(wvalid_s_inf_data),
    .wready_s_inf(wready_s_inf_data),
    .bid_s_inf(bid_s_inf_data),
    .bresp_s_inf(bresp_s_inf_data),
    .bvalid_s_inf(bvalid_s_inf_data),
    .bready_s_inf(bready_s_inf_data),
    .arid_s_inf(arid_s_inf_data),
    .araddr_s_inf(araddr_s_inf_data),
    .arlen_s_inf(arlen_s_inf_data),
    .arsize_s_inf(arsize_s_inf_data),
    .arburst_s_inf(arburst_s_inf_data),
    .arvalid_s_inf(arvalid_s_inf_data),
    .arready_s_inf(arready_s_inf_data),
    .rid_s_inf(rid_s_inf_data),
    .rdata_s_inf(rdata_s_inf_data),
    .rresp_s_inf(rresp_s_inf_data),
    .rlast_s_inf(rlast_s_inf_data),
    .rvalid_s_inf(rvalid_s_inf_data),
    .rready_s_inf(rready_s_inf_data)
);

pseudo_DRAM_inst1 #(4, 32, 16, 7) DRAM_inst1 (
    .clk(clk),
    .rst_n(rst_n),
    .awid_s_inf(awid_s_inf_inst_1),
    .awaddr_s_inf(awaddr_s_inf_inst_1),
    .awsize_s_inf(awsize_s_inf_inst_1),
    .awburst_s_inf(awburst_s_inf_inst_1),
    .awlen_s_inf(awlen_s_inf_inst_1),
    .awvalid_s_inf(awvalid_s_inf_inst_1),
    .awready_s_inf(awready_s_inf_inst_1),
    .wdata_s_inf(wdata_s_inf_inst_1),
    .wlast_s_inf(wlast_s_inf_inst_1),
    .wvalid_s_inf(wvalid_s_inf_inst_1),
    .wready_s_inf(wready_s_inf_inst_1),
    .bid_s_inf(bid_s_inf_inst_1),
    .bresp_s_inf(bresp_s_inf_inst_1),
    .bvalid_s_inf(bvalid_s_inf_inst_1),
    .bready_s_inf(bready_s_inf_inst_1),
    .arid_s_inf(arid_s_inf_inst_1),
    .araddr_s_inf(araddr_s_inf_inst_1),
    .arlen_s_inf(arlen_s_inf_inst_1),
    .arsize_s_inf(arsize_s_inf_inst_1),
    .arburst_s_inf(arburst_s_inf_inst_1),
    .arvalid_s_inf(arvalid_s_inf_inst_1),
    .arready_s_inf(arready_s_inf_inst_1),
    .rid_s_inf(rid_s_inf_inst_1),
    .rdata_s_inf(rdata_s_inf_inst_1),
    .rresp_s_inf(rresp_s_inf_inst_1),
    .rlast_s_inf(rlast_s_inf_inst_1),
    .rvalid_s_inf(rvalid_s_inf_inst_1),
    .rready_s_inf(rready_s_inf_inst_1)
);

pseudo_DRAM_inst2 #(4, 32, 16, 7) DRAM_inst2 (
    .clk(clk),
    .rst_n(rst_n),
    .awid_s_inf(awid_s_inf_inst_2),
    .awaddr_s_inf(awaddr_s_inf_inst_2),
    .awsize_s_inf(awsize_s_inf_inst_2),
    .awburst_s_inf(awburst_s_inf_inst_2),
    .awlen_s_inf(awlen_s_inf_inst_2),
    .awvalid_s_inf(awvalid_s_inf_inst_2),
    .awready_s_inf(awready_s_inf_inst_2),
    .wdata_s_inf(wdata_s_inf_inst_2),
    .wlast_s_inf(wlast_s_inf_inst_2),
    .wvalid_s_inf(wvalid_s_inf_inst_2),
    .wready_s_inf(wready_s_inf_inst_2),
    .bid_s_inf(bid_s_inf_inst_2),
    .bresp_s_inf(bresp_s_inf_inst_2),
    .bvalid_s_inf(bvalid_s_inf_inst_2),
    .bready_s_inf(bready_s_inf_inst_2),
    .arid_s_inf(arid_s_inf_inst_2),
    .araddr_s_inf(araddr_s_inf_inst_2),
    .arlen_s_inf(arlen_s_inf_inst_2),
    .arsize_s_inf(arsize_s_inf_inst_2),
    .arburst_s_inf(arburst_s_inf_inst_2),
    .arvalid_s_inf(arvalid_s_inf_inst_2),
    .arready_s_inf(arready_s_inf_inst_2),
    .rid_s_inf(rid_s_inf_inst_2),
    .rdata_s_inf(rdata_s_inf_inst_2),
    .rresp_s_inf(rresp_s_inf_inst_2),
    .rlast_s_inf(rlast_s_inf_inst_2),
    .rvalid_s_inf(rvalid_s_inf_inst_2),
    .rready_s_inf(rready_s_inf_inst_2)
);
// ==============================
//  Parameters & Variables
// ==============================
parameter CYCLE = `CYCLE_TIME;

integer seed = 123; 
integer pat_idx;
integer total_latency;
integer i, k;

integer ic_1 = 0, ic_2 = 0;
integer lat_1 = 0, lat_2 = 0;
reg core1_done, core2_done;

integer golden_pc_1 = 0;
integer golden_pc_2 = 0;
reg signed [15:0] golden_reg1 [0:7];
reg signed [15:0] golden_reg2 [0:7];
reg signed [15:0] golden_mem  [0:4095];

reg signed [15:0] trace_reg1 [0:20000][0:7];
reg signed [15:0] trace_reg2 [0:20000][0:7];

reg [15:0] last_exec_pc_1, last_exec_pc_2;

reg [15:0] trace_pc_1 [0:20000];
reg [15:0] trace_pc_2 [0:20000];

reg [15:0] snapshot_mem [0:100][0:4095];

integer final_ic;
integer sim_next_check_ic = 50;
integer sim_check_idx = 0;
integer hw_next_check_ic = 50;
integer hw_check_idx = 0;

reg [31:0] trace_inst_name_1 [0:20000];
reg [31:0] trace_inst_name_2 [0:20000];

reg[9*8:1]  reset_color       = "\033[1;0m";
reg[10*8:1] txt_red_prefix    = "\033[1;31m";
reg[10*8:1] txt_green_prefix  = "\033[1;32m";
reg[10*8:1] txt_blue_prefix   = "\033[1;34m";
reg[10*8:1] txt_yellow_prefix = "\033[1;33m";

always #(CYCLE/2.0) clk = ~clk;

function [31:0] rand_range;
    input [31:0] min, max;
    begin
        rand_range = ($random(seed) & 32'h7FFFFFFF) % (max - min + 1) + min;
    end
endfunction

function [15:0] get_inst1; 
    input integer pc; 
    begin
        get_inst1 = {DRAM_inst1.DRAM_r[pc+1], DRAM_inst1.DRAM_r[pc]};
    end
endfunction

function [15:0] get_inst2; 
    input integer pc; 
    begin
        get_inst2 = {DRAM_inst2.DRAM_r[pc+1], DRAM_inst2.DRAM_r[pc]}; 
    end
endfunction

initial begin
    if (`flag_debug == 0) begin
        // ==========================================
        //  Generate Mode: Generate .dat files
        // ==========================================
        GEN_task;
        $display("\n%0s[Info] Entering Generate Mode. Generating .dat files...%0s", txt_yellow_prefix, reset_color);
        pat_idx = 0; 
        
        generate_pattern_task;
        dump_dat_task;
        
        $display("\n%0s[Info] Pattern Generation Completed! Files (inst1.dat, inst2.dat, data.dat) saved.%0s", txt_green_prefix, reset_color);
        $finish;
    end 
    else begin
        // ==========================================
        //  Debug Mode: Simulate (DRAM will load .dat by itself)
        // ==========================================
        clk = 0; 
        total_latency = 0;
        
        // reset_task; 

        for (pat_idx = 0; pat_idx < `PAT_NUM; pat_idx = pat_idx + 1) begin
            reset_task; 
            last_exec_pc_1 = 16'h0000;
            last_exec_pc_2 = 16'h0000;
            core1_done = 0; core2_done = 0;
            ic_1 = 0; ic_2 = 0; lat_1 = 0; lat_2 = 0;
            hw_next_check_ic = 50;
            hw_check_idx = 0;
            
            $display("\n%0s[Info] Pattern %0d Start Simulation!%0s", txt_green_prefix, pat_idx, reset_color);
            
            setup_golden_env;

            check_last_inst_task;
            generate_golden_trace_task;
            $display("%0s[Info] Golden Model Trace Generated! (Final IC: %0d)%0s", txt_yellow_prefix, final_ic, reset_color);
            
            @(negedge clk);

            while (!core1_done || !core2_done) begin
                if (ic_1 == final_ic) core1_done = 1;
                if (ic_2 == final_ic) core2_done = 1;
                
                if (!core1_done) begin
                    if (stall_1 === 1'b0) begin
                        last_exec_pc_1 = golden_pc_1; 
                        check_hw_core1(ic_1); 
                        lat_1 = 0;
                        ic_1 = ic_1 + 1;
                    end 
                    else begin
                        lat_1 = lat_1 + 1;
                        if (lat_1 > `MAX_WAIT_READY_CYCLE) begin 
                            YOU_FAIL_task;
                            $display("\n%0s[Timeout] Core 1 IC:%d%0s", txt_red_prefix, ic_1, reset_color); 
                            $finish; 
                        end
                    end
                end
                
                if (!core2_done) begin
                    if (stall_2 === 1'b0) begin
                        last_exec_pc_2 = golden_pc_2;
                        check_hw_core2(ic_2); 
                        lat_2 = 0;
                        ic_2 = ic_2 + 1;
                    end 
                    else begin
                        lat_2 = lat_2 + 1;
                        if (lat_2 > `MAX_WAIT_READY_CYCLE) begin 
                            YOU_FAIL_task;
                            $display("\n%0s[Timeout] Core 2 IC:%d%0s", txt_red_prefix, ic_2, reset_color); 
                            $finish; 
                        end
                    end
                end

                if (ic_1 >= hw_next_check_ic && ic_2 >= hw_next_check_ic) begin
                    check_mem_snapshot(hw_check_idx);
                    hw_next_check_ic = hw_next_check_ic + 50;
                    hw_check_idx = hw_check_idx + 1;
                end

                if (ic_2 > ic_1 + 1) begin
                    YOU_FAIL_task;
                    $display("\n%0s[Sequence Error] Core 2 (IC:%0d) executed ahead of Core 1 (IC:%0d) by more than 1!%0s", txt_red_prefix, ic_2, ic_1, reset_color);
                    $finish;
                end

                @(negedge clk); 
                total_latency = total_latency + 1;
            end
            
            // check_final_pc_task();
            check_mem_task(); 
            // $display("Final inst1 word = %h, byte[1FFE]=%02h, byte[1FFF]=%02h",
            //             get_inst1(16'h1FFE),
            //             DRAM_inst1.DRAM_r[16'h1FFE],
            //             DRAM_inst1.DRAM_r[16'h1FFF]);

            // $display("Final inst2 word = %h, byte[1FFE]=%02h, byte[1FFF]=%02h",
            //             get_inst2(16'h1FFE),
            //             DRAM_inst2.DRAM_r[16'h1FFE],
            //             DRAM_inst2.DRAM_r[16'h1FFF]);
            $display("\n%0s[Pattern %0d Passed]%0s", txt_blue_prefix, pat_idx, reset_color);
        end
        
        YOU_PASS_task; 
        $finish;
    end
end

// task check_final_pc_task;
// begin
//     if (last_exec_pc_1 !== 16'h1FFE ||
//         last_exec_pc_2 !== 16'h1FFE) begin
//         YOU_FAIL_task;
//         $display("\n%0s[Final PC Error] DUT final PC should be 0x1FFE!%0s",
//                  txt_red_prefix, reset_color);
//         $display("pc_1 = %h, expected 1FFE", `DESIGN_INSTANCE.pc_1);
//         $display("pc_2 = %h, expected 1FFE", `DESIGN_INSTANCE.pc_2);
//         $finish;
//     end
// end
// endtask

task generate_golden_trace_task; 
    integer sim_ic1, sim_ic2, rr;
    reg [2:0] op1, op2;
begin
    sim_ic1 = 0; sim_ic2 = 0;
    golden_pc_1 = 0; golden_pc_2 = 0;
    sim_next_check_ic = 50;
    sim_check_idx = 0;

    while (!(golden_pc_1 == 16'h1FFE && golden_pc_2 == 16'h1FFE && sim_ic1 == sim_ic2)) begin
        
        if (sim_ic1 > 50000 || sim_ic2 > 50000) begin
            YOU_FAIL_task;
            $display("\n%0s[Trace Error] Golden Model fell into an infinite loop!%0s", txt_red_prefix, reset_color);
            $finish;
        end

        if (golden_pc_1 == 16'h1FFE && golden_pc_2 != 16'h1FFE) begin
            sim_core2(sim_ic2); 
            sim_ic2 = sim_ic2 + 1;
        end 
        else if (golden_pc_2 == 16'h1FFE && golden_pc_1 != 16'h1FFE) begin
            sim_core1(sim_ic1); 
            sim_ic1 = sim_ic1 + 1;
        end 
        else begin
            if (sim_ic1 == sim_ic2) begin
                op1 = get_inst1(golden_pc_1) >> 13;
                op2 = get_inst2(golden_pc_2) >> 13;
                
                if (op1 == 3'b100 && op2 == 3'b101) begin
                    sim_core2(sim_ic2); sim_ic2 = sim_ic2 + 1;
                    sim_core1(sim_ic1); sim_ic1 = sim_ic1 + 1;
                end 
                else begin
                    sim_core1(sim_ic1); sim_ic1 = sim_ic1 + 1;
                    sim_core2(sim_ic2); sim_ic2 = sim_ic2 + 1;
                end
            end 
            else if (sim_ic1 < sim_ic2) begin
                sim_core1(sim_ic1); sim_ic1 = sim_ic1 + 1;
            end 
            else begin
                sim_core2(sim_ic2); sim_ic2 = sim_ic2 + 1;
            end
        end

        if (sim_ic1 >= sim_next_check_ic && sim_ic2 >= sim_next_check_ic) begin
            if (sim_check_idx < 100) begin
                for (rr = 0; rr < 4096; rr = rr + 1) snapshot_mem[sim_check_idx][rr] = golden_mem[rr];
            end
            sim_next_check_ic = sim_next_check_ic + 50;
            sim_check_idx = sim_check_idx + 1;
        end
        
        if (golden_pc_1 == 16'h1FFE && golden_pc_2 == 16'h1FFE && sim_ic1 != sim_ic2) begin
             YOU_FAIL_task;
             $display("\n%0s[Trace Error] Both cores reached 1FFE but ICs are unequal! (IC1:%0d, IC2:%0d)%0s", txt_red_prefix, sim_ic1, sim_ic2, reset_color);
             $finish;
        end
    end
    
    sim_core1(sim_ic1); 
    sim_ic1 = sim_ic1 + 1;
    
    sim_core2(sim_ic2); 
    sim_ic2 = sim_ic2 + 1;

    final_ic = sim_ic1; 
end endtask

task sim_core1; input integer cur_ic;
    reg [15:0] inst; reg [2:0] op, rs, rt, rd, func, rl; reg signed [6:0] imm; reg [12:0] j_addr;
    reg signed [15:0] s_val, t_val; integer target, physical_addr; reg signed [31:0] mul_res;
    integer rr;
begin
    trace_pc_1[cur_ic] = golden_pc_1;
    inst = get_inst1(golden_pc_1);
    op = inst[15:13]; rs = inst[12:10]; rt = inst[9:7]; rd = inst[6:4]; func = inst[3:1]; rl = inst[3:1];
    imm = $signed(inst[6:0]); j_addr = inst[12:0]; s_val = golden_reg1[rs]; t_val = golden_reg1[rt]; 
    target = s_val + imm;
    
    physical_addr = target * 2 + 'h1000;
    if ((op == 3'b100 || op == 3'b101) && (physical_addr < 'h1000 || physical_addr >= 'h3000)) begin 
        YOU_FAIL_task;
        $display("\n%0s[OOB Error] Core 1 Access Out of Bounds at IC %d (Physical: 0x%04H)%0s", txt_red_prefix, cur_ic, physical_addr, reset_color); 
        $finish; 
    end

    case (op)
        3'b000: 
            case (func) 
                3'b000: trace_inst_name_1[cur_ic] = " ADD"; 
                3'b001: trace_inst_name_1[cur_ic] = " SUB"; 
                3'b010: trace_inst_name_1[cur_ic] = " AND"; 
                3'b011: trace_inst_name_1[cur_ic] = "  OR"; 
                3'b100: trace_inst_name_1[cur_ic] = "NAND"; 
                3'b101: trace_inst_name_1[cur_ic] = " NOR"; 
                3'b110: trace_inst_name_1[cur_ic] = " XOR"; 
                3'b111: trace_inst_name_1[cur_ic] = " SLT"; 
            endcase
        3'b001: trace_inst_name_1[cur_ic] = " MUL"; 
        3'b010: trace_inst_name_1[cur_ic] = "ADDI"; 
        3'b011: trace_inst_name_1[cur_ic] = "SUBI"; 
        3'b100: trace_inst_name_1[cur_ic] = "  LH"; 
        3'b101: trace_inst_name_1[cur_ic] = "  SH"; 
        3'b110: trace_inst_name_1[cur_ic] = " BEQ"; 
        3'b111: trace_inst_name_1[cur_ic] = "   J";
    endcase

    if (op == 3'b101) golden_mem[target] = t_val;

    case (op)
        3'b000: begin 
            case (func) 
                3'b000: golden_reg1[rd] = s_val + t_val; 
                3'b001: golden_reg1[rd] = s_val - t_val; 
                3'b010: golden_reg1[rd] = s_val & t_val; 
                3'b011: golden_reg1[rd] = s_val | t_val; 
                3'b100: golden_reg1[rd] = ~(s_val & t_val); 
                3'b101: golden_reg1[rd] = ~(s_val | t_val); 
                3'b110: golden_reg1[rd] = s_val ^ t_val; 
                3'b111: golden_reg1[rd] = (s_val < t_val) ? 1 : 0; 
            endcase 
        end
        3'b001: begin 
            mul_res = s_val * t_val; 
            golden_reg1[rd] = mul_res[31:16]; 
            golden_reg1[rl] = mul_res[15:0]; 
            end
        3'b010: golden_reg1[rt] = s_val + imm; 3'b011: golden_reg1[rt] = s_val - imm; 
        3'b100: golden_reg1[rt] = golden_mem[target]; 3'b101: ; 
        3'b110: if (s_val == t_val) golden_pc_1 = golden_pc_1 + (imm * 2);
        3'b111: golden_pc_1 = j_addr - 2;
    endcase
    golden_pc_1 = golden_pc_1 + 2;

    for (rr = 0; rr < 8; rr = rr + 1) trace_reg1[cur_ic][rr] = golden_reg1[rr];
end endtask

task sim_core2; input integer cur_ic;
    reg [15:0] inst; reg [2:0] op, rs, rt, rd, func, rl; reg signed [6:0] imm; reg [12:0] j_addr;
    reg signed [15:0] s_val, t_val; integer target, physical_addr; reg signed [31:0] mul_res;
    integer rr;
begin
    trace_pc_2[cur_ic] = golden_pc_2;
    inst = get_inst2(golden_pc_2);
    op = inst[15:13]; rs = inst[12:10]; rt = inst[9:7]; rd = inst[6:4]; func = inst[3:1]; rl = inst[3:1];
    imm = $signed(inst[6:0]); j_addr = inst[12:0]; s_val = golden_reg2[rs]; t_val = golden_reg2[rt]; 
    target = s_val + imm;
    
    physical_addr = target * 2 + 'h1000;
    if ((op == 3'b100 || op == 3'b101) && (physical_addr < 'h1000 || physical_addr >= 'h3000)) begin 
        YOU_FAIL_task;
        $display("\n%0s[OOB Error] Core 2 Access Out of Bounds at IC %d (Physical: 0x%04H)%0s", txt_red_prefix, cur_ic, physical_addr, reset_color); 
        $finish; 
    end

    case (op)
        3'b000: 
            case (func) 
                3'b000: trace_inst_name_2[cur_ic] = " ADD"; 
                3'b001: trace_inst_name_2[cur_ic] = " SUB"; 
                3'b010: trace_inst_name_2[cur_ic] = " AND"; 
                3'b011: trace_inst_name_2[cur_ic] = "  OR"; 
                3'b100: trace_inst_name_2[cur_ic] = "NAND"; 
                3'b101: trace_inst_name_2[cur_ic] = " NOR"; 
                3'b110: trace_inst_name_2[cur_ic] = " XOR"; 
                3'b111: trace_inst_name_2[cur_ic] = " SLT"; 
            endcase
        3'b001: trace_inst_name_2[cur_ic] = " MUL"; 
        3'b010: trace_inst_name_2[cur_ic] = "ADDI"; 
        3'b011: trace_inst_name_2[cur_ic] = "SUBI"; 
        3'b100: trace_inst_name_2[cur_ic] = "  LH"; 
        3'b101: trace_inst_name_2[cur_ic] = "  SH"; 
        3'b110: trace_inst_name_2[cur_ic] = " BEQ"; 
        3'b111: trace_inst_name_2[cur_ic] = "   J";
    endcase

    if (op == 3'b101) golden_mem[target] = t_val;

    case (op)
        3'b000: 
        begin 
            case (func) 
                3'b000: golden_reg2[rd] = s_val + t_val; 
                3'b001: golden_reg2[rd] = s_val - t_val; 
                3'b010: golden_reg2[rd] = s_val & t_val; 
                3'b011: golden_reg2[rd] = s_val | t_val; 
                3'b100: golden_reg2[rd] = ~(s_val & t_val); 
                3'b101: golden_reg2[rd] = ~(s_val | t_val); 
                3'b110: golden_reg2[rd] = s_val ^ t_val; 
                3'b111: golden_reg2[rd] = (s_val < t_val) ? 1 : 0; 
            endcase 
        end
        3'b001: 
            begin 
                mul_res = s_val * t_val; 
                golden_reg2[rd] = mul_res[31:16]; 
                golden_reg2[rl] = mul_res[15:0]; 
            end
        3'b010: golden_reg2[rt] = s_val + imm; 3'b011: golden_reg2[rt] = s_val - imm; 
        3'b100: golden_reg2[rt] = golden_mem[target]; 3'b101: ; 
        3'b110: if (s_val == t_val) golden_pc_2 = golden_pc_2 + (imm * 2);
        3'b111: golden_pc_2 = j_addr - 2;
    endcase
    golden_pc_2 = golden_pc_2 + 2;

    for (rr = 0; rr < 8; rr = rr + 1) trace_reg2[cur_ic][rr] = golden_reg2[rr];
end endtask


task check_hw_core1; input integer check_ic;
begin
    if(`DESIGN_INSTANCE.core_1_r0 !== trace_reg1[check_ic][0] || `DESIGN_INSTANCE.core_1_r1 !== trace_reg1[check_ic][1] || `DESIGN_INSTANCE.core_1_r2 !== trace_reg1[check_ic][2] || `DESIGN_INSTANCE.core_1_r3 !== trace_reg1[check_ic][3] || `DESIGN_INSTANCE.core_1_r4 !== trace_reg1[check_ic][4] || `DESIGN_INSTANCE.core_1_r5 !== trace_reg1[check_ic][5] || `DESIGN_INSTANCE.core_1_r6 !== trace_reg1[check_ic][6] || `DESIGN_INSTANCE.core_1_r7 !== trace_reg1[check_ic][7]) begin
        YOU_FAIL_task;
        // $display ("\n%0sFAIL! Core 1 Register Mismatch at IC: %4d%0s", txt_red_prefix, check_ic, reset_color);
        $display ("\n%0sFAIL! Core 1 Register Mismatch at IC: %4d (PC: 0x%04H)%0s", txt_red_prefix, check_ic, trace_pc_1[check_ic], reset_color);
        $display ("%0s---> Error occurred in [Core 1] executing instruction: [%0s] <---%0s", txt_red_prefix, trace_inst_name_1[check_ic], reset_color);
        $display ("%0s---> \ [Core 2] instruction: [%0s] <---%0s", txt_red_prefix, trace_inst_name_2[check_ic], reset_color);
        
        $display (" r0: Your %6d | Golden %6d ", `DESIGN_INSTANCE.core_1_r0, trace_reg1[check_ic][0]);
        $display (" r1: Your %6d | Golden %6d ", `DESIGN_INSTANCE.core_1_r1, trace_reg1[check_ic][1]);
        $display (" r2: Your %6d | Golden %6d ", `DESIGN_INSTANCE.core_1_r2, trace_reg1[check_ic][2]);
        $display (" r3: Your %6d | Golden %6d ", `DESIGN_INSTANCE.core_1_r3, trace_reg1[check_ic][3]);
        $display (" r4: Your %6d | Golden %6d ", `DESIGN_INSTANCE.core_1_r4, trace_reg1[check_ic][4]);
        $display (" r5: Your %6d | Golden %6d ", `DESIGN_INSTANCE.core_1_r5, trace_reg1[check_ic][5]);
        $display (" r6: Your %6d | Golden %6d ", `DESIGN_INSTANCE.core_1_r6, trace_reg1[check_ic][6]);
        $display (" r7: Your %6d | Golden %6d ", `DESIGN_INSTANCE.core_1_r7, trace_reg1[check_ic][7]);
        $finish;
    end
    // $display("%0s[Core 1] PASS PATTERN NO. %4d | Func: %4s | Latency: %4d%0s", txt_blue_prefix, check_ic, trace_inst_name_1[check_ic], lat_1, reset_color);
    $display("%0s[Core 1] PASS PATTERN NO. %4d | PC: 0x%04H | Func: %4s | Latency: %4d%0s", txt_blue_prefix, check_ic, trace_pc_1[check_ic], trace_inst_name_1[check_ic], lat_1, reset_color);

end endtask

task check_hw_core2; input integer check_ic; begin
    if(`DESIGN_INSTANCE.core_2_r0 !== trace_reg2[check_ic][0] || `DESIGN_INSTANCE.core_2_r1 !== trace_reg2[check_ic][1] || `DESIGN_INSTANCE.core_2_r2 !== trace_reg2[check_ic][2] || `DESIGN_INSTANCE.core_2_r3 !== trace_reg2[check_ic][3] || `DESIGN_INSTANCE.core_2_r4 !== trace_reg2[check_ic][4] || `DESIGN_INSTANCE.core_2_r5 !== trace_reg2[check_ic][5] || `DESIGN_INSTANCE.core_2_r6 !== trace_reg2[check_ic][6] || `DESIGN_INSTANCE.core_2_r7 !== trace_reg2[check_ic][7]) begin
        YOU_FAIL_task;
        // $display ("\n%0sFAIL! Core 2 Register Mismatch at IC: %4d%0s", txt_red_prefix, check_ic, reset_color);
        $display ("\n%0sFAIL! Core 2 Register Mismatch at IC: %4d (PC: 0x%04H)%0s", txt_red_prefix, check_ic, trace_pc_2[check_ic], reset_color);
        $display ("%0s---> Error occurred in [Core 2] executing instruction: [%0s] <---%0s", txt_red_prefix, trace_inst_name_2[check_ic], reset_color);
        $display ("%0s---> \ [Core 1] instruction: [%0s] <---%0s", txt_red_prefix, trace_inst_name_1[check_ic], reset_color);

        $display (" r0: Your %6d | Golden %6d ", `DESIGN_INSTANCE.core_2_r0, trace_reg2[check_ic][0]);
        $display (" r1: Your %6d | Golden %6d ", `DESIGN_INSTANCE.core_2_r1, trace_reg2[check_ic][1]);
        $display (" r2: Your %6d | Golden %6d ", `DESIGN_INSTANCE.core_2_r2, trace_reg2[check_ic][2]);
        $display (" r3: Your %6d | Golden %6d ", `DESIGN_INSTANCE.core_2_r3, trace_reg2[check_ic][3]);
        $display (" r4: Your %6d | Golden %6d ", `DESIGN_INSTANCE.core_2_r4, trace_reg2[check_ic][4]);
        $display (" r5: Your %6d | Golden %6d ", `DESIGN_INSTANCE.core_2_r5, trace_reg2[check_ic][5]);
        $display (" r6: Your %6d | Golden %6d ", `DESIGN_INSTANCE.core_2_r6, trace_reg2[check_ic][6]);
        $display (" r7: Your %6d | Golden %6d ", `DESIGN_INSTANCE.core_2_r7, trace_reg2[check_ic][7]);
        $finish;
    end
    // $display("%0s[Core 2] PASS PATTERN NO. %4d | Func: %4s | Latency: %4d%0s", txt_green_prefix, check_ic, trace_inst_name_2[check_ic], lat_2, reset_color);
    $display("%0s[Core 2] PASS PATTERN NO. %4d | PC: 0x%04H | Func: %4s | Latency: %4d%0s", txt_green_prefix, check_ic, trace_pc_2[check_ic], trace_inst_name_2[check_ic], lat_2, reset_color);
end endtask

task check_mem_snapshot; input integer snap_idx;
    integer m;
    begin
        if (snap_idx < 100) begin
            for (m = 0; m < 4096; m = m + 1) begin
                if (snapshot_mem[snap_idx][m] !== {DRAM_data.DRAM_r[m*2+'h1000+1], DRAM_data.DRAM_r[m*2+'h1000]}) begin
                    YOU_FAIL_task;
                    $display("\n%0s[Mem Error] Mismatch at Physical 0x%04H at IC 50-boundary (Snapshot %0d)%0s", txt_red_prefix, m*2+'h1000, snap_idx, reset_color);
                    $finish;
                end
            end
            $display("%0s[Info] Global Memory Check Passed at IC 50-boundary (Snapshot %0d)%0s", txt_yellow_prefix, snap_idx, reset_color);
        end
    end
endtask


task setup_golden_env; begin
    for(i=0; i<8; i=i+1) begin 
        golden_reg1[i]=0; 
        golden_reg2[i]=0; 
    end

    k = 0; 

    for(i='h1000; i<'h3000; i=i+2) begin 
        golden_mem[k] = {DRAM_data.DRAM_r[i+1], DRAM_data.DRAM_r[i]}; 
        k = k + 1; 
    end
end endtask

task check_mem_task; begin
    k = 0; for(i='h1000; i<'h3000; i=i+2) begin
        if(golden_mem[k] !== {DRAM_data.DRAM_r[i+1], DRAM_data.DRAM_r[i]}) begin 
            YOU_FAIL_task;
            $display ("\n%0sFAIL! Final Memory Mismatch at Physical 0x%04H%0s", txt_red_prefix, i, reset_color); 
            $finish; 
        end
        k = k + 1;
    end
end endtask

// task check_last_inst_task;
//     reg [15:0] last_inst1, last_inst2;
// begin
//     last_inst1 = get_inst1(16'h1FFE);
//     last_inst2 = get_inst2(16'h1FFE);

//     if (last_inst1 !== {3'b111, 13'h1FFE} ||
//         last_inst2 !== {3'b111, 13'h1FFE}) begin
//         YOU_FAIL_task;
//         $display("\n%0s[Last Inst Error] Last instruction must be J 0x1FFE!%0s",
//                  txt_red_prefix, reset_color);
//         $display("Core1 inst[1FFE] = %h, expected = %h",
//                  last_inst1, {3'b111, 13'h1FFE});
//         $display("Core2 inst[1FFE] = %h, expected = %h",
//                  last_inst2, {3'b111, 13'h1FFE});
//         $finish;
//     end
// end
// endtask

task check_last_inst_task;
    reg [15:0] last_inst1, last_inst2;
    reg [15:0] expected_last_inst;
begin
    expected_last_inst = {3'b010, 3'd0, 3'd0, 7'd0}; // ADDI r0, r0, 0

    last_inst1 = get_inst1(16'h1FFE);
    last_inst2 = get_inst2(16'h1FFE);

    if (last_inst1 !== expected_last_inst ||
        last_inst2 !== expected_last_inst) begin
        YOU_FAIL_task;
        $display("\n%0s[Last Inst Error] Last instruction must be ADDI r0, r0, 0!%0s",
                 txt_red_prefix, reset_color);
        $display("Core1 inst[1FFE] = %h, expected = %h",
                 last_inst1, expected_last_inst);
        $display("Core2 inst[1FFE] = %h, expected = %h",
                 last_inst2, expected_last_inst);
        $finish;
    end
end
endtask

task reset_task; begin
    rst_n = 'b1;
    force clk = 0; 
    
    #CYCLE; 
    rst_n = 0; 
    
    #(CYCLE * 3);

    if(stall_1 !== 1'b1 || stall_2 !== 1'b1) begin 
        YOU_FAIL_task;
        $display ("\n%0sFAIL! stall MUST be 1 after RESET%0s", txt_red_prefix, reset_color); 
        $finish; 
    end

    if (`DESIGN_INSTANCE.core_1_r0 !== 16'd0 || `DESIGN_INSTANCE.core_1_r1 !== 16'd0 ||
        `DESIGN_INSTANCE.core_1_r2 !== 16'd0 || `DESIGN_INSTANCE.core_1_r3 !== 16'd0 ||
        `DESIGN_INSTANCE.core_1_r4 !== 16'd0 || `DESIGN_INSTANCE.core_1_r5 !== 16'd0 ||
        `DESIGN_INSTANCE.core_1_r6 !== 16'd0 || `DESIGN_INSTANCE.core_1_r7 !== 16'd0 ||
        `DESIGN_INSTANCE.core_2_r0 !== 16'd0 || `DESIGN_INSTANCE.core_2_r1 !== 16'd0 ||
        `DESIGN_INSTANCE.core_2_r2 !== 16'd0 || `DESIGN_INSTANCE.core_2_r3 !== 16'd0 ||
        `DESIGN_INSTANCE.core_2_r4 !== 16'd0 || `DESIGN_INSTANCE.core_2_r5 !== 16'd0 ||
        `DESIGN_INSTANCE.core_2_r6 !== 16'd0 || `DESIGN_INSTANCE.core_2_r7 !== 16'd0) begin
        YOU_FAIL_task;
        $display("\n[RESET DEBUG] Core 1 Registers:");
        $display("core_1_r0 = %h", `DESIGN_INSTANCE.core_1_r0);
        $display("core_1_r1 = %h", `DESIGN_INSTANCE.core_1_r1);
        $display("core_1_r2 = %h", `DESIGN_INSTANCE.core_1_r2);
        $display("core_1_r3 = %h", `DESIGN_INSTANCE.core_1_r3);
        $display("core_1_r4 = %h", `DESIGN_INSTANCE.core_1_r4);
        $display("core_1_r5 = %h", `DESIGN_INSTANCE.core_1_r5);
        $display("core_1_r6 = %h", `DESIGN_INSTANCE.core_1_r6);
        $display("core_1_r7 = %h", `DESIGN_INSTANCE.core_1_r7);

        $display("[RESET DEBUG] Core 2 Registers:");
        $display("core_2_r0 = %h", `DESIGN_INSTANCE.core_2_r0);
        $display("core_2_r1 = %h", `DESIGN_INSTANCE.core_2_r1);
        $display("core_2_r2 = %h", `DESIGN_INSTANCE.core_2_r2);
        $display("core_2_r3 = %h", `DESIGN_INSTANCE.core_2_r3);
        $display("core_2_r4 = %h", `DESIGN_INSTANCE.core_2_r4);
        $display("core_2_r5 = %h", `DESIGN_INSTANCE.core_2_r5);
        $display("core_2_r6 = %h", `DESIGN_INSTANCE.core_2_r6);
        $display("core_2_r7 = %h", `DESIGN_INSTANCE.core_2_r7);

        $display ("\n%0sFAIL! All registers of two cores MUST be zero after RESET!%0s", txt_red_prefix, reset_color);
        $finish;
    end

    #(CYCLE); 
    rst_n = 1; 
    
    #(CYCLE * 3); 
    
    release clk;
end endtask

task write_inst1_word; input integer byte_addr; input [15:0] word; 
begin 
    DRAM_inst1.DRAM_r[byte_addr] = word[7:0]; 
    DRAM_inst1.DRAM_r[byte_addr+1] = word[15:8]; 
end endtask

task write_inst2_word; input integer byte_addr; input [15:0] word; 
begin 
    DRAM_inst2.DRAM_r[byte_addr] = word[7:0]; 
    DRAM_inst2.DRAM_r[byte_addr+1] = word[15:8]; 
end endtask

task write_data_word;  input integer byte_addr; input [15:0] word; 
begin 
    DRAM_data.DRAM_r[byte_addr] = word[7:0]; 
    DRAM_data.DRAM_r[byte_addr+1] = word[15:8]; 
end endtask

task generate_pattern_task; 
    integer gen_i, type_sel1, type_sel2;
    reg [2:0] g1_op, g1_rs, g1_rt, g1_rd, g1_func, g1_rl;
    reg [2:0] g2_op, g2_rs, g2_rt, g2_rd, g2_func, g2_rl;
    reg signed [6:0] g1_imm, g2_imm;
    reg [12:0] g1_addr, g2_addr;
    reg [15:0] gen_inst1, gen_inst2, data_word;
begin
    for (gen_i = 0; gen_i <= 'h1FFF; gen_i = gen_i + 1) begin 
        DRAM_inst1.DRAM_r[gen_i] = 8'h00; 
        DRAM_inst2.DRAM_r[gen_i] = 8'h00; 
    end

    for (gen_i = 'h1000; gen_i <= 'h2FFF; gen_i = gen_i + 1) begin 
        DRAM_data.DRAM_r[gen_i] = 8'h00; 
    end

    for(gen_i=0; gen_i<4096; gen_i=gen_i+1) begin
        // [0x1000] 0
        if (gen_i == 0) data_word = 16'd0;
        // [0x1002] 4095
        else if (gen_i == 1) data_word = 16'd4095;
        // [0x1004] 32767
        else if (gen_i == 2) data_word = 16'h7FFF;
        // [0x1006] -32768
        else if (gen_i == 3) data_word = 16'h8000;
        // [0x1008] -1
        else if (gen_i == 4) data_word = 16'hFFFF;
        else if (gen_i < 9) data_word = gen_i * 10; 
        else data_word = rand_range(0, 65535);
        
        write_data_word('h1000 + (gen_i*2), data_word); 
    end
    
    gen_i = 0;
    while(gen_i < 4095) begin
        if (gen_i == 0) begin g1_op = 3'b000; g1_rs = 7; g1_rt = 7; g1_rd = 7; g1_func = 3'b110; end // [0x0000] C1/C2: XOR r7, r7, r7
        else if (gen_i == 1) begin g1_op = 3'b010; g1_rs = 7; g1_rt = 7; g1_imm = 50; end // [0x0002] C1/C2: ADDI r7, r7, 50
        else if (gen_i == 2) begin g1_op = 3'b010; g1_rs = 7; g1_rt = 7; g1_imm = 50; end // [0x0004] C1/C2: ADDI r7, r7, 50
        else if (gen_i == 3) begin g1_op = 3'b010; g1_rs = 0; g1_rt = 2; g1_imm = 1;  end // [0x0006] C1/C2: ADDI r2, r0, 1
        else if (gen_i == 4) begin g1_op = 3'b010; g1_rs = 0; g1_rt = 5; g1_imm = 50; end // [0x0008] C1/C2: ADDI r5, r0, 50
        else if (gen_i == 5) begin g1_op = 3'b001; g1_rs = 5; g1_rt = 5; g1_rd = 4; g1_rl = 5; end // [0x000A] C1/C2: MUL r4, r5, r5, r5

        else if (gen_i == 100) begin
            // [0x00C8] C1: ADDI r6, r0, 2    | C2: ADDI r5, r0, 2
            write_inst1_word(gen_i*2, {3'b010, 3'd0, 3'd6, 7'd2});
            write_inst2_word(gen_i*2, {3'b010, 3'd0, 3'd5, 7'd2});
            gen_i = gen_i + 1;
            // [0x00CA] C1: SUBI r6, r6, 1    | C2: SUBI r5, r5, 1
            write_inst1_word(gen_i*2, {3'b011, 3'd6, 3'd6, 7'd1});
            write_inst2_word(gen_i*2, {3'b011, 3'd5, 3'd5, 7'd1});
            gen_i = gen_i + 1;
            // [0x00CC] C1: BEQ r6, r0, 1     | C2: BEQ r5, r0, 1
            write_inst1_word(gen_i*2, {3'b110, 3'd6, 3'd0, 7'd1});
            write_inst2_word(gen_i*2, {3'b110, 3'd5, 3'd0, 7'd1});
            gen_i = gen_i + 1;
            // [0x00CE] C1: BEQ r0, r0, -3    | C2: BEQ r0, r0, -3
            g1_op = 3'b110; g1_rs = 3'd0; g1_rt = 3'd0; g1_imm = -7'sd3; 
            g2_op = 3'b110; g2_rs = 3'd0; g2_rt = 3'd0; g2_imm = -7'sd3;
        end
        else if (gen_i == 104) begin
            // [0x00D0] C1: XOR r6, r6, r6    | C2: XOR r5, r5, r5
            g1_op = 3'b000; g1_rs = 6; g1_rt = 6; g1_rd = 6; g1_func = 3'b110; 
            g2_op = 3'b000; g2_rs = 5; g2_rt = 5; g2_rd = 5; g2_func = 3'b110; 
        end
        
        else if (gen_i == 200) begin
            // [0x0190] C1: ADDI r6, r0, 2    | C2: ADDI r5, r0, 2
            write_inst1_word(gen_i*2, {3'b010, 3'd0, 3'd6, 7'd2});
            write_inst2_word(gen_i*2, {3'b010, 3'd0, 3'd5, 7'd2});
            gen_i = gen_i + 1;
            // [0x0192] C1: SUBI r6, r6, 1    | C2: SUBI r5, r5, 1
            write_inst1_word(gen_i*2, {3'b011, 3'd6, 3'd6, 7'd1});
            write_inst2_word(gen_i*2, {3'b011, 3'd5, 3'd5, 7'd1});
            gen_i = gen_i + 1;
            // [0x0194] C1: BEQ r6, r0, 1     | C2: BEQ r5, r0, 1
            write_inst1_word(gen_i*2, {3'b110, 3'd6, 3'd0, 7'd1});
            write_inst2_word(gen_i*2, {3'b110, 3'd5, 3'd0, 7'd1});
            gen_i = gen_i + 1;
            // [0x0196] C1: J 0x0192          | C2: J 0x0192
            g1_op = 3'b111; g1_addr = 13'h0192; 
            g2_op = 3'b111; g2_addr = 13'h0192;
        end
        else if (gen_i == 204) begin
            // [0x0198] C1: XOR r6, r6, r6    | C2: XOR r5, r5, r5
            g1_op = 3'b000; g1_rs = 6; g1_rt = 6; g1_rd = 6; g1_func = 3'b110; 
            g2_op = 3'b000; g2_rs = 5; g2_rt = 5; g2_rd = 5; g2_func = 3'b110; 
        end
        
        else if (gen_i == 210) begin
            // [0x01A4] C1: ADDI r7, r0, 20   | C2: ADDI r7, r0, 20
            write_inst1_word(gen_i*2, {3'b010, 3'd0, 3'd7, 7'd20});
            write_inst2_word(gen_i*2, {3'b010, 3'd0, 3'd7, 7'd20});
            gen_i = gen_i + 1;
            // [0x01A6] C1: ADDI r3, r0, 0    | C2: ADDI r4, r0, 55
            write_inst1_word(gen_i*2, {3'b010, 3'd0, 3'd3, 7'd0});
            write_inst2_word(gen_i*2, {3'b010, 3'd0, 3'd4, 7'd55});
            gen_i = gen_i + 1;
            // [0x01A8] C1: LH r3, 0(r7)      | C2: SH r4, 0(r7)
            g1_op = 3'b100; g1_rs = 3'd7; g1_rt = 3'd3; g1_imm = 7'd0;
            g2_op = 3'b101; g2_rs = 3'd7; g2_rt = 3'd4; g2_imm = 7'd0;
        end
        else if (gen_i == 213) begin
            // [0x01AA] C1: ADDI r7, r0, 50   | C2: ADDI r7, r0, 50
            write_inst1_word(gen_i*2, {3'b010, 3'd0, 3'd7, 7'd50});
            write_inst2_word(gen_i*2, {3'b010, 3'd0, 3'd7, 7'd50});
            gen_i = gen_i + 1;
            // [0x01AC] C1: ADDI r7, r7, 50   | C2: ADDI r7, r7, 50
            g1_op = 3'b010; g1_rs = 7; g1_rt = 7; g1_imm = 7'd50;
            g2_op = 3'b010; g2_rs = 7; g2_rt = 7; g2_imm = 7'd50;
        end
        
        else if (gen_i == 220) begin
            // [0x01B8] C1: ADDI r7, r0, 30   | C2: ADDI r7, r0, 30
            write_inst1_word(gen_i*2, {3'b010, 3'd0, 3'd7, 7'd30});
            write_inst2_word(gen_i*2, {3'b010, 3'd0, 3'd7, 7'd30});
            gen_i = gen_i + 1;
            // [0x01BA] C1: ADDI r4, r0, 55   | C2: ADDI r3, r0, 0
            write_inst1_word(gen_i*2, {3'b010, 3'd0, 3'd4, 7'd55});
            write_inst2_word(gen_i*2, {3'b010, 3'd0, 3'd3, 7'd0});
            gen_i = gen_i + 1;
            // [0x01BC] C1: SH r4, 0(r7)      | C2: LH r3, 0(r7)
            g1_op = 3'b101; g1_rs = 3'd7; g1_rt = 3'd4; g1_imm = 7'd0;
            g2_op = 3'b100; g2_rs = 3'd7; g2_rt = 3'd3; g2_imm = 7'd0;
        end
        else if (gen_i == 223) begin
            // [0x01BE] C1: ADDI r7, r0, 50   | C2: ADDI r7, r0, 50
            write_inst1_word(gen_i*2, {3'b010, 3'd0, 3'd7, 7'd50});
            write_inst2_word(gen_i*2, {3'b010, 3'd0, 3'd7, 7'd50});
            gen_i = gen_i + 1;
            // [0x01C0] C1: ADDI r7, r7, 50   | C2: ADDI r7, r7, 50
            g1_op = 3'b010; g1_rs = 7; g1_rt = 7; g1_imm = 7'd50;
            g2_op = 3'b010; g2_rs = 7; g2_rt = 7; g2_imm = 7'd50;
        end
        
        else if (gen_i == 230) begin
            // [0x01CC] C1: SUBI r3, r0, 1    | C2: SUBI r3, r0, 1
            write_inst1_word(gen_i*2, {3'b011, 3'd0, 3'd3, 7'd1});
            write_inst2_word(gen_i*2, {3'b011, 3'd0, 3'd3, 7'd1});
            gen_i = gen_i + 1;
            // [0x01CE] C1: SUBI r4, r0, 1    | C2: SUBI r4, r0, 1
            write_inst1_word(gen_i*2, {3'b011, 3'd0, 3'd4, 7'd1});
            write_inst2_word(gen_i*2, {3'b011, 3'd0, 3'd4, 7'd1});
            gen_i = gen_i + 1;
            // [0x01D0] C1: MUL r2, r3, r3, r4| C2: MUL r2, r3, r3, r4
            write_inst1_word(gen_i*2, {3'b001, 3'd3, 3'd4, 3'd2, 3'd3, 1'b0});
            write_inst2_word(gen_i*2, {3'b001, 3'd3, 3'd4, 3'd2, 3'd3, 1'b0});
            gen_i = gen_i + 1;
            // [0x01D2] C1: XOR r4, r4, r4    | C2: XOR r4, r4, r4
            write_inst1_word(gen_i*2, {3'b000, 3'd4, 3'd4, 3'd4, 3'b110, 1'b0});
            write_inst2_word(gen_i*2, {3'b000, 3'd4, 3'd4, 3'd4, 3'b110, 1'b0});
            gen_i = gen_i + 1;
            // [0x01D4] C1: MUL r2, r3, r3, r4| C2: MUL r2, r3, r3, r4
            g1_op = 3'b001; g1_rs = 3; g1_rt = 4; g1_rd = 2; g1_rl = 3;
            g2_op = 3'b001; g2_rs = 3; g2_rt = 4; g2_rd = 2; g2_rl = 3;
        end
        else if (gen_i == 235) begin
            // [0x01D6] C1: ADDI r7, r0, 50   | C2: ADDI r7, r0, 50
            write_inst1_word(gen_i*2, {3'b010, 3'd0, 3'd7, 7'd50});
            write_inst2_word(gen_i*2, {3'b010, 3'd0, 3'd7, 7'd50});
            gen_i = gen_i + 1;
            // [0x01D8] C1: ADDI r7, r7, 50   | C2: ADDI r7, r7, 50
            g1_op = 3'b010; g1_rs = 7; g1_rt = 7; g1_imm = 7'd50;
            g2_op = 3'b010; g2_rs = 7; g2_rt = 7; g2_imm = 7'd50;
        end
        
        else if (gen_i == 240) begin
            // [0x01E0] C1: ADDI r2, r0, 1    | C2: ADDI r2, r0, 1
            write_inst1_word(gen_i*2, {3'b010, 3'd0, 3'd2, 7'd1}); 
            write_inst2_word(gen_i*2, {3'b010, 3'd0, 3'd2, 7'd1});
            gen_i = gen_i + 1;
            // [0x01E2] C1: XOR r3, r3, r3    | C2: XOR r3, r3, r3
            write_inst1_word(gen_i*2, {3'b000, 3'd3, 3'd3, 3'd3, 3'b110, 1'b0}); 
            write_inst2_word(gen_i*2, {3'b000, 3'd3, 3'd3, 3'd3, 3'b110, 1'b0});
            gen_i = gen_i + 1;
            // [0x01E4] C1: BEQ r2, r3, 5     | C2: BEQ r2, r3, 5
            g1_op = 3'b110; g1_rs = 3'd2; g1_rt = 3'd3; g1_imm = 7'd5;
            g2_op = 3'b110; g2_rs = 3'd2; g2_rt = 3'd3; g2_imm = 7'd5;
        end

        else if (gen_i == 250) begin
            // [0x01F4] C1: XOR r7, r7, r7    | C2: XOR r7, r7, r7
            g1_op = 3'b000; g1_rs = 7; g1_rt = 7; g1_rd = 7; g1_func = 3'b110;
            g2_op = 3'b000; g2_rs = 7; g2_rt = 7; g2_rd = 7; g2_func = 3'b110;
        end
        else if (gen_i == 251) begin
            // [0x01F6] C1: LH r6, 1(r7)      | C2: LH r6, 1(r7)
            g1_op = 3'b100; g1_rs = 7; g1_rt = 6; g1_imm = 7'd1;
            g2_op = 3'b100; g2_rs = 7; g2_rt = 6; g2_imm = 7'd1;
        end
        else if (gen_i == 252) begin
            // [0x01F8] C1: LH r3, 0(r7)      | C2: SH r3, 0(r7)
            g1_op = 3'b100; g1_rs = 7; g1_rt = 3; g1_imm = 7'd0;
            g2_op = 3'b101; g2_rs = 7; g2_rt = 3; g2_imm = 7'd0;
        end
        else if (gen_i == 253) begin
            // [0x01FA] C1: SH r3, 0(r6)      | C2: LH r4, 0(r6)
            g1_op = 3'b101; g1_rs = 6; g1_rt = 3; g1_imm = 7'd0;
            g2_op = 3'b100; g2_rs = 6; g2_rt = 4; g2_imm = 7'd0;
        end
        else if (gen_i == 254) begin
            // [0x01FC] C1: ADDI r7, r0, 50   | C2: ADDI r7, r0, 50
            g1_op = 3'b010; g1_rs = 0; g1_rt = 7; g1_imm = 7'd50;
            g2_op = 3'b010; g2_rs = 0; g2_rt = 7; g2_imm = 7'd50;
        end
        else if (gen_i == 255) begin
            // [0x01FE] C1: ADDI r7, r7, 50   | C2: ADDI r7, r7, 50
            g1_op = 3'b010; g1_rs = 7; g1_rt = 7; g1_imm = 7'd50;
            g2_op = 3'b010; g2_rs = 7; g2_rt = 7; g2_imm = 7'd50;
        end

        else if (gen_i == 260) begin
            // [0x0208] C1: XOR r7, r7, r7    | C2: XOR r7, r7, r7
            g1_op = 3'b000; g1_rs = 7; g1_rt = 7; g1_rd = 7; g1_func = 3'b110;
            g2_op = 3'b000; g2_rs = 7; g2_rt = 7; g2_rd = 7; g2_func = 3'b110;
        end
        else if (gen_i == 261) begin
            // [0x020A] C1: ADDI r7, r7, 50   | C2: ADDI r7, r7, 50
            g1_op = 3'b010; g1_rs = 7; g1_rt = 7; g1_imm = 7'd50;
            g2_op = 3'b010; g2_rs = 7; g2_rt = 7; g2_imm = 7'd50;
        end
        else if (gen_i == 262) begin
            // [0x020C] C1: ADDI r7, r7, 50   | C2: ADDI r7, r7, 50
            g1_op = 3'b010; g1_rs = 7; g1_rt = 7; g1_imm = 7'd50;
            g2_op = 3'b010; g2_rs = 7; g2_rt = 7; g2_imm = 7'd50;
        end
        else if (gen_i == 263) begin
            // [0x020E] C1: LH r3, -1(r7)     | C2: SH r4, -2(r7)
            g1_op = 3'b100; g1_rs = 7; g1_rt = 3; g1_imm = -7'sd1;
            g2_op = 3'b101; g2_rs = 7; g2_rt = 4; g2_imm = -7'sd2;
        end

        else if (gen_i == 270) begin
            // [0x021C] C1: ADDI r3, r7, 63   | C2: ADDI r3, r7, 63
            g1_op = 3'b010; g1_rs = 7; g1_rt = 3; g1_imm = 7'd63;
            g2_op = 3'b010; g2_rs = 7; g2_rt = 3; g2_imm = 7'd63;
        end
        else if (gen_i == 271) begin
            // [0x021E] C1: ADDI r4, r7, -64  | C2: ADDI r4, r7, -64
            g1_op = 3'b010; g1_rs = 7; g1_rt = 4; g1_imm = -7'sd64;
            g2_op = 3'b010; g2_rs = 7; g2_rt = 4; g2_imm = -7'sd64;
        end
        else if (gen_i == 272) begin
            // [0x0220] C1: SUBI r5, r7, 63   | C2: SUBI r6, r7, -64
            g1_op = 3'b011; g1_rs = 7; g1_rt = 5; g1_imm = 7'd63;
            g2_op = 3'b011; g2_rs = 7; g2_rt = 6; g2_imm = -7'sd64;
        end

        else if (gen_i == 280) begin
            // [0x0230] C1: XOR r0, r0, r0    | C2: XOR r0, r0, r0
            g1_op = 3'b000; g1_rs = 0; g1_rt = 0; g1_rd = 0; g1_func = 3'b110;
            g2_op = 3'b000; g2_rs = 0; g2_rt = 0; g2_rd = 0; g2_func = 3'b110;
        end
        else if (gen_i == 281) begin
            // [0x0232] C1: LH r5, 2(r0)      | C2: LH r5, 2(r0)
            g1_op = 3'b100; g1_rs = 0; g1_rt = 5; g1_imm = 7'd2;
            g2_op = 3'b100; g2_rs = 0; g2_rt = 5; g2_imm = 7'd2;
        end
        else if (gen_i == 282) begin
            // [0x0234] C1: LH r6, 3(r0)      | C2: LH r6, 3(r0)
            g1_op = 3'b100; g1_rs = 0; g1_rt = 6; g1_imm = 7'd3;
            g2_op = 3'b100; g2_rs = 0; g2_rt = 6; g2_imm = 7'd3;
        end
        else if (gen_i == 283) begin
            // [0x0236] C1: ADDI r1, r0, 1    | C2: ADDI r1, r0, 1
            g1_op = 3'b010; g1_rs = 0; g1_rt = 1; g1_imm = 7'd1;
            g2_op = 3'b010; g2_rs = 0; g2_rt = 1; g2_imm = 7'd1;
        end
        else if (gen_i == 284) begin
            // [0x0238] C1: ADD r5, r5, r1    | C2: SUB r6, r6, r1
            g1_op = 3'b000; g1_rs = 5; g1_rt = 1; g1_rd = 5; g1_func = 3'b000;
            g2_op = 3'b000; g2_rs = 6; g2_rt = 1; g2_rd = 6; g2_func = 3'b001;
        end

        else if (gen_i == 290) begin
            // [0x0244] C1: LH r5, 2(r0)      | C2: LH r5, 2(r0)
            g1_op = 3'b100; g1_rs = 0; g1_rt = 5; g1_imm = 7'd2;
            g2_op = 3'b100; g2_rs = 0; g2_rt = 5; g2_imm = 7'd2;
        end
        else if (gen_i == 291) begin
            // [0x0246] C1: LH r6, 3(r0)      | C2: LH r6, 3(r0)
            g1_op = 3'b100; g1_rs = 0; g1_rt = 6; g1_imm = 7'd3;
            g2_op = 3'b100; g2_rs = 0; g2_rt = 6; g2_imm = 7'd3;
        end
        else if (gen_i == 292) begin
            // [0x0248] C1: LH r4, 4(r0)      | C2: LH r4, 4(r0)
            g1_op = 3'b100; g1_rs = 0; g1_rt = 4; g1_imm = 7'd4;
            g2_op = 3'b100; g2_rs = 0; g2_rt = 4; g2_imm = 7'd4;
        end
        else if (gen_i == 293) begin
            // [0x024A] C1: MUL r2, r3, r5, r5| C2: MUL r2, r3, r6, r4
            g1_op = 3'b001; g1_rs = 5; g1_rt = 5; g1_rd = 2; g1_rl = 3;
            g2_op = 3'b001; g2_rs = 6; g2_rt = 4; g2_rd = 2; g2_rl = 3;
        end
        else if (gen_i == 294) begin
            // [0x024C] C1: MUL r4, r4, r5, r6| C2: MUL r4, r4, r5, r6
            g1_op = 3'b001; g1_rs = 5; g1_rt = 6; g1_rd = 4; g1_rl = 4;
            g2_op = 3'b001; g2_rs = 5; g2_rt = 6; g2_rd = 4; g2_rl = 4;
        end

        else if (gen_i == 320) begin
            // [0x0280] C1: ADDI r7, r0, 10   | C2: ADDI r7, r0, 10
            g1_op = 3'b010; g1_rs = 0; g1_rt = 7; g1_imm = 7'd10;
            g2_op = 3'b010; g2_rs = 0; g2_rt = 7; g2_imm = 7'd10;
        end
        else if (gen_i == 321) begin
            // [0x0282] C1: ADDI r6, r0, 11   | C2: ADDI r6, r0, 11
            g1_op = 3'b010; g1_rs = 0; g1_rt = 6; g1_imm = 7'd11;
            g2_op = 3'b010; g2_rs = 0; g2_rt = 6; g2_imm = 7'd11;
        end
        else if (gen_i == 322) begin
            // [0x0284] C1: LH r2, 0(r7)      | C2: LH r3, 0(r7)
            g1_op = 3'b100; g1_rs = 7; g1_rt = 2; g1_imm = 7'd0;
            g2_op = 3'b100; g2_rs = 7; g2_rt = 3; g2_imm = 7'd0;
        end
        else if (gen_i == 323) begin
            // [0x0286] C1: SH r2, 0(r7)      | C2: LH r3, 0(r6)
            g1_op = 3'b101; g1_rs = 7; g1_rt = 2; g1_imm = 7'd0;
            g2_op = 3'b100; g2_rs = 6; g2_rt = 3; g2_imm = 7'd0;
        end
        else if (gen_i == 324) begin
            // [0x0288] C1: LH r2, 0(r6)      | C2: SH r3, 0(r7)
            g1_op = 3'b100; g1_rs = 6; g1_rt = 2; g1_imm = 7'd0;
            g2_op = 3'b101; g2_rs = 7; g2_rt = 3; g2_imm = 7'd0;
        end
        else if (gen_i == 325) begin
            // [0x028A] C1: ADDI r7, r0, 50   | C2: ADDI r7, r0, 50
            g1_op = 3'b010; g1_rs = 0; g1_rt = 7; g1_imm = 7'd50;
            g2_op = 3'b010; g2_rs = 0; g2_rt = 7; g2_imm = 7'd50;
        end
        else if (gen_i == 326) begin
            // [0x028C] C1: ADDI r7, r7, 50   | C2: ADDI r7, r7, 50
            g1_op = 3'b010; g1_rs = 7; g1_rt = 7; g1_imm = 7'd50;
            g2_op = 3'b010; g2_rs = 7; g2_rt = 7; g2_imm = 7'd50;
        end

        else if (gen_i == 330) begin
            // [0x0294] C1: ADDI r1, r0, 3    | C2: ADDI r1, r0, 3
            write_inst1_word(gen_i*2, {3'b010, 3'd0, 3'd1, 7'd3});
            write_inst2_word(gen_i*2, {3'b010, 3'd0, 3'd1, 7'd3});
            gen_i = gen_i + 1;
            // [0x0296] C1: SUBI r1, r1, 1    | C2: SUBI r1, r1, 1
            write_inst1_word(gen_i*2, {3'b011, 3'd1, 3'd1, 7'd1});
            write_inst2_word(gen_i*2, {3'b011, 3'd1, 3'd1, 7'd1});
            gen_i = gen_i + 1;
            // [0x0298] C1: BEQ r1, r0, 1     | C2: BEQ r1, r0, 1
            write_inst1_word(gen_i*2, {3'b110, 3'd1, 3'd0, 7'd1});
            write_inst2_word(gen_i*2, {3'b110, 3'd1, 3'd0, 7'd1});
            gen_i = gen_i + 1;
            // [0x029A] C1: J 0x0296          | C2: J 0x0296
            g1_op = 3'b111; g1_addr = 13'h0296;
            g2_op = 3'b111; g2_addr = 13'h0296;
        end

        else if (gen_i == 350) begin
            // [0x02BE] C1: J 0x02D0          | C2: J 0x02D0
            g1_op = 3'b111; g1_addr = 13'h02D0;
            g2_op = 3'b111; g2_addr = 13'h02D0;
        end

        else begin
            type_sel1 = rand_range(0, 999); 
            if (type_sel1 < 400) begin
                g1_op = 3'b000;
                g1_rs = rand_range(0,4);
                g1_rt = rand_range(0,4);
                g1_rd = rand_range(2,4);
                g1_func = rand_range(0,7);
            end
            else if (type_sel1 < 500) begin
                g1_op = 3'b001;
                g1_rs = rand_range(0,4);
                g1_rt = rand_range(0,4);
                g1_rd = rand_range(2,4);
                g1_rl = rand_range(2,4);
                if(g1_rd==g1_rl) g1_rl=(g1_rl==4)?2:g1_rl+1;
            end
            else if (type_sel1 < 650) begin
                g1_op = rand_range(0,1)?3'b010:3'b011;
                g1_rs = rand_range(0,4);
                g1_rt = rand_range(2,4);
                g1_imm = rand_range(0,14)-7;
            end
            else begin
                g1_op = rand_range(0,1)?3'b100:3'b101;
                g1_rs = 7;
                g1_rt = rand_range(2,4);
                g1_imm = rand_range(0, 60) - 30;
            end
            
            type_sel2 = rand_range(0, 999);
            if (type_sel2 < 400) begin
                g2_op = 3'b000;
                g2_rs = rand_range(0,4);
                g2_rt = rand_range(0,4);
                g2_rd = rand_range(2,4);
                g2_func = rand_range(0,7);
            end
            else if (type_sel2 < 500) begin
                g2_op = 3'b001;
                g2_rs = rand_range(0,4);
                g2_rt = rand_range(0,4);
                g2_rd = rand_range(2,4);
                g2_rl = rand_range(2,4);
                if(g2_rd==g2_rl) g2_rl=(g2_rl==4)?2:g2_rl+1;
            end
            else if (type_sel2 < 650) begin
                g2_op = rand_range(0,1)?3'b010:3'b011;
                g2_rs = rand_range(0,4);
                g2_rt = rand_range(2,4);
                g2_imm = rand_range(0,14)-7;
            end
            else begin
                g2_op = rand_range(0,1)?3'b100:3'b101;
                g2_rs = 7;
                g2_rt = rand_range(2,4);
                g2_imm = rand_range(0, 60) - 30;
            end
            
            if (g1_op == 3'b101 && g2_op == 3'b101) g2_op = 3'b100; 
        end
        
        if (gen_i < 6) begin 
            gen_inst1 = (g1_op==3'b000)?{g1_op,g1_rs,g1_rt,g1_rd,g1_func,1'b0} : (g1_op==3'b001)?{g1_op,g1_rs,g1_rt,g1_rd,g1_rl,1'b0} : (g1_op==3'b111)?{g1_op,g1_addr} : {g1_op,g1_rs,g1_rt,g1_imm};
            gen_inst2 = gen_inst1;
        end 
        else begin
            gen_inst1 = (g1_op==3'b000)?{g1_op,g1_rs,g1_rt,g1_rd,g1_func,1'b0} : (g1_op==3'b001)?{g1_op,g1_rs,g1_rt,g1_rd,g1_rl,1'b0} : (g1_op==3'b111)?{g1_op,g1_addr} : {g1_op,g1_rs,g1_rt,g1_imm};
            gen_inst2 = (g2_op==3'b000)?{g2_op,g2_rs,g2_rt,g2_rd,g2_func,1'b0} : (g2_op==3'b001)?{g2_op,g2_rs,g2_rt,g2_rd,g2_rl,1'b0} : (g2_op==3'b111)?{g2_op,g2_addr} : {g2_op,g2_rs,g2_rt,g2_imm};
        end
        write_inst1_word(gen_i*2, gen_inst1); write_inst2_word(gen_i*2, gen_inst2); 
        gen_i = gen_i + 1;
    end

    while (gen_i < 4096) begin
        gen_inst1 = {3'b010, 3'd0, 3'd0, 7'd0};  // ADDI r0, r0, 0
        gen_inst2 = {3'b010, 3'd0, 3'd0, 7'd0};  // ADDI r0, r0, 0
        write_inst1_word(gen_i*2, gen_inst1);
        write_inst2_word(gen_i*2, gen_inst2);
        gen_i = gen_i + 1;
    end
end endtask

task dump_dat_task;
    integer fd_i1, fd_i2, fd_d;
    integer mem_i;
begin
    fd_i1 = $fopen("../00_TESTBED/DRAM/inst_1_dram_file.dat", "w");
    fd_i2 = $fopen("../00_TESTBED/DRAM/inst_2_dram_file.dat", "w");
    fd_d  = $fopen("../00_TESTBED/DRAM/data_dram_file.dat", "w");

    // Inst 1: 0x0000 to 0x1FFF
    for (mem_i = 0; mem_i < 8192; mem_i = mem_i + 2) begin
        $fwrite(fd_i1, "@%08X\n%02X %02X\n", mem_i, DRAM_inst1.DRAM_r[mem_i], DRAM_inst1.DRAM_r[mem_i+1]);
    end

    // Inst 2: 0x0000 to 0x1FFF
    for (mem_i = 0; mem_i < 8192; mem_i = mem_i + 2) begin
        $fwrite(fd_i2, "@%08X\n%02X %02X\n", mem_i, DRAM_inst2.DRAM_r[mem_i], DRAM_inst2.DRAM_r[mem_i+1]);
    end

    // Data: 0x1000 to 0x2FFF
    for (mem_i = 'h1000; mem_i < 'h3000; mem_i = mem_i + 2) begin
        $fwrite(fd_d, "@%08X\n%02X %02X\n", mem_i, DRAM_data.DRAM_r[mem_i], DRAM_data.DRAM_r[mem_i+1]);
    end

    $fclose(fd_i1);
    $fclose(fd_i2);
    $fclose(fd_d);
end endtask

parameter AXI_MAX_LATENCY = 300;

integer r_lat_inst1 = 0, b_lat_inst1 = 0;
integer r_lat_inst2 = 0, b_lat_inst2 = 0;
integer r_lat_data  = 0, b_lat_data  = 0;

always @(negedge clk) begin
    if (rst_n === 1'b1) begin
        // --- INST 1 Monitor ---
        if (rvalid_s_inf_inst_1 === 1'b1 && rready_s_inf_inst_1 === 1'b0) r_lat_inst1 = r_lat_inst1 + 1;
        else r_lat_inst1 = 0;
        if (r_lat_inst1 > AXI_MAX_LATENCY) begin 
            YOU_FAIL_task;
            $display("\n%0s[AXI Error] INST1 RVALID to RREADY latency > 300 cycles!%0s", txt_red_prefix, reset_color); 
            $finish; 
        end

        if (bvalid_s_inf_inst_1 === 1'b1 && bready_s_inf_inst_1 === 1'b0) b_lat_inst1 = b_lat_inst1 + 1;
        else b_lat_inst1 = 0;
        if (b_lat_inst1 > AXI_MAX_LATENCY) begin 
            YOU_FAIL_task;
            $display("\n%0s[AXI Error] INST1 BVALID to BREADY latency > 300 cycles!%0s", txt_red_prefix, reset_color); 
            $finish; 
        end

        // --- INST 2 Monitor ---
        if (rvalid_s_inf_inst_2 === 1'b1 && rready_s_inf_inst_2 === 1'b0) r_lat_inst2 = r_lat_inst2 + 1;
        else r_lat_inst2 = 0;
        if (r_lat_inst2 > AXI_MAX_LATENCY) begin 
            YOU_FAIL_task;
            $display("\n%0s[AXI Error] INST2 RVALID to RREADY latency > 300 cycles!%0s", txt_red_prefix, reset_color); 
            $finish; 
        end

        if (bvalid_s_inf_inst_2 === 1'b1 && bready_s_inf_inst_2 === 1'b0) b_lat_inst2 = b_lat_inst2 + 1;
        else b_lat_inst2 = 0;
        if (b_lat_inst2 > AXI_MAX_LATENCY) begin 
            YOU_FAIL_task;
            $display("\n%0s[AXI Error] INST2 BVALID to BREADY latency > 300 cycles!%0s", txt_red_prefix, reset_color); 
            $finish; 
        end

        // --- DATA Monitor ---
        if (rvalid_s_inf_data === 1'b1 && rready_s_inf_data === 1'b0) r_lat_data = r_lat_data + 1;
        else r_lat_data = 0;
        if (r_lat_data > AXI_MAX_LATENCY) begin 
            YOU_FAIL_task;
            $display("\n%0s[AXI Error] DATA RVALID to RREADY latency > 300 cycles!%0s", txt_red_prefix, reset_color); 
            $finish; 
        end

        if (bvalid_s_inf_data === 1'b1 && bready_s_inf_data === 1'b0) b_lat_data = b_lat_data + 1;
        else b_lat_data = 0;
        if (b_lat_data > AXI_MAX_LATENCY) begin 
            YOU_FAIL_task;
            $display("\n%0s[AXI Error] DATA BVALID to BREADY latency > 300 cycles!%0s", txt_red_prefix, reset_color); 
            $finish; 
        end
    end
end

task YOU_PASS_task; begin
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[0m");
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[0m");
    $display("\033[38;5;17m,\033[38;5;17m,\033[38;5;17m.\033[38;5;17m,\033[38;5;17m:\033[38;5;17m:\033[38;5;18m:\033[38;5;18m:\033[38;5;18m:\033[38;5;18m:\033[38;5;18m:\033[38;5;17m:\033[38;5;18m:\033[38;5;18m;\033[38;5;18m;\033[38;5;18m;\033[38;5;18m:\033[38;5;18m;\033[38;5;18m;\033[38;5;18m;\033[38;5;18m;\033[38;5;18m;\033[38;5;18m;\033[38;5;18m;\033[38;5;18m;\033[38;5;18m;\033[38;5;18m;\033[38;5;18m;\033[38;5;18m;\033[38;5;18m;\033[38;5;54m;\033[38;5;54mi\033[38;5;54mi\033[38;5;54mr\033[38;5;54mr\033[38;5;61ms\033[38;5;61mX\033[38;5;61ms\033[38;5;60mr\033[38;5;60mr\033[38;5;54mi\033[38;5;54mi\033[38;5;18m;\033[38;5;18m;\033[38;5;18mi\033[38;5;54mi\033[38;5;18m;\033[38;5;54mi\033[38;5;18m;\033[38;5;18m;\033[38;5;54m;\033[38;5;18m;\033[38;5;18m;\033[38;5;17m:\033[38;5;17m:\033[38;5;17m:\033[38;5;17m:\033[38;5;17m:\033[38;5;17m:\033[38;5;17m:\033[38;5;17m:\033[38;5;17m,\033[38;5;17m,\033[38;5;17m,\033[38;5;17m:\033[38;5;17m,\033[38;5;17m,\033[38;5;17m,\033[38;5;17m,\033[38;5;17m:\033[38;5;17m:\033[38;5;17m:\033[38;5;17m:\033[38;5;17m:\033[38;5;17m:\033[38;5;17m:\033[38;5;17m:\033[38;5;17m:\033[38;5;17m:\033[38;5;17m:\033[0m");
    $display("\033[38;5;60mr\033[38;5;60ms\033[38;5;60ms\033[38;5;60ms\033[38;5;60ms\033[38;5;60ms\033[38;5;61mX\033[38;5;54mi\033[38;5;54mi\033[38;5;61mX\033[38;5;61mX\033[38;5;61ms\033[38;5;60mr\033[38;5;60mr\033[38;5;61mr\033[38;5;61mr\033[38;5;61ms\033[38;5;61ms\033[38;5;61ms\033[38;5;61ms\033[38;5;61ms\033[38;5;61ms\033[38;5;61ms\033[38;5;61ms\033[38;5;61ms\033[38;5;61ms\033[38;5;61ms\033[38;5;61ms\033[38;5;61ms\033[38;5;61ms\033[38;5;61mX\033[38;5;61ms\033[38;5;61ms\033[38;5;61ms\033[38;5;54mr\033[38;5;54mr\033[38;5;54ms\033[38;5;61mX\033[38;5;61mA\033[38;5;61mX\033[38;5;61mX\033[38;5;61mA\033[38;5;61mA\033[38;5;61mA\033[38;5;61mX\033[38;5;61mA\033[38;5;61mX\033[38;5;61mX\033[38;5;61mA\033[38;5;61mX\033[38;5;61mX\033[38;5;61mA\033[38;5;61m2\033[38;5;61m2\033[38;5;61mA\033[38;5;62m2\033[38;5;98m5\033[38;5;98m5\033[38;5;98m5\033[38;5;98m5\033[38;5;104m5\033[38;5;104m5\033[38;5;61mA\033[38;5;62m2\033[38;5;104m5\033[38;5;104m3\033[38;5;104m3\033[38;5;104m3\033[38;5;98m5\033[38;5;104m3\033[38;5;104m3\033[38;5;98m5\033[38;5;104m3\033[38;5;104m3\033[38;5;104mh\033[38;5;104mh\033[38;5;104mh\033[38;5;104mh\033[38;5;104mh\033[38;5;104mh\033[0m");
    $display("\033[38;5;104mh\033[38;5;104m3\033[38;5;110mM\033[38;5;147mH\033[38;5;147mH\033[38;5;147mM\033[38;5;105mh\033[38;5;111mM\033[38;5;104mh\033[38;5;147mM\033[38;5;147mG\033[38;5;147mG\033[38;5;147mM\033[38;5;147mH\033[38;5;147mH\033[38;5;147mM\033[38;5;147mG\033[38;5;147mG\033[38;5;147mH\033[38;5;147mH\033[38;5;147mG\033[38;5;147mS\033[38;5;183mS\033[38;5;183mS\033[38;5;189mS\033[38;5;183mS\033[38;5;147mH\033[38;5;141mh\033[38;5;140m3\033[38;5;98m3\033[38;5;98m5\033[38;5;98m5\033[38;5;134m5\033[38;5;134m5\033[38;5;98m2\033[38;5;98m5\033[38;5;98m3\033[38;5;141mM\033[38;5;147mG\033[38;5;147mH\033[38;5;147mH\033[38;5;147mH\033[38;5;147mG\033[38;5;189mS\033[38;5;105mh\033[38;5;104m3\033[38;5;105mh\033[38;5;147mG\033[38;5;147mG\033[38;5;147mH\033[38;5;141mM\033[38;5;147mH\033[38;5;189mS\033[38;5;189mS\033[38;5;189mS\033[38;5;189m#\033[38;5;189mS\033[38;5;183mS\033[38;5;189mS\033[38;5;189m#\033[38;5;189m#\033[38;5;189m#\033[38;5;189mS\033[38;5;147mH\033[38;5;147mH\033[38;5;147mM\033[38;5;147mH\033[38;5;147mG\033[38;5;147mS\033[38;5;147mH\033[38;5;104m3\033[38;5;104m3\033[38;5;147mM\033[38;5;147mG\033[38;5;189mS\033[38;5;189mS\033[38;5;189mS\033[38;5;189mS\033[38;5;189m#\033[38;5;189m#\033[0m");
    $display("\033[38;5;104mh\033[38;5;104mh\033[38;5;104mh\033[38;5;146mM\033[38;5;146mH\033[38;5;146mM\033[38;5;104m3\033[38;5;104mh\033[38;5;147mM\033[38;5;147mM\033[38;5;147mH\033[38;5;147mH\033[38;5;147mH\033[38;5;147mG\033[38;5;147mG\033[38;5;147mG\033[38;5;189mS\033[38;5;189mS\033[38;5;189mS\033[38;5;147mS\033[38;5;189mS\033[38;5;189mS\033[38;5;189m#\033[38;5;189mS\033[38;5;153mS\033[38;5;147mG\033[38;5;104mh\033[38;5;61mX\033[38;5;60ms\033[38;5;60ms\033[38;5;60ms\033[38;5;60ms\033[38;5;54mr\033[38;5;60ms\033[38;5;98m5\033[38;5;98m5\033[38;5;98m3\033[38;5;147mG\033[38;5;147mH\033[38;5;104mh\033[38;5;105mM\033[38;5;147mH\033[38;5;147mM\033[38;5;104m3\033[38;5;104mh\033[38;5;104mh\033[38;5;104m3\033[38;5;140mh\033[38;5;141mM\033[38;5;105mh\033[38;5;147mH\033[38;5;147mG\033[38;5;189mS\033[38;5;189mS\033[38;5;189m#\033[38;5;189m#\033[38;5;189m#\033[38;5;189m#\033[38;5;189m#\033[38;5;189m#\033[38;5;189m#\033[38;5;189mS\033[38;5;147mG\033[38;5;105mh\033[38;5;98m5\033[38;5;98m5\033[38;5;97m2\033[38;5;104m3\033[38;5;147mH\033[38;5;147mG\033[38;5;104mh\033[38;5;97m2\033[38;5;104m3\033[38;5;141mM\033[38;5;147mH\033[38;5;189mS\033[38;5;189mS\033[38;5;189mS\033[38;5;189mS\033[38;5;147mG\033[0m");
    $display("\033[38;5;104m3\033[38;5;104mh\033[38;5;104mh\033[38;5;104mh\033[38;5;146mH\033[38;5;104mM\033[38;5;104mM\033[38;5;104mh\033[38;5;147mH\033[38;5;147mG\033[38;5;147mH\033[38;5;147mM\033[38;5;147mG\033[38;5;147mG\033[38;5;147mH\033[38;5;147mH\033[38;5;189mS\033[38;5;189mS\033[38;5;189mS\033[38;5;189mS\033[38;5;147mG\033[38;5;147mG\033[38;5;189mS\033[38;5;189m#\033[38;5;183mS\033[38;5;147mM\033[38;5;98m5\033[38;5;60ms\033[38;5;97mX\033[38;5;97mA\033[38;5;97mA\033[38;5;61mX\033[38;5;61mX\033[38;5;60mX\033[38;5;60ms\033[38;5;61mX\033[38;5;98m2\033[38;5;141mM\033[38;5;147mG\033[38;5;140mM\033[38;5;98m5\033[38;5;147mH\033[38;5;104m3\033[38;5;60ms\033[38;5;98m5\033[38;5;140mh\033[38;5;98m5\033[38;5;97m2\033[38;5;104mh\033[38;5;105mM\033[38;5;147mS\033[38;5;147mG\033[38;5;147mG\033[38;5;189mS\033[38;5;189mS\033[38;5;183mS\033[38;5;147mS\033[38;5;189mS\033[38;5;189m#\033[38;5;189m#\033[38;5;189mS\033[38;5;147mG\033[38;5;147mG\033[38;5;147mH\033[38;5;104m3\033[38;5;61mX\033[38;5;60mr\033[38;5;54mr\033[38;5;61mX\033[38;5;104m3\033[38;5;141mM\033[38;5;97m5\033[38;5;97m5\033[38;5;104m3\033[38;5;104m3\033[38;5;147mS\033[38;5;189mS\033[38;5;189m#\033[38;5;189m#\033[38;5;189mS\033[0m");
    $display("\033[38;5;104m5\033[38;5;104m3\033[38;5;104mM\033[38;5;146mH\033[38;5;146mH\033[38;5;146mM\033[38;5;147mM\033[38;5;104mh\033[38;5;104mM\033[38;5;147mH\033[38;5;111mM\033[38;5;147mG\033[38;5;147mG\033[38;5;147mS\033[38;5;147mG\033[38;5;189mS\033[38;5;153mS\033[38;5;147mG\033[38;5;141mh\033[38;5;104mh\033[38;5;147mH\033[38;5;147mG\033[38;5;147mG\033[38;5;183mS\033[38;5;189m#\033[38;5;147mG\033[38;5;140mh\033[38;5;97mA\033[38;5;97m2\033[38;5;97mA\033[38;5;97mX\033[38;5;60mX\033[38;5;97mA\033[38;5;98m5\033[38;5;140m3\033[38;5;98m3\033[38;5;97mA\033[38;5;60ms\033[38;5;104m5\033[38;5;104m5\033[38;5;61m2\033[38;5;147mM\033[38;5;140mM\033[38;5;97m2\033[38;5;61mA\033[38;5;97m2\033[38;5;97mA\033[38;5;97mA\033[38;5;97mA\033[38;5;98m5\033[38;5;104mh\033[38;5;104m3\033[38;5;105mh\033[38;5;147mH\033[38;5;147mG\033[38;5;147mH\033[38;5;147mH\033[38;5;189mS\033[38;5;189m#\033[38;5;189m#\033[38;5;189mS\033[38;5;147mS\033[38;5;189mS\033[38;5;153mS\033[38;5;147mG\033[38;5;147mH\033[38;5;97m5\033[38;5;61mA\033[38;5;60ms\033[38;5;54mr\033[38;5;61mA\033[38;5;61mA\033[38;5;61mA\033[38;5;97mA\033[38;5;61mA\033[38;5;104m3\033[38;5;147mH\033[38;5;147mS\033[38;5;147mG\033[38;5;147mG\033[0m");
    $display("\033[38;5;104m5\033[38;5;98m5\033[38;5;104m3\033[38;5;146mM\033[38;5;146mH\033[38;5;146mH\033[38;5;147mH\033[38;5;147mM\033[38;5;104m3\033[38;5;104mh\033[38;5;147mH\033[38;5;147mG\033[38;5;147mH\033[38;5;147mG\033[38;5;147mG\033[38;5;147mG\033[38;5;105mM\033[38;5;104mh\033[38;5;98m5\033[38;5;98m3\033[38;5;104m3\033[38;5;141mh\033[38;5;104m3\033[38;5;105mh\033[38;5;147mH\033[38;5;147mH\033[38;5;104m3\033[38;5;97m2\033[38;5;97m2\033[38;5;97mA\033[38;5;96mA\033[38;5;96mX\033[38;5;97mA\033[38;5;97m2\033[38;5;104m3\033[38;5;104m3\033[38;5;98m5\033[38;5;61mX\033[38;5;60ms\033[38;5;60ms\033[38;5;60mX\033[38;5;97m5\033[38;5;141mM\033[38;5;97m2\033[38;5;60ms\033[38;5;60mX\033[38;5;60mX\033[38;5;60mX\033[38;5;60mX\033[38;5;97m5\033[38;5;140mh\033[38;5;141mM\033[38;5;104m3\033[38;5;147mM\033[38;5;189mS\033[38;5;189mS\033[38;5;189mS\033[38;5;189m#\033[38;5;189m#\033[38;5;147mG\033[38;5;147mS\033[38;5;189m#\033[38;5;147mG\033[38;5;189mS\033[38;5;189mS\033[38;5;189mS\033[38;5;147mG\033[38;5;147mH\033[38;5;97m2\033[38;5;236mi\033[38;5;53mi\033[38;5;53mr\033[38;5;59mr\033[38;5;60mX\033[38;5;61mA\033[38;5;97m2\033[38;5;105mM\033[38;5;147mG\033[38;5;147mH\033[38;5;147mH\033[0m");
    $display("\033[38;5;104m3\033[38;5;104m5\033[38;5;61mA\033[38;5;104m3\033[38;5;110mM\033[38;5;104mM\033[38;5;104mh\033[38;5;104mh\033[38;5;104m3\033[38;5;104mh\033[38;5;147mG\033[38;5;147mG\033[38;5;147mH\033[38;5;147mG\033[38;5;147mG\033[38;5;105mh\033[38;5;104m3\033[38;5;104m3\033[38;5;141mh\033[38;5;98m5\033[38;5;98m5\033[38;5;98m3\033[38;5;134m3\033[38;5;98m5\033[38;5;98m5\033[38;5;98m5\033[38;5;97m2\033[38;5;97m2\033[38;5;97m2\033[38;5;97mA\033[38;5;97mA\033[38;5;60mX\033[38;5;60mX\033[38;5;60mX\033[38;5;61mA\033[38;5;98m2\033[38;5;104m3\033[38;5;61mA\033[38;5;54mr\033[38;5;54mr\033[38;5;60mr\033[38;5;60mr\033[38;5;60mX\033[38;5;60ms\033[38;5;60ms\033[38;5;60ms\033[38;5;60ms\033[38;5;54mr\033[38;5;61mA\033[38;5;147mH\033[38;5;147mH\033[38;5;147mG\033[38;5;189mS\033[38;5;189mS\033[38;5;189m#\033[38;5;189mS\033[38;5;189m#\033[38;5;189m#\033[38;5;189mS\033[38;5;147mH\033[38;5;189mS\033[38;5;189m#\033[38;5;147mG\033[38;5;189mS\033[38;5;189mS\033[38;5;104mh\033[38;5;61m2\033[38;5;60ms\033[38;5;17m;\033[38;5;235m;\033[38;5;53m;\033[38;5;53mi\033[38;5;237mr\033[38;5;59ms\033[38;5;60ms\033[38;5;104m5\033[38;5;147mG\033[38;5;189m#\033[38;5;189mS\033[38;5;189m#\033[0m");
    $display("\033[38;5;61mA\033[38;5;61mA\033[38;5;60ms\033[38;5;61mA\033[38;5;61m2\033[38;5;98m5\033[38;5;104m3\033[38;5;62m5\033[38;5;61m2\033[38;5;60mX\033[38;5;61mA\033[38;5;104mh\033[38;5;147mH\033[38;5;147mM\033[38;5;147mH\033[38;5;147mM\033[38;5;141mM\033[38;5;141mM\033[38;5;140mh\033[38;5;97m5\033[38;5;97m2\033[38;5;97m2\033[38;5;97m5\033[38;5;97m2\033[38;5;97m2\033[38;5;97m2\033[38;5;97m2\033[38;5;97m2\033[38;5;97m2\033[38;5;97m2\033[38;5;96mA\033[38;5;60ms\033[38;5;53mr\033[38;5;53mi\033[38;5;53mi\033[38;5;53mi\033[38;5;53mi\033[38;5;236m;\033[38;5;235m;\033[38;5;17m:\033[38;5;17m,\033[38;5;17m,\033[38;5;17m,\033[38;5;17m:\033[38;5;17m:\033[38;5;17m:\033[38;5;235m:\033[38;5;53m;\033[38;5;60ms\033[38;5;97m2\033[38;5;104mh\033[38;5;147mH\033[38;5;189mS\033[38;5;189m#\033[38;5;147mG\033[38;5;147mG\033[38;5;147mG\033[38;5;147mG\033[38;5;146mM\033[38;5;104mh\033[38;5;104mh\033[38;5;104m3\033[38;5;104m3\033[38;5;147mH\033[38;5;140mh\033[38;5;236mi\033[38;5;236mi\033[38;5;61mA\033[38;5;60mX\033[38;5;53mi\033[38;5;53mi\033[38;5;236m;\033[38;5;236mi\033[38;5;237mi\033[38;5;237mi\033[38;5;60mX\033[38;5;140mM\033[38;5;153mS\033[38;5;147mG\033[38;5;147mG\033[0m");
    $display("\033[38;5;54mr\033[38;5;60ms\033[38;5;98m5\033[38;5;61m2\033[38;5;61mA\033[38;5;62m2\033[38;5;104mh\033[38;5;141mM\033[38;5;147mM\033[38;5;61m2\033[38;5;60mX\033[38;5;104m3\033[38;5;105mM\033[38;5;104mh\033[38;5;105mh\033[38;5;147mG\033[38;5;147mG\033[38;5;183mS\033[38;5;147mH\033[38;5;104m3\033[38;5;104m3\033[38;5;134m3\033[38;5;97m2\033[38;5;97m2\033[38;5;97m2\033[38;5;97m2\033[38;5;97m2\033[38;5;97m2\033[38;5;97mA\033[38;5;53mr\033[38;5;234m:\033[38;5;233m.\033[38;5;232m.\033[38;5;233m,\033[38;5;234m:\033[38;5;234m:\033[38;5;234m:\033[38;5;234m,\033[38;5;233m.\033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;233m.\033[38;5;233m,\033[38;5;234m,\033[38;5;234m:\033[38;5;236mi\033[38;5;61mA\033[38;5;147mH\033[38;5;147mG\033[38;5;147mG\033[38;5;147mM\033[38;5;104m3\033[38;5;104mh\033[38;5;140mM\033[38;5;104mh\033[38;5;98m5\033[38;5;104m3\033[38;5;104mh\033[38;5;104m3\033[38;5;97m2\033[38;5;97m2\033[38;5;140mh\033[38;5;147mG\033[38;5;104mh\033[38;5;60ms\033[38;5;60mr\033[38;5;53mi\033[38;5;235m:\033[38;5;235m;\033[38;5;53mi\033[38;5;53mi\033[38;5;60ms\033[38;5;104m5\033[38;5;147mH\033[38;5;147mG\033[0m");
    $display("\033[38;5;60mr\033[38;5;54mr\033[38;5;60mX\033[38;5;98m5\033[38;5;104m3\033[38;5;104m3\033[38;5;105mM\033[38;5;61m2\033[38;5;60ms\033[38;5;60mX\033[38;5;60ms\033[38;5;61mA\033[38;5;62m5\033[38;5;98m5\033[38;5;105mh\033[38;5;147mG\033[38;5;189mS\033[38;5;183mS\033[38;5;189mS\033[38;5;183mS\033[38;5;141mM\033[38;5;141mM\033[38;5;104m3\033[38;5;60ms\033[38;5;96mA\033[38;5;96mA\033[38;5;96mA\033[38;5;53mr\033[38;5;233m,\033[38;5;16m \033[38;5;233m.\033[38;5;234m,\033[38;5;235m:\033[38;5;235m:\033[38;5;235m:\033[38;5;235m:\033[38;5;234m:\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;236mi\033[38;5;237mr\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;234m,\033[38;5;234m:\033[38;5;233m,\033[38;5;232m.\033[38;5;235m;\033[38;5;60mX\033[38;5;98m5\033[38;5;98m5\033[38;5;104m3\033[38;5;141mM\033[38;5;140mh\033[38;5;140mM\033[38;5;97m2\033[38;5;104m3\033[38;5;103m5\033[38;5;237mi\033[38;5;237mr\033[38;5;140mM\033[38;5;147mH\033[38;5;103m5\033[38;5;60ms\033[38;5;236m;\033[38;5;235m;\033[38;5;235m:\033[38;5;234m,\033[38;5;234m:\033[38;5;235m:\033[38;5;53m;\033[38;5;53mi\033[38;5;53mi\033[38;5;60mX\033[38;5;97m5\033[0m");
    $display("\033[38;5;53mi\033[38;5;53mi\033[38;5;60ms\033[38;5;97m2\033[38;5;61mA\033[38;5;60mX\033[38;5;97m5\033[38;5;61mA\033[38;5;236m;\033[38;5;234m:\033[38;5;17m:\033[38;5;61mA\033[38;5;98m5\033[38;5;98m5\033[38;5;62m2\033[38;5;147mH\033[38;5;147mH\033[38;5;147mH\033[38;5;189m#\033[38;5;189m#\033[38;5;147mG\033[38;5;61mA\033[38;5;60mX\033[38;5;53mi\033[38;5;60mr\033[38;5;60ms\033[38;5;235m:\033[38;5;16m \033[38;5;16m \033[38;5;234m:\033[38;5;235m;\033[38;5;235m;\033[38;5;235m:\033[38;5;234m:\033[38;5;235m;\033[38;5;235m;\033[38;5;233m,\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;236mi\033[38;5;95mA\033[38;5;233m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;233m,\033[38;5;234m:\033[38;5;234m,\033[38;5;233m,\033[38;5;232m.\033[38;5;16m \033[38;5;233m,\033[38;5;53mr\033[38;5;97mA\033[38;5;97mA\033[38;5;61mX\033[38;5;61mX\033[38;5;60mX\033[38;5;60mX\033[38;5;237mi\033[38;5;60mX\033[38;5;60mX\033[38;5;97m2\033[38;5;104mh\033[38;5;60mX\033[38;5;236m;\033[38;5;235m:\033[38;5;234m:\033[38;5;234m:\033[38;5;234m:\033[38;5;233m,\033[38;5;234m,\033[38;5;53m:\033[38;5;53m;\033[38;5;53m;\033[38;5;53m;\033[38;5;53m;\033[0m");
    $display("\033[38;5;53mi\033[38;5;53mi\033[38;5;54mr\033[38;5;60ms\033[38;5;54mr\033[38;5;60ms\033[38;5;61m2\033[38;5;97m2\033[38;5;54mr\033[38;5;53m;\033[38;5;234m:\033[38;5;68m5\033[38;5;105mM\033[38;5;98m5\033[38;5;54mi\033[38;5;61mA\033[38;5;105mh\033[38;5;189mS\033[38;5;183mS\033[38;5;147mH\033[38;5;141mM\033[38;5;104m3\033[38;5;60mX\033[38;5;60ms\033[38;5;53mi\033[38;5;232m.\033[38;5;16m \033[38;5;232m.\033[38;5;234m,\033[38;5;235m;\033[38;5;235m:\033[38;5;234m:\033[38;5;234m:\033[38;5;236m;\033[38;5;235m;\033[38;5;234m:\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;233m.\033[38;5;235m;\033[38;5;95mA\033[38;5;236mi\033[38;5;16m \033[38;5;232m.\033[38;5;233m.\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;232m.\033[38;5;232m.\033[38;5;233m.\033[38;5;233m,\033[38;5;16m \033[38;5;234m:\033[38;5;59mr\033[38;5;60ms\033[38;5;59mr\033[38;5;237mi\033[38;5;237mi\033[38;5;61mA\033[38;5;97m2\033[38;5;60mX\033[38;5;60mX\033[38;5;60mA\033[38;5;60mX\033[38;5;60mX\033[38;5;237mi\033[38;5;235m;\033[38;5;60ms\033[38;5;60mX\033[38;5;53mr\033[38;5;53m:\033[38;5;234m:\033[38;5;234m:\033[38;5;234m:\033[38;5;235m:\033[38;5;53m;\033[0m");
    $display("\033[38;5;54mr\033[38;5;60ms\033[38;5;54mr\033[38;5;54mr\033[38;5;54mi\033[38;5;60mr\033[38;5;97m2\033[38;5;61m2\033[38;5;60ms\033[38;5;60mr\033[38;5;237mi\033[38;5;104mh\033[38;5;147mH\033[38;5;104mh\033[38;5;62m5\033[38;5;147mH\033[38;5;147mG\033[38;5;147mH\033[38;5;147mH\033[38;5;147mH\033[38;5;104m3\033[38;5;141mM\033[38;5;98m3\033[38;5;236m;\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m.\033[38;5;234m:\033[38;5;234m,\033[38;5;234m:\033[38;5;235m:\033[38;5;234m:\033[38;5;234m,\033[38;5;234m:\033[38;5;233m,\033[38;5;232m.\033[38;5;233m.\033[38;5;233m.\033[38;5;233m,\033[38;5;233m,\033[38;5;235m;\033[38;5;239ms\033[38;5;237mi\033[38;5;233m.\033[38;5;232m.\033[38;5;233m.\033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;233m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;232m.\033[38;5;235m;\033[38;5;235m;\033[38;5;234m:\033[38;5;237mi\033[38;5;61mX\033[38;5;60mX\033[38;5;61mA\033[38;5;60ms\033[38;5;60mX\033[38;5;60ms\033[38;5;60mX\033[38;5;60ms\033[38;5;235m;\033[38;5;60ms\033[38;5;97m2\033[38;5;60mX\033[38;5;53mi\033[38;5;53m;\033[38;5;53m:\033[38;5;234m:\033[38;5;53m:\033[38;5;53m;\033[0m");
    $display("\033[38;5;53mi\033[38;5;53mi\033[38;5;53mr\033[38;5;54mr\033[38;5;53mi\033[38;5;53mi\033[38;5;60ms\033[38;5;97m5\033[38;5;147mM\033[38;5;104m3\033[38;5;53mi\033[38;5;97m5\033[38;5;147mH\033[38;5;147mH\033[38;5;105mh\033[38;5;147mG\033[38;5;147mH\033[38;5;141mh\033[38;5;147mH\033[38;5;141mM\033[38;5;97m2\033[38;5;97m2\033[38;5;237mi\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;233m,\033[38;5;233m,\033[38;5;16m \033[38;5;234m,\033[38;5;234m:\033[38;5;234m:\033[38;5;235m;\033[38;5;235m:\033[38;5;236m;\033[38;5;238mr\033[38;5;240mX\033[38;5;101m5\033[38;5;138mM\033[38;5;138m3\033[38;5;95m5\033[38;5;95m2\033[38;5;59mA\033[38;5;238mr\033[38;5;235m:\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;234m:\033[38;5;235m:\033[38;5;236m;\033[38;5;237mi\033[38;5;60ms\033[38;5;59mr\033[38;5;60mX\033[38;5;60ms\033[38;5;61mX\033[38;5;104m5\033[38;5;60mX\033[38;5;237mr\033[38;5;60mr\033[38;5;60ms\033[38;5;53mi\033[38;5;53m;\033[38;5;53m;\033[38;5;53m;\033[38;5;53m:\033[38;5;235m:\033[38;5;53m;\033[0m");
    $display("\033[38;5;53mi\033[38;5;53mi\033[38;5;53mi\033[38;5;53mi\033[38;5;53mr\033[38;5;53mi\033[38;5;60mX\033[38;5;104m3\033[38;5;97m2\033[38;5;60ms\033[38;5;53mi\033[38;5;60ms\033[38;5;98m5\033[38;5;98m5\033[38;5;98m5\033[38;5;141mh\033[38;5;104m3\033[38;5;140mh\033[38;5;98m3\033[38;5;97m2\033[38;5;97mA\033[38;5;53mi\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;232m.\033[38;5;235m;\033[38;5;236m;\033[38;5;237mi\033[38;5;237mr\033[38;5;237mr\033[38;5;101m5\033[38;5;180mH\033[38;5;223m#\033[38;5;223m9\033[38;5;223m9\033[38;5;223m9\033[38;5;223m9\033[38;5;223m9\033[38;5;223m9\033[38;5;223m#\033[38;5;216mS\033[38;5;137mh\033[38;5;237mr\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;235m:\033[38;5;60mr\033[38;5;60mX\033[38;5;60ms\033[38;5;235m:\033[38;5;236m;\033[38;5;237mi\033[38;5;60mr\033[38;5;60mA\033[38;5;60ms\033[38;5;53mi\033[38;5;234m:\033[38;5;234m:\033[38;5;234m:\033[38;5;233m,\033[38;5;233m,\033[38;5;234m:\033[38;5;53m;\033[38;5;235m;\033[38;5;53m;\033[0m");
    $display("\033[38;5;53m;\033[38;5;53m;\033[38;5;53m;\033[38;5;53mi\033[38;5;53mi\033[38;5;53m;\033[38;5;53m;\033[38;5;53mi\033[38;5;17m,\033[38;5;53m:\033[38;5;53m;\033[38;5;53m;\033[38;5;54m;\033[38;5;54mi\033[38;5;60ms\033[38;5;97mA\033[38;5;97m2\033[38;5;97mA\033[38;5;97mA\033[38;5;96mX\033[38;5;53mi\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;234m:\033[38;5;234m:\033[38;5;237mr\033[38;5;235m;\033[38;5;95m2\033[38;5;187mS\033[38;5;223m9\033[38;5;230m9\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;230m9\033[38;5;224m9\033[38;5;223m9\033[38;5;223m9\033[38;5;223m#\033[38;5;223m#\033[38;5;216mS\033[38;5;238mr\033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;235m;\033[38;5;236mi\033[38;5;235m;\033[38;5;235m:\033[38;5;234m:\033[38;5;234m,\033[38;5;233m,\033[38;5;232m.\033[38;5;233m.\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;234m,\033[38;5;234m:\033[38;5;234m:\033[38;5;234m:\033[0m");
    $display("\033[38;5;53mi\033[38;5;53m;\033[38;5;53m;\033[38;5;53m;\033[38;5;53m;\033[38;5;53m;\033[38;5;53m;\033[38;5;53m;\033[38;5;53m;\033[38;5;53m;\033[38;5;53m;\033[38;5;53m:\033[38;5;53m;\033[38;5;53mi\033[38;5;54mr\033[38;5;60mX\033[38;5;97mA\033[38;5;97mA\033[38;5;97m2\033[38;5;60ms\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;235m;\033[38;5;237mi\033[38;5;239ms\033[38;5;181mG\033[38;5;223m#\033[38;5;224m9\033[38;5;230m9\033[38;5;230mB\033[38;5;230mB\033[38;5;230m9\033[38;5;230m9\033[38;5;224m9\033[38;5;223m9\033[38;5;223m9\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;180mH\033[38;5;234m:\033[38;5;233m,\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;235m:\033[38;5;234m:\033[38;5;234m:\033[38;5;234m,\033[38;5;17m,\033[38;5;17m,\033[38;5;17m,\033[38;5;234m,\033[38;5;234m:\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;234m:\033[38;5;235m:\033[38;5;234m:\033[0m");
    $display("\033[38;5;53mi\033[38;5;53m;\033[38;5;53m;\033[38;5;53m;\033[38;5;53mi\033[38;5;53mi\033[38;5;53mi\033[38;5;53mr\033[38;5;54mr\033[38;5;54mr\033[38;5;54mi\033[38;5;53mi\033[38;5;53mi\033[38;5;53mi\033[38;5;54ms\033[38;5;97mX\033[38;5;97mA\033[38;5;97m2\033[38;5;96mA\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m.\033[38;5;240mX\033[38;5;238mr\033[38;5;180mH\033[38;5;223m#\033[38;5;224m9\033[38;5;224m9\033[38;5;230m9\033[38;5;230m9\033[38;5;230m9\033[38;5;230m9\033[38;5;230m9\033[38;5;230m9\033[38;5;230m9\033[38;5;230m9\033[38;5;230m9\033[38;5;224m9\033[38;5;223m9\033[38;5;223m9\033[38;5;95m2\033[38;5;233m,\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;53m;\033[38;5;235m:\033[38;5;234m:\033[38;5;234m:\033[38;5;234m:\033[38;5;234m:\033[38;5;235m:\033[38;5;234m:\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;234m:\033[38;5;234m:\033[38;5;235m;\033[38;5;235m;\033[0m");
    $display("\033[38;5;53mi\033[38;5;53mi\033[38;5;53mi\033[38;5;53mi\033[38;5;54mr\033[38;5;90mr\033[38;5;90mr\033[38;5;90ms\033[38;5;90ms\033[38;5;90mX\033[38;5;96mX\033[38;5;90ms\033[38;5;54mr\033[38;5;53mi\033[38;5;54mr\033[38;5;96mX\033[38;5;97mA\033[38;5;97m2\033[38;5;235m:\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;237mr\033[38;5;239ms\033[38;5;59mX\033[38;5;181mG\033[38;5;223m#\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;223m#\033[38;5;187mS\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;180mG\033[38;5;138mh\033[38;5;233m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;235m;\033[38;5;53m;\033[38;5;234m:\033[38;5;53m:\033[38;5;53m;\033[38;5;53m;\033[38;5;235m;\033[38;5;235m:\033[38;5;234m:\033[38;5;234m:\033[38;5;234m:\033[38;5;234m:\033[38;5;235m:\033[38;5;235m;\033[38;5;235m:\033[38;5;234m:\033[38;5;235m;\033[0m");
    $display("\033[38;5;54mr\033[38;5;90ms\033[38;5;90ms\033[38;5;90ms\033[38;5;90ms\033[38;5;90ms\033[38;5;90ms\033[38;5;91mX\033[38;5;97mA\033[38;5;97mA\033[38;5;96mX\033[38;5;90ms\033[38;5;54mr\033[38;5;54mr\033[38;5;54mr\033[38;5;96mX\033[38;5;97m2\033[38;5;60ms\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;234m:\033[38;5;238mr\033[38;5;235m;\033[38;5;59mX\033[38;5;132m5\033[38;5;138m3\033[38;5;174mM\033[38;5;217mS\033[38;5;224m#\033[38;5;224m9\033[38;5;224m#\033[38;5;224m#\033[38;5;223m#\033[38;5;181mG\033[38;5;138mh\033[38;5;138m3\033[38;5;138mh\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mM\033[38;5;235m;\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;53m;\033[38;5;53m:\033[38;5;53m;\033[38;5;53m;\033[38;5;53m;\033[38;5;53mi\033[38;5;53mi\033[38;5;53mi\033[38;5;53m;\033[38;5;234m:\033[38;5;234m:\033[38;5;234m:\033[38;5;234m:\033[38;5;235m:\033[38;5;234m:\033[38;5;234m:\033[0m");
    $display("\033[38;5;54mr\033[38;5;90ms\033[38;5;90mX\033[38;5;90mX\033[38;5;97mX\033[38;5;91mX\033[38;5;97mX\033[38;5;133mA\033[38;5;133mA\033[38;5;97mX\033[38;5;90ms\033[38;5;54mi\033[38;5;54mi\033[38;5;54mr\033[38;5;96mX\033[38;5;96mX\033[38;5;96mA\033[38;5;235m;\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;238mr\033[38;5;95mA\033[38;5;238ms\033[38;5;138m5\033[38;5;181mM\033[38;5;174mM\033[38;5;174mM\033[38;5;174mM\033[38;5;181mG\033[38;5;224m#\033[38;5;224m#\033[38;5;223m#\033[38;5;181mG\033[38;5;181mH\033[38;5;181mH\033[38;5;174mM\033[38;5;96m5\033[38;5;95m2\033[38;5;95mA\033[38;5;138m3\033[38;5;138mh\033[38;5;237mi\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;53m;\033[38;5;53mr\033[38;5;53mr\033[38;5;53mr\033[38;5;60ms\033[38;5;60ms\033[38;5;60ms\033[38;5;53mr\033[38;5;53mi\033[38;5;53mi\033[38;5;53mi\033[38;5;53mr\033[38;5;53mr\033[38;5;53mi\033[38;5;236mi\033[38;5;236m;\033[0m");
    $display("\033[38;5;53mi\033[38;5;53mr\033[38;5;90ms\033[38;5;90ms\033[38;5;90ms\033[38;5;90mX\033[38;5;91mX\033[38;5;133mA\033[38;5;97mX\033[38;5;90ms\033[38;5;54mi\033[38;5;53mi\033[38;5;54mi\033[38;5;54ms\033[38;5;96mX\033[38;5;96mX\033[38;5;53mr\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;238mr\033[38;5;241mA\033[38;5;234m:\033[38;5;235m;\033[38;5;59mA\033[38;5;138mh\033[38;5;181mH\033[38;5;181mH\033[38;5;223m#\033[38;5;224m9\033[38;5;223m#\033[38;5;217mS\033[38;5;181mS\033[38;5;138mh\033[38;5;181mH\033[38;5;242m2\033[38;5;235m;\033[38;5;238mr\033[38;5;95mA\033[38;5;238ms\033[38;5;95mX\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;235m:\033[38;5;96mX\033[38;5;96mX\033[38;5;96mX\033[38;5;96mX\033[38;5;96mX\033[38;5;96mX\033[38;5;96mX\033[38;5;96mA\033[38;5;97mA\033[38;5;97m2\033[38;5;97m2\033[38;5;97mA\033[38;5;96mX\033[38;5;60mX\033[38;5;238mr\033[0m");
    $display("\033[38;5;53mi\033[38;5;53mi\033[38;5;53mr\033[38;5;89mr\033[38;5;90mr\033[38;5;90ms\033[38;5;90mX\033[38;5;96mX\033[38;5;96mX\033[38;5;90ms\033[38;5;53mi\033[38;5;54mi\033[38;5;54ms\033[38;5;90ms\033[38;5;96mX\033[38;5;96mX\033[38;5;235m:\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;239ms\033[38;5;95m2\033[38;5;138mh\033[38;5;181mH\033[38;5;138mh\033[38;5;138mM\033[38;5;181mG\033[38;5;181mG\033[38;5;223mS\033[38;5;181mG\033[38;5;223mS\033[38;5;230mB\033[38;5;224m9\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223mS\033[38;5;217mS\033[38;5;181mG\033[38;5;217mS\033[38;5;217mS\033[38;5;223m#\033[38;5;223m#\033[38;5;131m5\033[38;5;232m.\033[38;5;233m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;53mr\033[38;5;60ms\033[38;5;60ms\033[38;5;96mX\033[38;5;96mX\033[38;5;96mX\033[38;5;96ms\033[38;5;96mX\033[38;5;96mX\033[38;5;96mX\033[38;5;59ms\033[38;5;59mr\033[38;5;53mr\033[38;5;236mi\033[38;5;235m;\033[0m");
    $display("\033[38;5;53m;\033[38;5;53m;\033[38;5;53mi\033[38;5;53mi\033[38;5;53mi\033[38;5;89mr\033[38;5;90ms\033[38;5;90ms\033[38;5;90ms\033[38;5;54mr\033[38;5;54mi\033[38;5;54mr\033[38;5;54ms\033[38;5;90ms\033[38;5;96ms\033[38;5;90ms\033[38;5;235m;\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m.\033[38;5;16m \033[38;5;237mr\033[38;5;217mS\033[38;5;223m#\033[38;5;223m#\033[38;5;223mS\033[38;5;224m#\033[38;5;224m#\033[38;5;224m#\033[38;5;223m#\033[38;5;223m#\033[38;5;181mG\033[38;5;223mS\033[38;5;230mB\033[38;5;224m9\033[38;5;223m#\033[38;5;223m#\033[38;5;230m9\033[38;5;230m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m#\033[38;5;223m#\033[38;5;217mS\033[38;5;238mr\033[38;5;16m \033[38;5;233m,\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;235m;\033[38;5;60ms\033[38;5;59ms\033[38;5;59ms\033[38;5;59ms\033[38;5;59ms\033[38;5;59ms\033[38;5;59ms\033[38;5;59ms\033[38;5;59ms\033[38;5;237mr\033[38;5;235m;\033[38;5;234m:\033[38;5;234m,\033[38;5;233m,\033[0m");
    $display("\033[38;5;53mr\033[38;5;90ms\033[38;5;90ms\033[38;5;89mr\033[38;5;89mr\033[38;5;89ms\033[38;5;89mr\033[38;5;53mi\033[38;5;53mi\033[38;5;53m;\033[38;5;53m;\033[38;5;53m;\033[38;5;53mi\033[38;5;53mr\033[38;5;90ms\033[38;5;96ms\033[38;5;236m;\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;234m,\033[38;5;233m,\033[38;5;132m5\033[38;5;217mG\033[38;5;217mS\033[38;5;224m#\033[38;5;224m#\033[38;5;224m#\033[38;5;224m#\033[38;5;224m#\033[38;5;223m#\033[38;5;217mS\033[38;5;180mH\033[38;5;223mS\033[38;5;230mB\033[38;5;224m9\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m#\033[38;5;224m#\033[38;5;223m#\033[38;5;217mS\033[38;5;174mH\033[38;5;237mi\033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;233m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m.\033[38;5;53mr\033[38;5;59ms\033[38;5;59ms\033[38;5;59ms\033[38;5;239ms\033[38;5;59ms\033[38;5;95mX\033[38;5;95mX\033[38;5;59ms\033[38;5;237mr\033[38;5;235m;\033[38;5;234m:\033[38;5;234m:\033[38;5;234m,\033[0m");
    $display("\033[38;5;133m2\033[38;5;134m5\033[38;5;170m3\033[38;5;170m3\033[38;5;170m3\033[38;5;134m3\033[38;5;133m2\033[38;5;96mX\033[38;5;90ms\033[38;5;53mr\033[38;5;53m;\033[38;5;53m:\033[38;5;53m;\033[38;5;53mi\033[38;5;54ms\033[38;5;96mX\033[38;5;53mi\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;234m,\033[38;5;234m:\033[38;5;233m,\033[38;5;95mX\033[38;5;174mh\033[38;5;217mG\033[38;5;223m#\033[38;5;224m#\033[38;5;224m#\033[38;5;224m#\033[38;5;224m#\033[38;5;181mG\033[38;5;180mH\033[38;5;174mM\033[38;5;180mH\033[38;5;224m#\033[38;5;223mS\033[38;5;180mH\033[38;5;181mG\033[38;5;223mS\033[38;5;224m#\033[38;5;224m#\033[38;5;224m#\033[38;5;224m#\033[38;5;224m#\033[38;5;223m#\033[38;5;181mH\033[38;5;132m5\033[38;5;233m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;53mi\033[38;5;59ms\033[38;5;59ms\033[38;5;59ms\033[38;5;237mr\033[38;5;237mr\033[38;5;238ms\033[38;5;238ms\033[38;5;236mi\033[38;5;233m,\033[38;5;232m.\033[38;5;233m,\033[38;5;234m,\033[38;5;234m:\033[0m");
    $display("\033[38;5;133mA\033[38;5;134m5\033[38;5;170m3\033[38;5;170m3\033[38;5;170m3\033[38;5;170mh\033[38;5;170mh\033[38;5;169m5\033[38;5;133m2\033[38;5;133m2\033[38;5;96mA\033[38;5;53mr\033[38;5;53m:\033[38;5;53m;\033[38;5;53mi\033[38;5;53mr\033[38;5;53mi\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;234m:\033[38;5;16m \033[38;5;16m \033[38;5;237mr\033[38;5;95mA\033[38;5;138mh\033[38;5;181mH\033[38;5;217mS\033[38;5;223mS\033[38;5;223m#\033[38;5;223mS\033[38;5;181mG\033[38;5;138m3\033[38;5;132m5\033[38;5;132m5\033[38;5;138m3\033[38;5;138mh\033[38;5;138mh\033[38;5;181mH\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;224m#\033[38;5;224m#\033[38;5;217mS\033[38;5;181mH\033[38;5;138mh\033[38;5;238mr\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;234m:\033[38;5;53mi\033[38;5;53m;\033[38;5;53m;\033[38;5;235m;\033[38;5;235m;\033[38;5;235m:\033[38;5;233m,\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;233m.\033[38;5;233m.\033[0m");
    $display("\033[38;5;132mA\033[38;5;133m2\033[38;5;133m5\033[38;5;133m2\033[38;5;133m5\033[38;5;170m3\033[38;5;170mh\033[38;5;170mh\033[38;5;169m3\033[38;5;169m3\033[38;5;169mh\033[38;5;133m3\033[38;5;96mX\033[38;5;53mi\033[38;5;53m;\033[38;5;53mi\033[38;5;235m;\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;234m:\033[38;5;239ms\033[38;5;95m2\033[38;5;132m3\033[38;5;175mM\033[38;5;181mG\033[38;5;181mG\033[38;5;181mS\033[38;5;223m#\033[38;5;181mG\033[38;5;174mM\033[38;5;174mM\033[38;5;174mM\033[38;5;217mG\033[38;5;223mS\033[38;5;223m#\033[38;5;223m9\033[38;5;223m#\033[38;5;223m#\033[38;5;217mS\033[38;5;181mG\033[38;5;181mH\033[38;5;138mh\033[38;5;95m2\033[38;5;233m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;235m;\033[38;5;53mi\033[38;5;235m:\033[38;5;233m,\033[38;5;232m.\033[38;5;233m.\033[38;5;234m,\033[38;5;233m,\033[38;5;232m.\033[38;5;232m.\033[38;5;234m:\033[38;5;236m;\033[38;5;53mi\033[38;5;53mi\033[0m");
    $display("\033[38;5;133m3\033[38;5;134m3\033[38;5;134m3\033[38;5;133m5\033[38;5;133m5\033[38;5;133m5\033[38;5;169m3\033[38;5;170mh\033[38;5;176mh\033[38;5;176mh\033[38;5;176mM\033[38;5;176mH\033[38;5;169m3\033[38;5;96mX\033[38;5;53mi\033[38;5;53m;\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;234m:\033[38;5;239ms\033[38;5;95mA\033[38;5;138m3\033[38;5;180mM\033[38;5;174mM\033[38;5;95m2\033[38;5;238mr\033[38;5;237mr\033[38;5;238ms\033[38;5;95mX\033[38;5;95mX\033[38;5;89ms\033[38;5;53mr\033[38;5;236mi\033[38;5;238mr\033[38;5;138m5\033[38;5;181mH\033[38;5;181mG\033[38;5;181mG\033[38;5;174mM\033[38;5;95m2\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;236m;\033[38;5;59ms\033[38;5;239ms\033[38;5;237mi\033[38;5;234m:\033[38;5;233m.\033[38;5;233m,\033[38;5;234m,\033[38;5;233m,\033[38;5;238mr\033[38;5;97m5\033[38;5;139m3\033[38;5;133m3\033[38;5;133m5\033[0m");
    $display("\033[38;5;134m3\033[38;5;134m3\033[38;5;133m2\033[38;5;133m2\033[38;5;133m5\033[38;5;169m3\033[38;5;169m3\033[38;5;133m5\033[38;5;133m5\033[38;5;169m3\033[38;5;170mh\033[38;5;133m3\033[38;5;132m2\033[38;5;95ms\033[38;5;53m;\033[38;5;235m;\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;237mr\033[38;5;95mA\033[38;5;138mh\033[38;5;180mH\033[38;5;138mh\033[38;5;95mX\033[38;5;89ms\033[38;5;95mX\033[38;5;131m2\033[38;5;95m2\033[38;5;95m2\033[38;5;131m2\033[38;5;131m2\033[38;5;131m5\033[38;5;180mH\033[38;5;181mG\033[38;5;181mH\033[38;5;138mh\033[38;5;239ms\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;233m,\033[38;5;235m;\033[38;5;238mr\033[38;5;239ms\033[38;5;59mX\033[38;5;59ms\033[38;5;236mi\033[38;5;233m,\033[38;5;233m,\033[38;5;53mi\033[38;5;97m2\033[38;5;139mh\033[38;5;139m3\033[38;5;133m5\033[38;5;132m2\033[0m");
    $display("\033[38;5;133m5\033[38;5;132mA\033[38;5;96mA\033[38;5;133m5\033[38;5;176mh\033[38;5;176mM\033[38;5;176mh\033[38;5;133m5\033[38;5;133m2\033[38;5;133m5\033[38;5;132m5\033[38;5;132m2\033[38;5;96mA\033[38;5;95ms\033[38;5;53mi\033[38;5;53m;\033[38;5;234m:\033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;235m;\033[38;5;59mX\033[38;5;138m3\033[38;5;180mH\033[38;5;180mH\033[38;5;181mH\033[38;5;224mS\033[38;5;182mS\033[38;5;188mS\033[38;5;253m#\033[38;5;225m9\033[38;5;225m9\033[38;5;224m#\033[38;5;181mG\033[38;5;180mH\033[38;5;131m5\033[38;5;235m;\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;237mi\033[38;5;174mh\033[38;5;181mG\033[38;5;95mA\033[38;5;236m;\033[38;5;95mX\033[38;5;238mr\033[38;5;237mr\033[38;5;59ms\033[38;5;59mX\033[38;5;59ms\033[38;5;60mX\033[38;5;97m2\033[38;5;133m3\033[38;5;133m3\033[38;5;133m5\033[38;5;96mA\033[38;5;96mA\033[0m");
    $display("\033[38;5;96mA\033[38;5;96mX\033[38;5;133m2\033[38;5;169m3\033[38;5;170m3\033[38;5;169m3\033[38;5;169mh\033[38;5;169m3\033[38;5;132m2\033[38;5;95mX\033[38;5;95ms\033[38;5;95ms\033[38;5;96mX\033[38;5;132m2\033[38;5;133m2\033[38;5;59ms\033[38;5;235m;\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;236mi\033[38;5;95mX\033[38;5;138mh\033[38;5;225m#\033[38;5;188mS\033[38;5;182mG\033[38;5;188m#\033[38;5;225m9\033[38;5;225m9\033[38;5;225m9\033[38;5;225m9\033[38;5;182mS\033[38;5;95mX\033[38;5;235m;\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;234m,\033[38;5;234m:\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;132m3\033[38;5;174mM\033[38;5;174mM\033[38;5;237mi\033[38;5;234m:\033[38;5;95ms\033[38;5;53mr\033[38;5;235m;\033[38;5;235m;\033[38;5;237mr\033[38;5;59ms\033[38;5;96mX\033[38;5;60mX\033[38;5;96mA\033[38;5;96m2\033[38;5;96m2\033[38;5;96mA\033[38;5;96mA\033[0m");
    $display("\033[38;5;96mX\033[38;5;132mA\033[38;5;133m5\033[38;5;176mh\033[38;5;176mh\033[38;5;175mh\033[38;5;175mh\033[38;5;176mM\033[38;5;175mh\033[38;5;133m5\033[38;5;132mA\033[38;5;132m2\033[38;5;132m5\033[38;5;132m5\033[38;5;132m2\033[38;5;59ms\033[38;5;235m;\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;233m,\033[38;5;233m.\033[38;5;16m \033[38;5;233m.\033[38;5;233m,\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;238mr\033[38;5;181mH\033[38;5;224m9\033[38;5;224m9\033[38;5;230m9\033[38;5;230m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;225m9\033[38;5;225m#\033[38;5;95mX\033[38;5;235m:\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;237mi\033[38;5;181mH\033[38;5;224mS\033[38;5;181mH\033[38;5;95mA\033[38;5;236m;\033[38;5;232m.\033[38;5;234m:\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;138mM\033[38;5;233m.\033[38;5;234m:\033[38;5;53mr\033[38;5;236mi\033[38;5;234m:\033[38;5;234m:\033[38;5;235m;\033[38;5;236mi\033[38;5;235m;\033[38;5;236mi\033[38;5;96mA\033[38;5;139m3\033[38;5;139mh\033[38;5;139m3\033[0m");
    $display("\033[38;5;53mi\033[38;5;53mr\033[38;5;95ms\033[38;5;95mX\033[38;5;96mA\033[38;5;132m2\033[38;5;132m5\033[38;5;133m3\033[38;5;133m3\033[38;5;132m5\033[38;5;132m5\033[38;5;132m3\033[38;5;132m2\033[38;5;95ms\033[38;5;53mi\033[38;5;53mi\033[38;5;234m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;233m,\033[38;5;233m,\033[38;5;16m \033[38;5;233m,\033[38;5;234m:\033[38;5;235m:\033[38;5;233m,\033[38;5;233m,\033[38;5;246mh\033[38;5;224m#\033[38;5;224m9\033[38;5;224m#\033[38;5;180mH\033[38;5;132m5\033[38;5;138mM\033[38;5;180mH\033[38;5;217mG\033[38;5;217mS\033[38;5;217mS\033[38;5;224m#\033[38;5;96m2\033[38;5;233m,\033[38;5;233m.\033[38;5;16m \033[38;5;16m \033[38;5;235m:\033[38;5;181mH\033[38;5;218mS\033[38;5;217mS\033[38;5;217mG\033[38;5;180mH\033[38;5;217mS\033[38;5;181mH\033[38;5;138m3\033[38;5;181mH\033[38;5;181mG\033[38;5;181mG\033[38;5;224mS\033[38;5;181mH\033[38;5;234m:\033[38;5;235m;\033[38;5;53mi\033[38;5;235m:\033[38;5;233m,\033[38;5;234m:\033[38;5;236mi\033[38;5;237mi\033[38;5;236mi\033[38;5;237mi\033[38;5;59mX\033[38;5;96mA\033[38;5;59mX\033[0m");
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;53mr\033[38;5;95mX\033[38;5;95mX\033[38;5;95mX\033[38;5;59ms\033[38;5;95mX\033[38;5;96mA\033[38;5;95ms\033[38;5;53mi\033[38;5;53m;\033[38;5;53m:\033[38;5;53m:\033[38;5;234m:\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;235m;\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;234m:\033[38;5;235m:\033[38;5;239ms\033[38;5;138mh\033[38;5;223m#\033[38;5;223m#\033[38;5;181mG\033[38;5;180mH\033[38;5;181mH\033[38;5;181mH\033[38;5;187mS\033[38;5;224m#\033[38;5;223m#\033[38;5;181mG\033[38;5;138mM\033[38;5;181mH\033[38;5;102m5\033[38;5;237mi\033[38;5;233m,\033[38;5;232m.\033[38;5;16m \033[38;5;235m;\033[38;5;132m5\033[38;5;181mH\033[38;5;224m9\033[38;5;224m9\033[38;5;224m#\033[38;5;224m9\033[38;5;224m9\033[38;5;181mH\033[38;5;181mM\033[38;5;181mS\033[38;5;224m#\033[38;5;224m#\033[38;5;230m9\033[38;5;59mX\033[38;5;16m \033[38;5;234m:\033[38;5;234m:\033[38;5;234m:\033[38;5;234m:\033[38;5;235m;\033[38;5;237mi\033[38;5;238mr\033[38;5;237mi\033[38;5;236m;\033[38;5;235m;\033[38;5;234m,\033[0m");
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;235m:\033[38;5;238mr\033[38;5;237mr\033[38;5;236mi\033[38;5;235m;\033[38;5;233m,\033[38;5;234m:\033[38;5;53m;\033[38;5;53m:\033[38;5;233m,\033[38;5;234m:\033[38;5;53m;\033[38;5;53m;\033[38;5;232m.\033[38;5;233m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;234m:\033[38;5;235m;\033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m.\033[38;5;234m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;235m;\033[38;5;187mS\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;230m9\033[38;5;230mB\033[38;5;224m9\033[38;5;223m#\033[38;5;181mG\033[38;5;187mS\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;180mH\033[38;5;237mi\033[38;5;232m.\033[38;5;16m \033[38;5;232m.\033[38;5;233m.\033[38;5;238ms\033[38;5;102m5\033[38;5;181mS\033[38;5;224m#\033[38;5;224m#\033[38;5;224m#\033[38;5;224m#\033[38;5;181mH\033[38;5;187mS\033[38;5;230m9\033[38;5;230m9\033[38;5;224m9\033[38;5;224m9\033[38;5;144mM\033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;234m:\033[38;5;234m:\033[38;5;234m:\033[38;5;235m;\033[38;5;236mi\033[38;5;237mr\033[38;5;237mr\033[38;5;237mr\033[38;5;236mi\033[0m");
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;233m.\033[38;5;233m,\033[38;5;16m \033[38;5;232m.\033[38;5;233m.\033[38;5;233m,\033[38;5;53m;\033[38;5;53mi\033[38;5;53m;\033[38;5;234m:\033[38;5;234m,\033[38;5;234m:\033[38;5;233m.\033[38;5;233m.\033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;235m;\033[38;5;233m,\033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;242m2\033[38;5;230mB\033[38;5;224m9\033[38;5;230m9\033[38;5;230mB\033[38;5;224m9\033[38;5;224m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;181mS\033[38;5;217mS\033[38;5;223mS\033[38;5;223mS\033[38;5;223mS\033[38;5;223mS\033[38;5;95m2\033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;233m.\033[38;5;237mr\033[38;5;59mX\033[38;5;187mS\033[38;5;224m9\033[38;5;224m9\033[38;5;230mB\033[38;5;230m9\033[38;5;224m#\033[38;5;224m#\033[38;5;230m9\033[38;5;230m9\033[38;5;224m9\033[38;5;224m9\033[38;5;181mM\033[38;5;16m \033[38;5;233m,\033[38;5;233m.\033[38;5;233m.\033[38;5;233m,\033[38;5;235m;\033[38;5;236mi\033[38;5;237mi\033[38;5;238mr\033[38;5;59ms\033[38;5;59mX\033[38;5;60mX\033[0m");
    $display("\033[38;5;59mX\033[38;5;237mr\033[38;5;236mi\033[38;5;235m;\033[38;5;235m;\033[38;5;236m;\033[38;5;235m;\033[38;5;53mi\033[38;5;53mr\033[38;5;53mr\033[38;5;53mi\033[38;5;233m,\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;233m.\033[38;5;234m:\033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;233m,\033[38;5;233m.\033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;233m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;239ms\033[38;5;187mS\033[38;5;224m9\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;224m9\033[38;5;253m#\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;223m#\033[38;5;224m#\033[38;5;224m9\033[38;5;224m#\033[38;5;223mS\033[38;5;174mH\033[38;5;236mi\033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;96m5\033[38;5;217mS\033[38;5;223m#\033[38;5;223m#\033[38;5;181mG\033[38;5;181mG\033[38;5;187mS\033[38;5;188m#\033[38;5;224m9\033[38;5;230m9\033[38;5;230mB\033[38;5;230mB\033[38;5;224m#\033[38;5;181mH\033[38;5;234m,\033[38;5;16m \033[38;5;236mi\033[38;5;237mi\033[38;5;238mr\033[38;5;235m:\033[38;5;234m:\033[38;5;236mi\033[38;5;237mr\033[38;5;238mr\033[38;5;238ms\033[38;5;59mX\033[0m");
    $display("\033[38;5;250mG\033[38;5;251mS\033[38;5;188m#\033[38;5;251mS\033[38;5;188m#\033[38;5;253m#\033[38;5;251mS\033[38;5;251mS\033[38;5;251mS\033[38;5;251mS\033[38;5;181mH\033[38;5;96m5\033[38;5;239ms\033[38;5;241mA\033[38;5;59mX\033[38;5;59ms\033[38;5;233m.\033[38;5;232m.\033[38;5;16m \033[38;5;233m.\033[38;5;232m.\033[38;5;16m \033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;233m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;102m5\033[38;5;224m9\033[38;5;230m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m#\033[38;5;224m#\033[38;5;224m9\033[38;5;223m#\033[38;5;223mS\033[38;5;217mS\033[38;5;217mS\033[38;5;174mM\033[38;5;138m3\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;239ms\033[38;5;138mM\033[38;5;223mS\033[38;5;224m#\033[38;5;224m#\033[38;5;223m#\033[38;5;187mS\033[38;5;223m#\033[38;5;224m9\033[38;5;224m9\033[38;5;230m9\033[38;5;181mS\033[38;5;181mG\033[38;5;241mA\033[38;5;239ms\033[38;5;243m2\033[38;5;247mM\033[38;5;246mh\033[38;5;239ms\033[38;5;240mX\033[38;5;236m;\033[38;5;234m,\033[38;5;234m:\033[38;5;235m:\033[38;5;235m;\033[0m");
    $display("\033[38;5;145mH\033[38;5;250mG\033[38;5;251mS\033[38;5;252m#\033[38;5;188m#\033[38;5;224m#\033[38;5;187m#\033[38;5;188m#\033[38;5;224m#\033[38;5;187mS\033[38;5;187mS\033[38;5;187m#\033[38;5;224m9\033[38;5;253m#\033[38;5;224m9\033[38;5;102m5\033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;59ms\033[38;5;224m#\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;181mS\033[38;5;139mM\033[38;5;240mX\033[38;5;239ms\033[38;5;59mX\033[38;5;241mA\033[38;5;181mG\033[38;5;181mH\033[38;5;174mM\033[38;5;138mh\033[38;5;239ms\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;234m:\033[38;5;239ms\033[38;5;138m3\033[38;5;181mG\033[38;5;252mS\033[38;5;224m#\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;181mG\033[38;5;181mG\033[38;5;181mH\033[38;5;239ms\033[38;5;240mX\033[38;5;102m5\033[38;5;236m;\033[38;5;237mr\033[38;5;102m3\033[38;5;243m5\033[38;5;236mi\033[38;5;234m:\033[38;5;233m,\033[38;5;235m:\033[0m");
    $display("\033[38;5;145mH\033[38;5;188m#\033[38;5;224m9\033[38;5;224m9\033[38;5;253m#\033[38;5;224m#\033[38;5;224m#\033[38;5;253m#\033[38;5;188m#\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;254m9\033[38;5;181mG\033[38;5;244m5\033[38;5;235m:\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;234m,\033[38;5;233m.\033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;235m;\033[38;5;139mh\033[38;5;181mS\033[38;5;223mS\033[38;5;217mS\033[38;5;217mG\033[38;5;96m2\033[38;5;182mH\033[38;5;237mr\033[38;5;234m:\033[38;5;238mr\033[38;5;234m:\033[38;5;253m#\033[38;5;225m#\033[38;5;138mh\033[38;5;95m2\033[38;5;237mi\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m.\033[38;5;96m5\033[38;5;138m3\033[38;5;139mh\033[38;5;181mH\033[38;5;181mG\033[38;5;181mH\033[38;5;145mH\033[38;5;251mS\033[38;5;224m#\033[38;5;240mX\033[38;5;16m \033[38;5;16m \033[38;5;235m;\033[38;5;241mA\033[38;5;59mA\033[38;5;239ms\033[38;5;243m5\033[38;5;95m2\033[38;5;234m:\033[38;5;233m.\033[0m");
    $display("\033[38;5;139mh\033[38;5;241mA\033[38;5;236mi\033[38;5;239ms\033[38;5;59mX\033[38;5;240mX\033[38;5;239mX\033[38;5;241mA\033[38;5;239mX\033[38;5;236m;\033[38;5;246mh\033[38;5;231mB\033[38;5;252mS\033[38;5;224m#\033[38;5;95m2\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;234m,\033[38;5;232m.\033[38;5;234m:\033[38;5;235m;\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;96m2\033[38;5;181mH\033[38;5;224m#\033[38;5;224m#\033[38;5;223m#\033[38;5;182mG\033[38;5;231m@\033[38;5;188mS\033[38;5;249mH\033[38;5;251mS\033[38;5;250mG\033[38;5;255mB\033[38;5;225m9\033[38;5;138mh\033[38;5;239mX\033[38;5;236mi\033[38;5;233m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;234m:\033[38;5;138m3\033[38;5;139mM\033[38;5;145mM\033[38;5;181mH\033[38;5;182mG\033[38;5;188mS\033[38;5;224m#\033[38;5;224m#\033[38;5;145mM\033[38;5;233m.\033[38;5;234m,\033[38;5;236m;\033[38;5;238mr\033[38;5;101m5\033[38;5;137mh\033[38;5;137m5\033[38;5;138mh\033[38;5;137m3\033[38;5;239mX\033[0m");
    $display("\033[38;5;181mH\033[38;5;239mX\033[38;5;16m \033[38;5;239mX\033[38;5;239ms\033[38;5;238mr\033[38;5;238mr\033[38;5;239ms\033[38;5;241mA\033[38;5;16m \033[38;5;243m5\033[38;5;224m9\033[38;5;246mh\033[38;5;244m5\033[38;5;234m:\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;236m;\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;102m5\033[38;5;139mh\033[38;5;251mS\033[38;5;224m9\033[38;5;223m#\033[38;5;181mG\033[38;5;225m9\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;225m9\033[38;5;181mG\033[38;5;137m3\033[38;5;235m;\033[38;5;234m,\033[38;5;233m,\033[38;5;234m,\033[38;5;16m \033[38;5;232m.\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;239ms\033[38;5;175mM\033[38;5;181mH\033[38;5;181mG\033[38;5;182mS\033[38;5;224m#\033[38;5;224m#\033[38;5;188mS\033[38;5;188m#\033[38;5;138mM\033[38;5;95m2\033[38;5;238mr\033[38;5;233m,\033[38;5;233m,\033[38;5;239ms\033[38;5;101m5\033[38;5;95m2\033[38;5;137m3\033[38;5;180mH\033[0m");
    $display("\033[38;5;180mH\033[38;5;239mX\033[38;5;16m \033[38;5;241mA\033[38;5;237mr\033[38;5;236mi\033[38;5;237mr\033[38;5;59mX\033[38;5;241mA\033[38;5;16m \033[38;5;243m5\033[38;5;187m#\033[38;5;138mh\033[38;5;240mX\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;238ms\033[38;5;139mM\033[38;5;139mM\033[38;5;181mH\033[38;5;181mG\033[38;5;181mH\033[38;5;139mM\033[38;5;225m9\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;225m9\033[38;5;181mG\033[38;5;180mH\033[38;5;238mr\033[38;5;238ms\033[38;5;234m,\033[38;5;235m:\033[38;5;232m.\033[38;5;16m \033[38;5;233m,\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;237mr\033[38;5;139mM\033[38;5;181mH\033[38;5;181mG\033[38;5;188mS\033[38;5;224m#\033[38;5;224m#\033[38;5;224m#\033[38;5;224m#\033[38;5;224m9\033[38;5;229mB\033[38;5;223m#\033[38;5;180mH\033[38;5;238ms\033[38;5;233m,\033[38;5;237mi\033[38;5;244m5\033[38;5;101m5\033[38;5;137m3\033[0m");
    $display("\033[38;5;180mH\033[38;5;238ms\033[38;5;16m \033[38;5;59mX\033[38;5;238mr\033[38;5;237mr\033[38;5;237mi\033[38;5;238ms\033[38;5;59mX\033[38;5;16m \033[38;5;242m2\033[38;5;187mS\033[38;5;187m#\033[38;5;138mh\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;181mG\033[38;5;224m#\033[38;5;187m#\033[38;5;224m#\033[38;5;181mG\033[38;5;138mh\033[38;5;138m3\033[38;5;225m#\033[38;5;231mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;225m9\033[38;5;181mG\033[38;5;180mG\033[38;5;240mX\033[38;5;137m3\033[38;5;239ms\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;237mi\033[38;5;139mM\033[38;5;181mH\033[38;5;188mS\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m#\033[38;5;223m9\033[38;5;223m9\033[38;5;229m9\033[38;5;223m9\033[38;5;240mX\033[38;5;233m,\033[38;5;237mr\033[38;5;138mh\033[38;5;138mM\033[0m");
    $display("\033[38;5;180mM\033[38;5;238mr\033[38;5;16m \033[38;5;240mX\033[38;5;238ms\033[38;5;239mX\033[38;5;239mX\033[38;5;239mX\033[38;5;240mX\033[38;5;16m \033[38;5;101m3\033[38;5;180mH\033[38;5;144mM\033[38;5;237mi\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;234m,\033[38;5;236mi\033[38;5;233m,\033[38;5;232m.\033[38;5;241mA\033[38;5;239ms\033[38;5;237mr\033[38;5;239mX\033[38;5;237mi\033[38;5;239ms\033[38;5;145mH\033[38;5;255mB\033[38;5;230mB\033[38;5;230mB\033[38;5;224m9\033[38;5;224m#\033[38;5;181mH\033[38;5;138m3\033[38;5;189m#\033[38;5;231mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;225m9\033[38;5;187mS\033[38;5;187mS\033[38;5;138mh\033[38;5;138mh\033[38;5;244m5\033[38;5;236mi\033[38;5;237mr\033[38;5;234m:\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;238mr\033[38;5;139mM\033[38;5;181mH\033[38;5;224m#\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m#\033[38;5;223m9\033[38;5;223m9\033[38;5;223m9\033[38;5;229m9\033[38;5;222mS\033[38;5;236mi\033[38;5;232m.\033[38;5;238ms\033[38;5;144mM\033[0m");
    $display("\033[38;5;138mh\033[38;5;237mi\033[38;5;16m \033[38;5;241mA\033[38;5;238mr\033[38;5;237mi\033[38;5;236mi\033[38;5;240mX\033[38;5;240mX\033[38;5;16m \033[38;5;144mM\033[38;5;95m2\033[38;5;235m:\033[38;5;16m \033[38;5;16m \033[38;5;236mi\033[38;5;237mr\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;239ms\033[38;5;235m;\033[38;5;16m \033[38;5;242m2\033[38;5;241mA\033[38;5;242mA\033[38;5;241mA\033[38;5;243m5\033[38;5;188m#\033[38;5;255mB\033[38;5;255m9\033[38;5;231mB\033[38;5;230mB\033[38;5;224m9\033[38;5;224m9\033[38;5;181mM\033[38;5;138m3\033[38;5;253m#\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;225m#\033[38;5;188m#\033[38;5;223m#\033[38;5;187mS\033[38;5;245m3\033[38;5;240mX\033[38;5;243m2\033[38;5;241mA\033[38;5;235m;\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;237mi\033[38;5;139mM\033[38;5;181mG\033[38;5;224m#\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m#\033[38;5;224m#\033[38;5;223m9\033[38;5;223m9\033[38;5;223m9\033[38;5;229m9\033[38;5;95m2\033[38;5;16m \033[38;5;236m;\033[38;5;144mM\033[0m");
    $display("\033[38;5;138m3\033[38;5;236mi\033[38;5;16m \033[38;5;241mA\033[38;5;237mi\033[38;5;237mr\033[38;5;238ms\033[38;5;59mA\033[38;5;239mX\033[38;5;16m \033[38;5;144mh\033[38;5;240mX\033[38;5;232m.\033[38;5;232m.\033[38;5;242m2\033[38;5;241mA\033[38;5;234m:\033[38;5;232m.\033[38;5;235m:\033[38;5;235m;\033[38;5;235m;\033[38;5;235m:\033[38;5;236m;\033[38;5;235m;\033[38;5;235m:\033[38;5;236mi\033[38;5;234m:\033[38;5;233m.\033[38;5;234m:\033[38;5;234m:\033[38;5;234m:\033[38;5;247mM\033[38;5;224m9\033[38;5;224m9\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;224m9\033[38;5;224m9\033[38;5;181mH\033[38;5;102m5\033[38;5;182mG\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;182mH\033[38;5;181mG\033[38;5;223m9\033[38;5;180mH\033[38;5;237mr\033[38;5;236m;\033[38;5;238mr\033[38;5;233m,\033[38;5;234m:\033[38;5;235m;\033[38;5;235m;\033[38;5;235m;\033[38;5;235m:\033[38;5;235m:\033[38;5;239ms\033[38;5;139mM\033[38;5;181mG\033[38;5;224m#\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m#\033[38;5;224m9\033[38;5;223m9\033[38;5;223m9\033[38;5;229m9\033[38;5;95mA\033[38;5;16m \033[38;5;59mX\033[38;5;181mG\033[0m");
    $display("\033[38;5;95m2\033[38;5;235m;\033[38;5;16m \033[38;5;241mA\033[38;5;237mi\033[38;5;239ms\033[38;5;239ms\033[38;5;241mA\033[38;5;239mX\033[38;5;16m \033[38;5;144mM\033[38;5;239mX\033[38;5;232m.\033[38;5;232m.\033[38;5;243m2\033[38;5;241mA\033[38;5;234m:\033[38;5;234m:\033[38;5;237mr\033[38;5;238mr\033[38;5;59mX\033[38;5;240mX\033[38;5;241mA\033[38;5;241mA\033[38;5;59mA\033[38;5;240mX\033[38;5;237mr\033[38;5;238ms\033[38;5;241mA\033[38;5;240mX\033[38;5;243m2\033[38;5;245mh\033[38;5;245m3\033[38;5;102m3\033[38;5;245m3\033[38;5;145mH\033[38;5;231mB\033[38;5;255m9\033[38;5;224m9\033[38;5;145mH\033[38;5;181mG\033[38;5;253m#\033[38;5;255mB\033[38;5;254m9\033[38;5;254m9\033[38;5;254m9\033[38;5;254m9\033[38;5;188m#\033[38;5;252mS\033[38;5;230m9\033[38;5;145mH\033[38;5;242mA\033[38;5;242mA\033[38;5;187mS\033[38;5;241mA\033[38;5;240mX\033[38;5;59mX\033[38;5;239ms\033[38;5;239ms\033[38;5;238mr\033[38;5;238ms\033[38;5;242m2\033[38;5;145mH\033[38;5;181mG\033[38;5;224m#\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m#\033[38;5;224m#\033[38;5;223m9\033[38;5;229m9\033[38;5;138mh\033[38;5;232m.\033[38;5;59mX\033[38;5;181mG\033[38;5;187mS\033[0m");
    $display("\033[38;5;240mX\033[38;5;235m:\033[38;5;16m \033[38;5;239ms\033[38;5;238ms\033[38;5;238mr\033[38;5;237mr\033[38;5;239ms\033[38;5;236m;\033[38;5;16m \033[38;5;144mM\033[38;5;239ms\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;236mi\033[38;5;237mi\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;236mi\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;241mA\033[38;5;243m5\033[38;5;242m2\033[38;5;239ms\033[38;5;239ms\033[38;5;239mX\033[38;5;246mh\033[38;5;230mB\033[38;5;224m9\033[38;5;187mS\033[38;5;138mh\033[38;5;181mG\033[38;5;182mS\033[38;5;189m#\033[38;5;239ms\033[38;5;241mA\033[38;5;242mA\033[38;5;239ms\033[38;5;188mS\033[38;5;224m#\033[38;5;223m9\033[38;5;187mS\033[38;5;138mh\033[38;5;95mA\033[38;5;144mM\033[38;5;95m5\033[38;5;233m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;234m:\033[38;5;139mM\033[38;5;251mS\033[38;5;224m#\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m#\033[38;5;181mG\033[38;5;95m2\033[38;5;237mr\033[38;5;144mM\033[38;5;223m9\033[38;5;223m#\033[38;5;144mM\033[0m");
    $display("\033[38;5;236m;\033[38;5;234m:\033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;234m:\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;144mM\033[38;5;239mX\033[38;5;235m;\033[38;5;233m.\033[38;5;235m:\033[38;5;234m:\033[38;5;235m:\033[38;5;235m:\033[38;5;16m \033[38;5;16m \033[38;5;236mi\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;236mi\033[38;5;248mM\033[38;5;247mM\033[38;5;246mh\033[38;5;59mA\033[38;5;240mX\033[38;5;59mX\033[38;5;246mh\033[38;5;230mB\033[38;5;224m9\033[38;5;181mG\033[38;5;243m2\033[38;5;144mH\033[38;5;181mG\033[38;5;189m#\033[38;5;237mr\033[38;5;239ms\033[38;5;242mA\033[38;5;235m:\033[38;5;146mH\033[38;5;253m#\033[38;5;229m9\033[38;5;223m9\033[38;5;230m9\033[38;5;223m#\033[38;5;144mM\033[38;5;138m3\033[38;5;237mr\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;235m;\033[38;5;139mM\033[38;5;181mG\033[38;5;224m#\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;254m9\033[38;5;224m9\033[38;5;181mG\033[38;5;144mH\033[38;5;224m9\033[38;5;230m9\033[38;5;223m#\033[38;5;223m#\033[38;5;242m2\033[0m");
    $display("\033[38;5;233m,\033[38;5;233m,\033[38;5;16m \033[38;5;238mr\033[38;5;16m \033[38;5;232m.\033[38;5;59mX\033[38;5;240mX\033[38;5;16m \033[38;5;16m \033[38;5;144mM\033[38;5;239mX\033[38;5;234m:\033[38;5;236mi\033[38;5;237mr\033[38;5;16m \033[38;5;232m.\033[38;5;239ms\033[38;5;234m:\033[38;5;16m \033[38;5;236mi\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;234m:\033[38;5;240mX\033[38;5;245m3\033[38;5;245m3\033[38;5;102m3\033[38;5;240mX\033[38;5;240mX\033[38;5;240mX\033[38;5;246mh\033[38;5;230mB\033[38;5;224m9\033[38;5;181mH\033[38;5;235m;\033[38;5;240mX\033[38;5;187mS\033[38;5;182mH\033[38;5;235m;\033[38;5;242m2\033[38;5;247mM\033[38;5;239ms\033[38;5;246mh\033[38;5;230mB\033[38;5;230mB\033[38;5;224m9\033[38;5;230m9\033[38;5;230mB\033[38;5;230mB\033[38;5;144mM\033[38;5;234m:\033[38;5;232m.\033[38;5;235m;\033[38;5;233m,\033[38;5;232m.\033[38;5;16m \033[38;5;235m;\033[38;5;139mM\033[38;5;181mG\033[38;5;188m#\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;230mB\033[38;5;230m9\033[38;5;224m9\033[38;5;223m#\033[38;5;187mS\033[38;5;238mr\033[0m");
    $display("\033[38;5;17m:\033[38;5;233m.\033[38;5;16m \033[38;5;238mr\033[38;5;16m \033[38;5;16m \033[38;5;236mi\033[38;5;234m:\033[38;5;16m \033[38;5;16m \033[38;5;144mH\033[38;5;238mr\033[38;5;235m:\033[38;5;239ms\033[38;5;238mr\033[38;5;235m;\033[38;5;235m;\033[38;5;234m:\033[38;5;16m \033[38;5;16m \033[38;5;237mi\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;238mr\033[38;5;239ms\033[38;5;239ms\033[38;5;239ms\033[38;5;239ms\033[38;5;239ms\033[38;5;239ms\033[38;5;239ms\033[38;5;246mh\033[38;5;230mB\033[38;5;224m#\033[38;5;241mA\033[38;5;16m \033[38;5;234m:\033[38;5;138mh\033[38;5;180mH\033[38;5;241mA\033[38;5;243m2\033[38;5;247mM\033[38;5;245m3\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;187m#\033[38;5;237mr\033[38;5;233m,\033[38;5;236mi\033[38;5;236mi\033[38;5;236m;\033[38;5;232m.\033[38;5;16m \033[38;5;235m;\033[38;5;139mM\033[38;5;181mG\033[38;5;188mS\033[38;5;224m#\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;254m9\033[38;5;224m9\033[38;5;253m#\033[38;5;224m9\033[38;5;223m9\033[38;5;223m#\033[38;5;144mM\033[38;5;233m,\033[0m");
    $display("\033[38;5;53m;\033[38;5;233m,\033[38;5;16m \033[38;5;234m:\033[38;5;235m;\033[38;5;235m;\033[38;5;235m;\033[38;5;232m.\033[38;5;233m,\033[38;5;233m,\033[38;5;240mX\033[38;5;16m \033[38;5;234m:\033[38;5;234m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;236mi\033[38;5;235m;\033[38;5;235m;\033[38;5;234m:\033[38;5;235m:\033[38;5;239mX\033[38;5;243m5\033[38;5;243m5\033[38;5;244m5\033[38;5;102m3\033[38;5;244m5\033[38;5;102m5\033[38;5;102m3\033[38;5;102m3\033[38;5;244m5\033[38;5;248mH\033[38;5;224m9\033[38;5;181mH\033[38;5;233m,\033[38;5;16m \033[38;5;235m:\033[38;5;138mh\033[38;5;187mS\033[38;5;138m3\033[38;5;242m2\033[38;5;145mM\033[38;5;247mM\033[38;5;230m9\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;101m3\033[38;5;235m;\033[38;5;235m;\033[38;5;236m;\033[38;5;237mi\033[38;5;234m:\033[38;5;16m \033[38;5;16m \033[38;5;236m;\033[38;5;145mM\033[38;5;181mG\033[38;5;252mS\033[38;5;224m#\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;255m9\033[38;5;255mB\033[38;5;255mB\033[38;5;255mB\033[38;5;255mB\033[38;5;254m9\033[38;5;224m9\033[38;5;223m9\033[38;5;223m9\033[38;5;241mA\033[38;5;17m.\033[0m");
    $display("\033[38;5;17m;\033[38;5;17m;\033[38;5;236mi\033[38;5;59mX\033[38;5;101m5\033[38;5;138mh\033[38;5;144mM\033[38;5;180mH\033[38;5;95m2\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;234m:\033[38;5;233m.\033[38;5;233m,\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;235m:\033[38;5;235m;\033[38;5;234m:\033[38;5;145mH\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;230mB\033[38;5;224m#\033[38;5;59mA\033[38;5;16m \033[38;5;16m \033[38;5;242m2\033[38;5;230m9\033[38;5;230mB\033[38;5;138mh\033[38;5;242m2\033[38;5;250mG\033[38;5;250mG\033[38;5;254m9\033[38;5;230mB\033[38;5;187m#\033[38;5;187mS\033[38;5;230mB\033[38;5;187m#\033[38;5;237mi\033[38;5;234m:\033[38;5;16m \033[38;5;240mX\033[38;5;95m2\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;235m;\033[38;5;138mh\033[38;5;145mH\033[38;5;181mG\033[38;5;251mS\033[38;5;188mS\033[38;5;188mS\033[38;5;251mS\033[38;5;251mS\033[38;5;251mS\033[38;5;251mS\033[38;5;250mG\033[38;5;250mG\033[38;5;249mH\033[38;5;247mM\033[38;5;144mM\033[38;5;138mh\033[38;5;235m:\033[38;5;233m,\033[0m");
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[0m");
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[0m");
    $display ("===============================================================================");
    $display ("                                   %0sCongratulation!!%0s                    ", txt_green_prefix, reset_color);
    $display ("                           You have passed all patterns!                   ");
    $display ("                       total execution cycles = %10d cycles               ", total_latency);
    $display ("===============================================================================");  

end endtask

task YOU_FAIL_task; begin
    $display("\033[38;5;96m2\033[38;5;96m2\033[38;5;102m5\033[38;5;246mh\033[38;5;145mH\033[38;5;145mH\033[38;5;247mM\033[38;5;246mh\033[38;5;102m3\033[38;5;102m5\033[38;5;102m5\033[38;5;245m3\033[38;5;247mh\033[38;5;145mM\033[38;5;249mH\033[38;5;146mG\033[38;5;250mG\033[38;5;188mS\033[38;5;189m#\033[38;5;189m#\033[38;5;189m9\033[38;5;195m9\033[38;5;255mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;255mB\033[38;5;195m9\033[38;5;189m9\033[38;5;189m#\033[38;5;189m#\033[38;5;189mS\033[38;5;189mS\033[38;5;189m#\033[38;5;189m9\033[38;5;189m9\033[38;5;255mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;255mB\033[38;5;189m9\033[38;5;189m#\033[38;5;188mS\033[38;5;250mG\033[38;5;249mH\033[38;5;145mH\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mH\033[38;5;145mH\033[38;5;249mH\033[38;5;249mH\033[38;5;146mG\033[38;5;250mG\033[38;5;182mG\033[38;5;251mS\033[38;5;188mS\033[38;5;188mS\033[38;5;188m#\033[38;5;189m#\033[0m");
    $display("\033[38;5;246mh\033[38;5;245m3\033[38;5;138m3\033[38;5;138mh\033[38;5;246mh\033[38;5;246mh\033[38;5;102m3\033[38;5;102m5\033[38;5;102m5\033[38;5;102m5\033[38;5;102m3\033[38;5;139m3\033[38;5;139mh\033[38;5;145mM\033[38;5;145mM\033[38;5;145mH\033[38;5;249mH\033[38;5;146mG\033[38;5;251mS\033[38;5;188mS\033[38;5;189m#\033[38;5;189m9\033[38;5;195m9\033[38;5;255mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;255mB\033[38;5;189m9\033[38;5;189m9\033[38;5;189m#\033[38;5;189m#\033[38;5;189m#\033[38;5;189m9\033[38;5;189m9\033[38;5;255mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;195m9\033[38;5;189m9\033[38;5;188m#\033[38;5;251mS\033[38;5;249mH\033[38;5;145mH\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mH\033[38;5;145mH\033[38;5;249mH\033[38;5;249mH\033[38;5;250mG\033[38;5;250mG\033[38;5;188mG\033[38;5;188mS\033[38;5;188mS\033[0m");
    $display("\033[38;5;246mh\033[38;5;102m3\033[38;5;102m3\033[38;5;245m3\033[38;5;245m3\033[38;5;102m5\033[38;5;102m5\033[38;5;102m5\033[38;5;102m5\033[38;5;102m3\033[38;5;103m3\033[38;5;103m3\033[38;5;103m3\033[38;5;139mh\033[38;5;139mh\033[38;5;246mh\033[38;5;139mh\033[38;5;145mM\033[38;5;146mH\033[38;5;182mG\033[38;5;188mS\033[38;5;189m#\033[38;5;189m9\033[38;5;189m9\033[38;5;255mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;195m9\033[38;5;189m9\033[38;5;189m9\033[38;5;189m#\033[38;5;189m9\033[38;5;189m9\033[38;5;195m9\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;255mB\033[38;5;189m9\033[38;5;189m#\033[38;5;188mS\033[38;5;146mG\033[38;5;145mH\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mH\033[38;5;249mH\033[38;5;249mH\033[38;5;146mG\033[38;5;250mG\033[38;5;182mG\033[0m");
    $display("\033[38;5;102m5\033[38;5;96m5\033[38;5;96m5\033[38;5;102m5\033[38;5;102m5\033[38;5;102m5\033[38;5;102m5\033[38;5;102m3\033[38;5;103m3\033[38;5;103m3\033[38;5;103m3\033[38;5;103m3\033[38;5;103m3\033[38;5;103m3\033[38;5;245m3\033[38;5;103m3\033[38;5;139mh\033[38;5;139mh\033[38;5;145mM\033[38;5;249mH\033[38;5;250mG\033[38;5;188mS\033[38;5;189m#\033[38;5;189m9\033[38;5;189m9\033[38;5;255mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;255mB\033[38;5;195m9\033[38;5;189m9\033[38;5;189m9\033[38;5;189m9\033[38;5;195m9\033[38;5;255mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;255mB\033[38;5;189m9\033[38;5;189m#\033[38;5;188mS\033[38;5;250mG\033[38;5;145mH\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mH\033[38;5;145mH\033[38;5;249mH\033[38;5;249mH\033[0m");
    $display("\033[38;5;102m5\033[38;5;102m5\033[38;5;102m5\033[38;5;102m5\033[38;5;102m5\033[38;5;102m3\033[38;5;102m3\033[38;5;245m3\033[38;5;245m3\033[38;5;103m3\033[38;5;103m3\033[38;5;103m3\033[38;5;103m3\033[38;5;103m3\033[38;5;103m3\033[38;5;139mh\033[38;5;246mh\033[38;5;246mh\033[38;5;247mh\033[38;5;145mM\033[38;5;249mH\033[38;5;250mG\033[38;5;188mS\033[38;5;188m#\033[38;5;189m9\033[38;5;254m9\033[38;5;255mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;255mB\033[38;5;254m9\033[38;5;189m9\033[38;5;189m9\033[38;5;195m9\033[38;5;255mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;195m9\033[38;5;189m#\033[38;5;188mS\033[38;5;250mG\033[38;5;249mH\033[38;5;145mH\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mH\033[0m");
    $display("\033[38;5;102m5\033[38;5;102m5\033[38;5;102m5\033[38;5;102m3\033[38;5;102m3\033[38;5;245m3\033[38;5;138m3\033[38;5;138m3\033[38;5;138m3\033[38;5;138mh\033[38;5;139mh\033[38;5;139mh\033[38;5;139mh\033[38;5;139mh\033[38;5;139mh\033[38;5;139mh\033[38;5;139mh\033[38;5;139mh\033[38;5;139mM\033[38;5;145mM\033[38;5;145mM\033[38;5;249mH\033[38;5;250mG\033[38;5;188mS\033[38;5;188m#\033[38;5;189m#\033[38;5;254m9\033[38;5;255mB\033[38;5;255mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;255mB\033[38;5;255mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;255mB\033[38;5;254m9\033[38;5;188m#\033[38;5;251mS\033[38;5;249mG\033[38;5;145mH\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[0m");
    $display("\033[38;5;138m3\033[38;5;138m3\033[38;5;138m3\033[38;5;138m3\033[38;5;138m3\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;139mh\033[38;5;139mM\033[38;5;139mM\033[38;5;139mh\033[38;5;139mh\033[38;5;139mM\033[38;5;139mM\033[38;5;139mM\033[38;5;139mM\033[38;5;139mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mH\033[38;5;145mH\033[38;5;181mH\033[38;5;182mG\033[38;5;188mS\033[38;5;253m#\033[38;5;189m9\033[38;5;255mB\033[38;5;231mB\033[38;5;231mB\033[38;5;254m9\033[38;5;251mS\033[38;5;145mH\033[38;5;138mh\033[38;5;102m3\033[38;5;102m5\033[38;5;246mh\033[38;5;251mS\033[38;5;188mS\033[38;5;251mS\033[38;5;188mS\033[38;5;188mS\033[38;5;253m#\033[38;5;231m9\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;254m9\033[38;5;253m#\033[38;5;188mS\033[38;5;250mG\033[38;5;249mH\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;248mM\033[38;5;145mH\033[0m");
    $display("\033[38;5;138m3\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;175mM\033[38;5;175mM\033[38;5;175mM\033[38;5;181mM\033[38;5;181mM\033[38;5;181mM\033[38;5;181mM\033[38;5;181mM\033[38;5;181mM\033[38;5;139mM\033[38;5;175mM\033[38;5;181mM\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mG\033[38;5;182mG\033[38;5;188m#\033[38;5;253m#\033[38;5;188mS\033[38;5;145mM\033[38;5;96m5\033[38;5;95mX\033[38;5;59ms\033[38;5;238mr\033[38;5;238ms\033[38;5;59ms\033[38;5;238mr\033[38;5;236mi\033[38;5;237mr\033[38;5;238mr\033[38;5;59mX\033[38;5;95mA\033[38;5;95m2\033[38;5;96m5\033[38;5;102m5\033[38;5;139mh\033[38;5;250mG\033[38;5;254m9\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;255mB\033[38;5;253m9\033[38;5;188mS\033[38;5;250mG\033[38;5;249mH\033[38;5;145mH\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mH\033[38;5;249mH\033[0m");
    $display("\033[38;5;138mh\033[38;5;138mh\033[38;5;174mh\033[38;5;174mh\033[38;5;174mM\033[38;5;174mM\033[38;5;175mM\033[38;5;175mM\033[38;5;175mM\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;182mG\033[38;5;145mH\033[38;5;244m5\033[38;5;95mX\033[38;5;238mr\033[38;5;59mr\033[38;5;96mA\033[38;5;60mX\033[38;5;60mX\033[38;5;96mA\033[38;5;96mA\033[38;5;59mr\033[38;5;237mr\033[38;5;237mr\033[38;5;238ms\033[38;5;59mX\033[38;5;95m2\033[38;5;96m2\033[38;5;95mA\033[38;5;243m2\033[38;5;95m2\033[38;5;95m2\033[38;5;102m5\033[38;5;139mh\033[38;5;254m9\033[38;5;231m@\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;255mB\033[38;5;254m9\033[38;5;188m#\033[38;5;250mG\033[38;5;249mH\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mH\033[38;5;249mH\033[38;5;249mH\033[0m");
    $display("\033[38;5;174mh\033[38;5;174mM\033[38;5;174mM\033[38;5;174mM\033[38;5;174mM\033[38;5;175mM\033[38;5;175mM\033[38;5;175mM\033[38;5;175mM\033[38;5;181mH\033[38;5;181mH\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;102m3\033[38;5;95mX\033[38;5;239ms\033[38;5;237mr\033[38;5;237mi\033[38;5;237mr\033[38;5;237mr\033[38;5;239ms\033[38;5;239ms\033[38;5;238mr\033[38;5;95m2\033[38;5;95mA\033[38;5;59ms\033[38;5;239ms\033[38;5;59ms\033[38;5;59mX\033[38;5;95mA\033[38;5;95m2\033[38;5;239ms\033[38;5;238mr\033[38;5;95m2\033[38;5;243m5\033[38;5;243m5\033[38;5;95mA\033[38;5;59mX\033[38;5;249mG\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;254m9\033[38;5;188m#\033[38;5;250mG\033[38;5;249mH\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mH\033[38;5;145mH\033[0m");
    $display("\033[38;5;60mX\033[38;5;96m2\033[38;5;174mh\033[38;5;175mH\033[38;5;175mH\033[38;5;175mM\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;95m2\033[38;5;240mX\033[38;5;95mA\033[38;5;238ms\033[38;5;238mr\033[38;5;95mA\033[38;5;95mA\033[38;5;95m2\033[38;5;138mh\033[38;5;137m5\033[38;5;95m2\033[38;5;138mh\033[38;5;181mG\033[38;5;138mh\033[38;5;132m5\033[38;5;95mA\033[38;5;95m2\033[38;5;95mA\033[38;5;239ms\033[38;5;237mi\033[38;5;235m;\033[38;5;234m:\033[38;5;238ms\033[38;5;239ms\033[38;5;239ms\033[38;5;239ms\033[38;5;236mi\033[38;5;246mh\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;254m9\033[38;5;188m#\033[38;5;182mG\033[38;5;249mH\033[38;5;145mH\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mH\033[38;5;146mH\033[38;5;146mH\033[38;5;145mH\033[38;5;145mH\033[0m");
    $display("\033[38;5;237mr\033[38;5;238mr\033[38;5;59ms\033[38;5;96m2\033[38;5;139mh\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;181mS\033[38;5;181mS\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;95m5\033[38;5;95mA\033[38;5;95mA\033[38;5;240mX\033[38;5;239ms\033[38;5;137m3\033[38;5;138mh\033[38;5;137m5\033[38;5;174mM\033[38;5;181mG\033[38;5;138mM\033[38;5;138mh\033[38;5;180mH\033[38;5;223m#\033[38;5;181mG\033[38;5;181mG\033[38;5;138m3\033[38;5;95m2\033[38;5;132m5\033[38;5;95mX\033[38;5;236mi\033[38;5;234m:\033[38;5;234m,\033[38;5;232m.\033[38;5;234m:\033[38;5;235m;\033[38;5;236mi\033[38;5;238mr\033[38;5;235m:\033[38;5;102m5\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;195m9\033[38;5;253m#\033[38;5;188mS\033[38;5;249mG\033[38;5;145mH\033[38;5;145mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;145mH\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;146mH\033[38;5;146mH\033[38;5;146mH\033[38;5;146mH\033[38;5;146mH\033[38;5;146mH\033[0m");
    $display("\033[38;5;237mi\033[38;5;238mr\033[38;5;59ms\033[38;5;238mr\033[38;5;59ms\033[38;5;96m5\033[38;5;181mH\033[38;5;181mG\033[38;5;181mH\033[38;5;181mG\033[38;5;181mS\033[38;5;182mS\033[38;5;182mS\033[38;5;182mS\033[38;5;182mS\033[38;5;181mS\033[38;5;181mS\033[38;5;181mS\033[38;5;181mS\033[38;5;181mG\033[38;5;217mS\033[38;5;138m5\033[38;5;95mX\033[38;5;95mA\033[38;5;238mr\033[38;5;237mr\033[38;5;95m2\033[38;5;180mM\033[38;5;95m5\033[38;5;95m2\033[38;5;180mH\033[38;5;181mG\033[38;5;138m3\033[38;5;138mM\033[38;5;180mM\033[38;5;224m#\033[38;5;223m#\033[38;5;180mH\033[38;5;223mS\033[38;5;95mA\033[38;5;95m2\033[38;5;95mA\033[38;5;95mA\033[38;5;237mr\033[38;5;233m.\033[38;5;234m,\033[38;5;16m \033[38;5;233m,\033[38;5;235m:\033[38;5;236m;\033[38;5;237mi\033[38;5;234m:\033[38;5;245m3\033[38;5;231m@\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;255mB\033[38;5;189m9\033[38;5;188mS\033[38;5;250mG\033[38;5;145mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mH\033[38;5;146mH\033[38;5;146mH\033[38;5;146mH\033[38;5;146mH\033[38;5;146mH\033[0m");
    $display("\033[38;5;237mr\033[38;5;236mi\033[38;5;237mr\033[38;5;238mr\033[38;5;238mr\033[38;5;59ms\033[38;5;60mX\033[38;5;139mM\033[38;5;217mG\033[38;5;181mG\033[38;5;181mS\033[38;5;188mS\033[38;5;188mS\033[38;5;188m#\033[38;5;224m#\033[38;5;252mS\033[38;5;224mS\033[38;5;224mS\033[38;5;181mS\033[38;5;223mS\033[38;5;181mH\033[38;5;238ms\033[38;5;95mX\033[38;5;237mi\033[38;5;235m;\033[38;5;236m;\033[38;5;95m2\033[38;5;101m5\033[38;5;237mr\033[38;5;131m5\033[38;5;180mH\033[38;5;138mh\033[38;5;95m2\033[38;5;138mh\033[38;5;137m5\033[38;5;138mh\033[38;5;138mM\033[38;5;95mA\033[38;5;138mM\033[38;5;137m3\033[38;5;238mr\033[38;5;138m5\033[38;5;95mA\033[38;5;137m5\033[38;5;239ms\033[38;5;233m.\033[38;5;232m.\033[38;5;16m \033[38;5;234m:\033[38;5;235m:\033[38;5;235m;\033[38;5;236m;\033[38;5;234m:\033[38;5;249mH\033[38;5;231m@\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;254m9\033[38;5;188mS\033[38;5;250mG\033[38;5;249mH\033[38;5;139mh\033[38;5;102m3\033[38;5;245m3\033[38;5;244m5\033[38;5;138m3\033[38;5;138mh\033[38;5;102m5\033[38;5;243m5\033[38;5;246mh\033[38;5;247mh\033[38;5;145mM\033[38;5;145mM\033[38;5;145mH\033[38;5;145mH\033[38;5;145mH\033[38;5;145mM\033[0m");
    $display("\033[38;5;239ms\033[38;5;238mr\033[38;5;237mr\033[38;5;236mi\033[38;5;236mi\033[38;5;237mr\033[38;5;59ms\033[38;5;59ms\033[38;5;181mH\033[38;5;223mS\033[38;5;217mS\033[38;5;224mS\033[38;5;224m#\033[38;5;224m#\033[38;5;224m#\033[38;5;224mS\033[38;5;223mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;95m5\033[38;5;238mr\033[38;5;238mr\033[38;5;235m;\033[38;5;233m,\033[38;5;235m;\033[38;5;239ms\033[38;5;238mr\033[38;5;235m;\033[38;5;95mA\033[38;5;95m2\033[38;5;239ms\033[38;5;95mX\033[38;5;131m5\033[38;5;95mA\033[38;5;95m2\033[38;5;180mH\033[38;5;137m3\033[38;5;138mh\033[38;5;174mM\033[38;5;95mA\033[38;5;237mi\033[38;5;131m5\033[38;5;239ms\033[38;5;138m3\033[38;5;238mr\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;235m:\033[38;5;235m;\033[38;5;235m:\033[38;5;237mr\033[38;5;254m9\033[38;5;231mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;254m9\033[38;5;188m#\033[38;5;182mG\033[38;5;249mH\033[38;5;145mH\033[38;5;145mM\033[38;5;145mM\033[38;5;247mM\033[38;5;247mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[0m");
    $display("\033[38;5;239ms\033[38;5;239ms\033[38;5;238ms\033[38;5;236mi\033[38;5;236mi\033[38;5;236mi\033[38;5;237mi\033[38;5;237mr\033[38;5;59mX\033[38;5;181mG\033[38;5;223mS\033[38;5;224m#\033[38;5;224m#\033[38;5;224m#\033[38;5;223m#\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;181mG\033[38;5;238mr\033[38;5;237mi\033[38;5;236mi\033[38;5;235m:\033[38;5;232m.\033[38;5;233m,\033[38;5;238ms\033[38;5;59mX\033[38;5;235m;\033[38;5;95mX\033[38;5;137m3\033[38;5;138mh\033[38;5;252mS\033[38;5;181mS\033[38;5;181mH\033[38;5;180mH\033[38;5;138m3\033[38;5;102m5\033[38;5;236m;\033[38;5;237mi\033[38;5;95mX\033[38;5;95mA\033[38;5;180mH\033[38;5;180mH\033[38;5;138mM\033[38;5;174mM\033[38;5;235m;\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;234m,\033[38;5;235m:\033[38;5;235m;\033[38;5;234m:\033[38;5;244m5\033[38;5;231m@\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;255m9\033[38;5;189m#\033[38;5;251mS\033[38;5;249mH\033[38;5;145mH\033[38;5;145mH\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[0m");
    $display("\033[38;5;239ms\033[38;5;238ms\033[38;5;239ms\033[38;5;236mi\033[38;5;237mi\033[38;5;236mi\033[38;5;236mi\033[38;5;236mi\033[38;5;236mi\033[38;5;96m2\033[38;5;223m#\033[38;5;223mS\033[38;5;224m#\033[38;5;223m#\033[38;5;223m#\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;138mh\033[38;5;236mi\033[38;5;237mr\033[38;5;236m;\033[38;5;235m;\033[38;5;233m.\033[38;5;236mi\033[38;5;95m2\033[38;5;138m3\033[38;5;95mA\033[38;5;138mh\033[38;5;224m9\033[38;5;230mB\033[38;5;231mB\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;224m#\033[38;5;223m#\033[38;5;181mG\033[38;5;181mG\033[38;5;224m#\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;224m9\033[38;5;217mG\033[38;5;239ms\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m.\033[38;5;235m:\033[38;5;235m;\033[38;5;236m;\033[38;5;237mi\033[38;5;253m#\033[38;5;231m@\033[38;5;231mB\033[38;5;231m@\033[38;5;231mB\033[38;5;255mB\033[38;5;189m#\033[38;5;188mS\033[38;5;249mH\033[38;5;145mH\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mH\033[38;5;146mH\033[38;5;146mH\033[38;5;146mH\033[38;5;146mH\033[38;5;145mH\033[38;5;145mM\033[0m");
    $display("\033[38;5;238ms\033[38;5;237mr\033[38;5;238ms\033[38;5;236mi\033[38;5;236mi\033[38;5;236mi\033[38;5;236m;\033[38;5;237mr\033[38;5;237mr\033[38;5;237mr\033[38;5;181mH\033[38;5;223mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;137m5\033[38;5;236mi\033[38;5;238ms\033[38;5;237mi\033[38;5;234m:\033[38;5;238mr\033[38;5;223m#\033[38;5;224m9\033[38;5;224m9\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;231mB\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;230mB\033[38;5;224m9\033[38;5;224m#\033[38;5;217mG\033[38;5;174mM\033[38;5;237mr\033[38;5;235m:\033[38;5;235m;\033[38;5;233m.\033[38;5;233m.\033[38;5;235m;\033[38;5;236mi\033[38;5;237mi\033[38;5;236mi\033[38;5;247mM\033[38;5;231m@\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;254m9\033[38;5;188mS\033[38;5;250mG\033[38;5;249mG\033[38;5;181mG\033[38;5;249mH\033[38;5;145mH\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;146mH\033[38;5;146mG\033[38;5;146mG\033[38;5;146mG\033[38;5;146mG\033[38;5;152mG\033[38;5;146mH\033[38;5;145mM\033[0m");
    $display("\033[38;5;238mr\033[38;5;236mi\033[38;5;238mr\033[38;5;237mr\033[38;5;236mi\033[38;5;236mi\033[38;5;236m;\033[38;5;237mi\033[38;5;238mr\033[38;5;236mi\033[38;5;138m3\033[38;5;217mS\033[38;5;181mG\033[38;5;217mG\033[38;5;217mG\033[38;5;217mG\033[38;5;217mG\033[38;5;217mS\033[38;5;217mS\033[38;5;95m5\033[38;5;238mr\033[38;5;239ms\033[38;5;239ms\033[38;5;233m.\033[38;5;95mX\033[38;5;224m9\033[38;5;224m9\033[38;5;230m9\033[38;5;230mB\033[38;5;224m9\033[38;5;181mG\033[38;5;144mM\033[38;5;181mH\033[38;5;138m3\033[38;5;138mh\033[38;5;180mH\033[38;5;224m9\033[38;5;231mB\033[38;5;255mB\033[38;5;230mB\033[38;5;230m9\033[38;5;224m9\033[38;5;223m#\033[38;5;217mG\033[38;5;175mM\033[38;5;132m5\033[38;5;236mi\033[38;5;237mr\033[38;5;95mA\033[38;5;236mi\033[38;5;234m,\033[38;5;237mi\033[38;5;237mi\033[38;5;237mr\033[38;5;237mi\033[38;5;138mh\033[38;5;231m@\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231m9\033[38;5;253m#\033[38;5;188m#\033[38;5;188m#\033[38;5;188m#\033[38;5;188m#\033[38;5;188mS\033[38;5;249mH\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mH\033[38;5;146mG\033[38;5;152mG\033[38;5;152mG\033[38;5;152mG\033[38;5;146mG\033[38;5;249mH\033[38;5;145mM\033[0m");
    $display("\033[38;5;237mi\033[38;5;236m;\033[38;5;238mr\033[38;5;237mi\033[38;5;237mi\033[38;5;236mi\033[38;5;235m;\033[38;5;237mi\033[38;5;237mi\033[38;5;235m;\033[38;5;95mA\033[38;5;181mH\033[38;5;181mH\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;181mS\033[38;5;181mS\033[38;5;95m2\033[38;5;239ms\033[38;5;238mr\033[38;5;95mA\033[38;5;235m;\033[38;5;236mi\033[38;5;217mS\033[38;5;224m9\033[38;5;224m9\033[38;5;230m9\033[38;5;230mB\033[38;5;138mM\033[38;5;95m2\033[38;5;95m2\033[38;5;95mA\033[38;5;138m3\033[38;5;181mH\033[38;5;230mB\033[38;5;230mB\033[38;5;230m9\033[38;5;224m9\033[38;5;223m#\033[38;5;217mG\033[38;5;181mH\033[38;5;174mM\033[38;5;138m3\033[38;5;95mA\033[38;5;235m;\033[38;5;95mX\033[38;5;95m2\033[38;5;237mi\033[38;5;236mi\033[38;5;238ms\033[38;5;238mr\033[38;5;238mr\033[38;5;237mr\033[38;5;138mh\033[38;5;231m@\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;189m#\033[38;5;188m#\033[38;5;188m#\033[38;5;253m#\033[38;5;188m#\033[38;5;188mS\033[38;5;249mG\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mH\033[38;5;145mH\033[38;5;249mH\033[38;5;249mH\033[38;5;145mH\033[38;5;145mM\033[38;5;145mM\033[0m");
    $display("\033[38;5;235m;\033[38;5;236m;\033[38;5;237mr\033[38;5;236m;\033[38;5;237mi\033[38;5;236mi\033[38;5;236mi\033[38;5;237mr\033[38;5;236m;\033[38;5;235m;\033[38;5;95mX\033[38;5;181mH\033[38;5;181mH\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;181mS\033[38;5;188m#\033[38;5;181mG\033[38;5;95m2\033[38;5;239ms\033[38;5;238ms\033[38;5;240mX\033[38;5;240mX\033[38;5;234m:\033[38;5;95mA\033[38;5;181mG\033[38;5;223m#\033[38;5;223m9\033[38;5;224m9\033[38;5;230m9\033[38;5;223m#\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;181mG\033[38;5;181mG\033[38;5;180mM\033[38;5;180mH\033[38;5;217mS\033[38;5;217mS\033[38;5;181mG\033[38;5;181mH\033[38;5;138mh\033[38;5;131m2\033[38;5;237mi\033[38;5;237mi\033[38;5;237mr\033[38;5;234m:\033[38;5;237mr\033[38;5;236mi\033[38;5;238mr\033[38;5;238mr\033[38;5;238ms\033[38;5;238mr\033[38;5;145mM\033[38;5;231mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;254m9\033[38;5;188mS\033[38;5;250mG\033[38;5;249mG\033[38;5;249mH\033[38;5;145mH\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[0m");
    $display("\033[38;5;235m;\033[38;5;236mi\033[38;5;238mr\033[38;5;235m:\033[38;5;236mi\033[38;5;237mr\033[38;5;237mi\033[38;5;237mr\033[38;5;235m;\033[38;5;235m;\033[38;5;59mX\033[38;5;181mM\033[38;5;181mG\033[38;5;181mG\033[38;5;181mS\033[38;5;187mS\033[38;5;252mS\033[38;5;253m#\033[38;5;181mH\033[38;5;95mA\033[38;5;238mr\033[38;5;239ms\033[38;5;239ms\033[38;5;239mX\033[38;5;237mr\033[38;5;236mi\033[38;5;137m3\033[38;5;223mS\033[38;5;223m#\033[38;5;138mM\033[38;5;238mr\033[38;5;95ms\033[38;5;131m2\033[38;5;131m2\033[38;5;131m2\033[38;5;95mX\033[38;5;89ms\033[38;5;238mr\033[38;5;144mM\033[38;5;223m9\033[38;5;223m#\033[38;5;181mG\033[38;5;138m3\033[38;5;95mA\033[38;5;236mi\033[38;5;232m.\033[38;5;236mi\033[38;5;235m;\033[38;5;236mi\033[38;5;237mi\033[38;5;236m;\033[38;5;237mr\033[38;5;237mr\033[38;5;238ms\033[38;5;238ms\033[38;5;188m#\033[38;5;231m@\033[38;5;231mB\033[38;5;231m@\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;253m#\033[38;5;250mG\033[38;5;145mH\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[0m");
    $display("\033[38;5;235m:\033[38;5;236mi\033[38;5;236mi\033[38;5;234m:\033[38;5;237mr\033[38;5;237mi\033[38;5;236m;\033[38;5;237mr\033[38;5;236m;\033[38;5;236m;\033[38;5;237mr\033[38;5;139mM\033[38;5;188mS\033[38;5;188mS\033[38;5;188m#\033[38;5;188m#\033[38;5;188m#\033[38;5;253m#\033[38;5;144mM\033[38;5;95mA\033[38;5;238mr\033[38;5;238ms\033[38;5;239mX\033[38;5;237mi\033[38;5;238mr\033[38;5;237mr\033[38;5;238mr\033[38;5;137m3\033[38;5;223mS\033[38;5;223m9\033[38;5;181mG\033[38;5;174mh\033[38;5;168m3\033[38;5;174mh\033[38;5;174mh\033[38;5;167m3\033[38;5;174mh\033[38;5;217mS\033[38;5;230m9\033[38;5;223m#\033[38;5;180mH\033[38;5;131m5\033[38;5;239ms\033[38;5;235m;\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;235m;\033[38;5;237mr\033[38;5;236m;\033[38;5;95m2\033[38;5;245m3\033[38;5;239ms\033[38;5;237mr\033[38;5;95mA\033[38;5;231mB\033[38;5;255mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;188m#\033[38;5;182mG\033[38;5;145mH\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[0m");
    $display("\033[38;5;235m;\033[38;5;236mi\033[38;5;233m,\033[38;5;235m;\033[38;5;239ms\033[38;5;236mi\033[38;5;235m;\033[38;5;236mi\033[38;5;236mi\033[38;5;235m;\033[38;5;235m;\033[38;5;145mM\033[38;5;254m9\033[38;5;253m9\033[38;5;253m9\033[38;5;253m#\033[38;5;188m#\033[38;5;253m#\033[38;5;144mM\033[38;5;239mX\033[38;5;238ms\033[38;5;237mi\033[38;5;238ms\033[38;5;236mi\033[38;5;235m;\033[38;5;236m;\033[38;5;236mi\033[38;5;236mi\033[38;5;95mA\033[38;5;180mG\033[38;5;224m9\033[38;5;224m9\033[38;5;187mS\033[38;5;181mG\033[38;5;181mG\033[38;5;188m#\033[38;5;230mB\033[38;5;230mB\033[38;5;223m#\033[38;5;180mH\033[38;5;95mA\033[38;5;236mi\033[38;5;234m:\033[38;5;233m,\033[38;5;232m.\033[38;5;16m \033[38;5;232m.\033[38;5;234m:\033[38;5;236m;\033[38;5;238ms\033[38;5;224m#\033[38;5;231mB\033[38;5;95m2\033[38;5;235m;\033[38;5;102m5\033[38;5;255mB\033[38;5;224m9\033[38;5;255m9\033[38;5;231mB\033[38;5;255mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231mB\033[38;5;231m@\033[38;5;255mB\033[38;5;188mS\033[38;5;182mG\033[38;5;145mH\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[0m");
    $display("\033[38;5;237mr\033[38;5;234m:\033[38;5;16m \033[38;5;236mi\033[38;5;237mr\033[38;5;234m:\033[38;5;235m;\033[38;5;236mi\033[38;5;236mi\033[38;5;235m;\033[38;5;234m:\033[38;5;145mM\033[38;5;231mB\033[38;5;255mB\033[38;5;255mB\033[38;5;254m9\033[38;5;254m9\033[38;5;254m9\033[38;5;249mH\033[38;5;238mr\033[38;5;240mX\033[38;5;236mi\033[38;5;235m;\033[38;5;237mi\033[38;5;235m;\033[38;5;233m,\033[38;5;233m,\033[38;5;235m:\033[38;5;234m,\033[38;5;235m;\033[38;5;95m2\033[38;5;181mG\033[38;5;224m9\033[38;5;230m9\033[38;5;224m9\033[38;5;224m#\033[38;5;181mG\033[38;5;138m3\033[38;5;95mX\033[38;5;236mi\033[38;5;234m:\033[38;5;234m:\033[38;5;235m:\033[38;5;233m,\033[38;5;233m.\033[38;5;16m \033[38;5;233m,\033[38;5;235m;\033[38;5;236m;\033[38;5;239ms\033[38;5;224m9\033[38;5;230mB\033[38;5;95m2\033[38;5;234m:\033[38;5;145mH\033[38;5;231mB\033[38;5;224m9\033[38;5;231mB\033[38;5;230mB\033[38;5;224m9\033[38;5;255mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;255m9\033[38;5;188m#\033[38;5;250mG\033[38;5;145mH\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[0m");
    $display("\033[38;5;236m;\033[38;5;232m.\033[38;5;232m.\033[38;5;236mi\033[38;5;235m;\033[38;5;234m:\033[38;5;234m:\033[38;5;237mi\033[38;5;235m;\033[38;5;235m:\033[38;5;235m:\033[38;5;250mG\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;255mB\033[38;5;254m9\033[38;5;254m9\033[38;5;251mS\033[38;5;237mi\033[38;5;236mi\033[38;5;238mr\033[38;5;234m:\033[38;5;233m.\033[38;5;235m;\033[38;5;235m;\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;235m:\033[38;5;236mi\033[38;5;236mi\033[38;5;235m;\033[38;5;234m:\033[38;5;234m:\033[38;5;235m;\033[38;5;236m;\033[38;5;235m;\033[38;5;234m:\033[38;5;236m;\033[38;5;234m,\033[38;5;233m,\033[38;5;233m,\033[38;5;234m:\033[38;5;235m;\033[38;5;238mr\033[38;5;230mB\033[38;5;231mB\033[38;5;96m5\033[38;5;95mA\033[38;5;231mB\033[38;5;231mB\033[38;5;255mB\033[38;5;231mB\033[38;5;231mB\033[38;5;255mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;255mB\033[38;5;253m#\033[38;5;182mG\033[38;5;249mH\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[0m");
    $display("\033[38;5;232m.\033[38;5;16m \033[38;5;234m:\033[38;5;236mi\033[38;5;234m:\033[38;5;233m,\033[38;5;235m:\033[38;5;237mi\033[38;5;236m;\033[38;5;233m,\033[38;5;237mi\033[38;5;188mS\033[38;5;255mB\033[38;5;255mB\033[38;5;255mB\033[38;5;255m9\033[38;5;254m9\033[38;5;254m9\033[38;5;253m#\033[38;5;239mX\033[38;5;233m,\033[38;5;236m;\033[38;5;237mr\033[38;5;234m:\033[38;5;232m.\033[38;5;234m:\033[38;5;235m:\033[38;5;234m,\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;234m,\033[38;5;237mi\033[38;5;237mr\033[38;5;237mr\033[38;5;237mi\033[38;5;237mr\033[38;5;236mi\033[38;5;235m;\033[38;5;238ms\033[38;5;236mi\033[38;5;234m:\033[38;5;233m,\033[38;5;238mr\033[38;5;237mi\033[38;5;233m,\033[38;5;239ms\033[38;5;230mB\033[38;5;231mB\033[38;5;138m3\033[38;5;181mH\033[38;5;231m@\033[38;5;230mB\033[38;5;255m9\033[38;5;231mB\033[38;5;255mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;254m9\033[38;5;188mS\033[38;5;250mG\033[38;5;181mG\033[38;5;249mH\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[0m");
    $display("\033[38;5;232m.\033[38;5;233m.\033[38;5;235m;\033[38;5;235m:\033[38;5;233m.\033[38;5;232m.\033[38;5;235m;\033[38;5;237mi\033[38;5;235m;\033[38;5;233m,\033[38;5;238ms\033[38;5;252mS\033[38;5;253m#\033[38;5;253m#\033[38;5;253m9\033[38;5;253m9\033[38;5;253m9\033[38;5;253m9\033[38;5;254m9\033[38;5;138m3\033[38;5;235m;\033[38;5;234m:\033[38;5;234m:\033[38;5;236mi\033[38;5;234m:\033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;233m,\033[38;5;233m.\033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;234m:\033[38;5;236m;\033[38;5;237mr\033[38;5;237mr\033[38;5;237mi\033[38;5;236mi\033[38;5;236mi\033[38;5;240mX\033[38;5;238mr\033[38;5;235m;\033[38;5;234m:\033[38;5;59mX\033[38;5;231mB\033[38;5;181mG\033[38;5;233m,\033[38;5;59mX\033[38;5;231mB\033[38;5;231mB\033[38;5;138mh\033[38;5;96mA\033[38;5;246mh\033[38;5;138mM\033[38;5;230mB\033[38;5;230mB\033[38;5;224m9\033[38;5;231mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;255mB\033[38;5;254m9\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;254m9\033[38;5;188m#\033[38;5;182mG\033[38;5;181mG\033[38;5;145mH\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[0m");
    $display("\033[38;5;232m.\033[38;5;233m.\033[38;5;234m:\033[38;5;233m,\033[38;5;16m \033[38;5;233m,\033[38;5;234m:\033[38;5;237mi\033[38;5;235m;\033[38;5;234m:\033[38;5;95mA\033[38;5;181mG\033[38;5;251mS\033[38;5;188mS\033[38;5;188mS\033[38;5;188mS\033[38;5;188mS\033[38;5;188mS\033[38;5;188m#\033[38;5;248mM\033[38;5;240mX\033[38;5;237mr\033[38;5;234m:\033[38;5;233m.\033[38;5;234m:\033[38;5;234m:\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;236mi\033[38;5;237mi\033[38;5;237mi\033[38;5;236mi\033[38;5;237mi\033[38;5;240mX\033[38;5;239ms\033[38;5;236mi\033[38;5;234m,\033[38;5;102m5\033[38;5;224m#\033[38;5;217mG\033[38;5;174mM\033[38;5;234m:\033[38;5;102m3\033[38;5;231mB\033[38;5;231mB\033[38;5;254m9\033[38;5;249mH\033[38;5;145mM\033[38;5;249mH\033[38;5;231mB\033[38;5;230m9\033[38;5;224m9\033[38;5;231mB\033[38;5;231mB\033[38;5;255mB\033[38;5;254m9\033[38;5;254m9\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;255mB\033[38;5;188m#\033[38;5;250mG\033[38;5;145mH\033[38;5;145mH\033[38;5;145mH\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[0m");
    $display("\033[38;5;232m.\033[38;5;232m.\033[38;5;233m.\033[38;5;16m \033[38;5;233m,\033[38;5;233m.\033[38;5;234m:\033[38;5;236mi\033[38;5;236m;\033[38;5;235m:\033[38;5;59mX\033[38;5;145mH\033[38;5;181mH\033[38;5;250mG\033[38;5;250mG\033[38;5;250mG\033[38;5;250mG\033[38;5;250mG\033[38;5;250mG\033[38;5;247mM\033[38;5;95mX\033[38;5;238ms\033[38;5;238mr\033[38;5;235m:\033[38;5;233m,\033[38;5;232m.\033[38;5;233m,\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;237mr\033[38;5;238ms\033[38;5;238mr\033[38;5;237mr\033[38;5;239ms\033[38;5;95mA\033[38;5;236mi\033[38;5;233m,\033[38;5;233m,\033[38;5;253m#\033[38;5;223m#\033[38;5;174mH\033[38;5;236m;\033[38;5;234m:\033[38;5;188m#\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;230m9\033[38;5;224m9\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;255mB\033[38;5;188m#\033[38;5;250mG\033[38;5;145mH\033[38;5;145mH\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[38;5;145mM\033[0m");
    $display("\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;233m.\033[38;5;233m,\033[38;5;232m.\033[38;5;235m;\033[38;5;237mi\033[38;5;236mi\033[38;5;236mi\033[38;5;235m:\033[38;5;102m5\033[38;5;181mG\033[38;5;181mG\033[38;5;251mS\033[38;5;251mS\033[38;5;251mS\033[38;5;181mG\033[38;5;181mG\033[38;5;138mM\033[38;5;95mA\033[38;5;238mr\033[38;5;238mr\033[38;5;237mr\033[38;5;235m;\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;245m3\033[38;5;138mh\033[38;5;95m2\033[38;5;95mA\033[38;5;95m2\033[38;5;238mr\033[38;5;234m:\033[38;5;16m \033[38;5;59mX\033[38;5;231mB\033[38;5;230mB\033[38;5;230m9\033[38;5;242m2\033[38;5;145mM\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;224m9\033[38;5;231mB\033[38;5;231m@\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;253m#\033[38;5;182mG\033[38;5;249mH\033[38;5;145mM\033[38;5;145mH\033[38;5;145mM\033[38;5;145mM\033[0m");
    $display("\033[38;5;234m,\033[38;5;232m.\033[38;5;233m,\033[38;5;233m.\033[38;5;233m.\033[38;5;233m,\033[38;5;235m:\033[38;5;235m;\033[38;5;234m:\033[38;5;237mr\033[38;5;238mr\033[38;5;236mi\033[38;5;102m5\033[38;5;181mH\033[38;5;181mG\033[38;5;181mS\033[38;5;251mS\033[38;5;181mS\033[38;5;181mG\033[38;5;181mH\033[38;5;95mA\033[38;5;236mi\033[38;5;234m,\033[38;5;235m;\033[38;5;235m;\033[38;5;236m;\033[38;5;235m;\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;233m.\033[38;5;232m.\033[38;5;235m;\033[38;5;237mi\033[38;5;187mS\033[38;5;187mS\033[38;5;101m5\033[38;5;237mr\033[38;5;233m,\033[38;5;233m,\033[38;5;232m.\033[38;5;95mA\033[38;5;230mB\033[38;5;230mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;230mB\033[38;5;181mH\033[38;5;254m9\033[38;5;231mB\033[38;5;255mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;254m9\033[38;5;182mS\033[38;5;181mH\033[38;5;145mH\033[38;5;145mH\033[38;5;181mH\033[0m");
    $display("\033[38;5;235m;\033[38;5;234m:\033[38;5;233m.\033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;233m,\033[38;5;235m:\033[38;5;234m:\033[38;5;235m;\033[38;5;237mr\033[38;5;236mi\033[38;5;238ms\033[38;5;243m5\033[38;5;247mh\033[38;5;181mH\033[38;5;181mS\033[38;5;187mS\033[38;5;181mS\033[38;5;181mS\033[38;5;138m3\033[38;5;237mr\033[38;5;235m;\033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;234m:\033[38;5;236mi\033[38;5;236m;\033[38;5;233m.\033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;233m,\033[38;5;16m \033[38;5;238ms\033[38;5;181mG\033[38;5;101m5\033[38;5;239ms\033[38;5;237mr\033[38;5;235m;\033[38;5;234m:\033[38;5;234m:\033[38;5;234m:\033[38;5;181mH\033[38;5;230mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;230m9\033[38;5;96m5\033[38;5;236mi\033[38;5;231mB\033[38;5;231m@\033[38;5;225m9\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;225m9\033[38;5;188mS\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[0m");
    $display("\033[38;5;236mi\033[38;5;233m,\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;233m,\033[38;5;234m:\033[38;5;235m:\033[38;5;234m:\033[38;5;233m,\033[38;5;233m,\033[38;5;234m:\033[38;5;235m;\033[38;5;235m;\033[38;5;236m;\033[38;5;237mr\033[38;5;60mA\033[38;5;102m3\033[38;5;145mH\033[38;5;181mG\033[38;5;181mH\033[38;5;95mA\033[38;5;235m;\033[38;5;234m,\033[38;5;233m.\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;234m:\033[38;5;236m;\033[38;5;234m:\033[38;5;233m,\033[38;5;234m:\033[38;5;234m:\033[38;5;239mX\033[38;5;101m3\033[38;5;95m5\033[38;5;95mA\033[38;5;237mi\033[38;5;234m:\033[38;5;235m:\033[38;5;234m:\033[38;5;234m:\033[38;5;234m:\033[38;5;236mi\033[38;5;181mG\033[38;5;230mB\033[38;5;230mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;230mB\033[38;5;223mS\033[38;5;59mX\033[38;5;17m,\033[38;5;235m;\033[38;5;253m#\033[38;5;231mB\033[38;5;231mB\033[38;5;225m9\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;224m#\033[38;5;181mG\033[38;5;181mH\033[0m");
    $display("\033[38;5;234m,\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;234m,\033[38;5;234m:\033[38;5;233m.\033[38;5;16m \033[38;5;16m \033[38;5;233m.\033[38;5;234m:\033[38;5;234m:\033[38;5;234m:\033[38;5;234m:\033[38;5;234m:\033[38;5;17m:\033[38;5;17m:\033[38;5;17m:\033[38;5;236mi\033[38;5;96m5\033[38;5;181mH\033[38;5;181mG\033[38;5;95m2\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;234m:\033[38;5;232m.\033[38;5;234m,\033[38;5;234m:\033[38;5;236mi\033[38;5;95mA\033[38;5;101m5\033[38;5;95m2\033[38;5;235m;\033[38;5;234m:\033[38;5;234m:\033[38;5;234m:\033[38;5;234m:\033[38;5;233m,\033[38;5;233m,\033[38;5;240mX\033[38;5;145mH\033[38;5;59mX\033[38;5;138mM\033[38;5;224m9\033[38;5;223m9\033[38;5;230m9\033[38;5;230mB\033[38;5;230m9\033[38;5;224m9\033[38;5;181mG\033[38;5;138m3\033[38;5;236m;\033[38;5;232m.\033[38;5;236mi\033[38;5;238ms\033[38;5;145mM\033[38;5;224m9\033[38;5;224m#\033[38;5;224m9\033[38;5;254m9\033[38;5;231mB\033[38;5;231m9\033[38;5;231m9\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;224m#\033[38;5;217mG\033[0m");
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;233m.\033[38;5;233m,\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;233m,\033[38;5;234m:\033[38;5;234m,\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;234m,\033[38;5;234m:\033[38;5;234m:\033[38;5;234m:\033[38;5;234m:\033[38;5;239ms\033[38;5;223m#\033[38;5;181mH\033[38;5;235m;\033[38;5;238mr\033[38;5;232m.\033[38;5;233m.\033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;234m:\033[38;5;95m2\033[38;5;144mM\033[38;5;238ms\033[38;5;233m,\033[38;5;232m.\033[38;5;16m \033[38;5;234m:\033[38;5;235m;\033[38;5;238mr\033[38;5;144mM\033[38;5;250mG\033[38;5;236mi\033[38;5;233m,\033[38;5;236mi\033[38;5;236mi\033[38;5;236m;\033[38;5;236mi\033[38;5;236mi\033[38;5;235m;\033[38;5;234m:\033[38;5;232m.\033[38;5;16m \033[38;5;232m.\033[38;5;234m:\033[38;5;235m;\033[38;5;235m:\033[38;5;242m2\033[38;5;217mS\033[38;5;175mH\033[38;5;217mS\033[38;5;182mG\033[38;5;231mB\033[38;5;231mB\033[38;5;254m9\033[38;5;254m9\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;225m9\033[0m");
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;232m.\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;233m.\033[38;5;232m.\033[38;5;232m.\033[38;5;233m.\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;233m,\033[38;5;16m \033[38;5;245m3\033[38;5;187mS\033[38;5;240mX\033[38;5;95m2\033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;233m.\033[38;5;16m \033[38;5;233m,\033[38;5;59mX\033[38;5;138mh\033[38;5;95m2\033[38;5;234m:\033[38;5;233m.\033[38;5;232m.\033[38;5;233m.\033[38;5;235m;\033[38;5;236mi\033[38;5;187m#\033[38;5;230mB\033[38;5;230mB\033[38;5;251mS\033[38;5;241mA\033[38;5;235m;\033[38;5;16m \033[38;5;233m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m.\033[38;5;233m,\033[38;5;233m,\033[38;5;233m.\033[38;5;232m.\033[38;5;233m.\033[38;5;16m \033[38;5;138m3\033[38;5;181mG\033[38;5;181mG\033[38;5;138m3\033[38;5;132m3\033[38;5;254m9\033[38;5;231m@\033[38;5;255mB\033[38;5;225m9\033[38;5;255mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[0m");
    $display("\033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;233m.\033[38;5;233m.\033[38;5;233m,\033[38;5;233m.\033[38;5;233m.\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;238mr\033[38;5;231mB\033[38;5;243m2\033[38;5;139mM\033[38;5;234m:\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;234m:\033[38;5;234m:\033[38;5;239ms\033[38;5;144mM\033[38;5;239ms\033[38;5;233m.\033[38;5;233m.\033[38;5;16m \033[38;5;232m.\033[38;5;234m,\033[38;5;17m \033[38;5;102m3\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;252m#\033[38;5;238mr\033[38;5;232m.\033[38;5;237mr\033[38;5;60mA\033[38;5;239ms\033[38;5;235m;\033[38;5;233m.\033[38;5;232m.\033[38;5;233m.\033[38;5;233m.\033[38;5;232m.\033[38;5;16m \033[38;5;233m,\033[38;5;181mG\033[38;5;181mG\033[38;5;138mh\033[38;5;96mA\033[38;5;132m5\033[38;5;254m9\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[0m");
    $display("\033[38;5;233m.\033[38;5;233m.\033[38;5;233m.\033[38;5;233m.\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;253m#\033[38;5;145mM\033[38;5;181mH\033[38;5;139mh\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;235m;\033[38;5;237mi\033[38;5;95m2\033[38;5;138mh\033[38;5;240mX\033[38;5;16m \033[38;5;233m.\033[38;5;233m.\033[38;5;232m.\033[38;5;233m,\033[38;5;235m;\033[38;5;236m;\033[38;5;249mH\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;223m9\033[38;5;223m#\033[38;5;223m#\033[38;5;240mX\033[38;5;16m \033[38;5;235m:\033[38;5;235m:\033[38;5;234m:\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;236mi\033[38;5;223m#\033[38;5;181mH\033[38;5;95mA\033[38;5;95mA\033[38;5;132m5\033[38;5;231mB\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[0m");
    $display("\033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;145mH\033[38;5;225m#\033[38;5;139mM\033[38;5;59mX\033[38;5;16m \033[38;5;232m.\033[38;5;234m:\033[38;5;238mr\033[38;5;95mA\033[38;5;101m5\033[38;5;237mr\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;232m.\033[38;5;234m,\033[38;5;237mr\033[38;5;238mr\033[38;5;187m9\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;229m9\033[38;5;223m#\033[38;5;180mS\033[38;5;180mH\033[38;5;234m:\033[38;5;16m \033[38;5;16m \033[38;5;234m:\033[38;5;235m;\033[38;5;234m,\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;239ms\033[38;5;145mM\033[38;5;96m2\033[38;5;95mX\033[38;5;95mX\033[38;5;139mM\033[38;5;231m@\033[38;5;231mB\033[38;5;255mB\033[38;5;224m#\033[38;5;224m#\033[38;5;225m9\033[38;5;225m9\033[38;5;225m9\033[38;5;231mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[0m");
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;236mi\033[38;5;234m:\033[38;5;238ms\033[38;5;239ms\033[38;5;241mA\033[38;5;102m3\033[38;5;238mr\033[38;5;232m.\033[38;5;233m,\033[38;5;232m.\033[38;5;233m.\033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;235m:\033[38;5;237mr\033[38;5;145mH\033[38;5;187m#\033[38;5;223m9\033[38;5;229m9\033[38;5;229mB\033[38;5;229m9\033[38;5;223m9\033[38;5;223m#\033[38;5;235m:\033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;234m:\033[38;5;235m:\033[38;5;236m;\033[38;5;237mi\033[38;5;60mX\033[38;5;60ms\033[38;5;237mr\033[38;5;238mr\033[38;5;59ms\033[38;5;251mS\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;224mS\033[38;5;218mS\033[38;5;218mS\033[38;5;218mS\033[38;5;224m#\033[38;5;224m#\033[38;5;225m9\033[38;5;231mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[0m");
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;138m3\033[38;5;174mh\033[38;5;174mh\033[38;5;237mr\033[38;5;243m2\033[38;5;95m2\033[38;5;243m5\033[38;5;242m2\033[38;5;238mr\033[38;5;232m.\033[38;5;234m,\033[38;5;233m.\033[38;5;233m.\033[38;5;233m,\033[38;5;232m.\033[38;5;232m.\033[38;5;233m,\033[38;5;60mX\033[38;5;236mi\033[38;5;59ms\033[38;5;59mX\033[38;5;241mA\033[38;5;242m2\033[38;5;244m5\033[38;5;138mh\033[38;5;180mH\033[38;5;223m#\033[38;5;237mr\033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;234m:\033[38;5;236mi\033[38;5;238mr\033[38;5;238mr\033[38;5;60ms\033[38;5;237mr\033[38;5;182mG\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;224m#\033[38;5;182mG\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;182mG\033[38;5;182mS\033[38;5;224m#\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[0m");
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;174mh\033[38;5;174mM\033[38;5;174mh\033[38;5;242m2\033[38;5;242m2\033[38;5;239ms\033[38;5;236mi\033[38;5;233m,\033[38;5;16m \033[38;5;233m,\033[38;5;233m,\033[38;5;16m \033[38;5;236m;\033[38;5;232m.\033[38;5;232m.\033[38;5;235m;\033[38;5;60mX\033[38;5;60mX\033[38;5;237mr\033[38;5;246mh\033[38;5;246mh\033[38;5;102m5\033[38;5;59mX\033[38;5;237mi\033[38;5;234m:\033[38;5;233m,\033[38;5;239ms\033[38;5;236mi\033[38;5;233m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;234m:\033[38;5;236mi\033[38;5;237mi\033[38;5;60mX\033[38;5;102m3\033[38;5;231m@\033[38;5;231mB\033[38;5;231m@\033[38;5;224m9\033[38;5;217mG\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;181mH\033[38;5;181mG\033[38;5;224m#\033[38;5;231mB\033[0m");
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;237mr\033[38;5;174mM\033[38;5;174mh\033[38;5;138m3\033[38;5;243m5\033[38;5;59mX\033[38;5;236mi\033[38;5;17m,\033[38;5;234m:\033[38;5;232m.\033[38;5;233m,\033[38;5;16m \033[38;5;234m:\033[38;5;236m;\033[38;5;235m;\033[38;5;233m,\033[38;5;237mr\033[38;5;237mr\033[38;5;238mr\033[38;5;243m2\033[38;5;247mh\033[38;5;60m2\033[38;5;59mX\033[38;5;239ms\033[38;5;237mi\033[38;5;235m;\033[38;5;233m,\033[38;5;233m,\033[38;5;234m:\033[38;5;234m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;232m.\033[38;5;235m;\033[38;5;237mr\033[38;5;60ms\033[38;5;96m2\033[38;5;254m9\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;255mB\033[38;5;255m9\033[38;5;255mB\033[38;5;255mB\033[38;5;255mB\033[38;5;255mB\033[38;5;255m9\033[38;5;224m9\033[38;5;223mS\033[38;5;223mS\033[38;5;230mB\033[0m");
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;95mA\033[38;5;174mM\033[38;5;243m5\033[38;5;241mA\033[38;5;242mA\033[38;5;239ms\033[38;5;233m,\033[38;5;234m,\033[38;5;233m.\033[38;5;235m;\033[38;5;235m;\033[38;5;16m \033[38;5;234m:\033[38;5;16m \033[38;5;234m:\033[38;5;59ms\033[38;5;233m,\033[38;5;16m \033[38;5;235m:\033[38;5;59mX\033[38;5;59mX\033[38;5;236mi\033[38;5;236m;\033[38;5;235m;\033[38;5;234m:\033[38;5;233m,\033[38;5;233m.\033[38;5;16m \033[38;5;232m.\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;237mr\033[38;5;238mr\033[38;5;59ms\033[38;5;224m#\033[38;5;231m@\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;230mB\033[0m");
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;233m,\033[38;5;234m,\033[38;5;233m,\033[38;5;95m2\033[38;5;244m5\033[38;5;59mX\033[38;5;239ms\033[38;5;236m;\033[38;5;16m \033[38;5;233m.\033[38;5;237mr\033[38;5;235m:\033[38;5;234m:\033[38;5;232m.\033[38;5;234m:\033[38;5;60mX\033[38;5;233m,\033[38;5;16m \033[38;5;237mr\033[38;5;234m:\033[38;5;16m \033[38;5;234m,\033[38;5;238mr\033[38;5;236mi\033[38;5;234m:\033[38;5;234m:\033[38;5;234m,\033[38;5;233m,\033[38;5;233m.\033[38;5;232m.\033[38;5;232m.\033[38;5;233m.\033[38;5;234m,\033[38;5;236mi\033[38;5;235m:\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m.\033[38;5;234m:\033[38;5;235m;\033[38;5;233m,\033[38;5;234m:\033[38;5;236m;\033[38;5;235m;\033[38;5;95mA\033[38;5;253m#\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;230mB\033[38;5;224m9\033[38;5;230mB\033[0m");
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;235m:\033[38;5;240mX\033[38;5;95m2\033[38;5;101m5\033[38;5;137m3\033[38;5;137m3\033[38;5;95m5\033[38;5;240mX\033[38;5;236mi\033[38;5;234m:\033[38;5;235m:\033[38;5;236mi\033[38;5;174mh\033[38;5;138mh\033[38;5;241mA\033[38;5;237mr\033[38;5;234m:\033[38;5;233m.\033[38;5;232m.\033[38;5;232m.\033[38;5;235m:\033[38;5;238mr\033[38;5;233m,\033[38;5;16m \033[38;5;234m,\033[38;5;235m:\033[38;5;233m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;234m:\033[38;5;234m:\033[38;5;233m,\033[38;5;233m.\033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;235m;\033[38;5;236mi\033[38;5;234m:\033[38;5;235m;\033[38;5;235m;\033[38;5;235m;\033[38;5;235m;\033[38;5;236m;\033[38;5;237mi\033[38;5;237mr\033[38;5;237mr\033[38;5;233m.\033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;59mX\033[38;5;236mi\033[38;5;235m;\033[38;5;145mM\033[38;5;231m@\033[38;5;231mB\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m#\033[38;5;217mG\033[38;5;181mH\033[38;5;217mG\033[0m");
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;101m5\033[38;5;222mS\033[38;5;223m9\033[38;5;229m9\033[38;5;229m9\033[38;5;223m9\033[38;5;223m#\033[38;5;222mS\033[38;5;180mH\033[38;5;137m3\033[38;5;95mX\033[38;5;95mA\033[38;5;175mM\033[38;5;244m5\033[38;5;237mr\033[38;5;233m.\033[38;5;233m,\033[38;5;232m.\033[38;5;233m.\033[38;5;17m,\033[38;5;235m;\033[38;5;237mr\033[38;5;234m,\033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m.\033[38;5;16m \033[38;5;234m:\033[38;5;234m:\033[38;5;234m:\033[38;5;234m:\033[38;5;234m:\033[38;5;234m,\033[38;5;233m,\033[38;5;233m,\033[38;5;233m.\033[38;5;232m.\033[38;5;233m.\033[38;5;238ms\033[38;5;236mi\033[38;5;234m,\033[38;5;234m:\033[38;5;234m:\033[38;5;234m:\033[38;5;233m,\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;235m;\033[38;5;95m2\033[38;5;236mi\033[38;5;232m.\033[38;5;96m5\033[38;5;255mB\033[38;5;217mG\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[0m");
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;95mA\033[38;5;180mG\033[38;5;222m#\033[38;5;222m#\033[38;5;223m#\033[38;5;222m#\033[38;5;222mS\033[38;5;180mG\033[38;5;180mH\033[38;5;174mM\033[38;5;137m3\033[38;5;132m3\033[38;5;59mX\033[38;5;242m2\033[38;5;235m;\033[38;5;234m:\033[38;5;234m,\033[38;5;16m \033[38;5;17m,\033[38;5;17m:\033[38;5;235m:\033[38;5;235m:\033[38;5;17m:\033[38;5;233m.\033[38;5;17m,\033[38;5;233m.\033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;233m.\033[38;5;16m \033[38;5;237mr\033[38;5;237mr\033[38;5;235m:\033[38;5;235m:\033[38;5;235m;\033[38;5;236mi\033[38;5;235m;\033[38;5;234m:\033[38;5;234m,\033[38;5;234m,\033[38;5;233m,\033[38;5;235m:\033[38;5;238mr\033[38;5;234m:\033[38;5;235m:\033[38;5;235m;\033[38;5;235m:\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;239ms\033[38;5;236mi\033[38;5;235m:\033[38;5;234m:\033[38;5;247mM\033[38;5;255mB\033[38;5;181mG\033[38;5;181mG\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mG\033[0m");
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;238mr\033[38;5;101m5\033[38;5;180mG\033[38;5;223m#\033[38;5;223m9\033[38;5;223m9\033[38;5;223m#\033[38;5;222mS\033[38;5;180mG\033[38;5;180mH\033[38;5;137mh\033[38;5;131m3\033[38;5;95mA\033[38;5;235m;\033[38;5;241mA\033[38;5;234m:\033[38;5;233m.\033[38;5;232m.\033[38;5;16m \033[38;5;233m,\033[38;5;233m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;234m:\033[38;5;16m \033[38;5;16m \033[38;5;236mi\033[38;5;238ms\033[38;5;238mr\033[38;5;236mi\033[38;5;235m;\033[38;5;235m;\033[38;5;236m;\033[38;5;235m:\033[38;5;233m,\033[38;5;232m.\033[38;5;16m \033[38;5;232m.\033[38;5;236m;\033[38;5;232m.\033[38;5;232m.\033[38;5;233m,\033[38;5;233m,\033[38;5;233m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;237mr\033[38;5;237mr\033[38;5;236mi\033[38;5;60m2\033[38;5;188m#\033[38;5;231m@\033[38;5;224m#\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[0m");
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;239ms\033[38;5;132m5\033[38;5;101m5\033[38;5;186mS\033[38;5;223m9\033[38;5;223m9\033[38;5;223m9\033[38;5;223m#\033[38;5;222mS\033[38;5;180mG\033[38;5;180mM\033[38;5;137mh\033[38;5;138m3\033[38;5;235m;\033[38;5;237mr\033[38;5;240mX\033[38;5;233m.\033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;233m.\033[38;5;234m:\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;234m,\033[38;5;16m \033[38;5;16m \033[38;5;235m;\033[38;5;59mX\033[38;5;60m2\033[38;5;59mX\033[38;5;235m;\033[38;5;234m:\033[38;5;235m:\033[38;5;234m:\033[38;5;233m,\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;235m;\033[38;5;239mX\033[38;5;239ms\033[38;5;188mS\033[38;5;231m@\033[38;5;231m@\033[38;5;224m#\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[0m");
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;235m;\033[38;5;132m5\033[38;5;95m2\033[38;5;137m3\033[38;5;222m#\033[38;5;223m9\033[38;5;229m9\033[38;5;223m9\033[38;5;222m#\033[38;5;222mS\033[38;5;180mG\033[38;5;180mM\033[38;5;137m3\033[38;5;138m3\033[38;5;234m:\033[38;5;235m;\033[38;5;95m2\033[38;5;235m;\033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;233m,\033[38;5;16m \033[38;5;232m.\033[38;5;233m,\033[38;5;17m:\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;232m.\033[38;5;232m.\033[38;5;234m,\033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;233m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;234m:\033[38;5;240mX\033[38;5;233m,\033[38;5;249mH\033[38;5;231mB\033[38;5;253m#\033[38;5;181mG\033[38;5;181mH\033[38;5;181mH\033[38;5;181mH\033[38;5;175mH\033[38;5;175mH\033[38;5;175mH\033[38;5;181mH\033[38;5;181mH\033[0m");
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m.\033[38;5;95m2\033[38;5;95m5\033[38;5;95m2\033[38;5;137mh\033[38;5;223m#\033[38;5;223m9\033[38;5;229m9\033[38;5;223m9\033[38;5;222m#\033[38;5;222mS\033[38;5;180mG\033[38;5;180mM\033[38;5;137m3\033[38;5;132m3\033[38;5;234m:\033[38;5;234m,\033[38;5;239ms\033[38;5;237mr\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;233m,\033[38;5;233m.\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;233m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;237mr\033[38;5;240mX\033[38;5;181mH\033[38;5;181mG\033[38;5;181mH\033[38;5;175mH\033[38;5;175mH\033[38;5;175mM\033[38;5;175mM\033[38;5;175mM\033[38;5;175mM\033[38;5;175mM\033[38;5;175mM\033[38;5;175mH\033[0m");
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;238ms\033[38;5;132m5\033[38;5;95m2\033[38;5;95m2\033[38;5;144mM\033[38;5;223m#\033[38;5;223m9\033[38;5;223m9\033[38;5;223m9\033[38;5;223m#\033[38;5;222mS\033[38;5;180mG\033[38;5;174mM\033[38;5;131m5\033[38;5;138m3\033[38;5;237mr\033[38;5;16m \033[38;5;235m;\033[38;5;237mr\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;233m.\033[38;5;233m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;232m.\033[38;5;236mi\033[38;5;95m2\033[38;5;138mh\033[38;5;174mM\033[38;5;175mM\033[38;5;175mM\033[38;5;175mM\033[38;5;175mM\033[38;5;175mM\033[38;5;175mM\033[38;5;174mM\033[38;5;174mM\033[38;5;174mM\033[38;5;175mM\033[38;5;175mM\033[0m");
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;237mi\033[38;5;138mh\033[38;5;138m3\033[38;5;132m5\033[38;5;95m2\033[38;5;180mH\033[38;5;223m#\033[38;5;223m9\033[38;5;223m9\033[38;5;223m#\033[38;5;222m#\033[38;5;222mS\033[38;5;180mH\033[38;5;137mh\033[38;5;131m5\033[38;5;138mh\033[38;5;138m3\033[38;5;234m:\033[38;5;235m;\033[38;5;236m;\033[38;5;233m,\033[38;5;232m.\033[38;5;235m:\033[38;5;235m;\033[38;5;234m:\033[38;5;233m,\033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;232m.\033[38;5;236mi\033[38;5;235m:\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;232m.\033[38;5;233m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;95mA\033[38;5;244m5\033[38;5;237mi\033[38;5;233m,\033[38;5;234m:\033[38;5;234m:\033[38;5;235m;\033[38;5;238ms\033[38;5;95mA\033[38;5;138m3\033[38;5;138mh\033[38;5;181mH\033[38;5;138mh\033[38;5;138m3\033[38;5;175mH\033[38;5;175mM\033[38;5;175mM\033[38;5;175mM\033[38;5;175mM\033[38;5;175mM\033[38;5;174mM\033[38;5;174mM\033[38;5;175mM\033[38;5;175mM\033[38;5;175mH\033[0m");
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;234m,\033[38;5;181mH\033[38;5;181mS\033[38;5;181mG\033[38;5;138mM\033[38;5;138m3\033[38;5;180mG\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;222mS\033[38;5;180mG\033[38;5;180mH\033[38;5;137m3\033[38;5;132m5\033[38;5;174mh\033[38;5;138m3\033[38;5;132m5\033[38;5;95mA\033[38;5;238ms\033[38;5;235m;\033[38;5;232m.\033[38;5;234m:\033[38;5;233m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;238mr\033[38;5;101m3\033[38;5;144mM\033[38;5;138mh\033[38;5;59mX\033[38;5;236mi\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;240mX\033[38;5;217mS\033[38;5;174mM\033[38;5;174mh\033[38;5;138m3\033[38;5;95mA\033[38;5;132m3\033[38;5;174mM\033[38;5;174mM\033[38;5;174mM\033[38;5;138m3\033[38;5;174m3\033[38;5;131m3\033[38;5;174mh\033[38;5;174mM\033[38;5;174mM\033[38;5;174mM\033[38;5;174mM\033[38;5;174mM\033[38;5;174mM\033[38;5;174mM\033[38;5;174mM\033[38;5;174mM\033[38;5;174mM\033[38;5;174mM\033[0m");
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;237mi\033[38;5;181mH\033[38;5;181mH\033[38;5;181mG\033[38;5;139mM\033[38;5;138mh\033[38;5;180mG\033[38;5;222mS\033[38;5;223m#\033[38;5;223m#\033[38;5;222mS\033[38;5;222mS\033[38;5;180mG\033[38;5;180mH\033[38;5;137m3\033[38;5;138m3\033[38;5;138mh\033[38;5;132m5\033[38;5;132m5\033[38;5;132m5\033[38;5;138m5\033[38;5;239ms\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;234m:\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;236m;\033[38;5;240mX\033[38;5;138mh\033[38;5;187mG\033[38;5;229mB\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;229mB\033[38;5;223m9\033[38;5;180mG\033[38;5;137m3\033[38;5;240mX\033[38;5;236m;\033[38;5;233m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;95mA\033[38;5;217mG\033[38;5;180mG\033[38;5;217mG\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;223mS\033[38;5;223mS\033[38;5;223m#\033[38;5;181mS\033[38;5;223mS\033[38;5;224m#\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;223m#\033[38;5;224m#\033[0m");
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;102m5\033[38;5;138mh\033[38;5;138mh\033[38;5;138m3\033[38;5;138mh\033[38;5;186mS\033[38;5;222mS\033[38;5;222mS\033[38;5;222mS\033[38;5;222mS\033[38;5;186mS\033[38;5;180mG\033[38;5;180mH\033[38;5;137mh\033[38;5;138m3\033[38;5;132m5\033[38;5;95m5\033[38;5;132m5\033[38;5;132m5\033[38;5;95m2\033[38;5;234m:\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;235m:\033[38;5;232m.\033[38;5;233m.\033[38;5;240mX\033[38;5;138m3\033[38;5;180mH\033[38;5;223m#\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;229mB\033[38;5;229mB\033[38;5;229mB\033[38;5;229m9\033[38;5;223m#\033[38;5;180mG\033[38;5;138mh\033[38;5;95m2\033[38;5;238mr\033[38;5;234m:\033[38;5;232m.\033[38;5;233m.\033[38;5;138mh\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[0m");
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;235m;\033[38;5;95mA\033[38;5;138m5\033[38;5;96m2\033[38;5;138mh\033[38;5;186mS\033[38;5;223mS\033[38;5;186mS\033[38;5;180mG\033[38;5;222mS\033[38;5;222mS\033[38;5;222mS\033[38;5;180mG\033[38;5;138mh\033[38;5;138mh\033[38;5;132m5\033[38;5;95m2\033[38;5;131m5\033[38;5;132m5\033[38;5;238ms\033[38;5;234m:\033[38;5;234m:\033[38;5;233m,\033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;238ms\033[38;5;144mM\033[38;5;144mM\033[38;5;187mS\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;229mB\033[38;5;229mB\033[38;5;229m9\033[38;5;229m9\033[38;5;229m9\033[38;5;229m9\033[38;5;230m9\033[38;5;223m9\033[38;5;224m9\033[38;5;181mG\033[38;5;95m2\033[38;5;52m:\033[38;5;95m2\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[0m");
    $display("\033[38;5;232m.\033[38;5;233m.\033[38;5;16m \033[38;5;16m \033[38;5;234m,\033[38;5;96m5\033[38;5;95m2\033[38;5;144mM\033[38;5;222mS\033[38;5;186mS\033[38;5;180mG\033[38;5;180mG\033[38;5;222mS\033[38;5;223m#\033[38;5;223m#\033[38;5;186mS\033[38;5;180mM\033[38;5;138mh\033[38;5;95m2\033[38;5;95m2\033[38;5;95m2\033[38;5;131m5\033[38;5;132m5\033[38;5;95m2\033[38;5;131m2\033[38;5;167m3\033[38;5;95mX\033[38;5;235m:\033[38;5;240mX\033[38;5;144mM\033[38;5;144mM\033[38;5;181mG\033[38;5;223m#\033[38;5;223m#\033[38;5;223m9\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;229mB\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;229mB\033[38;5;229mB\033[38;5;229mB\033[38;5;229m9\033[38;5;229m9\033[38;5;223m9\033[38;5;223m9\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;224m#\033[38;5;217mS\033[38;5;138mh\033[38;5;255mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;230mB\033[38;5;231mB\033[38;5;231mB\033[38;5;255mB\033[38;5;255mB\033[38;5;230mB\033[38;5;255mB\033[38;5;255mB\033[38;5;255mB\033[38;5;230m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m#\033[38;5;223mS\033[38;5;216mG\033[38;5;217mG\033[0m"); 

end endtask

task GEN_task; begin
    $display("\033[38;5;245m3\033[38;5;245m3\033[38;5;102m3\033[38;5;102m3\033[38;5;102m3\033[38;5;244m3\033[38;5;244m3\033[38;5;244m3\033[38;5;244m3\033[38;5;244m3\033[38;5;244m3\033[38;5;102m3\033[38;5;102m3\033[38;5;102m3\033[38;5;102m3\033[38;5;102m3\033[38;5;245m3\033[38;5;245m3\033[38;5;245m3\033[38;5;245m3\033[38;5;245m3\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;144mh\033[38;5;144mh\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138m3\033[38;5;137m3\033[38;5;137m3\033[38;5;101m3\033[38;5;101m3\033[38;5;101m3\033[38;5;101m5\033[38;5;101m3\033[38;5;101m5\033[38;5;101m5\033[38;5;101m5\033[38;5;101m5\033[38;5;101m5\033[38;5;101m3\033[38;5;101m3\033[38;5;101m3\033[38;5;101m3\033[38;5;137m3\033[38;5;137m3\033[38;5;137mh\033[38;5;137mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[0m");
    $display("\033[38;5;244m5\033[38;5;244m5\033[38;5;244m5\033[38;5;244m5\033[38;5;244m5\033[38;5;244m3\033[38;5;102m3\033[38;5;102m3\033[38;5;102m3\033[38;5;245m3\033[38;5;245m3\033[38;5;245mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;144mh\033[38;5;144mh\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;180mH\033[38;5;187mS\033[38;5;138mh\033[38;5;138m3\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mH\033[38;5;180mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mM\033[38;5;144mM\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;144mM\033[38;5;144mM\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;137mh\033[38;5;137mh\033[38;5;137m3\033[38;5;137m3\033[38;5;137m3\033[38;5;137m3\033[38;5;137m3\033[38;5;137m3\033[38;5;137m3\033[38;5;137m3\033[0m");
    $display("\033[38;5;245m3\033[38;5;245m3\033[38;5;245m3\033[38;5;245m3\033[38;5;245m3\033[38;5;245mh\033[38;5;246mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;144mh\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mH\033[38;5;144mH\033[38;5;180mH\033[38;5;187mS\033[38;5;138m3\033[38;5;138mh\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mH\033[38;5;144mM\033[38;5;138mh\033[38;5;101m5\033[38;5;241mA\033[38;5;240mX\033[38;5;240mX\033[38;5;240mX\033[38;5;59mA\033[38;5;95m2\033[38;5;101m2\033[38;5;101m5\033[38;5;137m3\033[38;5;137m3\033[38;5;137m3\033[38;5;137mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;144mM\033[38;5;138mh\033[38;5;138mh\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;180mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;138mh\033[0m");
    $display("\033[38;5;246mh\033[38;5;246mh\033[38;5;246mh\033[38;5;246mh\033[38;5;246mh\033[38;5;246mh\033[38;5;246mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;144mh\033[38;5;144mh\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;180mH\033[38;5;187m#\033[38;5;138mh\033[38;5;138mh\033[38;5;144mM\033[38;5;144mM\033[38;5;144mH\033[38;5;144mH\033[38;5;101m3\033[38;5;239mX\033[38;5;236mi\033[38;5;235m;\033[38;5;236mi\033[38;5;236mi\033[38;5;235m;\033[38;5;236m;\033[38;5;236mi\033[38;5;235m;\033[38;5;236mi\033[38;5;237mr\033[38;5;240mX\033[38;5;95m2\033[38;5;101m5\033[38;5;101m3\033[38;5;101m3\033[38;5;137m3\033[38;5;137m3\033[38;5;138mh\033[38;5;137mh\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;144mH\033[0m");
    $display("\033[38;5;144mh\033[38;5;144mh\033[38;5;144mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;144mh\033[38;5;144mh\033[38;5;144mh\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mG\033[38;5;223m#\033[38;5;138mh\033[38;5;138mh\033[38;5;144mH\033[38;5;144mH\033[38;5;144mM\033[38;5;59mA\033[38;5;236mi\033[38;5;236m;\033[38;5;237mr\033[38;5;238mr\033[38;5;235m;\033[38;5;237mr\033[38;5;235m;\033[38;5;236mi\033[38;5;237mr\033[38;5;234m,\033[38;5;236mi\033[38;5;234m:\033[38;5;235m:\033[38;5;237mr\033[38;5;240mX\033[38;5;101m5\033[38;5;101m3\033[38;5;137m3\033[38;5;137m3\033[38;5;138mh\033[38;5;138mh\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mH\033[38;5;144mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[0m");
    $display("\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;144mh\033[38;5;144mh\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;180mH\033[38;5;180mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;181mG\033[38;5;101m5\033[38;5;101m5\033[38;5;245m3\033[38;5;245m3\033[38;5;240mX\033[38;5;236mi\033[38;5;236mi\033[38;5;238ms\033[38;5;238mr\033[38;5;237mr\033[38;5;235m;\033[38;5;234m:\033[38;5;234m:\033[38;5;235m;\033[38;5;236mi\033[38;5;235m:\033[38;5;234m:\033[38;5;234m:\033[38;5;237mi\033[38;5;234m:\033[38;5;237mr\033[38;5;239ms\033[38;5;101m5\033[38;5;101m3\033[38;5;101m3\033[38;5;138mh\033[38;5;138mh\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mH\033[38;5;144mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[0m");
    $display("\033[38;5;144mH\033[38;5;144mH\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;138mh\033[38;5;138mh\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mM\033[38;5;138mh\033[38;5;101m5\033[38;5;241mA\033[38;5;240mX\033[38;5;238mr\033[38;5;236mi\033[38;5;234m:\033[38;5;234m:\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;234m,\033[38;5;236m;\033[38;5;236m;\033[38;5;236m;\033[38;5;235m;\033[38;5;234m:\033[38;5;234m:\033[38;5;235m:\033[38;5;238mr\033[38;5;234m:\033[38;5;234m:\033[38;5;234m:\033[38;5;236mi\033[38;5;236m;\033[38;5;235m;\033[38;5;238mr\033[38;5;240mA\033[38;5;101m3\033[38;5;101m3\033[38;5;138mh\033[38;5;138mh\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mH\033[38;5;144mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[0m");
    $display("\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mH\033[38;5;144mM\033[38;5;144mM\033[38;5;138mh\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;138mh\033[38;5;243m5\033[38;5;59mX\033[38;5;238mr\033[38;5;236mi\033[38;5;235m:\033[38;5;233m,\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;234m:\033[38;5;235m;\033[38;5;233m,\033[38;5;234m,\033[38;5;233m,\033[38;5;235m;\033[38;5;236m;\033[38;5;235m;\033[38;5;238mr\033[38;5;240mX\033[38;5;101m3\033[38;5;101m5\033[38;5;138m3\033[38;5;138mh\033[38;5;144mM\033[38;5;144mM\033[38;5;144mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[0m");
    $display("\033[38;5;245m3\033[38;5;138mh\033[38;5;144mh\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;102m3\033[38;5;240mX\033[38;5;236mi\033[38;5;235m;\033[38;5;234m:\033[38;5;233m,\033[38;5;233m.\033[38;5;233m.\033[38;5;233m.\033[38;5;233m.\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;233m.\033[38;5;233m,\033[38;5;233m.\033[38;5;233m.\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;233m.\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;235m:\033[38;5;237mi\033[38;5;101m2\033[38;5;138mh\033[38;5;138m3\033[38;5;138mh\033[38;5;138mh\033[38;5;144mM\033[38;5;144mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mG\033[38;5;180mG\033[38;5;180mG\033[38;5;180mG\033[38;5;180mG\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[0m");
    $display("\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mh\033[38;5;138mh\033[38;5;243m2\033[38;5;238mr\033[38;5;235m;\033[38;5;234m:\033[38;5;234m:\033[38;5;234m,\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;233m.\033[38;5;233m.\033[38;5;233m.\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;233m.\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;232m.\033[38;5;233m.\033[38;5;235m;\033[38;5;240mX\033[38;5;138mh\033[38;5;181mG\033[38;5;144mM\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mG\033[38;5;180mG\033[38;5;180mG\033[38;5;180mG\033[38;5;180mG\033[38;5;180mG\033[38;5;180mG\033[38;5;180mG\033[38;5;180mG\033[38;5;180mG\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[0m");
    $display("\033[38;5;244m3\033[38;5;102m3\033[38;5;245m3\033[38;5;245mh\033[38;5;245mh\033[38;5;245m3\033[38;5;246mh\033[38;5;246mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;144mH\033[38;5;181mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;138mh\033[38;5;138mh\033[38;5;243m5\033[38;5;239ms\033[38;5;235m;\033[38;5;234m:\033[38;5;234m:\033[38;5;235m:\033[38;5;234m:\033[38;5;234m:\033[38;5;233m.\033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;233m.\033[38;5;233m.\033[38;5;233m.\033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;239ms\033[38;5;101m5\033[38;5;180mH\033[38;5;180mG\033[38;5;144mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[0m");
    $display("\033[38;5;239ms\033[38;5;239mX\033[38;5;238mr\033[38;5;237mi\033[38;5;238ms\033[38;5;239ms\033[38;5;239mX\033[38;5;240mX\033[38;5;240mX\033[38;5;59mA\033[38;5;239mX\033[38;5;144mh\033[38;5;181mG\033[38;5;144mM\033[38;5;246mh\033[38;5;239mX\033[38;5;241mA\033[38;5;59mA\033[38;5;59mX\033[38;5;240mX\033[38;5;238ms\033[38;5;235m;\033[38;5;234m:\033[38;5;235m;\033[38;5;235m;\033[38;5;235m;\033[38;5;235m:\033[38;5;233m,\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;238mr\033[38;5;144mM\033[38;5;181mG\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[0m");
    $display("\033[38;5;242m2\033[38;5;242m2\033[38;5;242m2\033[38;5;240mX\033[38;5;240mX\033[38;5;240mX\033[38;5;240mX\033[38;5;242m2\033[38;5;242m2\033[38;5;243m2\033[38;5;241mA\033[38;5;144mM\033[38;5;181mG\033[38;5;144mH\033[38;5;144mM\033[38;5;59mA\033[38;5;241mA\033[38;5;241mA\033[38;5;239ms\033[38;5;237mi\033[38;5;235m:\033[38;5;234m:\033[38;5;235m;\033[38;5;236mi\033[38;5;235m;\033[38;5;234m:\033[38;5;233m,\033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;233m.\033[38;5;232m.\033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;240mX\033[38;5;101m5\033[38;5;101m3\033[38;5;101m5\033[38;5;101m3\033[38;5;101m5\033[38;5;101m5\033[38;5;101m5\033[38;5;101m5\033[38;5;101m5\033[38;5;101m5\033[38;5;101m5\033[38;5;101m5\033[38;5;101m5\033[0m");
    $display("\033[38;5;144mM\033[38;5;144mM\033[38;5;187mS\033[38;5;138mh\033[38;5;245m3\033[38;5;138mh\033[38;5;138mh\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;144mH\033[38;5;181mH\033[38;5;144mH\033[38;5;144mh\033[38;5;245m3\033[38;5;239mX\033[38;5;235m;\033[38;5;235m:\033[38;5;235m;\033[38;5;236mi\033[38;5;235m;\033[38;5;235m:\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;234m:\033[38;5;233m.\033[38;5;234m:\033[38;5;233m,\033[38;5;233m.\033[38;5;233m,\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;236mi\033[38;5;101m5\033[38;5;138m3\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;137m3\033[38;5;137m3\033[38;5;137m3\033[38;5;137m3\033[38;5;137m3\033[38;5;137m3\033[38;5;137m3\033[0m");
    $display("\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;249mH\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;181mH\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;181mG\033[38;5;249mH\033[38;5;144mM\033[38;5;240mX\033[38;5;236mi\033[38;5;235m:\033[38;5;235m;\033[38;5;236mi\033[38;5;235m;\033[38;5;235m:\033[38;5;234m,\033[38;5;234m:\033[38;5;235m;\033[38;5;233m,\033[38;5;232m.\033[38;5;233m,\033[38;5;233m,\033[38;5;234m:\033[38;5;234m:\033[38;5;233m,\033[38;5;235m:\033[38;5;234m:\033[38;5;234m,\033[38;5;234m:\033[38;5;233m,\033[38;5;234m:\033[38;5;233m,\033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;233m,\033[38;5;233m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;235m;\033[38;5;138mh\033[38;5;180mH\033[38;5;180mG\033[38;5;180mG\033[38;5;180mG\033[38;5;180mG\033[38;5;180mG\033[38;5;180mG\033[38;5;180mG\033[38;5;180mG\033[38;5;180mH\033[0m");
    $display("\033[38;5;187mS\033[38;5;187mS\033[38;5;187mS\033[38;5;187mS\033[38;5;187mS\033[38;5;187mS\033[38;5;187mS\033[38;5;187mS\033[38;5;187mS\033[38;5;187mS\033[38;5;187mG\033[38;5;187mS\033[38;5;187mS\033[38;5;181mH\033[38;5;144mM\033[38;5;241mA\033[38;5;238mr\033[38;5;236mi\033[38;5;236mi\033[38;5;236mi\033[38;5;236m;\033[38;5;236mi\033[38;5;234m:\033[38;5;234m:\033[38;5;236mi\033[38;5;234m:\033[38;5;232m.\033[38;5;233m,\033[38;5;234m:\033[38;5;235m;\033[38;5;236mi\033[38;5;234m:\033[38;5;235m;\033[38;5;235m;\033[38;5;233m,\033[38;5;234m:\033[38;5;234m:\033[38;5;234m:\033[38;5;234m:\033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m.\033[38;5;234m:\033[38;5;235m;\033[38;5;235m;\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;235m:\033[38;5;102m3\033[38;5;180mH\033[38;5;180mG\033[38;5;180mG\033[38;5;187mS\033[38;5;186mG\033[38;5;180mG\033[38;5;180mG\033[38;5;180mG\033[38;5;180mG\033[0m");
    $display("\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;138mh\033[38;5;144mM\033[38;5;144mM\033[38;5;144mh\033[38;5;144mM\033[38;5;241mA\033[38;5;238mr\033[38;5;237mi\033[38;5;238ms\033[38;5;237mi\033[38;5;235m;\033[38;5;236mi\033[38;5;236mi\033[38;5;234m:\033[38;5;239ms\033[38;5;235m;\033[38;5;233m,\033[38;5;234m,\033[38;5;234m:\033[38;5;235m:\033[38;5;239ms\033[38;5;237mr\033[38;5;235m;\033[38;5;235m;\033[38;5;234m:\033[38;5;234m:\033[38;5;235m;\033[38;5;235m;\033[38;5;234m:\033[38;5;233m.\033[38;5;16m \033[38;5;232m.\033[38;5;235m;\033[38;5;234m:\033[38;5;233m,\033[38;5;232m.\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;234m:\033[38;5;236mi\033[38;5;235m;\033[38;5;237mi\033[38;5;237mi\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;234m:\033[38;5;138mh\033[38;5;187mS\033[38;5;187mS\033[38;5;187mS\033[38;5;187mS\033[38;5;187mS\033[38;5;187mS\033[38;5;187mS\033[38;5;187mS\033[0m");
    $display("\033[38;5;144mH\033[38;5;144mH\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;247mM\033[38;5;247mM\033[38;5;247mh\033[38;5;246mh\033[38;5;138mh\033[38;5;246mh\033[38;5;245mh\033[38;5;138mh\033[38;5;242m2\033[38;5;239ms\033[38;5;237mi\033[38;5;242m2\033[38;5;241mA\033[38;5;237mr\033[38;5;236mi\033[38;5;59mX\033[38;5;235m;\033[38;5;239ms\033[38;5;237mr\033[38;5;234m:\033[38;5;234m,\033[38;5;236mi\033[38;5;234m:\033[38;5;239mX\033[38;5;95mX\033[38;5;239ms\033[38;5;236m;\033[38;5;236mi\033[38;5;234m:\033[38;5;233m,\033[38;5;235m;\033[38;5;236m;\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;234m,\033[38;5;237mr\033[38;5;235m;\033[38;5;234m,\033[38;5;233m,\033[38;5;234m:\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;234m:\033[38;5;237mr\033[38;5;236mi\033[38;5;237mr\033[38;5;238ms\033[38;5;237mr\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;236mi\033[38;5;137m3\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;144mH\033[0m");
    $display("\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;252m#\033[38;5;240mX\033[38;5;239ms\033[38;5;59mX\033[38;5;243m2\033[38;5;95mA\033[38;5;239ms\033[38;5;95mA\033[38;5;95mA\033[38;5;238mr\033[38;5;243m5\033[38;5;235m;\033[38;5;235m;\033[38;5;236mi\033[38;5;237mr\033[38;5;236m;\033[38;5;131m5\033[38;5;95mA\033[38;5;240mX\033[38;5;238mr\033[38;5;238mr\033[38;5;234m:\033[38;5;233m,\033[38;5;235m;\033[38;5;236m;\033[38;5;234m:\033[38;5;16m \033[38;5;16m \033[38;5;235m:\033[38;5;239mX\033[38;5;235m;\033[38;5;234m:\033[38;5;234m:\033[38;5;234m:\033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;233m,\033[38;5;237mi\033[38;5;239ms\033[38;5;238mr\033[38;5;239mX\033[38;5;239ms\033[38;5;236mi\033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;95m2\033[38;5;180mH\033[38;5;216mS\033[38;5;216mS\033[38;5;216mS\033[38;5;216mS\033[38;5;216mS\033[38;5;216mS\033[0m");
    $display("\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;254m9\033[38;5;95mA\033[38;5;59mX\033[38;5;241mA\033[38;5;241mA\033[38;5;95mA\033[38;5;95m2\033[38;5;95mA\033[38;5;138mh\033[38;5;235m;\033[38;5;138m3\033[38;5;243m2\033[38;5;237mi\033[38;5;237mr\033[38;5;95mA\033[38;5;237mr\033[38;5;95mX\033[38;5;131m5\033[38;5;95mA\033[38;5;238mr\033[38;5;239mX\033[38;5;238ms\033[38;5;234m:\033[38;5;234m:\033[38;5;236m;\033[38;5;235m;\033[38;5;235m:\033[38;5;232m.\033[38;5;232m.\033[38;5;235m;\033[38;5;95m2\033[38;5;237mr\033[38;5;234m,\033[38;5;236mi\033[38;5;234m:\033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;233m.\033[38;5;235m;\033[38;5;95mX\033[38;5;239mX\033[38;5;95mX\033[38;5;95mX\033[38;5;238ms\033[38;5;235m;\033[38;5;16m \033[38;5;232m.\033[38;5;233m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;237mi\033[38;5;138mh\033[38;5;216mS\033[38;5;216mG\033[38;5;216mS\033[38;5;222mS\033[38;5;216mS\033[38;5;216mS\033[0m");
    $display("\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;231m@\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231m@\033[38;5;246mh\033[38;5;59mX\033[38;5;241mA\033[38;5;238mr\033[38;5;242mA\033[38;5;102m5\033[38;5;95mA\033[38;5;138mh\033[38;5;243m5\033[38;5;237mr\033[38;5;247mM\033[38;5;241mA\033[38;5;240mX\033[38;5;237mi\033[38;5;95mA\033[38;5;236mi\033[38;5;239mX\033[38;5;239ms\033[38;5;239ms\033[38;5;236mi\033[38;5;95mX\033[38;5;95mX\033[38;5;235m;\033[38;5;235m;\033[38;5;236mi\033[38;5;235m;\033[38;5;236m;\033[38;5;234m,\033[38;5;233m.\033[38;5;235m;\033[38;5;95m2\033[38;5;239ms\033[38;5;234m:\033[38;5;237mr\033[38;5;236mi\033[38;5;16m \033[38;5;16m \033[38;5;234m:\033[38;5;233m.\033[38;5;236m;\033[38;5;95mX\033[38;5;95m2\033[38;5;95mX\033[38;5;95mA\033[38;5;240mX\033[38;5;237mr\033[38;5;234m:\033[38;5;232m.\033[38;5;233m,\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m.\033[38;5;95m2\033[38;5;174mM\033[38;5;180mG\033[38;5;180mH\033[38;5;180mM\033[38;5;216mG\033[38;5;216mS\033[0m");
    $display("\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231m@\033[38;5;253m#\033[38;5;241mA\033[38;5;239mX\033[38;5;237mi\033[38;5;237mr\033[38;5;59mX\033[38;5;244m5\033[38;5;102m5\033[38;5;181mG\033[38;5;59mX\033[38;5;243m5\033[38;5;145mM\033[38;5;238mr\033[38;5;238ms\033[38;5;236mi\033[38;5;237mi\033[38;5;235m;\033[38;5;236m;\033[38;5;236mi\033[38;5;237mr\033[38;5;236m;\033[38;5;239ms\033[38;5;238mr\033[38;5;236mi\033[38;5;235m;\033[38;5;236mi\033[38;5;236mi\033[38;5;237mi\033[38;5;235m;\033[38;5;234m:\033[38;5;236mi\033[38;5;131m5\033[38;5;240mX\033[38;5;235m;\033[38;5;237mi\033[38;5;235m;\033[38;5;232m.\033[38;5;16m \033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;235m;\033[38;5;237mr\033[38;5;236mi\033[38;5;238mr\033[38;5;238mr\033[38;5;238mr\033[38;5;236m;\033[38;5;234m,\033[38;5;233m.\033[38;5;233m,\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;238mr\033[38;5;138mh\033[38;5;174mM\033[38;5;174mM\033[38;5;174mM\033[38;5;180mH\033[38;5;223mS\033[0m");
    $display("\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;247mM\033[38;5;239ms\033[38;5;236mi\033[38;5;237mr\033[38;5;236mi\033[38;5;239ms\033[38;5;138mh\033[38;5;180mM\033[38;5;181mG\033[38;5;237mr\033[38;5;247mM\033[38;5;102m5\033[38;5;239ms\033[38;5;95mA\033[38;5;95mX\033[38;5;95m2\033[38;5;237mr\033[38;5;95mX\033[38;5;95mX\033[38;5;239mX\033[38;5;238mr\033[38;5;95mA\033[38;5;238mr\033[38;5;237mr\033[38;5;236mi\033[38;5;236mi\033[38;5;236m;\033[38;5;236mi\033[38;5;236mi\033[38;5;235m:\033[38;5;236mi\033[38;5;131m5\033[38;5;95mA\033[38;5;236m;\033[38;5;237mi\033[38;5;236m;\033[38;5;234m:\033[38;5;233m,\033[38;5;233m,\033[38;5;234m:\033[38;5;235m:\033[38;5;236mi\033[38;5;238mr\033[38;5;95mX\033[38;5;238mr\033[38;5;237mr\033[38;5;236mi\033[38;5;235m;\033[38;5;234m,\033[38;5;233m,\033[38;5;233m.\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;235m;\033[38;5;137mh\033[38;5;180mH\033[38;5;222mS\033[38;5;222mS\033[38;5;216mS\033[38;5;223mS\033[0m");
    $display("\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231m@\033[38;5;253m#\033[38;5;59mX\033[38;5;235m;\033[38;5;234m,\033[38;5;237mr\033[38;5;235m;\033[38;5;242m2\033[38;5;138m3\033[38;5;187mS\033[38;5;145mH\033[38;5;238mr\033[38;5;251mS\033[38;5;95mA\033[38;5;95mX\033[38;5;131m5\033[38;5;95mX\033[38;5;95mA\033[38;5;237mi\033[38;5;238mr\033[38;5;95mA\033[38;5;239ms\033[38;5;237mr\033[38;5;95m2\033[38;5;239ms\033[38;5;237mi\033[38;5;235m;\033[38;5;237mi\033[38;5;235m:\033[38;5;236m;\033[38;5;236mi\033[38;5;235m;\033[38;5;237mi\033[38;5;95mA\033[38;5;239ms\033[38;5;236mi\033[38;5;235m;\033[38;5;235m;\033[38;5;237mi\033[38;5;234m:\033[38;5;234m,\033[38;5;234m:\033[38;5;235m;\033[38;5;95mX\033[38;5;95m2\033[38;5;137m5\033[38;5;95m2\033[38;5;131m5\033[38;5;95mX\033[38;5;238mr\033[38;5;235m;\033[38;5;233m.\033[38;5;232m.\033[38;5;233m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m.\033[38;5;137m3\033[38;5;216mG\033[38;5;216mS\033[38;5;216mS\033[38;5;217mS\033[38;5;223m#\033[0m");
    $display("\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;231m@\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;246mh\033[38;5;235m;\033[38;5;234m:\033[38;5;232m.\033[38;5;234m:\033[38;5;237mr\033[38;5;243m5\033[38;5;180mH\033[38;5;231mB\033[38;5;138m3\033[38;5;95mA\033[38;5;224m9\033[38;5;240mX\033[38;5;131m5\033[38;5;137m5\033[38;5;95mX\033[38;5;239ms\033[38;5;237mr\033[38;5;238ms\033[38;5;95mX\033[38;5;95mX\033[38;5;95mA\033[38;5;131m5\033[38;5;95m2\033[38;5;237mi\033[38;5;237mr\033[38;5;236mi\033[38;5;234m,\033[38;5;234m:\033[38;5;235m;\033[38;5;233m,\033[38;5;236mi\033[38;5;238mr\033[38;5;237mr\033[38;5;235m;\033[38;5;233m,\033[38;5;235m;\033[38;5;236mi\033[38;5;234m:\033[38;5;233m.\033[38;5;16m \033[38;5;235m:\033[38;5;95mX\033[38;5;95m2\033[38;5;131m5\033[38;5;131m5\033[38;5;131m5\033[38;5;131m5\033[38;5;95mA\033[38;5;239ms\033[38;5;234m:\033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;95m5\033[38;5;216mS\033[38;5;216mS\033[38;5;216mS\033[38;5;223mS\033[38;5;223mS\033[0m");
    $display("\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;231mB\033[38;5;255m9\033[38;5;238ms\033[38;5;234m:\033[38;5;234m:\033[38;5;232m.\033[38;5;239mX\033[38;5;240mX\033[38;5;95m2\033[38;5;187mS\033[38;5;231mB\033[38;5;138m5\033[38;5;138mh\033[38;5;255mB\033[38;5;181mH\033[38;5;95mA\033[38;5;239ms\033[38;5;95m5\033[38;5;247mM\033[38;5;244m5\033[38;5;239ms\033[38;5;237mr\033[38;5;95mA\033[38;5;131m5\033[38;5;174mM\033[38;5;180mH\033[38;5;174mh\033[38;5;180mH\033[38;5;174mM\033[38;5;137m3\033[38;5;95m2\033[38;5;131m5\033[38;5;95mA\033[38;5;95mA\033[38;5;95mA\033[38;5;95mX\033[38;5;239ms\033[38;5;239ms\033[38;5;95mA\033[38;5;95mA\033[38;5;236mi\033[38;5;235m;\033[38;5;239ms\033[38;5;237mi\033[38;5;237mr\033[38;5;239ms\033[38;5;95mA\033[38;5;239ms\033[38;5;239ms\033[38;5;95mA\033[38;5;95m2\033[38;5;95mA\033[38;5;236mi\033[38;5;233m,\033[38;5;232m.\033[38;5;16m \033[38;5;233m,\033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;95m2\033[38;5;180mG\033[38;5;216mS\033[38;5;216mG\033[38;5;223mS\033[38;5;217mS\033[0m");
    $display("\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;231m@\033[38;5;250mG\033[38;5;233m,\033[38;5;234m:\033[38;5;233m,\033[38;5;238mr\033[38;5;95mX\033[38;5;240mX\033[38;5;243m2\033[38;5;188m#\033[38;5;231mB\033[38;5;138m3\033[38;5;250mG\033[38;5;255mB\033[38;5;174mh\033[38;5;138mh\033[38;5;181mH\033[38;5;231mB\033[38;5;188m#\033[38;5;234m:\033[38;5;235m;\033[38;5;16m \033[38;5;233m.\033[38;5;138mh\033[38;5;174mM\033[38;5;217mS\033[38;5;223mS\033[38;5;223mS\033[38;5;223m#\033[38;5;223m9\033[38;5;224m9\033[38;5;224m9\033[38;5;223m#\033[38;5;216mG\033[38;5;173mh\033[38;5;173m3\033[38;5;174mM\033[38;5;216mG\033[38;5;216mH\033[38;5;131m5\033[38;5;138m3\033[38;5;255m9\033[38;5;244m5\033[38;5;236m;\033[38;5;233m,\033[38;5;16m \033[38;5;238mr\033[38;5;247mM\033[38;5;239ms\033[38;5;236mi\033[38;5;238mr\033[38;5;239ms\033[38;5;237mr\033[38;5;236mi\033[38;5;235m;\033[38;5;233m.\033[38;5;235m;\033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;95mA\033[38;5;180mH\033[38;5;217mS\033[38;5;217mS\033[38;5;223mS\033[38;5;223mS\033[0m");
    $display("\033[38;5;249mG\033[38;5;249mG\033[38;5;249mG\033[38;5;249mG\033[38;5;250mG\033[38;5;251mS\033[38;5;250mG\033[38;5;250mG\033[38;5;243m5\033[38;5;233m,\033[38;5;232m.\033[38;5;233m,\033[38;5;138mh\033[38;5;96m5\033[38;5;138m5\033[38;5;174mM\033[38;5;224m#\033[38;5;231mB\033[38;5;138mh\033[38;5;253m#\033[38;5;231mB\033[38;5;224m9\033[38;5;231mB\033[38;5;217mG\033[38;5;217mG\033[38;5;180mH\033[38;5;95m2\033[38;5;95mX\033[38;5;239ms\033[38;5;238ms\033[38;5;174mh\033[38;5;216mG\033[38;5;223mS\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;217mS\033[38;5;174mM\033[38;5;173m3\033[38;5;174mh\033[38;5;174mH\033[38;5;217mS\033[38;5;217mS\033[38;5;131m3\033[38;5;180mH\033[38;5;181mS\033[38;5;95m2\033[38;5;238ms\033[38;5;237mr\033[38;5;235m;\033[38;5;237mr\033[38;5;131m2\033[38;5;95mX\033[38;5;95ms\033[38;5;238mr\033[38;5;238mr\033[38;5;239ms\033[38;5;95mX\033[38;5;239ms\033[38;5;236mi\033[38;5;236m;\033[38;5;233m,\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;237mi\033[38;5;238mr\033[38;5;235m:\033[38;5;16m \033[38;5;241mA\033[38;5;138mM\033[38;5;180mH\033[38;5;180mH\033[38;5;180mG\033[38;5;180mH\033[0m");
    $display("\033[38;5;239ms\033[38;5;240mX\033[38;5;59mX\033[38;5;242mA\033[38;5;241mA\033[38;5;241mA\033[38;5;239ms\033[38;5;238ms\033[38;5;236mi\033[38;5;233m,\033[38;5;16m \033[38;5;232m.\033[38;5;95m5\033[38;5;216mG\033[38;5;181mG\033[38;5;217mS\033[38;5;224m9\033[38;5;231mB\033[38;5;95m5\033[38;5;253m9\033[38;5;231mB\033[38;5;255m9\033[38;5;224m9\033[38;5;223m#\033[38;5;223mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mG\033[38;5;217mS\033[38;5;217mS\033[38;5;223m#\033[38;5;224m9\033[38;5;224m9\033[38;5;223m9\033[38;5;223m#\033[38;5;223m9\033[38;5;223m#\033[38;5;223m#\033[38;5;216mG\033[38;5;173mh\033[38;5;137m3\033[38;5;174mh\033[38;5;216mH\033[38;5;217mS\033[38;5;223m#\033[38;5;223mS\033[38;5;217mG\033[38;5;210mH\033[38;5;216mG\033[38;5;216mG\033[38;5;210mH\033[38;5;210mM\033[38;5;174mM\033[38;5;173m3\033[38;5;173m3\033[38;5;137m3\033[38;5;137m3\033[38;5;131m5\033[38;5;131m5\033[38;5;95m2\033[38;5;95mA\033[38;5;237mr\033[38;5;236mi\033[38;5;233m,\033[38;5;233m.\033[38;5;16m \033[38;5;233m,\033[38;5;235m;\033[38;5;238mr\033[38;5;236m;\033[38;5;52m;\033[38;5;237mi\033[38;5;16m \033[38;5;237mr\033[38;5;242m2\033[38;5;239mX\033[38;5;239ms\033[38;5;241mA\033[38;5;241mA\033[0m");
    $display("\033[38;5;253m#\033[38;5;253m#\033[38;5;224m9\033[38;5;224m#\033[38;5;224m9\033[38;5;188m#\033[38;5;250mG\033[38;5;246mh\033[38;5;238ms\033[38;5;232m.\033[38;5;16m \033[38;5;233m.\033[38;5;234m,\033[38;5;180mH\033[38;5;223m#\033[38;5;223mS\033[38;5;224m9\033[38;5;255mB\033[38;5;244m5\033[38;5;255mB\033[38;5;231mB\033[38;5;224m9\033[38;5;224m9\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;223m#\033[38;5;223mS\033[38;5;216mG\033[38;5;173m3\033[38;5;137m3\033[38;5;137m3\033[38;5;174mH\033[38;5;217mS\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;216mG\033[38;5;174mM\033[38;5;137mh\033[38;5;131m2\033[38;5;95mA\033[38;5;238ms\033[38;5;237mi\033[38;5;233m,\033[38;5;232m.\033[38;5;232m.\033[38;5;233m,\033[38;5;237mr\033[38;5;240mX\033[38;5;235m;\033[38;5;237mi\033[38;5;234m:\033[38;5;16m \033[38;5;239mX\033[38;5;95m2\033[38;5;95mA\033[38;5;95m2\033[38;5;95m5\033[38;5;101m5\033[0m");
    $display("\033[38;5;231mB\033[38;5;231mB\033[38;5;249mH\033[38;5;246mh\033[38;5;249mH\033[38;5;246mh\033[38;5;243m5\033[38;5;241mA\033[38;5;237mr\033[38;5;232m.\033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;95m5\033[38;5;223m#\033[38;5;217mS\033[38;5;223mS\033[38;5;224m9\033[38;5;95m2\033[38;5;231mB\033[38;5;230m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;223m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;223m#\033[38;5;217mS\033[38;5;216mH\033[38;5;131m3\033[38;5;131m5\033[38;5;131m3\033[38;5;174mh\033[38;5;217mG\033[38;5;223mS\033[38;5;223mS\033[38;5;223mS\033[38;5;223mS\033[38;5;223mS\033[38;5;223mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;216mG\033[38;5;216mH\033[38;5;174mh\033[38;5;131m5\033[38;5;95mA\033[38;5;239ms\033[38;5;236mi\033[38;5;233m,\033[38;5;16m \033[38;5;234m:\033[38;5;233m,\033[38;5;233m,\033[38;5;236mi\033[38;5;236mi\033[38;5;235m;\033[38;5;16m \033[38;5;16m \033[38;5;236mi\033[38;5;237mr\033[38;5;237mr\033[38;5;237mi\033[38;5;236mi\033[38;5;238ms\033[0m");
    $display("\033[38;5;251mS\033[38;5;231m@\033[38;5;249mH\033[38;5;246mh\033[38;5;247mh\033[38;5;242m2\033[38;5;242m2\033[38;5;242m2\033[38;5;237mr\033[38;5;233m,\033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;234m:\033[38;5;223m#\033[38;5;223m#\033[38;5;223mS\033[38;5;224m#\033[38;5;95m2\033[38;5;231mB\033[38;5;224m9\033[38;5;224m#\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;255mB\033[38;5;223m#\033[38;5;223m#\033[38;5;217mS\033[38;5;210mH\033[38;5;131m3\033[38;5;95m2\033[38;5;95m2\033[38;5;131m5\033[38;5;174mM\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223mS\033[38;5;223mS\033[38;5;223mS\033[38;5;223m#\033[38;5;223m#\033[38;5;223mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;216mG\033[38;5;174mH\033[38;5;173mh\033[38;5;131m5\033[38;5;95mA\033[38;5;238mr\033[38;5;235m;\033[38;5;233m,\033[38;5;233m,\033[38;5;234m:\033[38;5;234m:\033[38;5;235m;\033[38;5;234m:\033[38;5;234m:\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;234m:\033[38;5;234m:\033[38;5;234m:\033[38;5;233m,\033[38;5;233m,\033[0m");
    $display("\033[38;5;235m;\033[38;5;240mX\033[38;5;243m5\033[38;5;245m3\033[38;5;246mh\033[38;5;241mA\033[38;5;238ms\033[38;5;236mi\033[38;5;239mX\033[38;5;59mX\033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;243m2\033[38;5;230mB\033[38;5;223mS\033[38;5;224m9\033[38;5;95m2\033[38;5;255m9\033[38;5;224m9\033[38;5;223m#\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;224m9\033[38;5;255mB\033[38;5;231mB\033[38;5;255mB\033[38;5;224m9\033[38;5;223m#\033[38;5;216mG\033[38;5;210mH\033[38;5;173mh\033[38;5;131m5\033[38;5;95mA\033[38;5;95mA\033[38;5;131m2\033[38;5;180mH\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223mS\033[38;5;223mS\033[38;5;223mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;216mG\033[38;5;216mH\033[38;5;174mM\033[38;5;137m3\033[38;5;131m2\033[38;5;95mA\033[38;5;238mr\033[38;5;235m;\033[38;5;234m:\033[38;5;235m;\033[38;5;235m;\033[38;5;235m;\033[38;5;237mr\033[38;5;238mr\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;233m.\033[0m");
    $display("\033[38;5;233m,\033[38;5;232m.\033[38;5;234m:\033[38;5;237mi\033[38;5;235m:\033[38;5;59mX\033[38;5;59mX\033[38;5;234m,\033[38;5;238mr\033[38;5;188m#\033[38;5;241mA\033[38;5;16m \033[38;5;233m,\033[38;5;235m;\033[38;5;16m \033[38;5;248mM\033[38;5;224m9\033[38;5;224m9\033[38;5;95m2\033[38;5;254m9\033[38;5;230mB\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;224m9\033[38;5;255mB\033[38;5;224m9\033[38;5;187mS\033[38;5;223m#\033[38;5;223mS\033[38;5;217mS\033[38;5;216mH\033[38;5;173mh\033[38;5;131m5\033[38;5;137m5\033[38;5;137m3\033[38;5;137m3\033[38;5;131m2\033[38;5;95mA\033[38;5;180mH\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;216mG\033[38;5;216mH\033[38;5;174mM\033[38;5;137m3\033[38;5;131m5\033[38;5;95m2\033[38;5;95mA\033[38;5;239mX\033[38;5;235m;\033[38;5;235m;\033[38;5;237mi\033[38;5;238mr\033[38;5;236mi\033[38;5;238ms\033[38;5;236mi\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;232m.\033[38;5;233m.\033[38;5;233m.\033[38;5;233m.\033[38;5;232m.\033[0m");
    $display("\033[38;5;236m;\033[38;5;237mi\033[38;5;238mr\033[38;5;236mi\033[38;5;233m,\033[38;5;233m,\033[38;5;234m:\033[38;5;233m,\033[38;5;236mi\033[38;5;253m#\033[38;5;250mG\033[38;5;238ms\033[38;5;237mi\033[38;5;233m,\033[38;5;16m \033[38;5;233m,\033[38;5;245m3\033[38;5;187mS\033[38;5;138m3\033[38;5;253m#\033[38;5;231mB\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;223m9\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;224m9\033[38;5;223m#\033[38;5;173mh\033[38;5;131mA\033[38;5;174mM\033[38;5;216mG\033[38;5;174mh\033[38;5;167m3\033[38;5;95mX\033[38;5;237mi\033[38;5;237mi\033[38;5;131m5\033[38;5;174mM\033[38;5;131m2\033[38;5;95mA\033[38;5;174mh\033[38;5;217mS\033[38;5;223m#\033[38;5;223mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mG\033[38;5;216mG\033[38;5;174mM\033[38;5;174mh\033[38;5;137m3\033[38;5;95m2\033[38;5;95m2\033[38;5;95mA\033[38;5;238ms\033[38;5;235m;\033[38;5;237mi\033[38;5;238mr\033[38;5;239ms\033[38;5;239mX\033[38;5;236mi\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[0m");
    $display("\033[38;5;238mr\033[38;5;240mX\033[38;5;242m2\033[38;5;238ms\033[38;5;234m:\033[38;5;233m.\033[38;5;233m,\033[38;5;234m,\033[38;5;235m;\033[38;5;188m#\033[38;5;249mH\033[38;5;102m5\033[38;5;243m2\033[38;5;59mX\033[38;5;236m;\033[38;5;235m;\033[38;5;237mr\033[38;5;181mH\033[38;5;138mh\033[38;5;252mS\033[38;5;231mB\033[38;5;230mB\033[38;5;230m9\033[38;5;224m9\033[38;5;224m9\033[38;5;224m9\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223m9\033[38;5;224m9\033[38;5;224m9\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;216mG\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;174mH\033[38;5;174mH\033[38;5;174mM\033[38;5;174mh\033[38;5;174mH\033[38;5;216mH\033[38;5;216mG\033[38;5;217mS\033[38;5;223mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mG\033[38;5;216mG\033[38;5;180mH\033[38;5;174mM\033[38;5;137m3\033[38;5;131m2\033[38;5;95m2\033[38;5;95m2\033[38;5;240mX\033[38;5;236m;\033[38;5;236mi\033[38;5;235m;\033[38;5;236mi\033[38;5;236mi\033[38;5;234m:\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;233m,\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[0m");
    $display("\033[38;5;235m;\033[38;5;236mi\033[38;5;238mr\033[38;5;235m;\033[38;5;233m,\033[38;5;233m,\033[38;5;234m,\033[38;5;16m \033[38;5;237mr\033[38;5;254m9\033[38;5;249mH\033[38;5;246mh\033[38;5;102m3\033[38;5;248mM\033[38;5;59mX\033[38;5;237mr\033[38;5;234m:\033[38;5;236mi\033[38;5;238mr\033[38;5;138mh\033[38;5;231m@\033[38;5;231mB\033[38;5;230mB\033[38;5;224m9\033[38;5;224m9\033[38;5;223m9\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;224m9\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;230m9\033[38;5;223m#\033[38;5;223mS\033[38;5;223m#\033[38;5;223m9\033[38;5;223mS\033[38;5;216mG\033[38;5;180mH\033[38;5;216mH\033[38;5;216mG\033[38;5;216mG\033[38;5;216mG\033[38;5;216mG\033[38;5;216mG\033[38;5;217mS\033[38;5;217mS\033[38;5;217mG\033[38;5;216mG\033[38;5;216mG\033[38;5;180mH\033[38;5;174mM\033[38;5;138mh\033[38;5;137m5\033[38;5;95m2\033[38;5;95m2\033[38;5;95mX\033[38;5;237mr\033[38;5;237mr\033[38;5;237mi\033[38;5;235m;\033[38;5;239mX\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[0m");
    $display("\033[38;5;235m;\033[38;5;235m;\033[38;5;236m;\033[38;5;235m;\033[38;5;236m;\033[38;5;237mr\033[38;5;238ms\033[38;5;243m2\033[38;5;253m#\033[38;5;188mS\033[38;5;246mh\033[38;5;139mh\033[38;5;247mM\033[38;5;245m3\033[38;5;235m;\033[38;5;234m,\033[38;5;235m:\033[38;5;235m:\033[38;5;234m:\033[38;5;235m:\033[38;5;248mM\033[38;5;231m@\033[38;5;231mB\033[38;5;230mB\033[38;5;224m9\033[38;5;224m9\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;224m9\033[38;5;230mB\033[38;5;231mB\033[38;5;231mB\033[38;5;224m#\033[38;5;217mS\033[38;5;216mH\033[38;5;210mH\033[38;5;210mH\033[38;5;210mH\033[38;5;210mH\033[38;5;210mM\033[38;5;210mM\033[38;5;174mM\033[38;5;174mM\033[38;5;174mH\033[38;5;174mH\033[38;5;180mH\033[38;5;174mH\033[38;5;180mH\033[38;5;216mG\033[38;5;216mG\033[38;5;216mG\033[38;5;216mH\033[38;5;180mH\033[38;5;174mM\033[38;5;138mh\033[38;5;137m3\033[38;5;131m5\033[38;5;95m5\033[38;5;95m2\033[38;5;239mX\033[38;5;239ms\033[38;5;234m,\033[38;5;232m.\033[38;5;233m,\033[38;5;235m;\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;233m.\033[38;5;234m:\033[38;5;234m:\033[0m");
    $display("\033[38;5;145mH\033[38;5;145mH\033[38;5;145mH\033[38;5;145mH\033[38;5;145mH\033[38;5;145mH\033[38;5;188mS\033[38;5;253m#\033[38;5;249mH\033[38;5;246mh\033[38;5;247mh\033[38;5;246mh\033[38;5;247mM\033[38;5;102m3\033[38;5;233m,\033[38;5;232m.\033[38;5;233m,\033[38;5;232m.\033[38;5;16m \033[38;5;234m:\033[38;5;232m.\033[38;5;245m3\033[38;5;231m@\033[38;5;231mB\033[38;5;230mB\033[38;5;224m9\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;230m9\033[38;5;230mB\033[38;5;224m#\033[38;5;204mh\033[38;5;167m2\033[38;5;167m5\033[38;5;174mh\033[38;5;174mh\033[38;5;174mh\033[38;5;167m5\033[38;5;131m5\033[38;5;167m5\033[38;5;131m5\033[38;5;131m2\033[38;5;131m2\033[38;5;131m5\033[38;5;137m3\033[38;5;137m3\033[38;5;138mh\033[38;5;174mM\033[38;5;180mH\033[38;5;216mH\033[38;5;180mH\033[38;5;180mH\033[38;5;174mM\033[38;5;138mh\033[38;5;137m3\033[38;5;137m3\033[38;5;131m5\033[38;5;95m2\033[38;5;95m2\033[38;5;240mX\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;234m,\033[38;5;234m,\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;234m:\033[0m");
    $display("\033[38;5;250mG\033[38;5;250mG\033[38;5;249mG\033[38;5;249mG\033[38;5;249mG\033[38;5;249mH\033[38;5;145mH\033[38;5;145mM\033[38;5;145mH\033[38;5;145mH\033[38;5;145mM\033[38;5;145mM\033[38;5;145mH\033[38;5;245m3\033[38;5;234m:\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;244m5\033[38;5;231m@\033[38;5;231mB\033[38;5;230mB\033[38;5;223m9\033[38;5;223m#\033[38;5;223m#\033[38;5;224m9\033[38;5;217mS\033[38;5;125ms\033[38;5;52m:\033[38;5;235m;\033[38;5;239mX\033[38;5;245m3\033[38;5;250mG\033[38;5;181mG\033[38;5;181mH\033[38;5;181mG\033[38;5;181mH\033[38;5;95m5\033[38;5;95mA\033[38;5;52mr\033[38;5;52mi\033[38;5;238mr\033[38;5;95mA\033[38;5;131m5\033[38;5;174mh\033[38;5;174mM\033[38;5;180mH\033[38;5;180mH\033[38;5;180mH\033[38;5;174mM\033[38;5;137m3\033[38;5;137m5\033[38;5;131m5\033[38;5;95m2\033[38;5;95m2\033[38;5;239ms\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m.\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[0m");
    $display("\033[38;5;145mH\033[38;5;145mM\033[38;5;247mM\033[38;5;247mM\033[38;5;247mM\033[38;5;247mM\033[38;5;247mM\033[38;5;247mM\033[38;5;246mh\033[38;5;246mh\033[38;5;245mh\033[38;5;245mh\033[38;5;246mh\033[38;5;246mh\033[38;5;235m:\033[38;5;233m,\033[38;5;236mi\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;242mA\033[38;5;231m@\033[38;5;230mB\033[38;5;230m9\033[38;5;223m#\033[38;5;223m#\033[38;5;223m9\033[38;5;216mH\033[38;5;52m,\033[38;5;232m.\033[38;5;235m;\033[38;5;233m,\033[38;5;16m \033[38;5;52m,\033[38;5;52m;\033[38;5;52m;\033[38;5;52mi\033[38;5;237mr\033[38;5;52mi\033[38;5;88mr\033[38;5;238mr\033[38;5;52m;\033[38;5;52m;\033[38;5;131m2\033[38;5;173mh\033[38;5;174mM\033[38;5;174mM\033[38;5;180mH\033[38;5;180mH\033[38;5;174mM\033[38;5;137m3\033[38;5;131m5\033[38;5;95m2\033[38;5;95m2\033[38;5;95mA\033[38;5;239ms\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;238mr\033[38;5;101m5\033[38;5;137m3\033[38;5;137mh\033[38;5;137m3\033[38;5;137mh\033[38;5;137mh\033[38;5;137mh\033[38;5;137mh\033[0m");
    $display("\033[38;5;23ms\033[38;5;23ms\033[38;5;23ms\033[38;5;23ms\033[38;5;23ms\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;237mr\033[38;5;237mr\033[38;5;238ms\033[38;5;234m:\033[38;5;59mX\033[38;5;235m;\033[38;5;232m.\033[38;5;233m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;187mS\033[38;5;231mB\033[38;5;230mB\033[38;5;224m9\033[38;5;223m#\033[38;5;223m9\033[38;5;224m9\033[38;5;167m3\033[38;5;88mi\033[38;5;52mi\033[38;5;238ms\033[38;5;233m,\033[38;5;52m;\033[38;5;95mX\033[38;5;131mA\033[38;5;131mX\033[38;5;131mX\033[38;5;131mA\033[38;5;131m2\033[38;5;131m2\033[38;5;131mX\033[38;5;131m2\033[38;5;210mH\033[38;5;174mM\033[38;5;174mh\033[38;5;174mM\033[38;5;174mM\033[38;5;174mh\033[38;5;137m3\033[38;5;131m5\033[38;5;95m2\033[38;5;95mA\033[38;5;240mX\033[38;5;238ms\033[38;5;236mi\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;137mh\033[38;5;180mH\033[38;5;180mH\033[38;5;180mG\033[38;5;180mG\033[38;5;180mG\033[38;5;180mG\033[38;5;180mG\033[38;5;180mG\033[0m");
    $display("\033[38;5;23mr\033[38;5;23mr\033[38;5;23mi\033[38;5;23mr\033[38;5;23mi\033[38;5;23mi\033[38;5;23mi\033[38;5;23mi\033[38;5;23mi\033[38;5;23mi\033[38;5;23mi\033[38;5;23mi\033[38;5;23mi\033[38;5;237mr\033[38;5;60m2\033[38;5;239ms\033[38;5;232m.\033[38;5;233m,\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;131m5\033[38;5;223m9\033[38;5;231mB\033[38;5;230mB\033[38;5;230m9\033[38;5;230m9\033[38;5;230mB\033[38;5;224m9\033[38;5;211mH\033[38;5;168m3\033[38;5;131mA\033[38;5;52mi\033[38;5;52m,\033[38;5;52m;\033[38;5;131mA\033[38;5;131m2\033[38;5;167m2\033[38;5;167m2\033[38;5;167m5\033[38;5;167m2\033[38;5;167m2\033[38;5;203m3\033[38;5;167m3\033[38;5;137mh\033[38;5;138mh\033[38;5;174mh\033[38;5;138mh\033[38;5;137m3\033[38;5;131m5\033[38;5;95m2\033[38;5;95mA\033[38;5;239ms\033[38;5;238mr\033[38;5;237mr\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;235m;\033[38;5;95m2\033[38;5;95m2\033[38;5;59mA\033[38;5;95mA\033[38;5;95m2\033[38;5;95m2\033[38;5;95m2\033[38;5;95mA\033[38;5;95mA\033[0m");
    $display("\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mi\033[38;5;240mX\033[38;5;102m5\033[38;5;60mA\033[38;5;236m;\033[38;5;233m.\033[38;5;233m,\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;239ms\033[38;5;216mS\033[38;5;223m#\033[38;5;231mB\033[38;5;231mB\033[38;5;230mB\033[38;5;230mB\033[38;5;230mB\033[38;5;224m9\033[38;5;217mG\033[38;5;210mM\033[38;5;204mh\033[38;5;167m3\033[38;5;167m2\033[38;5;167m2\033[38;5;167m5\033[38;5;203m3\033[38;5;203m3\033[38;5;203m5\033[38;5;167mA\033[38;5;125mX\033[38;5;131mA\033[38;5;137m5\033[38;5;138mh\033[38;5;137m3\033[38;5;137m3\033[38;5;137m5\033[38;5;131m5\033[38;5;95mA\033[38;5;95mX\033[38;5;238ms\033[38;5;238mr\033[38;5;238mr\033[38;5;235m;\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;238mr\033[38;5;59mA\033[38;5;240mA\033[38;5;95m2\033[38;5;95mA\033[38;5;95mA\033[38;5;95mA\033[38;5;95mA\033[38;5;95mA\033[0m");
    $display("\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mi\033[38;5;23ms\033[38;5;59mA\033[38;5;239mX\033[38;5;235m;\033[38;5;233m,\033[38;5;233m,\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;235m:\033[38;5;216mH\033[38;5;216mS\033[38;5;223m#\033[38;5;230mB\033[38;5;231mB\033[38;5;231mB\033[38;5;230mB\033[38;5;230mB\033[38;5;223m#\033[38;5;210mH\033[38;5;203m3\033[38;5;203m3\033[38;5;203m3\033[38;5;203m3\033[38;5;203m3\033[38;5;203m5\033[38;5;167m2\033[38;5;125mX\033[38;5;89ms\033[38;5;95mA\033[38;5;131m5\033[38;5;138mh\033[38;5;137m3\033[38;5;137m5\033[38;5;131m5\033[38;5;95m5\033[38;5;95mA\033[38;5;239ms\033[38;5;238mr\033[38;5;238ms\033[38;5;239ms\033[38;5;238mr\033[38;5;235m;\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;235m;\033[38;5;137m3\033[38;5;137mh\033[38;5;137mh\033[38;5;137m3\033[38;5;137m3\033[38;5;137m3\033[38;5;137m3\033[38;5;137m3\033[0m");
    $display("\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mi\033[38;5;237mr\033[38;5;235m;\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;173mh\033[38;5;216mS\033[38;5;222mS\033[38;5;223m#\033[38;5;224m9\033[38;5;231mB\033[38;5;231mB\033[38;5;230mB\033[38;5;224m9\033[38;5;223m#\033[38;5;217mG\033[38;5;210mM\033[38;5;173mh\033[38;5;167m3\033[38;5;167m5\033[38;5;167m5\033[38;5;131m5\033[38;5;131m5\033[38;5;137m3\033[38;5;174mh\033[38;5;174mh\033[38;5;137m3\033[38;5;137m5\033[38;5;131m5\033[38;5;95m2\033[38;5;95mX\033[38;5;238ms\033[38;5;239ms\033[38;5;239mX\033[38;5;239mX\033[38;5;239mX\033[38;5;237mi\033[38;5;236mi\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;101m5\033[38;5;138mM\033[38;5;137mh\033[38;5;137m3\033[38;5;137m3\033[38;5;137m3\033[38;5;137m3\033[38;5;137m3\033[0m");
    $display("\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mi\033[38;5;236mi\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;131m5\033[38;5;216mS\033[38;5;216mS\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;230mB\033[38;5;230mB\033[38;5;224m9\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;216mG\033[38;5;216mG\033[38;5;216mH\033[38;5;174mH\033[38;5;174mM\033[38;5;174mh\033[38;5;137m3\033[38;5;131m5\033[38;5;95mA\033[38;5;239ms\033[38;5;238ms\033[38;5;240mX\033[38;5;95mA\033[38;5;95mA\033[38;5;95mX\033[38;5;239mX\033[38;5;234m:\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;95m2\033[38;5;144mM\033[38;5;137mh\033[38;5;137mh\033[38;5;137mh\033[38;5;137mh\033[38;5;137mh\033[38;5;137mh\033[0m");
    $display("\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;234m:\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;234m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;95mA\033[38;5;216mG\033[38;5;216mS\033[38;5;223mS\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;224m9\033[38;5;223m#\033[38;5;223m#\033[38;5;223mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;216mG\033[38;5;180mH\033[38;5;174mM\033[38;5;174mh\033[38;5;137m3\033[38;5;95m2\033[38;5;95mX\033[38;5;239ms\033[38;5;239ms\033[38;5;95mA\033[38;5;95m2\033[38;5;95m2\033[38;5;95m2\033[38;5;95mA\033[38;5;238mr\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;101m5\033[38;5;137mh\033[38;5;137m3\033[38;5;137mh\033[38;5;137mh\033[38;5;137mh\033[38;5;137mh\033[38;5;137mh\033[0m");
    $display("\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mr\033[38;5;23mi\033[38;5;23mi\033[38;5;23mi\033[38;5;23mi\033[38;5;23mi\033[38;5;23mi\033[38;5;23mr\033[38;5;240mX\033[38;5;66m2\033[38;5;238mr\033[38;5;16m \033[38;5;235m;\033[38;5;236m;\033[38;5;232m.\033[38;5;234m:\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;238mr\033[38;5;179mM\033[38;5;216mG\033[38;5;216mS\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223mS\033[38;5;223m#\033[38;5;223m#\033[38;5;217mS\033[38;5;216mG\033[38;5;180mH\033[38;5;180mH\033[38;5;174mM\033[38;5;174mM\033[38;5;174mh\033[38;5;137m3\033[38;5;131m5\033[38;5;95m2\033[38;5;95mX\033[38;5;95mX\033[38;5;95mX\033[38;5;95mX\033[38;5;95m2\033[38;5;95m5\033[38;5;131m5\033[38;5;95m5\033[38;5;95m2\033[38;5;95mA\033[38;5;235m;\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;137m3\033[38;5;144mM\033[38;5;137mh\033[38;5;137mh\033[38;5;137mh\033[38;5;137mh\033[38;5;137mh\033[38;5;137m3\033[0m");
    $display("\033[38;5;23mr\033[38;5;23mr\033[38;5;23ms\033[38;5;23ms\033[38;5;23ms\033[38;5;240mX\033[38;5;240mX\033[38;5;109mM\033[38;5;152mG\033[38;5;188mS\033[38;5;254m9\033[38;5;255mB\033[38;5;231m@\033[38;5;254m9\033[38;5;236mi\033[38;5;235m;\033[38;5;233m,\033[38;5;233m.\033[38;5;234m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;237mi\033[38;5;173mh\033[38;5;216mG\033[38;5;216mS\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;222mS\033[38;5;216mS\033[38;5;216mG\033[38;5;216mG\033[38;5;180mH\033[38;5;180mH\033[38;5;174mM\033[38;5;173mh\033[38;5;137m3\033[38;5;137m5\033[38;5;131m5\033[38;5;95m5\033[38;5;131m5\033[38;5;137m5\033[38;5;137m3\033[38;5;137m3\033[38;5;137m3\033[38;5;137m3\033[38;5;95m5\033[38;5;239mX\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;236mi\033[38;5;138mh\033[38;5;137m3\033[38;5;137m3\033[38;5;138mh\033[38;5;144mM\033[38;5;144mM\033[38;5;144mM\033[38;5;137mh\033[0m");
    $display("\033[38;5;238ms\033[38;5;60mX\033[38;5;60mA\033[38;5;238ms\033[38;5;238ms\033[38;5;238mr\033[38;5;236m;\033[38;5;241mA\033[38;5;224m9\033[38;5;230mB\033[38;5;230m9\033[38;5;230mB\033[38;5;187m#\033[38;5;240mX\033[38;5;234m:\033[38;5;233m.\033[38;5;232m.\033[38;5;234m:\033[38;5;233m,\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;237mi\033[38;5;137m3\033[38;5;180mM\033[38;5;216mG\033[38;5;216mS\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;216mS\033[38;5;216mS\033[38;5;216mS\033[38;5;216mS\033[38;5;216mS\033[38;5;216mS\033[38;5;216mS\033[38;5;216mH\033[38;5;180mM\033[38;5;174mM\033[38;5;138mh\033[38;5;137m3\033[38;5;137m3\033[38;5;138mh\033[38;5;174mM\033[38;5;180mM\033[38;5;180mM\033[38;5;138mh\033[38;5;95m2\033[38;5;235m;\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;237mi\033[38;5;95mA\033[38;5;237mi\033[38;5;16m \033[38;5;234m:\033[38;5;236m;\033[38;5;237mr\033[38;5;240mX\033[38;5;241mA\033[0m");
    $display("\033[38;5;235m;\033[38;5;237mi\033[38;5;234m,\033[38;5;234m:\033[38;5;233m,\033[38;5;235m:\033[38;5;233m.\033[38;5;16m \033[38;5;236mi\033[38;5;216mG\033[38;5;223m#\033[38;5;223m#\033[38;5;95m2\033[38;5;237mi\033[38;5;233m.\033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;234m:\033[38;5;137m5\033[38;5;173mM\033[38;5;180mH\033[38;5;216mS\033[38;5;223mS\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223mS\033[38;5;216mS\033[38;5;216mS\033[38;5;216mS\033[38;5;216mS\033[38;5;216mS\033[38;5;216mS\033[38;5;216mG\033[38;5;216mG\033[38;5;180mH\033[38;5;180mH\033[38;5;180mM\033[38;5;174mM\033[38;5;180mM\033[38;5;180mH\033[38;5;216mG\033[38;5;216mG\033[38;5;180mG\033[38;5;174mM\033[38;5;239mX\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;236m;\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[0m");
    $display("\033[38;5;232m.\033[38;5;233m,\033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;232m.\033[38;5;234m,\033[38;5;232m.\033[38;5;16m \033[38;5;131m2\033[38;5;217mS\033[38;5;138mh\033[38;5;240mX\033[38;5;234m:\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;95m2\033[38;5;180mH\033[38;5;180mH\033[38;5;216mG\033[38;5;216mS\033[38;5;223mS\033[38;5;223m#\033[38;5;223m#\033[38;5;223mS\033[38;5;216mS\033[38;5;216mG\033[38;5;216mS\033[38;5;217mS\033[38;5;223mS\033[38;5;223m#\033[38;5;223mS\033[38;5;217mS\033[38;5;217mS\033[38;5;216mG\033[38;5;216mG\033[38;5;180mH\033[38;5;216mG\033[38;5;217mS\033[38;5;217mS\033[38;5;216mS\033[38;5;180mG\033[38;5;131m5\033[38;5;236m;\033[38;5;234m:\033[38;5;233m,\033[38;5;234m:\033[38;5;235m;\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;234m:\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[0m");
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;232m.\033[38;5;236mi\033[38;5;174mM\033[38;5;180mH\033[38;5;240mX\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;95mX\033[38;5;174mM\033[38;5;180mH\033[38;5;216mH\033[38;5;216mG\033[38;5;216mS\033[38;5;223m#\033[38;5;223m#\033[38;5;223mS\033[38;5;217mS\033[38;5;216mG\033[38;5;216mG\033[38;5;217mS\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;223mS\033[38;5;223m#\033[38;5;223mS\033[38;5;216mS\033[38;5;137mh\033[38;5;238mr\033[38;5;237mi\033[38;5;235m;\033[38;5;235m;\033[38;5;239mX\033[38;5;237mi\033[38;5;237mr\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[0m");
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;233m,\033[38;5;233m.\033[38;5;95m2\033[38;5;216mS\033[38;5;180mM\033[38;5;238mr\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;235m:\033[38;5;131m5\033[38;5;180mH\033[38;5;216mG\033[38;5;216mG\033[38;5;216mG\033[38;5;216mG\033[38;5;217mS\033[38;5;223mS\033[38;5;223m#\033[38;5;217mS\033[38;5;216mG\033[38;5;180mH\033[38;5;216mG\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;223mS\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;180mH\033[38;5;95mX\033[38;5;238mr\033[38;5;240mX\033[38;5;236mi\033[38;5;238ms\033[38;5;239mX\033[38;5;238ms\033[38;5;240mX\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[0m");
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;16m \033[38;5;238mr\033[38;5;180mG\033[38;5;217mS\033[38;5;216mG\033[38;5;95m5\033[38;5;235m;\033[38;5;235m;\033[38;5;235m;\033[38;5;234m:\033[38;5;233m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;234m:\033[38;5;95m2\033[38;5;180mH\033[38;5;216mS\033[38;5;216mS\033[38;5;216mS\033[38;5;216mG\033[38;5;216mS\033[38;5;217mS\033[38;5;223mS\033[38;5;217mS\033[38;5;216mG\033[38;5;180mH\033[38;5;180mH\033[38;5;216mG\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;217mS\033[38;5;223m#\033[38;5;223m#\033[38;5;223m9\033[38;5;223m9\033[38;5;223m#\033[38;5;216mG\033[38;5;95m2\033[38;5;239ms\033[38;5;95mA\033[38;5;95m2\033[38;5;95mA\033[38;5;95m2\033[38;5;95mX\033[38;5;95m2\033[38;5;95mA\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[0m");
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;235m;\033[38;5;174mM\033[38;5;223m#\033[38;5;223mS\033[38;5;223m#\033[38;5;174mM\033[38;5;235m;\033[38;5;235m;\033[38;5;235m;\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;233m,\033[38;5;239ms\033[38;5;137m3\033[38;5;180mG\033[38;5;223mS\033[38;5;223m#\033[38;5;217mS\033[38;5;216mS\033[38;5;216mS\033[38;5;223mS\033[38;5;223mS\033[38;5;217mS\033[38;5;216mH\033[38;5;174mH\033[38;5;216mH\033[38;5;217mS\033[38;5;217mS\033[38;5;223mS\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223m9\033[38;5;223m9\033[38;5;223mS\033[38;5;137m3\033[38;5;95mX\033[38;5;95mA\033[38;5;137m3\033[38;5;174mM\033[38;5;174mh\033[38;5;131m5\033[38;5;173mh\033[38;5;173mh\033[38;5;131m5\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[0m");
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;232m.\033[38;5;137m5\033[38;5;223m#\033[38;5;223mS\033[38;5;223mS\033[38;5;95mA\033[38;5;232m.\033[38;5;234m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;238ms\033[38;5;131m5\033[38;5;180mH\033[38;5;180mG\033[38;5;223mS\033[38;5;223m#\033[38;5;223m#\033[38;5;223mS\033[38;5;217mS\033[38;5;223mS\033[38;5;223mS\033[38;5;216mG\033[38;5;180mH\033[38;5;174mH\033[38;5;216mG\033[38;5;217mS\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;174mH\033[38;5;95m2\033[38;5;95mA\033[38;5;131m5\033[38;5;216mG\033[38;5;217mG\033[38;5;174mh\033[38;5;180mH\033[38;5;180mH\033[38;5;174mM\033[38;5;137m3\033[38;5;236mi\033[38;5;232m.\033[38;5;232m.\033[38;5;233m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[0m");
    $display("\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;232m.\033[38;5;16m \033[38;5;239ms\033[38;5;223mS\033[38;5;223mS\033[38;5;223m#\033[38;5;137m5\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;237mr\033[38;5;137m3\033[38;5;216mG\033[38;5;216mG\033[38;5;216mG\033[38;5;223mS\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223mS\033[38;5;216mG\033[38;5;174mM\033[38;5;216mH\033[38;5;216mS\033[38;5;223m#\033[38;5;223m#\033[38;5;223m9\033[38;5;223m#\033[38;5;223m#\033[38;5;216mG\033[38;5;173m3\033[38;5;137m3\033[38;5;173mh\033[38;5;180mH\033[38;5;216mG\033[38;5;174mM\033[38;5;216mG\033[38;5;216mG\033[38;5;216mH\033[38;5;174mM\033[38;5;173mh\033[38;5;240mX\033[38;5;233m,\033[38;5;235m;\033[38;5;234m:\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[0m");
    $display("\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;234m:\033[38;5;180mG\033[38;5;223m#\033[38;5;223m#\033[38;5;217mG\033[38;5;233m,\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;235m;\033[38;5;174mM\033[38;5;216mG\033[38;5;217mS\033[38;5;223m#\033[38;5;217mS\033[38;5;216mG\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;223m#\033[38;5;217mS\033[38;5;216mG\033[38;5;174mH\033[38;5;216mG\033[38;5;223m#\033[38;5;223m9\033[38;5;223m9\033[38;5;223m#\033[38;5;223m#\033[38;5;216mG\033[38;5;174mM\033[38;5;216mG\033[38;5;216mG\033[38;5;216mG\033[38;5;174mM\033[38;5;180mH\033[38;5;216mG\033[38;5;180mH\033[38;5;174mM\033[38;5;137m3\033[38;5;95m2\033[38;5;235m;\033[38;5;232m.\033[38;5;233m,\033[38;5;233m,\033[38;5;16m \033[38;5;232m.\033[38;5;232m.\033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[38;5;16m \033[0m");

end endtask

endmodule


