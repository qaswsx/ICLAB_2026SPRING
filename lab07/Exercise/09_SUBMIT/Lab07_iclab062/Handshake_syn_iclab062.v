// module Handshake_syn #(parameter WIDTH=8) (
//     sclk,
//     dclk,
//     rst_n,
//     sready,
//     din,
//     dbusy,
//     sidle,
//     dvalid,
//     dout,

//     flag_handshake_to_clk1,
//     flag_clk1_to_handshake,

//     flag_handshake_to_clk2,
//     flag_clk2_to_handshake
// );

// //==============================================================
// // I/O
// //==============================================================
// input               sclk, dclk;
// input               rst_n;
// input               sready;
// input  [WIDTH-1:0]  din;
// input               dbusy;
// output              sidle;
// output reg          dvalid;
// output reg [WIDTH-1:0] dout;

// output flag_handshake_to_clk1;
// input  flag_clk1_to_handshake;

// output flag_handshake_to_clk2;
// input  flag_clk2_to_handshake;

// reg  sreq;  // sreq==1 "This data has been locked and is awaiting processing by the other party." 
// wire dreq;  // dreq==1 "The destination sees an ongoing request." 
// reg  dack;  // dack==1 "I have received this data." 
// wire sack;  // sack==1 "The other party has replied with ACK."

// assign sidle = (~sreq) && (~sack);

// NDFF_syn req (.D(sreq), .Q(dreq), .clk(dclk), .rst_n(rst_n));
// NDFF_syn ack (.D(dack), .Q(sack), .clk(sclk), .rst_n(rst_n));

// always @(posedge sclk or negedge rst_n) begin
//     if (~rst_n) begin
//         sreq <= 0;
//     end 
//     else begin
//         if (sack) begin
//             sreq <= 0;
//         end         
//         else if (sready) begin
//             sreq <= 1;
//         end   
//         else begin
//             sreq <= sreq;
//         end             
//     end
// end

// always @(posedge dclk or negedge rst_n) begin
//     if (~rst_n) begin
//         dack <= 0;
//     end 
//     else begin
//         dack <= dreq;
//     end
// end

// wire fire_d = (~dack) & dreq & (~dbusy);

// always @(posedge dclk or negedge rst_n) begin
//     if (~rst_n) begin
//         dvalid <= 0;
//         dout   <= 0;
//     end 
//     else begin
//         dvalid <= fire_d;
//         if (fire_d) begin
//             dout <= din;     
//         end
//     end
// end

// endmodule




module Handshake_syn #(parameter WIDTH=8) ( 
    input               sclk, dclk,
    input               rst_n,
    input               sready,
    input  [WIDTH-1:0]  din,
    input               dbusy,
    output              sidle,
    output reg          dvalid,
    output reg [WIDTH-1:0] dout,

    output flag_handshake_to_clk1,
    input  flag_clk1_to_handshake,
    output flag_handshake_to_clk2,
    input  flag_clk2_to_handshake
);

reg  sreq;
wire dreq;
reg  dack;
wire sack;
reg [WIDTH-1:0] sdata; 

NDFF_syn req_sync (.D(sreq), .Q(dreq), .clk(dclk), .rst_n(rst_n));
NDFF_syn ack_sync (.D(dack), .Q(sack), .clk(sclk), .rst_n(rst_n));

//--------------------------------------------------------------
// Source Domain Logic (sclk)
//--------------------------------------------------------------
assign sidle = (~sreq) && (~sack);

always @(posedge sclk or negedge rst_n) begin
    if (~rst_n) begin
        sreq  <= 1'b0;
        sdata <= 0;
    end else begin
        if (sready && sidle) begin
            sreq  <= 1'b1;
            sdata <= din; 
        end 
        else if (sack) begin
            sreq  <= 1'b0;
        end
    end
end

//--------------------------------------------------------------
// Destination Domain Logic (dclk)
//--------------------------------------------------------------
always @(posedge dclk or negedge rst_n) begin
    if (~rst_n) begin
        dack <= 1'b0;
    end 
    else begin
        dack <= dreq;
    end
end

wire fire_d = dreq && (~dack) && (~dbusy);

always @(posedge dclk or negedge rst_n) begin
    if (~rst_n) begin
        dvalid <= 1'b0;
        dout   <= 0;
    end 
    else begin
        dvalid <= fire_d;
        if (fire_d) begin
            dout <= sdata; 
        end
    end
end

endmodule