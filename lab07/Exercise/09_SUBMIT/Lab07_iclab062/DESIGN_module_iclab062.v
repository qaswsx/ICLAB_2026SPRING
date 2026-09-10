
module CLK_1_MODULE (
    input               clk, 
    input               rst_n,
    input               in_mode_valid,
    input               in_mode,
    
    input               in_valid,
    input      [1:0]    in_bank,
    input      [5:0]    in_src_row,

    output reg          out_valid,
    output reg [63:0]   out_data,

    input               out_idle,
    output reg          handshake_sready,
    output reg [8:0]    handshake_din,
    input               flag_handshake_to_clk1,
    output              flag_clk1_to_handshake,

    input               fifo_empty,
    input      [31:0]   fifo_rdata,
    output              fifo_rinc,
    output              flag_clk1_to_fifo,
    input               flag_fifo_to_clk1
);

localparam IDLE      = 2'd0;
localparam SEND_CMD  = 2'd1;
localparam WAIT_FIFO = 2'd2; 

reg  [1:0] cs, ns;
reg  [2:0] cnt;      
reg  [2:0] hand_cnt; 
reg        wait_busy;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) cs <= IDLE;
    else        cs <= ns;   
end

always @(*) begin
ns = cs;
case(cs)
    IDLE: begin
        if (cnt == 3'd3 && in_valid) ns = SEND_CMD;
    end

    SEND_CMD: begin
        if (out_idle && !wait_busy && hand_cnt == 3'd3)
            ns = WAIT_FIFO;
    end

    WAIT_FIFO: begin
        if (in_mode_valid) ns = IDLE;
    end

    default: ns = IDLE;
endcase    
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) cnt <= 0;
    else begin
        if (cs == IDLE && in_valid) cnt <= cnt + 1;
        else if (cs == SEND_CMD)        cnt <= 0;
    end
end

reg        in_mode_temp;
reg  [1:0] in_bank_temp    [0:3];
reg  [5:0] in_src_row_temp [0:3];
integer i;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) in_mode_temp <= 0;
    else if (in_mode_valid) in_mode_temp <= in_mode;
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        for (i = 0; i < 4; i = i + 1) begin
            in_bank_temp[i]    <= 0;
            in_src_row_temp[i] <= 0;
        end
    end
    else if (in_valid) begin
        in_bank_temp[cnt]    <= in_bank;
        in_src_row_temp[cnt] <= in_src_row;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        handshake_sready <= 1'b0;
        handshake_din    <= 9'b0;
        hand_cnt         <= 3'b0;
        wait_busy        <= 1'b0;
    end
    else begin
        handshake_sready <= 1'b0;

        if (cs == IDLE) begin
            hand_cnt  <= 0;
            wait_busy <= 0;

            if (ns == SEND_CMD && out_idle) begin
                handshake_sready <= 1'b1;
                handshake_din    <= {in_mode_temp, in_bank_temp[0], in_src_row_temp[0]};
                hand_cnt         <= 3'd1;
                wait_busy        <= 1'b1;
            end
        end
        else if (cs == SEND_CMD) begin
            if (out_idle && !wait_busy && hand_cnt < 4) begin
                handshake_sready <= 1'b1;
                handshake_din    <= {in_mode_temp, in_bank_temp[hand_cnt], in_src_row_temp[hand_cnt]};
                hand_cnt         <= hand_cnt + 1;
                wait_busy        <= 1'b1; 
            end
            else begin
                if (~out_idle) wait_busy <= 1'b0;
            end
        end
    end
end

reg fifo_empty_s1, fifo_empty_s2;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        fifo_empty_s1 <= 1'b1;
        fifo_empty_s2 <= 1'b1;
    end 
    else begin
        fifo_empty_s1 <= fifo_empty;
        fifo_empty_s2 <= fifo_empty_s1;
    end
end

