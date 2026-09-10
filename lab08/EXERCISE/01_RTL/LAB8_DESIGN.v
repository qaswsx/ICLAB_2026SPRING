// synopsys translate_off
`ifdef RTL
	`include "GATED_OR.v"
`else
	`include "Netlist/GATED_OR_SYN.v"
`endif
// synopsys translate_on

module LAB8_DESIGN(
    input              clk,
    input              rst_n,
    input              in_valid,
    input       [7:0]  in_data,
    input              cg_en,
    output reg         out_valid,
    output reg  [11:0] out_data
);

//==================================================================
// parameter & integer
//==================================================================
localparam IDLE = 0;
localparam CALC = 1;

//==================================================================
// reg & wire
//==================================================================
reg cs, ns;
reg task_temp;

reg [11:0] A_flat [0:15];
reg [11:0] B_flat [0:15];

reg [3:0] buf_cur;
reg [6:0] cnt;
wire [6:0] calc_cnt = cnt - 7'd34;

reg [3:0]  psum_x [0:3];
reg [7:0]  psum_y [0:3];
reg [3:0]  X_reg [0:3][0:3];

wire [11:0] mid_b_w [0:3];
wire [3:0]  mod_15_out[0:3];
wire [7:0]  single_div_quo;
wire [3:0]  mac_x_out_w[0:3];
wire [7:0]  mac_y_out_w[0:3];
wire [7:0]  mac2_out_w[0:3];

always@(posedge clk or negedge rst_n) begin
    if(~rst_n) cs <= IDLE;
    else cs <= ns;
end

always@(*) begin
    ns = cs;
    case(cs)
        IDLE: if (cnt >= 33) ns = CALC; else ns = IDLE;
        CALC: if (calc_cnt >= 95) ns = IDLE; else ns = CALC;
    endcase
end

always@(posedge clk or negedge rst_n) begin
    if(~rst_n) cnt <= 0;
    else if (cs == CALC && calc_cnt >= 95) cnt <= 0;
    else if (in_valid || cs == CALC) cnt <= cnt + 1;
    else cnt <= 0;
end

wire [3:0] load_idx = cnt[3:0] - 4'd1;

always@(posedge clk) begin
    if(in_valid && cnt == 0) task_temp <= in_data[0];
end

wire [1:0] row_idx = calc_cnt[3:2];
wire [1:0] cc_lsb  = calc_cnt[1:0];

wire is_stage_2 = (calc_cnt[6:4] == 3'b011);
wire is_stage_3 = (calc_cnt[6:4] == 3'b100);
wire is_div_stage = is_stage_2 || is_stage_3;

wire is_in_1_16   = ((cnt[6:4] == 3'd0) && (|cnt[3:0])) || (cnt == 7'd16);
wire is_in_17_32  = ((cnt[6:4] == 3'd1) && (|cnt[3:0])) || (cnt == 7'd32);
wire is_in_33_48  = ((cnt[6:4] == 3'd2) && (|cnt[3:0])) || (cnt == 7'd48);
wire is_in_49_64  = ((cnt[6:4] == 3'd3) && (|cnt[3:0])) || (cnt == 7'd64);

wire is_in_33_96  = ((cnt[6:5] == 2'b01) && (|cnt[4:0])) ||
                    (cnt[6:5] == 2'b10) ||
                    (cnt == 7'd96);

wire is_calc_0_15  = (calc_cnt[6:4] == 3'b000);
wire is_calc_16_31 = (calc_cnt[6:4] == 3'b001);
wire is_calc_32_47 = (calc_cnt[6:4] == 3'b010);
wire is_calc_48_63 = (calc_cnt[6:4] == 3'b011);

wire is_calc_52_67 = ((calc_cnt[6:4] == 3'b011) && (calc_cnt[3:2] != 2'b00)) ||
                     (calc_cnt[6:2] == 5'b10000);

wire is_calc_68_83 = ((calc_cnt[6:4] == 3'b100) && (calc_cnt[3:2] != 2'b00)) ||
                     (calc_cnt[6:2] == 5'b10100);

reg [7:0] num_buf [0:3];

wire [1:0] prev_row_idx = {~(row_idx[1] ^ row_idx[0]), ~row_idx[0]};

wire is_div_load_cycle = (cc_lsb == 2'b11) && is_div_stage;

wire en_numbuf = cs == CALC && is_div_load_cycle;
wire clk_numbuf;
GATED_OR GATED_numbuf (
    .CLOCK(clk), .SLEEP_CTRL(cg_en && !en_numbuf), .RST_N(rst_n), .CLOCK_GATED(clk_numbuf)
);

always @(posedge clk_numbuf) begin
    if (cs == CALC && is_div_load_cycle) begin
        num_buf[0] <= mid_b_w[0][7:0];
        num_buf[1] <= mid_b_w[1][7:0];
        num_buf[2] <= mid_b_w[2][7:0];
        num_buf[3] <= mid_b_w[3][7:0];
    end
end

always@(posedge clk) begin
    if(in_valid && is_in_33_96) begin
        buf_cur <= in_data[3:0];
    end
end

wire [3:0] flat_idx_load    = load_idx;
wire [3:0] flat_idx_calc_cc = {prev_row_idx, cc_lsb}; 

wire en_A [0:15];
wire clk_A [0:15];

genvar i;
generate
for (i = 0; i < 16; i = i + 1) begin : GATED_A_FLAT
    assign en_A[i] = 
        (in_valid && is_in_1_16 && (flat_idx_load == i)) ||
        (in_valid && task_temp && is_in_33_48 && (flat_idx_load == i)) ||
        (cs == CALC && is_calc_48_63 && cc_lsb == 2'b11 && ~task_temp && (row_idx == (i/4))) || 
        (cs == CALC && task_temp && is_calc_52_67 && (flat_idx_calc_cc == i));

    GATED_OR GATED_A_elem (
        .CLOCK(clk), .SLEEP_CTRL(cg_en && !en_A[i]), .RST_N(rst_n), .CLOCK_GATED(clk_A[i])
    );

    always @(posedge clk_A[i]) begin
        if (in_valid) begin
            if (is_in_1_16 && flat_idx_load == i)
                A_flat[i] <= {4'd0, in_data};
            if (task_temp && is_in_33_48 && flat_idx_load == i)
                A_flat[i] <= {in_data[3:0], A_flat[i][7:0]}; 
        end
        if (cs == CALC) begin
            if (is_calc_48_63 && cc_lsb == 2'b11 && ~task_temp && (row_idx == (i/4)))
                A_flat[i] <= mid_b_w[(i%4)]; 
            if (task_temp && is_calc_52_67 && flat_idx_calc_cc == i)
                A_flat[i] <= {A_flat[i][11:8], single_div_quo};
        end
    end
end
endgenerate

wire en_B [0:15];
wire clk_B [0:15];

genvar j;
generate
for (j = 0; j < 16; j = j + 1) begin : GATED_B_FLAT
    assign en_B[j] = 
        (in_valid && is_in_17_32 && (flat_idx_load == j)) ||
        (in_valid && task_temp && is_in_49_64 && (flat_idx_load == j)) ||
        (cs == CALC && is_calc_16_31 && cc_lsb == 2'b11 && ~task_temp && (row_idx == (j/4))) || 
        (cs == CALC && task_temp && is_calc_68_83 && (flat_idx_calc_cc == j));

    GATED_OR GATED_B_elem (
        .CLOCK(clk), .SLEEP_CTRL(cg_en && !en_B[j]), .RST_N(rst_n), .CLOCK_GATED(clk_B[j])
    );

    always @(posedge clk_B[j]) begin
        if (in_valid) begin
            if (is_in_17_32 && flat_idx_load == j)
                B_flat[j] <= {4'd0, in_data};
            if (task_temp && is_in_49_64 && flat_idx_load == j)
                B_flat[j] <= {in_data[3:0], B_flat[j][7:0]};
        end
        if (cs == CALC) begin
            if (is_calc_16_31 && cc_lsb == 2'b11 && ~task_temp && (row_idx == (j/4)))
                B_flat[j] <= mid_b_w[(j%4)]; 
            if (task_temp && is_calc_68_83 && flat_idx_calc_cc == j)
                B_flat[j] <= {4'd0, single_div_quo};
        end
    end
end
endgenerate

wire div_active = (cs == CALC) && task_temp && (is_calc_52_67 || is_calc_68_83);
wire [7:0] single_div_num = div_active ? num_buf[cc_lsb]             : 8'd0;
wire [3:0] single_div_den = div_active ? X_reg[prev_row_idx][cc_lsb] : 4'd1;

DIV_8_BY_4 u_single_div (.num(single_div_num), .den(single_div_den), .quo(single_div_quo));

wire [31:0] A_data_row_cc  = {A_flat[{cc_lsb, 2'b11}][7:0], A_flat[{cc_lsb, 2'b10}][7:0], A_flat[{cc_lsb, 2'b01}][7:0], A_flat[{cc_lsb, 2'b00}][7:0]};
wire [31:0] B_data_row_cc  = {B_flat[{cc_lsb, 2'b11}][7:0], B_flat[{cc_lsb, 2'b10}][7:0], B_flat[{cc_lsb, 2'b01}][7:0], B_flat[{cc_lsb, 2'b00}][7:0]};
wire [15:0] B_tag_row_cc   = {B_flat[{cc_lsb, 2'b11}][11:8], B_flat[{cc_lsb, 2'b10}][11:8], B_flat[{cc_lsb, 2'b01}][11:8], B_flat[{cc_lsb, 2'b00}][11:8]};

wire [31:0] A_data_row_idx = {A_flat[{row_idx, 2'b11}][7:0], A_flat[{row_idx, 2'b10}][7:0], A_flat[{row_idx, 2'b01}][7:0], A_flat[{row_idx, 2'b00}][7:0]};
wire [31:0] B_data_row_idx = {B_flat[{row_idx, 2'b11}][7:0], B_flat[{row_idx, 2'b10}][7:0], B_flat[{row_idx, 2'b01}][7:0], B_flat[{row_idx, 2'b00}][7:0]};

reg  [3:0]  mult_in_A;
reg  [11:0] mult_in_B[0:3];   
reg [3:0]  sum_in_x [0:3];
reg [7:0]  sum_in_y [0:3]; 

always@(*) begin
    sum_in_x[0] = psum_x[0]; sum_in_x[1] = psum_x[1];
    sum_in_x[2] = psum_x[2]; sum_in_x[3] = psum_x[3];

    sum_in_y[0] = psum_y[0]; sum_in_y[1] = psum_y[1];
    sum_in_y[2] = psum_y[2]; sum_in_y[3] = psum_y[3];
end

wire use_A_for_B = (calc_cnt[6:5] == 2'b00) || calc_cnt[6];
wire bypass_A33 = (calc_cnt == 67) && task_temp;
 
reg [7:0] B_data_sel [0:3];
reg [3:0] B_tag_sel  [0:3];

wire sel_b_div = bypass_A33 && (cc_lsb == 2'b11);
wire [7:0] A_cc_31_24 = sel_b_div ? single_div_quo : A_data_row_cc[31:24];

wire use_B_tag = (~task_temp) && (~use_A_for_B);

always @(*) begin
    B_data_sel[0] = use_A_for_B ? A_data_row_cc[7:0]   : B_data_row_cc[7:0];
    B_data_sel[1] = use_A_for_B ? A_data_row_cc[15:8]  : B_data_row_cc[15:8];
    B_data_sel[2] = use_A_for_B ? A_data_row_cc[23:16] : B_data_row_cc[23:16];
    B_data_sel[3] = use_A_for_B ? A_cc_31_24           : B_data_row_cc[31:24];

    B_tag_sel[0]  = use_B_tag ? B_tag_row_cc[3:0]   : 4'd0;
    B_tag_sel[1]  = use_B_tag ? B_tag_row_cc[7:4]   : 4'd0;
    B_tag_sel[2]  = use_B_tag ? B_tag_row_cc[11:8]  : 4'd0;
    B_tag_sel[3]  = use_B_tag ? B_tag_row_cc[15:12] : 4'd0;
end

wire mac_active = (cs == CALC) && (calc_cnt <= 7'd79);

always@(*) begin
    if (mac_active) begin
        mult_in_A = is_stage_3 ? A_flat[{row_idx, cc_lsb}][11:8] : buf_cur;
        mult_in_B[0] = {B_tag_sel[0], B_data_sel[0]};
        mult_in_B[1] = {B_tag_sel[1], B_data_sel[1]};
        mult_in_B[2] = {B_tag_sel[2], B_data_sel[2]};
        mult_in_B[3] = {B_tag_sel[3], B_data_sel[3]};
    end 
    else begin
        mult_in_A    = 4'd0;
        mult_in_B[0] = 12'd0; mult_in_B[1] = 12'd0;
        mult_in_B[2] = 12'd0; mult_in_B[3] = 12'd0;
    end
end

wire mac_x_need = (cs == CALC) && (is_calc_0_15 || is_calc_32_47 || (task_temp && is_stage_3));
wire mac_y_need = (cs == CALC) && (is_calc_16_31 || is_calc_48_63);

MAC u_MAC (
    .x_en(mac_x_need), .y_en(mac_y_need),
    .mult_in_A(mult_in_A), .mult_in_B(mult_in_B), 
    .sum_in_x(sum_in_x), .sum_in_y(sum_in_y),
    .x_out(mac_x_out_w), .y_out(mac_y_out_w)
);

MOD_15_PLUS_1 mod0 (.data_in(mac_x_out_w[0]), .out(mod_15_out[0]));
MOD_15_PLUS_1 mod1 (.data_in(mac_x_out_w[1]), .out(mod_15_out[1]));
MOD_15_PLUS_1 mod2 (.data_in(mac_x_out_w[2]), .out(mod_15_out[2]));
MOD_15_PLUS_1 mod3 (.data_in(mac_x_out_w[3]), .out(mod_15_out[3]));

wire psum_y_use_big = is_calc_16_31 || is_calc_48_63;
wire psum_y_use_mac2 = task_temp && is_stage_3;

wire en_psum = (cs == IDLE) || (cs == CALC); 
wire clk_psum;
GATED_OR GATED_psum (.CLOCK(clk), .SLEEP_CTRL(cg_en && !en_psum), .RST_N(rst_n), .CLOCK_GATED(clk_psum));

always@(posedge clk_psum) begin
    if (cs == IDLE || (cs == CALC && cc_lsb == 2'b11)) begin
        psum_x[0] <= 4'd0; psum_x[1] <= 4'd0; psum_x[2] <= 4'd0; psum_x[3] <= 4'd0;
        psum_y[0] <= 8'd0; psum_y[1] <= 8'd0; psum_y[2] <= 8'd0; psum_y[3] <= 8'd0;
    end 
    else if (cs == CALC) begin
        psum_x[0] <= mac_x_out_w[0]; psum_x[1] <= mac_x_out_w[1];
        psum_x[2] <= mac_x_out_w[2]; psum_x[3] <= mac_x_out_w[3];
        
        if (psum_y_use_big) begin
            psum_y[0] <= mac_y_out_w[0]; psum_y[1] <= mac_y_out_w[1];
            psum_y[2] <= mac_y_out_w[2]; psum_y[3] <= mac_y_out_w[3];
        end
        else if (psum_y_use_mac2) begin
            psum_y[0] <= mac2_out_w[0]; psum_y[1] <= mac2_out_w[1];
            psum_y[2] <= mac2_out_w[2]; psum_y[3] <= mac2_out_w[3];
        end
        else begin
            psum_y[0] <= 8'd0; psum_y[1] <= 8'd0; psum_y[2] <= 8'd0; psum_y[3] <= 8'd0;
        end
    end
end

wire en_Xreg = (cs == CALC && cc_lsb == 2'b11 && ((is_calc_0_15 || is_calc_32_47) || (is_stage_3 && task_temp)));
wire clk_Xreg;
GATED_OR GATED_Xreg (.CLOCK(clk), .SLEEP_CTRL(cg_en && !en_Xreg), .RST_N(rst_n), .CLOCK_GATED(clk_Xreg));

always @(posedge clk_Xreg) begin
    if (cs == CALC) begin
        if ((is_calc_0_15 || is_calc_32_47) && cc_lsb == 2'b11) begin
            X_reg[row_idx][0] <= mod_15_out[0]; X_reg[row_idx][1] <= mod_15_out[1];
            X_reg[row_idx][2] <= mod_15_out[2]; X_reg[row_idx][3] <= mod_15_out[3];
        end
        else if (is_stage_3 && cc_lsb == 2'b11 && task_temp) begin
            X_reg[row_idx][0] <= mod_15_out[0]; X_reg[row_idx][1] <= mod_15_out[1];
            X_reg[row_idx][2] <= mod_15_out[2]; X_reg[row_idx][3] <= mod_15_out[3];
        end
    end
end

reg  [3:0]  mult_in_a_stage3;
reg  [3:0]  mult_in_a [0:3];
reg  [7:0]  mult_in_b [0:3];
wire [11:0] bx1_w [0:3];
reg  [7:0]  xor_in_b [0:3];

wire mult2_active = (cs == CALC) && (is_calc_16_31 || is_calc_48_63 || is_stage_3);

always @(*) begin
    if (mult2_active) begin
        mult_in_a_stage3 = B_flat[{row_idx, cc_lsb}][11:8];
        mult_in_a[0] = is_stage_3 ? mult_in_a_stage3 : X_reg[row_idx][0];
        mult_in_a[1] = is_stage_3 ? mult_in_a_stage3 : X_reg[row_idx][1];
        mult_in_a[2] = is_stage_3 ? mult_in_a_stage3 : X_reg[row_idx][2];
        mult_in_a[3] = is_stage_3 ? mult_in_a_stage3 : X_reg[row_idx][3];
        mult_in_b[0] = is_stage_3 ? A_data_row_cc[7:0]   : is_stage_2 ? A_data_row_idx[7:0]   : B_data_row_idx[7:0];
        mult_in_b[1] = is_stage_3 ? A_data_row_cc[15:8]  : is_stage_2 ? A_data_row_idx[15:8]  : B_data_row_idx[15:8];
        mult_in_b[2] = is_stage_3 ? A_data_row_cc[23:16] : is_stage_2 ? A_data_row_idx[23:16] : B_data_row_idx[23:16];
        mult_in_b[3] = is_stage_3 ? (bypass_A33 ? single_div_quo : A_data_row_cc[31:24]) : is_stage_2 ? A_data_row_idx[31:24] : B_data_row_idx[31:24];
    end 
    else begin
        mult_in_a_stage3 = 4'd0;
        mult_in_a[0] = 4'd0; mult_in_a[1] = 4'd0;
        mult_in_a[2] = 4'd0; mult_in_a[3] = 4'd0;
        mult_in_b[0] = 8'd0; mult_in_b[1] = 8'd0;
        mult_in_b[2] = 8'd0; mult_in_b[3] = 8'd0;
    end
end

always @(*) begin
    if (mult2_active) begin
        xor_in_b[0] = is_stage_3 ? mac2_out_w[0] : mac_y_out_w[0];
        xor_in_b[1] = is_stage_3 ? mac2_out_w[1] : mac_y_out_w[1];
        xor_in_b[2] = is_stage_3 ? mac2_out_w[2] : mac_y_out_w[2];
        xor_in_b[3] = is_stage_3 ? mac2_out_w[3] : mac_y_out_w[3];
    end 
    else begin
        xor_in_b[0] = 8'd0; xor_in_b[1] = 8'd0;
        xor_in_b[2] = 8'd0; xor_in_b[3] = 8'd0;
    end
end

MULT_4X8 u_mult_0 (.in_a(mult_in_a[0]), .in_b(mult_in_b[0]), .out(bx1_w[0]));
MULT_4X8 u_mult_1 (.in_a(mult_in_a[1]), .in_b(mult_in_b[1]), .out(bx1_w[1]));
MULT_4X8 u_mult_2 (.in_a(mult_in_a[2]), .in_b(mult_in_b[2]), .out(bx1_w[2]));
MULT_4X8 u_mult_3 (.in_a(mult_in_a[3]), .in_b(mult_in_b[3]), .out(bx1_w[3]));
 
assign mac2_out_w[0] = bx1_w[0][7:0] + sum_in_y[0];
assign mac2_out_w[1] = bx1_w[1][7:0] + sum_in_y[1];
assign mac2_out_w[2] = bx1_w[2][7:0] + sum_in_y[2];
assign mac2_out_w[3] = bx1_w[3][7:0] + sum_in_y[3];
 
wire bypass_en = task_temp && is_div_stage;
wire bypass_is_B = is_stage_3;
 
wire [7:0] bypass_data_0 = bypass_is_B ? B_data_row_idx[7:0]   : A_data_row_idx[7:0];
wire [7:0] bypass_data_1 = bypass_is_B ? B_data_row_idx[15:8]  : A_data_row_idx[15:8];
wire [7:0] bypass_data_2 = bypass_is_B ? B_data_row_idx[23:16] : A_data_row_idx[23:16];
wire [7:0] bypass_data_3 = bypass_is_B ? B_data_row_idx[31:24] : A_data_row_idx[31:24];
 
wire [11:0] xor_in_a [0:3];
assign xor_in_a[0] = bypass_en ? {4'd0, bypass_data_0} : bx1_w[0];
assign xor_in_a[1] = bypass_en ? {4'd0, bypass_data_1} : bx1_w[1];
assign xor_in_a[2] = bypass_en ? {4'd0, bypass_data_2} : bx1_w[2];
assign xor_in_a[3] = bypass_en ? {4'd0, bypass_data_3} : bx1_w[3];

XOR_12X8 u_xor_0 (.in_a(xor_in_a[0]), .in_b(xor_in_b[0]), .out(mid_b_w[0]));
XOR_12X8 u_xor_1 (.in_a(xor_in_a[1]), .in_b(xor_in_b[1]), .out(mid_b_w[1]));
XOR_12X8 u_xor_2 (.in_a(xor_in_a[2]), .in_b(xor_in_b[2]), .out(mid_b_w[2]));
XOR_12X8 u_xor_3 (.in_a(xor_in_a[3]), .in_b(xor_in_b[3]), .out(mid_b_w[3]));
 
wire is_calc_63    = (~calc_cnt[6]) & (&calc_cnt[5:0]);
wire is_calc_64_94 = calc_cnt[6] & ~calc_cnt[5] & ~(&calc_cnt[4:0]);
wire is_out_window = is_calc_63 | is_calc_64_94;
 
wire [4:0] out_idx = calc_cnt[4:0] + 5'd1;
wire out_is_A = ~out_idx[4]; 
wire [3:0] flat_out_idx = out_idx[3:0]; 

wire [11:0] out_arr_val = is_out_window ? (out_is_A ? A_flat[flat_out_idx] : B_flat[flat_out_idx]) : 12'd0;

always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        out_valid <= 0;
        out_data <= 0;
    end
    else if(cs == CALC && is_out_window) begin
        out_valid <= 1;
        out_data <= task_temp ? {4'd0, out_arr_val[7:0]} : out_arr_val;
    end
    else begin
        out_valid <= 0;
        out_data <= 0;
    end
end

endmodule

module MAC(
    input         x_en,
    input         y_en,
    input  [3:0]  mult_in_A,
    input  [11:0] mult_in_B[0:3],
    input  [3:0]  sum_in_x[0:3],
    input  [7:0]  sum_in_y[0:3],
    output [3:0]  x_out[0:3],
    output [7:0]  y_out[0:3]
);

    wire [3:0] mult_A_x = x_en ? mult_in_A : 4'd0;

    wire a_is_15 = &mult_A_x;
    wire [3:0] a_mod15 = {4{~a_is_15}} & mult_A_x;
    wire [4:0] a2_tmp = {a_mod15, 1'b0};
    wire [3:0] a2_mod15 = a2_tmp[3:0] + {3'd0, (a2_tmp >= 5'd15)};
    wire [4:0] a4_tmp = {a2_mod15, 1'b0};
    wire [3:0] a4_mod15 = a4_tmp[3:0] + {3'd0, (a4_tmp >= 5'd15)};
    wire [4:0] a8_tmp = {a4_mod15, 1'b0};
    wire [3:0] a8_mod15 = a8_tmp[3:0] + {3'd0, (a8_tmp >= 5'd15)};

    wire [3:0] mult_A_y = y_en ? mult_in_A : 4'd0;

    genvar i;
    generate
    for (i = 0; i < 4; i = i + 1) begin : g
        
        wire [11:0] mult_B_x = x_en ? mult_in_B[i] : 12'd0;
        wire [3:0]  sum_x_g  = x_en ? sum_in_x[i] : 4'd0;

        wire [5:0] b_sum;
        wire [3:0] b_mod15;

        assign b_sum = {2'b0, mult_B_x[11:8]} + {2'b0, mult_B_x[7:4]}  + {2'b0, mult_B_x[3:0]};

        wire sub_30 = (b_sum >= 6'd30);
        wire sub_15 = (b_sum >= 6'd15) & ~sub_30;
        assign b_mod15 = b_sum[3:0] + {2'd0, sub_30, sub_15};

        wire [3:0] pp0_mod15 = {4{b_mod15[0]}} & a_mod15;
        wire [3:0] pp1_mod15 = {4{b_mod15[1]}} & a2_mod15;
        wire [3:0] pp2_mod15 = {4{b_mod15[2]}} & a4_mod15;
        wire [3:0] pp3_mod15 = {4{b_mod15[3]}} & a8_mod15;

        wire [4:0] s01_tmp = pp0_mod15 + pp1_mod15;
        wire [3:0] s01_mod15 = s01_tmp[3:0] + {3'd0, (s01_tmp >= 5'd15)};

        wire [4:0] s23_tmp = pp2_mod15 + pp3_mod15;
        wire [3:0] s23_mod15 = s23_tmp[3:0] + {3'd0, (s23_tmp >= 5'd15)};

        wire [4:0] prod_tmp = s01_mod15 + s23_mod15;
        wire [3:0] prod_mod15 = prod_tmp[3:0] + {3'd0, (prod_tmp >= 5'd15)};

        wire [4:0] add5 = prod_mod15 + sum_x_g;
        assign x_out[i] = add5[3:0] + {3'd0, (add5 >= 5'd15)};

        wire [7:0] mult_B_y = y_en ? mult_in_B[i][7:0] : 8'd0;
        wire [7:0] sum_y_g  = y_en ? sum_in_y[i] : 8'd0;
        wire [11:0] full_y_prod = mult_A_y * mult_B_y;

        assign y_out[i] = full_y_prod[7:0] + sum_y_g;
        
    end
    endgenerate
endmodule

module MOD_15_PLUS_1 (input [3:0] data_in, output [3:0] out);
    assign out = data_in + 4'd1;
endmodule
 
module MULT_4X8(input [3:0] in_a, input [7:0] in_b, output [11:0] out);
    assign out = in_a * in_b;
endmodule
 
module XOR_12X8(input [11:0] in_a, input [7:0] in_b, output [11:0] out);
    assign out = in_a ^ {4'b0, in_b};
endmodule
 
module DIV_8_BY_4 (input [7:0] num, input [3:0] den, output reg [7:0] quo);
    reg [4:0] rem; reg [4:0] d5; integer i;
    always @(*) begin
        rem = 5'd0; quo = 8'd0; d5 = {1'b0, den};
        for (i = 0; i < 8; i = i + 1) begin
            rem = {rem[3:0], num[7-i]};
            if (rem >= d5) begin
                rem = rem - d5; quo[7-i] = 1'b1;
            end else begin
                quo[7-i] = 1'b0;
            end
        end
    end
endmodule

// 115205.127366 2.908e-03