###################################################################

# Created by write_sdc on Mon May  4 00:11:01 2026

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
{in_data[1]}] [get_ports {in_data[0]}]]  -to [list [get_ports out_valid] [get_ports {out_data[11]}] [get_ports         \
{out_data[10]}] [get_ports {out_data[9]}] [get_ports {out_data[8]}] [get_ports \
{out_data[7]}] [get_ports {out_data[6]}] [get_ports {out_data[5]}] [get_ports  \
{out_data[4]}] [get_ports {out_data[3]}] [get_ports {out_data[2]}] [get_ports  \
{out_data[1]}] [get_ports {out_data[0]}]]
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
