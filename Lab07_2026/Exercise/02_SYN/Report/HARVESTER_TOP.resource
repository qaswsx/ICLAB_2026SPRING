 
****************************************
Report : resources
Design : HARVESTER_TOP
Version: T-2022.03
Date   : Mon May 18 18:29:45 2026
****************************************


Resource Report for this hierarchy in file ../01_RTL/DESIGN_module.v
=============================================================================
| Cell           | Module         | Parameters | Contained Operations       |
=============================================================================
| add_x_5        | DW01_inc       | width=3    | u_input_output/add_65_S2 (DESIGN_module.v:65) |
| add_x_10       | DW01_inc       | width=3    | u_input_output/add_118 (DESIGN_module.v:118) |
| add_x_21       | DW01_inc       | width=2    | u_input_output/add_154 (DESIGN_module.v:154) |
| add_x_32       | DW01_add       | width=7    | u_FIFO_syn_output/add_40 (FIFO_syn.v:40) |
| add_x_33       | DW01_add       | width=7    | u_FIFO_syn_output/add_41 (FIFO_syn.v:41) |
| eq_x_34        | DW_cmp         | width=7    | u_FIFO_syn_output/eq_83 (FIFO_syn.v:83) |
| eq_x_35        | DW_cmp         | width=7    | u_FIFO_syn_output/eq_88 (FIFO_syn.v:88) |
| add_x_36       | DW01_add       | width=7    | u_FIFO_syn_R/add_40 (FIFO_syn.v:40) |
| add_x_37       | DW01_add       | width=7    | u_FIFO_syn_R/add_41 (FIFO_syn.v:41) |
| eq_x_38        | DW_cmp         | width=7    | u_FIFO_syn_R/eq_83 (FIFO_syn.v:83) |
| eq_x_39        | DW_cmp         | width=7    | u_FIFO_syn_R/eq_88 (FIFO_syn.v:88) |
| add_x_40       | DW01_add       | width=7    | u_FIFO_syn_AR/add_40 (FIFO_syn.v:40) |
| add_x_41       | DW01_add       | width=7    | u_FIFO_syn_AR/add_41 (FIFO_syn.v:41) |
| eq_x_42        | DW_cmp         | width=7    | u_FIFO_syn_AR/eq_83 (FIFO_syn.v:83) |
| eq_x_43        | DW_cmp         | width=7    | u_FIFO_syn_AR/eq_88 (FIFO_syn.v:88) |
| DP_OP_5_131_6419                |            |                            |
|                | DP_OP_5_131_6419 |          |                            |
| DP_OP_6_132_6419                |            |                            |
|                | DP_OP_6_132_6419 |          |                            |
| DP_OP_505J1_127_1847            |            |                            |
|                | DP_OP_505J1_127_1847 |      |                            |
=============================================================================

Datapath Report for DP_OP_5_131_6419
==============================================================================
| Cell                 | Contained Operations                                |
==============================================================================
| DP_OP_5_131_6419     | sub_334 (DESIGN_module.v:334)                       |
==============================================================================

==============================================================================
|       |      | Data     |       |                                          |
| Var   | Type | Class    | Width | Expression                               |
==============================================================================
| I1    | PI   | Unsigned | 31    |                                          |
| I2    | PI   | Unsigned | 31    |                                          |
| O1    | PO   | Signed   | 32    | I1 - I2 (DESIGN_module.v:334)            |
==============================================================================

Datapath Report for DP_OP_6_132_6419
==============================================================================
| Cell                 | Contained Operations                                |
==============================================================================
| DP_OP_6_132_6419     | sub_334_2 (DESIGN_module.v:334)                     |
==============================================================================

==============================================================================
|       |      | Data     |       |                                          |
| Var   | Type | Class    | Width | Expression                               |
==============================================================================
| I1    | PI   | Unsigned | 31    |                                          |
| I2    | PI   | Unsigned | 31    |                                          |
| O1    | PO   | Signed   | 32    | I1 - I2 (DESIGN_module.v:334)            |
==============================================================================

Datapath Report for DP_OP_505J1_127_1847
==============================================================================
| Cell                 | Contained Operations                                |
==============================================================================
| DP_OP_505J1_127_1847 | add_442 (DESIGN_module.v:442)                       |
|                      | sub_443 (DESIGN_module.v:443)                       |
==============================================================================

==============================================================================
|       |      | Data     |       |                                          |
| Var   | Type | Class    | Width | Expression                               |
==============================================================================
| I1    | PI   | Signed   | 7     |                                          |
| I2    | PI   | Unsigned | 1     |                                          |
| O1    | PO   | Signed   | 7     | addsub(I1,1,I2) ( DESIGN_module.v:442 DESIGN_module.v:443 ) |
==============================================================================


Resource Report for Ungrouped Hierarchy u_HARVESTER in file
        ../01_RTL/DESIGN_module.v
