

module OT_DESIGN(
    // input signals
    clk,
    rst_n,
	
    in_valid_data,
	in_data,
	
    in_valid_cmd,
	in_cmd,    
	
    // output signals
	out_valid,	
	out_data
);

input              clk;
input              rst_n;

input              in_valid_data;
input       [7:0]  in_data;

input              in_valid_cmd;
input      [9:0]  in_cmd;

output reg         out_valid;
output reg  [7:0]  out_data;

//==================================================================
// parameter & integer
//==================================================================
reg [3:0] cs, ns;
parameter idle = 4'b0000;
parameter read_cmd = 4'b0001;
parameter load_data1 = 4'b0010;
parameter load_data2 = 4'b0011;
parameter plus_state = 4'b0100;
parameter minus_state = 4'b0101;
parameter swag_state = 4'b0110;
parameter maxpool_state = 4'b0111;
parameter out_state = 4'b1000;
parameter writeback1_state = 4'b1001;
parameter writeback2_state = 4'b1010;
parameter wait_state = 4'b1011;


integer i, j;

reg [20:0] cnt, cnt_next;
reg web0;
reg cs0;
reg [11:0] address;
reg [7:0] data_in;

reg [7:0] data_out0_reg;

reg [7:0] image1[0:15][0:15], image1_next[0:15][0:15];
reg [7:0] image2[0:15][0:15], image2_next[0:15][0:15];

reg [9:0] opcode, opcode_next; 

reg [7:0] out_image[0:15][0:15], out_image_next[0:15][0:15]; 
reg [7:0] temp;

reg [100:0]	ans1, ans1_next;
reg [100:0]	ans2, ans2_next;


//==================================================================
// reg & wire
//==================================================================

// -----------------------------------------------------
// MEM
// -----------------------------------------------------

// MEM_0: 8-bit width, 4096 depth
wire        mem0_web;
wire [11:0] mem0_addr;
wire  [7:0] mem0_din;
wire  [7:0] mem0_dout;


//==================================================================
// design
//==================================================================
always@(posedge clk, negedge rst_n) begin       //output from MEMs
    if(!rst_n) begin
        data_out0_reg <= 0;
    end
    else begin
        data_out0_reg <= mem0_dout;
    end
end

