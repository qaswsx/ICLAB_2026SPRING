module DSS(input clk, INF.DSS_inf inf);
    import usertype::*;

    FSM cs, ns;
//==================================================================
    // ALL DECLARATIONS
    //==================================================================
    
    logic        act_make_r;
    logic        act_restock_r;
    logic        act_hire_r;
    logic        act_payday_r;
    logic        act_cvd_r;
    Month        month_temp;
    Day          day_temp;
    Data_No      data_no_temp;
    Stock        restock_temp [0:4];
    Dessert_Type type_temp;
    Order_Mode   mode_temp;
    Staff_t      staff_temp;
    logic [2:0]  restock_cnt;
    Stock        cur_flour, cur_butter, cur_milk, cur_sugar, cur_fruit;
    Sales_t      cur_sales;
    Month        cur_month;
    Day          cur_day;
    Level_t      cur_level;
    Staff_t      cur_staff;
    Balance_t    cur_balance;
    logic [3:0]  calc_cnt;
    logic [1:0]  read_word_cnt;
    logic [1:0]  write_word_cnt;
    logic        w_beat;
    logic        calc_done_w;
    logic        r_handshake;
    logic        ar_handshake;
    logic        b_handshake;
    logic        w_handshake;
    logic        aw_handshake;

    logic        write_done_w;
    logic        read_done_w;
    logic        payday_no_staff_fast_w;
    logic        staff_zero_for_warn_w;

    logic        out_complete_reg;
    Warn_Msg     out_warn_msg_reg;
    logic        write_word2_r;
    logic        need_write_word2_w;

    logic        use_wr_stock_w;
    logic        use_wr_fruit_w;
    logic [63:0] wdata_word1_w;
    logic [63:0] wdata_word2_w;
    
    logic [20:0] req_total_cost_r;
    logic [23:0] cost_r;
    
    logic        cur_staff_zero_r;
    logic        is_staff_warn_r;
    logic [12:0] make_sales_sum_r;
    logic [6:0]  make_th_r;
    logic        make_need_fruit_r;
    logic        add_req_r;
    logic        add_actual_r;
    logic [20:0] mul_prod_21_r;
    
    logic        make_stock_warn_r;
    logic        make_stock_warn_now_w;
    logic [2:0]  make_idx_w;
    Stock        make_cur_stock_w;
    Stock        make_base_ing_w;
    Stock        make_req_ing_w;

    logic        stock_eng_valid_r;
    logic        stock_eng_is_make_r;
    logic [2:0]  stock_eng_idx_r;
    Stock        stock_eng_a_r;
    Stock        stock_eng_b_r;
    logic [12:0] stock_eng_sum_w;
    logic [12:0] stock_make_diff_w;
    logic        stock_eng_overflow_w;
    logic        stock_eng_underflow_w;
    Stock        stock_eng_final_stock_w;
    Stock        stock_eng_actual_qty_w;
    
    logic [4:0]  cur_factor_r;
    logic [5:0]  price_bonus_r;
    logic [5:0]  base_price_coeff_w;
    logic [9:0]  make_single_price_w;
    logic        setup_req_d, setup_actual_d;
    logic        setup_req_r, setup_actual_r;
    logic [2:0]  ing_idx_d, ing_idx_r;
    
    logic [3:0]  sale_inc_w;
    logic [3:0]  level_div10_w;
    logic [4:0]  cur_factor_w;
    logic [5:0]  price_bonus_w;
    logic [15:0] hr_level_cost_r;
    logic [15:0] unit_price_w;
    logic [8:0]  total_staff_w;
    logic        staff_over_100_w;
    
    logic [7:0]  actual_hire_amount_w;
    logic [12:0] current_total_sales_w;
    logic [6:0]  upgrade_threshold_w;
    logic        is_staff_warn_w;

    logic [11:0] sel_cur_stock_w;
    logic [11:0] sel_restock_w;
    logic [7:0]  sel_unit_cost_w;
    logic        overflow_acc_r;
    logic        capture_mul_w;
    logic        add_req_w;
    logic        add_actual_w;
    logic [15:0] mul_a_r;
    logic [7:0]  mul_b_r;
    logic [19:0] mul_part_lo_r;
    logic [19:0] mul_part_hi_r;
    logic [23:0] mul_prod_sum_w;

    logic [8:0]  unit_a_w;
    logic [8:0]  unit_b_w;
    logic [8:0]  unit_sum_w;

    Warn_Msg     final_warn_msg_w;
    logic        out_complete_w;

    logic [23:0] balance_op_b_w;
    logic        balance_sub_w;
    logic [24:0] balance_addsub_w;
    logic        balance_underflow_w;
    Balance_t    balance_calc_w;
    
    logic [23:0] balance_calc_r;
    logic [23:0] out_balance_w;
    logic [11:0] out_sales_w;
    logic [7:0]  out_staff_w;
    logic [7:0]  out_level_w;
    logic [7:0]  penalty_level_w;

    logic [4:0]  max_day_w;
    logic        date_invalid_w;
    logic        cur_date_earlier_w;
    logic        cvd_date_earlier_w;
    logic        cvd_date_warn_w;
    logic        date_warn_w;
    logic [12:0] make_norm_sales_r;
    logic [7:0]  make_norm_level_r;

    logic balance_warn_now_w;
    logic warn_no_staff_w;
    logic warn_stock_w;
    logic warn_balance_w;
    logic warn_restock_w;
    logic warn_staff_w;
    
    logic restock_cap_w;
    logic restock_add_req_w;
    logic restock_add_actual_w;
    logic restock_balance_warn_now_w;

    logic [12:0] make_div_rem_r;
    logic [8:0]  make_div_q_r;
    logic [8:0]  make_div_bit_mask_w;
    logic [14:0] make_div_th_shift_w;
    logic [14:0] make_div_rem_ext_w;
    logic [14:0] make_div_sub_w;
    logic [12:0] make_div_rem_next_w;
    logic [8:0]  make_div_q_next_w;
    logic [9:0]  make_div_new_level_w;
    logic use_balance_calc_w;

    //==================================================================
    // Combinational Assignments
    //==================================================================
    assign penalty_level_w = (cur_level >= 8'd10) ? (cur_level - 8'd10) : 8'd0;

    assign read_done_w = (act_cvd_r) ?
        ((read_word_cnt == 2'd0) && r_handshake) :
        ((read_word_cnt == 2'd2) || ((read_word_cnt == 2'd1) && r_handshake));
    assign payday_no_staff_fast_w  = act_payday_r && (cur_staff == 8'd0);
    assign staff_zero_for_warn_w =
        ((act_make_r || act_payday_r) && calc_cnt == 4'd0) ?
        (cur_staff == 8'd0) : cur_staff_zero_r;

    assign r_handshake  = inf.R_VALID  && inf.R_READY;
    assign ar_handshake = inf.AR_VALID && inf.AR_READY;
    assign b_handshake  = inf.B_VALID  && inf.B_READY;
    assign w_handshake  = inf.W_VALID  && inf.W_READY;
    assign aw_handshake = inf.AW_VALID && inf.AW_READY;

    assign make_stock_warn_now_w = make_stock_warn_r |
        (stock_eng_valid_r && stock_eng_is_make_r && stock_eng_underflow_w);
    assign write_done_w = b_handshake && (write_word_cnt == {1'b0, write_word2_r});
    assign make_idx_w   = calc_cnt[2:0];

    // Combinational division step
    always_comb begin
        make_div_bit_mask_w = 9'd0;
        make_div_th_shift_w = 15'd0;

        unique case (calc_cnt)
            4'd1: begin
                make_div_bit_mask_w = 9'b1_0000_0000;
                make_div_th_shift_w = {make_th_r, 8'd0};
            end
            4'd2: begin
                make_div_bit_mask_w = 9'b0_1000_0000;
                make_div_th_shift_w = {1'd0, make_th_r, 7'd0};
            end
            4'd3: begin
                make_div_bit_mask_w = 9'b0_0100_0000;
                make_div_th_shift_w = {2'd0, make_th_r, 6'd0};
            end
            4'd4: begin
                make_div_bit_mask_w = 9'b0_0010_0000;
                make_div_th_shift_w = {3'd0, make_th_r, 5'd0};
            end
            4'd5: begin
                make_div_bit_mask_w = 9'b0_0001_0000;
                make_div_th_shift_w = {4'd0, make_th_r, 4'd0};
            end
            4'd6: begin
                make_div_bit_mask_w = 9'b0_0000_1000;
                make_div_th_shift_w = {5'd0, make_th_r, 3'd0};
            end
            4'd7: begin
                make_div_bit_mask_w = 9'b0_0000_0100;
                make_div_th_shift_w = {6'd0, make_th_r, 2'd0};
            end
            4'd8: begin
                make_div_bit_mask_w = 9'b0_0000_0010;
                make_div_th_shift_w = {7'd0, make_th_r, 1'd0};
            end
            4'd9: begin
                make_div_bit_mask_w = 9'b0_0000_0001;
                make_div_th_shift_w = {8'd0, make_th_r};
            end
            default: begin
                make_div_bit_mask_w = 9'd0;
                make_div_th_shift_w = 15'd0;
            end
        endcase
    end

    assign make_div_rem_ext_w   = {2'd0, make_div_rem_r};
    assign make_div_sub_w       = make_div_rem_ext_w - make_div_th_shift_w;
    assign make_div_new_level_w = {2'd0, cur_level} + {1'b0, make_div_q_r};
    always_comb begin
        make_div_q_next_w   = make_div_q_r;
        make_div_rem_next_w = make_div_rem_r;
        if (make_div_rem_ext_w >= make_div_th_shift_w) begin
            make_div_rem_next_w = make_div_sub_w[12:0];
            make_div_q_next_w   = make_div_q_r | make_div_bit_mask_w;
        end
    end

    always_comb begin
        unique case (mode_temp)
            Single:     make_req_ing_w = make_base_ing_w;
            Family_Set: make_req_ing_w = {make_base_ing_w[9:0], 2'b00};
            Party_Pack: make_req_ing_w = {make_base_ing_w[8:0], 3'b000};
            default:    make_req_ing_w = make_base_ing_w;
        endcase
    end

    assign stock_eng_sum_w         = {1'b0, stock_eng_a_r} + {1'b0, stock_eng_b_r};
    assign stock_eng_overflow_w    = stock_eng_sum_w[12];
    assign stock_make_diff_w       = {1'b0, stock_eng_a_r} - {1'b0, stock_eng_b_r};
    assign stock_eng_underflow_w   = stock_make_diff_w[12];
    assign stock_eng_final_stock_w = stock_eng_is_make_r ?
        (stock_eng_underflow_w ? stock_eng_a_r : stock_make_diff_w[11:0]) :
        (stock_eng_overflow_w  ? 12'd4095      : stock_eng_sum_w[11:0]);
    assign stock_eng_actual_qty_w  = stock_eng_overflow_w ? ~stock_eng_a_r : stock_eng_b_r;

    always_comb begin
        if      (act_restock_r) calc_done_w = (calc_cnt == 4'd14);
        else if (act_hire_r)    calc_done_w = (calc_cnt == 4'd7);
        else if (act_payday_r)  calc_done_w = payday_no_staff_fast_w ? (calc_cnt == 4'd0) : (calc_cnt == 4'd7);
        else if (act_make_r) begin
            calc_done_w = staff_zero_for_warn_w ? (calc_cnt == 4'd0) :
                          (((calc_cnt >= 4'd1) && make_stock_warn_now_w) ||
                           (calc_cnt >= 4'd10));
        end
        else if (act_cvd_r)     calc_done_w = (calc_cnt == 4'd0);
        else                    calc_done_w = (calc_cnt == 4'd0);
    end

    always_comb begin
        unique case (month_temp)
            4'd2: max_day_w = 5'd28;
            4'd4, 4'd6, 4'd9, 4'd11: max_day_w = 5'd30;
            4'd1, 4'd3, 4'd5, 4'd7, 4'd8, 4'd10, 4'd12: max_day_w = 5'd31;
            default: max_day_w = 5'd0;
        endcase
    end
    assign use_balance_calc_w =
    ((act_hire_r || act_restock_r) && (out_warn_msg_reg != Balance_Warn)) ||
    ((act_payday_r || act_make_r)  && (out_warn_msg_reg == No_Warn));

    assign date_invalid_w   = (day_temp == 5'd0) ||
        (day_temp > max_day_w);

    assign cur_date_earlier_w =
        (month_temp < cur_month) ||
        ((month_temp == cur_month) && (day_temp < cur_day));

    assign cvd_date_earlier_w =
        (month_temp < inf.R_DATA[35:32]) ||
        ((month_temp == inf.R_DATA[35:32]) && (day_temp < inf.R_DATA[4:0]));

    assign date_warn_w    = date_invalid_w || cur_date_earlier_w;
    assign cvd_date_warn_w = date_invalid_w || cvd_date_earlier_w;

    always_comb begin
        unique case (make_idx_w)
            3'd0:    make_cur_stock_w = cur_flour;
            3'd1:    make_cur_stock_w = cur_butter;
            3'd2:    make_cur_stock_w = cur_milk;
            3'd3:    make_cur_stock_w = cur_sugar;
            3'd4:    make_cur_stock_w = cur_fruit;
            default: make_cur_stock_w = 12'd0;
        endcase
    end

    always_comb begin
        make_base_ing_w = 12'd0;
        unique case (type_temp)
            Cookie: begin
                unique case (make_idx_w)
                    3'd0:    make_base_ing_w = 12'd100;
                    3'd1:    make_base_ing_w = 12'd50;
                    3'd3:    make_base_ing_w = 12'd30;
                    default: make_base_ing_w = 12'd0;
                endcase
            end
            Bread: begin
                unique case (make_idx_w)
                    3'd0:    make_base_ing_w = 12'd200;
                    3'd1:    make_base_ing_w = 12'd20;
                    3'd2:    make_base_ing_w = 12'd50;
                    3'd3:    make_base_ing_w = 12'd10;
                    default: make_base_ing_w = 12'd0;
                endcase
            end
            Fruit_Cake: begin
                unique case (make_idx_w)
                    3'd0:    make_base_ing_w = 12'd150;
                    3'd1:    make_base_ing_w = 12'd80;
                    3'd2:    make_base_ing_w = 12'd40;
                    3'd3:    make_base_ing_w = 12'd60;
                    3'd4:    make_base_ing_w = 12'd100;
                    default: make_base_ing_w = 12'd0;
                endcase
            end
            Pudding: begin
                unique case (make_idx_w)
                    3'd2:    make_base_ing_w = 12'd150;
                    3'd3:    make_base_ing_w = 12'd50;
                    3'd4:    make_base_ing_w = 12'd20;
                    default: make_base_ing_w = 12'd0;
                endcase
            end
            Macaron: begin
                unique case (make_idx_w)
                    3'd0:    make_base_ing_w = 12'd40;
                    3'd1:    make_base_ing_w = 12'd30;
                    3'd3:    make_base_ing_w = 12'd120;
                    default: make_base_ing_w = 12'd0;
                endcase
            end
            Pancake: begin
                unique case (make_idx_w)
                    3'd0:    make_base_ing_w = 12'd120;
                    3'd1:    make_base_ing_w = 12'd30;
                    3'd2:    make_base_ing_w = 12'd80;
                    3'd3:    make_base_ing_w = 12'd20;
                    3'd4:    make_base_ing_w = 12'd40;
                    default: make_base_ing_w = 12'd0;
                endcase
            end
            Brownie: begin
                unique case (make_idx_w)
                    3'd0:    make_base_ing_w = 12'd80;
                    3'd1:    make_base_ing_w = 12'd100;
                    3'd3:    make_base_ing_w = 12'd100;
                    default: make_base_ing_w = 12'd0;
                endcase
            end
            Scone: begin
                unique case (make_idx_w)
                    3'd0:    make_base_ing_w = 12'd150;
                    3'd1:    make_base_ing_w = 12'd60;
                    3'd2:    make_base_ing_w = 12'd30;
                    3'd3:    make_base_ing_w = 12'd20;
                    3'd4:    make_base_ing_w = 12'd10;
                    default: make_base_ing_w = 12'd0;
                endcase
            end
            default: make_base_ing_w = 12'd0;
        endcase
    end

    always_comb begin
        unique case (mode_temp)
            Single:     sale_inc_w = 4'd1;
            Family_Set: sale_inc_w = 4'd4;
            Party_Pack: sale_inc_w = 4'd8;
            default:    sale_inc_w = 4'd1;
        endcase
        
        unique case (cur_level[7:4])
            4'd0: begin level_div10_w = (cur_level[3:0] >= 4'd10) ? 4'd1 : 4'd0; end
            4'd1: begin 
                if      (cur_level[3:0] >= 4'd14) level_div10_w = 4'd3;
                else if (cur_level[3:0] >= 4'd4 ) level_div10_w = 4'd2; 
                else                              level_div10_w = 4'd1;
            end
            4'd2: begin level_div10_w = (cur_level[3:0] >= 4'd8) ? 4'd4 : 4'd3; end
            4'd3: begin 
                if      (cur_level[3:0] >= 4'd12) level_div10_w = 4'd6;
                else if (cur_level[3:0] >= 4'd2 ) level_div10_w = 4'd5; 
                else                              level_div10_w = 4'd4;
            end
            4'd4: begin level_div10_w = (cur_level[3:0] >= 4'd6) ? 4'd7 : 4'd6; end
            4'd5: begin level_div10_w = (cur_level[3:0] >= 4'd10) ? 4'd9 : 4'd8; end
            4'd6: begin level_div10_w = (cur_level[3:0] >= 4'd4) ? 4'd10 : 4'd9; end
            default: begin level_div10_w = 4'd10; end
        endcase

        cur_factor_w  = 5'd10 + {1'b0, level_div10_w};
        
        unique case (cur_level)
            8'd0, 8'd1, 8'd2, 8'd3, 8'd4, 8'd5, 8'd6, 8'd7, 8'd8, 8'd9, 8'd10, 8'd11, 8'd12, 8'd13, 8'd14: price_bonus_w = 6'd0;
            8'd15, 8'd16, 8'd17, 8'd18, 8'd19: price_bonus_w = 6'd1;
            8'd20, 8'd21, 8'd22, 8'd23, 8'd24: price_bonus_w = 6'd2;
            8'd25, 8'd26, 8'd27, 8'd28: price_bonus_w = 6'd3;
            8'd29, 8'd30, 8'd31: price_bonus_w = 6'd4;
            8'd32, 8'd33, 8'd34: price_bonus_w = 6'd5;
            8'd35, 8'd36, 8'd37: price_bonus_w = 6'd6;
            8'd38, 8'd39: price_bonus_w = 6'd7;
            8'd40, 8'd41, 8'd42: price_bonus_w = 6'd8;
            8'd43, 8'd44: price_bonus_w = 6'd9;
            8'd45, 8'd46: price_bonus_w = 6'd10;
            8'd47, 8'd48: price_bonus_w = 6'd11;
            8'd49, 8'd50: price_bonus_w = 6'd12;
            8'd51, 8'd52: price_bonus_w = 6'd13;
            8'd53, 8'd54: price_bonus_w = 6'd14;
            8'd55, 8'd56: price_bonus_w = 6'd15;
            8'd57, 8'd58: price_bonus_w = 6'd16;
            8'd59: price_bonus_w = 6'd17;
            8'd60, 8'd61: price_bonus_w = 6'd18;
            8'd62, 8'd63: price_bonus_w = 6'd19;
            8'd64: price_bonus_w = 6'd20;
            8'd65, 8'd66: price_bonus_w = 6'd21;
            8'd67: price_bonus_w = 6'd22;
            8'd68, 8'd69: price_bonus_w = 6'd23;
            8'd70: price_bonus_w = 6'd24;
            8'd71, 8'd72: price_bonus_w = 6'd25;
            8'd73: price_bonus_w = 6'd26;
            8'd74: price_bonus_w = 6'd27;
            8'd75, 8'd76: price_bonus_w = 6'd28;
            8'd77: price_bonus_w = 6'd29;
            8'd78: price_bonus_w = 6'd30;
            8'd79: price_bonus_w = 6'd31;
            8'd80, 8'd81: price_bonus_w = 6'd32;
            8'd82: price_bonus_w = 6'd33;
            8'd83: price_bonus_w = 6'd34;
            8'd84: price_bonus_w = 6'd35;
            8'd85, 8'd86: price_bonus_w = 6'd36;
            8'd87: price_bonus_w = 6'd37;
            8'd88: price_bonus_w = 6'd38;
            8'd89: price_bonus_w = 6'd39;
            8'd90: price_bonus_w = 6'd40;
            8'd91: price_bonus_w = 6'd41;
            8'd92: price_bonus_w = 6'd42;
            8'd93: price_bonus_w = 6'd43;
            8'd94: price_bonus_w = 6'd44;
            8'd95: price_bonus_w = 6'd45;
            8'd96: price_bonus_w = 6'd46;
            8'd97: price_bonus_w = 6'd47;
            8'd98: price_bonus_w = 6'd48;
            8'd99: price_bonus_w = 6'd49;
            8'd100: price_bonus_w = 6'd50;
            default: price_bonus_w = 6'd50;
        endcase

        total_staff_w  = {1'b0, cur_staff} + {1'b0, staff_temp};
        staff_over_100_w = (total_staff_w > 9'd100);

        actual_hire_amount_w = staff_over_100_w ? (8'd100 - cur_staff) : staff_temp;
        is_staff_warn_w       = staff_over_100_w;
        upgrade_threshold_w = (cur_level < 8'd10) ? 7'd10 :
                                                        ({level_div10_w, 3'b000} + {2'd0, level_div10_w, 1'b0});
        current_total_sales_w = {1'b0, cur_sales} + {9'd0, sale_inc_w};
    end

    always_comb begin
        unique case (type_temp)
            Cookie:     base_price_coeff_w = 6'd12;
            Bread:      base_price_coeff_w = 6'd10;
            Fruit_Cake: base_price_coeff_w = 6'd40;
            Pudding:    base_price_coeff_w = 6'd18;
            Macaron:    base_price_coeff_w = 6'd25;
            Pancake:    base_price_coeff_w = 6'd20;
            Brownie:    base_price_coeff_w = 6'd28;
            Scone:      base_price_coeff_w = 6'd16;
            default:    base_price_coeff_w = 6'd0;
        endcase
    end

    always_comb begin
        setup_req_d    = 1'b0;
        setup_actual_d = 1'b0;
        ing_idx_d      = 3'd0;
        if (act_restock_r && (calc_cnt <= 4'd9)) begin
            ing_idx_d      = calc_cnt[3:1];
            setup_req_d    = ~calc_cnt[0];
            setup_actual_d =  calc_cnt[0];
        end
    end

    assign restock_cap_w        = act_restock_r && (calc_cnt >= 4'd2) && (calc_cnt <= 4'd11);
    assign restock_add_req_w    = act_restock_r && (calc_cnt >= 4'd3) && (calc_cnt <= 4'd11) &&  calc_cnt[0];
    assign restock_add_actual_w = act_restock_r && (calc_cnt >= 4'd4) && (calc_cnt <= 4'd12) && ~calc_cnt[0];
    always_comb begin
        capture_mul_w = 1'b0;
        add_req_w     = 1'b0;
        add_actual_w  = 1'b0;
        
        capture_mul_w = restock_cap_w ||
                ((act_payday_r || act_hire_r) && 
                 (calc_cnt == 4'd1 || calc_cnt == 4'd3 || calc_cnt == 4'd5)) ||
                (act_make_r && calc_cnt == 4'd1);

        add_req_w    = restock_add_req_w;
        add_actual_w = restock_add_actual_w;
    end

    always_comb begin
        unique case (ing_idx_r)
            3'd0: begin 
                unit_a_w = {4'd0, cur_factor_r};
                unit_b_w = {3'd0, cur_factor_r, 1'b0}; 
            end 
            3'd1: begin 
                unit_a_w = {2'd0, cur_factor_r, 2'd0};
                unit_b_w = {3'd0, cur_factor_r, 1'b0}; 
            end
            3'd2: begin 
                unit_a_w = {2'd0, cur_factor_r, 2'd0};
                unit_b_w = {4'd0, cur_factor_r};      
            end
            3'd3: begin 
                unit_a_w = {4'd0, cur_factor_r};
                unit_b_w = 9'd0;                        
            end
            3'd4: begin 
                unit_a_w = {1'd0, cur_factor_r, 3'd0};
                unit_b_w = 9'd0;                        
            end
            default: begin 
                unit_a_w = 9'd0;
                unit_b_w = 9'd0; 
            end
        endcase
    end
    
    assign unit_sum_w = unit_a_w + unit_b_w;
    always_comb begin
        sel_cur_stock_w = cur_flour;
        sel_restock_w    = restock_temp[0];
        sel_unit_cost_w  = 8'd0;
        
        unique case (ing_idx_r)
            3'd0: begin
                sel_cur_stock_w = cur_flour;
                sel_restock_w    = restock_temp[0];
                sel_unit_cost_w  = unit_sum_w[8:1];
            end
            3'd1: begin
                sel_cur_stock_w = cur_butter;
                sel_restock_w    = restock_temp[1];
                sel_unit_cost_w  = unit_sum_w[7:0];
            end
            3'd2: begin
                sel_cur_stock_w = cur_milk;
                sel_restock_w    = restock_temp[2];
                sel_unit_cost_w  = unit_sum_w[8:1];
            end
            3'd3: begin
                sel_cur_stock_w = cur_sugar;
                sel_restock_w    = restock_temp[3];
                sel_unit_cost_w  = unit_sum_w[7:0];
            end
            3'd4: begin
                sel_cur_stock_w = cur_fruit;
                sel_restock_w    = restock_temp[4];
                sel_unit_cost_w  = unit_sum_w[7:0];
            end
            default: begin end
        endcase

        mul_prod_sum_w = {4'd0, mul_part_lo_r} + {mul_part_hi_r, 4'd0};
    end

    always_comb begin
        unit_price_w = 16'd0;

        if (act_payday_r) begin
            unit_price_w = 16'd20000 + hr_level_cost_r + {mul_prod_sum_w[12:0], 3'b000};
        end
        else if (act_hire_r) begin
            unit_price_w = 16'd2000 + hr_level_cost_r + mul_prod_sum_w[15:0];
        end
        else begin
            unit_price_w = {6'd0, mul_prod_sum_w[9:0]} + {10'd0, price_bonus_r};
        end
    end

    assign make_single_price_w = unit_price_w[9:0];

    assign balance_op_b_w = cost_r;
    assign balance_sub_w = act_hire_r || act_payday_r || act_restock_r;

    // assign balance_addsub_w = {1'b0, cur_balance} +
    //                           {1'b0, (balance_op_b_w ^ {24{balance_sub_w}})} +
    //                           {24'd0, balance_sub_w};

    // assign balance_calc_w = balance_addsub_w[23:0];
    // assign balance_underflow_w = balance_sub_w && ~balance_addsub_w[24];
    logic balance_overflow_w;

    assign balance_addsub_w = {1'b0, cur_balance} +
                            {1'b0, (balance_op_b_w ^ {24{balance_sub_w}})} +
                            {24'd0, balance_sub_w};

    assign balance_overflow_w  = (!balance_sub_w) && balance_addsub_w[24];
    assign balance_calc_w      = balance_overflow_w ? 24'hFF_FFFF : balance_addsub_w[23:0];
    assign balance_underflow_w = balance_sub_w && ~balance_addsub_w[24];

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (~inf.rst_n) balance_calc_r <= 24'd0;
        else            balance_calc_r <= balance_calc_w;
    end

    assign restock_balance_warn_now_w = act_restock_r && (calc_cnt == 4'd14) && balance_underflow_w;
    assign balance_warn_now_w = act_restock_r ?
                                restock_balance_warn_now_w :
                                (act_payday_r || act_hire_r) ?
                                balance_underflow_w : 1'b0; 

    assign warn_no_staff_w = (act_make_r || act_payday_r) && staff_zero_for_warn_w;
    assign warn_stock_w    = act_make_r && make_stock_warn_now_w;
    assign warn_balance_w  = balance_warn_now_w;
    assign warn_restock_w  = act_restock_r && overflow_acc_r;
    assign warn_staff_w    = act_hire_r && is_staff_warn_r;

    always_comb begin
        if      (date_warn_w)     final_warn_msg_w = Date_Warn;
        else if (warn_no_staff_w) final_warn_msg_w = No_Staff_Warn;
        else if (warn_stock_w)    final_warn_msg_w = Stock_Warn;
        else if (warn_balance_w)  final_warn_msg_w = Balance_Warn;
        else if (warn_restock_w)  final_warn_msg_w = Restock_Warn;
        else if (warn_staff_w)    final_warn_msg_w = Staff_Warn;
        else                      final_warn_msg_w = No_Warn;
        out_complete_w = !(date_warn_w || warn_no_staff_w || warn_stock_w ||
                           warn_balance_w || warn_restock_w || warn_staff_w);
    end

    always_comb begin
        need_write_word2_w = 1'b1;
        if (act_cvd_r)
            need_write_word2_w = 1'b0;
        else if (act_make_r)
            need_write_word2_w = !(warn_no_staff_w || warn_stock_w);
        else if (act_restock_r)
            need_write_word2_w = !warn_balance_w;
        else if (act_hire_r)
            need_write_word2_w = !warn_balance_w;
        else if (act_payday_r)
            need_write_word2_w = !warn_no_staff_w;
    end

    assign use_wr_stock_w =
        (act_restock_r && (out_warn_msg_reg != Balance_Warn)) ||
        (act_make_r    && (out_warn_msg_reg == No_Warn));

    assign use_wr_fruit_w =
        (act_restock_r && (out_warn_msg_reg != Balance_Warn)) ||
        (act_make_r    && (out_warn_msg_reg == No_Warn) && make_need_fruit_r);
    assign wdata_word1_w = {
        use_wr_stock_w ?
        restock_temp[0]  : cur_flour,
        use_wr_stock_w ?
        restock_temp[1]  : cur_butter,
        4'd0,
        month_temp,
        use_wr_stock_w ?
        restock_temp[2]  : cur_milk,
        use_wr_stock_w ?
        restock_temp[3]  : cur_sugar,
        3'd0,
        day_temp
    };
    always_comb begin
        out_balance_w = use_balance_calc_w ? balance_calc_r : cur_balance;

        out_level_w = cur_level;
        out_sales_w = cur_sales;
        if (act_payday_r && out_warn_msg_reg == Balance_Warn) begin
            out_level_w = penalty_level_w;
            out_sales_w = 12'd0;
        end
        else if (act_make_r && out_warn_msg_reg == No_Warn) begin
            out_level_w = make_norm_level_r;
            out_sales_w = make_norm_sales_r[11:0];
        end

        out_staff_w = cur_staff;
        if (act_hire_r && out_warn_msg_reg != Balance_Warn) begin
            out_staff_w = staff_over_100_w ?
                8'd100 : total_staff_w[7:0];
        end
        else if (act_payday_r && out_warn_msg_reg == Balance_Warn) begin
            out_staff_w = (cur_staff[7:1] == 7'd0) ?
                8'd1 : {1'b0, cur_staff[7:1]};
        end
    end

    assign wdata_word2_w = {
        use_wr_fruit_w ?
        restock_temp[4] : cur_fruit, 
        out_sales_w,
        out_staff_w,
        out_balance_w,
        out_level_w
    };
    //==================================================================
    // Sequential FSM 
    //==================================================================
    always_comb begin
        ns = cs;
        case (cs)
            IDLE: ns = inf.sel_action_valid ? GET_IN : IDLE;
            GET_IN: begin
                if (act_restock_r) ns = (restock_cnt == 3'd4 && inf.restock_valid) ? READ_DRAM : GET_IN;
                else               ns = inf.data_no_valid ? READ_DRAM : GET_IN;
            end
            READ_DRAM: begin
                if (read_done_w) begin
                    if (!act_cvd_r && date_warn_w) ns = IDLE;
                    else if (act_cvd_r)            ns = WRITE_DRAM;
                    else                           ns = CALC;
                end
                else ns = READ_DRAM;
            end
            CALC:       ns = calc_done_w ? WRITE_DRAM : CALC;
            WRITE_DRAM: ns = write_done_w ? IDLE : WRITE_DRAM;
            default:    ns = IDLE;
        endcase
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (~inf.rst_n) cs <= IDLE;
        else            cs <= ns;
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (~inf.rst_n) calc_cnt <= 4'd0;
        else if (cs == CALC) begin
            if (calc_done_w) calc_cnt <= 4'd0;
            else             calc_cnt <= calc_cnt + 4'd1;
        end
        else calc_cnt <= 4'd0;
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (~inf.rst_n) begin
            act_make_r    <= 1'b1;
            act_restock_r <= 1'b0;
            act_hire_r    <= 1'b0;
            act_payday_r  <= 1'b0;
            act_cvd_r     <= 1'b0;
        end
        else if (inf.sel_action_valid) begin
            act_make_r    <= (inf.D.d_act[0] == Make_and_Sell);
            act_restock_r <= (inf.D.d_act[0] == Restock);
            act_hire_r    <= (inf.D.d_act[0] == Hire_Staff);
            act_payday_r  <= (inf.D.d_act[0] == Pay_Day);
            act_cvd_r     <= (inf.D.d_act[0] == Check_Valid_Date);
        end
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (~inf.rst_n) begin
            month_temp <= 0;
            day_temp   <= 0;
        end
        else if (inf.date_valid) begin
            month_temp <= inf.D.d_date[0].M;
            day_temp   <= inf.D.d_date[0].D;
        end
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (~inf.rst_n)         data_no_temp <= 0;
        else if (inf.data_no_valid) data_no_temp <= inf.D.d_data_no[0];
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (~inf.rst_n)         restock_cnt <= 0;
        else if (inf.restock_valid) restock_cnt <= restock_cnt + 1'b1;
        else if (cs == IDLE)    restock_cnt <= 0;
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (~inf.rst_n) begin
            for (int i = 0; i < 5; i = i + 1) restock_temp[i] <= 0;
        end
        else begin
            if (inf.restock_valid) begin
                restock_temp[restock_cnt] <= inf.D.d_stock[0];
            end
            else if (cs == CALC && stock_eng_valid_r) begin
                if (!stock_eng_is_make_r || (!cur_staff_zero_r && stock_eng_is_make_r)) begin
                    restock_temp[stock_eng_idx_r] <= stock_eng_final_stock_w;
                end
            end
        end
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (~inf.rst_n)         type_temp <= Cookie;
        else if (inf.type_valid) type_temp <= inf.D.d_type[0];
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (~inf.rst_n)         mode_temp <= Single;
        else if (inf.mode_valid) mode_temp <= inf.D.d_mode[0];
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (~inf.rst_n)          staff_temp <= 0;
        else if (inf.staff_valid) staff_temp <= inf.D.d_staff[0];
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (~inf.rst_n)             read_word_cnt <= 2'd0;
        else if (cs == IDLE)        read_word_cnt <= 2'd0;
        else if (r_handshake)       read_word_cnt <= read_word_cnt + 1'b1;
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (~inf.rst_n) begin
            inf.AR_VALID <= 1'b0;
            inf.AR_ADDR  <= 17'd0;
        end
        else begin
            if (inf.data_no_valid) begin
                inf.AR_VALID <= 1'b1;
                inf.AR_ADDR  <= {6'b010000, inf.D.d_data_no[0], 4'b0000};
            end
            else if (ar_handshake && inf.AR_ADDR[3] == 1'b0) begin
                if (act_cvd_r) begin
                    inf.AR_VALID <= 1'b0;
                end
                else begin
                    inf.AR_VALID <= 1'b1;
                    inf.AR_ADDR  <= {6'b010000, data_no_temp, 4'b1000};
                end
            end
            else if (ar_handshake && inf.AR_ADDR[3] == 1'b1) begin
                inf.AR_VALID <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (~inf.rst_n) inf.R_READY <= 1'b0;
        else begin
            if (inf.AR_VALID || ar_handshake) inf.R_READY <= 1'b1;
            else if (r_handshake &&
                    ((act_cvd_r && read_word_cnt == 2'd0) ||
                     (!act_cvd_r && read_word_cnt == 2'd1))) begin
                inf.R_READY <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (r_handshake) begin
            if (read_word_cnt == 2'd0) begin
                cur_flour  <= inf.R_DATA[63:52];
                cur_butter <= inf.R_DATA[51:40];
                cur_month  <= inf.R_DATA[35:32];
                cur_milk   <= inf.R_DATA[31:20];
                cur_sugar  <= inf.R_DATA[19:8];
                cur_day    <= inf.R_DATA[4:0];
            end
            else if (read_word_cnt == 2'd1) begin
                cur_fruit   <= inf.R_DATA[63:52];
                cur_sales   <= inf.R_DATA[51:40];
                cur_staff   <= inf.R_DATA[39:32];
                cur_balance <= inf.R_DATA[31:8];
                cur_level   <= inf.R_DATA[7:0];
            end
        end
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (~inf.rst_n) begin
            inf.AW_VALID <= 1'b0;
            inf.AW_ADDR  <= 17'd0;
        end
        else begin
            if ((cs == CALC && calc_done_w && ns == WRITE_DRAM) ||
                (cs == READ_DRAM && act_cvd_r && read_done_w)) begin
                inf.AW_VALID <= 1'b1;
                inf.AW_ADDR  <= {6'b010000, data_no_temp, 4'b0000};
            end
            else if (aw_handshake && inf.AW_ADDR[3] == 1'b0) begin
                if (write_word2_r) begin
                    inf.AW_VALID <= 1'b1;
                    inf.AW_ADDR  <= {6'b010000, data_no_temp, 4'b1000};
                end
                else begin
                    inf.AW_VALID <= 1'b0;
                end
            end
            else if (aw_handshake && inf.AW_ADDR[3] == 1'b1) begin
                inf.AW_VALID <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (~inf.rst_n)       w_beat <= 1'b0;
        else if (cs == IDLE)  w_beat <= 1'b0;
        else if (w_handshake) w_beat <= 1'b1;
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (~inf.rst_n) begin
            inf.W_VALID <= 1'b0;
            inf.W_DATA  <= 64'd0;
        end
        else begin
            if (cs == WRITE_DRAM && write_word_cnt == 2'd0 && w_beat == 1'b0 && !inf.W_VALID) begin
                inf.W_VALID <= 1'b1;
                inf.W_DATA  <= wdata_word1_w;
            end
            else if (w_handshake && w_beat == 1'b0) begin
                if (write_word2_r) begin
                    inf.W_VALID <= 1'b1;
                    inf.W_DATA  <= wdata_word2_w;
                end
                else begin
                    inf.W_VALID <= 1'b0;
                end
            end
            else if (w_handshake && w_beat == 1'b1) begin
                inf.W_VALID <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (~inf.rst_n) inf.B_READY <= 1'b0;
        else begin
            if (inf.AW_VALID || inf.W_VALID) inf.B_READY <= 1'b1;
            else if (write_done_w)           inf.B_READY <= 1'b0;
        end
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (~inf.rst_n)       write_word_cnt <= 2'd0;
        else if (cs == IDLE)  write_word_cnt <= 2'd0;
        else if (b_handshake) write_word_cnt <= write_word_cnt + 1'b1;
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (~inf.rst_n) begin
            setup_req_r    <= 1'b0;
            setup_actual_r <= 1'b0;
            ing_idx_r      <= 3'd0;
            add_req_r      <= 1'b0;
            add_actual_r   <= 1'b0;
            mul_prod_21_r  <= 21'd0;
        end
        else if (cs == CALC) begin
            setup_req_r    <= setup_req_d;
            setup_actual_r <= setup_actual_d;
            ing_idx_r      <= ing_idx_d;
            add_req_r      <= add_req_w;
            add_actual_r   <= add_actual_w;
            mul_prod_21_r  <= mul_prod_sum_w[20:0];
        end
        else begin
            setup_req_r    <= 1'b0;
            setup_actual_r <= 1'b0;
            ing_idx_r      <= 3'd0;
            add_req_r      <= 1'b0;
            add_actual_r   <= 1'b0;
            mul_prod_21_r  <= 21'd0;
        end
    end

    always_ff @(posedge clk) begin
        stock_eng_valid_r <= 1'b0;
        if (cs == CALC) begin
            if (act_make_r &&
                ((calc_cnt <= 4'd3) || ((calc_cnt == 4'd4) && make_need_fruit_r))) begin
                stock_eng_valid_r   <= 1'b1;
                stock_eng_is_make_r <= 1'b1;
                stock_eng_idx_r     <= make_idx_w;
                stock_eng_a_r       <= make_cur_stock_w;
                stock_eng_b_r       <= make_req_ing_w;
            end
            else if (act_restock_r && setup_req_r) begin
                stock_eng_valid_r   <= 1'b1;
                stock_eng_is_make_r <= 1'b0;
                stock_eng_idx_r     <= ing_idx_r;
                stock_eng_a_r       <= sel_cur_stock_w;
                stock_eng_b_r       <= sel_restock_w;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (cs == CALC) begin
            if (calc_cnt == 4'd0) begin
                req_total_cost_r    <= 21'd0;
                cost_r              <= 24'd0;
                cur_factor_r       <= cur_factor_w;
                price_bonus_r       <= price_bonus_w;
                cur_staff_zero_r   <= (cur_staff == 8'd0);
                is_staff_warn_r     <= is_staff_warn_w;
                if (act_make_r) begin
                    req_total_cost_r  <= {8'd0, current_total_sales_w};
                    make_sales_sum_r  <= current_total_sales_w;
                    make_th_r         <= upgrade_threshold_w;
                    make_need_fruit_r <= ((~type_temp[2]) & type_temp[1]) |
                                            ( type_temp[2]  & type_temp[0]);
                                         
                    make_div_rem_r    <= current_total_sales_w;
                    make_div_q_r      <= 9'd0;
                end
                else begin
                    make_norm_sales_r <= 13'd0;
                    make_norm_level_r <= 8'd0;
                    make_th_r         <= 8'd10;
                end

                if (act_make_r) make_stock_warn_r <= 1'b0;
                if (act_restock_r) overflow_acc_r <= 1'b0;
                if (act_payday_r) begin
                    mul_a_r <= {8'd0, cur_level};
                    mul_b_r <= 8'd200;
                end
                else if (act_hire_r) begin
                    mul_a_r <= {8'd0, cur_level};
                    mul_b_r <= 8'd100;
                end
                else if (act_make_r) begin
                    mul_a_r <= {11'd0, cur_factor_w};
                    mul_b_r <= {2'd0, base_price_coeff_w};
                end
                else begin
                    mul_a_r <= 16'd0;
                    mul_b_r <= 8'd0;
                end
            end
            else begin
                if (act_make_r && calc_cnt >= 4'd1 && calc_cnt <= 4'd9) begin
                    make_div_rem_r <= make_div_rem_next_w;
                    make_div_q_r   <= make_div_q_next_w;
                end

                if (act_make_r && calc_cnt == 4'd10) begin
                    if (cur_level >= 8'd100) begin
                        make_norm_level_r <= 8'd100;
                        make_norm_sales_r <= (make_sales_sum_r > 13'd4095) ?
                                             13'd4095 : make_sales_sum_r;
                    end
                    else if (make_div_q_r != 9'd0) begin
                        if (make_div_new_level_w > 16'd100) begin
                            make_norm_level_r <= 8'd100;
                            make_norm_sales_r <= (make_sales_sum_r > 13'd4095) ?
                                                 13'd4095 : make_sales_sum_r;
                        end
                        else begin
                            make_norm_level_r <= make_div_new_level_w[7:0];
                            make_norm_sales_r <= make_div_rem_r;
                        end
                    end
                    else begin
                        make_norm_level_r <= cur_level;
                        make_norm_sales_r <= make_sales_sum_r;
                    end
                end

                if (stock_eng_valid_r && stock_eng_is_make_r) begin
                    if (stock_eng_underflow_w) make_stock_warn_r <= 1'b1;
                end
                
                if (stock_eng_valid_r && !stock_eng_is_make_r) begin
                    overflow_acc_r <= overflow_acc_r |
                        stock_eng_overflow_w;
                end
                
                if (act_make_r && calc_cnt == 4'd2) begin
                    unique case (mode_temp)
                        Single:     cost_r <= {11'd0, 3'd0, make_single_price_w};
                        Family_Set: cost_r <= {11'd0, 1'd0, make_single_price_w, 2'b00};
                        Party_Pack: cost_r <= {11'd0, make_single_price_w, 3'b000};
                        default:    cost_r <= {11'd0, 3'd0, make_single_price_w};
                    endcase
                end
                
                if (setup_req_r) begin
                    mul_a_r <= {4'd0, sel_restock_w};
                    mul_b_r <= sel_unit_cost_w;
                end
                else if (setup_actual_r) begin
                    mul_a_r <= {4'd0, stock_eng_actual_qty_w};
                    mul_b_r <= sel_unit_cost_w;
                end

                if (capture_mul_w) begin
                    mul_part_lo_r <= mul_a_r * mul_b_r[3:0];
                    mul_part_hi_r <= mul_a_r * mul_b_r[7:4];
                end

                if (add_req_r) begin
                    req_total_cost_r <= req_total_cost_r + mul_prod_21_r;
                end
                else if (add_actual_r) begin
                    cost_r <= cost_r + {3'd0, mul_prod_21_r};
                end

                if (act_payday_r && calc_cnt == 4'd2) begin
                    hr_level_cost_r <= mul_prod_sum_w[15:0];
                    mul_a_r <= {12'd0, level_div10_w};
                    mul_b_r <= 8'd125;
                end
                else if (act_hire_r && calc_cnt == 4'd2) begin
                    hr_level_cost_r <= mul_prod_sum_w[15:0];
                    mul_a_r <= {12'd0, level_div10_w};
                    mul_b_r <= 8'd200;
                end

                if (act_payday_r && calc_cnt == 4'd4) begin
                    mul_a_r <= unit_price_w;
                    mul_b_r <= cur_staff;
                end
                else if (act_hire_r && calc_cnt == 4'd4) begin
                    mul_a_r <= unit_price_w;
                    mul_b_r <= actual_hire_amount_w;
                end

                if ((act_payday_r || act_hire_r) && calc_cnt == 4'd6) begin
                    cost_r <= {1'b0, mul_prod_sum_w[22:0]};
                end
            end
        end
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (~inf.rst_n) begin
            out_complete_reg <= 1'b0;
            out_warn_msg_reg <= No_Warn;
            write_word2_r    <= 1'b1;
        end
        else begin
            if (cs == READ_DRAM && act_cvd_r && read_done_w) begin
                out_complete_reg <= !cvd_date_warn_w;
                out_warn_msg_reg <= cvd_date_warn_w ?
                    Date_Warn : No_Warn; 
                write_word2_r    <= 1'b0;
            end
            else if (cs == CALC && calc_done_w) begin
                out_complete_reg <= out_complete_w;
                out_warn_msg_reg <= final_warn_msg_w;
                write_word2_r    <= need_write_word2_w;
            end
        end
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (~inf.rst_n) begin
            inf.out_valid <= 1'b0;
            inf.complete  <= 1'b0;
            inf.warn_msg  <= No_Warn;
        end
        else begin
            if (cs == WRITE_DRAM && write_done_w) begin
                inf.out_valid <= 1'b1;
                inf.complete  <= out_complete_reg;
                inf.warn_msg  <= out_warn_msg_reg;
            end
            else if (cs == READ_DRAM && ns == IDLE) begin
                inf.out_valid <= 1'b1;
                inf.complete  <= 1'b0;
                inf.warn_msg  <= Date_Warn;
            end
            else begin
                inf.out_valid <= 1'b0;
                inf.complete  <= 1'b0;
                inf.warn_msg  <= No_Warn;
            end
        end
    end

endmodule