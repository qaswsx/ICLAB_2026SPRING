











module ISP (
    input         clk,
    input         rst_n,

    input         in_data_valid,
    input  [11:0] in_data,

    input         cmd_valid,
    input  [5:0]  cmd,

    output reg        out_valid,
    output reg [7:0]  r_out,
    output reg [7:0]  g_out,
    output reg [7:0]  b_out
);

//==============================
//   Design
//==============================
localparam IDLE     = 3'd0;
localparam LOAD_IMG = 3'd1;
localparam WAIT_CMD = 3'd2;
localparam INPUT    = 3'd3;
localparam DPC      = 3'd4;
localparam DEM      = 3'd5;

integer i, j;

reg  [3:0] x_cnt, y_cnt;
reg  [3:0] dpc_cnt_x, dpc_cnt_y;
reg  [7:0] dem_cnt;
reg  [8:0] dem_pix_cnt;   // count real DEM valid pixels, 0~256
reg  [2:0] cs, ns;

// ============================================================
// SRAM write/read controller
// ============================================================
reg [13:0] load_cnt;
reg [5:0]  cmd_r;
reg [7:0]  rd_cnt;
reg        rd_active;
reg        rd_req_d;
reg [1:0]  rd_bank_d;

wire [1:0]  wr_bank = load_cnt[13:12];
wire [11:0] wr_addr = load_cnt[11:0];
wire [1:0]  rd_bank = cmd_r[5:4];
wire [11:0] rd_addr = {cmd_r[3:0], rd_cnt};
wire        rd_req  = rd_active;

