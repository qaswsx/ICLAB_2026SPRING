# ----------------------------------------
# Jasper Version Info
# tool      : Jasper 2023.09
# platform  : Linux 3.10.0-1160.88.1.el7.x86_64
# version   : 2023.09p001 64 bits
# build date: 2023.10.25 14:35:20 UTC
# ----------------------------------------
# started   : 2026-05-04 00:32:26 CST
# hostname  : ee29.EEHPC
# pid       : 27892
# arguments : '-label' 'session_0' '-console' '//127.0.0.1:33326' '-style' 'windows' '-data' 'AAAAnnicVYq9CkBgGEbPR0omV+AOGMxWG4nBapCUZPCzWLhUd/J5E+LU81ePAqJNa82FuYq5JKQUxOIZpeSLOu4SKb6ofP8lWM/xuRgiG5+Jhlq6R0dLde+KkYWBkIBZdi8PhxN+VREN' '-proj' '/RAID2/COURSE/2026_Spring/iclab/iclab062/Lab08_2026s/JG/jgproject/sessionLogs/session_0' '-init' '-hidden' '/RAID2/COURSE/2026_Spring/iclab/iclab062/Lab08_2026s/JG/jgproject/.tmp/.initCmds.tcl' 'jg_sec_run2.tcl'
clear -all 

set_proofgrid_max_local_jobs 10
check_sec -analyze -sv -both ../EXERCISE/01_RTL/GATED_OR.v
check_sec -analyze -sv -both ../EXERCISE/01_RTL/LAB8_DESIGN.v 
check_sec -analyze -sv -both checker_only1f.sv 
check_sec -elaborate -both  -top LAB8_DESIGN -disable_auto_bbox
check_sec -setup

clock clk -both_edge 
reset ~rst_n

#CDNS added
assume -name in_valid_keep {bind_checker_only1f.in_valid_keep |-> in_valid}
assume -name in_valid_invalid_after {bind_checker_only1f.in_valid_forbidden |-> !in_valid}

check_sec -gen
check_sec -interface

assume cg_en==0
assume LAB8_DESIGN_imp.cg_en==1
check_sec -waive -waive_signals cg_en
check_sec -waive -waive_signals LAB8_DESIGN_imp.cg_en

check_sec -interface


# set_sec_autoprove_strategy design_style
# set_sec_autoprove_design_style_type clock_gating
set_sec_autoprove_strategy clock_gating


check_sec -prove -bg
