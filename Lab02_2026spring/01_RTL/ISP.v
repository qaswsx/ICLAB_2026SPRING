// // // // // // module ISP (
// // // // // //     input         clk,
// // // // // //     input         rst_n,
// // // // // //     input         in_valid,
// // // // // //     input  [12:0] in,
// // // // // //     input         param_valid,
// // // // // //     input  [12:0] param_gain,

// // // // // //     output reg        out_valid,
// // // // // //     output reg [12:0] r_out,
// // // // // //     output reg [12:0] g_out,
// // // // // //     output reg [12:0] b_out
// // // // // // );

// // // // // // //==============================
// // // // // // //   Design
// // // // // // //==============================
// // // // // // localparam IDLE  = 2'd0;
// // // // // // localparam INPUT = 2'd1;
// // // // // // localparam DPC   = 2'd2;
// // // // // // localparam DEM   = 2'd3;

// // // // // // integer i, j;

// // // // // // reg  [3:0] x_cnt, y_cnt; 
// // // // // // reg  [3:0] dpc_cnt_x, dpc_cnt_y;
// // // // // // reg  [7:0] dem_cnt;

// // // // // // reg  [1:0] cs, ns;

// // // // // // always @(posedge clk or negedge rst_n) begin
// // // // // //     if (~rst_n) cs <= IDLE;
// // // // // //     else        cs <= ns;
// // // // // // end

// // // // // // always @(*) begin
// // // // // //     ns = cs; 
// // // // // //     case (cs)
// // // // // //         IDLE:  ns = (in_valid) ? INPUT : IDLE;
// // // // // //         INPUT: ns = (x_cnt == 4 && y_cnt == 2) ? DPC : INPUT;

// // // // // //         // 原本 13,13，太晚 5 cycles
// // // // // //         DPC:   ns = (dpc_cnt_x == 8 && dpc_cnt_y == 13) ? DEM : DPC;

// // // // // //         DEM:   ns = (dem_cnt == 255) ? IDLE : DEM;
// // // // // //     endcase
// // // // // // end

// // // // // // reg [2:0] param_x_cnt, param_y_cnt; 
// // // // // // reg [1:0] next_gain;

// // // // // // always @(posedge clk or negedge rst_n) begin
// // // // // //     if (~rst_n) begin
// // // // // //         param_x_cnt <= 0; 
// // // // // //         param_y_cnt <= 0; 
// // // // // //         next_gain <= 0;
// // // // // //     end
// // // // // //     else if (param_valid) begin
// // // // // //         if (param_x_cnt == 5 && param_y_cnt == 5) begin
// // // // // //             param_x_cnt <= 0; 
// // // // // //             param_y_cnt <= 0; 
// // // // // //             next_gain <= next_gain + 1;
// // // // // //         end
// // // // // //         else if (param_x_cnt == 5) begin 
// // // // // //             param_x_cnt <= 3'd0; 
// // // // // //             param_y_cnt <= param_y_cnt + 3'd1;
// // // // // //         end
// // // // // //         else
// // // // // //             param_x_cnt <= param_x_cnt + 3'd1;
// // // // // //     end
// // // // // // end

// // // // // // reg  [12:0] r_matrix  [0:5][0:5];
// // // // // // reg  [12:0] gr_matrix [0:5][0:5];
// // // // // // reg  [12:0] gb_matrix [0:5][0:5];
// // // // // // reg  [12:0] b_matrix  [0:5][0:5];

// // // // // // always @(posedge clk or negedge rst_n) begin
// // // // // //     if (~rst_n) begin
// // // // // //         for (i = 0; i < 6; i = i + 1) 
// // // // // //         for (j = 0; j < 6; j = j + 1) begin
// // // // // //             r_matrix[i][j]  <= 0; 
// // // // // //             gr_matrix[i][j] <= 0;
// // // // // //             gb_matrix[i][j] <= 0; 
// // // // // //             b_matrix[i][j]  <= 0;
// // // // // //         end
// // // // // //     end
// // // // // //     else if (param_valid) begin
// // // // // //         case (next_gain)
// // // // // //             0: r_matrix[param_y_cnt][param_x_cnt]  <= param_gain;
// // // // // //             1: gr_matrix[param_y_cnt][param_x_cnt] <= param_gain;
// // // // // //             2: gb_matrix[param_y_cnt][param_x_cnt] <= param_gain;
// // // // // //             3: b_matrix[param_y_cnt][param_x_cnt]  <= param_gain;
// // // // // //         endcase
// // // // // //     end
// // // // // // end

// // // // // // // ====================== BLC =====================
// // // // // // always @(posedge clk or negedge rst_n) begin
// // // // // //     if (~rst_n) begin
// // // // // //         x_cnt <= 0; 
// // // // // //         y_cnt <= 0;
// // // // // //     end
// // // // // //     else if (in_valid) begin
// // // // // //         if (x_cnt == 15) begin 
// // // // // //             x_cnt <= 0; 
// // // // // //             y_cnt <= y_cnt + 1;
// // // // // //         end
// // // // // //         else 
// // // // // //             x_cnt <= x_cnt + 1;
// // // // // //     end
// // // // // // end

// // // // // // wire [1:0] color_id = {y_cnt[0], x_cnt[0]};
// // // // // // reg  [6:0] black_level;

// // // // // // always @(*) begin
// // // // // //     case (color_id)
// // // // // //         2'b00: black_level = 64; 
// // // // // //         2'b01: black_level = 48; 
// // // // // //         2'b10: black_level = 52; 
// // // // // //         2'b11: black_level = 72; 
// // // // // //     endcase
// // // // // // end

// // // // // // wire [13:0] sub_result = {1'b0, in} - {7'b0, black_level};
// // // // // // wire [12:0] i_blc = sub_result[13] ? 0 : sub_result[12:0];

// // // // // // // ====================== LSC =====================
// // // // // // reg [2:0] x0, y0; 
// // // // // // reg [1:0] rx, ry;

// // // // // // always @(*) begin
// // // // // //     case (x_cnt)
// // // // // //         0, 1, 2:        begin x0 = 0; rx = x_cnt[1:0]; end
// // // // // //         3, 4, 5:        begin x0 = 1; rx = x_cnt - 3; end
// // // // // //         6, 7, 8:        begin x0 = 2; rx = x_cnt - 6; end
// // // // // //         9, 10, 11:      begin x0 = 3; rx = x_cnt - 9; end
// // // // // //         12, 13, 14, 15: begin x0 = 4; rx = (x_cnt >= 14) ? 2 : x_cnt - 12; end
// // // // // //         default:        begin x0 = 0; rx = 0; end
// // // // // //     endcase
// // // // // // end

// // // // // // always @(*) begin
// // // // // //     case (y_cnt)
// // // // // //         0, 1, 2:        begin y0 = 0; ry = y_cnt[1:0]; end
// // // // // //         3, 4, 5:        begin y0 = 1; ry = y_cnt - 3; end
// // // // // //         6, 7, 8:        begin y0 = 2; ry = y_cnt - 6; end
// // // // // //         9, 10, 11:      begin y0 = 3; ry = y_cnt - 9; end
// // // // // //         12, 13, 14, 15: begin y0 = 4; ry = (y_cnt >= 14) ? 2 : y_cnt - 12; end
// // // // // //         default:        begin y0 = 0; ry = 0; end
// // // // // //     endcase
// // // // // // end

// // // // // // reg [12:0] c_row_0 [0:5];
// // // // // // reg [12:0] c_row_1 [0:5];

// // // // // // always @(*) begin
// // // // // //     case (color_id)
// // // // // //         2'b00: begin
// // // // // //             for(i = 0; i < 6; i = i + 1) begin 
// // // // // //                 c_row_0[i] = r_matrix[y0][i];  
// // // // // //                 c_row_1[i] = r_matrix[y0 + 1][i];  
// // // // // //             end
// // // // // //         end
// // // // // //         2'b01: begin
// // // // // //             for(i = 0; i < 6; i = i + 1) begin 
// // // // // //                 c_row_0[i] = gr_matrix[y0][i]; 
// // // // // //                 c_row_1[i] = gr_matrix[y0 + 1][i]; 
// // // // // //             end
// // // // // //         end
// // // // // //         2'b10: begin
// // // // // //             for(i = 0; i < 6; i = i + 1) begin 
// // // // // //                 c_row_0[i] = gb_matrix[y0][i]; 
// // // // // //                 c_row_1[i] = gb_matrix[y0 + 1][i]; 
// // // // // //             end
// // // // // //         end
// // // // // //         2'b11: begin
// // // // // //             for(i = 0; i < 6; i = i + 1) begin 
// // // // // //                 c_row_0[i] = b_matrix[y0][i];  
// // // // // //                 c_row_1[i] = b_matrix[y0 + 1][i];  
// // // // // //             end
// // // // // //         end
// // // // // //     endcase
// // // // // // end

// // // // // // reg [12:0] g00, g01, g10, g11;
// // // // // // reg [13:0] g0110, g0011, g0010, g0001;

// // // // // // always @(*) begin
// // // // // //     g00 = c_row_0[x0];
// // // // // //     g01 = c_row_0[x0 + 1];
// // // // // //     g10 = c_row_1[x0];
// // // // // //     g11 = c_row_1[x0 + 1];

// // // // // //     g0110 = g01 + g10;
// // // // // //     g0011 = g00 + g11;
// // // // // //     g0010 = g00 + g10; 
// // // // // //     g0001 = g00 + g01; 
// // // // // // end

// // // // // // reg [12:0] m_29241, m_7225;
// // // // // // reg [13:0] m_14535; 

// // // // // // always @(*) begin
// // // // // //     m_29241 = 0; 
// // // // // //     m_14535 = 0; 
// // // // // //     m_7225  = 0;
// // // // // //     case ({rx, ry})
// // // // // //         4'b0001: begin m_29241 = g00; m_14535 = g0010; m_7225 = g10; end
// // // // // //         4'b0010: begin m_29241 = g10; m_14535 = g0010; m_7225 = g00; end
// // // // // //         4'b0100: begin m_29241 = g00; m_14535 = g0001; m_7225 = g01; end
// // // // // //         4'b1000: begin m_29241 = g01; m_14535 = g0001; m_7225 = g00; end
// // // // // //         4'b0101: begin m_29241 = g00; m_14535 = g0110; m_7225 = g11; end
// // // // // //         4'b0110: begin m_29241 = g10; m_14535 = g0011; m_7225 = g01; end
// // // // // //         4'b1001: begin m_29241 = g01; m_14535 = g0011; m_7225 = g10; end
// // // // // //         4'b1010: begin m_29241 = g11; m_14535 = g0110; m_7225 = g00; end
// // // // // //     endcase
// // // // // // end

// // // // // // reg [12:0] m_29241_ff, m_7225_ff, g00_ff;
// // // // // // reg [13:0] m_14535_ff;
// // // // // // reg        rx_ry_zero_ff;
// // // // // // reg [12:0] i_blc_ff;
// // // // // // reg        in_valid_ff;

// // // // // // always @(posedge clk) begin
// // // // // //     m_29241_ff <= m_29241; 
// // // // // //     m_14535_ff <= m_14535; 
// // // // // //     m_7225_ff  <= m_7225;
// // // // // //     g00_ff     <= g00;
// // // // // //     rx_ry_zero_ff <= ({rx, ry} == 0);
// // // // // //     i_blc_ff   <= i_blc;
// // // // // //     in_valid_ff<= in_valid;
// // // // // // end

// // // // // // wire [29:0] gxy_sum_opt = (m_29241_ff * 29241) + 
// // // // // //                           (m_14535_ff * 14535) + 
// // // // // //                           (m_7225_ff  * 7225);

// // // // // // wire [13:0] gxy_calc = gxy_sum_opt[29:16] + gxy_sum_opt[15];
// // // // // // wire [13:0] gxy = (rx_ry_zero_ff) ? {1'b0, g00_ff} : gxy_calc;

// // // // // // reg [13:0] gxy_ff;
// // // // // // reg [12:0] i_blc_ff_ff;
// // // // // // reg        in_valid_ff_ff;

// // // // // // always @(posedge clk) begin
// // // // // //     gxy_ff         <= gxy;
// // // // // //     i_blc_ff_ff    <= i_blc_ff; 
// // // // // //     in_valid_ff_ff <= in_valid_ff; 
// // // // // // end

// // // // // // wire [25:0] p_sum = gxy_ff * i_blc_ff_ff;
// // // // // // wire [16:0] p_sum_round = p_sum[25:10] + p_sum[9];

// // // // // // wire p_is_over = |p_sum_round[16:12];
// // // // // // wire [11:0] pp_xy = p_is_over ? 4095 : p_sum_round[11:0];

// // // // // // // ====================== DPC =====================

// // // // // // reg [11:0] lb0 [0:15]; 
// // // // // // reg [11:0] lb1 [0:15];
// // // // // // reg [11:0] lb2 [0:15]; 
// // // // // // reg [11:0] lb3 [0:15];
// // // // // // reg [11:0] lb4 [0:4]; 

// // // // // // always @(posedge clk) begin
// // // // // //     if (in_valid_ff_ff || cs == DPC || cs == DEM) begin
// // // // // //         for (i = 15; i > 0; i = i - 1) begin
// // // // // //             lb3[i] <= lb3[i - 1]; 
// // // // // //             lb2[i] <= lb2[i - 1];
// // // // // //             lb1[i] <= lb1[i - 1]; 
// // // // // //             lb0[i] <= lb0[i - 1];
// // // // // //         end
// // // // // //         lb3[0] <= lb2[15]; 
// // // // // //         lb2[0] <= lb1[15];
// // // // // //         lb1[0] <= lb0[15]; 
// // // // // //         lb0[0] <= (in_valid_ff_ff) ? pp_xy : 0;
        
// // // // // //         for (i = 4; i > 0; i = i - 1) 
// // // // // //             lb4[i] <= lb4[i - 1];
            
// // // // // //         lb4[0] <= lb3[15];
// // // // // //     end
// // // // // //     else begin
// // // // // //         for (i = 0; i < 16; i = i + 1) begin
// // // // // //             lb0[i] <= 0; 
// // // // // //             lb1[i] <= 0; 
// // // // // //             lb2[i] <= 0; 
// // // // // //             lb3[i] <= 0;
// // // // // //         end
// // // // // //         for (i = 0; i < 5; i = i + 1) 
// // // // // //             lb4[i] <= 0;
// // // // // //     end
// // // // // // end

// // // // // // reg [11:0] px_mat [0:4][0:4];

// // // // // // always @(*) begin
// // // // // //     for (i = 0; i < 5; i = i + 1) begin
// // // // // //         px_mat[4][i] = lb0[4 - i];
// // // // // //         px_mat[3][i] = lb1[4 - i];
// // // // // //         px_mat[2][i] = lb2[4 - i];
// // // // // //         px_mat[1][i] = lb3[4 - i];
// // // // // //         px_mat[0][i] = lb4[4 - i];
// // // // // //     end
// // // // // // end

// // // // // // // ====================== DPC  =====================

// // // // // // always @(posedge clk) begin
// // // // // //     if (cs == DPC || cs == DEM) begin
// // // // // //         if (dpc_cnt_x == 15) begin
// // // // // //             dpc_cnt_x <= 0;
// // // // // //             if (dpc_cnt_y == 15) 
// // // // // //                 dpc_cnt_y <= 0;
// // // // // //             else 
// // // // // //                 dpc_cnt_y <= dpc_cnt_y + 1;
// // // // // //         end
// // // // // //         else 
// // // // // //             dpc_cnt_x <= dpc_cnt_x + 1;
// // // // // //     end
// // // // // //     else begin
// // // // // //         dpc_cnt_x <= 0; 
// // // // // //         dpc_cnt_y <= 0;
// // // // // //     end
// // // // // // end

// // // // // // reg [2:0] px [0:4];
// // // // // // reg [2:0] py [0:4];

// // // // // // always @(*) begin
// // // // // //     px[0] = (dpc_cnt_x == 4'd0)  ? 3'd4 : (dpc_cnt_x == 4'd1)  ? 3'd2 : 3'd0;
// // // // // //     px[1] = (dpc_cnt_x == 4'd0)  ? 3'd3 : 3'd1; 
// // // // // //     px[2] = 3'd2; 
// // // // // //     px[3] = (dpc_cnt_x == 4'd15) ? 3'd1 : 3'd3; 
// // // // // //     px[4] = (dpc_cnt_x == 4'd15) ? 3'd0 : (dpc_cnt_x == 4'd14) ? 3'd2 : 3'd4;

// // // // // //     py[0] = (dpc_cnt_y == 4'd0)  ? 3'd4 : (dpc_cnt_y == 4'd1)  ? 3'd2 : 3'd0;
// // // // // //     py[1] = (dpc_cnt_y == 4'd0)  ? 3'd3 : 3'd1; 
// // // // // //     py[2] = 3'd2; 
// // // // // //     py[3] = (dpc_cnt_y == 4'd15) ? 3'd1 : 3'd3; 
// // // // // //     py[4] = (dpc_cnt_y == 4'd15) ? 3'd0 : (dpc_cnt_y == 4'd14) ? 3'd2 : 3'd4;
// // // // // // end

// // // // // // reg [11:0] p_row_0 [0:4]; 
// // // // // // reg [11:0] p_row_1 [0:4]; 
// // // // // // reg [11:0] p_row_2 [0:4];
// // // // // // reg [11:0] p_row_3 [0:4]; 
// // // // // // reg [11:0] p_row_4 [0:4];

// // // // // // always @(*) begin
// // // // // //     for(i = 0; i < 5; i = i + 1) begin
// // // // // //         p_row_0[i] = px_mat[py[0]][i]; 
// // // // // //         p_row_1[i] = px_mat[py[1]][i];
// // // // // //         p_row_2[i] = px_mat[py[2]][i]; 
// // // // // //         p_row_3[i] = px_mat[py[3]][i];
// // // // // //         p_row_4[i] = px_mat[py[4]][i];
// // // // // //     end
// // // // // // end

// // // // // // reg [11:0] H  [0:3];
// // // // // // reg [11:0] V  [0:3];
// // // // // // reg [11:0] D1 [0:3];
// // // // // // reg [11:0] D2 [0:3];

// // // // // // always @(*) begin
// // // // // //     H[0]  = p_row_2[px[0]]; 
// // // // // //     H[1]  = p_row_2[px[1]]; 
// // // // // //     H[2]  = p_row_2[px[3]]; 
// // // // // //     H[3]  = p_row_2[px[4]];

// // // // // //     V[0]  = p_row_0[px[2]]; 
// // // // // //     V[1]  = p_row_1[px[2]]; 
// // // // // //     V[2]  = p_row_3[px[2]]; 
// // // // // //     V[3]  = p_row_4[px[2]];

// // // // // //     D1[0] = p_row_0[px[0]]; 
// // // // // //     D1[1] = p_row_1[px[1]]; 
// // // // // //     D1[2] = p_row_3[px[3]]; 
// // // // // //     D1[3] = p_row_4[px[4]];

// // // // // //     D2[0] = p_row_0[px[4]]; 
// // // // // //     D2[1] = p_row_1[px[3]]; 
// // // // // //     D2[2] = p_row_3[px[1]]; 
// // // // // //     D2[3] = p_row_4[px[0]];
// // // // // // end

// // // // // // reg [11:0] H_ff[0:3], V_ff[0:3], D1_ff[0:3], D2_ff[0:3];
// // // // // // reg [11:0] P_ff;
// // // // // // reg        dpc_valid_ff;

// // // // // // always @(posedge clk) begin
// // // // // //     for(i = 0; i < 4; i = i + 1) begin
// // // // // //         H_ff[i] <= H[i]; 
// // // // // //         V_ff[i] <= V[i]; 
// // // // // //         D1_ff[i] <= D1[i]; 
// // // // // //         D2_ff[i] <= D2[i];
// // // // // //     end
// // // // // //     P_ff <= p_row_2[px[2]];
// // // // // //     dpc_valid_ff <= (cs == DPC || cs == DEM);
// // // // // // end

// // // // // // wire [11:0] med_H, med_V, med_D1, med_D2;

// // // // // // median calc_med_H (.A(H_ff[0]), .B(H_ff[1]), .C(H_ff[2]), .D(H_ff[3]), .median(med_H));
// // // // // // median calc_med_V (.A(V_ff[0]), .B(V_ff[1]), .C(V_ff[2]), .D(V_ff[3]), .median(med_V));
// // // // // // median calc_med_D1(.A(D1_ff[0]),.B(D1_ff[1]),.C(D1_ff[2]),.D(D1_ff[3]),.median(med_D1));
// // // // // // median calc_med_D2(.A(D2_ff[0]),.B(D2_ff[1]),.C(D2_ff[2]),.D(D2_ff[3]),.median(med_D2));

// // // // // // reg [11:0] H_ff_ff[0:3], V_ff_ff[0:3], D1_ff_ff[0:3], D2_ff_ff[0:3];
// // // // // // reg [11:0] med_H_ff, med_V_ff, med_D1_ff, med_D2_ff;
// // // // // // reg [11:0] P_ff_ff;
// // // // // // reg        dpc_valid_ff_ff;

// // // // // // always @(posedge clk) begin
// // // // // //     for(i = 0; i < 4; i = i + 1) begin
// // // // // //         H_ff_ff[i] <= H_ff[i]; 
// // // // // //         V_ff_ff[i] <= V_ff[i]; 
// // // // // //         D1_ff_ff[i] <= D1_ff[i]; 
// // // // // //         D2_ff_ff[i] <= D2_ff[i];
// // // // // //     end
// // // // // //     med_H_ff <= med_H; 
// // // // // //     med_V_ff <= med_V; 
// // // // // //     med_D1_ff <= med_D1; 
// // // // // //     med_D2_ff <= med_D2;
// // // // // //     P_ff_ff <= P_ff;
// // // // // //     dpc_valid_ff_ff <= dpc_valid_ff;
// // // // // // end

// // // // // // wire [11:0] err_H0, err_H1, err_H2, err_H3;
// // // // // // wire [11:0] err_V0, err_V1, err_V2, err_V3;
// // // // // // wire [11:0] err_D1_0, err_D1_1, err_D1_2, err_D1_3;
// // // // // // wire [11:0] err_D2_0, err_D2_1, err_D2_2, err_D2_3;

// // // // // // sad sad_h0 (.A(H_ff_ff[0]), .B(med_H_ff), .abs(err_H0)); 
// // // // // // sad sad_h1 (.A(H_ff_ff[1]), .B(med_H_ff), .abs(err_H1));
// // // // // // sad sad_h2 (.A(H_ff_ff[2]), .B(med_H_ff), .abs(err_H2)); 
// // // // // // sad sad_h3 (.A(H_ff_ff[3]), .B(med_H_ff), .abs(err_H3));
// // // // // // wire [13:0] SAD_H = err_H0 + err_H1 + err_H2 + err_H3;

// // // // // // sad sad_v0 (.A(V_ff_ff[0]), .B(med_V_ff), .abs(err_V0)); 
// // // // // // sad sad_v1 (.A(V_ff_ff[1]), .B(med_V_ff), .abs(err_V1));
// // // // // // sad sad_v2 (.A(V_ff_ff[2]), .B(med_V_ff), .abs(err_V2)); 
// // // // // // sad sad_v3 (.A(V_ff_ff[3]), .B(med_V_ff), .abs(err_V3));
// // // // // // wire [13:0] SAD_V = err_V0 + err_V1 + err_V2 + err_V3;

// // // // // // sad sad_d1_0 (.A(D1_ff_ff[0]), .B(med_D1_ff), .abs(err_D1_0)); 
// // // // // // sad sad_d1_1 (.A(D1_ff_ff[1]), .B(med_D1_ff), .abs(err_D1_1));
// // // // // // sad sad_d1_2 (.A(D1_ff_ff[2]), .B(med_D1_ff), .abs(err_D1_2)); 
// // // // // // sad sad_d1_3 (.A(D1_ff_ff[3]), .B(med_D1_ff), .abs(err_D1_3));
// // // // // // wire [13:0] SAD_D1 = err_D1_0 + err_D1_1 + err_D1_2 + err_D1_3;

// // // // // // sad sad_d2_0 (.A(D2_ff_ff[0]), .B(med_D2_ff), .abs(err_D2_0)); 
// // // // // // sad sad_d2_1 (.A(D2_ff_ff[1]), .B(med_D2_ff), .abs(err_D2_1));
// // // // // // sad sad_d2_2 (.A(D2_ff_ff[2]), .B(med_D2_ff), .abs(err_D2_2)); 
// // // // // // sad sad_d2_3 (.A(D2_ff_ff[3]), .B(med_D2_ff), .abs(err_D2_3));
// // // // // // wire [13:0] SAD_D2 = err_D2_0 + err_D2_1 + err_D2_2 + err_D2_3;

// // // // // // // // ====================== DPC =====================

// // // // // // reg  [3:0] dem_cnt_x, dem_cnt_y;

// // // // // // always @(posedge clk or negedge rst_n) begin
// // // // // //     if (~rst_n) begin
// // // // // //         dem_cnt <= 0; 
// // // // // //         dem_cnt_x <= 0; 
// // // // // //         dem_cnt_y <= 0;
// // // // // //     end
// // // // // //     else if (cs == DEM) begin
// // // // // //         dem_cnt <= dem_cnt + 1;
// // // // // //         if (dem_cnt_x == 15) begin
// // // // // //             dem_cnt_x <= 0; 
// // // // // //             dem_cnt_y <= 
// // // // // //             dem_cnt_y + 1;
// // // // // //         end
// // // // // //         else 
// // // // // //             dem_cnt_x <= dem_cnt_x + 1;
// // // // // //     end
// // // // // //     else 
// // // // // //         dem_cnt <= 0;
// // // // // // end

// // // // // // reg [13:0] SAD_H_ff, SAD_V_ff, SAD_D1_ff, SAD_D2_ff;
// // // // // // reg [11:0] med_H_ff_ff, med_V_ff_ff, med_D1_ff_ff, med_D2_ff_ff;
// // // // // // reg [11:0] P_ff_ff_ff;
// // // // // // reg        dpc_valid_ff_ff_ff;

// // // // // // always @(posedge clk) begin
// // // // // //     SAD_H_ff  <= SAD_H;  
// // // // // //     SAD_V_ff  <= SAD_V; 
// // // // // //     SAD_D1_ff <= SAD_D1; 
// // // // // //     SAD_D2_ff <= SAD_D2;
// // // // // //     med_H_ff_ff  <= med_H_ff;  
// // // // // //     med_V_ff_ff  <= med_V_ff; 
// // // // // //     med_D1_ff_ff <= med_D1_ff; 
// // // // // //     med_D2_ff_ff <= med_D2_ff;
// // // // // //     P_ff_ff_ff   <= P_ff_ff;
// // // // // //     dpc_valid_ff_ff_ff <= dpc_valid_ff_ff;
// // // // // // end

// // // // // // wire cmp_HV = (SAD_H_ff <= SAD_V_ff);
// // // // // // wire [13:0] min_SAD_HV = cmp_HV ? SAD_H_ff : SAD_V_ff;
// // // // // // wire [11:0] target_HV  = cmp_HV ? med_H_ff_ff : med_V_ff_ff;

// // // // // // wire cmp_D1D2 = (SAD_D1_ff <= SAD_D2_ff);
// // // // // // wire [13:0] min_SAD_D1D2 = cmp_D1D2 ? SAD_D1_ff : SAD_D2_ff;
// // // // // // wire [11:0] target_D1D2  = cmp_D1D2 ? med_D1_ff_ff : med_D2_ff_ff;

// // // // // // wire cmp_final = (min_SAD_HV <= min_SAD_D1D2);
// // // // // // wire [11:0] Target = cmp_final ? target_HV : target_D1D2;

// // // // // // wire replace_cond = ({1'b0, P_ff_ff_ff} > {1'b0, Target} + 320) || 
// // // // // //                     ({1'b0, Target} > {1'b0, P_ff_ff_ff} + 320);

// // // // // // wire [11:0] dpc_out = replace_cond ? Target : P_ff_ff_ff;

// // // // // // reg [11:0] dpc_fifo [0:235];

// // // // // // always @(posedge clk) begin
// // // // // //     for (i = 235; i > 0; i = i - 1) 
// // // // // //         dpc_fifo[i] <= dpc_fifo[i - 1];

// // // // // //     dpc_fifo[0] <= dpc_out;
// // // // // // end

// // // // // // // ============================ dem ===================================

// // // // // // wire [1:0] dem_color_id = {dem_cnt_y[0], dem_cnt_x[0]};

// // // // // // wire [11:0] raw_C  = dpc_fifo[213];
// // // // // // wire [11:0] raw_E  = dpc_fifo[212];
// // // // // // wire [11:0] raw_W  = dpc_fifo[214];
// // // // // // wire [11:0] raw_S  = dpc_fifo[197];
// // // // // // wire [11:0] raw_SE = dpc_fifo[196];
// // // // // // wire [11:0] raw_SW = dpc_fifo[198];
// // // // // // wire [11:0] raw_N  = dpc_fifo[229];
// // // // // // wire [11:0] raw_NE = dpc_fifo[228];
// // // // // // wire [11:0] raw_NW = dpc_fifo[230];

// // // // // // wire is_top    = (dem_cnt_y == 0);
// // // // // // wire is_bottom = (dem_cnt_y == 15);
// // // // // // wire is_left   = (dem_cnt_x == 0);
// // // // // // wire is_right  = (dem_cnt_x == 15);

// // // // // // wire [11:0] C = raw_C;
// // // // // // wire [11:0] W = is_left   ? raw_E : raw_W;
// // // // // // wire [11:0] E = is_right  ? raw_W : raw_E;
// // // // // // wire [11:0] N = is_top    ? raw_S : raw_N;
// // // // // // wire [11:0] S = is_bottom ? raw_N : raw_S;

// // // // // // wire [11:0] NW = (is_top & is_left)  ? raw_SE :
// // // // // //                  (is_top)            ? raw_SW :
// // // // // //                  (is_left)           ? raw_NE : raw_NW;

// // // // // // wire [11:0] NE = (is_top & is_right) ? raw_SW :
// // // // // //                  (is_top)            ? raw_SE :
// // // // // //                  (is_right)          ? raw_NW : raw_NE;

// // // // // // wire [11:0] SW = (is_bottom & is_left) ? raw_NE :
// // // // // //                  (is_bottom)           ? raw_NW :
// // // // // //                  (is_left)             ? raw_SE : raw_SW;

// // // // // // wire [11:0] SE = (is_bottom & is_right) ? raw_NW :
// // // // // //                  (is_bottom)            ? raw_NE :
// // // // // //                  (is_right)             ? raw_SW : raw_SE;


// // // // // // wire [12:0] total_ns = N + S; 
// // // // // // wire [12:0] total_we = W + E; 

// // // // // // wire [13:0] total_nswe  = total_ns + total_we; 
// // // // // // wire [13:0] total_other = (NW + NE) + (SW + SE); 

// // // // // // wire [11:0] avg_nswe   = total_nswe[13:2]; 
// // // // // // wire [11:0] avg_pother = total_other[13:2];
// // // // // // wire [11:0] avg_ns     = total_ns[12:1];     
// // // // // // wire [11:0] avg_we     = total_we[12:1];     

// // // // // // reg [11:0] r_interp, g_interp, b_interp;

// // // // // // always @(*) begin
// // // // // //     case (dem_color_id)
// // // // // //         2'b00: begin r_interp = C;          g_interp = avg_nswe; b_interp = avg_pother; end 
// // // // // //         2'b01: begin r_interp = avg_we;     g_interp = C;        b_interp = avg_ns;     end 
// // // // // //         2'b10: begin r_interp = avg_ns;     g_interp = C;        b_interp = avg_we;     end 
// // // // // //         2'b11: begin r_interp = avg_pother; g_interp = avg_nswe; b_interp = C;          end 
// // // // // //     endcase
// // // // // // end

// // // // // // reg [11:0] r_dem_ff, g_dem_ff, b_dem_ff;
// // // // // // reg        dem_valid_ff;

// // // // // // always @(posedge clk) begin
// // // // // //     r_dem_ff     <= r_interp;
// // // // // //     g_dem_ff     <= g_interp;
// // // // // //     b_dem_ff     <= b_interp;
// // // // // //     dem_valid_ff <= (cs == DEM);
// // // // // // end

// // // // // // // ========================== CCM =====================================

// // // // // // wire signed [13:0] r_s = $signed({2'b0, r_dem_ff});
// // // // // // wire signed [13:0] g_s = $signed({2'b0, g_dem_ff});
// // // // // // wire signed [13:0] b_s = $signed({2'b0, b_dem_ff});

// // // // // // localparam signed [14:0] C_err = 15'sd1150; 
// // // // // // localparam signed [14:0] C_SUB  = -15'sd50;

// // // // // // wire signed [15:0] rgb_sum = r_s + g_s + b_s;
// // // // // // wire signed [26:0] shared_sub_ffult = rgb_sum * C_SUB;

// // // // // // wire signed [26:0] r_raw = (r_s * C_err) + shared_sub_ffult + 27'sd512;
// // // // // // wire signed [26:0] g_raw = (g_s * C_err) + shared_sub_ffult + 27'sd512;
// // // // // // wire signed [26:0] b_raw = (b_s * C_err) + shared_sub_ffult + 27'sd512;

// // // // // // wire signed [26:0] r_shift = r_raw >>> 10;
// // // // // // wire signed [26:0] g_shift = g_raw >>> 10;
// // // // // // wire signed [26:0] b_shift = b_raw >>> 10;

// // // // // // wire r_is_neg = r_shift[26];
// // // // // // wire g_is_neg = g_shift[26];
// // // // // // wire b_is_neg = b_shift[26];

// // // // // // wire [26:0] r_shift_u = $unsigned(r_shift);
// // // // // // wire [26:0] g_shift_u = $unsigned(g_shift);
// // // // // // wire [26:0] b_shift_u = $unsigned(b_shift);

// // // // // // wire r_is_over = (|r_shift_u[25:12]) & ~r_is_neg;
// // // // // // wire g_is_over = (|g_shift_u[25:12]) & ~g_is_neg;
// // // // // // wire b_is_over = (|b_shift_u[25:12]) & ~b_is_neg;

// // // // // // wire [12:0] r_ccm = r_is_neg ? 0 : (r_is_over ? 4095 : r_shift_u[12:0]);
// // // // // // wire [12:0] g_ccm = g_is_neg ? 0 : (g_is_over ? 4095 : g_shift_u[12:0]);
// // // // // // wire [12:0] b_ccm = b_is_neg ? 0 : (b_is_over ? 4095 : b_shift_u[12:0]);

// // // // // // always @(posedge clk or negedge rst_n) begin
// // // // // //     if (~rst_n) begin
// // // // // //         out_valid <= 0; 
// // // // // //         r_out <= 0; 
// // // // // //         g_out <= 0; 
// // // // // //         b_out <= 0;
// // // // // //     end
// // // // // //     else if (dem_valid_ff) begin 
// // // // // //         out_valid <= 1;
// // // // // //         r_out     <= r_ccm; 
// // // // // //         g_out     <= g_ccm;
// // // // // //         b_out     <= b_ccm;
// // // // // //     end
// // // // // //     else begin
// // // // // //         out_valid <= 0; 
// // // // // //         r_out <= 0; 
// // // // // //         g_out <= 0; 
// // // // // //         b_out <= 0;
// // // // // //     end
// // // // // // end

// // // // // // endmodule

// // // // // // module median (
// // // // // //     input  [11:0] A, B, C, D,
// // // // // //     output [11:0] median
// // // // // // );
// // // // // //     wire [11:0] max1, min1, max2, min2;
// // // // // //     assign {max1, min1} = (A > B) ? {A, B} : {B, A};
// // // // // //     assign {max2, min2} = (C > D) ? {C, D} : {D, C};

// // // // // //     wire [11:0] mid_low  = (min1 > min2) ? min1 : min2;
// // // // // //     wire [11:0] mid_high = (max1 < max2) ? max1 : max2;

// // // // // //     wire [12:0] safe_sum = {1'b0, mid_low} + {1'b0, mid_high};
// // // // // //     assign median = safe_sum[12:1];

// // // // // // endmodule

// // // // // // module sad (
// // // // // //     input  [11:0] A, B,
// // // // // //     output [11:0] abs
// // // // // // );
// // // // // //     wire [12:0] err = {1'b0, A} - {1'b0, B}; 
// // // // // //     wire sign = err[12]; 
// // // // // //     assign abs = (err[11:0] ^ {12{sign}}) + sign;
// // // // // // endmodule
























// // // // // // module ISP (
// // // // // //     input         clk,
// // // // // //     input         rst_n,
// // // // // //     input         in_valid,
// // // // // //     input  [12:0] in,
// // // // // //     input         param_valid,
// // // // // //     input  [12:0] param_gain,

// // // // // //     output reg        out_valid,
// // // // // //     output reg [12:0] r_out,
// // // // // //     output reg [12:0] g_out,
// // // // // //     output reg [12:0] b_out
// // // // // // );

