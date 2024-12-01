module debounce #(parameter WIDTH = 1)(
    clk,
    rst,
    data_in, 
    data_out
);

input clk;
input rst;
input [WIDTH - 1:0] data_in;
output [WIDTH - 1:0] data_out;

wire [WIDTH - 1:0] data_d1;
wire [WIDTH - 1:0] data_d2;
wire [WIDTH - 1:0] data_d3;

dflip #(WIDTH) debounce_ff1 (.clk(clk), .rst(rst), .d(data_in), .q(data_d1));
dflip #(WIDTH) debounce_ff2 (.clk(clk), .rst(rst), .d(data_d1), .q(data_d2));
dflip #(WIDTH) debounce_ff3 (.clk(clk), .rst(rst), .d(data_d2), .q(data_d3));

assign data_out = data_d2 & (~data_d3);

endmodule
