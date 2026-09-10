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