// // // // // // //==============================
// // // // // // //   Design
// // // // // // //==============================
// // // // // // localparam IDLE  = 2'd0;
// // // // // // localparam INPUT = 2'd1;
// // // // // // localparam DPC   = 2'd2;
// // // // // // localparam DEM   = 2'd3;

// // // // // // integer i, j;

// // // // // // reg  [3:0] x_cnt, y_cnt; 
// // // // // // reg  [3:0] dpc_cnt_x, dpc_cnt_y;
// // // // // // reg  [7:0] dem_cnt;

// // // // // // reg  [1:0] cs, ns;

// // // // // // always @(posedge clk or negedge rst_n) begin
// // // // // //     if (~rst_n) cs <= IDLE;
// // // // // //     else        cs <= ns;
// // // // // // end

// // // // // // always @(*) begin
// // // // // //     ns = cs; 
// // // // // //     case (cs)
// // // // // //         IDLE:  ns = (in_valid) ? INPUT : IDLE;
// // // // // //         INPUT: ns = (x_cnt == 5 && y_cnt == 2) ? DPC : INPUT;

// // // // // //         // 原本 13,13，太晚 5 cycles
// // // // // //         DPC:   ns = (dpc_cnt_x == 6 && dpc_cnt_y == 13) ? DEM : DPC;

// // // // // //         DEM:   ns = (dem_cnt == 255) ? IDLE : DEM;
// // // // // //     endcase
// // // // // // end

// // // // // // reg [2:0] param_x_cnt, param_y_cnt; 
// // // // // // reg [1:0] next_gain;

// // // // // // always @(posedge clk or negedge rst_n) begin
// // // // // //     if (~rst_n) begin
// // // // // //         param_x_cnt <= 0; 
// // // // // //         param_y_cnt <= 0; 
// // // // // //         next_gain <= 0;
// // // // // //     end
// // // // // //     else if (param_valid) begin
// // // // // //         if (param_x_cnt == 5 && param_y_cnt == 5) begin
// // // // // //             param_x_cnt <= 0; 
// // // // // //             param_y_cnt <= 0; 
// // // // // //             next_gain <= next_gain + 1;
// // // // // //         end
// // // // // //         else if (param_x_cnt == 5) begin 
// // // // // //             param_x_cnt <= 3'd0; 
// // // // // //             param_y_cnt <= param_y_cnt + 3'd1;
// // // // // //         end
// // // // // //         else
// // // // // //             param_x_cnt <= param_x_cnt + 3'd1;
// // // // // //     end
// // // // // // end

// // // // // // reg  [12:0] r_matrix  [0:5][0:5];
// // // // // // reg  [12:0] gr_matrix [0:5][0:5];
// // // // // // reg  [12:0] gb_matrix [0:5][0:5];
// // // // // // reg  [12:0] b_matrix  [0:5][0:5];

// // // // // // always @(posedge clk or negedge rst_n) begin
// // // // // //     if (~rst_n) begin
// // // // // //         for (i = 0; i < 6; i = i + 1) 
// // // // // //         for (j = 0; j < 6; j = j + 1) begin
// // // // // //             r_matrix[i][j]  <= 0; 
// // // // // //             gr_matrix[i][j] <= 0;
// // // // // //             gb_matrix[i][j] <= 0; 
// // // // // //             b_matrix[i][j]  <= 0;
// // // // // //         end
// // // // // //     end
// // // // // //     else if (param_valid) begin
// // // // // //         case (next_gain)
// // // // // //             0: r_matrix[param_y_cnt][param_x_cnt]  <= param_gain;
// // // // // //             1: gr_matrix[param_y_cnt][param_x_cnt] <= param_gain;
// // // // // //             2: gb_matrix[param_y_cnt][param_x_cnt] <= param_gain;
// // // // // //             3: b_matrix[param_y_cnt][param_x_cnt]  <= param_gain;
// // // // // //         endcase
// // // // // //     end
// // // // // // end

// // // // // // // ====================== BLC =====================
// // // // // // always @(posedge clk or negedge rst_n) begin
// // // // // //     if (~rst_n) begin
// // // // // //         x_cnt <= 0; 
// // // // // //         y_cnt <= 0;
// // // // // //     end
// // // // // //     else if (in_valid) begin
// // // // // //         if (x_cnt == 15) begin 
// // // // // //             x_cnt <= 0; 
// // // // // //             y_cnt <= y_cnt + 1;
// // // // // //         end
// // // // // //         else 
// // // // // //             x_cnt <= x_cnt + 1;
// // // // // //     end
// // // // // // end

// // // // // // wire [1:0] color_id = {y_cnt[0], x_cnt[0]};
// // // // // // reg  [6:0] black_level;

// // // // // // always @(*) begin
// // // // // //     case (color_id)
// // // // // //         2'b00: black_level = 64; 
// // // // // //         2'b01: black_level = 48; 
// // // // // //         2'b10: black_level = 52; 
// // // // // //         2'b11: black_level = 72; 
// // // // // //     endcase
// // // // // // end

// // // // // // wire [13:0] in_ext = {1'b0, in};

// // // // // // wire [13:0] sub_r  = in_ext - 14'd64;
// // // // // // wire [13:0] sub_gr = in_ext - 14'd48;
// // // // // // wire [13:0] sub_gb = in_ext - 14'd52;
// // // // // // wire [13:0] sub_b  = in_ext - 14'd72;

// // // // // // reg [13:0] sub_result;

// // // // // // always @(*) begin
// // // // // //     case (color_id)
// // // // // //         2'b00: sub_result = sub_r;
// // // // // //         2'b01: sub_result = sub_gr;
// // // // // //         2'b10: sub_result = sub_gb;
// // // // // //         2'b11: sub_result = sub_b;
// // // // // //     endcase
// // // // // // end

// // // // // // wire [12:0] i_blc = sub_result[13] ? 13'd0 : sub_result[12:0];

// // // // // // // ====================== LSC =====================
// // // // // // reg [2:0] x0, y0; 
// // // // // // reg [1:0] rx, ry;

// // // // // // always @(*) begin
// // // // // //     case (x_cnt)
// // // // // //         0, 1, 2:        begin x0 = 0; rx = x_cnt[1:0]; end
// // // // // //         3, 4, 5:        begin x0 = 1; rx = x_cnt - 3; end
// // // // // //         6, 7, 8:        begin x0 = 2; rx = x_cnt - 6; end
// // // // // //         9, 10, 11:      begin x0 = 3; rx = x_cnt - 9; end
// // // // // //         12, 13, 14, 15: begin x0 = 4; rx = (x_cnt >= 14) ? 2 : x_cnt - 12; end
// // // // // //         default:        begin x0 = 0; rx = 0; end
// // // // // //     endcase
// // // // // // end

// // // // // // always @(*) begin
// // // // // //     case (y_cnt)
// // // // // //         0, 1, 2:        begin y0 = 0; ry = y_cnt[1:0]; end
// // // // // //         3, 4, 5:        begin y0 = 1; ry = y_cnt - 3; end
// // // // // //         6, 7, 8:        begin y0 = 2; ry = y_cnt - 6; end
// // // // // //         9, 10, 11:      begin y0 = 3; ry = y_cnt - 9; end
// // // // // //         12, 13, 14, 15: begin y0 = 4; ry = (y_cnt >= 14) ? 2 : y_cnt - 12; end
// // // // // //         default:        begin y0 = 0; ry = 0; end
// // // // // //     endcase
// // // // // // end

// // // // // // reg [12:0] g00, g01, g10, g11;
// // // // // // reg [13:0] g0110, g0011, g0010, g0001;

// // // // // // always @(*) begin
// // // // // //     case (color_id)
// // // // // //         2'b00: begin
// // // // // //             g00 = r_matrix[y0][x0];
// // // // // //             g01 = r_matrix[y0][x0 + 3'd1];
// // // // // //             g10 = r_matrix[y0 + 3'd1][x0];
// // // // // //             g11 = r_matrix[y0 + 3'd1][x0 + 3'd1];
// // // // // //         end
// // // // // //         2'b01: begin
// // // // // //             g00 = gr_matrix[y0][x0];
// // // // // //             g01 = gr_matrix[y0][x0 + 3'd1];
// // // // // //             g10 = gr_matrix[y0 + 3'd1][x0];
// // // // // //             g11 = gr_matrix[y0 + 3'd1][x0 + 3'd1];
// // // // // //         end
// // // // // //         2'b10: begin
// // // // // //             g00 = gb_matrix[y0][x0];
// // // // // //             g01 = gb_matrix[y0][x0 + 3'd1];
// // // // // //             g10 = gb_matrix[y0 + 3'd1][x0];
// // // // // //             g11 = gb_matrix[y0 + 3'd1][x0 + 3'd1];
// // // // // //         end
// // // // // //         2'b11: begin
// // // // // //             g00 = b_matrix[y0][x0];
// // // // // //             g01 = b_matrix[y0][x0 + 3'd1];
// // // // // //             g10 = b_matrix[y0 + 3'd1][x0];
// // // // // //             g11 = b_matrix[y0 + 3'd1][x0 + 3'd1];
// // // // // //         end
// // // // // //     endcase

// // // // // //     g0110 = g01 + g10;
// // // // // //     g0011 = g00 + g11;
// // // // // //     g0010 = g00 + g10; 
// // // // // //     g0001 = g00 + g01; 
// // // // // // end

// // // // // // reg [12:0] m_29241, m_7225;
// // // // // // reg [13:0] m_14535; 

// // // // // // always @(*) begin
// // // // // //     m_29241 = 0; 
// // // // // //     m_14535 = 0; 
// // // // // //     m_7225  = 0;
// // // // // //     case ({rx, ry})
// // // // // //         4'b0001: begin m_29241 = g00; m_14535 = g0010; m_7225 = g10; end
// // // // // //         4'b0010: begin m_29241 = g10; m_14535 = g0010; m_7225 = g00; end
// // // // // //         4'b0100: begin m_29241 = g00; m_14535 = g0001; m_7225 = g01; end
// // // // // //         4'b1000: begin m_29241 = g01; m_14535 = g0001; m_7225 = g00; end
// // // // // //         4'b0101: begin m_29241 = g00; m_14535 = g0110; m_7225 = g11; end
// // // // // //         4'b0110: begin m_29241 = g10; m_14535 = g0011; m_7225 = g01; end
// // // // // //         4'b1001: begin m_29241 = g01; m_14535 = g0011; m_7225 = g10; end
// // // // // //         4'b1010: begin m_29241 = g11; m_14535 = g0110; m_7225 = g00; end
// // // // // //     endcase
// // // // // // end

// // // // // // reg [12:0] m_29241_ff, m_7225_ff, g00_ff;
// // // // // // reg [13:0] m_14535_ff;
// // // // // // reg        rx_ry_zero_ff;
// // // // // // reg [12:0] i_blc_ff;
// // // // // // reg        in_valid_ff;

// // // // // // always @(posedge clk) begin
// // // // // //     m_29241_ff <= m_29241; 
// // // // // //     m_14535_ff <= m_14535; 
// // // // // //     m_7225_ff  <= m_7225;
// // // // // //     g00_ff     <= g00;
// // // // // //     rx_ry_zero_ff <= ({rx, ry} == 0);
// // // // // //     i_blc_ff   <= i_blc;
// // // // // //     in_valid_ff<= in_valid;
// // // // // // end

// // // // // // // 數學優化：將四捨五入的進位提早化為常數 32768 (即 1<<15) 融入加法樹中
// // // // // // wire [29:0] gxy_sum_opt = (m_29241_ff * 29241) + 
// // // // // //                           (m_14535_ff * 14535) + 
// // // // // //                           (m_7225_ff  * 7225) + 
// // // // // //                           30'd32768; 

// // // // // // // 省略了一個 14-bit 加法器的延遲 (省下 >0.2ns，足以吃掉 -0.06ns 的 slack)
// // // // // // wire [13:0] gxy_calc = gxy_sum_opt[29:16];
// // // // // // wire [13:0] gxy = (rx_ry_zero_ff) ? {1'b0, g00_ff} : gxy_calc;

// // // // // // reg [13:0] gxy_ff;
// // // // // // reg [12:0] i_blc_ff_ff;
// // // // // // reg        in_valid_ff_ff;

// // // // // // always @(posedge clk) begin
// // // // // //     gxy_ff         <= gxy;
// // // // // //     i_blc_ff_ff    <= i_blc_ff; 
// // // // // //     in_valid_ff_ff <= in_valid_ff; 
// // // // // // end

// // // // // // wire [25:0] p_sum_w = gxy_ff * i_blc_ff_ff;

// // // // // // reg [25:0] p_sum_r;
// // // // // // reg        pp_valid_r;

// // // // // // always @(posedge clk or negedge rst_n) begin
// // // // // //     if (~rst_n) begin
// // // // // //         p_sum_r    <= 26'd0;
// // // // // //         pp_valid_r <= 1'b0;
// // // // // //     end
// // // // // //     else begin
// // // // // //         p_sum_r    <= p_sum_w;
// // // // // //         pp_valid_r <= in_valid_ff_ff;
// // // // // //     end
// // // // // // end

// // // // // // wire [16:0] p_sum_round = p_sum_r[25:10] + p_sum_r[9];
// // // // // // wire p_is_over = |p_sum_round[16:12];
// // // // // // wire [11:0] pp_xy = p_is_over ? 12'd4095 : p_sum_round[11:0];

// // // // // // // ====================== DPC =====================

// // // // // // reg [11:0] lb0 [0:15]; 
// // // // // // reg [11:0] lb1 [0:15];
// // // // // // reg [11:0] lb2 [0:15]; 
// // // // // // reg [11:0] lb3 [0:15];
// // // // // // reg [11:0] lb4 [0:4]; 

// // // // // // always @(posedge clk) begin
// // // // // //     if (pp_valid_r || cs == DPC || cs == DEM) begin
// // // // // //         for (i = 15; i > 0; i = i - 1) begin
// // // // // //             lb3[i] <= lb3[i - 1]; 
// // // // // //             lb2[i] <= lb2[i - 1];
// // // // // //             lb1[i] <= lb1[i - 1]; 
// // // // // //             lb0[i] <= lb0[i - 1];
// // // // // //         end
// // // // // //         lb3[0] <= lb2[15]; 
// // // // // //         lb2[0] <= lb1[15];
// // // // // //         lb1[0] <= lb0[15]; 
// // // // // //         lb0[0] <= (pp_valid_r) ? pp_xy : 12'd0;
        
// // // // // //         for (i = 4; i > 0; i = i - 1) 
// // // // // //             lb4[i] <= lb4[i - 1];
            
// // // // // //         lb4[0] <= lb3[15];
// // // // // //     end
// // // // // //     else begin
// // // // // //         for (i = 0; i < 16; i = i + 1) begin
// // // // // //             lb0[i] <= 0; 
// // // // // //             lb1[i] <= 0; 
// // // // // //             lb2[i] <= 0; 
// // // // // //             lb3[i] <= 0;
// // // // // //         end
// // // // // //         for (i = 0; i < 5; i = i + 1) 
// // // // // //             lb4[i] <= 0;
// // // // // //     end
// // // // // // end

// // // // // // reg [11:0] px_mat [0:4][0:4];

// // // // // // always @(*) begin
// // // // // //     for (i = 0; i < 5; i = i + 1) begin
// // // // // //         px_mat[4][i] = lb0[4 - i];
// // // // // //         px_mat[3][i] = lb1[4 - i];
// // // // // //         px_mat[2][i] = lb2[4 - i];
// // // // // //         px_mat[1][i] = lb3[4 - i];
// // // // // //         px_mat[0][i] = lb4[4 - i];
// // // // // //     end
// // // // // // end

// // // // // // // ====================== DPC  =====================

// // // // // // always @(posedge clk) begin
// // // // // //     if (cs == DPC || cs == DEM) begin
// // // // // //         if (dpc_cnt_x == 15) begin
// // // // // //             dpc_cnt_x <= 0;
// // // // // //             if (dpc_cnt_y == 15) 
// // // // // //                 dpc_cnt_y <= 0;
// // // // // //             else 
// // // // // //                 dpc_cnt_y <= dpc_cnt_y + 1;
// // // // // //         end
// // // // // //         else 
// // // // // //             dpc_cnt_x <= dpc_cnt_x + 1;
// // // // // //     end
// // // // // //     else begin
// // // // // //         dpc_cnt_x <= 0; 
// // // // // //         dpc_cnt_y <= 0;
// // // // // //     end
// // // // // // end

// // // // // // reg [2:0] px [0:4];
// // // // // // reg [2:0] py [0:4];

// // // // // // always @(*) begin
// // // // // //     px[0] = (dpc_cnt_x == 4'd0)  ? 3'd4 : (dpc_cnt_x == 4'd1)  ? 3'd2 : 3'd0;
// // // // // //     px[1] = (dpc_cnt_x == 4'd0)  ? 3'd3 : 3'd1; 
// // // // // //     px[2] = 3'd2; 
// // // // // //     px[3] = (dpc_cnt_x == 4'd15) ? 3'd1 : 3'd3; 
// // // // // //     px[4] = (dpc_cnt_x == 4'd15) ? 3'd0 : (dpc_cnt_x == 4'd14) ? 3'd2 : 3'd4;

// // // // // //     py[0] = (dpc_cnt_y == 4'd0)  ? 3'd4 : (dpc_cnt_y == 4'd1)  ? 3'd2 : 3'd0;
// // // // // //     py[1] = (dpc_cnt_y == 4'd0)  ? 3'd3 : 3'd1; 
// // // // // //     py[2] = 3'd2; 
// // // // // //     py[3] = (dpc_cnt_y == 4'd15) ? 3'd1 : 3'd3; 
// // // // // //     py[4] = (dpc_cnt_y == 4'd15) ? 3'd0 : (dpc_cnt_y == 4'd14) ? 3'd2 : 3'd4;
// // // // // // end

// // // // // // reg [11:0] p_row_0 [0:4]; 
// // // // // // reg [11:0] p_row_1 [0:4]; 
// // // // // // reg [11:0] p_row_2 [0:4];
// // // // // // reg [11:0] p_row_3 [0:4]; 
// // // // // // reg [11:0] p_row_4 [0:4];

// // // // // // always @(*) begin
// // // // // //     for(i = 0; i < 5; i = i + 1) begin
// // // // // //         p_row_0[i] = px_mat[py[0]][i]; 
// // // // // //         p_row_1[i] = px_mat[py[1]][i];
// // // // // //         p_row_2[i] = px_mat[py[2]][i]; 
// // // // // //         p_row_3[i] = px_mat[py[3]][i];
// // // // // //         p_row_4[i] = px_mat[py[4]][i];
// // // // // //     end
// // // // // // end

// // // // // // reg [11:0] H  [0:3];
// // // // // // reg [11:0] V  [0:3];
// // // // // // reg [11:0] D1 [0:3];
// // // // // // reg [11:0] D2 [0:3];

// // // // // // always @(*) begin
// // // // // //     H[0]  = p_row_2[px[0]]; 
// // // // // //     H[1]  = p_row_2[px[1]]; 
// // // // // //     H[2]  = p_row_2[px[3]]; 
// // // // // //     H[3]  = p_row_2[px[4]];

// // // // // //     V[0]  = p_row_0[px[2]]; 
// // // // // //     V[1]  = p_row_1[px[2]]; 
// // // // // //     V[2]  = p_row_3[px[2]]; 
// // // // // //     V[3]  = p_row_4[px[2]];

// // // // // //     D1[0] = p_row_0[px[0]]; 
// // // // // //     D1[1] = p_row_1[px[1]]; 
// // // // // //     D1[2] = p_row_3[px[3]]; 
// // // // // //     D1[3] = p_row_4[px[4]];

// // // // // //     D2[0] = p_row_0[px[4]]; 
// // // // // //     D2[1] = p_row_1[px[3]]; 
// // // // // //     D2[2] = p_row_3[px[1]]; 
// // // // // //     D2[3] = p_row_4[px[0]];
// // // // // // end

// // // // // // reg [11:0] H_ff[0:3], V_ff[0:3], D1_ff[0:3], D2_ff[0:3];
// // // // // // reg [11:0] P_ff;
// // // // // // reg        dpc_valid_ff;

// // // // // // always @(posedge clk) begin
// // // // // //     for(i = 0; i < 4; i = i + 1) begin
// // // // // //         H_ff[i] <= H[i]; 
// // // // // //         V_ff[i] <= V[i]; 
// // // // // //         D1_ff[i] <= D1[i]; 
// // // // // //         D2_ff[i] <= D2[i];
// // // // // //     end
// // // // // //     P_ff <= p_row_2[px[2]];
// // // // // //     dpc_valid_ff <= (cs == DPC || cs == DEM);
// // // // // // end

// // // // // // wire [11:0] med_H, med_V, med_D1, med_D2;

// // // // // // // median calc_med_H (.A(H_ff[0]), .B(H_ff[1]), .C(H_ff[2]), .D(H_ff[3]), .median(med_H));
// // // // // // // median calc_med_V (.A(V_ff[0]), .B(V_ff[1]), .C(V_ff[2]), .D(V_ff[3]), .median(med_V));
// // // // // // // median calc_med_D1(.A(D1_ff[0]),.B(D1_ff[1]),.C(D1_ff[2]),.D(D1_ff[3]),.median(med_D1));
// // // // // // // median calc_med_D2(.A(D2_ff[0]),.B(D2_ff[1]),.C(D2_ff[2]),.D(D2_ff[3]),.median(med_D2));

// // // // // // median_pipe calc_med_H (
// // // // // //     .clk(clk), .rst_n(rst_n),
// // // // // //     .A(H_ff[0]), .B(H_ff[1]), .C(H_ff[2]), .D(H_ff[3]),
// // // // // //     .median(med_H)
// // // // // // );

// // // // // // median_pipe calc_med_V (
// // // // // //     .clk(clk), .rst_n(rst_n),
// // // // // //     .A(V_ff[0]), .B(V_ff[1]), .C(V_ff[2]), .D(V_ff[3]),
// // // // // //     .median(med_V)
// // // // // // );

// // // // // // median_pipe calc_med_D1 (
// // // // // //     .clk(clk), .rst_n(rst_n),
// // // // // //     .A(D1_ff[0]), .B(D1_ff[1]), .C(D1_ff[2]), .D(D1_ff[3]),
// // // // // //     .median(med_D1)
// // // // // // );

// // // // // // median_pipe calc_med_D2 (
// // // // // //     .clk(clk), .rst_n(rst_n),
// // // // // //     .A(D2_ff[0]), .B(D2_ff[1]), .C(D2_ff[2]), .D(D2_ff[3]),
// // // // // //     .median(med_D2)
// // // // // // );

// // // // // // reg [11:0] H_ff_d[0:3], V_ff_d[0:3], D1_ff_d[0:3], D2_ff_d[0:3];
// // // // // // reg [11:0] P_ff_d;
// // // // // // reg        dpc_valid_ff_d;

// // // // // // reg [11:0] H_ff_ff[0:3], V_ff_ff[0:3], D1_ff_ff[0:3], D2_ff_ff[0:3];
// // // // // // reg [11:0] med_H_ff, med_V_ff, med_D1_ff, med_D2_ff;
// // // // // // reg [11:0] P_ff_ff;
// // // // // // reg        dpc_valid_ff_ff;

// // // // // // always @(posedge clk) begin
// // // // // //     for (i = 0; i < 4; i = i + 1) begin
// // // // // //         H_ff_d[i]  <= H_ff[i];
// // // // // //         V_ff_d[i]  <= V_ff[i];
// // // // // //         D1_ff_d[i] <= D1_ff[i];
// // // // // //         D2_ff_d[i] <= D2_ff[i];
// // // // // //     end
// // // // // //     P_ff_d         <= P_ff;
// // // // // //     dpc_valid_ff_d <= dpc_valid_ff;
// // // // // // end

// // // // // // always @(posedge clk) begin
// // // // // //     for(i = 0; i < 4; i = i + 1) begin
// // // // // //         H_ff_ff[i]  <= H_ff_d[i]; 
// // // // // //         V_ff_ff[i]  <= V_ff_d[i]; 
// // // // // //         D1_ff_ff[i] <= D1_ff_d[i]; 
// // // // // //         D2_ff_ff[i] <= D2_ff_d[i];
// // // // // //     end
// // // // // //     med_H_ff  <= med_H; 
// // // // // //     med_V_ff  <= med_V; 
// // // // // //     med_D1_ff <= med_D1; 
// // // // // //     med_D2_ff <= med_D2;
// // // // // //     P_ff_ff <= P_ff_d;
// // // // // //     dpc_valid_ff_ff <= dpc_valid_ff_d;
// // // // // // end

// // // // // // wire [11:0] err_H0, err_H1, err_H2, err_H3;
// // // // // // wire [11:0] err_V0, err_V1, err_V2, err_V3;
// // // // // // wire [11:0] err_D1_0, err_D1_1, err_D1_2, err_D1_3;
// // // // // // wire [11:0] err_D2_0, err_D2_1, err_D2_2, err_D2_3;

// // // // // // sad sad_h0 (.A(H_ff_ff[0]), .B(med_H_ff), .abs(err_H0)); 
// // // // // // sad sad_h1 (.A(H_ff_ff[1]), .B(med_H_ff), .abs(err_H1));
// // // // // // sad sad_h2 (.A(H_ff_ff[2]), .B(med_H_ff), .abs(err_H2)); 
// // // // // // sad sad_h3 (.A(H_ff_ff[3]), .B(med_H_ff), .abs(err_H3));
// // // // // // wire [13:0] SAD_H = err_H0 + err_H1 + err_H2 + err_H3;

// // // // // // sad sad_v0 (.A(V_ff_ff[0]), .B(med_V_ff), .abs(err_V0)); 
// // // // // // sad sad_v1 (.A(V_ff_ff[1]), .B(med_V_ff), .abs(err_V1));
// // // // // // sad sad_v2 (.A(V_ff_ff[2]), .B(med_V_ff), .abs(err_V2)); 
// // // // // // sad sad_v3 (.A(V_ff_ff[3]), .B(med_V_ff), .abs(err_V3));
// // // // // // wire [13:0] SAD_V = err_V0 + err_V1 + err_V2 + err_V3;

// // // // // // sad sad_d1_0 (.A(D1_ff_ff[0]), .B(med_D1_ff), .abs(err_D1_0)); 
// // // // // // sad sad_d1_1 (.A(D1_ff_ff[1]), .B(med_D1_ff), .abs(err_D1_1));
// // // // // // sad sad_d1_2 (.A(D1_ff_ff[2]), .B(med_D1_ff), .abs(err_D1_2)); 
// // // // // // sad sad_d1_3 (.A(D1_ff_ff[3]), .B(med_D1_ff), .abs(err_D1_3));
// // // // // // wire [13:0] SAD_D1 = err_D1_0 + err_D1_1 + err_D1_2 + err_D1_3;

// // // // // // sad sad_d2_0 (.A(D2_ff_ff[0]), .B(med_D2_ff), .abs(err_D2_0)); 
// // // // // // sad sad_d2_1 (.A(D2_ff_ff[1]), .B(med_D2_ff), .abs(err_D2_1));
// // // // // // sad sad_d2_2 (.A(D2_ff_ff[2]), .B(med_D2_ff), .abs(err_D2_2)); 
// // // // // // sad sad_d2_3 (.A(D2_ff_ff[3]), .B(med_D2_ff), .abs(err_D2_3));
// // // // // // wire [13:0] SAD_D2 = err_D2_0 + err_D2_1 + err_D2_2 + err_D2_3;

// // // // // // // // ====================== DPC =====================

// // // // // // reg  [3:0] dem_cnt_x, dem_cnt_y;

// // // // // // always @(posedge clk or negedge rst_n) begin
// // // // // //     if (~rst_n) begin
// // // // // //         dem_cnt <= 0; 
// // // // // //         dem_cnt_x <= 0; 
// // // // // //         dem_cnt_y <= 0;
// // // // // //     end
// // // // // //     else if (cs == DEM) begin
// // // // // //         dem_cnt <= dem_cnt + 1;
// // // // // //         if (dem_cnt_x == 15) begin
// // // // // //             dem_cnt_x <= 0; 
// // // // // //             dem_cnt_y <= 
// // // // // //             dem_cnt_y + 1;
// // // // // //         end
// // // // // //         else 
// // // // // //             dem_cnt_x <= dem_cnt_x + 1;
// // // // // //     end
// // // // // //     else 
// // // // // //         dem_cnt <= 0;
// // // // // // end

// // // // // // reg [13:0] SAD_H_ff, SAD_V_ff, SAD_D1_ff, SAD_D2_ff;
// // // // // // reg [11:0] med_H_ff_ff, med_V_ff_ff, med_D1_ff_ff, med_D2_ff_ff;
// // // // // // reg [11:0] P_ff_ff_ff;
// // // // // // reg        dpc_valid_ff_ff_ff;

// // // // // // always @(posedge clk) begin
// // // // // //     SAD_H_ff  <= SAD_H;  
// // // // // //     SAD_V_ff  <= SAD_V; 
// // // // // //     SAD_D1_ff <= SAD_D1; 
// // // // // //     SAD_D2_ff <= SAD_D2;
// // // // // //     med_H_ff_ff  <= med_H_ff;  
// // // // // //     med_V_ff_ff  <= med_V_ff; 
// // // // // //     med_D1_ff_ff <= med_D1_ff; 
// // // // // //     med_D2_ff_ff <= med_D2_ff;
// // // // // //     P_ff_ff_ff   <= P_ff_ff;
// // // // // //     dpc_valid_ff_ff_ff <= dpc_valid_ff_ff;
// // // // // // end

// // // // // // wire cmp_HV = (SAD_H_ff <= SAD_V_ff);
// // // // // // wire [13:0] min_SAD_HV = cmp_HV ? SAD_H_ff : SAD_V_ff;
// // // // // // wire [11:0] target_HV  = cmp_HV ? med_H_ff_ff : med_V_ff_ff;

// // // // // // wire cmp_D1D2 = (SAD_D1_ff <= SAD_D2_ff);
// // // // // // wire [13:0] min_SAD_D1D2 = cmp_D1D2 ? SAD_D1_ff : SAD_D2_ff;
// // // // // // wire [11:0] target_D1D2  = cmp_D1D2 ? med_D1_ff_ff : med_D2_ff_ff;

// // // // // // wire cmp_final = (min_SAD_HV <= min_SAD_D1D2);
// // // // // // wire [11:0] Target_w = cmp_final ? target_HV : target_D1D2;

// // // // // // reg [11:0] Target_r;
// // // // // // reg [11:0] P_replace_r;

// // // // // // always @(posedge clk or negedge rst_n) begin
// // // // // //     if (~rst_n) begin
// // // // // //         Target_r    <= 12'd0;
// // // // // //         P_replace_r <= 12'd0;
// // // // // //     end
// // // // // //     else begin
// // // // // //         Target_r    <= Target_w;
// // // // // //         P_replace_r <= P_ff_ff_ff;
// // // // // //     end
// // // // // // end

// // // // // // wire replace_cond = ({1'b0, P_replace_r} > {1'b0, Target_r} + 13'd320) || 
// // // // // //                     ({1'b0, Target_r} > {1'b0, P_replace_r} + 13'd320);

// // // // // // wire [11:0] dpc_out = replace_cond ? Target_r : P_replace_r;

// // // // // // reg [11:0] dpc_fifo [0:235];

// // // // // // always @(posedge clk) begin
// // // // // //     for (i = 235; i > 0; i = i - 1) 
// // // // // //         dpc_fifo[i] <= dpc_fifo[i - 1];

// // // // // //     dpc_fifo[0] <= dpc_out;
// // // // // // end

// // // // // // // ============================ dem ===================================

// // // // // // wire [1:0] dem_color_id = {dem_cnt_y[0], dem_cnt_x[0]};

// // // // // // wire [11:0] raw_C  = dpc_fifo[209];
// // // // // // wire [11:0] raw_E  = dpc_fifo[208];
// // // // // // wire [11:0] raw_W  = dpc_fifo[210];
// // // // // // wire [11:0] raw_S  = dpc_fifo[193];
// // // // // // wire [11:0] raw_SE = dpc_fifo[192];
// // // // // // wire [11:0] raw_SW = dpc_fifo[194];
// // // // // // wire [11:0] raw_N  = dpc_fifo[225];
// // // // // // wire [11:0] raw_NE = dpc_fifo[224];
// // // // // // wire [11:0] raw_NW = dpc_fifo[226];

// // // // // // wire is_top    = (dem_cnt_y == 0);
// // // // // // wire is_bottom = (dem_cnt_y == 15);
// // // // // // wire is_left   = (dem_cnt_x == 0);
// // // // // // wire is_right  = (dem_cnt_x == 15);

// // // // // // wire [11:0] C = raw_C;
// // // // // // wire [11:0] W = is_left   ? raw_E : raw_W;
// // // // // // wire [11:0] E = is_right  ? raw_W : raw_E;
// // // // // // wire [11:0] N = is_top    ? raw_S : raw_N;
// // // // // // wire [11:0] S = is_bottom ? raw_N : raw_S;

// // // // // // wire [11:0] NW = (is_top & is_left)  ? raw_SE :
// // // // // //                  (is_top)            ? raw_SW :
// // // // // //                  (is_left)           ? raw_NE : raw_NW;

// // // // // // wire [11:0] NE = (is_top & is_right) ? raw_SW :
// // // // // //                  (is_top)            ? raw_SE :
// // // // // //                  (is_right)          ? raw_NW : raw_NE;

// // // // // // wire [11:0] SW = (is_bottom & is_left) ? raw_NE :
// // // // // //                  (is_bottom)           ? raw_NW :
// // // // // //                  (is_left)             ? raw_SE : raw_SW;

// // // // // // wire [11:0] SE = (is_bottom & is_right) ? raw_NW :
// // // // // //                  (is_bottom)            ? raw_NE :
// // // // // //                  (is_right)             ? raw_SW : raw_SE;


// // // // // // wire [12:0] total_ns = N + S; 
// // // // // // wire [12:0] total_we = W + E; 

// // // // // // wire [13:0] total_nswe  = total_ns + total_we; 
// // // // // // wire [13:0] total_other = (NW + NE) + (SW + SE); 

// // // // // // wire [11:0] avg_nswe   = total_nswe[13:2]; 
// // // // // // wire [11:0] avg_pother = total_other[13:2];
// // // // // // wire [11:0] avg_ns     = total_ns[12:1];     
// // // // // // wire [11:0] avg_we     = total_we[12:1];     

// // // // // // reg [11:0] r_interp, g_interp, b_interp;

// // // // // // always @(*) begin
// // // // // //     case (dem_color_id)
// // // // // //         2'b00: begin r_interp = C;          g_interp = avg_nswe; b_interp = avg_pother; end 
// // // // // //         2'b01: begin r_interp = avg_we;     g_interp = C;        b_interp = avg_ns;     end 
// // // // // //         2'b10: begin r_interp = avg_ns;     g_interp = C;        b_interp = avg_we;     end 
// // // // // //         2'b11: begin r_interp = avg_pother; g_interp = avg_nswe; b_interp = C;          end 
// // // // // //     endcase
// // // // // // end

// // // // // // reg [11:0] r_dem_ff, g_dem_ff, b_dem_ff;
// // // // // // reg        dem_valid_ff;

// // // // // // always @(posedge clk) begin
// // // // // //     r_dem_ff     <= r_interp;
// // // // // //     g_dem_ff     <= g_interp;
// // // // // //     b_dem_ff     <= b_interp;
// // // // // //     dem_valid_ff <= (cs == DEM);
// // // // // // end

// // // // // // // ========================== CCM =====================================

// // // // // // // 擴充至 15 bits signed 以防 g_s + b_s 溢位
// // // // // // wire signed [14:0] r_s = $signed({3'b0, r_dem_ff});
// // // // // // wire signed [14:0] g_s = $signed({3'b0, g_dem_ff});
// // // // // // wire signed [14:0] b_s = $signed({3'b0, b_dem_ff});

// // // // // // // 數學化簡： r*1150 - (r+g+b)*50 = r*1100 - (g+b)*50
// // // // // // localparam signed [15:0] C_1100 = 16'sd1100;
// // // // // // localparam signed [15:0] C_50   = 16'sd50;

// // // // // // reg signed [26:0] r_1100_r, g_1100_r, b_1100_r;
// // // // // // reg signed [26:0] gb_50_r, rb_50_r, rg_50_r;
// // // // // // reg               ccm_valid_r;

// // // // // // // 第一級 Cycle: 只算乘法並 Register 起來 (完美切斷原先過長的 Critical Path)
// // // // // // always @(posedge clk or negedge rst_n) begin
// // // // // //     if (~rst_n) begin
// // // // // //         r_1100_r    <= 27'sd0;
// // // // // //         g_1100_r    <= 27'sd0;
// // // // // //         b_1100_r    <= 27'sd0;
// // // // // //         gb_50_r     <= 27'sd0;
// // // // // //         rb_50_r     <= 27'sd0;
// // // // // //         rg_50_r     <= 27'sd0;
// // // // // //         ccm_valid_r <= 1'b0;
// // // // // //     end
// // // // // //     else begin
// // // // // //         r_1100_r    <= r_s * C_1100;
// // // // // //         g_1100_r    <= g_s * C_1100;
// // // // // //         b_1100_r    <= b_s * C_1100;
        
