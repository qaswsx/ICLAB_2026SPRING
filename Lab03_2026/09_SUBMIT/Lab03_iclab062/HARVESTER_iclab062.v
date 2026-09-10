module HARVESTER(
    input               clk, 
    input               rst_n,
    input               in_mode_valid,
    input               in_valid,
    input       [1:0]   in_mode,
    input       [1:0]   in_bank,
    input       [5:0]   in_src_row,
    input       [5:0]   in_dst_row,
    input       [63:0]  in_data,
    output              out_valid,
    output      [63:0]  out_data,
    
    output      [31:0]  aw_addr, 
    output              aw_valid, 
    input               aw_ready,
    output      [63:0]  w_data,  
    output              w_valid,  
    input               w_ready,
    input       [1:0]   b_resp,  
    input               b_valid,  
    output              b_ready,
    output      [31:0]  ar_addr, 
    output              ar_valid, 
    input               ar_ready,
    input       [63:0]  r_data,  
    input       [1:0]   r_resp, 
    input               r_valid, 
    output              r_ready
);

reg        in_valid_r;
reg [1:0]  in_bank_r;
reg [5:0]  in_src_row_r;
reg [5:0]  in_dst_row_r;
reg [63:0] in_data_r;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        in_valid_r   <= 0; 
        in_bank_r    <= 0;
        in_src_row_r <= 0; 
        in_dst_row_r <= 0; 
        in_data_r    <= 0;
    end 
    else begin
        in_valid_r   <= in_valid;
        if (in_valid) begin
            in_bank_r    <= in_bank; 
            in_src_row_r <= in_src_row;
            in_dst_row_r <= in_dst_row; 
            in_data_r    <= in_data;
        end
    end
end

reg [1:0] mode_reg;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) mode_reg <= 0;
    else if (in_mode_valid) mode_reg <= in_mode; 
end

localparam TOP_IDLE =  0; 
localparam TOP_READ =  1; 
localparam TOP_WRITE = 2; 
localparam TOP_CALC =  3; 
localparam TOP_SORT =  4;

reg [2:0] top_state;
wire read_done, write_done, calc_done, sort_done;

wire start_read  = (top_state == TOP_IDLE && in_valid_r && mode_reg == 0);
wire start_write = (top_state == TOP_IDLE && in_valid_r && mode_reg == 1);
wire start_calc  = (top_state == TOP_IDLE && in_valid_r && mode_reg == 2);
wire start_sort  = (top_state == TOP_IDLE && in_valid_r && mode_reg == 3);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) top_state <= TOP_IDLE;
    else case(top_state)
        TOP_IDLE: begin
            if (in_valid_r) begin
                if (mode_reg == 0) top_state <= TOP_READ;
                else if (mode_reg == 1) top_state <= TOP_WRITE;
                else if (mode_reg == 2) top_state <= TOP_CALC;
                else if (mode_reg == 3) top_state <= TOP_SORT;
            end
        end
        TOP_READ:  if (read_done)  top_state <= TOP_IDLE;
        TOP_WRITE: if (write_done) top_state <= TOP_IDLE;
        TOP_CALC:  if (calc_done)  top_state <= TOP_IDLE;
        TOP_SORT:  if (sort_done)  top_state <= TOP_IDLE;
    endcase
end

wire [31:0] r_ar_addr, c_ar_addr, s_ar_addr;
wire r_ar_valid, c_ar_valid, s_ar_valid;
wire r_r_ready, c_r_ready, s_r_ready;

wire [31:0] w_aw_addr, s_aw_addr;
wire w_aw_valid, s_aw_valid;
wire [63:0] w_w_data, s_w_data;
wire w_w_valid, s_w_valid;
wire w_b_ready, s_b_ready;

wire r_out_valid, c_out_valid, w_out_valid, s_out_valid;
wire [63:0] r_out_data, c_out_data;

assign ar_addr   = r_ar_addr | c_ar_addr | s_ar_addr;
assign ar_valid  = r_ar_valid | c_ar_valid | s_ar_valid;
assign r_ready   = r_r_ready | c_r_ready | s_r_ready;

assign aw_addr   = w_aw_addr | s_aw_addr;
assign aw_valid  = w_aw_valid | s_aw_valid;
assign w_data    = w_w_data | s_w_data;
assign w_valid   = w_w_valid | s_w_valid;
assign b_ready   = w_b_ready | s_b_ready;

assign out_valid = r_out_valid | w_out_valid | c_out_valid | s_out_valid;
assign out_data  = r_out_data | c_out_data;

wire        shared_we;
wire [5:0]  shared_waddr;
wire [63:0] shared_wdata;
wire [5:0]  shared_raddr;
wire [63:0] shared_rdata;

harvester_read u_read (
    .clk(clk), .rst_n(rst_n), .start(start_read),
    .in_bank(in_bank_r), .in_src_row(in_src_row_r),
    .ar_addr(r_ar_addr), .ar_valid(r_ar_valid), .ar_ready(ar_ready), 
    .r_data(r_data), .r_valid(r_valid), .r_ready(r_r_ready),
    .out_valid(r_out_valid), .out_data(r_out_data), .done(read_done)
);

