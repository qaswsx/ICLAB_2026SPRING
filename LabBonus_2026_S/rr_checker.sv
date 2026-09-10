module rr_checker #(
    parameter int N = 8
)(
    input  logic         clk,
    input  logic         rst_n,
    input  logic [N-1:0] req,
    input  logic [N-1:0] gnt
);

   // req need to high until corresponding gnt raise
   genvar gen_i;
   generate 
        for (gen_i = 0; gen_i < N; gen_i = gen_i + 1) begin : gen_blk 
            AST_REQ_KEEP_UNTIL_GNT : assume property( req[gen_i] && !gnt[gen_i] |=> req[gen_i]);
        end
   endgenerate

// ======= Question 1 : Cover ========

   // Cover example 1 : gnt[0] asserted (high). Observe req[0] to see corresponsing request
   EX1_GNT_0_COVER : cover property ( gnt[0] );
   // Cover example 2 : gnt[0] asserted then gnt[1] asserted in the next cycle
   //                   Observe req[0] and req[1] to see corresponsing request
   EX2_GNT_0_1_SEQ_COVER : cover property ( gnt[0] ##1 gnt[1] );


   // === Question 1.1 === 
   // Please create the cover A1P1_COVER to describe the scenario : 
   // Where gnt[0] asserted, followed by gnt[1] asserted in the next cycle,
   // then gnt[2] in the following cycle, and so on, until all gnt signals have been asserted sequentially once
   A1P1_COVER : cover property (
        gnt[0] ##1 gnt[1] ##1 gnt[2] ##1 gnt[3] ##1
        gnt[4] ##1 gnt[5] ##1 gnt[6] ##1 gnt[7]
    );
   // A1P1_COVER : <write your answer here>
   
   // === Question 1.2 ===
   // Q1P2_COVER describes all 8 req raised after gnt[0] asserted then after some cycle gnt[0] asserted again   
   // (In SVA, ##[0:$] means from 0 to infinity) 
   // Please check the length of shortest waveform and explain it from design knowledge
   // (We ask Jasper to report shortest possible waveform in this case)
   Q1P2_COVER :  cover property ( gnt[0] ##1 (&req) ##[0:$] gnt[0] );

   // === Question 1.3 ===
   // Please explain the result of these two covers from design knowledge
   // (In SVA, [*n] means replication for n cycles)
   Q1P3_COVER_1 :  cover property ( (req[0] && gnt[1]) ##1 (!gnt[0])[*6] );
   Q1P3_COVER_2 :  cover property ( (req[0] && gnt[1]) ##1 (!gnt[0])[*7] );

// ======= Question 2 : Assert ========
 
   // Asssert example : Check IF gnt[0] asserted THEN gnt[1] cannot asserted 
   // (In SVA, |-> means same cycle implication : 
   // Right-hand side (consequence) must be hold in the same cycle while Left-hand side (pre-condition) meet) 
   EX3_GNT0_NO_GNT1_ASSERT : assert property ( gnt[0] |-> !gnt[1] );


   // === Question 2.1 ===
   // Please create the assert that checks while gnt[0] asserted, all other gnts cannot be asserted
   A2P1_ASSERT : assert property (
        gnt[0] |-> (gnt[7:1] == 7'b0)
    );
   // A2P1_ASSERT : <write your answer here>

   // === Question 2.2 ===
   // Please create the assert that checks only one or zero gnt can be asserted at the same time
   // (Tips : Search $countone)
   A2P2_ASSERT : assert property (
        $countones(gnt) <= 1
    );
   // A2P2_ASSERT : <write your answer here>

   // === Question 2.3 ===
   // There is a bug in the design. Please try to find it by the fail of assertion
   // The violation of it claims in some condition, the request cannot get granted suitably, which violates the design intent of Round-robin arbiter
   Q2P2_ASSERT : assert property ( req[0] |-> ##[0:7] gnt[0] );


endmodule

bind rr rr_checker # (.N(N)) i_rr_checker (.*);





