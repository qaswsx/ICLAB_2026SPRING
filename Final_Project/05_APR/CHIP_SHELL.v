module CHIP(
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

    // awid_m_inf_inst_1,
    // awaddr_m_inf_inst_1,
    // awsize_m_inf_inst_1,
    // awburst_m_inf_inst_1,
    // awlen_m_inf_inst_1,
    // awvalid_m_inf_inst_1,
    // awready_m_inf_inst_1,
                
    // wdata_m_inf_inst_1,
    // wlast_m_inf_inst_1,
    // wvalid_m_inf_inst_1,
    // wready_m_inf_inst_1,

    // bid_m_inf_inst_1,
    // bresp_m_inf_inst_1,
    // bvalid_m_inf_inst_1,
    // bready_m_inf_inst_1,
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

    // awid_m_inf_inst_2,
    // awaddr_m_inf_inst_2,
    // awsize_m_inf_inst_2,
    // awburst_m_inf_inst_2,
    // awlen_m_inf_inst_2,
    // awvalid_m_inf_inst_2,
    // awready_m_inf_inst_2,
                
    // wdata_m_inf_inst_2,
    // wlast_m_inf_inst_2,
    // wvalid_m_inf_inst_2,
    // wready_m_inf_inst_2,

    // bid_m_inf_inst_2,
    // bresp_m_inf_inst_2,
    // bvalid_m_inf_inst_2,
    // bready_m_inf_inst_2,  
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
output reg  stall_1, stall_2;

parameter ID_WIDTH=4, ADDR_WIDTH=32, DATA_WIDTH=16, BURST_LEN=7;

// AXI Interface wire connecttion for pseudo-DRAM read/write

//########################################### Instruction1 DRAM
// // axi write addr channel 
// // src master
// output wire [ID_WIDTH-1:0]   awid_m_inf_inst_1; 
// output wire [ADDR_WIDTH-1:0] awaddr_m_inf_inst_1;
// output wire [2:0]            awsize_m_inf_inst_1; 
// output wire [1:0]            awburst_m_inf_inst_1; 
// output wire [BURST_LEN-1:0]  awlen_m_inf_inst_1;
// output wire                  awvalid_m_inf_inst_1;
// // src slave
// input wire                   awready_m_inf_inst_1;
// // -------------------------

// // axi write data channel 
// // src master
// output wire [DATA_WIDTH-1:0] wdata_m_inf_inst_1;
// output wire                  wlast_m_inf_inst_1;
// output wire                  wvalid_m_inf_inst_1;
// // src slave
// input wire                   wready_m_inf_inst_1;

// // axi write resp channel 
// // src slave
// input wire  [ID_WIDTH-1:0] bid_m_inf_inst_1; 
// input wire  [1:0]          bresp_m_inf_inst_1; 
// input wire                 bvalid_m_inf_inst_1;
// // src master 
// output wire                bready_m_inf_inst_1;
// // ------------------------

// axi read addr channel 
// src master
output wire [ID_WIDTH-1:0]   arid_m_inf_inst_1; 
output wire [ADDR_WIDTH-1:0] araddr_m_inf_inst_1;
output wire [BURST_LEN-1:0]  arlen_m_inf_inst_1;
output wire [2:0]            arsize_m_inf_inst_1; 
output wire [1:0]            arburst_m_inf_inst_1; 
output wire                  arvalid_m_inf_inst_1;
// src slave
input wire                   arready_m_inf_inst_1;
// ------------------------

// axi read data channel 
// slave
input wire [ID_WIDTH-1:0]   rid_m_inf_inst_1; 
input wire [DATA_WIDTH-1:0] rdata_m_inf_inst_1;
input wire [1:0]            rresp_m_inf_inst_1; 
input wire                  rlast_m_inf_inst_1;
input wire                  rvalid_m_inf_inst_1;
// master
output wire                 rready_m_inf_inst_1;
// -----------------------------

//########################################### Instruction2 DRAM
// // axi write addr channel 
// // src master
// output wire [ID_WIDTH-1:0]   awid_m_inf_inst_2; 
// output wire [ADDR_WIDTH-1:0] awaddr_m_inf_inst_2;
// output wire [2:0]            awsize_m_inf_inst_2; 
// output wire [1:0]            awburst_m_inf_inst_2; 
// output wire [BURST_LEN-1:0]  awlen_m_inf_inst_2;
// output wire                  awvalid_m_inf_inst_2;
// // src slave
// input wire                   awready_m_inf_inst_2;
// // -------------------------

// // axi write data channel 
// // src master
// output wire [DATA_WIDTH-1:0] wdata_m_inf_inst_2;
// output wire                  wlast_m_inf_inst_2;
// output wire                  wvalid_m_inf_inst_2;
// // src slave
// input wire                   wready_m_inf_inst_2;

// // axi write resp channel 
// // src slave
// input wire  [ID_WIDTH-1:0] bid_m_inf_inst_2; 
// input wire  [1:0]          bresp_m_inf_inst_2; 
// input wire                 bvalid_m_inf_inst_2;
// // src master 
// output wire                bready_m_inf_inst_2;
// // ------------------------

// axi read addr channel 
// src master
output wire [ID_WIDTH-1:0]   arid_m_inf_inst_2; 
output wire [ADDR_WIDTH-1:0] araddr_m_inf_inst_2;
output wire [BURST_LEN-1:0]  arlen_m_inf_inst_2;
output wire [2:0]            arsize_m_inf_inst_2; 
output wire [1:0]            arburst_m_inf_inst_2; 
output wire                  arvalid_m_inf_inst_2;
// src slave
input wire                   arready_m_inf_inst_2;
// ------------------------

// axi read data channel 
// slave
input wire [ID_WIDTH-1:0]   rid_m_inf_inst_2; 
input wire [DATA_WIDTH-1:0] rdata_m_inf_inst_2;
input wire [1:0]            rresp_m_inf_inst_2; 
input wire                  rlast_m_inf_inst_2;
input wire                  rvalid_m_inf_inst_2;
// master
output wire                 rready_m_inf_inst_2;
// -----------------------------

//########################################### Data DRAM 
// axi write addr channel 
// src master
output wire [ID_WIDTH-1:0]   awid_m_inf_data; 
output wire [ADDR_WIDTH-1:0] awaddr_m_inf_data;
output wire [2:0]            awsize_m_inf_data; 
output wire [1:0]            awburst_m_inf_data; 
output wire [BURST_LEN-1:0]  awlen_m_inf_data;
output wire                  awvalid_m_inf_data;
// src slave
input wire                   awready_m_inf_data;
// -------------------------

// axi write data channel 
// src master
output wire [DATA_WIDTH-1:0] wdata_m_inf_data;
output wire                  wlast_m_inf_data;
output wire                  wvalid_m_inf_data;
// src slave
input wire                   wready_m_inf_data;

// axi write resp channel 
// src slave
input wire  [ID_WIDTH-1:0] bid_m_inf_data; 
input wire  [1:0]          bresp_m_inf_data; 
input wire                 bvalid_m_inf_data;
// src master 
output wire                bready_m_inf_data;
// ------------------------

// axi read addr channel 
// src master
output wire [ID_WIDTH-1:0]   arid_m_inf_data; 
output wire [ADDR_WIDTH-1:0] araddr_m_inf_data;
output wire [BURST_LEN-1:0]  arlen_m_inf_data;
output wire [2:0]            arsize_m_inf_data; 
output wire [1:0]            arburst_m_inf_data; 
output wire                  arvalid_m_inf_data;
// src slave
input wire                   arready_m_inf_data;
// ------------------------

// axi read data channel 
// slave
input wire [ID_WIDTH-1:0]   rid_m_inf_data; 
input wire [DATA_WIDTH-1:0] rdata_m_inf_data;
input wire [1:0]            rresp_m_inf_data; 
input wire                  rlast_m_inf_data;
input wire                  rvalid_m_inf_data;
// master
output wire                 rready_m_inf_data;
// -----------------------------

//==================================================================
// reg & wire
//==================================================================
wire             C_clk;
wire             C_rst_n;
wire             C_stall_1;
wire             C_stall_2;

//########################################### Instruction1 DRAM
// // axi write addr channel 
// // src master
// wire [ID_WIDTH-1:0]   C_awid_m_inf_inst_1; 
// wire [ADDR_WIDTH-1:0] C_awaddr_m_inf_inst_1;
// wire [2:0]            C_awsize_m_inf_inst_1; 
// wire [1:0]            C_awburst_m_inf_inst_1; 
// wire [BURST_LEN-1:0]  C_awlen_m_inf_inst_1;
// wire                  C_awvalid_m_inf_inst_1;
// // src slave
// wire                  C_awready_m_inf_inst_1;
// // -------------------------

// // axi write data channel 
// // src master
// wire [DATA_WIDTH-1:0] C_wdata_m_inf_inst_1;
// wire                  C_wlast_m_inf_inst_1;
// wire                  C_wvalid_m_inf_inst_1;
// // src slave
// wire                  C_wready_m_inf_inst_1;

// // axi write resp channel 
// // src slave
// wire  [ID_WIDTH-1:0] C_bid_m_inf_inst_1; 
// wire  [1:0]          C_bresp_m_inf_inst_1; 
// wire                 C_bvalid_m_inf_inst_1;
// // src master 
// wire                 C_bready_m_inf_inst_1;
// // ------------------------

// axi read addr channel 
// src master
wire [ID_WIDTH-1:0]   C_arid_m_inf_inst_1; 
wire [ADDR_WIDTH-1:0] C_araddr_m_inf_inst_1;
wire [BURST_LEN-1:0]  C_arlen_m_inf_inst_1;
wire [2:0]            C_arsize_m_inf_inst_1; 
wire [1:0]            C_arburst_m_inf_inst_1; 
wire                  C_arvalid_m_inf_inst_1;
// src slave
wire                  C_arready_m_inf_inst_1;
// ------------------------

// axi read data channel 
// slave
wire [ID_WIDTH-1:0]   C_rid_m_inf_inst_1; 
wire [DATA_WIDTH-1:0] C_rdata_m_inf_inst_1;
wire [1:0]            C_rresp_m_inf_inst_1; 
wire                  C_rlast_m_inf_inst_1;
wire                  C_rvalid_m_inf_inst_1;
// master
wire                  C_rready_m_inf_inst_1;
// -----------------------------

//########################################### Instruction2 DRAM
// // axi write addr channel 
// // src master
// wire [ID_WIDTH-1:0]   C_awid_m_inf_inst_2; 
// wire [ADDR_WIDTH-1:0] C_awaddr_m_inf_inst_2;
// wire [2:0]            C_awsize_m_inf_inst_2; 
// wire [1:0]            C_awburst_m_inf_inst_2; 
// wire [BURST_LEN-1:0]  C_awlen_m_inf_inst_2;
// wire                  C_awvalid_m_inf_inst_2;
// // src slave
// wire                  C_awready_m_inf_inst_2;
// // -------------------------

// // axi write data channel 
// // src master
// wire [DATA_WIDTH-1:0] C_wdata_m_inf_inst_2;
// wire                  C_wlast_m_inf_inst_2;
// wire                  C_wvalid_m_inf_inst_2;
// // src slave
// wire                  C_wready_m_inf_inst_2;

// // axi write resp channel 
// // src slave
// wire  [ID_WIDTH-1:0] C_bid_m_inf_inst_2; 
// wire  [1:0]          C_bresp_m_inf_inst_2; 
// wire                 C_bvalid_m_inf_inst_2;
// // src master 
// wire                 C_bready_m_inf_inst_2;
// // ------------------------

// axi read addr channel 
// src master
wire [ID_WIDTH-1:0]   C_arid_m_inf_inst_2; 
wire [ADDR_WIDTH-1:0] C_araddr_m_inf_inst_2;
wire [BURST_LEN-1:0]  C_arlen_m_inf_inst_2;
wire [2:0]            C_arsize_m_inf_inst_2; 
wire [1:0]            C_arburst_m_inf_inst_2; 
wire                  C_arvalid_m_inf_inst_2;
// src slave
wire                  C_arready_m_inf_inst_2;
// ------------------------

// axi read data channel 
// slave
wire [ID_WIDTH-1:0]   C_rid_m_inf_inst_2; 
wire [DATA_WIDTH-1:0] C_rdata_m_inf_inst_2;
wire [1:0]            C_rresp_m_inf_inst_2; 
wire                  C_rlast_m_inf_inst_2;
wire                  C_rvalid_m_inf_inst_2;
// master
wire                  C_rready_m_inf_inst_2;
// -----------------------------

//########################################### Data DRAM 
// axi write addr channel 
// src master
wire [ID_WIDTH-1:0]   C_awid_m_inf_data; 
wire [ADDR_WIDTH-1:0] C_awaddr_m_inf_data;
wire [2:0]            C_awsize_m_inf_data; 
wire [1:0]            C_awburst_m_inf_data; 
wire [BURST_LEN-1:0]  C_awlen_m_inf_data;
wire                  C_awvalid_m_inf_data;
// src slave
wire                  C_awready_m_inf_data;
// -------------------------

// axi write data channel 
// src master
wire [DATA_WIDTH-1:0] C_wdata_m_inf_data;
wire                  C_wlast_m_inf_data;
wire                  C_wvalid_m_inf_data;
// src slave
wire                  C_wready_m_inf_data;

// axi write resp channel 
// src slave
wire  [ID_WIDTH-1:0] C_bid_m_inf_data; 
wire  [1:0]          C_bresp_m_inf_data; 
wire                 C_bvalid_m_inf_data;
// src master 
wire                 C_bready_m_inf_data;
// ------------------------

// axi read addr channel 
// src master
wire [ID_WIDTH-1:0]   C_arid_m_inf_data; 
wire [ADDR_WIDTH-1:0] C_araddr_m_inf_data;
wire [BURST_LEN-1:0]  C_arlen_m_inf_data;
wire [2:0]            C_arsize_m_inf_data; 
wire [1:0]            C_arburst_m_inf_data; 
wire                  C_arvalid_m_inf_data;
// src slave
wire                  C_arready_m_inf_data;
// ------------------------

// axi read data channel 
// slave
wire [ID_WIDTH-1:0]   C_rid_m_inf_data; 
wire [DATA_WIDTH-1:0] C_rdata_m_inf_data;
wire [1:0]            C_rresp_m_inf_data; 
wire                  C_rlast_m_inf_data;
wire                  C_rvalid_m_inf_data;
// master
wire                  C_rready_m_inf_data;
// -----------------------------

//==================================================================
// CORE
//==================================================================
DCCPU_SYN CORE(
// Input
    .clk(C_clk),
    .rst_n(C_rst_n),
// Output
    .stall_1(C_stall_1),
    .stall_2(C_stall_2),
//===== AXI-4 Instruction1 DRAM =====
    .arid_m_inf_inst_1(C_arid_m_inf_inst_1),
    .araddr_m_inf_inst_1(C_araddr_m_inf_inst_1),
    .arlen_m_inf_inst_1(C_arlen_m_inf_inst_1),
    .arsize_m_inf_inst_1(C_arsize_m_inf_inst_1),
    .arburst_m_inf_inst_1(C_arburst_m_inf_inst_1),
    .arvalid_m_inf_inst_1(C_arvalid_m_inf_inst_1),
    .arready_m_inf_inst_1(C_arready_m_inf_inst_1),

    .rid_m_inf_inst_1(C_rid_m_inf_inst_1),
    .rdata_m_inf_inst_1(C_rdata_m_inf_inst_1),
    .rresp_m_inf_inst_1(C_rresp_m_inf_inst_1),
    .rlast_m_inf_inst_1(C_rlast_m_inf_inst_1),
    .rvalid_m_inf_inst_1(C_rvalid_m_inf_inst_1),
    .rready_m_inf_inst_1(C_rready_m_inf_inst_1),

    // .awid_m_inf_inst_1(C_awid_m_inf_inst_1),
    // .awaddr_m_inf_inst_1(C_awaddr_m_inf_inst_1),
    // .awsize_m_inf_inst_1(C_awsize_m_inf_inst_1),
    // .awburst_m_inf_inst_1(C_awburst_m_inf_inst_1),
    // .awlen_m_inf_inst_1(C_awlen_m_inf_inst_1),
    // .awvalid_m_inf_inst_1(C_awvalid_m_inf_inst_1),
    // .awready_m_inf_inst_1(C_awready_m_inf_inst_1),
                
    // .wdata_m_inf_inst_1(C_wdata_m_inf_inst_1),
    // .wlast_m_inf_inst_1(C_wlast_m_inf_inst_1),
    // .wvalid_m_inf_inst_1(C_wvalid_m_inf_inst_1),
    // .wready_m_inf_inst_1(C_wready_m_inf_inst_1),

    // .bid_m_inf_inst_1(C_bid_m_inf_inst_1),
    // .bresp_m_inf_inst_1(C_bresp_m_inf_inst_1),
    // .bvalid_m_inf_inst_1(C_bvalid_m_inf_inst_1),
    // .bready_m_inf_inst_1(C_bready_m_inf_inst_1),
//===== AXI-4 Instruction2 DRAM =====
    .arid_m_inf_inst_2(C_arid_m_inf_inst_2),
    .araddr_m_inf_inst_2(C_araddr_m_inf_inst_2),
    .arlen_m_inf_inst_2(C_arlen_m_inf_inst_2),
    .arsize_m_inf_inst_2(C_arsize_m_inf_inst_2),
    .arburst_m_inf_inst_2(C_arburst_m_inf_inst_2),
    .arvalid_m_inf_inst_2(C_arvalid_m_inf_inst_2),
    .arready_m_inf_inst_2(C_arready_m_inf_inst_2),

    .rid_m_inf_inst_2(C_rid_m_inf_inst_2),
    .rdata_m_inf_inst_2(C_rdata_m_inf_inst_2),
    .rresp_m_inf_inst_2(C_rresp_m_inf_inst_2),
    .rlast_m_inf_inst_2(C_rlast_m_inf_inst_2),
    .rvalid_m_inf_inst_2(C_rvalid_m_inf_inst_2),
    .rready_m_inf_inst_2(C_rready_m_inf_inst_2),

    // .awid_m_inf_inst_2(C_awid_m_inf_inst_2),
    // .awaddr_m_inf_inst_2(C_awaddr_m_inf_inst_2),
    // .awsize_m_inf_inst_2(C_awsize_m_inf_inst_2),
    // .awburst_m_inf_inst_2(C_awburst_m_inf_inst_2),
    // .awlen_m_inf_inst_2(C_awlen_m_inf_inst_2),
    // .awvalid_m_inf_inst_2(C_awvalid_m_inf_inst_2),
    // .awready_m_inf_inst_2(C_awready_m_inf_inst_2),
                
    // .wdata_m_inf_inst_2(C_wdata_m_inf_inst_2),
    // .wlast_m_inf_inst_2(C_wlast_m_inf_inst_2),
    // .wvalid_m_inf_inst_2(C_wvalid_m_inf_inst_2),
    // .wready_m_inf_inst_2(C_wready_m_inf_inst_2),

    // .bid_m_inf_inst_2(C_bid_m_inf_inst_2),
    // .bresp_m_inf_inst_2(C_bresp_m_inf_inst_2),
    // .bvalid_m_inf_inst_2(C_bvalid_m_inf_inst_2),
    // .bready_m_inf_inst_2(C_bready_m_inf_inst_2),  
//===== AXI-4 Data DRAM =====
    .arid_m_inf_data(C_arid_m_inf_data),
    .araddr_m_inf_data(C_araddr_m_inf_data),
    .arlen_m_inf_data(C_arlen_m_inf_data),
    .arsize_m_inf_data(C_arsize_m_inf_data),
    .arburst_m_inf_data(C_arburst_m_inf_data),
    .arvalid_m_inf_data(C_arvalid_m_inf_data),
    .arready_m_inf_data(C_arready_m_inf_data),

    .rid_m_inf_data(C_rid_m_inf_data),
    .rdata_m_inf_data(C_rdata_m_inf_data),
    .rresp_m_inf_data(C_rresp_m_inf_data),
    .rlast_m_inf_data(C_rlast_m_inf_data),
    .rvalid_m_inf_data(C_rvalid_m_inf_data),
    .rready_m_inf_data(C_rready_m_inf_data),

    .awid_m_inf_data(C_awid_m_inf_data),
    .awaddr_m_inf_data(C_awaddr_m_inf_data),
    .awsize_m_inf_data(C_awsize_m_inf_data),
    .awburst_m_inf_data(C_awburst_m_inf_data),
    .awlen_m_inf_data(C_awlen_m_inf_data),
    .awvalid_m_inf_data(C_awvalid_m_inf_data),
    .awready_m_inf_data(C_awready_m_inf_data),
                
    .wdata_m_inf_data(C_wdata_m_inf_data),
    .wlast_m_inf_data(C_wlast_m_inf_data),
    .wvalid_m_inf_data(C_wvalid_m_inf_data),
    .wready_m_inf_data(C_wready_m_inf_data),

    .bid_m_inf_data(C_bid_m_inf_data),
    .bresp_m_inf_data(C_bresp_m_inf_data),
    .bvalid_m_inf_data(C_bvalid_m_inf_data),
    .bready_m_inf_data(C_bready_m_inf_data)  
);

//==================================================================
// INPUT PAD
// Syntax: XMD PAD_NAME ( .O(CORE_PORT_NAME), .I(CHIP_PORT_NAME), .PU(1'b0), .PD(1'b0), .SMT(1'b0));
//     Ex: XMD    I_CLK ( .O(C_clk),          .I(clk),            .PU(1'b0), .PD(1'b0), .SMT(1'b0));
//==================================================================
// You need to finish this part

//==================================================================
// OUTPUT PAD
// Syntax: YA2GSD PAD_NAME (.I(CORE_PIN_NAME), .O(PAD_PIN_NAME), .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
//     Ex: YA2GSD  O_VALID (.I(C_out_valid),   .O(out_valid),    .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
//==================================================================
// You need to finish this part

//==================================================================
// I/O power 3.3V pads x? (DVDD + DGND)
// Syntax: VCC3IOD/GNDIOD PAD_NAME ();
//    Ex1: VCC3IOD        VDDP0 ();
//    Ex2: GNDIOD         GNDP0 ();
//==================================================================
// You need to finish this part

//==================================================================
// Core power 1.8V pads x? (VDD + GND)
// Syntax: VCCKD/GNDKD PAD_NAME ();
//    Ex1: VCCKD       VDDC0 ();
//    Ex2: GNDKD       GNDC0 ();
//==================================================================
// You need to finish this part
endmodule