always@(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        cs <= idle;
        cnt <= 0;

        for(i=0; i<16; i=i+1) begin
            for(j=0; j<16; j=j+1) begin
                image1[i][j] <= 0;
				image2[i][j] <= 0;
				out_image[i][j] <= 0;
            end
        end
        opcode <= 0;

		ans1 <= 0;
		ans2 <= 0;


    end
    else begin
        cs <= ns;
        cnt <= cnt_next;

        for(i=0; i<16; i=i+1) begin
            for(j=0; j<16; j=j+1) begin
                image1[i][j] <= image1_next[i][j];
				image2[i][j] <= image2_next[i][j];
				out_image[i][j] <= out_image_next[i][j];
            end
        end

        opcode <= opcode_next;

		ans1 <= ans1_next;
		ans2 <= ans2_next;

    end
end

always@(*) begin
    ns = cs;
    cnt_next = cnt;
	out_valid = 0;
	out_data = 0;
	data_in = 0;
    
    address = 0;
    cs0 = 0; 
    web0 = 1;

    for(i=0; i<16; i=i+1) begin
        for(j=0; j<16; j=j+1) begin
            image1_next[i][j] = image1[i][j];
			image2_next[i][j] = image2[i][j];
			out_image_next[i][j] = out_image[i][j];
        end
    end
    opcode_next = opcode;
	temp = 0;

	ans1_next = ans1;
	ans2_next = ans2;

    case(cs)
        idle: begin
			if(in_valid_data) begin
				cnt_next = cnt + 1;

				address = cnt;
                cs0 = 1; // select MEM0
                web0 = 0; // write enable
                data_in = in_data; // input data to MEM0


				if(cnt == 4095) begin
					cnt_next = 0;
					ns = read_cmd;
				end
			end

		end

		read_cmd: begin
			if(in_valid_cmd) begin
				opcode_next = in_cmd;
				ns = load_data1;
			end
		end

		load_data1: begin
			case(opcode[7:4])
                0: address = cnt;
                1: address = cnt + 256;
                2: address = cnt + 512;
                3: address = cnt + 768;
                4: address = cnt + 1024;
                5: address = cnt + 1280;
                6: address = cnt + 1536;
                7: address = cnt + 1792;
                8: address = cnt + 2048;
                9: address = cnt + 2304;
                10: address = cnt + 2560;
                11: address = cnt + 2816;
                12: address = cnt + 3072;
                13: address = cnt + 3328;
                14: address = cnt + 3584;
                15: address = cnt + 3840;
			endcase

			cs0 = 1; // select MEM0
			web0 = 1; // read enable

			cnt_next = cnt + 1;

			if(cnt >= 2) begin
				image1_next[(cnt-2)/16][(cnt-2)%16] = data_out0_reg;

				if(cnt == 257) begin
					cnt_next = 0;
					ns = load_data2;
				end
			end
		end

		load_data2: begin
			case(opcode[3:0])
				0: address = cnt;
				1: address = cnt + 256;
				2: address = cnt + 512;
				3: address = cnt + 768;
				4: address = cnt + 1024;
				5: address = cnt + 1280;
				6: address = cnt + 1536;
				7: address = cnt + 1792;
				8: address = cnt + 2048;
				9: address = cnt + 2304;
				10: address = cnt + 2560;
				11: address = cnt + 2816;
				12: address = cnt + 3072;
				13: address = cnt + 3328;
				14: address = cnt + 3584;
				15: address = cnt + 3840;
			endcase

			cs0 = 1; // select MEM0
			web0 = 1; // read enable

			cnt_next = cnt + 1;

			if(cnt >= 2) begin
				image2_next[(cnt-2)/16][(cnt-2)%16] = data_out0_reg;

				if(cnt == 257) begin
					cnt_next = 0;

					case(opcode[9:8])
						0: ns = plus_state;
						1: ns = minus_state;
						2: begin ns = swag_state;	
							ans1_next = 0;
							ans2_next = 0;
						end
						3: ns = maxpool_state;
					endcase
				end
			end
		end

		plus_state: begin
			cnt_next = cnt + 1;

			out_image_next[cnt/16][cnt%16] = (image1[cnt/16][cnt%16] + image2[cnt/16][cnt%16]) / 2;

			if(cnt == 255) begin
				cnt_next = 0;
				ns = out_state;
			end			
		end

		minus_state: begin
			cnt_next = cnt + 1;

			if(image1[cnt/16][cnt%16] > image2[cnt/16][cnt%16]) 
				out_image_next[cnt/16][cnt%16] = image1[cnt/16][cnt%16] - image2[cnt/16][cnt%16];
			else 
				out_image_next[cnt/16][cnt%16] = image2[cnt/16][cnt%16] - image1[cnt/16][cnt%16];

			if(cnt == 255) begin
				cnt_next = 0;
				ns = out_state;
			end			
		end

		swag_state: begin
			cnt_next = cnt + 1;

			image1_next[cnt/16][cnt%16] = image2[cnt/16][cnt%16];
			image2_next[cnt/16][cnt%16] = image1[cnt/16][cnt%16];

			ans1_next = ans1 + image1[cnt/16][cnt%16];
			ans2_next = ans2 + image2[cnt/16][cnt%16];

			if(cnt == 255) begin
				cnt_next = 0;
				ns = wait_state;
			end			
		end

		wait_state: begin
			cnt_next = cnt + 1;

			if(ans1 >= ans2) begin
				for(i=0; i<16; i=i+1) begin
					out_image_next[cnt][i] = image2[cnt][i];
				end
			end
			else begin
				for(i=0; i<16; i=i+1) begin
					out_image_next[cnt][i] = image1[cnt][i];
				end
			end

			if(cnt == 15) begin
				cnt_next = 0;
				ans1_next = 0;
				ans2_next = 0;
				ns = writeback1_state;
			end
		end

		writeback1_state: begin
			case(opcode[7:4])
                0: address = cnt;
                1: address = cnt + 256;
                2: address = cnt + 512;
                3: address = cnt + 768;
                4: address = cnt + 1024;
                5: address = cnt + 1280;
                6: address = cnt + 1536;
                7: address = cnt + 1792;
                8: address = cnt + 2048;
                9: address = cnt + 2304;
                10: address = cnt + 2560;
                11: address = cnt + 2816;
                12: address = cnt + 3072;
                13: address = cnt + 3328;
                14: address = cnt + 3584;
                15: address = cnt + 3840;
			endcase

			cs0 = 1; // select MEM0
			web0 = 0; // write enable

			cnt_next = cnt + 1;

			data_in = image1[cnt/16][cnt%16];

			if(cnt == 255) begin
				cnt_next = 0;
				ns = writeback2_state;
			end
		end

		writeback2_state: begin
			case(opcode[3:0])
				0: address = cnt;
				1: address = cnt + 256;
				2: address = cnt + 512;
				3: address = cnt + 768;
				4: address = cnt + 1024;
				5: address = cnt + 1280;
				6: address = cnt + 1536;
				7: address = cnt + 1792;
				8: address = cnt + 2048;
				9: address = cnt + 2304;
				10: address = cnt + 2560;
				11: address = cnt + 2816;
				12: address = cnt + 3072;
				13: address = cnt + 3328;
				14: address = cnt + 3584;
				15: address = cnt + 3840;
			endcase

			cs0 = 1; // select MEM0
			web0 = 0; // write enable

			cnt_next = cnt + 1;

			data_in = image2[cnt/16][cnt%16];

			if(cnt == 255) begin
				cnt_next = 0;
				ns = out_state;
			end
		end

		maxpool_state: begin
			cnt_next = cnt + 1;
			temp = 0;

			for(i=0; i<16; i=i+1) begin
				if(image1[cnt][i] > temp) 
					temp = image1[cnt][i];
			end
			for(i=0; i<16; i=i+1) begin
				out_image_next[cnt][i] = temp;
			end

			if(cnt == 15) begin
				cnt_next = 0;
				ns = out_state;
			end
		end

		out_state: begin
			out_valid = 1;
			cnt_next = cnt + 1;

			out_data = out_image[cnt/16][cnt%16];

			if(cnt == 255) begin
				cnt_next = 0;
				ns = read_cmd;
			end
		end

		default: begin
			ns = idle;
		end

	endcase
end

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/* 
  There are eight SRAMs in your GTE. You should not change the name of those SRAMs.
  TA will check the value in each SRAMs when your GTE is not busy.
  If you change the name of SRAMs below, you must get the fail in this lab.
  
  You should finish SRAM-related signals assignments for each SRAM.
*/
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// SRAM-related signals assignments
assign mem0_addr = address;
assign mem0_web  = web0;
assign mem0_din  = data_in;


// MEM_0, MEM_1, MEM_2, MEM_3, MEM_4, MEM_5, MEM_6, MEM_7 instantiation
SUMA180_4096X8X1BM4 MEM0(
    .A0(mem0_addr[0]), .A1(mem0_addr[1]), .A2(mem0_addr[2]), .A3(mem0_addr[3]), .A4(mem0_addr[4]), .A5(mem0_addr[5]), .A6(mem0_addr[6]), .A7(mem0_addr[7]), 
    .A8(mem0_addr[8]), .A9(mem0_addr[9]), .A10(mem0_addr[10]), .A11(mem0_addr[11]),
    .DO0(mem0_dout[0]), .DO1(mem0_dout[1]), .DO2(mem0_dout[2]), .DO3(mem0_dout[3]), .DO4(mem0_dout[4]), .DO5(mem0_dout[5]), .DO6(mem0_dout[6]), .DO7(mem0_dout[7]),
    .DI0(mem0_din[0]), .DI1(mem0_din[1]), .DI2(mem0_din[2]), .DI3(mem0_din[3]), .DI4(mem0_din[4]), .DI5(mem0_din[5]), .DI6(mem0_din[6]), .DI7(mem0_din[7]),
    .CK(clk), .WEB(mem0_web), .OE(1'b1), .CS(cs0)
);

endmodule