// // // // // //         gb_50_r     <= (g_s + b_s) * C_50;
// // // // // //         rb_50_r     <= (r_s + b_s) * C_50;
// // // // // //         rg_50_r     <= (r_s + g_s) * C_50;
        
// // // // // //         ccm_valid_r <= dem_valid_ff;
// // // // // //     end
// // // // // // end

// // // // // // // 第二級 Cycle (Combinational): 利用原本很空閒的 Shift 階段來完成最後的加減法
// // // // // // wire signed [26:0] r_raw = r_1100_r - gb_50_r + 27'sd512;
// // // // // // wire signed [26:0] g_raw = g_1100_r - rb_50_r + 27'sd512;
// // // // // // wire signed [26:0] b_raw = b_1100_r - rg_50_r + 27'sd512;

// // // // // // wire signed [26:0] r_shift = r_raw >>> 10;
// // // // // // wire signed [26:0] g_shift = g_raw >>> 10;
// // // // // // wire signed [26:0] b_shift = b_raw >>> 10;

// // // // // // wire r_is_neg = r_shift[26];
// // // // // // wire g_is_neg = g_shift[26];
// // // // // // wire b_is_neg = b_shift[26];

// // // // // // wire [26:0] r_shift_u = $unsigned(r_shift);
// // // // // // wire [26:0] g_shift_u = $unsigned(g_shift);
// // // // // // wire [26:0] b_shift_u = $unsigned(b_shift);

// // // // // // wire r_is_over = (|r_shift_u[25:12]) & ~r_is_neg;
// // // // // // wire g_is_over = (|g_shift_u[25:12]) & ~g_is_neg;
// // // // // // wire b_is_over = (|b_shift_u[25:12]) & ~b_is_neg;

// // // // // // wire [12:0] r_ccm = r_is_neg ? 13'd0 : (r_is_over ? 13'd4095 : r_shift_u[12:0]);
// // // // // // wire [12:0] g_ccm = g_is_neg ? 13'd0 : (g_is_over ? 13'd4095 : g_shift_u[12:0]);
// // // // // // wire [12:0] b_ccm = b_is_neg ? 13'd0 : (b_is_over ? 13'd4095 : b_shift_u[12:0]);

// // // // // // always @(posedge clk or negedge rst_n) begin
// // // // // //     if (~rst_n) begin
// // // // // //         out_valid <= 0; 
// // // // // //         r_out <= 0; 
// // // // // //         g_out <= 0; 
// // // // // //         b_out <= 0;
// // // // // //     end
// // // // // //     else if (ccm_valid_r) begin 
// // // // // //         out_valid <= 1;
// // // // // //         r_out     <= r_ccm; 
// // // // // //         g_out     <= g_ccm;
// // // // // //         b_out     <= b_ccm;
// // // // // //     end
// // // // // //     else begin
// // // // // //         out_valid <= 0; 
// // // // // //         r_out <= 0; 
// // // // // //         g_out <= 0; 
// // // // // //         b_out <= 0;
// // // // // //     end
// // // // // // end

// // // // // // endmodule

// // // // // // module median_pipe (
// // // // // //     input         clk,
// // // // // //     input         rst_n,
// // // // // //     input  [11:0] A, B, C, D,
// // // // // //     output [11:0] median
// // // // // // );
// // // // // //     reg [11:0] max1_r, min1_r;
// // // // // //     reg [11:0] max2_r, min2_r;

// // // // // //     always @(posedge clk or negedge rst_n) begin
// // // // // //         if (~rst_n) begin
// // // // // //             max1_r <= 12'd0;
// // // // // //             min1_r <= 12'd0;
// // // // // //             max2_r <= 12'd0;
// // // // // //             min2_r <= 12'd0;
// // // // // //         end
// // // // // //         else begin
// // // // // //             if (A > B) begin
// // // // // //                 max1_r <= A;
// // // // // //                 min1_r <= B;
// // // // // //             end
// // // // // //             else begin
// // // // // //                 max1_r <= B;
// // // // // //                 min1_r <= A;
// // // // // //             end

// // // // // //             if (C > D) begin
// // // // // //                 max2_r <= C;
// // // // // //                 min2_r <= D;
// // // // // //             end
// // // // // //             else begin
// // // // // //                 max2_r <= D;
// // // // // //                 min2_r <= C;
// // // // // //             end
// // // // // //         end
// // // // // //     end

// // // // // //     wire [11:0] mid_low  = (min1_r > min2_r) ? min1_r : min2_r;
// // // // // //     wire [11:0] mid_high = (max1_r < max2_r) ? max1_r : max2_r;
// // // // // //     wire [12:0] safe_sum = {1'b0, mid_low} + {1'b0, mid_high};

// // // // // //     assign median = safe_sum[12:1];
// // // // // // endmodule

// // // // // // module sad (
// // // // // //     input  [11:0] A, B,
// // // // // //     output [11:0] abs
// // // // // // );
// // // // // //     // 平行運算：兩個減法器同時跑，打平原本 (減法 -> XOR -> 加1) 的深層路徑
// // // // // //     wire [12:0] err    = {1'b0, A} - {1'b0, B}; 
// // // // // //     wire [11:0] sub_ba = B - A;
    
// // // // // //     // err[12] 為 1 代表 A < B，選 B-A；否則選 A-B (err[11:0])
// // // // // //     assign abs = err[12] ? sub_ba : err[11:0];
// // // // // // endmodule






















// // // // // module ISP (
// // // // //     input         clk,
// // // // //     input         rst_n,
// // // // //     input         in_valid,
// // // // //     input  [12:0] in,
// // // // //     input         param_valid,
// // // // //     input  [12:0] param_gain,

// // // // //     output reg        out_valid,
// // // // //     output reg [12:0] r_out,
// // // // //     output reg [12:0] g_out,
// // // // //     output reg [12:0] b_out
// // // // // );

// // // // // //==============================
// // // // // //   Design
// // // // // //==============================
// // // // // localparam IDLE  = 2'd0;
// // // // // localparam INPUT = 2'd1;
// // // // // localparam DPC   = 2'd2;
// // // // // localparam DEM   = 2'd3;

// // // // // integer i, j;

// // // // // reg  [3:0] x_cnt, y_cnt; 
// // // // // reg  [3:0] dpc_cnt_x, dpc_cnt_y;
// // // // // reg  [7:0] dem_cnt;

// // // // // reg  [1:0] cs, ns;

// // // // // always @(posedge clk or negedge rst_n) begin
// // // // //     if (~rst_n) cs <= IDLE;
// // // // //     else        cs <= ns;
// // // // // end

// // // // // always @(*) begin
// // // // //     ns = cs; 
// // // // //     case (cs)
// // // // //         IDLE:  ns = (in_valid) ? INPUT : IDLE;
// // // // //         INPUT: ns = (x_cnt == 5 && y_cnt == 2) ? DPC : INPUT;

// // // // //         // 原本 13,13，太晚 5 cycles
// // // // //         DPC:   ns = (dpc_cnt_x == 6 && dpc_cnt_y == 13) ? DEM : DPC;

// // // // //         DEM:   ns = (dem_cnt == 255) ? IDLE : DEM;
// // // // //     endcase
// // // // // end

// // // // // reg [2:0] param_x_cnt, param_y_cnt; 
// // // // // reg [1:0] next_gain;

// // // // // always @(posedge clk or negedge rst_n) begin
// // // // //     if (~rst_n) begin
// // // // //         param_x_cnt <= 0; 
// // // // //         param_y_cnt <= 0; 
// // // // //         next_gain <= 0;
// // // // //     end
// // // // //     else if (param_valid) begin
// // // // //         if (param_x_cnt == 5 && param_y_cnt == 5) begin
// // // // //             param_x_cnt <= 0; 
// // // // //             param_y_cnt <= 0; 
// // // // //             next_gain <= next_gain + 1;
// // // // //         end
// // // // //         else if (param_x_cnt == 5) begin 
// // // // //             param_x_cnt <= 3'd0; 
// // // // //             param_y_cnt <= param_y_cnt + 3'd1;
// // // // //         end
// // // // //         else
// // // // //             param_x_cnt <= param_x_cnt + 3'd1;
// // // // //     end
// // // // // end

// // // // // reg  [12:0] r_matrix  [0:5][0:5];
// // // // // reg  [12:0] gr_matrix [0:5][0:5];
// // // // // reg  [12:0] gb_matrix [0:5][0:5];
// // // // // reg  [12:0] b_matrix  [0:5][0:5];

// // // // // always @(posedge clk or negedge rst_n) begin
// // // // //     if (~rst_n) begin
// // // // //         for (i = 0; i < 6; i = i + 1) 
// // // // //         for (j = 0; j < 6; j = j + 1) begin
// // // // //             r_matrix[i][j]  <= 0; 
// // // // //             gr_matrix[i][j] <= 0;
// // // // //             gb_matrix[i][j] <= 0; 
// // // // //             b_matrix[i][j]  <= 0;
// // // // //         end
// // // // //     end
// // // // //     else if (param_valid) begin
// // // // //         case (next_gain)
// // // // //             0: r_matrix[param_y_cnt][param_x_cnt]  <= param_gain;
// // // // //             1: gr_matrix[param_y_cnt][param_x_cnt] <= param_gain;
// // // // //             2: gb_matrix[param_y_cnt][param_x_cnt] <= param_gain;
// // // // //             3: b_matrix[param_y_cnt][param_x_cnt]  <= param_gain;
// // // // //         endcase
// // // // //     end
// // // // // end

// // // // // // ====================== BLC =====================
// // // // // always @(posedge clk or negedge rst_n) begin
// // // // //     if (~rst_n) begin
// // // // //         x_cnt <= 0; 
// // // // //         y_cnt <= 0;
// // // // //     end
// // // // //     else if (in_valid) begin
// // // // //         if (x_cnt == 15) begin 
// // // // //             x_cnt <= 0; 
// // // // //             y_cnt <= y_cnt + 1;
// // // // //         end
// // // // //         else 
// // // // //             x_cnt <= x_cnt + 1;
// // // // //     end
// // // // // end

// // // // // wire [1:0] color_id = {y_cnt[0], x_cnt[0]};
// // // // // reg  [6:0] black_level;

// // // // // always @(*) begin
// // // // //     case (color_id)
// // // // //         2'b00: black_level = 64; 
// // // // //         2'b01: black_level = 48; 
// // // // //         2'b10: black_level = 52; 
// // // // //         2'b11: black_level = 72; 
// // // // //     endcase
// // // // // end

// // // // // wire [13:0] in_ext = {1'b0, in};

// // // // // wire [13:0] sub_r  = in_ext - 14'd64;
// // // // // wire [13:0] sub_gr = in_ext - 14'd48;
// // // // // wire [13:0] sub_gb = in_ext - 14'd52;
// // // // // wire [13:0] sub_b  = in_ext - 14'd72;

// // // // // reg [13:0] sub_result;

// // // // // always @(*) begin
// // // // //     case (color_id)
// // // // //         2'b00: sub_result = sub_r;
// // // // //         2'b01: sub_result = sub_gr;
// // // // //         2'b10: sub_result = sub_gb;
// // // // //         2'b11: sub_result = sub_b;
// // // // //     endcase
// // // // // end

// // // // // wire [12:0] i_blc = sub_result[13] ? 13'd0 : sub_result[12:0];

// // // // // // ====================== LSC =====================
// // // // // reg [2:0] x0, y0; 
// // // // // reg [1:0] rx, ry;

// // // // // always @(*) begin
// // // // //     case (x_cnt)
// // // // //         0, 1, 2:        begin x0 = 0; rx = x_cnt[1:0]; end
// // // // //         3, 4, 5:        begin x0 = 1; rx = x_cnt - 3; end
// // // // //         6, 7, 8:        begin x0 = 2; rx = x_cnt - 6; end
// // // // //         9, 10, 11:      begin x0 = 3; rx = x_cnt - 9; end
// // // // //         12, 13, 14, 15: begin x0 = 4; rx = (x_cnt >= 14) ? 2 : x_cnt - 12; end
// // // // //         default:        begin x0 = 0; rx = 0; end
// // // // //     endcase
// // // // // end

// // // // // always @(*) begin
// // // // //     case (y_cnt)
// // // // //         0, 1, 2:        begin y0 = 0; ry = y_cnt[1:0]; end
// // // // //         3, 4, 5:        begin y0 = 1; ry = y_cnt - 3; end
// // // // //         6, 7, 8:        begin y0 = 2; ry = y_cnt - 6; end
// // // // //         9, 10, 11:      begin y0 = 3; ry = y_cnt - 9; end
// // // // //         12, 13, 14, 15: begin y0 = 4; ry = (y_cnt >= 14) ? 2 : y_cnt - 12; end
// // // // //         default:        begin y0 = 0; ry = 0; end
// // // // //     endcase
// // // // // end

// // // // // reg [12:0] g00, g01, g10, g11;
// // // // // reg [13:0] g0110, g0011, g0010, g0001;

// // // // // always @(*) begin
// // // // //     case (color_id)
// // // // //         2'b00: begin
// // // // //             g00 = r_matrix[y0][x0];
// // // // //             g01 = r_matrix[y0][x0 + 3'd1];
// // // // //             g10 = r_matrix[y0 + 3'd1][x0];
// // // // //             g11 = r_matrix[y0 + 3'd1][x0 + 3'd1];
// // // // //         end
// // // // //         2'b01: begin
// // // // //             g00 = gr_matrix[y0][x0];
// // // // //             g01 = gr_matrix[y0][x0 + 3'd1];
// // // // //             g10 = gr_matrix[y0 + 3'd1][x0];
// // // // //             g11 = gr_matrix[y0 + 3'd1][x0 + 3'd1];
// // // // //         end
// // // // //         2'b10: begin
// // // // //             g00 = gb_matrix[y0][x0];
// // // // //             g01 = gb_matrix[y0][x0 + 3'd1];
// // // // //             g10 = gb_matrix[y0 + 3'd1][x0];
// // // // //             g11 = gb_matrix[y0 + 3'd1][x0 + 3'd1];
// // // // //         end
// // // // //         2'b11: begin
// // // // //             g00 = b_matrix[y0][x0];
// // // // //             g01 = b_matrix[y0][x0 + 3'd1];
// // // // //             g10 = b_matrix[y0 + 3'd1][x0];
// // // // //             g11 = b_matrix[y0 + 3'd1][x0 + 3'd1];
// // // // //         end
// // // // //     endcase

// // // // //     g0110 = g01 + g10;
// // // // //     g0011 = g00 + g11;
// // // // //     g0010 = g00 + g10; 
// // // // //     g0001 = g00 + g01; 
// // // // // end

// // // // // reg [12:0] m_29241, m_7225;
// // // // // reg [13:0] m_14535; 

// // // // // // 1. 補上 4'b0000 的特例，利用數學魔法自動產生 g00
// // // // // // 當 rx=0, ry=0 時，總和 = g00*29241 + (g00*2)*14535 + g00*7225 = g00 * 65536
// // // // // // 這樣右移 16 bit 後，出來的答案保證等於 g00，我們就不需要 MUX 了！
// // // // // always @(*) begin
// // // // //     m_29241 = 0; 
// // // // //     m_14535 = 0; 
// // // // //     m_7225  = 0;
// // // // //     case ({rx, ry})
// // // // //         4'b0000: begin m_29241 = g00; m_14535 = {g00, 1'b0}; m_7225 = g00; end // {g00, 1'b0} 就是乘 2
// // // // //         4'b0001: begin m_29241 = g00; m_14535 = g0010; m_7225 = g10; end
// // // // //         4'b0010: begin m_29241 = g10; m_14535 = g0010; m_7225 = g00; end
// // // // //         4'b0100: begin m_29241 = g00; m_14535 = g0001; m_7225 = g01; end
// // // // //         4'b1000: begin m_29241 = g01; m_14535 = g0001; m_7225 = g00; end
// // // // //         4'b0101: begin m_29241 = g00; m_14535 = g0110; m_7225 = g11; end
// // // // //         4'b0110: begin m_29241 = g10; m_14535 = g0011; m_7225 = g01; end
// // // // //         4'b1001: begin m_29241 = g01; m_14535 = g0011; m_7225 = g10; end
// // // // //         4'b1010: begin m_29241 = g11; m_14535 = g0110; m_7225 = g00; end
// // // // //     endcase
// // // // // end

// // // // // // 2. 因為不用 MUX 了，可以大方刪除 rx_ry_zero_ff 與 g00_ff，減輕時鐘樹負載
// // // // // reg [12:0] m_29241_ff, m_7225_ff;
// // // // // reg [13:0] m_14535_ff;
// // // // // reg [12:0] i_blc_ff;
// // // // // reg        in_valid_ff;

// // // // // always @(posedge clk) begin
// // // // //     m_29241_ff  <= m_29241; 
// // // // //     m_14535_ff  <= m_14535; 
// // // // //     m_7225_ff   <= m_7225;
// // // // //     i_blc_ff    <= i_blc;
// // // // //     in_valid_ff <= in_valid;
// // // // // end

// // // // // // ======================================================================
// // // // // // 3. 改良版 CSD 展開：使用「平衡加法樹 (Balanced Tree)」縮短 Critical Path
// // // // // // ======================================================================

// // // // // wire [29:0] ext_29241 = {17'b0, m_29241_ff};
// // // // // wire [29:0] ext_14535 = {16'b0, m_14535_ff};
// // // // // wire [29:0] ext_7225  = {17'b0, m_7225_ff};

// // // // // // 29241 = 32768 - 4096 + 512 + 64 - 8 + 1
// // // // // // 將 6 個項目拆成兩兩一組平行計算，降低邏輯層級深度
// // // // // wire [29:0] t1_29 = (ext_29241 << 15) - (ext_29241 << 12);
// // // // // wire [29:0] t2_29 = (ext_29241 << 9)  + (ext_29241 << 6);
// // // // // wire [29:0] t3_29 = ext_29241         - (ext_29241 << 3); 
// // // // // wire [29:0] mul_29241 = (t1_29 + t2_29) + t3_29;

// // // // // // 14535 = 16384 - 2048 + 256 - 64 + 8 - 1
// // // // // // 同樣拆分成兩兩一組
// // // // // wire [29:0] t1_14 = (ext_14535 << 14) - (ext_14535 << 11);
// // // // // wire [29:0] t2_14 = (ext_14535 << 8)  - (ext_14535 << 6);
// // // // // wire [29:0] t3_14 = (ext_14535 << 3)  - ext_14535;
// // // // // wire [29:0] mul_14535 = (t1_14 + t2_14) + t3_14;

// // // // // // 7225 = 8192 - 1024 + 64 - 8 + 1
// // // // // // 分組計算
// // // // // wire [29:0] t1_72 = (ext_7225 << 13) - (ext_7225 << 10);
// // // // // wire [29:0] t2_72 = (ext_7225 << 6)  - (ext_7225 << 3);
// // // // // wire [29:0] mul_7225 = (t1_72 + t2_72) + ext_7225;

// // // // // // 最後的總和也使用樹狀結構相加，避免 mul_29241 + mul_14535 + mul_7225 變成線性串接
// // // // // wire [29:0] sum_part1   = mul_29241 + mul_14535;
// // // // // wire [29:0] gxy_sum_opt = sum_part1 + mul_7225;

// // // // // // 4. 四捨五入照舊
// // // // // wire [13:0] gxy = gxy_sum_opt[29:16] + gxy_sum_opt[15];

// // // // // reg [13:0] gxy_ff;
// // // // // reg [12:0] i_blc_ff_ff;
// // // // // reg        in_valid_ff_ff;

// // // // // always @(posedge clk) begin
// // // // //     gxy_ff         <= gxy;
// // // // //     i_blc_ff_ff    <= i_blc_ff; 
// // // // //     in_valid_ff_ff <= in_valid_ff; 
// // // // // end

// // // // // wire [25:0] p_sum_w = gxy_ff * i_blc_ff_ff;

// // // // // reg [25:0] p_sum_r;
// // // // // reg        pp_valid_r;

// // // // // always @(posedge clk or negedge rst_n) begin
// // // // //     if (~rst_n) begin
// // // // //         p_sum_r    <= 26'd0;
// // // // //         pp_valid_r <= 1'b0;
// // // // //     end
// // // // //     else begin
// // // // //         p_sum_r    <= p_sum_w;
// // // // //         pp_valid_r <= in_valid_ff_ff;
// // // // //     end
// // // // // end

// // // // // wire [16:0] p_sum_round = p_sum_r[25:10] + p_sum_r[9];
// // // // // wire p_is_over = |p_sum_round[16:12];
// // // // // wire [11:0] pp_xy = p_is_over ? 12'd4095 : p_sum_round[11:0];

// // // // // // ====================== DPC =====================

// // // // // reg [11:0] lb0 [0:15]; 
// // // // // reg [11:0] lb1 [0:15];
// // // // // reg [11:0] lb2 [0:15]; 
// // // // // reg [11:0] lb3 [0:15];
// // // // // reg [11:0] lb4 [0:4]; 

// // // // // always @(posedge clk) begin
// // // // //     if (pp_valid_r || cs == DPC || cs == DEM) begin
// // // // //         for (i = 15; i > 0; i = i - 1) begin
// // // // //             lb3[i] <= lb3[i - 1]; 
// // // // //             lb2[i] <= lb2[i - 1];
// // // // //             lb1[i] <= lb1[i - 1]; 
// // // // //             lb0[i] <= lb0[i - 1];
// // // // //         end
// // // // //         lb3[0] <= lb2[15]; 
// // // // //         lb2[0] <= lb1[15];
// // // // //         lb1[0] <= lb0[15]; 
// // // // //         lb0[0] <= (pp_valid_r) ? pp_xy : 12'd0;
        
// // // // //         for (i = 4; i > 0; i = i - 1) 
// // // // //             lb4[i] <= lb4[i - 1];
            
// // // // //         lb4[0] <= lb3[15];
// // // // //     end
// // // // //     else begin
// // // // //         for (i = 0; i < 16; i = i + 1) begin
// // // // //             lb0[i] <= 0; 
// // // // //             lb1[i] <= 0; 
// // // // //             lb2[i] <= 0; 
// // // // //             lb3[i] <= 0;
// // // // //         end
// // // // //         for (i = 0; i < 5; i = i + 1) 
// // // // //             lb4[i] <= 0;
// // // // //     end
// // // // // end

// // // // // reg [11:0] px_mat [0:4][0:4];

// // // // // always @(*) begin
// // // // //     for (i = 0; i < 5; i = i + 1) begin
// // // // //         px_mat[4][i] = lb0[4 - i];
// // // // //         px_mat[3][i] = lb1[4 - i];
// // // // //         px_mat[2][i] = lb2[4 - i];
// // // // //         px_mat[1][i] = lb3[4 - i];
// // // // //         px_mat[0][i] = lb4[4 - i];
// // // // //     end
// // // // // end

// // // // // // ====================== DPC  =====================

// // // // // always @(posedge clk) begin
// // // // //     if (cs == DPC || cs == DEM) begin
// // // // //         if (dpc_cnt_x == 15) begin
// // // // //             dpc_cnt_x <= 0;
// // // // //             if (dpc_cnt_y == 15) 
// // // // //                 dpc_cnt_y <= 0;
// // // // //             else 
// // // // //                 dpc_cnt_y <= dpc_cnt_y + 1;
// // // // //         end
// // // // //         else 
// // // // //             dpc_cnt_x <= dpc_cnt_x + 1;
// // // // //     end
// // // // //     else begin
// // // // //         dpc_cnt_x <= 0; 
// // // // //         dpc_cnt_y <= 0;
// // // // //     end
// // // // // end

// // // // // reg [2:0] px [0:4];
// // // // // reg [2:0] py [0:4];

// // // // // always @(*) begin
// // // // //     px[0] = (dpc_cnt_x == 4'd0)  ? 3'd4 : (dpc_cnt_x == 4'd1)  ? 3'd2 : 3'd0;
// // // // //     px[1] = (dpc_cnt_x == 4'd0)  ? 3'd3 : 3'd1; 
// // // // //     px[2] = 3'd2; 
// // // // //     px[3] = (dpc_cnt_x == 4'd15) ? 3'd1 : 3'd3; 
// // // // //     px[4] = (dpc_cnt_x == 4'd15) ? 3'd0 : (dpc_cnt_x == 4'd14) ? 3'd2 : 3'd4;

// // // // //     py[0] = (dpc_cnt_y == 4'd0)  ? 3'd4 : (dpc_cnt_y == 4'd1)  ? 3'd2 : 3'd0;
// // // // //     py[1] = (dpc_cnt_y == 4'd0)  ? 3'd3 : 3'd1; 
// // // // //     py[2] = 3'd2; 
// // // // //     py[3] = (dpc_cnt_y == 4'd15) ? 3'd1 : 3'd3; 
// // // // //     py[4] = (dpc_cnt_y == 4'd15) ? 3'd0 : (dpc_cnt_y == 4'd14) ? 3'd2 : 3'd4;
// // // // // end

// // // // // reg [11:0] p_row_0 [0:4]; 
// // // // // reg [11:0] p_row_1 [0:4]; 
// // // // // reg [11:0] p_row_2 [0:4];
// // // // // reg [11:0] p_row_3 [0:4]; 
// // // // // reg [11:0] p_row_4 [0:4];

// // // // // always @(*) begin
// // // // //     for(i = 0; i < 5; i = i + 1) begin
// // // // //         p_row_0[i] = px_mat[py[0]][i]; 
// // // // //         p_row_1[i] = px_mat[py[1]][i];
// // // // //         p_row_2[i] = px_mat[py[2]][i]; 
// // // // //         p_row_3[i] = px_mat[py[3]][i];
// // // // //         p_row_4[i] = px_mat[py[4]][i];
// // // // //     end
// // // // // end

// // // // // reg [11:0] H  [0:3];
// // // // // reg [11:0] V  [0:3];
// // // // // reg [11:0] D1 [0:3];
// // // // // reg [11:0] D2 [0:3];

// // // // // always @(*) begin
// // // // //     H[0]  = p_row_2[px[0]]; 
// // // // //     H[1]  = p_row_2[px[1]]; 
// // // // //     H[2]  = p_row_2[px[3]]; 
// // // // //     H[3]  = p_row_2[px[4]];

// // // // //     V[0]  = p_row_0[px[2]]; 
// // // // //     V[1]  = p_row_1[px[2]]; 
// // // // //     V[2]  = p_row_3[px[2]]; 
// // // // //     V[3]  = p_row_4[px[2]];

// // // // //     D1[0] = p_row_0[px[0]]; 
// // // // //     D1[1] = p_row_1[px[1]]; 
// // // // //     D1[2] = p_row_3[px[3]]; 
// // // // //     D1[3] = p_row_4[px[4]];

// // // // //     D2[0] = p_row_0[px[4]]; 
// // // // //     D2[1] = p_row_1[px[3]]; 
// // // // //     D2[2] = p_row_3[px[1]]; 
// // // // //     D2[3] = p_row_4[px[0]];
// // // // // end

// // // // // reg [11:0] H_ff[0:3], V_ff[0:3], D1_ff[0:3], D2_ff[0:3];
// // // // // reg [11:0] P_ff;
// // // // // reg        dpc_valid_ff;

// // // // // always @(posedge clk) begin
// // // // //     for(i = 0; i < 4; i = i + 1) begin
// // // // //         H_ff[i] <= H[i]; 
// // // // //         V_ff[i] <= V[i]; 
// // // // //         D1_ff[i] <= D1[i]; 
// // // // //         D2_ff[i] <= D2[i];
// // // // //     end
// // // // //     P_ff <= p_row_2[px[2]];
// // // // //     dpc_valid_ff <= (cs == DPC || cs == DEM);
// // // // // end

// // // // // wire [11:0] med_H, med_V, med_D1, med_D2;

// // // // // // median calc_med_H (.A(H_ff[0]), .B(H_ff[1]), .C(H_ff[2]), .D(H_ff[3]), .median(med_H));
// // // // // // median calc_med_V (.A(V_ff[0]), .B(V_ff[1]), .C(V_ff[2]), .D(V_ff[3]), .median(med_V));
// // // // // // median calc_med_D1(.A(D1_ff[0]),.B(D1_ff[1]),.C(D1_ff[2]),.D(D1_ff[3]),.median(med_D1));
// // // // // // median calc_med_D2(.A(D2_ff[0]),.B(D2_ff[1]),.C(D2_ff[2]),.D(D2_ff[3]),.median(med_D2));

// // // // // median_pipe calc_med_H (
// // // // //     .clk(clk), .rst_n(rst_n),
// // // // //     .A(H_ff[0]), .B(H_ff[1]), .C(H_ff[2]), .D(H_ff[3]),
// // // // //     .median(med_H)
// // // // // );

// // // // // median_pipe calc_med_V (
// // // // //     .clk(clk), .rst_n(rst_n),
// // // // //     .A(V_ff[0]), .B(V_ff[1]), .C(V_ff[2]), .D(V_ff[3]),
// // // // //     .median(med_V)
// // // // // );

// // // // // median_pipe calc_med_D1 (
// // // // //     .clk(clk), .rst_n(rst_n),
// // // // //     .A(D1_ff[0]), .B(D1_ff[1]), .C(D1_ff[2]), .D(D1_ff[3]),
// // // // //     .median(med_D1)
// // // // // );

// // // // // median_pipe calc_med_D2 (
// // // // //     .clk(clk), .rst_n(rst_n),
// // // // //     .A(D2_ff[0]), .B(D2_ff[1]), .C(D2_ff[2]), .D(D2_ff[3]),
// // // // //     .median(med_D2)
// // // // // );

// // // // // reg [11:0] H_ff_d[0:3], V_ff_d[0:3], D1_ff_d[0:3], D2_ff_d[0:3];
// // // // // reg [11:0] P_ff_d;
// // // // // reg        dpc_valid_ff_d;

// // // // // reg [11:0] H_ff_ff[0:3], V_ff_ff[0:3], D1_ff_ff[0:3], D2_ff_ff[0:3];
// // // // // reg [11:0] med_H_ff, med_V_ff, med_D1_ff, med_D2_ff;
// // // // // reg [11:0] P_ff_ff;
// // // // // reg        dpc_valid_ff_ff;

// // // // // always @(posedge clk) begin
// // // // //     for (i = 0; i < 4; i = i + 1) begin
// // // // //         H_ff_d[i]  <= H_ff[i];
// // // // //         V_ff_d[i]  <= V_ff[i];
// // // // //         D1_ff_d[i] <= D1_ff[i];
// // // // //         D2_ff_d[i] <= D2_ff[i];
// // // // //     end
// // // // //     P_ff_d         <= P_ff;
// // // // //     dpc_valid_ff_d <= dpc_valid_ff;
// // // // // end

// // // // // always @(posedge clk) begin
// // // // //     for(i = 0; i < 4; i = i + 1) begin
// // // // //         H_ff_ff[i]  <= H_ff_d[i]; 
// // // // //         V_ff_ff[i]  <= V_ff_d[i]; 
// // // // //         D1_ff_ff[i] <= D1_ff_d[i]; 
// // // // //         D2_ff_ff[i] <= D2_ff_d[i];
// // // // //     end
// // // // //     med_H_ff  <= med_H; 
// // // // //     med_V_ff  <= med_V; 
// // // // //     med_D1_ff <= med_D1; 
// // // // //     med_D2_ff <= med_D2;
// // // // //     P_ff_ff <= P_ff_d;
// // // // //     dpc_valid_ff_ff <= dpc_valid_ff_d;
// // // // // end

// // // // // wire [11:0] err_H0, err_H1, err_H2, err_H3;
// // // // // wire [11:0] err_V0, err_V1, err_V2, err_V3;
// // // // // wire [11:0] err_D1_0, err_D1_1, err_D1_2, err_D1_3;
// // // // // wire [11:0] err_D2_0, err_D2_1, err_D2_2, err_D2_3;

// // // // // sad sad_h0 (.A(H_ff_ff[0]), .B(med_H_ff), .abs(err_H0)); 
// // // // // sad sad_h1 (.A(H_ff_ff[1]), .B(med_H_ff), .abs(err_H1));
// // // // // sad sad_h2 (.A(H_ff_ff[2]), .B(med_H_ff), .abs(err_H2)); 
// // // // // sad sad_h3 (.A(H_ff_ff[3]), .B(med_H_ff), .abs(err_H3));
// // // // // wire [13:0] SAD_H = err_H0 + err_H1 + err_H2 + err_H3;

// // // // // sad sad_v0 (.A(V_ff_ff[0]), .B(med_V_ff), .abs(err_V0)); 
// // // // // sad sad_v1 (.A(V_ff_ff[1]), .B(med_V_ff), .abs(err_V1));
// // // // // sad sad_v2 (.A(V_ff_ff[2]), .B(med_V_ff), .abs(err_V2)); 
// // // // // sad sad_v3 (.A(V_ff_ff[3]), .B(med_V_ff), .abs(err_V3));
// // // // // wire [13:0] SAD_V = err_V0 + err_V1 + err_V2 + err_V3;

// // // // // sad sad_d1_0 (.A(D1_ff_ff[0]), .B(med_D1_ff), .abs(err_D1_0)); 
// // // // // sad sad_d1_1 (.A(D1_ff_ff[1]), .B(med_D1_ff), .abs(err_D1_1));
// // // // // sad sad_d1_2 (.A(D1_ff_ff[2]), .B(med_D1_ff), .abs(err_D1_2)); 
// // // // // sad sad_d1_3 (.A(D1_ff_ff[3]), .B(med_D1_ff), .abs(err_D1_3));
// // // // // wire [13:0] SAD_D1 = err_D1_0 + err_D1_1 + err_D1_2 + err_D1_3;

// // // // // sad sad_d2_0 (.A(D2_ff_ff[0]), .B(med_D2_ff), .abs(err_D2_0)); 
// // // // // sad sad_d2_1 (.A(D2_ff_ff[1]), .B(med_D2_ff), .abs(err_D2_1));
// // // // // sad sad_d2_2 (.A(D2_ff_ff[2]), .B(med_D2_ff), .abs(err_D2_2)); 
// // // // // sad sad_d2_3 (.A(D2_ff_ff[3]), .B(med_D2_ff), .abs(err_D2_3));
// // // // // wire [13:0] SAD_D2 = err_D2_0 + err_D2_1 + err_D2_2 + err_D2_3;

// // // // // // // ====================== DPC =====================

// // // // // reg  [3:0] dem_cnt_x, dem_cnt_y;

// // // // // always @(posedge clk or negedge rst_n) begin
// // // // //     if (~rst_n) begin
// // // // //         dem_cnt <= 0; 
// // // // //         dem_cnt_x <= 0; 
// // // // //         dem_cnt_y <= 0;
// // // // //     end
// // // // //     else if (cs == DEM) begin
// // // // //         dem_cnt <= dem_cnt + 1;
// // // // //         if (dem_cnt_x == 15) begin
// // // // //             dem_cnt_x <= 0; 
// // // // //             dem_cnt_y <= 
// // // // //             dem_cnt_y + 1;
// // // // //         end
// // // // //         else 
// // // // //             dem_cnt_x <= dem_cnt_x + 1;
// // // // //     end
// // // // //     else 
// // // // //         dem_cnt <= 0;
// // // // // end

// // // // // reg [13:0] SAD_H_ff, SAD_V_ff, SAD_D1_ff, SAD_D2_ff;
// // // // // reg [11:0] med_H_ff_ff, med_V_ff_ff, med_D1_ff_ff, med_D2_ff_ff;
// // // // // reg [11:0] P_ff_ff_ff;
// // // // // reg        dpc_valid_ff_ff_ff;

// // // // // always @(posedge clk) begin
// // // // //     SAD_H_ff  <= SAD_H;  
// // // // //     SAD_V_ff  <= SAD_V; 
// // // // //     SAD_D1_ff <= SAD_D1; 
// // // // //     SAD_D2_ff <= SAD_D2;
// // // // //     med_H_ff_ff  <= med_H_ff;  
// // // // //     med_V_ff_ff  <= med_V_ff; 
// // // // //     med_D1_ff_ff <= med_D1_ff; 
// // // // //     med_D2_ff_ff <= med_D2_ff;
// // // // //     P_ff_ff_ff   <= P_ff_ff;
// // // // //     dpc_valid_ff_ff_ff <= dpc_valid_ff_ff;
// // // // // end

// // // // // wire cmp_HV = (SAD_H_ff <= SAD_V_ff);
// // // // // wire [13:0] min_SAD_HV = cmp_HV ? SAD_H_ff : SAD_V_ff;
// // // // // wire [11:0] target_HV  = cmp_HV ? med_H_ff_ff : med_V_ff_ff;

// // // // // wire cmp_D1D2 = (SAD_D1_ff <= SAD_D2_ff);
// // // // // wire [13:0] min_SAD_D1D2 = cmp_D1D2 ? SAD_D1_ff : SAD_D2_ff;
// // // // // wire [11:0] target_D1D2  = cmp_D1D2 ? med_D1_ff_ff : med_D2_ff_ff;

