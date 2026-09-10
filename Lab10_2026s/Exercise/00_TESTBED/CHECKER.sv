/*
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
NYCU Institute of Electronic
2026 Spring IC Design Laboratory 
Lab10: SystemVerilog Coverage & Assertion
File Name   : CHECKER.sv
Module Name : CHECKER
Release version : v1.0 (Release Date: May-2026)
Author : Chia-Hsin Lee
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/

`include "Usertype.sv"
module CHECKER(input clk, INF.CHECKER inf);
import usertype::*;

// integer fp_w;

// initial begin
// fp_w = $fopen("out_valid.txt", "w");
// end

/**
 * This section contains the definition of the class and the instantiation of the object.
 *  * 
 * The always_ff blocks update the object based on the values of valid signals.
 * When valid signal is true, the corresponding property is updated with the value of inf.D
 */

class Type_and_mode;
    Dessert_Type f_type;
    Order_Mode f_mode;
endclass
Type_and_mode fm_info = new();

always_comb begin
    if(inf.type_valid) fm_info.f_type = inf.D.d_type[0];
    if(inf.mode_valid) fm_info.f_mode = inf.D.d_mode[0];
end

// =================================================
// Coverage 1
// =================================================

covergroup CG_SPEC1 @(posedge clk iff inf.type_valid);
    option.per_instance = 1;

    cp_type: coverpoint inf.D.d_type[0] {
        option.at_least = 100;
        bins b_cookie     = {Cookie};
        bins b_bread      = {Bread};
        bins b_fruitcake  = {Fruit_Cake};
        bins b_pudding    = {Pudding};
        bins b_macaron    = {Macaron};
        bins b_pancake    = {Pancake};
        bins b_brownie    = {Brownie};
        bins b_scone      = {Scone};
    }
endgroup

CG_SPEC1 cg_spec1_inst = new();

// =================================================
// Coverage 2
// =================================================

covergroup CG_SPEC2 @(posedge clk iff inf.mode_valid);
    option.per_instance = 1;

    cp_mode: coverpoint inf.D.d_mode[0] {
        option.at_least = 100;
        bins b_single = {Single};
        bins b_family = {Family_Set};
        bins b_party  = {Party_Pack};
    }
endgroup

CG_SPEC2 cov_spec2 = new();

// =================================================
// Coverage 3
// =================================================

covergroup CG_SPEC3 @(posedge clk iff inf.mode_valid);
    option.per_instance = 1;

    // cp_type: coverpoint fm_info.f_type {
    //     bins b_cookie     = {Cookie};
    //     bins b_bread      = {Bread};
    //     bins b_fruitcake  = {Fruit_Cake};
    //     bins b_pudding    = {Pudding};
    //     bins b_macaron    = {Macaron};
    //     bins b_pancake    = {Pancake};
    //     bins b_brownie    = {Brownie};
    //     bins b_scone      = {Scone};
    // }

    // cp_mode: coverpoint inf.D.d_mode[0] {
    //     bins b_single = {Single};
    //     bins b_family = {Family_Set};
    //     bins b_party  = {Party_Pack};
    // }

    cross_type_mode: cross fm_info.f_mode, fm_info.f_type {
        option.at_least = 100;
    }
endgroup

CG_SPEC3 cov_spec3 = new();

// =================================================
// Coverage 4
// =================================================

covergroup CG_SPEC4 @(posedge clk iff inf.out_valid);
    option.per_instance = 1;

    cp_warn_msg: coverpoint inf.warn_msg {
        option.at_least = 40;

        bins b_no_warn       = {No_Warn};
        bins b_date_warn     = {Date_Warn};
        bins b_no_staff_warn = {No_Staff_Warn};
        bins b_stock_warn    = {Stock_Warn};
        bins b_balance_warn  = {Balance_Warn};
        bins b_restock_warn  = {Restock_Warn};
        bins b_staff_warn    = {Staff_Warn};
    }
endgroup

CG_SPEC4 cov_spec4 = new();

