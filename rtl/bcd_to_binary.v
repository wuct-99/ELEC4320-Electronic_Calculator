module bcd_convert_bin(
clk,
rst_n,
in_digits,
bin_output,
bin_output_unsign,
sign_output
);

input  clk;
input  rst_n;

input  [3:0][3:0] in_digits;
output reg [15:0] bin_output;
output reg [15:0] bin_output_unsign;
output reg sign;
wire [15:0] in_hundreds;
wire [15:0] in_tens;
wire [15:0] in_ones;
wire 	      sign;
wire [15:0] hundreds;
wire [15:0] tens;
wire [15:0] ones;
wire [15:0] bin_output_tmp;
wire [15:0] bin_output_unsign_tmp;
assign sign = (~|in_digits[3]);
assign in_hundreds = {12'b0, in_digits[2]};
assign hundreds = (hundreds << 6) + (hundreds << 5) + (hundreds << 4) + hundreds

assign in_tens = {12'b0, in_digits[1]};
assign tens    = (in_tens << 3) + (tens << 1);

assign in_ones = {12'b0, in_digits[0]};
assign bin_output_tmp =  sign? (~(hundreds + tens + in_ones) + 1) : (hundreds + tens + in_ones);
assign bin_output_unsign_tmp = (hundreds + tens + in_ones);
always @(posedge clk or negedge rst_n) begin
    if(rst_n) begin
        bin_output <= 16'b0;
        bin_output_unsign <= 16'b0;
        bin_output_sign <= 'b0;
    end
    else begin
        bin_output <= bin_output_tmp;
        bin_output_unsign <= bin_output_unsign_tmp;
        bin_output_sign <= sign;
    end
end

endmodule
