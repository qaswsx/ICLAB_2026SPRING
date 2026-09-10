module OT_DESIGN(
    clk,
    rst_n,
    in_valid_data,
    in_data,
    in_valid_cmd,
    in_cmd,    
    out_valid,  
    out_data
);

input              clk;
input              rst_n;

input              in_valid_data;
input       [7:0]  in_data;

input              in_valid_cmd;
input      [9:0]   in_cmd;

output reg         out_valid;
output reg  [7:0]  out_data;

//==================================================================
// parameter & integer
//==================================================================
localparam IDLE = 0;
localparam LOAD = 1;
localparam DOWN = 2;
localparam CMP = 3;
localparam OUT = 4;

//==================================================================
// reg & wire declarations
//==================================================================
reg [10:0] cs, ns;
reg [7:0] in_data_temp;
reg [20:0] cnt;
reg [9:0] in_cmd_temp;
reg in_valid_ff;
reg [7:0] matrix0[0:15][0:15];
reg [7:0] matrix1[0:15][0:15];

reg [10:0] down_cnt;
reg [10:0] cmp_cnt;
reg [10:0] out_cnt;

reg [16:0] sum0; 
reg [16:0] sum1;

reg [11:0] addr;
reg [7:0] mem0_dout_ff;

reg [3:0] down_x, down_y;
reg [3:0] cmp_x, cmp_y;
reg [3:0] out_x, out_y;

reg [7:0] max0[0:15];

integer i, j;

wire [1:0] op = in_cmd_temp[9:8];
wire [3:0] target[0:1];

assign target[0] = in_cmd_temp[7:4];
assign target[1] = in_cmd_temp[3:0];

//==================================================================
// design
//==================================================================

always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        cnt <= 0;
    end   
    else if(cnt > 0) begin
        cnt <= cnt + 1;
    end
    else if(in_valid_data) begin
        cnt <= 1;
    end
    else if(cs == IDLE) begin 
        cnt <= 0;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(~rst_n) cs <= IDLE;
    else cs <= ns;    
end 

always@(*) begin
    ns = cs;
    case(cs)
        IDLE: ns = (in_valid_data || in_valid_cmd) ? LOAD : IDLE;
        LOAD: ns = (in_cmd_temp != 0) ? DOWN : LOAD;
        DOWN: ns = (down_cnt == 517) ? CMP : DOWN;
        CMP:  ns = (op == 2) ? ((cmp_cnt == 512) ? OUT : CMP) : ((cmp_cnt == 257) ? OUT : CMP); 
        OUT:  ns = (out_cnt == 256) ? IDLE : OUT; 
    endcase
end

always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        in_data_temp <= 0;
        in_valid_ff <= 0;
    end
    else if(in_valid_data)begin
        in_valid_ff <= in_valid_data;
        in_data_temp <= in_data;
    end
    else begin
        in_data_temp <= 0;
        in_valid_ff <= 0;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        in_cmd_temp <= 0;
    end
    else if(in_valid_cmd)begin
        in_cmd_temp <= in_cmd;
    end
    else if(cs == IDLE) begin
        in_cmd_temp <= 0;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        down_cnt <= 0;
    end
    else if(cs == DOWN) begin
        down_cnt <= down_cnt + 1;
    end
    else begin
        down_cnt <= 0; 
    end
end

always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        sum0 <= 0;
        sum1 <= 0;
    end
    else if(cs == DOWN) begin
        if(down_cnt >= 3 && down_cnt < 259) begin
            sum0 <= sum0 + mem0_dout_ff;
        end
        else if(down_cnt >= 260 && down_cnt < 516) begin
            sum1 <= sum1 + mem0_dout_ff;
        end
    end
    else if(cs == IDLE) begin
        sum0 <= 0;
        sum1 <= 0;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        addr <= 0;
    end
    else if(down_cnt == 0)begin
        addr <= target[0] << 8;
    end    
    else if(down_cnt < 257) begin
        addr <= addr + 1;
    end
    else if(down_cnt == 257) begin
        addr <= target[1] << 8;
    end
    else if(down_cnt > 257 && down_cnt < 513)begin 
        addr <= addr + 1;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        down_x <= 0;
        down_y <= 0;
    end 
    else begin
        if(cs == DOWN) begin
            if((down_cnt >= 3 && down_cnt < 259) || (down_cnt >= 260 && down_cnt < 516)) begin
                down_x <= down_x + 1;
                if(down_x == 15) begin
                    down_x <= 0;
                    down_y <= down_y + 1;
                end
            end 
            else begin
                down_x <= 0;
                down_y <= 0;
            end
        end
        else begin
            down_x <= 0;
            down_y <= 0;
        end
    end   
