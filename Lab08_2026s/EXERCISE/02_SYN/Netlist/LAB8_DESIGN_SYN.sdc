###################################################################

# Created by write_sdc on Mon May  4 13:06:50 2026

###################################################################
set sdc_version 2.1

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA
set_load -pin_load 0.05 [get_ports out_valid]
set_load -pin_load 0.05 [get_ports {out_data[11]}]
set_load -pin_load 0.05 [get_ports {out_data[10]}]
set_load -pin_load 0.05 [get_ports {out_data[9]}]
set_load -pin_load 0.05 [get_ports {out_data[8]}]
set_load -pin_load 0.05 [get_ports {out_data[7]}]
set_load -pin_load 0.05 [get_ports {out_data[6]}]
set_load -pin_load 0.05 [get_ports {out_data[5]}]
set_load -pin_load 0.05 [get_ports {out_data[4]}]
set_load -pin_load 0.05 [get_ports {out_data[3]}]
set_load -pin_load 0.05 [get_ports {out_data[2]}]
set_load -pin_load 0.05 [get_ports {out_data[1]}]
set_load -pin_load 0.05 [get_ports {out_data[0]}]
create_clock [get_ports clk]  -period 15  -waveform {0 7.5}
set_max_delay 15  -from [list [get_ports clk] [get_ports rst_n] [get_ports in_valid] [get_ports \
{in_data[7]}] [get_ports {in_data[6]}] [get_ports {in_data[5]}] [get_ports     \
{in_data[4]}] [get_ports {in_data[3]}] [get_ports {in_data[2]}] [get_ports     \
{in_data[1]}] [get_ports {in_data[0]}] [get_ports cg_en]]  -to [list [get_ports out_valid] [get_ports {out_data[11]}] [get_ports         \
{out_data[10]}] [get_ports {out_data[9]}] [get_ports {out_data[8]}] [get_ports \
{out_data[7]}] [get_ports {out_data[6]}] [get_ports {out_data[5]}] [get_ports  \
{out_data[4]}] [get_ports {out_data[3]}] [get_ports {out_data[2]}] [get_ports  \
{out_data[1]}] [get_ports {out_data[0]}]]
set_false_path   -from [get_clocks clk]  -to [list [get_cells GATED_Xreg/latch_or_sleep_reg] [get_cells                \
GATED_psum/latch_or_sleep_reg] [get_cells                                      \
GATED_B_FLAT_15__GATED_B_elem/latch_or_sleep_reg] [get_cells                   \
GATED_B_FLAT_14__GATED_B_elem/latch_or_sleep_reg] [get_cells                   \
GATED_B_FLAT_13__GATED_B_elem/latch_or_sleep_reg] [get_cells                   \
GATED_B_FLAT_12__GATED_B_elem/latch_or_sleep_reg] [get_cells                   \
GATED_B_FLAT_11__GATED_B_elem/latch_or_sleep_reg] [get_cells                   \
GATED_B_FLAT_10__GATED_B_elem/latch_or_sleep_reg] [get_cells                   \
GATED_B_FLAT_9__GATED_B_elem/latch_or_sleep_reg] [get_cells                    \
GATED_B_FLAT_8__GATED_B_elem/latch_or_sleep_reg] [get_cells                    \
GATED_B_FLAT_7__GATED_B_elem/latch_or_sleep_reg] [get_cells                    \
GATED_B_FLAT_6__GATED_B_elem/latch_or_sleep_reg] [get_cells                    \
GATED_B_FLAT_5__GATED_B_elem/latch_or_sleep_reg] [get_cells                    \
GATED_B_FLAT_4__GATED_B_elem/latch_or_sleep_reg] [get_cells                    \
GATED_B_FLAT_3__GATED_B_elem/latch_or_sleep_reg] [get_cells                    \
GATED_B_FLAT_2__GATED_B_elem/latch_or_sleep_reg] [get_cells                    \
GATED_B_FLAT_1__GATED_B_elem/latch_or_sleep_reg] [get_cells                    \
GATED_B_FLAT_0__GATED_B_elem/latch_or_sleep_reg] [get_cells                    \
GATED_A_FLAT_15__GATED_A_elem/latch_or_sleep_reg] [get_cells                   \
GATED_A_FLAT_14__GATED_A_elem/latch_or_sleep_reg] [get_cells                   \
GATED_A_FLAT_13__GATED_A_elem/latch_or_sleep_reg] [get_cells                   \
GATED_A_FLAT_12__GATED_A_elem/latch_or_sleep_reg] [get_cells                   \
GATED_A_FLAT_11__GATED_A_elem/latch_or_sleep_reg] [get_cells                   \
GATED_A_FLAT_10__GATED_A_elem/latch_or_sleep_reg] [get_cells                   \
GATED_A_FLAT_9__GATED_A_elem/latch_or_sleep_reg] [get_cells                    \
GATED_A_FLAT_8__GATED_A_elem/latch_or_sleep_reg] [get_cells                    \
GATED_A_FLAT_7__GATED_A_elem/latch_or_sleep_reg] [get_cells                    \
GATED_A_FLAT_6__GATED_A_elem/latch_or_sleep_reg] [get_cells                    \
GATED_A_FLAT_5__GATED_A_elem/latch_or_sleep_reg] [get_cells                    \
GATED_A_FLAT_4__GATED_A_elem/latch_or_sleep_reg] [get_cells                    \
GATED_A_FLAT_3__GATED_A_elem/latch_or_sleep_reg] [get_cells                    \
GATED_A_FLAT_2__GATED_A_elem/latch_or_sleep_reg] [get_cells                    \
GATED_A_FLAT_1__GATED_A_elem/latch_or_sleep_reg] [get_cells                    \
GATED_A_FLAT_0__GATED_A_elem/latch_or_sleep_reg] [get_cells                    \
GATED_numbuf/latch_or_sleep_reg]]
set_input_delay -clock clk  0  [get_ports clk]
set_input_delay -clock clk  0  [get_ports rst_n]
set_input_delay -clock clk  7.5  [get_ports in_valid]
set_input_delay -clock clk  7.5  [get_ports {in_data[7]}]
set_input_delay -clock clk  7.5  [get_ports {in_data[6]}]
set_input_delay -clock clk  7.5  [get_ports {in_data[5]}]
set_input_delay -clock clk  7.5  [get_ports {in_data[4]}]
set_input_delay -clock clk  7.5  [get_ports {in_data[3]}]
set_input_delay -clock clk  7.5  [get_ports {in_data[2]}]
set_input_delay -clock clk  7.5  [get_ports {in_data[1]}]
set_input_delay -clock clk  7.5  [get_ports {in_data[0]}]
set_input_delay -clock clk  0  [get_ports cg_en]
set_output_delay -clock clk  7.5  [get_ports out_valid]
set_output_delay -clock clk  7.5  [get_ports {out_data[11]}]
set_output_delay -clock clk  7.5  [get_ports {out_data[10]}]
set_output_delay -clock clk  7.5  [get_ports {out_data[9]}]
set_output_delay -clock clk  7.5  [get_ports {out_data[8]}]
set_output_delay -clock clk  7.5  [get_ports {out_data[7]}]
set_output_delay -clock clk  7.5  [get_ports {out_data[6]}]
set_output_delay -clock clk  7.5  [get_ports {out_data[5]}]
set_output_delay -clock clk  7.5  [get_ports {out_data[4]}]
set_output_delay -clock clk  7.5  [get_ports {out_data[3]}]
set_output_delay -clock clk  7.5  [get_ports {out_data[2]}]
set_output_delay -clock clk  7.5  [get_ports {out_data[1]}]
set_output_delay -clock clk  7.5  [get_ports {out_data[0]}]
