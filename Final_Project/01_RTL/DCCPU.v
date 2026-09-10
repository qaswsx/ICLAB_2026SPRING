//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2026 Spring Midterm Project: Dual-Core CPU 
//   Author                           : Ying-Yu Wang
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : DCCPU.v
//   Module Name : DCCPU.v
//   Release version : V1.0 
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
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

input wire clk, rst_n;
output reg stall_1, stall_2;
parameter ID_WIDTH=4, ADDR_WIDTH=32, DATA_WIDTH=16, BURST_LEN=7;

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

reg [15:0] core_1_r0, core_1_r1, core_1_r2, core_1_r3;
reg [15:0] core_1_r4, core_1_r5, core_1_r6, core_1_r7;
reg [15:0] core_2_r0, core_2_r1, core_2_r2, core_2_r3;
reg [15:0] core_2_r4, core_2_r5, core_2_r6, core_2_r7;

reg [13:0] pc_1, pc_2;
reg [15:0] inst_reg_1, inst_reg_2;

reg thread_id;
reg exec_order;
reg exec_step;

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
localparam CLEAR_REGS_2    = 5'd23; 

reg [4:0] cs, ns;

wire t0_halted = (pc_1 >= 14'h2000);
wire t1_halted = (pc_2 >= 14'h2000);
wire active_halted = (thread_id == 1'b0) ? t0_halted : t1_halted;

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

wire [13:0] active_pc   = (thread_id == 1'b0) ? pc_1 : pc_2;
wire [15:0] active_inst = (thread_id == 1'b0) ? inst_reg_1 : inst_reg_2;

wire [2:0] opcode = active_inst[15:13];
wire [2:0] rs     = active_inst[12:10];
wire [2:0] rt     = active_inst[9:7];
wire [2:0] rd     = active_inst[6:4];
wire [2:0] func   = active_inst[3:1];
wire [2:0] rl     = active_inst[3:1];

// ==========================================================================
// Multiply counter: CG-friendly enable, no manual clk&en.
// ==========================================================================
reg [2:0] mul_cnt;
wire mult_start_pre = (cs == EXECUTE && opcode == 3'b001 && !active_halted);
wire mult_step_pre  = (cs == MULT_WAIT);
wire mul_cnt_en = mult_start_pre || mult_step_pre;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        mul_cnt <= 3'd0;
    end
    else if (mul_cnt_en) begin
        if (mult_start_pre)
            mul_cnt <= 3'd0;
        else
            mul_cnt <= mul_cnt + 3'd1;
    end
end

wire [2:0] op1 = inst_reg_1[15:13];
wire [2:0] op2 = inst_reg_2[15:13];
wire t0_is_store = !t0_halted && (op1 == 3'b101);
wire t1_is_store = !t1_halted && (op2 == 3'b101);

wire t1_goes_first = t1_is_store && !t0_is_store;
wire next_thread_to_exec = exec_order ? 1'b0 : 1'b1;
wire next_thread_halted  = (next_thread_to_exec == 1'b0) ? t0_halted : t1_halted;

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
    (t1_slow_op && t0_fast_op) ? 1'b1 :
    (t1_goes_first ? 1'b1 : 1'b0);

wire fast_thread_id =
    (t0_fast_op && t1_slow_op) ? 1'b0 :
    (t1_fast_op && t0_slow_op) ? 1'b1 : 1'b0;

wire fetch_exec_thread =
    one_fast_one_slow ? slow_thread_id :
    (t1_goes_first ? 1'b1 : 1'b0);

wire decode_stage = (cs == WAIT_SRAM_2);
wire [15:0] sram_inst_out;

reg [15:0] sram_do_r;
wire sram_do_update =
    (cs == READ_SRAM_2) ||
    (cs == WAIT_SRAM_2) ||
    (cs == DCACHE_WB);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        sram_do_r <= 16'd0;
    else if (sram_do_update)
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
    (dec_t1_slow_op && dec_t0_fast_op) ? 1'b1 :
    (dec_t1_goes_first ? 1'b1 : 1'b0);

wire dec_fast_thread_id =
    (dec_t0_fast_op && dec_t1_slow_op) ? 1'b0 :
    (dec_t1_fast_op && dec_t0_slow_op) ? 1'b1 : 1'b0;

wire dec_fetch_exec_thread =
    dec_one_fast_one_slow ? dec_slow_thread_id :
    (dec_t1_goes_first ? 1'b1 : 1'b0);

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

reg [15:0] fast_c1_alu_r, fast_c2_alu_r;
reg [13:0] fast_c1_next_pc_r, fast_c2_next_pc_r;

wire fast_c1_res_need = (cs == FETCH_DONE) &&
    ((both_fast_path && !t0_halted) || (one_fast_one_slow && (fast_thread_id == 1'b0)));
wire fast_c2_res_need = (cs == FETCH_DONE) &&
    ((both_fast_path && !t1_halted) || (one_fast_one_slow && (fast_thread_id == 1'b1)));
wire fast_c1_alu_need = fast_c1_res_need &&
    (fast_op1 == 3'b000 || fast_op1 == 3'b010 || fast_op1 == 3'b011);
wire fast_c2_alu_need = fast_c2_res_need &&
    (fast_op2 == 3'b000 || fast_op2 == 3'b010 || fast_op2 == 3'b011);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        fast_c1_alu_r <= 16'd0;
    else if (fast_c1_alu_need)
        fast_c1_alu_r <= fast_c1_alu;
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        fast_c2_alu_r <= 16'd0;
    else if (fast_c2_alu_need)
        fast_c2_alu_r <= fast_c2_alu;
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        fast_c1_next_pc_r <= 14'd0;
    else if (fast_c1_res_need)
        fast_c1_next_pc_r <= fast_c1_next_pc;
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        fast_c2_next_pc_r <= 14'd0;
    else if (fast_c2_res_need)
        fast_c2_next_pc_r <= fast_c2_next_pc;
end

wire exec_order_en = (cs == CLEAR_REGS) || (cs == EXEC_BOTH_FAST) ||
                     (cs == FETCH_DONE) || (cs == EXEC_DONE);
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        exec_order <= 1'b0;
        exec_step  <= 1'b0;
    end
    else if (exec_order_en) begin
        if (cs == CLEAR_REGS || cs == EXEC_BOTH_FAST) begin
            exec_order <= 1'b0;
            exec_step  <= 1'b0;
        end
        else if (cs == FETCH_DONE) begin
            exec_order <= t1_goes_first;
            exec_step  <= 1'b0;
        end
        else begin
            exec_step  <= 1'b1;
        end
    end
end

wire thread_id_en = (cs == CLEAR_REGS) || (cs == EXEC_BOTH_FAST) ||
                    (cs == FETCH_DONE) || (cs == EXEC_DONE);
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        thread_id <= 1'b0;
    end
    else if (thread_id_en) begin
        if (cs == CLEAR_REGS || cs == EXEC_BOTH_FAST) begin
            thread_id <= 1'b0;
        end
        else if (cs == FETCH_DONE) begin
            thread_id <= fetch_exec_thread;
        end
        else begin
            if (exec_step == 1'b0)
                thread_id <= next_thread_to_exec;
            else
                thread_id <= 1'b0;
        end
    end
end

wire par_fast_en = (cs == FETCH_DONE) ||
                   (cs == EXECUTE && par_fast_valid && !par_fast_done) ||
                   (cs == CHECK_HIT) || (cs == CLEAR_REGS);
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        par_fast_valid  <= 1'b0;
        par_fast_done   <= 1'b0;
        par_fast_thread <= 1'b0;
    end
    else if (par_fast_en) begin
        if (cs == FETCH_DONE) begin
            par_fast_valid  <= one_fast_one_slow;
            par_fast_done   <= 1'b0;
            par_fast_thread <= fast_thread_id;
        end
        else if (cs == EXECUTE && par_fast_valid && !par_fast_done) begin
            par_fast_done <= 1'b1;
        end
        else begin
            par_fast_valid <= 1'b0;
            par_fast_done  <= 1'b0;
        end
    end
end

// ==========================================================================
// SRAM / cache state
// ==========================================================================
reg [1:0]  valid_1, valid_2;
reg [5:0]  tag_1 [0:1];
reg [5:0]  tag_2 [0:1];
reg [1:0]  d_valid;
reg [4:0]  d_tag_arr [0:1];

wire idx_1 = pc_1[6];
wire [4:0] off_1 = pc_1[5:1];
wire [5:0] tag_1_val = pc_1[12:7];
wire idx_2 = pc_2[6];
wire [4:0] off_2 = pc_2[5:1];
wire [5:0] tag_2_val = pc_2[12:7];
wire hit_1 = valid_1[idx_1] && (tag_1[idx_1] == tag_1_val);
wire hit_2 = valid_2[idx_2] && (tag_2[idx_2] == tag_2_val);
wire miss_1 = !t0_halted && !hit_1;
wire miss_2 = !t1_halted && !hit_2;

wire pf_window = (cs == DRAIN_STORE);
wire [6:0] line_1 = pc_1[12:6];
wire [6:0] line_2 = pc_2[12:6];
wire [6:0] next_line_1 = line_1 + 7'd1;
wire [6:0] next_line_2 = line_2 + 7'd1;
wire next_line_legal_1 = (line_1 != 7'd127);
wire next_line_legal_2 = (line_2 != 7'd127);
wire next_idx_1 = next_line_1[0];
wire next_idx_2 = next_line_2[0];
wire [5:0] next_tag_1 = next_line_1[6:1];
wire [5:0] next_tag_2 = next_line_2[6:1];
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
reg        lf_idx_1, lf_idx_2;
reg [5:0]  lf_tag_1, lf_tag_2;
reg        drain_pf_triggered;

wire lf_r_fire_1 = rvalid_m_inf_inst_1 && rready_m_inf_inst_1 && lf_active;
wire lf_r_fire_2 = rvalid_m_inf_inst_2 && rready_m_inf_inst_2 && lf_active;
wire lf_buf_write = lf_active && lf_buf_valid;

wire lf_write_req_1 = lf_buf_write ? (lf_buf_core == 1'b0) : lf_r_fire_1;
wire lf_write_req_2 = lf_buf_write ? (lf_buf_core == 1'b1) : (!lf_r_fire_1 && lf_r_fire_2);
wire lf_write_last_1 = lf_buf_write ? (lf_buf_core == 1'b0 && lf_buf_last) : rlast_m_inf_inst_1;
wire lf_write_last_2 = lf_buf_write ? (lf_buf_core == 1'b1 && lf_buf_last) : rlast_m_inf_inst_2;
wire push_lf_buf = lf_active && !lf_buf_valid && lf_r_fire_1 && lf_r_fire_2;

wire lf_normal_trigger = (cs == CHECK_HIT && (miss_1 || miss_2) && !lf_active);
wire lf_pf_trigger     = (pf_window && !drain_pf_triggered && !lf_active && (pf_need_1 || pf_need_2));

always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        drain_pf_triggered <= 1'b0;
    else if (!pf_window)
        drain_pf_triggered <= 1'b0;
    else if (pf_window && !drain_pf_triggered && !lf_active)
        drain_pf_triggered <= 1'b1;
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        lf_active <= 1'b0;
        lf_is_pf  <= 1'b0;
        lf_req_1  <= 1'b0;
        lf_req_2  <= 1'b0;
    end
    else begin
        if (lf_normal_trigger) begin
            lf_active <= 1'b1;
            lf_is_pf  <= 1'b0;
            lf_req_1  <= miss_1;
            lf_req_2  <= miss_2;
        end
        else if (lf_pf_trigger) begin
            lf_active <= 1'b1;
            lf_is_pf  <= 1'b1;
            lf_req_1  <= pf_need_1;
            lf_req_2  <= pf_need_2;
        end
        else if (lf_active) begin
            if ((!lf_req_1 || lf_r_done_1) && (!lf_req_2 || lf_r_done_2))
                lf_active <= 1'b0;
        end
    end
end

wire lf_ar_en = lf_normal_trigger || lf_pf_trigger || lf_active;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        lf_ar_done_1 <= 1'b0;
        lf_ar_done_2 <= 1'b0;
    end
    else if (lf_ar_en) begin
        if (lf_normal_trigger || lf_pf_trigger) begin
            lf_ar_done_1 <= 1'b0;
            lf_ar_done_2 <= 1'b0;
        end
        else begin
            if (arvalid_m_inf_inst_1 && arready_m_inf_inst_1 && lf_req_1)
                lf_ar_done_1 <= 1'b1;
            if (arvalid_m_inf_inst_2 && arready_m_inf_inst_2 && lf_req_2)
                lf_ar_done_2 <= 1'b1;
        end
    end
end

wire lf_cnt_en = lf_normal_trigger || lf_pf_trigger || lf_active;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        lf_r_done_1 <= 1'b0;
        lf_r_done_2 <= 1'b0;
        lf_cnt_1    <= 6'd0;
        lf_cnt_2    <= 6'd0;
    end
    else if (lf_cnt_en) begin
        if (lf_normal_trigger || lf_pf_trigger) begin
            lf_r_done_1 <= 1'b0;
            lf_r_done_2 <= 1'b0;
            lf_cnt_1    <= 6'd0;
            lf_cnt_2    <= 6'd0;
        end
        else begin
            if (lf_write_req_1) begin
                lf_cnt_1    <= lf_cnt_1 + 6'd1;
                lf_r_done_1 <= lf_write_last_1;
            end
            if (lf_write_req_2) begin
                lf_cnt_2    <= lf_cnt_2 + 6'd1;
                lf_r_done_2 <= lf_write_last_2;
            end
        end
    end
end

wire lf_buf_en = lf_normal_trigger || lf_pf_trigger || push_lf_buf || lf_buf_write;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        lf_buf_valid <= 1'b0;
        lf_buf_core  <= 1'b0;
        lf_buf_data  <= 16'd0;
        lf_buf_last  <= 1'b0;
    end
    else if (lf_buf_en) begin
        if (lf_normal_trigger || lf_pf_trigger) begin
            lf_buf_valid <= 1'b0;
        end
        else if (push_lf_buf) begin
            lf_buf_valid <= 1'b1;
            lf_buf_core  <= 1'b1;
            lf_buf_data  <= rdata_m_inf_inst_2;
            lf_buf_last  <= rlast_m_inf_inst_2;
        end
        else begin
            lf_buf_valid <= 1'b0;
        end
    end
end

wire lf_addr1_en = (lf_normal_trigger && miss_1) || (lf_pf_trigger && pf_need_1);
wire lf_addr2_en = (lf_normal_trigger && miss_2) || (lf_pf_trigger && pf_need_2);
wire gclk_lf_addr1 = clk & lf_addr1_en;
wire gclk_lf_addr2 = clk & lf_addr2_en;

always @(posedge gclk_lf_addr1 or negedge rst_n) begin
    if (~rst_n) begin
        lf_addr_1 <= 13'd0;
        lf_idx_1  <= 1'b0;
        lf_tag_1  <= 6'd0;
    end
    else begin
        if (lf_normal_trigger) begin
            lf_addr_1 <= {pc_1[12:6], 6'd0};
            lf_idx_1  <= idx_1;
            lf_tag_1  <= tag_1_val;
        end
        else begin
            lf_addr_1 <= pf_cur_need_1 ? {pc_1[12:6], 6'd0} : {next_line_1, 6'd0};
            lf_idx_1  <= pf_cur_need_1 ? idx_1 : next_idx_1;
            lf_tag_1  <= pf_cur_need_1 ? tag_1_val : next_tag_1;
        end
    end
end

always @(posedge gclk_lf_addr2 or negedge rst_n) begin
    if (~rst_n) begin
        lf_addr_2 <= 13'd0;
        lf_idx_2  <= 1'b0;
        lf_tag_2  <= 6'd0;
    end
    else begin
        if (lf_normal_trigger) begin
            lf_addr_2 <= {pc_2[12:6], 6'd0};
            lf_idx_2  <= idx_2;
            lf_tag_2  <= tag_2_val;
        end
        else begin
            lf_addr_2 <= pf_cur_need_2 ? {pc_2[12:6], 6'd0} : {next_line_2, 6'd0};
            lf_idx_2  <= pf_cur_need_2 ? idx_2 : next_idx_2;
            lf_tag_2  <= pf_cur_need_2 ? tag_2_val : next_tag_2;
        end
    end
end

// ==========================================================================
// AXI Instruction Fetch Assignments
// ==========================================================================
assign arid_m_inf_inst_1    = 4'b0000;
assign araddr_m_inf_inst_1  = {19'd0, lf_addr_1};
assign arlen_m_inf_inst_1   = 7'd31;
assign arsize_m_inf_inst_1  = 3'b001;
assign arburst_m_inf_inst_1 = 2'b01;
assign arvalid_m_inf_inst_1 = lf_active && lf_req_1 && !lf_ar_done_1;

assign arid_m_inf_inst_2    = 4'b0000;
assign araddr_m_inf_inst_2  = {19'd0, lf_addr_2};
assign arlen_m_inf_inst_2   = 7'd31;
assign arsize_m_inf_inst_2  = 3'b001;
assign arburst_m_inf_inst_2 = 2'b01;
assign arvalid_m_inf_inst_2 = lf_active && lf_req_2 && !lf_ar_done_2;

wire lf_core1_pending = lf_req_1 && !lf_r_done_1;
assign rready_m_inf_inst_1 = lf_active && lf_core1_pending && !lf_buf_valid;
assign rready_m_inf_inst_2 = lf_active && lf_req_2 && !lf_r_done_2 && !lf_buf_valid && !lf_core1_pending;

// ==========================================================================
// Sequential / slow path setup
// ==========================================================================
wire read_thread_id =
    (cs == EXEC_DONE && exec_step == 1'b0) ? next_thread_to_exec :
    (cs == FETCH_DONE) ? fetch_exec_thread : thread_id;

wire [15:0] read_inst =
    (cs == FETCH_DONE) ?
    ((fetch_exec_thread == 1'b0) ? inst_reg_1 : inst_reg_2) :
    ((read_thread_id == 1'b0) ? inst_reg_1 : inst_reg_2);

wire [15:0] slow_rs = (read_thread_id == 1'b0) ? fast_c1_rs : fast_c2_rs;
wire [15:0] slow_rt = (read_thread_id == 1'b0) ? fast_c1_rt : fast_c2_rt;

wire signed [11:0] slow_rs_12  = slow_rs[11:0];
wire signed [11:0] slow_imm_12 = {{5{read_inst[6]}}, read_inst[6:0]};
wire [11:0] slow_mem_addr = slow_rs_12 + slow_imm_12;

reg [11:0] mem_addr_r;
wire       mem_line_idx_r = mem_addr_r[6];
wire [5:0] mem_word_off_r = mem_addr_r[5:0];
wire [4:0] mem_tag_r      = mem_addr_r[11:7];
wire       mem_is_load_r  = (opcode == 3'b100);
wire       mem_is_store_r = (opcode == 3'b101);
wire       mem_halted_r   = active_halted;

reg [13:0] seq_pc_plus_2_r;
wire       seq_will_halt = (seq_pc_plus_2_r >= 14'h2000);
reg signed [15:0] rs_reg, rt_reg;
wire fetch_thread_halted = (fetch_exec_thread == 1'b0) ? t0_halted : t1_halted;
wire slow_setup_fetch_en = (cs == FETCH_DONE) && !both_fast_path && !fetch_thread_halted;
wire slow_setup_next_en  = (cs == EXEC_DONE && exec_step == 1'b0 && !next_thread_halted);
wire slow_setup_en = slow_setup_fetch_en || slow_setup_next_en;
wire [2:0] slow_setup_op = read_inst[15:13];
wire slow_setup_is_load  = (slow_setup_op == 3'b100);
wire slow_setup_is_store = (slow_setup_op == 3'b101);
wire slow_setup_is_mult  = (slow_setup_op == 3'b001);
wire slow_setup_mem_en   = slow_setup_en && (slow_setup_is_load || slow_setup_is_store);
wire slow_setup_rt_en    = slow_setup_en && (slow_setup_is_store || slow_setup_is_mult);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        seq_pc_plus_2_r <= 14'd0;
    else if (slow_setup_en)
        seq_pc_plus_2_r <= ((read_thread_id == 1'b0) ? pc_1 : pc_2) + 14'd2;
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        rs_reg <= 16'd0;
    else if (slow_setup_en)
        rs_reg <= slow_rs;
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        rt_reg <= 16'd0;
    else if (slow_setup_rt_en)
        rt_reg <= slow_rt;
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        mem_addr_r <= 12'd0;
    else if (slow_setup_mem_en)
        mem_addr_r <= slow_mem_addr;
end

// ==========================================================================
// D-cache hit evaluation
// ==========================================================================
wire       d_line_idx = mem_line_idx_r;
wire [5:0] d_word_off = mem_word_off_r;
wire [4:0] d_tag      = mem_tag_r;
wire d_hit = d_valid[d_line_idx] && (d_tag_arr[d_line_idx] == d_tag);

// ==========================================================================
// 2-entry Store Queue, entry-level fine-grain enable
// ==========================================================================
reg        sq_head, sq_tail;
reg [1:0]  sq_count;
reg        issue_sent_aw;
reg        issue_sent_w;
reg [11:0] sq_addr [0:1];
reg [15:0] sq_data [0:1];
wire sq_full  = (sq_count == 2'd2);
wire sq_empty = (sq_count == 2'd0);

wire store_exec = (cs == EXECUTE && mem_is_store_r && !mem_halted_r);
wire [1:0] unissued_count = sq_count;
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
            if (sq_addr[sq_search_cur] == mem_addr_r) begin
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

wire aw_fire = awvalid_m_inf_data && awready_m_inf_data;
wire w_fire  = wvalid_m_inf_data  && wready_m_inf_data;
wire b_fire  = bvalid_m_inf_data  && bready_m_inf_data;

wire store_accepted;
wire sq_push_new = store_accepted && !sq_merge_hit;
wire sq_merge    = store_accepted && sq_merge_hit;
wire sq_has_unissued = !sq_empty;
wire can_issue_store = sq_has_unissued && !(store_exec && sq_merge_hit);
wire issue_fire = can_issue_store && (issue_sent_aw || aw_fire) && (issue_sent_w || w_fire);
wire sq_pop_real = issue_fire;
assign store_accepted = store_exec && (sq_merge_hit || (!sq_full || sq_pop_real));

wire sq0_wr_en = (sq_merge && (sq_merge_idx == 1'b0)) || (sq_push_new && (sq_tail == 1'b0));
wire sq1_wr_en = (sq_merge && (sq_merge_idx == 1'b1)) || (sq_push_new && (sq_tail == 1'b1));
wire sq0_wr_is_push = sq_push_new && (sq_tail == 1'b0);
wire sq1_wr_is_push = sq_push_new && (sq_tail == 1'b1);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        sq_addr[0] <= 12'd0;
        sq_data[0] <= 16'd0;
    end
    else if (sq0_wr_en) begin
        if (sq0_wr_is_push)
            sq_addr[0] <= mem_addr_r;
        sq_data[0] <= rt_reg;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        sq_addr[1] <= 12'd0;
        sq_data[1] <= 16'd0;
    end
    else if (sq1_wr_en) begin
        if (sq1_wr_is_push)
            sq_addr[1] <= mem_addr_r;
        sq_data[1] <= rt_reg;
    end
end

wire sq_ptr_en = (cs == CLEAR_REGS) || sq_push_new || issue_fire;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        sq_head  <= 1'd0;
        sq_tail  <= 1'd0;
        sq_count <= 2'd0;
    end
    else if (sq_ptr_en) begin
        if (cs == CLEAR_REGS) begin
            sq_head  <= 1'd0;
            sq_tail  <= 1'd0;
            sq_count <= 2'd0;
        end
        else begin
            if (sq_push_new)
                sq_tail <= sq_tail + 1'd1;
            if (issue_fire)
                sq_head <= sq_head + 1'd1;

            if (sq_push_new && issue_fire)
                sq_count <= sq_count;
            else if (sq_push_new)
                sq_count <= sq_count + 2'd1;
            else
                sq_count <= sq_count - 2'd1;
        end
    end
end

wire issue_sent_en = (cs == CLEAR_REGS) || can_issue_store || issue_fire;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        issue_sent_aw <= 1'b0;
        issue_sent_w  <= 1'b0;
    end
    else if (issue_sent_en) begin
        if (cs == CLEAR_REGS || issue_fire) begin
            issue_sent_aw <= 1'b0;
            issue_sent_w  <= 1'b0;
        end
        else begin
            if (aw_fire) issue_sent_aw <= 1'b1;
            if (w_fire)  issue_sent_w  <= 1'b1;
        end
    end
end

// ==========================================================================
// D-cache SRAM request register
// ==========================================================================
reg        d_sram_we_r;
wire [15:0] d_sram_di_r = rt_reg;
wire d_sram_we_en = (cs == CLEAR_REGS) || (cs == EXECUTE && (mem_is_store_r || mem_is_load_r));
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        d_sram_we_r <= 1'b0;
    else if (d_sram_we_en) begin
        if (cs == CLEAR_REGS)
            d_sram_we_r <= 1'b0;
        else
            d_sram_we_r <= !mem_halted_r && (mem_is_store_r && store_accepted && d_hit);
    end
end

reg was_dcache_hit;
reg was_sq_hit;
reg [15:0] load_forward_data;

wire load_hit_flag_en = (cs == EXECUTE && mem_is_load_r);
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        was_dcache_hit <= 1'b0;
        was_sq_hit     <= 1'b0;
    end
    else if (load_hit_flag_en) begin
        was_sq_hit     <= sq_hit;
        was_dcache_hit <= (!sq_hit && d_hit);
    end
end

wire load_forward_en = (cs == EXECUTE && mem_is_load_r && sq_hit);
wire gclk_load_forward = clk & load_forward_en; // idempotent: sq_forward_val is from staged SQ/mem_addr
always @(posedge gclk_load_forward or negedge rst_n) begin
    if (~rst_n)
        load_forward_data <= 16'd0;
    else
        load_forward_data <= sq_forward_val;
end

// ==========================================================================
// D-cache line fill registers
// ==========================================================================
reg [6:0] fill_cnt;
reg [15:0] load_miss_data;
reg data_burst_active;

wire data_miss_start = (cs == EXECUTE && mem_is_load_r && !mem_halted_r && !sq_hit && !d_hit);
wire data_first_beat = (cs == DATA_READ_WAIT) && rvalid_m_inf_data && !data_burst_active;
wire data_fill_beat  = (cs == DATA_READ_WAIT) && (data_burst_active || rvalid_m_inf_data);
wire data_fill_last  = data_fill_beat && (fill_cnt == 7'd63);

wire data_burst_en = data_miss_start || data_fill_last || data_first_beat;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        data_burst_active <= 1'b0;
    else if (data_burst_en) begin
        if (data_miss_start || data_fill_last)
            data_burst_active <= 1'b0;
        else
            data_burst_active <= 1'b1;
    end
end

wire fill_cnt_en = data_miss_start || data_fill_beat;
wire load_miss_data_en = data_fill_beat && (fill_cnt[5:0] == mem_word_off_r);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        fill_cnt <= 7'd0;
    else if (fill_cnt_en) begin
        if (data_miss_start)
            fill_cnt <= 7'd0;
        else
            fill_cnt <= fill_cnt + 7'd1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        load_miss_data <= 16'd0;
    else if (load_miss_data_en)
        load_miss_data <= rdata_m_inf_data;
end

// ==========================================================================
// PC update trigger / target generation
// ==========================================================================
wire inst_done_pulse = !active_halted && (
                       (cs == EXEC_DONE && (opcode == 3'b000 || opcode == 3'b010 || opcode == 3'b011 || opcode == 3'b001 || opcode == 3'b101)) ||
                       (cs == EXECUTE && (opcode == 3'b110 || opcode == 3'b111 ||
                       (mem_is_load_r && (sq_hit || d_hit)))) ||
                       data_fill_last
                       );
wire other_halted_now = (thread_id == 1'b0) ? t1_halted : t0_halted;
wire program_end_after_this =
    (cs == EXEC_DONE) &&
    other_halted_now &&
    seq_will_halt &&
    (exec_step == 1'b1 || (exec_step == 1'b0 && par_fast_done));

wire pc1_en =
    (cs == CLEAR_REGS) ||
    (cs == EXEC_BOTH_FAST && !t0_halted) ||
    (cs == EXECUTE && par_fast_valid && !par_fast_done && par_fast_thread == 1'b0) ||
    (cs == EXEC_DONE && !active_halted && thread_id == 1'b0);

wire pc2_en =
    (cs == CLEAR_REGS) ||
    (cs == EXEC_BOTH_FAST && !t1_halted) ||
    (cs == EXECUTE && par_fast_valid && !par_fast_done && par_fast_thread == 1'b1) ||
    (cs == EXEC_DONE && !active_halted && thread_id == 1'b1);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        pc_1 <= 14'd0;
    else if (pc1_en) begin
        if (cs == CLEAR_REGS)
            pc_1 <= 14'd0;
        else if (cs == EXEC_BOTH_FAST)
            pc_1 <= fast_c1_next_pc_r;
        else if (cs == EXECUTE)
            pc_1 <= fast_c1_next_pc_r;
        else
            pc_1 <= seq_pc_plus_2_r;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        pc_2 <= 14'd0;
    else if (pc2_en) begin
        if (cs == CLEAR_REGS)
            pc_2 <= 14'd0;
        else if (cs == EXEC_BOTH_FAST)
            pc_2 <= fast_c2_next_pc_r;
        else if (cs == EXECUTE)
            pc_2 <= fast_c2_next_pc_r;
        else
            pc_2 <= seq_pc_plus_2_r;
    end
end

// ==========================================================================
// Instruction counter / drain sync
// ==========================================================================
reg [5:0] inst_mod50;
wire store_visible_done = sq_empty && !issue_sent_aw && !issue_sent_w;
wire store_resp_done = store_visible_done;
wire store_all_done = store_visible_done;

wire fast_c1_will_halt_wb = t0_halted || (fast_c1_next_pc_r >= 14'h2000);
wire fast_c2_will_halt_wb = t1_halted || (fast_c2_next_pc_r >= 14'h2000);
wire fast_program_end_after_this = (cs == EXEC_BOTH_FAST) && fast_c1_will_halt_wb && fast_c2_will_halt_wb;
wire checkpoint_need_drain = (inst_mod50 == 6'd49) && !store_visible_done;
wire final_need_drain = program_end_after_this && !store_resp_done;
wire fast_checkpoint_need_drain = (inst_mod50 == 6'd49) && !store_visible_done;
wire fast_final_need_drain = fast_program_end_after_this && !store_resp_done;
wire fast_need_drain = fast_checkpoint_need_drain || fast_final_need_drain;
wire need_drain_before_done = checkpoint_need_drain || final_need_drain;

reg drain_wait_resp;
wire drain_wait_en = (cs == CLEAR_REGS) ||
                     (cs == EXEC_BOTH_FAST && fast_need_drain) ||
                     (cs == EXEC_DONE && need_drain_before_done) ||
                     (cs == CHECK_HIT && t0_halted && t1_halted && !store_resp_done);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        drain_wait_resp <= 1'b0;
    else if (drain_wait_en) begin
        if (cs == CLEAR_REGS)
            drain_wait_resp <= 1'b0;
        else if (cs == EXEC_BOTH_FAST)
            drain_wait_resp <= fast_program_end_after_this;
        else if (cs == EXEC_DONE)
            drain_wait_resp <= program_end_after_this;
        else
            drain_wait_resp <= 1'b1;
    end
end

wire pair_done_with_parallel_fast = (cs == EXEC_DONE && exec_step == 1'b0 && par_fast_done);
wire normal_done = ((cs == EXEC_DONE && exec_step == 1'b1) || pair_done_with_parallel_fast) && !need_drain_before_done;
wire drain_finish = drain_wait_resp ? store_resp_done : store_visible_done;
wire drain_done  = (cs == DRAIN_STORE && drain_finish);
wire fast_done = (cs == EXEC_BOTH_FAST && !fast_need_drain);
wire finish_pulse = normal_done || drain_done || fast_done;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        inst_mod50 <= 6'd0;
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
                else                    ns = DATA_READ_ADDR;
            end
            else if (mem_is_store_r) begin
                if (!sq_merge_hit && sq_full && !sq_pop_real) ns = EXECUTE;
                else if (d_hit)                              ns = DCACHE_SRAM;
                else                                         ns = EXEC_DONE;
            end
            else if (opcode == 3'b110 || opcode == 3'b111) ns = EXEC_DONE;
            else if (opcode == 3'b001)  ns = MULT_WAIT;
            else                        ns = EXEC_DONE;
        end
        STORE_COMMIT: begin
            if (d_sram_we_r) ns = DCACHE_SRAM;
            else             ns = EXEC_DONE;
        end
        DCACHE_SRAM: ns = d_sram_we_r ? EXEC_DONE : DCACHE_WB;
        DCACHE_WB:   ns = EXEC_DONE;
        MULT_WAIT: begin
            if (mul_cnt == 3'd7) ns = WRITEBACK_MULT;
            else                 ns = MULT_WAIT;
        end
        WRITEBACK_MULT: ns = EXEC_DONE;
        DATA_READ_ADDR: begin
            if (arready_m_inf_data) ns = DATA_READ_WAIT;
            else                    ns = DATA_READ_ADDR;
        end
        DATA_READ_WAIT: begin
            if (data_fill_last) ns = EXEC_DONE;
            else                ns = DATA_READ_WAIT;
        end
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
        CLEAR_REGS:   ns = CLEAR_REGS_2;
        CLEAR_REGS_2: ns = IDLE;
        default: ns = IDLE;
    endcase
end

// ==========================================================================
// Cache regs update logic
// ==========================================================================

wire icache_reg_en = (cs == CLEAR_REGS) ||
                     (lf_active && ((lf_write_req_1 && lf_write_last_1) ||
                                    (lf_write_req_2 && lf_write_last_2)));
wire gclk_icache_reg = clk & icache_reg_en;

// v8: cache valid/tag writes are idempotent line-fill commits.
always @(posedge gclk_icache_reg or negedge rst_n) begin
    if (~rst_n) begin
        valid_1 <= 2'd0;
        valid_2 <= 2'd0;
        tag_1[0] <= 6'd0;
        tag_1[1] <= 6'd0;
        tag_2[0] <= 6'd0;
        tag_2[1] <= 6'd0;
    end
    else begin
        if (cs == CLEAR_REGS) begin
            valid_1 <= 2'd0;
            valid_2 <= 2'd0;
        end
        else begin
            if (lf_write_req_1 && lf_write_last_1) begin
                valid_1[lf_idx_1] <= 1'b1;
                tag_1[lf_idx_1]   <= lf_tag_1;
            end
            if (lf_write_req_2 && lf_write_last_2) begin
                valid_2[lf_idx_2] <= 1'b1;
                tag_2[lf_idx_2]   <= lf_tag_2;
            end
        end
    end
end

wire dcache_reg_en = (cs == CLEAR_REGS) || data_fill_last;
wire gclk_dcache_reg = clk & dcache_reg_en;
always @(posedge gclk_dcache_reg or negedge rst_n) begin
    if (~rst_n) begin
        d_valid <= 2'd0;
        d_tag_arr[0] <= 5'd0;
        d_tag_arr[1] <= 5'd0;
    end
    else begin
        if (cs == CLEAR_REGS) begin
            d_valid <= 2'd0;
        end
        else begin
            d_valid[mem_line_idx_r] <= 1'b1;
            d_tag_arr[mem_line_idx_r] <= mem_tag_r;
        end
    end
end

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
wire is_d_load_miss_fill = data_fill_beat;
wire lf_we = lf_buf_write | lf_r_fire_1 | lf_r_fire_2;

wire inst_rbeat1_fast = lf_core1_pending;
wire sel_lf_1 = lf_buf_valid ? (lf_buf_core == 1'b0) : inst_rbeat1_fast;

wire [7:0] sram_lf_addr_1   = {2'b00, lf_idx_1, lf_cnt_1[4:0]};
wire [7:0] sram_lf_addr_2   = {2'b01, lf_idx_2, lf_cnt_2[4:0]};
wire [7:0] sram_read_addr_1 = {2'b00, idx_1, off_1};
wire [7:0] sram_read_addr_2 = {2'b01, idx_2, off_2};

wire [15:0] inst_lf_data =
    lf_buf_valid ? lf_buf_data :
    inst_rbeat1_fast ? rdata_m_inf_inst_1 : rdata_m_inf_inst_2;

reg        lf_wr_v_r;
reg [7:0]  lf_wr_addr_r;
reg [15:0] lf_wr_data_r;
wire lf_wr_pipe_en = lf_we || lf_wr_v_r;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        lf_wr_v_r    <= 1'b0;
        lf_wr_addr_r <= 8'd0;
        lf_wr_data_r <= 16'd0;
    end
    else if (lf_wr_pipe_en) begin
        lf_wr_v_r <= lf_we;
        if (lf_we) begin
            lf_wr_addr_r <= sel_lf_1 ? sram_lf_addr_1 : sram_lf_addr_2;
            lf_wr_data_r <= inst_lf_data;
        end
    end
end

reg        data_fill_v_r;
reg [6:0]  data_fill_addr_r;
reg [15:0] data_fill_data_r;
wire data_fill_pipe_en = is_d_load_miss_fill || data_fill_v_r;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        data_fill_v_r    <= 1'b0;
        data_fill_addr_r <= 7'd0;
        data_fill_data_r <= 16'd0;
    end
    else if (data_fill_pipe_en) begin
        data_fill_v_r <= is_d_load_miss_fill;
        if (is_d_load_miss_fill) begin
            data_fill_addr_r <= {mem_line_idx_r, fill_cnt[5:0]};
            data_fill_data_r <= rdata_m_inf_data;
        end
    end
end

wire inst_access = lf_wr_v_r | is_read_1 | is_read_2;
wire inst_we     = lf_wr_v_r;

wire [6:0] data_addr_low =
    data_fill_v_r ? data_fill_addr_r : {mem_line_idx_r, mem_word_off_r};
wire [15:0] data_wdata = data_fill_v_r ? data_fill_data_r : d_sram_di_r;
wire data_access = is_d_store | d_load_sram_req | data_fill_v_r;
wire data_we = is_d_store | data_fill_v_r;
wire use_data = data_access & ~inst_access;

wire [7:0] sram_addr = inst_we ?
    lf_wr_addr_r :
    use_data ? {1'b1, data_addr_low} :
    (is_read_1 ? sram_read_addr_1 : sram_read_addr_2);

wire [15:0] sram_di = use_data ? data_wdata : lf_wr_data_r;
wire sram_we_n = ~(use_data ? data_we : inst_we);
wire sram_cs = inst_access | data_access;

MEM_256X16 Shared_Cache_SRAM (
    .CLK(clk), .CS(sram_cs), .OE(1'b1), .WEB(sram_we_n),
    .A(sram_addr), .DI(sram_di), .DO(sram_inst_out)
);

wire inst_reg1_en = (cs == WAIT_SRAM_2);
wire inst_reg2_en = (cs == INST_WB);
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        inst_reg_1 <= 16'd0;
    else if (inst_reg1_en)
        inst_reg_1 <= inst_data_r;
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        inst_reg_2 <= 16'd0;
    else if (inst_reg2_en)
        inst_reg_2 <= inst_data_r;
end

wire [5:0] data_line_base = mem_addr_r[11:6];
reg [13:0] axi_addr_reg;
wire axi_addr_en = data_miss_start;
wire gclk_axi_addr = clk & axi_addr_en; // idempotent: data_line_base is staged in mem_addr_r
always @(posedge gclk_axi_addr or negedge rst_n) begin
    if (~rst_n) begin
        axi_addr_reg <= 14'd0;
    end
    else begin
        axi_addr_reg <= {
            data_line_base[5],
            ~data_line_base[5],
            data_line_base[4:0],
            7'b0000000
        };
    end
end

// ==========================================================================
// Booth multiplier, narrowed enable
// ==========================================================================
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

wire mult_start = (cs == EXECUTE) && (opcode == 3'b001) && !active_halted;
wire mult_step  = (cs == MULT_WAIT);
wire booth_m_en = mult_start;
wire booth_main_en = mult_start || mult_step;
wire gclk_booth_m = clk & booth_m_en; // idempotent load only; booth_acc/q remain normal clk

always @(posedge gclk_booth_m or negedge rst_n) begin
    if (~rst_n)
        booth_m <= 18'sd0;
    else
        booth_m <= {{2{rs_reg[15]}}, rs_reg};
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        booth_acc <= 18'sd0;
        booth_q   <= 16'd0;
        booth_qm1 <= 1'b0;
    end
    else if (booth_main_en) begin
        if (mult_start) begin
            booth_acc <= 18'sd0;
            booth_q   <= rt_reg;
            booth_qm1 <= 1'b0;
        end
        else begin
            booth_acc <= booth_shift_out[34:17];
            booth_q   <= booth_shift_out[16:1];
            booth_qm1 <= booth_shift_out[0];
        end
    end
end

// ==========================================================================
// AXI Data Channel Assignments
// ==========================================================================
assign arid_m_inf_data    = 4'b0000;
assign arlen_m_inf_data   = 7'd63;
assign arsize_m_inf_data  = 3'b001;
assign arburst_m_inf_data = 2'b01;
assign araddr_m_inf_data  = {18'd0, axi_addr_reg};
assign arvalid_m_inf_data = (cs == DATA_READ_ADDR);
assign rready_m_inf_data  = (cs == DATA_READ_WAIT);

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
assign bready_m_inf_data  = 1'b1;

wire c_is_load_axi       = data_fill_last;
wire c_is_load_dcache_wb = (!active_halted && cs == EXEC_DONE && opcode == 3'b100 && was_dcache_hit);
wire c_is_load_sq_wb     = (!active_halted && cs == EXEC_DONE && opcode == 3'b100 && was_sq_hit);
wire c_is_load           = c_is_load_axi | c_is_load_dcache_wb | c_is_load_sq_wb;
wire c_is_mult_l = (!active_halted && cs == EXEC_DONE && opcode == 3'b001);
wire c_is_mult_h = (!active_halted && cs == WRITEBACK_MULT);
wire slow_wb_en = c_is_load | c_is_mult_l | c_is_mult_h;

wire [15:0] load_axi_data = (fill_cnt[5:0] == mem_word_off_r) ? rdata_m_inf_data : load_miss_data;
wire [15:0] slow_wb_data = c_is_load_sq_wb     ? load_forward_data :
                           c_is_load_dcache_wb ? dcache_data_r :
                           c_is_load_axi       ? load_axi_data :
                           c_is_mult_h         ? mult_product[31:16] :
                                                 mult_product[15:0];
wire [2:0] slow_waddr = c_is_load   ? rt :
                        c_is_mult_l ? rl : rd;

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

// ==========================================================================
// Stall output with RF writeback staging compensation
// ==========================================================================
wire finish_any = normal_done || drain_done || fast_done;
wire finish_has_rf_wb      = finish_any && (c1_wen || c2_wen);
wire finish_has_dual_rf_wb = finish_any && c1_wen && c2_wen;

// RF writeback uses one staged cycle. When both cores write in the same
// finish cycle, core2 is intentionally committed one cycle later to reduce
// instantaneous peak power, so stall output must be delayed by two cycles.
reg [1:0] finish_rf_wait_cnt;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        finish_rf_wait_cnt <= 2'd0;
    end
    else if (cs == CLEAR_REGS) begin
        finish_rf_wait_cnt <= 2'd0;
    end
    else if (finish_rf_wait_cnt != 2'd0) begin
        finish_rf_wait_cnt <= finish_rf_wait_cnt - 2'd1;
    end
    else if (finish_has_rf_wb) begin
        finish_rf_wait_cnt <= finish_has_dual_rf_wb ? 2'd2 : 2'd1;
    end
end

wire finish_visible = (finish_rf_wait_cnt == 2'd1) || (finish_any && !finish_has_rf_wb);
wire stall_next = ~finish_visible;
wire stall_en = (stall_1 != stall_next) || (stall_2 != stall_next);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        stall_1 <= 1'b1;
        stall_2 <= 1'b1;
    end
    else if (stall_en) begin
        stall_1 <= stall_next;
        stall_2 <= stall_next;
    end
end


// ==========================================================================
// Writeback staging + Register file fine-grain naked-AND clock gating
// ==========================================================================
reg        c1_wen_stg;
reg [2:0]  c1_waddr_stg;
reg [15:0] c1_wdata_stg;
reg        c2_wen_stg;
reg [2:0]  c2_waddr_stg;
reg [15:0] c2_wdata_stg;

reg        c2_wen_hold;
reg [2:0]  c2_waddr_hold;
reg [15:0] c2_wdata_hold;

wire wb_clear_stg = (cs == CLEAR_REGS);
wire dual_rf_wb   = c1_wen && c2_wen;
wire c1_stg_data_en   = !wb_clear_stg && !c2_wen_hold && c1_wen;
wire c2_stg_data_en   = !wb_clear_stg && (c2_wen_hold || (!dual_rf_wb && c2_wen));
wire c2_hold_data_en  = !wb_clear_stg && dual_rf_wb;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        c1_wen_stg  <= 1'b0;
        c2_wen_stg  <= 1'b0;
        c2_wen_hold <= 1'b0;
    end
    else if (wb_clear_stg) begin
        c1_wen_stg  <= 1'b0;
        c2_wen_stg  <= 1'b0;
        c2_wen_hold <= 1'b0;
    end
    else if (c2_wen_hold) begin
        c1_wen_stg  <= 1'b0;
        c2_wen_stg  <= 1'b1;
        c2_wen_hold <= 1'b0;
    end
    else if (dual_rf_wb) begin
        c1_wen_stg  <= 1'b1;
        c2_wen_stg  <= 1'b0;
        c2_wen_hold <= 1'b1;
    end
    else begin
        c1_wen_stg  <= c1_wen;
        c2_wen_stg  <= c2_wen;
        c2_wen_hold <= 1'b0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        c1_waddr_stg <= 3'd0;
        c1_wdata_stg <= 16'd0;
    end
    else if (c1_stg_data_en) begin
        c1_waddr_stg <= c1_waddr;
        c1_wdata_stg <= c1_wdata;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        c2_waddr_stg <= 3'd0;
        c2_wdata_stg <= 16'd0;
    end
    else if (c2_stg_data_en) begin
        if (c2_wen_hold) begin
            c2_waddr_stg <= c2_waddr_hold;
            c2_wdata_stg <= c2_wdata_hold;
        end
        else begin
            c2_waddr_stg <= c2_waddr;
            c2_wdata_stg <= c2_wdata;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        c2_waddr_hold <= 3'd0;
        c2_wdata_hold <= 16'd0;
    end
    else if (c2_hold_data_en) begin
        c2_waddr_hold <= c2_waddr;
        c2_wdata_hold <= c2_wdata;
    end
end

wire clear_c1_rf = (cs == CLEAR_REGS);
wire clear_c2_rf = (cs == CLEAR_REGS_2);

wire c1_r0_en = clear_c1_rf || (c1_wen_stg && c1_waddr_stg == 3'd0);
wire c1_r1_en = clear_c1_rf || (c1_wen_stg && c1_waddr_stg == 3'd1);
wire c1_r2_en = clear_c1_rf || (c1_wen_stg && c1_waddr_stg == 3'd2);
wire c1_r3_en = clear_c1_rf || (c1_wen_stg && c1_waddr_stg == 3'd3);
wire c1_r4_en = clear_c1_rf || (c1_wen_stg && c1_waddr_stg == 3'd4);
wire c1_r5_en = clear_c1_rf || (c1_wen_stg && c1_waddr_stg == 3'd5);
wire c1_r6_en = clear_c1_rf || (c1_wen_stg && c1_waddr_stg == 3'd6);
wire c1_r7_en = clear_c1_rf || (c1_wen_stg && c1_waddr_stg == 3'd7);
wire c2_r0_en = clear_c2_rf || (c2_wen_stg && c2_waddr_stg == 3'd0);
wire c2_r1_en = clear_c2_rf || (c2_wen_stg && c2_waddr_stg == 3'd1);
wire c2_r2_en = clear_c2_rf || (c2_wen_stg && c2_waddr_stg == 3'd2);
wire c2_r3_en = clear_c2_rf || (c2_wen_stg && c2_waddr_stg == 3'd3);
wire c2_r4_en = clear_c2_rf || (c2_wen_stg && c2_waddr_stg == 3'd4);
wire c2_r5_en = clear_c2_rf || (c2_wen_stg && c2_waddr_stg == 3'd5);
wire c2_r6_en = clear_c2_rf || (c2_wen_stg && c2_waddr_stg == 3'd6);
wire c2_r7_en = clear_c2_rf || (c2_wen_stg && c2_waddr_stg == 3'd7);

wire gclk_c1_r0 = clk & c1_r0_en;
wire gclk_c1_r1 = clk & c1_r1_en;
wire gclk_c1_r2 = clk & c1_r2_en;
wire gclk_c1_r3 = clk & c1_r3_en;
wire gclk_c1_r4 = clk & c1_r4_en;
wire gclk_c1_r5 = clk & c1_r5_en;
wire gclk_c1_r6 = clk & c1_r6_en;
wire gclk_c1_r7 = clk & c1_r7_en;
wire gclk_c2_r0 = clk & c2_r0_en;
wire gclk_c2_r1 = clk & c2_r1_en;
wire gclk_c2_r2 = clk & c2_r2_en;
wire gclk_c2_r3 = clk & c2_r3_en;
wire gclk_c2_r4 = clk & c2_r4_en;
wire gclk_c2_r5 = clk & c2_r5_en;
wire gclk_c2_r6 = clk & c2_r6_en;
wire gclk_c2_r7 = clk & c2_r7_en;

always @(posedge gclk_c1_r0 or negedge rst_n) begin
    if (~rst_n) core_1_r0 <= 16'd0;
    else        core_1_r0 <= clear_c1_rf ? 16'd0 : c1_wdata_stg;
end
always @(posedge gclk_c1_r1 or negedge rst_n) begin
    if (~rst_n) core_1_r1 <= 16'd0;
    else        core_1_r1 <= clear_c1_rf ? 16'd0 : c1_wdata_stg;
end
always @(posedge gclk_c1_r2 or negedge rst_n) begin
    if (~rst_n) core_1_r2 <= 16'd0;
    else        core_1_r2 <= clear_c1_rf ? 16'd0 : c1_wdata_stg;
end
always @(posedge gclk_c1_r3 or negedge rst_n) begin
    if (~rst_n) core_1_r3 <= 16'd0;
    else        core_1_r3 <= clear_c1_rf ? 16'd0 : c1_wdata_stg;
end
always @(posedge gclk_c1_r4 or negedge rst_n) begin
    if (~rst_n) core_1_r4 <= 16'd0;
    else        core_1_r4 <= clear_c1_rf ? 16'd0 : c1_wdata_stg;
end
always @(posedge gclk_c1_r5 or negedge rst_n) begin
    if (~rst_n) core_1_r5 <= 16'd0;
    else        core_1_r5 <= clear_c1_rf ? 16'd0 : c1_wdata_stg;
end
always @(posedge gclk_c1_r6 or negedge rst_n) begin
    if (~rst_n) core_1_r6 <= 16'd0;
    else        core_1_r6 <= clear_c1_rf ? 16'd0 : c1_wdata_stg;
end
always @(posedge gclk_c1_r7 or negedge rst_n) begin
    if (~rst_n) core_1_r7 <= 16'd0;
    else        core_1_r7 <= clear_c1_rf ? 16'd0 : c1_wdata_stg;
end

always @(posedge gclk_c2_r0 or negedge rst_n) begin
    if (~rst_n) core_2_r0 <= 16'd0;
    else        core_2_r0 <= clear_c2_rf ? 16'd0 : c2_wdata_stg;
end
always @(posedge gclk_c2_r1 or negedge rst_n) begin
    if (~rst_n) core_2_r1 <= 16'd0;
    else        core_2_r1 <= clear_c2_rf ? 16'd0 : c2_wdata_stg;
end
always @(posedge gclk_c2_r2 or negedge rst_n) begin
    if (~rst_n) core_2_r2 <= 16'd0;
    else        core_2_r2 <= clear_c2_rf ? 16'd0 : c2_wdata_stg;
end
always @(posedge gclk_c2_r3 or negedge rst_n) begin
    if (~rst_n) core_2_r3 <= 16'd0;
    else        core_2_r3 <= clear_c2_rf ? 16'd0 : c2_wdata_stg;
end
always @(posedge gclk_c2_r4 or negedge rst_n) begin
    if (~rst_n) core_2_r4 <= 16'd0;
    else        core_2_r4 <= clear_c2_rf ? 16'd0 : c2_wdata_stg;
end
always @(posedge gclk_c2_r5 or negedge rst_n) begin
    if (~rst_n) core_2_r5 <= 16'd0;
    else        core_2_r5 <= clear_c2_rf ? 16'd0 : c2_wdata_stg;
end
always @(posedge gclk_c2_r6 or negedge rst_n) begin
    if (~rst_n) core_2_r6 <= 16'd0;
    else        core_2_r6 <= clear_c2_rf ? 16'd0 : c2_wdata_stg;
end
always @(posedge gclk_c2_r7 or negedge rst_n) begin
    if (~rst_n) core_2_r7 <= 16'd0;
    else        core_2_r7 <= clear_c2_rf ? 16'd0 : c2_wdata_stg;
end
endmodule

module MEM_256X16(
    input         CLK, CS, OE, WEB,
    input  [7:0]  A,
    input  [15:0] DI,
    output [15:0] DO
);
SRAM_256X16 SRAM_inst(
    .A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .A5(A[5]), .A6(A[6]), .A7(A[7]),
    .DO0(DO[0]),   .DO1(DO[1]),   .DO2(DO[2]),   .DO3(DO[3]),
    .DO4(DO[4]),   .DO5(DO[5]),   .DO6(DO[6]),   .DO7(DO[7]),
    .DO8(DO[8]),   .DO9(DO[9]),   .DO10(DO[10]), .DO11(DO[11]),
    .DO12(DO[12]), .DO13(DO[13]), .DO14(DO[14]), .DO15(DO[15]),
    .DI0(DI[0]),   .DI1(DI[1]),   .DI2(DI[2]),   .DI3(DI[3]),
    .DI4(DI[4]),   .DI5(DI[5]),   .DI6(DI[6]),   .DI7(DI[7]),
    .DI8(DI[8]),   .DI9(DI[9]),   .DI10(DI[10]), .DI11(DI[11]),
    .DI12(DI[12]), .DI13(DI[13]), .DI14(DI[14]), .DI15(DI[15]),
    .CK(CLK), .WEB(WEB), .OE(OE), .CS(CS)
);
endmodule
