module DM(
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
output reg  o_valid;
output reg [7:0] o_data;

integer idx_w, idx_s, idx_q, idx_qkv, idx_out, idx_ffn, idx_a;

parameter S_IDLE         = 4'd0;
parameter S_LOAD         = 4'd1;
parameter S_DOWN_CONV    = 4'd2;
parameter S_TRANS_WAIT   = 4'd3; 
parameter S_TRANS_QKV    = 4'd4; 
parameter S_ATTEN_WAIT   = 4'd5; 
parameter S_ATTEN_Q      = 4'd6; 
parameter S_ATTEN_KV     = 4'd7; 
parameter S_FFN_WAIT     = 4'd8; 
parameter S_FFN          = 4'd9; 
parameter S_UP_CONV_WAIT = 4'd10; 
parameter S_UP_CONV      = 4'd11; 
parameter S_INTER_PRE    = 4'd12; 
parameter S_INTER_CALC   = 4'd13; 
parameter S_ITER_SWITCH  = 4'd14; 

reg [3:0] cs, ns; 

wire [255:0] mac_outs;     
wire [127:0] ds_sram_dout; 
wire [127:0] k_sram_dout, v_sram_dout;
wire [63:0]  img_sram_dout;
wire [63:0]  w_sram_dout; 

reg [63:0] w_sram_dout_reg;
always @(posedge clk) begin
    w_sram_dout_reg <= w_sram_dout;
end

reg [12:0] img_total_cnt;
reg        is_img_recv_done;
wire       down_done;
wire       qkv_done;
reg [4:0]  phase_step;   
reg [8:0]  kv_step;
reg [8:0]  atten_q_cnt;
reg [7:0]  ffn_pt;
reg        up_valid_d4;
reg [3:0]  up_step_d4;
reg        up_valid_d5;
reg [3:0]  up_step_d5;

reg [4:0]  inter_load_cnt;
reg [12:0] inter_calc_cnt;
reg [1:0]  switch_cnt;
reg [2:0]  curr_iter;
reg [2:0]  i_iter_reg;
wire       is_last_iter = (curr_iter == i_iter_reg);

reg [7:0] up_out_cnt; 

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) cs <= S_IDLE;
    else cs <= ns;
end

