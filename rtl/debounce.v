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

wire [WIDTH - 1:0] data_d0;
wire [WIDTH - 1:0] data_d1;
wire [WIDTH - 1:0] data_d2;
wire [WIDTH - 1:0] data_d3;
wire [WIDTH - 1:0] data_d4;
wire [WIDTH - 1:0] data_d5;
wire [WIDTH - 1:0] data_d6;
wire [WIDTH - 1:0] data_d7;
wire [WIDTH - 1:0] data_d8;
wire [WIDTH - 1:0] data_d9;

dflip #(WIDTH) debounce_ff0 (.clk(clk), .rst(rst), .d(data_in), .q(data_d0));
dflip #(WIDTH) debounce_ff1 (.clk(clk), .rst(rst), .d(data_d0), .q(data_d1));
dflip #(WIDTH) debounce_ff2 (.clk(clk), .rst(rst), .d(data_d1), .q(data_d2));
dflip #(WIDTH) debounce_ff3 (.clk(clk), .rst(rst), .d(data_d2), .q(data_d3));
dflip #(WIDTH) debounce_ff4 (.clk(clk), .rst(rst), .d(data_d3), .q(data_d4));
dflip #(WIDTH) debounce_ff5 (.clk(clk), .rst(rst), .d(data_d4), .q(data_d5));
dflip #(WIDTH) debounce_ff6 (.clk(clk), .rst(rst), .d(data_d5), .q(data_d6));
dflip #(WIDTH) debounce_ff7 (.clk(clk), .rst(rst), .d(data_d6), .q(data_d7));
dflip #(WIDTH) debounce_ff8 (.clk(clk), .rst(rst), .d(data_d7), .q(data_d8));
dflip #(WIDTH) debounce_ff9 (.clk(clk), .rst(rst), .d(data_d8), .q(data_d9));
//get the edge 
assign data_out = data_d2 & (~data_d3);

endmodule
