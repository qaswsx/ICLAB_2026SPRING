//###############################################################################################
//***********************************************************************************************
//    File Name   : SORT_IP.v
//    Module Name : SORT_IP (Flat Dataflow Optimal Sorting Network - Direct Array Access)
//***********************************************************************************************
//###############################################################################################

module SORT_IP #(parameter IP_WIDTH = 8)(
    //Input signals
    input  [IP_WIDTH*4-1:0] IN_character,
    input  [IP_WIDTH*5-1:0] IN_weight,
    //Output signals
    output [IP_WIDTH*4-1:0] OUT_character
);

// ======================================================
// Data Packing (9-bit combination of Weight & ID)
// ======================================================
wire [8:0] data_in [0:IP_WIDTH-1];
genvar i;
generate
    for (i = 0; i < IP_WIDTH; i = i + 1) begin : GEN_DATA_IN
        assign data_in[i] = { IN_weight[ (i * 5 + 4) -: 5 ], IN_character[ (i * 4 + 3) -: 4 ] };
    end
endgenerate

// ======================================================
// Flat Combinational Sorting Networks
// ======================================================
generate
    if (IP_WIDTH == 8) begin : GEN_W8
        // Layer 1
        wire [8:0] layer1_0 = (data_in[0]>data_in[1])? data_in[0] : data_in[1]; wire [8:0] layer1_1 = (data_in[0]>data_in[1])? data_in[1] : data_in[0];
        wire [8:0] layer1_2 = (data_in[2]>data_in[3])? data_in[2] : data_in[3]; wire [8:0] layer1_3 = (data_in[2]>data_in[3])? data_in[3] : data_in[2];
        wire [8:0] layer1_4 = (data_in[4]>data_in[5])? data_in[4] : data_in[5]; wire [8:0] layer1_5 = (data_in[4]>data_in[5])? data_in[5] : data_in[4];
        wire [8:0] layer1_6 = (data_in[6]>data_in[7])? data_in[6] : data_in[7]; wire [8:0] layer1_7 = (data_in[6]>data_in[7])? data_in[7] : data_in[6];

        // Layer 2
        wire [8:0] layer2_0 = (layer1_0>layer1_2)? layer1_0 : layer1_2; wire [8:0] layer2_2 = (layer1_0>layer1_2)? layer1_2 : layer1_0;
        wire [8:0] layer2_1 = (layer1_1>layer1_3)? layer1_1 : layer1_3; wire [8:0] layer2_3 = (layer1_1>layer1_3)? layer1_3 : layer1_1;
        wire [8:0] layer2_4 = (layer1_4>layer1_6)? layer1_4 : layer1_6; wire [8:0] layer2_6 = (layer1_4>layer1_6)? layer1_6 : layer1_4;
        wire [8:0] layer2_5 = (layer1_5>layer1_7)? layer1_5 : layer1_7; wire [8:0] layer2_7 = (layer1_5>layer1_7)? layer1_7 : layer1_5;

        // Layer 3
        wire [8:0] layer3_0 = layer2_0; 
        wire [8:0] layer3_1 = (layer2_1>layer2_2)? layer2_1 : layer2_2; wire [8:0] layer3_2 = (layer2_1>layer2_2)? layer2_2 : layer2_1;
        wire [8:0] layer3_3 = layer2_3; wire [8:0] layer3_4 = layer2_4; 
        wire [8:0] layer3_5 = (layer2_5>layer2_6)? layer2_5 : layer2_6; wire [8:0] layer3_6 = (layer2_5>layer2_6)? layer2_6 : layer2_5;
        wire [8:0] layer3_7 = layer2_7;

        // Layer 4
        wire [8:0] layer4_0 = (layer3_0>layer3_4)? layer3_0 : layer3_4; wire [8:0] layer4_4 = (layer3_0>layer3_4)? layer3_4 : layer3_0;
        wire [8:0] layer4_1 = (layer3_1>layer3_5)? layer3_1 : layer3_5; wire [8:0] layer4_5 = (layer3_1>layer3_5)? layer3_5 : layer3_1;
        wire [8:0] layer4_2 = (layer3_2>layer3_6)? layer3_2 : layer3_6; wire [8:0] layer4_6 = (layer3_2>layer3_6)? layer3_6 : layer3_2;
        wire [8:0] layer4_3 = (layer3_3>layer3_7)? layer3_3 : layer3_7; wire [8:0] layer4_7 = (layer3_3>layer3_7)? layer3_7 : layer3_3;

        // Layer 5
        wire [8:0] layer5_0 = layer4_0; wire [8:0] layer5_1 = layer4_1; 
        wire [8:0] layer5_2 = (layer4_2>layer4_4)? layer4_2 : layer4_4; wire [8:0] layer5_4 = (layer4_2>layer4_4)? layer4_4 : layer4_2;
        wire [8:0] layer5_3 = (layer4_3>layer4_5)? layer4_3 : layer4_5; wire [8:0] layer5_5 = (layer4_3>layer4_5)? layer4_5 : layer4_3;
        wire [8:0] layer5_6 = layer4_6; wire [8:0] layer5_7 = layer4_7;

        // Layer 6
        wire [8:0] layer6_0 = layer5_0; 
        wire [8:0] layer6_1 = (layer5_1>layer5_2)? layer5_1 : layer5_2; wire [8:0] layer6_2 = (layer5_1>layer5_2)? layer5_2 : layer5_1;
        wire [8:0] layer6_3 = (layer5_3>layer5_4)? layer5_3 : layer5_4; wire [8:0] layer6_4 = (layer5_3>layer5_4)? layer5_4 : layer5_3;
        wire [8:0] layer6_5 = (layer5_5>layer5_6)? layer5_5 : layer5_6; wire [8:0] layer6_6 = (layer5_5>layer5_6)? layer5_6 : layer5_5;
        wire [8:0] layer6_7 = layer5_7;

        assign OUT_character[31:28] = layer6_0[3:0]; assign OUT_character[27:24] = layer6_1[3:0];
        assign OUT_character[23:20] = layer6_2[3:0]; assign OUT_character[19:16] = layer6_3[3:0];
        assign OUT_character[15:12] = layer6_4[3:0]; assign OUT_character[11:8]  = layer6_5[3:0];
        assign OUT_character[7:4]   = layer6_6[3:0]; assign OUT_character[3:0]   = layer6_7[3:0];
    end

    else if (IP_WIDTH == 7) begin : GEN_W7
        wire [8:0] layer1_0 = (data_in[0]>data_in[1])? data_in[0] : data_in[1]; wire [8:0] layer1_1 = (data_in[0]>data_in[1])? data_in[1] : data_in[0];
        wire [8:0] layer1_2 = (data_in[2]>data_in[3])? data_in[2] : data_in[3]; wire [8:0] layer1_3 = (data_in[2]>data_in[3])? data_in[3] : data_in[2];
        wire [8:0] layer1_4 = (data_in[4]>data_in[5])? data_in[4] : data_in[5]; wire [8:0] layer1_5 = (data_in[4]>data_in[5])? data_in[5] : data_in[4];
        wire [8:0] layer1_6 = data_in[6];

        wire [8:0] layer2_0 = (layer1_0>layer1_2)? layer1_0 : layer1_2; wire [8:0] layer2_2 = (layer1_0>layer1_2)? layer1_2 : layer1_0;
        wire [8:0] layer2_1 = (layer1_1>layer1_3)? layer1_1 : layer1_3; wire [8:0] layer2_3 = (layer1_1>layer1_3)? layer1_3 : layer1_1;
        wire [8:0] layer2_4 = (layer1_4>layer1_6)? layer1_4 : layer1_6; wire [8:0] layer2_6 = (layer1_4>layer1_6)? layer1_6 : layer1_4;
        wire [8:0] layer2_5 = layer1_5;

        wire [8:0] layer3_0 = layer2_0; 
        wire [8:0] layer3_1 = (layer2_1>layer2_2)? layer2_1 : layer2_2; wire [8:0] layer3_2 = (layer2_1>layer2_2)? layer2_2 : layer2_1;
        wire [8:0] layer3_3 = layer2_3; wire [8:0] layer3_4 = layer2_4; 
        wire [8:0] layer3_5 = (layer2_5>layer2_6)? layer2_5 : layer2_6; wire [8:0] layer3_6 = (layer2_5>layer2_6)? layer2_6 : layer2_5;

        wire [8:0] layer4_0 = (layer3_0>layer3_4)? layer3_0 : layer3_4; wire [8:0] layer4_4 = (layer3_0>layer3_4)? layer3_4 : layer3_0;
        wire [8:0] layer4_1 = (layer3_1>layer3_5)? layer3_1 : layer3_5; wire [8:0] layer4_5 = (layer3_1>layer3_5)? layer3_5 : layer3_1;
        wire [8:0] layer4_2 = (layer3_2>layer3_6)? layer3_2 : layer3_6; wire [8:0] layer4_6 = (layer3_2>layer3_6)? layer3_6 : layer3_2;
        wire [8:0] layer4_3 = layer3_3;

        wire [8:0] layer5_0 = layer4_0; wire [8:0] layer5_1 = layer4_1; 
        wire [8:0] layer5_2 = (layer4_2>layer4_4)? layer4_2 : layer4_4; wire [8:0] layer5_4 = (layer4_2>layer4_4)? layer4_4 : layer4_2;
        wire [8:0] layer5_3 = (layer4_3>layer4_5)? layer4_3 : layer4_5; wire [8:0] layer5_5 = (layer4_3>layer4_5)? layer4_5 : layer4_3;
        wire [8:0] layer5_6 = layer4_6;

        wire [8:0] layer6_0 = layer5_0; 
        wire [8:0] layer6_1 = (layer5_1>layer5_2)? layer5_1 : layer5_2; wire [8:0] layer6_2 = (layer5_1>layer5_2)? layer5_2 : layer5_1;
        wire [8:0] layer6_3 = (layer5_3>layer5_4)? layer5_3 : layer5_4; wire [8:0] layer6_4 = (layer5_3>layer5_4)? layer5_4 : layer5_3;
        wire [8:0] layer6_5 = (layer5_5>layer5_6)? layer5_5 : layer5_6; wire [8:0] layer6_6 = (layer5_5>layer5_6)? layer5_6 : layer5_5;

        assign OUT_character[27:24] = layer6_0[3:0]; assign OUT_character[23:20] = layer6_1[3:0];
        assign OUT_character[19:16] = layer6_2[3:0]; assign OUT_character[15:12] = layer6_3[3:0];
        assign OUT_character[11:8]  = layer6_4[3:0]; assign OUT_character[7:4]   = layer6_5[3:0];
        assign OUT_character[3:0]   = layer6_6[3:0];
    end

    else if (IP_WIDTH == 6) begin : GEN_W6
        wire [8:0] layer1_0 = (data_in[0]>data_in[1])? data_in[0] : data_in[1]; wire [8:0] layer1_1 = (data_in[0]>data_in[1])? data_in[1] : data_in[0];
        wire [8:0] layer1_2 = (data_in[2]>data_in[3])? data_in[2] : data_in[3]; wire [8:0] layer1_3 = (data_in[2]>data_in[3])? data_in[3] : data_in[2];
        wire [8:0] layer1_4 = (data_in[4]>data_in[5])? data_in[4] : data_in[5]; wire [8:0] layer1_5 = (data_in[4]>data_in[5])? data_in[5] : data_in[4];

        wire [8:0] layer2_0 = (layer1_0>layer1_2)? layer1_0 : layer1_2; wire [8:0] layer2_2 = (layer1_0>layer1_2)? layer1_2 : layer1_0;
        wire [8:0] layer2_1 = (layer1_1>layer1_3)? layer1_1 : layer1_3; wire [8:0] layer2_3 = (layer1_1>layer1_3)? layer1_3 : layer1_1;
        wire [8:0] layer2_4 = layer1_4; wire [8:0] layer2_5 = layer1_5;

        wire [8:0] layer3_0 = layer2_0; 
        wire [8:0] layer3_1 = (layer2_1>layer2_2)? layer2_1 : layer2_2; wire [8:0] layer3_2 = (layer2_1>layer2_2)? layer2_2 : layer2_1;
        wire [8:0] layer3_3 = layer2_3; wire [8:0] layer3_4 = layer2_4; wire [8:0] layer3_5 = layer2_5;

        wire [8:0] layer4_0 = layer3_0; wire [8:0] layer4_1 = layer3_1; wire [8:0] layer4_2 = layer3_2;
        wire [8:0] layer4_3 = (layer3_3>layer3_4)? layer3_3 : layer3_4; wire [8:0] layer4_4 = (layer3_3>layer3_4)? layer3_4 : layer3_3;
        wire [8:0] layer4_5 = layer3_5;

        wire [8:0] layer5_0 = layer4_0; wire [8:0] layer5_1 = layer4_1;
        wire [8:0] layer5_2 = (layer4_2>layer4_3)? layer4_2 : layer4_3; wire [8:0] layer5_3 = (layer4_2>layer4_3)? layer4_3 : layer4_2;
        wire [8:0] layer5_4 = (layer4_4>layer4_5)? layer4_4 : layer4_5; wire [8:0] layer5_5 = (layer4_4>layer4_5)? layer4_5 : layer4_4;

        wire [8:0] layer6_0 = layer5_0;
        wire [8:0] layer6_1 = (layer5_1>layer5_2)? layer5_1 : layer5_2; wire [8:0] layer6_2 = (layer5_1>layer5_2)? layer5_2 : layer5_1;
        wire [8:0] layer6_3 = (layer5_3>layer5_4)? layer5_3 : layer5_4; wire [8:0] layer6_4 = (layer5_3>layer5_4)? layer5_4 : layer5_3;
        wire [8:0] layer6_5 = layer5_5;

        wire [8:0] layer7_0 = (layer6_0>layer6_1)? layer6_0 : layer6_1; wire [8:0] layer7_1 = (layer6_0>layer6_1)? layer6_1 : layer6_0;
        wire [8:0] layer7_2 = (layer6_2>layer6_3)? layer6_2 : layer6_3; wire [8:0] layer7_3 = (layer6_2>layer6_3)? layer6_3 : layer6_2;
        wire [8:0] layer7_4 = layer6_4; wire [8:0] layer7_5 = layer6_5;

        wire [8:0] layer8_0 = layer7_0;
        wire [8:0] layer8_1 = (layer7_1>layer7_2)? layer7_1 : layer7_2; wire [8:0] layer8_2 = (layer7_1>layer7_2)? layer7_2 : layer7_1;
        wire [8:0] layer8_3 = layer7_3; wire [8:0] layer8_4 = layer7_4; wire [8:0] layer8_5 = layer7_5;

        assign OUT_character[23:20] = layer8_0[3:0]; assign OUT_character[19:16] = layer8_1[3:0];
        assign OUT_character[15:12] = layer8_2[3:0]; assign OUT_character[11:8]  = layer8_3[3:0];
        assign OUT_character[7:4]   = layer8_4[3:0]; assign OUT_character[3:0]   = layer8_5[3:0];
    end

    else if (IP_WIDTH == 5) begin : GEN_W5
        wire [8:0] layer1_0 = (data_in[0]>data_in[1])? data_in[0] : data_in[1]; wire [8:0] layer1_1 = (data_in[0]>data_in[1])? data_in[1] : data_in[0];
        wire [8:0] layer1_2 = (data_in[2]>data_in[3])? data_in[2] : data_in[3]; wire [8:0] layer1_3 = (data_in[2]>data_in[3])? data_in[3] : data_in[2];
        wire [8:0] layer1_4 = data_in[4];

        wire [8:0] layer2_0 = (layer1_0>layer1_2)? layer1_0 : layer1_2; wire [8:0] layer2_2 = (layer1_0>layer1_2)? layer1_2 : layer1_0;
        wire [8:0] layer2_1 = (layer1_1>layer1_3)? layer1_1 : layer1_3; wire [8:0] layer2_3 = (layer1_1>layer1_3)? layer1_3 : layer1_1;
        wire [8:0] layer2_4 = layer1_4;

        wire [8:0] layer3_0 = layer2_0;
        wire [8:0] layer3_1 = (layer2_1>layer2_2)? layer2_1 : layer2_2; wire [8:0] layer3_2 = (layer2_1>layer2_2)? layer2_2 : layer2_1;
        wire [8:0] layer3_3 = layer2_3; wire [8:0] layer3_4 = layer2_4;

        wire [8:0] layer4_0 = layer3_0; wire [8:0] layer4_1 = layer3_1; wire [8:0] layer4_2 = layer3_2;
        wire [8:0] layer4_3 = (layer3_3>layer3_4)? layer3_3 : layer3_4; wire [8:0] layer4_4 = (layer3_3>layer3_4)? layer3_4 : layer3_3;

        wire [8:0] layer5_0 = layer4_0; wire [8:0] layer5_1 = layer4_1;
        wire [8:0] layer5_2 = (layer4_2>layer4_3)? layer4_2 : layer4_3; wire [8:0] layer5_3 = (layer4_2>layer4_3)? layer4_3 : layer4_2;
        wire [8:0] layer5_4 = layer4_4;

        wire [8:0] layer6_0 = layer5_0;
        wire [8:0] layer6_1 = (layer5_1>layer5_2)? layer5_1 : layer5_2; wire [8:0] layer6_2 = (layer5_1>layer5_2)? layer5_2 : layer5_1;
        wire [8:0] layer6_3 = layer5_3; wire [8:0] layer6_4 = layer5_4;

        wire [8:0] layer7_0 = (layer6_0>layer6_1)? layer6_0 : layer6_1; wire [8:0] layer7_1 = (layer6_0>layer6_1)? layer6_1 : layer6_0;
        wire [8:0] layer7_2 = layer6_2; wire [8:0] layer7_3 = layer6_3; wire [8:0] layer7_4 = layer6_4;

        assign OUT_character[19:16] = layer7_0[3:0]; assign OUT_character[15:12] = layer7_1[3:0];
        assign OUT_character[11:8]  = layer7_2[3:0]; assign OUT_character[7:4]   = layer7_3[3:0];
        assign OUT_character[3:0]   = layer7_4[3:0];
    end

    else if (IP_WIDTH == 4) begin : GEN_W4
        wire [8:0] layer1_0 = (data_in[0]>data_in[1])? data_in[0] : data_in[1]; wire [8:0] layer1_1 = (data_in[0]>data_in[1])? data_in[1] : data_in[0];
        wire [8:0] layer1_2 = (data_in[2]>data_in[3])? data_in[2] : data_in[3]; wire [8:0] layer1_3 = (data_in[2]>data_in[3])? data_in[3] : data_in[2];

        wire [8:0] layer2_0 = (layer1_0>layer1_2)? layer1_0 : layer1_2; wire [8:0] layer2_2 = (layer1_0>layer1_2)? layer1_2 : layer1_0;
        wire [8:0] layer2_1 = (layer1_1>layer1_3)? layer1_1 : layer1_3; wire [8:0] layer2_3 = (layer1_1>layer1_3)? layer1_3 : layer1_1;

        wire [8:0] layer3_0 = layer2_0;
        wire [8:0] layer3_1 = (layer2_1>layer2_2)? layer2_1 : layer2_2; wire [8:0] layer3_2 = (layer2_1>layer2_2)? layer2_2 : layer2_1;
        wire [8:0] layer3_3 = layer2_3;

        assign OUT_character[15:12] = layer3_0[3:0]; assign OUT_character[11:8]  = layer3_1[3:0];
        assign OUT_character[7:4]   = layer3_2[3:0]; assign OUT_character[3:0]   = layer3_3[3:0];
    end

    else if (IP_WIDTH == 3) begin : GEN_W3
        wire [8:0] layer1_0 = (data_in[0]>data_in[1])? data_in[0] : data_in[1]; wire [8:0] layer1_1 = (data_in[0]>data_in[1])? data_in[1] : data_in[0];
        wire [8:0] layer1_2 = data_in[2];

        wire [8:0] layer2_0 = layer1_0;
        wire [8:0] layer2_1 = (layer1_1>layer1_2)? layer1_1 : layer1_2; wire [8:0] layer2_2 = (layer1_1>layer1_2)? layer1_2 : layer1_1;

        wire [8:0] layer3_0 = (layer2_0>layer2_1)? layer2_0 : layer2_1; wire [8:0] layer3_1 = (layer2_0>layer2_1)? layer2_1 : layer2_0;
        wire [8:0] layer3_2 = layer2_2;

        assign OUT_character[11:8] = layer3_0[3:0]; assign OUT_character[7:4]  = layer3_1[3:0];
        assign OUT_character[3:0]  = layer3_2[3:0];
    end
endgenerate

endmodule