// // // // // wire cmp_final = (min_SAD_HV <= min_SAD_D1D2);
// // // // // wire [11:0] Target_w = cmp_final ? target_HV : target_D1D2;

// // // // // reg [11:0] Target_r;
// // // // // reg [11:0] P_replace_r;

// // // // // always @(posedge clk or negedge rst_n) begin
// // // // //     if (~rst_n) begin
// // // // //         Target_r    <= 12'd0;
// // // // //         P_replace_r <= 12'd0;
// // // // //     end
// // // // //     else begin
// // // // //         Target_r    <= Target_w;
// // // // //         P_replace_r <= P_ff_ff_ff;
// // // // //     end
// // // // // end

// // // // // wire replace_cond = ({1'b0, P_replace_r} > {1'b0, Target_r} + 13'd320) || 
// // // // //                     ({1'b0, Target_r} > {1'b0, P_replace_r} + 13'd320);

// // // // // wire [11:0] dpc_out = replace_cond ? Target_r : P_replace_r;

// // // // // reg [11:0] dpc_fifo [0:235];

// // // // // always @(posedge clk) begin
// // // // //     for (i = 235; i > 0; i = i - 1) 
// // // // //         dpc_fifo[i] <= dpc_fifo[i - 1];

// // // // //     dpc_fifo[0] <= dpc_out;
// // // // // end

// // // // // // ============================ dem ===================================

// // // // // wire [1:0] dem_color_id = {dem_cnt_y[0], dem_cnt_x[0]};

// // // // // wire [11:0] raw_C  = dpc_fifo[209];
// // // // // wire [11:0] raw_E  = dpc_fifo[208];
// // // // // wire [11:0] raw_W  = dpc_fifo[210];
// // // // // wire [11:0] raw_S  = dpc_fifo[193];
// // // // // wire [11:0] raw_SE = dpc_fifo[192];
// // // // // wire [11:0] raw_SW = dpc_fifo[194];
// // // // // wire [11:0] raw_N  = dpc_fifo[225];
// // // // // wire [11:0] raw_NE = dpc_fifo[224];
// // // // // wire [11:0] raw_NW = dpc_fifo[226];

// // // // // wire is_top    = (dem_cnt_y == 0);
// // // // // wire is_bottom = (dem_cnt_y == 15);
// // // // // wire is_left   = (dem_cnt_x == 0);
// // // // // wire is_right  = (dem_cnt_x == 15);

// // // // // wire [11:0] C = raw_C;
// // // // // wire [11:0] W = is_left   ? raw_E : raw_W;
// // // // // wire [11:0] E = is_right  ? raw_W : raw_E;
// // // // // wire [11:0] N = is_top    ? raw_S : raw_N;
// // // // // wire [11:0] S = is_bottom ? raw_N : raw_S;

// // // // // wire [11:0] NW = (is_top & is_left)  ? raw_SE :
// // // // //                  (is_top)            ? raw_SW :
// // // // //                  (is_left)           ? raw_NE : raw_NW;

// // // // // wire [11:0] NE = (is_top & is_right) ? raw_SW :
// // // // //                  (is_top)            ? raw_SE :
// // // // //                  (is_right)          ? raw_NW : raw_NE;

// // // // // wire [11:0] SW = (is_bottom & is_left) ? raw_NE :
// // // // //                  (is_bottom)           ? raw_NW :
// // // // //                  (is_left)             ? raw_SE : raw_SW;

// // // // // wire [11:0] SE = (is_bottom & is_right) ? raw_NW :
// // // // //                  (is_bottom)            ? raw_NE :
// // // // //                  (is_right)             ? raw_SW : raw_SE;


// // // // // wire [12:0] total_ns = N + S; 
// // // // // wire [12:0] total_we = W + E; 

// // // // // wire [13:0] total_nswe  = total_ns + total_we; 
// // // // // wire [13:0] total_other = (NW + NE) + (SW + SE); 

// // // // // wire [11:0] avg_nswe   = total_nswe[13:2]; 
// // // // // wire [11:0] avg_pother = total_other[13:2];
// // // // // wire [11:0] avg_ns     = total_ns[12:1];     
// // // // // wire [11:0] avg_we     = total_we[12:1];     

// // // // // reg [11:0] r_interp, g_interp, b_interp;

// // // // // always @(*) begin
// // // // //     case (dem_color_id)
// // // // //         2'b00: begin r_interp = C;          g_interp = avg_nswe; b_interp = avg_pother; end 
// // // // //         2'b01: begin r_interp = avg_we;     g_interp = C;        b_interp = avg_ns;     end 
// // // // //         2'b10: begin r_interp = avg_ns;     g_interp = C;        b_interp = avg_we;     end 
// // // // //         2'b11: begin r_interp = avg_pother; g_interp = avg_nswe; b_interp = C;          end 
// // // // //     endcase
// // // // // end

// // // // // reg [11:0] r_dem_ff, g_dem_ff, b_dem_ff;
// // // // // reg        dem_valid_ff;

// // // // // always @(posedge clk) begin
// // // // //     r_dem_ff     <= r_interp;
// // // // //     g_dem_ff     <= g_interp;
// // // // //     b_dem_ff     <= b_interp;
// // // // //     dem_valid_ff <= (cs == DEM);
// // // // // end

// // // // // // ========================== CCM =====================================

// // // // // // 擴充至 15 bits signed 以防 g_s + b_s 溢位
// // // // // wire signed [14:0] r_s = $signed({3'b0, r_dem_ff});
// // // // // wire signed [14:0] g_s = $signed({3'b0, g_dem_ff});
// // // // // wire signed [14:0] b_s = $signed({3'b0, b_dem_ff});

// // // // // // 數學化簡： r*1150 - (r+g+b)*50 = r*1100 - (g+b)*50
// // // // // localparam signed [15:0] C_1100 = 16'sd1100;
// // // // // localparam signed [15:0] C_50   = 16'sd50;

// // // // // reg signed [26:0] r_1100_r, g_1100_r, b_1100_r;
// // // // // reg signed [26:0] gb_50_r, rb_50_r, rg_50_r;
// // // // // reg               ccm_valid_r;

// // // // // // Signed 操作時，為確保符號位元 (Sign bit) 正確延伸，需使用 `<<<` 算術移位
// // // // // // 先擴充到 27 bits signed 以防止溢位
// // // // // wire signed [26:0] ext_r_s = r_s;
// // // // // wire signed [26:0] ext_g_s = g_s;
// // // // // wire signed [26:0] ext_b_s = b_s;

// // // // // wire signed [26:0] sum_gb = g_s + b_s; 
// // // // // wire signed [26:0] sum_rb = r_s + b_s;
// // // // // wire signed [26:0] sum_rg = r_s + g_s;

// // // // // always @(posedge clk or negedge rst_n) begin
// // // // //     if (~rst_n) begin
// // // // //         r_1100_r    <= 27'sd0;
// // // // //         g_1100_r    <= 27'sd0;
// // // // //         b_1100_r    <= 27'sd0;
// // // // //         gb_50_r     <= 27'sd0;
// // // // //         rb_50_r     <= 27'sd0;
// // // // //         rg_50_r     <= 27'sd0;
// // // // //         ccm_valid_r <= 1'b0;
// // // // //     end
// // // // //     else begin
// // // // //         // 1100 = 1024 + 64 + 8 + 4
// // // // //         // = (x <<< 10) + (x <<< 6) + (x <<< 3) + (x <<< 2)
// // // // //         r_1100_r    <= (ext_r_s <<< 10) + (ext_r_s <<< 6) + (ext_r_s <<< 3) + (ext_r_s <<< 2);
// // // // //         g_1100_r    <= (ext_g_s <<< 10) + (ext_g_s <<< 6) + (ext_g_s <<< 3) + (ext_g_s <<< 2);
// // // // //         b_1100_r    <= (ext_b_s <<< 10) + (ext_b_s <<< 6) + (ext_b_s <<< 3) + (ext_b_s <<< 2);
        
// // // // //         // 50 = 32 + 16 + 2
// // // // //         // = (x <<< 5) + (x <<< 4) + (x <<< 1)
// // // // //         gb_50_r     <= (sum_gb <<< 5) + (sum_gb <<< 4) + (sum_gb <<< 1);
// // // // //         rb_50_r     <= (sum_rb <<< 5) + (sum_rb <<< 4) + (sum_rb <<< 1);
// // // // //         rg_50_r     <= (sum_rg <<< 5) + (sum_rg <<< 4) + (sum_rg <<< 1);
        
// // // // //         ccm_valid_r <= dem_valid_ff;
// // // // //     end
// // // // // end

// // // // // // 第二級 Cycle (Combinational): 利用原本很空閒的 Shift 階段來完成最後的加減法
// // // // // wire signed [26:0] r_raw = r_1100_r - gb_50_r + 27'sd512;
// // // // // wire signed [26:0] g_raw = g_1100_r - rb_50_r + 27'sd512;
// // // // // wire signed [26:0] b_raw = b_1100_r - rg_50_r + 27'sd512;

// // // // // wire signed [26:0] r_shift = r_raw >>> 10;
// // // // // wire signed [26:0] g_shift = g_raw >>> 10;
// // // // // wire signed [26:0] b_shift = b_raw >>> 10;

// // // // // wire r_is_neg = r_shift[26];
// // // // // wire g_is_neg = g_shift[26];
// // // // // wire b_is_neg = b_shift[26];

// // // // // wire [26:0] r_shift_u = $unsigned(r_shift);
// // // // // wire [26:0] g_shift_u = $unsigned(g_shift);
// // // // // wire [26:0] b_shift_u = $unsigned(b_shift);

// // // // // wire r_is_over = (|r_shift_u[25:12]) & ~r_is_neg;
// // // // // wire g_is_over = (|g_shift_u[25:12]) & ~g_is_neg;
// // // // // wire b_is_over = (|b_shift_u[25:12]) & ~b_is_neg;

// // // // // wire [12:0] r_ccm = r_is_neg ? 13'd0 : (r_is_over ? 13'd4095 : r_shift_u[12:0]);
// // // // // wire [12:0] g_ccm = g_is_neg ? 13'd0 : (g_is_over ? 13'd4095 : g_shift_u[12:0]);
// // // // // wire [12:0] b_ccm = b_is_neg ? 13'd0 : (b_is_over ? 13'd4095 : b_shift_u[12:0]);

// // // // // always @(posedge clk or negedge rst_n) begin
// // // // //     if (~rst_n) begin
// // // // //         out_valid <= 0; 
// // // // //         r_out <= 0; 
// // // // //         g_out <= 0; 
// // // // //         b_out <= 0;
// // // // //     end
// // // // //     else if (ccm_valid_r) begin 
// // // // //         out_valid <= 1;
// // // // //         r_out     <= r_ccm; 
// // // // //         g_out     <= g_ccm;
// // // // //         b_out     <= b_ccm;
// // // // //     end
// // // // //     else begin
// // // // //         out_valid <= 0; 
// // // // //         r_out <= 0; 
// // // // //         g_out <= 0; 
// // // // //         b_out <= 0;
// // // // //     end
// // // // // end

// // // // // endmodule

// // // // // module median_pipe (
// // // // //     input         clk,
// // // // //     input         rst_n,
// // // // //     input  [11:0] A, B, C, D,
// // // // //     output [11:0] median
// // // // // );
// // // // //     reg [11:0] max1_r, min1_r;
// // // // //     reg [11:0] max2_r, min2_r;

// // // // //     always @(posedge clk or negedge rst_n) begin
// // // // //         if (~rst_n) begin
// // // // //             max1_r <= 12'd0;
// // // // //             min1_r <= 12'd0;
// // // // //             max2_r <= 12'd0;
// // // // //             min2_r <= 12'd0;
// // // // //         end
// // // // //         else begin
// // // // //             if (A > B) begin
// // // // //                 max1_r <= A;
// // // // //                 min1_r <= B;
// // // // //             end
// // // // //             else begin
// // // // //                 max1_r <= B;
// // // // //                 min1_r <= A;
// // // // //             end

// // // // //             if (C > D) begin
// // // // //                 max2_r <= C;
// // // // //                 min2_r <= D;
// // // // //             end
// // // // //             else begin
// // // // //                 max2_r <= D;
// // // // //                 min2_r <= C;
// // // // //             end
// // // // //         end
// // // // //     end

// // // // //     wire [11:0] mid_low  = (min1_r > min2_r) ? min1_r : min2_r;
// // // // //     wire [11:0] mid_high = (max1_r < max2_r) ? max1_r : max2_r;
// // // // //     wire [12:0] safe_sum = {1'b0, mid_low} + {1'b0, mid_high};

// // // // //     assign median = safe_sum[12:1];
// // // // // endmodule

// // // // // module sad (
// // // // //     input  [11:0] A, B,
// // // // //     output [11:0] abs
// // // // // );
// // // // //     // 平行運算：兩個減法器同時跑，打平原本 (減法 -> XOR -> 加1) 的深層路徑
// // // // //     wire [12:0] err    = {1'b0, A} - {1'b0, B}; 
// // // // //     wire [11:0] sub_ba = B - A;
    
// // // // //     // err[12] 為 1 代表 A < B，選 B-A；否則選 A-B (err[11:0])
// // // // //     assign abs = err[12] ? sub_ba : err[11:0];
// // // // // endmodule
























// // // // module ISP (
// // // //     input         clk,
// // // //     input         rst_n,
// // // //     input         in_valid,
// // // //     input  [12:0] in,
// // // //     input         param_valid,
// // // //     input  [12:0] param_gain,

// // // //     output reg        out_valid,
// // // //     output reg [12:0] r_out,
// // // //     output reg [12:0] g_out,
// // // //     output reg [12:0] b_out
// // // // );

// // // // //==============================
// // // // //   Design
// // // // //==============================
// // // // localparam IDLE  = 2'd0;
// // // // localparam INPUT = 2'd1;
// // // // localparam DPC   = 2'd2;
// // // // localparam DEM   = 2'd3;

// // // // integer i, j;

// // // // reg  [3:0] x_cnt, y_cnt;
// // // // reg  [3:0] dpc_cnt_x, dpc_cnt_y;
// // // // reg  [7:0] dem_cnt;

// // // // reg  [1:0] cs, ns;
// // // // always @(posedge clk or negedge rst_n) begin
// // // //     if (~rst_n) cs <= IDLE;
// // // //     else        cs <= ns;
// // // // end

// // // // always @(*) begin
// // // //     ns = cs;
// // // //     case (cs)
// // // //         IDLE:  ns = (in_valid) ? INPUT : IDLE;
// // // //         INPUT: ns = (x_cnt == 5 && y_cnt == 2) ? DPC : INPUT;
// // // //         // 原本 13,13，太晚 5 cycles
// // // //         DPC:   ns = (dpc_cnt_x == 6 && dpc_cnt_y == 13) ? DEM : DPC;
// // // //         DEM:   ns = (dem_cnt == 255) ? IDLE : DEM;
// // // //     endcase
// // // // end

// // // // reg [2:0] param_x_cnt, param_y_cnt;
// // // // reg [1:0] next_gain;

// // // // always @(posedge clk or negedge rst_n) begin
// // // //     if (~rst_n) begin
// // // //         param_x_cnt <= 0;
// // // //         param_y_cnt <= 0; 
// // // //         next_gain <= 0;
// // // //     end
// // // //     else if (param_valid) begin
// // // //         if (param_x_cnt == 5 && param_y_cnt == 5) begin
// // // //             param_x_cnt <= 0;
// // // //             param_y_cnt <= 0; 
// // // //             next_gain <= next_gain + 1;
// // // //         end
// // // //         else if (param_x_cnt == 5) begin 
// // // //             param_x_cnt <= 3'd0;
// // // //             param_y_cnt <= param_y_cnt + 3'd1;
// // // //         end
// // // //         else
// // // //             param_x_cnt <= param_x_cnt + 3'd1;
// // // //     end
// // // // end

// // // // reg  [12:0] r_matrix  [0:5][0:5];
// // // // reg  [12:0] gr_matrix [0:5][0:5];
// // // // reg  [12:0] gb_matrix [0:5][0:5];
// // // // reg  [12:0] b_matrix  [0:5][0:5];

// // // // always @(posedge clk or negedge rst_n) begin
// // // //     if (~rst_n) begin
// // // //         for (i = 0; i < 6; i = i + 1) 
// // // //         for (j = 0; j < 6; j = j + 1) begin
// // // //             r_matrix[i][j]  <= 0;
// // // //             gr_matrix[i][j] <= 0;
// // // //             gb_matrix[i][j] <= 0; 
// // // //             b_matrix[i][j]  <= 0;
// // // //         end
// // // //     end
// // // //     else if (param_valid) begin
// // // //         case (next_gain)
// // // //             0: r_matrix[param_y_cnt][param_x_cnt]  <= param_gain;
// // // //             1: gr_matrix[param_y_cnt][param_x_cnt] <= param_gain;
// // // //             2: gb_matrix[param_y_cnt][param_x_cnt] <= param_gain;
// // // //             3: b_matrix[param_y_cnt][param_x_cnt]  <= param_gain;
// // // //         endcase
// // // //     end
// // // // end

// // // // // ====================== BLC =====================
// // // // always @(posedge clk or negedge rst_n) begin
// // // //     if (~rst_n) begin
// // // //         x_cnt <= 0;
// // // //         y_cnt <= 0;
// // // //     end
// // // //     else if (in_valid) begin
// // // //         if (x_cnt == 15) begin 
// // // //             x_cnt <= 0;
// // // //             y_cnt <= y_cnt + 1;
// // // //         end
// // // //         else 
// // // //             x_cnt <= x_cnt + 1;
// // // //     end
// // // // end

// // // // wire [1:0] color_id = {y_cnt[0], x_cnt[0]};
// // // // reg  [6:0] black_level;
// // // // always @(*) begin
// // // //     case (color_id)
// // // //         2'b00: black_level = 64;
// // // //         2'b01: black_level = 48; 
// // // //         2'b10: black_level = 52; 
// // // //         2'b11: black_level = 72; 
// // // //     endcase
// // // // end

// // // // wire [13:0] in_ext = {1'b0, in};
// // // // wire [13:0] sub_r  = in_ext - 14'd64;
// // // // wire [13:0] sub_gr = in_ext - 14'd48;
// // // // wire [13:0] sub_gb = in_ext - 14'd52;
// // // // wire [13:0] sub_b  = in_ext - 14'd72;

// // // // reg [13:0] sub_result;
// // // // always @(*) begin
// // // //     case (color_id)
// // // //         2'b00: sub_result = sub_r;
// // // //         2'b01: sub_result = sub_gr;
// // // //         2'b10: sub_result = sub_gb;
// // // //         2'b11: sub_result = sub_b;
// // // //     endcase
// // // // end

// // // // wire [12:0] i_blc = sub_result[13] ? 13'd0 : sub_result[12:0];

// // // // // ====================== LSC 座標 LUT =====================
// // // // // 展開為查表，消除減法器的 Critical Path
// // // // reg [2:0] x0, y0; 
// // // // reg [1:0] rx, ry;

// // // // always @(*) begin
// // // //     case (x_cnt)
// // // //         4'd0:  begin x0 = 3'd0; rx = 2'd0; end
// // // //         4'd1:  begin x0 = 3'd0; rx = 2'd1; end
// // // //         4'd2:  begin x0 = 3'd0; rx = 2'd2; end
// // // //         4'd3:  begin x0 = 3'd1; rx = 2'd0; end
// // // //         4'd4:  begin x0 = 3'd1; rx = 2'd1; end
// // // //         4'd5:  begin x0 = 3'd1; rx = 2'd2; end
// // // //         4'd6:  begin x0 = 3'd2; rx = 2'd0; end
// // // //         4'd7:  begin x0 = 3'd2; rx = 2'd1; end
// // // //         4'd8:  begin x0 = 3'd2; rx = 2'd2; end
// // // //         4'd9:  begin x0 = 3'd3; rx = 2'd0; end
// // // //         4'd10: begin x0 = 3'd3; rx = 2'd1; end
// // // //         4'd11: begin x0 = 3'd3; rx = 2'd2; end
// // // //         4'd12: begin x0 = 3'd4; rx = 2'd0; end
// // // //         4'd13: begin x0 = 3'd4; rx = 2'd1; end
// // // //         4'd14: begin x0 = 3'd4; rx = 2'd2; end
// // // //         4'd15: begin x0 = 3'd4; rx = 2'd2; end
// // // //         default: begin x0 = 3'd0; rx = 2'd0; end
// // // //     endcase
// // // // end

// // // // always @(*) begin
// // // //     case (y_cnt)
// // // //         4'd0:  begin y0 = 3'd0; ry = 2'd0; end
// // // //         4'd1:  begin y0 = 3'd0; ry = 2'd1; end
// // // //         4'd2:  begin y0 = 3'd0; ry = 2'd2; end
// // // //         4'd3:  begin y0 = 3'd1; ry = 2'd0; end
// // // //         4'd4:  begin y0 = 3'd1; ry = 2'd1; end
// // // //         4'd5:  begin y0 = 3'd1; ry = 2'd2; end
// // // //         4'd6:  begin y0 = 3'd2; ry = 2'd0; end
// // // //         4'd7:  begin y0 = 3'd2; ry = 2'd1; end
// // // //         4'd8:  begin y0 = 3'd2; ry = 2'd2; end
// // // //         4'd9:  begin y0 = 3'd3; ry = 2'd0; end
// // // //         4'd10: begin y0 = 3'd3; ry = 2'd1; end
// // // //         4'd11: begin y0 = 3'd3; ry = 2'd2; end
// // // //         4'd12: begin y0 = 3'd4; ry = 2'd0; end
// // // //         4'd13: begin y0 = 3'd4; ry = 2'd1; end
// // // //         4'd14: begin y0 = 3'd4; ry = 2'd2; end
// // // //         4'd15: begin y0 = 3'd4; ry = 2'd2; end
// // // //         default: begin y0 = 3'd0; ry = 2'd0; end
// // // //     endcase
// // // // end

// // // // reg [12:0] g00, g01, g10, g11;
// // // // always @(*) begin
// // // //     case (color_id)
// // // //         2'b00: begin
// // // //             g00 = r_matrix[y0][x0];
// // // //             g01 = r_matrix[y0][x0 + 3'd1];
// // // //             g10 = r_matrix[y0 + 3'd1][x0];
// // // //             g11 = r_matrix[y0 + 3'd1][x0 + 3'd1];
// // // //         end
// // // //         2'b01: begin
// // // //             g00 = gr_matrix[y0][x0];
// // // //             g01 = gr_matrix[y0][x0 + 3'd1];
// // // //             g10 = gr_matrix[y0 + 3'd1][x0];
// // // //             g11 = gr_matrix[y0 + 3'd1][x0 + 3'd1];
// // // //         end
// // // //         2'b10: begin
// // // //             g00 = gb_matrix[y0][x0];
// // // //             g01 = gb_matrix[y0][x0 + 3'd1];
// // // //             g10 = gb_matrix[y0 + 3'd1][x0];
// // // //             g11 = gb_matrix[y0 + 3'd1][x0 + 3'd1];
// // // //         end
// // // //         2'b11: begin
// // // //             g00 = b_matrix[y0][x0];
// // // //             g01 = b_matrix[y0][x0 + 3'd1];
// // // //             g10 = b_matrix[y0 + 3'd1][x0];
// // // //             g11 = b_matrix[y0 + 3'd1][x0 + 3'd1];
// // // //         end
// // // //     endcase
// // // // end

// // // // // ====================== MUX 延遲重構 =====================
// // // // // 先 MUX 出 opA 和 opB，最後才進入共用的加法器 (m_14535)
// // // // reg [12:0] m_29241, m_7225;
// // // // reg [12:0] opA_14535, opB_14535; 
// // // // wire [13:0] m_14535 = opA_14535 + opB_14535;

// // // // // 1. 補上 4'b0000 的特例，利用數學魔法自動產生 g00
// // // // always @(*) begin
// // // //     m_29241 = 0;
// // // //     opA_14535 = 0; 
// // // //     opB_14535 = 0; 
// // // //     m_7225  = 0;
// // // //     case ({rx, ry})
// // // //         4'b0000: begin m_29241 = g00; opA_14535 = g00; opB_14535 = g00; m_7225 = g00; end 
// // // //         4'b0001: begin m_29241 = g00; opA_14535 = g00; opB_14535 = g10; m_7225 = g10; end
// // // //         4'b0010: begin m_29241 = g10; opA_14535 = g00; opB_14535 = g10; m_7225 = g00; end
// // // //         4'b0100: begin m_29241 = g00; opA_14535 = g00; opB_14535 = g01; m_7225 = g01; end
// // // //         4'b1000: begin m_29241 = g01; opA_14535 = g00; opB_14535 = g01; m_7225 = g00; end
// // // //         4'b0101: begin m_29241 = g00; opA_14535 = g01; opB_14535 = g10; m_7225 = g11; end
// // // //         4'b0110: begin m_29241 = g10; opA_14535 = g00; opB_14535 = g11; m_7225 = g01; end
// // // //         4'b1001: begin m_29241 = g01; opA_14535 = g00; opB_14535 = g11; m_7225 = g10; end
// // // //         4'b1010: begin m_29241 = g11; opA_14535 = g01; opB_14535 = g10; m_7225 = g00; end
// // // //     endcase
// // // // end

// // // // reg [12:0] m_29241_ff, m_7225_ff;
// // // // reg [13:0] m_14535_ff;
// // // // reg [12:0] i_blc_ff;
// // // // reg        in_valid_ff;
// // // // always @(posedge clk) begin
// // // //     m_29241_ff  <= m_29241; 
// // // //     m_14535_ff  <= m_14535; 
// // // //     m_7225_ff   <= m_7225;
// // // //     i_blc_ff    <= i_blc;
// // // //     in_valid_ff <= in_valid;
// // // // end

// // // // // ======================================================================
// // // // // 3. 改良版 CSD 展開：使用「平衡加法樹 (Balanced Tree)」縮短 Critical Path
// // // // // ======================================================================

// // // // wire [29:0] ext_29241 = {17'b0, m_29241_ff};
// // // // wire [29:0] ext_14535 = {16'b0, m_14535_ff};
// // // // wire [29:0] ext_7225  = {17'b0, m_7225_ff};

// // // // // 29241 = 32768 - 4096 + 512 + 64 - 8 + 1
// // // // // 將 6 個項目拆成兩兩一組平行計算，降低邏輯層級深度
// // // // wire [29:0] t1_29 = (ext_29241 << 15) - (ext_29241 << 12);
// // // // wire [29:0] t2_29 = (ext_29241 << 9)  + (ext_29241 << 6);
// // // // wire [29:0] t3_29 = ext_29241         - (ext_29241 << 3);
// // // // wire [29:0] mul_29241 = (t1_29 + t2_29) + t3_29;

// // // // // 14535 = 16384 - 2048 + 256 - 64 + 8 - 1
// // // // wire [29:0] t1_14 = (ext_14535 << 14) - (ext_14535 << 11);
// // // // wire [29:0] t2_14 = (ext_14535 << 8)  - (ext_14535 << 6);
// // // // wire [29:0] t3_14 = (ext_14535 << 3)  - ext_14535;
// // // // wire [29:0] mul_14535 = (t1_14 + t2_14) + t3_14;

// // // // // 7225 = 8192 - 1024 + 64 - 8 + 1
// // // // wire [29:0] t1_72 = (ext_7225 << 13) - (ext_7225 << 10);
// // // // wire [29:0] t2_72 = (ext_7225 << 6)  - (ext_7225 << 3);
// // // // wire [29:0] mul_7225 = (t1_72 + t2_72) + ext_7225;

// // // // wire [29:0] sum_part1   = mul_29241 + mul_14535;
// // // // wire [29:0] gxy_sum_opt = sum_part1 + mul_7225;

// // // // // 4. 四捨五入照舊
// // // // wire [13:0] gxy = gxy_sum_opt[29:16] + gxy_sum_opt[15];

// // // // reg [13:0] gxy_ff;
// // // // reg [12:0] i_blc_ff_ff;
// // // // reg        in_valid_ff_ff;
// // // // always @(posedge clk) begin
// // // //     gxy_ff         <= gxy;
// // // //     i_blc_ff_ff    <= i_blc_ff; 
// // // //     in_valid_ff_ff <= in_valid_ff; 
// // // // end

// // // // // ======================================================================
// // // // // 改良版 Multiplier: 拆分為高低位元部分積，將加法推移至下一個 Cycle
// // // // // ======================================================================
// // // // reg [19:0] p_sum_H_r;
// // // // reg [19:0] p_sum_L_r;
// // // // reg        pp_valid_r;

// // // // always @(posedge clk or negedge rst_n) begin
// // // //     if (~rst_n) begin
// // // //         p_sum_H_r  <= 20'd0;
// // // //         p_sum_L_r  <= 20'd0;
// // // //         pp_valid_r <= 1'b0;
// // // //     end
// // // //     else begin
// // // //         p_sum_H_r  <= gxy_ff[13:7] * i_blc_ff_ff;
// // // //         p_sum_L_r  <= gxy_ff[6:0]  * i_blc_ff_ff;
// // // //         pp_valid_r <= in_valid_ff_ff;
// // // //     end
// // // // end

// // // // // 在下一個 Cycle 合併部分積 (Shift and Add)
// // // // wire [26:0] p_sum_w_full = {p_sum_H_r, 7'd0} + p_sum_L_r;

// // // // // 維持原本的四捨五入邏輯
// // // // wire [16:0] p_sum_round = p_sum_w_full[25:10] + p_sum_w_full[9];
// // // // wire p_is_over = |p_sum_round[16:12];
// // // // wire [11:0] pp_xy = p_is_over ? 12'd4095 : p_sum_round[11:0];

// // // // // ====================== DPC =====================

// // // // reg [11:0] lb0 [0:15]; 
// // // // reg [11:0] lb1 [0:15];
// // // // reg [11:0] lb2 [0:15];
// // // // reg [11:0] lb3 [0:15];
// // // // reg [11:0] lb4 [0:4]; 

// // // // always @(posedge clk) begin
// // // //     if (pp_valid_r || cs == DPC || cs == DEM) begin
// // // //         for (i = 15; i > 0; i = i - 1) begin
// // // //             lb3[i] <= lb3[i - 1];
// // // //             lb2[i] <= lb2[i - 1];
// // // //             lb1[i] <= lb1[i - 1]; 
// // // //             lb0[i] <= lb0[i - 1];
// // // //         end
// // // //         lb3[0] <= lb2[15]; 
// // // //         lb2[0] <= lb1[15];
// // // //         lb1[0] <= lb0[15];
// // // //         lb0[0] <= (pp_valid_r) ? pp_xy : 12'd0;
        
// // // //         for (i = 4; i > 0; i = i - 1) 
// // // //             lb4[i] <= lb4[i - 1];
// // // //         lb4[0] <= lb3[15];
// // // //     end
// // // //     else begin
// // // //         for (i = 0; i < 16; i = i + 1) begin
// // // //             lb0[i] <= 0;
// // // //             lb1[i] <= 0; 
// // // //             lb2[i] <= 0; 
// // // //             lb3[i] <= 0;
// // // //         end
// // // //         for (i = 0; i < 5; i = i + 1) 
// // // //             lb4[i] <= 0;
// // // //     end
// // // // end

// // // // reg [11:0] px_mat [0:4][0:4];

// // // // always @(*) begin
// // // //     for (i = 0; i < 5; i = i + 1) begin
// // // //         px_mat[4][i] = lb0[4 - i];
// // // //         px_mat[3][i] = lb1[4 - i];
// // // //         px_mat[2][i] = lb2[4 - i];
// // // //         px_mat[1][i] = lb3[4 - i];
// // // //         px_mat[0][i] = lb4[4 - i];
// // // //     end
// // // // end

// // // // // ====================== DPC  =====================

// // // // always @(posedge clk) begin
// // // //     if (cs == DPC || cs == DEM) begin
// // // //         if (dpc_cnt_x == 15) begin
// // // //             dpc_cnt_x <= 0;
// // // //             if (dpc_cnt_y == 15) 
// // // //                 dpc_cnt_y <= 0;
// // // //             else 
// // // //                 dpc_cnt_y <= dpc_cnt_y + 1;
// // // //         end
// // // //         else 
// // // //             dpc_cnt_x <= dpc_cnt_x + 1;
// // // //     end
// // // //     else begin
// // // //         dpc_cnt_x <= 0; 
// // // //         dpc_cnt_y <= 0;
// // // //     end
// // // // end

// // // // reg [2:0] px [0:4];
// // // // reg [2:0] py [0:4];

// // // // always @(*) begin
// // // //     px[0] = (dpc_cnt_x == 4'd0)  ? 3'd4 : (dpc_cnt_x == 4'd1)  ? 3'd2 : 3'd0;
// // // //     px[1] = (dpc_cnt_x == 4'd0)  ? 3'd3 : 3'd1;
// // // //     px[2] = 3'd2; 
// // // //     px[3] = (dpc_cnt_x == 4'd15) ? 3'd1 : 3'd3; 
// // // //     px[4] = (dpc_cnt_x == 4'd15) ? 3'd0 : (dpc_cnt_x == 4'd14) ? 3'd2 : 3'd4;

// // // //     py[0] = (dpc_cnt_y == 4'd0)  ? 3'd4 : (dpc_cnt_y == 4'd1)  ? 3'd2 : 3'd0;
// // // //     py[1] = (dpc_cnt_y == 4'd0)  ? 3'd3 : 3'd1;
// // // //     py[2] = 3'd2; 
// // // //     py[3] = (dpc_cnt_y == 4'd15) ? 3'd1 : 3'd3; 
// // // //     py[4] = (dpc_cnt_y == 4'd15) ? 3'd0 : (dpc_cnt_y == 4'd14) ? 3'd2 : 3'd4;
// // // // end

// // // // reg [11:0] p_row_0 [0:4]; 
// // // // reg [11:0] p_row_1 [0:4];
// // // // reg [11:0] p_row_2 [0:4];
// // // // reg [11:0] p_row_3 [0:4]; 
// // // // reg [11:0] p_row_4 [0:4];
// // // // always @(*) begin
// // // //     for(i = 0; i < 5; i = i + 1) begin
// // // //         p_row_0[i] = px_mat[py[0]][i];
// // // //         p_row_1[i] = px_mat[py[1]][i];
// // // //         p_row_2[i] = px_mat[py[2]][i]; 
// // // //         p_row_3[i] = px_mat[py[3]][i];
// // // //         p_row_4[i] = px_mat[py[4]][i];
// // // //     end
// // // // end

// // // // reg [11:0] H  [0:3];
// // // // reg [11:0] V  [0:3];
// // // // reg [11:0] D1 [0:3];
// // // // reg [11:0] D2 [0:3];
// // // // always @(*) begin
// // // //     H[0]  = p_row_2[px[0]]; 
// // // //     H[1]  = p_row_2[px[1]]; 
// // // //     H[2]  = p_row_2[px[3]];
// // // //     H[3]  = p_row_2[px[4]];

// // // //     V[0]  = p_row_0[px[2]]; 
// // // //     V[1]  = p_row_1[px[2]]; 
// // // //     V[2]  = p_row_3[px[2]]; 
// // // //     V[3]  = p_row_4[px[2]];
    
// // // //     D1[0] = p_row_0[px[0]]; 
// // // //     D1[1] = p_row_1[px[1]]; 
// // // //     D1[2] = p_row_3[px[3]]; 
// // // //     D1[3] = p_row_4[px[4]];

// // // //     D2[0] = p_row_0[px[4]]; 
// // // //     D2[1] = p_row_1[px[3]];
// // // //     D2[2] = p_row_3[px[1]]; 
// // // //     D2[3] = p_row_4[px[0]];
// // // // end

// // // // reg [11:0] H_ff[0:3], V_ff[0:3], D1_ff[0:3], D2_ff[0:3];
// // // // reg [11:0] P_ff;
// // // // reg        dpc_valid_ff;

// // // // always @(posedge clk) begin
// // // //     for(i = 0; i < 4; i = i + 1) begin
// // // //         H_ff[i] <= H[i];
// // // //         V_ff[i] <= V[i]; 
// // // //         D1_ff[i] <= D1[i]; 
// // // //         D2_ff[i] <= D2[i];
// // // //     end
// // // //     P_ff <= p_row_2[px[2]];
// // // //     dpc_valid_ff <= (cs == DPC || cs == DEM);
// // // // end

// // // // wire [11:0] med_H, med_V, med_D1, med_D2;

// // // // median_pipe calc_med_H (
// // // //     .clk(clk), .rst_n(rst_n),
// // // //     .A(H_ff[0]), .B(H_ff[1]), .C(H_ff[2]), .D(H_ff[3]),
// // // //     .median(med_H)
// // // // );
// // // // median_pipe calc_med_V (
// // // //     .clk(clk), .rst_n(rst_n),
// // // //     .A(V_ff[0]), .B(V_ff[1]), .C(V_ff[2]), .D(V_ff[3]),
// // // //     .median(med_V)
// // // // );
// // // // median_pipe calc_med_D1 (
// // // //     .clk(clk), .rst_n(rst_n),
// // // //     .A(D1_ff[0]), .B(D1_ff[1]), .C(D1_ff[2]), .D(D1_ff[3]),
// // // //     .median(med_D1)
// // // // );
// // // // median_pipe calc_med_D2 (
// // // //     .clk(clk), .rst_n(rst_n),
// // // //     .A(D2_ff[0]), .B(D2_ff[1]), .C(D2_ff[2]), .D(D2_ff[3]),
// // // //     .median(med_D2)
// // // // );

