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

integer i, j;

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
        DPC:   ns = (dpc_cnt_x == 13 && dpc_cnt_y == 13) ? DEM : DPC;
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

reg  [12:0] r_matrix  [0:5][0:5];
reg  [12:0] gr_matrix [0:5][0:5];
reg  [12:0] gb_matrix [0:5][0:5];
reg  [12:0] b_matrix  [0:5][0:5];

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        for (i = 0; i < 6; i = i + 1) 
        for (j = 0; j < 6; j = j + 1) begin
            r_matrix[i][j]  <= 0; 
            gr_matrix[i][j] <= 0;
            gb_matrix[i][j] <= 0; 
            b_matrix[i][j]  <= 0;
        end
    end
    else if (param_valid) begin
        case (next_gain)
            0: r_matrix[param_y_cnt][param_x_cnt]  <= param_gain;
            1: gr_matrix[param_y_cnt][param_x_cnt] <= param_gain;
            2: gb_matrix[param_y_cnt][param_x_cnt] <= param_gain;
            3: b_matrix[param_y_cnt][param_x_cnt]  <= param_gain;
        endcase
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

reg [12:0] c_row_0 [0:5];
reg [12:0] c_row_1 [0:5];

always @(*) begin
    case (color_id)
        2'b00: begin
            for(i = 0; i < 6; i = i + 1) begin 
                c_row_0[i] = r_matrix[y0][i];  
                c_row_1[i] = r_matrix[y0 + 1][i];  
            end
        end
        2'b01: begin
            for(i = 0; i < 6; i = i + 1) begin 
                c_row_0[i] = gr_matrix[y0][i]; 
                c_row_1[i] = gr_matrix[y0 + 1][i]; 
            end
        end
        2'b10: begin
            for(i = 0; i < 6; i = i + 1) begin 
                c_row_0[i] = gb_matrix[y0][i]; 
                c_row_1[i] = gb_matrix[y0 + 1][i]; 
            end
        end
        2'b11: begin
            for(i = 0; i < 6; i = i + 1) begin 
                c_row_0[i] = b_matrix[y0][i];  
                c_row_1[i] = b_matrix[y0 + 1][i];  
            end
        end
    endcase
end

reg [12:0] g00, g01, g10, g11;
reg [13:0] g0110, g0011, g0010, g0001;

always @(*) begin
    g00 = c_row_0[x0];
    g01 = c_row_0[x0 + 1];
    g10 = c_row_1[x0];
    g11 = c_row_1[x0 + 1];

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

wire [25:0] p_sum = gxy_ff * i_blc_ff_ff;
wire [16:0] p_sum_round = p_sum[25:10] + p_sum[9];

wire p_is_over = |p_sum_round[16:12];
wire [11:0] pp_xy = p_is_over ? 4095 : p_sum_round[11:0];

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

// ====================== DPC  =====================

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

wire [11:0] err_H0, err_H1, err_H2, err_H3;
wire [11:0] err_V0, err_V1, err_V2, err_V3;
wire [11:0] err_D1_0, err_D1_1, err_D1_2, err_D1_3;
wire [11:0] err_D2_0, err_D2_1, err_D2_2, err_D2_3;

sad sad_h0 (.A(H_ff_ff[0]), .B(med_H_ff), .abs(err_H0)); 
sad sad_h1 (.A(H_ff_ff[1]), .B(med_H_ff), .abs(err_H1));
sad sad_h2 (.A(H_ff_ff[2]), .B(med_H_ff), .abs(err_H2)); 
sad sad_h3 (.A(H_ff_ff[3]), .B(med_H_ff), .abs(err_H3));
wire [13:0] SAD_H = err_H0 + err_H1 + err_H2 + err_H3;

sad sad_v0 (.A(V_ff_ff[0]), .B(med_V_ff), .abs(err_V0)); 
sad sad_v1 (.A(V_ff_ff[1]), .B(med_V_ff), .abs(err_V1));
sad sad_v2 (.A(V_ff_ff[2]), .B(med_V_ff), .abs(err_V2)); 
sad sad_v3 (.A(V_ff_ff[3]), .B(med_V_ff), .abs(err_V3));
wire [13:0] SAD_V = err_V0 + err_V1 + err_V2 + err_V3;

sad sad_d1_0 (.A(D1_ff_ff[0]), .B(med_D1_ff), .abs(err_D1_0)); 
sad sad_d1_1 (.A(D1_ff_ff[1]), .B(med_D1_ff), .abs(err_D1_1));
sad sad_d1_2 (.A(D1_ff_ff[2]), .B(med_D1_ff), .abs(err_D1_2)); 
sad sad_d1_3 (.A(D1_ff_ff[3]), .B(med_D1_ff), .abs(err_D1_3));
wire [13:0] SAD_D1 = err_D1_0 + err_D1_1 + err_D1_2 + err_D1_3;

sad sad_d2_0 (.A(D2_ff_ff[0]), .B(med_D2_ff), .abs(err_D2_0)); 
sad sad_d2_1 (.A(D2_ff_ff[1]), .B(med_D2_ff), .abs(err_D2_1));
sad sad_d2_2 (.A(D2_ff_ff[2]), .B(med_D2_ff), .abs(err_D2_2)); 
sad sad_d2_3 (.A(D2_ff_ff[3]), .B(med_D2_ff), .abs(err_D2_3));
wire [13:0] SAD_D2 = err_D2_0 + err_D2_1 + err_D2_2 + err_D2_3;

