`define CYCLE_TIME      31.4

module PATTERN(
    // Output Port (To DUT)
    clk,
    rst_n,
    instruction_in_valid,
    image_in_valid,
    weight_in_valid,
    in_data,
    
    // Input Port (From DUT)
    out_valid,
    out_data
);

// Output Port (To DUT)
output reg clk;
output reg rst_n;
output reg instruction_in_valid;
output reg image_in_valid;
output reg weight_in_valid;
output reg [31:0] in_data;
    
// Input Port (From DUT)
input    out_valid;
input  [31:0]  out_data;


//================================================================
// parameters & integer
//================================================================
real CYCLE = `CYCLE_TIME;

// ========== Parameter ==========
parameter PAT_NUM = 100;
integer i_pat;
integer exe_latency;
integer total_latency;


// ========== file path ==========
parameter IMAGE_FILE = "../00_TESTBED/image.dat";
parameter WEIGHT_FILE = "../00_TESTBED/weight.dat";
parameter INST_FILE = "../00_TESTBED/inst.dat";
parameter GOLD_FILE = "../00_TESTBED/golden.dat";


//================================================================
// wire & registers 
//================================================================

reg [31:0] inst_mem   [0:PAT_NUM-1];
reg [31:0] weight_mem [0:(PAT_NUM*144)-1];
reg [31:0] image_mem  [0:(PAT_NUM*128)-1];
reg [31:0] golden_mem [0:(PAT_NUM*128)-1];

//================================================================
// clock
//================================================================
initial 
begin
	clk = 0;
end
always #(CYCLE/2.0) clk = ~clk;


//================================================================
// initial
//================================================================
initial begin
    rst_n = 1'b1;
    instruction_in_valid = 1'b0;
    weight_in_valid = 1'b0;
    force clk = 0;
    image_in_valid = 1'b0;
    in_data = 32'bx;

    load_test_data;   

    reset_signal_task;  
    #(CYCLE*3);

    for (i_pat = 0; i_pat < PAT_NUM; i_pat = i_pat + 1) begin
        $display("------------------------------------------------------------------------");
		$display("  Testing Pattern %0d/%0d", i_pat+1, PAT_NUM);
		$display("------------------------------------------------------------------------");
        repeat($urandom_range(1, 3)) @(negedge clk);

        instruction_task;
        weight_task;
        image_task;
        
        
        wait_out_valid; 
        check_ans;      
        
        $display("Pass Pattern No.%0d", i_pat);
    end

    $display("=================================================");
    $display("  Congratulations! All patterns passed!          ");
    $display("=================================================");
    $finish;
end


//================================================================
// Output monitoring and checking
//================================================================

// Check out signal when out_valid is low
always @(negedge clk) begin	
	if(out_valid === 0 && (out_data !== 32'b0)) begin
        $display("---------------------------------------------------------------------------------------------");
        $display("             FAIL! The output signals should be 0 when out_valid is pulled down.                   ");
        $display("                               Time: %0t, out_data = %0d", $time, out_data);
        $display("---------------------------------------------------------------------------------------------");
        repeat(2) #CYCLE;
        $finish;
    end
end

// I/O_valid overlap check
always @(negedge clk) begin	
	if(out_valid === 1 && ((instruction_in_valid === 1) || (weight_in_valid === 1) || (image_in_valid === 1))) begin
        $display("---------------------------------------------------------------------------------------------");
        $display("             FAIL! The out_valid should not be high when image_in_valid is high.                ");
        $display("---------------------------------------------------------------------------------------------");
        $finish;
	end
end


//================================================================
// task
//================================================================

task reset_signal_task; 
begin 
    #(CYCLE);  rst_n = 0;
    #(CYCLE*3); rst_n = 1;
    if((out_valid !== 0) || (out_data !== 0)) 
    begin
        $display("---------------------------------------------------------------------------------------------");
        $display("             FAIL! Output signals should be 0 after reset at %4t.", $time);
        $display("                            out_valid = %b, out_data = %0d", out_valid, out_data);
        $display("---------------------------------------------------------------------------------------------");
        $finish;
    end
    #(CYCLE* $urandom_range(2, 5))
    release clk;
end 
endtask

task load_test_data;
begin
    $readmemh(IMAGE_FILE, image_mem);
    $readmemh(WEIGHT_FILE, weight_mem);
    $readmemh(INST_FILE, inst_mem);
    $readmemh(GOLD_FILE, golden_mem);
end
endtask

task instruction_task;
begin
    @(negedge clk);
    instruction_in_valid = 1'b1;
    in_data = inst_mem[i_pat];
    
    @(negedge clk);
    instruction_in_valid = 1'b0;
    in_data = 32'bx;
end
endtask

task weight_task;
integer w_idx;
integer wait_cycles;
begin
    wait_cycles = $urandom_range(2, 5);
    repeat(wait_cycles) @(negedge clk);

    weight_in_valid = 1'b1;
    for(w_idx = 0; w_idx < 144; w_idx = w_idx + 1) begin
        in_data = weight_mem[i_pat * 144 + w_idx];
        @(negedge clk);
    end
    
    weight_in_valid = 1'b0;
    in_data = 32'bx;
end
endtask

task image_task;
integer img_idx;
integer wait_cycles;
begin
    wait_cycles = $urandom_range(2, 5);
    repeat(wait_cycles) @(negedge clk);

    image_in_valid = 1'b1;
    for(img_idx = 0; img_idx < 128; img_idx = img_idx + 1) begin
        in_data = image_mem[i_pat * 128 + img_idx];
        @(negedge clk);
    end
    
    image_in_valid = 1'b0;
    in_data = 32'bx;
end
endtask

task wait_out_valid;
begin
    exe_latency = 0;
    while(out_valid === 1'b0) begin
        if(exe_latency >= 1200) begin
            $display("=================================================");
            $display("  Failed! Execution Latency exceeded 1200 cycles!");
            $display("=================================================");
            $finish;
        end
        @(negedge clk);
        exe_latency = exe_latency + 1;
    end
    total_latency = total_latency + exe_latency;
end
endtask

task check_ans;
integer out_idx;
real golden_val, my_out_val, diff, error;
begin
    for(out_idx = 0; out_idx < 128; out_idx = out_idx + 1) begin
        if(out_valid === 1'b0) begin
            $display("Error: out_valid should be strictly high for 128 cycles.");
            $finish;
        end

        // 32-bit to floating point
        golden_val = $bitstoshortreal(golden_mem[i_pat * 128 + out_idx]);
        my_out_val = $bitstoshortreal(out_data);

        // 💥 修改：依照要求直接計算絕對誤差 |golden_ans - out_data|
        diff = golden_val - my_out_val;
        error = (diff < 0.0) ? -diff : diff;

        // 判斷是否大於等於 0.002
        if(error >= 0.002) begin
            $display("=================================================");
            $display("  Failed! Pattern %0d, Output index: %0d", i_pat, out_idx);
            $display("  Golden: %.15f, Yours: %.15f, Error: %f", golden_val, my_out_val, error);
            $display("=================================================");
            $finish;
        end
        @(negedge clk);
    end

    if (out_valid !== 1'b0) begin 
        $display("=================================================");
        $display("  Failed! out_valid is active for MORE than 128 cycles! ");
        $display("=================================================");
        $finish;
    end

    if(out_data !== 32'b0) begin
        $display("Error: out_data must be 0 when out_valid is low.");
        $finish;
    end
end
endtask

endmodule