// ##############################################################
//   You can modify by your own
// ##############################################################

module CHIP(
    clk,
    rst_n,
    i_valid,
    i_iter,
    i_mode,
    i_data,
    i_weight,
    o_valid,
    o_data
);

input       clk, rst_n, i_valid;
input [7:0] i_data;
input [2:0] i_iter;
input [1:0] i_mode;
input [3:0] i_weight;
output      o_valid;
output [7:0] o_data;

//==================================================================
// reg & wire
//==================================================================
wire        C_clk, C_rst_n, C_i_valid;
wire [7:0]  C_i_data;
wire [2:0]  C_i_iter;
wire [1:0]  C_i_mode;
wire [3:0]  C_i_weight;

wire        C_o_valid;
wire [7:0]  C_o_data;

//==================================================================
// CORE
//==================================================================
DM CORE(
    .clk     (C_clk),
    .rst_n   (C_rst_n),
    .i_valid (C_i_valid),
    .i_iter  (C_i_iter),
    .i_mode  (C_i_mode),
    .i_data  (C_i_data),
    .i_weight(C_i_weight),

    .o_valid (C_o_valid),
    .o_data  (C_o_data)
);

//==================================================================
// INPUT PAD
// XMD PAD_NAME ( .O(CORE_PORT_NAME), .I(CHIP_PORT_NAME),
//                .PU(1'b0), .PD(1'b0), .SMT(1'b0));
//==================================================================
XMD I_CLK      ( .O(C_clk),         .I(clk),         .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD I_RST_N    ( .O(C_rst_n),       .I(rst_n),       .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD I_VALID    ( .O(C_i_valid),     .I(i_valid),     .PU(1'b0), .PD(1'b0), .SMT(1'b0));

XMD I_ITER_0   ( .O(C_i_iter[0]),   .I(i_iter[0]),   .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD I_ITER_1   ( .O(C_i_iter[1]),   .I(i_iter[1]),   .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD I_ITER_2   ( .O(C_i_iter[2]),   .I(i_iter[2]),   .PU(1'b0), .PD(1'b0), .SMT(1'b0));

XMD I_MODE_0   ( .O(C_i_mode[0]),   .I(i_mode[0]),   .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD I_MODE_1   ( .O(C_i_mode[1]),   .I(i_mode[1]),   .PU(1'b0), .PD(1'b0), .SMT(1'b0));

XMD I_DATA_0   ( .O(C_i_data[0]),   .I(i_data[0]),   .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD I_DATA_1   ( .O(C_i_data[1]),   .I(i_data[1]),   .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD I_DATA_2   ( .O(C_i_data[2]),   .I(i_data[2]),   .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD I_DATA_3   ( .O(C_i_data[3]),   .I(i_data[3]),   .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD I_DATA_4   ( .O(C_i_data[4]),   .I(i_data[4]),   .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD I_DATA_5   ( .O(C_i_data[5]),   .I(i_data[5]),   .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD I_DATA_6   ( .O(C_i_data[6]),   .I(i_data[6]),   .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD I_DATA_7   ( .O(C_i_data[7]),   .I(i_data[7]),   .PU(1'b0), .PD(1'b0), .SMT(1'b0));

XMD I_WEIGHT_0 ( .O(C_i_weight[0]), .I(i_weight[0]), .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD I_WEIGHT_1 ( .O(C_i_weight[1]), .I(i_weight[1]), .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD I_WEIGHT_2 ( .O(C_i_weight[2]), .I(i_weight[2]), .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD I_WEIGHT_3 ( .O(C_i_weight[3]), .I(i_weight[3]), .PU(1'b0), .PD(1'b0), .SMT(1'b0));

//==================================================================
// OUTPUT PAD
// YA2GSD PAD_NAME (.I(CORE_PIN_NAME), .O(PAD_PIN_NAME),
//                  .E(1'b1), .E2(1'b1), .E4(1'b1),
//                  .E8(1'b0), .SR(1'b0));
//==================================================================
YA2GSD O_VALID  ( .I(C_o_valid),   .O(o_valid),   .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));

YA2GSD O_DATA_0 ( .I(C_o_data[0]), .O(o_data[0]), .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_DATA_1 ( .I(C_o_data[1]), .O(o_data[1]), .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_DATA_2 ( .I(C_o_data[2]), .O(o_data[2]), .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_DATA_3 ( .I(C_o_data[3]), .O(o_data[3]), .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_DATA_4 ( .I(C_o_data[4]), .O(o_data[4]), .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_DATA_5 ( .I(C_o_data[5]), .O(o_data[5]), .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_DATA_6 ( .I(C_o_data[6]), .O(o_data[6]), .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_DATA_7 ( .I(C_o_data[7]), .O(o_data[7]), .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));

//==================================================================
// I/O power 3.3V pads
// VCC3IOD / GNDIOD
//==================================================================
VCC3IOD VDDP0 ();
GNDIOD  GNDP0 ();

VCC3IOD VDDP1 ();
GNDIOD  GNDP1 ();

VCC3IOD VDDP2 ();
GNDIOD  GNDP2 ();

VCC3IOD VDDP3 ();
GNDIOD  GNDP3 ();

//==================================================================
// Core power 1.8V pads
// VCCKD / GNDKD
//==================================================================
VCCKD VDDC0 ();
GNDKD GNDC0 ();

VCCKD VDDC1 ();
GNDKD GNDC1 ();

VCCKD VDDC2 ();
GNDKD GNDC2 ();

VCCKD VDDC3 ();
GNDKD GNDC3 ();

VCCKD VDDC4 ();
GNDKD GNDC4 ();

VCCKD VDDC5 ();
GNDKD GNDC5 ();

VCCKD VDDC6 ();
GNDKD GNDC6 ();

VCCKD VDDC7 ();
GNDKD GNDC7 ();

endmodule