end

always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        for(i = 0; i < 16; i = i + 1) begin
            for(j = 0; j < 16; j = j + 1) begin
                matrix0[i][j] <= 0;
                matrix1[i][j] <= 0;
            end
        end
    end
    else if(cs == DOWN)begin
        if(down_cnt >= 3 && down_cnt < 259) begin
            matrix0[down_y][down_x] <= mem0_dout_ff;
        end
        else if(down_cnt >= 260 && down_cnt < 516) begin
            matrix1[down_y][down_x] <= mem0_dout_ff;
        end
    end
    else if(cs == CMP) begin
        if(op == 3 && cmp_cnt == 256) begin 
            for(i = 0; i < 16; i = i + 1) begin
                for(j = 0; j < 16; j = j + 1) begin
                    matrix0[i][j] <= max0[i];
                end
            end
        end
    end
end

always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        cmp_cnt <= 0;
    end
    else if(cs == CMP) begin
        cmp_cnt <= cmp_cnt + 1;
    end
    else begin
        cmp_cnt <= 0; 
    end
end

always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        out_cnt <= 0;
    end
    else if(cs == OUT) begin
        out_cnt <= out_cnt + 1;
    end
    else begin
        out_cnt <= 0; 
    end
end

always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        cmp_x <= 0;
        cmp_y <= 0;
    end 
    else begin
        if(cs == CMP) begin
            if(cmp_cnt >= 0) begin
                cmp_x <= cmp_x + 1;
                if(cmp_x == 15) begin
                    cmp_x <= 0;
                    cmp_y <= cmp_y + 1;
                end
            end
        end
        else begin
            cmp_x <= 0;
            cmp_y <= 0;
        end
    end   
end

always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        for(i = 0; i < 16; i = i + 1) begin
            max0[i] <= 0;
        end
    end
    else if(cs == CMP) begin
        if(op == 3) begin
            if(max0[cmp_y] < matrix0[cmp_y][cmp_x]) begin
                max0[cmp_y] <= matrix0[cmp_y][cmp_x];
            end
        end
    end    
    else if(cs == IDLE) begin
        for(i = 0; i < 16; i = i + 1) begin
            max0[i] <= 0;
        end
    end
end

wire        mem0_web;
wire [11:0] mem0_addr;
wire  [7:0] mem0_din;
wire  [7:0] mem0_dout;

assign mem0_addr = (cs == DOWN) ? addr : 
                   (cs == CMP && op == 2) ? (
                       (cmp_cnt < 256) ? {target[0], cmp_cnt[7:0]} : {target[1], cmp_cnt[7:0]}
                   ) :
                   (in_valid_data ? cnt : 0);

assign mem0_web  = (cs == DOWN) ? 1 : 
                   (cs == CMP && op == 2 && cmp_cnt < 512) ? 0 : 
                   (in_valid_data ? 0 : 1);

assign mem0_din  = (cs == CMP && op == 2) ? (
                       (cmp_cnt < 256) ? matrix1[cmp_cnt[7:4]][cmp_cnt[3:0]] : matrix0[cmp_cnt[7:4]][cmp_cnt[3:0]]
                   ) : in_data;

always@(posedge clk) begin
    mem0_dout_ff <= mem0_dout;
end

