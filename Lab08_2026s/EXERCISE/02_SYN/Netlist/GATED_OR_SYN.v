/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : T-2022.03
// Date      : Mon May  4 13:05:50 2026
/////////////////////////////////////////////////////////////


module GATED_OR ( CLOCK, SLEEP_CTRL, RST_N, CLOCK_GATED );
  input CLOCK, SLEEP_CTRL, RST_N;
  output CLOCK_GATED;
  wire   latch_or_sleep;

  QDLHRBN latch_or_sleep_reg ( .CK(CLOCK), .D(SLEEP_CTRL), .RB(RST_N), .Q(
        latch_or_sleep) );
  OR2 U4 ( .I1(CLOCK), .I2(latch_or_sleep), .O(CLOCK_GATED) );
endmodule

