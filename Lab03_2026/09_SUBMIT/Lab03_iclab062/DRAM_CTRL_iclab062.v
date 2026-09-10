module DRAM_CTRL (
    input               clk,
    input               rst_n,
    
    // AXI4-Lite Slave Interface
    input [31:0]        aw_addr,
    input               aw_valid,
    output wire         aw_ready,   
    input [63:0]        w_data,
    input               w_valid,
    output wire         w_ready,    
    output wire [1:0]   b_resp,
    output wire         b_valid,
    input               b_ready,
    
    input [31:0]        ar_addr,
    input               ar_valid,
    output wire         ar_ready,   
    output reg [63:0]   r_data,     
    output wire [1:0]   r_resp,
    output wire         r_valid,
    input               r_ready,

    // DRAM Master Interface
    output reg  [3:0]   dram_cmd,   
    output reg  [1:0]   dram_ba,    
    output reg  [10:0]  dram_addr,  
    output reg  [63:0]  dram_wdata, 
    input [63:0]        dram_rdata,
    input               dram_valid
);

reg [15:0] queue_ar [0:3];  reg [1:0] hd_ar, tl_ar; reg [2:0] cnt_ar;
reg [15:0] queue_aw [0:3];  reg [1:0] hd_aw, tl_aw; reg [2:0] cnt_aw;
reg [63:0] queue_w  [0:3];  reg [1:0] tl_w;         reg [2:0] cnt_w;
reg [63:0] queue_r  [0:3];  reg [1:0] hd_r,  tl_r;  reg [2:0] cnt_r;

reg [2:0]  cnt_b;          
reg [4:0]  inflight_rd_tasks; 

reg        bk_is_open    [0:3]; 
reg [5:0]  bk_active_row [0:3]; 
reg [1:0]  delay_trcd_trp [0:3]; 
reg [2:0]  delay_tras     [0:3]; 

assign ar_ready = rst_n && (cnt_ar < 4);
assign aw_ready = rst_n && (cnt_aw < 4);
assign w_ready  = rst_n && (cnt_w  < 4);

wire fire_ar = ar_valid && ar_ready;
wire fire_aw = aw_valid && aw_ready;
wire fire_w  = w_valid  && w_ready;
wire fire_r  = r_valid  && r_ready;
wire fire_b  = b_valid  && b_ready;

assign r_valid = rst_n && (cnt_r > 0);
assign r_resp = 0; 
always @(*) r_data = r_valid ? queue_r[hd_r] : 0;

assign b_valid = rst_n && (cnt_b > 0);
assign b_resp  = 0; 

wire rd_quota_ok = (~inflight_rd_tasks[3] | ~inflight_rd_tasks[2] | ~inflight_rd_tasks[1] | ~inflight_rd_tasks[0]); 
wire wr_quota_ok = (cnt_b < 4);

wire want_rd = (cnt_ar > 0) && rd_quota_ok;
wire want_wr = (cnt_aw > 0) && (cnt_w > 0) && wr_quota_ok;

reg        turn_flag; 
reg [3:0]  consecutive_cmds; 

wire win_rd = want_rd && (~want_wr || (~turn_flag));
wire win_wr = want_wr && (~want_rd || turn_flag);

wire [15:0] mux_addr = win_rd ? queue_ar[hd_ar] : queue_aw[hd_aw];

wire [1:0] mux_bk = mux_addr[15:14];
wire [5:0] mux_ro = mux_addr[13:8];
wire [7:0] mux_co = mux_addr[7:0];

reg [3:0]  nxt_cmd;   
reg [1:0]  nxt_ba;    
reg [10:0] nxt_addr;  
reg drop_ar, drop_aw;