// =================================================
// Coverage 5
// =================================================

covergroup CG_SPEC5 @(posedge clk iff inf.sel_action_valid);
    option.per_instance = 1;

    cp_action: coverpoint inf.D.d_act[0] {
        option.at_least = 200;

        bins action_transition[] =
            ([Make_and_Sell:Check_Valid_Date] => [Make_and_Sell:Check_Valid_Date]);
    }
endgroup

CG_SPEC5 cov_spec5 = new();

// =================================================
// Coverage 6
// =================================================

covergroup CG_SPEC6 @(posedge clk iff inf.restock_valid);
    option.per_instance = 1;

    cp_restock_amount: coverpoint inf.D.d_stock[0] {
        option.auto_bin_max = 128;
        option.at_least     = 5;

        bins b_restock_amt[128] = {[0:2047]};
    }
endgroup

CG_SPEC6 cov_spec6 = new();

// =================================================
// Coverage 7
// =================================================

covergroup CG_SPEC7 @(posedge clk iff inf.out_valid);
    option.per_instance = 1;

    cp_complete: coverpoint inf.complete {
        option.at_least = 1500;

        bins b_complete = {1'b1};
    }
endgroup

CG_SPEC7 cov_spec7 = new();

// =================================================
// Assertion 1
// =================================================

assert_1: assert property (
    @(negedge inf.rst_n)
    1'b1 |-> @(posedge inf.rst_n)
    (      inf.out_valid === 0
        && inf.warn_msg  === 0
        && inf.complete  === 0
        && inf.AR_VALID  === 0
        && inf.AR_ADDR   === 0
        && inf.R_READY   === 0
        && inf.AW_VALID  === 0
        && inf.AW_ADDR   === 0
        && inf.W_VALID   === 0
        && inf.W_DATA    === 0
        && inf.B_READY   === 0
    )
)
else begin
    $display("================================================");
    $display("            Assertion 1 is violated             ");
    $display("================================================");
    $fatal;
end

// =================================================
// Assertion 2
// =================================================

sequence seq_make;
    (inf.D.d_act[0] === Make_and_Sell)
    ##[1:999] inf.type_valid
    ##[1:999] inf.mode_valid
    ##[1:999] inf.date_valid
    ##[1:999] inf.data_no_valid
    ##[1:999] inf.out_valid;
endsequence

sequence seq_restock;
    (inf.D.d_act[0] === Restock)
    ##[1:999] inf.date_valid
    ##[1:999] inf.data_no_valid
    ##[1:999] inf.restock_valid
    ##[1:999] inf.restock_valid
    ##[1:999] inf.restock_valid
    ##[1:999] inf.restock_valid
    ##[1:999] inf.restock_valid
    ##[1:999] inf.out_valid;
endsequence

sequence seq_hire;
    (inf.D.d_act[0] === Hire_Staff)
    ##[1:999] inf.staff_valid
    ##[1:999] inf.date_valid
    ##[1:999] inf.data_no_valid
    ##[1:999] inf.out_valid;
endsequence

sequence seq_pay;
    (inf.D.d_act[0] === Pay_Day)
    ##[1:999] inf.date_valid
    ##[1:999] inf.data_no_valid
    ##[1:999] inf.out_valid;
endsequence

sequence seq_check_date;
    (inf.D.d_act[0] === Check_Valid_Date)
    ##[1:999] inf.date_valid
    ##[1:999] inf.data_no_valid
    ##[1:999] inf.out_valid;
endsequence

assert_2: assert property (
    @(posedge clk)
    inf.sel_action_valid |-> (seq_make or seq_restock or seq_hire or seq_pay or seq_check_date)
)
else begin
    $display("================================================");
    $display("            Assertion 2 is violated             ");
    $display("================================================");
    $fatal;
end

// =================================================
// Assertion 3
// =================================================

assert_3: assert property (
    @(negedge clk)
    (inf.out_valid === 1'b1 && inf.complete === 1'b1)
    |-> (inf.warn_msg === No_Warn)
)
else begin
    $display("================================================");
    $display("            Assertion 3 is violated             ");
    $display("================================================");
    $fatal;
end

// =================================================
// Assertion 4
// =================================================

sequence s4_make;
    (inf.D.d_act[0] === Make_and_Sell)
    ##[1:4] inf.type_valid
    ##[1:4] inf.mode_valid
    ##[1:4] inf.date_valid
    ##[1:4] inf.data_no_valid;
endsequence

sequence s4_restock;
    (inf.D.d_act[0] === Restock)
    ##[1:4] inf.date_valid
    ##[1:4] inf.data_no_valid
    ##[1:4] inf.restock_valid
    ##[1:4] inf.restock_valid
    ##[1:4] inf.restock_valid
    ##[1:4] inf.restock_valid
    ##[1:4] inf.restock_valid;
endsequence

sequence s4_hire;
    (inf.D.d_act[0] === Hire_Staff)
    ##[1:4] inf.staff_valid
    ##[1:4] inf.date_valid
    ##[1:4] inf.data_no_valid;
endsequence

sequence s4_pay;
    (inf.D.d_act[0] === Pay_Day)
    ##[1:4] inf.date_valid
    ##[1:4] inf.data_no_valid;
endsequence

sequence s4_check_date;
    (inf.D.d_act[0] === Check_Valid_Date)
    ##[1:4] inf.date_valid
    ##[1:4] inf.data_no_valid;
endsequence

assert_4: assert property (
    @(posedge clk)
    inf.sel_action_valid |-> (s4_make or s4_restock or s4_hire or s4_pay or s4_check_date)
)
else begin
    $display("================================================");
    $display("            Assertion 4 is violated             ");
    $display("================================================");
    $fatal;
end

// =================================================
// Assertion 5
// =================================================

assert_5: assert property (
    @(posedge clk)
    $onehot0({
        inf.sel_action_valid,
        inf.type_valid,
        inf.mode_valid,
        inf.staff_valid,
        inf.date_valid,
        inf.data_no_valid,
        inf.restock_valid
    })
)
else begin
    $display("================================================");
    $display("            Assertion 5 is violated             ");
    $display("================================================");
    $fatal;
end

// =================================================
// Assertion 6
// =================================================

// assert_6: assert property (
//     @(negedge clk)
//     (inf.out_valid === 1'b1) |=> (inf.out_valid === 1'b0)
// )
// else begin
//     $display("================================================");
//     $display("            Assertion 6 is violated             ");
//     $display("================================================");
//     $fatal;
// end

assert_6_one_cycle: assert property (
    @(negedge clk)
    (inf.out_valid === 1'b1) |=> (inf.out_valid === 1'b0)
)
else begin
    $display("================================================");
    $display("            Assertion 6 is violated             ");
    $display("================================================");
    $fatal;
end

assert_6_complete_low: assert property (
    @(negedge clk)
    (inf.rst_n === 1'b1 && inf.out_valid === 1'b0)
    |-> (inf.complete === 1'b0)
)
else begin
    $display("================================================");
    $display("            Assertion 6 is violated             ");
    $display("================================================");
    $fatal;
end

assert_6_out_no_input_overlap: assert property (
    @(posedge clk)
    !(inf.out_valid === 1'b1 &&
      (inf.sel_action_valid === 1'b1 ||
       inf.type_valid       === 1'b1 ||
       inf.mode_valid       === 1'b1 ||
       inf.staff_valid      === 1'b1 ||
       inf.date_valid       === 1'b1 ||
       inf.data_no_valid    === 1'b1 ||
       inf.restock_valid    === 1'b1))
)
else begin
    $display("================================================");
    $display("            Assertion 6 is violated             ");
    $display("================================================");
    $fatal;
end

// =================================================
// Assertion 7
// =================================================

assert_7: assert property (
    @(posedge clk)
    inf.out_valid |-> ##[1:4] inf.sel_action_valid
)
else begin
    $display("================================================");
    $display("            Assertion 7 is violated             ");
    $display("================================================");
    $fatal;
end

// =================================================
// Assertion 8
// =================================================

// assert_8: assert property (
//     @(posedge clk)
//     inf.date_valid |->
//     (
//         (
//             (inf.D.d_date[0].M === 4'd1  ||
//              inf.D.d_date[0].M === 4'd3  ||
//              inf.D.d_date[0].M === 4'd5  ||
//              inf.D.d_date[0].M === 4'd7  ||
//              inf.D.d_date[0].M === 4'd8  ||
//              inf.D.d_date[0].M === 4'd10 ||
//              inf.D.d_date[0].M === 4'd12)
//             &&
//             (inf.D.d_date[0].D >= 5'd1 && inf.D.d_date[0].D <= 5'd31)
//         )
//         ||
//         (
//             (inf.D.d_date[0].M === 4'd4  ||
//              inf.D.d_date[0].M === 4'd6  ||
//              inf.D.d_date[0].M === 4'd9  ||
//              inf.D.d_date[0].M === 4'd11)
//             &&
//             (inf.D.d_date[0].D >= 5'd1 && inf.D.d_date[0].D <= 5'd30)
//         )
//         ||
//         (
//             (inf.D.d_date[0].M === 4'd2)
//             &&
//             (inf.D.d_date[0].D >= 5'd1 && inf.D.d_date[0].D <= 5'd28)
//         )
//     )
// )
// else begin
//     $display("================================================");
//     $display("            Assertion 8 is violated             ");
//     $display("================================================");
//     $fatal;
// end

assert_8: assert property (
    @(posedge clk)
    inf.date_valid |->
    (
        (inf.D.d_date[0].M inside {[1:12]}) &&
        (
            ((inf.D.d_date[0].M == 2) &&
             (inf.D.d_date[0].D inside {[1:28]})) ||

            ((inf.D.d_date[0].M inside {4,6,9,11}) &&
             (inf.D.d_date[0].D inside {[1:30]})) ||

            ((inf.D.d_date[0].M inside {1,3,5,7,8,10,12}) &&
             (inf.D.d_date[0].D inside {[1:31]}))
        )
    )
)
else begin
    $display("================================================");
    $display("            Assertion 8 is violated             ");
    $display("================================================");
    $fatal;
end

assert_8_input_value_legal: assert property (
    @(posedge clk)
    (
        (!inf.sel_action_valid || (inf.D.d_act[0] inside {Make_and_Sell, Restock, Hire_Staff, Pay_Day, Check_Valid_Date})) &&
        (!inf.type_valid       || (inf.D.d_type[0] inside {Cookie, Bread, Fruit_Cake, Pudding, Macaron, Pancake, Brownie, Scone})) &&
        (!inf.mode_valid       || (inf.D.d_mode[0] inside {Single, Family_Set, Party_Pack})) &&
        (!inf.staff_valid      || (inf.D.d_staff[0] inside {[1:30]})) &&
        (!inf.restock_valid    || (inf.D.d_stock[0] inside {[0:2047]})) &&
        (!inf.data_no_valid    || (inf.D.d_data_no[0] inside {[0:127]}))
    )
)
else begin
    $display("================================================");
    $display("            Assertion 8 is violated             ");
    $display("================================================");
    $fatal;
end

// =================================================
// Assertion 9
// =================================================

// assert_9: assert property (
//     @(negedge clk)
//     !(inf.AR_VALID === 1'b1 && inf.AW_VALID === 1'b1)
// )
// else begin
//     $display("================================================");
//     $display("            Assertion 9 is violated             ");
//     $display("================================================");
//     $fatal;
// end

assert_9: assert property (
    @(negedge clk)
    !(inf.AR_VALID === 1'b1 && inf.AW_VALID === 1'b1)
)
else begin
    $display("================================================");
    $display("            Assertion 9 is violated             ");
    $display("================================================");
    $fatal;
end

endmodule