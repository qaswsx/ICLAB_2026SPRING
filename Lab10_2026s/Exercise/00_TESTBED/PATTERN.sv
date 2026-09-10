`include "Usertype.sv"
`define CYCLE_TIME 20.0

program automatic PATTERN(input clk, INF.PATTERN inf);
import usertype::*;

//================================================================
// Parameters & Variables
//================================================================
parameter DRAM_p_r = "../00_TESTBED/DRAM/dram.dat";
parameter MAX_CYCLE = 1000;
parameter SEED = 123; 

logic [7:0] golden_DRAM [((65536 + 8*256) - 1):(65536 + 0)];
integer PATNUM = 10000;
integer patcount;
integer latency;
integer total_latency;

int act_count [5];
int warn_count [7];

int cov_make_idx;
int cov_restock_idx;
int cov_hire_idx;
int cov_payday_idx;
int cov_cvd_idx;

int probe_staff_no;
int probe_payday_no;
int probe_cvd_no;

Warn_Msg golden_warn_msg;
logic    golden_complete;
Data_Dir curr_shop_data; 
Data_Dir pre_shop_data; 

//================================================================
// Randomizer Class
//================================================================
class Randomizer;
    rand Action      act;
    rand Dessert_Type dessert;
    rand Order_Mode  mode;
    rand Month       month;
    rand Day         day;
    rand Data_No     dram_no;
    rand Stock       restock_amt [5];
    rand Staff_t     hire_staff_num;
    rand int         val_delay;

    constraint c_action { act inside {Make_and_Sell, Restock, Hire_Staff, Pay_Day, Check_Valid_Date}; }
    constraint c_type   { dessert inside {Cookie, Bread, Fruit_Cake, Pudding, Macaron, Pancake, Brownie, Scone}; }
    constraint c_mode   { mode inside {Single, Family_Set, Party_Pack}; }
    constraint c_date {
        month inside {1, 3, 5, 7, 8, 10, 12, 4, 6, 9, 11, 2};
        if (month == 2) { day inside {[1:28]}; }
        else if (month == 4 || month == 6 || month == 9 || month == 11) { day inside {[1:30]}; }
        else { day inside {[1:31]}; }
    }
    constraint c_dram_no { dram_no inside {[0:127]}; }
    constraint c_staff   { hire_staff_num inside {[1:30]}; }
    constraint c_restock { foreach(restock_amt[i]) restock_amt[i] inside {[0:2047]}; }
    constraint c_delay   { val_delay inside {[1:3]}; }
endclass

Randomizer rnd;

//================================================================
// Helper Functions: Utility
//================================================================
function automatic int find_hire_cap_probe_shop(input int hire_num);
    int no, base_addr;
    logic [63:0] word2;
    int staff, balance, level;
    int fee, actual_hired;
begin
    find_hire_cap_probe_shop = -1;
    for (no = 0; no < 128; no++) begin
        base_addr = 65536 + no * 16;
        word2 = {
            golden_DRAM[base_addr+15], golden_DRAM[base_addr+14],
            golden_DRAM[base_addr+13], golden_DRAM[base_addr+12],
            golden_DRAM[base_addr+11], golden_DRAM[base_addr+10],
            golden_DRAM[base_addr+9],  golden_DRAM[base_addr+8]
        };
        staff   = word2[39:32];
        balance = word2[31:8];
        level   = word2[7:0];
        fee = 2000 + level * 100 + (level / 10) * 200;
        actual_hired = 100 - staff;
        if ((staff < 100) &&
            (staff + hire_num > 100) &&
            (actual_hired > 0) &&
            (balance >= fee * (actual_hired + 1) + 50000)) begin
            return no;
        end
    end
end
endfunction

function automatic int find_payday_penalty_probe_shop();
    int no, base_addr;
    logic [63:0] word2;
    int staff, balance, level;
    int salary_before;
    int salary_after;
    int next_level;
    int next_staff;
begin
    find_payday_penalty_probe_shop = -1;
    for (no = 0; no < 128; no++) begin
        base_addr = 65536 + no * 16;
        word2 = {
            golden_DRAM[base_addr+15], golden_DRAM[base_addr+14],
            golden_DRAM[base_addr+13], golden_DRAM[base_addr+12],
            golden_DRAM[base_addr+11], golden_DRAM[base_addr+10],
            golden_DRAM[base_addr+9],  golden_DRAM[base_addr+8]
        };
        staff   = word2[39:32];
        balance = word2[31:8];
        level   = word2[7:0];
        salary_before = (20000 + level * 200 + (level / 10) * 1000) * staff;
        next_level = (level < 10) ? 0 : (level - 10);
        next_staff = ((staff / 2) == 0) ? 1 : (staff / 2);
        salary_after = (20000 + next_level * 200 + (next_level / 10) * 1000) * next_staff;
        if ((staff > 0) &&
            (balance < salary_before) &&
            (balance >= salary_after + 50000)) begin
            return no;
        end
    end
end
endfunction

function automatic Dessert_Type get_type(input int idx);
begin
    case (idx)
        0: get_type = Cookie;
        1: get_type = Bread;
        2: get_type = Fruit_Cake;  
        3: get_type = Pudding;
        4: get_type = Macaron;     
        5: get_type = Pancake;
        6: get_type = Brownie;     
        default: get_type = Scone;
    endcase
end
endfunction

function automatic Order_Mode get_mode(input int idx);
begin
    case (idx)
        0: get_mode = Single;
        1: get_mode = Family_Set;
        default: get_mode = Party_Pack;
    endcase
end
endfunction

function automatic void get_req(
    input Dessert_Type dessert, input Order_Mode mode,
    output int req_f, output int req_b, output int req_m, output int req_s, output int req_fr
);
int scale;
begin
    case (dessert)
        Cookie:     begin req_f=100; req_b=50;  req_m=0;   req_s=30;  req_fr=0;   end
        Bread:      begin req_f=200; req_b=20;  req_m=50;  req_s=10;  req_fr=0;   end
        Fruit_Cake: begin req_f=150; req_b=80;  req_m=40;  req_s=60;  req_fr=100; end
        Pudding:    begin req_f=0;   req_b=0;   req_m=150; req_s=50;  req_fr=20;  end
        Macaron:    begin req_f=40;  req_b=30;  req_m=0;   req_s=120; req_fr=0;   end
        Pancake:    begin req_f=120; req_b=30;  req_m=80;  req_s=20;  req_fr=40;  end
        Brownie:    begin req_f=80;  req_b=100; req_m=0;   req_s=100; req_fr=0;   end
        Scone:      begin req_f=150; req_b=60;  req_m=30;  req_s=20;  req_fr=10;  end
    endcase
    scale = (mode == Single) ? 1 : (mode == Family_Set) ? 4 : 8;
    req_f *= scale; req_b *= scale; req_m *= scale; req_s *= scale; req_fr *= scale;
end
endfunction

//================================================================
// Helper Functions: Finders
//================================================================
function automatic int find_make_safe_shop(input Dessert_Type dessert, input Order_Mode mode);
    int no, base_addr; logic [63:0] word1, word2;
    int flour, butter, milk, sugar, fruit, staff;
    int req_f, req_b, req_m, req_s, req_fr;
begin
    find_make_safe_shop = -1;
    get_req(dessert, mode, req_f, req_b, req_m, req_s, req_fr);
    for (no = 0; no < 128; no++) begin
        base_addr = 65536 + no * 16;
        word1 = {golden_DRAM[base_addr+7], golden_DRAM[base_addr+6], golden_DRAM[base_addr+5], golden_DRAM[base_addr+4],
                 golden_DRAM[base_addr+3], golden_DRAM[base_addr+2], golden_DRAM[base_addr+1], golden_DRAM[base_addr+0]};
        word2 = {golden_DRAM[base_addr+15], golden_DRAM[base_addr+14], golden_DRAM[base_addr+13], golden_DRAM[base_addr+12],
                 golden_DRAM[base_addr+11], golden_DRAM[base_addr+10], golden_DRAM[base_addr+9],  golden_DRAM[base_addr+8]};
        flour=word1[63:52]; butter=word1[51:40]; milk=word1[31:20]; sugar=word1[19:8];
        fruit=word2[63:52]; staff=word2[39:32];
        if (staff > 0 && flour >= req_f && butter >= req_b && milk >= req_m && sugar >= req_s && fruit >= req_fr)
            return no;
    end
end
endfunction

function automatic int find_make_stock_warn_shop(input Dessert_Type dessert, input Order_Mode mode);
    int no, base_addr; logic [63:0] word1, word2;
    int flour, butter, milk, sugar, fruit, staff;
    int req_f, req_b, req_m, req_s, req_fr;
begin
    find_make_stock_warn_shop = -1;
    get_req(dessert, mode, req_f, req_b, req_m, req_s, req_fr);
    for (no = 0; no < 128; no++) begin
        base_addr = 65536 + no * 16;
        word1 = {golden_DRAM[base_addr+7], golden_DRAM[base_addr+6], golden_DRAM[base_addr+5], golden_DRAM[base_addr+4],
                 golden_DRAM[base_addr+3], golden_DRAM[base_addr+2], golden_DRAM[base_addr+1], golden_DRAM[base_addr+0]};
        word2 = {golden_DRAM[base_addr+15], golden_DRAM[base_addr+14], golden_DRAM[base_addr+13], golden_DRAM[base_addr+12],
                 golden_DRAM[base_addr+11], golden_DRAM[base_addr+10], golden_DRAM[base_addr+9],  golden_DRAM[base_addr+8]};
        flour=word1[63:52]; butter=word1[51:40]; milk=word1[31:20]; sugar=word1[19:8];
        fruit=word2[63:52]; staff=word2[39:32];
        if (staff > 0 && (flour < req_f || butter < req_b || milk < req_m || sugar < req_s || fruit < req_fr))
            return no;
    end
end
endfunction

function automatic int find_no_staff_shop();
    int no, base_addr; logic [63:0] word2;
begin
    find_no_staff_shop = -1;
    for (no = 0; no < 128; no++) begin
        base_addr = 65536 + no * 16;
        word2 = {golden_DRAM[base_addr+15], golden_DRAM[base_addr+14], golden_DRAM[base_addr+13], golden_DRAM[base_addr+12],
                 golden_DRAM[base_addr+11], golden_DRAM[base_addr+10], golden_DRAM[base_addr+9],  golden_DRAM[base_addr+8]};
        if (word2[39:32] == 0) return no;
    end
end
endfunction

function automatic int find_payday_safe_shop();
    int no, base_addr;
    logic [63:0] word2;
    int staff, balance, level, salary;
    int safe_margin;
begin
    find_payday_safe_shop = -1;
    safe_margin = 300000;
    for (no = 0; no < 128; no++) begin
        base_addr = 65536 + no * 16;
        word2 = {
            golden_DRAM[base_addr+15], golden_DRAM[base_addr+14],
            golden_DRAM[base_addr+13], golden_DRAM[base_addr+12],
            golden_DRAM[base_addr+11], golden_DRAM[base_addr+10],
            golden_DRAM[base_addr+9],  golden_DRAM[base_addr+8]
        };
        staff   = word2[39:32];
        balance = word2[31:8];
        level   = word2[7:0];
        salary = (20000 + level * 200 + (level / 10) * 1000) * staff;
        if (staff > 0 && balance >= salary + safe_margin)
            return no;
    end
end
endfunction

function automatic int find_payday_balance_warn_shop();
    int no, base_addr; logic [63:0] word2;
    int staff, balance, level, salary;
begin
    find_payday_balance_warn_shop = -1;
    for (no = 0; no < 128; no++) begin
        base_addr = 65536 + no * 16;
        word2 = {golden_DRAM[base_addr+15], golden_DRAM[base_addr+14], golden_DRAM[base_addr+13], golden_DRAM[base_addr+12],
                 golden_DRAM[base_addr+11], golden_DRAM[base_addr+10], golden_DRAM[base_addr+9],  golden_DRAM[base_addr+8]};
        staff = word2[39:32]; balance = word2[31:8]; level = word2[7:0];
        salary = (20000 + level * 200 + (level/10) * 1000) * staff;
        if (staff > 0 && balance < salary) return no;
    end
end
endfunction

function automatic int find_hire_safe_shop(input int hire_num);
    int no, base_addr;
    logic [63:0] word2;
    int staff, balance, level, cost;
    int safe_margin;
begin
    find_hire_safe_shop = -1;
    safe_margin = 50000;
    for (no = 0; no < 128; no++) begin
        base_addr = 65536 + no * 16;
        word2 = {
            golden_DRAM[base_addr+15], golden_DRAM[base_addr+14],
            golden_DRAM[base_addr+13], golden_DRAM[base_addr+12],
            golden_DRAM[base_addr+11], golden_DRAM[base_addr+10],
            golden_DRAM[base_addr+9],  golden_DRAM[base_addr+8]
        };
        staff   = word2[39:32];
        balance = word2[31:8];
        level   = word2[7:0];
        cost = (2000 + level * 100 + (level / 10) * 200) * hire_num;
        
        if ((staff + hire_num <= 100) &&
            (balance >= cost + safe_margin)) begin
            return no;
        end
    end
end
endfunction

function automatic int find_hire_balance_warn_shop(input int hire_num);
    int no, base_addr; logic [63:0] word2;
    int staff, balance, level, cost;
begin
    find_hire_balance_warn_shop = -1;
    for (no = 0; no < 128; no++) begin
        base_addr = 65536 + no * 16;
        word2 = {golden_DRAM[base_addr+15], golden_DRAM[base_addr+14], golden_DRAM[base_addr+13], golden_DRAM[base_addr+12],
                 golden_DRAM[base_addr+11], golden_DRAM[base_addr+10], golden_DRAM[base_addr+9],  golden_DRAM[base_addr+8]};
        staff = word2[39:32]; balance = word2[31:8]; level = word2[7:0];
        cost = (2000 + level * 100 + (level/10) * 200) * hire_num;
        if ((staff + hire_num <= 100) && (balance < cost)) return no;
    end
end
endfunction

function automatic int find_hire_staff_warn_shop(input int hire_num);
    int no, base_addr;
    logic [63:0] word2;
    int staff, balance, level, fee, actual_hired;
begin
    find_hire_staff_warn_shop = -1;
    for (no = 0; no < 128; no++) begin
        base_addr = 65536 + no * 16;
        word2 = {
            golden_DRAM[base_addr+15], golden_DRAM[base_addr+14],
            golden_DRAM[base_addr+13], golden_DRAM[base_addr+12],
            golden_DRAM[base_addr+11], golden_DRAM[base_addr+10],
            golden_DRAM[base_addr+9],  golden_DRAM[base_addr+8]
        };
        staff   = word2[39:32];
        balance = word2[31:8];
        level   = word2[7:0];
        fee = 2000 + level * 100 + (level / 10) * 200;
        if (staff >= 100)
            actual_hired = 0;
        else
            actual_hired = 100 - staff;
        
        if ((staff + hire_num > 100) &&
            (balance >= fee * actual_hired)) begin
            return no;
        end
    end
end
endfunction

function automatic int find_restock_safe_shop();
    int no, base_addr; logic [63:0] word1, word2;
    int flour, butter, milk, sugar, fruit, balance;
begin
    find_restock_safe_shop = -1;
    for (no = 0; no < 128; no++) begin
        base_addr = 65536 + no * 16;
        word1 = {golden_DRAM[base_addr+7], golden_DRAM[base_addr+6], golden_DRAM[base_addr+5], golden_DRAM[base_addr+4],
                 golden_DRAM[base_addr+3], golden_DRAM[base_addr+2], golden_DRAM[base_addr+1], golden_DRAM[base_addr+0]};
        word2 = {golden_DRAM[base_addr+15], golden_DRAM[base_addr+14], golden_DRAM[base_addr+13], golden_DRAM[base_addr+12],
                 golden_DRAM[base_addr+11], golden_DRAM[base_addr+10], golden_DRAM[base_addr+9],  golden_DRAM[base_addr+8]};
        flour=word1[63:52]; butter=word1[51:40]; milk=word1[31:20]; sugar=word1[19:8];
        fruit=word2[63:52]; balance=word2[31:8];
        if (balance > 200000 && flour < 1000 && butter < 1000 && milk < 1000 && sugar < 1000 && fruit < 1000) return no;
    end
end
endfunction

function automatic int find_restock_overflow_shop();
    int no, base_addr; logic [63:0] word1, word2;
    int flour, butter, milk, sugar, fruit, balance;
begin
    find_restock_overflow_shop = -1;
    for (no = 0; no < 128; no++) begin
        base_addr = 65536 + no * 16;
        word1 = {golden_DRAM[base_addr+7], golden_DRAM[base_addr+6], golden_DRAM[base_addr+5], golden_DRAM[base_addr+4],
                 golden_DRAM[base_addr+3], golden_DRAM[base_addr+2], golden_DRAM[base_addr+1], golden_DRAM[base_addr+0]};
        word2 = {golden_DRAM[base_addr+15], golden_DRAM[base_addr+14], golden_DRAM[base_addr+13], golden_DRAM[base_addr+12],
                 golden_DRAM[base_addr+11], golden_DRAM[base_addr+10], golden_DRAM[base_addr+9],  golden_DRAM[base_addr+8]};
        flour=word1[63:52]; butter=word1[51:40]; milk=word1[31:20]; sugar=word1[19:8];
        fruit=word2[63:52]; balance=word2[31:8];
        if (balance > 1000000 && flour > 3000 && butter > 3000 && milk > 3000 && sugar > 3000 && fruit > 3000) return no;
    end
end
endfunction

function automatic int find_restock_balance_warn_shop();
    int no, base_addr; logic [63:0] word2;
    int balance;
begin
    find_restock_balance_warn_shop = -1;
    for (no = 0; no < 128; no++) begin
        base_addr = 65536 + no * 16;
        word2 = {golden_DRAM[base_addr+15], golden_DRAM[base_addr+14], golden_DRAM[base_addr+13], golden_DRAM[base_addr+12],
                 golden_DRAM[base_addr+11], golden_DRAM[base_addr+10], golden_DRAM[base_addr+9],  golden_DRAM[base_addr+8]};
        balance = word2[31:8];
        if (balance < 500) return no; // Low balance guaranteed to trigger warn on high restock
    end
end
endfunction

function automatic int find_cvd_date_warn_shop(input int m, input int d);
    int no, base_addr; logic [63:0] word1; int dram_m, dram_d;
begin
    find_cvd_date_warn_shop = -1;
    for (no = 0; no < 128; no++) begin
        base_addr = 65536 + no * 16;
        word1 = {golden_DRAM[base_addr+7], golden_DRAM[base_addr+6], golden_DRAM[base_addr+5], golden_DRAM[base_addr+4],
                 golden_DRAM[base_addr+3], golden_DRAM[base_addr+2], golden_DRAM[base_addr+1], golden_DRAM[base_addr+0]};
        dram_m = word1[39:32]; dram_d = word1[7:0];
        if ((m < dram_m) || (m == dram_m && d < dram_d)) return no;
    end
end
endfunction

function automatic int find_restock_isolated_shop(
    input int a0,
    input int a1,
    input int a2,
    input int a3,
    input int a4,
    input Warn_Msg target_warn
);
    int no;
    int base_addr;
    logic [63:0] word1, word2;

    int flour, butter, milk, sugar, fruit;
    int balance, level, level_div10;
    int cost_flour, cost_butter, cost_milk, cost_sugar, cost_fruit;
    int add_f, add_b, add_m, add_s, add_fr;
    int total_cost;
    bit overflow;
    bit enough_balance;
    int safe_margin;
    int warn_margin;
begin
    find_restock_isolated_shop = -1;

    safe_margin = 200000;
    warn_margin = 50000;

    for (no = 0; no < 128; no = no + 1) begin
        base_addr = 65536 + no * 16;
        word1 = {
            golden_DRAM[base_addr+7], golden_DRAM[base_addr+6],
            golden_DRAM[base_addr+5], golden_DRAM[base_addr+4],
            golden_DRAM[base_addr+3], golden_DRAM[base_addr+2],
            golden_DRAM[base_addr+1], golden_DRAM[base_addr+0]
        };
        word2 = {
            golden_DRAM[base_addr+15], golden_DRAM[base_addr+14],
            golden_DRAM[base_addr+13], golden_DRAM[base_addr+12],
            golden_DRAM[base_addr+11], golden_DRAM[base_addr+10],
            golden_DRAM[base_addr+9],  golden_DRAM[base_addr+8]
        };
        flour   = word1[63:52];
        butter  = word1[51:40];
        milk    = word1[31:20];
        sugar   = word1[19:8];
        fruit   = word2[63:52];
        balance = word2[31:8];
        level   = word2[7:0];

        level_div10 = level / 10;
        cost_flour  = (15 * (10 + level_div10)) / 10;
        cost_butter = (60 * (10 + level_div10)) / 10;
        cost_milk   = (25 * (10 + level_div10)) / 10;
        cost_sugar  = (10 * (10 + level_div10)) / 10;
        cost_fruit  = (80 * (10 + level_div10)) / 10;
        add_f  = ((flour  + a0) > 4095) ? (4095 - flour ) : a0;
        add_b  = ((butter + a1) > 4095) ? (4095 - butter) : a1;
        add_m  = ((milk   + a2) > 4095) ? (4095 - milk  ) : a2;
        add_s  = ((sugar  + a3) > 4095) ? (4095 - sugar ) : a3;
        add_fr = ((fruit  + a4) > 4095) ? (4095 - fruit ) : a4;
        overflow =
            (add_f  < a0) ||
            (add_b  < a1) ||
            (add_m  < a2) ||
            (add_s  < a3) ||
            (add_fr < a4);
        total_cost =
            add_f  * cost_flour  +
            add_b  * cost_butter +
            add_m  * cost_milk   +
            add_s  * cost_sugar  +
            add_fr * cost_fruit;
        enough_balance = (balance >= total_cost);

        case (target_warn)
            No_Warn: begin
                
                if (!overflow && (balance >= total_cost + safe_margin)) begin
                    find_restock_isolated_shop = no;
                    return no;
                end
            end

            Balance_Warn: begin
                
                if (!overflow && (balance + warn_margin < total_cost)) begin
                    find_restock_isolated_shop = no;
                    return no;
                end
            end

            Restock_Warn: begin
                
                if (overflow && (balance >= total_cost + safe_margin)) begin
                    find_restock_isolated_shop = no;
                    return no;
                end
            end

            default: begin
            end
        endcase
    end
end
endfunction

function automatic Action cov_action_seq(input int pos);
begin
    case (pos % 26)
        0 : cov_action_seq = Make_and_Sell;
        1 : cov_action_seq = Make_and_Sell;
        2 : cov_action_seq = Restock;
        3 : cov_action_seq = Make_and_Sell;
        4 : cov_action_seq = Hire_Staff;
        5 : cov_action_seq = Make_and_Sell;
        6 : cov_action_seq = Pay_Day;
        7 : cov_action_seq = Make_and_Sell;
        8 : cov_action_seq = Check_Valid_Date;
        9 : cov_action_seq = Restock;
        10: cov_action_seq = Restock;
        11: cov_action_seq = Hire_Staff;
        12: cov_action_seq = Restock;
        13: cov_action_seq = Pay_Day;
        14: cov_action_seq = Restock;
        15: cov_action_seq = Check_Valid_Date;
        16: cov_action_seq = Hire_Staff;
        17: cov_action_seq = Hire_Staff;
        18: cov_action_seq = Pay_Day;
        19: cov_action_seq = Hire_Staff;
        20: cov_action_seq = Check_Valid_Date;
        21: cov_action_seq = Pay_Day;
        22: cov_action_seq = Pay_Day;
        23: cov_action_seq = Check_Valid_Date;
        24: cov_action_seq = Check_Valid_Date;
        default: cov_action_seq = Make_and_Sell;
    endcase
end
endfunction

//================================================================
// Generator Tasks
//================================================================
task gen_action_for_cov(input Action a);
begin
    case (a)
        Make_and_Sell: begin
            if (cov_make_idx < 80)
                gen_make_stock_warn(cov_make_idx % 24);
            else
                gen_make_cov(cov_make_idx % 24);

            cov_make_idx++;
        end

        Restock: begin
            if (cov_restock_idx < 128)
                gen_restock_amount_bin(cov_restock_idx);
            else if (cov_restock_idx < 208)
                gen_restock_overflow();
            else
                gen_restock_safe(0);

            cov_restock_idx++;
        end

        Hire_Staff: begin
            gen_hire_cov(cov_hire_idx);
            cov_hire_idx++;
        end

        Pay_Day: begin
            if (cov_payday_idx < 80)
                gen_payday_no_staff();
            else
                gen_payday_cov(0);

            cov_payday_idx++;
        end

        Check_Valid_Date: begin
            if (cov_cvd_idx < 80)
                gen_cvd_date_warn();
            else
                gen_cvd_cov(1);

            cov_cvd_idx++;
        end
    endcase
end
endtask

task pick_any_shop; begin
    rnd.dram_no = Data_No'($urandom_range(0, 127));
end endtask

task gen_cvd_safe;
begin
    rnd.act = Check_Valid_Date; rnd.month = 12; rnd.day = 31;
    pick_any_shop();
end endtask

task gen_cvd_date_warn; int no;
begin
    rnd.act = Check_Valid_Date; rnd.month = 1; rnd.day = 1;
    no = find_cvd_date_warn_shop(1, 1);
    if (no != -1) rnd.dram_no = Data_No'(no);
    else gen_cvd_safe();
end endtask

task gen_payday_safe; int no;
begin
    rnd.act = Pay_Day; rnd.month = 12; rnd.day = 31;
    no = find_payday_safe_shop();
    if (no != -1) rnd.dram_no = Data_No'(no);
    else gen_cvd_safe();
end endtask

task gen_payday_no_staff; int no;
begin
    rnd.act = Pay_Day; rnd.month = 12; rnd.day = 31;
    no = find_no_staff_shop();
    if (no != -1) rnd.dram_no = Data_No'(no);
    else gen_payday_safe();
end endtask

task gen_payday_balance_warn; int no;
begin
    rnd.act = Pay_Day; rnd.month = 12; rnd.day = 31;
    no = find_payday_balance_warn_shop();
    if (no != -1) rnd.dram_no = Data_No'(no);
    else gen_payday_safe();
end endtask

task gen_hire_safe;
    int no;
begin
    rnd.act = Hire_Staff;
    rnd.month = 12;
    rnd.day   = 31;

    rnd.hire_staff_num = Staff_t'(10);
    no = find_hire_safe_shop(10);

    if (no == -1) begin
        rnd.hire_staff_num = Staff_t'(5);
        no = find_hire_safe_shop(5);
    end

    if (no == -1) begin
        rnd.hire_staff_num = Staff_t'(1);
        no = find_hire_safe_shop(1);
    end

    if (no != -1)
        rnd.dram_no = Data_No'(no);
    else
        gen_cvd_safe();
end
endtask

task gen_hire_staff_warn; int no; begin
    rnd.act = Hire_Staff;
    rnd.month = 12; rnd.day = 31; rnd.hire_staff_num = Staff_t'(30);
    no = find_hire_staff_warn_shop(30);
    if (no != -1) rnd.dram_no = Data_No'(no);
    else gen_hire_safe();
end endtask

task gen_hire_balance_warn; int no; begin
    rnd.act = Hire_Staff; rnd.month = 12; rnd.day = 31;
    rnd.hire_staff_num = Staff_t'(20);
    no = find_hire_balance_warn_shop(20);
    if (no != -1) rnd.dram_no = Data_No'(no);
    else gen_hire_safe();
end endtask

task gen_make_safe(input int idx);
    int combo, no; begin
    rnd.act = Make_and_Sell; rnd.month = 12; rnd.day = 31;
    combo = idx % 24; rnd.dessert = get_type(combo / 3); rnd.mode = get_mode(combo % 3);
    no = find_make_safe_shop(rnd.dessert, rnd.mode);
    if (no != -1) rnd.dram_no = Data_No'(no);
    else gen_cvd_safe();
end endtask

task gen_make_no_staff; int no;
begin
    rnd.act = Make_and_Sell; rnd.month = 12; rnd.day = 31; rnd.dessert = Cookie; rnd.mode = Single;
    no = find_no_staff_shop();
    if (no != -1) rnd.dram_no = Data_No'(no);
    else gen_make_safe(0);
end endtask

task gen_make_stock_warn(input int idx); int combo, no;
begin
    rnd.act = Make_and_Sell; rnd.month = 12; rnd.day = 31;
    combo = idx % 24;
    rnd.dessert = get_type(combo / 3); rnd.mode = get_mode(combo % 3);
    no = find_make_stock_warn_shop(rnd.dessert, rnd.mode);
    if (no != -1) rnd.dram_no = Data_No'(no);
    else gen_make_safe(idx);
end endtask

task gen_staff_probe_first;
begin
    rnd.act = Hire_Staff;
    rnd.month = 12;
    rnd.day   = 31;
    rnd.hire_staff_num = Staff_t'(30);

    probe_staff_no = find_hire_cap_probe_shop(30);
    if (probe_staff_no != -1)
        rnd.dram_no = Data_No'(probe_staff_no);
    else
        gen_hire_cov(1);
end
endtask

task gen_staff_probe_second;
begin
    rnd.act = Hire_Staff;
    rnd.month = 12;
    rnd.day   = 31;
    rnd.hire_staff_num = Staff_t'(1);
    if (probe_staff_no != -1)
        rnd.dram_no = Data_No'(probe_staff_no);
    else
        gen_hire_cov(1);
end
endtask

task gen_payday_probe_first;
begin
    rnd.act = Pay_Day;
    rnd.month = 12;
    rnd.day   = 31;

    probe_payday_no = find_payday_penalty_probe_shop();
    if (probe_payday_no != -1)
        rnd.dram_no = Data_No'(probe_payday_no);
    else
        gen_payday_cov(2);
end
endtask

task gen_payday_probe_second;
begin
    rnd.act = Pay_Day;
    rnd.month = 12;
    rnd.day   = 31;

    if (probe_payday_no != -1)
        rnd.dram_no = Data_No'(probe_payday_no);
    else
        gen_payday_cov(2);