always @(*) begin
    nxt_cmd   = 4'b0111; 
    nxt_ba    = 0;
    nxt_addr  = 0;
    drop_ar   = 0;
    drop_aw   = 0;

    if (win_rd || win_wr) begin
        if (delay_trcd_trp[mux_bk] == 0) begin
            if (!bk_is_open[mux_bk]) begin
                nxt_cmd  = 4'b0011; 
                nxt_ba   = mux_bk;
                nxt_addr = {5'b0, mux_ro};
            end 
            else if (bk_active_row[mux_bk] != mux_ro) begin
                if (delay_tras[mux_bk] == 0) begin
                    nxt_cmd  = 4'b0010; 
                    nxt_ba   = mux_bk;
                end
            end 
            else begin
                if (win_rd) begin
                    nxt_cmd  = 4'b0101; 
                    nxt_ba   = mux_bk;
                    nxt_addr = {3'b0, mux_co};
                    drop_ar  = 1;
                end 
                else begin
                    nxt_cmd   = 4'b0100; 
                    nxt_ba    = mux_bk;
                    nxt_addr  = {3'b0, mux_co};
                    drop_aw   = 1;
                end
            end
        end
    end
end

wire trig_rd = (nxt_cmd == 4'b0101);
wire trig_wr = (nxt_cmd == 4'b0100);
wire push_r  = dram_valid;
wire push_b  = trig_wr;

integer idx;

always @(posedge clk) begin
    if (fire_ar) queue_ar[tl_ar] <= ar_addr[15:0];
    if (fire_aw) queue_aw[tl_aw] <= aw_addr[15:0];
    
    if (fire_w)  queue_w[tl_w]   <= w_data;
    if (push_r)  queue_r[tl_r]   <= dram_rdata;

    for (idx = 0; idx < 4; idx = idx + 1) begin
        if (nxt_cmd == 4'b0011 && nxt_ba == idx) 
            bk_active_row[idx] <= mux_ro;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        hd_ar <= 0; tl_ar <= 0; cnt_ar <= 0;
        hd_aw <= 0; tl_aw <= 0; cnt_aw <= 0;
        tl_w  <= 0; cnt_w <= 0;
        hd_r  <= 0; tl_r  <= 0; cnt_r  <= 0;
        cnt_b <= 0; inflight_rd_tasks <= 0;
        turn_flag <= 0; consecutive_cmds <= 0;
        
        dram_cmd <= 4'b0111; 
        dram_ba <= 0;
        dram_addr <= 0; 
        dram_wdata <= 0;

        for (idx = 0; idx < 4; idx = idx + 1) begin
            bk_is_open[idx] <= 0; 
            delay_trcd_trp[idx] <= 0; 
            delay_tras[idx] <= 0;
        end
    end 
    else begin
        if (drop_ar || drop_aw) consecutive_cmds <= consecutive_cmds + 1;

        if (turn_flag == 0) begin
            if (want_wr && (!want_rd || consecutive_cmds >= 15)) begin
                turn_flag <= 1; 
                consecutive_cmds <= 0;
            end
        end 
        else begin
            if (want_rd && (!want_wr || consecutive_cmds >= 15)) begin
                turn_flag <= 0; 
                consecutive_cmds <= 0;
            end
        end

        if (fire_ar) tl_ar <= tl_ar + 1;
        if (drop_ar) hd_ar <= hd_ar + 1;

        if (fire_aw) tl_aw <= tl_aw + 1;
        if (drop_aw) hd_aw <= hd_aw + 1;

        if (fire_w) tl_w <= tl_w + 1;

        if (push_r) tl_r <= tl_r + 1;
        if (fire_r) hd_r <= hd_r + 1;
        
        if (fire_ar && !drop_ar) cnt_ar <= cnt_ar + 1;
        else if (!fire_ar && drop_ar) cnt_ar <= cnt_ar - 1;

        if (fire_aw && !drop_aw) cnt_aw <= cnt_aw + 1;
        else if (!fire_aw && drop_aw) cnt_aw <= cnt_aw - 1;

        if (fire_w && !drop_aw) cnt_w <= cnt_w + 1;
        else if (!fire_w && drop_aw) cnt_w <= cnt_w - 1;

        if (push_r && !fire_r) cnt_r <= cnt_r + 1;
        else if (!push_r && fire_r) cnt_r <= cnt_r - 1;

        if (push_b && !fire_b) cnt_b <= cnt_b + 1;
        else if (!push_b && fire_b) cnt_b <= cnt_b - 1;

        if (trig_rd && !fire_r) inflight_rd_tasks <= inflight_rd_tasks + 1;
        else if (!trig_rd && fire_r) inflight_rd_tasks <= inflight_rd_tasks - 1;

        dram_cmd <= nxt_cmd; 
        dram_ba <= nxt_ba; 
        dram_addr <= nxt_addr; 
        dram_wdata <= queue_w[hd_aw];

        for (idx = 0; idx < 4; idx = idx + 1) begin
            if (nxt_cmd == 4'b0011 && nxt_ba == idx) begin
                bk_is_open[idx] <= 1; 
                delay_trcd_trp[idx] <= 1; 
                delay_tras[idx] <= 4;
            end 
            else if (nxt_cmd == 4'b0010 && nxt_ba == idx) begin
                bk_is_open[idx] <= 0; delay_trcd_trp[idx] <= 2;
                if (delay_tras[idx] > 0) delay_tras[idx] <= delay_tras[idx] - 1;
            end 
            else begin
                if (delay_trcd_trp[idx] > 0) delay_trcd_trp[idx] <= delay_trcd_trp[idx] - 1;
                if (delay_tras[idx] > 0)     delay_tras[idx]     <= delay_tras[idx] - 1;
            end
        end
    end
end
endmodule