SUMA180_4096X8X1BM4 MEM0(
    .A0(mem0_addr[0]), .A1(mem0_addr[1]), .A2(mem0_addr[2]), .A3(mem0_addr[3]), .A4(mem0_addr[4]), .A5(mem0_addr[5]), .A6(mem0_addr[6]), .A7(mem0_addr[7]), 
    .A8(mem0_addr[8]), .A9(mem0_addr[9]), .A10(mem0_addr[10]), .A11(mem0_addr[11]),
    .DO0(mem0_dout[0]), .DO1(mem0_dout[1]), .DO2(mem0_dout[2]), .DO3(mem0_dout[3]), .DO4(mem0_dout[4]), .DO5(mem0_dout[5]), .DO6(mem0_dout[6]), .DO7(mem0_dout[7]),
    .DI0(mem0_din[0]), .DI1(mem0_din[1]), .DI2(mem0_din[2]), .DI3(mem0_din[3]), .DI4(mem0_din[4]), .DI5(mem0_din[5]), .DI6(mem0_din[6]), .DI7(mem0_din[7]),
    .CK(clk), .WEB(mem0_web), .OE(1'b1), .CS(1'b1)
);

always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        out_x <= 0;
        out_y <= 0;
    end 
    else begin
        if(cs == OUT) begin
            if(out_cnt >= 0) begin
                out_x <= out_x + 1;
                if(out_x == 15) begin
                    out_x <= 0;
                    out_y <= out_y + 1;
                end
            end
        end
        else begin
            out_x <= 0;
            out_y <= 0;
        end
    end   
end

always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        out_valid <= 0;
        out_data <= 0;
    end
    else if(cs == OUT) begin
        if(out_cnt < 256) begin 
            out_valid <= 1;
            
            if (op == 0) begin
                out_data <= ({1'b0, matrix0[out_y][out_x]} + {1'b0, matrix1[out_y][out_x]}) >> 1;
            end
            else if (op == 1) begin
                out_data <= (matrix0[out_y][out_x] > matrix1[out_y][out_x]) ? 
                            (matrix0[out_y][out_x] - matrix1[out_y][out_x]) : 
                            (matrix1[out_y][out_x] - matrix0[out_y][out_x]);
            end
            else if (op == 2) begin
                out_data <= (sum0 > sum1) ? matrix0[out_y][out_x] : matrix1[out_y][out_x];
            end
            else if (op == 3) begin
                out_data <= matrix0[out_y][out_x];
            end
            else begin
                out_data <= 0;
            end
            
        end
        else begin
            out_valid <= 0;
            out_data <= 0;
        end
    end
    else begin
        out_valid <= 0;
        out_data <= 0;
    end
end
endmodule

















// //############################################################################
// //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// //   (C) Copyright Laboratory System Integration and Silicon Implementation
// //   All Right Reserved
// //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// //
// //   ICLAB 2026 Spring
// //   OT Exercise		
// //   Author     		: Cho-Hsun Lee 
// //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// `define CYCLE_TIME      20.0
// `define SEED_NUMBER     69
// `define PATTERN_NUMBER  100

// module PATTERN(
//     // Output Port
//     clk,
//     rst_n,
//     in_valid_data,
//     in_data,
//     in_valid_cmd,
//     in_cmd,
    
//     // Input Port
//     out_valid,
//     out_data
//     );

// //---------------------------------------------------------------------
// //   PORT DECLARATION          
// //---------------------------------------------------------------------
// output  logic        clk, rst_n, in_valid_data, in_valid_cmd;
// output  logic[7:0]  in_data;
// output  logic[9:0]  in_cmd;

// input           out_valid;
// input   [7:0]   out_data;

// //---------------------------------------------------------------------
// //   PARAMETER & INTEGER DECLARATION
// //---------------------------------------------------------------------
// real CYCLE = `CYCLE_TIME;
// real seed = `SEED_NUMBER;


// integer i,j,k;
// integer latency, total_latency;
// integer pat_num, PAT_NUM;


// //---------------------------------------------------------------------
// //   Reg & Wires
// //---------------------------------------------------------------------
// logic[7:0]  golden_out[0:15][0:15];

// logic[7:0]  golden_Image1[0:15][0:15], golden_Image2[0:15][0:15], golden_Image3[0:15][0:15], golden_Image4[0:15][0:15], golden_Image5[0:15][0:15], golden_Image6[0:15][0:15], golden_Image7[0:15][0:15], golden_Image8[0:15][0:15], golden_Image9[0:15][0:15], golden_Image10[0:15][0:15], golden_Image11[0:15][0:15], golden_Image12[0:15][0:15], golden_Image13[0:15][0:15], golden_Image14[0:15][0:15], golden_Image15[0:15][0:15], golden_Image16[0:15][0:15];
// reg [7:0]  golden_Image[1:16][0:15][0:15];