// // // // reg [11:0] H_ff_d[0:3], V_ff_d[0:3], D1_ff_d[0:3], D2_ff_d[0:3];
// // // // reg [11:0] P_ff_d;
// // // // reg        dpc_valid_ff_d;
// // // // reg [11:0] H_ff_ff[0:3], V_ff_ff[0:3], D1_ff_ff[0:3], D2_ff_ff[0:3];
// // // // reg [11:0] med_H_ff, med_V_ff, med_D1_ff, med_D2_ff;
// // // // reg [11:0] P_ff_ff;
// // // // reg        dpc_valid_ff_ff;

// // // // always @(posedge clk) begin
// // // //     for (i = 0; i < 4; i = i + 1) begin
// // // //         H_ff_d[i]  <= H_ff[i];
// // // //         V_ff_d[i]  <= V_ff[i];
// // // //         D1_ff_d[i] <= D1_ff[i];
// // // //         D2_ff_d[i] <= D2_ff[i];
// // // //     end
// // // //     P_ff_d         <= P_ff;
// // // //     dpc_valid_ff_d <= dpc_valid_ff;
// // // // end

// // // // always @(posedge clk) begin
// // // //     for(i = 0; i < 4; i = i + 1) begin
// // // //         H_ff_ff[i]  <= H_ff_d[i];
// // // //         V_ff_ff[i]  <= V_ff_d[i]; 
// // // //         D1_ff_ff[i] <= D1_ff_d[i]; 
// // // //         D2_ff_ff[i] <= D2_ff_d[i];
// // // //     end
// // // //     med_H_ff  <= med_H;
// // // //     med_V_ff  <= med_V; 
// // // //     med_D1_ff <= med_D1; 
// // // //     med_D2_ff <= med_D2;
// // // //     P_ff_ff <= P_ff_d;
// // // //     dpc_valid_ff_ff <= dpc_valid_ff_d;
// // // // end

// // // // wire [11:0] err_H0, err_H1, err_H2, err_H3;
// // // // wire [11:0] err_V0, err_V1, err_V2, err_V3;
// // // // wire [11:0] err_D1_0, err_D1_1, err_D1_2, err_D1_3;
// // // // wire [11:0] err_D2_0, err_D2_1, err_D2_2, err_D2_3;

// // // // sad sad_h0 (.A(H_ff_ff[0]), .B(med_H_ff), .abs(err_H0)); 
// // // // sad sad_h1 (.A(H_ff_ff[1]), .B(med_H_ff), .abs(err_H1));
// // // // sad sad_h2 (.A(H_ff_ff[2]), .B(med_H_ff), .abs(err_H2)); 
// // // // sad sad_h3 (.A(H_ff_ff[3]), .B(med_H_ff), .abs(err_H3));
// // // // wire [13:0] SAD_H = err_H0 + err_H1 + err_H2 + err_H3;

// // // // sad sad_v0 (.A(V_ff_ff[0]), .B(med_V_ff), .abs(err_V0));
// // // // sad sad_v1 (.A(V_ff_ff[1]), .B(med_V_ff), .abs(err_V1));
// // // // sad sad_v2 (.A(V_ff_ff[2]), .B(med_V_ff), .abs(err_V2)); 
// // // // sad sad_v3 (.A(V_ff_ff[3]), .B(med_V_ff), .abs(err_V3));
// // // // wire [13:0] SAD_V = err_V0 + err_V1 + err_V2 + err_V3;

// // // // sad sad_d1_0 (.A(D1_ff_ff[0]), .B(med_D1_ff), .abs(err_D1_0));
// // // // sad sad_d1_1 (.A(D1_ff_ff[1]), .B(med_D1_ff), .abs(err_D1_1));
// // // // sad sad_d1_2 (.A(D1_ff_ff[2]), .B(med_D1_ff), .abs(err_D1_2)); 
// // // // sad sad_d1_3 (.A(D1_ff_ff[3]), .B(med_D1_ff), .abs(err_D1_3));
// // // // wire [13:0] SAD_D1 = err_D1_0 + err_D1_1 + err_D1_2 + err_D1_3;

// // // // sad sad_d2_0 (.A(D2_ff_ff[0]), .B(med_D2_ff), .abs(err_D2_0));
// // // // sad sad_d2_1 (.A(D2_ff_ff[1]), .B(med_D2_ff), .abs(err_D2_1));
// // // // sad sad_d2_2 (.A(D2_ff_ff[2]), .B(med_D2_ff), .abs(err_D2_2)); 
// // // // sad sad_d2_3 (.A(D2_ff_ff[3]), .B(med_D2_ff), .abs(err_D2_3));
// // // // wire [13:0] SAD_D2 = err_D2_0 + err_D2_1 + err_D2_2 + err_D2_3;

// // // // // // ====================== DPC =====================

// // // // reg  [3:0] dem_cnt_x, dem_cnt_y;
// // // // always @(posedge clk or negedge rst_n) begin
// // // //     if (~rst_n) begin
// // // //         dem_cnt <= 0;
// // // //         dem_cnt_x <= 0; 
// // // //         dem_cnt_y <= 0;
// // // //     end
// // // //     else if (cs == DEM) begin
// // // //         dem_cnt <= dem_cnt + 1;
// // // //         if (dem_cnt_x == 15) begin
// // // //             dem_cnt_x <= 0;
// // // //             dem_cnt_y <= dem_cnt_y + 1;
// // // //         end
// // // //         else 
// // // //             dem_cnt_x <= dem_cnt_x + 1;
// // // //     end
// // // //     else 
// // // //         dem_cnt <= 0;
// // // // end

// // // // reg [13:0] SAD_H_ff, SAD_V_ff, SAD_D1_ff, SAD_D2_ff;
// // // // reg [11:0] med_H_ff_ff, med_V_ff_ff, med_D1_ff_ff, med_D2_ff_ff;
// // // // reg [11:0] P_ff_ff_ff;
// // // // reg        dpc_valid_ff_ff_ff;

// // // // always @(posedge clk) begin
// // // //     SAD_H_ff  <= SAD_H;
// // // //     SAD_V_ff  <= SAD_V; 
// // // //     SAD_D1_ff <= SAD_D1; 
// // // //     SAD_D2_ff <= SAD_D2;
// // // //     med_H_ff_ff  <= med_H_ff;  
// // // //     med_V_ff_ff  <= med_V_ff;
// // // //     med_D1_ff_ff <= med_D1_ff; 
// // // //     med_D2_ff_ff <= med_D2_ff;
// // // //     P_ff_ff_ff   <= P_ff_ff;
// // // //     dpc_valid_ff_ff_ff <= dpc_valid_ff_ff;
// // // // end

// // // // wire cmp_HV = (SAD_H_ff <= SAD_V_ff);
// // // // wire [13:0] min_SAD_HV = cmp_HV ? SAD_H_ff : SAD_V_ff;
// // // // wire [11:0] target_HV  = cmp_HV ? med_H_ff_ff : med_V_ff_ff;
// // // // wire cmp_D1D2 = (SAD_D1_ff <= SAD_D2_ff);
// // // // wire [13:0] min_SAD_D1D2 = cmp_D1D2 ? SAD_D1_ff : SAD_D2_ff;
// // // // wire [11:0] target_D1D2  = cmp_D1D2 ? med_D1_ff_ff : med_D2_ff_ff;

// // // // wire cmp_final = (min_SAD_HV <= min_SAD_D1D2);
// // // // wire [11:0] Target_w = cmp_final ? target_HV : target_D1D2;

// // // // reg [11:0] Target_r;
// // // // reg [11:0] P_replace_r;
// // // // always @(posedge clk or negedge rst_n) begin
// // // //     if (~rst_n) begin
// // // //         Target_r    <= 12'd0;
// // // //         P_replace_r <= 12'd0;
// // // //     end
// // // //     else begin
// // // //         Target_r    <= Target_w;
// // // //         P_replace_r <= P_ff_ff_ff;
// // // //     end
// // // // end

// // // // wire replace_cond = ({1'b0, P_replace_r} > {1'b0, Target_r} + 13'd320) ||
// // // //                     ({1'b0, Target_r} > {1'b0, P_replace_r} + 13'd320);

// // // // wire [11:0] dpc_out = replace_cond ? Target_r : P_replace_r;

// // // // reg [11:0] dpc_fifo [0:235];
// // // // always @(posedge clk) begin
// // // //     for (i = 235; i > 0; i = i - 1) 
// // // //         dpc_fifo[i] <= dpc_fifo[i - 1];
// // // //     dpc_fifo[0] <= dpc_out;
// // // // end

// // // // // ============================ dem ===================================

// // // // wire [1:0] dem_color_id = {dem_cnt_y[0], dem_cnt_x[0]};

// // // // wire [11:0] raw_C  = dpc_fifo[209];
// // // // wire [11:0] raw_E  = dpc_fifo[208];
// // // // wire [11:0] raw_W  = dpc_fifo[210];
// // // // wire [11:0] raw_S  = dpc_fifo[193];
// // // // wire [11:0] raw_SE = dpc_fifo[192];
// // // // wire [11:0] raw_SW = dpc_fifo[194];
// // // // wire [11:0] raw_N  = dpc_fifo[225];
// // // // wire [11:0] raw_NE = dpc_fifo[224];
// // // // wire [11:0] raw_NW = dpc_fifo[226];

// // // // wire is_top    = (dem_cnt_y == 0);
// // // // wire is_bottom = (dem_cnt_y == 15);
// // // // wire is_left   = (dem_cnt_x == 0);
// // // // wire is_right  = (dem_cnt_x == 15);

// // // // wire [11:0] C = raw_C;
// // // // wire [11:0] W = is_left   ? raw_E : raw_W;
// // // // wire [11:0] E = is_right  ? raw_W : raw_E;
// // // // wire [11:0] N = is_top    ? raw_S : raw_N;
// // // // wire [11:0] S = is_bottom ? raw_N : raw_S;

// // // // wire [11:0] NW = (is_top & is_left)  ? raw_SE :
// // // //                  (is_top)            ? raw_SW :
// // // //                  (is_left)           ? raw_NE : raw_NW;

// // // // wire [11:0] NE = (is_top & is_right) ? raw_SW :
// // // //                  (is_top)            ? raw_SE :
// // // //                  (is_right)          ? raw_NW : raw_NE;

// // // // wire [11:0] SW = (is_bottom & is_left) ? raw_NE :
// // // //                  (is_bottom)           ? raw_NW :
// // // //                  (is_left)             ? raw_SE : raw_SW;

// // // // wire [11:0] SE = (is_bottom & is_right) ? raw_NW :
// // // //                  (is_bottom)            ? raw_NE :
// // // //                  (is_right)             ? raw_SW : raw_SE;


// // // // wire [12:0] total_ns = N + S; 
// // // // wire [12:0] total_we = W + E;
// // // // wire [13:0] total_nswe  = total_ns + total_we; 
// // // // wire [13:0] total_other = (NW + NE) + (SW + SE);
// // // // wire [11:0] avg_nswe   = total_nswe[13:2]; 
// // // // wire [11:0] avg_pother = total_other[13:2];
// // // // wire [11:0] avg_ns     = total_ns[12:1];     
// // // // wire [11:0] avg_we     = total_we[12:1];
// // // // reg [11:0] r_interp, g_interp, b_interp;

// // // // always @(*) begin
// // // //     case (dem_color_id)
// // // //         2'b00: begin r_interp = C;          g_interp = avg_nswe; b_interp = avg_pother; end 
// // // //         2'b01: begin r_interp = avg_we;     g_interp = C;        b_interp = avg_ns;     end 
// // // //         2'b10: begin r_interp = avg_ns;     g_interp = C;        b_interp = avg_we;     end 
// // // //         2'b11: begin r_interp = avg_pother; g_interp = avg_nswe; b_interp = C;          end 
// // // //     endcase
// // // // end

// // // // reg [11:0] r_dem_ff, g_dem_ff, b_dem_ff;
// // // // reg        dem_valid_ff;

// // // // always @(posedge clk) begin
// // // //     r_dem_ff     <= r_interp;
// // // //     g_dem_ff     <= g_interp;
// // // //     b_dem_ff     <= b_interp;
// // // //     dem_valid_ff <= (cs == DEM);
// // // // end

// // // // // ========================== CCM =====================================

// // // // // 擴充至 15 bits signed 以防 g_s + b_s 溢位
// // // // wire signed [14:0] r_s = $signed({3'b0, r_dem_ff});
// // // // wire signed [14:0] g_s = $signed({3'b0, g_dem_ff});
// // // // wire signed [14:0] b_s = $signed({3'b0, b_dem_ff});
// // // // // 數學化簡： r*1150 - (r+g+b)*50 = r*1100 - (g+b)*50
// // // // localparam signed [15:0] C_1100 = 16'sd1100;
// // // // localparam signed [15:0] C_50   = 16'sd50;

// // // // reg signed [26:0] r_1100_r, g_1100_r, b_1100_r;
// // // // reg signed [26:0] gb_50_r, rb_50_r, rg_50_r;
// // // // reg               ccm_valid_r;
// // // // // Signed 操作時，為確保符號位元 (Sign bit) 正確延伸，需使用 `<<<` 算術移位
// // // // // 先擴充到 27 bits signed 以防止溢位
// // // // wire signed [26:0] ext_r_s = r_s;
// // // // wire signed [26:0] ext_g_s = g_s;
// // // // wire signed [26:0] ext_b_s = b_s;

// // // // wire signed [26:0] sum_gb = g_s + b_s;
// // // // wire signed [26:0] sum_rb = r_s + b_s;
// // // // wire signed [26:0] sum_rg = r_s + g_s;
// // // // always @(posedge clk or negedge rst_n) begin
// // // //     if (~rst_n) begin
// // // //         r_1100_r    <= 27'sd0;
// // // //         g_1100_r    <= 27'sd0;
// // // //         b_1100_r    <= 27'sd0;
// // // //         gb_50_r     <= 27'sd0;
// // // //         rb_50_r     <= 27'sd0;
// // // //         rg_50_r     <= 27'sd0;
// // // //         ccm_valid_r <= 1'b0;
// // // //     end
// // // //     else begin
// // // //         // 1100 = 1024 + 64 + 8 + 4
// // // //         // = (x <<< 10) + (x <<< 6) + (x <<< 3) + (x <<< 2)
// // // //         r_1100_r    <= (ext_r_s <<< 10) + (ext_r_s <<< 6) + (ext_r_s <<< 3) + (ext_r_s <<< 2);
// // // //         g_1100_r    <= (ext_g_s <<< 10) + (ext_g_s <<< 6) + (ext_g_s <<< 3) + (ext_g_s <<< 2);
// // // //         b_1100_r    <= (ext_b_s <<< 10) + (ext_b_s <<< 6) + (ext_b_s <<< 3) + (ext_b_s <<< 2);
// // // //         // 50 = 32 + 16 + 2
// // // //         // = (x <<< 5) + (x <<< 4) + (x <<< 1)
// // // //         gb_50_r     <= (sum_gb <<< 5) + (sum_gb <<< 4) + (sum_gb <<< 1);
// // // //         rb_50_r     <= (sum_rb <<< 5) + (sum_rb <<< 4) + (sum_rb <<< 1);
// // // //         rg_50_r     <= (sum_rg <<< 5) + (sum_rg <<< 4) + (sum_rg <<< 1);
        
// // // //         ccm_valid_r <= dem_valid_ff;
// // // //     end
// // // // end

// // // // // 第二級 Cycle (Combinational): 利用原本很空閒的 Shift 階段來完成最後的加減法
// // // // wire signed [26:0] r_raw = r_1100_r - gb_50_r + 27'sd512;
// // // // wire signed [26:0] g_raw = g_1100_r - rb_50_r + 27'sd512;
// // // // wire signed [26:0] b_raw = b_1100_r - rg_50_r + 27'sd512;
// // // // wire signed [26:0] r_shift = r_raw >>> 10;
// // // // wire signed [26:0] g_shift = g_raw >>> 10;
// // // // wire signed [26:0] b_shift = b_raw >>> 10;

// // // // wire r_is_neg = r_shift[26];
// // // // wire g_is_neg = g_shift[26];
// // // // wire b_is_neg = b_shift[26];
// // // // wire [26:0] r_shift_u = $unsigned(r_shift);
// // // // wire [26:0] g_shift_u = $unsigned(g_shift);
// // // // wire [26:0] b_shift_u = $unsigned(b_shift);
// // // // wire r_is_over = (|r_shift_u[25:12]) & ~r_is_neg;
// // // // wire g_is_over = (|g_shift_u[25:12]) & ~g_is_neg;
// // // // wire b_is_over = (|b_shift_u[25:12]) & ~b_is_neg;
// // // // wire [12:0] r_ccm = r_is_neg ? 13'd0 : (r_is_over ? 13'd4095 : r_shift_u[12:0]);
// // // // wire [12:0] g_ccm = g_is_neg ? 13'd0 : (g_is_over ? 13'd4095 : g_shift_u[12:0]);
// // // // wire [12:0] b_ccm = b_is_neg ? 13'd0 : (b_is_over ? 13'd4095 : b_shift_u[12:0]);
// // // // always @(posedge clk or negedge rst_n) begin
// // // //     if (~rst_n) begin
// // // //         out_valid <= 0;
// // // //         r_out <= 0; 
// // // //         g_out <= 0; 
// // // //         b_out <= 0;
// // // //     end
// // // //     else if (ccm_valid_r) begin 
// // // //         out_valid <= 1;
// // // //         r_out     <= r_ccm; 
// // // //         g_out     <= g_ccm;
// // // //         b_out     <= b_ccm;
// // // //     end
// // // //     else begin
// // // //         out_valid <= 0;
// // // //         r_out <= 0; 
// // // //         g_out <= 0; 
// // // //         b_out <= 0;
// // // //     end
// // // // end

// // // // endmodule

// // // // module median_pipe (
// // // //     input         clk,
// // // //     input         rst_n,
// // // //     input  [11:0] A, B, C, D,
// // // //     output [11:0] median
// // // // );
// // // //     reg [11:0] max1_r, min1_r;
// // // //     reg [11:0] max2_r, min2_r;

// // // //     always @(posedge clk or negedge rst_n) begin
// // // //         if (~rst_n) begin
// // // //             max1_r <= 12'd0;
// // // //             min1_r <= 12'd0;
// // // //             max2_r <= 12'd0;
// // // //             min2_r <= 12'd0;
// // // //         end
// // // //         else begin
// // // //             if (A > B) begin
// // // //                 max1_r <= A;
// // // //                 min1_r <= B;
// // // //             end
// // // //             else begin
// // // //                 max1_r <= B;
// // // //                 min1_r <= A;
// // // //             end

// // // //             if (C > D) begin
// // // //                 max2_r <= C;
// // // //                 min2_r <= D;
// // // //             end
// // // //             else begin
// // // //                 max2_r <= D;
// // // //                 min2_r <= C;
// // // //             end
// // // //         end
// // // //     end

// // // //     wire [11:0] mid_low  = (min1_r > min2_r) ? min1_r : min2_r;
// // // //     wire [11:0] mid_high = (max1_r < max2_r) ? max1_r : max2_r;
// // // //     wire [12:0] safe_sum = {1'b0, mid_low} + {1'b0, mid_high};

// // // //     assign median = safe_sum[12:1];
// // // // endmodule

// // // // module sad (
// // // //     input  [11:0] A, B,
// // // //     output [11:0] abs
// // // // );
// // // //     // 平行運算：兩個減法器同時跑，打平原本 (減法 -> XOR -> 加1) 的深層路徑
// // // //     wire [12:0] err    = {1'b0, A} - {1'b0, B};
// // // //     wire [11:0] sub_ba = B - A;
    
// // // //     // err[12] 為 1 代表 A < B，選 B-A；否則選 A-B (err[11:0])
// // // //     assign abs = err[12] ? sub_ba : err[11:0];
// // // // endmodule






















// // // module ISP (
// // //     input         clk,
// // //     input         rst_n,
// // //     input         in_valid,
// // //     input  [12:0] in,
// // //     input         param_valid,
// // //     input  [12:0] param_gain,

// // //     output reg        out_valid,
// // //     output reg [12:0] r_out,
// // //     output reg [12:0] g_out,
// // //     output reg [12:0] b_out
// // // );

// // // //==============================
// // // //   Design
// // // //==============================
// // // localparam IDLE  = 2'd0;
// // // localparam INPUT = 2'd1;
// // // localparam DPC   = 2'd2;
// // // localparam DEM   = 2'd3;

// // // integer i, j;

// // // reg  [3:0] x_cnt, y_cnt;
// // // reg  [3:0] dpc_cnt_x, dpc_cnt_y;
// // // reg  [7:0] dem_cnt;

// // // reg  [1:0] cs, ns;
// // // always @(posedge clk or negedge rst_n) begin
// // //     if (~rst_n) cs <= IDLE;
// // //     else        cs <= ns;
// // // end

// // // always @(*) begin
// // //     ns = cs;
// // //     case (cs)
// // //         IDLE:  ns = (in_valid) ? INPUT : IDLE;
// // //         INPUT: ns = (x_cnt == 5 && y_cnt == 2) ? DPC : INPUT;
// // //         // 原本 13,13，太晚 5 cycles
// // //         DPC:   ns = (dpc_cnt_x == 6 && dpc_cnt_y == 13) ? DEM : DPC;
// // //         DEM:   ns = (dem_cnt == 255) ? IDLE : DEM;
// // //     endcase
// // // end

// // // reg [2:0] param_x_cnt, param_y_cnt;
// // // reg [1:0] next_gain;

// // // always @(posedge clk or negedge rst_n) begin
// // //     if (~rst_n) begin
// // //         param_x_cnt <= 0;
// // //         param_y_cnt <= 0; 
// // //         next_gain <= 0;
// // //     end
// // //     else if (param_valid) begin
// // //         if (param_x_cnt == 5 && param_y_cnt == 5) begin
// // //             param_x_cnt <= 0;
// // //             param_y_cnt <= 0; 
// // //             next_gain <= next_gain + 1;
// // //         end
// // //         else if (param_x_cnt == 5) begin 
// // //             param_x_cnt <= 3'd0;
// // //             param_y_cnt <= param_y_cnt + 3'd1;
// // //         end
// // //         else
// // //             param_x_cnt <= param_x_cnt + 3'd1;
// // //     end
// // // end

// // // reg  [12:0] r_matrix  [0:5][0:5];
// // // reg  [12:0] gr_matrix [0:5][0:5];
// // // reg  [12:0] gb_matrix [0:5][0:5];
// // // reg  [12:0] b_matrix  [0:5][0:5];

// // // always @(posedge clk or negedge rst_n) begin
// // //     if (~rst_n) begin
// // //         for (i = 0; i < 6; i = i + 1) 
// // //         for (j = 0; j < 6; j = j + 1) begin
// // //             r_matrix[i][j]  <= 0;
// // //             gr_matrix[i][j] <= 0;
// // //             gb_matrix[i][j] <= 0; 
// // //             b_matrix[i][j]  <= 0;
// // //         end
// // //     end
// // //     else if (param_valid) begin
// // //         case (next_gain)
// // //             0: r_matrix[param_y_cnt][param_x_cnt]  <= param_gain;
// // //             1: gr_matrix[param_y_cnt][param_x_cnt] <= param_gain;
// // //             2: gb_matrix[param_y_cnt][param_x_cnt] <= param_gain;
// // //             3: b_matrix[param_y_cnt][param_x_cnt]  <= param_gain;
// // //         endcase
// // //     end
// // // end

// // // // ====================== BLC =====================
// // // always @(posedge clk or negedge rst_n) begin
// // //     if (~rst_n) begin
// // //         x_cnt <= 0;
// // //         y_cnt <= 0;
// // //     end
// // //     else if (in_valid) begin
// // //         if (x_cnt == 15) begin 
// // //             x_cnt <= 0;
// // //             y_cnt <= y_cnt + 1;
// // //         end
// // //         else 
// // //             x_cnt <= x_cnt + 1;
// // //     end
// // // end

// // // wire [1:0] color_id = {y_cnt[0], x_cnt[0]};
// // // // reg  [6:0] black_level;
// // // // always @(*) begin
// // // //     case (color_id)
// // // //         2'b00: black_level = 64;
// // // //         2'b01: black_level = 48; 
// // // //         2'b10: black_level = 52; 
// // // //         2'b11: black_level = 72; 
// // // //     endcase
// // // // end

// // // wire [13:0] in_ext = {1'b0, in};
// // // wire [13:0] sub_r  = in_ext - 14'd64;
// // // wire [13:0] sub_gr = in_ext - 14'd48;
// // // wire [13:0] sub_gb = in_ext - 14'd52;
// // // wire [13:0] sub_b  = in_ext - 14'd72;

// // // reg [13:0] sub_result;
// // // always @(*) begin
// // //     case (color_id)
// // //         2'b00: sub_result = sub_r;
// // //         2'b01: sub_result = sub_gr;
// // //         2'b10: sub_result = sub_gb;
// // //         2'b11: sub_result = sub_b;
// // //     endcase
// // // end

// // // wire [12:0] i_blc = sub_result[13] ? 13'd0 : sub_result[12:0];

// // // // ====================== LSC 座標 LUT =====================
// // // // 展開為查表，消除減法器的 Critical Path
// // // reg [2:0] x0, y0; 
// // // reg [1:0] rx, ry;

// // // always @(*) begin
// // //     case (x_cnt)
// // //         4'd0:  begin x0 = 3'd0; rx = 2'd0; end
// // //         4'd1:  begin x0 = 3'd0; rx = 2'd1; end
// // //         4'd2:  begin x0 = 3'd0; rx = 2'd2; end
// // //         4'd3:  begin x0 = 3'd1; rx = 2'd0; end
// // //         4'd4:  begin x0 = 3'd1; rx = 2'd1; end
// // //         4'd5:  begin x0 = 3'd1; rx = 2'd2; end
// // //         4'd6:  begin x0 = 3'd2; rx = 2'd0; end
// // //         4'd7:  begin x0 = 3'd2; rx = 2'd1; end
// // //         4'd8:  begin x0 = 3'd2; rx = 2'd2; end
// // //         4'd9:  begin x0 = 3'd3; rx = 2'd0; end
// // //         4'd10: begin x0 = 3'd3; rx = 2'd1; end
// // //         4'd11: begin x0 = 3'd3; rx = 2'd2; end
// // //         4'd12: begin x0 = 3'd4; rx = 2'd0; end
// // //         4'd13: begin x0 = 3'd4; rx = 2'd1; end
// // //         4'd14: begin x0 = 3'd4; rx = 2'd2; end
// // //         4'd15: begin x0 = 3'd4; rx = 2'd2; end
// // //         default: begin x0 = 3'd0; rx = 2'd0; end
// // //     endcase
// // // end

// // // always @(*) begin
// // //     case (y_cnt)
// // //         4'd0:  begin y0 = 3'd0; ry = 2'd0; end
// // //         4'd1:  begin y0 = 3'd0; ry = 2'd1; end
// // //         4'd2:  begin y0 = 3'd0; ry = 2'd2; end
// // //         4'd3:  begin y0 = 3'd1; ry = 2'd0; end
// // //         4'd4:  begin y0 = 3'd1; ry = 2'd1; end
// // //         4'd5:  begin y0 = 3'd1; ry = 2'd2; end
// // //         4'd6:  begin y0 = 3'd2; ry = 2'd0; end
// // //         4'd7:  begin y0 = 3'd2; ry = 2'd1; end
// // //         4'd8:  begin y0 = 3'd2; ry = 2'd2; end
// // //         4'd9:  begin y0 = 3'd3; ry = 2'd0; end
// // //         4'd10: begin y0 = 3'd3; ry = 2'd1; end
// // //         4'd11: begin y0 = 3'd3; ry = 2'd2; end
// // //         4'd12: begin y0 = 3'd4; ry = 2'd0; end
// // //         4'd13: begin y0 = 3'd4; ry = 2'd1; end
// // //         4'd14: begin y0 = 3'd4; ry = 2'd2; end
// // //         4'd15: begin y0 = 3'd4; ry = 2'd2; end
// // //         default: begin y0 = 3'd0; ry = 2'd0; end
// // //     endcase
// // // end

// // // reg [12:0] g00, g01, g10, g11;
// // // always @(*) begin
// // //     case (color_id)
// // //         2'b00: begin
// // //             g00 = r_matrix[y0][x0];
// // //             g01 = r_matrix[y0][x0 + 3'd1];
// // //             g10 = r_matrix[y0 + 3'd1][x0];
// // //             g11 = r_matrix[y0 + 3'd1][x0 + 3'd1];
// // //         end
// // //         2'b01: begin
// // //             g00 = gr_matrix[y0][x0];
// // //             g01 = gr_matrix[y0][x0 + 3'd1];
// // //             g10 = gr_matrix[y0 + 3'd1][x0];
// // //             g11 = gr_matrix[y0 + 3'd1][x0 + 3'd1];
// // //         end
// // //         2'b10: begin
// // //             g00 = gb_matrix[y0][x0];
// // //             g01 = gb_matrix[y0][x0 + 3'd1];
// // //             g10 = gb_matrix[y0 + 3'd1][x0];
// // //             g11 = gb_matrix[y0 + 3'd1][x0 + 3'd1];
// // //         end
// // //         2'b11: begin
// // //             g00 = b_matrix[y0][x0];
// // //             g01 = b_matrix[y0][x0 + 3'd1];
// // //             g10 = b_matrix[y0 + 3'd1][x0];
// // //             g11 = b_matrix[y0 + 3'd1][x0 + 3'd1];
// // //         end
// // //     endcase
// // // end

// // // // ====================== MUX 延遲重構 =====================
// // // // 先 MUX 出 opA 和 opB，最後才進入共用的加法器 (m_14535)
// // // reg [12:0] m_29241, m_7225;
// // // reg [12:0] opA_14535, opB_14535; 
// // // wire [13:0] m_14535 = opA_14535 + opB_14535;

// // // // 1. 補上 4'b0000 的特例，利用數學魔法自動產生 g00
// // // always @(*) begin
// // //     m_29241 = 0;
// // //     opA_14535 = 0; 
// // //     opB_14535 = 0; 
// // //     m_7225  = 0;
// // //     case ({rx, ry})
// // //         4'b0000: begin m_29241 = g00; opA_14535 = g00; opB_14535 = g00; m_7225 = g00; end 
// // //         4'b0001: begin m_29241 = g00; opA_14535 = g00; opB_14535 = g10; m_7225 = g10; end
// // //         4'b0010: begin m_29241 = g10; opA_14535 = g00; opB_14535 = g10; m_7225 = g00; end
// // //         4'b0100: begin m_29241 = g00; opA_14535 = g00; opB_14535 = g01; m_7225 = g01; end
// // //         4'b1000: begin m_29241 = g01; opA_14535 = g00; opB_14535 = g01; m_7225 = g00; end
// // //         4'b0101: begin m_29241 = g00; opA_14535 = g01; opB_14535 = g10; m_7225 = g11; end
// // //         4'b0110: begin m_29241 = g10; opA_14535 = g00; opB_14535 = g11; m_7225 = g01; end
// // //         4'b1001: begin m_29241 = g01; opA_14535 = g00; opB_14535 = g11; m_7225 = g10; end
// // //         4'b1010: begin m_29241 = g11; opA_14535 = g01; opB_14535 = g10; m_7225 = g00; end
// // //     endcase
// // // end

// // // reg [12:0] m_29241_ff, m_7225_ff;
// // // reg [13:0] m_14535_ff;
// // // reg [12:0] i_blc_ff;
// // // reg        in_valid_ff;
// // // always @(posedge clk) begin
// // //     m_29241_ff  <= m_29241; 
// // //     m_14535_ff  <= m_14535; 
// // //     m_7225_ff   <= m_7225;
// // //     i_blc_ff    <= i_blc;
// // //     in_valid_ff <= in_valid;
// // // end

// // // // ======================================================================
// // // // 3. 改良版 CSD 展開：使用「平衡加法樹 (Balanced Tree)」縮短 Critical Path
// // // // ======================================================================

// // // wire [29:0] ext_29241 = {17'b0, m_29241_ff};
// // // wire [29:0] ext_14535 = {16'b0, m_14535_ff};
// // // wire [29:0] ext_7225  = {17'b0, m_7225_ff};

// // // // 29241 = 32768 - 4096 + 512 + 64 - 8 + 1
// // // // 將 6 個項目拆成兩兩一組平行計算，降低邏輯層級深度
// // // wire [29:0] t1_29 = (ext_29241 << 15) - (ext_29241 << 12);
// // // wire [29:0] t2_29 = (ext_29241 << 9)  + (ext_29241 << 6);
// // // wire [29:0] t3_29 = ext_29241         - (ext_29241 << 3);
// // // wire [29:0] mul_29241 = (t1_29 + t2_29) + t3_29;

// // // // 14535 = 16384 - 2048 + 256 - 64 + 8 - 1
// // // wire [29:0] t1_14 = (ext_14535 << 14) - (ext_14535 << 11);
// // // wire [29:0] t2_14 = (ext_14535 << 8)  - (ext_14535 << 6);
// // // wire [29:0] t3_14 = (ext_14535 << 3)  - ext_14535;
// // // wire [29:0] mul_14535 = (t1_14 + t2_14) + t3_14;

// // // // 7225 = 8192 - 1024 + 64 - 8 + 1
// // // wire [29:0] t1_72 = (ext_7225 << 13) - (ext_7225 << 10);
// // // wire [29:0] t2_72 = (ext_7225 << 6)  - (ext_7225 << 3);
// // // wire [29:0] mul_7225 = (t1_72 + t2_72) + ext_7225;

// // // wire [29:0] sum_part1   = mul_29241 + mul_14535;
// // // wire [29:0] gxy_sum_opt = sum_part1 + mul_7225;

// // // // 4. 四捨五入照舊
// // // wire [13:0] gxy = gxy_sum_opt[29:16] + gxy_sum_opt[15];

// // // reg [13:0] gxy_ff;
// // // reg [12:0] i_blc_ff_ff;
// // // reg        in_valid_ff_ff;
// // // always @(posedge clk) begin
// // //     gxy_ff         <= gxy;
// // //     i_blc_ff_ff    <= i_blc_ff; 
// // //     in_valid_ff_ff <= in_valid_ff; 
// // // end

// // // // ======================================================================
// // // // 改良版 Multiplier: 拆分為高低位元部分積，將加法推移至下一個 Cycle
// // // // ======================================================================
// // // reg [19:0] p_sum_H_r;
// // // reg [19:0] p_sum_L_r;
// // // reg        pp_valid_r;

// // // always @(posedge clk or negedge rst_n) begin
// // //     if (~rst_n) begin
// // //         p_sum_H_r  <= 20'd0;
// // //         p_sum_L_r  <= 20'd0;
// // //         pp_valid_r <= 1'b0;
// // //     end
// // //     else begin
// // //         p_sum_H_r  <= gxy_ff[13:7] * i_blc_ff_ff;
// // //         p_sum_L_r  <= gxy_ff[6:0]  * i_blc_ff_ff;
// // //         pp_valid_r <= in_valid_ff_ff;
// // //     end
// // // end

// // // // 在下一個 Cycle 合併部分積 (Shift and Add)
// // // wire [26:0] p_sum_w_full = {p_sum_H_r, 7'd0} + p_sum_L_r;

// // // // 維持原本的四捨五入邏輯
// // // wire [16:0] p_sum_round = p_sum_w_full[25:10] + p_sum_w_full[9];
// // // wire p_is_over = |p_sum_round[16:12];
// // // wire [11:0] pp_xy = p_is_over ? 12'd4095 : p_sum_round[11:0];

// // // // ====================== DPC =====================

// // // reg [11:0] lb0 [0:15]; 
// // // reg [11:0] lb1 [0:15];
// // // reg [11:0] lb2 [0:15];
// // // reg [11:0] lb3 [0:15];
// // // reg [11:0] lb4 [0:4]; 

// // // always @(posedge clk) begin
// // //     if (pp_valid_r || cs == DPC || cs == DEM) begin
// // //         for (i = 15; i > 0; i = i - 1) begin
// // //             lb3[i] <= lb3[i - 1];
// // //             lb2[i] <= lb2[i - 1];
// // //             lb1[i] <= lb1[i - 1]; 
// // //             lb0[i] <= lb0[i - 1];
// // //         end
// // //         lb3[0] <= lb2[15]; 
// // //         lb2[0] <= lb1[15];
// // //         lb1[0] <= lb0[15];
// // //         lb0[0] <= (pp_valid_r) ? pp_xy : 12'd0;
        
