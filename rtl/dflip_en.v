module dflip_en #(parameter WIDTH = 1 ,
                  parameter INIT_VALUE = {WIDTH{1'b0}}) (
	clk,
	rst,
    en,
    d,
    q
);

input clk;
input rst;
input en;
input [WIDTH - 1: 0] d;
output [WIDTH - 1: 0] q;
reg [WIDTH-1:0] reg_q;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        reg_q <= INIT_VALUE;
    end
    else if(en) begin
        reg_q <= d;
    end
end

assign q = reg_q;

endmodule