// logic[9:0] golden_task_number;

// logic[7:0]  golden_ImageA[0:15][0:15], golden_ImageB[0:15][0:15];

// logic[50:0] golden_ans1;
// logic[50:0] golden_ans2;

// logic [10:0] ccntt;

// logic [7:0]  temp;

// //================================================================
// // clock
// //================================================================

// always #(CYCLE/2.0) clk = ~clk;
// initial	clk = 0;

// //---------------------------------------------------------------------
// //   Pattern_Design
// //---------------------------------------------------------------------

// initial begin
//     force clk = 1'b0;

//     reset_task;
//     pat_num = 0;
//     total_latency = 0;

//     input_task1;
//     repeat($urandom_range(2, 4)) @(negedge clk);

//     for(pat_num=0; pat_num<`PATTERN_NUMBER; pat_num+=1) begin
//         ccntt = 0;
//         input_task2;

//         calculate_task;

//         wait_out_valid_task;
//         check_ans_task;
//         PASS_task;
//         repeat($urandom_range(2, 4)) @(negedge clk);

//     end

//     YOU_PASS_task;

// end


// /* reset task*/
// task reset_task; begin
//     rst_n = 'b1;
//     in_valid_data = 'b0;
//     in_valid_cmd = 'b0;

//     ccntt = 0;

//     in_data = 'bx;
//     in_cmd = 'bx;
    
//     #CYCLE; rst_n = 'b0;
//     #(3*CYCLE); rst_n = 'b1;
    
//     if( (out_valid !== 0) || (out_data !== 0)) begin
//         $display("***********************************************************************");
//         $display("*                            SPEC FAIL                                  *");
//         $display("************** Output signal should be 0 after initial RESET at %4t **************",$time);
//         $display("***********************************************************************");
//         #(50);
//         $finish;
//     end
//     #CYCLE;
//     release clk;
//     repeat (5) @(negedge clk);
// end endtask

// task input_task1; begin                                 //golden_Images1~16 are treated as SRAM for storing 16 images

//     for(i=0; i<4096; i=i+1) begin
//         in_valid_data = 'b1;
//         in_data = $random(seed) % 256;

//         if(i<256) begin
//             golden_Image1[i/16][i%16] = in_data;
//         end
//         else if(i >= 256 && i < 512) begin
//             golden_Image2[(i-256)/16][(i-256)%16] = in_data;
//         end
//         else if(i >= 512 && i < 768) begin
//             golden_Image3[(i-512)/16][(i-512)%16] = in_data;
//         end
//         else if(i >= 768 && i < 1024) begin
//             golden_Image4[(i-768)/16][(i-768)%16] = in_data;
//         end
//         else if(i >= 1024 && i < 1280) begin
//             golden_Image5[(i-1024)/16][(i-1024)%16] = in_data;
//         end
//         else if(i >= 1280 && i < 1536) begin
//             golden_Image6[(i-1280)/16][(i-1280)%16] = in_data;
//         end
//         else if(i >= 1536 && i < 1792) begin
//             golden_Image7[(i-1536)/16][(i-1536)%16] = in_data;
//         end
//         else if(i >= 1792 && i < 2048) begin
//             golden_Image8[(i-1792)/16][(i-1792)%16] = in_data;
//         end
//         else if(i >= 2048 && i < 2304) begin
//             golden_Image9[(i-2048)/16][(i-2048)%16] = in_data;
//         end
//         else if(i >= 2304 && i < 2560) begin
//             golden_Image10[(i-2304)/16][(i-2304)%16] = in_data;
//         end
//         else if(i >= 2560 && i < 2816) begin
//             golden_Image11[(i-2560)/16][(i-2560)%16] = in_data;
//         end
//         else if(i >= 2816 && i < 3072) begin
//             golden_Image12[(i-2816)/16][(i-2816)%16] = in_data;
//         end
//         else if(i >= 3072 && i < 3328) begin
//             golden_Image13[(i-3072)/16][(i-3072)%16] = in_data; 
//         end
//         else if(i >= 3328 && i < 3584) begin
//             golden_Image14[(i-3328)/16][(i-3328)%16] = in_data;
//         end
//         else if(i >= 3584 && i < 3840) begin
//             golden_Image15[(i-3584)/16][(i-3584)%16] = in_data;
//         end
//         else if(i >= 3840 && i < 4096) begin
//             golden_Image16[(i-3840)/16][(i-3840)%16] = in_data;
//         end