reg  [1:0] wait_cnt;
wire       fifo_data_valid = (wait_cnt == 2'd2) && !fifo_empty_s2;
reg        fifo_rinc_raw;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        wait_cnt <= 2'd0;
    end 
    else begin
        if (fifo_empty_s2 || fifo_rinc_raw) begin
            wait_cnt <= 2'd0;
        end 
        else if (wait_cnt < 2'd2) begin
            wait_cnt <= wait_cnt + 1;
        end
    end
end

assign fifo_rinc = fifo_rinc_raw && !fifo_empty;

reg  [31:0] skid_data;
reg         skid_valid;
wire        skid_ready         = 1'b1; 
wire        skid_will_be_empty = (!skid_valid || (skid_valid && skid_ready));

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        skid_data     <= 0;
        skid_valid    <= 0;
        fifo_rinc_raw <= 0;
    end 
    else begin
        fifo_rinc_raw <= 0;

        if (skid_valid && skid_ready)
            skid_valid <= 0;

        if (fifo_data_valid && skid_will_be_empty && !fifo_rinc_raw) begin
            skid_data     <= fifo_rdata;
            skid_valid    <= 1'b1;
            fifo_rinc_raw <= 1'b1;
        end
    end
end

reg         get_lower;
reg  [31:0] upper_data;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        out_valid  <= 1'b0;
        out_data   <= 64'b0;
        get_lower  <= 1'b0;
        upper_data <= 32'b0;
    end 
    else begin
        out_valid <= 1'b0; 
        out_data  <= 0;

        if (in_mode_valid) begin
            get_lower <= 1'b0;
        end

        if (skid_valid && skid_ready) begin
            if (!get_lower) begin
                upper_data <= skid_data;
                get_lower  <= 1'b1;
            end 
            else begin
                out_valid <= 1'b1;
                out_data  <= {upper_data, skid_data};
                get_lower <= 1'b0;
            end
        end
    end
end

endmodule






module CLK_2_MODULE (
    input               clk,
    input               rst_n,
    
    output              busy,
    input               in_valid,
    input      [8:0]    in_data,
    input               flag_handshake_to_clk2,
    output              flag_clk2_to_handshake,

    input               out_fifo_full,
    output              out_valid,
    output     [31:0]   out_data,
    input               flag_fifo_to_clk2,
    output              flag_clk2_to_fifo,

    input               ar_fifo_full,
    output reg          ar_out_valid,
    output reg [31:0]   ar_out_data,
    input               ar_flag_fifo_to_wclk,
    output              ar_flag_wclk_to_fifo,

    input               r_fifo_empty,
    input      [31:0]   r_fifo_rdata,  
    output              r_fifo_rinc,
    input               r_flag_fifo_to_rclk,
    output              r_flag_rclk_to_fifo,

    output     [31:0]   ar_addr, 
    output              ar_valid, 
    output              ar_ready,
    output reg [63:0]   r_data,  
    output reg          r_valid, 
    output              r_ready
);

localparam IDLE           = 4'd0; 
localparam G_PASS1        = 4'd1; 
localparam G_DIV1         = 4'd2; 
localparam G_PASS3        = 4'd3; 
localparam C_R            = 4'd5; 
localparam C_EVAL         = 4'd6; 
localparam C_OUT          = 4'd7;
localparam C_ROOT_AR      = 4'd8; 
localparam C_ROOT_R       = 4'd9;
localparam C_PROCESS_ROOT = 4'd10; 

reg  [3:0] cs, ns;
reg  [1:0] out_state;
reg  [2:0] out_cnt;

reg  [2:0] in_cnt;
reg        in_mode;
reg  [1:0] in_bank    [0:3];
reg  [5:0] in_src_row [0:3];

reg  [10:0] ar_req_cnt; 
reg  [10:0] r_rcv_cnt;  
reg         r_merge_idx;  
reg  [31:0] r_data_lower; 

reg  [63:0] sum_reg;     
reg  [10:0] valid_N;     
reg  [30:0] mu_reg;       

reg  [72:0] sum_sq_reg;   
reg  [63:0] sigma2_reg;   

reg  [6:0]  div1_cnt, div2_cnt; 
reg  [72:0] div1_quo, div1_rem, div1_divisor; 
reg  [72:0] div2_quo, div2_rem, div2_divisor;
reg         div1_done, div2_done;

reg         calc_ar_req;      
reg  [15:0] calc_target_addr; 
reg  [1:0]  cur_tree_idx;     
reg         stack_state [0:7]; 
reg  [2:0]  stack_push; 
reg  [1:0]  stack_op    [0:7]; 
reg  [15:0] stack_r_ptr [0:7]; 
reg  signed [63:0] stack_l_val [0:7]; 
reg  signed [63:0] cur_val; 
reg  signed [63:0] final_ans   [0:3]; 

reg  [2:0]  root_ar_cnt;
reg  [2:0]  root_r_cnt;
reg  [63:0] root_buf [0:3]; 

reg  [63:0] out_buf;
reg  [1:0]  r_fifo_wait_cnt;
reg  [31:0] r_skid_data;
reg         r_skid_valid;

reg         out_pending;
reg  [63:0] out_pending_data;

reg r_fifo_empty_ff;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) r_fifo_empty_ff <= 1'b1;
    else        r_fifo_empty_ff <= r_fifo_empty;
end

wire out_busy           = (out_state != 0); 
wire r_skid_ready       = (cs == G_PASS1 || cs == G_PASS3 || cs == C_R || cs == C_ROOT_R);
wire skid_will_be_empty = (!r_skid_valid || (r_skid_valid && r_skid_ready));
wire r_fifo_data_valid  = (r_fifo_wait_cnt == 2'd2) && !r_fifo_empty_ff;
wire phase_data_ready   = ((cs == G_PASS1 || cs == G_PASS3 || cs == C_R || cs == C_ROOT_R) && r_skid_valid && r_skid_ready);

wire [30:0] cur_val_g     = r_skid_data[30:0];
wire [31:0] diff          = (cur_val_g > mu_reg) ? (cur_val_g - mu_reg) : (mu_reg - cur_val_g);

reg  [31:0] sq_in;
always @(*) begin
    if (cs == G_PASS1)
        sq_in = {1'b0, cur_val_g};
    else if (cs == G_PASS3)
        sq_in = diff;
    else
        sq_in = {1'b0, div1_quo[30:0]};
end

wire [63:0] sq_out = sq_in * sq_in;

wire        is_valid_num  = (r_skid_data[31] == 1'b0);
wire        is_within_std = (sq_out <= sigma2_reg);
wire        is_last_word  = (r_rcv_cnt == 11'd1023); 

wire trigger_output = (cs == G_PASS3) && phase_data_ready && (r_merge_idx == 1'b1) &&
                        ((is_valid_num && is_within_std) || is_last_word);
wire [63:0] target_out_data = {r_skid_data, r_data_lower};

wire signed [63:0] comb_alu_l  = stack_l_val[stack_push - 1];
wire signed [63:0] comb_alu_r  = cur_val;
wire [1:0]         comb_alu_op = stack_op[stack_push - 1];

wire op_add_c = (comb_alu_op == 2'b00); 
wire op_sub_c = (comb_alu_op == 2'b01); 
wire op_mul_c = (comb_alu_op == 2'b10); 
wire op_sra_c = (comb_alu_op == 2'b11);

wire signed [63:0] add_sub_b_c   = op_sub_c ? (~comb_alu_r + 1) : comb_alu_r;
wire signed [63:0] res_add_sub_c = comb_alu_l + add_sub_b_c;
wire signed [63:0] res_mul_c     = comb_alu_l * comb_alu_r;
wire signed [63:0] res_sra_c     = comb_alu_l >>> comb_alu_r[5:0];

wire signed [63:0] alu_out_c = ({64{op_add_c | op_sub_c}} & res_add_sub_c) | 
                                ({64{op_mul_c}} & res_mul_c) | 
                                ({64{op_sra_c}} & res_sra_c);

wire        is_pass1       = (cs == G_PASS1);
wire [1:0]  gauss_bank_idx = is_pass1 ? ar_req_cnt[1:0] : ar_req_cnt[9:8];
wire [7:0]  gauss_col      = is_pass1 ? ar_req_cnt[9:2] : ar_req_cnt[7:0];
wire [15:0] gauss_addr     = {in_bank[gauss_bank_idx], in_src_row[gauss_bank_idx], gauss_col};

reg  [6:0]  ar_inflight_cnt;

wire fire_calc_ar = calc_ar_req && !ar_fifo_full && !r_valid && (ar_inflight_cnt < 7'd8);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) cs <= IDLE;
    else        cs <= ns;
end

always @(*) begin
    ns = cs;
    case (cs)
        IDLE: begin
            if (in_cnt == 3'd4 && !in_valid) begin
                if (in_mode == 1'b1) ns = G_PASS1; 
                else                 ns = C_ROOT_AR; 
            end
        end
        G_PASS1: if (r_rcv_cnt == 11'd1024) ns = G_DIV1;
        G_DIV1:  if (div1_done && div2_done) ns = G_PASS3;
        G_PASS3: begin
            if (r_rcv_cnt == 11'd1024 && out_state == 0 && !trigger_output && !out_pending) ns = IDLE; 
        end
        
        C_ROOT_AR: if (root_ar_cnt == 3'd4) ns = C_ROOT_R; 
        C_ROOT_R:  if (root_r_cnt  == 3'd4) ns = C_PROCESS_ROOT;
        
        C_PROCESS_ROOT: begin
            if (root_buf[cur_tree_idx][63] == 1'b1) ns = C_R; 
            else ns = C_EVAL;
        end
        C_R: begin
            if (r_skid_valid && r_skid_ready && r_merge_idx == 1'b1) begin
                if (r_skid_data[31] == 1'b1) ns = C_R; 
                else if (stack_push > 0 && stack_state[stack_push - 1] == 0) ns = C_R; 
                else ns = C_EVAL; 
            end
        end
        C_EVAL: begin 
            if (stack_push == 0) begin 
                if (cur_tree_idx == 3) ns = C_OUT; 
                else ns = C_PROCESS_ROOT; 
            end 
            else begin 
                if (stack_state[stack_push - 1] == 0) ns = C_R; 
                else ns = C_EVAL; 
            end 
        end
        C_OUT:      if (out_state == 0 && out_cnt == 4) ns = IDLE;
        default:    ns = IDLE;
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        ar_inflight_cnt <= 0;
    end 
    else begin
        if ((cs == IDLE && ns == G_PASS1) || (cs == IDLE && ns == C_ROOT_AR)) begin
            ar_inflight_cnt <= 0;
        end 
        else begin
            case ({ar_out_valid, phase_data_ready && (r_merge_idx == 1'b1)})
                2'b10:   ar_inflight_cnt <= ar_inflight_cnt + 1;
                2'b01:   ar_inflight_cnt <= ar_inflight_cnt - 1;
                default: ar_inflight_cnt <= ar_inflight_cnt;
            endcase
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        r_fifo_wait_cnt <= 2'd0;
    end 
    else begin
        if (r_fifo_empty_ff  || r_fifo_rinc) begin
            r_fifo_wait_cnt <= 2'd0;
        end 
        else if (r_fifo_wait_cnt < 2'd2) begin
            r_fifo_wait_cnt <= r_fifo_wait_cnt + 1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        div1_cnt <= 0; div1_quo <= 0; div1_rem <= 0; div1_divisor <= 0; div1_done <= 0;
        div2_cnt <= 0; div2_quo <= 0; div2_rem <= 0; div2_divisor <= 0; div2_done <= 0;
    end 
    else begin
        if (cs == G_PASS1 && ns == G_DIV1) begin
            div1_cnt     <= 7'd73; div1_quo <= {9'd0, sum_reg}; div1_rem <= 73'd0; div1_divisor <= {62'd0, valid_N}; div1_done <= 0;
            div2_cnt     <= 7'd73; div2_quo <= sum_sq_reg;      div2_rem <= 73'd0; div2_divisor <= {62'd0, valid_N}; div2_done <= 0;
        end 
        else if (cs == G_DIV1) begin
            if (!div1_done) begin
                if (div1_cnt > 0) begin
                    if ({div1_rem[71:0], div1_quo[72]} >= div1_divisor) begin
                        div1_rem <= {div1_rem[71:0], div1_quo[72]} - div1_divisor; div1_quo <= {div1_quo[71:0], 1'b1};
                    end 
                    else begin
                        div1_rem <= {div1_rem[71:0], div1_quo[72]};                div1_quo <= {div1_quo[71:0], 1'b0};
                    end
                    div1_cnt <= div1_cnt - 1;
                end else div1_done <= 1'b1; 
            end
            if (!div2_done) begin
                if (div2_cnt > 0) begin
                    if ({div2_rem[71:0], div2_quo[72]} >= div2_divisor) begin
                        div2_rem <= {div2_rem[71:0], div2_quo[72]} - div2_divisor; div2_quo <= {div2_quo[71:0], 1'b1};
                    end 
                    else begin
                        div2_rem <= {div2_rem[71:0], div2_quo[72]};                div2_quo <= {div2_quo[71:0], 1'b0};
                    end
                    div2_cnt <= div2_cnt - 1;
                end 
                else div2_done <= 1'b1; 
            end
        end
        if (cs == G_DIV1 && ns == G_PASS3) begin
            div1_done <= 0; div2_done <= 0;
        end
    end
end

reg r_fifo_rinc_raw;
assign r_fifo_rinc = r_fifo_rinc_raw && !r_fifo_empty;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        r_skid_data     <= 0; r_skid_valid    <= 0; r_fifo_rinc_raw <= 0;
    end 
    else begin
        r_fifo_rinc_raw <= 0; 
        if (r_skid_valid && r_skid_ready) r_skid_valid <= 0;
        if (r_fifo_data_valid && skid_will_be_empty && !r_fifo_rinc_raw) begin
            r_skid_data     <= r_fifo_rdata; 
            r_skid_valid    <= 1'b1;
            r_fifo_rinc_raw <= 1'b1; 
        end
    end
end

always@(posedge clk or negedge rst_n) begin
    if(~rst_n) in_cnt <= 0;
    else begin
        if (cs == IDLE && in_valid) in_cnt <= in_cnt + 1;
        else if (cs != IDLE)        in_cnt <= 0;
    end
end

integer i;
always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        for(i = 0; i < 4; i = i + 1) begin in_bank[i] <= 0; in_src_row[i] <= 0; end
        in_mode <= 0;
    end 
    else if(in_valid && cs == IDLE) begin
        in_mode            <= in_data[8];
        in_bank[in_cnt]    <= in_data[7:6];
        in_src_row[in_cnt] <= in_data[5:0];
    end
end

always @(*) begin
    if ((cs == G_PASS1 || cs == G_PASS3) && ar_req_cnt < 11'd1024 && !ar_fifo_full && (ar_inflight_cnt < 7'd16)) begin
        ar_out_valid = 1'b1;
        ar_out_data  = {16'b0, gauss_addr}; 
    end 
    else if (cs == C_ROOT_AR && root_ar_cnt < 3'd4 && !ar_fifo_full && (ar_inflight_cnt < 7'd16)) begin
        ar_out_valid = 1'b1;
        ar_out_data  = {16'b0, in_bank[root_ar_cnt[1:0]], in_src_row[root_ar_cnt[1:0]], 8'd0}; 
    end
    else if (fire_calc_ar) begin
        ar_out_valid = 1'b1;
        ar_out_data  = {16'b0, calc_target_addr}; 
    end
    else begin
        ar_out_valid = 1'b0;
        ar_out_data  = 32'b0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        ar_req_cnt <= 0; r_rcv_cnt <= 0; sum_reg <= 0; valid_N <= 0; r_merge_idx <= 0; r_data_lower <= 0;
        mu_reg     <= 0; sum_sq_reg <= 0; sigma2_reg <= 0; 
        
        calc_target_addr <= 0; cur_tree_idx <= 0; stack_push <= 0;
        calc_ar_req      <= 0; 
        root_ar_cnt      <= 0; root_r_cnt   <= 0;
        
        for (i = 0; i < 4; i = i + 1) root_buf[i] <= 0;
        for (i = 0; i < 8; i = i + 1) begin stack_state[i] <= 0; stack_op[i] <= 0; stack_r_ptr[i] <= 0; stack_l_val[i] <= 0; end
        for (i = 0; i < 4; i = i + 1) final_ans[i] <= 0;
        cur_val <= 0; 
    end 
    else begin
        if (fire_calc_ar) calc_ar_req <= 1'b0;

        if (cs == IDLE && ns == G_PASS1) begin
            ar_req_cnt <= 0; r_rcv_cnt <= 0; sum_reg <= 0; sum_sq_reg <= 0; valid_N <= 0; r_merge_idx <= 0;
        end
        if (cs == IDLE && ns == C_ROOT_AR) begin
            root_ar_cnt <= 0; root_r_cnt <= 0; cur_tree_idx <= 0; stack_push <= 0; r_merge_idx <= 0;
            calc_ar_req <= 0;
        end

        if (cs == C_ROOT_AR && ar_out_valid) begin
            root_ar_cnt <= root_ar_cnt + 1;
        end

        if (cs == G_DIV1 && ns == G_PASS3) begin
            ar_req_cnt <= 0; r_rcv_cnt <= 0; r_merge_idx <= 0; 
            mu_reg      <= div1_quo[30:0]; 
            sigma2_reg  <= (div2_quo[63:0] > sq_out) ? (div2_quo[63:0] - sq_out) : 64'd0; 
        end
        
        if (ar_out_valid && (cs == G_PASS1 || cs == G_PASS3)) ar_req_cnt <= ar_req_cnt + 1;

        if (phase_data_ready) begin
            if (r_merge_idx == 1'b0) begin
                r_data_lower <= r_skid_data; r_merge_idx  <= 1'b1;
            end 
            else begin
                r_merge_idx <= 1'b0;
                if (cs == G_PASS1) begin
                    r_rcv_cnt <= r_rcv_cnt + 1; 
                    if (is_valid_num) begin 
                        sum_reg    <= sum_reg + cur_val_g; 
                        sum_sq_reg <= sum_sq_reg + {9'd0, sq_out}; 
                        valid_N    <= valid_N + 1; 
                    end
                end
                else if (cs == G_PASS3) r_rcv_cnt <= r_rcv_cnt + 1; 
                else if (cs == C_ROOT_R) begin
                    root_buf[root_r_cnt[1:0]] <= {r_skid_data, r_data_lower};
                    root_r_cnt <= root_r_cnt + 1;
                end
                else if (cs == C_R) begin
                    if (r_skid_data[31] == 1'b1) begin 
                        stack_op[stack_push]    <= r_skid_data[1:0]; 
                        stack_r_ptr[stack_push] <= r_data_lower[15:0]; 
                        stack_state[stack_push] <= 0; 
                        stack_push              <= stack_push + 1; 
                        calc_target_addr        <= r_data_lower[31:16]; 
                        calc_ar_req             <= 1'b1; 
                    end 
                    else begin 
                        cur_val <= {{33{r_skid_data[30]}}, r_skid_data[30:0]};
                        if (stack_push > 0 && stack_state[stack_push - 1] == 0) begin
                            stack_l_val[stack_push - 1] <= {{33{r_skid_data[30]}}, r_skid_data[30:0]}; 
                            stack_state[stack_push - 1] <= 1; 
                            calc_target_addr            <= stack_r_ptr[stack_push - 1]; 
                            calc_ar_req                 <= 1'b1; 
                        end
                    end
                end
            end
        end

        if (cs == C_PROCESS_ROOT) begin
            if (root_buf[cur_tree_idx][63] == 1'b1) begin 
                stack_op[stack_push]    <= root_buf[cur_tree_idx][33:32];
                stack_r_ptr[stack_push] <= root_buf[cur_tree_idx][15:0];
                stack_state[stack_push] <= 0;
                stack_push              <= stack_push + 1;
                calc_target_addr        <= root_buf[cur_tree_idx][31:16];
                calc_ar_req             <= 1'b1; 
            end 
            else begin 
                cur_val <= {{33{root_buf[cur_tree_idx][62]}}, root_buf[cur_tree_idx][62:32]};
            end
        end

        if (cs == C_EVAL && stack_push == 0) begin
            final_ans[cur_tree_idx] <= cur_val;
            if (cur_tree_idx < 3) begin 
                cur_tree_idx <= cur_tree_idx + 1; 
            end
        end
        else if (cs == C_EVAL && stack_push > 0) begin 
            if (stack_state[stack_push - 1] == 0) begin
                stack_l_val[stack_push - 1] <= cur_val; 
                stack_state[stack_push - 1] <= 1; 
                calc_target_addr            <= stack_r_ptr[stack_push - 1]; 
                calc_ar_req                 <= 1'b1; 
            end 
            else begin
                cur_val <= alu_out_c;
                stack_push <= stack_push - 1;
            end
        end 
    end
end

reg        out_valid_raw;
reg [31:0] out_data_raw;

wire consume_pending = (out_state == 0 && out_pending && !(out_valid_raw && out_fifo_full));

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        out_state        <= 0; out_buf          <= 0;
        out_valid_raw    <= 0; out_data_raw     <= 0; out_cnt          <= 0;
        out_pending      <= 0; out_pending_data <= 0;
    end 
    else begin
        if ((cs == IDLE && ns == G_PASS1) || (cs == IDLE && ns == C_ROOT_AR)) begin
            out_state <= 0; out_cnt <= 0; out_pending <= 0;
        end

        if (trigger_output) begin
            out_pending      <= 1'b1; out_pending_data <= target_out_data;
        end 
        else if (consume_pending) begin
            out_pending      <= 1'b0;
        end

        if (out_valid_raw && out_fifo_full) begin
            out_valid_raw <= out_valid_raw; out_data_raw  <= out_data_raw;
        end 
        else begin
            case (out_state)
                0: begin 
                    if (out_pending) begin 
                        out_buf       <= out_pending_data; 
                        out_valid_raw <= 1'b1;
                        out_data_raw  <= out_pending_data[63:32]; 
                        out_state     <= 1; 
                    end 
                    else if (cs == C_OUT && out_cnt < 4) begin 
                        out_buf       <= final_ans[out_cnt];
                        out_valid_raw <= 1'b1;
                        out_data_raw  <= final_ans[out_cnt][63:32]; 
                        out_state     <= 1; 
                    end
                    else out_valid_raw <= 1'b0;
                end
                1: begin 
                    out_valid_raw <= 1'b1; out_data_raw  <= out_buf[31:0]; 
                    out_state     <= 0; 
                    if (cs == C_OUT) out_cnt <= out_cnt + 1;
                end
                default: out_state <= 0;
            endcase
        end
    end
end

assign out_valid = out_valid_raw && !out_fifo_full;
assign out_data  = out_valid ? out_data_raw : 32'd0;

assign busy = (cs != IDLE);

assign ar_addr  = ar_valid ? {16'b0, ar_out_data[15:0]} : 32'b0;
assign ar_valid = ar_out_valid; assign ar_ready = ar_valid;  
assign r_ready  = r_valid;    

always @(*) begin
    if ((cs == G_PASS1 || cs == G_PASS3 || cs == C_R || cs == C_ROOT_R) && r_skid_valid && r_skid_ready && r_merge_idx == 1'b1) begin
        r_valid = 1'b1; r_data  = {r_skid_data, r_data_lower}; 
    end 
    else begin
        r_valid = 1'b0; r_data  = 64'b0; 
    end
end

endmodule













module CLK_3_MODULE (
    input               clk, rst_n,
    input               r_fifo_full,
    output              r_out_valid,
    output     [31:0]   r_out_data,

    input               ar_fifo_empty,
    input      [31:0]   ar_fifo_rdata,
    output              ar_fifo_rinc,

    input               ar_flag_fifo_to_rclk, r_flag_fifo_to_wclk,
    output              ar_flag_rclk_to_fifo, r_flag_wclk_to_fifo,

    output     [31:0]   ar_addr, 
    output reg          ar_valid, 
    output              ar_ready,
    
    output reg [63:0]   r_data,  
    output reg          r_valid, 
    output reg          r_ready,

    output reg [3:0]    dram_cmd,  
    output reg [1:0]    dram_ba,
    output reg [10:0]   dram_addr,
    output reg [63:0]   dram_wdata,
    input      [63:0]   dram_rdata,
    input               dram_valid
);

reg         r_fifo_full_ff;
reg         ar_fifo_empty_ff;
reg  [31:0] ar_fifo_rdata_ff;
reg         dram_valid_ff;
reg  [63:0] dram_rdata_ff;
reg req_valid;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        r_fifo_full_ff   <= 1'b0;
        ar_fifo_empty_ff <= 1'b1; 
        ar_fifo_rdata_ff <= 32'd0;
        dram_valid_ff    <= 1'b0;
        dram_rdata_ff    <= 64'd0;
    end 
    else begin
        r_fifo_full_ff   <= r_fifo_full;
        ar_fifo_empty_ff <= ar_fifo_empty;
        ar_fifo_rdata_ff <= ar_fifo_rdata;
        dram_valid_ff    <= dram_valid;
        dram_rdata_ff    <= dram_rdata;
    end
end

reg ar_fifo_empty_ctrl;
reg ar_fifo_empty_data;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        ar_fifo_empty_ctrl <= 1'b1;
        ar_fifo_empty_data <= 1'b1;
    end else begin
        ar_fifo_empty_ctrl <= ar_fifo_empty_ff;
        ar_fifo_empty_data <= ar_fifo_empty_ff;
    end
end

wire [3:0] req_read, req_act, req_pre;
wire [3:0] grant_read, grant_act, grant_pre;

reg [31:0] ar_addr_hold;
reg [31:0] ar_addr_mon;
wire [1:0] target_bank = ar_addr_hold[15:14];
wire [5:0] target_row  = ar_addr_hold[13:8];
wire [7:0] target_col  = ar_addr_hold[7:0];

wire issue_full;
wire can_dispatch = !issue_full;
reg  [1:0] issue_bank_q [0:15];
reg  [5:0] issue_row_q  [0:15];
reg  [7:0] issue_col_q  [0:15];

reg  [4:0] wptr, rptr;
wire [4:0] q_count = wptr - rptr;

assign issue_full  = (q_count >= 5'd16);
wire   issue_empty = (wptr == rptr);

wire [1:0] head_bank = issue_bank_q[rptr[3:0]];
wire [5:0] head_row  = issue_row_q [rptr[3:0]];
wire [7:0] head_col  = issue_col_q [rptr[3:0]];

assign ar_addr = ar_valid ? ar_addr_mon : 32'd0;
assign ar_ready = ar_valid;

reg  [1:0] ar_fifo_wait_cnt;

wire ar_data_valid = (ar_fifo_wait_cnt == 2'd3) && !ar_fifo_empty_data;
reg  ar_fifo_rinc_raw;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        ar_fifo_wait_cnt <= 2'd0;
    end 
    else begin
        if (ar_fifo_empty_ctrl || ar_fifo_rinc_raw) ar_fifo_wait_cnt <= 2'd0;
        else if (ar_fifo_wait_cnt < 2'd3)           ar_fifo_wait_cnt <= ar_fifo_wait_cnt + 1;
    end
end

assign ar_fifo_rinc = ar_fifo_rinc_raw && !ar_fifo_empty;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        ar_addr_hold     <= 32'd0;
        ar_fifo_rinc_raw <= 1'b0;
        req_valid <= 1'b0;
    end 
    else begin
        ar_fifo_rinc_raw <= 1'b0;
        if (req_valid && can_dispatch)
            req_valid <= 1'b0;

        if (!req_valid && ar_data_valid && !ar_fifo_rinc_raw) begin
            ar_addr_hold     <= ar_fifo_rdata_ff;
            req_valid        <= 1'b1;
            ar_fifo_rinc_raw <= 1'b1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        ar_valid    <= 1'b0;
        ar_addr_mon <= 32'd0;
    end 
    else begin
        ar_valid <= |grant_read;
        if (|grant_read)
            ar_addr_mon <= {16'b0, head_bank, head_row, head_col};
        else
            ar_addr_mon <= 32'd0;
    end
end

reg  [63:0] catch_q [0:15];
reg  [4:0]  cq_wptr, cq_rptr;
wire [4:0]  cq_count = cq_wptr - cq_rptr;
wire        cq_empty = (cq_wptr == cq_rptr);
wire        cq_full  = (cq_count >= 15);

wire        int_r_valid = dram_valid_ff;
wire        int_r_ready = !cq_full;
wire [63:0] int_r_data  = dram_rdata_ff;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) cq_wptr <= 0;
    else if (int_r_valid && int_r_ready) begin
        catch_q[cq_wptr[3:0]] <= int_r_data;
        cq_wptr <= cq_wptr + 1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        r_valid <= 1'b0;
        r_ready <= 1'b0;
        r_data  <= 64'd0;
    end 
    else begin
        r_valid <= int_r_valid;
        r_ready <= int_r_ready;
        r_data  <= int_r_valid ? int_r_data : 64'd0; 
    end
end

assign ar_flag_rclk_to_fifo = 1'b0;
assign r_flag_wclk_to_fifo  = 1'b0;

reg         r_out_valid_raw;
reg  [31:0] r_out_data_raw;

assign r_out_valid = r_out_valid_raw && !r_fifo_full;
assign r_out_data  = r_out_valid ? r_out_data_raw : 32'd0;
reg r_write_state;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        r_out_valid_raw <= 0;
        r_out_data_raw  <= 0;
        r_write_state   <= 0;
        cq_rptr         <= 0;
    end 
    else begin
        if (r_out_valid_raw && r_fifo_full_ff) begin
            r_out_valid_raw <= r_out_valid_raw;
            r_out_data_raw  <= r_out_data_raw;
        end 
        else begin
            case (r_write_state)
                1'b0: begin
                    if (!cq_empty) begin
                        r_out_valid_raw <= 1;
                        r_out_data_raw  <= catch_q[cq_rptr[3:0]][31:0];
                        r_write_state   <= 1'b1;
                    end 
                    else begin
                        r_out_valid_raw <= 0;
                    end
                end
                1'b1: begin
                    r_out_valid_raw <= 1;
                    r_out_data_raw  <= catch_q[cq_rptr[3:0]][63:32];
                    r_write_state   <= 1'b0;
                    cq_rptr         <= cq_rptr + 1;
                end
            endcase
        end
    end
end

reg        prep_valid [0:3];
reg [5:0]  prep_row   [0:3];

integer bi, qi;
reg [3:0] scan_idx;

always @(*) begin
    for (bi = 0; bi < 4; bi = bi + 1) begin
        prep_valid[bi] = 1'b0;
        prep_row[bi]   = 6'd0;
    end

    for (qi = 0; qi < 12; qi = qi + 1) begin
        if (qi < q_count) begin
            scan_idx = rptr[3:0] + qi[3:0]; 

            if (!prep_valid[issue_bank_q[scan_idx]]) begin
                prep_valid[issue_bank_q[scan_idx]] = 1'b1;
                prep_row[issue_bank_q[scan_idx]]   = issue_row_q[scan_idx];
            end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        wptr <= 0;
        rptr <= 0;
    end 
    else begin
        if (req_valid && can_dispatch) begin
            issue_bank_q[wptr[3:0]] <= target_bank;
            issue_row_q [wptr[3:0]] <= target_row;
            issue_col_q [wptr[3:0]] <= target_col;
            wptr <= wptr + 1;
        end

        if (|grant_read) begin
            rptr <= rptr + 1;
        end
    end
end

reg [3:0] inflight_cnt;

reg [3:0] bank_inflight_cnt [0:3]; 
wire bank_read_busy [0:3];

assign bank_read_busy[0] = (bank_inflight_cnt[0] != 0);
assign bank_read_busy[1] = (bank_inflight_cnt[1] != 0);
assign bank_read_busy[2] = (bank_inflight_cnt[2] != 0);
assign bank_read_busy[3] = (bank_inflight_cnt[3] != 0);

reg [1:0] rd_bank_q [0:15];
reg [4:0] rd_wptr, rd_rptr;
integer rb;

reg is_grant  [0:3];
reg is_retire [0:3];

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        rd_wptr <= 0;
        rd_rptr <= 0;
        for (rb = 0; rb < 4; rb = rb + 1) begin
            bank_inflight_cnt[rb] <= 4'd0;
            is_grant[rb]  <= 1'b0;
            is_retire[rb] <= 1'b0;
        end
    end 
    else begin
        for (rb = 0; rb < 4; rb = rb + 1) begin
            is_grant[rb]  <= (|grant_read) && (head_bank == rb);
            is_retire[rb] <= (int_r_valid && int_r_ready) && (rd_bank_q[rd_rptr[3:0]] == rb);
        end

        for (rb = 0; rb < 4; rb = rb + 1) begin
            case ({is_grant[rb], is_retire[rb]})
                2'b10: bank_inflight_cnt[rb] <= bank_inflight_cnt[rb] + 1'b1;
                2'b01: bank_inflight_cnt[rb] <= bank_inflight_cnt[rb] - 1'b1;
                default: bank_inflight_cnt[rb] <= bank_inflight_cnt[rb];
            endcase
        end

        if (|grant_read) begin
            rd_bank_q[rd_wptr[3:0]] <= head_bank;
            rd_wptr <= rd_wptr + 1'b1;
        end

        if (int_r_valid && int_r_ready) begin
            rd_rptr <= rd_rptr + 1'b1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        inflight_cnt <= 0;
    end else begin
        case ({(|grant_read), (int_r_valid && int_r_ready)})
            2'b10:   inflight_cnt <= inflight_cnt + 1;
            2'b01:   inflight_cnt <= inflight_cnt - 1;
            default: inflight_cnt <= inflight_cnt;
        endcase
    end
end

wire can_send_read = (inflight_cnt < 4'd12) && !cq_full;

localparam S_CLOSED   = 2'd0;
localparam S_ACT_WAIT = 2'd1;
localparam S_OPEN     = 2'd2;
localparam S_PRE_WAIT = 2'd3;

reg [1:0] bank_state      [0:3];
reg [2:0] bank_timer      [0:3];
reg [2:0] ras_timer       [0:3]; 
reg [5:0] bank_active_row [0:3];

genvar i;
generate
    for (i = 0; i < 4; i = i + 1) begin : BANK_FSM

        wire head_can_read =
            !issue_empty &&
            (bank_state[head_bank] == S_OPEN) &&
            (bank_active_row[head_bank] == head_row);

        assign req_read[i] =
            (head_bank == i) &&
            head_can_read &&
            can_send_read;

        assign req_act[i] =
            prep_valid[i] &&
            (bank_state[i] == S_CLOSED);

        assign req_pre[i] =
            (bank_state[i] == S_OPEN) &&
            (ras_timer[i] >= 3'd5) &&
            !bank_read_busy[i] &&
            prep_valid[i] && (bank_active_row[i] != prep_row[i]);

        always @(posedge clk or negedge rst_n) begin
            if (~rst_n) begin
                bank_state[i]      <= S_CLOSED;
                bank_timer[i]      <= 0;
                ras_timer[i]       <= 0;
                bank_active_row[i] <= 0;
            end 
            else begin
                if (bank_timer[i] > 0) bank_timer[i] <= bank_timer[i] - 1;
                
                if ((bank_state[i] == S_ACT_WAIT) || (bank_state[i] == S_OPEN)) begin
                    if (ras_timer[i] < 3'd7) ras_timer[i] <= ras_timer[i] + 1;
                end

                case (bank_state[i])
                    S_CLOSED: begin
                        if (grant_act[i]) begin
                            bank_state[i]      <= S_ACT_WAIT;
                            bank_timer[i]      <= 3'd2; // t_RCD
                            ras_timer[i]       <= 3'd1;
                            bank_active_row[i] <= prep_row[i];
                        end
                    end
                    S_ACT_WAIT: begin
                        if (bank_timer[i] == 3'd1) begin
                            bank_state[i] <= S_OPEN;
                        end
                    end
                    S_OPEN: begin
                        if (grant_pre[i]) begin
                            bank_state[i] <= S_PRE_WAIT;
                            bank_timer[i] <= 3'd2; 
                            ras_timer[i]  <= 0;
                        end
                    end
                    S_PRE_WAIT: begin
                        if (bank_timer[i] == 3'd1) begin
                            bank_state[i] <= S_CLOSED;
                        end
                    end
                endcase
            end
        end
    end
endgenerate

wire any_read = |req_read;
wire any_act  = |req_act;

assign grant_read[0] = req_read[0];
assign grant_read[1] = req_read[1] & ~req_read[0];
assign grant_read[2] = req_read[2] & ~(req_read[1] | req_read[0]);
assign grant_read[3] = req_read[3] & ~(req_read[2] | req_read[1] | req_read[0]);

assign grant_act[0]  = req_act[0]  & ~any_read;
assign grant_act[1]  = req_act[1]  & ~any_read & ~req_act[0];
assign grant_act[2]  = req_act[2]  & ~any_read & ~(req_act[1]  | req_act[0]);
assign grant_act[3]  = req_act[3]  & ~any_read & ~(req_act[2]  | req_act[1]  | req_act[0]);

assign grant_pre[0]  = req_pre[0]  & ~any_read & ~any_act;
assign grant_pre[1]  = req_pre[1]  & ~any_read & ~any_act & ~req_pre[0];
assign grant_pre[2]  = req_pre[2]  & ~any_read & ~any_act & ~(req_pre[1]  | req_pre[0]);
assign grant_pre[3]  = req_pre[3]  & ~any_read & ~any_act & ~(req_pre[2]  | req_pre[1]  | req_pre[0]);

wire [1:0] act_bank =
    grant_act[0] ? 2'd0 :
    grant_act[1] ? 2'd1 :
    grant_act[2] ? 2'd2 : 2'd3;

wire [5:0] act_row =
    grant_act[0] ? prep_row[0] :
    grant_act[1] ? prep_row[1] :
    grant_act[2] ? prep_row[2] :
                prep_row[3];

wire [1:0] pre_bank =
    grant_pre[0] ? 2'd0 :
    grant_pre[1] ? 2'd1 :
    grant_pre[2] ? 2'd2 : 2'd3;
    
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        dram_cmd   <= 4'b0000; 
        dram_ba    <= 0;
        dram_addr  <= 0;
        dram_wdata <= 0;       
    end else begin
        dram_cmd   <= 4'b0111; // NOP / Default
        dram_wdata <= 0;
        if (|grant_read) begin
            dram_cmd  <= 4'b0101; // READ
            dram_ba   <= head_bank;
            dram_addr <= {3'd0, head_col};
        end
        else if (|grant_act) begin
            dram_cmd  <= 4'b0011; // ACT
            dram_ba   <= act_bank;
            dram_addr <= {5'd0, act_row};
        end
        else if (|grant_pre) begin
            dram_cmd  <= 4'b0010; // PRE
            dram_ba   <= pre_bank;
            dram_addr <= 0;
        end
    end
end

endmodule