// // ====================== DPC =====================

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
            dem_cnt_y <= 
            dem_cnt_y + 1;
        end
        else 
            dem_cnt_x <= dem_cnt_x + 1;
    end
    else 
        dem_cnt <= 0;
end

reg [13:0] SAD_H_ff, SAD_V_ff, SAD_D1_ff, SAD_D2_ff;
reg [11:0] med_H_ff_ff, med_V_ff_ff, med_D1_ff_ff, med_D2_ff_ff;
reg [11:0] P_ff_ff_ff;
reg        dpc_valid_ff_ff_ff;

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
end

wire cmp_HV = (SAD_H_ff <= SAD_V_ff);
wire [13:0] min_SAD_HV = cmp_HV ? SAD_H_ff : SAD_V_ff;
wire [11:0] target_HV  = cmp_HV ? med_H_ff_ff : med_V_ff_ff;

wire cmp_D1D2 = (SAD_D1_ff <= SAD_D2_ff);
wire [13:0] min_SAD_D1D2 = cmp_D1D2 ? SAD_D1_ff : SAD_D2_ff;
wire [11:0] target_D1D2  = cmp_D1D2 ? med_D1_ff_ff : med_D2_ff_ff;

wire cmp_final = (min_SAD_HV <= min_SAD_D1D2);
wire [11:0] Target = cmp_final ? target_HV : target_D1D2;

wire replace_cond = ({1'b0, P_ff_ff_ff} > {1'b0, Target} + 320) || 
                    ({1'b0, Target} > {1'b0, P_ff_ff_ff} + 320);

wire [11:0] dpc_out = replace_cond ? Target : P_ff_ff_ff;

reg [11:0] dpc_fifo [0:235];

always @(posedge clk) begin
    for (i = 235; i > 0; i = i - 1) 
        dpc_fifo[i] <= dpc_fifo[i - 1];

    dpc_fifo[0] <= dpc_out;
end

// ============================ dem ===================================

wire [1:0] dem_color_id = {dem_cnt_y[0], dem_cnt_x[0]};

wire [11:0] raw_C  = dpc_fifo[218];
wire [11:0] raw_E  = dpc_fifo[217];
wire [11:0] raw_W  = dpc_fifo[219];
wire [11:0] raw_S  = dpc_fifo[202];
wire [11:0] raw_SE = dpc_fifo[201];
wire [11:0] raw_SW = dpc_fifo[203];
wire [11:0] raw_N  = dpc_fifo[234];
wire [11:0] raw_NE = dpc_fifo[233];
wire [11:0] raw_NW = dpc_fifo[235];

wire is_top    = (dem_cnt_y == 0);
wire is_bottom = (dem_cnt_y == 15);
wire is_left   = (dem_cnt_x == 0);
wire is_right  = (dem_cnt_x == 15);

wire [11:0] C = raw_C;
wire [11:0] W = is_left   ? raw_E : raw_W;
wire [11:0] E = is_right  ? raw_W : raw_E;
wire [11:0] N = is_top    ? raw_S : raw_N;
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

localparam signed [14:0] C_err = 15'sd1150; 
localparam signed [14:0] C_SUB  = -15'sd50;

wire signed [15:0] rgb_sum = r_s + g_s + b_s;
wire signed [26:0] shared_sub_ffult = rgb_sum * C_SUB;

wire signed [26:0] r_raw = (r_s * C_err) + shared_sub_ffult + 27'sd512;
wire signed [26:0] g_raw = (g_s * C_err) + shared_sub_ffult + 27'sd512;
wire signed [26:0] b_raw = (b_s * C_err) + shared_sub_ffult + 27'sd512;

wire signed [26:0] r_shift = r_raw >>> 10;
wire signed [26:0] g_shift = g_raw >>> 10;
wire signed [26:0] b_shift = b_raw >>> 10;

wire r_is_neg = r_shift[26];
wire g_is_neg = g_shift[26];
wire b_is_neg = b_shift[26];

wire [26:0] r_shift_u = $unsigned(r_shift);
wire [26:0] g_shift_u = $unsigned(g_shift);
wire [26:0] b_shift_u = $unsigned(b_shift);

wire r_is_over = (|r_shift_u[25:12]) & ~r_is_neg;
wire g_is_over = (|g_shift_u[25:12]) & ~g_is_neg;
wire b_is_over = (|b_shift_u[25:12]) & ~b_is_neg;

wire [12:0] r_ccm = r_is_neg ? 0 : (r_is_over ? 4095 : r_shift_u[12:0]);
wire [12:0] g_ccm = g_is_neg ? 0 : (g_is_over ? 4095 : g_shift_u[12:0]);
wire [12:0] b_ccm = b_is_neg ? 0 : (b_is_over ? 4095 : b_shift_u[12:0]);

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
    wire [11:0] max1, min1, max2, min2;
    assign {max1, min1} = (A > B) ? {A, B} : {B, A};
    assign {max2, min2} = (C > D) ? {C, D} : {D, C};

    wire [11:0] mid_low  = (min1 > min2) ? min1 : min2;
    wire [11:0] mid_high = (max1 < max2) ? max1 : max2;

    wire [12:0] safe_sum = {1'b0, mid_low} + {1'b0, mid_high};
    assign median = safe_sum[12:1];

endmodule

module sad (
    input  [11:0] A, B,
    output [11:0] abs
);
    wire [12:0] err = {1'b0, A} - {1'b0, B}; 
    wire sign = err[12]; 
    assign abs = (err[11:0] ^ {12{sign}}) + sign;
endmodule