//         @(negedge clk);
//     end


//     in_valid_data = 'b0;
//     in_data = 'bx;

// end endtask

// task input_task2; begin                                 //golden_task_number is used for storing cmd
//     in_valid_cmd = 'b1;
//     in_cmd = $random(seed) % 1024;  // cmd0

//     if(in_cmd[7:4] == in_cmd[3:0]) begin
//         in_cmd[3:0] = in_cmd[7:4] + 6;
//     end

//     golden_task_number = in_cmd;

//     @(negedge clk);
//     in_valid_cmd = 'b0;
//     in_cmd = 'bx;
// end endtask 

// task wait_out_valid_task; begin
//   latency = 0;
//   while(out_valid !== 1'b1) begin
//     if(latency == 2000) begin
//         $display("*************************************************************************");
//         $display("*                          SPEC FAIL                                    *");
//         $display("*                  Latency are over 2000 cycles                          *");
//         $display("*************************************************************************");
//         repeat(4) @(negedge clk);
//         $finish;
//     end

//     if(out_data !== 0) begin
//         $display("*************************************************************************");
//         $display("*                          SPEC FAIL                                    *");
//         $display("*          out signal should be zero when out_valid is low              *");
//         $display("*************************************************************************");
//         repeat(4) @(negedge clk);
//         $finish;
//     end

//     latency = latency + 1;
//     @(negedge clk);
//   end
//   total_latency+=latency;
// end endtask

// integer op, target1, target2;
// integer sum1, sum2;
// reg [7:0] max[0:15];
// task calculate_task; begin                               
//     op = golden_task_number[9:8];
//     target1 = golden_task_number[7:4];
//     target2 = golden_task_number[3:0];
//     sum1 = 0;
//     sum2 = 0;

//     for(i = 0; i < 16; i = i + 1) begin
//         for(j = 0; j < 16; j = j + 1) begin 
//             golden_Image[1][i][j]  = golden_Image1[i][j]; 
//             golden_Image[2][i][j]  = golden_Image2[i][j]; 
//             golden_Image[3][i][j]  = golden_Image3[i][j]; 
//             golden_Image[4][i][j]  = golden_Image4[i][j]; 
//             golden_Image[5][i][j]  = golden_Image5[i][j]; 
//             golden_Image[6][i][j]  = golden_Image6[i][j]; 
//             golden_Image[7][i][j]  = golden_Image7[i][j]; 
//             golden_Image[8][i][j]  = golden_Image8[i][j]; 
//             golden_Image[9][i][j]  = golden_Image9[i][j]; 
//             golden_Image[10][i][j] = golden_Image10[i][j]; 
//             golden_Image[11][i][j] = golden_Image11[i][j]; 
//             golden_Image[12][i][j] = golden_Image12[i][j]; 
//             golden_Image[13][i][j] = golden_Image13[i][j]; 
//             golden_Image[14][i][j] = golden_Image14[i][j]; 
//             golden_Image[15][i][j] = golden_Image15[i][j]; 
//             golden_Image[16][i][j] = golden_Image16[i][j]; 
//         end
//     end
    
