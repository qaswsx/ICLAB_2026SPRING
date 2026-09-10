//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   ICLAB 2026 OT 
//      File Name : OT_DESIGN.v
//    Module Name : OT
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

`timescale 1ns/10ps

`include "PATTERN.v"

`ifdef RTL
    `include "OT_DESIGN.v"
`elsif GATE
    `include "OT_DESIGN_SYN.v"
`endif

	  		  	
module TESTBED;



wire          clk;
wire          rst_n;
wire          in_valid_data;
wire   [7:0]  in_data;
wire          in_valid_cmd;
wire  [9:0]  in_cmd;

wire          out_valid;
wire   [7:0]  out_data;

initial begin
	`ifdef RTL
		$fsdbDumpfile("OT_DESIGN.fsdb");
		$fsdbDumpvars(0,"+mda");
		$fsdbDumpvars();
	`endif
	`ifdef GATE
		$sdf_annotate("OT_DESIGN_SYN.sdf", u_design);
		//$fsdbDumpfile("design_SYN.fsdb");
		//$fsdbDumpvars();    
	`endif
end

`ifdef RTL
	OT_DESIGN u_design(
		// input signals
		.clk(clk),
		.rst_n(rst_n),

		.in_valid_data(in_valid_data),
		.in_data(in_data),

		.in_valid_cmd(in_valid_cmd),
		.in_cmd(in_cmd),

		// output signals
		.out_valid(out_valid),
		.out_data(out_data)
	);
`elsif GATE
	OT_DESIGN u_design(
		// input signals
		.clk(clk),
		.rst_n(rst_n),

		.in_valid_data(in_valid_data),
		.in_data(in_data),

		.in_valid_cmd(in_valid_cmd),
		.in_cmd(in_cmd),

		// output signals
		.out_valid(out_valid),
		.out_data(out_data)
	);
`endif

PATTERN u_PATTERN(
    // Output signals
    .clk(clk),
	.rst_n(rst_n),

	.in_valid_data(in_valid_data),
	.in_data(in_data),

	.in_valid_cmd(in_valid_cmd),
	.in_cmd(in_cmd),

    // Input signals
	.out_valid(out_valid),
	.out_data(out_data)
);
 
endmodule
