#######################################################
#                                                     
#  Innovus Command Logging File                     
#  Created on Wed May 27 22:24:33 2026                
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
set init_lef_file {LEF/header6_V55_20ka_cic.lef LEF/fsa0m_a_generic_core.lef LEF/FSA0M_A_GENERIC_CORE_ANT_V55.lef LEF/fsa0m_a_t33_generic_io.lef LEF/FSA0M_A_T33_GENERIC_IO_ANT_V55.lef LEF/BONDPAD.lef LEF/SRAM_256X128.lef LEF/SRAM_512X64.lef LEF/SRAM_82X64.lef}
set init_verilog CHIP_SYN.v
set init_mmmc_file CHIP_mmmc.view
set init_io_file CHIP.io
set init_top_cell CHIP
set init_pwr_net VCC
init_design
getIoFlowFlag
setIoFlowFlag 0
floorPlan -site core_5040 -r 0.99814785888 0.3 250.0 250 250 250
uiSetTool select
getIoFlowFlag
fit
setDrawView fplan
uiSetTool move
selectInst CORE/u_image_sram_A_SRAM1
setObjFPlanBox Instance CORE/u_image_sram_A_SRAM1 439.255 2789.973 1444.275 3083.973
deselectAll
selectInst CORE/u_weight_sram_SRAM3
setObjFPlanBox Instance CORE/u_weight_sram_SRAM3 1584.599 2930.296 2579.079 3097.176
deselectAll
selectInst CORE/u_v_sram_SRAM2
flipOrRotateObject -rotate R90
setObjFPlanBox Instance CORE/u_v_sram_SRAM2 439.255 771.781 654.855 2670.841
zoomOut
deselectAll
selectInst CORE/u_ds_sram_SRAM2
flipOrRotateObject -rotate R180
setObjFPlanBox Instance CORE/u_ds_sram_SRAM2 854.121 469.545 2753.181 685.145
deselectAll
selectInst CORE/u_k_sram_SRAM2
flipOrRotateObject -rotate R270
setObjFPlanBox Instance CORE/u_k_sram_SRAM2 2769.372 922.899 2984.972 2821.959
fit
setObjFPlanBox Instance CORE/u_k_sram_SRAM2 2866.517 890.518 3082.117 2789.578
deselectAll
selectInst CORE/u_weight_sram_SRAM3
setObjFPlanBox Instance CORE/u_weight_sram_SRAM3 1854.454 2930.3 2848.934 3097.18
deselectAll
selectInst CORE/u_image_sram_A_SRAM1
setObjFPlanBox Instance CORE/u_image_sram_A_SRAM1 784.662 2757.588 1789.682 3051.588
setObjFPlanBox Instance CORE/u_image_sram_A_SRAM1 795.454 2811.561 1800.474 3105.561
setObjFPlanBox Instance CORE/u_image_sram_A_SRAM1 790.053 2784.574 1795.073 3078.574
deselectAll
selectInst CORE/u_weight_sram_SRAM3
setObjFPlanBox Instance CORE/u_weight_sram_SRAM3 1843.656 2892.521 2838.136 3059.401
uiSetTool select
deselectAll
selectInst CORE/u_image_sram_A_SRAM1
addHaloToBlock {15 15 15 15} -allMacro
setDrawView place
gui_select -rect {1417.77600 3429.59100 235.81800 3424.19400}
deselectAll
selectInst GNDP0
gui_select -append -rect {1066.96600 3402.60500 1018.39300 3391.81100}
selectInst I_MODE_0
selectInst I_ITER_2
selectInst I_ITER_1
selectInst I_ITER_0
selectInst I_VALID
selectInst I_RST_N
selectInst I_CLK
selectInst VDDC0
selectInst VDDP0
selectInst GNDC0
uiSetTool move
setObjFPlanBox Instance GNDC0 2033.746 3324.306 2096.366 3464.426
setObjFPlanBox Instance VDDP0 1191.166 3324.306 1253.786 3464.426
setObjFPlanBox Instance VDDC0 1284.786 3324.306 1347.406 3464.426
setObjFPlanBox Instance I_CLK 1378.406 3324.306 1441.026 3464.426
setObjFPlanBox Instance I_RST_N 1472.026 3324.306 1534.646 3464.426
setObjFPlanBox Instance I_VALID 1565.646 3324.306 1628.266 3464.426
setObjFPlanBox Instance I_ITER_0 1659.266 3324.306 1721.886 3464.426
setObjFPlanBox Instance I_ITER_1 1752.886 3324.306 1815.506 3464.426
setObjFPlanBox Instance I_ITER_2 1846.506 3324.306 1909.126 3464.426
setObjFPlanBox Instance I_MODE_0 1940.126 3324.306 2002.746 3464.426
setObjFPlanBox Instance GNDP0 2127.366 3324.306 2189.986 3464.426
uiSetTool select
selectInst GNDP1
selectInst GNDC1
selectInst I_DATA_7
selectInst I_DATA_6
selectInst I_DATA_5
selectInst I_DATA_4
selectInst I_DATA_3
selectInst I_DATA_2
selectInst I_DATA_1
selectInst I_DATA_0
selectInst VDDC1
selectInst VDDP1
uiSetTool move
setObjFPlanBox Instance VDDP1 0.0 1207.357 140.12 1269.977
setObjFPlanBox Instance VDDC1 0.0 1300.977 140.12 1363.597
setObjFPlanBox Instance I_DATA_0 0.0 1394.597 140.12 1457.217
setObjFPlanBox Instance I_DATA_1 0.0 1488.217 140.12 1550.837
setObjFPlanBox Instance I_DATA_2 0.0 1581.837 140.12 1644.457
setObjFPlanBox Instance I_DATA_3 0.0 1675.457 140.12 1738.077
setObjFPlanBox Instance I_DATA_4 0.0 1769.077 140.12 1831.697
setObjFPlanBox Instance I_DATA_5 0.0 1862.697 140.12 1925.317
setObjFPlanBox Instance I_DATA_6 0.0 1956.317 140.12 2018.937
setObjFPlanBox Instance I_DATA_7 0.0 2049.937 140.12 2112.557
setObjFPlanBox Instance GNDC1 0.0 2143.557 140.12 2206.177
setObjFPlanBox Instance GNDP1 0.0 2237.177 140.12 2299.797
setObjFPlanBox Instance GNDC0 2033.75 4409.117 2096.37 4549.237
setObjFPlanBox Instance VDDP0 1191.17 4409.117 1253.79 4549.237
setObjFPlanBox Instance VDDC0 1284.79 4409.117 1347.41 4549.237
setObjFPlanBox Instance I_CLK 1378.41 4409.117 1441.03 4549.237
setObjFPlanBox Instance I_RST_N 1472.03 4409.117 1534.65 4549.237
setObjFPlanBox Instance I_VALID 1565.65 4409.117 1628.27 4549.237
setObjFPlanBox Instance I_ITER_0 1659.27 4409.117 1721.89 4549.237
setObjFPlanBox Instance I_ITER_1 1752.89 4409.117 1815.51 4549.237
setObjFPlanBox Instance I_ITER_2 1846.51 4409.117 1909.13 4549.237
setObjFPlanBox Instance I_MODE_0 1940.13 4409.117 2002.75 4549.237
setObjFPlanBox Instance GNDP0 2127.37 4409.117 2189.99 4549.237
uiSetTool select
selectInst GNDP2
selectInst GNDC2
selectInst O_DATA_0
selectInst O_VALID
selectInst I_WEIGHT_3
selectInst I_WEIGHT_2
selectInst I_WEIGHT_1
selectInst I_WEIGHT_0
selectInst I_MODE_1
selectInst VDDC2
selectInst VDDP2
uiSetTool move
setObjFPlanBox Instance VDDP2 1239.739 21.588 1302.359 161.708
setObjFPlanBox Instance VDDC2 1333.359 21.588 1395.979 161.708
setObjFPlanBox Instance I_MODE_1 1426.979 21.588 1489.599 161.708
setObjFPlanBox Instance I_WEIGHT_0 1520.599 21.588 1583.219 161.708
setObjFPlanBox Instance I_WEIGHT_1 1614.219 21.588 1676.839 161.708
setObjFPlanBox Instance I_WEIGHT_2 1707.839 21.588 1770.459 161.708
setObjFPlanBox Instance I_WEIGHT_3 1801.459 21.588 1864.079 161.708
setObjFPlanBox Instance O_VALID 1895.079 21.588 1957.699 161.708
setObjFPlanBox Instance O_DATA_0 1988.699 21.588 2051.319 161.708
setObjFPlanBox Instance GNDC2 2082.319 21.588 2144.939 161.708
setObjFPlanBox Instance GNDP2 2175.939 21.588 2238.559 161.708
setObjFPlanBox Instance VDDP1 1068.619 1228.948 1208.739 1291.568
setObjFPlanBox Instance VDDC1 1068.619 1322.568 1208.739 1385.188
setObjFPlanBox Instance I_DATA_0 1068.619 1416.188 1208.739 1478.808
setObjFPlanBox Instance I_DATA_1 1068.619 1509.808 1208.739 1572.428
setObjFPlanBox Instance I_DATA_2 1068.619 1603.428 1208.739 1666.048
setObjFPlanBox Instance I_DATA_3 1068.619 1697.048 1208.739 1759.668
setObjFPlanBox Instance I_DATA_4 1068.619 1790.668 1208.739 1853.288
setObjFPlanBox Instance I_DATA_5 1068.619 1884.288 1208.739 1946.908
setObjFPlanBox Instance I_DATA_6 1068.619 1977.908 1208.739 2040.528
setObjFPlanBox Instance I_DATA_7 1068.619 2071.528 1208.739 2134.148
setObjFPlanBox Instance GNDC1 1068.619 2165.148 1208.739 2227.768
setObjFPlanBox Instance GNDP1 1068.619 2258.768 1208.739 2321.388
setObjFPlanBox Instance GNDC0 3102.369 3394.468 3164.989 3534.588
setObjFPlanBox Instance VDDP0 2259.789 3394.468 2322.409 3534.588
setObjFPlanBox Instance VDDC0 2353.409 3394.468 2416.029 3534.588
setObjFPlanBox Instance I_CLK 2447.029 3394.468 2509.649 3534.588
setObjFPlanBox Instance I_RST_N 2540.649 3394.468 2603.269 3534.588
setObjFPlanBox Instance I_VALID 2634.269 3394.468 2696.889 3534.588
setObjFPlanBox Instance I_ITER_0 2727.889 3394.468 2790.509 3534.588
setObjFPlanBox Instance I_ITER_1 2821.509 3394.468 2884.129 3534.588
setObjFPlanBox Instance I_ITER_2 2915.129 3394.468 2977.749 3534.588
setObjFPlanBox Instance I_MODE_0 3008.749 3394.468 3071.369 3534.588
setObjFPlanBox Instance GNDP0 3195.989 3394.468 3258.609 3534.588
undo
uiSetTool select
deselectAll
selectInst VDDP2
selectInst VDDC2
selectInst I_MODE_1
selectInst I_WEIGHT_0
selectInst I_WEIGHT_1
selectInst I_WEIGHT_2
selectInst I_WEIGHT_3
selectInst O_VALID
selectInst O_DATA_0
selectInst GNDC2
selectInst GNDP2
uiSetTool move
setObjFPlanBox Instance GNDP2 2170.542 -32.382 2233.162 107.738
setObjFPlanBox Instance GNDC2 2076.922 -32.382 2139.542 107.738
setObjFPlanBox Instance O_DATA_0 1983.302 -32.382 2045.922 107.738
setObjFPlanBox Instance O_VALID 1889.682 -32.382 1952.302 107.738
setObjFPlanBox Instance I_WEIGHT_3 1796.062 -32.382 1858.682 107.738
setObjFPlanBox Instance I_WEIGHT_2 1702.442 -32.382 1765.062 107.738
setObjFPlanBox Instance I_WEIGHT_1 1608.822 -32.382 1671.442 107.738
setObjFPlanBox Instance I_WEIGHT_0 1515.202 -32.382 1577.822 107.738
setObjFPlanBox Instance I_MODE_1 1421.582 -32.382 1484.202 107.738
setObjFPlanBox Instance VDDC2 1327.962 -32.382 1390.582 107.738
setObjFPlanBox Instance VDDP2 1234.342 -32.382 1296.962 107.738
setObjFPlanBox Instance GNDP2 2127.366 21.588 2189.986 161.708
setObjFPlanBox Instance GNDC2 2033.746 21.588 2096.366 161.708
setObjFPlanBox Instance O_DATA_0 1940.126 21.588 2002.746 161.708
setObjFPlanBox Instance O_VALID 1846.506 21.588 1909.126 161.708
setObjFPlanBox Instance I_WEIGHT_3 1752.886 21.588 1815.506 161.708
setObjFPlanBox Instance I_WEIGHT_2 1659.266 21.588 1721.886 161.708
setObjFPlanBox Instance I_WEIGHT_1 1565.646 21.588 1628.266 161.708
setObjFPlanBox Instance I_WEIGHT_0 1472.026 21.588 1534.646 161.708
setObjFPlanBox Instance I_MODE_1 1378.406 21.588 1441.026 161.708
setObjFPlanBox Instance VDDC2 1284.786 21.588 1347.406 161.708
setObjFPlanBox Instance VDDP2 1191.166 21.588 1253.786 161.708
uiSetTool select
deselectAll
selectInst GNDP3
selectInst GNDC3
selectInst O_DATA_7
selectInst O_DATA_6
selectInst O_DATA_5
selectInst O_DATA_4
selectInst O_DATA_3
selectInst O_DATA_2
selectInst O_DATA_1
selectInst VDDC3
selectInst VDDP3
uiSetTool move
setObjFPlanBox Instance VDDP3 3386.257 1174.975 3526.377 1237.595
setObjFPlanBox Instance VDDC3 3386.257 1268.595 3526.377 1331.215
setObjFPlanBox Instance O_DATA_1 3386.257 1362.215 3526.377 1424.835
setObjFPlanBox Instance O_DATA_2 3386.257 1455.835 3526.377 1518.455
setObjFPlanBox Instance O_DATA_3 3386.257 1549.455 3526.377 1612.075
setObjFPlanBox Instance O_DATA_4 3386.257 1643.075 3526.377 1705.695
setObjFPlanBox Instance O_DATA_5 3386.257 1736.695 3526.377 1799.315
setObjFPlanBox Instance O_DATA_6 3386.257 1830.315 3526.377 1892.935
setObjFPlanBox Instance O_DATA_7 3386.257 1923.935 3526.377 1986.555
setObjFPlanBox Instance GNDC3 3386.257 2017.555 3526.377 2080.175
setObjFPlanBox Instance GNDP3 3386.257 2111.175 3526.377 2173.795
saveDesign DBS/CHIP_floorplan.inn
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
saveDesign ./DBS/CHIP_powerplan.inn
setPlaceMode -prerouteAsObs {2 3}
setPlaceMode -fp false
place_design -noPrePlaceOpt
saveDesign ./DBS/CHIP_placement.inn
update_constraint_mode -name func_mode -sdc_files CHIP.sdc
timeDesign -preCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix CHIP_preCTS -outDir timingReports
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -preCTS
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -preCTS
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -preCTS
saveDesign ./DBS/CHIP_preCTS.inn
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
set_ccopt_property clock_period -pin clk 20
create_ccopt_skew_group -name clk/func_mode -sources clk -auto_sinks
set_ccopt_property include_source_latency -skew_group clk/func_mode true
set_ccopt_property extracted_from_clock_name -skew_group clk/func_mode clk
set_ccopt_property extracted_from_constraint_mode_name -skew_group clk/func_mode func_mode
set_ccopt_property extracted_from_delay_corners -skew_group clk/func_mode {Delay_Corner_max Delay_Corner_min}
check_ccopt_clock_tree_convergence
get_ccopt_property auto_design_state_for_ilms
ccopt_design
timeDesign -postCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix CHIP_postCTS -outDir timingReports
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -postCTS
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -postCTS
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -postCTS
timeDesign -postCTS -hold -pathReports -slackReports -numPaths 50 -prefix CHIP_postCTS -outDir timingReports
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -postCTS -hold
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -postCTS -hold
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -postCTS -hold
saveDesign ./DBS/CHIP_CTS.inn
addIoFiller -cell EMPTY16D -prefix IOFILLER
addIoFiller -cell EMPTY8D -prefix IOFILLER
addIoFiller -cell EMPTY4D -prefix IOFILLER
addIoFiller -cell EMPTY2D -prefix IOFILLER
addIoFiller -cell EMPTY1D -prefix IOFILLER -fillAnyGap
setNanoRouteMode -quiet -routeInsertAntennaDiode 1
setNanoRouteMode -quiet -routeAntennaCellName ANTENNA
setNanoRouteMode -quiet -timingEngine {}
setNanoRouteMode -quiet -routeWithTimingDriven 1
setNanoRouteMode -quiet -routeWithSiDriven 1
setNanoRouteMode -quiet -routeTdrEffort 10
setNanoRouteMode -quiet -routeTopRoutingLayer 6
setNanoRouteMode -quiet -routeBottomRoutingLayer 1
setNanoRouteMode -quiet -drouteEndIteration 100
setNanoRouteMode -quiet -routeWithTimingDriven true
setNanoRouteMode -quiet -routeWithSiDriven true
routeDesign -globalDetail
verifyConnectivity -type all -error 1000 -warning 50
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
saveDesign ./DBS/CHIP_nanoRoute.inn
setAnalysisMode -cppr none -clockGatingCheck true -timeBorrowing true -useOutputPinCap true -sequentialConstProp false -timingSelfLoopsNoSkew false -enableMultipleDriveNet true -clkSrcPath true -warn true -usefulSkew true -analysisType onChipVariation -log true
setExtractRCMode -engine postRoute -effortLevel high -coupled true -capFilterMode relOnly -coupling_c_th 3 -total_c_th 5 -relative_c_th 0.03
setExtractRCMode -engine postRoute
setExtractRCMode -effortLevel high
setDelayCalMode -SIAware true
timeDesign -postRoute -pathReports -drvReports -slackReports -numPaths 50 -prefix CHIP_postRoute -outDir timingReports
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
setDelayCalMode -engine default -siAware true
optDesign -postRoute
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
setDelayCalMode -engine default -siAware true
optDesign -postRoute
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
setDelayCalMode -engine default -siAware true
optDesign -postRoute
timeDesign -postRoute -hold -pathReports -slackReports -numPaths 50 -prefix CHIP_postRoute -outDir timingReports
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
setDelayCalMode -engine default -siAware true
optDesign -postRoute -hold
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
setDelayCalMode -engine default -siAware true
optDesign -postRoute -hold
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
setDelayCalMode -engine default -siAware true
optDesign -postRoute -hold
saveDesign ./DBS/CHIP_postRoute.inn
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
verifyConnectivity -type all -error 1000 -warning 50
zoomBox -237.28500 1075.98900 4001.92800 3449.15300
zoomBox 359.64300 1636.12700 3422.47500 3350.73800
zoomBox 977.83600 2187.78900 2858.79900 3240.77500
zoomBox 1227.18700 2382.04700 2586.18400 3142.83000
zoomBox 1519.25200 2582.12600 2353.84600 3049.34200
zoomBox 1638.94400 2667.94200 2241.93900 3005.50600
zoomBox 1725.02900 2730.73900 2160.69500 2974.63000
zoomBox 1846.87000 2814.68300 2040.17900 2922.90000
zoomBox 1892.45400 2847.33700 1993.36500 2903.82800
uiSetTool select
selectWire 1940.6000 686.9400 1944.6000 2884.1900 2 GND
editTrim
zoomOut
zoomOut
zoomBox 1613.73800 2747.28500 2269.91300 3114.62000
zoomBox 1820.11300 2944.52000 2067.59000 3083.06100
deselectAll
selectWire 1940.6000 3067.7300 1944.6000 3331.1000 2 GND
editTrim
deselectAll
selectWire 2040.6000 3067.7300 2044.6000 3331.1000 2 GND
uiSetTool move
editTrim
zoomOut
zoomBox 1761.74600 2880.88200 2298.15500 3181.17000
uiSetTool select
zoomBox 1818.11300 2910.07200 2274.06100 3165.31700
deselectAll
selectWire 2140.6000 3067.7300 2144.6000 3331.1000 2 GND
editTrim
deselectAll
selectWire 2240.6000 3067.7300 2244.6000 3331.1000 2 GND
editTrim
deselectAll
selectWire 2244.8800 3067.7300 2248.8800 3340.3800 2 VCC
editTrim
zoomBox 1579.97300 2835.55300 2322.40800 3251.17700
zoomBox 1296.41300 2649.58300 2505.34600 3326.35900
zoomBox 921.36000 2491.26800 2594.62500 3427.98200
zoomBox 301.80000 2308.86700 2617.73900 3605.35800
zoomOut
zoomBox 233.20500 1942.44000 3860.01100 3972.77100
zoomBox 1458.50800 2449.36800 3351.72600 3509.21500
zoomBox 2128.86500 2796.35200 2968.89800 3266.61300
zoomBox 2333.13600 2903.55600 2849.02200 3192.35500
zoomBox 2482.55500 2983.95200 2751.85200 3134.70800
deselectAll
selectWire 2640.6000 3067.7300 2644.6000 3331.1000 2 GND
editTrim
zoomBox 2224.41900 2885.75100 2831.34700 3225.51700
zoomBox 1626.41800 2683.56400 2994.28400 3449.31200
zoomBox 2167.27300 2769.44500 2881.30800 3169.17100
zoomBox 2492.74500 2825.12300 2809.56700 3002.48400
zoomBox 2615.41100 2847.61900 2780.79500 2940.20300
deselectAll
selectWire 2740.6000 686.9400 2744.6000 2884.1900 2 GND
editTrim
uiSetTool move
editTrim
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
verifyConnectivity -type all -error 1000 -warning 50
fit
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -postRoute -pathReports -drvReports -slackReports -numPaths 50 -prefix CHIP_postRoute -outDir timingReports
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -postRoute -hold -pathReports -slackReports -numPaths 50 -prefix CHIP_postRoute -outDir timingReports
setLayerPreference violation -isVisible 1
violationBrowser -all -no_display_false -displayByLayer
zoomBox -615.04400 532.43100 3624.16900 2905.59500
uiSetTool select
uiSetTool select
zoomBox 16.76700 967.28200 2620.17500 2424.70200
zoomBox 515.89400 1291.27600 1874.89000 2052.05900
zoomBox 830.35100 1497.65600 1433.34600 1835.22000
zoomBox 930.47900 1562.78400 1300.79400 1770.09100
zoomBox 1004.35500 1612.92700 1197.66300 1721.14300
zoomBox 1040.99600 1639.13200 1141.90600 1695.62300
zoomBox 1051.64700 1647.03200 1124.55600 1687.84700
zoomBox 1062.27100 1655.06000 1107.04700 1680.12600
deselectAll
selectMarker 1078.6100 1668.0200 1079.6100 1669.0200 6 2 44
deselectAll
selectWire 1078.9700 1668.3800 1079.2500 1793.5400 2 {CORE/v_sram_dout[106]}
deselectAll
selectMarker 1078.6100 1668.0200 1079.6100 1669.0200 6 2 44
editTrim
deselectAll
selectMarker 1078.6100 1668.0200 1079.6100 1669.0200 6 2 44
deselectAll
selectWire 1078.9700 1668.3800 1079.2500 1793.5400 2 {CORE/v_sram_dout[106]}
editTrim
editTrim
zoomBox 1070.39200 1660.97900 1093.76600 1674.06400
zoomBox 1075.27600 1664.75000 1085.64800 1670.55600
zoomBox 1076.75300 1665.89600 1083.12300 1669.46200
zoomBox 1076.30200 1665.48400 1083.79600 1669.67900
deselectAll
selectMarker 1078.6100 1668.0200 1079.6100 1669.0200 6 2 44
deselectAll
selectInst CORE/v_sram_dout_d1_reg_106_
deselectAll
selectMarker 1078.6100 1668.0200 1079.6100 1669.0200 6 2 44
zoomBox 1073.53400 1662.58500 1087.89000 1670.62200
zoomBox 1071.11700 1660.52000 1090.99000 1671.64500
zoomBox 1069.58200 1659.21200 1092.96200 1672.30000
zoomBox 1065.42400 1655.72900 1097.78500 1673.84500
deselectAll
selectMarker 1078.6100 1668.0200 1079.6100 1669.0200 6 2 44
zoomOut
setLayerPreference via2 -isVisible 0
setLayerPreference metal2 -isVisible 0
setLayerPreference via -isVisible 0
setLayerPreference via -isVisible 1
setLayerPreference metal1 -isVisible 0
setLayerPreference via3 -isVisible 0
setLayerPreference metal4 -isVisible 0
setLayerPreference via4 -isVisible 0
setLayerPreference metal5 -isVisible 0
setLayerPreference via5 -isVisible 0
setLayerPreference metal6 -isVisible 0
deselectAll
selectMarker 1078.6100 1668.0200 1079.6100 1669.0200 3 2 44
editTrim
zoomBox 1033.06300 1626.74300 1130.14600 1681.09100
zoomBox 982.25300 1605.05700 1168.23500 1709.17200
zoomBox 816.34800 1541.86800 1235.51000 1776.52000
zoomBox 442.44000 1396.00300 1387.12700 1924.85000
