module display_module(
.clk,
.rst_n,
.clk_60_hz,
.in_digits_a,
.in_digits_b,
.display_mode,
.out_anode,
.out_led_val
);

input clk;
input rst_n;
input clk_60_hz;
input [3:0][3:0] in_digits_a;
input [3:0][3:0] in_digits_b;
input [1:0]      display_mode;

output [3:0] out_anode;
output [7:0] out_led_val;


endmodule 
