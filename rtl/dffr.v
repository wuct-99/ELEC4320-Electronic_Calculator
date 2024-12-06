//dff with rst

module dffr #(parameter BIT_WIDTH = 1)(
clk,
rst_n,
d,
q);

input clk;
input rst_n;
input [BIT_WIDTH -1:0]   d;
output reg [BIT_WIDTH -1:0] q;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        q <= {BIT_WIDTH{1'b0}};
				end 
				else begin
				    q <= d;
				end 
end 


endmodule 

