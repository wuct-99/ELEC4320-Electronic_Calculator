module bin2decdigit (
    clk,
    rst,
    bin2decdigit_init,
    bin2decdigit_en,
    input_bin,
    output_dec 
);

input clk;
input rst;
input bin2decdigit_init;
input bin2decdigit_en;
input [31:0] input_bin;
output [39:0] output_dec; 

wire [71:0] dec_digit;
wire [71:0] dec_digit_q;
wire [71:0] dec_digit_shift;

assign dec_digit[31:0]  = dec_digit_q[31:0];
assign dec_digit[35:32] = dec_digit_q[35:32] >= 4'h5 ? dec_digit_q[35:32] + 4'h3 : dec_digit_q[35:32];
assign dec_digit[39:36] = dec_digit_q[39:36] >= 4'h5 ? dec_digit_q[39:36] + 4'h3 : dec_digit_q[39:36];
assign dec_digit[43:40] = dec_digit_q[43:40] >= 4'h5 ? dec_digit_q[43:40] + 4'h3 : dec_digit_q[43:40];
assign dec_digit[47:44] = dec_digit_q[47:44] >= 4'h5 ? dec_digit_q[47:44] + 4'h3 : dec_digit_q[47:44];
assign dec_digit[51:48] = dec_digit_q[51:48] >= 4'h5 ? dec_digit_q[51:48] + 4'h3 : dec_digit_q[51:48];
assign dec_digit[55:52] = dec_digit_q[55:52] >= 4'h5 ? dec_digit_q[55:52] + 4'h3 : dec_digit_q[55:52];
assign dec_digit[59:56] = dec_digit_q[59:56] >= 4'h5 ? dec_digit_q[59:56] + 4'h3 : dec_digit_q[59:56];
assign dec_digit[63:60] = dec_digit_q[63:60] >= 4'h5 ? dec_digit_q[63:60] + 4'h3 : dec_digit_q[63:60];
assign dec_digit[67:64] = dec_digit_q[67:64] >= 4'h5 ? dec_digit_q[67:64] + 4'h3 : dec_digit_q[67:64];
assign dec_digit[71:68] = dec_digit_q[71:68] >= 4'h5 ? dec_digit_q[71:68] + 4'h3 : dec_digit_q[71:68];
assign dec_digit_shift = bin2decdigit_init ? {39'b0, input_bin, 1'b0} : dec_digit << 1'b1;
assign dec_digit_en = bin2decdigit_en;

dflip_en #(72) dec_digit_ff (.clk(clk), .rst(rst), .en(dec_digit_en), .d(dec_digit_shift), .q(dec_digit_q));
assign output_dec = dec_digit_q[71:32];

endmodule