wire load_last = in_data_valid && (load_cnt == 14'd16383);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) cs <= IDLE;
    else        cs <= ns;
end

always @(*) begin
    ns = cs;
    case (cs)
        IDLE: begin
            if (in_data_valid) ns = LOAD_IMG;
            else               ns = IDLE;
        end
        LOAD_IMG: begin
            if (load_last) ns = WAIT_CMD;
            else           ns = LOAD_IMG;
        end
        WAIT_CMD: begin
            if (cmd_valid) ns = INPUT;
            else           ns = WAIT_CMD;
        end
        INPUT: begin
            if (x_cnt == 4 && y_cnt == 2) ns = DPC;
            else                          ns = INPUT;
        end
        DPC: begin
            if (dpc_cnt_x == 7 && dpc_cnt_y == 13) ns = DEM;
            else                                   ns = DPC;
        end
        DEM: begin
            if (dem_pix_cnt == 9'd256) ns = WAIT_CMD;
            else                       ns = DEM;
        end
        default: ns = IDLE;
    endcase
end

// write 16384 input data into 4 SRAMs
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        load_cnt <= 14'd0;
    end
    else if (in_data_valid) begin
        load_cnt <= load_cnt + 14'd1;
    end
end

// latch cmd and read 256 pixels
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        cmd_r     <= 6'd0;
        rd_cnt    <= 8'd0;
        rd_active <= 1'b0;
    end
    else if (cmd_valid) begin
        cmd_r     <= cmd;
        rd_cnt    <= 8'd0;
        rd_active <= 1'b1;
    end
    else if (rd_active) begin
        if (rd_cnt == 8'd255) begin
            rd_active <= 1'b0;
            rd_cnt    <= 8'd0;
        end
        else begin
            rd_cnt <= rd_cnt + 8'd1;
        end
    end
end

// SRAM is synchronous read, so data valid is delayed one cycle
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        rd_req_d  <= 1'b0;
        rd_bank_d <= 2'd0;
    end
    else begin
        rd_req_d  <= rd_req;
        rd_bank_d <= rd_bank;
    end
end

wire [11:0] mem0_addr = (in_data_valid && wr_bank == 2'd0) ? wr_addr : rd_addr;
wire [11:0] mem1_addr = (in_data_valid && wr_bank == 2'd1) ? wr_addr : rd_addr;
wire [11:0] mem2_addr = (in_data_valid && wr_bank == 2'd2) ? wr_addr : rd_addr;
wire [11:0] mem3_addr = (in_data_valid && wr_bank == 2'd3) ? wr_addr : rd_addr;

wire mem0_web = ~(in_data_valid && wr_bank == 2'd0);
wire mem1_web = ~(in_data_valid && wr_bank == 2'd1);
wire mem2_web = ~(in_data_valid && wr_bank == 2'd2);
wire mem3_web = ~(in_data_valid && wr_bank == 2'd3);

wire [11:0] sram0_q, sram1_q, sram2_q, sram3_q;
reg [11:0] sram0_q_r, sram1_q_r, sram2_q_r, sram3_q_r;
reg [11:0] pix_data;
reg        pix_valid;

MEM_4096X12 MEM0 (
    .CLK (clk), .CS  (1'b1), .OE  (1'b1), .WEB (mem0_web),
    .A   (mem0_addr), .DI  (in_data), .DO  (sram0_q)
);
MEM_4096X12 MEM1 (
    .CLK (clk), .CS  (1'b1), .OE  (1'b1), .WEB (mem1_web),
    .A   (mem1_addr), .DI  (in_data), .DO  (sram1_q)
);
MEM_4096X12 MEM2 (
    .CLK (clk), .CS  (1'b1), .OE  (1'b1), .WEB (mem2_web),
    .A   (mem2_addr), .DI  (in_data), .DO  (sram2_q)
);
MEM_4096X12 MEM3 (
    .CLK (clk), .CS  (1'b1), .OE  (1'b1), .WEB (mem3_web),
    .A   (mem3_addr), .DI  (in_data), .DO  (sram3_q)
);

// ============================================================
// Pipeline cut 1: register SRAM output before BLC
// ============================================================
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        sram0_q_r <= 12'd0;
        sram1_q_r <= 12'd0;
        sram2_q_r <= 12'd0;
        sram3_q_r <= 12'd0;
        pix_valid <= 1'b0;
    end
    else begin
        sram0_q_r <= sram0_q;
        sram1_q_r <= sram1_q;
        sram2_q_r <= sram2_q;
        sram3_q_r <= sram3_q;
        pix_valid <= rd_req_d;
    end
end

always @(*) begin
    case (rd_bank_d)
        2'd0: pix_data = sram0_q_r;
        2'd1: pix_data = sram1_q_r;
        2'd2: pix_data = sram2_q_r;
        2'd3: pix_data = sram3_q_r;
        default: pix_data = 12'd0;
    endcase
end

// ====================== BLC =====================
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        x_cnt <= 0;
        y_cnt <= 0;
    end
    else if (cmd_valid) begin
        x_cnt <= 0;
        y_cnt <= 0;
    end
    else if (pix_valid) begin
        if (x_cnt == 15) begin 
            x_cnt <= 0;
            y_cnt <= y_cnt + 1;
        end
        else begin
            x_cnt <= x_cnt + 1;
        end
    end
end

wire [1:0] color_id = {y_cnt[0], x_cnt[0]};
reg  [6:0] black_level;

always @(*) begin
    case (color_id)
        2'b00: black_level = 64;
        2'b01: black_level = 48; 
        2'b10: black_level = 52; 
        2'b11: black_level = 72;
    endcase
end

wire [13:0] sub_result = {2'b0, pix_data} - {7'b0, black_level};
wire [12:0] i_blc = sub_result[13] ? 13'd0 : sub_result[12:0];

// ====================== LSC =====================
function [12:0] gain_rom;
    input [1:0] cid; // 0:R, 1:Gr, 2:Gb, 3:B
    input [2:0] yy;
    input [2:0] xx;
begin
    gain_rom = 13'h400;
    case (cid)
        2'd0: begin // R
            case ({yy, xx})
                {3'd0,3'd0}: gain_rom = 13'h640;
                {3'd0,3'd1}: gain_rom = 13'h5DC; {3'd0,3'd2}: gain_rom = 13'h5AA; {3'd0,3'd3}: gain_rom = 13'h5AA; {3'd0,3'd4}: gain_rom = 13'h5DC; {3'd0,3'd5}: gain_rom = 13'h640;
                {3'd1,3'd0}: gain_rom = 13'h5DC; {3'd1,3'd1}: gain_rom = 13'h546; {3'd1,3'd2}: gain_rom = 13'h4E2; {3'd1,3'd3}: gain_rom = 13'h4E2; {3'd1,3'd4}: gain_rom = 13'h546;
                {3'd1,3'd5}: gain_rom = 13'h5DC;
                {3'd2,3'd0}: gain_rom = 13'h5AA; {3'd2,3'd1}: gain_rom = 13'h4E2; {3'd2,3'd2}: gain_rom = 13'h44C; {3'd2,3'd3}: gain_rom = 13'h44C;
                {3'd2,3'd4}: gain_rom = 13'h4E2; {3'd2,3'd5}: gain_rom = 13'h5AA;
                {3'd3,3'd0}: gain_rom = 13'h5AA; {3'd3,3'd1}: gain_rom = 13'h4E2; {3'd3,3'd2}: gain_rom = 13'h44C;
                {3'd3,3'd3}: gain_rom = 13'h44C; {3'd3,3'd4}: gain_rom = 13'h4E2; {3'd3,3'd5}: gain_rom = 13'h5AA;
                {3'd4,3'd0}: gain_rom = 13'h5DC; {3'd4,3'd1}: gain_rom = 13'h546;
                {3'd4,3'd2}: gain_rom = 13'h4E2; {3'd4,3'd3}: gain_rom = 13'h4E2; {3'd4,3'd4}: gain_rom = 13'h546; {3'd4,3'd5}: gain_rom = 13'h5DC;
                {3'd5,3'd0}: gain_rom = 13'h640;
                {3'd5,3'd1}: gain_rom = 13'h5DC; {3'd5,3'd2}: gain_rom = 13'h5AA; {3'd5,3'd3}: gain_rom = 13'h5AA; {3'd5,3'd4}: gain_rom = 13'h5DC; {3'd5,3'd5}: gain_rom = 13'h640;
            endcase
        end
        2'd1: begin // Gr
            case ({yy, xx})
                {3'd0,3'd0}: gain_rom = 13'h5DC;
                {3'd0,3'd1}: gain_rom = 13'h58C; {3'd0,3'd2}: gain_rom = 13'h550; {3'd0,3'd3}: gain_rom = 13'h550; {3'd0,3'd4}: gain_rom = 13'h58C; {3'd0,3'd5}: gain_rom = 13'h5DC;
                {3'd1,3'd0}: gain_rom = 13'h58C; {3'd1,3'd1}: gain_rom = 13'h500; {3'd1,3'd2}: gain_rom = 13'h4B0; {3'd1,3'd3}: gain_rom = 13'h4B0; {3'd1,3'd4}: gain_rom = 13'h500;
                {3'd1,3'd5}: gain_rom = 13'h58C;
                {3'd2,3'd0}: gain_rom = 13'h550; {3'd2,3'd1}: gain_rom = 13'h4B0; {3'd2,3'd2}: gain_rom = 13'h438; {3'd2,3'd3}: gain_rom = 13'h438;
                {3'd2,3'd4}: gain_rom = 13'h4B0; {3'd2,3'd5}: gain_rom = 13'h550;
                {3'd3,3'd0}: gain_rom = 13'h550; {3'd3,3'd1}: gain_rom = 13'h4B0; {3'd3,3'd2}: gain_rom = 13'h438;
                {3'd3,3'd3}: gain_rom = 13'h438; {3'd3,3'd4}: gain_rom = 13'h4B0; {3'd3,3'd5}: gain_rom = 13'h550;
                {3'd4,3'd0}: gain_rom = 13'h58C; {3'd4,3'd1}: gain_rom = 13'h500;
                {3'd4,3'd2}: gain_rom = 13'h4B0; {3'd4,3'd3}: gain_rom = 13'h4B0; {3'd4,3'd4}: gain_rom = 13'h500; {3'd4,3'd5}: gain_rom = 13'h58C;
                {3'd5,3'd0}: gain_rom = 13'h5DC;
                {3'd5,3'd1}: gain_rom = 13'h58C; {3'd5,3'd2}: gain_rom = 13'h550; {3'd5,3'd3}: gain_rom = 13'h550; {3'd5,3'd4}: gain_rom = 13'h58C; {3'd5,3'd5}: gain_rom = 13'h5DC;
            endcase
        end
        2'd2: begin // Gb
            case ({yy, xx})
                {3'd0,3'd0}: gain_rom = 13'h5DC;
                {3'd0,3'd1}: gain_rom = 13'h58C; {3'd0,3'd2}: gain_rom = 13'h550; {3'd0,3'd3}: gain_rom = 13'h550; {3'd0,3'd4}: gain_rom = 13'h58C; {3'd0,3'd5}: gain_rom = 13'h5DC;
                {3'd1,3'd0}: gain_rom = 13'h58C; {3'd1,3'd1}: gain_rom = 13'h500; {3'd1,3'd2}: gain_rom = 13'h4B0; {3'd1,3'd3}: gain_rom = 13'h4B0; {3'd1,3'd4}: gain_rom = 13'h500;
                {3'd1,3'd5}: gain_rom = 13'h58C;
                {3'd2,3'd0}: gain_rom = 13'h550; {3'd2,3'd1}: gain_rom = 13'h4B0; {3'd2,3'd2}: gain_rom = 13'h438; {3'd2,3'd3}: gain_rom = 13'h438;
                {3'd2,3'd4}: gain_rom = 13'h4B0; {3'd2,3'd5}: gain_rom = 13'h550;
                {3'd3,3'd0}: gain_rom = 13'h550; {3'd3,3'd1}: gain_rom = 13'h4B0; {3'd3,3'd2}: gain_rom = 13'h438;
                {3'd3,3'd3}: gain_rom = 13'h438; {3'd3,3'd4}: gain_rom = 13'h4B0; {3'd3,3'd5}: gain_rom = 13'h550;
                {3'd4,3'd0}: gain_rom = 13'h58C; {3'd4,3'd1}: gain_rom = 13'h500;
                {3'd4,3'd2}: gain_rom = 13'h4B0; {3'd4,3'd3}: gain_rom = 13'h4B0; {3'd4,3'd4}: gain_rom = 13'h500; {3'd4,3'd5}: gain_rom = 13'h58C;
                {3'd5,3'd0}: gain_rom = 13'h5DC;
                {3'd5,3'd1}: gain_rom = 13'h58C; {3'd5,3'd2}: gain_rom = 13'h550; {3'd5,3'd3}: gain_rom = 13'h550; {3'd5,3'd4}: gain_rom = 13'h58C; {3'd5,3'd5}: gain_rom = 13'h5DC;
            endcase
        end
        2'd3: begin // B
            case ({yy, xx})
                {3'd0,3'd0}: gain_rom = 13'h6A4;
                {3'd0,3'd1}: gain_rom = 13'h62C; {3'd0,3'd2}: gain_rom = 13'h5DC; {3'd0,3'd3}: gain_rom = 13'h5DC; {3'd0,3'd4}: gain_rom = 13'h62C; {3'd0,3'd5}: gain_rom = 13'h6A4;
                {3'd1,3'd0}: gain_rom = 13'h62C; {3'd1,3'd1}: gain_rom = 13'h58C; {3'd1,3'd2}: gain_rom = 13'h528; {3'd1,3'd3}: gain_rom = 13'h528; {3'd1,3'd4}: gain_rom = 13'h58C;
                {3'd1,3'd5}: gain_rom = 13'h62C;
                {3'd2,3'd0}: gain_rom = 13'h5DC; {3'd2,3'd1}: gain_rom = 13'h528; {3'd2,3'd2}: gain_rom = 13'h47E; {3'd2,3'd3}: gain_rom = 13'h47E;
                {3'd2,3'd4}: gain_rom = 13'h528; {3'd2,3'd5}: gain_rom = 13'h5DC;
                {3'd3,3'd0}: gain_rom = 13'h5DC; {3'd3,3'd1}: gain_rom = 13'h528; {3'd3,3'd2}: gain_rom = 13'h47E;
                {3'd3,3'd3}: gain_rom = 13'h47E; {3'd3,3'd4}: gain_rom = 13'h528; {3'd3,3'd5}: gain_rom = 13'h5DC;
                {3'd4,3'd0}: gain_rom = 13'h62C; {3'd4,3'd1}: gain_rom = 13'h58C;
                {3'd4,3'd2}: gain_rom = 13'h528; {3'd4,3'd3}: gain_rom = 13'h528; {3'd4,3'd4}: gain_rom = 13'h58C; {3'd4,3'd5}: gain_rom = 13'h62C;
                {3'd5,3'd0}: gain_rom = 13'h6A4;
                {3'd5,3'd1}: gain_rom = 13'h62C; {3'd5,3'd2}: gain_rom = 13'h5DC; {3'd5,3'd3}: gain_rom = 13'h5DC; {3'd5,3'd4}: gain_rom = 13'h62C; {3'd5,3'd5}: gain_rom = 13'h6A4;
            endcase
        end
    endcase
end
endfunction

reg [2:0] x0, y0; 
reg [1:0] rx, ry;

always @(*) begin
    case (x_cnt)
        0, 1, 2:        begin x0 = 0; rx = x_cnt[1:0]; end
        3, 4, 5:        begin x0 = 1; rx = x_cnt - 3; end
        6, 7, 8:        begin x0 = 2; rx = x_cnt - 6; end
        9, 10, 11:      begin x0 = 3; rx = x_cnt - 9; end
        12, 13, 14, 15: begin x0 = 4; rx = (x_cnt >= 14) ? 2 : x_cnt - 12; end
        default:        begin x0 = 0; rx = 0; end
    endcase
end

always @(*) begin
    case (y_cnt)
        0, 1, 2:        begin y0 = 0; ry = y_cnt[1:0]; end
        3, 4, 5:        begin y0 = 1; ry = y_cnt - 3; end
        6, 7, 8:        begin y0 = 2; ry = y_cnt - 6; end
        9, 10, 11:      begin y0 = 3; ry = y_cnt - 9; end
        12, 13, 14, 15: begin y0 = 4; ry = (y_cnt >= 14) ? 2 : y_cnt - 12; end
        default:        begin y0 = 0; ry = 0; end
    endcase
end

reg [12:0] g00, g01, g10, g11;
reg [13:0] g0110, g0011, g0010, g0001;

always @(*) begin
    g00 = gain_rom(color_id, y0,        x0);
    g01 = gain_rom(color_id, y0,        x0 + 3'd1);
    g10 = gain_rom(color_id, y0 + 3'd1, x0);
    g11 = gain_rom(color_id, y0 + 3'd1, x0 + 3'd1);

    g0110 = g01 + g10;
    g0011 = g00 + g11;
    g0010 = g00 + g10; 
    g0001 = g00 + g01;
end

reg [12:0] m_29241, m_7225;
reg [13:0] m_14535;

always @(*) begin
    m_29241 = 0; 
    m_14535 = 0;
    m_7225  = 0;
    case ({rx, ry})
        4'b0001: begin m_29241 = g00; m_14535 = g0010; m_7225 = g10; end
        4'b0010: begin m_29241 = g10; m_14535 = g0010; m_7225 = g00; end
        4'b0100: begin m_29241 = g00; m_14535 = g0001; m_7225 = g01; end
        4'b1000: begin m_29241 = g01; m_14535 = g0001; m_7225 = g00; end
        4'b0101: begin m_29241 = g00; m_14535 = g0110; m_7225 = g11; end
        4'b0110: begin m_29241 = g10; m_14535 = g0011; m_7225 = g01; end
        4'b1001: begin m_29241 = g01; m_14535 = g0011; m_7225 = g10; end
        4'b1010: begin m_29241 = g11; m_14535 = g0110; m_7225 = g00; end
    endcase
end

reg [12:0] m_29241_ff, m_7225_ff, g00_ff;
reg [13:0] m_14535_ff;
reg        rx_ry_zero_ff;
reg [12:0] i_blc_ff;
reg        in_valid_ff;

always @(posedge clk) begin
    m_29241_ff    <= m_29241;
    m_14535_ff    <= m_14535;
    m_7225_ff     <= m_7225;
    g00_ff        <= g00;
    rx_ry_zero_ff <= ({rx, ry} == 0);
    i_blc_ff      <= i_blc;
    in_valid_ff   <= pix_valid;
end

wire [29:0] gxy_sum_opt = (m_29241_ff * 29241) + 
                          (m_14535_ff * 14535) + 
                          (m_7225_ff  * 7225);

wire [13:0] gxy_calc = gxy_sum_opt[29:16] + gxy_sum_opt[15];
wire [13:0] gxy      = rx_ry_zero_ff ? {1'b0, g00_ff} : gxy_calc;

reg [13:0] gxy_ff;
reg [12:0] i_blc_ff_ff;
reg        in_valid_ff_ff;

always @(posedge clk) begin
    gxy_ff         <= gxy;
    i_blc_ff_ff    <= i_blc_ff;
    in_valid_ff_ff <= in_valid_ff;
end

wire [26:0] p_sum_round_pre = (gxy_ff * i_blc_ff_ff) + 27'd512;
wire [16:0] p_sum_round     = p_sum_round_pre[26:10];

wire p_is_over = |p_sum_round[16:12];
wire [11:0] pp_xy = p_is_over ? 12'd4095 : p_sum_round[11:0];

// ====================== DPC =====================

reg [11:0] lb0 [0:15]; 
reg [11:0] lb1 [0:15];
reg [11:0] lb2 [0:15];
reg [11:0] lb3 [0:15];
reg [11:0] lb4 [0:4]; 

always @(posedge clk) begin
    if (in_valid_ff_ff || cs == DPC || cs == DEM) begin
        for (i = 15; i > 0; i = i - 1) begin
            lb3[i] <= lb3[i - 1];
            lb2[i] <= lb2[i - 1];
            lb1[i] <= lb1[i - 1]; 
            lb0[i] <= lb0[i - 1];
        end
        lb3[0] <= lb2[15]; 
        lb2[0] <= lb1[15];
        lb1[0] <= lb0[15];
        lb0[0] <= (in_valid_ff_ff) ? pp_xy : 0;
        
        for (i = 4; i > 0; i = i - 1) 
            lb4[i] <= lb4[i - 1];
        lb4[0] <= lb3[15];
    end
    else begin
        for (i = 0; i < 16; i = i + 1) begin
            lb0[i] <= 0;
            lb1[i] <= 0; lb2[i] <= 0; lb3[i] <= 0;
        end
        for (i = 0; i < 5; i = i + 1) 
            lb4[i] <= 0;
    end
end

reg [11:0] px_mat [0:4][0:4];

always @(*) begin
    for (i = 0; i < 5; i = i + 1) begin
        px_mat[4][i] = lb0[4 - i];
        px_mat[3][i] = lb1[4 - i];
        px_mat[2][i] = lb2[4 - i];
        px_mat[1][i] = lb3[4 - i];
        px_mat[0][i] = lb4[4 - i];
    end
end

always @(posedge clk) begin
    if (cs == DPC || cs == DEM) begin
        if (dpc_cnt_x == 15) begin
            dpc_cnt_x <= 0;
            if (dpc_cnt_y == 15) 
                dpc_cnt_y <= 0;
            else 
                dpc_cnt_y <= dpc_cnt_y + 1;
        end
        else 
            dpc_cnt_x <= dpc_cnt_x + 1;
    end
    else begin
        dpc_cnt_x <= 0; 
        dpc_cnt_y <= 0;
    end
end

reg [2:0] px [0:4];
reg [2:0] py [0:4];

always @(*) begin
    px[0] = (dpc_cnt_x == 4'd0)  ? 3'd4 : (dpc_cnt_x == 4'd1)  ? 3'd2 : 3'd0;
    px[1] = (dpc_cnt_x == 4'd0)  ? 3'd3 : 3'd1;
    px[2] = 3'd2; 
    px[3] = (dpc_cnt_x == 4'd15) ? 3'd1 : 3'd3; 
    px[4] = (dpc_cnt_x == 4'd15) ? 3'd0 : (dpc_cnt_x == 4'd14) ? 3'd2 : 3'd4;

    py[0] = (dpc_cnt_y == 4'd0)  ? 3'd4 : (dpc_cnt_y == 4'd1)  ? 3'd2 : 3'd0;
    py[1] = (dpc_cnt_y == 4'd0)  ? 3'd3 : 3'd1;
    py[2] = 3'd2; 
    py[3] = (dpc_cnt_y == 4'd15) ? 3'd1 : 3'd3; 
    py[4] = (dpc_cnt_y == 4'd15) ? 3'd0 : (dpc_cnt_y == 4'd14) ? 3'd2 : 3'd4;
end

reg [11:0] p_row_0 [0:4]; reg [11:0] p_row_1 [0:4];
reg [11:0] p_row_2 [0:4]; reg [11:0] p_row_3 [0:4]; reg [11:0] p_row_4 [0:4];

always @(*) begin
    for(i = 0; i < 5; i = i + 1) begin
        p_row_0[i] = px_mat[py[0]][i];
        p_row_1[i] = px_mat[py[1]][i];
        p_row_2[i] = px_mat[py[2]][i]; 
        p_row_3[i] = px_mat[py[3]][i];
        p_row_4[i] = px_mat[py[4]][i];
    end
end

reg [11:0] H  [0:3];
reg [11:0] V  [0:3];
reg [11:0] D1 [0:3]; reg [11:0] D2 [0:3];

always @(*) begin
    H[0]  = p_row_2[px[0]]; H[1]  = p_row_2[px[1]]; H[2]  = p_row_2[px[3]]; H[3]  = p_row_2[px[4]];
    V[0]  = p_row_0[px[2]]; V[1]  = p_row_1[px[2]]; V[2]  = p_row_3[px[2]]; V[3]  = p_row_4[px[2]];
    D1[0] = p_row_0[px[0]]; D1[1] = p_row_1[px[1]]; D1[2] = p_row_3[px[3]]; D1[3] = p_row_4[px[4]];
    D2[0] = p_row_0[px[4]]; D2[1] = p_row_1[px[3]]; D2[2] = p_row_3[px[1]]; D2[3] = p_row_4[px[0]];
end

wire [11:0] H_max1, H_min1, H_max2, H_min2;
wire [11:0] V_max1, V_min1, V_max2, V_min2;
wire [11:0] D1_max1, D1_min1, D1_max2, D1_min2;
wire [11:0] D2_max1, D2_min1, D2_max2, D2_min2;

median_stage1 stg1_H (.A(H[0]), .B(H[1]), .C(H[2]), .D(H[3]), .max1(H_max1), .min1(H_min1), .max2(H_max2), .min2(H_min2));
median_stage1 stg1_V (.A(V[0]), .B(V[1]), .C(V[2]), .D(V[3]), .max1(V_max1), .min1(V_min1), .max2(V_max2), .min2(V_min2));
median_stage1 stg1_D1(.A(D1[0]),.B(D1[1]),.C(D1[2]),.D(D1[3]),.max1(D1_max1),.min1(D1_min1),.max2(D1_max2),.min2(D1_min2));
median_stage1 stg1_D2(.A(D2[0]),.B(D2[1]),.C(D2[2]),.D(D2[3]),.max1(D2_max1),.min1(D2_min1),.max2(D2_max2),.min2(D2_min2));

reg [11:0] H_ff[0:3], V_ff[0:3], D1_ff[0:3], D2_ff[0:3];
reg [11:0] H_max1_ff, H_min1_ff, H_max2_ff, H_min2_ff;
reg [11:0] V_max1_ff, V_min1_ff, V_max2_ff, V_min2_ff;
reg [11:0] D1_max1_ff, D1_min1_ff, D1_max2_ff, D1_min2_ff;
reg [11:0] D2_max1_ff, D2_min1_ff, D2_max2_ff, D2_min2_ff;
reg [11:0] P_ff;
reg        dpc_valid_ff;

always @(posedge clk) begin
    for(i = 0; i < 4; i = i + 1) begin
        H_ff[i] <= H[i];
        V_ff[i] <= V[i]; D1_ff[i] <= D1[i]; D2_ff[i] <= D2[i];
    end
    H_max1_ff <= H_max1; H_min1_ff <= H_min1;
    H_max2_ff <= H_max2; H_min2_ff <= H_min2;
    V_max1_ff <= V_max1; V_min1_ff <= V_min1; V_max2_ff <= V_max2; V_min2_ff <= V_min2;
    D1_max1_ff<= D1_max1;D1_min1_ff<= D1_min1;D1_max2_ff<= D1_max2;D1_min2_ff<= D1_min2;
    D2_max1_ff<= D2_max1;D2_min1_ff<= D2_min1;D2_max2_ff<= D2_max2;D2_min2_ff<= D2_min2;
    P_ff <= p_row_2[px[2]];
    dpc_valid_ff <= (cs == DPC || cs == DEM);
end

wire [11:0] med_H, med_V, med_D1, med_D2;

median_stage2 stg2_H (.max1(H_max1_ff), .min1(H_min1_ff), .max2(H_max2_ff), .min2(H_min2_ff), .median(med_H));
median_stage2 stg2_V (.max1(V_max1_ff), .min1(V_min1_ff), .max2(V_max2_ff), .min2(V_min2_ff), .median(med_V));
median_stage2 stg2_D1(.max1(D1_max1_ff),.min1(D1_min1_ff),.max2(D1_max2_ff),.min2(D1_min2_ff),.median(med_D1));
median_stage2 stg2_D2(.max1(D2_max1_ff),.min1(D2_min1_ff),.max2(D2_max2_ff),.min2(D2_min2_ff),.median(med_D2));

reg [11:0] H_ff_ff[0:3], V_ff_ff[0:3], D1_ff_ff[0:3], D2_ff_ff[0:3];
reg [11:0] med_H_ff, med_V_ff, med_D1_ff, med_D2_ff;
reg [11:0] P_ff_ff;
reg        dpc_valid_ff_ff;

always @(posedge clk) begin
    for(i = 0; i < 4; i = i + 1) begin
        H_ff_ff[i] <= H_ff[i];
        V_ff_ff[i] <= V_ff[i]; D1_ff_ff[i] <= D1_ff[i]; D2_ff_ff[i] <= D2_ff[i];
    end
    med_H_ff <= med_H; med_V_ff <= med_V;
    med_D1_ff <= med_D1; med_D2_ff <= med_D2;
    P_ff_ff <= P_ff;
    dpc_valid_ff_ff <= dpc_valid_ff;
end

wire [11:0] err_H0, err_H1, err_H2, err_H3;
wire [11:0] err_V0, err_V1, err_V2, err_V3;
wire [11:0] err_D1_0, err_D1_1, err_D1_2, err_D1_3;
wire [11:0] err_D2_0, err_D2_1, err_D2_2, err_D2_3;

sad sad_h0 (.A(H_ff_ff[0]), .B(med_H_ff), .abs(err_H0)); sad sad_h1 (.A(H_ff_ff[1]), .B(med_H_ff), .abs(err_H1));
sad sad_h2 (.A(H_ff_ff[2]), .B(med_H_ff), .abs(err_H2)); sad sad_h3 (.A(H_ff_ff[3]), .B(med_H_ff), .abs(err_H3));

sad sad_v0 (.A(V_ff_ff[0]), .B(med_V_ff), .abs(err_V0));
sad sad_v1 (.A(V_ff_ff[1]), .B(med_V_ff), .abs(err_V1));
sad sad_v2 (.A(V_ff_ff[2]), .B(med_V_ff), .abs(err_V2)); sad sad_v3 (.A(V_ff_ff[3]), .B(med_V_ff), .abs(err_V3));

sad sad_d1_0 (.A(D1_ff_ff[0]), .B(med_D1_ff), .abs(err_D1_0));
sad sad_d1_1 (.A(D1_ff_ff[1]), .B(med_D1_ff), .abs(err_D1_1));
sad sad_d1_2 (.A(D1_ff_ff[2]), .B(med_D1_ff), .abs(err_D1_2)); sad sad_d1_3 (.A(D1_ff_ff[3]), .B(med_D1_ff), .abs(err_D1_3));

sad sad_d2_0 (.A(D2_ff_ff[0]), .B(med_D2_ff), .abs(err_D2_0));
sad sad_d2_1 (.A(D2_ff_ff[1]), .B(med_D2_ff), .abs(err_D2_1));
sad sad_d2_2 (.A(D2_ff_ff[2]), .B(med_D2_ff), .abs(err_D2_2)); sad sad_d2_3 (.A(D2_ff_ff[3]), .B(med_D2_ff), .abs(err_D2_3));

wire [12:0] err_H01 = err_H0 + err_H1;
wire [12:0] err_H23 = err_H2 + err_H3;
wire [13:0] SAD_H   = err_H01 + err_H23;

wire [12:0] err_V01 = err_V0 + err_V1;
wire [12:0] err_V23 = err_V2 + err_V3;
wire [13:0] SAD_V   = err_V01 + err_V23;

wire [12:0] err_D1_01 = err_D1_0 + err_D1_1;
wire [12:0] err_D1_23 = err_D1_2 + err_D1_3;
wire [13:0] SAD_D1    = err_D1_01 + err_D1_23;

wire [12:0] err_D2_01 = err_D2_0 + err_D2_1;
wire [12:0] err_D2_23 = err_D2_2 + err_D2_3;
wire [13:0] SAD_D2    = err_D2_01 + err_D2_23;

reg [13:0] SAD_H_ff, SAD_V_ff, SAD_D1_ff, SAD_D2_ff;
reg [11:0] med_H_ff_ff, med_V_ff_ff, med_D1_ff_ff, med_D2_ff_ff;
reg [11:0] P_ff_ff_ff;
reg        dpc_valid_ff_ff_ff;

always @(posedge clk) begin
    SAD_H_ff  <= SAD_H;
    SAD_V_ff  <= SAD_V; 
    SAD_D1_ff <= SAD_D1; SAD_D2_ff <= SAD_D2;
    med_H_ff_ff  <= med_H_ff;  med_V_ff_ff  <= med_V_ff;
    med_D1_ff_ff <= med_D1_ff; med_D2_ff_ff <= med_D2_ff;
    P_ff_ff_ff   <= P_ff_ff;
    dpc_valid_ff_ff_ff <= dpc_valid_ff_ff;
end

wire cmp_HV = (SAD_H_ff <= SAD_V_ff);
wire [13:0] min_SAD_HV = cmp_HV ? SAD_H_ff : SAD_V_ff;
wire [11:0] target_HV  = cmp_HV ? med_H_ff_ff : med_V_ff_ff;

wire cmp_D1D2 = (SAD_D1_ff <= SAD_D2_ff);
wire [13:0] min_SAD_D1D2 = cmp_D1D2 ? SAD_D1_ff : SAD_D2_ff;
wire [11:0] target_D1D2  = cmp_D1D2 ? med_D1_ff_ff : med_D2_ff_ff;

wire cmp_final = (min_SAD_HV <= min_SAD_D1D2);
wire [11:0] Target_w = cmp_final ? target_HV : target_D1D2;

reg [11:0] Target_r;
reg [11:0] P_replace_r;

always @(posedge clk) begin
    Target_r    <= Target_w;
    P_replace_r <= P_ff_ff_ff;
end

wire replace_cond = ({1'b0, P_replace_r} > {1'b0, Target_r} + 13'd320) ||
                    ({1'b0, Target_r} > {1'b0, P_replace_r} + 13'd320);
wire [11:0] dpc_out = replace_cond ? Target_r : P_replace_r;

reg [11:0] dem_lb0 [0:15];  // previous row
reg [11:0] dem_lb1 [0:15];  // two rows before

reg [11:0] top_l, top_c, top_r;
reg [11:0] mid_l, mid_c, mid_r;
reg [11:0] bot_l, bot_c, bot_r;

reg [3:0] dpc_out_x, dpc_out_y;

reg dpc_stream_valid;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        dpc_stream_valid <= 1'b0;
    else
        dpc_stream_valid <= dpc_valid_ff_ff_ff;
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        dpc_out_x <= 0;
        dpc_out_y <= 0;
    end
    else if (cmd_valid) begin
        dpc_out_x <= 0;
        dpc_out_y <= 0;
    end
    else if (dpc_stream_valid) begin
        if (dpc_out_x == 15) begin
            dpc_out_x <= 0;
            dpc_out_y <= dpc_out_y + 1;
        end
        else begin
            dpc_out_x <= dpc_out_x + 1;
        end
    end
end

wire [11:0] two_row_up = dem_lb1[dpc_out_x];
wire [11:0] one_row_up = dem_lb0[dpc_out_x];

always @(posedge clk) begin
    if (dpc_stream_valid) begin
        dem_lb1[dpc_out_x] <= dem_lb0[dpc_out_x];
        dem_lb0[dpc_out_x] <= dpc_out;

        top_l <= top_c;
        top_c <= top_r;
        top_r <= two_row_up;

        mid_l <= mid_c;
        mid_c <= mid_r;
        mid_r <= one_row_up;

        bot_l <= bot_c;
        bot_c <= bot_r;
        bot_r <= dpc_out;
    end
end

reg dem_started;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        dem_started <= 1'b0;
    else if (cmd_valid)
        dem_started <= 1'b0;
    else if (dpc_stream_valid && dpc_out_y == 1 && dpc_out_x == 2)
        dem_started <= 1'b1;
end

wire dem_start_hit = dpc_stream_valid &&
                     (dpc_out_y == 4'd1) &&
                     (dpc_out_x == 4'd2);

wire dem_fire_raw = dpc_stream_valid &&
                    (dem_started || dem_start_hit);

wire dem_window_valid = dem_fire_raw && (dem_pix_cnt < 9'd256);

reg  [3:0] dem_cnt_x, dem_cnt_y;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        dem_cnt     <= 0;
        dem_pix_cnt <= 0;
        dem_cnt_x   <= 0;
        dem_cnt_y   <= 0;
    end
    else if (cmd_valid) begin 
        dem_cnt     <= 0;
        dem_pix_cnt <= 0;
        dem_cnt_x   <= 0;
        dem_cnt_y   <= 0;
    end
    else if (dem_window_valid) begin
        dem_cnt     <= dem_cnt + 1;
        dem_pix_cnt <= dem_pix_cnt + 1;

        if (dem_cnt_x == 15) begin
            dem_cnt_x <= 0;
            dem_cnt_y <= dem_cnt_y + 1;
        end
        else begin
            dem_cnt_x <= dem_cnt_x + 1;
        end
    end
end

// ============================ dem ===================================

wire [1:0] dem_color_id = {dem_cnt_y[0], dem_cnt_x[0]};

wire [11:0] raw_NW = top_l;
wire [11:0] raw_N  = top_c;
wire [11:0] raw_NE = top_r;

wire [11:0] raw_W  = mid_l;
wire [11:0] raw_C  = mid_c;
wire [11:0] raw_E  = mid_r;

wire [11:0] raw_SW = bot_l;
wire [11:0] raw_S  = bot_c;
wire [11:0] raw_SE = bot_r;

wire is_top    = (dem_cnt_y == 0);
wire is_bottom = (dem_cnt_y == 15);
wire is_left   = (dem_cnt_x == 0);
wire is_right  = (dem_cnt_x == 15);

wire [11:0] C = raw_C;
wire [11:0] W = is_left   ? raw_E : raw_W;
wire [11:0] E = is_right  ? raw_W : raw_E;
wire [11:0] N = is_top    ? raw_S : raw_N;
wire [11:0] S = is_bottom ? raw_N : raw_S;

wire [11:0] NW = (is_top & is_left) ? raw_SE : (is_top) ? raw_SW : (is_left) ? raw_NE : raw_NW;
wire [11:0] NE = (is_top & is_right) ? raw_SW : (is_top) ? raw_SE : (is_right) ? raw_NW : raw_NE;
wire [11:0] SW = (is_bottom & is_left) ? raw_NE : (is_bottom) ? raw_NW : (is_left) ? raw_SE : raw_SW;
wire [11:0] SE = (is_bottom & is_right) ? raw_NW : (is_bottom) ? raw_NE : (is_right) ? raw_SW : raw_SE;

wire [12:0] total_ns = N + S; 
wire [12:0] total_we = W + E;
wire [13:0] total_nswe  = total_ns + total_we; 
wire [13:0] total_other = (NW + NE) + (SW + SE);

wire [11:0] avg_nswe   = total_nswe[13:2]; 
wire [11:0] avg_pother = total_other[13:2];
wire [11:0] avg_ns     = total_ns[12:1];     
wire [11:0] avg_we     = total_we[12:1];

reg [11:0] r_interp, g_interp, b_interp;

always @(*) begin
    case (dem_color_id)
        2'b00: begin r_interp = C;          g_interp = avg_nswe; b_interp = avg_pother; end 
        2'b01: begin r_interp = avg_we;     g_interp = C;        b_interp = avg_ns;     end 
        2'b10: begin r_interp = avg_ns;     g_interp = C;        b_interp = avg_we;     end 
        2'b11: begin r_interp = avg_pother; g_interp = avg_nswe; b_interp = C;          end 
    endcase
end

reg [11:0] r_dem_ff, g_dem_ff, b_dem_ff;
reg        dem_valid_ff;

always @(posedge clk) begin
    r_dem_ff     <= r_interp;
    g_dem_ff     <= g_interp;
    b_dem_ff     <= b_interp;
    dem_valid_ff <= dem_window_valid;
end

// ========================== CCM =====================================

wire signed [13:0] r_s = $signed({2'b0, r_dem_ff});
wire signed [13:0] g_s = $signed({2'b0, g_dem_ff});
wire signed [13:0] b_s = $signed({2'b0, b_dem_ff});

localparam signed [14:0] C_err = 15'sd1150; 
localparam signed [14:0] C_SUB = -15'sd50;

wire signed [15:0] rgb_sum = r_s + g_s + b_s;

wire signed [26:0] shared_sub_nxt = (rgb_sum * C_SUB) + 27'sd512;
wire signed [26:0] r_mul_nxt = r_s * C_err;
wire signed [26:0] g_mul_nxt = g_s * C_err;
wire signed [26:0] b_mul_nxt = b_s * C_err;

reg signed [26:0] shared_sub_r;
reg signed [26:0] r_mul_r, g_mul_r, b_mul_r;
reg               ccm_valid_r;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        shared_sub_r <= 27'sd0;
        r_mul_r      <= 27'sd0;
        g_mul_r      <= 27'sd0;
        b_mul_r      <= 27'sd0;
        ccm_valid_r  <= 1'b0;
    end
    else begin
        shared_sub_r <= shared_sub_nxt;
        r_mul_r      <= r_mul_nxt;
        g_mul_r      <= g_mul_nxt;
        b_mul_r      <= b_mul_nxt;
        ccm_valid_r  <= dem_valid_ff;
    end
end

wire signed [26:0] r_raw_calc = r_mul_r + shared_sub_r;
wire signed [26:0] g_raw_calc = g_mul_r + shared_sub_r;
wire signed [26:0] b_raw_calc = b_mul_r + shared_sub_r;

wire signed [26:0] r_shift = r_raw_calc >>> 10;
wire signed [26:0] g_shift = g_raw_calc >>> 10;
wire signed [26:0] b_shift = b_raw_calc >>> 10;

wire r_is_neg = r_shift[26];
wire g_is_neg = g_shift[26];
wire b_is_neg = b_shift[26];
wire [26:0] r_shift_u = $unsigned(r_shift);
wire [26:0] g_shift_u = $unsigned(g_shift);
wire [26:0] b_shift_u = $unsigned(b_shift);

wire r_is_over = (|r_shift_u[25:12]) & ~r_is_neg;
wire g_is_over = (|g_shift_u[25:12]) & ~g_is_neg;
wire b_is_over = (|b_shift_u[25:12]) & ~b_is_neg;

wire [7:0] r_ccm8 = r_is_neg ? 8'd0 : (r_is_over ? 8'hff : r_shift_u[11:4]);
wire [7:0] g_ccm8 = g_is_neg ? 8'd0 : (g_is_over ? 8'hff : g_shift_u[11:4]);
wire [7:0] b_ccm8 = b_is_neg ? 8'd0 : (b_is_over ? 8'hff : b_shift_u[11:4]);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        out_valid <= 0;
        r_out <= 8'd0; g_out <= 8'd0; b_out <= 8'd0;
    end
    else if (ccm_valid_r) begin 
        out_valid <= 1;
        r_out <= r_ccm8; g_out <= g_ccm8; b_out <= b_ccm8;
    end
    else begin
        out_valid <= 0;
        r_out <= 8'd0; g_out <= 8'd0; b_out <= 8'd0;
    end
end

endmodule

// ============================================================
// Submodules
// ============================================================

module median_stage1 (
    input  [11:0] A, B, C, D,
    output [11:0] max1, min1, max2, min2
);
    assign {max1, min1} = (A > B) ? {A, B} : {B, A};
    assign {max2, min2} = (C > D) ? {C, D} : {D, C};
endmodule

module median_stage2 (
    input  [11:0] max1, min1, max2, min2,
    output [11:0] median
);
    wire [11:0] mid_low  = (min1 > min2) ? min1 : min2;
    wire [11:0] mid_high = (max1 < max2) ? max1 : max2;
    wire [12:0] safe_sum = {1'b0, mid_low} + {1'b0, mid_high};
    assign median = safe_sum[12:1];
endmodule

module sad (
    input  [11:0] A, B,
    output [11:0] abs
);
    wire [11:0] sub_ab = A - B;
    wire [11:0] sub_ba = B - A;
    assign abs = (A > B) ? sub_ab : sub_ba;
endmodule

module MEM_4096X12(
    input         CLK, CS, OE, WEB,
    input  [11:0] A,   
    input  [11:0] DI,  
    output [11:0] DO   
);
    SUMA180_4096X12 SRAM_INST (
        .A0(A[0]),   .A1(A[1]),   .A2(A[2]),   .A3(A[3]), 
        .A4(A[4]),   .A5(A[5]),   .A6(A[6]),   .A7(A[7]), 
        .A8(A[8]),   .A9(A[9]),   .A10(A[10]), .A11(A[11]),
        .DO0(DO[0]), .DO1(DO[1]), .DO2(DO[2]), .DO3(DO[3]),
        .DO4(DO[4]), .DO5(DO[5]), .DO6(DO[6]), .DO7(DO[7]),
        .DO8(DO[8]), .DO9(DO[9]), .DO10(DO[10]), .DO11(DO[11]),
        .DI0(DI[0]), .DI1(DI[1]), .DI2(DI[2]), .DI3(DI[3]),
        .DI4(DI[4]), .DI5(DI[5]), .DI6(DI[6]), .DI7(DI[7]),
        .DI8(DI[8]), .DI9(DI[9]), .DI10(DI[10]), .DI11(DI[11]),
        .CK(CLK), .WEB(WEB), .OE(OE), .CS(CS)
    );
endmodule

// 320 1773821.927114 4.2 
// 320 4253022.655 12.0 0.85 190


// 4288078.596 11.5 0.85 190
// 4291924.406 11.1 0.85 190