=============================================================================
| Cell           | Module         | Parameters | Contained Operations       |
=============================================================================
| gt_x_1         | DW_cmp         | width=31   | gt_334 (DESIGN_module.v:334) |
| mult_x_5       | DW_mult_uns    | a_width=64 | mult_367 (DESIGN_module.v:367) |
             |                | b_width=64 |                            |
| ashr_6         | DW_rightsh     | A_width=64 | sra_368 (DESIGN_module.v:368) |
              |                | SH_width=6 |                            |
| add_x_23       | DW01_inc       | width=2    | add_459 (DESIGN_module.v:459) |
| gt_x_26        | DW_cmp         | width=7    | gt_476 (DESIGN_module.v:476) |
| gte_x_27       | DW_cmp         | width=73   | gte_477 (DESIGN_module.v:477) |
| sub_x_28       | DW01_sub       | width=72   | sub_478 (DESIGN_module.v:478) |
| sub_x_29       | DW01_dec       | width=7    | sub_483 (DESIGN_module.v:483) |
| gt_x_30        | DW_cmp         | width=7    | gt_487 (DESIGN_module.v:487) |
| gte_x_31       | DW_cmp         | width=73   | gte_488 (DESIGN_module.v:488) |
| sub_x_32       | DW01_sub       | width=72   | sub_489 (DESIGN_module.v:489) |
| sub_x_33       | DW01_dec       | width=7    | sub_494 (DESIGN_module.v:494) |
| add_x_57       | DW01_inc       | width=3    | add_525_S2 (DESIGN_module.v:525) |
| add_x_64       | DW01_inc       | width=3    | add_588 (DESIGN_module.v:588) |
| add_x_65       | DW01_inc       | width=11   | add_597_S2 (DESIGN_module.v:597) |
| add_x_67       | DW01_add       | width=64   | add_608 (DESIGN_module.v:608) |
| add_x_68       | DW01_inc       | width=11   | add_610 (DESIGN_module.v:610) |
| add_x_69       | DW01_inc       | width=3    | add_616 (DESIGN_module.v:616) |
| lt_x_72        | DW_cmp         | width=2    | lt_656 (DESIGN_module.v:656) |
| add_x_73       | DW01_inc       | width=2    | add_657 (DESIGN_module.v:657) |
| add_x_286      | DW01_inc       | width=3    | add_721_S2 (DESIGN_module.v:721) |
| gt_x_315       | DW_cmp         | width=3    | gt_413 (DESIGN_module.v:413) |
               |                |            | gt_629 (DESIGN_module.v:629) |
               |                |            | gt_660 (DESIGN_module.v:660) |
| sub_x_71       | DW01_dec       | width=4    | sub_630 (DESIGN_module.v:630) |
              |                |            | sub_631 (DESIGN_module.v:631) |
              |                |            | sub_662 (DESIGN_module.v:662) |
              |                |            | sub_663 (DESIGN_module.v:663) |
              |                |            | sub_669 (DESIGN_module.v:669) |
| add_x_66       | DW01_inc       | width=11   | add_606 (DESIGN_module.v:606) |
              |                |            | add_613_S2 (DESIGN_module.v:613) |
| add_x_70       | DW01_inc       | width=3    | add_623 (DESIGN_module.v:623) |
              |                |            | add_645 (DESIGN_module.v:645) |
| DP_OP_501J1_122_1627            |            |                            |
|                | DP_OP_501J1_122_1627 |      |                            |
| DP_OP_502J1_123_6851            |            |                            |
|                | DP_OP_502J1_123_6851 |      |                            |
=============================================================================

Datapath Report for DP_OP_501J1_122_1627
==============================================================================
| Cell                 | Contained Operations                                |
==============================================================================
| DP_OP_501J1_122_1627 | mult_346 (DESIGN_module.v:346)                      |
|                      | lte_349 (DESIGN_module.v:349)                       |
|                      | gt_594 (DESIGN_module.v:594)                        |
|                      | sub_594 (DESIGN_module.v:594)                       |
|                      | add_609 (DESIGN_module.v:609)                       |
==============================================================================

==============================================================================
|       |      | Data     |       |                                          |
| Var   | Type | Class    | Width | Expression                               |
==============================================================================
| I1    | PI   | Unsigned | 32    |                                          |
| I2    | PI   | Unsigned | 64    |                                          |
| I3    | PI   | Unsigned | 64    |                                          |
| I4    | PI   | Unsigned | 73    |                                          |
| T5    | IFO  | Unsigned | 64    | I1 * I1 (DESIGN_module.v:346)            |
| O1    | PO   | Unsigned | 1     | T5 <= I2 (DESIGN_module.v:349)           |
| O2    | PO   | Unsigned | 1     | I3 > T5 (DESIGN_module.v:594)            |
| O3    | PO   | Signed   | 64    | I3 - T5 (DESIGN_module.v:594)            |
| O4    | PO   | Unsigned | 73    | I4 + T5 (DESIGN_module.v:609)            |
==============================================================================