harvester_write u_write (
    .clk(clk), .rst_n(rst_n), .start(start_write),
    .in_valid(in_valid_r), .in_data(in_data_r),
    .in_bank(in_bank_r), .in_dst_row(in_dst_row_r),
    .aw_addr(w_aw_addr), .aw_valid(w_aw_valid), .aw_ready(aw_ready),  
    .w_data(w_w_data), .w_valid(w_w_valid), .w_ready(w_ready),   
    .b_valid(b_valid), .b_ready(w_b_ready),
    .out_valid(w_out_valid), .done(write_done),
    .buf_we(shared_we), .buf_waddr(shared_waddr), .buf_wdata(shared_wdata),
    .buf_raddr(shared_raddr), .buf_rdata(shared_rdata)
);

harvester_calc u_calc (
    .clk(clk), .rst_n(rst_n), .start(start_calc),
    .in_src_row(in_src_row_r),
    .ar_addr(c_ar_addr), .ar_valid(c_ar_valid), .ar_ready(ar_ready),  
    .r_data(r_data), .r_valid(r_valid), .r_ready(c_r_ready),
    .out_valid(c_out_valid), .out_data(c_out_data), .done(calc_done)
);

harvester_sort u_sort (
    .clk(clk), .rst_n(rst_n), .start(start_sort),
    .in_src_row(in_src_row_r), .in_dst_row(in_dst_row_r),
    .ar_addr(s_ar_addr), .ar_valid(s_ar_valid), .ar_ready(ar_ready),  
    .r_data(r_data), .r_valid(r_valid), .r_ready(s_r_ready),
    .aw_addr(s_aw_addr), .aw_valid(s_aw_valid), .aw_ready(aw_ready),  
    .w_data(s_w_data), .w_valid(s_w_valid), .w_ready(w_ready),   
    .b_valid(b_valid), .b_ready(s_b_ready),
    .out_valid(s_out_valid), .done(sort_done),
    .ext_we(shared_we), .ext_waddr(shared_waddr), .ext_wdata(shared_wdata),
    .ext_raddr(shared_raddr), .ext_rdata(shared_rdata)
);
endmodule

module harvester_read (
    input clk, rst_n, start,
    input [1:0] in_bank, input [5:0] in_src_row,
    output wire [31:0] ar_addr, output wire ar_valid, input ar_ready,
    input [63:0] r_data, input r_valid, output wire r_ready,
    output reg out_valid, output reg [63:0] out_data, output reg done
);
reg busy;

reg [1:0] bank_reg; 
reg [5:0] src_row_reg;
always @(posedge clk) begin
    if (start) begin 
        bank_reg <= in_bank; 
        src_row_reg <= in_src_row; 
    end
end

reg [8:0] ar_cnt, r_cnt;
wire ar_hs = ar_valid && ar_ready; 
wire r_hs  = r_valid && r_ready;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin 
        busy <= 0; 
        ar_cnt <= 0; 
        r_cnt <= 0; 
    end 
    else begin
        if (start) begin 
            busy <= 1; 
            ar_cnt <= 0; 
            r_cnt <= 0; 
        end 
        else if (busy) begin
            if (ar_hs) ar_cnt <= ar_cnt + 1;
            if (r_hs) begin
                r_cnt <= r_cnt + 1;
                if (r_cnt == 255) busy <= 0; 
            end
        end
    end
end

assign ar_valid = busy && (ar_cnt < 256);
assign ar_addr  = ar_valid ? {16'b0, bank_reg, src_row_reg, ar_cnt[7:0]} : 0;
assign r_ready  = busy && (r_cnt < 256);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin 
        out_valid <= 0; 
        done <= 0; 
    end 
    else begin
        done <= 0;
        if (busy) begin
            out_valid <= r_hs;
            if (r_hs && r_cnt == 255) done <= 1;
        end 
        else begin
            out_valid <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) 
        out_data <= 0;
    else if (busy && r_hs) out_data <= r_data;
    else out_data <= 64'd0;
end

endmodule

module harvester_write (
    input clk, rst_n, start,
    input in_valid, input [63:0] in_data,
    input [1:0] in_bank, input [5:0] in_dst_row,
    output wire [31:0] aw_addr, output reg aw_valid, input aw_ready, 
    output wire [63:0] w_data,  output reg w_valid, input w_ready,   
    input b_valid, output reg b_ready,
    output reg out_valid, output reg done,
    output wire buf_we, output wire [5:0] buf_waddr, output wire [63:0] buf_wdata,
    output wire [5:0] buf_raddr, input [63:0] buf_rdata
);
reg busy;

reg [1:0] bank_reg; 
reg [5:0] dst_row_reg;

always @(posedge clk) begin
    if (start) begin 
        bank_reg <= in_bank; 
        dst_row_reg <= in_dst_row; 
    end
end

reg [8:0] in_cnt, aw_cnt, w_cnt;
reg [7:0] b_cnt; 

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin 
        busy <= 0; 
    end 
    else if (start) begin 
        busy <= 1; 
    end 
    else if (b_valid && b_ready && b_cnt == 255) begin
        busy <= 0;
    end
end

wire aw_hs = aw_valid && aw_ready;
wire w_hs  = w_valid && w_ready;
wire b_hs  = b_valid && b_ready;

wire [8:0] nxt_in_cnt = in_cnt + in_valid;
wire [8:0] nxt_aw_cnt = aw_cnt + aw_hs;
wire [8:0] nxt_w_cnt  = w_cnt + w_hs;

