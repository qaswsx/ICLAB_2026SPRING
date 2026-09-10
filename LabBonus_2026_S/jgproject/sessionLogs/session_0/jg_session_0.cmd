# ----------------------------------------
# Jasper Version Info
# tool      : Jasper 2023.09
# platform  : Linux 3.10.0-1160.88.1.el7.x86_64
# version   : 2023.09p001 64 bits
# build date: 2023.10.25 14:35:20 UTC
# ----------------------------------------
# started   : 2026-06-03 19:28:04 CST
# hostname  : ee28.EEHPC
# pid       : 194236
# arguments : '-label' 'session_0' '-console' '//127.0.0.1:46218' '-style' 'windows' '-data' 'AAAAgnicY2RgYLCp////PwMYMFcBCQEGHwZfhiAGVyDpzxAGpOGA8QGUYcPIgAwYAxtQaAYGVphCuBIg5mMoYihlyGPQYyhhSGbIAYsDANovDIY=' '-proj' '/RAID2/COURSE/2026_Spring/iclab/iclab062/LabBonus_2026_S/jgproject/sessionLogs/session_0' '-init' '-hidden' '/RAID2/COURSE/2026_Spring/iclab/iclab062/LabBonus_2026_S/jgproject/.tmp/.initCmds.tcl' 'run.tcl'
clear -all

analyze -sv12 rr.sv rr_checker.sv
elaborate -top rr -create_related_cover {}

clock clk
reset ~rst_n

prove -all -prefer_shortest
visualize -property <embedded>::rr.i_rr_checker.A1P1_COVER -new_window
visualize -violation -property <embedded>::rr.i_rr_checker.Q2P2_ASSERT -new_window
visualize -violation -property <embedded>::rr.i_rr_checker.Q2P2_ASSERT -new_window
visualize -property <embedded>::rr.i_rr_checker.A1P1_COVER -new_window
visualize -property <embedded>::rr.i_rr_checker.Q1P2_COVER -new_window
visualize -property <embedded>::rr.i_rr_checker.Q1P3_COVER_1 -new_window
visualize -violation -property <embedded>::rr.i_rr_checker.Q2P2_ASSERT -new_window