end
endtask

task gen_restock_safe(input int idx);
    int no;
begin
    rnd.act = Restock;
    rnd.month = 12;
    rnd.day   = 31;

    rnd.restock_amt[0] = 10;
    rnd.restock_amt[1] = 10;
    rnd.restock_amt[2] = 10;
    rnd.restock_amt[3] = 10;
    rnd.restock_amt[4] = 10;
    no = find_restock_isolated_shop(
        rnd.restock_amt[0],
        rnd.restock_amt[1],
        rnd.restock_amt[2],
        rnd.restock_amt[3],
        rnd.restock_amt[4],
        No_Warn
    );
    if (no != -1)
        rnd.dram_no = Data_No'(no);
    else
        gen_cvd_safe();
end
endtask

task gen_restock_overflow;
    int no;
begin
    rnd.act = Restock;
    rnd.month = 12;
    rnd.day   = 31;

    rnd.restock_amt[0] = 2000;
    rnd.restock_amt[1] = 2000;
    rnd.restock_amt[2] = 2000;
    rnd.restock_amt[3] = 2000;
    rnd.restock_amt[4] = 2000;

    no = find_restock_isolated_shop(
        rnd.restock_amt[0],
        rnd.restock_amt[1],
        rnd.restock_amt[2],
        rnd.restock_amt[3],
        rnd.restock_amt[4],
        Restock_Warn
    );
    if (no != -1)
        rnd.dram_no = Data_No'(no);
    else
        gen_restock_safe(0);
end
endtask

task gen_restock_balance_warn;
    int no;
begin
    rnd.act = Restock;
    rnd.month = 12;
    rnd.day   = 31;

    rnd.restock_amt[0] = 1000;
    rnd.restock_amt[1] = 1000;
    rnd.restock_amt[2] = 1000;
    rnd.restock_amt[3] = 1000;
    rnd.restock_amt[4] = 1000;

    no = find_restock_isolated_shop(
        rnd.restock_amt[0],
        rnd.restock_amt[1],
        rnd.restock_amt[2],
        rnd.restock_amt[3],
        rnd.restock_amt[4],
        Balance_Warn
    );
    if (no != -1)
        rnd.dram_no = Data_No'(no);
    else
        gen_restock_safe(0);
end
endtask

task gen_restock_amount_bin(input int idx);
    int b;
    int no;
begin
    rnd.act = Restock;
    rnd.month = 12;
    rnd.day   = 31;
    for (int i = 0; i < 5; i = i + 1) begin
        b = (idx * 5 + i) % 128;
        rnd.restock_amt[i] = Stock'(b * 16 + 8);
    end

    no = find_restock_isolated_shop(
        rnd.restock_amt[0],
        rnd.restock_amt[1],
        rnd.restock_amt[2],
        rnd.restock_amt[3],
        rnd.restock_amt[4],
        No_Warn
    );
    if (no == -1) begin
        no = find_restock_isolated_shop(
            rnd.restock_amt[0],
            rnd.restock_amt[1],
            rnd.restock_amt[2],
            rnd.restock_amt[3],
            rnd.restock_amt[4],
            Restock_Warn
        );
    end

    if (no == -1) begin
        no = find_restock_isolated_shop(
            rnd.restock_amt[0],
            rnd.restock_amt[1],
            rnd.restock_amt[2],
            rnd.restock_amt[3],
            rnd.restock_amt[4],
            Balance_Warn
        );
    end

    if (no != -1)
        rnd.dram_no = Data_No'(no);
    else
        gen_restock_safe(0);
end
endtask

//================================================================
// Task Routing & Phasing
//================================================================
task directed_spec_task(input int idx);
    int sid;
begin
    sid = idx % 40;
    case (sid)
        0,1,2,3,4,5,6,7: gen_make_safe(idx);
        8: gen_make_no_staff();
        9: gen_make_stock_warn(idx);
        10,11,12: gen_restock_safe(idx);
        13: gen_restock_overflow();
        14: gen_restock_balance_warn();
        15,16: gen_hire_safe();
        17: gen_hire_staff_warn();
        18: gen_hire_balance_warn();
        19,20: gen_payday_safe();
        21: gen_payday_no_staff();
        22: gen_payday_balance_warn();
        23: gen_cvd_safe();
        24: gen_cvd_date_warn();
        25: begin rnd.act=Check_Valid_Date; rnd.month=2; rnd.day=28; pick_any_shop();
        end // Edge date
        26,27,28,29,30: gen_restock_amount_bin(idx);
        default: gen_cvd_safe();
    endcase
end endtask

task random_safe_task;
    int r;
begin
    r = $urandom_range(0, 99);

    if (r < 30) begin
        gen_make_cov(cov_make_idx % 24);
        cov_make_idx++;
    end
    else if (r < 50) begin
        gen_restock_safe(patcount);
    end
    else if (r < 65) begin
        gen_hire_safe();
    end
    else if (r < 80) begin
        gen_payday_cov(0);
        // Pay_Day safe only
    end
    else begin
        gen_cvd_cov(1);
        // CVD safe only
    end
end
endtask

task gen_make_cov(input int combo);
    int no;
begin
    rnd.act = Make_and_Sell;
    rnd.month = 12;
    rnd.day   = 31;

    rnd.dessert = get_type(combo / 3);
    rnd.mode    = get_mode(combo % 3);

    no = find_make_safe_shop(rnd.dessert, rnd.mode);
    if (no == -1)
        no = find_make_stock_warn_shop(rnd.dessert, rnd.mode);
    if (no == -1)
        no = find_no_staff_shop();
    if (no != -1)
        rnd.dram_no = Data_No'(no);
    else
        rnd.dram_no = Data_No'($urandom_range(0, 127));
    // still Make, do not fallback CVD
end
endtask

task gen_hire_cov(input int mode_sel);
    int no;
begin
    rnd.act = Hire_Staff;
    rnd.month = 12;
    rnd.day   = 31;
    no = -1;
    if (mode_sel < 80) begin
        rnd.hire_staff_num = Staff_t'(30);
        no = find_hire_staff_warn_shop(30);
    end

    else if (mode_sel < 160) begin
        rnd.hire_staff_num = Staff_t'(20);
        no = find_hire_balance_warn_shop(20);
    end

    else begin
        rnd.hire_staff_num = Staff_t'(10);
        no = find_hire_safe_shop(10);

        if (no == -1) begin
            rnd.hire_staff_num = Staff_t'(5);
            no = find_hire_safe_shop(5);
        end

        if (no == -1) begin
            rnd.hire_staff_num = Staff_t'(1);
            no = find_hire_safe_shop(1);
        end
    end

    if (no != -1) begin
        rnd.dram_no = Data_No'(no);
    end
    else begin
        rnd.hire_staff_num = Staff_t'(1);
        rnd.dram_no = Data_No'($urandom_range(0, 127));
    end
end
endtask

task gen_payday_cov(input int mode_sel);
    int no;
begin
    rnd.act = Pay_Day;
    rnd.month = 12;
    rnd.day   = 31;

    if (mode_sel % 2 == 0)
        no = find_payday_safe_shop();
    else
        no = find_no_staff_shop();
    if (no != -1) begin
        rnd.dram_no = Data_No'(no);
    end
    else begin
        // still Pay_Day, but avoid directed Balance_Warn
        no = find_payday_safe_shop();
        if (no != -1)
            rnd.dram_no = Data_No'(no);
        else
            rnd.dram_no = Data_No'(0);
    end
end
endtask

task gen_cvd_cov(input int mode_sel);
    int no;
begin
    rnd.act = Check_Valid_Date;

    if (mode_sel % 2 == 0) begin
        rnd.month = 1;
        rnd.day   = 1;
        no = find_cvd_date_warn_shop(1, 1);
        if (no != -1)
            rnd.dram_no = Data_No'(no);
        else begin
            rnd.month = 12;
            rnd.day   = 31;
            rnd.dram_no = Data_No'($urandom_range(0, 127));
        end
    end
    else begin
        rnd.month = 12;
        rnd.day   = 31;
        rnd.dram_no = Data_No'($urandom_range(0, 127));
    end
end
endtask

task directed_task;
    Action a;
    int combo;
begin
    rnd.month = 12;
    rnd.day   = 31;
    if (patcount < 5200) begin
        if (patcount == 23) begin
            gen_cvd_probe_first();
        end
        else if (patcount == 24) begin
            gen_cvd_probe_second();
        end
        else begin
            a = cov_action_seq(patcount);
            gen_action_for_cov(a);
        end
    end
    else if (patcount < 6400) begin
        combo = ((patcount - 5200) / 50) % 24;
        gen_make_cov(combo);
    end
    else begin
        random_safe_task();
    end
end
endtask

