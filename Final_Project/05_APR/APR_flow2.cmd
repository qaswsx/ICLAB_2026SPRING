#====================================================================
# Final Project APR - Part 2
# From first power-plan verify to before the next verify
# Assumption: floorplan / global net / rings / stripes / sroute have been done.
# Final project is pin design, so PAD filler is skipped.
#====================================================================


#====================================================================
#  Placement Blockage & Place Standard Cells
#  Block metal2/metal3 stripe area during placement.
#====================================================================
setPlaceMode -prerouteAsObs {2 3}
setPlaceMode -fp false
place_design -noPrePlaceOpt

# Spec Step 11-4: save immediately after placement
saveDesign ./DBS/CHIP_placement.inn


#====================================================================
#  Pre-CTS Timing Check / IPO
#====================================================================
update_constraint_mode -name func_mode -sdc_files CHIP.sdc

timeDesign -preCTS -pathReports -drvReports -slackReports \
    -numPaths 50 -prefix CHIP_preCTS -outDir timingReports

setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -preCTS
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -preCTS
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -preCTS
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -preCTS

saveDesign ./DBS/CHIP_preCTS.inn


#====================================================================
#  Clock Tree Synthesis (CTS)
#  CHIP_cts.sdc should comment out set_clock_uncertainty / transition.
#====================================================================
update_constraint_mode -name func_mode -sdc_files CHIP_cts.sdc

# Follow Final APR / TA flow
source ./cmd/ccopt.cmd


#====================================================================
#  Post-CTS Setup Timing Check / IPO
#====================================================================
timeDesign -postCTS -pathReports -drvReports -slackReports \
    -numPaths 50 -prefix CHIP_postCTS -outDir timingReports

setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -postCTS
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -postCTS
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -postCTS
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -postCTS


#====================================================================
#  Post-CTS Hold Timing Check / IPO
#====================================================================
timeDesign -postCTS -hold -pathReports -slackReports \
    -numPaths 50 -prefix CHIP_postCTS -outDir timingReports

setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -postCTS -hold
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -postCTS -hold
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -postCTS -hold
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -postCTS -hold

saveDesign ./DBS/CHIP_CTS.inn


#====================================================================
#  PAD Filler
#====================================================================
# Final Project is pin design and has no IO pads.
# Therefore, skip addIoFiller commands.


#====================================================================
#  SI-Prevention Detail Route (NanoRoute)
#====================================================================
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

# Stop here. The next step is route DRC / Connectivity verify.