// // //         for (i = 4; i > 0; i = i - 1) 
// // //             lb4[i] <= lb4[i - 1];
// // //         lb4[0] <= lb3[15];
// // //     end
// // //     else begin
// // //         for (i = 0; i < 16; i = i + 1) begin
// // //             lb0[i] <= 0;
// // //             lb1[i] <= 0; 
// // //             lb2[i] <= 0; 
// // //             lb3[i] <= 0;
// // //         end
// // //         for (i = 0; i < 5; i = i + 1) 
// // //             lb4[i] <= 0;
// // //     end
// // // end

// // // reg [11:0] px_mat [0:4][0:4];

// // // always @(*) begin
// // //     for (i = 0; i < 5; i = i + 1) begin
// // //         px_mat[4][i] = lb0[4 - i];
// // //         px_mat[3][i] = lb1[4 - i];
// // //         px_mat[2][i] = lb2[4 - i];
// // //         px_mat[1][i] = lb3[4 - i];
// // //         px_mat[0][i] = lb4[4 - i];
// // //     end
// // // end

// // // // ====================== DPC  =====================

// // // always @(posedge clk) begin
// // //     if (cs == DPC || cs == DEM) begin
// // //         if (dpc_cnt_x == 15) begin
// // //             dpc_cnt_x <= 0;
// // //             if (dpc_cnt_y == 15) 
// // //                 dpc_cnt_y <= 0;
// // //             else 
// // //                 dpc_cnt_y <= dpc_cnt_y + 1;
// // //         end
// // //         else 
// // //             dpc_cnt_x <= dpc_cnt_x + 1;
// // //     end
// // //     else begin
// // //         dpc_cnt_x <= 0; 
// // //         dpc_cnt_y <= 0;
// // //     end
// // // end

// // // reg [2:0] px [0:4];
// // // reg [2:0] py [0:4];

// // // always @(*) begin
// // //     px[0] = (dpc_cnt_x == 4'd0)  ? 3'd4 : (dpc_cnt_x == 4'd1)  ? 3'd2 : 3'd0;
// // //     px[1] = (dpc_cnt_x == 4'd0)  ? 3'd3 : 3'd1;
// // //     px[2] = 3'd2; 
// // //     px[3] = (dpc_cnt_x == 4'd15) ? 3'd1 : 3'd3; 
// // //     px[4] = (dpc_cnt_x == 4'd15) ? 3'd0 : (dpc_cnt_x == 4'd14) ? 3'd2 : 3'd4;

// // //     py[0] = (dpc_cnt_y == 4'd0)  ? 3'd4 : (dpc_cnt_y == 4'd1)  ? 3'd2 : 3'd0;
// // //     py[1] = (dpc_cnt_y == 4'd0)  ? 3'd3 : 3'd1;
// // //     py[2] = 3'd2; 
// // //     py[3] = (dpc_cnt_y == 4'd15) ? 3'd1 : 3'd3; 
// // //     py[4] = (dpc_cnt_y == 4'd15) ? 3'd0 : (dpc_cnt_y == 4'd14) ? 3'd2 : 3'd4;
// // // end

// // // reg [11:0] p_row_0 [0:4]; 
// // // reg [11:0] p_row_1 [0:4];
// // // reg [11:0] p_row_2 [0:4];
// // // reg [11:0] p_row_3 [0:4]; 
// // // reg [11:0] p_row_4 [0:4];
// // // always @(*) begin
// // //     for(i = 0; i < 5; i = i + 1) begin
// // //         p_row_0[i] = px_mat[py[0]][i];
// // //         p_row_1[i] = px_mat[py[1]][i];
// // //         p_row_2[i] = px_mat[py[2]][i]; 
// // //         p_row_3[i] = px_mat[py[3]][i];
// // //         p_row_4[i] = px_mat[py[4]][i];
// // //     end
// // // end

// // // reg [11:0] H  [0:3];
// // // reg [11:0] V  [0:3];
// // // reg [11:0] D1 [0:3];
// // // reg [11:0] D2 [0:3];
// // // always @(*) begin
// // //     H[0]  = p_row_2[px[0]]; 
// // //     H[1]  = p_row_2[px[1]]; 
// // //     H[2]  = p_row_2[px[3]];
// // //     H[3]  = p_row_2[px[4]];

// // //     V[0]  = p_row_0[px[2]]; 
// // //     V[1]  = p_row_1[px[2]]; 
// // //     V[2]  = p_row_3[px[2]]; 
// // //     V[3]  = p_row_4[px[2]];
    
// // //     D1[0] = p_row_0[px[0]]; 
// // //     D1[1] = p_row_1[px[1]]; 
// // //     D1[2] = p_row_3[px[3]]; 
// // //     D1[3] = p_row_4[px[4]];

// // //     D2[0] = p_row_0[px[4]]; 
// // //     D2[1] = p_row_1[px[3]];
// // //     D2[2] = p_row_3[px[1]]; 
// // //     D2[3] = p_row_4[px[0]];
// // // end

// // // reg [11:0] H_ff[0:3], V_ff[0:3], D1_ff[0:3], D2_ff[0:3];
// // // reg [11:0] P_ff;

// // // always @(posedge clk) begin
// // //     for(i = 0; i < 4; i = i + 1) begin
// // //         H_ff[i] <= H[i];
// // //         V_ff[i] <= V[i]; 
// // //         D1_ff[i] <= D1[i]; 
// // //         D2_ff[i] <= D2[i];
// // //     end
// // //     P_ff <= p_row_2[px[2]];
// // // end

// // // wire [11:0] med_H, med_V, med_D1, med_D2;

// // // median_pipe calc_med_H (
// // //     .clk(clk), .rst_n(rst_n),
// // //     .A(H_ff[0]), .B(H_ff[1]), .C(H_ff[2]), .D(H_ff[3]),
// // //     .median(med_H)
// // // );
// // // median_pipe calc_med_V (
// // //     .clk(clk), .rst_n(rst_n),
// // //     .A(V_ff[0]), .B(V_ff[1]), .C(V_ff[2]), .D(V_ff[3]),
// // //     .median(med_V)
// // // );
// // // median_pipe calc_med_D1 (
// // //     .clk(clk), .rst_n(rst_n),
// // //     .A(D1_ff[0]), .B(D1_ff[1]), .C(D1_ff[2]), .D(D1_ff[3]),
// // //     .median(med_D1)
// // // );
// // // median_pipe calc_med_D2 (
// // //     .clk(clk), .rst_n(rst_n),
// // //     .A(D2_ff[0]), .B(D2_ff[1]), .C(D2_ff[2]), .D(D2_ff[3]),
// // //     .median(med_D2)
// // // );

// // // reg [11:0] H_ff_d[0:3], V_ff_d[0:3], D1_ff_d[0:3], D2_ff_d[0:3];
// // // reg [11:0] P_ff_d;

// // // reg [11:0] H_ff_ff[0:3], V_ff_ff[0:3], D1_ff_ff[0:3], D2_ff_ff[0:3];
// // // reg [11:0] med_H_ff, med_V_ff, med_D1_ff, med_D2_ff;
// // // reg [11:0] P_ff_ff;


// // // always @(posedge clk) begin
// // //     for (i = 0; i < 4; i = i + 1) begin
// // //         H_ff_d[i]  <= H_ff[i];
// // //         V_ff_d[i]  <= V_ff[i];
// // //         D1_ff_d[i] <= D1_ff[i];
// // //         D2_ff_d[i] <= D2_ff[i];
// // //     end
// // //     P_ff_d         <= P_ff;
// // // end

// // // always @(posedge clk) begin
// // //     for(i = 0; i < 4; i = i + 1) begin
// // //         H_ff_ff[i]  <= H_ff_d[i];
// // //         V_ff_ff[i]  <= V_ff_d[i]; 
// // //         D1_ff_ff[i] <= D1_ff_d[i]; 
// // //         D2_ff_ff[i] <= D2_ff_d[i];
// // //     end
// // //     med_H_ff  <= med_H;
// // //     med_V_ff  <= med_V; 
// // //     med_D1_ff <= med_D1; 
// // //     med_D2_ff <= med_D2;
// // //     P_ff_ff <= P_ff_d;
// // // end

// // // wire [11:0] err_H0, err_H1, err_H2, err_H3;
// // // wire [11:0] err_V0, err_V1, err_V2, err_V3;
// // // wire [11:0] err_D1_0, err_D1_1, err_D1_2, err_D1_3;
// // // wire [11:0] err_D2_0, err_D2_1, err_D2_2, err_D2_3;

// // // sad sad_h0 (.A(H_ff_ff[0]), .B(med_H_ff), .abs(err_H0)); 
// // // sad sad_h1 (.A(H_ff_ff[1]), .B(med_H_ff), .abs(err_H1));
// // // sad sad_h2 (.A(H_ff_ff[2]), .B(med_H_ff), .abs(err_H2)); 
// // // sad sad_h3 (.A(H_ff_ff[3]), .B(med_H_ff), .abs(err_H3));
// // // wire [13:0] SAD_H = err_H0 + err_H1 + err_H2 + err_H3;

// // // sad sad_v0 (.A(V_ff_ff[0]), .B(med_V_ff), .abs(err_V0));
// // // sad sad_v1 (.A(V_ff_ff[1]), .B(med_V_ff), .abs(err_V1));
// // // sad sad_v2 (.A(V_ff_ff[2]), .B(med_V_ff), .abs(err_V2)); 
// // // sad sad_v3 (.A(V_ff_ff[3]), .B(med_V_ff), .abs(err_V3));
// // // wire [13:0] SAD_V = err_V0 + err_V1 + err_V2 + err_V3;

// // // sad sad_d1_0 (.A(D1_ff_ff[0]), .B(med_D1_ff), .abs(err_D1_0));
// // // sad sad_d1_1 (.A(D1_ff_ff[1]), .B(med_D1_ff), .abs(err_D1_1));
// // // sad sad_d1_2 (.A(D1_ff_ff[2]), .B(med_D1_ff), .abs(err_D1_2)); 
// // // sad sad_d1_3 (.A(D1_ff_ff[3]), .B(med_D1_ff), .abs(err_D1_3));
// // // wire [13:0] SAD_D1 = err_D1_0 + err_D1_1 + err_D1_2 + err_D1_3;

// // // sad sad_d2_0 (.A(D2_ff_ff[0]), .B(med_D2_ff), .abs(err_D2_0));
// // // sad sad_d2_1 (.A(D2_ff_ff[1]), .B(med_D2_ff), .abs(err_D2_1));
// // // sad sad_d2_2 (.A(D2_ff_ff[2]), .B(med_D2_ff), .abs(err_D2_2)); 
// // // sad sad_d2_3 (.A(D2_ff_ff[3]), .B(med_D2_ff), .abs(err_D2_3));
// // // wire [13:0] SAD_D2 = err_D2_0 + err_D2_1 + err_D2_2 + err_D2_3;

// // // // // ====================== DPC =====================

// // // reg  [3:0] dem_cnt_x, dem_cnt_y;
// // // always @(posedge clk or negedge rst_n) begin
// // //     if (~rst_n) begin
// // //         dem_cnt <= 0;
// // //         dem_cnt_x <= 0; 
// // //         dem_cnt_y <= 0;
// // //     end
// // //     else if (cs == DEM) begin
// // //         dem_cnt <= dem_cnt + 1;
// // //         if (dem_cnt_x == 15) begin
// // //             dem_cnt_x <= 0;
// // //             dem_cnt_y <= dem_cnt_y + 1;
// // //         end
// // //         else 
// // //             dem_cnt_x <= dem_cnt_x + 1;
// // //     end
// // //     else 
// // //         dem_cnt <= 0;
// // // end

// // // reg [13:0] SAD_H_ff, SAD_V_ff, SAD_D1_ff, SAD_D2_ff;
// // // reg [11:0] med_H_ff_ff, med_V_ff_ff, med_D1_ff_ff, med_D2_ff_ff;
// // // reg [11:0] P_ff_ff_ff;


// // // always @(posedge clk) begin
// // //     SAD_H_ff  <= SAD_H;
// // //     SAD_V_ff  <= SAD_V; 
// // //     SAD_D1_ff <= SAD_D1; 
// // //     SAD_D2_ff <= SAD_D2;
// // //     med_H_ff_ff  <= med_H_ff;  
// // //     med_V_ff_ff  <= med_V_ff;
// // //     med_D1_ff_ff <= med_D1_ff; 
// // //     med_D2_ff_ff <= med_D2_ff;
// // //     P_ff_ff_ff   <= P_ff_ff;
// // // end

// // // wire cmp_HV = (SAD_H_ff <= SAD_V_ff);
// // // wire [13:0] min_SAD_HV = cmp_HV ? SAD_H_ff : SAD_V_ff;
// // // wire [11:0] target_HV  = cmp_HV ? med_H_ff_ff : med_V_ff_ff;
// // // wire cmp_D1D2 = (SAD_D1_ff <= SAD_D2_ff);
// // // wire [13:0] min_SAD_D1D2 = cmp_D1D2 ? SAD_D1_ff : SAD_D2_ff;
// // // wire [11:0] target_D1D2  = cmp_D1D2 ? med_D1_ff_ff : med_D2_ff_ff;

// // // wire cmp_final = (min_SAD_HV <= min_SAD_D1D2);
// // // wire [11:0] Target_w = cmp_final ? target_HV : target_D1D2;

// // // reg [11:0] Target_r;
// // // reg [11:0] P_replace_r;
// // // always @(posedge clk or negedge rst_n) begin
// // //     if (~rst_n) begin
// // //         Target_r    <= 12'd0;
// // //         P_replace_r <= 12'd0;
// // //     end
// // //     else begin
// // //         Target_r    <= Target_w;
// // //         P_replace_r <= P_ff_ff_ff;
// // //     end
// // // end

// // // wire [12:0] diff_PT = {1'b0, P_replace_r} - {1'b0, Target_r};
// // // wire [11:0] abs_PT  = diff_PT[12] ? (~diff_PT[11:0] + 12'd1) : diff_PT[11:0];

// // // wire replace_cond = (abs_PT > 12'd320);

// // // wire [11:0] dpc_out = replace_cond ? Target_r : P_replace_r;

// // // reg [11:0] dpc_fifo [0:226];

// // // always @(posedge clk) begin
// // //     for (i = 226; i > 0; i = i - 1) 
// // //         dpc_fifo[i] <= dpc_fifo[i - 1];
// // //     dpc_fifo[0] <= dpc_out;
// // // end

// // // // ============================ dem ===================================

// // // wire [1:0] dem_color_id = {dem_cnt_y[0], dem_cnt_x[0]};

// // // wire [11:0] raw_C  = dpc_fifo[209];
// // // wire [11:0] raw_E  = dpc_fifo[208];
// // // wire [11:0] raw_W  = dpc_fifo[210];
// // // wire [11:0] raw_S  = dpc_fifo[193];
// // // wire [11:0] raw_SE = dpc_fifo[192];
// // // wire [11:0] raw_SW = dpc_fifo[194];
// // // wire [11:0] raw_N  = dpc_fifo[225];
// // // wire [11:0] raw_NE = dpc_fifo[224];
// // // wire [11:0] raw_NW = dpc_fifo[226];

// // // wire is_top    = (dem_cnt_y == 0);
// // // wire is_bottom = (dem_cnt_y == 15);
// // // wire is_left   = (dem_cnt_x == 0);
// // // wire is_right  = (dem_cnt_x == 15);

// // // wire [11:0] C = raw_C;
// // // wire [11:0] W = is_left   ? raw_E : raw_W;
// // // wire [11:0] E = is_right  ? raw_W : raw_E;
// // // wire [11:0] N = is_top    ? raw_S : raw_N;
// // // wire [11:0] S = is_bottom ? raw_N : raw_S;

// // // wire [11:0] NW = (is_top & is_left)  ? raw_SE :
// // //                  (is_top)            ? raw_SW :
// // //                  (is_left)           ? raw_NE : raw_NW;

// // // wire [11:0] NE = (is_top & is_right) ? raw_SW :
// // //                  (is_top)            ? raw_SE :
// // //                  (is_right)          ? raw_NW : raw_NE;

// // // wire [11:0] SW = (is_bottom & is_left) ? raw_NE :
// // //                  (is_bottom)           ? raw_NW :
// // //                  (is_left)             ? raw_SE : raw_SW;

// // // wire [11:0] SE = (is_bottom & is_right) ? raw_NW :
// // //                  (is_bottom)            ? raw_NE :
// // //                  (is_right)             ? raw_SW : raw_SE;


// // // wire [12:0] total_ns = N + S; 
// // // wire [12:0] total_we = W + E;
// // // wire [13:0] total_nswe  = total_ns + total_we; 
// // // wire [13:0] total_other = (NW + NE) + (SW + SE);
// // // wire [11:0] avg_nswe   = total_nswe[13:2]; 
// // // wire [11:0] avg_pother = total_other[13:2];
// // // wire [11:0] avg_ns     = total_ns[12:1];     
// // // wire [11:0] avg_we     = total_we[12:1];
// // // reg [11:0] r_interp, g_interp, b_interp;

// // // always @(*) begin
// // //     case (dem_color_id)
// // //         2'b00: begin r_interp = C;          g_interp = avg_nswe; b_interp = avg_pother; end 
// // //         2'b01: begin r_interp = avg_we;     g_interp = C;        b_interp = avg_ns;     end 
// // //         2'b10: begin r_interp = avg_ns;     g_interp = C;        b_interp = avg_we;     end 
// // //         2'b11: begin r_interp = avg_pother; g_interp = avg_nswe; b_interp = C;          end 
// // //     endcase
// // // end

// // // reg [11:0] r_dem_ff, g_dem_ff, b_dem_ff;
// // // reg        dem_valid_ff;

// // // always @(posedge clk) begin
// // //     r_dem_ff     <= r_interp;
// // //     g_dem_ff     <= g_interp;
// // //     b_dem_ff     <= b_interp;
// // //     dem_valid_ff <= (cs == DEM);
// // // end

// // // // ========================== CCM =====================================

// // // // 擴充至 15 bits signed 以防 g_s + b_s 溢位
// // // wire signed [14:0] r_s = $signed({3'b0, r_dem_ff});
// // // wire signed [14:0] g_s = $signed({3'b0, g_dem_ff});
// // // wire signed [14:0] b_s = $signed({3'b0, b_dem_ff});

// // // reg signed [26:0] r_1150_r, g_1150_r, b_1150_r;
// // // reg signed [26:0] rgb_50_r;
// // // reg               ccm_valid_r;

// // // wire signed [26:0] ext_r_s = r_s;
// // // wire signed [26:0] ext_g_s = g_s;
// // // wire signed [26:0] ext_b_s = b_s;

// // // wire signed [26:0] rgb_sum = ext_r_s + ext_g_s + ext_b_s;

// // // always @(posedge clk or negedge rst_n) begin
// // //     if (~rst_n) begin
// // //         r_1150_r    <= 27'sd0;
// // //         g_1150_r    <= 27'sd0;
// // //         b_1150_r    <= 27'sd0;
// // //         rgb_50_r    <= 27'sd0;
// // //         ccm_valid_r <= 1'b0;
// // //     end
// // //     else begin
// // //         // 1150 = 1024 + 128 - 2
// // //         r_1150_r <= (ext_r_s <<< 10) + (ext_r_s <<< 7) - (ext_r_s <<< 1);
// // //         g_1150_r <= (ext_g_s <<< 10) + (ext_g_s <<< 7) - (ext_g_s <<< 1);
// // //         b_1150_r <= (ext_b_s <<< 10) + (ext_b_s <<< 7) - (ext_b_s <<< 1);

// // //         // 50 = 32 + 16 + 2
// // //         rgb_50_r <= (rgb_sum <<< 5) + (rgb_sum <<< 4) + (rgb_sum <<< 1);

// // //         ccm_valid_r <= dem_valid_ff;
// // //     end
// // // end

// // // wire signed [26:0] r_raw = r_1150_r - rgb_50_r + 27'sd512;
// // // wire signed [26:0] g_raw = g_1150_r - rgb_50_r + 27'sd512;
// // // wire signed [26:0] b_raw = b_1150_r - rgb_50_r + 27'sd512;

// // // wire signed [16:0] r_shift = r_raw[26:10];
// // // wire signed [16:0] g_shift = g_raw[26:10];
// // // wire signed [16:0] b_shift = b_raw[26:10];

// // // wire r_is_neg = r_shift[16];
// // // wire g_is_neg = g_shift[16];
// // // wire b_is_neg = b_shift[16];

// // // wire r_is_over = (|r_shift[15:12]) & ~r_is_neg;
// // // wire g_is_over = (|g_shift[15:12]) & ~g_is_neg;
// // // wire b_is_over = (|b_shift[15:12]) & ~b_is_neg;

// // // wire [12:0] r_ccm = r_is_neg ? 13'd0 : (r_is_over ? 13'd4095 : r_shift[12:0]);
// // // wire [12:0] g_ccm = g_is_neg ? 13'd0 : (g_is_over ? 13'd4095 : g_shift[12:0]);
// // // wire [12:0] b_ccm = b_is_neg ? 13'd0 : (b_is_over ? 13'd4095 : b_shift[12:0]);
// // // always @(posedge clk or negedge rst_n) begin
// // //     if (~rst_n) begin
// // //         out_valid <= 0;
// // //         r_out <= 0; 
// // //         g_out <= 0; 
// // //         b_out <= 0;
// // //     end
// // //     else if (ccm_valid_r) begin 
// // //         out_valid <= 1;
// // //         r_out     <= r_ccm; 
// // //         g_out     <= g_ccm;
// // //         b_out     <= b_ccm;
// // //     end
// // //     else begin
// // //         out_valid <= 0;
// // //         r_out <= 0; 
// // //         g_out <= 0; 
// // //         b_out <= 0;
// // //     end
// // // end

// // // endmodule

// // // module median_pipe (
// // //     input         clk,
// // //     input         rst_n,
// // //     input  [11:0] A, B, C, D,
// // //     output [11:0] median
// // // );
// // //     reg [11:0] max1_r, min1_r;
// // //     reg [11:0] max2_r, min2_r;

// // //     always @(posedge clk or negedge rst_n) begin
// // //         if (~rst_n) begin
// // //             max1_r <= 12'd0;
// // //             min1_r <= 12'd0;
// // //             max2_r <= 12'd0;
// // //             min2_r <= 12'd0;
// // //         end
// // //         else begin
// // //             if (A > B) begin
// // //                 max1_r <= A;
// // //                 min1_r <= B;
// // //             end
// // //             else begin
// // //                 max1_r <= B;
// // //                 min1_r <= A;
// // //             end

// // //             if (C > D) begin
// // //                 max2_r <= C;
// // //                 min2_r <= D;
// // //             end
// // //             else begin
// // //                 max2_r <= D;
// // //                 min2_r <= C;
// // //             end
// // //         end
// // //     end

// // //     wire [11:0] mid_low  = (min1_r > min2_r) ? min1_r : min2_r;
// // //     wire [11:0] mid_high = (max1_r < max2_r) ? max1_r : max2_r;
// // //     wire [12:0] safe_sum = {1'b0, mid_low} + {1'b0, mid_high};

// // //     assign median = safe_sum[12:1];
// // // endmodule

// // // module sad (
// // //     input  [11:0] A, B,
// // //     output [11:0] abs
// // // );
// // //     wire [12:0] diff = {1'b0, A} - {1'b0, B};
// // //     wire [11:0] diff_abs = diff[12] ? (~diff[11:0] + 12'd1) : diff[11:0];

// // //     assign abs = diff_abs;
// // // endmodule





















// // module ISP (
// //     input         clk,
// //     input         rst_n,
// //     input         in_valid,
// //     input  [12:0] in,
// //     input         param_valid,
// //     input  [12:0] param_gain,

// //     output reg        out_valid,
// //     output reg [12:0] r_out,
// //     output reg [12:0] g_out,
// //     output reg [12:0] b_out
// // );

// // //==============================
// // //   Design
// // //==============================
// // localparam IDLE  = 2'd0;
// // localparam INPUT = 2'd1;
// // localparam DPC   = 2'd2;
// // localparam DEM   = 2'd3;

// // integer i, j;

// // reg  [3:0] x_cnt, y_cnt; 
// // reg  [3:0] dpc_cnt_x, dpc_cnt_y;
// // reg  [7:0] dem_cnt;

// // reg  [1:0] cs, ns;

// // always @(posedge clk or negedge rst_n) begin
// //     if (~rst_n) cs <= IDLE;
// //     else        cs <= ns;
// // end

// // always @(*) begin
// //     ns = cs; 
// //     case (cs)
// //         IDLE:  ns = (in_valid) ? INPUT : IDLE;
// //         INPUT: ns = (x_cnt == 4 && y_cnt == 2) ? DPC : INPUT;
// //         DPC:   ns = (dpc_cnt_x == 8 && dpc_cnt_y == 13) ? DEM : DPC;
// //         DEM:   ns = (dem_cnt == 255) ? IDLE : DEM;
// //     endcase
// // end

// // reg [2:0] param_x_cnt, param_y_cnt; 
// // reg [1:0] next_gain;

// // always @(posedge clk or negedge rst_n) begin
// //     if (~rst_n) begin
// //         param_x_cnt <= 0; 
// //         param_y_cnt <= 0; 
// //         next_gain <= 0;
// //     end
// //     else if (param_valid) begin
// //         if (param_x_cnt == 5 && param_y_cnt == 5) begin
// //             param_x_cnt <= 0; 
// //             param_y_cnt <= 0; 
// //             next_gain <= next_gain + 1;
// //         end
// //         else if (param_x_cnt == 5) begin 
// //             param_x_cnt <= 3'd0; 
// //             param_y_cnt <= param_y_cnt + 3'd1;
// //         end
// //         else
// //             param_x_cnt <= param_x_cnt + 3'd1;
// //     end
// // end

// // reg  [12:0] r_matrix  [0:5][0:5];
// // reg  [12:0] gr_matrix [0:5][0:5];
// // reg  [12:0] gb_matrix [0:5][0:5];
// // reg  [12:0] b_matrix  [0:5][0:5];

// // always @(posedge clk or negedge rst_n) begin
// //     if (~rst_n) begin
// //         for (i = 0; i < 6; i = i + 1) 
// //         for (j = 0; j < 6; j = j + 1) begin
// //             r_matrix[i][j]  <= 0; 
// //             gr_matrix[i][j] <= 0;
// //             gb_matrix[i][j] <= 0; 
// //             b_matrix[i][j]  <= 0;
// //         end
// //     end
// //     else if (param_valid) begin
// //         case (next_gain)
// //             0: r_matrix[param_y_cnt][param_x_cnt]  <= param_gain;
// //             1: gr_matrix[param_y_cnt][param_x_cnt] <= param_gain;
// //             2: gb_matrix[param_y_cnt][param_x_cnt] <= param_gain;
// //             3: b_matrix[param_y_cnt][param_x_cnt]  <= param_gain;
// //         endcase
// //     end
// // end

// // // ====================== BLC =====================
// // always @(posedge clk or negedge rst_n) begin
// //     if (~rst_n) begin
// //         x_cnt <= 0; 
// //         y_cnt <= 0;
// //     end
// //     else if (in_valid) begin
// //         if (x_cnt == 15) begin 
// //             x_cnt <= 0; 
// //             y_cnt <= y_cnt + 1;
// //         end
// //         else 
// //             x_cnt <= x_cnt + 1;
// //     end
// // end

// // wire [1:0] color_id = {y_cnt[0], x_cnt[0]};
// // reg  [6:0] black_level;

// // always @(*) begin
// //     case (color_id)
// //         2'b00: black_level = 64; 
// //         2'b01: black_level = 48; 
// //         2'b10: black_level = 52; 
// //         2'b11: black_level = 72; 
// //     endcase
// // end

// // wire [13:0] sub_result = {1'b0, in} - {7'b0, black_level};
// // wire [12:0] i_blc = sub_result[13] ? 0 : sub_result[12:0];

// // // ====================== LSC =====================
// // reg [2:0] x0, y0; 
// // reg [1:0] rx, ry;

// // always @(*) begin
// //     case (x_cnt)
// //         0, 1, 2:        begin x0 = 0; rx = x_cnt[1:0]; end
// //         3, 4, 5:        begin x0 = 1; rx = x_cnt - 3; end
// //         6, 7, 8:        begin x0 = 2; rx = x_cnt - 6; end
// //         9, 10, 11:      begin x0 = 3; rx = x_cnt - 9; end
// //         12, 13, 14, 15: begin x0 = 4; rx = (x_cnt >= 14) ? 2 : x_cnt - 12; end
// //         default:        begin x0 = 0; rx = 0; end
// //     endcase
// // end

// // always @(*) begin
// //     case (y_cnt)
// //         0, 1, 2:        begin y0 = 0; ry = y_cnt[1:0]; end
// //         3, 4, 5:        begin y0 = 1; ry = y_cnt - 3; end
// //         6, 7, 8:        begin y0 = 2; ry = y_cnt - 6; end
// //         9, 10, 11:      begin y0 = 3; ry = y_cnt - 9; end
// //         12, 13, 14, 15: begin y0 = 4; ry = (y_cnt >= 14) ? 2 : y_cnt - 12; end
// //         default:        begin y0 = 0; ry = 0; end
// //     endcase
// // end

// // reg [12:0] c_row_0 [0:5];
// // reg [12:0] c_row_1 [0:5];

// // always @(*) begin
// //     case (color_id)
// //         2'b00: begin
// //             for(i = 0; i < 6; i = i + 1) begin 
// //                 c_row_0[i] = r_matrix[y0][i];  
// //                 c_row_1[i] = r_matrix[y0 + 1][i];  
// //             end
// //         end
// //         2'b01: begin
// //             for(i = 0; i < 6; i = i + 1) begin 
// //                 c_row_0[i] = gr_matrix[y0][i]; 
// //                 c_row_1[i] = gr_matrix[y0 + 1][i]; 
// //             end
// //         end
// //         2'b10: begin
// //             for(i = 0; i < 6; i = i + 1) begin 
// //                 c_row_0[i] = gb_matrix[y0][i]; 
// //                 c_row_1[i] = gb_matrix[y0 + 1][i]; 
// //             end
// //         end
// //         2'b11: begin
// //             for(i = 0; i < 6; i = i + 1) begin 
// //                 c_row_0[i] = b_matrix[y0][i];  
// //                 c_row_1[i] = b_matrix[y0 + 1][i];  
// //             end
// //         end
// //     endcase
// // end

// // reg [12:0] g00, g01, g10, g11;
// // reg [13:0] g0110, g0011, g0010, g0001;

// // always @(*) begin
// //     g00 = c_row_0[x0];
// //     g01 = c_row_0[x0 + 1];
// //     g10 = c_row_1[x0];
// //     g11 = c_row_1[x0 + 1];

// //     g0110 = g01 + g10;
// //     g0011 = g00 + g11;
// //     g0010 = g00 + g10; 
// //     g0001 = g00 + g01; 
// // end

// // reg [12:0] m_29241, m_7225;
// // reg [13:0] m_14535; 

// // always @(*) begin
// //     m_29241 = 0; 
// //     m_14535 = 0; 
// //     m_7225  = 0;
// //     case ({rx, ry})
// //         4'b0001: begin m_29241 = g00; m_14535 = g0010; m_7225 = g10; end
// //         4'b0010: begin m_29241 = g10; m_14535 = g0010; m_7225 = g00; end
// //         4'b0100: begin m_29241 = g00; m_14535 = g0001; m_7225 = g01; end
// //         4'b1000: begin m_29241 = g01; m_14535 = g0001; m_7225 = g00; end
// //         4'b0101: begin m_29241 = g00; m_14535 = g0110; m_7225 = g11; end
// //         4'b0110: begin m_29241 = g10; m_14535 = g0011; m_7225 = g01; end
// //         4'b1001: begin m_29241 = g01; m_14535 = g0011; m_7225 = g10; end
// //         4'b1010: begin m_29241 = g11; m_14535 = g0110; m_7225 = g00; end
// //     endcase
// // end

// // reg [12:0] m_29241_ff, m_7225_ff, g00_ff;
// // reg [13:0] m_14535_ff;
// // reg        rx_ry_zero_ff;
// // reg [12:0] i_blc_ff;
// // reg        in_valid_ff;

// // always @(posedge clk) begin
// //     m_29241_ff <= m_29241; 
// //     m_14535_ff <= m_14535; 
// //     m_7225_ff  <= m_7225;
// //     g00_ff     <= g00;
// //     rx_ry_zero_ff <= ({rx, ry} == 0);
// //     i_blc_ff   <= i_blc;
// //     in_valid_ff<= in_valid;
// // end

// // wire [29:0] gxy_sum_opt = (m_29241_ff * 29241) + 
// //                           (m_14535_ff * 14535) + 
// //                           (m_7225_ff  * 7225);

// // wire [13:0] gxy_calc = gxy_sum_opt[29:16] + gxy_sum_opt[15];
// // wire [13:0] gxy = (rx_ry_zero_ff) ? {1'b0, g00_ff} : gxy_calc;

// // reg [13:0] gxy_ff;
// // reg [12:0] i_blc_ff_ff;
// // reg        in_valid_ff_ff;

// // always @(posedge clk) begin
// //     gxy_ff         <= gxy;
// //     i_blc_ff_ff    <= i_blc_ff; 
// //     in_valid_ff_ff <= in_valid_ff; 
// // end

// // wire [25:0] p_sum = gxy_ff * i_blc_ff_ff;
// // wire [16:0] p_sum_round = p_sum[25:10] + p_sum[9];

// // wire p_is_over = |p_sum_round[16:12];
// // wire [11:0] pp_xy = p_is_over ? 4095 : p_sum_round[11:0];

// // // ====================== DPC =====================

// // reg [11:0] lb0 [0:15]; 
// // reg [11:0] lb1 [0:15];
// // reg [11:0] lb2 [0:15]; 
// // reg [11:0] lb3 [0:15];
// // reg [11:0] lb4 [0:4]; 

// // always @(posedge clk) begin
// //     if (in_valid_ff_ff || cs == DPC || cs == DEM) begin
// //         for (i = 15; i > 0; i = i - 1) begin
// //             lb3[i] <= lb3[i - 1]; 
// //             lb2[i] <= lb2[i - 1];
// //             lb1[i] <= lb1[i - 1]; 
// //             lb0[i] <= lb0[i - 1];
// //         end
// //         lb3[0] <= lb2[15]; 
// //         lb2[0] <= lb1[15];
// //         lb1[0] <= lb0[15]; 
// //         lb0[0] <= (in_valid_ff_ff) ? pp_xy : 0;
        
// //         for (i = 4; i > 0; i = i - 1) 
// //             lb4[i] <= lb4[i - 1];
            
// //         lb4[0] <= lb3[15];
// //     end
// //     else begin
// //         for (i = 0; i < 16; i = i + 1) begin
// //             lb0[i] <= 0; 
// //             lb1[i] <= 0; 
// //             lb2[i] <= 0; 
// //             lb3[i] <= 0;
// //         end
// //         for (i = 0; i < 5; i = i + 1) 
// //             lb4[i] <= 0;
// //     end
// // end

// // reg [11:0] px_mat [0:4][0:4];

// // always @(*) begin
// //     for (i = 0; i < 5; i = i + 1) begin
// //         px_mat[4][i] = lb0[4 - i];
// //         px_mat[3][i] = lb1[4 - i];
// //         px_mat[2][i] = lb2[4 - i];
// //         px_mat[1][i] = lb3[4 - i];
// //         px_mat[0][i] = lb4[4 - i];
// //     end
// // end

// // // ====================== DPC  =====================

// // always @(posedge clk) begin
// //     if (cs == DPC || cs == DEM) begin
// //         if (dpc_cnt_x == 15) begin
// //             dpc_cnt_x <= 0;
// //             if (dpc_cnt_y == 15) 
// //                 dpc_cnt_y <= 0;
// //             else 
// //                 dpc_cnt_y <= dpc_cnt_y + 1;
// //         end
// //         else 
// //             dpc_cnt_x <= dpc_cnt_x + 1;
// //     end
// //     else begin
// //         dpc_cnt_x <= 0; 
// //         dpc_cnt_y <= 0;
// //     end
// // end

// // reg [2:0] px [0:4];
// // reg [2:0] py [0:4];

// // always @(*) begin
// //     px[0] = (dpc_cnt_x == 4'd0)  ? 3'd4 : (dpc_cnt_x == 4'd1)  ? 3'd2 : 3'd0;
// //     px[1] = (dpc_cnt_x == 4'd0)  ? 3'd3 : 3'd1; 
// //     px[2] = 3'd2; 
// //     px[3] = (dpc_cnt_x == 4'd15) ? 3'd1 : 3'd3; 
// //     px[4] = (dpc_cnt_x == 4'd15) ? 3'd0 : (dpc_cnt_x == 4'd14) ? 3'd2 : 3'd4;

