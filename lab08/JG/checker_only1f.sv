
module checker_only1f (

	input clk,
  input rst_n,
  input in_valid

);

reg in_valid_d1_keep;
always @(posedge clk or negedge rst_n)
  if (~rst_n) in_valid_d1_keep <= 1'b0;
  else in_valid_d1_keep <= in_valid || in_valid_d1_keep;

wire first_in_valid_pulse = in_valid && !in_valid_d1_keep;

// add for keeping 97 cycle invalid
reg [7:0] counter_in_valid;
always @(posedge clk or negedge rst_n)
  if (~rst_n) counter_in_valid <= 8'b0;
  else if (first_in_valid_pulse) counter_in_valid <= 8'b1;
  else if (counter_in_valid!=8'b0) counter_in_valid <= (counter_in_valid==8'd97) ? 8'd97 : counter_in_valid+1'd1; 

wire in_valid_keep = (counter_in_valid>8'd0) && (counter_in_valid<8'd97);
wire in_valid_forbidden = (counter_in_valid==8'd97);

endmodule

bind LAB8_DESIGN checker_only1f bind_checker_only1f (.*);