Datapath Report for DP_OP_502J1_123_6851
==============================================================================
| Cell                 | Contained Operations                                |
==============================================================================
| DP_OP_502J1_123_6851 | add_365 (DESIGN_module.v:365)                       |
|                      | C26148 (DESIGN_module.v:365)                        |
|                      | add_366 (DESIGN_module.v:366)                       |
==============================================================================

==============================================================================
|       |      | Data     |       |                                          |
| Var   | Type | Class    | Width | Expression                               |
==============================================================================
| I1    | PI   | Signed   | 64    |                                          |
| I2    | PI   | Unsigned | 1     |                                          |
| I3    | PI   | Unsigned | 64    |                                          |
| I4    | PI   | Unsigned | 1     |                                          |
| I5    | PI   | Signed   | 64    |                                          |
| T9    | IFO  | Unsigned | 64    | I1 + $unsigned(1'b1) (DESIGN_module.v:365) |
| T10   | IFO  | Unsigned | 64    | { I2, I4 } ? T9 : I3 (DESIGN_module.v:365) |
| O1    | PO   | Unsigned | 64    | I5 + T10 (DESIGN_module.v:366)           |
==============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| add_x_5            | DW01_inc         | apparch (area)     |                |
| add_x_10           | DW01_inc         | apparch (area)     |                |
| add_x_21           | DW01_inc         | apparch (area)     |                |
| add_x_32           | DW01_add         | apparch (area)     |                |
| add_x_33           | DW01_add         | apparch (area)     |                |
| eq_x_34            | DW_cmp           | apparch (area)     |                |
| eq_x_35            | DW_cmp           | apparch (area)     |                |
| add_x_36           | DW01_add         | apparch (area)     |                |
| add_x_37           | DW01_add         | apparch (area)     |                |
| eq_x_38            | DW_cmp           | apparch (area)     |                |
| eq_x_39            | DW_cmp           | apparch (area)     |                |
| add_x_40           | DW01_add         | apparch (area)     |                |
| add_x_41           | DW01_add         | apparch (area)     |                |
| eq_x_42            | DW_cmp           | apparch (area)     |                |
| eq_x_43            | DW_cmp           | apparch (area)     |                |
| gt_x_1             | DW_cmp           | pparch (area,speed)                 |
| mult_x_5           | DW_mult_uns      | pparch (area,speed)                 |
|                    |                  | mult_arch: and     |                |
| ashr_6             | DW_rightsh       | astr (area)        |                |
| add_x_23           | DW01_inc         | apparch (area)     |                |
| gt_x_26            | DW_cmp           | apparch (area)     |                |
| gte_x_27           | DW_cmp           | apparch (area)     |                |
| sub_x_28           | DW01_sub         | pparch (area,speed)                 |
| sub_x_29           | DW01_dec         | apparch (area)     |                |
| gt_x_30            | DW_cmp           | apparch (area)     |                |
| gte_x_31           | DW_cmp           | apparch (area)     |                |
| sub_x_32           | DW01_sub         | pparch (area,speed)                 |
| sub_x_33           | DW01_dec         | apparch (area)     |                |
| add_x_57           | DW01_inc         | apparch (area)     |                |
| add_x_64           | DW01_inc         | apparch (area)     |                |
| add_x_65           | DW01_inc         | apparch (area)     |                |
| add_x_67           | DW01_add         | pparch (area,speed)                 |
| add_x_68           | DW01_inc         | apparch (area)     |                |
| add_x_69           | DW01_inc         | apparch (area)     |                |
| lt_x_72            | DW_cmp           | apparch (area)     |                |
| add_x_73           | DW01_inc         | apparch (area)     |                |
| add_x_286          | DW01_inc         | apparch (area)     |                |
| gt_x_315           | DW_cmp           | apparch (area)     |                |
| sub_x_71           | DW01_dec         | apparch (area)     |                |
| add_x_66           | DW01_inc         | apparch (area)     |                |
| add_x_70           | DW01_inc         | apparch (area)     |                |
| DP_OP_5_131_6419   | DP_OP_5_131_6419 | str (area,speed)   |                |
| DP_OP_6_132_6419   | DP_OP_6_132_6419 | str (area,speed)   |                |
| DP_OP_505J1_127_1847                  |                    |                |
|                    | DP_OP_505J1_127_1847 | str (area)     |                |
| DP_OP_501J1_122_1627                  |                    |                |
|                    | DP_OP_501J1_122_1627 | str (area,speed)                |
|                    |                  | mult_arch: and     |                |
| DP_OP_502J1_123_6851                  |                    |                |
|                    | DP_OP_502J1_123_6851 | str (area,speed)                |
===============================================================================

1
