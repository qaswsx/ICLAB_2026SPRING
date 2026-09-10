module CDNA(
input             clk,
input             rst_n,
input             instruction_in_valid,
input             image_in_valid,
input             weight_in_valid,
input      [31:0] in_data,
output reg        out_valid,
output reg [31:0] out_data
);

// IEEE floating point parameters
parameter inst_sig_width       = 23;
parameter inst_exp_width       = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch_type       = 0;
parameter inst_arch            = 0;
parameter inst_faithful_round  = 0;

localparam OP_SIGMOID = 2'b00;
localparam OP_TANH    = 2'b01;
localparam OP_RELU    = 2'b10;
localparam OP_LEAKY   = 2'b11;

// =========================================================================
// Global Counters and Control Signals
// =========================================================================
reg  [8:0] global_cnt; 
reg        padding_temp;
reg  [1:0] activation_temp;
reg        image_in_valid_ff;
reg        weight_in_valid_ff;
reg  [inst_sig_width + inst_exp_width : 0] in_data_ff;
reg  [7:0] weight_idx; 
integer    w_i; 

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        global_cnt <= 9'd0;
    end 
    else if (instruction_in_valid) begin 
        global_cnt <= 9'd0; 
    end 
    else if (image_in_valid || global_cnt > 0) begin
        global_cnt <= global_cnt + 1'b1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        image_in_valid_ff  <= 0;
        in_data_ff         <= 0;
        weight_in_valid_ff <= 0;
    end
    else if(weight_in_valid) begin
        weight_in_valid_ff <= weight_in_valid;
        in_data_ff <= in_data;
        image_in_valid_ff <= 0;
    end 
    else if(image_in_valid) begin
        weight_in_valid_ff <= 0;
        image_in_valid_ff <= image_in_valid;
        in_data_ff        <= in_data;
    end 
    else begin
        image_in_valid_ff <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        padding_temp    <= 0;
        activation_temp <= 0;
    end 
    else if(instruction_in_valid) begin
        {padding_temp, activation_temp} <= in_data;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        weight_idx <= 8'd0;
    end 
    else if (weight_in_valid_ff) begin 
        weight_idx <= weight_idx + 1'b1;
    end 
    else if(instruction_in_valid) begin
        weight_idx <= 0;
    end
end

// =========================================================================
// Pipeline Stage Enables
// =========================================================================
wire is_fast_act  = (activation_temp == OP_RELU || activation_temp == OP_LEAKY);

wire [8:0] shift_mid = is_fast_act ? 9'd3 : 9'd0;

wire proc_en      = (global_cnt >= 65  && global_cnt <= 192);
wire norm_wb_en   = (global_cnt >= 66  && global_cnt <= 193);
wire L1_conv_en   = (global_cnt >= 140 && global_cnt <= 203);
wire L2_conv_en   = (global_cnt >= 204 && global_cnt <= 219); 


wire Deconv1_en   = (global_cnt >= 9'd229 - shift_mid && global_cnt <= 9'd244 - shift_mid);
wire Deconv2_en   = (global_cnt >= 9'd245 - shift_mid && global_cnt <= 9'd372 - shift_mid);

wire L1_pool_en   = (global_cnt >= 145 && global_cnt <= 208);
wire L2_pool_en   = (global_cnt >= 209 && global_cnt <= 224); 
wire pool_en      = L1_pool_en | L2_pool_en;

wire unpool_en    = (global_cnt >= 9'd228 - shift_mid && global_cnt <= 9'd231 - shift_mid);

// =========================================================================
// Local Counters
// =========================================================================

// 1. Input Counter
reg [6:0] in_cnt;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) in_cnt <= 0;
    else if (instruction_in_valid) in_cnt <= 0;
    else if (image_in_valid_ff) in_cnt <= in_cnt + 1'b1; 
end
wire [2:0] in_x = in_cnt[2:0];
wire [2:0] in_y = in_cnt[5:3];
wire       in_c = in_cnt[6];

// 2. Normalization Counter
reg [6:0] proc_cnt;
reg [6:0] norm_wb_cnt;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        proc_cnt    <= 0;
        norm_wb_cnt <= 0;
    end 
    else begin
        if (global_cnt == 64) proc_cnt <= 0;
        else if (proc_en)     proc_cnt <= proc_cnt + 1'b1;
        
        norm_wb_cnt <= proc_cnt; 
    end
end
wire [2:0] rx = proc_cnt[2:0],    ry = proc_cnt[5:3],    rc = proc_cnt[6];
wire [2:0] wx = norm_wb_cnt[2:0], wy = norm_wb_cnt[5:3], wc = norm_wb_cnt[6];

// 3. Conv Counter
reg [6:0] conv_cnt; 

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) conv_cnt <= 0;
    else if (global_cnt == 139 || global_cnt == 203 || global_cnt == (9'd228 - shift_mid) || global_cnt == (9'd244 - shift_mid)) begin
        conv_cnt <= 0; 
    end 
    else if (L1_conv_en || L2_conv_en || Deconv1_en || Deconv2_en) begin
        conv_cnt <= conv_cnt + 1'b1;
    end
end

