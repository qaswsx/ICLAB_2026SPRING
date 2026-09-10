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

reg [15:0] pc_1, pc_2;
reg [15:0] inst_reg_1, inst_reg_2;

reg thread_id;     
reg exec_order;    
reg exec_step;     

reg [9:0] cache_tag_1, cache_tag_2;
reg       cache_valid_1, cache_valid_2;
reg [4:0] sram_waddr;

localparam IDLE            = 5'd0;
localparam HALT_CHECK      = 5'd1;
localparam CACHE_WAIT      = 5'd2;
localparam FETCH_ADDR      = 5'd4;
localparam FETCH_DATA      = 5'd5;
localparam FETCH_DONE      = 5'd6;
localparam EXECUTE         = 5'd8;
localparam MULT_WAIT       = 5'd9;
localparam WRITEBACK_MULT  = 5'd11;
localparam DATA_READ_ADDR  = 5'd12;
localparam DATA_READ_WAIT  = 5'd13;
localparam DATA_WRITE_ADDR = 5'd14;
localparam DATA_WRITE_DATA = 5'd15;
localparam DATA_WRITE_RESP = 5'd16;
localparam EXEC_DONE       = 5'd17;
localparam CLEAR_REGS      = 5'd18;

reg [4:0] cs, ns;

wire t0_halted = (pc_1 >= 16'h2000);
wire t1_halted = (pc_2 >= 16'h2000);
wire active_halted = (thread_id == 1'b0) ? t0_halted : t1_halted;

wire arready = (thread_id == 1'b0) ? arready_m_inf_inst_1 : arready_m_inf_inst_2;
wire rvalid  = (thread_id == 1'b0) ? rvalid_m_inf_inst_1  : rvalid_m_inf_inst_2;
wire rlast   = (thread_id == 1'b0) ? rlast_m_inf_inst_1   : rlast_m_inf_inst_2;

// ==========================================================================
// Arbitration Logic
// ==========================================================================
wire [2:0] op1 = inst_reg_1[15:13];
wire [2:0] op2 = inst_reg_2[15:13];
wire t0_is_store = !t0_halted && (op1 == 3'b101);
wire t1_is_store = !t1_halted && (op2 == 3'b101);

wire t1_goes_first = t1_is_store && !t0_is_store; 
wire next_thread_to_exec = exec_order ? 1'b0 : 1'b1;
wire next_thread_halted  = (next_thread_to_exec == 1'b0) ? t0_halted : t1_halted;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        exec_order <= 1'b0;
        exec_step  <= 1'b0;
    end 
    else if (cs == CLEAR_REGS) begin 
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
    else if (cs == CLEAR_REGS) begin
        thread_id <= 1'b0;
    end 
    else if (cs == CACHE_WAIT && thread_id == 1'b0) begin 
        thread_id <= 1'b1;
    end 
    else if (cs == FETCH_DONE) begin
        thread_id <= t1_goes_first ? 1'b1 : 1'b0;
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

// ==========================================================================
// Instruction Decoding
// ==========================================================================
wire [15:0] active_pc   = (thread_id == 1'b0) ? pc_1 : pc_2;
wire [15:0] active_inst = (thread_id == 1'b0) ? inst_reg_1 : inst_reg_2;

wire [2:0] opcode = active_inst[15:13];
wire [2:0] rs     = active_inst[12:10];
wire [2:0] rt     = active_inst[9:7];
wire [2:0] rd     = active_inst[6:4];
wire [2:0] func   = active_inst[3:1];
wire [2:0] rl     = active_inst[3:1];
wire signed [15:0] imm = {{9{active_inst[6]}}, active_inst[6:0]};

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

// ==========================================================================
// FSM
// ==========================================================================
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) cs <= IDLE;
    else        cs <= ns;
end

always @(*) begin
    case (cs)
        IDLE: ns = HALT_CHECK;
        HALT_CHECK: begin
            if (t0_halted && t1_halted) ns = CLEAR_REGS;
            else if (thread_id == 1'b0 && t0_halted) ns = FETCH_DONE; 
            else if (thread_id == 1'b1 && t1_halted) ns = FETCH_DONE;
            else if ((thread_id == 1'b0 && cache_valid_1 && (cache_tag_1 == pc_1[15:6])) ||
                     (thread_id == 1'b1 && cache_valid_2 && (cache_tag_2 == pc_2[15:6]))) 
                ns = CACHE_WAIT;
            else 
                ns = FETCH_ADDR;
        end
        CACHE_WAIT: begin
            if (thread_id == 1'b0) ns = HALT_CHECK; 
            else                   ns = FETCH_DONE;
        end
        FETCH_ADDR: if (arready) ns = FETCH_DATA; else ns = FETCH_ADDR;
        FETCH_DATA: if (rvalid && rlast) ns = HALT_CHECK; else ns = FETCH_DATA;
        FETCH_DONE: begin
            if (t1_goes_first ? t1_halted : t0_halted) ns = EXEC_DONE; 
            else ns = EXECUTE;
        end
        EXECUTE: begin 
            if (opcode == 3'b100)       ns = DATA_READ_ADDR;
            else if (opcode == 3'b101)  ns = DATA_WRITE_ADDR;
            else if (opcode == 3'b110 || opcode == 3'b111) ns = EXEC_DONE;
            else if (opcode == 3'b001)  ns = MULT_WAIT; 
            else                        ns = EXEC_DONE;
        end
        MULT_WAIT: begin
            if (mul_cnt == 3'd4) ns = WRITEBACK_MULT;
            else                 ns = MULT_WAIT;
        end
        WRITEBACK_MULT: ns = EXEC_DONE;                  

        DATA_READ_ADDR:  if (arready_m_inf_data) ns = DATA_READ_WAIT;
                         else ns = DATA_READ_ADDR;
        DATA_READ_WAIT:  if (rvalid_m_inf_data && rlast_m_inf_data) ns = EXEC_DONE; else ns = DATA_READ_WAIT;
        DATA_WRITE_ADDR: if (awready_m_inf_data) ns = DATA_WRITE_DATA;
                         else ns = DATA_WRITE_ADDR;
        DATA_WRITE_DATA: if (wready_m_inf_data)  ns = DATA_WRITE_RESP;
                         else ns = DATA_WRITE_DATA;
        DATA_WRITE_RESP: if (bvalid_m_inf_data)  ns = EXEC_DONE; else ns = DATA_WRITE_RESP;
        EXEC_DONE: begin
            if (exec_step == 1'b0) begin
                if (next_thread_halted) ns = EXEC_DONE;
                else                    ns = EXECUTE;
            end 
            else begin
                ns = HALT_CHECK;
            end
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
        stall_1 <= ~(cs == EXEC_DONE && exec_step == 1'b1);
        stall_2 <= ~(cs == EXEC_DONE && exec_step == 1'b1);
    end
end

// ==========================================================================
// SRAM Cache (Shared Instance) 
// ==========================================================================
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        cache_valid_1 <= 1'b0; cache_tag_1 <= 10'd0;
        cache_valid_2 <= 1'b0; cache_tag_2 <= 10'd0;
        sram_waddr <= 5'd0;
    end 
    else if (cs == CLEAR_REGS) begin 
        cache_valid_1 <= 1'b0; cache_tag_1 <= 10'd0;
        cache_valid_2 <= 1'b0; cache_tag_2 <= 10'd0;
    end 
    else begin
        if (cs == FETCH_ADDR) begin
            sram_waddr <= 5'd0;
        end 
        else if (cs == FETCH_DATA && rvalid) begin
            sram_waddr <= sram_waddr + 5'd1;
            if (rlast) begin
                if (thread_id == 1'b0) begin
                    cache_valid_1 <= 1'b1;
                    cache_tag_1 <= pc_1[15:6]; 
                end 
                else begin
                    cache_valid_2 <= 1'b1;
                    cache_tag_2 <= pc_2[15:6]; 
                end
            end
        end
    end
end

wire sram_we_n = ~(cs == FETCH_DATA && rvalid);
wire [5:0] sram_addr = (sram_we_n == 1'b0) ? {thread_id, sram_waddr} : {thread_id, active_pc[5:1]};
wire sram_cs = (cs == HALT_CHECK || cs == CACHE_WAIT || cs == FETCH_ADDR || cs == FETCH_DATA); 
wire [15:0] sram_di = (thread_id == 1'b0) ? rdata_m_inf_inst_1 : rdata_m_inf_inst_2;
wire [15:0] sram_inst_out;

MEM_64X16 Shared_I_Cache_SRAM (
    .CLK(clk), .CS(sram_cs), .OE(1'b1), .WEB(sram_we_n),
    .A(sram_addr), .DI(sram_di), .DO(sram_inst_out)
);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        inst_reg_1 <= 16'd0;
        inst_reg_2 <= 16'd0;
    end 
    else begin
        if (cs == CACHE_WAIT && thread_id == 1'b0) inst_reg_1 <= sram_inst_out;
        if (cs == CACHE_WAIT && thread_id == 1'b1) inst_reg_2 <= sram_inst_out;
    end
end

wire read_thread_id = (cs == EXEC_DONE && exec_step == 1'b0) ? next_thread_to_exec : 
                      (cs == FETCH_DONE) ? (t1_goes_first ? 1'b1 : 1'b0) : thread_id;

wire [15:0] read_inst = (read_thread_id == 1'b0) ? inst_reg_1 : inst_reg_2;
wire [2:0] read_rs = read_inst[12:10];
wire [2:0] read_rt = read_inst[9:7];

wire [15:0] t_r0 = (read_thread_id == 1'b0) ? core_1_r0 : core_2_r0;
wire [15:0] t_r1 = (read_thread_id == 1'b0) ? core_1_r1 : core_2_r1;
wire [15:0] t_r2 = (read_thread_id == 1'b0) ? core_1_r2 : core_2_r2;
wire [15:0] t_r3 = (read_thread_id == 1'b0) ? core_1_r3 : core_2_r3;
wire [15:0] t_r4 = (read_thread_id == 1'b0) ? core_1_r4 : core_2_r4;
wire [15:0] t_r5 = (read_thread_id == 1'b0) ? core_1_r5 : core_2_r5;
wire [15:0] t_r6 = (read_thread_id == 1'b0) ? core_1_r6 : core_2_r6;
wire [15:0] t_r7 = (read_thread_id == 1'b0) ? core_1_r7 : core_2_r7;

reg signed [15:0] val_rs, val_rt;
always @(*) begin
    case (read_rs)
        3'd0: val_rs = t_r0; 
        3'd1: val_rs = t_r1; 
        3'd2: val_rs = t_r2; 
        3'd3: val_rs = t_r3;
        3'd4: val_rs = t_r4; 
        3'd5: val_rs = t_r5;
        3'd6: val_rs = t_r6; 
        3'd7: val_rs = t_r7;
    endcase
    case (read_rt)
        3'd0: val_rt = t_r0; 
        3'd1: val_rt = t_r1; 
        3'd2: val_rt = t_r2; 
        3'd3: val_rt = t_r3;
        3'd4: val_rt = t_r4; 
        3'd5: val_rt = t_r5;
        3'd6: val_rt = t_r6; 
        3'd7: val_rt = t_r7;
    endcase
end

reg signed [15:0] rs_reg, rt_reg;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        rs_reg <= 16'd0;
        rt_reg <= 16'd0;
    end 
    else if (cs == FETCH_DONE || (cs == EXEC_DONE && exec_step == 1'b0 && !next_thread_halted)) begin 
        rs_reg <= val_rs;
        rt_reg <= val_rt;
    end
end

wire c_is_slt = (opcode == 3'b000 && func == 3'b111);
wire c_is_sub = (opcode == 3'b011) || (opcode == 3'b000 && func == 3'b001) || c_is_slt;
wire use_imm = (opcode == 3'b010) || (opcode == 3'b011) || (opcode == 3'b100) || (opcode == 3'b101);

wire [15:0] c_addsub_a = rs_reg;
wire [15:0] c_addsub_b = use_imm ? imm : rt_reg;
wire c_do_sub = (cs == EXECUTE && c_is_sub);

wire [15:0] c_addsub_res = c_do_sub ? (c_addsub_a - c_addsub_b) : (c_addsub_a + c_addsub_b);

wire slt_result = (rs_reg[15] != rt_reg[15]) ? rs_reg[15] : c_addsub_res[15];
wire [15:0] c_mem_addr = c_addsub_res; 

wire [15:0] bitwise_base = (func[0]) ? (rs_reg | rt_reg) : (rs_reg & rt_reg);
wire [15:0] bitwise_res  = func[2] ? ~bitwise_base : bitwise_base;
wire [15:0] w_xor        = rs_reg ^ rt_reg;

reg signed [15:0] alu_out;
always @(*) begin
    case (opcode)
        3'b000: begin 
            case (func)
                3'b000, 3'b001: alu_out = c_addsub_res;
                3'b010, 3'b011, 3'b100, 3'b101: alu_out = bitwise_res; 
                3'b110: alu_out = w_xor;
                3'b111: alu_out = {15'd0, slt_result}; 
                default: alu_out = 16'd0;
            endcase
        end
        3'b010, 3'b011: alu_out = c_addsub_res;
        default: alu_out = 16'd0;
    endcase
end

reg signed [15:0] alu_out_reg;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        alu_out_reg <= 16'd0;
    end 
    else if (cs == EXECUTE) begin
        alu_out_reg <= alu_out;
    end
end

reg [15:0] axi_addr_reg;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        axi_addr_reg <= 16'd0;
    end 
    else if (cs == EXECUTE) begin
        axi_addr_reg <= {c_mem_addr[14:0], 1'b0} + 16'h1000;
    end
end

wire signed [8:0] a_low  = {1'b0, rs_reg[7:0]};
wire signed [8:0] a_high = {rs_reg[15], rs_reg[15:8]};
wire signed [8:0] b_low  = {1'b0, rt_reg[7:0]};
wire signed [8:0] b_high = {rt_reg[15], rt_reg[15:8]};

reg signed [8:0] mul_op_a_reg;
reg signed [8:0] mul_op_b_reg;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        mul_op_a_reg <= 9'd0;
        mul_op_b_reg <= 9'd0;
    end 
    else if (cs == EXECUTE) begin
        mul_op_a_reg <= a_low;
        mul_op_b_reg <= b_low;
    end 
    else if (cs == MULT_WAIT) begin
        if (mul_cnt == 3'd0) begin
            mul_op_a_reg <= a_high;
            mul_op_b_reg <= b_low;
        end 
        else if (mul_cnt == 3'd1) begin
            mul_op_a_reg <= a_low;
            mul_op_b_reg <= b_high;
        end 
        else if (mul_cnt == 3'd2) begin
            mul_op_a_reg <= a_high;
            mul_op_b_reg <= b_high;
        end
    end
end

wire signed [17:0] mul_comb = mul_op_a_reg * mul_op_b_reg;
reg signed [17:0] mul_res_reg;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) mul_res_reg <= 18'd0;
    else mul_res_reg <= mul_comb;
end

reg signed [31:0] adder_b;
always @(*) begin
    case(mul_cnt)
        3'd1: adder_b = {{14{mul_res_reg[17]}}, mul_res_reg};
        3'd2, 3'd3: adder_b = {{6{mul_res_reg[17]}}, mul_res_reg, 8'd0};
        3'd4: adder_b = {mul_res_reg[15:0], 16'd0}; 
        default: adder_b = 32'd0;
    endcase
end

reg signed [31:0] mult_out_reg;
wire signed [31:0] next_mult_out = mult_out_reg + adder_b;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        mult_out_reg <= 32'd0;
    end 
    else if (cs == EXECUTE) begin
        mult_out_reg <= 32'd0;
    end 
    else if (cs == MULT_WAIT && mul_cnt >= 3'd1 && mul_cnt <= 3'd4) begin
        mult_out_reg <= next_mult_out;
    end
end

// ==========================================================================
// AXI Assignments
// ==========================================================================
assign arid_m_inf_inst_1    = 4'b0000;
assign araddr_m_inf_inst_1  = {16'b0, pc_1[15:6], 6'd0};
assign arlen_m_inf_inst_1   = 7'b001_1111;    
assign arsize_m_inf_inst_1  = 3'b001;        
assign arburst_m_inf_inst_1 = 2'b01;
assign arvalid_m_inf_inst_1 = (cs == FETCH_ADDR) && (thread_id == 1'b0);

assign arid_m_inf_inst_2    = 4'b0000;
assign araddr_m_inf_inst_2  = {16'b0, pc_2[15:6], 6'd0}; 
assign arlen_m_inf_inst_2   = 7'b001_1111;    
assign arsize_m_inf_inst_2  = 3'b001;
assign arburst_m_inf_inst_2 = 2'b01;
assign arvalid_m_inf_inst_2 = (cs == FETCH_ADDR) && (thread_id == 1'b1);

assign rready_m_inf_inst_1 = (cs == FETCH_DATA) && (thread_id == 1'b0);
assign rready_m_inf_inst_2 = (cs == FETCH_DATA) && (thread_id == 1'b1);

assign arid_m_inf_data    = 4'b0000;
assign arlen_m_inf_data   = 7'b0000000;
assign arsize_m_inf_data  = 3'b001;
assign arburst_m_inf_data = 2'b01;
assign araddr_m_inf_data  = {16'd0, axi_addr_reg};
assign arvalid_m_inf_data = (cs == DATA_READ_ADDR);
assign rready_m_inf_data  = (cs == DATA_READ_WAIT);

assign awid_m_inf_data    = 4'b0000;
assign awlen_m_inf_data   = 7'd0;
assign awsize_m_inf_data  = 3'b001;
assign awburst_m_inf_data = 2'b01;
assign awaddr_m_inf_data  = {16'd0, axi_addr_reg};
assign awvalid_m_inf_data = (cs == DATA_WRITE_ADDR);
assign wdata_m_inf_data   = rt_reg;
assign wvalid_m_inf_data  = (cs == DATA_WRITE_ADDR) || (cs == DATA_WRITE_DATA); 
assign wlast_m_inf_data   = wvalid_m_inf_data; 
assign bready_m_inf_data  = (cs == DATA_WRITE_RESP);

wire inst_done_pulse = !active_halted && (
                       (cs == EXEC_DONE && (opcode == 3'b000 || opcode == 3'b010 || opcode == 3'b011 || opcode == 3'b001)) ||
                       (cs == EXECUTE && (opcode == 3'b110 || opcode == 3'b111)) ||
                       (cs == DATA_READ_WAIT && rvalid_m_inf_data && rlast_m_inf_data) ||
                       (cs == DATA_WRITE_RESP && bvalid_m_inf_data)
                       );

wire [15:0] current_target_pc = (thread_id == 1'b0) ? pc_1 : pc_2;
wire [15:0] pc_plus_2 = current_target_pc + 16'd2;
wire [15:0] next_target_pc = (opcode == 3'b110 && rs_reg == rt_reg) ? (pc_plus_2 + {imm[14:0], 1'b0}) : pc_plus_2;
wire [15:0] jmp_pc = {3'b000, active_inst[12:0]};

always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        pc_1 <= 16'd0;
        pc_2 <= 16'd0;
    end 
    else if (cs == CLEAR_REGS) begin
        pc_1 <= 16'd0;
        pc_2 <= 16'd0;
    end 
    else begin
        if (inst_done_pulse) begin
            if (thread_id == 1'b0) begin
                pc_1 <= (opcode == 3'b111) ? jmp_pc : next_target_pc;
            end 
            else begin
                pc_2 <= (opcode == 3'b111) ? jmp_pc : next_target_pc;
            end
        end
    end
end

// ==========================================================================
// Writeback Logic 
// ==========================================================================
wire c_is_load   = (cs == DATA_READ_WAIT && rvalid_m_inf_data && rlast_m_inf_data);
wire c_is_alu    = (!active_halted && cs == EXEC_DONE && (opcode == 3'b000 || opcode == 3'b010 || opcode == 3'b011));
wire c_is_mult_l = (!active_halted && cs == EXEC_DONE && opcode == 3'b001); 
wire c_is_mult_h = (!active_halted && cs == WRITEBACK_MULT);

wire c_wb_en = c_is_load | c_is_alu;
wire [15:0] c_wb_data = c_is_load ? rdata_m_inf_data : alu_out_reg;

wire [7:0] dec_rd = 8'd1 << rd;
wire [7:0] dec_rt = 8'd1 << rt;
wire [7:0] dec_rl = 8'd1 << rl;

wire [7:0] c_alu_load_we = c_wb_en ? ((opcode == 3'b000 && !c_is_load) ? dec_rd : dec_rt) : 8'd0;
wire [7:0] c_mult_l_we   = c_is_mult_l ? dec_rl : 8'd0;
wire [7:0] c_mult_h_we   = c_is_mult_h ? dec_rd : 8'd0;

wire [7:0] c_final_we = c_alu_load_we | c_mult_l_we | c_mult_h_we;

wire [15:0] c_final_wdata = c_is_mult_h ? mult_out_reg[31:16] :
                            c_is_mult_l ? mult_out_reg[15:0]  : c_wb_data;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        core_1_r0 <= 0; core_2_r0 <= 0;
        core_1_r1 <= 0; core_2_r1 <= 0;
        core_1_r2 <= 0; core_2_r2 <= 0;
        core_1_r3 <= 0; core_2_r3 <= 0;
        core_1_r4 <= 0; core_2_r4 <= 0;
        core_1_r5 <= 0; core_2_r5 <= 0;
        core_1_r6 <= 0; core_2_r6 <= 0;
        core_1_r7 <= 0; core_2_r7 <= 0;
    end 
    else if (cs == CLEAR_REGS) begin
        core_1_r0 <= 0; core_2_r0 <= 0;
        core_1_r1 <= 0; core_2_r1 <= 0;
        core_1_r2 <= 0; core_2_r2 <= 0;
        core_1_r3 <= 0; core_2_r3 <= 0;
        core_1_r4 <= 0; core_2_r4 <= 0;
        core_1_r5 <= 0; core_2_r5 <= 0;
        core_1_r6 <= 0; core_2_r6 <= 0;
        core_1_r7 <= 0; core_2_r7 <= 0;
    end 
    else begin
        if (thread_id == 1'b0) begin
            if (c_final_we[0]) core_1_r0 <= c_final_wdata;
            if (c_final_we[1]) core_1_r1 <= c_final_wdata;
            if (c_final_we[2]) core_1_r2 <= c_final_wdata;
            if (c_final_we[3]) core_1_r3 <= c_final_wdata;
            if (c_final_we[4]) core_1_r4 <= c_final_wdata;
            if (c_final_we[5]) core_1_r5 <= c_final_wdata;
            if (c_final_we[6]) core_1_r6 <= c_final_wdata;
            if (c_final_we[7]) core_1_r7 <= c_final_wdata;
        end 
        else begin
            if (c_final_we[0]) core_2_r0 <= c_final_wdata;
            if (c_final_we[1]) core_2_r1 <= c_final_wdata;
            if (c_final_we[2]) core_2_r2 <= c_final_wdata;
            if (c_final_we[3]) core_2_r3 <= c_final_wdata;
            if (c_final_we[4]) core_2_r4 <= c_final_wdata;
            if (c_final_we[5]) core_2_r5 <= c_final_wdata;
            if (c_final_we[6]) core_2_r6 <= c_final_wdata;
            if (c_final_we[7]) core_2_r7 <= c_final_wdata;
        end
    end
end

endmodule

module MEM_64X16(
    input         CLK, CS, OE, WEB,
    input  [5:0]  A,   
    input  [15:0] DI,  
    output [15:0] DO   
);
SRAM_64X16 SRAM_inst(
    .A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .A5(A[5]),
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