//     if(op == 0) begin
//         for(i = 0; i < 16; i = i + 1) begin
//             for(j = 0; j < 16; j = j + 1) begin
//                 golden_out[i][j] = ({1'b0, golden_Image[target1+1][i][j]} + {1'b0, golden_Image[target2+1][i][j]}) >> 1;
//             end 
//         end
//     end
//     else if (op == 1) begin
//         for(i = 0; i < 16; i = i + 1) begin
//             for(j = 0; j < 16; j = j + 1) begin
//                 golden_out[i][j] = (golden_Image[target1+1][i][j] >= golden_Image[target2+1][i][j]) ? 
//                                    (golden_Image[target1+1][i][j] - golden_Image[target2+1][i][j]) : 
//                                    (golden_Image[target2+1][i][j] - golden_Image[target1+1][i][j]);
//             end 
//         end
//     end
//     else if(op == 2) begin
//         for(i = 0; i < 16; i = i + 1) begin
//             for(j = 0; j < 16; j = j + 1) begin
//                 temp = golden_Image[target1+1][i][j];
//                 golden_Image[target1+1][i][j] = golden_Image[target2+1][i][j];
//                 golden_Image[target2+1][i][j] = temp;
//             end 
//         end
//         for(i = 0; i < 16; i = i + 1) begin
//             for(j = 0; j < 16; j = j + 1) begin
//                 sum1 = golden_Image[target1+1][i][j] + sum1;
//                 sum2 = golden_Image[target2+1][i][j] + sum2;
//             end 
//         end
//         if(sum1 > sum2) begin
//             for(i = 0; i < 16; i = i + 1) begin
//                 for(j = 0; j < 16; j = j + 1) begin
//                     golden_out[i][j] = golden_Image[target1+1][i][j];
//                 end 
//             end
//         end
//         else begin
//             for(i = 0; i < 16; i = i + 1) begin
//                 for(j = 0; j < 16; j = j + 1) begin
//                     golden_out[i][j] = golden_Image[target2+1][i][j];
//                 end 
//             end
//         end

//         for(i = 0; i < 16; i = i + 1) begin
//             for(j = 0; j < 16; j = j + 1) begin
//                 case(target1 + 1)
//                     1: golden_Image1[i][j] = golden_Image[1][i][j];
//                     2: golden_Image2[i][j] = golden_Image[2][i][j];
//                     3: golden_Image3[i][j] = golden_Image[3][i][j];
//                     4: golden_Image4[i][j] = golden_Image[4][i][j];
//                     5: golden_Image5[i][j] = golden_Image[5][i][j];
//                     6: golden_Image6[i][j] = golden_Image[6][i][j];
//                     7: golden_Image7[i][j] = golden_Image[7][i][j];
//                     8: golden_Image8[i][j] = golden_Image[8][i][j];
//                     9: golden_Image9[i][j] = golden_Image[9][i][j];
//                     10: golden_Image10[i][j] = golden_Image[10][i][j];
//                     11: golden_Image11[i][j] = golden_Image[11][i][j];
//                     12: golden_Image12[i][j] = golden_Image[12][i][j];
//                     13: golden_Image13[i][j] = golden_Image[13][i][j];
//                     14: golden_Image14[i][j] = golden_Image[14][i][j];
//                     15: golden_Image15[i][j] = golden_Image[15][i][j];
//                     16: golden_Image16[i][j] = golden_Image[16][i][j];
//                 endcase
//                 case(target2 + 1)
//                     1: golden_Image1[i][j] = golden_Image[1][i][j];
//                     2: golden_Image2[i][j] = golden_Image[2][i][j];
//                     3: golden_Image3[i][j] = golden_Image[3][i][j];
//                     4: golden_Image4[i][j] = golden_Image[4][i][j];
//                     5: golden_Image5[i][j] = golden_Image[5][i][j];
//                     6: golden_Image6[i][j] = golden_Image[6][i][j];
//                     7: golden_Image7[i][j] = golden_Image[7][i][j];
//                     8: golden_Image8[i][j] = golden_Image[8][i][j];
//                     9: golden_Image9[i][j] = golden_Image[9][i][j];
//                     10: golden_Image10[i][j] = golden_Image[10][i][j];
//                     11: golden_Image11[i][j] = golden_Image[11][i][j];
//                     12: golden_Image12[i][j] = golden_Image[12][i][j];
//                     13: golden_Image13[i][j] = golden_Image[13][i][j];
//                     14: golden_Image14[i][j] = golden_Image[14][i][j];
//                     15: golden_Image15[i][j] = golden_Image[15][i][j];
//                     16: golden_Image16[i][j] = golden_Image[16][i][j];
//                 endcase
//             end
//         end
//     end
//     else if(op == 3) begin
//         for(i = 0; i < 16; i = i + 1) begin
//             max[i] = 0;
//         end
//         for(i = 0; i < 16; i = i + 1) begin
//             for(j = 0; j < 16; j = j + 1) begin
//                 if((max[i] < golden_Image[target1+1][i][j])) begin
//                     max[i] = golden_Image[target1+1][i][j];
//                 end
//             end 
//         end
//         for(i = 0; i < 16; i = i + 1) begin
//             for(j = 0; j < 16; j = j + 1) begin
//                 golden_out[i][j] = max[i];
//             end 
//         end
//     end