//================================================================
// Tasks: Operation & Driving
//================================================================
task check_out_not_early; begin
    if (inf.out_valid !== 1'b0) begin
        YOU_FAIL_task;
        $display("[ERROR] out_valid raised before all inputs are sent at pattern %0d", patcount);
        $finish;
    end
end endtask

task delay_task; begin
    if (patcount >= 6401) rnd.val_delay = 1;
    else rnd.val_delay = $urandom_range(1, 3);
    repeat(rnd.val_delay) begin
        @(negedge clk);
        check_out_not_early();
    end
end endtask

task drive_task;
begin
    inf.sel_action_valid = 1'b1; inf.D = 72'b0; inf.D.d_act[0] = rnd.act; 
    @(negedge clk); inf.sel_action_valid = 1'b0;
    inf.D = 72'bx; check_out_not_early();

    case (rnd.act)
        Make_and_Sell: begin
            delay_task();
            inf.type_valid = 1'b1; inf.D = 72'b0; inf.D.d_type[0] = rnd.dessert; @(negedge clk); inf.type_valid = 1'b0; inf.D = 72'bx; check_out_not_early();
            delay_task();
            inf.mode_valid = 1'b1; inf.D = 72'b0; inf.D.d_mode[0] = rnd.mode; @(negedge clk); inf.mode_valid = 1'b0; inf.D = 72'bx; check_out_not_early();
            delay_task();
            inf.date_valid = 1'b1; inf.D = 72'b0; inf.D.d_date[0] = {rnd.month, rnd.day}; @(negedge clk); inf.date_valid = 1'b0; inf.D = 72'bx; check_out_not_early();
            delay_task();
            inf.data_no_valid = 1'b1; inf.D = 72'b0; inf.D.d_data_no[0] = rnd.dram_no; @(negedge clk); inf.data_no_valid = 1'b0; inf.D = 72'bx;
        end
        Restock: begin
            delay_task();
            inf.date_valid = 1'b1; inf.D = 72'b0; inf.D.d_date[0] = {rnd.month, rnd.day}; @(negedge clk); inf.date_valid = 1'b0; inf.D = 72'bx; check_out_not_early();
            delay_task();
            inf.data_no_valid = 1'b1; inf.D = 72'b0; inf.D.d_data_no[0] = rnd.dram_no; @(negedge clk); inf.data_no_valid = 1'b0; inf.D = 72'bx; check_out_not_early();
            for(int i=0; i<5; i++) begin
                delay_task();
                inf.restock_valid = 1'b1; inf.D = 72'b0; inf.D.d_stock[0] = rnd.restock_amt[i]; @(negedge clk); inf.restock_valid = 1'b0; inf.D = 72'bx;
                if (i < 4) check_out_not_early();
            end
        end
        Hire_Staff: begin
            delay_task();
            inf.staff_valid = 1'b1; inf.D = 72'b0; inf.D.d_staff[0] = rnd.hire_staff_num; @(negedge clk); inf.staff_valid = 1'b0; inf.D = 72'bx; check_out_not_early();
            delay_task();
            inf.date_valid = 1'b1; inf.D = 72'b0; inf.D.d_date[0] = {rnd.month, rnd.day}; @(negedge clk); inf.date_valid = 1'b0; inf.D = 72'bx; check_out_not_early();
            delay_task();
            inf.data_no_valid = 1'b1; inf.D = 72'b0; inf.D.d_data_no[0] = rnd.dram_no; @(negedge clk); inf.data_no_valid = 1'b0; inf.D = 72'bx;
        end
        Pay_Day, Check_Valid_Date: begin
            delay_task();
            inf.date_valid = 1'b1; inf.D = 72'b0; inf.D.d_date[0] = {rnd.month, rnd.day}; @(negedge clk); inf.date_valid = 1'b0; inf.D = 72'bx; check_out_not_early();
            delay_task();
            inf.data_no_valid = 1'b1; inf.D = 72'b0; inf.D.d_data_no[0] = rnd.dram_no; @(negedge clk); inf.data_no_valid = 1'b0; inf.D = 72'bx;
        end
    endcase
end endtask

task reset_task; begin
    inf.rst_n = 1'b1; inf.sel_action_valid = 1'b0; inf.type_valid = 1'b0;
    inf.mode_valid = 1'b0;
    inf.staff_valid = 1'b0; inf.date_valid = 1'b0; inf.data_no_valid = 1'b0; inf.restock_valid = 1'b0; inf.D = 72'bx;
    #(`CYCLE_TIME / 2.0); inf.rst_n = 1'b0; #(`CYCLE_TIME * 3.0);
    
    if (inf.out_valid !== 1'b0 || inf.complete !== 1'b0 || inf.warn_msg !== No_Warn || inf.AR_VALID !== 1'b0 || inf.AW_VALID !== 1'b0 || inf.W_VALID !== 1'b0) begin
        YOU_FAIL_task;
        $display("[ERROR] Output signals are not reset to 0 after rst_n is asserted!");
        $finish;
    end
    inf.rst_n = 1'b1; #(`CYCLE_TIME / 2.0);
end endtask

task wait_out_valid_task;
begin
    latency = 0;
    while(inf.out_valid !== 1'b1) begin
        latency++;
        if(latency >= MAX_CYCLE) begin YOU_FAIL_task; $display("[ERROR] Latency exceeded %0d cycles at pattern %0d", MAX_CYCLE, patcount); $finish;
        end
        @(negedge clk);
    end
    total_latency = total_latency + latency;
end endtask

task gen_cvd_probe_first;
    int no;
begin
    rnd.act = Check_Valid_Date;
    rnd.month = 1;
    rnd.day   = 1;
    no = find_cvd_date_warn_shop(1, 1);
    probe_cvd_no = no;

    if (no != -1) begin
        rnd.dram_no = Data_No'(no);
    end
    else begin
        rnd.dram_no = Data_No'($urandom_range(0, 127));
    end
end
endtask

task gen_cvd_probe_second;
begin
    rnd.act = Check_Valid_Date;
    rnd.month = 1;
    rnd.day   = 1;
    if (probe_cvd_no != -1)
        rnd.dram_no = Data_No'(probe_cvd_no);
    else
        rnd.dram_no = Data_No'($urandom_range(0, 127));
end
endtask

//================================================================
// Tasks: Golden Model & Checking
//================================================================
task calculate_golden_model;
begin
    int base_addr = 65536 + (rnd.dram_no * 16); logic [63:0] word1, word2; logic date_is_early;
    int req_flour, req_butter, req_milk, req_sugar, req_fruit, scale;
    int base_price, total_price, level_div_10, upgrade_threshold;
    int cost_flour, cost_butter, cost_milk, cost_sugar, cost_fruit, total_cost;
    int actual_add_flour, actual_add_butter, actual_add_milk, actual_add_sugar, actual_add_fruit;
    int hire_fee, actual_hired, total_salary, old_level, new_sales;
    word1 = {golden_DRAM[base_addr+7], golden_DRAM[base_addr+6], golden_DRAM[base_addr+5], golden_DRAM[base_addr+4],
             golden_DRAM[base_addr+3], golden_DRAM[base_addr+2], golden_DRAM[base_addr+1], golden_DRAM[base_addr+0]};
    word2 = {golden_DRAM[base_addr+15], golden_DRAM[base_addr+14], golden_DRAM[base_addr+13], golden_DRAM[base_addr+12],
             golden_DRAM[base_addr+11], golden_DRAM[base_addr+10], golden_DRAM[base_addr+9], golden_DRAM[base_addr+8]};
    curr_shop_data.Flour=word1[63:52]; curr_shop_data.Butter=word1[51:40]; curr_shop_data.M=word1[39:32];
    curr_shop_data.Milk=word1[31:20]; curr_shop_data.Sugar=word1[19:8]; curr_shop_data.D=word1[7:0];
    curr_shop_data.Fruit=word2[63:52]; curr_shop_data.Sales=word2[51:40]; curr_shop_data.Staff=word2[39:32];
    curr_shop_data.Balance=word2[31:8]; curr_shop_data.Level=word2[7:0];

    pre_shop_data = curr_shop_data; level_div_10 = curr_shop_data.Level / 10;
    date_is_early = 1'b0;
    if (rnd.month < curr_shop_data.M) date_is_early = 1'b1;
    else if (rnd.month == curr_shop_data.M && rnd.day < curr_shop_data.D) date_is_early = 1'b1;
    
    golden_complete = 1'b0; golden_warn_msg = No_Warn;
    if (date_is_early) begin
        golden_warn_msg = Date_Warn;
        if (rnd.act == Check_Valid_Date) begin curr_shop_data.M = rnd.month; curr_shop_data.D = rnd.day;
        end
    end else begin
        curr_shop_data.M = rnd.month; curr_shop_data.D = rnd.day;
        case (rnd.act)
            Make_and_Sell: begin
                if (curr_shop_data.Staff == 0) golden_warn_msg = No_Staff_Warn;
                else begin
                    req_flour=0;
                    req_butter=0; req_milk=0; req_sugar=0; req_fruit=0; base_price=0;
                    case (rnd.dessert)
                        Cookie:     begin req_flour=100; req_butter=50;  req_milk=0;   req_sugar=30;  req_fruit=0;   base_price=120; end
                        Bread:      begin req_flour=200; req_butter=20;  req_milk=50;  req_sugar=10;  req_fruit=0;   base_price=100; end
                        Fruit_Cake: begin req_flour=150; req_butter=80;  req_milk=40;  req_sugar=60;  req_fruit=100; base_price=400; end
                        Pudding:    begin req_flour=0;   req_butter=0;   req_milk=150; req_sugar=50;  req_fruit=20;  base_price=180; end
                        Macaron:    begin req_flour=40;  req_butter=30;  req_milk=0;   req_sugar=120; req_fruit=0;   base_price=250; end
                        Pancake:    begin req_flour=120; req_butter=30;  req_milk=80;  req_sugar=20;  req_fruit=40;  base_price=200; end
                        Brownie:    begin req_flour=80;  req_butter=100; req_milk=0;   req_sugar=100; req_fruit=0;   base_price=280; end
                        Scone:      begin req_flour=150; req_butter=60;  req_milk=30;  req_sugar=20;  req_fruit=10;  base_price=160; end
                    endcase
                    scale = (rnd.mode == Single) ? 1 : (rnd.mode == Family_Set) ? 4 : 8;
                    req_flour *= scale; req_butter *= scale; req_milk *= scale;
                    req_sugar *= scale; req_fruit *= scale;
                    if (curr_shop_data.Flour < req_flour || curr_shop_data.Butter < req_butter || curr_shop_data.Milk < req_milk || curr_shop_data.Sugar < req_sugar || curr_shop_data.Fruit < req_fruit) begin
                        golden_warn_msg = Stock_Warn;
                    end else begin
                        golden_complete = 1'b1;
                        curr_shop_data.Flour -= req_flour; curr_shop_data.Butter -= req_butter; curr_shop_data.Milk -= req_milk; curr_shop_data.Sugar -= req_sugar; curr_shop_data.Fruit -= req_fruit;
                        total_price = ((base_price * (10 + level_div_10)) / 10) + ((curr_shop_data.Level * curr_shop_data.Level) / 200); total_price *= scale;
                        if ((curr_shop_data.Balance + total_price) > 16777215) curr_shop_data.Balance = 16777215; else curr_shop_data.Balance += total_price;
                        old_level = curr_shop_data.Level;
                        new_sales = curr_shop_data.Sales + scale;
                        if (old_level >= 100) begin
                            curr_shop_data.Level = 100;
                            curr_shop_data.Sales = (new_sales > 4095) ? 4095 : new_sales[11:0];
                        end else begin
                            upgrade_threshold = (10 * level_div_10 > 10) ? (10 * level_div_10) : 10;
                            if (new_sales >= upgrade_threshold) begin
                                curr_shop_data.Level += (new_sales / upgrade_threshold);
                                curr_shop_data.Sales  = (new_sales % upgrade_threshold);
                                if (curr_shop_data.Level > 100) begin curr_shop_data.Level = 100; curr_shop_data.Sales = (new_sales > 4095) ? 4095 : new_sales[11:0]; end
                            end else begin curr_shop_data.Sales = new_sales;
                            end
                        end
                    end
                end
            end
            Restock: begin
               
                cost_flour  = (15 * (10 + level_div_10)) / 10; cost_butter = (60 * (10 + level_div_10)) / 10;
                cost_milk   = (25 * (10 + level_div_10)) / 10;
                cost_sugar  = (10 * (10 + level_div_10)) / 10; cost_fruit  = (80 * (10 + level_div_10)) / 10;
                actual_add_flour  = ((curr_shop_data.Flour   + rnd.restock_amt[0]) > 4095) ? (4095 - curr_shop_data.Flour)  : rnd.restock_amt[0];
                actual_add_butter = ((curr_shop_data.Butter + rnd.restock_amt[1]) > 4095) ? (4095 - curr_shop_data.Butter) : rnd.restock_amt[1];
                actual_add_milk   = ((curr_shop_data.Milk    + rnd.restock_amt[2]) > 4095) ? (4095 - curr_shop_data.Milk)   : rnd.restock_amt[2];
                actual_add_sugar   = ((curr_shop_data.Sugar   + rnd.restock_amt[3]) > 4095) ? (4095 - curr_shop_data.Sugar)  : rnd.restock_amt[3];
                actual_add_fruit   = ((curr_shop_data.Fruit   + rnd.restock_amt[4]) > 4095) ? (4095 - curr_shop_data.Fruit)  : rnd.restock_amt[4];
                total_cost = (actual_add_flour*cost_flour) + (actual_add_butter*cost_butter) + (actual_add_milk*cost_milk) + (actual_add_sugar*cost_sugar) + (actual_add_fruit*cost_fruit);
                
                if (curr_shop_data.Balance < total_cost) begin golden_warn_msg = Balance_Warn;
                end
                else begin
                    curr_shop_data.Flour += actual_add_flour;
                    curr_shop_data.Butter += actual_add_butter; curr_shop_data.Milk += actual_add_milk; curr_shop_data.Sugar += actual_add_sugar; curr_shop_data.Fruit += actual_add_fruit;
                    curr_shop_data.Balance -= total_cost;
                    if (actual_add_flour<rnd.restock_amt[0] || actual_add_butter<rnd.restock_amt[1] || actual_add_milk<rnd.restock_amt[2] || actual_add_sugar<rnd.restock_amt[3] || actual_add_fruit<rnd.restock_amt[4]) begin
                        golden_warn_msg = Restock_Warn;
                    end else begin golden_complete = 1'b1; end
                end
            end
            Hire_Staff: begin
                hire_fee = 2000 + (curr_shop_data.Level * 100) + (level_div_10 * 200);
                actual_hired = ((curr_shop_data.Staff + rnd.hire_staff_num) > 100) ? (100 - curr_shop_data.Staff) : rnd.hire_staff_num;
                if (actual_hired < rnd.hire_staff_num) begin
                    golden_warn_msg = Staff_Warn;
                    curr_shop_data.Staff = curr_shop_data.Staff + actual_hired; curr_shop_data.Balance = curr_shop_data.Balance - (hire_fee * actual_hired);
                end else begin
                    total_cost = hire_fee * rnd.hire_staff_num;
                    if (curr_shop_data.Balance < total_cost) begin golden_warn_msg = Balance_Warn; end
                    else begin golden_complete = 1'b1;
                        curr_shop_data.Staff = curr_shop_data.Staff + rnd.hire_staff_num; curr_shop_data.Balance = curr_shop_data.Balance - total_cost;
                    end
                end
            end
            Pay_Day: begin
                if (curr_shop_data.Staff == 0) golden_warn_msg = No_Staff_Warn;
                else begin
                    total_salary = (20000 + (curr_shop_data.Level * 200) + (level_div_10 * 1000)) * curr_shop_data.Staff;
                    if (curr_shop_data.Balance < total_salary) begin
                        golden_warn_msg = Balance_Warn;
                        curr_shop_data.Level = (curr_shop_data.Level < 10) ? 0 : (curr_shop_data.Level - 10);
                        curr_shop_data.Staff = (curr_shop_data.Staff / 2 == 0) ? 1 : (curr_shop_data.Staff / 2);
                        curr_shop_data.Sales = 0;
                    end else begin
                        golden_complete = 1'b1;
                        curr_shop_data.Balance -= total_salary;
                    end
                end
            end
            Check_Valid_Date: begin golden_complete = 1'b1;
            end
        endcase
    end

    word1 = 64'b0;
    word1[63:52] = curr_shop_data.Flour; word1[51:40] = curr_shop_data.Butter; word1[39:32] = curr_shop_data.M; word1[31:20] = curr_shop_data.Milk; word1[19:8] = curr_shop_data.Sugar; word1[7:0] = curr_shop_data.D;
    word2 = 64'b0; word2[63:52] = curr_shop_data.Fruit; word2[51:40] = curr_shop_data.Sales; word2[39:32] = curr_shop_data.Staff; word2[31:8] = curr_shop_data.Balance; word2[7:0] = curr_shop_data.Level;
    golden_DRAM[base_addr+0] = word1[7:0];   golden_DRAM[base_addr+1] = word1[15:8];  golden_DRAM[base_addr+2] = word1[23:16]; golden_DRAM[base_addr+3] = word1[31:24];
    golden_DRAM[base_addr+4] = word1[39:32]; golden_DRAM[base_addr+5] = word1[47:40];
    golden_DRAM[base_addr+6] = word1[55:48]; golden_DRAM[base_addr+7] = word1[63:56];
    golden_DRAM[base_addr+8] = word2[7:0];   golden_DRAM[base_addr+9] = word2[15:8];  golden_DRAM[base_addr+10]= word2[23:16]; golden_DRAM[base_addr+11]= word2[31:24];
    golden_DRAM[base_addr+12]= word2[39:32]; golden_DRAM[base_addr+13]= word2[47:40];
    golden_DRAM[base_addr+14]= word2[55:48]; golden_DRAM[base_addr+15]= word2[63:56];
end endtask

task check_task;
    Warn_Msg dut_warn_msg;
begin
    dut_warn_msg = Warn_Msg'(inf.warn_msg);
    warn_count[dut_warn_msg]++;
    if (inf.complete !== golden_complete || inf.warn_msg !== golden_warn_msg) begin
        YOU_FAIL_task;
        $display("\033[0;31m==========================================================\033[0m");
        $display("                     Wrong Answer");
        $display("\033[0;31m==========================================================\033[0m");
        $display("\033[0;31m[ERROR] Pattern %0d Failed!\033[0m", patcount);
        $display("  [Input Information]");
        $display("  Action     : %s", rnd.act.name());
        $display("  DRAM No    : %0d", rnd.dram_no);
        $display("  Input Date : %0d/%0d", rnd.month, rnd.day);
        if (rnd.act == Make_and_Sell)
            $display("  Make Info  : %s, %s", rnd.dessert.name(), rnd.mode.name());
        else if (rnd.act == Restock)
            $display("  Restock Amt: F:%0d, B:%0d, M:%0d, S:%0d, Fr:%0d", rnd.restock_amt[0], rnd.restock_amt[1], rnd.restock_amt[2], rnd.restock_amt[3], rnd.restock_amt[4]);
        else if (rnd.act == Hire_Staff)
            $display("  Hire Amount: %0d", rnd.hire_staff_num);
        $display("  --------------------------------------------------------");
        $display("  [Golden Model State (TRUE Initial State Before Operation)]");
        $display("  Shop Date  : %0d/%0d", pre_shop_data.M, pre_shop_data.D);
        $display("  Level      : %0d", pre_shop_data.Level);
        $display("  Staff      : %0d", pre_shop_data.Staff);
        $display("  Sales      : %0d", pre_shop_data.Sales);
        $display("  Balance    : %0d", pre_shop_data.Balance);
        $display("  Ingredients: F:%0d, B:%0d, M:%0d, S:%0d, Fr:%0d", pre_shop_data.Flour, pre_shop_data.Butter, pre_shop_data.Milk, pre_shop_data.Sugar, pre_shop_data.Fruit);
        $display("  --------------------------------------------------------");
        $display("  Expected : Complete = %b, Warn = %s", golden_complete, golden_warn_msg.name());
        $display("  Received : Complete = %b, Warn = %s", inf.complete, dut_warn_msg.name());
        $display("\033[0;31m==========================================================\033[0m\n");
        $finish;
    end

    @(negedge clk);
    if (inf.out_valid !== 1'b0 || inf.complete !== 1'b0) begin
        YOU_FAIL_task;
        $display("\n\033[0;31m==========================================================\033[0m");
        $display("\033[0;31m[ERROR] out_valid/complete should only be high for exactly 1 cycle!\033[0m");
        $display("\033[0;31m==========================================================\033[0m\n");
        $finish;
    end

    $display("\033[0;36m[PASS] Pattern %04d \033[0m| Action: %-16s | Latency: %4d | Warn: %-15s", 
              patcount, rnd.act.name(), latency, dut_warn_msg.name());
end endtask

task gen_make_cover_combo(input int combo);
    int no;
begin
    rnd.act = Make_and_Sell;
    rnd.month = 12;
    rnd.day   = 31;

    rnd.dessert = get_type(combo / 3);
    rnd.mode    = get_mode(combo % 3);
    no = find_make_safe_shop(rnd.dessert, rnd.mode);
    if (no == -1)
        no = find_make_stock_warn_shop(rnd.dessert, rnd.mode);
    if (no == -1)
        no = find_no_staff_shop();
    if (no != -1)
        rnd.dram_no = Data_No'(no);
    else
        gen_cvd_safe();
end
endtask

//================================================================
// Main Execution
//================================================================
initial begin
    rnd = new(); rnd.srandom(SEED);
    $display("\033[0;34m[*] PATTERN initialized with Random Seed: %0d\033[0m", SEED);
    $readmemh(DRAM_p_r, golden_DRAM); 
    
    total_latency = 0;
    foreach(act_count[i]) act_count[i] = 0;
    foreach(warn_count[i]) warn_count[i] = 0;

    reset_task();
    cov_make_idx    = 0;
    cov_restock_idx = 0;
    cov_hire_idx    = 0;
    cov_payday_idx  = 0;
    cov_cvd_idx     = 0;

    probe_staff_no  = -1;
    probe_payday_no = -1;
    probe_cvd_no = -1;

    for (patcount = 0; patcount < PATNUM; patcount++) begin
        if (!rnd.randomize()) begin $display("[ERROR] Randomize failed!");
        $finish; end
        
        directed_task();
        // Routes to Generator -> Finder
        act_count[rnd.act]++;
        
        delay_task(); 
        drive_task();
        calculate_golden_model();
        wait_out_valid_task();
        check_task();
    end
    YOU_PASS_task;
    $display("\n\033[0;32m==================================================\033[0m");
    $display("                Congratulations                  ");
    $display("\033[0;32m==================================================\033[0m");
    $display("\n\033[0;33m[Summary Statistics]\033[0m");
    $display("--------------------------------------------------");
    $display("  \033[0;36mTotal Latency    :\033[0m %0d cycles", total_latency);
    $display("--------------------------------------------------");
    $display("  \033[0;35mAction Counts:\033[0m");
    $display("    Make_and_Sell    : %0d", act_count[Make_and_Sell]);
    $display("    Restock          : %0d", act_count[Restock]);
    $display("    Hire_Staff       : %0d", act_count[Hire_Staff]);
    $display("    Pay_Day          : %0d", act_count[Pay_Day]);
    $display("    Check_Valid_Date : %0d", act_count[Check_Valid_Date]);
    $display("--------------------------------------------------");
    $display("  \033[0;35mWarning Counts:\033[0m");
    $display("    No_Warn          : %0d", warn_count[No_Warn]);
    $display("    Date_Warn        : %0d", warn_count[Date_Warn]);
    $display("    No_Staff_Warn    : %0d", warn_count[No_Staff_Warn]);
    $display("    Stock_Warn       : %0d", warn_count[Stock_Warn]);
    $display("    Balance_Warn     : %0d", warn_count[Balance_Warn]);
    $display("    Restock_Warn     : %0d", warn_count[Restock_Warn]);
    $display("    Staff_Warn       : %0d", warn_count[Staff_Warn]);
    $display("==================================================\n");

    $finish;
end

task YOU_PASS_task; begin
    $display("\033[38;5;236ml\033[38;5;238m1\033[38;5;240mn\033[38;5;95munncu\033[38;5;239mjr\033[38;5;95mucU\033[38;5;244mCL\033[38;5;243mUY\033[38;5;242mz\033[38;5;240mn\033[38;5;238mt\033[38;5;236ml\033[38;5;233m::\033[38;5;234m;\033[38;5;235mI\033[38;5;239mj\033[38;5;241mz\033[38;5;243mU\033[38;5;102m0\033[38;5;245mOmO\033[38;5;138mO\033[38;5;137m0\033[38;5;101mCLLC0C\033[38;5;138mOOOmOOmO0\033[38;5;131mL\033[38;5;101mLLC\033[38;5;102mC\033[38;5;138m0\033[38;5;244mCLC\033[38;5;95mU\033[38;5;101mLL\033[38;5;95mYXU\033[38;5;96mL\033[38;5;95mLU\033[38;5;131mLL\033[38;5;138mCC\033[38;5;102m0\033[38;5;95mUzX\033[38;5;138m0w\033[38;5;247md\033[38;5;145mk\033[38;5;249mo\033[38;5;250mg\033[38;5;251ms\033[38;5;188mAG\033[38;5;189mG\033[38;5;188mGGGGG\033[38;5;189mGSSSG\033[38;5;188mGAG\033[38;5;189mGSSSSSS###M#\033[38;5;254mW\033[38;5;189mM\033[38;5;254mMW\033[38;5;189mMM\033[38;5;253m#S\033[38;5;188mA\033[38;5;251mg\033[38;5;249mo\033[38;5;138mm\033[38;5;131mYXUL\033[38;5;138m0O\033[0m");
    $display("\033[38;5;16m  .\033[38;5;233m:\033[38;5;234m!!\033[38;5;238mt\033[38;5;95mX\033[38;5;131mc\033[38;5;95muuuz\033[38;5;131mz\033[38;5;95mvn\033[38;5;88m1\033[38;5;52mI:\033[38;5;16m.     .\033[38;5;52m;\033[38;5;238m1\033[38;5;95mv\033[38;5;131mYUUU\033[38;5;95mXzcccvvuunnrr\033[38;5;88m11t\033[38;5;94mrr\033[38;5;95mrxncXz\033[38;5;131mz\033[38;5;95mcunuvv\033[38;5;131mz\033[38;5;95mcvnxjrxuzX\033[38;5;96mL\033[38;5;138mm\033[38;5;247md\033[38;5;145mh\033[38;5;249me\033[38;5;250mg\033[38;5;188msGG\033[38;5;189mSGG\033[38;5;188mAG\033[38;5;189mGGGG\033[38;5;188mS\033[38;5;189mSA\033[38;5;188mGAGG\033[38;5;189mSSS\033[38;5;253mSS\033[38;5;189mSS\033[38;5;253m##\033[38;5;189mMMM\033[38;5;254mMM\033[38;5;189mMM\033[38;5;253m##S\033[38;5;188mA\033[38;5;251mp\033[38;5;249mqo\033[38;5;145ma\033[38;5;249moooo\033[0m");
    $display("\033[38;5;16m       .\033[38;5;235mI\033[38;5;124m11\033[38;5;88m]]?llIi\033[38;5;52m;\033[38;5;233m,\033[38;5;16m.    .\033[38;5;52ml\033[38;5;239mj\033[38;5;95mnucXccuuxxxxnnuvvunr\033[38;5;88mtt\033[38;5;94mjt\033[38;5;95mrnzzXXzXU\033[38;5;101mL\033[38;5;138mOmmw\033[38;5;247md\033[38;5;246mw\033[38;5;138mp\033[38;5;246mw\033[38;5;102m0C\033[38;5;245mOmm\033[38;5;246mwp\033[38;5;247mb\033[38;5;249mo\033[38;5;250mf\033[38;5;251mp\033[38;5;188mAGG\033[38;5;253mS\033[38;5;188mGGGAGGGGGG\033[38;5;189mS\033[38;5;188mGA\033[38;5;252mA\033[38;5;188mA\033[38;5;189mGSS\033[38;5;188mGS\033[38;5;253mSS\033[38;5;189m#\033[38;5;253m####\033[38;5;189mMMMM#\033[38;5;253m#S\033[38;5;188mGA\033[38;5;251mg\033[38;5;152mgf\033[38;5;250mgffg\033[0m");
    $display("\033[38;5;16m         \033[38;5;232m,\033[38;5;94mj\033[38;5;131mzv\033[38;5;95mnunrr\033[38;5;238mj\033[38;5;237m[\033[38;5;236ml\033[38;5;234m!!\033[38;5;235mi\033[38;5;236m?\033[38;5;240mn\033[38;5;243mYL\033[38;5;244mLC\033[38;5;102m0\033[38;5;245m0\033[38;5;102m0\033[38;5;243mL\033[38;5;95mXXzXX\033[38;5;243mY\033[38;5;244mC\033[38;5;102m0\033[38;5;245mOO\033[38;5;138mm\033[38;5;245mO\033[38;5;246mww\033[38;5;245mO\033[38;5;244mLL\033[38;5;101mLYU\033[38;5;244mL\033[38;5;102m0O\033[38;5;245mmm\033[38;5;246mwp\033[38;5;245mm\033[38;5;246mm\033[38;5;145ma\033[38;5;251mp\033[38;5;252mA\033[38;5;250mg\033[38;5;251ms\033[38;5;249me\033[38;5;250mq\033[38;5;152mq\033[38;5;109mk\033[38;5;246mdpp\033[38;5;247mbk\033[38;5;248mh\033[38;5;249mo\033[38;5;250mf\033[38;5;188msAG\033[38;5;253mSSS\033[38;5;188mGAGGAGG\033[38;5;189mSSG\033[38;5;188mAGA\033[38;5;152mA\033[38;5;188mG\033[38;5;189mGSGG\033[38;5;188mS\033[38;5;253mS\033[38;5;189mS\033[38;5;253mSS#####\033[38;5;189m##\033[38;5;253m#S\033[38;5;188mGA\033[38;5;251mp\033[38;5;250mggffqf\033[0m");
    $display("\033[38;5;16m          .\033[38;5;238m1\033[38;5;138mw\033[38;5;145mh\033[38;5;247md\033[38;5;246mw\033[38;5;245mO\033[38;5;102mO\033[38;5;244mC\033[38;5;243mUU\033[38;5;242mY\033[38;5;243mULL\033[38;5;102m0\033[38;5;246mmwdppw\033[38;5;245mO\033[38;5;244mC\033[38;5;243mUL\033[38;5;244mLLC\033[38;5;102mO\033[38;5;245mOm\033[38;5;246mp\033[38;5;247mbb\033[38;5;248maakhh\033[38;5;246mp\033[38;5;245mwO\033[38;5;246mp\033[38;5;248mh\033[38;5;102m0\033[38;5;242mYz\033[38;5;244m0\033[38;5;59mv\033[38;5;235ml\033[38;5;233m;\033[38;5;16m  \033[38;5;232m,\033[38;5;235mIl\033[38;5;239mj\033[38;5;247mk\033[38;5;109mk\033[38;5;250mq\033[38;5;188mG\033[38;5;252mA\033[38;5;251ms\033[38;5;250mf\033[38;5;249me\033[38;5;145ma\033[38;5;248mh\033[38;5;249me\033[38;5;250mf\033[38;5;252mA\033[38;5;188mG\033[38;5;253mSSS\033[38;5;188mSGAG\033[38;5;189mG\033[38;5;188mGGGSGGAAAAGGGGG\033[38;5;189mG\033[38;5;253mSS#S\033[38;5;189mSS\033[38;5;253mS\033[38;5;189m##M\033[38;5;253m##S\033[38;5;188mGA\033[38;5;251msgg\033[38;5;250mggff\033[0m");
    $display("\033[38;5;16m            \033[38;5;235mI\033[38;5;245mO\033[38;5;249me\033[38;5;248mk\033[38;5;246mwm\033[38;5;245mwmO\033[38;5;244mCC\033[38;5;102m0C\033[38;5;245mm\033[38;5;246mppwwww\033[38;5;245mmO\033[38;5;244mCC\033[38;5;243mLLL\033[38;5;244mL\033[38;5;245mO\033[38;5;246mp\033[38;5;247mb\033[38;5;246mww\033[38;5;242mY\033[38;5;238mt\033[38;5;237m[[\033[38;5;233m:\033[38;5;16m. .\033[38;5;235ml\033[38;5;237m]\033[38;5;16m                 \033[38;5;233m:\033[38;5;237m[\033[38;5;242mX\033[38;5;250mq\033[38;5;188mG\033[38;5;253m#S\033[38;5;188mGsAG\033[38;5;253m#S\033[38;5;188mGGAAGAG\033[38;5;189mG\033[38;5;188mGGGAAGAAGGGG\033[38;5;189mS\033[38;5;253mSSSS###S#S#SS\033[38;5;188mG\033[38;5;252mA\033[38;5;251mg\033[38;5;250mg\033[38;5;251mp\033[38;5;250mggff\033[0m");
    $display("\033[38;5;16m             \033[38;5;233m:\033[38;5;240mn\033[38;5;247mb\033[38;5;246md\033[38;5;245mmmmmmm\033[38;5;246mwwp\033[38;5;247md\033[38;5;246mpppdppw\033[38;5;245mmO\033[38;5;244mCL\033[38;5;246mp\033[38;5;247md\033[38;5;246mw\033[38;5;59mv\033[38;5;234m!\033[38;5;16m                                 \033[38;5;234mi\033[38;5;59mn\033[38;5;248mk\033[38;5;253m#\033[38;5;231m$$\033[38;5;255m8\033[38;5;189m#SS\033[38;5;188mSGGGGGGGG\033[38;5;189mG\033[38;5;188mGGAAGGG\033[38;5;189mGSG\033[38;5;253mSSSSSSS###MS\033[38;5;188mSAs\033[38;5;251mp\033[38;5;250mffffff\033[0m");
    $display("\033[38;5;16m             .\033[38;5;233m;\033[38;5;239mj\033[38;5;246mw\033[38;5;144mb\033[38;5;246mmw\033[38;5;245mm\033[38;5;246mwwpd\033[38;5;247mbk\033[38;5;248mh\033[38;5;145maah\033[38;5;248mh\033[38;5;247mkd\033[38;5;246mw\033[38;5;247md\033[38;5;250mq\033[38;5;248mk\033[38;5;239mx\033[38;5;234m;\033[38;5;16m         \033[38;5;232m,\033[38;5;16m ..                           \033[38;5;236m]\033[38;5;246mm\033[38;5;195m8\033[38;5;231m$@\033[38;5;195mW\033[38;5;189m###S##SSSS\033[38;5;253mS\033[38;5;189mSGSSSSSS########M#M#\033[38;5;253mSS\033[38;5;188mA\033[38;5;251mp\033[38;5;250mgqqqffg\033[0m");
    $display("\033[38;5;16m    .   .      \033[38;5;232m,\033[38;5;239mr\033[38;5;247mdd\033[38;5;246mww\033[38;5;245mm\033[38;5;246mp\033[38;5;247mbk\033[38;5;145ma\033[38;5;249moq\033[38;5;250mqqq\033[38;5;249mqo\033[38;5;145mo\033[38;5;250mf\033[38;5;251mp\033[38;5;241mc\033[38;5;16m            .\033[38;5;232m.\033[38;5;16m                      .         \033[38;5;238m1\033[38;5;145ma\033[38;5;195m@\033[38;5;231m@\033[38;5;189mW##S####SSSS#SSS#####M###M#MMM\033[38;5;253m#\033[38;5;188mGG\033[38;5;251mp\033[38;5;250mfqqffgg\033[0m");
    $display("\033[38;5;16m         .      \033[38;5;232m,\033[38;5;240mn\033[38;5;144mb\033[38;5;247md\033[38;5;246mm\033[38;5;245mm\033[38;5;246mp\033[38;5;247mb\033[38;5;248mh\033[38;5;249maq\033[38;5;250mfggfq\033[38;5;188ms\033[38;5;224mM\033[38;5;246mw\033[38;5;232m,\033[38;5;16m                       \033[38;5;234mi\033[38;5;238mt\033[38;5;16m              .          \033[38;5;145mk\033[38;5;231m@@\033[38;5;195mW\033[38;5;189m#S#S#SSSS\033[38;5;253mS\033[38;5;188mG\033[38;5;189mS#S##M##M###MMMM#\033[38;5;253mS\033[38;5;188mAs\033[38;5;250mgg\033[38;5;251mg\033[38;5;250mgg\033[38;5;251mgp\033[0m");
    $display("\033[38;5;232m,\033[38;5;233m,\033[38;5;232m,\033[38;5;16m          . ..\033[38;5;233m:\033[38;5;241mc\033[38;5;247mb\033[38;5;246mw\033[38;5;245mm\033[38;5;246mp\033[38;5;247mb\033[38;5;248mk\033[38;5;145mo\033[38;5;249mq\033[38;5;250mg\033[38;5;251mp\033[38;5;250mg\033[38;5;251ms\033[38;5;254m&\033[38;5;187mg\033[38;5;238mj\033[38;5;16m          .               \033[38;5;240mn\033[38;5;238mj\033[38;5;16m                         \033[38;5;237m1\033[38;5;145mh\033[38;5;231m@$\033[38;5;195m8\033[38;5;189mMM#S#SSSGSS#S#####M#MMMMMS\033[38;5;253mS\033[38;5;188mGs\033[38;5;250mg\033[38;5;251mg\033[38;5;250mg\033[38;5;251mgpgp\033[0m");
    $display("\033[38;5;233m:\033[38;5;234mi\033[38;5;235mi\033[38;5;233m;\033[38;5;232m,\033[38;5;16m. ... .     .\033[38;5;236m?\033[38;5;102m0\033[38;5;247mb\033[38;5;246mwp\033[38;5;247mb\033[38;5;248mk\033[38;5;145mo\033[38;5;249me\033[38;5;250mfg\033[38;5;188ms\033[38;5;253m#\033[38;5;240mx\033[38;5;16m         \033[38;5;232m,,\033[38;5;16m                .\033[38;5;240mx\033[38;5;234m!\033[38;5;16m                           \033[38;5;233m;\033[38;5;243mU\033[38;5;231mB@\033[38;5;189mMM#SGGGSSS###M#M###M#MW#\033[38;5;253m#S\033[38;5;188mG\033[38;5;252ms\033[38;5;251mppgpgpp\033[0m");
    $display("\033[38;5;233m;\033[38;5;16m    .  .\033[38;5;232m.,..\033[38;5;16m.    \033[38;5;232m,\033[38;5;240mn\033[38;5;246mppd\033[38;5;247mb\033[38;5;248mh\033[38;5;145mo\033[38;5;250mf\033[38;5;181mf\033[38;5;224mG\033[38;5;230m@\033[38;5;234m!\033[38;5;16m            . .           .\033[38;5;241mv\033[38;5;238m1\033[38;5;16m                                \033[38;5;248mh\033[38;5;254m&\033[38;5;252mA\033[38;5;188mG\033[38;5;189mG\033[38;5;152mG\033[38;5;189mGGSSS######M#M#MMM\033[38;5;253mM#S\033[38;5;188mG\033[38;5;252mA\033[38;5;251mpppgppp\033[0m");
    $display("\033[38;5;236m?\033[38;5;23m]\033[38;5;236m?\033[38;5;234m;\033[38;5;16m.      . .\033[38;5;232m,\033[38;5;233m;\033[38;5;232m,\033[38;5;16m  \033[38;5;234mi\033[38;5;244mC\033[38;5;144mk\033[38;5;247md\033[38;5;144mbh\033[38;5;145mo\033[38;5;250mq\033[38;5;224mM&\033[38;5;239mx\033[38;5;16m             ..            .\033[38;5;240mn\033[38;5;241mc\033[38;5;16m                                 \033[38;5;95mc\033[38;5;188mG\033[38;5;250mg\033[38;5;152mgs\033[38;5;189mG\033[38;5;188mG\033[38;5;189mGS###M#M####MMMWM#\033[38;5;253mS\033[38;5;188mG\033[38;5;251msgp\033[38;5;250mf\033[38;5;181mgffg\033[0m");
    $display("\033[38;5;16m  \033[38;5;234m;ii\033[38;5;233m;\033[38;5;16m.      .\033[38;5;233m:\033[38;5;235mI\033[38;5;234m!\033[38;5;16m.  \033[38;5;233m;\033[38;5;246mw\033[38;5;144mkkk\033[38;5;145mo\033[38;5;224mM\033[38;5;181mf\033[38;5;16m.               .            \033[38;5;235mI\033[38;5;60mz\033[38;5;238mt\033[38;5;16m               .                  \033[38;5;238mt\033[38;5;253mS\033[38;5;188mA\033[38;5;152mgA\033[38;5;188mA\033[38;5;189mSS####M##M#MMWMMM\033[38;5;253m#S\033[38;5;188mGs\033[38;5;251mg\033[38;5;250mgf\033[38;5;181mfqqq\033[0m");
    $display("\033[38;5;23m]\033[38;5;16m   \033[38;5;233m,\033[38;5;235mII\033[38;5;234m!\033[38;5;233m:;::\033[38;5;234m!\033[38;5;237m]]\033[38;5;88m[j11\033[38;5;52m]\033[38;5;16m.\033[38;5;240mn\033[38;5;247mk\033[38;5;144mbh\033[38;5;187ms\033[38;5;144mb\033[38;5;16m                 ..           \033[38;5;234m!\033[38;5;235mII\033[38;5;16m                                   \033[38;5;234m;\033[38;5;188mA\033[38;5;189m#\033[38;5;152mp\033[38;5;188mA\033[38;5;189mGSS#M###M###MMWWM\033[38;5;253m#S\033[38;5;188mGs\033[38;5;251mg\033[38;5;250mgf\033[38;5;181mfqqq\033[0m");
    $display("\033[38;5;95mYzv\033[38;5;59mu\033[38;5;240mx\033[38;5;239mx\033[38;5;95mc\033[38;5;243mU\033[38;5;242mXX\033[38;5;243mYU\033[38;5;102m0\033[38;5;138m0\033[38;5;131mz\033[38;5;125mr\033[38;5;95mnn\033[38;5;88mt\033[38;5;131mz\033[38;5;174mp\033[38;5;138mO\033[38;5;246mp\033[38;5;144mk\033[38;5;181mf\033[38;5;187mp\033[38;5;16m               .               \033[38;5;235mI\033[38;5;16m                                       \033[38;5;188ms\033[38;5;189mM\033[38;5;152ms\033[38;5;189mSS#######M#MMM\033[38;5;195mW\033[38;5;189mWM#\033[38;5;253mS\033[38;5;188mS\033[38;5;252mA\033[38;5;251mppg\033[38;5;181mgfqf\033[0m");
    $display("\033[38;5;146mf\033[38;5;249mo\033[38;5;145mh\033[38;5;247mb\033[38;5;138mm0\033[38;5;96mL\033[38;5;138mCp\033[38;5;181maefeh\033[38;5;132mC\033[38;5;131mncUX\033[38;5;95mr\033[38;5;131mz\033[38;5;174md\033[38;5;181mhq\033[38;5;187ms\033[38;5;238m1\033[38;5;16m            ..                 \033[38;5;234m!\033[38;5;16m                 .                      \033[38;5;189mM\033[38;5;195mW\033[38;5;189mG###M#M####MMW\033[38;5;195mW\033[38;5;189mMM\033[38;5;253mM#S\033[38;5;188mGG\033[38;5;252ms\033[38;5;251mppg\033[38;5;181mgf\033[0m");
    $display("\033[38;5;195m88B8&\033[38;5;153mS\033[38;5;188ms\033[38;5;146me\033[38;5;248mk\033[38;5;139mk\033[38;5;174mkkk\033[38;5;181ma\033[38;5;138mO\033[38;5;52m[i\033[38;5;125mr\033[38;5;131mvX\033[38;5;95mn\033[38;5;131mc\033[38;5;174mpd\033[38;5;235mi\033[38;5;16m                                  \033[38;5;233m;\033[38;5;16m                                      \033[38;5;239mr\033[38;5;195mB\033[38;5;189m#S#####M##M#MWMWM#\033[38;5;253m##S\033[38;5;188mSGA\033[38;5;251mssp\033[38;5;181mg\033[0m");
    $display("\033[38;5;231m$@\033[38;5;195mB\033[38;5;231m@\033[38;5;195mB@\033[38;5;231m@\033[38;5;195mB8&\033[38;5;189mS\033[38;5;251mp\033[38;5;249mo\033[38;5;174mbd\033[38;5;95mv\033[38;5;52ml\033[38;5;88m?l\033[38;5;89mt\033[38;5;131mv\033[38;5;95mu\033[38;5;131mn\033[38;5;233m:\033[38;5;16m                                .\033[38;5;232m.\033[38;5;16m \033[38;5;233m,\033[38;5;16m                                       \033[38;5;152ms\033[38;5;195m&\033[38;5;189m####M##M##MMMMWM#\033[38;5;253mMM#SS\033[38;5;188mS\033[38;5;252mA\033[38;5;187msp\033[38;5;181mf\033[0m");
    $display("\033[38;5;195mB@BB8BBB8&BB\033[38;5;153mA\033[38;5;138mm\033[38;5;137mO\033[38;5;95mznx\033[38;5;52m!;;\033[38;5;88mI\033[38;5;52m:\033[38;5;16m                              .     ..                                      \033[38;5;243mU\033[38;5;195mB\033[38;5;189m#S####M####MMWMMM\033[38;5;253mMM##S\033[38;5;187mGAAp\033[38;5;181mq\033[0m");
    $display("\033[38;5;231m@@\033[38;5;195m8BBB8WW\033[38;5;189mM\033[38;5;195m&8\033[38;5;152ms\033[38;5;146mfq\033[38;5;248mk\033[38;5;243mL\033[38;5;95mzr\033[38;5;52m::\033[38;5;232m,\033[38;5;16m                     .          . \033[38;5;234mii\033[38;5;16m  \033[38;5;238m1\033[38;5;237m[\033[38;5;234m!\033[38;5;16m                                    \033[38;5;238mt\033[38;5;195m&\033[38;5;189mS########MMMMMWM\033[38;5;253mM#M##\033[38;5;188mS\033[38;5;187mAssg\033[38;5;249mq\033[0m");
    $display("\033[38;5;231m@@@\033[38;5;195m@BB8&&88\033[38;5;189m#\033[38;5;138mpO0\033[38;5;95mz\033[38;5;235mi\033[38;5;52m!\033[38;5;95mu\033[38;5;132m0\033[38;5;52m[\033[38;5;16m           \033[38;5;232m,\033[38;5;233m:\033[38;5;16m   \033[38;5;232m,\033[38;5;16m    \033[38;5;237m[\033[38;5;16m         \033[38;5;235ml\033[38;5;234m!\033[38;5;233m;\033[38;5;16m \033[38;5;95mz\033[38;5;237m[\033[38;5;234m!\033[38;5;16m \033[38;5;239mx\033[38;5;181me\033[38;5;95mz\033[38;5;233m;\033[38;5;16m .\033[38;5;233m;\033[38;5;16m \033[38;5;236m?\033[38;5;232m.\033[38;5;16m \033[38;5;236m?\033[38;5;16m                           \033[38;5;242mX\033[38;5;195mW\033[38;5;189m#\033[38;5;188mG\033[38;5;189mSS######MMMMMMM\033[38;5;253m#MM#S\033[38;5;188mG\033[38;5;187ms\033[38;5;251ms\033[38;5;187mp\033[38;5;181mf\033[0m");
    $display("\033[38;5;195mBBBBBBB@B\033[38;5;255m8\033[38;5;195m@W\033[38;5;138mw\033[38;5;131mC\033[38;5;138mO\033[38;5;131mX\033[38;5;52m?\033[38;5;94mt\033[38;5;174mw\033[38;5;217mg\033[38;5;237m1\033[38;5;16m           \033[38;5;232m.\033[38;5;16m   ..   \033[38;5;243mU\033[38;5;236m]\033[38;5;16m   \033[38;5;233m:\033[38;5;16m   . \033[38;5;238mt\033[38;5;240mn\033[38;5;16m \033[38;5;234m!\033[38;5;138mp\033[38;5;237m[\033[38;5;241mv\033[38;5;16m \033[38;5;239mj\033[38;5;181ma\033[38;5;145mh\033[38;5;16m.  \033[38;5;232m.\033[38;5;233m:\033[38;5;16m \033[38;5;95mz\033[38;5;233m,\033[38;5;235mi\033[38;5;131mC\033[38;5;16m  \033[38;5;232m,\033[38;5;16m                       \033[38;5;245mm\033[38;5;189m#SSSSS#S####MMWMMM\033[38;5;253m#MMSS\033[38;5;188mG\033[38;5;187mssgp\033[0m");
    $display("\033[38;5;195mB\033[38;5;231m@@\033[38;5;195mB\033[38;5;231m$$@\033[38;5;195mBB@&\033[38;5;146me\033[38;5;138mOOm\033[38;5;137mL\033[38;5;95mv\033[38;5;131mz\033[38;5;211mo\033[38;5;182mg\033[38;5;16m            . ..  .\033[38;5;232m.\033[38;5;59mu\033[38;5;239mr\033[38;5;234m;\033[38;5;16m  \033[38;5;235mI\033[38;5;16m    \033[38;5;233m:\033[38;5;16m \033[38;5;138md\033[38;5;239mx\033[38;5;16m.\033[38;5;59mu\033[38;5;181mg\033[38;5;242mX\033[38;5;138mw\033[38;5;16m \033[38;5;237m[\033[38;5;138mm\033[38;5;188mp\033[38;5;238m1\033[38;5;95mX\033[38;5;16m .\033[38;5;235ml\033[38;5;236m?\033[38;5;16m \033[38;5;137mC\033[38;5;16m \033[38;5;240mn\033[38;5;174mp\033[38;5;232m,\033[38;5;235mI\033[38;5;234m!\033[38;5;16m                      \033[38;5;109ma\033[38;5;152mp\033[38;5;188mS\033[38;5;189mGSS#S#S##MMMMMMM\033[38;5;253m#M##S\033[38;5;187mGAspp\033[0m");
    $display("\033[38;5;255m8\033[38;5;231m@@@@@\033[38;5;195m@B\033[38;5;231m@$\033[38;5;195mB\033[38;5;248mk\033[38;5;131mC\033[38;5;138mO0\033[38;5;131mL\033[38;5;95mv\033[38;5;131mvz\033[38;5;95mx\033[38;5;16m           .  \033[38;5;234m;\033[38;5;232m.\033[38;5;16m \033[38;5;233m;\033[38;5;235ml\033[38;5;237m1\033[38;5;238mj\033[38;5;236ml\033[38;5;233m;\033[38;5;16m \033[38;5;238m1j\033[38;5;16m  .  \033[38;5;232m,\033[38;5;224mW\033[38;5;234m!\033[38;5;236ml\033[38;5;95mU\033[38;5;138md\033[38;5;240mn\033[38;5;138mm\033[38;5;16m \033[38;5;234m!\033[38;5;181mge\033[38;5;95mXY\033[38;5;241mv\033[38;5;235mil\033[38;5;95mv\033[38;5;235mI\033[38;5;16m \033[38;5;95mc\033[38;5;16m \033[38;5;131mL\033[38;5;174mk\033[38;5;235mll\033[38;5;16m  .\033[38;5;233m:\033[38;5;16m                  \033[38;5;102m0\033[38;5;189m#\033[38;5;152ms\033[38;5;188mA\033[38;5;189mSSS#S###MMWMWMM\033[38;5;253mMMMSS\033[38;5;187mGAAsp\033[0m");
    $display("\033[38;5;195m&W\033[38;5;153mG\033[38;5;189mSW\033[38;5;195mM&8B\033[38;5;231mB\033[38;5;195mB\033[38;5;152mg\033[38;5;137m0CC\033[38;5;95mL\033[38;5;131mLU\033[38;5;174md\033[38;5;95mx\033[38;5;16m           . \033[38;5;232m,\033[38;5;235mI\033[38;5;16m \033[38;5;237m][\033[38;5;235mi\033[38;5;59mn\033[38;5;237m]\033[38;5;240mn\033[38;5;16m \033[38;5;95mx\033[38;5;181mh\033[38;5;235mI\033[38;5;16m .\033[38;5;233m,,\033[38;5;16m \033[38;5;102mC\033[38;5;181mq\033[38;5;16m \033[38;5;244mC\033[38;5;181mo\033[38;5;245mm\033[38;5;233m:\033[38;5;139mb\033[38;5;235mI\033[38;5;236m?\033[38;5;224mA\033[38;5;181mgq\033[38;5;95mu\033[38;5;182ms\033[38;5;232m,\033[38;5;138mw\033[38;5;238mj\033[38;5;244mL\033[38;5;16m \033[38;5;232m,\033[38;5;235mI\033[38;5;16m \033[38;5;137mO\033[38;5;180ma\033[38;5;233m::\033[38;5;16m. \033[38;5;235ml\033[38;5;236ml\033[38;5;16m                 \033[38;5;236m]\033[38;5;254mM\033[38;5;152mp\033[38;5;188mAA\033[38;5;189mSS#S###MMMWMMM\033[38;5;253mMM##S\033[38;5;187mAAGsp\033[0m");
    $display("\033[38;5;195m888\033[38;5;152mp\033[38;5;188mA\033[38;5;195m&\033[38;5;189mWS\033[38;5;153mpg\033[38;5;152mf\033[38;5;145mh\033[38;5;138m0\033[38;5;95mYzzY\033[38;5;138mC\033[38;5;174md\033[38;5;238mt\033[38;5;16m           \033[38;5;233m:\033[38;5;16m \033[38;5;235mi\033[38;5;16m \033[38;5;237m[\033[38;5;59mn\033[38;5;237m]\033[38;5;241mv\033[38;5;236m?\033[38;5;239mx\033[38;5;16m \033[38;5;240mn\033[38;5;181mh\033[38;5;138mp\033[38;5;237m[\033[38;5;16m \033[38;5;236m?\033[38;5;233m:\033[38;5;240mn\033[38;5;16m \033[38;5;253mM\033[38;5;237m11\033[38;5;248mk\033[38;5;181me\033[38;5;241mv\033[38;5;239mx\033[38;5;182mp\033[38;5;240mn\033[38;5;235mI\033[38;5;181mqe\033[38;5;253mS\033[38;5;131mU\033[38;5;181mo\033[38;5;95mX\033[38;5;240mn\033[38;5;95mcvU\033[38;5;234m!\033[38;5;16m   \033[38;5;95mU\033[38;5;138mm\033[38;5;233m:\033[38;5;234m!\033[38;5;16m .\033[38;5;131mL\033[38;5;95mv\033[38;5;16m                \033[38;5;236m?\033[38;5;189mM\033[38;5;152ms\033[38;5;188mGGG\033[38;5;189mSS#S##MMMWWWMM\033[38;5;253m#MS\033[38;5;188mS\033[38;5;187mGGAAs\033[0m");
    $display("\033[38;5;195m888\033[38;5;116mp\033[38;5;110ma\033[38;5;189m#\033[38;5;153mA\033[38;5;152mf\033[38;5;146meeo\033[38;5;246mw\033[38;5;95mvu\033[38;5;131mL\033[38;5;174mm\033[38;5;138mO\033[38;5;145mk\033[38;5;95mX\033[38;5;16m           . \033[38;5;233m:\033[38;5;16m.\033[38;5;235ml\033[38;5;59mx\033[38;5;233m;\033[38;5;240mn\033[38;5;241mu\033[38;5;237m1\033[38;5;232m.\033[38;5;59mu\033[38;5;174mk\033[38;5;251mp\033[38;5;247mk\033[38;5;238mj\033[38;5;233m:\033[38;5;95mX\033[38;5;233m:\033[38;5;238mt\033[38;5;232m,\033[38;5;253m#\033[38;5;234m!\033[38;5;139mb\033[38;5;138mp\033[38;5;181ma\033[38;5;59mu\033[38;5;138m0\033[38;5;188ms\033[38;5;245mO\033[38;5;59mn\033[38;5;250mq\033[38;5;181mq\033[38;5;253m#\033[38;5;139mk\033[38;5;247mb\033[38;5;138mw\033[38;5;235mI\033[38;5;249me\033[38;5;238m1\033[38;5;138mwm\033[38;5;237m[\033[38;5;16m  \033[38;5;234mi\033[38;5;138mC\033[38;5;240mu\033[38;5;16m   \033[38;5;236m?\033[38;5;137mO\033[38;5;95mu\033[38;5;233m;\033[38;5;16m               \033[38;5;152mp\033[38;5;189mS\033[38;5;188mAG\033[38;5;189mSSS#SM##MWMWMMM\033[38;5;253m###S\033[38;5;187mA\033[38;5;223mGG\033[38;5;187mAG\033[0m");
    $display("\033[38;5;195m88B\033[38;5;153ms\033[38;5;109md\033[38;5;146mf\033[38;5;152mppg\033[38;5;153mp\033[38;5;152mq\033[38;5;245mO\033[38;5;95mU\033[38;5;247mb\033[38;5;96mU\033[38;5;232m,\033[38;5;235mi\033[38;5;242mz\033[38;5;234m;\033[38;5;16m        ..   \033[38;5;237m[\033[38;5;234m!\033[38;5;243mU\033[38;5;16m  \033[38;5;96mU\033[38;5;240mn\033[38;5;234mi\033[38;5;236m?\033[38;5;131mL\033[38;5;188mG\033[38;5;145ma\033[38;5;249mo\033[38;5;233m:\033[38;5;238mj\033[38;5;242mX\033[38;5;238mt\033[38;5;16m \033[38;5;239mj\033[38;5;225m&\033[38;5;236m?\033[38;5;250mf\033[38;5;138mw\033[38;5;181mq\033[38;5;243mU\033[38;5;244mL\033[38;5;188mp\033[38;5;246mp\033[38;5;242mz\033[38;5;247mb\033[38;5;181mf\033[38;5;254mW\033[38;5;145mk\033[38;5;182mp\033[38;5;138mO\033[38;5;244mC\033[38;5;238mt\033[38;5;182ms\033[38;5;239mr\033[38;5;248mk\033[38;5;102m0\033[38;5;237m[\033[38;5;16m  \033[38;5;95mYu\033[38;5;233m:\033[38;5;16m   \033[38;5;95mvn\033[38;5;237m1\033[38;5;16m               \033[38;5;245mw\033[38;5;189m#\033[38;5;188mAG\033[38;5;189mSSSS###M#MMMWMM\033[38;5;253m##SS\033[38;5;187mA\033[38;5;223mGGGA\033[0m");
    $display("\033[38;5;195m8\033[38;5;159mM\033[38;5;195m8\033[38;5;153mG\033[38;5;146ma\033[38;5;152mf\033[38;5;153ms\033[38;5;152mpgf\033[38;5;146mqq\033[38;5;250mf\033[38;5;243mU\033[38;5;16m. \033[38;5;52mi?\033[38;5;16m         \033[38;5;234m!\033[38;5;16m   .\033[38;5;233m:\033[38;5;234m!\033[38;5;59mu\033[38;5;16m \033[38;5;235mI\033[38;5;241mc\033[38;5;234m;\033[38;5;16m \033[38;5;95mz\033[38;5;181mq\033[38;5;224mW\033[38;5;138md\033[38;5;145mh\033[38;5;233m:\033[38;5;59mux\033[38;5;102m0\033[38;5;235mi\033[38;5;243mU\033[38;5;253mS\033[38;5;239mr\033[38;5;145mhk\033[38;5;181me\033[38;5;145mk\033[38;5;138m0\033[38;5;181me\033[38;5;247mb\033[38;5;240mn\033[38;5;138md\033[38;5;182mp\033[38;5;188mp\033[38;5;181mf\033[38;5;138md\033[38;5;252mA\033[38;5;174mb\033[38;5;239mj\033[38;5;102mC\033[38;5;181mh\033[38;5;95mY\033[38;5;138m0m\033[38;5;233m,\033[38;5;16m \033[38;5;238mt\033[38;5;181ma\033[38;5;235mI\033[38;5;16m   \033[38;5;232m.\033[38;5;95mz\033[38;5;240mn\033[38;5;233m:\033[38;5;232m,,\033[38;5;16m            \033[38;5;59mu\033[38;5;195mW\033[38;5;188mAAG\033[38;5;189mGSSS####MMMMMM#\033[38;5;253m##S\033[38;5;187mGA\033[38;5;223mG\033[38;5;187mAA\033[0m");
    $display("\033[38;5;195m&W&\033[38;5;153mA\033[38;5;109mh\033[38;5;152mfg\033[38;5;146meo\033[38;5;110maoh\033[38;5;235mI\033[38;5;16m \033[38;5;232m.\033[38;5;237m1\033[38;5;95mc\033[38;5;237m[\033[38;5;52m!\033[38;5;16m       \033[38;5;232m.\033[38;5;238mj\033[38;5;16m   . \033[38;5;236m?\033[38;5;16m  \033[38;5;235mI\033[38;5;236m?\033[38;5;16m \033[38;5;236ml\033[38;5;224mA\033[38;5;231m$B\033[38;5;182mf\033[38;5;249mo\033[38;5;16m.\033[38;5;242mz\033[38;5;233m;\033[38;5;102mC\033[38;5;234m!\033[38;5;102m0\033[38;5;253m#\033[38;5;234m!\033[38;5;247mb\033[38;5;250mf\033[38;5;247mb\033[38;5;249me\033[38;5;102m0\033[38;5;250mq\033[38;5;145ma\033[38;5;241mc\033[38;5;245m0\033[38;5;254mW\033[38;5;188mAA\033[38;5;181mo\033[38;5;224m#G\033[38;5;251mp\033[38;5;238mj\033[38;5;254mW\033[38;5;181mef\033[38;5;182mg\033[38;5;244mL\033[38;5;16m. \033[38;5;95mz\033[38;5;181mh\033[38;5;16m.   \033[38;5;237m[\033[38;5;138mw\033[38;5;95mn\033[38;5;236m?\033[38;5;233m:\033[38;5;232m,\033[38;5;16m           \033[38;5;239mx\033[38;5;195mW\033[38;5;152mg\033[38;5;188mAG\033[38;5;189mGSSS#S###MMMMM\033[38;5;253m#SS\033[38;5;188mG\033[38;5;187mGA\033[38;5;223mGGG\033[0m");
    $display("\033[38;5;195m88B\033[38;5;153mG\033[38;5;109mp\033[38;5;110ma\033[38;5;116me\033[38;5;110me\033[38;5;146mq\033[38;5;152mgf\033[38;5;182mq\033[38;5;95mU\033[38;5;52m?\033[38;5;237m[\033[38;5;95mYUz\033[38;5;52ml\033[38;5;16m \033[38;5;137mO\033[38;5;224m&\033[38;5;240mn\033[38;5;16m   \033[38;5;232m,\033[38;5;233m:\033[38;5;16m    .\033[38;5;232m,\033[38;5;16m      \033[38;5;232m,\033[38;5;242mzXX\033[38;5;102m0\033[38;5;16m \033[38;5;240mn\033[38;5;232m,\033[38;5;238mt\033[38;5;16m \033[38;5;95mc\033[38;5;253mM\033[38;5;239mr\033[38;5;245mm\033[38;5;181mah\033[38;5;250mf\033[38;5;242mY\033[38;5;181me\033[38;5;145ma\033[38;5;243mU\033[38;5;102m0\033[38;5;224m#\033[38;5;189m#\033[38;5;253m#\033[38;5;181mq\033[38;5;253mS\033[38;5;250mf\033[38;5;251mp\033[38;5;233m;:\033[38;5;242mz\033[38;5;239mj\033[38;5;59mn\033[38;5;237m[\033[38;5;16m   \033[38;5;59mu\033[38;5;234m!\033[38;5;16m    \033[38;5;101mL\033[38;5;95mXX\033[38;5;236m?\033[38;5;237m]\033[38;5;16m        \033[38;5;240mn\033[38;5;224m#\033[38;5;230m8\033[38;5;187mp\033[38;5;188mA\033[38;5;152mAA\033[38;5;188mGG\033[38;5;189mSSSSSS#######\033[38;5;253m#S\033[38;5;188mS\033[38;5;252mA\033[38;5;187mssssA\033[0m");
    $display("\033[38;5;195m88B\033[38;5;159mS\033[38;5;248mh\033[38;5;188mgAG\033[38;5;253m#\033[38;5;224mM8\033[38;5;225mW\033[38;5;231mB@\033[38;5;181me\033[38;5;138mwm\033[38;5;137mC\033[38;5;236m]l\033[38;5;224mW\033[38;5;94mx\033[38;5;235mI\033[38;5;16m                \033[38;5;232m,\033[38;5;16m.\033[38;5;234m!\033[38;5;16m \033[38;5;233m:\033[38;5;232m,\033[38;5;16m . \033[38;5;238mj\033[38;5;16m \033[38;5;235mI\033[38;5;224m#\033[38;5;242mz\033[38;5;59mu\033[38;5;181mh\033[38;5;182ms\033[38;5;247mb\033[38;5;243mU\033[38;5;138md\033[38;5;249me\033[38;5;238mjj\033[38;5;138mp\033[38;5;102mL\033[38;5;240mx\033[38;5;232m,\033[38;5;234m!\033[38;5;16m.      \033[38;5;235mi\033[38;5;237m1\033[38;5;16m        .\033[38;5;95mYYcX\033[38;5;235mi\033[38;5;16m      \033[38;5;234m!\033[38;5;181mq\033[38;5;131mY\033[38;5;94mn\033[38;5;173md\033[38;5;137mO\033[38;5;188mG\033[38;5;152mA\033[38;5;188mG\033[38;5;189mGGGSSSSS####M##\033[38;5;253mS\033[38;5;188mG\033[38;5;252mA\033[38;5;181mggffg\033[0m");
    $display("\033[38;5;195m8B8\033[38;5;254mW\033[38;5;224mM&\033[38;5;255m88\033[38;5;231mB\033[38;5;254m&M\033[38;5;188mGG\033[38;5;251mp\033[38;5;181mh\033[38;5;138md\033[38;5;248mk\033[38;5;95mz\033[38;5;238mj\033[38;5;16m \033[38;5;224m#\033[38;5;174md\033[38;5;16m               .\033[38;5;239mx\033[38;5;224mW\033[38;5;223ms\033[38;5;224mW\033[38;5;181me\033[38;5;243mY\033[38;5;138md\033[38;5;16m \033[38;5;237m[\033[38;5;16m \033[38;5;234m!\033[38;5;16m \033[38;5;235mi\033[38;5;224m#\033[38;5;59mn\033[38;5;232m,\033[38;5;138mm\033[38;5;224mG\033[38;5;181ma\033[38;5;246mm\033[38;5;145ma\033[38;5;138mO\033[38;5;237m[]\033[38;5;95mz\033[38;5;243mU\033[38;5;95mX\033[38;5;238mt\033[38;5;59mu\033[38;5;95mYz\033[38;5;224m&\033[38;5;16m \033[38;5;237m[\033[38;5;181mg\033[38;5;239mr\033[38;5;218ms\033[38;5;224mS\033[38;5;181mf\033[38;5;232m.\033[38;5;16m \033[38;5;234m!\033[38;5;235mI\033[38;5;16m    \033[38;5;234m!\033[38;5;137mL\033[38;5;95mXz\033[38;5;239mx\033[38;5;16m      \033[38;5;233m:\033[38;5;95mc\033[38;5;52m:\033[38;5;94mr\033[38;5;217mq\033[38;5;138mm\033[38;5;152mA\033[38;5;153mG\033[38;5;152ms\033[38;5;188mA\033[38;5;189mGSGSSSSS##M#M#\033[38;5;253mS\033[38;5;188mGp\033[38;5;250mf\033[38;5;249mo\033[38;5;144mo\033[38;5;249mo\033[38;5;181mo\033[0m");
    $display("\033[38;5;195mB\033[38;5;255m8\033[38;5;224m#M\033[38;5;231m8$\033[38;5;225m&\033[38;5;181mp\033[38;5;174mb\033[38;5;138mbd\033[38;5;145mk\033[38;5;181meeh\033[38;5;138md\033[38;5;247mb\033[38;5;95mc\033[38;5;237m[\033[38;5;232m,\033[38;5;16m \033[38;5;224mM\033[38;5;174mh\033[38;5;101mU\033[38;5;238m1\033[38;5;16m            \033[38;5;52mi\033[38;5;181me\033[38;5;224mM\033[38;5;181mf\033[38;5;224mSM\033[38;5;96mL\033[38;5;224mM\033[38;5;16m \033[38;5;235ml\033[38;5;233m,\033[38;5;16m   \033[38;5;247mb\033[38;5;138mp\033[38;5;235mI\033[38;5;237m1\033[38;5;224mW\033[38;5;182mp\033[38;5;138mOd\033[38;5;238mt\033[38;5;95mc\033[38;5;234m;\033[38;5;243mU\033[38;5;138mmmk\033[38;5;181mhgg\033[38;5;217ms\033[38;5;255mB\033[38;5;16m \033[38;5;138mp\033[38;5;95mu\033[38;5;174mp\033[38;5;181mfgo\033[38;5;16m   .    \033[38;5;240mn\033[38;5;95mcU\033[38;5;240mn\033[38;5;16m      \033[38;5;137m0\033[38;5;144mh\033[38;5;131mUc\033[38;5;137mO\033[38;5;152mf\033[38;5;195mM\033[38;5;152mA\033[38;5;188mA\033[38;5;152mAs\033[38;5;188mG\033[38;5;189mSSSS##MMMWMM\033[38;5;253mS\033[38;5;152mA\033[38;5;251mp\033[38;5;250mq\033[38;5;145ma\033[38;5;247mb\033[38;5;248mhh\033[0m");
    $display("\033[38;5;254mM\033[38;5;224mG\033[38;5;225mM#\033[38;5;217mg\033[38;5;174mw\033[38;5;131mu\033[38;5;94mx\033[38;5;95mz\033[38;5;138mp\033[38;5;175mb\033[38;5;139mb\033[38;5;181meo\033[38;5;139mb\033[38;5;138mm0\033[38;5;95mv\033[38;5;238m1\033[38;5;233m:\033[38;5;16m  \033[38;5;181mq\033[38;5;239mj\033[38;5;238mj\033[38;5;235mI\033[38;5;16m          .\033[38;5;95mz\033[38;5;181meq\033[38;5;224mM\033[38;5;225m&\033[38;5;231m@\033[38;5;181mf\033[38;5;224mG\033[38;5;237m[\033[38;5;16m \033[38;5;235mi\033[38;5;16m \033[38;5;235mI\033[38;5;16m \033[38;5;238m1\033[38;5;181mo\033[38;5;237m1\033[38;5;232m.\033[38;5;138mw\033[38;5;224mW\033[38;5;138mpm\033[38;5;95mc\033[38;5;237m[\033[38;5;232m.\033[38;5;238m1\033[38;5;138mwCp\033[38;5;181mqf\033[38;5;217mp\033[38;5;181mf\033[38;5;225m&\033[38;5;243mU\033[38;5;16m \033[38;5;95mcx\033[38;5;174mk\033[38;5;180ma\033[38;5;217mf\033[38;5;180ma\033[38;5;16m       \033[38;5;95muU\033[38;5;137mC\033[38;5;95mX\033[38;5;233m:\033[38;5;16m   \033[38;5;233m:\033[38;5;232m,\033[38;5;235mI\033[38;5;95mY\033[38;5;138mO\033[38;5;174mh\033[38;5;249mo\033[38;5;152mss\033[38;5;189mSSSS\033[38;5;188mG\033[38;5;189mS##MMMMM#SG\033[38;5;152ms\033[38;5;251mp\033[38;5;250mgq\033[38;5;249mo\033[38;5;248mk\033[38;5;247mk\033[38;5;248mkh\033[0m");
    $display("\033[38;5;195m&\033[38;5;254mM\033[38;5;253m#\033[38;5;145mh\033[38;5;95mu\033[38;5;131mC\033[38;5;250mq\033[38;5;225mW\033[38;5;231mB\033[38;5;255m8\033[38;5;224m#\033[38;5;181mqfo\033[38;5;138mpO\033[38;5;95mY\033[38;5;137mC\033[38;5;95mX\033[38;5;16m   \033[38;5;236m?\033[38;5;102m0\033[38;5;244mC\033[38;5;239mx\033[38;5;16m           \033[38;5;234mi\033[38;5;236m?\033[38;5;60mu\033[38;5;235mI\033[38;5;234m;\033[38;5;235ml\033[38;5;236m]\033[38;5;238mt\033[38;5;235mI\033[38;5;16m \033[38;5;234m!\033[38;5;16m.\033[38;5;232m,\033[38;5;233m;\033[38;5;16m \033[38;5;181mo\033[38;5;95mcc\033[38;5;238m1\033[38;5;181mh\033[38;5;144mk\033[38;5;238mt\033[38;5;239mr\033[38;5;235mI\033[38;5;232m.\033[38;5;234m!\033[38;5;138mO\033[38;5;132mC\033[38;5;138mw\033[38;5;95mzY\033[38;5;245m0\033[38;5;240mn\033[38;5;232m,\033[38;5;236m?\033[38;5;16m   . .\033[38;5;237m[\033[38;5;52mI\033[38;5;16m  \033[38;5;232m,\033[38;5;16m   \033[38;5;234m!\033[38;5;138mC\033[38;5;95mU\033[38;5;131mC\033[38;5;234m!\033[38;5;16m   \033[38;5;232m.\033[38;5;242mX\033[38;5;234m!\033[38;5;239mnr\033[38;5;101mL\033[38;5;195mWM\033[38;5;152ms\033[38;5;189m#M##MSS#\033[38;5;188mG\033[38;5;152mpq\033[38;5;146ma\033[38;5;109mp\033[38;5;66m0L\033[38;5;244mC\033[38;5;102m0\033[38;5;245mm\033[38;5;138md\033[38;5;144mbbkk\033[38;5;248mhk\033[0m");
    $display("\033[38;5;195m8&W\033[38;5;189mM\033[38;5;254mW\033[38;5;231m$$@B\033[38;5;255m8\033[38;5;253mS\033[38;5;224mS\033[38;5;188ms\033[38;5;182mf\033[38;5;181mefg\033[38;5;95mY\033[38;5;16m  \033[38;5;232m.\033[38;5;16m  \033[38;5;138mpdw\033[38;5;16m          \033[38;5;95mz\033[38;5;109mw\033[38;5;195mB\033[38;5;74mp\033[38;5;16m  \033[38;5;232m.\033[38;5;16m  \033[38;5;234m!\033[38;5;16m. \033[38;5;236ml\033[38;5;234m!\033[38;5;102mL\033[38;5;16m.\033[38;5;138mw\033[38;5;181moq\033[38;5;249mo\033[38;5;145mh\033[38;5;181me\033[38;5;138m0\033[38;5;95mX\033[38;5;138mw00\033[38;5;174mpp\033[38;5;95mrX\033[38;5;159mSW\033[38;5;16m      \033[38;5;116mf\033[38;5;243mU\033[38;5;237m]\033[38;5;16m.\033[38;5;237m[\033[38;5;235mI\033[38;5;16m  \033[38;5;138mw\033[38;5;16m   \033[38;5;95mYc\033[38;5;131mU\033[38;5;235ml\033[38;5;16m  \033[38;5;235mI\033[38;5;95mc\033[38;5;235mi\033[38;5;236m]\033[38;5;138md\033[38;5;137m0\033[38;5;238m1\033[38;5;102mC\033[38;5;189mGA\033[38;5;146mq\033[38;5;152mgf\033[38;5;146mo\033[38;5;109mhp\033[38;5;66mU\033[38;5;59mu\033[38;5;237m1\033[38;5;235mi\033[38;5;232m,\033[38;5;16m    \033[38;5;235mI\033[38;5;240mu\033[38;5;244mC\033[38;5;246mp\033[38;5;144mb\033[38;5;138mb\033[38;5;247mbkbk\033[0m");
    $display("\033[38;5;253mM\033[38;5;224m#\033[38;5;225mW\033[38;5;231mB@\033[38;5;255m8\033[38;5;254mWW\033[38;5;188mG\033[38;5;182mpg\033[38;5;181mh\033[38;5;248mk\033[38;5;181mo\033[38;5;188ms\033[38;5;224mS\033[38;5;95mz\033[38;5;16m  \033[38;5;239mj\033[38;5;95mu\033[38;5;16m  \033[38;5;59mn\033[38;5;224mM\033[38;5;144mk\033[38;5;16m.    \033[38;5;238mt\033[38;5;237m1\033[38;5;239mr\033[38;5;95mYc\033[38;5;131mzX\033[38;5;139mb\033[38;5;246mp\033[38;5;16m.    \033[38;5;242mz\033[38;5;95mX\033[38;5;236m?\033[38;5;181mopfgf\033[38;5;224mG\033[38;5;255m8\033[38;5;231m$$\033[38;5;254mW\033[38;5;224mMS#\033[38;5;254mW\033[38;5;231mB\033[38;5;224mW\033[38;5;181mf\033[38;5;137mm\033[38;5;181meo\033[38;5;254mW\033[38;5;247mb\033[38;5;234mi\033[38;5;233m:\033[38;5;16m.\033[38;5;233m:\033[38;5;59mx\033[38;5;174mamwk\033[38;5;181me\033[38;5;224mS\033[38;5;138mO\033[38;5;16m \033[38;5;95mu\033[38;5;181mg\033[38;5;235mI\033[38;5;16m \033[38;5;236ml\033[38;5;95mc\033[38;5;131mL\033[38;5;232m,\033[38;5;16m \033[38;5;232m.,\033[38;5;234m!i\033[38;5;16m.\033[38;5;233m:\033[38;5;224mM\033[38;5;237m]\033[38;5;16m \033[38;5;234mi\033[38;5;237m[\033[38;5;234m;\033[38;5;233m:\033[38;5;232m,\033[38;5;16m          \033[38;5;233m,\033[38;5;59mv\033[38;5;138mm\033[38;5;144mb\033[38;5;145ma\033[38;5;181mo\033[38;5;145mo\033[38;5;249mo\033[38;5;145maaoa\033[0m");
    $display("\033[38;5;224mS\033[38;5;225mW\033[38;5;254mW\033[38;5;224mMSSGAAG\033[38;5;181megpfq\033[38;5;236m]\033[38;5;16m \033[38;5;242mX\033[38;5;181mea\033[38;5;144mk\033[38;5;16m   \033[38;5;181mq\033[38;5;224mM\033[38;5;239mr\033[38;5;16m  .\033[38;5;239mr\033[38;5;95mX\033[38;5;132mC\033[38;5;138mC\033[38;5;132mLC\033[38;5;95mzcu\033[38;5;131mY\033[38;5;132m0\033[38;5;138m0O\033[38;5;96mL\033[38;5;131mU\033[38;5;132mC\033[38;5;138md\033[38;5;181ma\033[38;5;139mb\033[38;5;182ms\033[38;5;181mqfff\033[38;5;224m#\033[38;5;225m88\033[38;5;254mW\033[38;5;224mS\033[38;5;218mA\033[38;5;224mGG\033[38;5;254mM\033[38;5;231mBBB\033[38;5;225m#\033[38;5;182mg\033[38;5;181me\033[38;5;224m#\033[38;5;225mW\033[38;5;224mM\033[38;5;218mG\033[38;5;217mgp\033[38;5;211mo\033[38;5;217mqg\033[38;5;218ms\033[38;5;224mSWS\033[38;5;217mf\033[38;5;174mb\033[38;5;181mef\033[38;5;236m]\033[38;5;16m  \033[38;5;95mc\033[38;5;233m;\033[38;5;16m \033[38;5;239mj\033[38;5;137mO\033[38;5;138mb\033[38;5;137mC\033[38;5;238m1\033[38;5;16m \033[38;5;233m,\033[38;5;16m                \033[38;5;235mI\033[38;5;101m0\033[38;5;144mo\033[38;5;181mf\033[38;5;187mgpggggg\033[38;5;250mff\033[0m");
    $display("\033[38;5;224mAAG#\033[38;5;225m&\033[38;5;231m8B@\033[38;5;225m&\033[38;5;188mAGG\033[38;5;249mq\033[38;5;181mo\033[38;5;59mu\033[38;5;236m?\033[38;5;138md\033[38;5;224mM\033[38;5;138mm\033[38;5;242mX\033[38;5;102m0\033[38;5;16m \033[38;5;235mI\033[38;5;242mz\033[38;5;235ml\033[38;5;231m$\033[38;5;138mw\033[38;5;16m \033[38;5;233m,:\033[38;5;238mt\033[38;5;95mz\033[38;5;138mw\033[38;5;174mbb\033[38;5;175ma\033[38;5;174mb\033[38;5;138mpmO0OmOd\033[38;5;181mhoqfoh\033[38;5;174mk\033[38;5;138mk\033[38;5;181map\033[38;5;224mS#G\033[38;5;218msAA\033[38;5;224mS#\033[38;5;225m&\033[38;5;231m$$$@\033[38;5;225m8M\033[38;5;224mMMMSMMMWWW##G\033[38;5;218mA\033[38;5;181mea\033[38;5;174mp\033[38;5;238m1\033[38;5;234m;\033[38;5;16m  \033[38;5;234mi\033[38;5;137mm\033[38;5;181mf\033[38;5;180mh\033[38;5;181mf\033[38;5;224m&\033[38;5;217ms\033[38;5;16m                 \033[38;5;59mv\033[38;5;138md\033[38;5;181mo\033[38;5;187mpppssssAss\033[0m");
    $display("\033[38;5;224mS\033[38;5;254mW\033[38;5;225m&&\033[38;5;254m&\033[38;5;253m##\033[38;5;188mG\033[38;5;181me\033[38;5;188mG\033[38;5;249mo\033[38;5;181mq\033[38;5;182mg\033[38;5;95mX\033[38;5;237m1\033[38;5;246mw\033[38;5;224mG\033[38;5;181mg\033[38;5;138mbm\033[38;5;238mt\033[38;5;16m \033[38;5;233m;\033[38;5;245mO\033[38;5;236ml\033[38;5;223mG\033[38;5;224mM\033[38;5;16m \033[38;5;235mI\033[38;5;16m.\033[38;5;237m[\033[38;5;131mU\033[38;5;138mw\033[38;5;175mh\033[38;5;181moeoeqqqf\033[38;5;217mfpppgf\033[38;5;181mea\033[38;5;174mkb\033[38;5;138mp\033[38;5;174mk\033[38;5;217mf\033[38;5;218mA\033[38;5;224mG\033[38;5;182mp\033[38;5;181mg\033[38;5;182mg\033[38;5;218mpp\033[38;5;224mS#\033[38;5;231mB@$$$$$$@$@B8\033[38;5;224m&WMMS\033[38;5;218mA\033[38;5;217mg\033[38;5;181me\033[38;5;180mh\033[38;5;138md\033[38;5;132mU\033[38;5;95mY\033[38;5;238m1\033[38;5;233m:\033[38;5;137mm\033[38;5;174md\033[38;5;180mh\033[38;5;224mM\033[38;5;231mB\033[38;5;230mB\033[38;5;137m0\033[38;5;16m                \033[38;5;233m,\033[38;5;241mz\033[38;5;138mw\033[38;5;144mh\033[38;5;249me\033[38;5;181meeeq\033[38;5;187mgg\033[38;5;181mgg\033[38;5;187mp\033[0m");
    $display("\033[38;5;182mgf\033[38;5;181mfef\033[38;5;182mg\033[38;5;224mSM\033[38;5;225mM\033[38;5;250mf\033[38;5;188mG\033[38;5;231m$\033[38;5;247mb\033[38;5;240mn\033[38;5;250mf\033[38;5;218ms\033[38;5;181moo\033[38;5;245mO\033[38;5;238mj\033[38;5;232m.\033[38;5;234m!;\033[38;5;16m   \033[38;5;95mz\033[38;5;16m \033[38;5;232m.\033[38;5;233m:,\033[38;5;131mX\033[38;5;138mm\033[38;5;174mka\033[38;5;175ma\033[38;5;181moeq\033[38;5;217mqffffq\033[38;5;181mqqeo\033[38;5;175mh\033[38;5;174mb\033[38;5;138mdd\033[38;5;174mk\033[38;5;217mg\033[38;5;224mGG\033[38;5;181mgqqeq\033[38;5;217mp\033[38;5;224mG#\033[38;5;225mM\033[38;5;231mB@@@@$@BB\033[38;5;255m8\033[38;5;225m&\033[38;5;224m&WM#G\033[38;5;217mpf\033[38;5;181ma\033[38;5;138mdO\033[38;5;101mCL\033[38;5;95mu\033[38;5;131mY\033[38;5;223mA\033[38;5;174mh\033[38;5;180me\033[38;5;224m&\033[38;5;138mp\033[38;5;235mI\033[38;5;16m                 \033[38;5;236m]\033[38;5;95mX\033[38;5;138mm\033[38;5;144mdbddbkhahh\033[38;5;248mh\033[0m");
    $display("\033[38;5;174mk\033[38;5;139mb\033[38;5;249mo\033[38;5;181me\033[38;5;182me\033[38;5;181me\033[38;5;145mh\033[38;5;139mw\033[38;5;243mY\033[38;5;145mk\033[38;5;225m&\033[38;5;145mb\033[38;5;59mv\033[38;5;145mh\033[38;5;251mp\033[38;5;181mqge\033[38;5;102m0\033[38;5;16m \033[38;5;232m.\033[38;5;234m!!\033[38;5;16m      \033[38;5;236m?\033[38;5;16m.\033[38;5;237m[\033[38;5;131mC\033[38;5;174mwkh\033[38;5;175maa\033[38;5;181meeq\033[38;5;217mqq\033[38;5;181mqqqee\033[38;5;175ma\033[38;5;174mb\033[38;5;138mpwp\033[38;5;181mo\033[38;5;217mp\033[38;5;224m#A\033[38;5;181mgoa\033[38;5;174mhh\033[38;5;180ma\033[38;5;181mq\033[38;5;217mp\033[38;5;224mGM\033[38;5;225m&8\033[38;5;231mBBBB8\033[38;5;255m8\033[38;5;225m&\033[38;5;224m&WMS#\033[38;5;218mA\033[38;5;217mg\033[38;5;181mo\033[38;5;174mk\033[38;5;138mwO\033[38;5;101mU\033[38;5;138mw\033[38;5;238mj\033[38;5;16m                       .\033[38;5;240mu\033[38;5;101mL\033[38;5;138md\033[38;5;144mhb\033[38;5;138mw\033[38;5;246mw\033[38;5;144md\033[38;5;138mdd\033[38;5;246mppww\033[0m");
    $display("\033[38;5;225mM#\033[38;5;182mp\033[38;5;181me\033[38;5;182mp\033[38;5;145mk\033[38;5;52ml\033[38;5;16m \033[38;5;239mj\033[38;5;247md\033[38;5;102mC\033[38;5;233m;\033[38;5;238mt\033[38;5;138md\033[38;5;181mf\033[38;5;224mA\033[38;5;182mp\033[38;5;246mw\033[38;5;235mI\033[38;5;16m \033[38;5;17mi\033[38;5;235mI\033[38;5;232m,\033[38;5;16m .\033[38;5;233m,\033[38;5;16m.  \033[38;5;232m,\033[38;5;233m::\033[38;5;95mz\033[38;5;138mm\033[38;5;174mpbk\033[38;5;175mao\033[38;5;181me\033[38;5;217meeq\033[38;5;181mqqeoa\033[38;5;174mb\033[38;5;138mOwO\033[38;5;174mp\033[38;5;181mq\033[38;5;217mp\033[38;5;224mA\033[38;5;217mg\033[38;5;181mqe\033[38;5;180ma\033[38;5;175mh\033[38;5;174mbbb\033[38;5;181maf\033[38;5;218mp\033[38;5;224mG#MW&\033[38;5;225m&&&\033[38;5;224mWWM#GG\033[38;5;217mg\033[38;5;181mqa\033[38;5;138mwO\033[38;5;101mCL\033[38;5;180mh\033[38;5;16m                        \033[38;5;234m!\033[38;5;241mv\033[38;5;102m0\033[38;5;144mkhhbk\033[38;5;145mo\033[38;5;144mahhkbd\033[0m");
    $display("\033[38;5;181me\033[38;5;145ma\033[38;5;249ma\033[38;5;145mh\033[38;5;236m]\033[38;5;16m \033[38;5;233m;\033[38;5;247mb\033[38;5;225m&\033[38;5;252mA\033[38;5;243mU\033[38;5;240mx\033[38;5;238mj\033[38;5;103mO\033[38;5;59mx\033[38;5;237m1\033[38;5;235mi\033[38;5;16m   \033[38;5;233m::\033[38;5;16m         .\033[38;5;237m[\033[38;5;137mC\033[38;5;138mm\033[38;5;174mdb\033[38;5;175mhaa\033[38;5;181moooooeo\033[38;5;174mk\033[38;5;138m0wp\033[38;5;131mL\033[38;5;174mb\033[38;5;217mggp\033[38;5;181mp\033[38;5;217mf\033[38;5;181meo\033[38;5;175mabkk\033[38;5;138md\033[38;5;181mef\033[38;5;217mg\033[38;5;218mp\033[38;5;224mASS##MMM###A\033[38;5;181mga\033[38;5;138mdmO\033[38;5;95mL\033[38;5;174mb\033[38;5;95mu\033[38;5;16m                        \033[38;5;234mi\033[38;5;95mz\033[38;5;102mO\033[38;5;144mhakba\033[38;5;145moaoo\033[38;5;144mahh\033[0m");
    $display("\033[38;5;109mb\033[38;5;116me\033[38;5;159mG\033[38;5;153ms\033[38;5;240mn\033[38;5;235ml\033[38;5;233m;\033[38;5;59mn\033[38;5;145mh\033[38;5;248mk\033[38;5;236m]\033[38;5;238mt\033[38;5;17miI..\033[38;5;16m. ..\033[38;5;233m,\033[38;5;17m!\033[38;5;16m.         \033[38;5;232m,\033[38;5;239mr\033[38;5;137m0\033[38;5;174mwd\033[38;5;175mkhhhha\033[38;5;181maoaa\033[38;5;174mb\033[38;5;95mY\033[38;5;174mb\033[38;5;138mw\033[38;5;137m0\033[38;5;174mh\033[38;5;217mf\033[38;5;224mS\033[38;5;231m@\033[38;5;224mG\033[38;5;181mqeoaoqo\033[38;5;138m0d\033[38;5;181mqqf\033[38;5;217mfg\033[38;5;218mpsAA\033[38;5;224mGSGGA\033[38;5;182mp\033[38;5;181me\033[38;5;138mdwmCp\033[38;5;137mm\033[38;5;16m                         \033[38;5;235ml\033[38;5;95mX\033[38;5;138mm\033[38;5;144mk\033[38;5;248mhh\033[38;5;144mbh\033[38;5;249mooo\033[38;5;145moa\033[38;5;144mhh\033[0m");
    $display("\033[38;5;188msGGG\033[38;5;225mW\033[38;5;231m8\033[38;5;138mp\033[38;5;232m.\033[38;5;17m!i\033[38;5;16m \033[38;5;17m:,i\033[38;5;24m]]\033[38;5;233m,\033[38;5;16m \033[38;5;17m:\033[38;5;232m,.,,\033[38;5;16m          \033[38;5;52mi\033[38;5;239mx\033[38;5;137mC\033[38;5;138mwd\033[38;5;174mkkh\033[38;5;175mh\033[38;5;181mhahh\033[38;5;174mk\033[38;5;138mkm\033[38;5;95mY\033[38;5;138mC\033[38;5;239mj\033[38;5;95mu\033[38;5;138mO\033[38;5;174md\033[38;5;181mea\033[38;5;138mp\033[38;5;95mYuc\033[38;5;138m0d\033[38;5;137mLC\033[38;5;180mk\033[38;5;181moeeeqqqf\033[38;5;217mg\033[38;5;218mg\033[38;5;181mpgffa\033[38;5;138mpwdppp\033[38;5;16m           .\033[38;5;234m;\033[38;5;16m         \033[38;5;233m;\033[38;5;234mi\033[38;5;235mi\033[38;5;16m \033[38;5;237m[\033[38;5;101mC\033[38;5;138mw\033[38;5;248mh\033[38;5;144mhkba\033[38;5;181mqq\033[38;5;144ma\033[38;5;145maaoa\033[0m");
    $display("\033[38;5;217mp\033[38;5;224mAG\033[38;5;188mG\033[38;5;181mqf\033[38;5;242mz\033[38;5;235ml\033[38;5;23ml\033[38;5;17m!\033[38;5;233m:\033[38;5;234m;\033[38;5;24mxr]]\033[38;5;232m,\033[38;5;17mI\033[38;5;232m,\033[38;5;16m .\033[38;5;17m,\033[38;5;232m,\033[38;5;16m          \033[38;5;232m,\033[38;5;237m[\033[38;5;240mx\033[38;5;138mCOwd\033[38;5;174mbkkkkhk\033[38;5;138mb\033[38;5;181mh\033[38;5;138mbm\033[38;5;59mu\033[38;5;240mnx\033[38;5;239mrr\033[38;5;95mrnxX\033[38;5;138mC\033[38;5;95mz\033[38;5;96mU\033[38;5;138mw\033[38;5;181maaaaaaaaaaaooea\033[38;5;138mbppdp\033[38;5;174mb\033[38;5;138mw\033[38;5;16m        \033[38;5;232m,\033[38;5;236m]\033[38;5;16m.\033[38;5;234m;\033[38;5;16m \033[38;5;237m[\033[38;5;233m:\033[38;5;16m   \033[38;5;232m,\033[38;5;16m.\033[38;5;232m,\033[38;5;233m;\033[38;5;238mt\033[38;5;234m;\033[38;5;16m \033[38;5;235mi\033[38;5;232m,\033[38;5;239mr\033[38;5;102mO\033[38;5;138mp\033[38;5;144ma\033[38;5;145ma\033[38;5;144mkkh\033[38;5;249me\033[38;5;144mo\033[38;5;145mo\033[38;5;248mh\033[38;5;145maoa\033[0m");
    $display("\033[38;5;249me\033[38;5;146mq\033[38;5;109mk\033[38;5;240mx\033[38;5;233m:\033[38;5;17mi;;\033[38;5;24m1\033[38;5;236m?\033[38;5;23m1\033[38;5;232m,\033[38;5;24m1x\033[38;5;25mn\033[38;5;24mt\033[38;5;16m.  \033[38;5;233m:\033[38;5;24m[?\033[38;5;16m.           \033[38;5;234mi\033[38;5;95mnuU\033[38;5;138mOmwpdddd\033[38;5;174mkk\033[38;5;144mk\033[38;5;181maea\033[38;5;248mk\033[38;5;138mdw\033[38;5;102mC\033[38;5;95mc\033[38;5;137mC\033[38;5;248mk\033[38;5;180mk\033[38;5;144mk\033[38;5;181maoeahah\033[38;5;180mh\033[38;5;174mkk\033[38;5;138mbkk\033[38;5;174mb\033[38;5;138mbbbdpdpp\033[38;5;181mh\033[38;5;138mp\033[38;5;16m         \033[38;5;238m1\033[38;5;16m \033[38;5;234mi\033[38;5;238m1\033[38;5;233m;\033[38;5;235mi\033[38;5;238mt\033[38;5;237m1\033[38;5;238mj\033[38;5;242mX\033[38;5;237m1\033[38;5;16m.\033[38;5;232m,\033[38;5;233m,:\033[38;5;234mi\033[38;5;236m]\033[38;5;235mI\033[38;5;237m1\033[38;5;243mY\033[38;5;245mm\033[38;5;138mp\033[38;5;247mb\033[38;5;145mh\033[38;5;246mdp\033[38;5;247mb\033[38;5;248mk\033[38;5;144mk\033[38;5;250mq\033[38;5;144mh\033[38;5;145maa\033[38;5;144ma\033[0m");
    $display("\033[38;5;67mCY\033[38;5;24mxt\033[38;5;25mxn\033[38;5;31mvc\033[38;5;61mv\033[38;5;238mt\033[38;5;23m]\033[38;5;17m;i\033[38;5;23ml\033[38;5;232m,\033[38;5;16m  \033[38;5;17m:\033[38;5;24m[t\033[38;5;25mx\033[38;5;17m!\033[38;5;16m             \033[38;5;237m]\033[38;5;95mXc\033[38;5;244mC\033[38;5;138mOOOOmOOd\033[38;5;181mkaeqqqf\033[38;5;224mW\033[38;5;254mM\033[38;5;182mp\033[38;5;181mq\033[38;5;187ms\033[38;5;224mA\033[38;5;181mfgqqeqoeqo\033[38;5;139mb\033[38;5;138mdpdddddppmmd\033[38;5;95mY\033[38;5;16m         .\033[38;5;236ml\033[38;5;235mi\033[38;5;16m. \033[38;5;236m]\033[38;5;16m.  \033[38;5;236m?\033[38;5;234m!\033[38;5;16m    \033[38;5;235mI\033[38;5;233m;\033[38;5;234m!\033[38;5;16m  \033[38;5;95mz\033[38;5;138mmp\033[38;5;144mb\033[38;5;247md\033[38;5;138mpp\033[38;5;247md\033[38;5;144mo\033[38;5;145ma\033[38;5;249mo\033[38;5;144ma\033[38;5;248mh\033[38;5;145maa\033[0m");
    $display("\033[38;5;16m \033[38;5;24ml\033[38;5;17mI;I\033[38;5;23ml?\033[38;5;24ml]\033[38;5;23mI\033[38;5;16m \033[38;5;233m:\033[38;5;16m \033[38;5;234m!\033[38;5;17m!:I\033[38;5;24m1jj]\033[38;5;16m .\033[38;5;17m;\033[38;5;16m.           \033[38;5;237m[\033[38;5;131mY\033[38;5;95mY\033[38;5;138mCOwwm\033[38;5;245m0\033[38;5;95mn\033[38;5;238m1\033[38;5;239mx\033[38;5;95muxx\033[38;5;88mj\033[38;5;124m[]\033[38;5;131muX\033[38;5;167m0\033[38;5;173mw\033[38;5;167mC\033[38;5;131mcucXYYU\033[38;5;138mC\033[38;5;242mY\033[38;5;238mj\033[38;5;235mi\033[38;5;240mn\033[38;5;96mU\033[38;5;138mmpddd\033[38;5;139mb\033[38;5;138mpmmm\033[38;5;95mL\033[38;5;235mI\033[38;5;16m..                      \033[38;5;233m;:\033[38;5;232m.\033[38;5;234mi\033[38;5;95mz\033[38;5;138mw\033[38;5;144mbh\033[38;5;181moe\033[38;5;248ma\033[38;5;144mhh\033[38;5;249meo\033[38;5;145mo\033[38;5;181me\033[38;5;145moaa\033[0m");
    $display("\033[38;5;17m,\033[38;5;24mjt?\033[38;5;17m;:::,:!\033[38;5;23m]\033[38;5;233m:\033[38;5;23m]\033[38;5;24m[\033[38;5;232m.\033[38;5;17mI\033[38;5;24m[t]\033[38;5;233m;\033[38;5;16m \033[38;5;23mI\033[38;5;25mv\033[38;5;24m[\033[38;5;16m          \033[38;5;17m;I\033[38;5;237m]\033[38;5;131mX\033[38;5;137mO\033[38;5;138mOwppp\033[38;5;244mL\033[38;5;95mx\033[38;5;237m[\033[38;5;52m;::\033[38;5;234m!\033[38;5;240mn\033[38;5;238m1\033[38;5;237m[\033[38;5;235ml\033[38;5;52m?]?\033[38;5;237m1\033[38;5;59mx\033[38;5;238mj\033[38;5;237m1\033[38;5;238mj\033[38;5;239mj\033[38;5;234m!\033[38;5;239mx\033[38;5;16m \033[38;5;52m:\033[38;5;88ml\033[38;5;95mc\033[38;5;138m0mwpdbpwOO\033[38;5;95mv\033[38;5;243mU\033[38;5;251ms\033[38;5;188mA\033[38;5;249mq\033[38;5;245mm\033[38;5;241mv\033[38;5;235mI\033[38;5;16m        .\033[38;5;233m::\033[38;5;237m]\033[38;5;240mn\033[38;5;95muXL\033[38;5;137mC\033[38;5;138m0m0mpd\033[38;5;144mk\033[38;5;181maeeee\033[38;5;145ma\033[38;5;144mk\033[38;5;145mo\033[38;5;249meeoo\033[38;5;145mooa\033[0m");
    $display("\033[38;5;24m1rjt[l?][[\033[38;5;17mIi;\033[38;5;234m;\033[38;5;23m?\033[38;5;17mI\033[38;5;25mux\033[38;5;24m1\033[38;5;17m;\033[38;5;232m.\033[38;5;23ml\033[38;5;25mn\033[38;5;31mz\033[38;5;25mv\033[38;5;17m;\033[38;5;16m         \033[38;5;233m:\033[38;5;24m]\033[38;5;17mI\033[38;5;234mi\033[38;5;95mx\033[38;5;137m0\033[38;5;138mwwwmdp\033[38;5;131mU\033[38;5;94mr\033[38;5;124m?]]11\033[38;5;95mz\033[38;5;102m0\033[38;5;103m0\033[38;5;95mczv\033[38;5;241mu\033[38;5;95mv\033[38;5;239mj\033[38;5;95mz\033[38;5;124mj?]]\033[38;5;160mx\033[38;5;131mY\033[38;5;138mOpwpwppw0\033[38;5;95mY\033[38;5;239mrr\033[38;5;188mA\033[38;5;231mB\033[38;5;254mM\033[38;5;253mS\033[38;5;188mG\033[38;5;251mp\033[38;5;144mh\033[38;5;240mn\033[38;5;232m,\033[38;5;16m    .\033[38;5;52m;\033[38;5;58m1\033[38;5;238mt\033[38;5;237m[\033[38;5;137mO\033[38;5;138mmd\033[38;5;144mbh\033[38;5;181maoooeooefqqqeo\033[38;5;145ma\033[38;5;249moeeeeooo\033[0m");
    $display("\033[38;5;24mtj\033[38;5;25mvu\033[38;5;24mrt]l?][tt\033[38;5;25mu\033[38;5;23m1[\033[38;5;24m[\033[38;5;23ml\033[38;5;17m!!\033[38;5;24m1\033[38;5;25mv\033[38;5;67mzU\033[38;5;68mL\033[38;5;23m]\033[38;5;16m          \033[38;5;17m;!i\033[38;5;232m,\033[38;5;237m[\033[38;5;95mv\033[38;5;138mwpOOpw\033[38;5;245mO\033[38;5;95mc\033[38;5;88m]l\033[38;5;124m?\033[38;5;160m11\033[38;5;196mt\033[38;5;160m1\033[38;5;131mY\033[38;5;132m0\033[38;5;131mX\033[38;5;124mx[\033[38;5;160m[1t[\033[38;5;124m]t\033[38;5;131mX\033[38;5;138mO\033[38;5;145mk\033[38;5;138mwwddbp\033[38;5;95mY\033[38;5;239mx\033[38;5;95mxuz\033[38;5;253m#\033[38;5;254m8M\033[38;5;188mSG\033[38;5;251mg\033[38;5;144ma\033[38;5;101m0\033[38;5;94mx\033[38;5;52m[\033[38;5;233m;\033[38;5;16m..\033[38;5;233m,\033[38;5;52mi\033[38;5;237m[\033[38;5;236ml\033[38;5;238mt\033[38;5;137mL0\033[38;5;138mmpd\033[38;5;144mbkh\033[38;5;180maaho\033[38;5;181meqfq\033[38;5;250mq\033[38;5;249meoooeee\033[38;5;145mo\033[38;5;249mooo\033[0m");
    $display("\033[38;5;24mr[1\033[38;5;25mu\033[38;5;31mcc\033[38;5;25muux\033[38;5;24mr[jt\033[38;5;25mx\033[38;5;23m?\033[38;5;24m1]\033[38;5;23mll?\033[38;5;24m]\033[38;5;23mll\033[38;5;24m[j\033[38;5;17m:\033[38;5;16m           \033[38;5;17mi\033[38;5;233m:;\033[38;5;18mI\033[38;5;16m \033[38;5;52mi\033[38;5;95mY\033[38;5;138mdwOw\033[38;5;139mp\033[38;5;138md\033[38;5;247md\033[38;5;244mC\033[38;5;95mu\033[38;5;88m1]\033[38;5;124m??]\033[38;5;160m[\033[38;5;124mnj]]]\033[38;5;88mt\033[38;5;95mv\033[38;5;137mL\033[38;5;246mp\033[38;5;247mb\033[38;5;138mkddb\033[38;5;180mk\033[38;5;181mh\033[38;5;101mL\033[38;5;239mxx\033[38;5;95mcYvY\033[38;5;254mWW\033[38;5;188mGG\033[38;5;251mp\033[38;5;249mo\033[38;5;144mk\033[38;5;101m0\033[38;5;95mYz\033[38;5;94mn\033[38;5;52ml\033[38;5;232m,,\033[38;5;52m!l\033[38;5;234mi\033[38;5;239mr\033[38;5;95mY\033[38;5;101mL\033[38;5;137m0\033[38;5;138mwdk\033[38;5;144mkkh\033[38;5;180mhha\033[38;5;181moeqqq\033[38;5;249mo\033[38;5;145maa\033[38;5;249mo\033[38;5;181mee\033[38;5;249moo\033[38;5;181me\033[38;5;249moo\033[0m");
    $display("\033[38;5;25mxx\033[38;5;24m1t\033[38;5;25mur\033[38;5;24mjt1]\033[38;5;23m??ll\033[38;5;17m;ii!;!i\033[38;5;24mltr\033[38;5;23m?\033[38;5;17m!\033[38;5;232m.\033[38;5;16m         .\033[38;5;17m:\033[38;5;232m,\033[38;5;233m:\033[38;5;17m;\033[38;5;235mI\033[38;5;58m1\033[38;5;52m;\033[38;5;236ml\033[38;5;95mz\033[38;5;138mpwmb\033[38;5;145mh\033[38;5;181ma\033[38;5;249ma\033[38;5;145ma\033[38;5;247mb\033[38;5;246mw\033[38;5;245mmmO\033[38;5;138m0\033[38;5;245m0\033[38;5;138mOO\033[38;5;246mp\033[38;5;247mb\033[38;5;145mk\033[38;5;248mh\033[38;5;181mhah\033[38;5;174mb\033[38;5;175mk\033[38;5;138md\033[38;5;95mU\033[38;5;239mrr\033[38;5;95mX\033[38;5;101mL\033[38;5;95mXzzz\033[38;5;255m8\033[38;5;254m&\033[38;5;188mGG\033[38;5;251mg\033[38;5;145ma\033[38;5;144md\033[38;5;101m0CU\033[38;5;95mY\033[38;5;239mx\033[38;5;232m.,\033[38;5;52m;I\033[38;5;235mi\033[38;5;238mt\033[38;5;95mcX\033[38;5;101mC\033[38;5;138mOwdb\033[38;5;180mkhkha\033[38;5;181moeee\033[38;5;249me\033[38;5;145mo\033[38;5;144mah\033[38;5;145ma\033[38;5;249me\033[38;5;181meee\033[38;5;249mo\033[38;5;144mo\033[38;5;249me\033[0m");
    $display("\033[38;5;24mr\033[38;5;25mnn\033[38;5;24mjt1?\033[38;5;23mI\033[38;5;17m!!i!\033[38;5;23mI\033[38;5;17mI\033[38;5;23mIll\033[38;5;24ml?]j\033[38;5;25mv\033[38;5;24mx\033[38;5;23m?\033[38;5;24mt\033[38;5;67mX\033[38;5;23m[\033[38;5;16m         \033[38;5;17m,\033[38;5;232m.\033[38;5;233m:\033[38;5;17m!;\033[38;5;52m?\033[38;5;95mzX\033[38;5;239mx\033[38;5;235mIl\033[38;5;95mX\033[38;5;138mddbb\033[38;5;181mhahoq\033[38;5;251mg\033[38;5;188mps\033[38;5;182mg\033[38;5;251mg\033[38;5;181mqqeooaooh\033[38;5;95mX\033[38;5;238m1\033[38;5;239mj\033[38;5;95mU\033[38;5;137m00\033[38;5;101mU\033[38;5;95mYY\033[38;5;101mY\033[38;5;95mz\033[38;5;253mS\033[38;5;254m&\033[38;5;253mS\033[38;5;188mA\033[38;5;250mg\033[38;5;144mh\033[38;5;137mO\033[38;5;101m0\033[38;5;137m0\033[38;5;101m0U\033[38;5;95mv\033[38;5;52m;\033[38;5;232m,\033[38;5;52m:!\033[38;5;235mi\033[38;5;58m[\033[38;5;95mncU\033[38;5;137mCm\033[38;5;138mwbbb\033[38;5;180mhkho\033[38;5;181mee\033[38;5;249moo\033[38;5;144mhhk\033[38;5;145mo\033[38;5;181meoeo\033[38;5;249moe\033[38;5;152mg\033[0m");
    $display("\033[38;5;24mr\033[38;5;25mrnxxxnux\033[38;5;24m1\033[38;5;23m?\033[38;5;24m???]?]]r\033[38;5;25mv\033[38;5;61mc\033[38;5;24mj\033[38;5;23m[\033[38;5;25mn\033[38;5;31mz\033[38;5;68mU\033[38;5;67mz\033[38;5;232m.\033[38;5;16m  .     \033[38;5;17m:i\033[38;5;233m;\033[38;5;17mI\033[38;5;235mi\033[38;5;94mt\033[38;5;95mcX\033[38;5;137mL\033[38;5;138mm\033[38;5;95mc\033[38;5;52m!\033[38;5;235mI\033[38;5;95mX\033[38;5;138md\033[38;5;181mh\033[38;5;175mk\033[38;5;181mhooeqqfgfqeeoqge\033[38;5;95mL\033[38;5;237m1\033[38;5;238mj\033[38;5;137mL\033[38;5;138mpp\033[38;5;137mO0C\033[38;5;101mU\033[38;5;137mCC\033[38;5;95mX\033[38;5;181mo\033[38;5;231m$\033[38;5;253mS\033[38;5;188mA\033[38;5;250mf\033[38;5;247mk\033[38;5;101mCUUU\033[38;5;95mc\033[38;5;239mr\033[38;5;52mI\033[38;5;232m,\033[38;5;233m,:\033[38;5;234m;\033[38;5;52m]\033[38;5;94mr\033[38;5;95muz\033[38;5;101mU\033[38;5;137m0O\033[38;5;138mwpdbb\033[38;5;144mk\033[38;5;180mao\033[38;5;249ma\033[38;5;145moo\033[38;5;144mhkka\033[38;5;181meoe\033[38;5;249mo\033[38;5;144mo\033[38;5;250mf\033[38;5;153mG\033[0m");
    $display("\033[38;5;23m1\033[38;5;25mrnnnn\033[38;5;24mrx\033[38;5;25mnu\033[38;5;31mc\033[38;5;25mvv\033[38;5;24mu\033[38;5;25muvuvu\033[38;5;24mr1r\033[38;5;67mcYU\033[38;5;68mL\033[38;5;67mC\033[38;5;23m[\033[38;5;16m.       \033[38;5;17m;\033[38;5;23m]I\033[38;5;17m!\033[38;5;236m?\033[38;5;94mn\033[38;5;95mzX\033[38;5;101mL\033[38;5;137mC\033[38;5;138mp\033[38;5;144mk\033[38;5;95mz\033[38;5;235mii\033[38;5;95mu\033[38;5;138mw\033[38;5;181maqqqeeooeqqqe\033[38;5;138mw\033[38;5;95mu\033[38;5;52m?\033[38;5;237m1\033[38;5;137mC\033[38;5;138mdpwmw\033[38;5;137mmOO0O0C\033[38;5;188mA\033[38;5;253mM\033[38;5;251mp\033[38;5;249me\033[38;5;144md\033[38;5;95mXzzv\033[38;5;94mx\033[38;5;58m1\033[38;5;52mi\033[38;5;232m,\033[38;5;233m,\033[38;5;232m,\033[38;5;52m;l\033[38;5;58m1\033[38;5;94mr\033[38;5;95mvY\033[38;5;101mL\033[38;5;137m0O\033[38;5;138mwpddb\033[38;5;144mk\033[38;5;180ma\033[38;5;144maa\033[38;5;145ma\033[38;5;144mhkk\033[38;5;145ma\033[38;5;181me\033[38;5;249mo\033[38;5;181me\033[38;5;249mo\033[38;5;145mo\033[38;5;249me\033[38;5;188mA\033[0m");
    $display("\033[38;5;109mb\033[38;5;24m?\033[38;5;25mvnuuun\033[38;5;24mxr\033[38;5;25mnv\033[38;5;67mz\033[38;5;31mc\033[38;5;61mc\033[38;5;67mczc\033[38;5;24mu\033[38;5;25mv\033[38;5;67mY\033[38;5;68mLL\033[38;5;67mLU\033[38;5;68mUL\033[38;5;24mr\033[38;5;233m,\033[38;5;17m;\033[38;5;16m.   . \033[38;5;17mi\033[38;5;24m[[\033[38;5;236ml\033[38;5;94mr\033[38;5;95mnXU\033[38;5;101mL\033[38;5;137mC\033[38;5;138m0m\033[38;5;144mbh\033[38;5;101mU\033[38;5;237m]\033[38;5;52m!I\033[38;5;239mj\033[38;5;95mzL\033[38;5;138m0wpO0\033[38;5;95mUu\033[38;5;238m1\033[38;5;236m?l\033[38;5;238mt\033[38;5;137mC\033[38;5;180mh\033[38;5;138mbdpdddww\033[38;5;137mmm0m0m\033[38;5;249ma\033[38;5;248mk\033[38;5;138mw\033[38;5;101mC\033[38;5;95mv\033[38;5;94mu\033[38;5;95mv\033[38;5;94mn\033[38;5;58mj\033[38;5;52m?!\033[38;5;233m,\033[38;5;232m,\033[38;5;233m:\033[38;5;234m;\033[38;5;52mI?\033[38;5;58mt\033[38;5;95mncY\033[38;5;101mL\033[38;5;137mOOm\033[38;5;138mmwpb\033[38;5;145mh\033[38;5;180mh\033[38;5;144mh\033[38;5;145mo\033[38;5;144mhkh\033[38;5;145ma\033[38;5;249mo\033[38;5;145mo\033[38;5;249moo\033[38;5;145ma\033[38;5;144ma\033[38;5;249me\033[0m");
    $display("\033[38;5;231m$\033[38;5;23ml\033[38;5;25mxvnuvunx\033[38;5;24mjtj\033[38;5;25mu\033[38;5;31mc\033[38;5;61mz\033[38;5;67mczYYULLLUU\033[38;5;68mC\033[38;5;61mv\033[38;5;16m.\033[38;5;233m,\033[38;5;24m[\033[38;5;17m;\033[38;5;16m .. .\033[38;5;24ml\033[38;5;23m?\033[38;5;94mnuu\033[38;5;95mXU\033[38;5;137m0O\033[38;5;138mmwpp\033[38;5;144mk\033[38;5;180ma\033[38;5;138mb\033[38;5;95mU\033[38;5;239mx\033[38;5;237m]\033[38;5;52mIIIIII\033[38;5;236m?\033[38;5;238mj\033[38;5;95mY\033[38;5;138md\033[38;5;181meo\033[38;5;144mb\033[38;5;138mdbbdbbddddw\033[38;5;137mmwm\033[38;5;138mpdp\033[38;5;94mcxn\033[38;5;95mvv\033[38;5;94mnr\033[38;5;58m[\033[38;5;52mI;\033[38;5;233m,\033[38;5;16m.\033[38;5;233m:\033[38;5;52m!l[\033[38;5;94mr\033[38;5;95mnzY\033[38;5;137mL00Omw\033[38;5;138md\033[38;5;144mbhh\033[38;5;145maa\033[38;5;144mhh\033[38;5;145ma\033[38;5;249mo\033[38;5;145maaaa\033[38;5;144maa\033[0m");
    $display("\033[38;5;231m$\033[38;5;60mu\033[38;5;24m?\033[38;5;31mc\033[38;5;25muvuuuun\033[38;5;24mx1[1t\033[38;5;25mx\033[38;5;61mv\033[38;5;25mvvv\033[38;5;61mc\033[38;5;67mcXzY\033[38;5;68mL\033[38;5;67mL\033[38;5;24mr\033[38;5;17m!\033[38;5;24m[\033[38;5;25mu\033[38;5;23mI\033[38;5;16m .\033[38;5;232m.\033[38;5;235ml\033[38;5;240mx\033[38;5;94mv\033[38;5;131mz\033[38;5;95mvcY\033[38;5;101mU\033[38;5;137mOO\033[38;5;138mwpdbdpb\033[38;5;144mk\033[38;5;181moqeeoooooeqa\033[38;5;175mk\033[38;5;138mkb\033[38;5;180mhh\033[38;5;144mkk\033[38;5;138mdbbbdpdp\033[38;5;137mwmp\033[38;5;138mp\033[38;5;144mkk\033[38;5;137mC\033[38;5;94mn\033[38;5;58mr\033[38;5;94mnu\033[38;5;95mv\033[38;5;94mx\033[38;5;58m1\033[38;5;52ml;\033[38;5;232m.\033[38;5;52m:;Il\033[38;5;58m1\033[38;5;94mr\033[38;5;95mvzY\033[38;5;137mLC0Om\033[38;5;138mpb\033[38;5;144mkh\033[38;5;145maa\033[38;5;248ma\033[38;5;144mh\033[38;5;145maa\033[38;5;144mhhhhah\033[0m");
    $display("\033[38;5;231m$\033[38;5;108mp\033[38;5;17mi\033[38;5;25muvvvcvuuvn\033[38;5;24mj\033[38;5;23m?\033[38;5;24m[\033[38;5;25mxnv\033[38;5;61mvv\033[38;5;25muv\033[38;5;31mv\033[38;5;67mXY\033[38;5;68mY\033[38;5;31mc\033[38;5;24mn\033[38;5;25mv\033[38;5;24m[t\033[38;5;61mz\033[38;5;242mX\033[38;5;137mC\033[38;5;180mk\033[38;5;173mb\033[38;5;131mCU\033[38;5;95mXXYU\033[38;5;101mL\033[38;5;137m0\033[38;5;138mmwbdbkbbdpddbb\033[38;5;180mhkh\033[38;5;174mkkk\033[38;5;181mh\033[38;5;180ma\033[38;5;144mh\033[38;5;180mhhhhkk\033[38;5;138mb\033[38;5;144mkkk\033[38;5;138mbddw\033[38;5;137mmwp\033[38;5;138mpd\033[38;5;180mh\033[38;5;144mk\033[38;5;101mC\033[38;5;240mx\033[38;5;58mtx\033[38;5;94mnx\033[38;5;58m1\033[38;5;52m!\033[38;5;233m:\033[38;5;52m::;Il\033[38;5;58m1\033[38;5;94mx\033[38;5;95muz\033[38;5;131mY\033[38;5;101mL\033[38;5;137mC0Ow\033[38;5;138md\033[38;5;248mk\033[38;5;144mhhkkkbk\033[38;5;248mh\033[38;5;144mhhhhh\033[0m");
    $display("\033[38;5;231m$\033[38;5;252mA\033[38;5;17mi\033[38;5;24mj\033[38;5;25mv\033[38;5;31mv\033[38;5;25munuvunnxuu\033[38;5;31mcc\033[38;5;25mu\033[38;5;31mvzc\033[38;5;32mzzXzz\033[38;5;61mv\033[38;5;60mz\033[38;5;245mm\033[38;5;138mb\033[38;5;180mh\033[38;5;215mo\033[38;5;180mea\033[38;5;137mm\033[38;5;95mX\033[38;5;131mU\033[38;5;137mL\033[38;5;95mU\033[38;5;101mULL\033[38;5;137m0O\033[38;5;138mmwbd\033[38;5;174mk\033[38;5;180mhk\033[38;5;138mkbdbk\033[38;5;144mk\033[38;5;180mkkhhkk\033[38;5;144mh\033[38;5;180maaaaaaah\033[38;5;144mhk\033[38;5;180mkh\033[38;5;144mkb\033[38;5;138mbbd\033[38;5;137mdmw\033[38;5;174mp\033[38;5;173mppw\033[38;5;180mhh\033[38;5;137mm\033[38;5;95mX\033[38;5;58mrt\033[38;5;52m?\033[38;5;236ml\033[38;5;52m?i;:!I]\033[38;5;94mj\033[38;5;95mxc\033[38;5;131mY\033[38;5;137mL\033[38;5;101mC\033[38;5;137m0Ow\033[38;5;138md\033[38;5;144mbkkkb\033[38;5;246mp\033[38;5;245mm\033[38;5;102mO\033[38;5;245mm\033[38;5;138mppd\033[38;5;144mbk\033[0m");
    $display("\033[38;5;231m$\033[38;5;255m8\033[38;5;23ml\033[38;5;24m1j\033[38;5;25mx\033[38;5;24mjtt1\033[38;5;25mrx\033[38;5;31mv\033[38;5;67mz\033[38;5;25mu\033[38;5;67mz\033[38;5;25mujjnv\033[38;5;67mX\033[38;5;66mYC\033[38;5;245mm\033[38;5;138mp\033[38;5;180mke\033[38;5;216mff\033[38;5;180mq\033[38;5;181mq\033[38;5;180meh\033[38;5;137mwC0OOCCCLO\033[38;5;138mmwddb\033[38;5;180mkhhhhkhkhhahaaha\033[38;5;181maaaa\033[38;5;180ma\033[38;5;181ma\033[38;5;180maahah\033[38;5;144mk\033[38;5;174mk\033[38;5;138mdbbb\033[38;5;174mb\033[38;5;173mdw\033[38;5;174mbb\033[38;5;173md\033[38;5;137mwp\033[38;5;173mp\033[38;5;180mh\033[38;5;181mq\033[38;5;180ma\033[38;5;101mC\033[38;5;237m1\033[38;5;58m][\033[38;5;52mlII!il\033[38;5;58m1\033[38;5;94mr\033[38;5;95muz\033[38;5;131mU\033[38;5;137mL0mm\033[38;5;138mdb\033[38;5;144mkkb\033[38;5;138md\033[38;5;245mO\033[38;5;101mCULL00\033[38;5;102m0\033[38;5;245mO\033[0m");
    $display("\033[38;5;231m$$\033[38;5;23ml\033[38;5;24ml]\033[38;5;188mG\033[38;5;231m$@$@@@$$$\033[38;5;253m#\033[38;5;180maofq\033[38;5;216mfgppgg\033[38;5;181mgffqe\033[38;5;180mak\033[38;5;138mb\033[38;5;137mpmwwwm00O\033[38;5;138mmmpdb\033[38;5;144mk\033[38;5;180mh\033[38;5;144mh\033[38;5;180maaaaah\033[38;5;181mha\033[38;5;180ma\033[38;5;181ma\033[38;5;180maaa\033[38;5;181moo\033[38;5;180maahh\033[38;5;181maaa\033[38;5;180mahh\033[38;5;144mkh\033[38;5;138mbb\033[38;5;144mk\033[38;5;180mk\033[38;5;174mbbb\033[38;5;137md\033[38;5;174mb\033[38;5;180mhohb\033[38;5;138md\033[38;5;180mke\033[38;5;181mee\033[38;5;180mo\033[38;5;101mY\033[38;5;58mt\033[38;5;52mi;!II\033[38;5;58m1\033[38;5;94mx\033[38;5;95muz\033[38;5;131mY\033[38;5;137mCOmm\033[38;5;138mwdbbd\033[38;5;245mm\033[38;5;244mL\033[38;5;95mXv\033[38;5;240mv\033[38;5;95mc\033[38;5;101mULUL\033[0m");
    $display("\033[38;5;253m##\033[38;5;145ma\033[38;5;181me\033[38;5;254m&\033[38;5;231m$$$$$$@@@@\033[38;5;254m&\033[38;5;181mq\033[38;5;223mA\033[38;5;217ms\033[38;5;181mgfqfqqqqqee\033[38;5;180maahk\033[38;5;174mb\033[38;5;138mbddpd\033[38;5;137mmm\033[38;5;138mmwppb\033[38;5;144mbk\033[38;5;180mh\033[38;5;181maoeeaaaoaoo\033[38;5;180ma\033[38;5;181mao\033[38;5;180ma\033[38;5;181maoeoeao\033[38;5;180mh\033[38;5;181ma\033[38;5;180mahh\033[38;5;181mh\033[38;5;180mhkkkhhhk\033[38;5;137mp\033[38;5;173mb\033[38;5;180maeeohhah\033[38;5;181mg\033[38;5;223ms\033[38;5;181mp\033[38;5;138mp\033[38;5;94mn\033[38;5;52m;,\033[38;5;233m:\033[38;5;52m;i?\033[38;5;88m[\033[38;5;94mjxv\033[38;5;131mU\033[38;5;137mOw\033[38;5;138mpdddm\033[38;5;101mU\033[38;5;95mX\033[38;5;241mc\033[38;5;240mu\033[38;5;95mz\033[38;5;101mLCLY\033[0m");
    $display("\033[38;5;224mGG&#\033[38;5;231m$@@BB\033[38;5;195m888\033[38;5;231m@B@\033[38;5;195m&\033[38;5;181megfqqeeqqqeee\033[38;5;180mee\033[38;5;181me\033[38;5;180moohaah\033[38;5;144mk\033[38;5;138mddpppdb\033[38;5;144mkkh\033[38;5;180ma\033[38;5;181moeqqqeeoeooeoaoooeeeeooooa\033[38;5;180maaahhha\033[38;5;181me\033[38;5;180moaeh\033[38;5;174mb\033[38;5;180mheqqaooqe\033[38;5;181mg\033[38;5;223mss\033[38;5;188mG\033[38;5;248mh\033[38;5;138mw\033[38;5;246mww\033[38;5;145ma\033[38;5;249mea\033[38;5;250mf\033[38;5;248mk\033[38;5;138mO\033[38;5;137m0CCOm0\033[38;5;95mX\033[38;5;59mvv\033[38;5;241mv\033[38;5;242mX\033[38;5;101mL\033[38;5;245mO\033[38;5;138mm\033[38;5;101mCL\033[0m");
    $display("\033[38;5;224m#S\033[38;5;252ms\033[38;5;250mg\033[38;5;231m@@@@@\033[38;5;195mB\033[38;5;255m8\033[38;5;195mB\033[38;5;231m@@@\033[38;5;189m#\033[38;5;181me\033[38;5;187ms\033[38;5;181mpggq\033[38;5;180mea\033[38;5;144mk\033[38;5;180maa\033[38;5;181moeeqqqe\033[38;5;180meo\033[38;5;181meo\033[38;5;180mhk\033[38;5;144mk\033[38;5;138mbbbb\033[38;5;144mkh\033[38;5;180mhh\033[38;5;181moeqqqqqqqqfqe\033[38;5;180mao\033[38;5;181mooooeeeqeeeeo\033[38;5;180mho\033[38;5;181mo\033[38;5;180maoooe\033[38;5;181mq\033[38;5;180meoeeoooo\033[38;5;181moee\033[38;5;180me\033[38;5;174mk\033[38;5;181mq\033[38;5;195mB\033[38;5;231m$$$$$$$$$$B\033[38;5;253mM\033[38;5;188ms\033[38;5;181me\033[38;5;180mh\033[38;5;138md\033[38;5;137mO\033[38;5;95mY\033[38;5;59mcvv\033[38;5;241mv\033[38;5;101mY\033[38;5;102m0\033[38;5;101m0\033[38;5;243mU\033[38;5;242mX\033[0m");
    $display("\033[38;5;224m#G\033[38;5;187ms\033[38;5;188mA\033[38;5;231m@@@@@\033[38;5;195mB8@B\033[38;5;231mB@\033[38;5;195mM\033[38;5;181mq\033[38;5;252ms\033[38;5;188ms\033[38;5;181mppgqqo\033[38;5;180moahahao\033[38;5;181mee\033[38;5;180moeoaoa\033[38;5;181mo\033[38;5;180ma\033[38;5;174mk\033[38;5;180mk\033[38;5;181mh\033[38;5;180mah\033[38;5;181mooeqqfggfffffffqeooooeqffqqfffq\033[38;5;180mh\033[38;5;181meq\033[38;5;180maooe\033[38;5;181mqfffqfqq\033[38;5;180meeoho\033[38;5;253mM\033[38;5;231m$$@$$$$$\033[38;5;255m8\033[38;5;188mG\033[38;5;224mSS#MWWWM#\033[38;5;223mG\033[38;5;181mgo\033[38;5;144mb\033[38;5;138mb\033[38;5;144mbkb\033[38;5;245mO\033[38;5;101mY\033[0m");
end endtask

task YOU_FAIL_task; begin
    $display("\033[38;5;234mIIIiiiiIiiiiIiIiIiIiIiIiIiIiIiIiIiIiIiiiIIiiIiI\033[38;5;235mll??\033[38;5;236m][[[[[]\033[38;5;235mlll\033[38;5;234mI\033[38;5;235mIl????????\033[38;5;236m]]][][[]]][[[[[[[[[[[[[[[]][\033[0m");
    $display("\033[38;5;232m:,,,:,:,,,,,:,:,,:,:::::::::::::,:,:::\033[38;5;233m:\033[38;5;232m:,,:,,:\033[38;5;233m:\033[38;5;16m,..,       \033[38;5;233m;\033[38;5;235ml\033[38;5;236m][\033[38;5;235mI\033[38;5;234mII\033[38;5;235mI\033[38;5;234mI\033[38;5;235mI\033[38;5;234mII\033[38;5;235mI\033[38;5;234mI\033[38;5;235mI\033[38;5;234mII\033[38;5;235mIIIII\033[38;5;234miiIiiIIiIiIIIIIiIIIi\033[0m");
    $display("\033[38;5;232m,::,::,:,::::,,::::\033[38;5;233m::::::::::\033[38;5;232m:::,\033[38;5;233m:\033[38;5;232m:\033[38;5;233m:\033[38;5;232m:,:,,\033[38;5;233m:\033[38;5;232m,\033[38;5;16m,..     ... \033[38;5;234miI\033[38;5;236m]1[\033[38;5;237mt\033[38;5;238mr\033[38;5;239mx\033[38;5;237m1\033[38;5;233m!\033[38;5;234mI\033[38;5;236m][[\033[38;5;235m??ll?l????l?lllllllllllllllllll\033[0m");
    $display("\033[38;5;233m:::;;:::;::;;;;:\033[38;5;232m:\033[38;5;233m:\033[38;5;232m::,:,:::,::,:::,\033[38;5;16m.. \033[38;5;232m,\033[38;5;16m,\033[38;5;233m:!\033[38;5;232m:\033[38;5;16m    .   ..\033[38;5;233m:\033[38;5;234mi!\033[38;5;236m[]\033[38;5;235m?\033[38;5;238mj\033[38;5;236m[\033[38;5;232m,\033[38;5;16m   .  .\033[38;5;233m!\033[38;5;235ml\033[38;5;236m]]\033[38;5;235ml??l?l?l?lllllIlllIlIlllllll\033[0m");
    $display("\033[38;5;233m;;;;;;;;;;;;;;;;;:;:;;;:;:;;!;\033[38;5;232m::,\033[38;5;233m;\033[38;5;236m]\033[38;5;234mIIi\033[38;5;233m:\033[38;5;16m      ..\033[38;5;232m:\033[38;5;233m:\033[38;5;16m.   \033[38;5;232m:\033[38;5;234mi\033[38;5;235mI\033[38;5;238mj\033[38;5;237mj\033[38;5;238mx\033[38;5;237mtt\033[38;5;59mn\033[38;5;239mn\033[38;5;234mI\033[38;5;16m      ,\033[38;5;234mi\033[38;5;236m[]\033[38;5;235m]???l?ll?llIlIllllllllllll\033[0m");
    $display("\033[38;5;233m;;;;;;;;;;;;;;;;!!!!\033[38;5;234m!!\033[38;5;233m!;!\033[38;5;234m!Ii\033[38;5;232m:\033[38;5;16m .\033[38;5;232m,\033[38;5;233m:\033[38;5;232m,\033[38;5;16m           \033[38;5;232m:\033[38;5;233m;\033[38;5;234mi\033[38;5;238mr\033[38;5;236m[\033[38;5;235ml\033[38;5;234mi\033[38;5;232m,\033[38;5;16m ..\033[38;5;233m;\033[38;5;237m1\033[38;5;238mjx\033[38;5;237mt\033[38;5;239mn\033[38;5;236m1\033[38;5;237m1\033[38;5;236m]\033[38;5;235ml\033[38;5;233m:\033[38;5;16m.     \033[38;5;233m!\033[38;5;235m?\033[38;5;236m]\033[38;5;235m?llllllllllllIllll\033[38;5;17mllllIl\033[0m");
    $display("\033[38;5;233m;;!!;!;!!\033[38;5;234m!!\033[38;5;233m!;!!!!!\033[38;5;234m!!\033[38;5;233m!\033[38;5;234m!iiII\033[38;5;232m,\033[38;5;16m  \033[38;5;234mi\033[38;5;235m?\033[38;5;233m;\033[38;5;16m  \033[38;5;235m?\033[38;5;238mj\033[38;5;233m:\033[38;5;232m,\033[38;5;233m;:\033[38;5;16m.. . \033[38;5;233m;\033[38;5;235m?\033[38;5;237mt1\033[38;5;238mr\033[38;5;236m[]\033[38;5;238mr\033[38;5;235m?\033[38;5;233m;\033[38;5;16m..\033[38;5;236m]\033[38;5;233m:\033[38;5;235m?\033[38;5;59mu\033[38;5;238mrr\033[38;5;234mI\033[38;5;235mll??\033[38;5;236m]\033[38;5;233m!\033[38;5;16m     \033[38;5;233m:\033[38;5;236m]]\033[38;5;235mlllllllllllllI\033[38;5;17mlllIIllI\033[0m");
    $display("\033[38;5;233m!!!\033[38;5;234m!!\033[38;5;233m!!;!\033[38;5;234mi!!!!!!i!iiii\033[38;5;235ml\033[38;5;234mi\033[38;5;16m. .\033[38;5;232m,\033[38;5;16m.\033[38;5;234mi\033[38;5;16m .\033[38;5;235m?\033[38;5;236m]\033[38;5;237mt\033[38;5;235m?\033[38;5;232m:\033[38;5;16m   \033[38;5;232m,\033[38;5;234mi\033[38;5;232m:\033[38;5;235ml?\033[38;5;234mi\033[38;5;16m \033[38;5;232m,\033[38;5;16m.\033[38;5;235mI\033[38;5;238mj\033[38;5;237m1\033[38;5;234mI\033[38;5;233m;\033[38;5;235mI\033[38;5;233m;;\033[38;5;232m,\033[38;5;16m  \033[38;5;232m:\033[38;5;234mI\033[38;5;236m]\033[38;5;235m]\033[38;5;238mj\033[38;5;237mj\033[38;5;234mi\033[38;5;16m. \033[38;5;233m;\033[38;5;236m]\033[38;5;234mi\033[38;5;16m.    \033[38;5;233m;\033[38;5;236m]]\033[38;5;235mlllllllll\033[38;5;17mllllllllll\033[38;5;18ml\033[0m");
    $display("\033[38;5;233m!!!!!!\033[38;5;234m!i!\033[38;5;233m!!\033[38;5;234m!iiiIiiiiII\033[38;5;232m:\033[38;5;16m .\033[38;5;235ml\033[38;5;236m[\033[38;5;232m:\033[38;5;16m  \033[38;5;233m!\033[38;5;235ml\033[38;5;238mj\033[38;5;16m  ,.    .\033[38;5;235m?\033[38;5;59mu\033[38;5;237m1t\033[38;5;235m?\033[38;5;234mI\033[38;5;235m?\033[38;5;238mrj\033[38;5;237m1\033[38;5;17m;\033[38;5;16m.\033[38;5;236m]]\033[38;5;234mi\033[38;5;17ml\033[38;5;60mx\033[38;5;17ml;\033[38;5;234mi\033[38;5;235m?\033[38;5;238mr\033[38;5;236m]\033[38;5;237mt\033[38;5;238mj\033[38;5;237mt\033[38;5;234mi\033[38;5;16m  \033[38;5;234mi!\033[38;5;16m.     \033[38;5;234mi\033[38;5;236m[\033[38;5;235mllllll\033[38;5;17ml?ll?\033[38;5;18ml?l?ll?l\033[0m");
    $display("\033[38;5;234m!!iii!iiiiiiiiiiiiII\033[38;5;235mI\033[38;5;233m:\033[38;5;16m.\033[38;5;235ml\033[38;5;236m[\033[38;5;16m, \033[38;5;235ml\033[38;5;236m][\033[38;5;235ml\033[38;5;234mI\033[38;5;237m1\033[38;5;232m,\033[38;5;16m  \033[38;5;233m;\033[38;5;232m:\033[38;5;16m    ,\033[38;5;234m!\033[38;5;236m]\033[38;5;238mj\033[38;5;59mn\033[38;5;235m?\033[38;5;234mI\033[38;5;237m1\033[38;5;235m]\033[38;5;16m.\033[38;5;233m:\033[38;5;16m  \033[38;5;232m:\033[38;5;16m \033[38;5;232m,\033[38;5;16m.\033[38;5;233m!\033[38;5;17m]\033[38;5;60mj\033[38;5;17m:\033[38;5;236m]\033[38;5;238mj\033[38;5;16m.\033[38;5;232m,\033[38;5;239mx\033[38;5;60mL\033[38;5;237mt\033[38;5;232m:\033[38;5;16m         \033[38;5;232m,\033[38;5;235m??l?l\033[38;5;17m?l?l\033[38;5;18m??l?ll?l?l\033[0m");
    $display("\033[38;5;234miii!iiiii!iiiiiiiiI\033[38;5;23m?\033[38;5;16m.\033[38;5;232m:\033[38;5;17mI\033[38;5;235ml\033[38;5;16m  .\033[38;5;233m:\033[38;5;232m,\033[38;5;233m!\033[38;5;16m.\033[38;5;234mI!\033[38;5;16m...\033[38;5;232m,\033[38;5;233m:\033[38;5;236m]\033[38;5;233m;\033[38;5;16m.    \033[38;5;17m!\033[38;5;16m.\033[38;5;232m:\033[38;5;238mrj\033[38;5;59mx\033[38;5;16m.           \033[38;5;232m,\033[38;5;237mjt\033[38;5;16m. \033[38;5;233m;\033[38;5;59mu\033[38;5;237mt\033[38;5;16m           \033[38;5;236m][\033[38;5;235mIl\033[38;5;17m?l?\033[38;5;18m??l?l?l?l??\033[0m");
    $display("\033[38;5;234miiiiiiiiiiiiiiiIi\033[38;5;235ml\033[38;5;234mI\033[38;5;16m  \033[38;5;232m:\033[38;5;16m.\033[38;5;235mI\033[38;5;16m   ,\033[38;5;235m?\033[38;5;16m.  \033[38;5;234miI\033[38;5;236m?\033[38;5;233m:\033[38;5;16m..\033[38;5;233m:;\033[38;5;234mI\033[38;5;235ml\033[38;5;234mi\033[38;5;235m?\033[38;5;233m:\033[38;5;16m.\033[38;5;235ml\033[38;5;232m:\033[38;5;16m.\033[38;5;232m,\033[38;5;233m;\033[38;5;235ml?\033[38;5;232m,\033[38;5;16m          .\033[38;5;234m!\033[38;5;233m:;\033[38;5;16m  \033[38;5;235mI\033[38;5;236m]\033[38;5;232m:\033[38;5;16m         \033[38;5;232m,\033[38;5;236m]\033[38;5;17m]ll??\033[38;5;18m??lll?l?lll\033[0m");
    $display("\033[38;5;234miiIiiiiiiIiiiiiiI\033[38;5;233m!\033[38;5;16m  \033[38;5;234mi\033[38;5;232m:\033[38;5;237m1\033[38;5;233m!\033[38;5;16m .\033[38;5;233m;\033[38;5;237mj\033[38;5;138md\033[38;5;234mI\033[38;5;16m \033[38;5;234mi\033[38;5;16m.\033[38;5;239mn\033[38;5;102mO\033[38;5;96mU\033[38;5;234mi\033[38;5;16m \033[38;5;234mI\033[38;5;232m,\033[38;5;233m;\033[38;5;236m[\033[38;5;235ml?\033[38;5;237mt\033[38;5;236m[\033[38;5;235ml\033[38;5;237m1\033[38;5;233m!\033[38;5;16m   \033[38;5;233m;!\033[38;5;16m              \033[38;5;232m,\033[38;5;16m  \033[38;5;233m;\033[38;5;16m,          \033[38;5;232m,\033[38;5;235m?\033[38;5;54m1\033[38;5;17mll\033[38;5;18m??ll?ll?l???\033[0m");
    $display("\033[38;5;234mIiiiIiiIiiiiIiI\033[38;5;235ml\033[38;5;234m!\033[38;5;16m  .,\033[38;5;236m]\033[38;5;237mt\033[38;5;16m.\033[38;5;235ml\033[38;5;237mt\033[38;5;96mLC\033[38;5;139mk\033[38;5;188ms\033[38;5;232m:\033[38;5;237mt11\033[38;5;96mU\033[38;5;182mgq\033[38;5;59mn\033[38;5;236m[\033[38;5;237mt1\033[38;5;236m]\033[38;5;60mn\033[38;5;237m1\033[38;5;235m?\033[38;5;236m[\033[38;5;234m!\033[38;5;16m.\033[38;5;235ml\033[38;5;236m]\033[38;5;233m!\033[38;5;16m.                 .               \033[38;5;59mj\033[38;5;18ml?]?l????l??l?\033[0m");
    $display("\033[38;5;234miIiIiIiiiIiiiIi\033[38;5;235mI\033[38;5;16m    \033[38;5;236m]\033[38;5;60mc\033[38;5;237m1\033[38;5;238mr\033[38;5;182me\033[38;5;243mL\033[38;5;132mC\033[38;5;102m0\033[38;5;145mo\033[38;5;182mq\033[38;5;102mC\033[38;5;16m.\033[38;5;245mm\033[38;5;241mXX\033[38;5;247mk\033[38;5;225mM&\033[38;5;246mp\033[38;5;59mu\033[38;5;235ml\033[38;5;233m!\033[38;5;17m;\033[38;5;235ml\033[38;5;232m,,\033[38;5;233m;\033[38;5;232m,\033[38;5;16m  .\033[38;5;232m:\033[38;5;16m ,               .               .\033[38;5;54m1\033[38;5;18m??l?l?l??l?l?\033[0m");
    $display("\033[38;5;234miiiiiiiIiiiIii\033[38;5;23ml\033[38;5;232m,\033[38;5;16m    \033[38;5;236m]\033[38;5;243mC\033[38;5;59mu\033[38;5;145ma\033[38;5;139mb\033[38;5;96mU\033[38;5;102mO\033[38;5;245mw\033[38;5;182mgge\033[38;5;240mv\033[38;5;238mj\033[38;5;139mb\033[38;5;96mU\033[38;5;102mm\033[38;5;243mC\033[38;5;231mB\033[38;5;225mW\033[38;5;242mL\033[38;5;238mr\033[38;5;16m    . \033[38;5;234mI\033[38;5;237m1\033[38;5;16m                                     \033[38;5;53m]\033[38;5;18m]l????l????l?\033[0m");
    $display("\033[38;5;234mIiIiiIiiiIiiII!\033[38;5;16m     \033[38;5;239mx\033[38;5;95mzX\033[38;5;182mg\033[38;5;242mU\033[38;5;240mu\033[38;5;139mbd\033[38;5;249me\033[38;5;225mSW\033[38;5;139mk\033[38;5;59mc\033[38;5;60mc\033[38;5;103mp\033[38;5;96mL\033[38;5;241mX\033[38;5;96mU\033[38;5;231m@\033[38;5;139mhk\033[38;5;240mv\033[38;5;16m    ,\033[38;5;233m;\033[38;5;234m!\033[38;5;95mz\033[38;5;236m]\033[38;5;16m                                   \033[38;5;233m;\033[38;5;54m[\033[38;5;18m]l???????l?]\033[0m");
    $display("\033[38;5;234mIiiiiiiIiiIiII\033[38;5;16m      \033[38;5;138mw\033[38;5;239mx\033[38;5;139mb\033[38;5;182mq\033[38;5;242mU\033[38;5;96mL\033[38;5;181me\033[38;5;145ma\033[38;5;139mb\033[38;5;182mg\033[38;5;231m$\033[38;5;225mM\033[38;5;139mp\033[38;5;59mu\033[38;5;239mx\033[38;5;139md\033[38;5;96mC\033[38;5;237mt\033[38;5;241mX\033[38;5;225m##\033[38;5;181mf\033[38;5;59mv\033[38;5;16m,   \033[38;5;233m:;\033[38;5;234mi\033[38;5;95mL\033[38;5;138mm\033[38;5;95mv\033[38;5;16m                  .               \033[38;5;235m?\033[38;5;54m]\033[38;5;18m??l??????\033[38;5;54m]\033[38;5;18m]\033[0m");
    $display("\033[38;5;234miIIiIiiiIiii\033[38;5;235ml\033[38;5;234m!\033[38;5;16m     \033[38;5;235m?\033[38;5;95mU\033[38;5;240mv\033[38;5;182mp\033[38;5;246mb\033[38;5;239mn\033[38;5;175mb\033[38;5;139md\033[38;5;138mp\033[38;5;145ma\033[38;5;218ms\033[38;5;231m@$\033[38;5;225m#\033[38;5;139mm\033[38;5;239mn\033[38;5;236m[\033[38;5;138mOw\033[38;5;240mu\033[38;5;236m[\033[38;5;181me\033[38;5;225m88\033[38;5;139md\033[38;5;232m,\033[38;5;16m     .\033[38;5;237mj\033[38;5;174md\033[38;5;175ma\033[38;5;235ml\033[38;5;16m                                 \033[38;5;18m??ll?????]\033[38;5;54m]]\033[0m");
    $display("\033[38;5;234miiiIiIiIiiIiI\033[38;5;16m      \033[38;5;239mn\033[38;5;102m0O\033[38;5;139mbb\033[38;5;237m1\033[38;5;175md\033[38;5;181mq\033[38;5;139md\033[38;5;246md\033[38;5;218mp\033[38;5;225m&\033[38;5;231m$$$\033[38;5;225mM\033[38;5;96mU\033[38;5;236m[\033[38;5;96mY\033[38;5;145me\033[38;5;139md\033[38;5;239mx\033[38;5;95mX\033[38;5;182mf\033[38;5;225m8&\033[38;5;132m0\033[38;5;52mi\033[38;5;16m     \033[38;5;233m:\033[38;5;96mL\033[38;5;138md\033[38;5;239mn\033[38;5;235m?\033[38;5;233m;\033[38;5;16m.            \033[38;5;96mU\033[38;5;235m?\033[38;5;16m               \033[38;5;17m!\033[38;5;54m[\033[38;5;18ml]l?]?]]\033[38;5;54m[[\033[0m");
    $display("\033[38;5;235mI\033[38;5;234mIiiiIiiIii\033[38;5;235ml\033[38;5;233m;\033[38;5;16m      \033[38;5;239mn\033[38;5;102mm\033[38;5;138mw\033[38;5;181me\033[38;5;145ma\033[38;5;59mc\033[38;5;181me\033[38;5;182mAq\033[38;5;139mb\033[38;5;182mf\033[38;5;225mW\033[38;5;231m$$$B\033[38;5;182mp\033[38;5;95mY\033[38;5;232m,\033[38;5;16m \033[38;5;234m!\033[38;5;236m[\033[38;5;235m?\033[38;5;16m.\033[38;5;235ml\033[38;5;96mL\033[38;5;145mo\033[38;5;139mh\033[38;5;95mL\033[38;5;235m?\033[38;5;233m;\033[38;5;16m     \033[38;5;237m1\033[38;5;238mr\033[38;5;233m;\033[38;5;232m:\033[38;5;16m          \033[38;5;52mi\033[38;5;175me\033[38;5;174mh\033[38;5;52ml\033[38;5;16m               ,\033[38;5;54m]\033[38;5;18mll???]?\033[38;5;54m]]]\033[0m");
    $display("\033[38;5;235mI\033[38;5;234mIiiIiIIIIi\033[38;5;235ml\033[38;5;232m:\033[38;5;16m      \033[38;5;96mC\033[38;5;139mk\033[38;5;138mm\033[38;5;145mo\033[38;5;182mp\033[38;5;240mu\033[38;5;175mh\033[38;5;182mp\033[38;5;188mG\033[38;5;139mkb\033[38;5;218ms\033[38;5;176mo\033[38;5;132mO\033[38;5;95mzv\033[38;5;131mc\033[38;5;132mO\033[38;5;175mhe\033[38;5;131mC\033[38;5;239mu\033[38;5;95mvc\033[38;5;235m?\033[38;5;233m;\033[38;5;232m:\033[38;5;233m!\033[38;5;238mr\033[38;5;138mmb\033[38;5;131mL\033[38;5;239mx\033[38;5;235m?\033[38;5;232m,\033[38;5;16m             ,\033[38;5;52m?\033[38;5;131mU\033[38;5;233m:\033[38;5;232m,\033[38;5;168mw\033[38;5;182mp\033[38;5;16m               \033[38;5;232m,\033[38;5;54m]\033[38;5;18ml???]?]?\033[38;5;54m]\033[0m");
    $display("\033[38;5;235mI\033[38;5;234mIIiiiIIIii\033[38;5;23m?\033[38;5;16m.      \033[38;5;95mv\033[38;5;96mU\033[38;5;59mv\033[38;5;175mq\033[38;5;182mq\033[38;5;241mz\033[38;5;175mh\033[38;5;181me\033[38;5;182mq\033[38;5;218mG\033[38;5;102mO\033[38;5;175mh\033[38;5;174mpk\033[38;5;175mo\033[38;5;217mg\033[38;5;218mG\033[38;5;225m&\033[38;5;231mB\033[38;5;225m888\033[38;5;217mp\033[38;5;174mdk\033[38;5;175mh\033[38;5;174mkp\033[38;5;131m00\033[38;5;138md\033[38;5;217mg\033[38;5;224m##\033[38;5;217mp\033[38;5;174mk\033[38;5;131mC\033[38;5;95mv\033[38;5;52m1]?\033[38;5;232m:\033[38;5;16m.   .\033[38;5;232m,\033[38;5;52mi\033[38;5;95mz\033[38;5;131m0\033[38;5;232m:\033[38;5;95mx\033[38;5;168md\033[38;5;219mA\033[38;5;95mc\033[38;5;16m               \033[38;5;18m?]?????]?]\033[0m");
    $display("\033[38;5;235mI\033[38;5;234mIiIIIIIIIi\033[38;5;235ml\033[38;5;16m          \033[38;5;235m?\033[38;5;131mY\033[38;5;234mI\033[38;5;132mO\033[38;5;175mk\033[38;5;182mg\033[38;5;225mG\033[38;5;139mh\033[38;5;138mm\033[38;5;217mf\033[38;5;218ms\033[38;5;219mG\033[38;5;218mG\033[38;5;217mq\033[38;5;95mz\033[38;5;234m!\033[38;5;16m \033[38;5;232m,\033[38;5;16m   \033[38;5;232m,\033[38;5;233m!\033[38;5;52m;\033[38;5;95mx\033[38;5;175ma\033[38;5;219mS\033[38;5;225m888W&8&\033[38;5;224mS\033[38;5;218mA\033[38;5;217msf\033[38;5;131m0\033[38;5;95mv\033[38;5;88mr\033[38;5;52m!lli\033[38;5;95mu\033[38;5;167mO\033[38;5;95mnzX\033[38;5;102mO\033[38;5;168mO\033[38;5;212mf\033[38;5;16m               \033[38;5;232m:\033[38;5;19m]\033[38;5;18m???]\033[38;5;54m]\033[38;5;18m??l\033[0m");
    $display("\033[38;5;235mI\033[38;5;234mIii\033[38;5;235mI\033[38;5;234mIIIIIIi\033[38;5;16m       \033[38;5;233m!\033[38;5;131m0U\033[38;5;238mj\033[38;5;95mn\033[38;5;236m]\033[38;5;95mu\033[38;5;131mY\033[38;5;138mb\033[38;5;225mM\033[38;5;219mG\033[38;5;132mO\033[38;5;138mp\033[38;5;211me\033[38;5;175mo\033[38;5;218mp\033[38;5;238mx\033[38;5;16m \033[38;5;103mm\033[38;5;16m  \033[38;5;233m;\033[38;5;60mz\033[38;5;139mk\033[38;5;89mrx\033[38;5;132mC\033[38;5;182mg\033[38;5;225m8\033[38;5;231m@@B\033[38;5;225m8W\033[38;5;224mMS\033[38;5;218mG\033[38;5;223mA\033[38;5;218mp\033[38;5;217mpf\033[38;5;174md\033[38;5;95mnx\033[38;5;52ml\033[38;5;95mn\033[38;5;131mU\033[38;5;95mv\033[38;5;132mm\033[38;5;218mA\033[38;5;131mU\033[38;5;88m?\033[38;5;124m[\033[38;5;168mm\033[38;5;96mY\033[38;5;218mG\033[38;5;237m1\033[38;5;16m .             \033[38;5;60mt\033[38;5;18m]????]??\033[0m");
    $display("\033[38;5;235mI\033[38;5;234mIIII\033[38;5;235mI\033[38;5;234mIii\033[38;5;235mlI\033[38;5;234m!\033[38;5;16m        \033[38;5;236m]\033[38;5;95mu\033[38;5;237mt\033[38;5;16m \033[38;5;235ml\033[38;5;95mc\033[38;5;131mC\033[38;5;95mu\033[38;5;182ms\033[38;5;231m$\033[38;5;225mW\033[38;5;182mf\033[38;5;218mSg\033[38;5;219mG\033[38;5;236m[\033[38;5;88mj\033[38;5;175ma\033[38;5;174mb\033[38;5;175ma\033[38;5;217mgg\033[38;5;210mk\033[38;5;211mq\033[38;5;225m8\033[38;5;231m$$$$B\033[38;5;225m888W\033[38;5;224m#\033[38;5;218mG\033[38;5;217mApq\033[38;5;174mok\033[38;5;131mY\033[38;5;52m]t\033[38;5;95mv\033[38;5;174mpbb\033[38;5;231m$\033[38;5;138mp\033[38;5;52mi\033[38;5;131mY\033[38;5;218mp\033[38;5;181me\033[38;5;225m8\033[38;5;238mj\033[38;5;16m               \033[38;5;233m;\033[38;5;55m1\033[38;5;18ml?????l\033[0m");
    $display("\033[38;5;235mlII\033[38;5;234mIIIIiI\033[38;5;235mIl\033[38;5;233m;\033[38;5;16m          \033[38;5;238mx\033[38;5;16m.  .\033[38;5;239mx\033[38;5;176me\033[38;5;231m$$$$$B\033[38;5;225mW\033[38;5;218mg\033[38;5;168mp\033[38;5;204mb\033[38;5;210ma\033[38;5;175mao\033[38;5;225m#\033[38;5;231m@8\033[38;5;225m&\033[38;5;231mB\033[38;5;225m8\033[38;5;231mB\033[38;5;225m88&&M\033[38;5;224mS\033[38;5;218mGA\033[38;5;181mpq\033[38;5;174mop\033[38;5;131mO\033[38;5;88mj\033[38;5;95mu\033[38;5;131mU\033[38;5;174mw\033[38;5;131mL\033[38;5;173mw\033[38;5;174mh\033[38;5;52mi\033[38;5;181mo\033[38;5;231m$\033[38;5;224mS\033[38;5;211me\033[38;5;218mp\033[38;5;234mi\033[38;5;16m .              \033[38;5;17mi\033[38;5;18m???]?l?\033[0m");
    $display("\033[38;5;235ml\033[38;5;234mIIIIIIII\033[38;5;235mlI\033[38;5;234mI\033[38;5;16m          \033[38;5;168mp\033[38;5;175md\033[38;5;95mX\033[38;5;131mC\033[38;5;132mCw\033[38;5;231mB$$$$$$$B@\033[38;5;225m8&8\033[38;5;231mB\033[38;5;225m88B8\033[38;5;231m@\033[38;5;225m8B88&W\033[38;5;224m#S\033[38;5;218mG\033[38;5;217mGp\033[38;5;181mf\033[38;5;174maw\033[38;5;131m0\033[38;5;95mz\033[38;5;131mXL0\033[38;5;95mc\033[38;5;174md\033[38;5;217mq\033[38;5;231m@$$\033[38;5;211me\033[38;5;167mC\033[38;5;52m[\033[38;5;16m                  \033[38;5;54m]\033[38;5;18m??????\033[0m");
    $display("\033[38;5;235ml\033[38;5;234mIii\033[38;5;235mI\033[38;5;234mIIII\033[38;5;235mI\033[38;5;234mI\033[38;5;23m?\033[38;5;232m:\033[38;5;16m      .  \033[38;5;167mCU0\033[38;5;211mq\033[38;5;225m&&\033[38;5;231m@$$$$$$$@\033[38;5;225m&&&8B\033[38;5;231mBB@BBB\033[38;5;225m88&WM\033[38;5;224mS\033[38;5;218mGA\033[38;5;217msp\033[38;5;211mq\033[38;5;174mb\033[38;5;132mm\033[38;5;131mLUXX\033[38;5;95mzv\033[38;5;217mp\033[38;5;231m$\033[38;5;217ms\033[38;5;174md\033[38;5;131mz\033[38;5;233m!\033[38;5;16m                    .\033[38;5;18m]??]l?\033[0m");
    $display("\033[38;5;235ml\033[38;5;234mIiIIIIIIII\033[38;5;235mI\033[38;5;234mI\033[38;5;16m        \033[38;5;235ml\033[38;5;231m@\033[38;5;225mM&\033[38;5;231mB\033[38;5;225m&W\033[38;5;231m$$@@$$$$B\033[38;5;225m88&\033[38;5;231mBBB@@@BB\033[38;5;225mB8WM#\033[38;5;219mS\033[38;5;218mA\033[38;5;217mpf\033[38;5;211mo\033[38;5;174mkd\033[38;5;131m0U\033[38;5;95mzuuu\033[38;5;94mr\033[38;5;52m;\033[38;5;16m                          \033[38;5;17mi?l\033[38;5;18m?l?\033[0m");
    $display("\033[38;5;234mIiIiiIiiiiIi\033[38;5;235ml\033[38;5;233m;\033[38;5;16m     . \033[38;5;238mj\033[38;5;231mB\033[38;5;225m#M8&\033[38;5;231mB$$$B\033[38;5;225m88\033[38;5;231mBB\033[38;5;225m888\033[38;5;231mBBBBB@@@B\033[38;5;225m8&M#\033[38;5;218mGsp\033[38;5;217mq\033[38;5;175ma\033[38;5;174mbp\033[38;5;131mCY\033[38;5;95mc\033[38;5;94mx\033[38;5;88mjrt\033[38;5;52m?\033[38;5;232m:\033[38;5;16m                         \033[38;5;232m:\033[38;5;233m!\033[38;5;18m]?][\033[38;5;54m1\033[0m");
    $display("\033[38;5;23mllll?l??????]]\033[38;5;16m.      \033[38;5;96mU\033[38;5;231mB\033[38;5;225mM8\033[38;5;231m@B$$$$$$$$\033[38;5;225m&\033[38;5;219mA\033[38;5;225m#&8\033[38;5;231mBBB\033[38;5;225m8&WMMMW#S\033[38;5;218mGp\033[38;5;211ma\033[38;5;174mk\033[38;5;173mp\033[38;5;167mO\033[38;5;131mLX\033[38;5;95mc\033[38;5;94mx\033[38;5;88mrj\033[38;5;94mr\033[38;5;52m1?i\033[38;5;232m,,\033[38;5;16m.                      \033[38;5;233m;\033[38;5;17m:\033[38;5;237mj\033[38;5;25mxrjr\033[0m");
    $display("\033[38;5;24mtttt1ttttttj\033[38;5;25mj\033[38;5;24m1\033[38;5;17mi\033[38;5;16m      \033[38;5;182mg\033[38;5;231m$\033[38;5;225mW8\033[38;5;231m$\033[38;5;225m#\033[38;5;219mG\033[38;5;225mWM\033[38;5;218mA\033[38;5;175ma\033[38;5;139mp\033[38;5;181me\033[38;5;218ms\033[38;5;211mf\033[38;5;167mC\033[38;5;224mS\033[38;5;225m8#W&M#\033[38;5;218mAAA\033[38;5;224mS\033[38;5;225mW8M\033[38;5;211ma\033[38;5;167m0XYL\033[38;5;131mLLXc\033[38;5;95mu\033[38;5;88mrr\033[38;5;94mrx\033[38;5;52m1]l\033[38;5;232m:\033[38;5;52mi?\033[38;5;16m                      \033[38;5;234m!\033[38;5;17m;\033[38;5;237m1\033[38;5;61mn\033[38;5;25mjxr\033[0m");
    $display("\033[38;5;25mrjrrrrjrrrrrrj\033[38;5;17m;\033[38;5;16m .  . \033[38;5;241mX\033[38;5;231m$\033[38;5;225m&&B&\033[38;5;175mh\033[38;5;168mm\033[38;5;167mmw\033[38;5;130mu\033[38;5;88ml?\033[38;5;124mr\033[38;5;167mU\033[38;5;175ma\033[38;5;231m@\033[38;5;225mM\033[38;5;218mg\033[38;5;175maa\033[38;5;218ms\033[38;5;224mS#\033[38;5;225m8\033[38;5;231mB@@\033[38;5;225m#\033[38;5;175ma\033[38;5;174ma\033[38;5;138md\033[38;5;131mCvzLLXc\033[38;5;94munu\033[38;5;95mvu\033[38;5;88mrt\033[38;5;52m?\033[38;5;232m,\033[38;5;52mi?\033[38;5;16m                       \033[38;5;17m?I\033[38;5;235m?\033[38;5;25mxtx\033[0m");
    $display("\033[38;5;25mjrjjjjrrrjrrtj\033[38;5;17mii\033[38;5;23m?\033[38;5;17m.\033[38;5;16m    \033[38;5;96m0\033[38;5;225m8\033[38;5;219mS\033[38;5;225mW\033[38;5;231mB$\033[38;5;218mG\033[38;5;131mXzzc\033[38;5;218mp\033[38;5;225m&\033[38;5;231mB$$$$$\033[38;5;224mS\033[38;5;131mY\033[38;5;137mw\033[38;5;231m$BBB\033[38;5;218mG\033[38;5;138mw\033[38;5;181mf\033[38;5;218mA\033[38;5;217ms\033[38;5;210me\033[38;5;131mc\033[38;5;130mu\033[38;5;167mLL\033[38;5;131mYzvvvXz\033[38;5;95mu\033[38;5;52mti\033[38;5;232m:\033[38;5;52m]\033[38;5;95mx\033[38;5;16m.                      \033[38;5;232m,\033[38;5;236m[\033[38;5;234mI\033[38;5;60mr\033[38;5;25mj\033[38;5;24m1\033[0m");
    $display("\033[38;5;25mjjjjjjjjjjjr\033[38;5;24m1\033[38;5;25mj\033[38;5;24m]\033[38;5;16m,\033[38;5;23m[\033[38;5;24mj\033[38;5;17m;\033[38;5;16m    \033[38;5;234mI\033[38;5;174md\033[38;5;210mk\033[38;5;181mq\033[38;5;219mG\033[38;5;218mp\033[38;5;174mph\033[38;5;131mC\033[38;5;225m&\033[38;5;231m$$$$B\033[38;5;224mA\033[38;5;175mo\033[38;5;174mp\033[38;5;168mp\033[38;5;132mC\033[38;5;131mY\033[38;5;225mW\033[38;5;231m@\033[38;5;225m&\033[38;5;219mS\033[38;5;167mO\033[38;5;255m8\033[38;5;231mB\033[38;5;181mf\033[38;5;168mp\033[38;5;131mX\033[38;5;124mn\033[38;5;131mY\033[38;5;174md\033[38;5;167mO0\033[38;5;131mCUXYXc\033[38;5;94mx\033[38;5;52m[!?\033[38;5;95mzY\033[38;5;235m?\033[38;5;16m                       \033[38;5;237m1\033[38;5;17m?\033[38;5;235m?\033[38;5;60mj\033[38;5;24m1\033[0m");
    $display("\033[38;5;25mtt\033[38;5;24mj\033[38;5;25mt\033[38;5;24mjtj\033[38;5;25mtjjt\033[38;5;24mj1\033[38;5;25mj\033[38;5;24m1\033[38;5;17m:I\033[38;5;23m[\033[38;5;25m1\033[38;5;233m:\033[38;5;16m    .\033[38;5;217mf\033[38;5;175ma\033[38;5;181mq\033[38;5;218ms\033[38;5;175mo\033[38;5;131mC\033[38;5;211ma\033[38;5;212mq\033[38;5;175ma\033[38;5;167mC\033[38;5;125mur\033[38;5;161mn\033[38;5;167mX\033[38;5;169mm\033[38;5;176mq\033[38;5;219mG\033[38;5;225m&\033[38;5;231m8\033[38;5;225mW&M\033[38;5;217mf\033[38;5;131mL\033[38;5;225mM\033[38;5;224mM\033[38;5;218mGs\033[38;5;174mb\033[38;5;124mu\033[38;5;88mx\033[38;5;167mm\033[38;5;174mbbd\033[38;5;173mp\033[38;5;131mYc\033[38;5;130mvv\033[38;5;88mj\033[38;5;52ml\033[38;5;88mt\033[38;5;131mO\033[38;5;138mp\033[38;5;132m0\033[38;5;239mx\033[38;5;16m     .\033[38;5;232m,\033[38;5;16m                \033[38;5;233m;\033[38;5;237mj\033[38;5;234mI\033[38;5;235m?\033[38;5;24mj\033[0m");
    $display("\033[38;5;24mtttttttttttt1t\033[38;5;25mj\033[38;5;24m1\033[38;5;17mIll\033[38;5;16m.     \033[38;5;231m$\033[38;5;225m8M\033[38;5;231mB$\033[38;5;219mS\033[38;5;95mc\033[38;5;124mx\033[38;5;161mv\033[38;5;167mL\033[38;5;204mp\033[38;5;211ma\033[38;5;218mp\033[38;5;225m#&&8\033[38;5;231m8@B\033[38;5;225mM\033[38;5;224mS\033[38;5;218mg\033[38;5;174mw\033[38;5;225m#M#\033[38;5;181mf\033[38;5;131mX\033[38;5;88mj\033[38;5;124mx\033[38;5;88mj\033[38;5;131m0\033[38;5;175mo\033[38;5;174mk\033[38;5;131mLvv\033[38;5;130mc\033[38;5;94mx\033[38;5;88mt\033[38;5;95mc\033[38;5;174mh\033[38;5;175ma\033[38;5;174mb\033[38;5;138mw\033[38;5;95mY\033[38;5;237mt\033[38;5;16m.    .                 \033[38;5;235mI\033[38;5;237mt\033[38;5;234mi\033[38;5;237mj\033[0m");
    $display("\033[38;5;24mttttttttttt1ttt111[\033[38;5;232m,\033[38;5;16m     \033[38;5;231m$$\033[38;5;224mS\033[38;5;218ms\033[38;5;231m$$\033[38;5;225m#\033[38;5;175mh\033[38;5;218msAA\033[38;5;219mS\033[38;5;225mM&&&&&&&&\033[38;5;219mS\033[38;5;218mA\033[38;5;175mh\033[38;5;231m$$$\033[38;5;218mf\033[38;5;174ma\033[38;5;88m1\033[38;5;124mr\033[38;5;130mnv\033[38;5;167mm\033[38;5;131mL\033[38;5;130mvz\033[38;5;131mX\033[38;5;130mv\033[38;5;88mx\033[38;5;131mC\033[38;5;218mp\033[38;5;182mf\033[38;5;175moa\033[38;5;132mm\033[38;5;96mL\033[38;5;95mvn\033[38;5;16m                       \033[38;5;236m]\033[38;5;235m?\033[38;5;234mI\033[0m");
    $display("\033[38;5;24mt111[1111111[t1][1t\033[38;5;232m,\033[38;5;16m...  \033[38;5;139mb\033[38;5;231m$$\033[38;5;224mS\033[38;5;175mk\033[38;5;182mf\033[38;5;231mB\033[38;5;225m8\033[38;5;218mG\033[38;5;225m#88\033[38;5;231mB\033[38;5;225m88&&WW&&W\033[38;5;211mq\033[38;5;139mk\033[38;5;231m$@@\033[38;5;211mo\033[38;5;225mM\033[38;5;88mj\033[38;5;124mj\033[38;5;167mULU\033[38;5;131mXYU\033[38;5;130mz\033[38;5;94mu\033[38;5;167mO\033[38;5;218mAs\033[38;5;182mq\033[38;5;175meh\033[38;5;138mp\033[38;5;131m0\033[38;5;96mU\033[38;5;132mC\033[38;5;95mv\033[38;5;16m                      \033[38;5;234mI\033[38;5;237mt\033[38;5;236m[\033[0m");
    $display("\033[38;5;24m[[[[[[[[[[[11[[]\033[38;5;23m]\033[38;5;24m]\033[38;5;18m?\033[38;5;233m;\033[38;5;17mI\033[38;5;16m \033[38;5;17m,,\033[38;5;16m.\033[38;5;238mj\033[38;5;231m$$$\033[38;5;218mG\033[38;5;88mj\033[38;5;52m;\033[38;5;168m0\033[38;5;218mG\033[38;5;219mG\033[38;5;225m8\033[38;5;231mBB\033[38;5;225m8888&&88M\033[38;5;174md\033[38;5;255m8\033[38;5;231m$$\033[38;5;225m8M\033[38;5;231m$\033[38;5;174mb\033[38;5;124mj\033[38;5;131mYzzz\033[38;5;130mcv\033[38;5;88mj\033[38;5;167mC\033[38;5;182ms\033[38;5;224mS\033[38;5;218mp\033[38;5;182mf\033[38;5;181me\033[38;5;175makb\033[38;5;139mb\033[38;5;132mO\033[38;5;139md\033[38;5;16m                       \033[38;5;234mi\033[38;5;236m[\033[0m");
    $display("\033[38;5;24m[][]]]]]][][r][[]]\033[38;5;234mI\033[38;5;17ml;\033[38;5;16m   \033[38;5;233m;\033[38;5;234m!\033[38;5;231m$$$$$\033[38;5;189mM\033[38;5;181me\033[38;5;132m0\033[38;5;95mz\033[38;5;132mL\033[38;5;218mp\033[38;5;219mS\033[38;5;225mM&&88&M\033[38;5;219mG\033[38;5;175ma\033[38;5;254m&\033[38;5;231m$$$$@\033[38;5;225m8\033[38;5;181mf\033[38;5;52m!i\033[38;5;88m1jjj]\033[38;5;131mc\033[38;5;175me\033[38;5;225m#\033[38;5;218mAAp\033[38;5;182mf\033[38;5;181mq\033[38;5;175meakb\033[38;5;138mw\033[38;5;237m1\033[38;5;16m                      \033[38;5;233m;\033[38;5;236m[\033[0m");
    $display("\033[38;5;25m[[\033[38;5;24m[[\033[38;5;25m[[[1[[[\033[38;5;24m1[[\033[38;5;25m111\033[38;5;24m1\033[38;5;234mi\033[38;5;18ml\033[38;5;17m!\033[38;5;16m .   \033[38;5;96mC\033[38;5;231m$$$$$$$\033[38;5;182mA\033[38;5;242mU\033[38;5;168mO\033[38;5;211mh\033[38;5;175mh\033[38;5;169md\033[38;5;168mwCw\033[38;5;175mkh\033[38;5;181me\033[38;5;188mG\033[38;5;231m$$$$$$\033[38;5;225m8\033[38;5;218ms\033[38;5;189mM\033[38;5;52mI;\033[38;5;88m][?r\033[38;5;174mb\033[38;5;218mpsSsss\033[38;5;182mf\033[38;5;181mqe\033[38;5;175mo\033[38;5;181me\033[38;5;138mw\033[38;5;95mY\033[38;5;16m                      \033[38;5;232m:\033[38;5;17m]\033[0m");
    $display("\033[38;5;24m11[[[[[[\033[38;5;25m[[1\033[38;5;24m[][]]\033[38;5;25m1\033[38;5;17m!I\033[38;5;18m?\033[38;5;17m;\033[38;5;232m,\033[38;5;16m      \033[38;5;59mv\033[38;5;225m&\033[38;5;231m$$$$$$$$@\033[38;5;255mB8\033[38;5;254m&\033[38;5;255mB\033[38;5;231m@$$$B@$$$$$$$$\033[38;5;95mX\033[38;5;52m;Il\033[38;5;174mp\033[38;5;167m0\033[38;5;174mk\033[38;5;182mg\033[38;5;218mAGAAp\033[38;5;182mfqgp\033[38;5;249me\033[38;5;138md\033[38;5;95mX\033[38;5;16m                      \033[38;5;17m!\033[0m");
    $display("\033[38;5;24m]]]]][[[[[[[][]\033[38;5;25m[1\033[38;5;16m.\033[38;5;17mI\033[38;5;18mI\033[38;5;16m.      \033[38;5;233m;\033[38;5;16m  \033[38;5;236m]\033[38;5;181me\033[38;5;225mW\033[38;5;231m@$$$$$$$$$$$$$$@$$$$$$$$$\033[38;5;139mh\033[38;5;52m;\033[38;5;131mc\033[38;5;167mp0\033[38;5;181mg\033[38;5;225m#\033[38;5;218mAAGAApgA\033[38;5;225m#\033[38;5;182mp\033[38;5;175mh\033[38;5;174mp\033[38;5;96mL\033[38;5;16m,                    \033[38;5;233m;\033[0m");
    $display("\033[38;5;24m[[][[[[[[[][[[[\033[38;5;25mt\033[38;5;17mi!\033[38;5;18m?\033[38;5;17m,\033[38;5;16m       \033[38;5;233m!\033[38;5;234mi\033[38;5;232m,\033[38;5;16m  \033[38;5;235mI\033[38;5;225mW\033[38;5;231m$$$$$$$$$$$$$$@$$$$$$$$$$\033[38;5;139mk\033[38;5;131mY\033[38;5;167mC\033[38;5;182mq\033[38;5;225mM\033[38;5;218ms\033[38;5;182ms\033[38;5;218mpAAAAg\033[38;5;182mf\033[38;5;225m#\033[38;5;218mG\033[38;5;182mf\033[38;5;175maah\033[38;5;59mu\033[38;5;16m                    \033[0m");
    $display("\033[38;5;24m][[[[][[][[[]][1\033[38;5;16m.\033[38;5;18m?\033[38;5;17m;\033[38;5;16m         .,   \033[38;5;233m:\033[38;5;182ms\033[38;5;224mM\033[38;5;218mAG\033[38;5;225mW8\033[38;5;231mB@$$$$$@$@$$$$$$$$\033[38;5;225m&\033[38;5;224mS\033[38;5;137mm\033[38;5;131mY\033[38;5;218mgGGs\033[38;5;182mps\033[38;5;218mGG\033[38;5;225m#M#SMS\033[38;5;182mpf\033[38;5;218mpp\033[38;5;175mb\033[38;5;239mx\033[38;5;16m      .           \033[0m");
    $display("\033[38;5;24m]]]][[][[[[[[[\033[38;5;25m[\033[38;5;18m?\033[38;5;17ml\033[38;5;18ml\033[38;5;16m,         \033[38;5;232m:,\033[38;5;16m     \033[38;5;95mc\033[38;5;209mh\033[38;5;210mae\033[38;5;217mp\033[38;5;224mS\033[38;5;225m&\033[38;5;231mB@$$$$$$$$$$$$$B\033[38;5;225m&\033[38;5;182mp\033[38;5;224mS\033[38;5;138mp\033[38;5;175mk\033[38;5;218ms\033[38;5;225mS\033[38;5;218mGA\033[38;5;182ms\033[38;5;218mG\033[38;5;225mM&B8\033[38;5;231mB\033[38;5;225mWM#M&S\033[38;5;218mg\033[38;5;217mf\033[38;5;132mO\033[38;5;239mn\033[38;5;232m,\033[38;5;16m            . .\033[0m");
    $display("\033[38;5;24m][[[[[[[[[[[][1\033[38;5;18mI]\033[38;5;17m!\033[38;5;16m                  \033[38;5;236m1\033[38;5;131mY\033[38;5;167mm\033[38;5;210ma\033[38;5;216mq\033[38;5;217mfp\033[38;5;218mS\033[38;5;225m&\033[38;5;231m@$@$$$$$$$$$\033[38;5;225m&WM\033[38;5;231mB\033[38;5;224mS\033[38;5;174mk\033[38;5;219mG\033[38;5;218mSGG\033[38;5;219mSG\033[38;5;225mW88\033[38;5;231mBBB\033[38;5;225m8&8\033[38;5;231m@B\033[38;5;225m8\033[38;5;182mg\033[38;5;174mp\033[38;5;132mm\033[38;5;174mp\033[38;5;95mY\033[38;5;237m1\033[38;5;96mL\033[38;5;239mx\033[38;5;16m.          \033[0m");
    $display("\033[38;5;24m]][[[[[[[[][[[\033[38;5;18mlIl\033[38;5;16m.                      \033[38;5;234mi\033[38;5;238mr\033[38;5;131mL\033[38;5;173md\033[38;5;210me\033[38;5;217mg\033[38;5;218mA\033[38;5;225mW8\033[38;5;231mB$$$$$$$\033[38;5;225m8\033[38;5;231m@@$\033[38;5;225m#\033[38;5;131mY\033[38;5;181me\033[38;5;225mM\033[38;5;224mS\033[38;5;219mS\033[38;5;225m#MW\033[38;5;231mB\033[38;5;225mB\033[38;5;231m8@@B@BB@@B\033[38;5;225m#\033[38;5;175ma\033[38;5;174mp\033[38;5;181me\033[38;5;174ma\033[38;5;182mA\033[38;5;231m@$$$B\033[38;5;255m8\033[38;5;231m@\033[38;5;195m&\033[38;5;251ms\033[38;5;249mf\033[38;5;246mb\033[38;5;243mL\033[0m");
    $display("\033[38;5;18m]\033[38;5;24m[[[][[[[[[[]\033[38;5;25m[\033[38;5;17mI:\033[38;5;16m                            \033[38;5;233m!\033[38;5;239mn\033[38;5;174mp\033[38;5;217mp\033[38;5;231m$B@$$$$$$@@$$\033[38;5;218mG\033[38;5;173md\033[38;5;167m0\033[38;5;224mS\033[38;5;225mSMMWM8\033[38;5;231m@B@$$$$$$$$$$\033[38;5;225m8\033[38;5;218mp\033[38;5;175me\033[38;5;131mL\033[38;5;88mxt\033[38;5;95mv\033[38;5;132mO\033[38;5;138mp\033[38;5;175mk\033[38;5;174mbb\033[38;5;218mG\033[38;5;231mB$$\033[0m");
    $display("\033[38;5;18m]\033[38;5;24m][[[[[[[[[[\033[38;5;25m1]\033[38;5;17m!\033[38;5;16m..\033[38;5;232m,\033[38;5;16m.                     .       \033[38;5;181mp\033[38;5;231m$@$$$$$$$BBB\033[38;5;218ms\033[38;5;210me\033[38;5;174mh\033[38;5;175me\033[38;5;225mSWW&MW\033[38;5;231m@$$$$$$$$$$$$$$$$$$\033[38;5;254mW\033[38;5;253m#\033[38;5;188mG\033[38;5;182ms\033[38;5;181mgfe\033[38;5;139mh\033[38;5;145mo\033[38;5;255m8\033[0m");
    $display("\033[38;5;18m[\033[38;5;24m]][][]\033[38;5;18m]?]?\033[38;5;24m]\033[38;5;18m?\033[38;5;17mi\033[38;5;16m. \033[38;5;17m;,\033[38;5;16m,                         .    \033[38;5;231m$$$$$$$$$B\033[38;5;225m&M\033[38;5;217mg\033[38;5;174me\033[38;5;181me\033[38;5;138mw\033[38;5;217mq\033[38;5;218mG\033[38;5;225mW&888\033[38;5;231m$$$$$$$$$$$$$$$$$$$$$$$$$$$\033[38;5;254m&\033[0m");
    $display("\033[38;5;18m???????l?ll?l\033[38;5;16m. \033[38;5;17m,:\033[38;5;16m..                              \033[38;5;255m8\033[38;5;231m$$$$$$$@\033[38;5;225m8#\033[38;5;224mS\033[38;5;217mgAs\033[38;5;88m1\033[38;5;131mc\033[38;5;174mb\033[38;5;218ms\033[38;5;225m&\033[38;5;231mBBB@$$$$$$$$$$$$$$$$@$$$\033[38;5;255mB\033[38;5;253mM\033[38;5;188mG\033[38;5;253mS#\033[38;5;254mWW\033[0m");
    $display("\033[38;5;19m???\033[38;5;18m??\033[38;5;19m??]l\033[38;5;18mll\033[38;5;19m?\033[38;5;17m:\033[38;5;16m.\033[38;5;17m,i,\033[38;5;16m \033[38;5;17m,\033[38;5;16m.                         \033[38;5;95mzv\033[38;5;233m:\033[38;5;235m?\033[38;5;231m$$$$$$$@BB\033[38;5;224mS\033[38;5;217msf\033[38;5;218mG\033[38;5;181mf\033[38;5;52m!I\033[38;5;88mr\033[38;5;175ma\033[38;5;224mS\033[38;5;225m8\033[38;5;231m8\033[38;5;225m8\033[38;5;231m8@$$$$$$$$$$$$$$$$$\033[38;5;224mM\033[38;5;182ms\033[38;5;188mS\033[38;5;254m&\033[38;5;231m$$$$$\033[0m");
    $display("\033[38;5;19ml??\033[38;5;18m?\033[38;5;19m???\033[38;5;18m??\033[38;5;19m?l\033[38;5;18m?\033[38;5;16m..\033[38;5;17m.,,\033[38;5;16m.\033[38;5;17m.\033[38;5;16m.                       \033[38;5;59mn\033[38;5;182mq\033[38;5;139mp\033[38;5;176me\033[38;5;132m0\033[38;5;255m8\033[38;5;231m$$$$$$$$$\033[38;5;225m8\033[38;5;224m#\033[38;5;217mpp\033[38;5;224mW\033[38;5;95mC\033[38;5;52m;?I\033[38;5;174mk\033[38;5;175me\033[38;5;225m888\033[38;5;231mB$$$$$$$$$$$$$$$@\033[38;5;181mf\033[38;5;174ma\033[38;5;224mG\033[38;5;231m$$$$$$$$\033[0m");
    $display("\033[38;5;19m?\033[38;5;18m?l?\033[38;5;19m?]?????\033[38;5;18mi\033[38;5;16m \033[38;5;17m,\033[38;5;16m.\033[38;5;238mj\033[38;5;233m:\033[38;5;16m.                        ,\033[38;5;231m$\033[38;5;182mqf\033[38;5;176mh\033[38;5;181mo\033[38;5;231m$$$$$$$$$\033[38;5;225m8W\033[38;5;218mA\033[38;5;217mp\033[38;5;224mSG\033[38;5;52m!?l\033[38;5;88m1\033[38;5;174ma\033[38;5;219mG\033[38;5;231m@\033[38;5;225mB\033[38;5;231mB$$$$$$$$@$$$$$\033[38;5;254m&\033[38;5;174ma\033[38;5;168mp\033[38;5;217mp\033[38;5;231m$$$$$$$$$$\033[0m");
    $display("\033[38;5;18m????\033[38;5;19m???????\033[38;5;17m,\033[38;5;16m \033[38;5;60mc\033[38;5;224mM\033[38;5;216ms\033[38;5;236m]\033[38;5;16m                         \033[38;5;96mL\033[38;5;231m$\033[38;5;225mW\033[38;5;231m@\033[38;5;225m&\033[38;5;231m$$$$$$$$$@\033[38;5;225m&\033[38;5;224mS\033[38;5;217mpg\033[38;5;255mB\033[38;5;240mu\033[38;5;52m!\033[38;5;88m[]1\033[38;5;217mf\033[38;5;231mB$@$$$$$$$$$$$$$\033[38;5;181ms\033[38;5;173md\033[38;5;174md\033[38;5;217mG\033[38;5;231m$$$$$$$$$$$$\033[0m");
    $display("\033[38;5;18m?????????\033[38;5;19m?\033[38;5;18m:\033[38;5;17m]\033[38;5;138mb\033[38;5;230m@\033[38;5;231m$\033[38;5;95mC\033[38;5;16m.                         \033[38;5;182me\033[38;5;231m$$$B$$$$$$$$$\033[38;5;225m8\033[38;5;224mWG\033[38;5;217mg\033[38;5;224m#\033[38;5;181me\033[38;5;52m;\033[38;5;88m1r1\033[38;5;131mY\033[38;5;225mM\033[38;5;231m$$$$$$$$$\033[38;5;251ms\033[38;5;241mz\033[38;5;239mn\033[38;5;145mo\033[38;5;255mB\033[38;5;174mbb\033[38;5;217ms\033[38;5;231mB$$$$$$$$$$$$$$\033[0m");
    $display("\033[38;5;18m?????l?l\033[38;5;19m]\033[38;5;18m:\033[38;5;59mn\033[38;5;231m$@\033[38;5;224mM\033[38;5;231m$\033[38;5;60mu\033[38;5;16m                         \033[38;5;233m;\033[38;5;231mB@$\033[38;5;225m8\033[38;5;231mB$$$$$$$$B\033[38;5;225m&\033[38;5;224mS\033[38;5;217mGA\033[38;5;224m&\033[38;5;52mt\033[38;5;88m1\033[38;5;94mxx\033[38;5;88m1\033[38;5;211mq\033[38;5;231m@$$$$$$\033[38;5;253m###\033[38;5;242mU\033[38;5;240mv\033[38;5;235ml\033[38;5;131mX\033[38;5;167mC\033[38;5;224mW\033[38;5;231m$$$$$$$$$$$$$$$$$\033[0m");
    $display("\033[38;5;18m?l?l????\033[38;5;19mi\033[38;5;17mi\033[38;5;231m$$\033[38;5;225m&\033[38;5;231mB\033[38;5;225m8\033[38;5;16m                          \033[38;5;176ma\033[38;5;231m$$B\033[38;5;225m&\033[38;5;231m$$$$$$$$@\033[38;5;225m8\033[38;5;224mM\033[38;5;223mG\033[38;5;217ms\033[38;5;224m&\033[38;5;138mb\033[38;5;88m[\033[38;5;130mvu\033[38;5;88m1\033[38;5;167mw\033[38;5;225m&\033[38;5;231m$$$$@$\033[38;5;249mf\033[38;5;236m[\033[38;5;231mB\033[38;5;146mf\033[38;5;138mk\033[38;5;95mU\033[38;5;138mk\033[38;5;255m8\033[38;5;231m$$$$$$$$$$$$$$$$$$$\033[0m");
    $display("\033[38;5;18m???????\033[38;5;19m?\033[38;5;18m:\033[38;5;224m#\033[38;5;231m$@@$\033[38;5;59mu\033[38;5;16m \033[38;5;96mY\033[38;5;16m                       \033[38;5;95mu\033[38;5;231m$@$\033[38;5;225mW\033[38;5;231m$$$$$$$$$B\033[38;5;225m&\033[38;5;224m#\033[38;5;217mG\033[38;5;223mS\033[38;5;224mW\033[38;5;94mx\033[38;5;130mnv\033[38;5;124mj\033[38;5;130mu\033[38;5;225mM\033[38;5;231m$$$$$$$@\033[38;5;188mG\033[38;5;255m8\033[38;5;95mU\033[38;5;138md\033[38;5;253mM\033[38;5;231m$$$$$\033[38;5;255m8\033[38;5;231mB$$$$$$$$$$$$$$\033[0m");
    $display("\033[38;5;18m?l???l]\033[38;5;19m!\033[38;5;237m1\033[38;5;231m$$$$\033[38;5;225mW\033[38;5;16m \033[38;5;102mm\033[38;5;235m?\033[38;5;16m                      \033[38;5;233m;\033[38;5;225m#\033[38;5;231m$$BB$$$$$$$$@\033[38;5;225m8W\033[38;5;224mS\033[38;5;217mA\033[38;5;231m@\033[38;5;144mh\033[38;5;88m1\033[38;5;130mun\033[38;5;88m1\033[38;5;217mf\033[38;5;231m$$$$$$$$$$\033[38;5;250mg\033[38;5;188mA\033[38;5;231m$$$$@\033[38;5;224m&W\033[38;5;255mB\033[38;5;231m$$$$$$$$$$$$$$$\033[0m");
    $display("\033[38;5;18m???l??\033[38;5;19m?\033[38;5;17m,\033[38;5;251ms\033[38;5;231m$$$$\033[38;5;16m.\033[38;5;235m?\033[38;5;139md\033[38;5;16m                 ..   \033[38;5;232m:\033[38;5;132mC\033[38;5;231m$$$\033[38;5;225m&\033[38;5;231m$$$$$$$$@\033[38;5;225m8W\033[38;5;224m#\033[38;5;223mG\033[38;5;224mM\033[38;5;231mB\033[38;5;88m1\033[38;5;124mr\033[38;5;130mv\033[38;5;88m1\033[38;5;167mm\033[38;5;231m@$$$$$$$$$\033[38;5;253mMW\033[38;5;231m$$$$$@@$$$$$$$$$$$$$$$$$\033[0m");
    $display("\033[38;5;18m?l??lli\033[38;5;17ml\033[38;5;231m$$$$\033[38;5;139md\033[38;5;16m \033[38;5;181ma\033[38;5;234mI\033[38;5;233m;\033[38;5;16m       .   . . .. . .\033[38;5;132mL\033[38;5;225mW\033[38;5;231m$$\033[38;5;225m&\033[38;5;231mB$$$$$$$$@\033[38;5;225m8\033[38;5;224mMS\033[38;5;223mG\033[38;5;231m$\033[38;5;138mb\033[38;5;88m?\033[38;5;130mn\033[38;5;88m]\033[38;5;124mn\033[38;5;225mW\033[38;5;231m$$$$$$$$$$\033[38;5;224m#\033[38;5;231mB$$$$$$$$$$$$$$@$$$$$$$$B\033[0m");
    $display("\033[38;5;18m??l?l\033[38;5;19m?\033[38;5;17m,\033[38;5;188mA\033[38;5;231m$@$\033[38;5;225m8\033[38;5;16m \033[38;5;234mI\033[38;5;239mn\033[38;5;235ml?\033[38;5;16m     .\033[38;5;232m,\033[38;5;16m  .\033[38;5;17m!,\033[38;5;16m.\033[38;5;17m,,\033[38;5;16m...\033[38;5;232m,,\033[38;5;89mx\033[38;5;176me\033[38;5;231m$$B\033[38;5;225m8\033[38;5;231m$$$$$$$$@\033[38;5;225m8\033[38;5;224mWM\033[38;5;217mG\033[38;5;224m#M\033[38;5;52mI\033[38;5;88m][\033[38;5;131mL\033[38;5;254m&\033[38;5;231m$$$$$$$$$$$\033[38;5;254m&\033[38;5;224mM\033[38;5;231m$$$$$$$$$$$$$$@$$$$$$@@\033[38;5;225m8\033[0m");
    $display("\033[38;5;18ml??l\033[38;5;19ml\033[38;5;18m;]\033[38;5;231m$B@$\033[38;5;232m,\033[38;5;16m \033[38;5;59mv\033[38;5;16m \033[38;5;237m1\033[38;5;16m      \033[38;5;234mi\033[38;5;235ml\033[38;5;16m  .\033[38;5;232m,\033[38;5;16m \033[38;5;17m.,\033[38;5;16m.  . \033[38;5;52m]\033[38;5;132mO\033[38;5;225mM\033[38;5;231m$$\033[38;5;225m&\033[38;5;231m$$$$$$$$@@\033[38;5;225m8\033[38;5;224mW#\033[38;5;217mA\033[38;5;231m@\033[38;5;95mX\033[38;5;88m1\033[38;5;138md\033[38;5;224mS\033[38;5;231m$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$B\033[38;5;225mB&W\033[0m");
    $display("\033[38;5;18m?l??\033[38;5;19m]\033[38;5;17m:\033[38;5;188mA\033[38;5;231m$B$\033[38;5;243mL\033[38;5;16m \033[38;5;139mb\033[38;5;234mI\033[38;5;95mX\033[38;5;237m1\033[38;5;16m   \033[38;5;17m:,\033[38;5;16m        .    \033[38;5;235m?\033[38;5;182mp\033[38;5;139md\033[38;5;175mh\033[38;5;231m@$\033[38;5;225m&\033[38;5;231m$$$$$$$$@@B\033[38;5;225m&\033[38;5;224mMS#S\033[38;5;138mm\033[38;5;181ms\033[38;5;217mg\033[38;5;182mp\033[38;5;225m&\033[38;5;231m$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$@\033[38;5;225m8&&M\033[38;5;224m#\033[0m");
    $display("\033[38;5;18m??l?!\033[38;5;17mI\033[38;5;231m$@$$\033[38;5;233m;\033[38;5;145ma\033[38;5;236m]\033[38;5;241mz\033[38;5;217mg\033[38;5;16m   \033[38;5;17m,:\033[38;5;16m             .\033[38;5;225m&\033[38;5;231m$$$$\033[38;5;225m8\033[38;5;231m@$$$$$$$$@@\033[38;5;225m8\033[38;5;224mWM\033[38;5;217mG\033[38;5;224mW\033[38;5;138mbp\033[38;5;131mOC\033[38;5;182mq\033[38;5;231m$$$$$$$$$$$$$$$$$$$$$$$$$$$$$@\033[38;5;225m888&&WM\033[38;5;224m#\033[38;5;218mA\033[0m");
    $display("\033[38;5;18ml?l\033[38;5;19m?\033[38;5;17m:\033[38;5;139mh\033[38;5;231m$B$\033[38;5;102m0\033[38;5;239mx\033[38;5;59mc\033[38;5;233m;\033[38;5;231mB\033[38;5;95mX\033[38;5;16m   \033[38;5;17m.\033[38;5;16m.            \033[38;5;17m,\033[38;5;140mk\033[38;5;231m$$$$@B$$$$$$$$$@8\033[38;5;225m&W\033[38;5;223mS\033[38;5;224mS\033[38;5;181ms\033[38;5;95mv\033[38;5;131mO0\033[38;5;168mw\033[38;5;231mB$$$$$$$$$$$$$$$$$$$$$$$$$$$@B\033[38;5;225m88W&&W#\033[38;5;218mSA\033[38;5;182mp\033[0m");
    $display("\033[38;5;18ml?l\033[38;5;19m?\033[38;5;17m,\033[38;5;255m8\033[38;5;231m$B$\033[38;5;237m1\033[38;5;59mu\033[38;5;16m \033[38;5;145ma\033[38;5;225m&\033[38;5;233m:\033[38;5;16m     \033[38;5;234mI\033[38;5;233m;\033[38;5;16m       .\033[38;5;237m1\033[38;5;97mL\033[38;5;189mG\033[38;5;231m$$$$@B$$$$$$$$$@B\033[38;5;225m8&\033[38;5;224mW\033[38;5;223mG\033[38;5;224mM\033[38;5;138mb\033[38;5;131mL\033[38;5;174mw\033[38;5;131mO\033[38;5;175ma\033[38;5;231m$$$$$$$$$$$$$$$$$$$$$$$$$$$$$B\033[38;5;225m&&WW#\033[38;5;224mS\033[38;5;218mSA\033[38;5;217mg\033[38;5;181me\033[0m");
    $display("\033[38;5;18m?l]!\033[38;5;23m[\033[38;5;231m$\033[38;5;225m8\033[38;5;231m$\033[38;5;181me\033[38;5;241mz\033[38;5;238mj\033[38;5;233m!\033[38;5;218mp\033[38;5;95mc\033[38;5;16m     \033[38;5;233m!\033[38;5;60mu\033[38;5;236m]\033[38;5;16m.    \033[38;5;232m,\033[38;5;60mr\033[38;5;103m0\033[38;5;189mW\033[38;5;231m$$$$$$\033[38;5;225mW\033[38;5;231m$$$$$$$$$$@B\033[38;5;225mB\033[38;5;224m&M\033[38;5;223mG\033[38;5;224m#\033[38;5;132mO\033[38;5;131mO\033[38;5;167mm\033[38;5;131m0\033[38;5;225mM\033[38;5;231m$$$$$$$$$$$$$$$$$$$$$$$$$$@@B\033[38;5;225m88&\033[38;5;224m##\033[38;5;218mSApg\033[38;5;181mq\033[38;5;175ma\033[0m");
    $display("\033[38;5;18ml??:\033[38;5;103m0\033[38;5;231m$\033[38;5;225m8\033[38;5;231m$\033[38;5;145mo\033[38;5;95mX\033[38;5;138mO\033[38;5;237m1\033[38;5;138mw\033[38;5;96mL\033[38;5;16m   \033[38;5;232m,\033[38;5;52m1\033[38;5;60mnv\033[38;5;236m]\033[38;5;61mv\033[38;5;17m.\033[38;5;16m  \033[38;5;232m:\033[38;5;146ma\033[38;5;225m8\033[38;5;231m$$$$$$$@B$$$$$$$$$$@8\033[38;5;255m8\033[38;5;224m&#\033[38;5;223mGG\033[38;5;168mw\033[38;5;174md\033[38;5;131mO\033[38;5;168mw\033[38;5;225m&\033[38;5;231m$$$$$$$$$$$$$$$$$$$$$$$$BBB\033[38;5;225m&&&&#\033[38;5;224m#\033[38;5;218mSs\033[38;5;217mf\033[38;5;181mq\033[38;5;175ma\033[38;5;174mkp\033[0m");
    $display("\033[38;5;18m?l\033[38;5;19m?\033[38;5;18m:\033[38;5;182mp\033[38;5;231m$B@\033[38;5;181me\033[38;5;96mY\033[38;5;139mb\033[38;5;234mi\033[38;5;225mW\033[38;5;16m,  \033[38;5;238mj\033[38;5;94mn\033[38;5;95mn\033[38;5;104mm\033[38;5;60mczu\033[38;5;17m?\033[38;5;237m1\033[38;5;139mb\033[38;5;231mB$$$$$$$$$\033[38;5;225m&\033[38;5;231m$$$$$$$$$$@@B\033[38;5;255m8\033[38;5;224m&##\033[38;5;137mw\033[38;5;131mU\033[38;5;167mm\033[38;5;130mv\033[38;5;131mO\033[38;5;225m8\033[38;5;231m$$$$$$$$$$$$$$$$$$$$@@BB\033[38;5;225mB8&W\033[38;5;224mM#\033[38;5;218mSGs\033[38;5;217mg\033[38;5;181me\033[38;5;175ma\033[38;5;174mkw\033[38;5;131mOL\033[0m");
    $display("\033[38;5;18ml?\033[38;5;19m?\033[38;5;17m:\033[38;5;224m&\033[38;5;231m@\033[38;5;225m8\033[38;5;231m@\033[38;5;225m8\033[38;5;181me\033[38;5;182ms\033[38;5;139mb\033[38;5;95mX\033[38;5;16m  \033[38;5;236m[\033[38;5;217mg\033[38;5;130mu\033[38;5;95mv\033[38;5;103mm\033[38;5;67mC\033[38;5;146mfo\033[38;5;231m$$$$$$$$$$$$\033[38;5;225m88\033[38;5;231m$$$$$$$$$$$@\033[38;5;255mB\033[38;5;224m&&\033[38;5;223m#S\033[38;5;131mLcX\033[38;5;138mk\033[38;5;231m$$$$$$$$$$$$$$$$$$$@@B\033[38;5;225m88&&WW#\033[38;5;218mSGAp\033[38;5;217mp\033[38;5;181mq\033[38;5;175moh\033[38;5;174mb\033[38;5;131mOLY\033[38;5;95mc\033[0m");

end endtask

endprogram