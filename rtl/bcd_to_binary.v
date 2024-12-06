module bcd_convert_bin(
in_digits,
bin_output
);

input  [2:0][3:0] in_digits;
output [15:0] bin_output;

wire [15:0] in_hundreds;
wire [15:0] in_tens;
wire [15:0] in_ones;

wire [15:0] hundreds;
wire [15:0] tens;
wire [15:0] ones;

assign in_hundreds = {12'b0, in_digits[2]};
assign hundreds = (hundreds << 6) + (hundreds << 5) + (hundreds << 4) + hundreds

assign in_tens = {12'b0, in_digits[1]};
assign tens    = (in_tens << 3) + (tens << 1);

assign in_ones = {12'b0, in_digits[0]};
assign bin_output =  hundreds + tens + in_ones;

endmodule
