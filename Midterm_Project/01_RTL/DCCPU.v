







// //############################################################################
// //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// //   (C) Copyright Laboratory System Integration and Silicon Implementation
// //   All Right Reserved
// //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// //
// //   ICLAB 2026 Spring Midterm Project: Dual-Core CPU 
// //   Author                           : Ying-Yu Wang
// //
// //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// //
// //   File Name   : DCCPU.v
// //   Module Name : DCCPU.v
// //   Release version : V6.0 (Area Extremely Optimized: Bit-width reductions applied)
// //
// //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// 

//############################################################################

module DCCPU(
// Input
    clk,
    rst_n,
// Output
    stall_1,
    stall_2,
//===== AXI-4 Instruction1 DRAM =====
    arid_m_inf_inst_1,
    araddr_m_inf_inst_1,
    arlen_m_inf_inst_1,
    arsize_m_inf_inst_1,
    arburst_m_inf_inst_1,
    arvalid_m_inf_inst_1,
    arready_m_inf_inst_1,

    rid_m_inf_inst_1,
    rdata_m_inf_inst_1,
    rresp_m_inf_inst_1,
    rlast_m_inf_inst_1,
    rvalid_m_inf_inst_1,
    rready_m_inf_inst_1,

    awid_m_inf_inst_1,
    awaddr_m_inf_inst_1,
    awsize_m_inf_inst_1,
    awburst_m_inf_inst_1,
    awlen_m_inf_inst_1,
  
    awvalid_m_inf_inst_1,
    awready_m_inf_inst_1,
   
    wdata_m_inf_inst_1,
    wlast_m_inf_inst_1,
    wvalid_m_inf_inst_1,
    wready_m_inf_inst_1,

    bid_m_inf_inst_1,
    bresp_m_inf_inst_1,
    bvalid_m_inf_inst_1,
    bready_m_inf_inst_1,
//===== AXI-4 Instruction2 DRAM =====
    arid_m_inf_inst_2,
    araddr_m_inf_inst_2,
    arlen_m_inf_inst_2,
    arsize_m_inf_inst_2,
    arburst_m_inf_inst_2,
    arvalid_m_inf_inst_2,
    arready_m_inf_inst_2,

    rid_m_inf_inst_2,
    rdata_m_inf_inst_2,
    rresp_m_inf_inst_2,
    rlast_m_inf_inst_2,
    rvalid_m_inf_inst_2,
    rready_m_inf_inst_2,

    awid_m_inf_inst_2,
    awaddr_m_inf_inst_2,
    awsize_m_inf_inst_2,
    awburst_m_inf_inst_2,
    awlen_m_inf_inst_2,
    awvalid_m_inf_inst_2,
    awready_m_inf_inst_2,
                
    wdata_m_inf_inst_2,
    wlast_m_inf_inst_2,
    wvalid_m_inf_inst_2,
    wready_m_inf_inst_2,

    bid_m_inf_inst_2,
    bresp_m_inf_inst_2,
    bvalid_m_inf_inst_2,
    bready_m_inf_inst_2,  
//===== AXI-4 Data DRAM =====
    arid_m_inf_data,
    araddr_m_inf_data,
    arlen_m_inf_data,
    arsize_m_inf_data,
    arburst_m_inf_data,
 
    arvalid_m_inf_data,
    arready_m_inf_data,

    rid_m_inf_data,
    rdata_m_inf_data,
    rresp_m_inf_data,
    rlast_m_inf_data,
    rvalid_m_inf_data,
    rready_m_inf_data,

    awid_m_inf_data,
    awaddr_m_inf_data,
    awsize_m_inf_data,
    awburst_m_inf_data,
    awlen_m_inf_data,
    awvalid_m_inf_data,
    awready_m_inf_data,
                
    wdata_m_inf_data,
    wlast_m_inf_data,
    wvalid_m_inf_data,
    wready_m_inf_data,

    bid_m_inf_data,
    bresp_m_inf_data,
 
    bvalid_m_inf_data,
    bready_m_inf_data
);

// Input port
input wire clk, rst_n;
// Output port
output reg stall_1, stall_2;
parameter ID_WIDTH=4, ADDR_WIDTH=32, DATA_WIDTH=16, BURST_LEN=7;

// AXI ports assignments
output wire [ID_WIDTH-1:0]   awid_m_inf_inst_1;
output wire [ADDR_WIDTH-1:0] awaddr_m_inf_inst_1;
output wire [2:0]            awsize_m_inf_inst_1;
output wire [1:0]            awburst_m_inf_inst_1;
output wire [BURST_LEN-1:0]  awlen_m_inf_inst_1;
output wire                  awvalid_m_inf_inst_1;
input  wire                  awready_m_inf_inst_1;
output wire [DATA_WIDTH-1:0] wdata_m_inf_inst_1;
output wire                  wlast_m_inf_inst_1;
output wire                  wvalid_m_inf_inst_1;
input  wire                  wready_m_inf_inst_1;
input  wire [ID_WIDTH-1:0]   bid_m_inf_inst_1;
input  wire [1:0]            bresp_m_inf_inst_1;
input  wire                  bvalid_m_inf_inst_1;
output wire                  bready_m_inf_inst_1;
output wire [ID_WIDTH-1:0]   arid_m_inf_inst_1;
output wire [ADDR_WIDTH-1:0] araddr_m_inf_inst_1;
output wire [BURST_LEN-1:0]  arlen_m_inf_inst_1;
output wire [2:0]            arsize_m_inf_inst_1;
output wire [1:0]            arburst_m_inf_inst_1;
output wire                  arvalid_m_inf_inst_1;
input  wire                  arready_m_inf_inst_1;
input  wire [ID_WIDTH-1:0]   rid_m_inf_inst_1;
input  wire [DATA_WIDTH-1:0] rdata_m_inf_inst_1;
input  wire [1:0]            rresp_m_inf_inst_1;
input  wire                  rlast_m_inf_inst_1;
input  wire                  rvalid_m_inf_inst_1;
output wire                  rready_m_inf_inst_1;
output wire [ID_WIDTH-1:0]   awid_m_inf_inst_2;
output wire [ADDR_WIDTH-1:0] awaddr_m_inf_inst_2;
output wire [2:0]            awsize_m_inf_inst_2;
output wire [1:0]            awburst_m_inf_inst_2;
output wire [BURST_LEN-1:0]  awlen_m_inf_inst_2;
output wire                  awvalid_m_inf_inst_2;
input  wire                  awready_m_inf_inst_2;
output wire [DATA_WIDTH-1:0] wdata_m_inf_inst_2;
output wire                  wlast_m_inf_inst_2;
output wire                  wvalid_m_inf_inst_2;
input  wire                  wready_m_inf_inst_2;
input  wire [ID_WIDTH-1:0]   bid_m_inf_inst_2;
input  wire [1:0]            bresp_m_inf_inst_2;
input  wire                  bvalid_m_inf_inst_2;
output wire                  bready_m_inf_inst_2;
output wire [ID_WIDTH-1:0]   arid_m_inf_inst_2;
output wire [ADDR_WIDTH-1:0] araddr_m_inf_inst_2;
output wire [BURST_LEN-1:0]  arlen_m_inf_inst_2;
output wire [2:0]            arsize_m_inf_inst_2;
output wire [1:0]            arburst_m_inf_inst_2;
output wire                  arvalid_m_inf_inst_2;
input  wire                  arready_m_inf_inst_2;
input  wire [ID_WIDTH-1:0]   rid_m_inf_inst_2;
input  wire [DATA_WIDTH-1:0] rdata_m_inf_inst_2;
input  wire [1:0]            rresp_m_inf_inst_2;
input  wire                  rlast_m_inf_inst_2;
input  wire                  rvalid_m_inf_inst_2;
output wire                  rready_m_inf_inst_2;
output wire [ID_WIDTH-1:0]   awid_m_inf_data;
output wire [ADDR_WIDTH-1:0] awaddr_m_inf_data;
output wire [2:0]            awsize_m_inf_data;
output wire [1:0]            awburst_m_inf_data;
output wire [BURST_LEN-1:0]  awlen_m_inf_data;
output wire                  awvalid_m_inf_data;
input  wire                  awready_m_inf_data;
output wire [DATA_WIDTH-1:0] wdata_m_inf_data;
output wire                  wlast_m_inf_data;
output wire                  wvalid_m_inf_data;
input  wire                  wready_m_inf_data;
input  wire [ID_WIDTH-1:0]   bid_m_inf_data;
input  wire [1:0]            bresp_m_inf_data;
input  wire                  bvalid_m_inf_data;
output wire                  bready_m_inf_data;
output wire [ID_WIDTH-1:0]   arid_m_inf_data;
output wire [ADDR_WIDTH-1:0] araddr_m_inf_data;
output wire [BURST_LEN-1:0]  arlen_m_inf_data;
output wire [2:0]            arsize_m_inf_data;
output wire [1:0]            arburst_m_inf_data;
output wire                  arvalid_m_inf_data;
input  wire                  arready_m_inf_data;
input  wire [ID_WIDTH-1:0]   rid_m_inf_data;
input  wire [DATA_WIDTH-1:0] rdata_m_inf_data;
input  wire [1:0]            rresp_m_inf_data;
input  wire                  rlast_m_inf_data;
input  wire                  rvalid_m_inf_data;
output wire                  rready_m_inf_data;

// Disable Unused Write Channels for Instructions
assign awid_m_inf_inst_1    = 0;
assign awaddr_m_inf_inst_1  = 0;
assign awsize_m_inf_inst_1  = 0;
assign awburst_m_inf_inst_1 = 0;
assign awlen_m_inf_inst_1   = 0;
assign awvalid_m_inf_inst_1 = 0;
assign wdata_m_inf_inst_1   = 0;
assign wlast_m_inf_inst_1   = 0;
assign wvalid_m_inf_inst_1  = 0;
assign bready_m_inf_inst_1  = 0;

assign awid_m_inf_inst_2    = 0;
assign awaddr_m_inf_inst_2  = 0;
assign awsize_m_inf_inst_2  = 0;
assign awburst_m_inf_inst_2 = 0;
assign awlen_m_inf_inst_2   = 0;
assign awvalid_m_inf_inst_2 = 0;
assign wdata_m_inf_inst_2   = 0;
assign wlast_m_inf_inst_2   = 0;
assign wvalid_m_inf_inst_2  = 0;
assign bready_m_inf_inst_2  = 0;

// -----------------------------
// Unified Register Files & FSM Control Regs
// -----------------------------
reg [15:0] core_1_r0, core_1_r1, core_1_r2, core_1_r3;
reg [15:0] core_1_r4, core_1_r5, core_1_r6, core_1_r7;
reg [15:0] core_2_r0, core_2_r1, core_2_r2, core_2_r3;
reg [15:0] core_2_r4, core_2_r5, core_2_r6, core_2_r7;
reg [13:0] pc_1, pc_2; // OPTIMIZED: 14-bit PC
reg [15:0] inst_reg_1, inst_reg_2;

reg thread_id;     
reg exec_order;    
reg exec_step;

// Flags for one_fast_one_slow
reg par_fast_valid;
reg par_fast_done;
reg par_fast_thread;

