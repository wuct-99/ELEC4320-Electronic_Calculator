module digit_shift(
    clk,
    rst,
    input_dec,
    output_digits,
    digit_idx_is0 
);

input clk;
input rst;
input [39:0] input_dec; 
output [39:0] output_digits;
output [9:0] digit_idx_is0;

wire [3:0] output_digit0;
wire [3:0] output_digit1;
wire [3:0] output_digit2;
wire [3:0] output_digit3;
wire [3:0] output_digit4;
wire [3:0] output_digit5;
wire [3:0] output_digit6;
wire [3:0] output_digit7;
wire [3:0] output_digit8;
wire [3:0] output_digit9;
wire [39:0] dec_digit_for_display;

wire dec_digit_9t9_is0  ;
wire dec_digit_9t8_is0;
wire dec_digit_9t7_is0;
wire dec_digit_9t6_is0;
wire dec_digit_9t5_is0;
wire dec_digit_9t4_is0;
wire dec_digit_9t3_is0;
wire dec_digit_9t2_is0;
wire dec_digit_9t1_is0;
wire dec_digit_9t0_is0;

assign dec_digit_9t9_is0 = ~(|input_dec[39:36]);
assign dec_digit_9t8_is0 = ~(|input_dec[39:32]);
assign dec_digit_9t7_is0 = ~(|input_dec[39:28]);
assign dec_digit_9t6_is0 = ~(|input_dec[39:24]);
assign dec_digit_9t5_is0 = ~(|input_dec[39:20]);
assign dec_digit_9t4_is0 = ~(|input_dec[39:16]);
assign dec_digit_9t3_is0 = ~(|input_dec[39:12]);
assign dec_digit_9t2_is0 = ~(|input_dec[39:8 ]);
assign dec_digit_9t1_is0 = ~(|input_dec[39:4 ]);
assign dec_digit_9t0_is0 = ~(|input_dec[39:0 ]);

assign digit_idx_is0 = {dec_digit_9t0_is0  ,
                        dec_digit_9t1_is0,
                        dec_digit_9t2_is0,
                        dec_digit_9t3_is0,
                        dec_digit_9t4_is0,
                        dec_digit_9t5_is0,
                        dec_digit_9t6_is0,
                        dec_digit_9t7_is0,
                        dec_digit_9t8_is0,
                        dec_digit_9t9_is0};

assign dec_digit_for_display = dec_digit_9t1_is0 ? {input_dec[3:0], 36'b0}  :
                               dec_digit_9t2_is0 ? {input_dec[7:0], 32'b0}  :
                               dec_digit_9t3_is0 ? {input_dec[11:0], 28'b0} :
                               dec_digit_9t4_is0 ? {input_dec[15:0], 24'b0} :
                               dec_digit_9t5_is0 ? {input_dec[19:0], 20'b0} :
                               dec_digit_9t6_is0 ? {input_dec[23:0], 16'b0} :
                               dec_digit_9t7_is0 ? {input_dec[27:0], 12'b0} :
                               dec_digit_9t8_is0 ? {input_dec[31:0], 8'b0 } :
                               dec_digit_9t9_is0 ? {input_dec[35:0], 4'b0 } : input_dec[39:0];

assign output_digit0 = (dec_digit_9t1_is0 | dec_digit_9t2_is0 | dec_digit_9t3_is0 | dec_digit_9t4_is0 | dec_digit_9t5_is0 | dec_digit_9t6_is0 | dec_digit_9t7_is0 | dec_digit_9t8_is0 | dec_digit_9t9_is0)? 4'ha : dec_digit_for_display[3:0];
assign output_digit1 = (dec_digit_9t1_is0 | dec_digit_9t2_is0 | dec_digit_9t3_is0 | dec_digit_9t4_is0 | dec_digit_9t5_is0 | dec_digit_9t6_is0 | dec_digit_9t7_is0 | dec_digit_9t8_is0) ? 4'ha : dec_digit_for_display[7:4];
assign output_digit2 = (dec_digit_9t1_is0 | dec_digit_9t2_is0 | dec_digit_9t3_is0 | dec_digit_9t4_is0 | dec_digit_9t5_is0 | dec_digit_9t6_is0 | dec_digit_9t7_is0 )? 4'ha : dec_digit_for_display[11:8];
assign output_digit3 = (dec_digit_9t1_is0 | dec_digit_9t2_is0 | dec_digit_9t3_is0 | dec_digit_9t4_is0 | dec_digit_9t5_is0 | dec_digit_9t6_is0 )? 4'ha : dec_digit_for_display[15:12];
assign output_digit4 = (dec_digit_9t1_is0 | dec_digit_9t2_is0 | dec_digit_9t3_is0 | dec_digit_9t4_is0 | dec_digit_9t5_is0 )? 4'ha : dec_digit_for_display[19:16];
assign output_digit5 = (dec_digit_9t1_is0 | dec_digit_9t2_is0 | dec_digit_9t3_is0 | dec_digit_9t4_is0 )? 4'ha : dec_digit_for_display[23:20];
assign output_digit6 = (dec_digit_9t1_is0 | dec_digit_9t2_is0 | dec_digit_9t3_is0 ) ? 4'ha : dec_digit_for_display[27:24];
assign output_digit7 = (dec_digit_9t1_is0 | dec_digit_9t2_is0 ) ? 4'ha : dec_digit_for_display[31:28];
assign output_digit8 = (dec_digit_9t1_is0) ? 4'ha :dec_digit_for_display[35:32];
assign output_digit9 = dec_digit_for_display[39:36];

assign output_digits = {output_digit9,
                        output_digit8,
                        output_digit7,
                        output_digit6,
                        output_digit5,
                        output_digit4,
                        output_digit3,
                        output_digit2,
                        output_digit1,
                        output_digit0};

endmodule;
