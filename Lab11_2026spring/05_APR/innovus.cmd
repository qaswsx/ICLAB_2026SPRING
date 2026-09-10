#######################################################
#                                                     
#  Innovus Command Logging File                     
#  Created on Sun May 24 22:52:00 2026                
#                                                     
#######################################################

#@(#)CDS: Innovus v20.15-s105_1 (64bit) 07/27/2021 14:15 (Linux 2.6.32-431.11.2.el6.x86_64)
#@(#)CDS: NanoRoute 20.15-s105_1 NR210726-1341/20_15-UB (database version 18.20.554) {superthreading v2.14}
#@(#)CDS: AAE 20.15-s020 (64bit) 07/27/2021 (Linux 2.6.32-431.11.2.el6.x86_64)
#@(#)CDS: CTE 20.15-s024_1 () Jul 23 2021 04:46:45 ( )
#@(#)CDS: SYNTECH 20.15-s012_1 () Jul 12 2021 23:29:38 ( )
#@(#)CDS: CPE v20.15-s071
#@(#)CDS: IQuantus/TQuantus 20.1.1-s460 (64bit) Fri Mar 5 18:46:16 PST 2021 (Linux 2.6.32-431.11.2.el6.x86_64)

set_global _enable_mmmc_by_default_flow      $CTE::mmmc_default
suppressMessage ENCEXT-2799
getVersion
win
set init_design_uniquify 1
setDesignMode -process 180
suppressMessage TECHLIB 1318
suppressMessage ENCEXT-2799
save_global CHIP.globals
set init_gnd_net GND
set init_lef_file {LEF/header6_V55_20ka_cic.lef LEF/fsa0m_a_generic_core.lef LEF/FSA0M_A_GENERIC_CORE_ANT_V55.lef LEF/fsa0m_a_t33_generic_io.lef LEF/FSA0M_A_T33_GENERIC_IO_ANT_V55.lef LEF/BONDPAD.lef LEF/SUMA180_4096X12.lef}
set init_verilog CHIP_SYN.v
set init_mmmc_file CHIP_mmmc.view
set init_io_file CHIP.io
set init_top_cell CHIP
set init_pwr_net VCC
init_design
getIoFlowFlag
setIoFlowFlag 0
floorPlan -site core_5040 -r 0.997269637729 0.85 190 190 190 190
uiSetTool select
getIoFlowFlag
fit
setDrawView fplan
uiSetTool move
selectInst CORE/MEM1_SRAM_INST
setObjFPlanBox Instance CORE/MEM1_SRAM_INST 337.93 1275.952 1116.65 1726.752
setObjFPlanBox Instance CORE/MEM1_SRAM_INST 346.092 1275.95 1124.812 1726.75
deselectAll
selectInst CORE/MEM2_SRAM_INST
flipOrRotateObject -rotate R90
setObjFPlanBox Instance CORE/MEM2_SRAM_INST 349.447 348.234 800.247 1126.954
zoomBox -1573.00600 -400.56600 3749.72700 2275.20400
deselectAll
selectInst CORE/MEM3_SRAM_INST
flipOrRotateObject -rotate R180
setObjFPlanBox Instance CORE/MEM3_SRAM_INST 945.247 352.075 1723.967 802.875
zoomBox -2132.75000 -690.88700 4129.29000 2457.07800
zoomBox -3868.27300 -1286.75000 4798.91300 3070.29600
deselectAll
selectInst CORE/MEM0_SRAM_INST
flipOrRotateObject -rotate R270
setObjFPlanBox Instance CORE/MEM0_SRAM_INST 1269.838 938.12 1720.638 1716.84
fit
uiSetTool select
addHaloToBlock {15 15 15 15} -allMacro
setDrawView place
uiSetTool move
deselectAll
selectInst CORE/MEM1_SRAM_INST
setObjFPlanBox Instance CORE/MEM1_SRAM_INST 343.37 1273.23 1122.09 1724.03
deselectAll
selectInst CORE/MEM0_SRAM_INST
setObjFPlanBox Instance CORE/MEM0_SRAM_INST 1272.56 938.12 1723.36 1716.84
setObjFPlanBox Instance CORE/MEM0_SRAM_INST 1275.281 938.12 1726.081 1716.84
setObjFPlanBox Instance CORE/MEM0_SRAM_INST 1280.721 938.12 1731.521 1716.84
setObjFPlanBox Instance CORE/MEM0_SRAM_INST 1280.72 943.561 1731.52 1722.281
setObjFPlanBox Instance CORE/MEM0_SRAM_INST 1280.72 940.839 1731.52 1719.559
deselectAll
selectInst CORE/MEM3_SRAM_INST
setObjFPlanBox Instance CORE/MEM3_SRAM_INST 953.412 346.629 1732.132 797.429
deselectAll
selectInst CORE/MEM2_SRAM_INST
setObjFPlanBox Instance CORE/MEM2_SRAM_INST 344.008 348.23 794.808 1126.95
setObjFPlanBox Instance CORE/MEM2_SRAM_INST 349.452 345.51 800.252 1124.23
undo
setObjFPlanBox Instance CORE/MEM2_SRAM_INST 346.731 348.23 797.531 1126.95
saveDesign CHIP_floorplan.inn
clearGlobalNets
globalNetConnect VCC -type pgpin -pin VCC -instanceBasename *
globalNetConnect VCC -type net -net VCC
globalNetConnect VCC -type tiehi -pin VCC -instanceBasename *
globalNetConnect GND -type pgpin -pin GND -instanceBasename *
globalNetConnect GND -type net -net GND
globalNetConnect GND -type tielo -pin GND -instanceBasename *
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
setAddRingMode -ring_target default -extend_over_row 0 -ignore_rows 0 -avoid_short 0 -skip_crossing_trunks none -stacked_via_top_layer metal6 -stacked_via_bottom_layer metal1 -via_using_exact_crossover_size 1 -orthogonal_only true -skip_via_on_pin {  standardcell } -skip_via_on_wire_shape {  noshape }
addRing -nets {GND VCC} -type core_rings -follow core -layer {top metal3 bottom metal3 left metal2 right metal2} -width {top 9 bottom 9 left 9 right 9} -spacing {top 0.28 bottom 0.28 left 0.28 right 0.28} -offset {top 1.8 bottom 1.8 left 1.8 right 1.8} -center 1 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid None -use_wire_group 1 -use_wire_group_bits 10 -use_interleaving_wire_group 1
setAddRingMode -ring_target default -extend_over_row 0 -ignore_rows 0 -avoid_short 0 -skip_crossing_trunks none -stacked_via_top_layer metal6 -stacked_via_bottom_layer metal1 -via_using_exact_crossover_size 1 -orthogonal_only true -skip_via_on_pin {  standardcell } -skip_via_on_wire_shape {  noshape }
addRing -nets {GND VCC} -type block_rings -around each_block -layer {top metal3 bottom metal3 left metal2 right metal2} -width {top 2 bottom 2 left 2 right 2} -spacing {top 0.28 bottom 0.28 left 0.28 right 0.28} -offset {top 1.8 bottom 1.8 left 1.8 right 1.8} -center 0 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid None
setSrouteMode -viaConnectToShape { ring blockring }
sroute -connect { blockPin padPin } -layerChangeRange { metal1(1) metal6(6) } -blockPinTarget { nearestTarget } -padPinPortConnect { allPort oneGeom } -padPinTarget { nearestTarget } -allowJogging 1 -crossoverViaLayerRange { metal1(1) metal6(6) } -nets { GND VCC } -allowLayerChange 1 -blockPin useLef -targetViaLayerRange { metal1(1) metal6(6) }
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
setAddStripeMode -ignore_block_check false -break_at none -route_over_rows_only false -rows_without_stripes_only false -extend_to_closest_target none -stop_at_last_wire_for_area false -partial_set_thru_domain false -ignore_nondefault_domains false -trim_antenna_back_to_shape none -spacing_type edge_to_edge -spacing_from_block 0 -stripe_min_length stripe_width -stacked_via_top_layer metal6 -stacked_via_bottom_layer metal1 -via_using_exact_crossover_size false -split_vias false -orthogonal_only true -allow_jog { padcore_ring  block_ring } -skip_via_on_pin {  standardcell } -skip_via_on_wire_shape {  noshape   }
addStripe -nets {GND VCC} -layer metal2 -direction vertical -width 4 -spacing 0.28 -set_to_set_distance 100 -start_from left -start_offset 50 -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit metal6 -padcore_ring_bottom_layer_limit metal1 -block_ring_top_layer_limit metal6 -block_ring_bottom_layer_limit metal1 -use_wire_group 0 -snap_wire_center_to_grid None
setAddStripeMode -ignore_block_check false -break_at none -route_over_rows_only false -rows_without_stripes_only false -extend_to_closest_target none -stop_at_last_wire_for_area false -partial_set_thru_domain false -ignore_nondefault_domains false -trim_antenna_back_to_shape none -spacing_type edge_to_edge -spacing_from_block 0 -stripe_min_length stripe_width -stacked_via_top_layer metal6 -stacked_via_bottom_layer metal1 -via_using_exact_crossover_size false -split_vias false -orthogonal_only true -allow_jog { padcore_ring  block_ring } -skip_via_on_pin {  standardcell } -skip_via_on_wire_shape {  noshape   }
addStripe -nets {GND VCC} -layer metal3 -direction horizontal -width 4 -spacing 0.28 -set_to_set_distance 100 -start_from bottom -start_offset 50 -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit metal6 -padcore_ring_bottom_layer_limit metal1 -block_ring_top_layer_limit metal6 -block_ring_bottom_layer_limit metal1 -use_wire_group 0 -snap_wire_center_to_grid None
setSrouteMode -viaConnectToShape { ring stripe blockring }
sroute -connect { corePin } -layerChangeRange { metal1(1) metal6(6) } -blockPinTarget { nearestTarget } -corePinTarget { firstAfterRowEnd } -allowJogging 1 -crossoverViaLayerRange { metal1(1) metal6(6) } -nets { GND VCC } -allowLayerChange 1 -targetViaLayerRange { metal1(1) metal6(6) }
getMultiCpuUsage -localCpu
get_verify_drc_mode -disable_rules -quiet
get_verify_drc_mode -quiet -area
get_verify_drc_mode -quiet -layer_range
get_verify_drc_mode -check_ndr_spacing -quiet
get_verify_drc_mode -check_only -quiet
get_verify_drc_mode -check_same_via_cell -quiet
get_verify_drc_mode -exclude_pg_net -quiet
get_verify_drc_mode -ignore_trial_route -quiet
get_verify_drc_mode -max_wrong_way_halo -quiet
get_verify_drc_mode -use_min_spacing_on_block_obs -quiet
get_verify_drc_mode -limit -quiet
set_verify_drc_mode -disable_rules {} -check_ndr_spacing auto -check_only default -check_same_via_cell false -exclude_pg_net false -ignore_trial_route false -ignore_cell_blockage false -use_min_spacing_on_block_obs auto -report CHIP.drc.rpt -limit 1000
verify_drc
set_verify_drc_mode -area {0 0 0 0}
verifyConnectivity -net {GND VCC} -type special -error 1000 -warning 50
saveDesign CHIP_powerplan.inn
setPlaceMode -prerouteAsObs {2 3}
setPlaceMode -fp false
place_design -noPrePlaceOpt
saveDesign CHIP_placement.inn
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -preCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix CHIP_preCTS -outDir timingReports
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -preCTS
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -preCTS
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -preCTS
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -preCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix CHIP_preCTS -outDir timingReports
update_constraint_mode -name func_mode -sdc_files CHIP_cts.sdc
set_ccopt_property update_io_latency false
create_ccopt_clock_tree_spec -file CHIP.CCOPT.spec -keep_all_sdc_clocks
get_ccopt_clock_trees
ccopt_check_and_flatten_ilms_no_restore
set_ccopt_property cts_is_sdc_clock_root -pin clk true
set_ccopt_property case_analysis -pin I_CLK/PD 0
set_ccopt_property case_analysis -pin I_CLK/PU 0
set_ccopt_property case_analysis -pin I_CLK/SMT 0
create_ccopt_clock_tree -name clk -source clk -no_skew_group
set_ccopt_property clock_period -pin clk 11
create_ccopt_skew_group -name clk/func_mode -sources clk -auto_sinks
set_ccopt_property include_source_latency -skew_group clk/func_mode true
set_ccopt_property extracted_from_clock_name -skew_group clk/func_mode clk
set_ccopt_property extracted_from_constraint_mode_name -skew_group clk/func_mode func_mode
set_ccopt_property extracted_from_delay_corners -skew_group clk/func_mode {Delay_Corner_max Delay_Corner_min}
check_ccopt_clock_tree_convergence
get_ccopt_property auto_design_state_for_ilms
ccopt_design
saveDesign ./DBS/CHIP_CTS.inn
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -postCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix CHIP_postCTS -outDir timingReports
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -postCTS
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -postCTS
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -postCTS
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -postCTS -hold -pathReports -slackReports -numPaths 50 -prefix CHIP_postCTS -outDir timingReports
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -postCTS -hold
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -postCTS -hold
