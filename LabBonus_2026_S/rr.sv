module rr #(
    parameter int N = 8
)(
    input  logic         clk,
    input  logic         rst_n,
    input  logic [N-1:0] req,
    output logic [N-1:0] gnt
);

    reg [N-1:0] gnt_last;
    integer i, j, k;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)       gnt_last <= {1'b1, {(N-1){1'b0}}};
        else if (|gnt)    gnt_last <= gnt;
    end

    always_comb begin
        gnt = '0;
        for (i = 0; i < N; i = i + 1) begin
	    if (gnt_last[i]==1'b1) begin
	       for (j = 1; j < N; j = j + 1) begin
		    k = (i+j >= N) ? i+j-N : i+j;
		    if (req[k]==1'b1) begin
		        gnt[k]=1'b1;
			break;
		    end
               end
            end
        end
    end
   
endmodule

