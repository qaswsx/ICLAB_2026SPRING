module DRCA (
    input  [3:0]  drc_sel,
    input  [18:0] shape0, 
    input  [18:0] shape1, 
    input  [18:0] shape2, 
    input  [18:0] shape3, 
    input  [18:0] shape4, 
    input  [18:0] shape5, 
    input  [18:0] shape6, 
    input  [18:0] shape7,
    input  [18:0] shape8, 
    input  [18:0] shape9, 
    input  [18:0] shape10, 
    input  [18:0] shape11, 
    input  [18:0] shape12, 
    input  [18:0] shape13, 
    input  [18:0] shape14, 
    input  [18:0] shape15,
    output reg [4:0] drc_out 
);

reg [18:0] shape_temp [0:15];

always @(*) begin
    shape_temp[0] = shape0;   
    shape_temp[1] = shape1;
    shape_temp[2] = shape2;   
    shape_temp[3] = shape3;
    shape_temp[4] = shape4;   
    shape_temp[5] = shape5;
    shape_temp[6] = shape6;   
    shape_temp[7] = shape7;
    shape_temp[8] = shape8;   
    shape_temp[9] = shape9;
    shape_temp[10]= shape10;  
    shape_temp[11]= shape11;
    shape_temp[12]= shape12;  
    shape_temp[13]= shape13;
    shape_temp[14]= shape14;  
    shape_temp[15]= shape15;
end

reg [2:0] layer_type [0:15];
reg [3:0] x1 [0:15], y1 [0:15], x2 [0:15], y2 [0:15];
reg [15:0] shape_active;

reg [7:0] layer_onehot;
reg [3:0] min_gt; 
wire spacing = drc_sel[0]; 

reg [15:0] range_x [0:15];
reg [15:0] range_y [0:15];

reg [15:0] rowbits [0:15];   
reg [15:0] colbits [0:15];   

reg [23:0] long_row  [0:15];   
reg [23:0] long_col  [0:15];   

reg [15:0] vx_row;
reg [15:0] vy_row;

reg ex_pm1, ex_p0, ex_p1, ex_p2, ex_p3, ex_p4;
reg ex_qm1, ex_q0, ex_q1, ex_q2, ex_q3, ex_q4;
reg cx1, cx2, cx3, cx4, mx1, mx2, mx3, mx4;

reg ey_pm1, ey_p0, ey_p1, ey_p2, ey_p3, ey_p4;
reg ey_qm1, ey_q0, ey_q1, ey_q2, ey_q3, ey_q4;
reg cy1, cy2, cy3, cy4, my1, my2, my3, my4;

reg [4:0] row_sum [0:15];

integer i, x, y; 

always @(*) begin

    layer_onehot = 0;
    case(drc_sel[3:1])
        0: begin layer_onehot[1] = 1'b1; min_gt = 4'd1; end 
        1: begin layer_onehot[2] = 1'b1; min_gt = drc_sel[0] ? 4'd1 : 4'd3; end 
        2: begin layer_onehot[3] = 1'b1; min_gt = 4'd1; end 
        3: begin layer_onehot[4] = 1'b1; min_gt = drc_sel[0] ? 4'd1 : 4'd3; end 
        4: begin layer_onehot[5] = 1'b1; min_gt = drc_sel[0] ? 4'd3 : 4'd7; end 
        5: begin layer_onehot[6] = 1'b1; min_gt = drc_sel[0] ? 4'd3 : 4'd7; end 
        6: begin layer_onehot[7] = 1'b1; min_gt = drc_sel[0] ? 4'd7 : 4'd15; end 
        default: begin layer_onehot[0] = 1'b0; min_gt = 4'd0; end
    endcase

    for (i = 0; i < 16; i = i + 1) begin
        layer_type[i] = shape_temp[i][18:16];
        x1[i] = shape_temp[i][15:12];
        y1[i] = shape_temp[i][11:8];
        x2[i] = shape_temp[i][7:4];
        y2[i] = shape_temp[i][3:0];
        shape_active[i] = layer_onehot[layer_type[i]];

        range_x[i] = (16'hFFFF << x1[i]) & ~(16'hFFFF << x2[i]);
        range_y[i] = (16'hFFFF << y1[i]) & ~(16'hFFFF << y2[i]);
    end

    for (x = 0; x < 16; x = x + 1) begin
        rowbits[x] = 0;
        for (y = 0; y < 16; y = y + 1) 
            if (shape_active[y] && range_y[y][x]) 
                rowbits[x] = rowbits[x] | range_x[y];
        long_row[x] = {4'b0, rowbits[x], 4'b0};
    end

    for (x = 0; x < 16; x = x + 1) begin
        colbits[x] = 0;
        for (y = 0; y < 16; y = y + 1) 
            colbits[x][y] = rowbits[y][x];
        long_col[x] = {4'b0, colbits[x], 4'b0};
    end
end

reg [23:0] prow, qrow;
reg [23:0] pcol, qcol;

