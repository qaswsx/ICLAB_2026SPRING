# ----------------------------------------
# Jasper Version Info
# tool      : Jasper 2023.09
# platform  : Linux 3.10.0-1160.88.1.el7.x86_64
# version   : 2023.09p001 64 bits
# build date: 2023.10.25 14:35:20 UTC
# ----------------------------------------
# started   : 2026-05-04 00:32:15 CST
# hostname  : ee29.EEHPC
# pid       : 27710
# arguments : '-label' 'session_0' '-console' '//127.0.0.1:45086' '-style' 'windows' '-data' 'AAAAnnicVYq9CkBgGEbPR0omV+AOKLvVRmKwGiQlGfwsFi7VnXzehDj1/NWjgGjTWnNhrmIuCSkFsXhGKfmijrtEii8q338J1nN8LobIxmeioZbu0dFS3btiZGEgJGCW3cvD4QR+RxEM' '-proj' '/RAID2/COURSE/2026_Spring/iclab/iclab062/Lab08_2026s/JG/jgproject/sessionLogs/session_0' '-init' '-hidden' '/RAID2/COURSE/2026_Spring/iclab/iclab062/Lab08_2026s/JG/jgproject/.tmp/.initCmds.tcl' 'jg_sec_run1.tcl'
clear -all 

check_sec -analyze -sv -spec ../EXERCISE_wocg/01_RTL/LAB8_DESIGN_wocg.v
check_sec -analyze -sv -spec checker_only1f.sv 
check_sec -analyze -sv -imp ../EXERCISE/01_RTL/GATED_OR.v
check_sec -analyze -sv -imp ../EXERCISE/01_RTL/LAB8_DESIGN.v
check_sec -analyze -sv -imp checker_only1f.sv 
# check_sec -analyze -sv -both checker_only1f.sv 
check_sec -elaborate -spec -top LAB8_DESIGN -disable_x_handling -disable_auto_bbox
check_sec -elaborate -imp  -top LAB8_DESIGN -disable_x_handling -disable_auto_bbox
check_sec -setup

clock clk -both_edge
reset ~rst_n

check_sec -gen
check_sec -interface

assume LAB8_DESIGN_imp.cg_en==0 
check_sec -waive -waive_signals LAB8_DESIGN_imp.cg_en

check_sec -interface


# set_sec_autoprove_strategy design_style
# set_sec_autoprove_design_style_type clock_gating
set_sec_autoprove_strategy clock_gating





check_sec -prove -bg