wire       d2_ch = conv_cnt[6];            
wire [2:0] mac_x = (L1_conv_en || Deconv2_en) ? conv_cnt[2:0] : 
                    L2_conv_en ? {1'b0, conv_cnt[1:0]} : 
                    Deconv1_en ? {1'b1, conv_cnt[1:0]} : 3'd0;

wire [2:0] mac_y = (L1_conv_en || Deconv2_en) ? conv_cnt[5:3] : 
                    L2_conv_en ? {1'b0, conv_cnt[3:2]} : 
                    Deconv1_en ? {1'b1, conv_cnt[3:2]} : 3'd0;

wire [4:0] conv_state = { 
    (Deconv2_en & d2_ch),     // 5'b10000 : Deconv2 (CH1)
    (Deconv2_en & ~d2_ch),    // 5'b01000 : Deconv2 (CH0)
    Deconv1_en,               // 5'b00100 : Deconv1
    L2_conv_en,               // 5'b00010 : L2_conv
    L1_conv_en                // 5'b00001 : L1_conv
};

// 4. Pooling Counter
reg [5:0] pool_cnt;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) pool_cnt <= 0;
    else if (global_cnt == 144 || global_cnt == 208) begin
        pool_cnt <= 0;
    end 
    else if (pool_en) begin
        pool_cnt <= pool_cnt + 1'b1;
    end
end

wire [2:0] pool_x = L1_pool_en ? pool_cnt[2:0] : {1'b0, pool_cnt[1:0]};
wire [2:0] pool_y = L1_pool_en ? pool_cnt[5:3] : {1'b0, pool_cnt[3:2]};
wire [1:0] p_x    = pool_x[2:1];
wire [1:0] p_y    = pool_y[2:1];

// 5. Unpooling Counter
reg [1:0] unpool_cnt;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) unpool_cnt <= 0;
    else if (global_cnt == (9'd227 - shift_mid)) begin
        unpool_cnt <= 0;
    end else if (unpool_en) begin
        unpool_cnt <= unpool_cnt + 1'b1;
    end
end

wire ux = unpool_cnt[0]; 
wire uy = unpool_cnt[1];

// =========================================================================
// Memories 
// =========================================================================
reg [inst_sig_width + inst_exp_width : 0] weight_reg [0:143];
reg [inst_sig_width + inst_exp_width : 0] image_reg  [0:1][0:7][0:7];

always @(posedge clk) begin
    if (weight_in_valid_ff) begin
        weight_reg[weight_idx] <= in_data_ff;
    end 
end

// =========================================================================
// Padding and Image Read Logic
// =========================================================================
wire zero_pad = (padding_temp == 1'b0);
wire [2:0] min_bound = Deconv1_en ? 3'd4 : 3'd0;
wire [2:0] max_bound = L2_conv_en ? 3'd3 : 3'd7;

wire is_top    = (mac_y == min_bound);
wire is_bottom = (mac_y == max_bound);
wire is_left   = (mac_x == min_bound);
wire is_right  = (mac_x == max_bound);

// 1. Padding Flag
wire pad_T = zero_pad & is_top;
wire pad_B = zero_pad & is_bottom;
wire pad_L = zero_pad & is_left;
wire pad_R = zero_pad & is_right;

// 2. Boundary Protection
wire [2:0] read_x_L = is_left  ? min_bound : mac_x - 3'd1;
wire [2:0] read_x_R = is_right ? max_bound : mac_x + 3'd1;
wire [2:0] read_y_T = is_top   ? min_bound : mac_y - 3'd1;
wire [2:0] read_y_B = is_bottom ? max_bound : mac_y + 3'd1;

wire [inst_sig_width + inst_exp_width : 0] img0_00 = image_reg[0][read_y_T][read_x_L];
wire [inst_sig_width + inst_exp_width : 0] img0_01 = image_reg[0][read_y_T][mac_x];
wire [inst_sig_width + inst_exp_width : 0] img0_02 = image_reg[0][read_y_T][read_x_R];
wire [inst_sig_width + inst_exp_width : 0] img0_10 = image_reg[0][mac_y][read_x_L];
wire [inst_sig_width + inst_exp_width : 0] img0_11 = image_reg[0][mac_y][mac_x]; 
wire [inst_sig_width + inst_exp_width : 0] img0_12 = image_reg[0][mac_y][read_x_R];
wire [inst_sig_width + inst_exp_width : 0] img0_20 = image_reg[0][read_y_B][read_x_L];
wire [inst_sig_width + inst_exp_width : 0] img0_21 = image_reg[0][read_y_B][mac_x];
wire [inst_sig_width + inst_exp_width : 0] img0_22 = image_reg[0][read_y_B][read_x_R];

wire [inst_sig_width + inst_exp_width : 0] img1_00 = image_reg[1][read_y_T][read_x_L];
wire [inst_sig_width + inst_exp_width : 0] img1_01 = image_reg[1][read_y_T][mac_x];
wire [inst_sig_width + inst_exp_width : 0] img1_02 = image_reg[1][read_y_T][read_x_R];
wire [inst_sig_width + inst_exp_width : 0] img1_10 = image_reg[1][mac_y][read_x_L];
wire [inst_sig_width + inst_exp_width : 0] img1_11 = image_reg[1][mac_y][mac_x]; 
wire [inst_sig_width + inst_exp_width : 0] img1_12 = image_reg[1][mac_y][read_x_R];
wire [inst_sig_width + inst_exp_width : 0] img1_20 = image_reg[1][read_y_B][read_x_L];
wire [inst_sig_width + inst_exp_width : 0] img1_21 = image_reg[1][read_y_B][mac_x];
wire [inst_sig_width + inst_exp_width : 0] img1_22 = image_reg[1][read_y_B][read_x_R];

// 3. Padding MUX
// CH0
wire pad_en = zero_pad; 
wire val_00 = ~(pad_en & (is_top | is_left));
wire val_01 = ~(pad_en & is_top);
wire val_02 = ~(pad_en & (is_top | is_right));
wire val_10 = ~(pad_en & is_left);
wire val_11 = 1'b1; 
wire val_12 = ~(pad_en & is_right);
wire val_20 = ~(pad_en & (is_bottom | is_left));
wire val_21 = ~(pad_en & is_bottom);
wire val_22 = ~(pad_en & (is_bottom | is_right));

// Padding CH0
wire [inst_sig_width + inst_exp_width : 0] pad0_00 = img0_00 & {32{val_00}};
wire [inst_sig_width + inst_exp_width : 0] pad0_01 = img0_01 & {32{val_01}};
wire [inst_sig_width + inst_exp_width : 0] pad0_02 = img0_02 & {32{val_02}};
wire [inst_sig_width + inst_exp_width : 0] pad0_10 = img0_10 & {32{val_10}};
wire [inst_sig_width + inst_exp_width : 0] pad0_11 = img0_11; 
wire [inst_sig_width + inst_exp_width : 0] pad0_12 = img0_12 & {32{val_12}};
wire [inst_sig_width + inst_exp_width : 0] pad0_20 = img0_20 & {32{val_20}};
wire [inst_sig_width + inst_exp_width : 0] pad0_21 = img0_21 & {32{val_21}};
wire [inst_sig_width + inst_exp_width : 0] pad0_22 = img0_22 & {32{val_22}};

// Padding CH1 
wire [inst_sig_width + inst_exp_width : 0] pad1_00 = img1_00 & {32{val_00}};
wire [inst_sig_width + inst_exp_width : 0] pad1_01 = img1_01 & {32{val_01}};
wire [inst_sig_width + inst_exp_width : 0] pad1_02 = img1_02 & {32{val_02}};
wire [inst_sig_width + inst_exp_width : 0] pad1_10 = img1_10 & {32{val_10}};
wire [inst_sig_width + inst_exp_width : 0] pad1_11 = img1_11; 
wire [inst_sig_width + inst_exp_width : 0] pad1_12 = img1_12 & {32{val_12}};
wire [inst_sig_width + inst_exp_width : 0] pad1_20 = img1_20 & {32{val_20}};
wire [inst_sig_width + inst_exp_width : 0] pad1_21 = img1_21 & {32{val_21}};
wire [inst_sig_width + inst_exp_width : 0] pad1_22 = img1_22 & {32{val_22}};

// =========================================================================
// MAC Stage 0: Multiplier Inputs & Execution 
// =========================================================================
reg [inst_sig_width + inst_exp_width : 0] mul      [1:18]; 
reg [inst_sig_width + inst_exp_width : 0] conv_mul [1:36];
integer i; 

always @(posedge clk) begin
    if (conv_state != 5'd0) begin
        mul[1]  <= pad0_00; mul[2]  <= pad0_01; mul[3]  <= pad0_02;
        mul[4]  <= pad0_10; mul[5]  <= pad0_11; mul[6]  <= pad0_12;
        mul[7]  <= pad0_20; mul[8]  <= pad0_21; mul[9]  <= pad0_22;
        mul[10] <= pad1_00; mul[11] <= pad1_01; mul[12] <= pad1_02;
        mul[13] <= pad1_10; mul[14] <= pad1_11; mul[15] <= pad1_12;
        mul[16] <= pad1_20; mul[17] <= pad1_21; mul[18] <= pad1_22;
        
        for (i = 1; i <= 36; i = i + 1) begin
            if      (conv_state[0]) conv_mul[i] <= weight_reg[i - 1];            // L1 (0~35)
            else if (conv_state[1]) conv_mul[i] <= weight_reg[36 + i - 1];       // L2 (36~71)
            else if (conv_state[2]) conv_mul[i] <= weight_reg[72 + i - 1];       // Deconv1 (72~107)
            else if (conv_state[3]) conv_mul[i] <= weight_reg[108 + i - 1];      // Deconv2 CH0 (108~143)
            else if (conv_state[4]) conv_mul[i] <= (i <= 18) ? weight_reg[126 + i - 1] : 32'd0; // Deconv2 CH1 
            else                    conv_mul[i] <= 32'd0;
        end
    end
end

wire [inst_sig_width + inst_exp_width : 0] mult_out[1:36];

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult1  (.a(mul[1]),  .b(conv_mul[1]),  .rnd(3'b0), .z(mult_out[1]),  .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult2  (.a(mul[2]),  .b(conv_mul[2]),  .rnd(3'b0), .z(mult_out[2]),  .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult3  (.a(mul[3]),  .b(conv_mul[3]),  .rnd(3'b0), .z(mult_out[3]),  .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult4  (.a(mul[4]),  .b(conv_mul[4]),  .rnd(3'b0), .z(mult_out[4]),  .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult5  (.a(mul[5]),  .b(conv_mul[5]),  .rnd(3'b0), .z(mult_out[5]),  .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult6  (.a(mul[6]),  .b(conv_mul[6]),  .rnd(3'b0), .z(mult_out[6]),  .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult7  (.a(mul[7]),  .b(conv_mul[7]),  .rnd(3'b0), .z(mult_out[7]),  .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult8  (.a(mul[8]),  .b(conv_mul[8]),  .rnd(3'b0), .z(mult_out[8]),  .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult9  (.a(mul[9]),  .b(conv_mul[9]),  .rnd(3'b0), .z(mult_out[9]),  .status());

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult10 (.a(mul[10]), .b(conv_mul[10]), .rnd(3'b0), .z(mult_out[10]), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult11 (.a(mul[11]), .b(conv_mul[11]), .rnd(3'b0), .z(mult_out[11]), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult12 (.a(mul[12]), .b(conv_mul[12]), .rnd(3'b0), .z(mult_out[12]), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult13 (.a(mul[13]), .b(conv_mul[13]), .rnd(3'b0), .z(mult_out[13]), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult14 (.a(mul[14]), .b(conv_mul[14]), .rnd(3'b0), .z(mult_out[14]), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult15 (.a(mul[15]), .b(conv_mul[15]), .rnd(3'b0), .z(mult_out[15]), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult16 (.a(mul[16]), .b(conv_mul[16]), .rnd(3'b0), .z(mult_out[16]), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult17 (.a(mul[17]), .b(conv_mul[17]), .rnd(3'b0), .z(mult_out[17]), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult18 (.a(mul[18]), .b(conv_mul[18]), .rnd(3'b0), .z(mult_out[18]), .status());

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult19 (.a(mul[1]), .b(conv_mul[19]), .rnd(3'b0), .z(mult_out[19]), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult20 (.a(mul[2]), .b(conv_mul[20]), .rnd(3'b0), .z(mult_out[20]), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult21 (.a(mul[3]), .b(conv_mul[21]), .rnd(3'b0), .z(mult_out[21]), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult22 (.a(mul[4]), .b(conv_mul[22]), .rnd(3'b0), .z(mult_out[22]), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult23 (.a(mul[5]), .b(conv_mul[23]), .rnd(3'b0), .z(mult_out[23]), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult24 (.a(mul[6]), .b(conv_mul[24]), .rnd(3'b0), .z(mult_out[24]), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult25 (.a(mul[7]), .b(conv_mul[25]), .rnd(3'b0), .z(mult_out[25]), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult26 (.a(mul[8]), .b(conv_mul[26]), .rnd(3'b0), .z(mult_out[26]), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult27 (.a(mul[9]), .b(conv_mul[27]), .rnd(3'b0), .z(mult_out[27]), .status());

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult28 (.a(mul[10]), .b(conv_mul[28]), .rnd(3'b0), .z(mult_out[28]), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult29 (.a(mul[11]), .b(conv_mul[29]), .rnd(3'b0), .z(mult_out[29]), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult30 (.a(mul[12]), .b(conv_mul[30]), .rnd(3'b0), .z(mult_out[30]), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult31 (.a(mul[13]), .b(conv_mul[31]), .rnd(3'b0), .z(mult_out[31]), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult32 (.a(mul[14]), .b(conv_mul[32]), .rnd(3'b0), .z(mult_out[32]), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult33 (.a(mul[15]), .b(conv_mul[33]), .rnd(3'b0), .z(mult_out[33]), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult34 (.a(mul[16]), .b(conv_mul[34]), .rnd(3'b0), .z(mult_out[34]), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult35 (.a(mul[17]), .b(conv_mul[35]), .rnd(3'b0), .z(mult_out[35]), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Umult36 (.a(mul[18]), .b(conv_mul[36]), .rnd(3'b0), .z(mult_out[36]), .status());

reg [inst_sig_width + inst_exp_width : 0] mul_ff [1:36];
always @(posedge clk) begin
    for(i = 1; i <= 36; i = i + 1) begin
        mul_ff[i] <= mult_out[i];
    end
end

// =========================================================================
// MAC Stage 1: Adder Tree Level 1
// =========================================================================
wire [inst_sig_width + inst_exp_width : 0] add_s1_1_w,  add_s1_2_w,  add_s1_3_w;
wire [inst_sig_width + inst_exp_width : 0] add_s1_4_w,  add_s1_5_w,  add_s1_6_w;
wire [inst_sig_width + inst_exp_width : 0] add_s1_7_w,  add_s1_8_w,  add_s1_9_w;
wire [inst_sig_width + inst_exp_width : 0] add_s1_10_w, add_s1_11_w, add_s1_12_w;

DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Uadd_s1_1  (.a(mul_ff[1]),  .b(mul_ff[2]),  .c(mul_ff[3]),  .rnd(3'b0), .z(add_s1_1_w),  .status());
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Uadd_s1_2  (.a(mul_ff[4]),  .b(mul_ff[5]),  .c(mul_ff[6]),  .rnd(3'b0), .z(add_s1_2_w),  .status());
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Uadd_s1_3  (.a(mul_ff[7]),  .b(mul_ff[8]),  .c(mul_ff[9]),  .rnd(3'b0), .z(add_s1_3_w),  .status());
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Uadd_s1_4  (.a(mul_ff[10]), .b(mul_ff[11]), .c(mul_ff[12]), .rnd(3'b0), .z(add_s1_4_w),  .status());
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Uadd_s1_5  (.a(mul_ff[13]), .b(mul_ff[14]), .c(mul_ff[15]), .rnd(3'b0), .z(add_s1_5_w),  .status());
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Uadd_s1_6  (.a(mul_ff[16]), .b(mul_ff[17]), .c(mul_ff[18]), .rnd(3'b0), .z(add_s1_6_w),  .status());
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Uadd_s1_7  (.a(mul_ff[19]), .b(mul_ff[20]), .c(mul_ff[21]), .rnd(3'b0), .z(add_s1_7_w),  .status());
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Uadd_s1_8  (.a(mul_ff[22]), .b(mul_ff[23]), .c(mul_ff[24]), .rnd(3'b0), .z(add_s1_8_w),  .status());
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Uadd_s1_9  (.a(mul_ff[25]), .b(mul_ff[26]), .c(mul_ff[27]), .rnd(3'b0), .z(add_s1_9_w),  .status());
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Uadd_s1_10 (.a(mul_ff[28]), .b(mul_ff[29]), .c(mul_ff[30]), .rnd(3'b0), .z(add_s1_10_w), .status());
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Uadd_s1_11 (.a(mul_ff[31]), .b(mul_ff[32]), .c(mul_ff[33]), .rnd(3'b0), .z(add_s1_11_w), .status());
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Uadd_s1_12 (.a(mul_ff[34]), .b(mul_ff[35]), .c(mul_ff[36]), .rnd(3'b0), .z(add_s1_12_w), .status());

reg [inst_sig_width + inst_exp_width : 0] add_s1_reg [1:12];
always @(posedge clk) begin
    add_s1_reg[1] <= add_s1_1_w;  add_s1_reg[2] <= add_s1_2_w;  add_s1_reg[3] <= add_s1_3_w;
    add_s1_reg[4] <= add_s1_4_w;  add_s1_reg[5] <= add_s1_5_w;  add_s1_reg[6] <= add_s1_6_w;
    add_s1_reg[7] <= add_s1_7_w;  add_s1_reg[8] <= add_s1_8_w;  add_s1_reg[9] <= add_s1_9_w;
    add_s1_reg[10]<= add_s1_10_w; add_s1_reg[11]<= add_s1_11_w; add_s1_reg[12]<= add_s1_12_w;
end

// =========================================================================
// MAC Stage 2: Adder Tree Level 2
// =========================================================================
wire [inst_sig_width + inst_exp_width : 0] add_s2_ch0_img0_w, add_s2_ch0_img1_w;
wire [inst_sig_width + inst_exp_width : 0] add_s2_ch1_img0_w, add_s2_ch1_img1_w;

DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Uadd_s2_1 (.a(add_s1_reg[1]),  .b(add_s1_reg[2]),  .c(add_s1_reg[3]),  .rnd(3'b0), .z(add_s2_ch0_img0_w), .status());
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Uadd_s2_2 (.a(add_s1_reg[4]),  .b(add_s1_reg[5]),  .c(add_s1_reg[6]),  .rnd(3'b0), .z(add_s2_ch0_img1_w), .status());
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Uadd_s2_3 (.a(add_s1_reg[7]),  .b(add_s1_reg[8]),  .c(add_s1_reg[9]),  .rnd(3'b0), .z(add_s2_ch1_img0_w), .status());
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Uadd_s2_4 (.a(add_s1_reg[10]), .b(add_s1_reg[11]), .c(add_s1_reg[12]), .rnd(3'b0), .z(add_s2_ch1_img1_w), .status());

reg [inst_sig_width + inst_exp_width : 0] ch0_img0_reg, ch0_img1_reg;
reg [inst_sig_width + inst_exp_width : 0] ch1_img0_reg, ch1_img1_reg;
always @(posedge clk) begin
    ch0_img0_reg <= add_s2_ch0_img0_w;
    ch0_img1_reg <= add_s2_ch0_img1_w;
    ch1_img0_reg <= add_s2_ch1_img0_w;
    ch1_img1_reg <= add_s2_ch1_img1_w;
end

// =========================================================================
// MAC Stage 3: Final Adder & Shared Norm Compare
// =========================================================================
wire [inst_sig_width + inst_exp_width : 0] conv_out_0_w, conv_out_1_w;
reg  [inst_sig_width + inst_exp_width : 0] max0, min0, max1, min1;

wire norm_calc_ch0 = (global_cnt == 65);
wire norm_calc_ch1 = (global_cnt == 129);
wire is_norm_calc  = norm_calc_ch0 | norm_calc_ch1;

wire [inst_sig_width + inst_exp_width : 0] add_final_0_a = is_norm_calc ? (norm_calc_ch1 ? max1 : max0) : ch0_img0_reg;
wire [inst_sig_width + inst_exp_width : 0] add_final_0_b = is_norm_calc ? (norm_calc_ch1 ? {~min1[31], min1[30:0]} : {~min0[31], min0[30:0]}) : ch0_img1_reg;

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Uadd_final_0 (
    .a(add_final_0_a), .b(add_final_0_b), .rnd(3'b0), .z(conv_out_0_w), .status()
);

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Uadd_final_1 (
    .a(ch1_img0_reg), .b(ch1_img1_reg), .rnd(3'b0), .z(conv_out_1_w), .status()
);

// =========================================================================
// Shared CMP & Extreme Value Tracking
// =========================================================================
reg [inst_sig_width + inst_exp_width : 0] pool_in_0_reg, pool_in_1_reg;
wire [inst_sig_width + inst_exp_width : 0] pool_in_0 = conv_out_0_w; 
wire [inst_sig_width + inst_exp_width : 0] pool_in_1 = conv_out_1_w;

always @(posedge clk) begin
    pool_in_0_reg <= pool_in_0; 
    pool_in_1_reg <= pool_in_1;
end

reg [inst_sig_width + inst_exp_width : 0] run_max_0 [0:3];
reg [inst_sig_width + inst_exp_width : 0] run_max_1 [0:3];

wire [inst_sig_width + inst_exp_width : 0] cmp_0_a = pool_en ? pool_in_0_reg : in_data_ff;
wire [inst_sig_width + inst_exp_width : 0] cmp_1_a = pool_en ? pool_in_1_reg : in_data_ff;

wire [inst_sig_width + inst_exp_width : 0] cmp_0_b = pool_en ? run_max_0[p_x] : (in_c ? max1 : max0);
wire [inst_sig_width + inst_exp_width : 0] cmp_1_b = pool_en ? run_max_1[p_x] : (in_c ? min1 : min0);

wire cmp_0_zctr = 1'b1;                  
wire cmp_1_zctr = pool_en ? 1'b1 : 1'b0; 

wire [inst_sig_width + inst_exp_width : 0] cmp_0_out, cmp_1_out;
wire        cmp_0_agtb, cmp_1_agtb; 

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Ucmp_shared_0 (
    .a(cmp_0_a), .b(cmp_0_b), .zctr(cmp_0_zctr), .z0(cmp_0_out), 
    .aeqb(), .altb(), .agtb(cmp_0_agtb), .unordered(), .z1(), .status0(), .status1()
);

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Ucmp_shared_1 (
    .a(cmp_1_a), .b(cmp_1_b), .zctr(cmp_1_zctr), .z0(cmp_1_out), 
    .aeqb(), .altb(), .agtb(cmp_1_agtb), .unordered(), .z1(), .status0(), .status1()
);

always @(posedge clk) begin
    if (image_in_valid_ff) begin
        if (in_c == 0) begin
            if (in_x == 0 && in_y == 0) begin max0 <= in_data_ff; min0 <= in_data_ff; end
            else begin max0 <= cmp_0_out; min0 <= cmp_1_out; end
        end 
        else begin
            if (in_x == 0 && in_y == 0) begin max1 <= in_data_ff; min1 <= in_data_ff; end
            else begin max1 <= cmp_0_out; min1 <= cmp_1_out; end
        end
    end
end

// =========================================================================
// Normalization Datapath
// =========================================================================
reg  [inst_sig_width + inst_exp_width : 0] add_num_a, add_num_b;
wire [inst_sig_width + inst_exp_width : 0] sub_num_out;
wire [inst_sig_width + inst_exp_width : 0] div_out;

always @(*) begin
    add_num_a = image_reg[rc][ry][rx]; 
    if (rc == 1'b1) add_num_b = {~min1[31], min1[30:0]}; 
    else            add_num_b = {~min0[31], min0[30:0]}; 
end

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Uadd_num ( 
    .a(add_num_a), .b(add_num_b), .rnd(3'b000), .z(sub_num_out), .status() 
);  

reg [inst_sig_width + inst_exp_width : 0] den_ch0_reg, den_ch1_reg;

always @(posedge clk) begin
    if (norm_calc_ch0) den_ch0_reg <= conv_out_0_w;
    if (norm_calc_ch1) den_ch1_reg <= conv_out_0_w;
end

wire [inst_sig_width + inst_exp_width : 0] cur_den = (rc == 1'b1) ? (norm_calc_ch1 ? conv_out_0_w : den_ch1_reg) : 
                                        (norm_calc_ch0 ? conv_out_0_w : den_ch0_reg);

reg [inst_sig_width + inst_exp_width : 0] num_reg, den_reg;
always @(posedge clk) begin
        num_reg <= sub_num_out;
        den_reg <= cur_den;     
end

DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Udiv ( 
    .a(num_reg), .b(den_reg), .rnd(3'b000), .z(div_out), .status() 
);

// =========================================================================
// Max Pooling Tracking & Unpooling Indices
// =========================================================================

wire        act_wb_valid;
wire        out_flag_wb;

wire [8:0]  l1_pop_thresh = 9'd230 - shift_mid;

reg [inst_sig_width + inst_exp_width : 0] shift_L1_idx_0;
reg [inst_sig_width + inst_exp_width : 0] shift_L1_idx_1;
reg [7:0]  shift_L2_idx_0;
reg [7:0]  shift_L2_idx_1;
reg [1:0]  run_max_pos_0 [0:3];
reg [1:0]  run_max_pos_1 [0:3];

wire current_is_first = (pool_x[0] == 1'b0 && pool_y[0] == 1'b0);
wire update_max_0     = current_is_first || cmp_0_agtb;
wire update_max_1     = current_is_first || cmp_1_agtb;

wire [1:0] push_idx_0 = update_max_0 ? 2'b11 : run_max_pos_0[p_x];
wire [1:0] push_idx_1 = update_max_1 ? 2'b11 : run_max_pos_1[p_x];

wire l2_unpool_pop = unpool_en; 
wire l1_unpool_pop = act_wb_valid && ~out_flag_wb && (global_cnt >= l1_pop_thresh);

always @(posedge clk) begin
    if (pool_en) begin
        run_max_0[p_x] <= update_max_0 ? pool_in_0_reg : cmp_0_out;
        run_max_1[p_x] <= update_max_1 ? pool_in_1_reg : cmp_1_out;

        if (update_max_0) run_max_pos_0[p_x] <= {pool_y[0], pool_x[0]};
        if (update_max_1) run_max_pos_1[p_x] <= {pool_y[0], pool_x[0]};

        if (pool_x[0] == 1'b1 && pool_y[0] == 1'b1) begin
            if (L1_pool_en) begin
                shift_L1_idx_0 <= {shift_L1_idx_0[29:0], push_idx_0};
                shift_L1_idx_1 <= {shift_L1_idx_1[29:0], push_idx_1};
            end 
            else if (L2_pool_en) begin
                shift_L2_idx_0 <= {shift_L2_idx_0[5:0],  push_idx_0};
                shift_L2_idx_1 <= {shift_L2_idx_1[5:0],  push_idx_1};
            end
        end
    end
    
    if (l2_unpool_pop) begin
        shift_L2_idx_0 <= {shift_L2_idx_0[5:0], 2'b00};
        shift_L2_idx_1 <= {shift_L2_idx_1[5:0], 2'b00};
    end
    if (l1_unpool_pop) begin
        shift_L1_idx_0 <= {shift_L1_idx_0[29:0], 2'b00};
        shift_L1_idx_1 <= {shift_L1_idx_1[29:0], 2'b00};
    end
    else if (instruction_in_valid) begin
        shift_L1_idx_0 <= 32'd0;
        shift_L1_idx_1 <= 32'd0;
        shift_L2_idx_0 <= 8'd0;
        shift_L2_idx_1 <= 8'd0;
    end
end

// =========================================================================
// Activation Stage 0
// =========================================================================
wire L1_L2_act_start   = pool_en && (pool_x[0] == 1'b1 && pool_y[0] == 1'b1);

wire [8:0] deconv1_start = 9'd233 - shift_mid;
wire Deconv1_act_start = (global_cnt >= deconv1_start && global_cnt <= 9'd248 - shift_mid);
wire Deconv2_act_start = (global_cnt >= 9'd249 - shift_mid && global_cnt <= 9'd376 - shift_mid); 
wire act_start         = L1_L2_act_start | Deconv1_act_start | Deconv2_act_start;

wire [7:0] deconv_out_cnt = global_cnt - deconv1_start;

wire [inst_sig_width + inst_exp_width : 0] raw_act_in_0 = (Deconv1_act_start || Deconv2_act_start) ? conv_out_0_w : (update_max_0 ? pool_in_0_reg : cmp_0_out);
wire [inst_sig_width + inst_exp_width : 0] raw_act_in_1 = Deconv1_act_start ? conv_out_1_w : (update_max_1 ? pool_in_1_reg : cmp_1_out);

wire [inst_sig_width + inst_exp_width : 0] next_exp_in_0 = (activation_temp == OP_SIGMOID) ? {~raw_act_in_0[31], raw_act_in_0[30:0]} :
                            (raw_act_in_0[30:23] == 0)      ? 32'd0 : {raw_act_in_0[31], raw_act_in_0[30:23] + 8'd1, raw_act_in_0[22:0]};
                            
wire [inst_sig_width + inst_exp_width : 0] next_exp_in_1 = (activation_temp == OP_SIGMOID) ? {~raw_act_in_1[31], raw_act_in_1[30:0]} :
                            (raw_act_in_1[30:23] == 0)      ? 32'd0 : {raw_act_in_1[31], raw_act_in_1[30:23] + 8'd1, raw_act_in_1[22:0]};

reg        relay_valid, relay_flag;
reg [1:0]  relay_px, relay_py;
reg [inst_sig_width + inst_exp_width : 0] relay_act_0, relay_act_1;
reg [inst_sig_width + inst_exp_width : 0] relay_exp_0, relay_exp_1;

reg        act_valid_s0, out_flag_s0; 
reg [1:0]  act_px_s0, act_py_s0; 
reg [inst_sig_width + inst_exp_width : 0] act_in_0_s0, act_in_1_s0;
reg [inst_sig_width + inst_exp_width : 0] exp_in_0_s0, exp_in_1_s0; 

always @(posedge clk) begin
    if (act_start) begin
        relay_act_0 <= raw_act_in_0; 
        relay_act_1 <= raw_act_in_1;
        relay_exp_0 <= next_exp_in_0; 
        relay_exp_1 <= next_exp_in_1;
        relay_px    <= Deconv1_act_start ? deconv_out_cnt[1:0] : p_x; 
        relay_py    <= Deconv1_act_start ? deconv_out_cnt[3:2] : p_y; 
    end
    relay_valid <= act_start;
    relay_flag  <= Deconv2_act_start;

    act_valid_s0 <= relay_valid;
    out_flag_s0  <= relay_flag;
    act_px_s0    <= relay_px;
    act_py_s0    <= relay_py;
    
    if (relay_valid) begin
        act_in_0_s0  <= relay_act_0; 
        act_in_1_s0  <= relay_act_1;
        exp_in_0_s0  <= relay_exp_0; 
        exp_in_1_s0  <= relay_exp_1;
    end
end

// =========================================================================
// Activation Stage 1 (Exp, ReLU, Leaky ReLU)
// =========================================================================

wire [inst_sig_width + inst_exp_width : 0] exp_out_0_w, exp_out_1_w;
DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Uexp_act0 (.a(exp_in_0_s0), .z(exp_out_0_w), .status());
DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Uexp_act1 (.a(exp_in_1_s0), .z(exp_out_1_w), .status());

wire [inst_sig_width + inst_exp_width : 0] relu_0_w     = act_in_0_s0[31] ? 32'd0 : act_in_0_s0;
wire [inst_sig_width + inst_exp_width : 0] leaky_0_w    = act_in_0_s0[31] ? ((act_in_0_s0[30:23] <= 8'd3) ? 32'd0 : {1'b1, act_in_0_s0[30:23] - 8'd3, act_in_0_s0[22:0]}) : act_in_0_s0;
wire [inst_sig_width + inst_exp_width : 0] relu_out_0_w = (activation_temp == OP_RELU) ? relu_0_w : leaky_0_w;

wire [inst_sig_width + inst_exp_width : 0] relu_1_w     = act_in_1_s0[31] ? 32'd0 : act_in_1_s0;
wire [inst_sig_width + inst_exp_width : 0] leaky_1_w    = act_in_1_s0[31] ? ((act_in_1_s0[30:23] <= 8'd3) ? 32'd0 : {1'b1, act_in_1_s0[30:23] - 8'd3, act_in_1_s0[22:0]}) : act_in_1_s0;
wire [inst_sig_width + inst_exp_width : 0] relu_out_1_w = (activation_temp == OP_RELU) ? relu_1_w : leaky_1_w;

reg        act_valid_s1;
reg        out_flag_s1;
reg  [inst_sig_width + inst_exp_width : 0] exp_out_0_s1,  exp_out_1_s1;
reg  [inst_sig_width + inst_exp_width : 0] relu_out_0_s1, relu_out_1_s1;
reg   [1:0] act_px_s1,     act_py_s1;

always @(posedge clk) begin
    act_valid_s1  <= act_valid_s0;
    out_flag_s1   <= out_flag_s0;
    exp_out_0_s1  <= exp_out_0_w;
    exp_out_1_s1  <= exp_out_1_w;
    relu_out_0_s1 <= relu_out_0_w; 
    relu_out_1_s1 <= relu_out_1_w;
    act_px_s1     <= act_px_s0;
    act_py_s1     <= act_py_s0;
end

// =========================================================================
// Activation Stage 2 (+/- 1 For Sigmoid/Tanh)
// =========================================================================
wire [inst_sig_width + inst_exp_width : 0] fp_one     = 32'h3F800000; 
wire [inst_sig_width + inst_exp_width : 0] fp_neg_one = 32'hBF800000; 

wire [inst_sig_width + inst_exp_width : 0] adder_den_0_w, adder_den_1_w;
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Uadd_den_act0 (.a(exp_out_0_s1), .b(fp_one), .rnd(3'b000), .z(adder_den_0_w), .status());
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Uadd_den_act1 (.a(exp_out_1_s1), .b(fp_one), .rnd(3'b000), .z(adder_den_1_w), .status());

wire [inst_sig_width + inst_exp_width : 0] adder_num_0_w, adder_num_1_w;
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Uadd_num_act0 (.a(exp_out_0_s1), .b(fp_neg_one), .rnd(3'b000), .z(adder_num_0_w), .status());
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Uadd_num_act1 (.a(exp_out_1_s1), .b(fp_neg_one), .rnd(3'b000), .z(adder_num_1_w), .status());

wire [inst_sig_width + inst_exp_width : 0] num_0_w = (activation_temp == OP_SIGMOID) ? fp_one : adder_num_0_w;
wire [inst_sig_width + inst_exp_width : 0] num_1_w = (activation_temp == OP_SIGMOID) ? fp_one : adder_num_1_w;

reg        act_valid_s2;
reg        out_flag_s2; 
reg  [inst_sig_width + inst_exp_width : 0] num_0_s2,      den_0_s2;
reg  [inst_sig_width + inst_exp_width : 0] num_1_s2,      den_1_s2;
reg  [inst_sig_width + inst_exp_width : 0] relu_out_0_s2, relu_out_1_s2;
reg   [1:0] act_px_s2,     act_py_s2;

always @(posedge clk) begin
    act_valid_s2  <= act_valid_s1;
    out_flag_s2   <= out_flag_s1;
    num_0_s2      <= num_0_w; 
    den_0_s2      <= adder_den_0_w;
    num_1_s2      <= num_1_w; 
    den_1_s2      <= adder_den_1_w;
    relu_out_0_s2 <= relu_out_0_s1; 
    relu_out_1_s2 <= relu_out_1_s1;
    act_px_s2     <= act_px_s1;
    act_py_s2     <= act_py_s1;
end

// =========================================================================
// Activation Stage 3 
// =========================================================================
wire [inst_sig_width + inst_exp_width : 0] div_out_0_w, div_out_1_w;

DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Udiv_act0 (.a(num_0_s2), .b(den_0_s2), .rnd(3'b000), .z(div_out_0_w), .status());
DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Udiv_act1 (.a(num_1_s2), .b(den_1_s2), .rnd(3'b000), .z(div_out_1_w), .status());

reg        act_valid_s3;
reg        out_flag_s3;
reg   [1:0] act_px_s3,      act_py_s3;
reg [inst_sig_width + inst_exp_width : 0] div_out_0_s3, div_out_1_s3;

always @(posedge clk) begin
    act_valid_s3   <= act_valid_s2;
    out_flag_s3    <= out_flag_s2;
    act_px_s3      <= act_px_s2;
    act_py_s3      <= act_py_s2;
    
    div_out_0_s3   <= div_out_0_w; 
    div_out_1_s3   <= div_out_1_w;
end

// =========================================================================
// Write Back MUXing (Fast Act Bypass)
// =========================================================================
assign act_wb_valid = is_fast_act ? act_valid_s0 : act_valid_s3;
assign out_flag_wb  = is_fast_act ? out_flag_s0  : out_flag_s3;
wire [1:0] act_px_wb  = is_fast_act ? act_px_s0  : act_px_s3;
wire [1:0] act_py_wb  = is_fast_act ? act_py_s0  : act_py_s3;

wire [inst_sig_width + inst_exp_width : 0] fast_act_0 = (activation_temp == OP_RELU) ? relu_0_w : leaky_0_w;
wire [inst_sig_width + inst_exp_width : 0] fast_act_1 = (activation_temp == OP_RELU) ? relu_1_w : leaky_1_w;

wire [inst_sig_width + inst_exp_width : 0] final_act_0_wb = is_fast_act ? fast_act_0 : div_out_0_s3;
wire [inst_sig_width + inst_exp_width : 0] final_act_1_wb = is_fast_act ? fast_act_1 : div_out_1_s3;

wire [2:0] out8_base_x = {act_px_wb, 1'b0}; 
wire [2:0] out8_base_y = {act_py_wb, 1'b0};

// =========================================================================
// Write Back & Unpooling Logic
// =========================================================================

wire [1:0] L1_idx0 = shift_L1_idx_0[31:30];
wire [1:0] L1_idx1 = shift_L1_idx_1[31:30];

wire [1:0] idx0 = shift_L2_idx_0[7:6];
wire [1:0] idx1 = shift_L2_idx_1[7:6];

wire [inst_sig_width + inst_exp_width : 0] unpool_val_0 = image_reg[0][uy][ux];
wire [inst_sig_width + inst_exp_width : 0] unpool_val_1 = image_reg[1][uy][ux];

wire [2:0] base_x = {1'b1, ux, 1'b0}; 
wire [2:0] base_y = {1'b1, uy, 1'b0};

always @(posedge clk) begin
    // Norm Write Back
    if (norm_wb_en) image_reg[wc][wy][wx] <= div_out;
    
    // Input Image Load
    if (image_in_valid_ff) image_reg[in_c][in_y][in_x] <= in_data_ff;
    
    // L1 / L2 / Deconv Activation Write Back
    if (act_wb_valid && ~out_flag_wb) begin
        if (global_cnt >= l1_pop_thresh) begin
            image_reg[0][out8_base_y][out8_base_x]         <= final_act_0_wb & {32{L1_idx0 == 2'b00}};
            image_reg[0][out8_base_y][out8_base_x + 1]     <= final_act_0_wb & {32{L1_idx0 == 2'b01}};
            image_reg[0][out8_base_y + 1][out8_base_x]     <= final_act_0_wb & {32{L1_idx0 == 2'b10}};
            image_reg[0][out8_base_y + 1][out8_base_x + 1] <= final_act_0_wb & {32{L1_idx0 == 2'b11}};
            
            image_reg[1][out8_base_y][out8_base_x]         <= final_act_1_wb & {32{L1_idx1 == 2'b00}};
            image_reg[1][out8_base_y][out8_base_x + 1]     <= final_act_1_wb & {32{L1_idx1 == 2'b01}};
            image_reg[1][out8_base_y + 1][out8_base_x]     <= final_act_1_wb & {32{L1_idx1 == 2'b10}};
            image_reg[1][out8_base_y + 1][out8_base_x + 1] <= final_act_1_wb & {32{L1_idx1 == 2'b11}};
        end 
        else begin
            image_reg[0][{1'b0, act_py_wb}][{1'b0, act_px_wb}] <= final_act_0_wb;
            image_reg[1][{1'b0, act_py_wb}][{1'b0, act_px_wb}] <= final_act_1_wb;
        end
    end
    
    // Unpooling (L2 2x2 -> 4x4)
    if (unpool_en) begin
        image_reg[0][base_y][base_x]         <= unpool_val_0 & {32{idx0 == 2'b00}};
        image_reg[0][base_y][base_x + 1]     <= unpool_val_0 & {32{idx0 == 2'b01}};
        image_reg[0][base_y + 1][base_x]     <= unpool_val_0 & {32{idx0 == 2'b10}};
        image_reg[0][base_y + 1][base_x + 1] <= unpool_val_0 & {32{idx0 == 2'b11}};
        
        image_reg[1][base_y][base_x]         <= unpool_val_1 & {32{idx1 == 2'b00}};
        image_reg[1][base_y][base_x + 1]     <= unpool_val_1 & {32{idx1 == 2'b01}};
        image_reg[1][base_y + 1][base_x]     <= unpool_val_1 & {32{idx1 == 2'b10}};
        image_reg[1][base_y + 1][base_x + 1] <= unpool_val_1 & {32{idx1 == 2'b11}};
    end
end

// =========================================================================
// Final Output (To TESTBED)
// =========================================================================
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        out_valid <= 0;
        out_data  <= 0;    
    end 
    else if (act_wb_valid && out_flag_wb) begin
        out_valid <= 1'b1;
        out_data  <= final_act_0_wb; 
    end 
    else begin
        out_valid <= 0;
        out_data  <= 0;
    end
end

endmodule