localparam IDLE            = 5'd0;
localparam CHECK_HIT       = 5'd1;
localparam FETCH_MISS      = 5'd2;
localparam READ_SRAM_1     = 5'd3;
localparam READ_SRAM_2     = 5'd4;
localparam WAIT_SRAM_2     = 5'd5;
localparam FETCH_DONE      = 5'd6;
localparam DCACHE_SRAM     = 5'd7; 
localparam EXECUTE         = 5'd8;
localparam MULT_WAIT       = 5'd9;
localparam STORE_COMMIT    = 5'd10;
localparam WRITEBACK_MULT  = 5'd11;
localparam DATA_READ_ADDR  = 5'd12;
localparam DATA_READ_WAIT  = 5'd13;
localparam DATA_WRITE_ADDR = 5'd14;
localparam DATA_WRITE_DATA = 5'd15;
localparam DATA_WRITE_RESP = 5'd16;
localparam EXEC_DONE       = 5'd17;
localparam CLEAR_REGS      = 5'd18;
localparam DRAIN_STORE     = 5'd19;
localparam EXEC_BOTH_FAST  = 5'd20;
localparam DCACHE_WB       = 5'd21;
localparam INST_WB         = 5'd22;

reg [4:0] cs, ns;
wire t0_halted = (pc_1 >= 14'h2000);
// OPTIMIZED: 14-bit comparison
wire t1_halted = (pc_2 >= 14'h2000); // OPTIMIZED: 14-bit comparison
wire active_halted = (thread_id == 1'b0) ?
t0_halted : t1_halted;

// ==========================================================================
// Dual Core Register Reading (Functions)
// ==========================================================================
function [15:0] read_core1;
    input [2:0] a;
begin
        case(a)
            3'd0: read_core1 = core_1_r0;
            3'd1: read_core1 = core_1_r1;
            3'd2: read_core1 = core_1_r2;
            3'd3: read_core1 = core_1_r3;
            3'd4: read_core1 = core_1_r4;
            3'd5: read_core1 = core_1_r5;
            3'd6: read_core1 = core_1_r6;
            3'd7: read_core1 = core_1_r7;
        endcase
    end
endfunction

function [15:0] read_core2;
    input [2:0] a;
begin
        case(a)
            3'd0: read_core2 = core_2_r0;
            3'd1: read_core2 = core_2_r1;
            3'd2: read_core2 = core_2_r2;
            3'd3: read_core2 = core_2_r3;
            3'd4: read_core2 = core_2_r4;
            3'd5: read_core2 = core_2_r5;
            3'd6: read_core2 = core_2_r6;
            3'd7: read_core2 = core_2_r7;
        endcase
    end
endfunction

// ==========================================================================
// Instruction Decoding & Arbitration Logic
// ==========================================================================
wire [13:0] active_pc   = (thread_id == 1'b0) ?
pc_1 : pc_2; // OPTIMIZED
wire [15:0] active_inst = (thread_id == 1'b0) ? inst_reg_1 : inst_reg_2;

wire [2:0] opcode = active_inst[15:13];
wire [2:0] rs     = active_inst[12:10];
wire [2:0] rt     = active_inst[9:7];
wire [2:0] rd     = active_inst[6:4];
wire [2:0] func   = active_inst[3:1];
wire [2:0] rl     = active_inst[3:1];

// 8-Cycle Radix-4 Booth Multiplier Tracking
reg [2:0] mul_cnt;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        mul_cnt <= 3'd0;
    end 
    else if (cs == EXECUTE && opcode == 3'b001 && !active_halted) begin
        mul_cnt <= 3'd0;
    end 
    else if (cs == MULT_WAIT) begin
        mul_cnt <= mul_cnt + 3'd1;
    end
end

wire [2:0] op1 = inst_reg_1[15:13];
wire [2:0] op2 = inst_reg_2[15:13];
wire t0_is_store = !t0_halted && (op1 == 3'b101);
wire t1_is_store = !t1_halted && (op2 == 3'b101);

wire t1_goes_first = t1_is_store && !t0_is_store; 
wire next_thread_to_exec = exec_order ?
1'b0 : 1'b1;
wire next_thread_halted  = (next_thread_to_exec == 1'b0) ? t0_halted : t1_halted;
// --------------------------------------------------------------------------
// Fast Path Evaluation
// --------------------------------------------------------------------------
wire t0_fast_op = !t0_halted &&
                  (op1 == 3'b000 || op1 == 3'b010 || op1 == 3'b011 ||
                   op1 == 3'b110 || op1 == 3'b111);
wire t1_fast_op = !t1_halted &&
                  (op2 == 3'b000 || op2 == 3'b010 || op2 == 3'b011 ||
                   op2 == 3'b110 || op2 == 3'b111);
wire both_fast_path =
    (t0_halted || t0_fast_op) &&
    (t1_halted || t1_fast_op) &&
    !(t0_halted && t1_halted);
wire t0_slow_op = !t0_halted && !t0_fast_op;
wire t1_slow_op = !t1_halted && !t1_fast_op;
wire one_fast_one_slow =
    (t0_fast_op && t1_slow_op) ||
    (t1_fast_op && t0_slow_op);
wire slow_thread_id =
    (t0_slow_op && t1_fast_op) ? 1'b0 :
    (t1_slow_op && t0_fast_op) ?
    1'b1 :
                                 (t1_goes_first ? 1'b1 : 1'b0);
wire fast_thread_id =
    (t0_fast_op && t1_slow_op) ? 1'b0 :
    (t1_fast_op && t0_slow_op) ?
    1'b1 :
                                 1'b0;
wire fetch_exec_thread =
    one_fast_one_slow ? slow_thread_id :
    (t1_goes_first ? 1'b1 : 1'b0);
// --------------------------------------------------------------------------
// Early Decode Signals
// --------------------------------------------------------------------------
wire decode_stage = (cs == WAIT_SRAM_2);
wire [15:0] sram_inst_out;

reg [15:0] sram_do_r;
always @(posedge clk) begin
    sram_do_r <= sram_inst_out;
end
wire [15:0] dcache_data_r = sram_do_r;
wire [15:0] inst_data_r   = sram_do_r;

wire [15:0] dec_inst_1 = inst_reg_1;
wire [15:0] dec_inst_2 = inst_reg_2;

wire [2:0] dec_op1 = dec_inst_1[15:13];
wire [2:0] dec_op2 = dec_inst_2[15:13];
wire dec_t0_is_store = !t0_halted && (dec_op1 == 3'b101);
wire dec_t1_is_store = !t1_halted && (dec_op2 == 3'b101);
wire dec_t1_goes_first = dec_t1_is_store && !dec_t0_is_store;
wire dec_t0_fast_op = !t0_halted &&
    (dec_op1 == 3'b000 || dec_op1 == 3'b010 || dec_op1 == 3'b011 ||
     dec_op1 == 3'b110 || dec_op1 == 3'b111);
wire dec_t1_fast_op = !t1_halted &&
    (dec_op2 == 3'b000 || dec_op2 == 3'b010 || dec_op2 == 3'b011 ||
     dec_op2 == 3'b110 || dec_op2 == 3'b111);
wire dec_both_fast_path =
    (t0_halted || dec_t0_fast_op) &&
    (t1_halted || dec_t1_fast_op) &&
    !(t0_halted && t1_halted);
wire dec_t0_slow_op = !t0_halted && !dec_t0_fast_op;
wire dec_t1_slow_op = !t1_halted && !dec_t1_fast_op;
wire dec_one_fast_one_slow =
    (dec_t0_fast_op && dec_t1_slow_op) ||
    (dec_t1_fast_op && dec_t0_slow_op);
wire dec_slow_thread_id =
    (dec_t0_slow_op && dec_t1_fast_op) ? 1'b0 :
    (dec_t1_slow_op && dec_t0_fast_op) ?
    1'b1 :
                                         (dec_t1_goes_first ? 1'b1 : 1'b0);
wire dec_fast_thread_id =
    (dec_t0_fast_op && dec_t1_slow_op) ? 1'b0 :
    (dec_t1_fast_op && dec_t0_slow_op) ?
    1'b1 :
                                         1'b0;
wire dec_fetch_exec_thread =
    dec_one_fast_one_slow ? dec_slow_thread_id :
    (dec_t1_goes_first ? 1'b1 : 1'b0);
// ==========================================================================
// Unified Fast Path: Core 1 & Core 2 Shared Decode & ALU
// ==========================================================================
wire use_dec_fast = (cs == WAIT_SRAM_2);
wire [15:0] fast_inst_1 = inst_reg_1;
wire [15:0] fast_inst_2 = inst_reg_2;
wire [2:0] fast_op1   = fast_inst_1[15:13];
wire [2:0] fast_rs1   = fast_inst_1[12:10];
wire [2:0] fast_rt1   = fast_inst_1[9:7];
wire [2:0] fast_rd1   = fast_inst_1[6:4];
wire [2:0] fast_func1 = fast_inst_1[3:1];
wire signed [15:0] fast_imm1 = {{9{fast_inst_1[6]}}, fast_inst_1[6:0]};
wire [2:0] fast_op2   = fast_inst_2[15:13];
wire [2:0] fast_rs2   = fast_inst_2[12:10];
wire [2:0] fast_rt2   = fast_inst_2[9:7];
wire [2:0] fast_rd2   = fast_inst_2[6:4];
wire [2:0] fast_func2 = fast_inst_2[3:1];
wire signed [15:0] fast_imm2 = {{9{fast_inst_2[6]}}, fast_inst_2[6:0]};

wire signed [15:0] fast_c1_rs = read_core1(fast_rs1);
wire signed [15:0] fast_c1_rt = read_core1(fast_rt1);
wire signed [15:0] fast_c2_rs = read_core2(fast_rs2);
wire signed [15:0] fast_c2_rt = read_core2(fast_rt2);
// Shared Fast ALU 1
wire fast_c1_use_imm = (fast_op1 == 3'b010) || (fast_op1 == 3'b011);
wire fast_c1_do_sub  = (fast_op1 == 3'b011) ||
                       (fast_op1 == 3'b000 && fast_func1 == 3'b001) ||
                       (fast_op1 == 3'b000 && fast_func1 == 3'b111);

wire signed [15:0] fast_c1_b = fast_c1_use_imm ? fast_imm1 : fast_c1_rt;
wire [15:0] fast_c1_b2 = fast_c1_b ^ {16{fast_c1_do_sub}};
wire signed [15:0] fast_c1_addsub = fast_c1_rs + fast_c1_b2 + {15'd0, fast_c1_do_sub};
wire fast_c1_slt =
    (fast_c1_rs[15] != fast_c1_rt[15]) ? fast_c1_rs[15] : fast_c1_addsub[15];

reg [15:0] fast_c1_alu;
always @(*) begin
    case (fast_op1)
        3'b000: begin
            case (fast_func1)
                3'b000, 3'b001: fast_c1_alu = fast_c1_addsub;
                3'b010: fast_c1_alu = fast_c1_rs & fast_c1_rt;
                3'b011: fast_c1_alu = fast_c1_rs | fast_c1_rt;
                3'b100: fast_c1_alu = ~(fast_c1_rs & fast_c1_rt);
                3'b101: fast_c1_alu = ~(fast_c1_rs | fast_c1_rt);
                3'b110: fast_c1_alu = fast_c1_rs ^ fast_c1_rt;
                3'b111: fast_c1_alu = {15'd0, fast_c1_slt};
                default: fast_c1_alu = 16'd0;
            endcase
        end
        3'b010, 3'b011: fast_c1_alu = fast_c1_addsub;
        default: fast_c1_alu = 16'd0;
    endcase
end

// Shared Fast ALU 2
wire fast_c2_use_imm = (fast_op2 == 3'b010) || (fast_op2 == 3'b011);
wire fast_c2_do_sub  = (fast_op2 == 3'b011) ||
                       (fast_op2 == 3'b000 && fast_func2 == 3'b001) ||
                       (fast_op2 == 3'b000 && fast_func2 == 3'b111);

wire signed [15:0] fast_c2_b = fast_c2_use_imm ? fast_imm2 : fast_c2_rt;
wire [15:0] fast_c2_b2 = fast_c2_b ^ {16{fast_c2_do_sub}};
wire signed [15:0] fast_c2_addsub = fast_c2_rs + fast_c2_b2 + {15'd0, fast_c2_do_sub};
wire fast_c2_slt =
    (fast_c2_rs[15] != fast_c2_rt[15]) ? fast_c2_rs[15] : fast_c2_addsub[15];

reg [15:0] fast_c2_alu;
always @(*) begin
    case (fast_op2)
        3'b000: begin
            case (fast_func2)
                3'b000, 3'b001: fast_c2_alu = fast_c2_addsub;
                3'b010: fast_c2_alu = fast_c2_rs & fast_c2_rt;
                3'b011: fast_c2_alu = fast_c2_rs | fast_c2_rt;
                3'b100: fast_c2_alu = ~(fast_c2_rs & fast_c2_rt);
                3'b101: fast_c2_alu = ~(fast_c2_rs | fast_c2_rt);
                3'b110: fast_c2_alu = fast_c2_rs ^ fast_c2_rt;
                3'b111: fast_c2_alu = {15'd0, fast_c2_slt};
                default: fast_c2_alu = 16'd0;
            endcase
        end
        3'b010, 3'b011: fast_c2_alu = fast_c2_addsub;
        default: fast_c2_alu = 16'd0;
    endcase
end

// Shared Fast PC Update Logic (Merged Adder Datapath) // OPTIMIZED
wire fast_c1_is_branch = (fast_op1 == 3'b110);
wire fast_c2_is_branch = (fast_op2 == 3'b110);

wire fast_c1_branch_taken = fast_c1_is_branch && (fast_c1_rs == fast_c1_rt);
wire fast_c2_branch_taken = fast_c2_is_branch && (fast_c2_rs == fast_c2_rt);

wire [13:0] fast_c1_branch_off_raw = {{6{fast_inst_1[6]}}, fast_inst_1[6:0], 1'b0};
wire [13:0] fast_c2_branch_off_raw = {{6{fast_inst_2[6]}}, fast_inst_2[6:0], 1'b0};

wire [13:0] fast_c1_add_op = fast_c1_branch_taken ? fast_c1_branch_off_raw : 14'd0;
wire [13:0] fast_c2_add_op = fast_c2_branch_taken ? fast_c2_branch_off_raw : 14'd0;

wire [13:0] fast_c1_jump_pc = {1'b0, fast_inst_1[12:0]};
wire [13:0] fast_c2_jump_pc = {1'b0, fast_inst_2[12:0]};

wire [13:0] fast_c1_next_pc = (fast_op1 == 3'b111) ?
    fast_c1_jump_pc : (pc_1 + fast_c1_add_op + 14'd2);
wire [13:0] fast_c2_next_pc = (fast_op2 == 3'b111) ?
    fast_c2_jump_pc : (pc_2 + fast_c2_add_op + 14'd2);

// ==========================================================================
// Fast Path Result Registers
// ==========================================================================
wire [15:0] fast_c1_alu_r = fast_c1_alu;
wire [15:0] fast_c2_alu_r = fast_c2_alu;
reg [13:0] fast_c1_next_pc_r, fast_c2_next_pc_r; // OPTIMIZED

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        fast_c1_next_pc_r <= 14'd0;
        fast_c2_next_pc_r <= 14'd0;
    end
    else if (cs == FETCH_DONE) begin
        fast_c1_next_pc_r <= fast_c1_next_pc;
        fast_c2_next_pc_r <= fast_c2_next_pc;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        exec_order <= 1'b0;
        exec_step  <= 1'b0;
    end 
    else if (cs == CLEAR_REGS || cs == EXEC_BOTH_FAST) begin 
        exec_order <= 1'b0;
        exec_step  <= 1'b0;
    end 
    else if (cs == FETCH_DONE) begin 
        exec_order <= t1_goes_first;
        exec_step  <= 1'b0;
    end 
    else if (cs == EXEC_DONE) begin
        exec_step  <= 1'b1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        thread_id <= 1'b0;
    end 
    else if (cs == CLEAR_REGS || cs == EXEC_BOTH_FAST) begin
        thread_id <= 1'b0;
    end 
    else if (cs == FETCH_DONE) begin
        thread_id <= fetch_exec_thread;
    end 
    else if (cs == EXEC_DONE) begin
        if (exec_step == 1'b0) begin
            thread_id <= next_thread_to_exec;
        end 
        else begin
            thread_id <= 1'b0;
        end
    end
end

// --------------------------------------------------------------------------
// Parallel Fast/Slow Track Status Update
// --------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        par_fast_valid  <= 1'b0;
        par_fast_done   <= 1'b0;
        par_fast_thread <= 1'b0;
    end else begin
        if (cs == FETCH_DONE) begin
            par_fast_valid  <= one_fast_one_slow;
            par_fast_done   <= 1'b0;
            par_fast_thread <= fast_thread_id;
        end
        else if (cs == EXECUTE && par_fast_valid && !par_fast_done) begin
            par_fast_done <= 1'b1;
        end
        else if (cs == CHECK_HIT || cs == CLEAR_REGS) begin
            par_fast_valid <= 1'b0;
            par_fast_done  <= 1'b0;
        end
    end
end

// ==========================================================================
// SRAM 512x16 Cache Hit Logic (Inst & Data)
// ==========================================================================
reg [1:0] valid_1, valid_2;
reg [4:0] tag_1 [0:1];
reg [4:0] tag_2 [0:1];

// 2-Line x 128-word D-Cache: use full 256-word data half, longer line test
reg [1:0]  d_valid;
reg [3:0]  d_tag_arr [0:1];

wire idx_1 = pc_1[7];
wire [5:0] off_1 = pc_1[6:1];
wire [4:0] tag_1_val = pc_1[12:8];
wire idx_2 = pc_2[7];
wire [5:0] off_2 = pc_2[6:1];
wire [4:0] tag_2_val = pc_2[12:8];
wire hit_1 = valid_1[idx_1] && (tag_1[idx_1] == tag_1_val);
wire hit_2 = valid_2[idx_2] && (tag_2[idx_2] == tag_2_val);
wire miss_1 = !t0_halted && !hit_1;
wire miss_2 = !t1_halted && !hit_2;
// ==========================================================================
// Unified Line-Fill Engine (Replaces duplicated Normal Fetch + Prefetch)
// ==========================================================================
wire pf_window = (cs == DRAIN_STORE);
wire [5:0] line_1 = pc_1[12:7];
wire [5:0] line_2 = pc_2[12:7];

wire [5:0] next_line_1 = line_1 + 6'd1;
wire [5:0] next_line_2 = line_2 + 6'd1;

wire next_line_legal_1 = (line_1 != 6'd63);
wire next_line_legal_2 = (line_2 != 6'd63);
wire next_idx_1 = next_line_1[0];
wire next_idx_2 = next_line_2[0];

wire [4:0] next_tag_1 = next_line_1[5:1];
wire [4:0] next_tag_2 = next_line_2[5:1];
wire next_hit_1 = valid_1[next_idx_1] && (tag_1[next_idx_1] == next_tag_1);
wire next_hit_2 = valid_2[next_idx_2] && (tag_2[next_idx_2] == next_tag_2);
wire pf_cur_need_1  = !t0_halted && !hit_1;
wire pf_cur_need_2  = !t1_halted && !hit_2;
wire pf_next_need_1 = !t0_halted && hit_1 && next_line_legal_1 && !next_hit_1;
wire pf_next_need_2 = !t1_halted && hit_2 && next_line_legal_2 && !next_hit_2;
wire pf_need_1 = pf_cur_need_1 || pf_next_need_1;
wire pf_need_2 = pf_cur_need_2 || pf_next_need_2;
reg        lf_active;
reg        lf_is_pf;
reg        lf_req_1, lf_req_2;
reg        lf_ar_done_1, lf_ar_done_2;
reg        lf_r_done_1, lf_r_done_2;
reg [5:0]  lf_cnt_1, lf_cnt_2;
reg        lf_buf_valid;
reg        lf_buf_core;
reg [15:0] lf_buf_data;
reg        lf_buf_last;

reg [12:0] lf_addr_1, lf_addr_2;
// OPTIMIZED: 13-bit fetch address
reg        lf_idx_1, lf_idx_2;
reg [4:0]  lf_tag_1, lf_tag_2;
reg        drain_pf_triggered;

wire lf_r_fire_1 = rvalid_m_inf_inst_1 && rready_m_inf_inst_1 && lf_active;
wire lf_r_fire_2 = rvalid_m_inf_inst_2 && rready_m_inf_inst_2 && lf_active;
wire lf_buf_write = lf_active && lf_buf_valid;

wire lf_write_req_1 = lf_buf_write ?
    (lf_buf_core == 1'b0) : lf_r_fire_1;
wire lf_write_req_2 = lf_buf_write ? (lf_buf_core == 1'b1) : (!lf_r_fire_1 && lf_r_fire_2);
wire lf_write_last_1 = lf_buf_write ? (lf_buf_core == 1'b0 && lf_buf_last) : rlast_m_inf_inst_1;
wire lf_write_last_2 = lf_buf_write ?
    (lf_buf_core == 1'b1 && lf_buf_last) : rlast_m_inf_inst_2;

wire push_lf_buf = lf_active && !lf_buf_valid && lf_r_fire_1 && lf_r_fire_2;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        lf_active <= 1'b0;
        lf_is_pf  <= 1'b0;
        lf_req_1  <= 1'b0;
        lf_req_2  <= 1'b0;
        lf_ar_done_1 <= 1'b0;
        lf_ar_done_2 <= 1'b0;
        lf_r_done_1 <= 1'b0;
        lf_r_done_2 <= 1'b0;
        lf_cnt_1 <= 6'd0;
        lf_cnt_2 <= 6'd0;
        lf_buf_valid <= 1'b0;
        lf_buf_core <= 1'b0;
        lf_buf_data <= 16'd0;
        lf_buf_last <= 1'b0;
        
        lf_addr_1 <= 13'd0; // OPTIMIZED
        lf_addr_2 <= 13'd0;
        // OPTIMIZED
        
        lf_idx_1 <= 1'b0;
        lf_idx_2 <= 1'b0;
        lf_tag_1 <= 5'd0;
        lf_tag_2 <= 5'd0;
        drain_pf_triggered <= 1'b0;
    end else begin
        if (!pf_window) begin
            drain_pf_triggered <= 1'b0;
        end

        // NORMAL FETCH TRIGGER (from CHECK_HIT)
        if (cs == CHECK_HIT && (miss_1 || miss_2) && !lf_active) begin
            lf_active <= 1'b1;
            lf_is_pf  <= 1'b0;
            lf_req_1  <= miss_1;
            lf_req_2  <= miss_2;
            lf_ar_done_1 <= 1'b0;
            lf_ar_done_2 <= 1'b0;
            lf_r_done_1  <= 1'b0;
            lf_r_done_2  <= 1'b0;
            lf_cnt_1     <= 6'd0;
            lf_cnt_2     <= 6'd0;
            lf_buf_valid <= 1'b0;
            
            lf_addr_1 <= {pc_1[12:7], 7'd0};
            // OPTIMIZED
            lf_addr_2 <= {pc_2[12:7], 7'd0};
            // OPTIMIZED
            
            lf_idx_1  <= idx_1;
            lf_idx_2  <= idx_2;
            lf_tag_1  <= tag_1_val;
            lf_tag_2  <= tag_2_val;
        end
        // PREFETCH TRIGGER (from DRAIN_STORE)
        else if (pf_window && !drain_pf_triggered && !lf_active) begin
            drain_pf_triggered <= 1'b1;
            if (pf_need_1 || pf_need_2) begin
                lf_active <= 1'b1;
                lf_is_pf  <= 1'b1;
                lf_req_1  <= pf_need_1;
                lf_req_2  <= pf_need_2;
                lf_ar_done_1 <= 1'b0;
                lf_ar_done_2 <= 1'b0;
                lf_r_done_1  <= 1'b0;
                lf_r_done_2  <= 1'b0;
                lf_cnt_1     <= 6'd0;
                lf_cnt_2     <= 6'd0;
                lf_buf_valid <= 1'b0;
                
                lf_addr_1 <= pf_cur_need_1 ?
                    {pc_1[12:7], 7'd0}     // OPTIMIZED
                                            : {next_line_1, 7'd0};
                lf_addr_2 <= pf_cur_need_2 ? {pc_2[12:7], 7'd0}     // OPTIMIZED
                                            : {next_line_2, 7'd0};
                lf_idx_1  <= pf_cur_need_1 ? idx_1 : next_idx_1;
                lf_idx_2  <= pf_cur_need_2 ? idx_2 : next_idx_2;
                lf_tag_1  <= pf_cur_need_1 ? tag_1_val : next_tag_1;
                lf_tag_2  <= pf_cur_need_2 ? tag_2_val : next_tag_2;
            end
        end
        else if (lf_active) begin
            if (arvalid_m_inf_inst_1 && arready_m_inf_inst_1 && lf_req_1)
                lf_ar_done_1 <= 1'b1;
            if (arvalid_m_inf_inst_2 && arready_m_inf_inst_2 && lf_req_2)
                lf_ar_done_2 <= 1'b1;
            if (push_lf_buf) begin
                lf_buf_valid <= 1'b1;
                lf_buf_core  <= 1'b1;
                lf_buf_data  <= rdata_m_inf_inst_2;
                lf_buf_last  <= rlast_m_inf_inst_2;
            end
            else if (lf_buf_write) begin
                lf_buf_valid <= 1'b0;
            end

            if (lf_write_req_1) begin
                lf_cnt_1 <= lf_cnt_1 + 6'd1;
                lf_r_done_1 <= lf_write_last_1;
            end
            if (lf_write_req_2) begin
                lf_cnt_2 <= lf_cnt_2 + 6'd1;
                lf_r_done_2 <= lf_write_last_2;
            end

            if ((!lf_req_1 || lf_r_done_1) && (!lf_req_2 || lf_r_done_2)) begin
                lf_active <= 1'b0;
            end
        end
    end
end

// ==========================================================================
// AXI Instruction Fetch Assignments
// ==========================================================================
assign arid_m_inf_inst_1    = 4'b0000;
assign araddr_m_inf_inst_1  = {19'd0, lf_addr_1}; // OPTIMIZED: 19 zeros + 13 bit addr
assign arlen_m_inf_inst_1   = 7'd63;
assign arsize_m_inf_inst_1  = 3'b001;
assign arburst_m_inf_inst_1 = 2'b01;
assign arvalid_m_inf_inst_1 = lf_active && lf_req_1 && !lf_ar_done_1;
// OPTIMIZED: logic simplified

assign arid_m_inf_inst_2    = 4'b0000;
assign araddr_m_inf_inst_2  = {19'd0, lf_addr_2};
// OPTIMIZED: 19 zeros + 13 bit addr
assign arlen_m_inf_inst_2   = 7'd63;
assign arsize_m_inf_inst_2  = 3'b001;
assign arburst_m_inf_inst_2 = 2'b01;
assign arvalid_m_inf_inst_2 = lf_active && lf_req_2 && !lf_ar_done_2;
// OPTIMIZED: logic simplified

assign rready_m_inf_inst_1 = lf_active && lf_req_1 && !lf_r_done_1 && !lf_buf_valid;
assign rready_m_inf_inst_2 = lf_active && lf_req_2 && !lf_r_done_2 && !lf_buf_valid;
// ==========================================================================
// Sequential/Slow Path: Setup & Target Address (ALU Handled by Fast Path)
// ==========================================================================
wire read_thread_id =
    (cs == EXEC_DONE && exec_step == 1'b0) ?
    next_thread_to_exec :
    (cs == FETCH_DONE) ? fetch_exec_thread : thread_id;
wire [15:0] read_inst =
    (cs == FETCH_DONE) ?
    ((fetch_exec_thread == 1'b0) ? inst_reg_1 : inst_reg_2) :
    ((read_thread_id == 1'b0) ? inst_reg_1 : inst_reg_2);
// Re-use fast path read mux logic
wire [15:0] slow_rs = (read_thread_id == 1'b0) ? fast_c1_rs : fast_c2_rs;
wire [15:0] slow_rt = (read_thread_id == 1'b0) ? fast_c1_rt : fast_c2_rt;
// OPTIMIZED: 12-bit datapath calculation
wire signed [11:0] slow_rs_12  = slow_rs[11:0];
wire signed [11:0] slow_imm_12 = {{5{read_inst[6]}}, read_inst[6:0]};
wire [11:0] slow_mem_addr = slow_rs_12 + slow_imm_12;

reg [11:0] mem_addr_r; // OPTIMIZED: 12-bit register
wire       mem_line_idx_r = mem_addr_r[7];
wire [6:0] mem_word_off_r = mem_addr_r[6:0];
wire [3:0] mem_tag_r      = mem_addr_r[11:8];
wire       mem_is_load_r  = (opcode == 3'b100);
wire       mem_is_store_r = (opcode == 3'b101);
wire       mem_halted_r   = active_halted;

reg [13:0] seq_pc_plus_2_r; // OPTIMIZED: 14-bit
wire       seq_will_halt = (seq_pc_plus_2_r >= 14'h2000);
reg signed [15:0] rs_reg, rt_reg;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        rs_reg          <= 16'd0;
        rt_reg          <= 16'd0;
        seq_pc_plus_2_r <= 14'd0;
        mem_addr_r      <= 12'd0; // OPTIMIZED
    end 
    else if (cs == FETCH_DONE ||
            (cs == EXEC_DONE && exec_step == 1'b0 && !next_thread_halted)) begin 
        rs_reg          <= slow_rs;
        rt_reg          <= slow_rt;
        seq_pc_plus_2_r <= ((read_thread_id == 1'b0) ? pc_1 : pc_2) + 14'd2;
// OPTIMIZED
        mem_addr_r      <= slow_mem_addr;
    end
end

// ==========================================================================
// D-Cache Hit Evaluation (4-Line Optimized)
// ==========================================================================
wire       d_line_idx = mem_line_idx_r;
wire [6:0] d_word_off = mem_word_off_r;
wire [3:0] d_tag      = mem_tag_r;
wire d_hit = d_valid[d_line_idx] && (d_tag_arr[d_line_idx] == d_tag);
// ==========================================================================
// 2-Entry Store Queue (AXI PIPELINED OUTSTANDING ISSUE)
// ==========================================================================
reg        sq_head, sq_tail;
reg [1:0]  sq_count;

reg        issue_sent_aw;
reg        issue_sent_w;
reg [11:0] sq_addr [0:1];
reg [15:0] sq_data [0:1];
wire sq_full  = (sq_count == 2'd2);
wire sq_empty = (sq_count == 2'd0);
// -- Store Merge Logic --
wire store_exec = (cs == EXECUTE && mem_is_store_r && !mem_halted_r);
wire [1:0] unissued_count = sq_count; // entries not yet sent to DRAM

// -- Unified Store Merge & Load Forward Search Logic --
wire load_exec = (cs == EXECUTE && mem_is_load_r && !mem_halted_r);
reg        sq_search_hit;
reg        sq_search_idx;
reg [15:0] sq_search_data;

reg        sq_search_base;
reg [1:0]  sq_search_count;
reg        sq_search_cur;

reg [1:0]  sq_count_mask;
always @(*) begin
    case (sq_search_count)
        2'd0: sq_count_mask = 2'b00;
        2'd1: sq_count_mask = 2'b01;
        2'd2: sq_count_mask = 2'b11;
        default: sq_count_mask = 2'b11;
    endcase
end

integer q;
always @(*) begin
    if (store_exec) begin
        sq_search_base  = sq_head;
        sq_search_count = unissued_count;
    end
    else if (load_exec) begin
        sq_search_base  = sq_head;
        sq_search_count = sq_count;
    end
    else begin
        sq_search_base  = 1'b0;
        sq_search_count = 2'd0;
    end

    sq_search_hit  = 1'b0;
    sq_search_idx  = sq_search_base;
    sq_search_data = 16'd0;
    sq_search_cur  = 1'b0;

    for (q = 0; q < 2; q = q + 1) begin
        sq_search_cur = sq_search_base ^ q[0];
        if (sq_count_mask[q]) begin
            if (sq_addr[sq_search_cur] == mem_addr_r) begin // OPTIMIZED comparison
                sq_search_hit  = 1'b1;
                sq_search_idx  = sq_search_cur;
                sq_search_data = sq_data[sq_search_cur];
            end
        end
    end
end

wire sq_merge_hit = store_exec && sq_search_hit;
wire sq_merge_idx = sq_search_idx;

wire sq_hit = load_exec && sq_search_hit;
wire [15:0] sq_forward_val = sq_search_data;
// -- Pipelined Issue Logic --
wire aw_fire = awvalid_m_inf_data && awready_m_inf_data;
wire w_fire  = wvalid_m_inf_data  && wready_m_inf_data;
wire b_fire  = bvalid_m_inf_data  && bready_m_inf_data;

wire store_accepted;
wire sq_push_new = store_accepted && !sq_merge_hit;
wire sq_merge    = store_accepted && sq_merge_hit;

// SQ now keeps only stores that have not completed AW/W.
// Once AW and W both fire, the write is visible to the DRAM model, so free the entry.
wire sq_has_unissued = !sq_empty;
wire can_issue_store = sq_has_unissued && !(store_exec && sq_merge_hit);
wire issue_fire = can_issue_store && (issue_sent_aw || aw_fire) && (issue_sent_w || w_fire);
wire sq_pop_real = issue_fire;
assign store_accepted = store_exec && (sq_merge_hit || (!sq_full || sq_pop_real));
integer k;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        sq_head <= 1'd0;
        sq_tail <= 1'd0;
        sq_count <= 2'd0;
        
        issue_sent_aw  <= 1'b0;
        issue_sent_w   <= 1'b0;
        
        for (k=0; k<2; k=k+1) begin
            sq_addr[k] <= 12'd0;
            sq_data[k] <= 16'd0;
        end
    end
    else if (cs == CLEAR_REGS) begin
        sq_head <= 1'd0;
        sq_tail <= 1'd0;
        sq_count <= 2'd0;
        
        issue_sent_aw  <= 1'b0;
        issue_sent_w   <= 1'b0;
    end
    else begin
        // Push / Merge
        if (sq_merge) begin
            sq_data[sq_merge_idx] <= rt_reg;
        end
        else if (sq_push_new) begin
            sq_addr[sq_tail] <= mem_addr_r;
// OPTIMIZED 12-bit connection
            sq_data[sq_tail] <= rt_reg;
            sq_tail <= sq_tail + 1'd1;
        end

        // Store Single Issue FSM
        if (can_issue_store) begin
            if (aw_fire) issue_sent_aw <= 1'b1;
            if (w_fire)  issue_sent_w  <= 1'b1;
        end
        
        if (issue_fire) begin
            issue_sent_aw <= 1'b0;
            issue_sent_w  <= 1'b0;
            sq_head <= sq_head + 1'd1;
        end

        // sq_count counts only entries whose AW/W are not both accepted yet.
        if (sq_push_new && issue_fire)
            sq_count <= sq_count;
        else if (sq_push_new)
            sq_count <= sq_count + 2'd1;
        else if (issue_fire)
            sq_count <= sq_count - 2'd1;
    end
end

// ==========================================================================
// D-Cache SRAM Request Register
// ==========================================================================
reg        d_sram_we_r;
wire [15:0] d_sram_di_r = rt_reg;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        d_sram_we_r <= 1'b0;
    end
    else if (cs == CLEAR_REGS) begin
        d_sram_we_r <= 1'b0;
    end
    else if (cs == EXECUTE) begin
        d_sram_we_r <= !mem_halted_r &&
                       (mem_is_store_r && store_accepted && d_hit);
    end
end

// Track Bypass to safely read from Buffer in EXEC_DONE
reg was_dcache_hit;
reg was_sq_hit;
reg [15:0] load_forward_data;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        was_dcache_hit     <= 1'b0;
        was_sq_hit         <= 1'b0;
        load_forward_data  <= 16'd0;
    end
    else if (cs == EXECUTE) begin
        was_sq_hit         <= (mem_is_load_r && sq_hit);
        was_dcache_hit     <= (mem_is_load_r && !sq_hit && d_hit);
        if (mem_is_load_r && sq_hit)
            load_forward_data <= sq_forward_val;
    end
end

// ==========================================================================
// D-Cache Line Fill Registers
// ==========================================================================
reg [6:0] fill_cnt;
reg [15:0] load_miss_data;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        fill_cnt       <= 7'd0;
        load_miss_data <= 16'd0;
    end
    else begin
        if (cs == EXECUTE && mem_is_load_r && !mem_halted_r && !sq_hit && !d_hit) begin
            fill_cnt      <= 7'd0;
        end
        else if (cs == DATA_READ_WAIT && rvalid_m_inf_data) begin
            fill_cnt <= fill_cnt + 7'd1;
            if (fill_cnt == mem_word_off_r)
                load_miss_data <= rdata_m_inf_data;
        end
    end
end

// ==========================================================================
// PC Update Trigger & Target Generation
// ==========================================================================
wire inst_done_pulse = !active_halted && (
                       (cs == EXEC_DONE && (opcode == 3'b000 || opcode == 3'b010 || opcode == 3'b011 || opcode == 3'b001 || opcode == 3'b101)) ||
                       (cs == EXECUTE && (opcode == 3'b110 || opcode == 3'b111 || 
  
                       (mem_is_load_r && (sq_hit || d_hit)))) ||
                       (cs == DATA_READ_WAIT && rvalid_m_inf_data && rlast_m_inf_data)
                       );
wire other_halted_now = (thread_id == 1'b0) ? t1_halted : t0_halted;
wire program_end_after_this =
    (cs == EXEC_DONE) &&
    other_halted_now &&
    seq_will_halt &&
    (exec_step == 1'b1 || (exec_step == 1'b0 && par_fast_done));
always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        pc_1 <= 14'd0;
// OPTIMIZED
        pc_2 <= 14'd0;
// OPTIMIZED
    end 
    else if (cs == CLEAR_REGS) begin
        pc_1 <= 14'd0;
// OPTIMIZED
        pc_2 <= 14'd0;
// OPTIMIZED
    end 
    else begin
        if (cs == EXEC_BOTH_FAST) begin
            if (!t0_halted) pc_1 <= fast_c1_next_pc_r;
            if (!t1_halted) pc_2 <= fast_c2_next_pc_r;
        end
        else if (cs == EXECUTE && par_fast_valid && !par_fast_done) begin
            if (par_fast_thread == 1'b0)
                pc_1 <= fast_c1_next_pc_r;
            else
                pc_2 <= fast_c2_next_pc_r;
        end
        else if (cs == EXEC_DONE && !active_halted) begin
            if (thread_id == 1'b0)
                pc_1 <= seq_pc_plus_2_r;
            else
                pc_2 <= seq_pc_plus_2_r;
        end
    end
end

// ==========================================================================
// Instruction Counter & Drain Sync
// ==========================================================================
reg [5:0] inst_mod50;
wire store_visible_done = sq_empty && !issue_sent_aw && !issue_sent_w;
wire store_resp_done = store_visible_done;
wire store_all_done = store_visible_done;

wire fast_c1_will_halt_wb = t0_halted || (fast_c1_next_pc_r >= 14'h2000); // OPTIMIZED
wire fast_c2_will_halt_wb = t1_halted ||
(fast_c2_next_pc_r >= 14'h2000); // OPTIMIZED

wire fast_program_end_after_this =
    (cs == EXEC_BOTH_FAST) && fast_c1_will_halt_wb && fast_c2_will_halt_wb;
wire checkpoint_need_drain =
    (inst_mod50 == 6'd49) && !store_visible_done;
wire final_need_drain =
    program_end_after_this && !store_resp_done;
wire fast_checkpoint_need_drain =
    (inst_mod50 == 6'd49) && !store_visible_done;
wire fast_final_need_drain =
    fast_program_end_after_this && !store_resp_done;
wire fast_need_drain =
    fast_checkpoint_need_drain || fast_final_need_drain;
wire need_drain_before_done =
    checkpoint_need_drain || final_need_drain;

reg drain_wait_resp;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        drain_wait_resp <= 1'b0;
    end
    else if (cs == CLEAR_REGS) begin
        drain_wait_resp <= 1'b0;
    end
    else if (cs == EXEC_BOTH_FAST && fast_need_drain) begin
        drain_wait_resp <= fast_program_end_after_this;
    end
    else if (cs == EXEC_DONE && need_drain_before_done) begin
        drain_wait_resp <= program_end_after_this;
    end
    else if (cs == CHECK_HIT && t0_halted && t1_halted && !store_resp_done) begin
        drain_wait_resp <= 1'b1;
    end
end

wire pair_done_with_parallel_fast =
    (cs == EXEC_DONE && exec_step == 1'b0 && par_fast_done);
wire normal_done =
    ((cs == EXEC_DONE && exec_step == 1'b1) || pair_done_with_parallel_fast) &&
    !need_drain_before_done;
wire drain_finish = drain_wait_resp ? store_resp_done : store_visible_done;
wire drain_done  = (cs == DRAIN_STORE && drain_finish);
wire fast_done = (cs == EXEC_BOTH_FAST && !fast_need_drain);

wire finish_pulse = normal_done || drain_done || fast_done;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        inst_mod50 <= 6'd0;
    end
    else if (finish_pulse) begin
        if (inst_mod50 == 6'd49)
            inst_mod50 <= 6'd0;
        else
            inst_mod50 <= inst_mod50 + 6'd1;
    end
end

// ==========================================================================
// FSM
// ==========================================================================
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) cs <= IDLE;
    else        cs <= ns;
end

always @(*) begin
    case (cs)
        IDLE: ns = CHECK_HIT;
        CHECK_HIT: begin
            if (lf_active) begin
                ns = CHECK_HIT;
            end
            else if (t0_halted && t1_halted) begin
                if (!store_resp_done) ns = DRAIN_STORE;
                else                  ns = CLEAR_REGS;
            end
            else if (miss_1 || miss_2)  ns = FETCH_MISS;
            else ns = READ_SRAM_2;
        end
        FETCH_MISS: begin
            if (!lf_active) ns = READ_SRAM_2;
            else ns = FETCH_MISS;
        end
        READ_SRAM_1: ns = READ_SRAM_2;
        READ_SRAM_2: ns = WAIT_SRAM_2;
        WAIT_SRAM_2: ns = INST_WB;
        INST_WB:     ns = FETCH_DONE;
        FETCH_DONE: begin
            if (both_fast_path) ns = EXEC_BOTH_FAST;
            else begin
                if (t1_goes_first ? t1_halted : t0_halted) ns = EXEC_DONE;
                else ns = EXECUTE;
            end
        end
        EXEC_BOTH_FAST: begin
            if (fast_need_drain) ns = DRAIN_STORE;
            else                 ns = CHECK_HIT;
        end
        EXECUTE: begin 
            if (active_halted)          ns = EXEC_DONE;
            else if (mem_is_load_r) begin
                if (sq_hit)             ns = EXEC_DONE;
                else if (d_hit)         ns = DCACHE_SRAM;
// Load Miss proceeds
                else                    ns = DATA_READ_ADDR;
            end
            else if (mem_is_store_r) begin
                if (!sq_merge_hit && sq_full && !sq_pop_real) ns = EXECUTE;
// Stall Store if Queue is full and cannot merge
                else if (d_hit)                              ns = DCACHE_SRAM;
                else                                         ns = EXEC_DONE;
            end
            else if (opcode == 3'b110 || opcode == 3'b111) ns = EXEC_DONE;
            else if (opcode == 3'b001)  ns = MULT_WAIT; 
            else                        ns = EXEC_DONE;
        end
        STORE_COMMIT: begin
            if (d_sram_we_r)
                ns = DCACHE_SRAM;
            else
                ns = EXEC_DONE;
        end
        DCACHE_SRAM: ns = d_sram_we_r ? EXEC_DONE : DCACHE_WB;
        DCACHE_WB:   ns = EXEC_DONE;
        MULT_WAIT: begin
            if (mul_cnt == 3'd7) ns = WRITEBACK_MULT;
            else                 ns = MULT_WAIT;
        end
        WRITEBACK_MULT: ns = EXEC_DONE;                  

        DATA_READ_ADDR:  if (arready_m_inf_data) ns = DATA_READ_WAIT;
        else ns = DATA_READ_ADDR;
        DATA_READ_WAIT:  if (rvalid_m_inf_data && rlast_m_inf_data) ns = EXEC_DONE; else ns = DATA_READ_WAIT;
        EXEC_DONE: begin
            if (exec_step == 1'b0) begin
                if (par_fast_done) begin
                    if (need_drain_before_done) ns = DRAIN_STORE;
                    else                        ns = CHECK_HIT;
                end
                else begin
                    if (next_thread_halted) ns = EXEC_DONE;
                    else                    ns = EXECUTE;
                end
            end 
            else begin
                if (need_drain_before_done) ns = DRAIN_STORE;
                else                        ns = CHECK_HIT;
            end
        end
        DRAIN_STORE: begin
            if (drain_finish) ns = CHECK_HIT;
            else              ns = DRAIN_STORE;
        end
        CLEAR_REGS: ns = IDLE;
        default: ns = IDLE;
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        stall_1 <= 1'b1;
        stall_2 <= 1'b1;
    end 
    else begin
        stall_1 <= ~(normal_done || drain_done || fast_done);
        stall_2 <= ~(normal_done || drain_done || fast_done);
    end
end

// ==========================================================================
// Cache Regs Update Logic
// ==========================================================================
integer i, j;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        valid_1 <= 2'd0;
        valid_2 <= 2'd0;
        for (i=0; i<2; i=i+1) begin
            tag_1[i] <= 5'd0;
            tag_2[i] <= 5'd0;
        end
        
        d_valid <= 2'd0;
        for (j=0; j<2; j=j+1) begin
            d_tag_arr[j] <= 4'd0;
        end
    end 
    else if (cs == CLEAR_REGS) begin 
        valid_1 <= 2'd0;
        valid_2 <= 2'd0;
        d_valid <= 2'd0;
    end 
    else begin
        if (lf_active) begin
            if (lf_write_req_1 && lf_write_last_1) begin
                valid_1[lf_idx_1] <= 1'b1;
                tag_1[lf_idx_1] <= lf_tag_1;
            end
            if (lf_write_req_2 && lf_write_last_2) begin
                valid_2[lf_idx_2] <= 1'b1;
                tag_2[lf_idx_2] <= lf_tag_2;
            end
        end
        
        // No-Write-Allocate D-Cache Update
        // Update D-Cache only on line-fill completion from Load Miss
        if ((cs == DATA_READ_WAIT) && rvalid_m_inf_data && rlast_m_inf_data) begin
            d_valid[mem_line_idx_r] <= 1'b1;
            d_tag_arr[mem_line_idx_r] <= mem_tag_r;
        end
    end
end

// ==========================================================================
// Unified SRAM (512x16) Memory Access - AREA FRIENDLY VERSION
// ==========================================================================
wire hit_read_1 =
    (cs == CHECK_HIT) &&
    !(t0_halted && t1_halted) &&
    !(miss_1 || miss_2) &&
    !lf_active;
wire miss_done_read_1    = (cs == FETCH_MISS) && !lf_active;
wire is_read_1           = (cs == READ_SRAM_1) || hit_read_1 || miss_done_read_1;
wire is_read_2           = (cs == READ_SRAM_2);
wire is_d_store          = (cs == DCACHE_SRAM) && d_sram_we_r;
wire d_load_sram_req     = (cs == DCACHE_SRAM) && !d_sram_we_r;

wire data_read_wait = (cs == DATA_READ_WAIT);
wire is_d_load_miss_fill = data_read_wait && rvalid_m_inf_data;
wire lf_we = lf_buf_write | lf_r_fire_1 | lf_r_fire_2;
// -----------------------------
// Inst-side mux first
// -----------------------------
// Timing fix: do not use lf_r_fire_1 on SRAM DI select.
// lf_r_fire_1 expands through rready/lf_active logic and creates the
// rvalid_m_inf_inst_1 -> SRAM DI critical path.  For DI/address selection,
// only the raw incoming beat direction is needed; actual write enable still
// uses lf_we/lf_r_fire_*.  This keeps behavior identical but removes logic depth.
// Timing-lite select for SRAM A/DI: do not put lf_req/lf_r_done on rvalid -> SRAM path.
// SRAM WEB is still controlled by lf_r_fire_*, so no illegal write is introduced.
wire inst_rbeat1_fast = rvalid_m_inf_inst_1;

wire sel_lf_1 = lf_buf_valid ?
    (lf_buf_core == 1'b0) : inst_rbeat1_fast;
wire [7:0] inst_lf_addr =
    sel_lf_1 ? {1'b0, lf_idx_1, lf_cnt_1} : {1'b1, lf_idx_2, lf_cnt_2};
wire [7:0] inst_read_addr =
    is_read_1 ? {1'b0, idx_1, off_1} : {1'b1, idx_2, off_2};
wire [7:0] inst_addr_low =
    lf_active ? inst_lf_addr : inst_read_addr;
wire [15:0] inst_lf_data =
    lf_buf_valid ? lf_buf_data :
    inst_rbeat1_fast ? rdata_m_inf_inst_1 : rdata_m_inf_inst_2;
wire [15:0] inst_wdata = inst_lf_data;

wire inst_access = lf_active | is_read_1 | is_read_2;
wire inst_we     = lf_we;

// -----------------------------
// Data-side mux first
// -----------------------------
wire [7:0] data_addr_low =
    data_read_wait ? {mem_line_idx_r, fill_cnt} :
                     {mem_line_idx_r, mem_word_off_r};

// 重點：DI select 不要用 rvalid_m_inf_data
wire [15:0] data_wdata =
    data_read_wait ? rdata_m_inf_data : d_sram_di_r;

wire data_access = is_d_store | d_load_sram_req | data_read_wait;

// write enable 才用 rvalid
wire data_we = is_d_store | is_d_load_miss_fill;
// -----------------------------
// Final SRAM mux: only choose inst/data
// -----------------------------
wire use_data = data_access & ~inst_access;

wire [8:0] sram_addr = use_data ?
    {1'b1, data_addr_low} : {1'b0, inst_addr_low};
wire [15:0] sram_di = use_data ? data_wdata : inst_wdata;
wire sram_we_n = ~(use_data ? data_we : inst_we);

wire sram_cs = inst_access | data_access;
MEM_512X16 Shared_Cache_SRAM (
    .CLK(clk), .CS(sram_cs), .OE(1'b1), .WEB(sram_we_n),
    .A(sram_addr), .DI(sram_di), .DO(sram_inst_out)
);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        inst_reg_1 <= 16'd0;
        inst_reg_2 <= 16'd0;
    end 
    else begin
        if (cs == WAIT_SRAM_2) inst_reg_1 <= inst_data_r;
        if (cs == INST_WB)     inst_reg_2 <= inst_data_r;
    end
end

// ==========================================================================
// Sequential Path: AXI Addr & Mult (16-cycle Iterative Shift-Add)
// ==========================================================================
wire [4:0] data_line_base = mem_addr_r[11:7];
// OPTIMIZED
reg [13:0] axi_addr_reg; // OPTIMIZED: 14-bit register

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        axi_addr_reg <= 14'd0;
// OPTIMIZED
    end 
    else if (cs == EXECUTE) begin
        axi_addr_reg <= {
            data_line_base[4],
            ~data_line_base[4],
            data_line_base[3:0],
            8'b00000000
        };
    end
end

// 8-cycle radix-4 Booth multiplier: cuts MULT_WAIT from 16 cycles to 8 cycles.
reg signed [17:0] booth_acc;
reg signed [17:0] booth_m;
reg [15:0]        booth_q;
reg               booth_qm1;

wire [2:0] booth_sel = {booth_q[1:0], booth_qm1};
reg signed [17:0] booth_addend;
always @(*) begin
    case (booth_sel)
        3'b001, 3'b010: booth_addend = booth_m;
        3'b011:         booth_addend = booth_m <<< 1;
        3'b100:         booth_addend = -(booth_m <<< 1);
        3'b101, 3'b110: booth_addend = -booth_m;
        default:        booth_addend = 18'sd0;
    endcase
end

wire signed [17:0] booth_acc_op = booth_acc + booth_addend;
wire signed [34:0] booth_shift_in  = {booth_acc_op, booth_q, booth_qm1};
wire signed [34:0] booth_shift_out = booth_shift_in >>> 2;
wire [31:0] mult_product = {booth_acc[15:0], booth_q};

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        booth_acc <= 18'sd0;
        booth_m   <= 18'sd0;
        booth_q   <= 16'd0;
        booth_qm1 <= 1'b0;
    end 
    else if (cs == EXECUTE) begin
        booth_acc <= 18'sd0;
        booth_m   <= {{2{rs_reg[15]}}, rs_reg};
        booth_q   <= rt_reg;
        booth_qm1 <= 1'b0;
    end 
    else if (cs == MULT_WAIT) begin
        booth_acc <= booth_shift_out[34:17];
        booth_q   <= booth_shift_out[16:1];
        booth_qm1 <= booth_shift_out[0];
    end
end

// ==========================================================================
// AXI Data Channel Assignments
// ==========================================================================
assign arid_m_inf_data    = 4'b0000;
assign arlen_m_inf_data   = 7'd127;
assign arsize_m_inf_data  = 3'b001;
assign arburst_m_inf_data = 2'b01;
assign araddr_m_inf_data  = {18'd0, axi_addr_reg};
// OPTIMIZED: 18 zeros + 14-bit
assign arvalid_m_inf_data = (cs == DATA_READ_ADDR);
assign rready_m_inf_data  = (cs == DATA_READ_WAIT);
// AXI Data Write mapped to Pipelined Single Issue Store Queue
assign awid_m_inf_data    = 4'b0000;
assign awlen_m_inf_data   = 7'd0;
assign awsize_m_inf_data  = 3'b001;
assign awburst_m_inf_data = 2'b01;
assign awaddr_m_inf_data  = {
    16'd0,
    2'b00,
    sq_addr[sq_head][11],
    ~sq_addr[sq_head][11],
    sq_addr[sq_head][10:0],
    1'b0
};
assign awvalid_m_inf_data = can_issue_store && !issue_sent_aw;
assign wdata_m_inf_data   = sq_data[sq_head];
assign wvalid_m_inf_data  = can_issue_store && !issue_sent_w;
assign wlast_m_inf_data   = 1'b1;

// PIPELINE FIX: BREADY always high if we issued any stores, preventing wait-stalls.
assign bready_m_inf_data  = 1'b1;

// ==========================================================================
// Unified Writeback Logic (Area Optimized)
// ==========================================================================
wire c_is_load_axi       = (cs == DATA_READ_WAIT && rvalid_m_inf_data && rlast_m_inf_data);
wire c_is_load_dcache_wb = (!active_halted && cs == EXEC_DONE && opcode == 3'b100 && was_dcache_hit);
wire c_is_load_sq_wb     = (!active_halted && cs == EXEC_DONE && opcode == 3'b100 && was_sq_hit);
wire c_is_load           = c_is_load_axi | c_is_load_dcache_wb | c_is_load_sq_wb;
wire c_is_mult_l = (!active_halted && cs == EXEC_DONE && opcode == 3'b001); 
wire c_is_mult_h = (!active_halted && cs == WRITEBACK_MULT);
wire slow_wb_en = c_is_load | c_is_mult_l | c_is_mult_h;

wire [15:0] load_axi_data = (fill_cnt == mem_word_off_r) ? rdata_m_inf_data : load_miss_data;
wire [15:0] slow_wb_data = c_is_load_sq_wb     ? load_forward_data :
                           c_is_load_dcache_wb ? dcache_data_r :
                           c_is_load_axi       ? load_axi_data :
                           c_is_mult_h         ? mult_product[31:16] :
                                                 mult_product[15:0];
wire [2:0] slow_waddr = c_is_load   ? rt :
                        c_is_mult_l ? rl :
                                      rd;
// -- Fast Path Writeback Decoding --
wire [2:0] fast_op1_wb = inst_reg_1[15:13];
wire [2:0] fast_rd1_wb = inst_reg_1[6:4];
wire [2:0] fast_rt1_wb = inst_reg_1[9:7];

wire [2:0] fast_op2_wb = inst_reg_2[15:13];
wire [2:0] fast_rd2_wb = inst_reg_2[6:4];
wire [2:0] fast_rt2_wb = inst_reg_2[9:7];
wire fast_c1_wen =
    !t0_halted &&
    (fast_op1_wb == 3'b000 || fast_op1_wb == 3'b010 || fast_op1_wb == 3'b011);
wire [2:0] fast_c1_waddr =
    (fast_op1_wb == 3'b000) ? fast_rd1_wb : fast_rt1_wb;
wire fast_c2_wen =
    !t1_halted &&
    (fast_op2_wb == 3'b000 || fast_op2_wb == 3'b010 || fast_op2_wb == 3'b011);
wire [2:0] fast_c2_waddr =
    (fast_op2_wb == 3'b000) ? fast_rd2_wb : fast_rt2_wb;
reg        c1_wen;
reg [2:0]  c1_waddr;
reg [15:0] c1_wdata;
reg        c2_wen;
reg [2:0]  c2_waddr;
reg [15:0] c2_wdata;
always @(*) begin
    c1_wen   = 1'b0;
    c1_waddr = 3'd0;
    c1_wdata = 16'd0;
    c2_wen   = 1'b0;
    c2_waddr = 3'd0;
    c2_wdata = 16'd0;
// both fast: 兩個 core 同拍寫
    if (cs == EXEC_BOTH_FAST) begin
        if (fast_c1_wen) begin
            c1_wen   = 1'b1;
            c1_waddr = fast_c1_waddr;
            c1_wdata = fast_c1_alu_r;
        end
        if (fast_c2_wen) begin
            c2_wen   = 1'b1;
            c2_waddr = fast_c2_waddr;
            c2_wdata = fast_c2_alu_r;
        end
    end

    // one fast one slow：快的那個先寫
    else if (cs == EXECUTE && par_fast_valid && !par_fast_done) begin
        if (par_fast_thread == 1'b0 && fast_c1_wen) begin
            c1_wen   = 1'b1;
            c1_waddr = fast_c1_waddr;
            c1_wdata = fast_c1_alu_r;
        end
        else if (par_fast_thread == 1'b1 && fast_c2_wen) begin
            c2_wen   = 1'b1;
            c2_waddr = fast_c2_waddr;
            c2_wdata = fast_c2_alu_r;
        end
    end

    // slow writeback：load / mult only
    else if (slow_wb_en) begin
        if (thread_id == 1'b0) begin
            c1_wen   = 1'b1;
            c1_waddr = slow_waddr;
            c1_wdata = slow_wb_data;
        end
        else begin
            c2_wen   = 1'b1;
            c2_waddr = slow_waddr;
            c2_wdata = slow_wb_data;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        core_1_r0 <= 0;
        core_2_r0 <= 0;
        core_1_r1 <= 0; core_2_r1 <= 0;
        core_1_r2 <= 0; core_2_r2 <= 0;
        core_1_r3 <= 0;
        core_2_r3 <= 0;
        core_1_r4 <= 0; core_2_r4 <= 0;
        core_1_r5 <= 0; core_2_r5 <= 0;
        core_1_r6 <= 0;
        core_2_r6 <= 0;
        core_1_r7 <= 0; core_2_r7 <= 0;
    end 
    else if (cs == CLEAR_REGS) begin
        core_1_r0 <= 0;
        core_2_r0 <= 0;
        core_1_r1 <= 0; core_2_r1 <= 0;
        core_1_r2 <= 0; core_2_r2 <= 0;
        core_1_r3 <= 0;
        core_2_r3 <= 0;
        core_1_r4 <= 0; core_2_r4 <= 0;
        core_1_r5 <= 0; core_2_r5 <= 0;
        core_1_r6 <= 0;
        core_2_r6 <= 0;
        core_1_r7 <= 0; core_2_r7 <= 0;
    end 
    else begin
        if (c1_wen) begin
            case (c1_waddr)
                3'd0: core_1_r0 <= c1_wdata;
                3'd1: core_1_r1 <= c1_wdata;
                3'd2: core_1_r2 <= c1_wdata;
                3'd3: core_1_r3 <= c1_wdata;
                3'd4: core_1_r4 <= c1_wdata;
                3'd5: core_1_r5 <= c1_wdata;
                3'd6: core_1_r6 <= c1_wdata;
                3'd7: core_1_r7 <= c1_wdata;
            endcase
        end
        if (c2_wen) begin
            case (c2_waddr)
                3'd0: core_2_r0 <= c2_wdata;
                3'd1: core_2_r1 <= c2_wdata;
                3'd2: core_2_r2 <= c2_wdata;
                3'd3: core_2_r3 <= c2_wdata;
                3'd4: core_2_r4 <= c2_wdata;
                3'd5: core_2_r5 <= c2_wdata;
                3'd6: core_2_r6 <= c2_wdata;
                3'd7: core_2_r7 <= c2_wdata;
            endcase
        end
    end
end

// ==========================================================================
// Performance Profiler ($display) - Ignored by Synthesis
// ========================================================================== 
// synthesis translate_off
integer cycles_total = 0;
integer cycles_fetch_miss = 0;
integer cycles_data_read = 0;
integer cycles_drain = 0;
integer cycles_store_stall = 0;

integer cyc_check_hit = 0;
integer cyc_read_sram_1 = 0;
integer cyc_read_sram_2 = 0;
integer cyc_wait_sram_2 = 0;
integer cyc_inst_wb = 0;
integer cyc_fetch_done = 0;
integer cyc_exec = 0;
integer cyc_exec_both_fast = 0;
integer cyc_exec_done = 0;
integer cyc_store_commit = 0;
integer cyc_dcache_sram = 0;
integer cyc_dcache_wb = 0;
integer cyc_mult_wait = 0;
integer cyc_data_read_addr = 0;

integer cnt_finish = 0;
integer cnt_fast_done = 0;
integer cnt_normal_done = 0;
integer cnt_drain_done = 0;
integer cnt_both_fast = 0;
integer cnt_one_fast_slow = 0;
integer cnt_slow_pair = 0;

integer cnt_miss1_only = 0;
integer cnt_miss2_only = 0;
integer cnt_miss_both = 0;
integer cnt_lf_start_norm = 0;
integer cnt_lf_start_pf = 0;
integer cyc_lf_active = 0;
integer cyc_lf_wait_ar1 = 0;
integer cyc_lf_wait_ar2 = 0;
integer cyc_lf_wait_r1 = 0;
integer cyc_lf_wait_r2 = 0;
integer cnt_inst_r1 = 0;
integer cnt_inst_r2 = 0;

integer cnt_load_exec = 0;
integer cnt_load_sq_hit = 0;
integer cnt_load_d_hit = 0;
integer cnt_load_miss = 0;
integer cnt_store_exec = 0;
integer cnt_store_accept = 0;
integer cnt_store_merge = 0;
integer cnt_store_push = 0;
integer cnt_store_dhit = 0;

integer cyc_sq0 = 0;
integer cyc_sq1 = 0;
integer cyc_sq2 = 0;
integer cnt_aw_fire = 0;
integer cnt_w_fire = 0;
integer cnt_b_fire = 0;
integer cnt_issue_fire = 0;
integer cyc_issue_aw_wait = 0;
integer cyc_issue_w_wait = 0;
integer cyc_issue_split = 0;
integer cyc_full_can_issue = 0;
integer cyc_full_no_issue = 0;
integer cyc_full_aw_wait = 0;
integer cyc_full_w_wait = 0;
integer cyc_full_b_fire_same = 0;
integer cyc_full_issue_same = 0;

integer cyc_data_wait_no_rvalid = 0;
integer cyc_data_wait_rvalid = 0;
integer cnt_data_r_beats = 0;
integer cnt_data_r_last = 0;
integer cnt_data_ar_fire = 0;

integer cyc_drain_lf_active = 0;
integer cyc_drain_sq_full = 0;
integer cyc_drain_wait_vis = 0;
integer cyc_drain_wait_resp = 0;
integer cyc_drain_aw_wait = 0;
integer cyc_drain_w_wait = 0;
integer cyc_drain_no_issue = 0;

always @(posedge clk) begin
    if (rst_n) begin
        cycles_total = cycles_total + 1;

        if (cs == CHECK_HIT)      cyc_check_hit = cyc_check_hit + 1;
        if (cs == FETCH_MISS)     cycles_fetch_miss = cycles_fetch_miss + 1;
        if (cs == READ_SRAM_1)    cyc_read_sram_1 = cyc_read_sram_1 + 1;
        if (cs == READ_SRAM_2)    cyc_read_sram_2 = cyc_read_sram_2 + 1;
        if (cs == WAIT_SRAM_2)    cyc_wait_sram_2 = cyc_wait_sram_2 + 1;
        if (cs == INST_WB)        cyc_inst_wb = cyc_inst_wb + 1;
        if (cs == FETCH_DONE)     cyc_fetch_done = cyc_fetch_done + 1;
        if (cs == EXECUTE)        cyc_exec = cyc_exec + 1;
        if (cs == EXEC_BOTH_FAST) cyc_exec_both_fast = cyc_exec_both_fast + 1;
        if (cs == EXEC_DONE)      cyc_exec_done = cyc_exec_done + 1;
        if (cs == STORE_COMMIT)   cyc_store_commit = cyc_store_commit + 1;
        if (cs == DCACHE_SRAM)    cyc_dcache_sram = cyc_dcache_sram + 1;
        if (cs == DCACHE_WB)      cyc_dcache_wb = cyc_dcache_wb + 1;
        if (cs == MULT_WAIT)      cyc_mult_wait = cyc_mult_wait + 1;
        if (cs == DATA_READ_ADDR) cyc_data_read_addr = cyc_data_read_addr + 1;
        if (cs == DATA_READ_WAIT) cycles_data_read = cycles_data_read + 1;
        if (cs == DRAIN_STORE)    cycles_drain = cycles_drain + 1;

        if (finish_pulse) cnt_finish = cnt_finish + 1;
        if (fast_done)    cnt_fast_done = cnt_fast_done + 1;
        if (normal_done)  cnt_normal_done = cnt_normal_done + 1;
        if (drain_done)   cnt_drain_done = cnt_drain_done + 1;

        if (cs == FETCH_DONE && both_fast_path) cnt_both_fast = cnt_both_fast + 1;
        if (cs == FETCH_DONE && one_fast_one_slow) cnt_one_fast_slow = cnt_one_fast_slow + 1;
        if (cs == FETCH_DONE && !both_fast_path && !one_fast_one_slow) cnt_slow_pair = cnt_slow_pair + 1;

        if (cs == CHECK_HIT && !lf_active) begin
            if (miss_1 && !miss_2) cnt_miss1_only = cnt_miss1_only + 1;
            if (!miss_1 && miss_2) cnt_miss2_only = cnt_miss2_only + 1;
            if (miss_1 && miss_2)  cnt_miss_both = cnt_miss_both + 1;
        end
        if (cs == CHECK_HIT && (miss_1 || miss_2) && !lf_active) cnt_lf_start_norm = cnt_lf_start_norm + 1;
        if (pf_window && !drain_pf_triggered && !lf_active && (pf_need_1 || pf_need_2)) cnt_lf_start_pf = cnt_lf_start_pf + 1;

        if (lf_active) cyc_lf_active = cyc_lf_active + 1;
        if (lf_active && lf_req_1 && !lf_ar_done_1 && !arready_m_inf_inst_1) cyc_lf_wait_ar1 = cyc_lf_wait_ar1 + 1;
        if (lf_active && lf_req_2 && !lf_ar_done_2 && !arready_m_inf_inst_2) cyc_lf_wait_ar2 = cyc_lf_wait_ar2 + 1;
        if (lf_active && lf_req_1 && lf_ar_done_1 && !lf_r_done_1 && !rvalid_m_inf_inst_1) cyc_lf_wait_r1 = cyc_lf_wait_r1 + 1;
        if (lf_active && lf_req_2 && lf_ar_done_2 && !lf_r_done_2 && !rvalid_m_inf_inst_2) cyc_lf_wait_r2 = cyc_lf_wait_r2 + 1;
        if (lf_r_fire_1) cnt_inst_r1 = cnt_inst_r1 + 1;
        if (lf_r_fire_2) cnt_inst_r2 = cnt_inst_r2 + 1;

        if (cs == EXECUTE && mem_is_load_r && !mem_halted_r) begin
            cnt_load_exec = cnt_load_exec + 1;
            if (sq_hit) cnt_load_sq_hit = cnt_load_sq_hit + 1;
            else if (d_hit) cnt_load_d_hit = cnt_load_d_hit + 1;
            else cnt_load_miss = cnt_load_miss + 1;
        end
        if (cs == EXECUTE && mem_is_store_r && !mem_halted_r) begin
            cnt_store_exec = cnt_store_exec + 1;
            if (store_accepted) cnt_store_accept = cnt_store_accept + 1;
            if (sq_merge_hit) cnt_store_merge = cnt_store_merge + 1;
            if (d_hit) cnt_store_dhit = cnt_store_dhit + 1;
        end
        if (sq_push_new) cnt_store_push = cnt_store_push + 1;

        if (sq_count == 2'd0) cyc_sq0 = cyc_sq0 + 1;
        if (sq_count == 2'd1) cyc_sq1 = cyc_sq1 + 1;
        if (sq_count == 2'd2) cyc_sq2 = cyc_sq2 + 1;
        if (aw_fire) cnt_aw_fire = cnt_aw_fire + 1;
        if (w_fire) cnt_w_fire = cnt_w_fire + 1;
        if (b_fire) cnt_b_fire = cnt_b_fire + 1;
        if (issue_fire) cnt_issue_fire = cnt_issue_fire + 1;

        if (can_issue_store && !issue_sent_aw && !awready_m_inf_data) cyc_issue_aw_wait = cyc_issue_aw_wait + 1;
        if (can_issue_store && !issue_sent_w  && !wready_m_inf_data)  cyc_issue_w_wait = cyc_issue_w_wait + 1;
        if (can_issue_store && (issue_sent_aw ^ issue_sent_w)) cyc_issue_split = cyc_issue_split + 1;

        if (cs == EXECUTE && mem_is_store_r && !sq_merge_hit && sq_full && !sq_pop_real) begin
            cycles_store_stall = cycles_store_stall + 1;
            if (can_issue_store) cyc_full_can_issue = cyc_full_can_issue + 1;
            else                 cyc_full_no_issue = cyc_full_no_issue + 1;
            if (can_issue_store && !issue_sent_aw && !awready_m_inf_data) cyc_full_aw_wait = cyc_full_aw_wait + 1;
            if (can_issue_store && !issue_sent_w  && !wready_m_inf_data)  cyc_full_w_wait = cyc_full_w_wait + 1;
            if (b_fire) cyc_full_b_fire_same = cyc_full_b_fire_same + 1;
            if (issue_fire) cyc_full_issue_same = cyc_full_issue_same + 1;
        end

        if (cs == DATA_READ_ADDR && arvalid_m_inf_data && arready_m_inf_data) cnt_data_ar_fire = cnt_data_ar_fire + 1;
        if (cs == DATA_READ_WAIT && !rvalid_m_inf_data) cyc_data_wait_no_rvalid = cyc_data_wait_no_rvalid + 1;
        if (cs == DATA_READ_WAIT &&  rvalid_m_inf_data) cyc_data_wait_rvalid = cyc_data_wait_rvalid + 1;
        if (cs == DATA_READ_WAIT &&  rvalid_m_inf_data && rready_m_inf_data) cnt_data_r_beats = cnt_data_r_beats + 1;
        if (cs == DATA_READ_WAIT &&  rvalid_m_inf_data && rlast_m_inf_data) cnt_data_r_last = cnt_data_r_last + 1;

        if (cs == DRAIN_STORE && lf_active) cyc_drain_lf_active = cyc_drain_lf_active + 1;
        if (cs == DRAIN_STORE && sq_full) cyc_drain_sq_full = cyc_drain_sq_full + 1;
        if (cs == DRAIN_STORE && !store_visible_done) cyc_drain_wait_vis = cyc_drain_wait_vis + 1;
        if (cs == DRAIN_STORE && !store_resp_done) cyc_drain_wait_resp = cyc_drain_wait_resp + 1;
        if (cs == DRAIN_STORE && can_issue_store && !issue_sent_aw && !awready_m_inf_data) cyc_drain_aw_wait = cyc_drain_aw_wait + 1;
        if (cs == DRAIN_STORE && can_issue_store && !issue_sent_w  && !wready_m_inf_data) cyc_drain_w_wait = cyc_drain_w_wait + 1;
        if (cs == DRAIN_STORE && !can_issue_store && !store_visible_done) cyc_drain_no_issue = cyc_drain_no_issue + 1;

        if (cs == CHECK_HIT && t0_halted && t1_halted && store_resp_done) begin
            $display("\n=======================================================");
            $display(" FSM Profiling Counters (Latency Analysis)");
            $display("=======================================================");
            $display(" Total Execution Cycles : %d", cycles_total);
            $display("-------------------------------------------------------");
            $display(" State cycles");
            $display(" CHECK_HIT          : %d", cyc_check_hit);
            $display(" FETCH_MISS         : %d", cycles_fetch_miss);
            $display(" READ_SRAM_1        : %d", cyc_read_sram_1);
            $display(" READ_SRAM_2        : %d", cyc_read_sram_2);
            $display(" WAIT_SRAM_2        : %d", cyc_wait_sram_2);
            $display(" INST_WB            : %d", cyc_inst_wb);
            $display(" FETCH_DONE         : %d", cyc_fetch_done);
            $display(" EXECUTE            : %d", cyc_exec);
            $display(" EXEC_BOTH_FAST     : %d", cyc_exec_both_fast);
            $display(" EXEC_DONE          : %d", cyc_exec_done);
            $display(" STORE_COMMIT       : %d", cyc_store_commit);
            $display(" DCACHE_SRAM        : %d", cyc_dcache_sram);
            $display(" DCACHE_WB          : %d", cyc_dcache_wb);
            $display(" MULT_WAIT          : %d", cyc_mult_wait);
            $display(" DATA_READ_ADDR     : %d", cyc_data_read_addr);
            $display(" DATA_READ_WAIT     : %d", cycles_data_read);
            $display(" DRAIN_STORE        : %d", cycles_drain);
            $display("-------------------------------------------------------");
            $display(" Pair / finish");
            $display(" finish_pulse       : %d", cnt_finish);
            $display(" fast_done          : %d", cnt_fast_done);
            $display(" normal_done        : %d", cnt_normal_done);
            $display(" drain_done         : %d", cnt_drain_done);
            $display(" fetch both_fast    : %d", cnt_both_fast);
            $display(" fetch one_fast_slow: %d", cnt_one_fast_slow);
            $display(" fetch slow_pair    : %d", cnt_slow_pair);
            $display("-------------------------------------------------------");
            $display(" I-cache / line fill");
            $display(" miss1 only         : %d", cnt_miss1_only);
            $display(" miss2 only         : %d", cnt_miss2_only);
            $display(" miss both          : %d", cnt_miss_both);
            $display(" lf normal starts   : %d", cnt_lf_start_norm);
            $display(" lf pf starts       : %d", cnt_lf_start_pf);
            $display(" lf_active cycles   : %d", cyc_lf_active);
            $display(" lf wait AR1/AR2    : %d / %d", cyc_lf_wait_ar1, cyc_lf_wait_ar2);
            $display(" lf wait R1/R2      : %d / %d", cyc_lf_wait_r1, cyc_lf_wait_r2);
            $display(" inst R beats 1/2   : %d / %d", cnt_inst_r1, cnt_inst_r2);
            $display("-------------------------------------------------------");
            $display(" Load / D-cache");
            $display(" load exec          : %d", cnt_load_exec);
            $display(" load SQ forward    : %d", cnt_load_sq_hit);
            $display(" load D hit         : %d", cnt_load_d_hit);
            $display(" load miss          : %d", cnt_load_miss);
            $display(" data AR fire       : %d", cnt_data_ar_fire);
            $display(" data wait no RVALID: %d", cyc_data_wait_no_rvalid);
            $display(" data wait RVALID   : %d", cyc_data_wait_rvalid);
            $display(" data R beats/last  : %d / %d", cnt_data_r_beats, cnt_data_r_last);
            $display("-------------------------------------------------------");
            $display(" Store queue");
            $display(" store exec         : %d", cnt_store_exec);
            $display(" store accepted     : %d", cnt_store_accept);
            $display(" store merge        : %d", cnt_store_merge);
            $display(" store push         : %d", cnt_store_push);
            $display(" store D hit        : %d", cnt_store_dhit);
            $display(" SQ occ 0/1/2 cyc   : %d / %d / %d", cyc_sq0, cyc_sq1, cyc_sq2);
            $display(" AW/W/B fire        : %d / %d / %d", cnt_aw_fire, cnt_w_fire, cnt_b_fire);
            $display(" issue_fire         : %d", cnt_issue_fire);
            $display(" issue AW wait cyc  : %d", cyc_issue_aw_wait);
            $display(" issue W wait cyc   : %d", cyc_issue_w_wait);
            $display(" issue split cyc    : %d", cyc_issue_split);
            $display(" SQ FULL stall      : %d", cycles_store_stall);
            $display("   full can_issue   : %d", cyc_full_can_issue);
            $display("   full no_issue    : %d", cyc_full_no_issue);
            $display("   full AW wait     : %d", cyc_full_aw_wait);
            $display("   full W wait      : %d", cyc_full_w_wait);
            $display("   full B same cyc  : %d", cyc_full_b_fire_same);
            $display("   full issue same  : %d", cyc_full_issue_same);
            $display("-------------------------------------------------------");
            $display(" Drain detail");
            $display(" drain cycles       : %d", cycles_drain);
            $display(" drain lf_active    : %d", cyc_drain_lf_active);
            $display(" drain SQ full      : %d", cyc_drain_sq_full);
            $display(" drain wait visible : %d", cyc_drain_wait_vis);
            $display(" drain wait resp    : %d", cyc_drain_wait_resp);
            $display(" drain AW wait      : %d", cyc_drain_aw_wait);
            $display(" drain W wait       : %d", cyc_drain_w_wait);
            $display(" drain no_issue     : %d", cyc_drain_no_issue);
            $display("=======================================================\n");
        end
    end
end
// synthesis translate_on

endmodule

module MEM_512X16(
    input         CLK, CS, OE, WEB,
    input  [8:0]  A,   
    input  [15:0] DI,  
    output [15:0] DO   
);
SRAM_512X16 SRAM_inst(
    .A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .A5(A[5]), .A6(A[6]), .A7(A[7]), .A8(A[8]),
    .DO0(DO[0]),   .DO1(DO[1]),   .DO2(DO[2]),   .DO3(DO[3]),
    .DO4(DO[4]),   .DO5(DO[5]),   .DO6(DO[6]),   .DO7(DO[7]),
    .DO8(DO[8]),   .DO9(DO[9]),   .DO10(DO[10]), .DO11(DO[11]),
    .DO12(DO[12]), .DO13(DO[13]), .DO14(DO[14]), .DO15(DO[15]),
    .DI0(DI[0]),   .DI1(DI[1]),   .DI2(DI[2]),   .DI3(DI[3]),
    .DI4(DI[4]),   .DI5(DI[5]),   .DI6(DI[6]),   .DI7(DI[7]),
    .DI8(DI[8]),   .DI9(DI[9]),   .DI10(DI[10]), .DI11(DI[11]),
    .DI12(DI[12]), .DI13(DI[13]), 
    .DI14(DI[14]), .DI15(DI[15]),
    .CK(CLK), .WEB(WEB), .OE(OE), .CS(CS)
);
endmodule