always @(*) begin
    for (y = 0; y < 16; y = y + 1) begin

        vx_row = 0;
        vy_row = 0;

        for (x = 0; x < 16; x = x + 1) begin
            // rows for horizontal patterns
            prow = long_row[y];
            qrow = (!y) ? 0 : long_row[y - 1];

            // cols for vertical patterns
            pcol = long_col[x];
            qcol = (!x) ? 0 : long_col[x - 1];

            // ----------------- X direction -----------------
            ex_pm1 = prow[x + 3] ^ spacing;  ex_qm1 = qrow[x + 3] ^ spacing;
            ex_p0  = prow[x + 4] ^ spacing;  ex_q0  = qrow[x + 4] ^ spacing;
            ex_p1  = prow[x + 5] ^ spacing;  ex_q1  = qrow[x + 5] ^ spacing;
            ex_p2  = prow[x + 6] ^ spacing;  ex_q2  = qrow[x + 6] ^ spacing;
            ex_p3  = prow[x + 7] ^ spacing;  ex_q3  = qrow[x + 7] ^ spacing;
            ex_p4  = prow[x + 8] ^ spacing;  ex_q4  = qrow[x + 8] ^ spacing;

            cx1 = ~ex_pm1 & ex_p0 & ~ex_p1;                         mx1 = ~ex_qm1 & ex_q0 & ~ex_q1;
            cx2 = ~ex_pm1 & ex_p0 & ex_p1 & ~ex_p2;                 mx2 = ~ex_qm1 & ex_q0 & ex_q1 & ~ex_q2;
            cx3 = ~ex_pm1 & ex_p0 & ex_p1 & ex_p2 & ~ex_p3;         mx3 = ~ex_qm1 & ex_q0 & ex_q1 & ex_q2 & ~ex_q3;
            cx4 = ~ex_pm1 & ex_p0 & ex_p1 & ex_p2 & ex_p3 & ~ex_p4; mx4 = ~ex_qm1 & ex_q0 & ex_q1 & ex_q2 & ex_q3 & ~ex_q4;

            vx_row[x] = (min_gt[0] & cx1 & ~mx1) |
                        (min_gt[1] & cx2 & ~mx2) |
                        (min_gt[2] & cx3 & ~mx3) |
                        (min_gt[3] & cx4 & ~mx4);

            // ----------------- Y direction -----------------
            ey_pm1 = pcol[y + 3] ^ spacing;  ey_qm1 = qcol[y + 3] ^ spacing;
            ey_p0  = pcol[y + 4] ^ spacing;  ey_q0  = qcol[y + 4] ^ spacing;
            ey_p1  = pcol[y + 5] ^ spacing;  ey_q1  = qcol[y + 5] ^ spacing;
            ey_p2  = pcol[y + 6] ^ spacing;  ey_q2  = qcol[y + 6] ^ spacing;
            ey_p3  = pcol[y + 7] ^ spacing;  ey_q3  = qcol[y + 7] ^ spacing;
            ey_p4  = pcol[y + 8] ^ spacing;  ey_q4  = qcol[y + 8] ^ spacing;

            cy1 = ~ey_pm1 & ey_p0 & ~ey_p1;                         my1 = ~ey_qm1 & ey_q0 & ~ey_q1;
            cy2 = ~ey_pm1 & ey_p0 & ey_p1 & ~ey_p2;                 my2 = ~ey_qm1 & ey_q0 & ey_q1 & ~ey_q2;
            cy3 = ~ey_pm1 & ey_p0 & ey_p1 & ey_p2 & ~ey_p3;         my3 = ~ey_qm1 & ey_q0 & ey_q1 & ey_q2 & ~ey_q3;
            cy4 = ~ey_pm1 & ey_p0 & ey_p1 & ey_p2 & ey_p3 & ~ey_p4; my4 = ~ey_qm1 & ey_q0 & ey_q1 & ey_q2 & ey_q3 & ~ey_q4;

            vy_row[x] = (min_gt[0] & cy1 & ~my1) |
                        (min_gt[1] & cy2 & ~my2) |
                        (min_gt[2] & cy3 & ~my3) |
                        (min_gt[3] & cy4 & ~my4);
        end

        row_sum[y] = ( (vx_row[0] + vx_row[1])  + (vx_row[2] + vx_row[3]) ) +
                     ( (vx_row[4] + vx_row[5])  + (vx_row[6] + vx_row[7]) ) +
                     ( (vx_row[8] + vx_row[9])  + (vx_row[10]+ vx_row[11]) ) +
                     ( (vx_row[12]+ vx_row[13]) + (vx_row[14]+ vx_row[15]) ) +
                     ( (vy_row[0] + vy_row[1])  + (vy_row[2] + vy_row[3]) ) +
                     ( (vy_row[4] + vy_row[5])  + (vy_row[6] + vy_row[7]) ) +
                     ( (vy_row[8] + vy_row[9])  + (vy_row[10]+ vy_row[11]) ) +
                     ( (vy_row[12]+ vy_row[13]) + (vy_row[14]+ vy_row[15]) );

    end

    drc_out = ( (row_sum[0] + row_sum[1]) + (row_sum[2] + row_sum[3]) ) +
              ( (row_sum[4] + row_sum[5]) + (row_sum[6] + row_sum[7]) ) +
              ( (row_sum[8] + row_sum[9]) + (row_sum[10]+ row_sum[11]) ) +
              ( (row_sum[12]+ row_sum[13]) + (row_sum[14]+ row_sum[15]) );
end

endmodule
