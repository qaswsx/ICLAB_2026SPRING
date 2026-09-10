//synopsys translate_off
`include "SORT_IP.v"
//synopsys translate_on

module HT(
    input clk,
    input rst_n,
    input in_valid,
    input [2:0] in_weight, 
    input out_mode,
    output reg out_valid, 
    output reg out_code
);

localparam char_A = 4'd15, char_B = 4'd14, char_C = 4'd13, char_E = 4'd12;
localparam char_I = 4'd11, char_L = 4'd10, char_O = 4'd9,  char_V = 4'd8;

reg [3:0] cnt;
reg out_mode_temp;
reg [2:0] weight_ff [0:7]; 

always@(posedge clk or negedge rst_n) begin
    if(~rst_n) cnt <= 0;
    else if(in_valid) cnt <= cnt + 1;
    else if(out_valid) cnt <= cnt; 
    else cnt <= 0;
end

always @(posedge clk) begin
    if (in_valid) begin
        weight_ff[cnt] <= in_weight; 
        if (cnt == 0) out_mode_temp <= out_mode;
    end
end

// ===============================================================
// Stage 0.A 
// ===============================================================
wire [27:0] char_in_7 = {char_A, char_B, char_C, char_E, char_I, char_L, char_O};
wire [34:0] weight_in_7 = {
    2'b00, weight_ff[0], 2'b00, weight_ff[1], 
    2'b00, weight_ff[2], 2'b00, weight_ff[3],
    2'b00, weight_ff[4], 2'b00, weight_ff[5], 
    2'b00, weight_ff[6]
};

wire [27:0] char_out_7;

SORT_IP #(.IP_WIDTH(7)) sort_inst_7 (
    .IN_character(char_in_7), 
    .IN_weight(weight_in_7), 
    .OUT_character(char_out_7)
);

reg [27:0] sorted_7_ff;
reg [2:0]  weight_V_ff; 

always @(posedge clk) begin
    if (cnt == 7) begin
        sorted_7_ff <= char_out_7; 
        weight_V_ff <= in_weight;  
    end
end

// ===============================================================
// Stage 0.B 
// ===============================================================
wire [3:0] s_id [0:6];
assign s_id[6] = sorted_7_ff[27:24]; assign s_id[5] = sorted_7_ff[23:20];
assign s_id[4] = sorted_7_ff[19:16]; assign s_id[3] = sorted_7_ff[15:12];
assign s_id[2] = sorted_7_ff[11:8];  assign s_id[1] = sorted_7_ff[7:4];   
assign s_id[0] = sorted_7_ff[3:0];   

wire [2:0] s_w [0:6];
GET_W_MOD gw0 (.id(s_id[0]), .w0(weight_ff[0]), .w1(weight_ff[1]), .w2(weight_ff[2]), .w3(weight_ff[3]), .w4(weight_ff[4]), .w5(weight_ff[5]), .w6(weight_ff[6]), .out_w(s_w[0]));
GET_W_MOD gw1 (.id(s_id[1]), .w0(weight_ff[0]), .w1(weight_ff[1]), .w2(weight_ff[2]), .w3(weight_ff[3]), .w4(weight_ff[4]), .w5(weight_ff[5]), .w6(weight_ff[6]), .out_w(s_w[1]));
GET_W_MOD gw2 (.id(s_id[2]), .w0(weight_ff[0]), .w1(weight_ff[1]), .w2(weight_ff[2]), .w3(weight_ff[3]), .w4(weight_ff[4]), .w5(weight_ff[5]), .w6(weight_ff[6]), .out_w(s_w[2]));
GET_W_MOD gw3 (.id(s_id[3]), .w0(weight_ff[0]), .w1(weight_ff[1]), .w2(weight_ff[2]), .w3(weight_ff[3]), .w4(weight_ff[4]), .w5(weight_ff[5]), .w6(weight_ff[6]), .out_w(s_w[3]));
GET_W_MOD gw4 (.id(s_id[4]), .w0(weight_ff[0]), .w1(weight_ff[1]), .w2(weight_ff[2]), .w3(weight_ff[3]), .w4(weight_ff[4]), .w5(weight_ff[5]), .w6(weight_ff[6]), .out_w(s_w[4]));
GET_W_MOD gw5 (.id(s_id[5]), .w0(weight_ff[0]), .w1(weight_ff[1]), .w2(weight_ff[2]), .w3(weight_ff[3]), .w4(weight_ff[4]), .w5(weight_ff[5]), .w6(weight_ff[6]), .out_w(s_w[5]));
GET_W_MOD gw6 (.id(s_id[6]), .w0(weight_ff[0]), .w1(weight_ff[1]), .w2(weight_ff[2]), .w3(weight_ff[3]), .w4(weight_ff[4]), .w5(weight_ff[5]), .w6(weight_ff[6]), .out_w(s_w[6]));

wire [9:0] node_7 [0:6];
assign node_7[0] = {3'd0, s_w[0], s_id[0]}; assign node_7[1] = {3'd0, s_w[1], s_id[1]};
assign node_7[2] = {3'd0, s_w[2], s_id[2]}; assign node_7[3] = {3'd0, s_w[3], s_id[3]};
assign node_7[4] = {3'd0, s_w[4], s_id[4]}; assign node_7[5] = {3'd0, s_w[5], s_id[5]};
assign node_7[6] = {3'd0, s_w[6], s_id[6]};

wire [9:0] v_node = {3'd0, weight_V_ff, char_V};

wire T [0:6];
assign T[0] = (weight_V_ff <= s_w[0]); assign T[1] = (weight_V_ff <= s_w[1]);
assign T[2] = (weight_V_ff <= s_w[2]); assign T[3] = (weight_V_ff <= s_w[3]);
assign T[4] = (weight_V_ff <= s_w[4]); assign T[5] = (weight_V_ff <= s_w[5]);
assign T[6] = (weight_V_ff <= s_w[6]);

wire [9:0] list0 [0:7];
assign list0[0] = T[0] ? v_node : node_7[0];
assign list0[1] = T[0] ? node_7[0] : (T[1] ? v_node : node_7[1]);
assign list0[2] = T[1] ? node_7[1] : (T[2] ? v_node : node_7[2]);
assign list0[3] = T[2] ? node_7[2] : (T[3] ? v_node : node_7[3]);
assign list0[4] = T[3] ? node_7[3] : (T[4] ? v_node : node_7[4]);
assign list0[5] = T[4] ? node_7[4] : (T[5] ? v_node : node_7[5]);
assign list0[6] = T[5] ? node_7[5] : (T[6] ? v_node : node_7[6]);
assign list0[7] = T[6] ? node_7[6] : v_node;

wire [3:0] left_root  [1:7];
wire [3:0] right_root [1:7];

// ===============================================================
// Stage 1
// ===============================================================
wire [9:0] merge1 = {list0[0][9:4] + list0[1][9:4], 4'd7};
assign left_root[7]  = list0[1][3:0]; assign right_root[7] = list0[0][3:0]; 

wire c1_2 = (merge1 <= list0[2]); wire c1_3 = (merge1 <= list0[3]);
wire c1_4 = (merge1 <= list0[4]); wire c1_5 = (merge1 <= list0[5]);
wire c1_6 = (merge1 <= list0[6]); wire c1_7 = (merge1 <= list0[7]);

wire [9:0] list1 [0:6];
assign list1[0] = c1_2 ? merge1 : list0[2];
assign list1[1] = c1_2 ? list0[2] : c1_3 ? merge1 : list0[3];
assign list1[2] = c1_3 ? list0[3] : c1_4 ? merge1 : list0[4];
assign list1[3] = c1_4 ? list0[4] : c1_5 ? merge1 : list0[5];
assign list1[4] = c1_5 ? list0[5] : c1_6 ? merge1 : list0[6];
assign list1[5] = c1_6 ? list0[6] : c1_7 ? merge1 : list0[7];
assign list1[6] = c1_7 ? list0[7] : merge1;

// ===============================================================
// Stage 2
// ===============================================================
wire [5:0] s2_opt_A = merge1[9:4] + list0[2][9:4];
wire [5:0] s2_opt_B = list0[2][9:4] + list0[3][9:4];
wire [9:0] merge2 = {c1_3 ? s2_opt_A : s2_opt_B, 4'd6};
assign left_root[6]  = list1[1][3:0]; assign right_root[6] = list1[0][3:0];

wire c2_2 = (merge2 <= list1[2]); wire c2_3 = (merge2 <= list1[3]);
wire c2_4 = (merge2 <= list1[4]); wire c2_5 = (merge2 <= list1[5]);
wire c2_6 = (merge2 <= list1[6]);

wire [9:0] list2 [0:5];
assign list2[0] = c2_2 ? merge2 : list1[2];
assign list2[1] = c2_2 ? list1[2] : c2_3 ? merge2 : list1[3];
assign list2[2] = c2_3 ? list1[3] : c2_4 ? merge2 : list1[4];
assign list2[3] = c2_4 ? list1[4] : c2_5 ? merge2 : list1[5];
assign list2[4] = c2_5 ? list1[5] : c2_6 ? merge2 : list1[6];
assign list2[5] = c2_6 ? list1[6] : merge2;

// ===============================================================
// Stage 3
// ===============================================================
wire [5:0] s3_opt_A = merge2[9:4] + list1[2][9:4];
wire [5:0] s3_opt_B = list1[2][9:4] + list1[3][9:4];
wire [9:0] merge3 = {c2_3 ? s3_opt_A : s3_opt_B, 4'd5};
assign left_root[5]  = list2[1][3:0]; assign right_root[5] = list2[0][3:0];

wire c3_2 = (merge3 <= list2[2]); wire c3_3 = (merge3 <= list2[3]);
wire c3_4 = (merge3 <= list2[4]); wire c3_5 = (merge3 <= list2[5]);

wire [9:0] list3 [0:4];
assign list3[0] = c3_2 ? merge3 : list2[2];
assign list3[1] = c3_2 ? list2[2] : c3_3 ? merge3 : list2[3];
assign list3[2] = c3_3 ? list2[3] : c3_4 ? merge3 : list2[4];
assign list3[3] = c3_4 ? list2[4] : c3_5 ? merge3 : list2[5];
assign list3[4] = c3_5 ? list2[5] : merge3;

// ===============================================================
// Stage 4
// ===============================================================
wire [5:0] s4_opt_A = merge3[9:4] + list2[2][9:4];
wire [5:0] s4_opt_B = list2[2][9:4] + list2[3][9:4];
wire [9:0] merge4 = {c3_3 ? s4_opt_A : s4_opt_B, 4'd4};
assign left_root[4]  = list3[1][3:0]; assign right_root[4] = list3[0][3:0];

wire c4_2 = (merge4 <= list3[2]); wire c4_3 = (merge4 <= list3[3]);
wire c4_4 = (merge4 <= list3[4]);

wire [9:0] list4 [0:3];
assign list4[0] = c4_2 ? merge4 : list3[2];
assign list4[1] = c4_2 ? list3[2] : c4_3 ? merge4 : list3[3];
assign list4[2] = c4_3 ? list3[3] : c4_4 ? merge4 : list3[4];
assign list4[3] = c4_4 ? list3[4] : merge4;

// ===============================================================
// Stage 5
// ===============================================================
wire [5:0] s5_opt_A = merge4[9:4] + list3[2][9:4];
wire [5:0] s5_opt_B = list3[2][9:4] + list3[3][9:4];
wire [9:0] merge5 = {c4_3 ? s5_opt_A : s5_opt_B, 4'd3};
assign left_root[3]  = list4[1][3:0]; assign right_root[3] = list4[0][3:0];

wire c5_2 = (merge5 <= list4[2]); wire c5_3 = (merge5 <= list4[3]);

wire [9:0] list5 [0:2];
assign list5[0] = c5_2 ? merge5 : list4[2];
assign list5[1] = c5_2 ? list4[2] : c5_3 ? merge5 : list4[3];
assign list5[2] = c5_3 ? list4[3] : merge5;

// ===============================================================
// Stage 6
// ===============================================================
wire [5:0] s6_opt_A = merge5[9:4] + list4[2][9:4];
wire [5:0] s6_opt_B = list4[2][9:4] + list4[3][9:4];
wire [9:0] merge6 = {c5_3 ? s6_opt_A : s6_opt_B, 4'd2};
assign left_root[2]  = list5[1][3:0]; assign right_root[2] = list5[0][3:0];

wire c6_2 = (merge6 <= list5[2]);
wire [9:0] list6 [0:1];
assign list6[0] = c6_2 ? merge6 : list5[2];
assign list6[1] = c6_2 ? list5[2] : merge6;

// ===============================================================
// Stage 7
// ===============================================================
assign left_root[1]  = list6[1][3:0]; assign right_root[1] = list6[0][3:0];

// ===============================================================
// Target Sequences
// ===============================================================
wire [3:0] t_id [1:5];
assign t_id[1] = 4'd11;                                 
assign t_id[2] = (~out_mode_temp) ? 4'd10 : 4'd13;      
assign t_id[3] = (~out_mode_temp) ? 4'd9  : 4'd10;      
assign t_id[4] = (~out_mode_temp) ? 4'd8  : 4'd15;      
assign t_id[5] = (~out_mode_temp) ? 4'd12 : 4'd14;      

reg [2:0] sym_idx;

wire [3:0] trace_id = (sym_idx >= 1 && sym_idx <= 5) ? t_id[sym_idx] : 4'd0;

reg [6:0] t_code;
reg [2:0] t_len;
reg [3:0] temp_id;
integer ti;

always @(*) begin
    temp_id = trace_id;
    t_code = 7'd0;
    t_len = 3'd0;
    
    for (ti = 7; ti >= 1; ti = ti - 1) begin
        if (temp_id == left_root[ti]) begin
            t_code = {1'b0, t_code[6:1]};
            t_len = t_len + 1;
            temp_id = ti[3:0];
        end 
        else if (temp_id == right_root[ti]) begin
            t_code = {1'b1, t_code[6:1]};
            t_len = t_len + 1;
            temp_id = ti[3:0];
        end
    end
end

// ===============================================================
// Output 
// ===============================================================
reg [6:0] cur_code;
reg [2:0] cur_len;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        out_valid <= 0; 
        out_code  <= 0;
        // cur_code  <= 0;  
        // cur_len   <= 0; 
        sym_idx   <= 1; 
    end
    else begin
        if (cnt == 8 && !out_valid) begin
            out_valid <= 1;
            out_code  <= t_code[6];       
            cur_code  <= t_code << 1;     
            cur_len   <= t_len - 1;
            
            sym_idx   <= 2;  
        end 
        else if (out_valid) begin
            if (cur_len > 0) begin
                out_code <= cur_code[6];
                cur_code <= cur_code << 1;
                cur_len  <= cur_len - 1;
            end 
            else if (sym_idx <= 5) begin
                out_code <= t_code[6]; 
                cur_code <= t_code << 1; 
                cur_len  <= t_len - 1; 

                sym_idx  <= sym_idx + 1;
            end
            else begin
                out_valid <= 0; 
                out_code  <= 0; 
                sym_idx   <= 1; 
            end
        end
    end
end

endmodule

module GET_W_MOD (
    input      [3:0] id,
    input      [2:0] w0, w1, w2, w3, w4, w5, w6,
    output reg [2:0] out_w
);
    always @(*) begin
        case(id)
            4'd15: out_w = w0; 
            4'd14: out_w = w1; 
            4'd13: out_w = w2; 
            4'd12: out_w = w3; 
            4'd11: out_w = w4; 
            4'd10: out_w = w5;  
            4'd9:  out_w = w6;   
            default: out_w = 3'd0;
        endcase
    end
endmodule