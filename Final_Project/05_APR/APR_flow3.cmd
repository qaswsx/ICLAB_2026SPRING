#====================================================================
#   In-Place Optimization (consider crosstalk effects)
#====================================================================
setAnalysisMode -cppr none -clockGatingCheck true -timeBorrowing true -useOutputPinCap true -sequentialConstProp false -timingSelfLoopsNoSkew false -enableMultipleDriveNet true -clkSrcPath true -warn true -usefulSkew true -analysisType onChipVariation -log true
setExtractRCMode -engine postRoute -effortLevel high -coupled true -capFilterMode relOnly -coupling_c_th 3 -total_c_th 5 -relative_c_th 0.03 

set_db extract_rc_engine post_route
set_db extract_rc_effort_level high
set_db delaycal_enable_si true

#====================================================================
#   Routing Timing check
#====================================================================
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
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
setDelayCalMode -engine default -siAware true
optDesign -postRoute -hold

saveDesign ./DBS/CHIP_postRoute.inn


#====================================================================
#   Add CORE Filler Cells
#====================================================================
#getFillerMode -quiet
addFiller -cell FILLER1 FILLER2 FILLER4 FILLER8 FILLER16 FILLER32 FILLER64 -prefix FILLER