// //     py[0] = (dpc_cnt_y == 4'd0)  ? 3'd4 : (dpc_cnt_y == 4'd1)  ? 3'd2 : 3'd0;
// //     py[1] = (dpc_cnt_y == 4'd0)  ? 3'd3 : 3'd1; 
// //     py[2] = 3'd2; 
// //     py[3] = (dpc_cnt_y == 4'd15) ? 3'd1 : 3'd3; 
// //     py[4] = (dpc_cnt_y == 4'd15) ? 3'd0 : (dpc_cnt_y == 4'd14) ? 3'd2 : 3'd4;
// // end

// // reg [11:0] p_row_0 [0:4]; 
// // reg [11:0] p_row_1 [0:4]; 
// // reg [11:0] p_row_2 [0:4];
// // reg [11:0] p_row_3 [0:4]; 
// // reg [11:0] p_row_4 [0:4];

// // always @(*) begin
// //     for(i = 0; i < 5; i = i + 1) begin
// //         p_row_0[i] = px_mat[py[0]][i]; 
// //         p_row_1[i] = px_mat[py[1]][i];
// //         p_row_2[i] = px_mat[py[2]][i]; 
// //         p_row_3[i] = px_mat[py[3]][i];
// //         p_row_4[i] = px_mat[py[4]][i];
// //     end
// // end

// // reg [11:0] H  [0:3];
// // reg [11:0] V  [0:3];
// // reg [11:0] D1 [0:3];
// // reg [11:0] D2 [0:3];

// // always @(*) begin
// //     H[0]  = p_row_2[px[0]]; 
// //     H[1]  = p_row_2[px[1]]; 
// //     H[2]  = p_row_2[px[3]]; 
// //     H[3]  = p_row_2[px[4]];

// //     V[0]  = p_row_0[px[2]]; 
// //     V[1]  = p_row_1[px[2]]; 
// //     V[2]  = p_row_3[px[2]]; 
// //     V[3]  = p_row_4[px[2]];

// //     D1[0] = p_row_0[px[0]]; 
// //     D1[1] = p_row_1[px[1]]; 
// //     D1[2] = p_row_3[px[3]]; 
// //     D1[3] = p_row_4[px[4]];

// //     D2[0] = p_row_0[px[4]]; 
// //     D2[1] = p_row_1[px[3]]; 
// //     D2[2] = p_row_3[px[1]]; 
// //     D2[3] = p_row_4[px[0]];
// // end

// // reg [11:0] H_ff[0:3], V_ff[0:3], D1_ff[0:3], D2_ff[0:3];
// // reg [11:0] P_ff;
// // reg        dpc_valid_ff;

// // always @(posedge clk) begin
// //     for(i = 0; i < 4; i = i + 1) begin
// //         H_ff[i] <= H[i]; 
// //         V_ff[i] <= V[i]; 
// //         D1_ff[i] <= D1[i]; 
// //         D2_ff[i] <= D2[i];
// //     end
// //     P_ff <= p_row_2[px[2]];
// //     dpc_valid_ff <= (cs == DPC || cs == DEM);
// // end

// // wire [11:0] med_H, med_V, med_D1, med_D2;

// // median calc_med_H (.A(H_ff[0]), .B(H_ff[1]), .C(H_ff[2]), .D(H_ff[3]), .median(med_H));
// // median calc_med_V (.A(V_ff[0]), .B(V_ff[1]), .C(V_ff[2]), .D(V_ff[3]), .median(med_V));
// // median calc_med_D1(.A(D1_ff[0]),.B(D1_ff[1]),.C(D1_ff[2]),.D(D1_ff[3]),.median(med_D1));
// // median calc_med_D2(.A(D2_ff[0]),.B(D2_ff[1]),.C(D2_ff[2]),.D(D2_ff[3]),.median(med_D2));

// // reg [11:0] H_ff_ff[0:3], V_ff_ff[0:3], D1_ff_ff[0:3], D2_ff_ff[0:3];
// // reg [11:0] med_H_ff, med_V_ff, med_D1_ff, med_D2_ff;
// // reg [11:0] P_ff_ff;
// // reg        dpc_valid_ff_ff;

// // always @(posedge clk) begin
// //     for(i = 0; i < 4; i = i + 1) begin
// //         H_ff_ff[i] <= H_ff[i]; 
// //         V_ff_ff[i] <= V_ff[i]; 
// //         D1_ff_ff[i] <= D1_ff[i]; 
// //         D2_ff_ff[i] <= D2_ff[i];
// //     end
// //     med_H_ff <= med_H; 
// //     med_V_ff <= med_V; 
// //     med_D1_ff <= med_D1; 
// //     med_D2_ff <= med_D2;
// //     P_ff_ff <= P_ff;
// //     dpc_valid_ff_ff <= dpc_valid_ff;
// // end

// // wire [11:0] err_H0, err_H1, err_H2, err_H3;
// // wire [11:0] err_V0, err_V1, err_V2, err_V3;
// // wire [11:0] err_D1_0, err_D1_1, err_D1_2, err_D1_3;
// // wire [11:0] err_D2_0, err_D2_1, err_D2_2, err_D2_3;

// // sad sad_h0 (.A(H_ff_ff[0]), .B(med_H_ff), .abs(err_H0)); 
// // sad sad_h1 (.A(H_ff_ff[1]), .B(med_H_ff), .abs(err_H1));
// // sad sad_h2 (.A(H_ff_ff[2]), .B(med_H_ff), .abs(err_H2)); 
// // sad sad_h3 (.A(H_ff_ff[3]), .B(med_H_ff), .abs(err_H3));
// // wire [13:0] SAD_H = err_H0 + err_H1 + err_H2 + err_H3;

// // sad sad_v0 (.A(V_ff_ff[0]), .B(med_V_ff), .abs(err_V0)); 
// // sad sad_v1 (.A(V_ff_ff[1]), .B(med_V_ff), .abs(err_V1));
// // sad sad_v2 (.A(V_ff_ff[2]), .B(med_V_ff), .abs(err_V2)); 
// // sad sad_v3 (.A(V_ff_ff[3]), .B(med_V_ff), .abs(err_V3));
// // wire [13:0] SAD_V = err_V0 + err_V1 + err_V2 + err_V3;

// // sad sad_d1_0 (.A(D1_ff_ff[0]), .B(med_D1_ff), .abs(err_D1_0)); 
// // sad sad_d1_1 (.A(D1_ff_ff[1]), .B(med_D1_ff), .abs(err_D1_1));
// // sad sad_d1_2 (.A(D1_ff_ff[2]), .B(med_D1_ff), .abs(err_D1_2)); 
// // sad sad_d1_3 (.A(D1_ff_ff[3]), .B(med_D1_ff), .abs(err_D1_3));
// // wire [13:0] SAD_D1 = err_D1_0 + err_D1_1 + err_D1_2 + err_D1_3;

// // sad sad_d2_0 (.A(D2_ff_ff[0]), .B(med_D2_ff), .abs(err_D2_0)); 
// // sad sad_d2_1 (.A(D2_ff_ff[1]), .B(med_D2_ff), .abs(err_D2_1));
// // sad sad_d2_2 (.A(D2_ff_ff[2]), .B(med_D2_ff), .abs(err_D2_2)); 
// // sad sad_d2_3 (.A(D2_ff_ff[3]), .B(med_D2_ff), .abs(err_D2_3));
// // wire [13:0] SAD_D2 = err_D2_0 + err_D2_1 + err_D2_2 + err_D2_3;

// // // // ====================== DPC =====================

// // reg  [3:0] dem_cnt_x, dem_cnt_y;

// // always @(posedge clk or negedge rst_n) begin
// //     if (~rst_n) begin
// //         dem_cnt <= 0; 
// //         dem_cnt_x <= 0; 
// //         dem_cnt_y <= 0;
// //     end
// //     else if (cs == DEM) begin
// //         dem_cnt <= dem_cnt + 1;
// //         if (dem_cnt_x == 15) begin
// //             dem_cnt_x <= 0; 
// //             dem_cnt_y <= 
// //             dem_cnt_y + 1;
// //         end
// //         else 
// //             dem_cnt_x <= dem_cnt_x + 1;
// //     end
// //     else 
// //         dem_cnt <= 0;
// // end

// // reg [13:0] SAD_H_ff, SAD_V_ff, SAD_D1_ff, SAD_D2_ff;
// // reg [11:0] med_H_ff_ff, med_V_ff_ff, med_D1_ff_ff, med_D2_ff_ff;
// // reg [11:0] P_ff_ff_ff;
// // reg        dpc_valid_ff_ff_ff;

// // always @(posedge clk) begin
// //     SAD_H_ff  <= SAD_H;  
// //     SAD_V_ff  <= SAD_V; 
// //     SAD_D1_ff <= SAD_D1; 
// //     SAD_D2_ff <= SAD_D2;
// //     med_H_ff_ff  <= med_H_ff;  
// //     med_V_ff_ff  <= med_V_ff; 
// //     med_D1_ff_ff <= med_D1_ff; 
// //     med_D2_ff_ff <= med_D2_ff;
// //     P_ff_ff_ff   <= P_ff_ff;
// //     dpc_valid_ff_ff_ff <= dpc_valid_ff_ff;
// // end

// // wire cmp_HV = (SAD_H_ff <= SAD_V_ff);
// // wire [13:0] min_SAD_HV = cmp_HV ? SAD_H_ff : SAD_V_ff;
// // wire [11:0] target_HV  = cmp_HV ? med_H_ff_ff : med_V_ff_ff;

// // wire cmp_D1D2 = (SAD_D1_ff <= SAD_D2_ff);
// // wire [13:0] min_SAD_D1D2 = cmp_D1D2 ? SAD_D1_ff : SAD_D2_ff;
// // wire [11:0] target_D1D2  = cmp_D1D2 ? med_D1_ff_ff : med_D2_ff_ff;

// // wire cmp_final = (min_SAD_HV <= min_SAD_D1D2);
// // wire [11:0] Target = cmp_final ? target_HV : target_D1D2;

// // wire replace_cond = ({1'b0, P_ff_ff_ff} > {1'b0, Target} + 320) || 
// //                     ({1'b0, Target} > {1'b0, P_ff_ff_ff} + 320);

// // wire [11:0] dpc_out = replace_cond ? Target : P_ff_ff_ff;

// // reg [11:0] dpc_fifo [0:235];

// // always @(posedge clk) begin
// //     for (i = 235; i > 0; i = i - 1) 
// //         dpc_fifo[i] <= dpc_fifo[i - 1];

// //     dpc_fifo[0] <= dpc_out;
// // end

// // // ============================ dem ===================================

// // wire [1:0] dem_color_id = {dem_cnt_y[0], dem_cnt_x[0]};

// // wire [11:0] raw_C  = dpc_fifo[213];
// // wire [11:0] raw_E  = dpc_fifo[212];
// // wire [11:0] raw_W  = dpc_fifo[214];
// // wire [11:0] raw_S  = dpc_fifo[197];
// // wire [11:0] raw_SE = dpc_fifo[196];
// // wire [11:0] raw_SW = dpc_fifo[198];
// // wire [11:0] raw_N  = dpc_fifo[229];
// // wire [11:0] raw_NE = dpc_fifo[228];
// // wire [11:0] raw_NW = dpc_fifo[230];

// // wire is_top    = (dem_cnt_y == 0);
// // wire is_bottom = (dem_cnt_y == 15);
// // wire is_left   = (dem_cnt_x == 0);
// // wire is_right  = (dem_cnt_x == 15);

// // wire [11:0] C = raw_C;
// // wire [11:0] W = is_left   ? raw_E : raw_W;
// // wire [11:0] E = is_right  ? raw_W : raw_E;
// // wire [11:0] N = is_top    ? raw_S : raw_N;
// // wire [11:0] S = is_bottom ? raw_N : raw_S;

// // wire [11:0] NW = (is_top & is_left)  ? raw_SE :
// //                  (is_top)            ? raw_SW :
// //                  (is_left)           ? raw_NE : raw_NW;

// // wire [11:0] NE = (is_top & is_right) ? raw_SW :
// //                  (is_top)            ? raw_SE :
// //                  (is_right)          ? raw_NW : raw_NE;

// // wire [11:0] SW = (is_bottom & is_left) ? raw_NE :
// //                  (is_bottom)           ? raw_NW :
// //                  (is_left)             ? raw_SE : raw_SW;

// // wire [11:0] SE = (is_bottom & is_right) ? raw_NW :
// //                  (is_bottom)            ? raw_NE :
// //                  (is_right)             ? raw_SW : raw_SE;


// // wire [12:0] total_ns = N + S; 
// // wire [12:0] total_we = W + E; 

// // wire [13:0] total_nswe  = total_ns + total_we; 
// // wire [13:0] total_other = (NW + NE) + (SW + SE); 

// // wire [11:0] avg_nswe   = total_nswe[13:2]; 
// // wire [11:0] avg_pother = total_other[13:2];
// // wire [11:0] avg_ns     = total_ns[12:1];     
// // wire [11:0] avg_we     = total_we[12:1];     

// // reg [11:0] r_interp, g_interp, b_interp;

// // always @(*) begin
// //     case (dem_color_id)
// //         2'b00: begin r_interp = C;          g_interp = avg_nswe; b_interp = avg_pother; end 
// //         2'b01: begin r_interp = avg_we;     g_interp = C;        b_interp = avg_ns;     end 
// //         2'b10: begin r_interp = avg_ns;     g_interp = C;        b_interp = avg_we;     end 
// //         2'b11: begin r_interp = avg_pother; g_interp = avg_nswe; b_interp = C;          end 
// //     endcase
// // end

// // reg [11:0] r_dem_ff, g_dem_ff, b_dem_ff;
// // reg        dem_valid_ff;

// // always @(posedge clk) begin
// //     r_dem_ff     <= r_interp;
// //     g_dem_ff     <= g_interp;
// //     b_dem_ff     <= b_interp;
// //     dem_valid_ff <= (cs == DEM);
// // end

// // // ========================== CCM =====================================

// // wire signed [13:0] r_s = $signed({2'b0, r_dem_ff});
// // wire signed [13:0] g_s = $signed({2'b0, g_dem_ff});
// // wire signed [13:0] b_s = $signed({2'b0, b_dem_ff});

// // localparam signed [14:0] C_err = 15'sd1150; 
// // localparam signed [14:0] C_SUB  = -15'sd50;

// // wire signed [15:0] rgb_sum = r_s + g_s + b_s;
// // wire signed [26:0] shared_sub_ffult = rgb_sum * C_SUB;

// // wire signed [26:0] r_raw = (r_s * C_err) + shared_sub_ffult + 27'sd512;
// // wire signed [26:0] g_raw = (g_s * C_err) + shared_sub_ffult + 27'sd512;
// // wire signed [26:0] b_raw = (b_s * C_err) + shared_sub_ffult + 27'sd512;

// // wire signed [26:0] r_shift = r_raw >>> 10;
// // wire signed [26:0] g_shift = g_raw >>> 10;
// // wire signed [26:0] b_shift = b_raw >>> 10;

// // wire r_is_neg = r_shift[26];
// // wire g_is_neg = g_shift[26];
// // wire b_is_neg = b_shift[26];

// // wire [26:0] r_shift_u = $unsigned(r_shift);
// // wire [26:0] g_shift_u = $unsigned(g_shift);
// // wire [26:0] b_shift_u = $unsigned(b_shift);

// // wire r_is_over = (|r_shift_u[25:12]) & ~r_is_neg;
// // wire g_is_over = (|g_shift_u[25:12]) & ~g_is_neg;
// // wire b_is_over = (|b_shift_u[25:12]) & ~b_is_neg;

// // wire [12:0] r_ccm = r_is_neg ? 0 : (r_is_over ? 4095 : r_shift_u[12:0]);
// // wire [12:0] g_ccm = g_is_neg ? 0 : (g_is_over ? 4095 : g_shift_u[12:0]);
// // wire [12:0] b_ccm = b_is_neg ? 0 : (b_is_over ? 4095 : b_shift_u[12:0]);

// // always @(posedge clk or negedge rst_n) begin
// //     if (~rst_n) begin
// //         out_valid <= 0; 
// //         r_out <= 0; 
// //         g_out <= 0; 
// //         b_out <= 0;
// //     end
// //     else if (dem_valid_ff) begin 
// //         out_valid <= 1;
// //         r_out     <= r_ccm; 
// //         g_out     <= g_ccm;
// //         b_out     <= b_ccm;
// //     end
// //     else begin
// //         out_valid <= 0; 
// //         r_out <= 0; 
// //         g_out <= 0; 
// //         b_out <= 0;
// //     end
// // end

// // endmodule

// // module median (
// //     input  [11:0] A, B, C, D,
// //     output [11:0] median
// // );
// //     wire [11:0] max1, min1, max2, min2;
// //     assign {max1, min1} = (A > B) ? {A, B} : {B, A};
// //     assign {max2, min2} = (C > D) ? {C, D} : {D, C};

// //     wire [11:0] mid_low  = (min1 > min2) ? min1 : min2;
// //     wire [11:0] mid_high = (max1 < max2) ? max1 : max2;

// //     wire [12:0] safe_sum = {1'b0, mid_low} + {1'b0, mid_high};
// //     assign median = safe_sum[12:1];

// // endmodule

// // module sad (
// //     input  [11:0] A, B,
// //     output [11:0] abs
// // );
// //     wire [12:0] err = {1'b0, A} - {1'b0, B}; 
// //     wire sign = err[12]; 
// //     assign abs = (err[11:0] ^ {12{sign}}) + sign;
// // endmodule

// module ISP (
//     input         clk,
//     input         rst_n,
//     input         in_valid,
//     input  [12:0] in,
//     input         param_valid,
//     input  [12:0] param_gain,

//     output reg        out_valid,
//     output reg [12:0] r_out,
//     output reg [12:0] g_out,
//     output reg [12:0] b_out
// );

// //==============================
// //   Design
// //==============================
// localparam IDLE  = 2'd0;
// localparam INPUT = 2'd1;
// localparam DPC   = 2'd2;
// localparam DEM   = 2'd3;

// integer i, j, k;

// reg  [3:0] x_cnt, y_cnt; 
// reg  [3:0] dpc_cnt_x, dpc_cnt_y;
// reg  [7:0] dem_cnt;

// reg  [1:0] cs, ns;

// always @(posedge clk or negedge rst_n) begin
//     if (~rst_n) cs <= IDLE;
//     else        cs <= ns;
// end

// always @(*) begin
//     ns = cs; 
//     case (cs)
//         IDLE:  ns = (in_valid) ? INPUT : IDLE;
//         INPUT: ns = (x_cnt == 4 && y_cnt == 2) ? DPC : INPUT;
//         DPC:   ns = (dpc_cnt_x == 8 && dpc_cnt_y == 13) ? DEM : DPC;
//         DEM:   ns = (dem_cnt == 255) ? IDLE : DEM;
//     endcase
// end

// reg [2:0] param_x_cnt, param_y_cnt; 
// reg [1:0] next_gain;

// always @(posedge clk or negedge rst_n) begin
//     if (~rst_n) begin
//         param_x_cnt <= 0; 
//         param_y_cnt <= 0; 
//         next_gain <= 0;
//     end
//     else if (param_valid) begin
//         if (param_x_cnt == 5 && param_y_cnt == 5) begin
//             param_x_cnt <= 0; 
//             param_y_cnt <= 0; 
//             next_gain <= next_gain + 1;
//         end
//         else if (param_x_cnt == 5) begin 
//             param_x_cnt <= 3'd0; 
//             param_y_cnt <= param_y_cnt + 3'd1;
//         end
//         else
//             param_x_cnt <= param_x_cnt + 3'd1;
//     end
// end

// // 【面積優化 1】將 4 個矩陣合併為 3D 陣列，直接消滅 16 顆巨大的 MUX
// reg [12:0] param_matrix [0:3][0:5][0:5];

// always @(posedge clk or negedge rst_n) begin
//     if (~rst_n) begin
//         for (i = 0; i < 4; i = i + 1) 
//             for (j = 0; j < 6; j = j + 1) 
//                 for (k = 0; k < 6; k = k + 1)
//                     param_matrix[i][j][k] <= 0;
//     end
//     else if (param_valid) begin
//         param_matrix[next_gain][param_y_cnt][param_x_cnt] <= param_gain;
//     end
// end

// // ====================== BLC =====================
// always @(posedge clk or negedge rst_n) begin
//     if (~rst_n) begin
//         x_cnt <= 0; 
//         y_cnt <= 0;
//     end
//     else if (in_valid) begin
//         if (x_cnt == 15) begin 
//             x_cnt <= 0; 
//             y_cnt <= y_cnt + 1;
//         end
//         else 
//             x_cnt <= x_cnt + 1;
//     end
// end

// wire [1:0] color_id = {y_cnt[0], x_cnt[0]};
// reg  [6:0] black_level;

// always @(*) begin
//     case (color_id)
//         2'b00: black_level = 64; 
//         2'b01: black_level = 48; 
//         2'b10: black_level = 52; 
//         2'b11: black_level = 72; 
//     endcase
// end

// wire [13:0] sub_result = {1'b0, in} - {7'b0, black_level};
// wire [12:0] i_blc = sub_result[13] ? 0 : sub_result[12:0];

// // ====================== LSC =====================
// reg [2:0] x0, y0; 
// reg [1:0] rx, ry;

// always @(*) begin
//     case (x_cnt)
//         0, 1, 2:        begin x0 = 0; rx = x_cnt[1:0]; end
//         3, 4, 5:        begin x0 = 1; rx = x_cnt - 3; end
//         6, 7, 8:        begin x0 = 2; rx = x_cnt - 6; end
//         9, 10, 11:      begin x0 = 3; rx = x_cnt - 9; end
//         12, 13, 14, 15: begin x0 = 4; rx = (x_cnt >= 14) ? 2 : x_cnt - 12; end
//         default:        begin x0 = 0; rx = 0; end
//     endcase
// end

// always @(*) begin
//     case (y_cnt)
//         0, 1, 2:        begin y0 = 0; ry = y_cnt[1:0]; end
//         3, 4, 5:        begin y0 = 1; ry = y_cnt - 3; end
//         6, 7, 8:        begin y0 = 2; ry = y_cnt - 6; end
//         9, 10, 11:      begin y0 = 3; ry = y_cnt - 9; end
//         12, 13, 14, 15: begin y0 = 4; ry = (y_cnt >= 14) ? 2 : y_cnt - 12; end
//         default:        begin y0 = 0; ry = 0; end
//     endcase
// end

// reg [12:0] g00, g01, g10, g11;

// // 直接動態索引！乾淨俐落省面積
// always @(*) begin
//     g00 = param_matrix[color_id][y0][x0];
//     g01 = param_matrix[color_id][y0][x0 + 1];
//     g10 = param_matrix[color_id][y0 + 1][x0];
//     g11 = param_matrix[color_id][y0 + 1][x0 + 1];
// end

// wire [13:0] g0110 = g01 + g10;
// wire [13:0] g0011 = g00 + g11;
// wire [13:0] g0010 = g00 + g10; 
// wire [13:0] g0001 = g00 + g01; 

// reg [12:0] m_29241, m_7225;
// reg [13:0] m_14535;

// always @(*) begin
//     m_29241 = 0; 
//     m_14535 = 0; 
//     m_7225  = 0;
//     case ({rx, ry})
//         4'b0001: begin m_29241 = g00; m_14535 = g0010; m_7225 = g10; end
//         4'b0010: begin m_29241 = g10; m_14535 = g0010; m_7225 = g00; end
//         4'b0100: begin m_29241 = g00; m_14535 = g0001; m_7225 = g01; end
//         4'b1000: begin m_29241 = g01; m_14535 = g0001; m_7225 = g00; end
//         4'b0101: begin m_29241 = g00; m_14535 = g0110; m_7225 = g11; end
//         4'b0110: begin m_29241 = g10; m_14535 = g0011; m_7225 = g01; end
//         4'b1001: begin m_29241 = g01; m_14535 = g0011; m_7225 = g10; end
//         4'b1010: begin m_29241 = g11; m_14535 = g0110; m_7225 = g00; end
//     endcase
// end

// reg [12:0] m_29241_ff, m_7225_ff, g00_ff;
// reg [13:0] m_14535_ff;
// reg        rx_ry_zero_ff;
// reg [12:0] i_blc_ff;
// reg        in_valid_ff;

// always @(posedge clk) begin
//     m_29241_ff <= m_29241; 
//     m_14535_ff <= m_14535; 
//     m_7225_ff  <= m_7225;
//     g00_ff     <= g00;
//     rx_ry_zero_ff <= ({rx, ry} == 0);
//     i_blc_ff   <= i_blc;
//     in_valid_ff<= in_valid;
// end

// wire [29:0] gxy_sum_opt = (m_29241_ff * 29241) + 
//                           (m_14535_ff * 14535) + 
//                           (m_7225_ff  * 7225);

// wire [13:0] gxy_calc = gxy_sum_opt[29:16] + gxy_sum_opt[15];
// wire [13:0] gxy = (rx_ry_zero_ff) ? {1'b0, g00_ff} : gxy_calc;

// reg [13:0] gxy_ff;
// reg [12:0] i_blc_ff_ff;
// reg        in_valid_ff_ff;

// always @(posedge clk) begin
//     gxy_ff         <= gxy;
//     i_blc_ff_ff    <= i_blc_ff; 
//     in_valid_ff_ff <= in_valid_ff; 
// end

// // 【面積優化 + Timing優化 2】將 LSC 溢位判斷用邏輯閘取代大加法器
// wire [25:0] p_sum = gxy_ff * i_blc_ff_ff;
// wire [15:0] p_sum_trunc = p_sum[25:10];
// wire p_is_over = (|p_sum_trunc[15:12]) || ((p_sum_trunc[11:0] == 12'hFFF) && p_sum[9]);
// wire [11:0] pp_xy = p_is_over ? 12'hFFF : (p_sum_trunc[11:0] + p_sum[9]);


// // ====================== DPC =====================

// reg [11:0] lb0 [0:15]; 
// reg [11:0] lb1 [0:15];
// reg [11:0] lb2 [0:15]; 
// reg [11:0] lb3 [0:15];
// reg [11:0] lb4 [0:4]; 

// always @(posedge clk) begin
//     if (in_valid_ff_ff || cs == DPC || cs == DEM) begin
//         for (i = 15; i > 0; i = i - 1) begin
//             lb3[i] <= lb3[i - 1]; 
//             lb2[i] <= lb2[i - 1];
//             lb1[i] <= lb1[i - 1]; 
//             lb0[i] <= lb0[i - 1];
//         end
//         lb3[0] <= lb2[15]; 
//         lb2[0] <= lb1[15];
//         lb1[0] <= lb0[15]; 
//         lb0[0] <= (in_valid_ff_ff) ? pp_xy : 0;
        
//         for (i = 4; i > 0; i = i - 1) 
//             lb4[i] <= lb4[i - 1];
            
//         lb4[0] <= lb3[15];
//     end
//     else begin
//         for (i = 0; i < 16; i = i + 1) begin
//             lb0[i] <= 0; 
//             lb1[i] <= 0; 
//             lb2[i] <= 0; 
//             lb3[i] <= 0;
//         end
//         for (i = 0; i < 5; i = i + 1) 
//             lb4[i] <= 0;
//     end
// end

// reg [11:0] px_mat [0:4][0:4];

// always @(*) begin
//     for (i = 0; i < 5; i = i + 1) begin
//         px_mat[4][i] = lb0[4 - i];
//         px_mat[3][i] = lb1[4 - i];
//         px_mat[2][i] = lb2[4 - i];
//         px_mat[1][i] = lb3[4 - i];
//         px_mat[0][i] = lb4[4 - i];
//     end
// end

// always @(posedge clk) begin
//     if (cs == DPC || cs == DEM) begin
//         if (dpc_cnt_x == 15) begin
//             dpc_cnt_x <= 0;
//             if (dpc_cnt_y == 15) 
//                 dpc_cnt_y <= 0;
//             else 
//                 dpc_cnt_y <= dpc_cnt_y + 1;
//         end
//         else 
//             dpc_cnt_x <= dpc_cnt_x + 1;
//     end
//     else begin
//         dpc_cnt_x <= 0; 
//         dpc_cnt_y <= 0;
//     end
// end

// reg [2:0] px [0:4];
// reg [2:0] py [0:4];

// always @(*) begin
//     px[0] = (dpc_cnt_x == 4'd0)  ? 3'd4 : (dpc_cnt_x == 4'd1)  ? 3'd2 : 3'd0;
//     px[1] = (dpc_cnt_x == 4'd0)  ? 3'd3 : 3'd1; 
//     px[2] = 3'd2; 
//     px[3] = (dpc_cnt_x == 4'd15) ? 3'd1 : 3'd3; 
//     px[4] = (dpc_cnt_x == 4'd15) ? 3'd0 : (dpc_cnt_x == 4'd14) ? 3'd2 : 3'd4;

//     py[0] = (dpc_cnt_y == 4'd0)  ? 3'd4 : (dpc_cnt_y == 4'd1)  ? 3'd2 : 3'd0;
//     py[1] = (dpc_cnt_y == 4'd0)  ? 3'd3 : 3'd1; 
//     py[2] = 3'd2; 
//     py[3] = (dpc_cnt_y == 4'd15) ? 3'd1 : 3'd3; 
//     py[4] = (dpc_cnt_y == 4'd15) ? 3'd0 : (dpc_cnt_y == 4'd14) ? 3'd2 : 3'd4;
// end

// reg [11:0] p_row_0 [0:4]; 
// reg [11:0] p_row_1 [0:4]; 
// reg [11:0] p_row_2 [0:4];
// reg [11:0] p_row_3 [0:4]; 
// reg [11:0] p_row_4 [0:4];

// always @(*) begin
//     for(i = 0; i < 5; i = i + 1) begin
//         p_row_0[i] = px_mat[py[0]][i]; 
//         p_row_1[i] = px_mat[py[1]][i];
//         p_row_2[i] = px_mat[py[2]][i]; 
//         p_row_3[i] = px_mat[py[3]][i];
//         p_row_4[i] = px_mat[py[4]][i];
//     end
// end

// reg [11:0] H  [0:3];
// reg [11:0] V  [0:3];
// reg [11:0] D1 [0:3];
// reg [11:0] D2 [0:3];

// always @(*) begin
//     H[0]  = p_row_2[px[0]]; 
//     H[1]  = p_row_2[px[1]]; 
//     H[2]  = p_row_2[px[3]]; 
//     H[3]  = p_row_2[px[4]];

//     V[0]  = p_row_0[px[2]]; 
//     V[1]  = p_row_1[px[2]]; 
//     V[2]  = p_row_3[px[2]]; 
//     V[3]  = p_row_4[px[2]];

//     D1[0] = p_row_0[px[0]]; 
//     D1[1] = p_row_1[px[1]]; 
//     D1[2] = p_row_3[px[3]]; 
//     D1[3] = p_row_4[px[4]];

//     D2[0] = p_row_0[px[4]]; 
//     D2[1] = p_row_1[px[3]]; 
//     D2[2] = p_row_3[px[1]]; 
//     D2[3] = p_row_4[px[0]];
// end

// reg [11:0] H_ff[0:3], V_ff[0:3], D1_ff[0:3], D2_ff[0:3];
// reg [11:0] P_ff;
// reg        dpc_valid_ff;

// always @(posedge clk) begin
//     for(i = 0; i < 4; i = i + 1) begin
//         H_ff[i] <= H[i]; 
//         V_ff[i] <= V[i]; 
//         D1_ff[i] <= D1[i]; 
//         D2_ff[i] <= D2[i];
//     end
//     P_ff <= p_row_2[px[2]];
//     dpc_valid_ff <= (cs == DPC || cs == DEM);
// end

// wire [11:0] med_H, med_V, med_D1, med_D2;

// median calc_med_H (.A(H_ff[0]), .B(H_ff[1]), .C(H_ff[2]), .D(H_ff[3]), .median(med_H));
// median calc_med_V (.A(V_ff[0]), .B(V_ff[1]), .C(V_ff[2]), .D(V_ff[3]), .median(med_V));
// median calc_med_D1(.A(D1_ff[0]),.B(D1_ff[1]),.C(D1_ff[2]),.D(D1_ff[3]),.median(med_D1));
// median calc_med_D2(.A(D2_ff[0]),.B(D2_ff[1]),.C(D2_ff[2]),.D(D2_ff[3]),.median(med_D2));

// reg [11:0] H_ff_ff[0:3], V_ff_ff[0:3], D1_ff_ff[0:3], D2_ff_ff[0:3];
// reg [11:0] med_H_ff, med_V_ff, med_D1_ff, med_D2_ff;
// reg [11:0] P_ff_ff;
// reg        dpc_valid_ff_ff;

// always @(posedge clk) begin
//     for(i = 0; i < 4; i = i + 1) begin
//         H_ff_ff[i] <= H_ff[i]; 
//         V_ff_ff[i] <= V_ff[i]; 
//         D1_ff_ff[i] <= D1_ff[i]; 
//         D2_ff_ff[i] <= D2_ff[i];
//     end
//     med_H_ff <= med_H; 
//     med_V_ff <= med_V; 
//     med_D1_ff <= med_D1; 
//     med_D2_ff <= med_D2;
//     P_ff_ff <= P_ff;
//     dpc_valid_ff_ff <= dpc_valid_ff;
// end

// // 宣告 val (反轉值) 與 sign (符號，即需要 +1 的進位)
// wire [11:0] vH0, vH1, vH2, vH3; wire sH0, sH1, sH2, sH3;
// wire [11:0] vV0, vV1, vV2, vV3; wire sV0, sV1, sV2, sV3;
// wire [11:0] vD1_0, vD1_1, vD1_2, vD1_3; wire sD1_0, sD1_1, sD1_2, sD1_3;
// wire [11:0] vD2_0, vD2_1, vD2_2, vD2_3; wire sD2_0, sD2_1, sD2_2, sD2_3;

// sad sad_h0 (.A(H_ff_ff[0]), .B(med_H_ff), .val(vH0), .sign(sH0)); 
// sad sad_h1 (.A(H_ff_ff[1]), .B(med_H_ff), .val(vH1), .sign(sH1));
// sad sad_h2 (.A(H_ff_ff[2]), .B(med_H_ff), .val(vH2), .sign(sH2)); 
// sad sad_h3 (.A(H_ff_ff[3]), .B(med_H_ff), .val(vH3), .sign(sH3));
// // 讓合成軟體自動生成高速 CSA 樹，一口氣把數值和進位加完！
// wire [13:0] SAD_H = vH0 + vH1 + vH2 + vH3 + sH0 + sH1 + sH2 + sH3;

// sad sad_v0 (.A(V_ff_ff[0]), .B(med_V_ff), .val(vV0), .sign(sV0)); 
// sad sad_v1 (.A(V_ff_ff[1]), .B(med_V_ff), .val(vV1), .sign(sV1));
// sad sad_v2 (.A(V_ff_ff[2]), .B(med_V_ff), .val(vV2), .sign(sV2)); 
// sad sad_v3 (.A(V_ff_ff[3]), .B(med_V_ff), .val(vV3), .sign(sV3));
// wire [13:0] SAD_V = vV0 + vV1 + vV2 + vV3 + sV0 + sV1 + sV2 + sV3;

// sad sad_d1_0 (.A(D1_ff_ff[0]), .B(med_D1_ff), .val(vD1_0), .sign(sD1_0)); 
// sad sad_d1_1 (.A(D1_ff_ff[1]), .B(med_D1_ff), .val(vD1_1), .sign(sD1_1));
// sad sad_d1_2 (.A(D1_ff_ff[2]), .B(med_D1_ff), .val(vD1_2), .sign(sD1_2)); 
// sad sad_d1_3 (.A(D1_ff_ff[3]), .B(med_D1_ff), .val(vD1_3), .sign(sD1_3));
// wire [13:0] SAD_D1 = vD1_0 + vD1_1 + vD1_2 + vD1_3 + sD1_0 + sD1_1 + sD1_2 + sD1_3;

// sad sad_d2_0 (.A(D2_ff_ff[0]), .B(med_D2_ff), .val(vD2_0), .sign(sD2_0)); 
// sad sad_d2_1 (.A(D2_ff_ff[1]), .B(med_D2_ff), .val(vD2_1), .sign(sD2_1));
// sad sad_d2_2 (.A(D2_ff_ff[2]), .B(med_D2_ff), .val(vD2_2), .sign(sD2_2)); 
// sad sad_d2_3 (.A(D2_ff_ff[3]), .B(med_D2_ff), .val(vD2_3), .sign(sD2_3));
// wire [13:0] SAD_D2 = vD2_0 + vD2_1 + vD2_2 + vD2_3 + sD2_0 + sD2_1 + sD2_2 + sD2_3;

// // // ====================== DEM 控制 =====================

// reg  [3:0] dem_cnt_x, dem_cnt_y;

// always @(posedge clk or negedge rst_n) begin
//     if (~rst_n) begin
//         dem_cnt <= 0; 
//         dem_cnt_x <= 0; 
//         dem_cnt_y <= 0;
//     end
//     else if (cs == DEM) begin
//         dem_cnt <= dem_cnt + 1;
//         if (dem_cnt_x == 15) begin
//             dem_cnt_x <= 0; 
//             dem_cnt_y <= dem_cnt_y + 1;
//         end
//         else 
//             dem_cnt_x <= dem_cnt_x + 1;
//     end
//     else 
//         dem_cnt <= 0;
// end

