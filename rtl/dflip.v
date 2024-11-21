module dflip #(parameter WIDTH = 1 ,
               parameter INIT_VALUE = {WIDTH{1'b0}}) (
	clk,
	rst,
    d,
    q
);

input clk;
input rst;
input [WIDTH - 1: 0] d;
output reg [WIDTH - 1: 0] q;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        q <= INIT_VALUE;
    end
    else begin
        q <= d;
    end
end

endmodule