// end endtask

// task check_ans_task; begin                              
//     for(i = 0; i < 16; i = i + 1) begin
//         for(j = 0; j < 16; j = j + 1) begin
//             if (out_valid !== 1'b1) begin
//                 $display("\n[ERROR] out_valid should be HIGH. It dropped at cycle %0d.", i+1);
//                 $finish;
//             end

//             if(golden_out[i][j] !== out_data) begin
//                 $display("========================================");
//                 $display("          Wrong Answer at PAT %0d       ", pat_num);
//                 $display("========================================");
//                 $display("Your Data    : %d", out_data);
//                 $display("Golden Data  : %d", golden_out[i][j]);
//                 $display("========================================");
//                 $finish;
//             end

//             @(negedge clk);
//         end 
//     end
    
//     if (out_valid !== 1'b0) begin
//         $display("\n[ERROR] out_valid should go LOW.");
//         $finish;
//     end
    
// end endtask


// task PASS_task; 
//   begin
//     $display("\033[32m********************** pass pat_num%d | Your execution cycles = %d cycles **********************\033[0m", pat_num, latency);
//   end
// endtask

// task YOU_PASS_task; begin
//     $display("                                                   ....... ... ....... ..... ... ......                 ");
//     $display("                                              ......:-+#&@@@&#+-:..-+#@@@@@&+:.....                 ");
//     $display("                                        .......:+#@@@@@@&&&&&@@@@@@@@@@&&&&@@@@@*:....              ");
//     $display("                                        ....:*@@@@&*=-:::..:*@@@@&+--:::::::::=#@@*....             ");
//     $display("                                     .....-&@@@#-::::....-@@@@#-:::::::.........=@@:...             ");
//     $display("                                  .  ...=@@@&=::::.....=&@@&=::::::...........:*@@*...              ");
//     $display("                                  . ...*@@&-::::.....-&@@&-::::::..........:+&@@@+. ..              ");
//     $display("                               .. ....&@@+:::::.....+@@&=::::::.........:*&@@@&-... ..              ");
//     $display("                              .. ....&@@=::::.....:+@@&::::::.......:+@@@@@@+......                 ");
//     $display("                     ........:-+#@@@@@@=:::...:@@@@@@@@&-::...:-+&@@@@@&*-.......                   ");
//     $display("                     ....=*&@@@@@@#*+=:........---::---:......@@@@@@@&+-.........                   ");
//     $display("                 ....:*@@@@@&+::..............................::-+#@@@@@@&#-.....                   ");
//     $display("              ....:*@@@@&+......::-=+*+:...............................+&@@@@&-........             ");
//     $display("             ...=&@@@&+:...:=#@@@@&&###-.................#@@@@&#+-:.......:+#@@@*:.....             ");
//     $display("           ...=&@@@*-....-#@@#-:.........................:---=+&@@@&+:.......:=@@@#:......          ");
//     $display("         ...:@@@@=.....:&@@+.....................................:#@@@*.........-&@@&:...           ");
//     $display("        ...*@@@+......=@@#..........................................=&@@+.........=@@@+... .        ");
//     $display("        .:#@@#:......+@@=.............................................=@@#:.........#@@#.....       ");
//     $display("    .....&@@+.......-@@=...............................................:&@@:.........+@@&:...       ");
//     $display("    ....&@@=........#@#:................................................-&@@:.........+@@#:.        ");
//     $display("    ...*@@+........:@@+..................................................=@@#:.........+@@+..       ");
//     $display("    ..-@@#:........:@@=...................................................#@@-..........#@@:.       ");
//     $display("    .:*@@-..........-=.....................................................+=...........-@@#...     ");
//     $display("    .=@@#........................+@@@@#-...................=&@@#:.......................:*@@-...    ");
//     $display(" ....#@@-.....................:*@@=..:@@*................*@@*:=#@&:......................=@@#...    ");
//     $display(" ...:@@&......................=@@&..-&@@&...............+@@#....#@@......................:&@&:.     ");
//     $display(" ...=@@*......................=@@@@@@@@@*...............+@@@@&&@@@@:......................*@@=..    ");
//     $display("  ..+@@+.......................*@@+=*@@#:...............:#@&=++#@@=.......................*@@+..    ");
//     $display("  ..*@@=............::::::::::...=**+=:...................-#@@@@#-..:::::::::.............*@@+..    ");
//     $display(" ...+@@+..........::+@#:::+:::+-...............:*-................::-=:::::::::...........*@@+..    ");
//     $display(" ...-@@#.........::=@@-:-@#-:#@+:.........#@=..+@@-..==..........::=@#::&&-:&&-:.........:#@@=..    ");
//     $display(" ....&@@..........:#@=::&@=:+@*::.........=@@@&@@@@=#@@-.........:-@#-:*@+:*@*::.........-&@&:..    ");
//     $display(" ....+@@+.........::::::-:::::::...........:#@@@@@@@@+...........:=*=::**-:#*:::.........+@@*...    ");
//     $display(" ....:&@@-..........:::::::::::.............*@&=&#:@@=............::::::::::::..........:&@@:...    ");
//     $display("  ....=@@&:.................................*@&:=::@@=.................::...............#@@-....    ");
//     $display("    ...+@@*:................................=@@=:::@@-................................:&@@+....     ");
//     $display("    ....*@@&:................................#@&+-#@#:...............................-&@@*....      ");
//     $display("     ....=@@@*................................=@@@@#:...............................*@@@=.....      ");
//     $display("        ..-&@@@+..............................:...................................*@@@&.....        ");
//     $display("         ...+@@@@+:..........................:@&+#&:...........................:+@@@@+......        ");
//     $display("         .....+@@@@#=.........................:+*+-..........................=#@@@@+.........       ");
//     $display("           .  ..-&@@@@@*:................................................:*&@@@@&-..........        ");
//     $display("              .....=&@@@@@@#=-::..................................::-=#@@@@@@&=.....                ");
//     $display("                 .....:+#@@@@@@@@&#+=-:::................:::-=+*&@@@@@@@@#+:.......                 ");
//     $display("                 ..........:-=#@@@@@@@@@@@@@@&&&&&&&&@@@@@@@@@@@@@@#=-:........                     ");
//     $display("                           .........:-=+*#&&&&@@@@@@&&&&#*+--:..... ..                              ");
//     $display("                           ..          .. .. ...             .  .. ..                           ");
//     $display("                                                     ");
//     $display("                                                      ");
//     $display("                          \033[0;32m \033[5m    //   ) )     // | |     //   ) )     //   ) )\033[m");
//     $display("                          \033[0;32m \033[5m   //___/ /     //__| |    ((           ((\033[m");
//     $display("                          \033[0;32m \033[5m  / ____ /     / ___  |      \\           \\\033[m");
//     $display("                          \033[0;32m \033[5m //           //    | |        ) )          ) )\033[m");
//     $display("                          \033[0;32m \033[5m//           //     | | ((___ / /    ((___ / /\033[m");
//     $display("                                  ----------------------------               ");
//     $display("                                  --                        --               ");
//     $display("                                  --  Congratulations !!    --               ");
//     $display("                                  --                        --               ");
//     $display("                                  --  \033[0;32mSimulation PASS!!\033[m          ");
//     $display("                                  --                        --               ");
//     $display("                                  --                        --               ");
//     $display("                                Total Latency = %d cycles                                    ", total_latency);
//     $display("                                  ----------------------------               ");
//     // $display("*                  Computation Time = %10d ns          *", total_latency * `CYCLE_TIME);
//     // $display("************************************************************************");
//     $finish;
// end endtask



// always @(*) begin
//     if(out_valid === 1 && in_valid_data === 1) begin
//         $display("*************************************************************************");
//         $display("*                            SPEC FAIL                                  *");
//         $display("*               out_valid cannot overlap with in_valid                  *");
//         $display("*************************************************************************");
//         repeat(4) @(negedge clk);
//         $finish;
//     end

//     if(out_valid === 1 && in_valid_cmd === 1) begin
//         $display("*************************************************************************");
//         $display("*                            SPEC FAIL                                  *");
//         $display("*               out_valid cannot overlap with in_valid                  *");
//         $display("*************************************************************************");
//         repeat(4) @(negedge clk);
//         $finish;
//     end
// end


// endmodule