// // 【Timing 終極前推】在算 SAD 的這拍，預先算出各方向是否超過 320
// wire [12:0] diff_P_H  = (P_ff_ff > med_H_ff)  ? ({1'b0, P_ff_ff} - {1'b0, med_H_ff})  : ({1'b0, med_H_ff} - {1'b0, P_ff_ff});
// wire [12:0] diff_P_V  = (P_ff_ff > med_V_ff)  ? ({1'b0, P_ff_ff} - {1'b0, med_V_ff})  : ({1'b0, med_V_ff} - {1'b0, P_ff_ff});
// wire [12:0] diff_P_D1 = (P_ff_ff > med_D1_ff) ? ({1'b0, P_ff_ff} - {1'b0, med_D1_ff}) : ({1'b0, med_D1_ff} - {1'b0, P_ff_ff});
// wire [12:0] diff_P_D2 = (P_ff_ff > med_D2_ff) ? ({1'b0, P_ff_ff} - {1'b0, med_D2_ff}) : ({1'b0, med_D2_ff} - {1'b0, P_ff_ff});

// wire cond_H_pre  = (diff_P_H > 13'd320);
// wire cond_V_pre  = (diff_P_V > 13'd320);
// wire cond_D1_pre = (diff_P_D1 > 13'd320);
// wire cond_D2_pre = (diff_P_D2 > 13'd320);

// reg [13:0] SAD_H_ff, SAD_V_ff, SAD_D1_ff, SAD_D2_ff;
// reg [11:0] med_H_ff_ff, med_V_ff_ff, med_D1_ff_ff, med_D2_ff_ff;
// reg [11:0] P_ff_ff_ff;
// reg        dpc_valid_ff_ff_ff;
// reg        cond_H_ff, cond_V_ff, cond_D1_ff, cond_D2_ff; // 新增：把判斷結果存起來

// always @(posedge clk) begin
//     SAD_H_ff  <= SAD_H;  
//     SAD_V_ff  <= SAD_V; 
//     SAD_D1_ff <= SAD_D1; 
//     SAD_D2_ff <= SAD_D2;
    
//     med_H_ff_ff  <= med_H_ff;  
//     med_V_ff_ff  <= med_V_ff; 
//     med_D1_ff_ff <= med_D1_ff; 
//     med_D2_ff_ff <= med_D2_ff;
    
//     P_ff_ff_ff   <= P_ff_ff;
//     dpc_valid_ff_ff_ff <= dpc_valid_ff_ff;
    
//     // 將預先算好的替換條件推到下一拍
//     cond_H_ff  <= cond_H_pre;
//     cond_V_ff  <= cond_V_pre;
//     cond_D1_ff <= cond_D1_pre;
//     cond_D2_ff <= cond_D2_pre;
// end

// // 這一拍完全拔除加減法與 13-bit 比較器！純 MUX 挑選！
// wire cmp_HV = (SAD_H_ff <= SAD_V_ff);
// wire [13:0] min_SAD_HV = cmp_HV ? SAD_H_ff : SAD_V_ff;
// wire [11:0] target_HV  = cmp_HV ? med_H_ff_ff : med_V_ff_ff;
// wire        cond_HV    = cmp_HV ? cond_H_ff   : cond_V_ff; 

// wire cmp_D1D2 = (SAD_D1_ff <= SAD_D2_ff);
// wire [13:0] min_SAD_D1D2 = cmp_D1D2 ? SAD_D1_ff : SAD_D2_ff;
// wire [11:0] target_D1D2  = cmp_D1D2 ? med_D1_ff_ff : med_D2_ff_ff;
// wire        cond_D1D2    = cmp_D1D2 ? cond_D1_ff   : cond_D2_ff; 

// wire cmp_final = (min_SAD_HV <= min_SAD_D1D2);
// wire [11:0] Target = cmp_final ? target_HV : target_D1D2;
// wire replace_cond  = cmp_final ? cond_HV   : cond_D1D2; 

// wire [11:0] dpc_out = replace_cond ? Target : P_ff_ff_ff;

// // FIFO 深度 236 保持不變，維持 out_valid 時序完美對齊！
// reg [11:0] dpc_fifo [0:235];

// always @(posedge clk) begin
//     for (i = 235; i > 0; i = i - 1) 
//         dpc_fifo[i] <= dpc_fifo[i - 1];

//     dpc_fifo[0] <= dpc_out;
// end

// // ============================ DEM ===================================

// wire [1:0] dem_color_id = {dem_cnt_y[0], dem_cnt_x[0]};

// wire [11:0] raw_C  = dpc_fifo[213];
// wire [11:0] raw_E  = dpc_fifo[212];
// wire [11:0] raw_W  = dpc_fifo[214];
// wire [11:0] raw_S  = dpc_fifo[197];
// wire [11:0] raw_SE = dpc_fifo[196];
// wire [11:0] raw_SW = dpc_fifo[198];
// wire [11:0] raw_N  = dpc_fifo[229];
// wire [11:0] raw_NE = dpc_fifo[228];
// wire [11:0] raw_NW = dpc_fifo[230];

// wire is_top    = (dem_cnt_y == 0);
// wire is_bottom = (dem_cnt_y == 15);
// wire is_left   = (dem_cnt_x == 0);
// wire is_right  = (dem_cnt_x == 15);

// wire [11:0] C = raw_C;
// wire [11:0] W = is_left  ? raw_E : raw_W;
// wire [11:0] E = is_right ? raw_W : raw_E;
// wire [11:0] N = is_top   ? raw_S : raw_N;
// wire [11:0] S = is_bottom ? raw_N : raw_S;

// wire [11:0] NW = (is_top & is_left)  ? raw_SE :
//                  (is_top)            ? raw_SW :
//                  (is_left)           ? raw_NE : raw_NW;

// wire [11:0] NE = (is_top & is_right) ? raw_SW :
//                  (is_top)            ? raw_SE :
//                  (is_right)          ? raw_NW : raw_NE;

// wire [11:0] SW = (is_bottom & is_left) ? raw_NE :
//                  (is_bottom)           ? raw_NW :
//                  (is_left)             ? raw_SE : raw_SW;

// wire [11:0] SE = (is_bottom & is_right) ? raw_NW :
//                  (is_bottom)            ? raw_NE :
//                  (is_right)             ? raw_SW : raw_SE;


// wire [12:0] total_ns = N + S; 
// wire [12:0] total_we = W + E; 

// wire [13:0] total_nswe  = total_ns + total_we; 
// wire [13:0] total_other = (NW + NE) + (SW + SE); 

// wire [11:0] avg_nswe   = total_nswe[13:2]; 
// wire [11:0] avg_pother = total_other[13:2];
// wire [11:0] avg_ns     = total_ns[12:1];     
// wire [11:0] avg_we     = total_we[12:1];     

// reg [11:0] r_interp, g_interp, b_interp;

// always @(*) begin
//     case (dem_color_id)
//         2'b00: begin r_interp = C;          g_interp = avg_nswe; b_interp = avg_pother; end 
//         2'b01: begin r_interp = avg_we;     g_interp = C;        b_interp = avg_ns;     end 
//         2'b10: begin r_interp = avg_ns;     g_interp = C;        b_interp = avg_we;     end 
//         2'b11: begin r_interp = avg_pother; g_interp = avg_nswe; b_interp = C;          end 
//     endcase
// end

// reg [11:0] r_dem_ff, g_dem_ff, b_dem_ff;
// reg        dem_valid_ff;

// always @(posedge clk) begin
//     r_dem_ff     <= r_interp;
//     g_dem_ff     <= g_interp;
//     b_dem_ff     <= b_interp;
//     dem_valid_ff <= (cs == DEM);
// end

// // ========================== CCM =====================================

// wire signed [13:0] r_s = $signed({2'b0, r_dem_ff});
// wire signed [13:0] g_s = $signed({2'b0, g_dem_ff});
// wire signed [13:0] b_s = $signed({2'b0, b_dem_ff});

// // 【Timing 絕殺：數學等價展開 (打平加法樹)】
// // 原本公式: r_raw = 1150*R - 50*(R+G+B) + 512
// // 數學等價: r_raw = 1100*R - 50*(G+B) + 512
// // 這樣能把深達 8 層的加法依賴，打平成 3~4 層，直接解掉 -0.26ns！

// wire signed [14:0] gb_sum = g_s + b_s;
// wire signed [14:0] rb_sum = r_s + b_s;
// wire signed [14:0] rg_sum = r_s + g_s;

// // 1100 = 1024 + 64 + 8 + 4 (利用括號強制 DC 生成平衡樹 Balanced Tree)
// wire signed [26:0] r_1100 = ((r_s <<< 10) + (r_s <<< 6)) + ((r_s <<< 3) + (r_s <<< 2));
// wire signed [26:0] g_1100 = ((g_s <<< 10) + (g_s <<< 6)) + ((g_s <<< 3) + (g_s <<< 2));
// wire signed [26:0] b_1100 = ((b_s <<< 10) + (b_s <<< 6)) + ((b_s <<< 3) + (b_s <<< 2));

// // 50 = 32 + 16 + 2
// wire signed [26:0] gb_50 = ((gb_sum <<< 5) + (gb_sum <<< 4)) + (gb_sum <<< 1);
// wire signed [26:0] rb_50 = ((rb_sum <<< 5) + (rb_sum <<< 4)) + (rb_sum <<< 1);
// wire signed [26:0] rg_50 = ((rg_sum <<< 5) + (rg_sum <<< 4)) + (rg_sum <<< 1);

// // 最終加總，括號確保加法器平行運算
// wire signed [26:0] r_raw = (r_1100 - gb_50) + 27'sd512;
// wire signed [26:0] g_raw = (g_1100 - rb_50) + 27'sd512;
// wire signed [26:0] b_raw = (b_1100 - rg_50) + 27'sd512;

// // 【Timing 再優化：拔除 Shift 與 Unsigned 轉換】
// // 直接從 r_raw 抽 bit 判斷溢位，省去大量的線路繞線 (Routing) 與邏輯閘
// wire r_is_neg = r_raw[26];
// wire g_is_neg = g_raw[26];
// wire b_is_neg = b_raw[26];

// // 如果不是負數，只要 [25:22] 有任何一個 bit 是 1，就代表大於 4095
// wire r_is_over = (|r_raw[25:22]) & ~r_is_neg;
// wire g_is_over = (|g_raw[25:22]) & ~g_is_neg;
// wire b_is_over = (|b_raw[25:22]) & ~b_is_neg;

// // r_raw[21:10] 就是原本 Shift 完的精確數值，直接拿來用！
// wire [12:0] r_ccm = r_is_neg ? 13'd0 : (r_is_over ? 13'd4095 : {1'b0, r_raw[21:10]});
// wire [12:0] g_ccm = g_is_neg ? 13'd0 : (g_is_over ? 13'd4095 : {1'b0, g_raw[21:10]});
// wire [12:0] b_ccm = b_is_neg ? 13'd0 : (b_is_over ? 13'd4095 : {1'b0, b_raw[21:10]});

// always @(posedge clk or negedge rst_n) begin
//     if (~rst_n) begin
//         out_valid <= 0; 
//         r_out <= 0; 
//         g_out <= 0; 
//         b_out <= 0;
//     end
//     else if (dem_valid_ff) begin 
//         out_valid <= 1;
//         r_out     <= r_ccm; 
//         g_out     <= g_ccm;
//         b_out     <= b_ccm;
//     end
//     else begin
//         out_valid <= 0; 
//         r_out <= 0; 
//         g_out <= 0; 
//         b_out <= 0;
//     end
// end

// endmodule

// module median (
//     input  [11:0] A, B, C, D,
//     output [11:0] median
// );
//     // 1. 第一層比較
//     wire A_gt_B = (A > B);
//     wire C_gt_D = (C > D);

//     wire [11:0] max1 = A_gt_B ? A : B;
//     wire [11:0] min1 = A_gt_B ? B : A;
//     wire [11:0] max2 = C_gt_D ? C : D;
//     wire [11:0] min2 = C_gt_D ? D : C;

//     // 2. 第二層比較
//     wire min1_gt_min2 = (min1 > min2);
//     wire max1_lt_max2 = (max1 < max2);

//     // 3. 【Timing 優化：加法平行化】
//     // 預先計算所有可能的組合和！這 4 個加法器會跟前面的比較器「同時」執行
//     wire [12:0] sum_AB = {1'b0, A} + {1'b0, B};
//     wire [12:0] sum_CD = {1'b0, C} + {1'b0, D};
//     wire [12:0] sum_min2_max1 = {1'b0, min2} + {1'b0, max1};
//     wire [12:0] sum_min1_max2 = {1'b0, min1} + {1'b0, max2};

//     // 4. 比較結果出來後，直接純 MUX 挑選答案，拔除最後端的加法延遲
//     reg [12:0] safe_sum;
//     always @(*) begin
//         case ({min1_gt_min2, max1_lt_max2})
//             2'b00: safe_sum = sum_CD;
//             2'b11: safe_sum = sum_AB;
//             2'b01: safe_sum = sum_min2_max1;
//             2'b10: safe_sum = sum_min1_max2;
//         endcase
//     end

//     assign median = safe_sum[12:1];

// endmodule

// // 【Timing 絕殺：把 +1 留給頂層加法樹】
// module sad (
//     input  [11:0] A, B,
//     output [11:0] val,
//     output        sign
// );
//     wire [12:0] diff = {1'b0, A} - {1'b0, B};
//     assign sign = diff[12];
//     assign val  = diff[11:0] ^ {12{sign}}; // 如果是負數就反轉 (1補數)，正數保持不變
// endmodule
module ISP (
    input         clk,
    input         rst_n,
    input         in_valid,
    input  [12:0] in,
    input         param_valid,
    input  [12:0] param_gain,

    output reg        out_valid,
    output reg [12:0] r_out,
    output reg [12:0] g_out,
    output reg [12:0] b_out
);

//==============================
//   Design
//==============================
localparam IDLE  = 2'd0;
localparam INPUT = 2'd1;
localparam DPC   = 2'd2;
localparam DEM   = 2'd3;

integer i, j, k;

reg  [3:0] x_cnt, y_cnt; 
reg  [3:0] dpc_cnt_x, dpc_cnt_y;
reg  [7:0] dem_cnt;

reg  [1:0] cs, ns;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) cs <= IDLE;
    else        cs <= ns;
end

always @(*) begin
    ns = cs; 
    case (cs)
        IDLE:  ns = (in_valid) ? INPUT : IDLE;
        INPUT: ns = (x_cnt == 4 && y_cnt == 2) ? DPC : INPUT;
        DPC:   ns = (dpc_cnt_x == 8 && dpc_cnt_y == 13) ? DEM : DPC;
        DEM:   ns = (dem_cnt == 255) ? IDLE : DEM;
    endcase
end

reg [2:0] param_x_cnt, param_y_cnt; 
reg [1:0] next_gain;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        param_x_cnt <= 0; 
        param_y_cnt <= 0; 
        next_gain <= 0;
    end
    else if (param_valid) begin
        if (param_x_cnt == 5 && param_y_cnt == 5) begin
            param_x_cnt <= 0; 
            param_y_cnt <= 0; 
            next_gain <= next_gain + 1;
        end
        else if (param_x_cnt == 5) begin 
            param_x_cnt <= 3'd0; 
            param_y_cnt <= param_y_cnt + 3'd1;
        end
        else
            param_x_cnt <= param_x_cnt + 3'd1;
    end
end

reg [12:0] param_matrix [0:3][0:5][0:5];

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        for (i = 0; i < 4; i = i + 1) 
            for (j = 0; j < 6; j = j + 1) 
                for (k = 0; k < 6; k = k + 1)
                    param_matrix[i][j][k] <= 0;
    end
    else if (param_valid) begin
        param_matrix[next_gain][param_y_cnt][param_x_cnt] <= param_gain;
    end
end

// ====================== BLC =====================
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        x_cnt <= 0; 
        y_cnt <= 0;
    end
    else if (in_valid) begin
        if (x_cnt == 15) begin 
            x_cnt <= 0; 
            y_cnt <= y_cnt + 1;
        end
        else 
            x_cnt <= x_cnt + 1;
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

wire [13:0] sub_result = {1'b0, in} - {7'b0, black_level};
wire [12:0] i_blc = sub_result[13] ? 0 : sub_result[12:0];

// ====================== LSC =====================
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

always @(*) begin
    g00 = param_matrix[color_id][y0][x0];
    g01 = param_matrix[color_id][y0][x0 + 1];
    g10 = param_matrix[color_id][y0 + 1][x0];
    g11 = param_matrix[color_id][y0 + 1][x0 + 1];
end

wire [13:0] g0110 = g01 + g10;
wire [13:0] g0011 = g00 + g11;
wire [13:0] g0010 = g00 + g10; 
wire [13:0] g0001 = g00 + g01; 

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
    m_29241_ff <= m_29241; 
    m_14535_ff <= m_14535; 
    m_7225_ff  <= m_7225;
    g00_ff     <= g00;
    rx_ry_zero_ff <= ({rx, ry} == 0);
    i_blc_ff   <= i_blc;
    in_valid_ff<= in_valid;
end

wire [29:0] gxy_sum_opt = (m_29241_ff * 29241) + 
                          (m_14535_ff * 14535) + 
                          (m_7225_ff  * 7225);

wire [13:0] gxy_calc = gxy_sum_opt[29:16] + gxy_sum_opt[15];
wire [13:0] gxy = (rx_ry_zero_ff) ? {1'b0, g00_ff} : gxy_calc;

reg [13:0] gxy_ff;
reg [12:0] i_blc_ff_ff;
reg        in_valid_ff_ff;

always @(posedge clk) begin
    gxy_ff         <= gxy;
    i_blc_ff_ff    <= i_blc_ff; 
    in_valid_ff_ff <= in_valid_ff; 
end

// Same-cycle LSC output. Do not insert a register here, otherwise total latency changes.
// Roll back to the original one-multiplier form. The split-multiplier form made DC mapping worse.
wire [25:0] p_sum = gxy_ff * i_blc_ff_ff;
wire [15:0] p_sum_trunc = p_sum[25:10];
wire p_is_over = (|p_sum_trunc[15:12]) || ((p_sum_trunc[11:0] == 12'hFFF) && p_sum[9]);
wire [11:0] pp_xy = p_is_over ? 12'hFFF : (p_sum_trunc[11:0] + p_sum[9]);

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
            lb1[i] <= 0; 
            lb2[i] <= 0; 
            lb3[i] <= 0;
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

reg [11:0] p_row_0 [0:4]; 
reg [11:0] p_row_1 [0:4]; 
reg [11:0] p_row_2 [0:4];
reg [11:0] p_row_3 [0:4]; 
reg [11:0] p_row_4 [0:4];

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
reg [11:0] D1 [0:3];
reg [11:0] D2 [0:3];

always @(*) begin
    H[0]  = p_row_2[px[0]]; 
    H[1]  = p_row_2[px[1]]; 
    H[2]  = p_row_2[px[3]]; 
    H[3]  = p_row_2[px[4]];

    V[0]  = p_row_0[px[2]]; 
    V[1]  = p_row_1[px[2]]; 
    V[2]  = p_row_3[px[2]]; 
    V[3]  = p_row_4[px[2]];

    D1[0] = p_row_0[px[0]]; 
    D1[1] = p_row_1[px[1]]; 
    D1[2] = p_row_3[px[3]]; 
    D1[3] = p_row_4[px[4]];

    D2[0] = p_row_0[px[4]]; 
    D2[1] = p_row_1[px[3]]; 
    D2[2] = p_row_3[px[1]]; 
    D2[3] = p_row_4[px[0]];
end

reg [11:0] H_ff[0:3], V_ff[0:3], D1_ff[0:3], D2_ff[0:3];
reg [11:0] P_ff;
reg        dpc_valid_ff;

always @(posedge clk) begin
    for(i = 0; i < 4; i = i + 1) begin
        H_ff[i] <= H[i]; 
        V_ff[i] <= V[i]; 
        D1_ff[i] <= D1[i]; 
        D2_ff[i] <= D2[i];
    end
    P_ff <= p_row_2[px[2]];
    dpc_valid_ff <= (cs == DPC || cs == DEM);
end

wire [11:0] med_H, med_V, med_D1, med_D2;

median calc_med_H (.A(H_ff[0]), .B(H_ff[1]), .C(H_ff[2]), .D(H_ff[3]), .median(med_H));
median calc_med_V (.A(V_ff[0]), .B(V_ff[1]), .C(V_ff[2]), .D(V_ff[3]), .median(med_V));
median calc_med_D1(.A(D1_ff[0]),.B(D1_ff[1]),.C(D1_ff[2]),.D(D1_ff[3]),.median(med_D1));
median calc_med_D2(.A(D2_ff[0]),.B(D2_ff[1]),.C(D2_ff[2]),.D(D2_ff[3]),.median(med_D2));

reg [11:0] H_ff_ff[0:3], V_ff_ff[0:3], D1_ff_ff[0:3], D2_ff_ff[0:3];
reg [11:0] med_H_ff, med_V_ff, med_D1_ff, med_D2_ff;
reg [11:0] P_ff_ff;
reg        dpc_valid_ff_ff;

always @(posedge clk) begin
    for(i = 0; i < 4; i = i + 1) begin
        H_ff_ff[i] <= H_ff[i]; 
        V_ff_ff[i] <= V_ff[i]; 
        D1_ff_ff[i] <= D1_ff[i]; 
        D2_ff_ff[i] <= D2_ff[i];
    end
    med_H_ff <= med_H; 
    med_V_ff <= med_V; 
    med_D1_ff <= med_D1; 
    med_D2_ff <= med_D2;
    P_ff_ff <= P_ff;
    dpc_valid_ff_ff <= dpc_valid_ff;
end

wire [11:0] vH0, vH1, vH2, vH3; wire sH0, sH1, sH2, sH3;
wire [11:0] vV0, vV1, vV2, vV3; wire sV0, sV1, sV2, sV3;
wire [11:0] vD1_0, vD1_1, vD1_2, vD1_3; wire sD1_0, sD1_1, sD1_2, sD1_3;
wire [11:0] vD2_0, vD2_1, vD2_2, vD2_3; wire sD2_0, sD2_1, sD2_2, sD2_3;

sad sad_h0 (.A(H_ff_ff[0]), .B(med_H_ff), .val(vH0), .sign(sH0)); 
sad sad_h1 (.A(H_ff_ff[1]), .B(med_H_ff), .val(vH1), .sign(sH1));
sad sad_h2 (.A(H_ff_ff[2]), .B(med_H_ff), .val(vH2), .sign(sH2)); 
sad sad_h3 (.A(H_ff_ff[3]), .B(med_H_ff), .val(vH3), .sign(sH3));

sad sad_v0 (.A(V_ff_ff[0]), .B(med_V_ff), .val(vV0), .sign(sV0)); 
sad sad_v1 (.A(V_ff_ff[1]), .B(med_V_ff), .val(vV1), .sign(sV1));
sad sad_v2 (.A(V_ff_ff[2]), .B(med_V_ff), .val(vV2), .sign(sV2)); 
sad sad_v3 (.A(V_ff_ff[3]), .B(med_V_ff), .val(vV3), .sign(sV3));

sad sad_d1_0 (.A(D1_ff_ff[0]), .B(med_D1_ff), .val(vD1_0), .sign(sD1_0)); 
sad sad_d1_1 (.A(D1_ff_ff[1]), .B(med_D1_ff), .val(vD1_1), .sign(sD1_1));
sad sad_d1_2 (.A(D1_ff_ff[2]), .B(med_D1_ff), .val(vD1_2), .sign(sD1_2)); 
sad sad_d1_3 (.A(D1_ff_ff[3]), .B(med_D1_ff), .val(vD1_3), .sign(sD1_3));

sad sad_d2_0 (.A(D2_ff_ff[0]), .B(med_D2_ff), .val(vD2_0), .sign(sD2_0)); 
sad sad_d2_1 (.A(D2_ff_ff[1]), .B(med_D2_ff), .val(vD2_1), .sign(sD2_1));
sad sad_d2_2 (.A(D2_ff_ff[2]), .B(med_D2_ff), .val(vD2_2), .sign(sD2_2)); 
sad sad_d2_3 (.A(D2_ff_ff[3]), .B(med_D2_ff), .val(vD2_3), .sign(sD2_3));

// Timing-safe change 1:
// Replace long chained SAD addition with balanced partial sums.
wire [12:0] H_01 = {1'b0, vH0} + {1'b0, vH1};
wire [12:0] H_23 = {1'b0, vH2} + {1'b0, vH3};
wire [13:0] H_val_sum = {1'b0, H_01} + {1'b0, H_23};
wire [2:0]  H_sign_sum = {2'b0, sH0} + {2'b0, sH1} + {2'b0, sH2} + {2'b0, sH3};
wire [13:0] SAD_H = H_val_sum + {11'd0, H_sign_sum};

wire [12:0] V_01 = {1'b0, vV0} + {1'b0, vV1};
wire [12:0] V_23 = {1'b0, vV2} + {1'b0, vV3};
wire [13:0] V_val_sum = {1'b0, V_01} + {1'b0, V_23};
wire [2:0]  V_sign_sum = {2'b0, sV0} + {2'b0, sV1} + {2'b0, sV2} + {2'b0, sV3};
wire [13:0] SAD_V = V_val_sum + {11'd0, V_sign_sum};

wire [12:0] D1_01 = {1'b0, vD1_0} + {1'b0, vD1_1};
wire [12:0] D1_23 = {1'b0, vD1_2} + {1'b0, vD1_3};
wire [13:0] D1_val_sum = {1'b0, D1_01} + {1'b0, D1_23};
wire [2:0]  D1_sign_sum = {2'b0, sD1_0} + {2'b0, sD1_1} + {2'b0, sD1_2} + {2'b0, sD1_3};
wire [13:0] SAD_D1 = D1_val_sum + {11'd0, D1_sign_sum};

wire [12:0] D2_01 = {1'b0, vD2_0} + {1'b0, vD2_1};
wire [12:0] D2_23 = {1'b0, vD2_2} + {1'b0, vD2_3};
wire [13:0] D2_val_sum = {1'b0, D2_01} + {1'b0, D2_23};
wire [2:0]  D2_sign_sum = {2'b0, sD2_0} + {2'b0, sD2_1} + {2'b0, sD2_2} + {2'b0, sD2_3};
wire [13:0] SAD_D2 = D2_val_sum + {11'd0, D2_sign_sum};

// ====================== DEM control =====================
reg  [3:0] dem_cnt_x, dem_cnt_y;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        dem_cnt <= 0; 
        dem_cnt_x <= 0; 
        dem_cnt_y <= 0;
    end
    else if (cs == DEM) begin
        dem_cnt <= dem_cnt + 1;
        if (dem_cnt_x == 15) begin
            dem_cnt_x <= 0; 
            dem_cnt_y <= dem_cnt_y + 1;
        end
        else 
            dem_cnt_x <= dem_cnt_x + 1;
    end
    else 
        dem_cnt <= 0;
end

wire [12:0] diff_P_H  = (P_ff_ff > med_H_ff)  ? ({1'b0, P_ff_ff} - {1'b0, med_H_ff})  : ({1'b0, med_H_ff} - {1'b0, P_ff_ff});
wire [12:0] diff_P_V  = (P_ff_ff > med_V_ff)  ? ({1'b0, P_ff_ff} - {1'b0, med_V_ff})  : ({1'b0, med_V_ff} - {1'b0, P_ff_ff});
wire [12:0] diff_P_D1 = (P_ff_ff > med_D1_ff) ? ({1'b0, P_ff_ff} - {1'b0, med_D1_ff}) : ({1'b0, med_D1_ff} - {1'b0, P_ff_ff});
wire [12:0] diff_P_D2 = (P_ff_ff > med_D2_ff) ? ({1'b0, P_ff_ff} - {1'b0, med_D2_ff}) : ({1'b0, med_D2_ff} - {1'b0, P_ff_ff});

wire cond_H_pre  = (diff_P_H > 13'd320);
wire cond_V_pre  = (diff_P_V > 13'd320);
wire cond_D1_pre = (diff_P_D1 > 13'd320);
wire cond_D2_pre = (diff_P_D2 > 13'd320);

reg [13:0] SAD_H_ff, SAD_V_ff, SAD_D1_ff, SAD_D2_ff;
reg [11:0] med_H_ff_ff, med_V_ff_ff, med_D1_ff_ff, med_D2_ff_ff;
reg [11:0] P_ff_ff_ff;
reg        dpc_valid_ff_ff_ff;
reg        cond_H_ff, cond_V_ff, cond_D1_ff, cond_D2_ff;

always @(posedge clk) begin
    SAD_H_ff  <= SAD_H;  
    SAD_V_ff  <= SAD_V; 
    SAD_D1_ff <= SAD_D1; 
    SAD_D2_ff <= SAD_D2;
    
    med_H_ff_ff  <= med_H_ff;  
    med_V_ff_ff  <= med_V_ff; 
    med_D1_ff_ff <= med_D1_ff; 
    med_D2_ff_ff <= med_D2_ff;
    
    P_ff_ff_ff   <= P_ff_ff;
    dpc_valid_ff_ff_ff <= dpc_valid_ff_ff;
    
    cond_H_ff  <= cond_H_pre;
    cond_V_ff  <= cond_V_pre;
    cond_D1_ff <= cond_D1_pre;
    cond_D2_ff <= cond_D2_pre;
end

wire cmp_HV = (SAD_H_ff <= SAD_V_ff);
wire [13:0] min_SAD_HV = cmp_HV ? SAD_H_ff : SAD_V_ff;
wire [11:0] target_HV  = cmp_HV ? med_H_ff_ff : med_V_ff_ff;
wire        cond_HV    = cmp_HV ? cond_H_ff   : cond_V_ff; 

wire cmp_D1D2 = (SAD_D1_ff <= SAD_D2_ff);
wire [13:0] min_SAD_D1D2 = cmp_D1D2 ? SAD_D1_ff : SAD_D2_ff;
wire [11:0] target_D1D2  = cmp_D1D2 ? med_D1_ff_ff : med_D2_ff_ff;
wire        cond_D1D2    = cmp_D1D2 ? cond_D1_ff   : cond_D2_ff; 

wire cmp_final = (min_SAD_HV <= min_SAD_D1D2);
wire [11:0] Target = cmp_final ? target_HV : target_D1D2;
wire replace_cond  = cmp_final ? cond_HV   : cond_D1D2; 

wire [11:0] dpc_out = replace_cond ? Target : P_ff_ff_ff;

reg [11:0] dpc_fifo [0:235];

always @(posedge clk) begin
    for (i = 235; i > 0; i = i - 1) 
        dpc_fifo[i] <= dpc_fifo[i - 1];

    dpc_fifo[0] <= dpc_out;
end

// ============================ DEM ===================================
wire [1:0] dem_color_id = {dem_cnt_y[0], dem_cnt_x[0]};

wire [11:0] raw_C  = dpc_fifo[213];
wire [11:0] raw_E  = dpc_fifo[212];
wire [11:0] raw_W  = dpc_fifo[214];
wire [11:0] raw_S  = dpc_fifo[197];
wire [11:0] raw_SE = dpc_fifo[196];
wire [11:0] raw_SW = dpc_fifo[198];
wire [11:0] raw_N  = dpc_fifo[229];
wire [11:0] raw_NE = dpc_fifo[228];
wire [11:0] raw_NW = dpc_fifo[230];

wire is_top    = (dem_cnt_y == 0);
wire is_bottom = (dem_cnt_y == 15);
wire is_left   = (dem_cnt_x == 0);
wire is_right  = (dem_cnt_x == 15);

wire [11:0] C = raw_C;
wire [11:0] W = is_left  ? raw_E : raw_W;
wire [11:0] E = is_right ? raw_W : raw_E;
wire [11:0] N = is_top   ? raw_S : raw_N;
wire [11:0] S = is_bottom ? raw_N : raw_S;

wire [11:0] NW = (is_top & is_left)  ? raw_SE :
                 (is_top)            ? raw_SW :
                 (is_left)           ? raw_NE : raw_NW;

wire [11:0] NE = (is_top & is_right) ? raw_SW :
                 (is_top)            ? raw_SE :
                 (is_right)          ? raw_NW : raw_NE;

wire [11:0] SW = (is_bottom & is_left) ? raw_NE :
                 (is_bottom)           ? raw_NW :
                 (is_left)             ? raw_SE : raw_SW;

wire [11:0] SE = (is_bottom & is_right) ? raw_NW :
                 (is_bottom)            ? raw_NE :
                 (is_right)             ? raw_SW : raw_SE;

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
    dem_valid_ff <= (cs == DEM);
end

// ========================== CCM =====================================
wire signed [13:0] r_s = $signed({2'b0, r_dem_ff});
wire signed [13:0] g_s = $signed({2'b0, g_dem_ff});
wire signed [13:0] b_s = $signed({2'b0, b_dem_ff});

wire signed [14:0] gb_sum = g_s + b_s;
wire signed [14:0] rb_sum = r_s + b_s;
wire signed [14:0] rg_sum = r_s + g_s;

wire signed [26:0] r_1100 = ((r_s <<< 10) + (r_s <<< 6)) + ((r_s <<< 3) + (r_s <<< 2));
wire signed [26:0] g_1100 = ((g_s <<< 10) + (g_s <<< 6)) + ((g_s <<< 3) + (g_s <<< 2));
wire signed [26:0] b_1100 = ((b_s <<< 10) + (b_s <<< 6)) + ((b_s <<< 3) + (b_s <<< 2));

wire signed [26:0] gb_50 = ((gb_sum <<< 5) + (gb_sum <<< 4)) + (gb_sum <<< 1);
wire signed [26:0] rb_50 = ((rb_sum <<< 5) + (rb_sum <<< 4)) + (rb_sum <<< 1);
wire signed [26:0] rg_50 = ((rg_sum <<< 5) + (rg_sum <<< 4)) + (rg_sum <<< 1);

wire signed [26:0] r_raw = (r_1100 - gb_50) + 27'sd512;
wire signed [26:0] g_raw = (g_1100 - rb_50) + 27'sd512;
wire signed [26:0] b_raw = (b_1100 - rg_50) + 27'sd512;

wire r_is_neg = r_raw[26];
wire g_is_neg = g_raw[26];
wire b_is_neg = b_raw[26];

wire r_is_over = (|r_raw[25:22]) & ~r_is_neg;
wire g_is_over = (|g_raw[25:22]) & ~g_is_neg;
wire b_is_over = (|b_raw[25:22]) & ~b_is_neg;

wire [12:0] r_ccm = r_is_neg ? 13'd0 : (r_is_over ? 13'd4095 : {1'b0, r_raw[21:10]});
wire [12:0] g_ccm = g_is_neg ? 13'd0 : (g_is_over ? 13'd4095 : {1'b0, g_raw[21:10]});
wire [12:0] b_ccm = b_is_neg ? 13'd0 : (b_is_over ? 13'd4095 : {1'b0, b_raw[21:10]});

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        out_valid <= 0; 
        r_out <= 0; 
        g_out <= 0; 
        b_out <= 0;
    end
    else if (dem_valid_ff) begin 
        out_valid <= 1;
        r_out     <= r_ccm; 
        g_out     <= g_ccm;
        b_out     <= b_ccm;
    end
    else begin
        out_valid <= 0; 
        r_out <= 0; 
        g_out <= 0; 
        b_out <= 0;
    end
end

endmodule

module median (
    input  [11:0] A, B, C, D,
    output [11:0] median
);
    wire A_gt_B = (A > B);
    wire C_gt_D = (C > D);

    wire [11:0] max1 = A_gt_B ? A : B;
    wire [11:0] min1 = A_gt_B ? B : A;
    wire [11:0] max2 = C_gt_D ? C : D;
    wire [11:0] min2 = C_gt_D ? D : C;

    wire min1_gt_min2 = (min1 > min2);
    wire max1_lt_max2 = (max1 < max2);

    wire [12:0] sum_AB = {1'b0, A} + {1'b0, B};
    wire [12:0] sum_CD = {1'b0, C} + {1'b0, D};
    wire [12:0] sum_min2_max1 = {1'b0, min2} + {1'b0, max1};
    wire [12:0] sum_min1_max2 = {1'b0, min1} + {1'b0, max2};

    reg [12:0] safe_sum;
    always @(*) begin
        case ({min1_gt_min2, max1_lt_max2})
            2'b00: safe_sum = sum_CD;
            2'b11: safe_sum = sum_AB;
            2'b01: safe_sum = sum_min2_max1;
            2'b10: safe_sum = sum_min1_max2;
        endcase
    end

    assign median = safe_sum[12:1];
endmodule

// Timing-safe change 2:
// Keep the original one's-complement + sign convention.
// Original SAD contribution = val + sign = abs(A-B).
module sad (
    input  [11:0] A, B,
    output [11:0] val,
    output        sign
);
    wire A_lt_B = (A < B);

    assign sign = A_lt_B;
    assign val  = A_lt_B ? (B - A - 12'd1) : (A - B);
endmodule