assign buf_we    = start | (busy && in_valid);
assign buf_waddr = start ? 0 : in_cnt[5:0];
assign buf_wdata = in_data;
assign buf_raddr = nxt_w_cnt[5:0];

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) in_cnt <= 0;
    else if (start) in_cnt <= 1;
    else if (busy && in_valid) in_cnt <= in_cnt + 1;
end

assign aw_addr = aw_valid ? {16'b0, bank_reg, dst_row_reg, aw_cnt[7:0]} : 32'd0;

wire aw_throttle = ((aw_cnt - w_cnt) < 32);
always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin 
        aw_valid <= 0; 
        aw_cnt <= 0; 
    end 
    else if (start) begin 
        aw_valid <= 1; 
        aw_cnt <= 0; 
    end 
    else if (busy) begin
        if (aw_hs) aw_cnt <= aw_cnt + 1;
        if (nxt_aw_cnt == 256) 
            aw_valid <= 0;
        else if (nxt_aw_cnt < nxt_in_cnt && aw_throttle) 
            aw_valid <= 1;
        else 
            aw_valid <= 0;
    end 
    else begin 
        aw_valid <= 0; 
        aw_cnt <= 0; 
    end
end

reg [63:0] w_data_internal; 
wire [63:0] w_data_src = (nxt_w_cnt == in_cnt && in_valid) ? in_data : buf_rdata;

always @(posedge clk) begin
    if (start) w_data_internal <= in_data;
    else if (busy && nxt_w_cnt < nxt_in_cnt) w_data_internal <= w_data_src;
end

assign w_data = w_valid ? w_data_internal : 64'd0;

always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin 
        w_valid <= 0; 
        w_cnt <= 0; 
    end 
    else if (start) begin 
        w_valid <= 1; 
        w_cnt <= 0; 
    end 
    else if (busy) begin
        if (w_hs) w_cnt <= w_cnt + 1;
        
        if (nxt_w_cnt == 256)  
            w_valid <= 0; 
        else if (nxt_w_cnt < nxt_in_cnt) 
            w_valid <= 1;
        else 
            w_valid <= 0;
    end 
    else begin 
        w_valid <= 0; 
        w_cnt <= 0; 
    end
end

always@(posedge clk or negedge rst_n) begin 
    if(~rst_n) b_ready <= 0; 
    else b_ready <= 1; 
end

always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin 
        b_cnt <= 0; 
        out_valid <= 0; 
        done <= 0; 
    end 
    else begin
        done <= 0; out_valid <= 0;
        if (!busy) begin 
            b_cnt <= 0; 
        end 
        else if (b_hs) begin
            b_cnt <= b_cnt + 1;
            if (b_cnt == 255) begin 
                out_valid <= 1; 
                done <= 1; 
            end 
        end
    end
end
endmodule

module harvester_calc (
    input clk, rst_n, start,
    input [5:0] in_src_row,
    output reg [31:0] ar_addr, output reg ar_valid, input ar_ready,
    input [63:0] r_data, input r_valid, output reg r_ready,
    output reg out_valid, output reg [63:0] out_data, output reg done
);
localparam IDLE          = 0; 
localparam CALC_AR       = 1; 
localparam CALC_R        = 2; 
localparam CALC_EVAL     = 3; 
localparam CALC_ALU_EXEC = 4; 
localparam CALC_ALU_WB   = 5; 
localparam CALC_OUT      = 6;

reg [2:0] cs, ns; 
reg [5:0] src_row_reg;

wire ar_handshake = ar_valid && ar_ready; 
wire r_handshake  = r_valid && r_ready;

reg [31:0] calc_target_addr; 
reg [1:0]  cur_tree_idx;     
reg        stack_state [0:7]; 
reg [2:0]  stack_push; 
reg [8:0]  out_cnt;

reg [1:0]  stack_op [0:7]; 
reg [15:0] stack_r_ptr [0:7]; 
reg signed [63:0] stack_l_val [0:7]; 
reg signed [63:0] cur_val; 
reg signed [63:0] final_ans [0:3]; 

reg signed [63:0] alu_in_l_reg, alu_in_r_reg; 
reg [1:0] alu_op_reg; 
reg signed [63:0] alu_out_reg;

wire op_add = (alu_op_reg == 2'b00); 
wire op_sub = (alu_op_reg == 2'b01); 
wire op_mul = (alu_op_reg == 2'b10); 
wire op_sra = (alu_op_reg == 2'b11);

wire signed [63:0] add_sub_b   = op_sub ? (~alu_in_r_reg + 1) : alu_in_r_reg;
wire signed [63:0] res_add_sub = alu_in_l_reg + add_sub_b;
wire signed [63:0] res_mul     = alu_in_l_reg * alu_in_r_reg;
wire signed [63:0] res_sra     = alu_in_l_reg >>> alu_in_r_reg[5:0];

wire signed [63:0] alu_out_w = ({64{op_add | op_sub}} & res_add_sub) | 
                                ({64{op_mul}} & res_mul) | 
                                ({64{op_sra}} & res_sra);

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) cs <= IDLE;
    else cs <= ns;
end

always @(posedge clk) begin
    // Pipeline Stage 1
    if (cs == CALC_EVAL && ns == CALC_ALU_EXEC) begin 
        alu_in_l_reg <= stack_l_val[stack_push - 1]; 
        alu_in_r_reg <= cur_val; 
        alu_op_reg   <= stack_op[stack_push - 1];
    end 

    // Pipeline Stage 2
    if (cs == CALC_ALU_EXEC) 
        alu_out_reg <= alu_out_w; 

    // Stack Push & Update
    if (cs == CALC_R && r_handshake) begin
        if (r_data[63] == 1) begin 
            stack_op[stack_push]    <= r_data[33:32]; 
            stack_r_ptr[stack_push] <= r_data[15:0]; 
        end 
        else if (stack_push > 0 && stack_state[stack_push - 1] == 0) begin 
            stack_l_val[stack_push - 1] <= {{33{r_data[62]}}, r_data[62:32]}; 
        end 
        else begin
            cur_val <= {{33{r_data[62]}}, r_data[62:32]};
        end
    end 
    else if (cs == CALC_EVAL) begin
        if (stack_push == 0) begin
            final_ans[cur_tree_idx] <= cur_val;
        end 
        else if (stack_state[stack_push - 1] == 0) begin 
            stack_l_val[stack_push - 1] <= cur_val; 
        end 
    end 
    else if (cs == CALC_ALU_WB) begin
        cur_val <= alu_out_reg;
    end
end

always @(*) begin
    ns = cs;
    case (cs)
        IDLE: if (start) ns = CALC_AR;
        CALC_AR: if (ar_handshake) ns = CALC_R;
        CALC_R: if (r_handshake) begin 
                    if (r_data[63] == 1 || (stack_push > 0 && stack_state[stack_push - 1] == 0)) ns = CALC_AR; 
                    else ns = CALC_EVAL; 
                end
        CALC_EVAL: begin 
            if (stack_push == 0) begin 
                if (cur_tree_idx == 3) ns = CALC_OUT; 
                else ns = CALC_AR; 
            end 
            else begin 
                if (stack_state[stack_push - 1] == 0) ns = CALC_AR; 
                else ns = CALC_ALU_EXEC; 
            end 
        end
        CALC_ALU_EXEC: ns = CALC_ALU_WB; 
        CALC_ALU_WB:   ns = CALC_EVAL; 
        CALC_OUT:      if (out_cnt == 3) ns = IDLE;
    endcase
end

integer k;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        src_row_reg <= 0; 
        calc_target_addr <= 0; 
        cur_tree_idx <= 0; 
        stack_push <= 0;
        for (k = 0; k < 8; k = k + 1) stack_state[k] <= 0;
    end 
    else begin
        if (start) begin 
            src_row_reg <= in_src_row; 
            calc_target_addr <= {16'b0, 2'b00, in_src_row, 8'd0}; 
            cur_tree_idx <= 0; 
            stack_push <= 0;
        end 
        else begin
            if (cs == CALC_R && r_handshake) begin
                if (r_data[63] == 1) begin 
                    stack_state[stack_push] <= 0; 
                    stack_push <= stack_push + 1; 
                    calc_target_addr <= {16'b0, r_data[31:16]}; 
                end 
                else begin 
                    if (stack_push > 0 && stack_state[stack_push - 1] == 0) begin 
                        stack_state[stack_push - 1] <= 1; 
                        calc_target_addr <= {16'b0, stack_r_ptr[stack_push - 1]}; 
                    end
                end
            end 
            else if (cs == CALC_EVAL) begin
                if (stack_push == 0) begin 
                    if (cur_tree_idx < 3) begin 
                        cur_tree_idx <= cur_tree_idx + 1; 
                        calc_target_addr <= {16'b0, cur_tree_idx + 2'd1, src_row_reg, 8'd0}; 
                    end
                end 
                else begin 
                    if (stack_state[stack_push - 1] == 0) begin 
                        stack_state[stack_push - 1] <= 1; 
                        calc_target_addr <= {16'b0, stack_r_ptr[stack_push - 1]}; 
                    end 
                end
            end 
            else if (cs == CALC_ALU_WB) stack_push <= stack_push - 1; 
        end
    end
end

always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin 
        ar_valid <= 0; 
        ar_addr  <= 0; 
    end
    else begin
        if (start) begin 
            ar_valid <= 1; 
            ar_addr  <= {16'b0, 2'b00, in_src_row, 8'd0}; 
        end
        else if (cs == CALC_AR) begin 
            if (ar_handshake) begin 
                ar_valid <= 0; 
                ar_addr  <= 0; end 
            else begin 
                ar_valid <= 1; 
                ar_addr  <= calc_target_addr; 
            end
        end 
        else begin 
            ar_valid <= 0; 
            ar_addr  <= 0; 
        end
    end
end

always@(posedge clk or negedge rst_n) begin
    if(~rst_n) r_ready <= 0;
    else begin 
        if(start) r_ready <= 0; 
        else if (cs == CALC_AR) r_ready <= 1; 
        else if (cs == CALC_R) begin if (r_handshake) r_ready <= 0; end 
        else r_ready <= 0; 
    end
end

always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin 
        out_valid <= 0; 
        out_data <= 0; 
        out_cnt <= 0; 
        done <= 0; 
    end
    else begin 
        done <= 0; 
        if (cs == CALC_OUT) begin 
            out_valid <= 1; 
            out_cnt <= out_cnt + 1; 
            out_data <= final_ans[out_cnt[1:0]]; 
            if (out_cnt == 3) done <= 1; 
        end 
        else begin 
            out_valid <= 0; 
            out_data <= 0; 
            out_cnt <= 0; 
        end 
    end
end
endmodule

module harvester_sort (
    input clk, rst_n, start,
    input [5:0] in_src_row, input [5:0] in_dst_row,
    output wire [31:0] ar_addr, output wire ar_valid, input ar_ready,
    input [63:0] r_data, input r_valid, output reg r_ready,
    output wire [31:0] aw_addr, output wire aw_valid, input aw_ready,
    output wire [63:0] w_data, output wire w_valid, input w_ready,
    input b_valid, output reg b_ready,
    output reg out_valid, output reg done,
    input ext_we, input [5:0] ext_waddr, input [63:0] ext_wdata,
    input [5:0] ext_raddr, output [63:0] ext_rdata
);

localparam S_IDLE     = 0;
localparam S_P0_READ  = 1; 
localparam S_P0_SORT  = 2; 
localparam S_P0_WRITE = 3; 
localparam S_P1_MERGE = 4; 
localparam S_P2_MERGE = 5; 
localparam S_DONE     = 6;

reg [2:0] cs, ns;

reg [5:0] src_row_reg, dst_row_reg;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin 
        src_row_reg <= 0; dst_row_reg <= 0; 
    end else if (start) begin 
        src_row_reg <= in_src_row; dst_row_reg <= in_dst_row; 
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) cs <= S_IDLE; else cs <= ns;
end

wire ar_hs = ar_valid && ar_ready;
wire r_hs  = r_valid && r_ready;
wire aw_hs = aw_valid && aw_ready;
wire w_hs  = w_valid && w_ready;
wire b_hs  = b_valid && b_ready;

reg [63:0] sort_ram [0:63]; 
assign ext_rdata = sort_ram[ext_raddr];

reg [3:0] p0_chunk; 
reg [1:0] p1_bank;  
reg [6:0] sort_pass; 
reg swap_occurred; 
reg [6:0] s1_ar_cnt, s1_r_rcv_cnt;
reg [6:0] s1_aw_cnt, s1_w_cnt, s1_b_cnt;

reg [3:0] hd0, tl0, hd1, tl1, hd2, tl2, hd3, tl3;
reg [4:0] cnt0, cnt1, cnt2, cnt3;
reg [4:0] occ0, occ1, occ2, occ3; 

reg [8:0] ar_req_cnt0, ar_req_cnt1, ar_req_cnt2, ar_req_cnt3;
reg [8:0] r_rcv_cnt0, r_rcv_cnt1, r_rcv_cnt2, r_rcv_cnt3;

reg [10:0] aw_issue_cnt, w_issue_cnt, merge_b_cnt;

reg [1:0] req_q [0:15]; 
reg [3:0] req_q_head, req_q_tail;

wire p1_done = (cs == S_P1_MERGE && b_hs && merge_b_cnt == 255);
wire p2_done = (cs == S_P2_MERGE && b_hs && merge_b_cnt == 1023);
wire merge_rst = (ns == S_P1_MERGE && cs != S_P1_MERGE) || p1_done || (ns == S_P2_MERGE && cs != S_P2_MERGE);

always @(*) begin
    ns = cs;
    case (cs)
        S_IDLE:     if (start) ns = S_P0_READ;
        S_P0_READ:  if (r_hs && s1_r_rcv_cnt == 63) ns = S_P0_SORT;
        S_P0_SORT:  if (sort_pass == 63 || (sort_pass > 0 && !swap_occurred)) ns = S_P0_WRITE;
        S_P0_WRITE: if (b_hs && s1_b_cnt == 63) ns = (p0_chunk == 15) ? S_P1_MERGE : S_P0_READ;
        S_P1_MERGE: if (p1_done) ns = (p1_bank == 3) ? S_P2_MERGE : S_P1_MERGE;
        S_P2_MERGE: if (p2_done) ns = S_DONE;
        S_DONE:     ns = S_IDLE;
    endcase
end

integer i;
always @(posedge clk) begin
    if (ext_we) 
        sort_ram[ext_waddr] <= ext_wdata;
    else if (cs == S_P0_READ) begin
        swap_occurred <= 1; 
        if (r_hs) sort_ram[s1_r_rcv_cnt[5:0]] <= r_data;
    end 
    else if (cs == S_P0_SORT) begin
        swap_occurred <= 0; 
        for (i = 0; i < 32; i = i + 1) begin
            if (sort_pass[0] == 0) begin 
                if (sort_ram[2 * i][62:32] > sort_ram[2 * i + 1][62:32]) begin
                    sort_ram[2 * i]   <= sort_ram[2 * i + 1];
                    sort_ram[2 * i + 1] <= sort_ram[2 * i];
                    swap_occurred <= 1;
                end
            end 
            else begin 
                if (i < 31) begin
                    if (sort_ram[2 * i + 1][62:32] > sort_ram[2 * i + 2][62:32]) begin
                        sort_ram[2 * i + 1] <= sort_ram[2 * i + 2];
                        sort_ram[2 * i + 2] <= sort_ram[2 * i + 1];
                        swap_occurred <= 1;
                    end
                end
            end
        end
    end else if ((cs == S_P1_MERGE || cs == S_P2_MERGE) && r_hs) begin
        if (req_q[req_q_head] == 0) sort_ram[{2'd0, tl0}] <= r_data;
        if (req_q[req_q_head] == 1) sort_ram[{2'd1, tl1}] <= r_data;
        if (req_q[req_q_head] == 2) sort_ram[{2'd2, tl2}] <= r_data;
        if (req_q[req_q_head] == 3) sort_ram[{2'd3, tl3}] <= r_data;
    end
end

wire p0_rst = (ns == S_P0_READ && cs != S_P0_READ) || (cs == S_IDLE);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin 
        p0_chunk <= 0; p1_bank <= 0; sort_pass <= 0;
        s1_ar_cnt <= 0; s1_r_rcv_cnt <= 0; s1_aw_cnt <= 0; s1_w_cnt <= 0; s1_b_cnt <= 0;
    end 
    else begin
        if (cs == S_IDLE) begin
            p0_chunk <= 0; p1_bank <= 0;
        end
        if (p0_rst) begin
            s1_ar_cnt <= 0; s1_r_rcv_cnt <= 0; s1_aw_cnt <= 0; s1_w_cnt <= 0; s1_b_cnt <= 0;
        end 
        else begin
            if (cs == S_P0_READ) begin
                if (ar_hs) s1_ar_cnt <= s1_ar_cnt + 1;
                if (r_hs)  s1_r_rcv_cnt <= s1_r_rcv_cnt + 1;
            end
            if (cs == S_P0_WRITE) begin
                if (aw_hs) s1_aw_cnt <= s1_aw_cnt + 1;
                if (w_hs)  s1_w_cnt  <= s1_w_cnt + 1;
                if (b_hs)  s1_b_cnt <= s1_b_cnt + 1;
            end
        end

        if (cs == S_P0_SORT) sort_pass <= sort_pass + 1;
        else sort_pass <= 0;

        if (cs == S_P0_WRITE && b_hs && s1_b_cnt == 63) p0_chunk <= p0_chunk + 1;
        if (p1_done) p1_bank <= p1_bank + 1;
    end
end

wire [8:0] tgt_len = (cs == S_P2_MERGE) ? 256 : 64;

wire rq0 = (occ0 < 14) && (ar_req_cnt0 < tgt_len);
wire rq1 = (occ1 < 14) && (ar_req_cnt1 < tgt_len);
wire rq2 = (occ2 < 14) && (ar_req_cnt2 < tgt_len);
wire rq3 = (occ3 < 14) && (ar_req_cnt3 < tgt_len);

wire [1:0] nx_req = rq0 ? 0 : rq1 ? 1 : rq2 ? 2 : rq3 ? 3 : 0;
wire do_req = rq0 | rq1 | rq2 | rq3;

reg ar_locked;
reg [1:0] locked_nx_req;
reg locked_do_req;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        locked_nx_req <= 0;
        locked_do_req <= 0;
    end else if ((cs == S_P1_MERGE || cs == S_P2_MERGE) && ar_valid && !ar_ready && !ar_locked) begin
        locked_nx_req <= nx_req; 
        locked_do_req <= do_req;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) ar_locked <= 0; 
    else if (merge_rst) ar_locked <= 0; 
    else if (cs == S_P1_MERGE || cs == S_P2_MERGE) begin
        if (ar_valid && !ar_ready) begin
            if (!ar_locked) ar_locked <= 1; 
        end else if (ar_ready) begin
            ar_locked <= 0;
        end
    end else ar_locked <= 0;
end

wire active_do_req = ar_locked ? locked_do_req : do_req;
wire [1:0] active_nx_req = ar_locked ? locked_nx_req : nx_req;

wire [63:0] full_v0 = sort_ram[{2'd0, hd0}];
wire [63:0] full_v1 = sort_ram[{2'd1, hd1}];
wire [63:0] full_v2 = sort_ram[{2'd2, hd2}];
wire [63:0] full_v3 = sort_ram[{2'd3, hd3}];

wire [31:0] v0 = full_v0[62:32]; wire [31:0] v1 = full_v1[62:32];
wire [31:0] v2 = full_v2[62:32]; wire [31:0] v3 = full_v3[62:32];

wire dn0 = (ar_req_cnt0 == tgt_len) && (occ0 == 0);
wire dn1 = (ar_req_cnt1 == tgt_len) && (occ1 == 0);
wire dn2 = (ar_req_cnt2 == tgt_len) && (occ2 == 0);
wire dn3 = (ar_req_cnt3 == tgt_len) && (occ3 == 0);

wire [31:0] c0 = dn0 ? 32'hFFFF_FFFF : v0; wire [31:0] c1 = dn1 ? 32'hFFFF_FFFF : v1;
wire [31:0] c2 = dn2 ? 32'hFFFF_FFFF : v2; wire [31:0] c3 = dn3 ? 32'hFFFF_FFFF : v3;

wire min_is_0 = !dn0 && (dn1 || c0<=c1) && (dn2 || c0<=c2) && (dn3 || c0 <= c3);
wire min_is_1 = !dn1 && !min_is_0 && (dn2 || c1 <= c2) && (dn3 || c1 <= c3);
wire min_is_2 = !dn2 && !min_is_0 && !min_is_1 && (dn3 || c2 <= c3);
wire min_is_3 = !dn3 && !min_is_0 && !min_is_1 && !min_is_2;

wire can_merge = (!dn0 || !dn1 || !dn2 || !dn3) && (cnt0 > 0 || dn0) && (cnt1 > 0 || dn1) && (cnt2 > 0 || dn2) && (cnt3 > 0 || dn3);

reg [63:0] merge_data_buf;
reg merge_data_valid, aw_sent, w_sent;

wire current_txn_done = merge_data_valid && (aw_sent || aw_hs) && (w_sent || w_hs);
wire merge_pop = can_merge && (!merge_data_valid || current_txn_done) && (cs == S_P1_MERGE || cs == S_P2_MERGE);

always @(posedge clk) begin
    if ((cs == S_P1_MERGE || cs == S_P2_MERGE) && merge_pop) 
        merge_data_buf <= min_is_0 ? full_v0 : min_is_1 ? full_v1 : min_is_2 ? full_v2 : full_v3;
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        merge_data_valid <= 0; aw_sent <= 0; w_sent <= 0; 
    end 
    else if (merge_rst) begin
        merge_data_valid <= 0; aw_sent <= 0; w_sent <= 0;
    end 
    else if (cs == S_P1_MERGE || cs == S_P2_MERGE) begin
        if (merge_pop) begin
            merge_data_valid <= 1; aw_sent <= 0; w_sent <= 0;
        end 
        else if (merge_data_valid) begin
            if (aw_hs) aw_sent <= 1;
            if (w_hs)  w_sent <= 1;
            if (current_txn_done) merge_data_valid <= 0;
        end
    end 
    else begin
        merge_data_valid <= 0; aw_sent <= 0; w_sent <= 0;
    end
end

wire pop0 = merge_pop && min_is_0; wire pop1 = merge_pop && min_is_1;
wire pop2 = merge_pop && min_is_2; wire pop3 = merge_pop && min_is_3;

integer j;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        for (j=0; j<16; j=j+1) req_q[j] <= 0;
    end else if ((cs == S_P1_MERGE || cs == S_P2_MERGE) && ar_hs) begin
        req_q[req_q_tail] <= active_nx_req;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        hd0<=0; tl0<=0; cnt0<=0; hd1<=0; tl1<=0; cnt1<=0;
        hd2<=0; tl2<=0; cnt2<=0; hd3<=0; tl3<=0; cnt3<=0;
        ar_req_cnt0<=0; r_rcv_cnt0<=0; ar_req_cnt1<=0; r_rcv_cnt1<=0;
        ar_req_cnt2<=0; r_rcv_cnt2<=0; ar_req_cnt3<=0; r_rcv_cnt3<=0;
        req_q_head<=0; req_q_tail<=0; merge_b_cnt<=0;
        aw_issue_cnt <= 0; w_issue_cnt <= 0;
        occ0 <= 0; occ1 <= 0; occ2 <= 0; occ3 <= 0;
    end 
    else if (merge_rst || start) begin 
        hd0<=0; tl0<=0; cnt0<=0; hd1<=0; tl1<=0; cnt1<=0;
        hd2<=0; tl2<=0; cnt2<=0; hd3<=0; tl3<=0; cnt3<=0;
        ar_req_cnt0<=0; r_rcv_cnt0<=0; ar_req_cnt1<=0; r_rcv_cnt1<=0;
        ar_req_cnt2<=0; r_rcv_cnt2<=0; ar_req_cnt3<=0; r_rcv_cnt3<=0;
        req_q_head<=0; req_q_tail<=0; merge_b_cnt<=0;
        aw_issue_cnt <= 0; w_issue_cnt <= 0;
        occ0 <= 0; occ1 <= 0; occ2 <= 0; occ3 <= 0;
    end 
    else begin
        if ((cs == S_P1_MERGE || cs == S_P2_MERGE) && r_hs) begin
            if (req_q[req_q_head] == 0) tl0 <= tl0 + 1;
            if (req_q[req_q_head] == 1) tl1 <= tl1 + 1;
            if (req_q[req_q_head] == 2) tl2 <= tl2 + 1;
            if (req_q[req_q_head] == 3) tl3 <= tl3 + 1;
        end

        if (pop0) hd0 <= hd0 + 1; if (pop1) hd1 <= hd1 + 1; 
        if (pop2) hd2 <= hd2 + 1; if (pop3) hd3 <= hd3 + 1; 

        cnt0 <= cnt0 + ((cs == S_P1_MERGE || cs == S_P2_MERGE) && r_hs && req_q[req_q_head] == 0) - pop0;
        cnt1 <= cnt1 + ((cs == S_P1_MERGE || cs == S_P2_MERGE) && r_hs && req_q[req_q_head] == 1) - pop1;
        cnt2 <= cnt2 + ((cs == S_P1_MERGE || cs == S_P2_MERGE) && r_hs && req_q[req_q_head] == 2) - pop2;
        cnt3 <= cnt3 + ((cs == S_P1_MERGE || cs == S_P2_MERGE) && r_hs && req_q[req_q_head] == 3) - pop3;
        
        if ((cs == S_P1_MERGE || cs == S_P2_MERGE) && ar_hs && active_nx_req == 0) begin
            if (!pop0) occ0 <= occ0 + 1;
        end else if (pop0) occ0 <= occ0 - 1;

        if ((cs == S_P1_MERGE || cs == S_P2_MERGE) && ar_hs && active_nx_req == 1) begin
            if (!pop1) occ1 <= occ1 + 1;
        end else if (pop1) occ1 <= occ1 - 1;

        if ((cs == S_P1_MERGE || cs == S_P2_MERGE) && ar_hs && active_nx_req == 2) begin
            if (!pop2) occ2 <= occ2 + 1;
        end else if (pop2) occ2 <= occ2 - 1;

        if ((cs == S_P1_MERGE || cs == S_P2_MERGE) && ar_hs && active_nx_req == 3) begin
            if (!pop3) occ3 <= occ3 + 1;
        end else if (pop3) occ3 <= occ3 - 1;

        if ((cs == S_P1_MERGE || cs == S_P2_MERGE) && ar_hs) begin
            req_q_tail <= req_q_tail + 1; 
            case (active_nx_req)
                0: ar_req_cnt0 <= ar_req_cnt0 + 1; 1: ar_req_cnt1 <= ar_req_cnt1 + 1;
                2: ar_req_cnt2 <= ar_req_cnt2 + 1; 3: ar_req_cnt3 <= ar_req_cnt3 + 1;
            endcase
        end
        
        if ((cs == S_P1_MERGE || cs == S_P2_MERGE) && r_hs) begin
            req_q_head <= req_q_head + 1; 
            case (req_q[req_q_head])
                0: r_rcv_cnt0 <= r_rcv_cnt0 + 1; 1: r_rcv_cnt1 <= r_rcv_cnt1 + 1;
                2: r_rcv_cnt2 <= r_rcv_cnt2 + 1; 3: r_rcv_cnt3 <= r_rcv_cnt3 + 1;
            endcase
        end
        
        if ((cs == S_P1_MERGE || cs == S_P2_MERGE) && b_hs) merge_b_cnt <= merge_b_cnt + 1;

        if (cs == S_P1_MERGE || cs == S_P2_MERGE) begin
            if (aw_hs) aw_issue_cnt <= aw_issue_cnt + 1;
            if (w_hs)  w_issue_cnt <= w_issue_cnt + 1;
        end
    end
end

wire [7:0] m_col = active_nx_req == 0 ? ar_req_cnt0[7:0] : active_nx_req == 1 ? ar_req_cnt1[7:0] :
                    active_nx_req == 2 ? ar_req_cnt2[7:0] : ar_req_cnt3[7:0];

wire [31:0] p1_ar_addr = {16'b0, p1_bank, dst_row_reg, active_nx_req, m_col[5:0]};
wire [31:0] p1_aw_addr = {16'b0, p1_bank, 6'd63, aw_issue_cnt[7:0]};
wire [31:0] p2_ar_addr = {16'b0, active_nx_req, 6'd63, m_col};
wire [31:0] p2_aw_addr = {16'b0, aw_issue_cnt[9:8], dst_row_reg, aw_issue_cnt[7:0]};

assign ar_valid = (cs == S_P0_READ) ? (s1_ar_cnt < 64) :
                    (cs == S_P1_MERGE || cs == S_P2_MERGE) ? active_do_req : 0;

wire [31:0] nxt_ar_addr = (cs == S_P0_READ) ? {16'b0, p0_chunk[3:2], src_row_reg, p0_chunk[1:0], s1_ar_cnt[5:0]} :
                            (cs == S_P1_MERGE) ? p1_ar_addr :
                            (cs == S_P2_MERGE) ? p2_ar_addr : 0;

assign ar_addr = ar_valid ? nxt_ar_addr : 0;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) r_ready <= 0;
    else if (cs == S_P0_READ) r_ready <= (s1_r_rcv_cnt < 64); 
    else if (cs == S_P1_MERGE || cs == S_P2_MERGE) r_ready <= 1;
    else r_ready <= 0; 
end

wire aw_p0_throttle = ((s1_aw_cnt - s1_w_cnt) < 16);
wire aw_merge_throttle = ((aw_issue_cnt - w_issue_cnt) < 16);

wire [10:0] tgt_write_len = (cs == S_P2_MERGE) ? 1024 : 256;

assign aw_valid = (cs == S_P0_WRITE) ? (s1_aw_cnt < 64 && aw_p0_throttle) :
                    (cs == S_P1_MERGE || cs == S_P2_MERGE) ? (aw_issue_cnt < tgt_write_len && merge_data_valid && !aw_sent && aw_merge_throttle) : 0;

wire [31:0] nxt_aw_addr = (cs == S_P0_WRITE) ? {16'b0, p0_chunk[3:2], dst_row_reg, p0_chunk[1:0], s1_aw_cnt[5:0]} :
                            (cs == S_P1_MERGE) ? p1_aw_addr :
                            (cs == S_P2_MERGE) ? p2_aw_addr : 0;

assign aw_addr = aw_valid ? nxt_aw_addr : 0;

assign w_valid = (cs == S_P0_WRITE) ? (s1_w_cnt < 64) :
                    (cs == S_P1_MERGE || cs == S_P2_MERGE) ? (w_issue_cnt < tgt_write_len && merge_data_valid && !w_sent) : 0;

wire [63:0] nxt_w_data = (cs == S_P0_WRITE) ? sort_ram[s1_w_cnt[5:0]] :
                            (cs == S_P1_MERGE || cs == S_P2_MERGE) ? merge_data_buf : 0;

assign w_data = w_valid ? nxt_w_data : 0;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) b_ready <= 0;
    else b_ready <= 1;
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin 
        out_valid <= 0; 
        done <= 0; 
    end
    else begin
        done <= 0;
        if (cs == S_DONE) begin 
            out_valid <= 1; 
            done <= 1; 
        end
        else out_valid <= 0;
    end
end
endmodule