always @(*) begin
    ns = cs;
    case (cs)
        S_IDLE: if (i_valid) ns = S_LOAD;
        S_LOAD: if (img_total_cnt > 13'd71 || is_img_recv_done) ns = S_DOWN_CONV;
        S_DOWN_CONV: if (down_done) ns = S_TRANS_WAIT;
        S_TRANS_WAIT: ns = S_TRANS_QKV; 
        S_TRANS_QKV: if (qkv_done) ns = S_ATTEN_WAIT; 
        S_ATTEN_WAIT: ns = S_ATTEN_Q; 
        S_ATTEN_Q: if (phase_step == 21) ns = S_ATTEN_KV;  
        S_ATTEN_KV: if (kv_step == 262) begin              
                        if (atten_q_cnt == 255) ns = S_FFN_WAIT; 
                        else ns = S_ATTEN_Q; 
                    end
        S_FFN_WAIT: ns = S_FFN; 
        S_FFN: if (ffn_pt == 255 && phase_step == 21) ns = S_UP_CONV_WAIT; 
        S_UP_CONV_WAIT: ns = S_UP_CONV; 
        S_UP_CONV: if (up_valid_d5 && up_step_d5 == 8 && up_out_cnt == 8'd255) ns = S_INTER_PRE; 
        S_INTER_PRE: if (inter_load_cnt == 4) ns = S_INTER_CALC; 
        S_INTER_CALC: if (inter_calc_cnt == 4095) ns = S_ITER_SWITCH; 
        S_ITER_SWITCH: if (switch_cnt == 1) begin
                           if (is_last_iter) ns = S_IDLE;
                           else ns = S_DOWN_CONV;
                       end
    endcase
end

// ===============================================================
// Data Loading (Weight & Image)
// ===============================================================
reg [1:0] i_mode_reg;
reg [10:0] weight_cnt; 
reg is_weight_recv_done;

wire is_down_w = (weight_cnt <  11'd144);
wire is_qkv_w  = (weight_cnt >= 11'd144  && weight_cnt < 11'd1168);
wire is_up_w   = (weight_cnt >= 11'd1168 && weight_cnt < 11'd1312);
wire is_first_img_valid = (i_valid && is_weight_recv_done && img_total_cnt == 13'd0);
wire clear_img = (cs == S_IDLE && i_valid && is_img_recv_done);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        weight_cnt <= 0; is_weight_recv_done <= 0;
    end else if (i_valid && !is_weight_recv_done) begin 
        if (weight_cnt == 11'd1311) is_weight_recv_done <= 1'b1;
        weight_cnt <= weight_cnt + 1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        i_iter_reg <= 0; i_mode_reg <= 0;
    end else if (is_first_img_valid || clear_img) begin 
        i_iter_reg <= i_iter; 
        i_mode_reg <= i_mode; 
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) curr_iter <= 0;
    else if (is_first_img_valid || clear_img) curr_iter <= 1;
    else if (cs == S_ITER_SWITCH && switch_cnt == 1 && curr_iter != i_iter_reg) curr_iter <= curr_iter + 1;
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) switch_cnt <= 0;
    else if (cs == S_ITER_SWITCH) switch_cnt <= switch_cnt + 1;
    else switch_cnt <= 0;
end

reg [63:0] assemble_buf [0:8];
reg [3:0]  assemble_k_cnt, assemble_ch_cnt;
wire [5:0] assemble_shift = {2'd0, assemble_ch_cnt} << 2; 

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        assemble_k_cnt <= 0; assemble_ch_cnt <= 0;
    end else if (i_valid && !is_weight_recv_done) begin
        if (is_down_w || is_up_w) begin
            if (assemble_k_cnt == 4'd8) begin
                assemble_k_cnt <= 0; assemble_ch_cnt <= assemble_ch_cnt + 1;
            end else assemble_k_cnt <= assemble_k_cnt + 1;
        end else begin
            assemble_k_cnt <= 0; assemble_ch_cnt <= 0;
        end
    end
end

always @(posedge clk) begin
    if (i_valid && !is_weight_recv_done && (is_down_w || is_up_w)) begin
        assemble_buf[assemble_k_cnt] <= (assemble_buf[assemble_k_cnt] & ~(64'hF << assemble_shift)) | ({60'd0, i_weight} << assemble_shift);
    end
end

wire dump_trigger = (i_valid && !is_weight_recv_done && 
                     (is_down_w || is_up_w) && 
                     assemble_k_cnt == 4'd8 && 
                     assemble_ch_cnt == 4'd15);

reg is_dumping;
reg [3:0] dump_cnt;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        is_dumping <= 1'b0;
        dump_cnt   <= 4'd0;
    end else begin
        if (dump_trigger) is_dumping <= 1'b1;
        else if (dump_cnt == 4'd8) is_dumping <= 1'b0;

        if (is_dumping) dump_cnt <= dump_cnt + 4'd1;
        else dump_cnt <= 4'd0;
    end
end

wire is_down_dumping = is_dumping && !weight_cnt[10];
wire is_up_dumping   = is_dumping && weight_cnt[10];

wire is_receiving_image = (i_valid && is_weight_recv_done && !is_img_recv_done);
reg [63:0] img_pack_buf;        
reg [2:0]  img_pack_cnt;        
reg [8:0]  img_sram_write_addr; 

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        img_total_cnt <= 13'd0; is_img_recv_done <= 1'b0;
        img_pack_buf <= 64'd0; img_pack_cnt <= 3'd0; img_sram_write_addr <= 9'd0;
    end else if (clear_img) begin
        img_total_cnt <= 13'd1; 
        is_img_recv_done <= 1'b0;
        img_pack_buf <= {i_data, 56'd0}; 
        img_pack_cnt <= 3'd1;
        img_sram_write_addr <= 9'd0;
    end else if (is_receiving_image) begin
        img_pack_buf <= {i_data, img_pack_buf[63:8]};
        img_total_cnt <= img_total_cnt + 13'd1;
        if (img_total_cnt == 13'd4095) is_img_recv_done <= 1'b1;
        if (img_pack_cnt == 3'd7) begin
            img_pack_cnt <= 3'd0; img_sram_write_addr <= img_sram_write_addr + 9'd1;
        end else img_pack_cnt <= img_pack_cnt + 3'd1;
    end
end

// ===============================================================
// Down Sampling
// ===============================================================
reg [3:0] cnt_x, cnt_y, cnt_step; 

wire [12:0] req_cnt = {1'b0, cnt_y[3:0], 2'b01, cnt_x[3:1], 3'b111}; 

wire safe_to_compute = is_img_recv_done || (img_total_cnt > req_cnt); 

wire denoise_write_en; 
wire stall_pipe = (is_receiving_image && img_pack_cnt == 3'd7) || denoise_write_en || !safe_to_compute;
wire step_is_valid = (cs == S_DOWN_CONV && !stall_pipe);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        cnt_x <= 0; cnt_y <= 0; cnt_step <= 0;
    end else if (cs == S_LOAD || cs == S_ITER_SWITCH) begin
        cnt_x <= 0; cnt_y <= 0; cnt_step <= 0;
    end else if (step_is_valid) begin
        if (cnt_step == 12) begin 
            cnt_step <= 0;
            if (cnt_x == 15) begin
                cnt_x <= 0; cnt_y <= cnt_y + 1;
            end else cnt_x <= cnt_x + 1;
        end else cnt_step <= cnt_step + 1;
    end
end

reg [1:0] offset_x;
reg [1:0] offset_y;

always @(*) begin
    case (cnt_step)
        4'd0: begin offset_x = 2'd0; offset_y = 2'd0; end
        4'd1: begin offset_x = 2'd1; offset_y = 2'd0; end
        4'd2: begin offset_x = 2'd2; offset_y = 2'd0; end
        4'd3: begin offset_x = 2'd0; offset_y = 2'd1; end
        4'd4: begin offset_x = 2'd1; offset_y = 2'd1; end
        4'd5: begin offset_x = 2'd2; offset_y = 2'd1; end
        4'd6: begin offset_x = 2'd0; offset_y = 2'd2; end
        4'd7: begin offset_x = 2'd1; offset_y = 2'd2; end
        4'd8: begin offset_x = 2'd2; offset_y = 2'd2; end
        default: begin offset_x = 2'd0; offset_y = 2'd0; end
    endcase
end

wire signed [7:0] actual_x = {1'b0, cnt_x, 2'b00} - 1 + {6'd0, offset_x};
wire signed [7:0] actual_y = {1'b0, cnt_y, 2'b00} - 1 + {6'd0, offset_y};
wire is_pad = (actual_x < 0 || actual_x > 63 || actual_y < 0 || actual_y > 63);

reg valid_d1, valid_d2, valid_d3, valid_d4, valid_d5;
reg [3:0] step_d1, step_d2, step_d3, step_d4, step_d5;
reg is_pad_d1, is_pad_d2;
reg [2:0] byte_offset_d1, byte_offset_d2;
reg [63:0] sram_data_d2;

always @(posedge clk) begin
    valid_d1 <= step_is_valid; step_d1 <= cnt_step;
    is_pad_d1 <= is_pad; byte_offset_d1 <= actual_x[2:0];
    
    valid_d2 <= valid_d1; step_d2 <= step_d1;
    is_pad_d2 <= is_pad_d1; byte_offset_d2 <= byte_offset_d1;
    sram_data_d2 <= img_sram_dout; 
    
    valid_d3 <= valid_d2; step_d3 <= step_d2;
    valid_d4 <= valid_d3; step_d4 <= step_d3;
    valid_d5 <= valid_d4; step_d5 <= step_d4;
end

wire [7:0] p_reg = (!valid_d2 || is_pad_d2) ? 8'd0 : sram_data_d2[byte_offset_d2 * 8 +: 8];

reg [7:0] p_reg_d3;
always @(posedge clk) begin
    p_reg_d3 <= p_reg;
end

wire is_down_conv_write = (valid_d5 && step_d5 == 9); 

reg [7:0] down_out_cnt;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) down_out_cnt <= 0;
    else if (cs == S_LOAD || cs == S_ITER_SWITCH) down_out_cnt <= 0;
    else if (valid_d5 && step_d5 == 12) down_out_cnt <= down_out_cnt + 1;
end

assign down_done = (valid_d5 && step_d5 == 12 && down_out_cnt == 8'd255);

reg signed [31:0] shared_mac_acc [0:15];

always @(posedge clk) begin
    if (cs == S_DOWN_CONV && valid_d4 && step_d4 < 9) begin 
        for(idx_s=0; idx_s<16; idx_s=idx_s+1) begin
            if (step_d4 == 0) shared_mac_acc[idx_s] <= $signed(mac_outs[idx_s*16 +: 16]);
            else shared_mac_acc[idx_s] <= shared_mac_acc[idx_s] + $signed(mac_outs[idx_s*16 +: 16]);
        end
    end
    else if ((cs == S_TRANS_QKV || cs == S_ATTEN_Q) && phase_step >= 5 && phase_step <= 20) begin
        for(idx_s=0; idx_s<16; idx_s=idx_s+1) begin
            if (phase_step == 5) shared_mac_acc[idx_s] <= $signed(mac_outs[idx_s*16 +: 16]);
            else shared_mac_acc[idx_s] <= shared_mac_acc[idx_s] + $signed(mac_outs[idx_s*16 +: 16]);
        end
    end
    else if (cs == S_ATTEN_KV && kv_step >= 6 && kv_step <= 261) begin 
        for(idx_s=0; idx_s<16; idx_s=idx_s+1) begin
            if (kv_step == 6) shared_mac_acc[idx_s] <= $signed(mac_outs[idx_s*16 +: 16]);
            else shared_mac_acc[idx_s] <= shared_mac_acc[idx_s] + $signed(mac_outs[idx_s*16 +: 16]);
        end
    end
    else if (cs == S_FFN && phase_step >= 5 && phase_step <= 20) begin
        for(idx_s=0; idx_s<16; idx_s=idx_s+1) begin
            if (phase_step == 5) shared_mac_acc[idx_s] <= $signed(mac_outs[idx_s*16 +: 16]);
            else shared_mac_acc[idx_s] <= shared_mac_acc[idx_s] + $signed(mac_outs[idx_s*16 +: 16]);
        end
    end
end

reg [127:0] flat_final_pixels;
always @(*) begin
    for (idx_q = 0; idx_q < 16; idx_q = idx_q + 1) begin
        if (shared_mac_acc[idx_q][31] == 1'b0 && (|shared_mac_acc[idx_q][30:13]))
            flat_final_pixels[idx_q*8 +: 8] = 8'h7F;
        else if (shared_mac_acc[idx_q][31] == 1'b1 && (~&shared_mac_acc[idx_q][30:13]))
            flat_final_pixels[idx_q*8 +: 8] = 8'h80;
        else
            flat_final_pixels[idx_q*8 +: 8] = shared_mac_acc[idx_q][13:6];
    end
end

// ===============================================================
// Transformer Block
// ===============================================================
reg signed [7:0] vec_val_reg; 
reg [127:0]      ds_sram_dout_reg;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) ds_sram_dout_reg <= 128'd0;
    else ds_sram_dout_reg <= ds_sram_dout;
end

reg [127:0] vec_buf; 
reg [1:0] qkv_type; 
reg [7:0] qkv_pt; 

assign qkv_done = (cs == S_TRANS_QKV && qkv_type == 2 && qkv_pt == 255 && phase_step == 21);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) vec_buf <= 128'd0;
    else if (cs == S_TRANS_WAIT || cs == S_ATTEN_WAIT || cs == S_FFN_WAIT) vec_buf <= 128'd0;
    else if (cs == S_TRANS_QKV || cs == S_ATTEN_Q || cs == S_FFN) begin
        if (phase_step == 2) vec_buf <= ds_sram_dout_reg;
    end
end

wire [3:0] phase_x_idx = (phase_step >= 3 && phase_step <= 18) ? (phase_step - 3) : 0;
wire signed [7:0] phase_x_val = vec_buf[phase_x_idx * 8 +: 8]; 

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        vec_val_reg <= 8'd0;
    end else begin
        vec_val_reg <= phase_x_val;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        qkv_type <= 1; qkv_pt <= 0; phase_step <= 0; 
    end else if (cs == S_TRANS_WAIT || cs == S_ATTEN_WAIT || cs == S_FFN_WAIT) begin
        qkv_type <= (cs == S_ATTEN_WAIT) ? 2'd0 : 2'd1; 
        qkv_pt <= 0; phase_step <= 0;
    end else if (cs == S_TRANS_QKV || cs == S_ATTEN_Q || cs == S_FFN) begin
        if (phase_step == 21) begin
            phase_step <= 0;
            if (cs == S_TRANS_QKV) begin
                if (qkv_pt == 255) begin
                    qkv_pt <= 0;
                    if (qkv_type == 1) qkv_type <= 2; 
                end else qkv_pt <= qkv_pt + 1;
            end 
        end else phase_step <= phase_step + 1;
    end
end

reg [127:0] qkv_write_data;
always @(*) begin
    for (idx_qkv = 0; idx_qkv < 16; idx_qkv = idx_qkv + 1) begin
        if (shared_mac_acc[idx_qkv][31] == 1'b0 && (|shared_mac_acc[idx_qkv][30:11]))
            qkv_write_data[idx_qkv*8 +: 8] = 8'h7F;
        else if (shared_mac_acc[idx_qkv][31] == 1'b1 && (~&shared_mac_acc[idx_qkv][30:11]))
            qkv_write_data[idx_qkv*8 +: 8] = 8'h80;
        else
            qkv_write_data[idx_qkv*8 +: 8] = shared_mac_acc[idx_qkv][11:4];
    end
end

reg [127:0] q_row_buf_flat; 
reg [127:0] k_reg, v_reg_d1, v_reg_d2, v_reg_d3, v_reg_d4;
reg [7:0]   score_reg;

wire signed [19:0] qk_dot_sum;
wire qk_pos_ovf = (qk_dot_sum[19] == 1'b0) && (|qk_dot_sum[18:13]);
wire qk_neg_ovf = (qk_dot_sum[19] == 1'b1) && (~&qk_dot_sum[18:13]);
wire [7:0] qk_softmax_score = qk_pos_ovf ? 8'hFF : 
                              qk_neg_ovf ? 8'h00 : (qk_dot_sum[13:6] ^ 8'h80);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        atten_q_cnt <= 0; kv_step <= 0;
        k_reg <= 0; v_reg_d1 <= 0; v_reg_d2 <= 0; v_reg_d3 <= 0; score_reg <= 0; v_reg_d4 <= 0;
        q_row_buf_flat <= 128'd0;
    end else if (cs == S_ATTEN_WAIT) begin
        atten_q_cnt <= 0; v_reg_d3 <= 0; v_reg_d4 <= 0;
    end else if (cs == S_ATTEN_Q) begin
        kv_step <= 0;
        if (phase_step == 21) q_row_buf_flat <= qkv_write_data;  
    end else if (cs == S_ATTEN_KV) begin
        kv_step <= kv_step + 1;
        if (kv_step >= 1 && kv_step <= 256) begin
            k_reg <= k_sram_dout; 
        end
        if (kv_step >= 4 && kv_step <= 259) begin
            score_reg <= qk_softmax_score; 
            v_reg_d4 <= v_sram_dout;
        end
        if (kv_step == 262) atten_q_cnt <= atten_q_cnt + 1; 
    end
end

reg [127:0] attn_out_packed;
always @(*) begin
    for (idx_out = 0; idx_out < 16; idx_out = idx_out + 1) begin
        if (shared_mac_acc[idx_out][31] == 1'b0 && (|shared_mac_acc[idx_out][30:23]))
            attn_out_packed[idx_out*8 +: 8] = 8'h7F;
        else if (shared_mac_acc[idx_out][31] == 1'b1 && (~&shared_mac_acc[idx_out][30:23]))
            attn_out_packed[idx_out*8 +: 8] = 8'h80;
        else
            attn_out_packed[idx_out*8 +: 8] = shared_mac_acc[idx_out][23:16];
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) ffn_pt <= 0;
    else if (cs == S_FFN_WAIT) ffn_pt <= 0;
    else if (cs == S_FFN && phase_step == 21 && ffn_pt != 255) ffn_pt <= ffn_pt + 1; 
end

reg [127:0] ffn_out_packed;
always @(*) begin
    for (idx_ffn = 0; idx_ffn < 16; idx_ffn = idx_ffn + 1) begin
        if (shared_mac_acc[idx_ffn][31] == 1'b0 && (|shared_mac_acc[idx_ffn][30:11]))
            ffn_out_packed[idx_ffn*8 +: 8] = 8'hFF;
        else if (shared_mac_acc[idx_ffn][31] == 1'b1 && (~&shared_mac_acc[idx_ffn][30:11]))
            ffn_out_packed[idx_ffn*8 +: 8] = 8'h00;
        else
            ffn_out_packed[idx_ffn*8 +: 8] = shared_mac_acc[idx_ffn][11:4] ^ 8'h80;
    end
end

// ===============================================================
// Up Sampling
// ===============================================================
reg [3:0] up_cx, up_cy, up_step;
reg [1:0] up_off_x, up_off_y;

always @(*) begin
    case (up_step)
        4'd0: begin up_off_x = 2'd0; up_off_y = 2'd0; end
        4'd1: begin up_off_x = 2'd1; up_off_y = 2'd0; end
        4'd2: begin up_off_x = 2'd2; up_off_y = 2'd0; end
        4'd3: begin up_off_x = 2'd0; up_off_y = 2'd1; end
        4'd4: begin up_off_x = 2'd1; up_off_y = 2'd1; end
        4'd5: begin up_off_x = 2'd2; up_off_y = 2'd1; end
        4'd6: begin up_off_x = 2'd0; up_off_y = 2'd2; end
        4'd7: begin up_off_x = 2'd1; up_off_y = 2'd2; end
        4'd8: begin up_off_x = 2'd2; up_off_y = 2'd2; end
        default: begin up_off_x = 2'd0; up_off_y = 2'd0; end
    endcase
end

wire signed [5:0] up_act_x = {1'b0, up_cx} - 1 + {4'd0, up_off_x};
wire signed [5:0] up_act_y = {1'b0, up_cy} - 1 + {4'd0, up_off_y};
wire up_is_pad = (up_act_x < 0 || up_act_x > 15 || up_act_y < 0 || up_act_y > 15);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        up_cx <= 0; up_cy <= 0; up_step <= 0;
    end else if (cs == S_UP_CONV_WAIT) begin
        up_cx <= 0; up_cy <= 0; up_step <= 0;
    end else if (cs == S_UP_CONV) begin
        if (up_step == 8) begin
            up_step <= 0;
            if (up_cx == 15) begin
                up_cx <= 0;
                if (up_cy != 15) up_cy <= up_cy + 1;
            end else up_cx <= up_cx + 1;
        end else up_step <= up_step + 1;
    end
end

reg up_valid_d1, up_valid_d2, up_valid_d3;
reg [3:0] up_step_d1, up_step_d2, up_step_d3;
reg up_is_pad_d1, up_is_pad_d2;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        up_valid_d1 <= 0; up_valid_d2 <= 0; up_valid_d3 <= 0; up_valid_d4 <= 0; up_valid_d5 <= 0;
        up_step_d1 <= 0; up_step_d2 <= 0; up_step_d3 <= 0; up_step_d4 <= 0; up_step_d5 <= 0;
        up_is_pad_d1 <= 0; up_is_pad_d2 <= 0;
    end else begin
        up_valid_d1  <= (cs == S_UP_CONV); up_step_d1 <= up_step;
        up_is_pad_d1 <= up_is_pad;

        up_valid_d2  <= up_valid_d1; up_step_d2 <= up_step_d1;
        up_is_pad_d2 <= up_is_pad_d1; 

        up_valid_d3  <= up_valid_d2; up_step_d3 <= up_step_d2;
        up_valid_d4  <= up_valid_d3; up_step_d4 <= up_step_d3;
        up_valid_d5  <= up_valid_d4; up_step_d5 <= up_step_d4;
    end
end

reg [127:0] ds_sram_dout_reg_d3;
reg         up_is_pad_d3;
always @(posedge clk) begin
    ds_sram_dout_reg_d3 <= ds_sram_dout_reg;
    up_is_pad_d3        <= up_is_pad_d2;
end

wire signed [31:0] up_mac_sum =
    $signed(mac_outs[0*16 +: 16])  + $signed(mac_outs[1*16 +: 16])  + $signed(mac_outs[2*16 +: 16])  + $signed(mac_outs[3*16 +: 16]) +
    $signed(mac_outs[4*16 +: 16])  + $signed(mac_outs[5*16 +: 16])  + $signed(mac_outs[6*16 +: 16])  + $signed(mac_outs[7*16 +: 16]) +
    $signed(mac_outs[8*16 +: 16])  + $signed(mac_outs[9*16 +: 16])  + $signed(mac_outs[10*16 +: 16]) + $signed(mac_outs[11*16 +: 16]) +
    $signed(mac_outs[12*16 +: 16]) + $signed(mac_outs[13*16 +: 16]) + $signed(mac_outs[14*16 +: 16]) + $signed(mac_outs[15*16 +: 16]);

reg signed [31:0] up_acc;
always @(posedge clk) begin
    if (up_valid_d4) begin  
        if (up_step_d4 == 0) up_acc <= up_mac_sum; 
        else up_acc <= up_acc + up_mac_sum;
    end
end

wire up_is_pos_ovf = (up_acc[31] == 1'b0) && (|up_acc[30:13]);
wire up_is_neg_ovf = (up_acc[31] == 1'b1) && (~&up_acc[30:13]);
wire [7:0] up_clipped = up_is_pos_ovf ? 8'hFF : 
                        up_is_neg_ovf ? 8'h00 : (up_acc[13:6] ^ 8'h80); 

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) up_out_cnt <= 0;
    else if (cs == S_UP_CONV_WAIT) up_out_cnt <= 0;
    else if (up_valid_d5 && up_step_d5 == 8) up_out_cnt <= up_out_cnt + 1;
end

reg [127:0] up_row_buf;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) up_row_buf <= 128'd0;
    else if (up_valid_d5 && up_step_d5 == 8) up_row_buf <= {up_clipped, up_row_buf[127:8]}; 
end

// ===============================================================
// Interpolation & Denoise
// ===============================================================
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) inter_load_cnt <= 0;
    else if (cs == S_INTER_PRE) inter_load_cnt <= inter_load_cnt + 1;
    else inter_load_cnt <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) inter_calc_cnt <= 0;
    else if (cs == S_INTER_CALC) inter_calc_cnt <= inter_calc_cnt + 1;
    else inter_calc_cnt <= 0;
end

wire [5:0] y_out = inter_calc_cnt[11:6]; 
wire [5:0] x_out = inter_calc_cnt[5:0];  
wire [3:0] y_in  = y_out[5:2];           
wire [3:0] x_in  = x_out[5:2];           
wire [1:0] y_rem = y_out[1:0];           
wire [1:0] x_rem = x_out[1:0];           

reg [127:0] v_sram_dout_d1;
reg [127:0] row_up, row_curr, row_down;
always @(posedge clk) v_sram_dout_d1 <= v_sram_dout;

always @(posedge clk) begin
    if (cs == S_INTER_PRE) begin
        if (inter_load_cnt == 2) row_up   <= v_sram_dout_d1;
        if (inter_load_cnt == 3) row_curr <= v_sram_dout_d1;
        if (inter_load_cnt == 4) row_down <= v_sram_dout_d1;
    end else if (cs == S_INTER_CALC) begin
        if (inter_calc_cnt[7:0] == 8'hFF) begin
            row_up   <= row_curr; row_curr <= row_down; row_down <= v_sram_dout_d1; 
        end
    end
end

wire [7:0] p_curr  = row_curr[x_in*8 +: 8];
wire [7:0] p_right = (x_in < 15) ? row_curr[(x_in+1)*8 +: 8] : p_curr; 
wire [7:0] p_left  = (x_in > 0)  ? row_curr[(x_in-1)*8 +: 8] : p_curr;
wire [7:0] p_down  = row_down[x_in*8 +: 8];
wire [7:0] p_up    = row_up[x_in*8 +: 8];

reg [7:0]        p_curr_pipe, p_right_pipe, p_left_pipe, p_down_pipe, p_up_pipe;
reg [3:0]        x_in_pipe, y_in_pipe;
reg [1:0]        x_rem_pipe, y_rem_pipe;

always @(posedge clk) begin
    p_curr_pipe  <= p_curr;
    p_right_pipe <= p_right;
    p_left_pipe  <= p_left;
    p_down_pipe  <= p_down;
    p_up_pipe    <= p_up;
    x_in_pipe    <= x_in;
    y_in_pipe    <= y_in;
    x_rem_pipe   <= x_rem;
    y_rem_pipe   <= y_rem;
end

wire signed [9:0] diff_m1_pipe = (x_in_pipe < 15) ? ($signed({1'b0, p_right_pipe}) - $signed({1'b0, p_curr_pipe})) : ($signed({1'b0, p_curr_pipe})  - $signed({1'b0, p_left_pipe}));
wire signed [9:0] diff_m2_pipe = (y_in_pipe < 15) ? ($signed({1'b0, p_down_pipe})  - $signed({1'b0, p_curr_pipe})) : ($signed({1'b0, p_curr_pipe})  - $signed({1'b0, p_up_pipe}));

wire signed [9:0] selected_diff = i_mode_reg[1] ? diff_m2_pipe : 
                                  i_mode_reg[0] ? diff_m1_pipe : 10'd0;

wire [1:0]        selected_rem  = i_mode_reg[0] ? x_rem_pipe : 
                                  i_mode_reg[1] ? y_rem_pipe : 2'd0;

wire signed [9:0] step = selected_diff >>> 2;

wire signed [11:0] step_x1 = step;
wire signed [11:0] step_x2 = step <<< 1;
wire signed [11:0] step_x3 = step_x1 + step_x2;

reg signed [11:0] step_mult;
always @(*) begin
    case(selected_rem)
        2'd1: step_mult = step_x1;
        2'd2: step_mult = step_x2;
        2'd3: step_mult = step_x3;
        default: step_mult = 12'd0;
    endcase
end

wire signed [11:0] inter_val = $signed({1'b0, p_curr_pipe}) + step_mult;

wire inter_is_neg = inter_val[11];
wire inter_is_ovf = ~inter_val[11] && (|inter_val[10:8]);
wire [7:0] inter_clipped = inter_is_neg ? 8'd0 : 
                           inter_is_ovf ? 8'd255 : inter_val[7:0];

reg        inter_calc_valid_d1, inter_calc_valid_d2;
reg [12:0] inter_calc_cnt_d1,   inter_calc_cnt_d2;
reg [7:0]  inter_clipped_d2;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        inter_calc_valid_d1 <= 1'b0; inter_calc_cnt_d1 <= 13'd0; 
        inter_calc_valid_d2 <= 1'b0; inter_calc_cnt_d2 <= 13'd0; inter_clipped_d2 <= 8'd0;
    end else begin
        inter_calc_valid_d1 <= (cs == S_INTER_CALC);
        inter_calc_cnt_d1   <= inter_calc_cnt;
        
        inter_calc_valid_d2 <= inter_calc_valid_d1;
        inter_calc_cnt_d2   <= inter_calc_cnt_d1;
        inter_clipped_d2    <= inter_clipped;
    end
end

reg [63:0] cur_img_word;
always @(posedge clk) begin
    if (inter_calc_valid_d2 && (inter_calc_cnt_d2 == 0 || inter_calc_cnt_d2[2:0] == 3'd7)) begin
        cur_img_word <= img_sram_dout; 
    end
end

wire [7:0] orig_pixel = (inter_calc_cnt_d2 == 0) ? img_sram_dout[0 +: 8] : cur_img_word[inter_calc_cnt_d2[2:0] * 8 +: 8];
wire [7:0] noise_scaled = inter_clipped_d2 >> 3;
wire signed [9:0] denoised_val = $signed({1'b0, orig_pixel}) - $signed({1'b0, noise_scaled});
wire denoise_is_neg = denoised_val[9];
wire denoise_is_ovf = ~denoised_val[9] && denoised_val[8];
wire [7:0] final_denoised = denoise_is_neg ? 8'd0 : 
                            denoise_is_ovf ? 8'd255 : denoised_val[7:0];

reg [63:0] denoise_pack_buf;
always @(posedge clk) begin
    if (inter_calc_valid_d2) denoise_pack_buf <= {final_denoised, denoise_pack_buf[63:8]};
end

assign denoise_write_en = (inter_calc_valid_d2 && !is_last_iter && inter_calc_cnt_d2[2:0] == 3'd7);

// ===============================================================
// MAC Data Path Formulation 
// ===============================================================
reg [143:0] mac_in_A;
reg [143:0] mac_in_B; 

reg [143:0] mac_in_A_comb;
reg [143:0] mac_in_B_comb; 

wire [143:0] p_reg_broadcast_comb     = {16{1'b0, p_reg}}; 
wire [143:0] vec_val_broadcast_comb   = {16{phase_x_val[7], phase_x_val}}; 
wire [143:0] score_reg_broadcast_comb = {16{1'b0, qk_softmax_score}}; 

always @(*) begin
    mac_in_A_comb = 144'd0; 
    mac_in_B_comb = 144'd0;
    
    if (cs == S_DOWN_CONV) begin
        if (step_d2 < 9) begin  
            mac_in_B_comb = p_reg_broadcast_comb; 
            for (idx_a = 0; idx_a < 16; idx_a = idx_a + 1) begin
                mac_in_A_comb[idx_a*9 +: 9] = { {5{w_sram_dout[idx_a*4+3]}}, w_sram_dout[idx_a*4 +: 4] };
            end
        end
    end
    else if (cs == S_TRANS_QKV || cs == S_ATTEN_Q || cs == S_FFN) begin 
        mac_in_B_comb = vec_val_broadcast_comb; 
        for (idx_a = 0; idx_a < 16; idx_a = idx_a + 1) begin
            mac_in_A_comb[idx_a*9 +: 9] = { {5{w_sram_dout[idx_a*4+3]}}, w_sram_dout[idx_a*4 +: 4] };
        end
    end
    else if (cs == S_ATTEN_KV) begin
        mac_in_A_comb = score_reg_broadcast_comb; 
        for (idx_a = 0; idx_a < 16; idx_a = idx_a + 1) begin
            mac_in_B_comb[idx_a*9 +: 9] = {v_sram_dout[idx_a*8+7], v_sram_dout[idx_a*8 +: 8]};
        end
    end
    else if (cs == S_UP_CONV) begin
        for (idx_a = 0; idx_a < 16; idx_a = idx_a + 1) begin
            mac_in_A_comb[idx_a*9 +: 9] = { {5{w_sram_dout[idx_a*4+3]}}, w_sram_dout[idx_a*4 +: 4] };
            if (up_is_pad_d2) mac_in_B_comb[idx_a*9 +: 9] = 9'd0; 
            else mac_in_B_comb[idx_a*9 +: 9] = {1'b0, ds_sram_dout_reg[idx_a*8 +: 8]}; 
        end
    end
end

always @(posedge clk) begin
    mac_in_A <= mac_in_A_comb;
    mac_in_B <= mac_in_B_comb;
end

// ===============================================================
// Output Logic
// ===============================================================
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        o_valid <= 0;
        o_data  <= 0;
    end else if (inter_calc_valid_d2 && is_last_iter && inter_calc_cnt_d2 < 13'd4096) begin 
        o_valid <= 1'b1;
        o_data  <= final_denoised;
    end else begin
        o_valid <= 1'b0;
        o_data  <= 8'd0;
    end
end

// ===============================================================
// Module & Memory Instantiations
// ===============================================================
reg [63:0] qkv_w_buf;
reg [3:0]  qkv_pack_cnt;
reg [5:0]  qkv_sram_addr;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        qkv_w_buf <= 64'd0; qkv_pack_cnt <= 4'd0; qkv_sram_addr <= 6'd0;
    end else if (i_valid && !is_weight_recv_done) begin
        if (is_qkv_w) begin
            qkv_w_buf <= {i_weight, qkv_w_buf[63:4]};
            qkv_pack_cnt <= qkv_pack_cnt + 1;
            if (qkv_pack_cnt == 4'd15) qkv_sram_addr <= qkv_sram_addr + 1;
        end else qkv_pack_cnt <= 4'd0;
    end
end

wire [3:0]  phase_w_idx = (phase_step >= 2 && phase_step <= 17) ? (phase_step - 2) : ((phase_step > 17) ? 15 : 0);

wire        qkv_sram_write_en = (i_valid && !is_weight_recv_done && is_qkv_w && qkv_pack_cnt == 4'd15);
wire        actual_w_sram_we  = is_dumping || qkv_sram_write_en;

wire [6:0]  actual_w_sram_addr = 
    (is_down_dumping) ? {3'd0, dump_cnt} :
    (is_up_dumping)   ? (7'd73 + {3'd0, dump_cnt}) :
    (cs == S_DOWN_CONV) ? {3'd0, (step_d1 < 9 ? step_d1 : 4'd0)} :
    (cs == S_UP_CONV)   ? (7'd73 + {3'd0, up_step_d1}) :
    (cs == S_TRANS_QKV || cs == S_ATTEN_Q) ? (7'd9 + qkv_type * 16 + phase_w_idx) :
    (cs == S_FFN)       ? (7'd57 + phase_w_idx) :
    (7'd9 + qkv_sram_addr); 

wire [63:0] actual_w_sram_di = 
    is_dumping ? assemble_buf[dump_cnt] :
    {i_weight, qkv_w_buf[63:4]}; 

MEM_82X64 u_weight_sram (
    .CLK (clk), .CS (1'b1), .OE (1'b1), 
    .WEB (~actual_w_sram_we), 
    .A   (actual_w_sram_addr), 
    .DI  (actual_w_sram_di), 
    .DO  (w_sram_dout)
);

wire [8:0] denoise_write_addr = inter_calc_cnt_d2[11:3]; 
wire [63:0] denoise_write_data = {final_denoised, denoise_pack_buf[63:8]};
wire        img_sram_write_en = (is_receiving_image && img_pack_cnt == 3'd7) || denoise_write_en;
wire [63:0] img_sram_di       = (denoise_write_en) ? denoise_write_data : {i_data, img_pack_buf[63:8]}; 

wire is_not_max_addr = ~(&inter_calc_cnt_d1[11:3]); 
wire [8:0] sram_read_addr_for_denoise = (inter_calc_cnt_d1[2:0] >= 3'd6 && is_not_max_addr) ? 
                                        (inter_calc_cnt_d1[11:3] + 1'b1) : inter_calc_cnt_d1[11:3];

wire [8:0] ds_read_addr = {actual_y[5:0], actual_x[5:3]};

wire [8:0]  actual_img_sram_addr = 
    (denoise_write_en) ? denoise_write_addr :
    (is_receiving_image && img_pack_cnt == 3'd7) ? img_sram_write_addr : 
    (cs == S_INTER_CALC) ? sram_read_addr_for_denoise :
    (cs == S_DOWN_CONV) ? ds_read_addr : 9'd0;

MEM_512X64 u_image_sram_A (
    .CLK (clk), .CS (1'b1), .OE (1'b1), 
    .WEB (~img_sram_write_en), 
    .A   (actual_img_sram_addr), 
    .DI  (img_sram_di), 
    .DO  (img_sram_dout)
);

wire k_write_en = (cs == S_TRANS_QKV && phase_step == 21 && qkv_type == 1);
wire [7:0] kv_sram_addr = (cs == S_ATTEN_KV) ? kv_step[7:0] : qkv_pt;

MEM_256X128 u_k_sram (
    .CLK(clk), .CS(1'b1), .OE(1'b1), 
    .WEB(~k_write_en), 
    .A(kv_sram_addr), 
    .DI(qkv_write_data), 
    .DO(k_sram_dout)
);

wire        v_write_en = (cs == S_TRANS_QKV && phase_step == 21 && qkv_type == 2); 
wire        up_write_en_wire   = (cs == S_UP_CONV) && (up_valid_d5 && up_step_d5 == 8 && up_out_cnt[3:0] == 4'd15); 
wire [7:0]  up_write_addr_wire = {4'd0, up_out_cnt[7:4]}; 
wire [127:0] up_write_data_wire = {up_clipped, up_row_buf[127:8]};

wire actual_v_write_en = v_write_en || up_write_en_wire;
wire [7:0] delayed_v_addr = kv_step - 8'd3; 

wire [7:0] actual_v_sram_addr = 
    (up_write_en_wire) ? up_write_addr_wire : 
    (cs == S_INTER_PRE) ? ((inter_load_cnt <= 1) ? 8'd0 : 8'd1) :
    (cs == S_INTER_CALC) ? ((y_in >= 14) ? 8'd15 : {4'd0, y_in} + 8'd2) :
    (cs == S_ATTEN_KV) ? delayed_v_addr :
    kv_sram_addr;
wire [127:0] actual_v_sram_di = (up_write_en_wire) ? up_write_data_wire : qkv_write_data;

MEM_256X128 u_v_sram (
    .CLK(clk), .CS(1'b1), .OE(1'b1), 
    .WEB(~actual_v_write_en), 
    .A(actual_v_sram_addr), 
    .DI(actual_v_sram_di), 
    .DO(v_sram_dout)
);

wire is_attn_write    = (cs == S_ATTEN_KV && kv_step == 262); 
wire is_ffn_write     = (cs == S_FFN && phase_step == 21);    
wire ds_sram_write_en = is_down_conv_write || is_attn_write || is_ffn_write;

wire [7:0] up_read_addr = {up_act_y[3:0], up_act_x[3:0]}; 
wire [7:0] actual_ds_sram_addr = 
    (cs == S_DOWN_CONV) ? down_out_cnt : 
    (cs == S_ATTEN_Q || cs == S_ATTEN_KV) ? atten_q_cnt[7:0] : 
    (cs == S_FFN) ? ffn_pt : 
    (cs == S_UP_CONV) ? up_read_addr : 
    qkv_pt;

wire [127:0] actual_ds_sram_di = 
    (cs == S_ATTEN_KV) ? attn_out_packed : 
    (cs == S_FFN) ? ffn_out_packed : 
    flat_final_pixels;

MEM_256X128 u_ds_sram (
    .CLK(clk), .CS(1'b1), .OE(1'b1), 
    .WEB(~ds_sram_write_en), 
    .A(actual_ds_sram_addr), 
    .DI(actual_ds_sram_di), 
    .DO(ds_sram_dout)
);

QK_DOT_SOFTMAX_UNIT u_qk_dot (
    .clk(clk),           
    .rst_n(rst_n),       
    .flat_q(q_row_buf_flat),
    .flat_k(k_reg), 
    .dot_sum_out(qk_dot_sum) 
);

PURE_MAC_16 u_mac (
    .clk(clk),            
    .flat_op_A(mac_in_A), 
    .flat_op_B(mac_in_B), 
    .mult_outs(mac_outs)
);

endmodule

module QK_DOT_SOFTMAX_UNIT (
    input          clk,          
    input          rst_n,        
    input  [127:0] flat_q,
    input  [127:0] flat_k,
    output signed [19:0] dot_sum_out
);
    reg  signed [15:0] prod_reg [0:15]; 
    
    reg  signed [19:0] dot_sum_comb;
    reg  signed [19:0] dot_sum_reg; 

    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            for (i = 0; i < 16; i = i + 1) prod_reg[i] <= 16'd0;
        end else begin
            for (i = 0; i < 16; i = i + 1) begin
                prod_reg[i] <= $signed(flat_q[i*8 +: 8]) * $signed(flat_k[i*8 +: 8]);
            end
        end
    end

    always @(*) begin
        dot_sum_comb = 20'd0;
        for (i = 0; i < 16; i = i + 1) begin
            dot_sum_comb = dot_sum_comb + prod_reg[i]; 
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            dot_sum_reg <= 20'd0;
        end else begin
            dot_sum_reg <= dot_sum_comb;
        end
    end

    assign dot_sum_out = dot_sum_reg;

endmodule

module PURE_MAC_16 (
    input              clk,       
    input      [143:0] flat_op_A,  
    input      [143:0] flat_op_B,  
    output reg [255:0] mult_outs  
);
    reg signed [8:0]  op_A [0:15];
    reg signed [8:0]  op_B [0:15];
    reg signed [17:0] prod [0:15]; 

    integer i;

    always @(*) begin
        for (i = 0; i < 16; i = i + 1) begin
            op_A[i] = flat_op_A[i*9 +: 9];
            op_B[i] = flat_op_B[i*9 +: 9];
            prod[i] = op_A[i] * op_B[i];
        end
    end

    always @(posedge clk) begin
        for (i = 0; i < 16; i = i + 1) begin
            mult_outs[i*16 +: 16] <= prod[i][15:0];
        end
    end

endmodule

module MEM_512X64(
    input         CLK, CS, OE, WEB,
    input  [8:0]  A,   
    input  [63:0] DI,  
    output [63:0] DO   
);
SRAM_512X64 SRAM1(
    .A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), 
    .A4(A[4]), .A5(A[5]), .A6(A[6]), .A7(A[7]), .A8(A[8]),
    .DO0(DO[0]),   .DO1(DO[1]),   .DO2(DO[2]),   .DO3(DO[3]),
    .DO4(DO[4]),   .DO5(DO[5]),   .DO6(DO[6]),   .DO7(DO[7]),
    .DO8(DO[8]),   .DO9(DO[9]),   .DO10(DO[10]), .DO11(DO[11]),
    .DO12(DO[12]), .DO13(DO[13]), .DO14(DO[14]), .DO15(DO[15]),
    .DO16(DO[16]), .DO17(DO[17]), .DO18(DO[18]), .DO19(DO[19]),
    .DO20(DO[20]), .DO21(DO[21]), .DO22(DO[22]), .DO23(DO[23]),
    .DO24(DO[24]), .DO25(DO[25]), .DO26(DO[26]), .DO27(DO[27]),
    .DO28(DO[28]), .DO29(DO[29]), .DO30(DO[30]), .DO31(DO[31]),
    .DO32(DO[32]), .DO33(DO[33]), .DO34(DO[34]), .DO35(DO[35]),
    .DO36(DO[36]), .DO37(DO[37]), .DO38(DO[38]), .DO39(DO[39]),
    .DO40(DO[40]), .DO41(DO[41]), .DO42(DO[42]), .DO43(DO[43]),
    .DO44(DO[44]), .DO45(DO[45]), .DO46(DO[46]), .DO47(DO[47]),
    .DO48(DO[48]), .DO49(DO[49]), .DO50(DO[50]), .DO51(DO[51]),
    .DO52(DO[52]), .DO53(DO[53]), .DO54(DO[54]), .DO55(DO[55]),
    .DO56(DO[56]), .DO57(DO[57]), .DO58(DO[58]), .DO59(DO[59]),
    .DO60(DO[60]), .DO61(DO[61]), .DO62(DO[62]), .DO63(DO[63]),
    .DI0(DI[0]),   .DI1(DI[1]),   .DI2(DI[2]),   .DI3(DI[3]),
    .DI4(DI[4]),   .DI5(DI[5]),   .DI6(DI[6]),   .DI7(DI[7]),
    .DI8(DI[8]),   .DI9(DI[9]),   .DI10(DI[10]), .DI11(DI[11]),
    .DI12(DI[12]), .DI13(DI[13]), .DI14(DI[14]), .DI15(DI[15]),
    .DI16(DI[16]), .DI17(DI[17]), .DI18(DI[18]), .DI19(DI[19]),
    .DI20(DI[20]), .DI21(DI[21]), .DI22(DI[22]), .DI23(DI[23]),
    .DI24(DI[24]), .DI25(DI[25]), .DI26(DI[26]), .DI27(DI[27]),
    .DI28(DI[28]), .DI29(DI[29]), .DI30(DI[30]), .DI31(DI[31]),
    .DI32(DI[32]), .DI33(DI[33]), .DI34(DI[34]), .DI35(DI[35]),
    .DI36(DI[36]), .DI37(DI[37]), .DI38(DI[38]), .DI39(DI[39]),
    .DI40(DI[40]), .DI41(DI[41]), .DI42(DI[42]), .DI43(DI[43]),
    .DI44(DI[44]), .DI45(DI[45]), .DI46(DI[46]), .DI47(DI[47]),
    .DI48(DI[48]), .DI49(DI[49]), .DI50(DI[50]), .DI51(DI[51]),
    .DI52(DI[52]), .DI53(DI[53]), .DI54(DI[54]), .DI55(DI[55]),
    .DI56(DI[56]), .DI57(DI[57]), .DI58(DI[58]), .DI59(DI[59]),
    .DI60(DI[60]), .DI61(DI[61]), .DI62(DI[62]), .DI63(DI[63]),
    .CK(CLK), .WEB(WEB), .OE(OE), .CS(CS)
);
endmodule

module MEM_256X128(
    input          CLK, CS, OE, WEB,
    input  [7:0]   A,   
    input  [127:0] DI,  
    output [127:0] DO   
);
SRAM_256X128 SRAM2(
    .A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), 
    .A4(A[4]), .A5(A[5]), .A6(A[6]), .A7(A[7]),
    .DO0(DO[0]),     .DO1(DO[1]),     .DO2(DO[2]),     .DO3(DO[3]),
    .DO4(DO[4]),     .DO5(DO[5]),     .DO6(DO[6]),     .DO7(DO[7]),
    .DO8(DO[8]),     .DO9(DO[9]),     .DO10(DO[10]),   .DO11(DO[11]),
    .DO12(DO[12]),   .DO13(DO[13]),   .DO14(DO[14]),   .DO15(DO[15]),
    .DO16(DO[16]),   .DO17(DO[17]),   .DO18(DO[18]),   .DO19(DO[19]),
    .DO20(DO[20]),   .DO21(DO[21]),   .DO22(DO[22]),   .DO23(DO[23]),
    .DO24(DO[24]),   .DO25(DO[25]),   .DO26(DO[26]),   .DO27(DO[27]),
    .DO28(DO[28]),   .DO29(DO[29]),   .DO30(DO[30]),   .DO31(DO[31]),
    .DO32(DO[32]),   .DO33(DO[33]),   .DO34(DO[34]),   .DO35(DO[35]),
    .DO36(DO[36]),   .DO37(DO[37]),   .DO38(DO[38]),   .DO39(DO[39]),
    .DO40(DO[40]),   .DO41(DO[41]),   .DO42(DO[42]),   .DO43(DO[43]),
    .DO44(DO[44]),   .DO45(DO[45]),   .DO46(DO[46]),   .DO47(DO[47]),
    .DO48(DO[48]),   .DO49(DO[49]),   .DO50(DO[50]),   .DO51(DO[51]),
    .DO52(DO[52]),   .DO53(DO[53]),   .DO54(DO[54]),   .DO55(DO[55]),
    .DO56(DO[56]),   .DO57(DO[57]),   .DO58(DO[58]),   .DO59(DO[59]),
    .DO60(DO[60]),   .DO61(DO[61]),   .DO62(DO[62]),   .DO63(DO[63]),
    .DO64(DO[64]),   .DO65(DO[65]),   .DO66(DO[66]),   .DO67(DO[67]),
    .DO68(DO[68]),   .DO69(DO[69]),   .DO70(DO[70]),   .DO71(DO[71]),
    .DO72(DO[72]),   .DO73(DO[73]),   .DO74(DO[74]),   .DO75(DO[75]),
    .DO76(DO[76]),   .DO77(DO[77]),   .DO78(DO[78]),   .DO79(DO[79]),
    .DO80(DO[80]),   .DO81(DO[81]),   .DO82(DO[82]),   .DO83(DO[83]),
    .DO84(DO[84]),   .DO85(DO[85]),   .DO86(DO[86]),   .DO87(DO[87]),
    .DO88(DO[88]),   .DO89(DO[89]),   .DO90(DO[90]),   .DO91(DO[91]),
    .DO92(DO[92]),   .DO93(DO[93]),   .DO94(DO[94]),   .DO95(DO[95]),
    .DO96(DO[96]),   .DO97(DO[97]),   .DO98(DO[98]),   .DO99(DO[99]),
    .DO100(DO[100]), .DO101(DO[101]), .DO102(DO[102]), .DO103(DO[103]),
    .DO104(DO[104]), .DO105(DO[105]), .DO106(DO[106]), .DO107(DO[107]),
    .DO108(DO[108]), .DO109(DO[109]), .DO110(DO[110]), .DO111(DO[111]),
    .DO112(DO[112]), .DO113(DO[113]), .DO114(DO[114]), .DO115(DO[115]),
    .DO116(DO[116]), .DO117(DO[117]), .DO118(DO[118]), .DO119(DO[119]),
    .DO120(DO[120]), .DO121(DO[121]), .DO122(DO[122]), .DO123(DO[123]),
    .DO124(DO[124]), .DO125(DO[125]), .DO126(DO[126]), .DO127(DO[127]),
    .DI0(DI[0]),     .DI1(DI[1]),     .DI2(DI[2]),     .DI3(DI[3]),
    .DI4(DI[4]),     .DI5(DI[5]),     .DI6(DI[6]),     .DI7(DI[7]),
    .DI8(DI[8]),     .DI9(DI[9]),     .DI10(DI[10]),   .DI11(DI[11]),
    .DI12(DI[12]),   .DI13(DI[13]),   .DI14(DI[14]),   .DI15(DI[15]),
    .DI16(DI[16]),   .DI17(DI[17]),   .DI18(DI[18]),   .DI19(DI[19]),
    .DI20(DI[20]),   .DI21(DI[21]),   .DI22(DI[22]),   .DI23(DI[23]),
    .DI24(DI[24]),   .DI25(DI[25]),   .DI26(DI[26]),   .DI27(DI[27]),
    .DI28(DI[28]),   .DI29(DI[29]),   .DI30(DI[30]),   .DI31(DI[31]),
    .DI32(DI[32]),   .DI33(DI[33]),   .DI34(DI[34]),   .DI35(DI[35]),
    .DI36(DI[36]),   .DI37(DI[37]),   .DI38(DI[38]),   .DI39(DI[39]),
    .DI40(DI[40]),   .DI41(DI[41]),   .DI42(DI[42]),   .DI43(DI[43]),
    .DI44(DI[44]),   .DI45(DI[45]),   .DI46(DI[46]),   .DI47(DI[47]),
    .DI48(DI[48]),   .DI49(DI[49]),   .DI50(DI[50]),   .DI51(DI[51]),
    .DI52(DI[52]),   .DI53(DI[53]),   .DI54(DI[54]),   .DI55(DI[55]),
    .DI56(DI[56]),   .DI57(DI[57]),   .DI58(DI[58]),   .DI59(DI[59]),
    .DI60(DI[60]),   .DI61(DI[61]),   .DI62(DI[62]),   .DI63(DI[63]),
    .DI64(DI[64]),   .DI65(DI[65]),   .DI66(DI[66]),   .DI67(DI[67]),
    .DI68(DI[68]),   .DI69(DI[69]),   .DI70(DI[70]),   .DI71(DI[71]),
    .DI72(DI[72]),   .DI73(DI[73]),   .DI74(DI[74]),   .DI75(DI[75]),
    .DI76(DI[76]),   .DI77(DI[77]),   .DI78(DI[78]),   .DI79(DI[79]),
    .DI80(DI[80]),   .DI81(DI[81]),   .DI82(DI[82]),   .DI83(DI[83]),
    .DI84(DI[84]),   .DI85(DI[85]),   .DI86(DI[86]),   .DI87(DI[87]),
    .DI88(DI[88]),   .DI89(DI[89]),   .DI90(DI[90]),   .DI91(DI[91]),
    .DI92(DI[92]),   .DI93(DI[93]),   .DI94(DI[94]),   .DI95(DI[95]),
    .DI96(DI[96]),   .DI97(DI[97]),   .DI98(DI[98]),   .DI99(DI[99]),
    .DI100(DI[100]), .DI101(DI[101]), .DI102(DI[102]), .DI103(DI[103]),
    .DI104(DI[104]), .DI105(DI[105]), .DI106(DI[106]), .DI107(DI[107]),
    .DI108(DI[108]), .DI109(DI[109]), .DI110(DI[110]), .DI111(DI[111]),
    .DI112(DI[112]), .DI113(DI[113]), .DI114(DI[114]), .DI115(DI[115]),
    .DI116(DI[116]), .DI117(DI[117]), .DI118(DI[118]), .DI119(DI[119]),
    .DI120(DI[120]), .DI121(DI[121]), .DI122(DI[122]), .DI123(DI[123]),
    .DI124(DI[124]), .DI125(DI[125]), .DI126(DI[126]), .DI127(DI[127]),
    .CK(CLK), .WEB(WEB), .OE(OE), .CS(CS)
);
endmodule

module MEM_82X64(
    input         CLK, CS, OE, WEB,
    input  [6:0]  A,   
    input  [63:0] DI,  
    output [63:0] DO   
);
SRAM_82X64 SRAM3(
    .A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .A5(A[5]), .A6(A[6]),
    .DO0(DO[0]),   .DO1(DO[1]),   .DO2(DO[2]),   .DO3(DO[3]),
    .DO4(DO[4]),   .DO5(DO[5]),   .DO6(DO[6]),   .DO7(DO[7]),
    .DO8(DO[8]),   .DO9(DO[9]),   .DO10(DO[10]), .DO11(DO[11]),
    .DO12(DO[12]), .DO13(DO[13]), .DO14(DO[14]), .DO15(DO[15]),
    .DO16(DO[16]), .DO17(DO[17]), .DO18(DO[18]), .DO19(DO[19]),
    .DO20(DO[20]), .DO21(DO[21]), .DO22(DO[22]), .DO23(DO[23]),
    .DO24(DO[24]), .DO25(DO[25]), .DO26(DO[26]), .DO27(DO[27]),
    .DO28(DO[28]), .DO29(DO[29]), .DO30(DO[30]), .DO31(DO[31]),
    .DO32(DO[32]), .DO33(DO[33]), .DO34(DO[34]), .DO35(DO[35]),
    .DO36(DO[36]), .DO37(DO[37]), .DO38(DO[38]), .DO39(DO[39]),
    .DO40(DO[40]), .DO41(DO[41]), .DO42(DO[42]), .DO43(DO[43]),
    .DO44(DO[44]), .DO45(DO[45]), .DO46(DO[46]), .DO47(DO[47]),
    .DO48(DO[48]), .DO49(DO[49]), .DO50(DO[50]), .DO51(DO[51]),
    .DO52(DO[52]), .DO53(DO[53]), .DO54(DO[54]), .DO55(DO[55]),
    .DO56(DO[56]), .DO57(DO[57]), .DO58(DO[58]), .DO59(DO[59]),
    .DO60(DO[60]), .DO61(DO[61]), .DO62(DO[62]), .DO63(DO[63]),
    .DI0(DI[0]),   .DI1(DI[1]),   .DI2(DI[2]),   .DI3(DI[3]),
    .DI4(DI[4]),   .DI5(DI[5]),   .DI6(DI[6]),   .DI7(DI[7]),
    .DI8(DI[8]),   .DI9(DI[9]),   .DI10(DI[10]), .DI11(DI[11]),
    .DI12(DI[12]), .DI13(DI[13]), .DI14(DI[14]), .DI15(DI[15]),
    .DI16(DI[16]), .DI17(DI[17]), .DI18(DI[18]), .DI19(DI[19]),
    .DI20(DI[20]), .DI21(DI[21]), .DI22(DI[22]), .DI23(DI[23]),
    .DI24(DI[24]), .DI25(DI[25]), .DI26(DI[26]), .DI27(DI[27]),
    .DI28(DI[28]), .DI29(DI[29]), .DI30(DI[30]), .DI31(DI[31]),
    .DI32(DI[32]), .DI33(DI[33]), .DI34(DI[34]), .DI35(DI[35]),
    .DI36(DI[36]), .DI37(DI[37]), .DI38(DI[38]), .DI39(DI[39]),
    .DI40(DI[40]), .DI41(DI[41]), .DI42(DI[42]), .DI43(DI[43]),
    .DI44(DI[44]), .DI45(DI[45]), .DI46(DI[46]), .DI47(DI[47]),
    .DI48(DI[48]), .DI49(DI[49]), .DI50(DI[50]), .DI51(DI[51]),
    .DI52(DI[52]), .DI53(DI[53]), .DI54(DI[54]), .DI55(DI[55]),
    .DI56(DI[56]), .DI57(DI[57]), .DI58(DI[58]), .DI59(DI[59]),
    .DI60(DI[60]), .DI61(DI[61]), .DI62(DI[62]), .DI63(DI[63]),
    .CK(CLK), .WEB(WEB), .OE(OE), .CS(CS)
);
endmodule

// 2417455.458336 208361.666229 6.4 3.2237123 12
// 2441478.920781 207864.823185 6.3 3.19723478 12
// 2439641.538348 208436.661373 6.2 3.15253396 12
// 2445163.059526 209958.438362 6.1 3.13163397 12