module frac2int(
    clk,
    rst,
    cvt_cnt_q,
    input_754,
    fraction_dec_qual,
    int_dec_qual,
    lead0_num,
    i754_overflow
);

input clk;
input rst;
input [31:0] input_754;
input [1:0] cvt_cnt_q;
output [31:0] fraction_dec_qual;
output [31:0] int_dec_qual;
output [2:0]  lead0_num;
output i754_overflow;


wire [7:0] exp;
wire [23:0] mantissa;
assign exp = input_754[30:23];
assign mantissa = {1'b1, input_754[22:0]};

wire signed [7:0] exp_qual;
assign exp_qual = exp - 8'd127;

parameter signed PINT_23 = 8'd23;
parameter signed NINT_16 = -8'd16;

assign i754_overflow = exp_qual > PINT_23 | exp_qual < NINT_16 ;

wire [23:0] mantissa_shift;
assign mantissa_shift = mantissa >> ~exp_qual+1;

wire exp_qual_eq_p23;
wire exp_qual_eq_p22;
wire exp_qual_eq_p21;
wire exp_qual_eq_p20;
wire exp_qual_eq_p19;
wire exp_qual_eq_p18;
wire exp_qual_eq_p17;
wire exp_qual_eq_p16;
wire exp_qual_eq_p15;
wire exp_qual_eq_p14;
wire exp_qual_eq_p13;
wire exp_qual_eq_p12;
wire exp_qual_eq_p11;
wire exp_qual_eq_p10;
wire exp_qual_eq_p9 ;
wire exp_qual_eq_p8 ;
wire exp_qual_eq_p7 ;
wire exp_qual_eq_p6 ;
wire exp_qual_eq_p5 ;
wire exp_qual_eq_p4 ;
wire exp_qual_eq_p3 ;
wire exp_qual_eq_p2 ;
wire exp_qual_eq_p1 ;
wire exp_qual_eq_p0 ;

assign exp_qual_eq_p23 = exp_qual == 8'd23;
assign exp_qual_eq_p22 = exp_qual == 8'd22;
assign exp_qual_eq_p21 = exp_qual == 8'd21;
assign exp_qual_eq_p20 = exp_qual == 8'd20;
assign exp_qual_eq_p19 = exp_qual == 8'd19;
assign exp_qual_eq_p18 = exp_qual == 8'd18;
assign exp_qual_eq_p17 = exp_qual == 8'd17;
assign exp_qual_eq_p16 = exp_qual == 8'd16;
assign exp_qual_eq_p15 = exp_qual == 8'd15;
assign exp_qual_eq_p14 = exp_qual == 8'd14;
assign exp_qual_eq_p13 = exp_qual == 8'd13;
assign exp_qual_eq_p12 = exp_qual == 8'd12;
assign exp_qual_eq_p11 = exp_qual == 8'd11;
assign exp_qual_eq_p10 = exp_qual == 8'd10;
assign exp_qual_eq_p9  = exp_qual == 8'd9 ;
assign exp_qual_eq_p8  = exp_qual == 8'd8 ;
assign exp_qual_eq_p7  = exp_qual == 8'd7 ;
assign exp_qual_eq_p6  = exp_qual == 8'd6 ;
assign exp_qual_eq_p5  = exp_qual == 8'd5 ;
assign exp_qual_eq_p4  = exp_qual == 8'd4 ;
assign exp_qual_eq_p3  = exp_qual == 8'd3 ;
assign exp_qual_eq_p2  = exp_qual == 8'd2 ;
assign exp_qual_eq_p1  = exp_qual == 8'd1 ;
assign exp_qual_eq_p0  = exp_qual == 8'd0 ;

wire cvt_lv0_en;
wire cvt_lv1_en;
wire cvt_lv2_en;
wire cvt_lv3_en;

assign cvt_lv0_en = cvt_cnt_q == 2'b0;
assign cvt_lv1_en = cvt_cnt_q == 2'b1;
assign cvt_lv2_en = cvt_cnt_q == 2'b10;
assign cvt_lv3_en = cvt_cnt_q == 2'b11;

wire [31:0] integer_part_dec;
assign integer_part_dec = {32{exp_qual_eq_p23}} & {8'b0 , mantissa[23:0 ]} |
                          {32{exp_qual_eq_p22}} & {9'b0 , mantissa[23:1 ]} |
                          {32{exp_qual_eq_p21}} & {10'b0, mantissa[23:2 ]} |
                          {32{exp_qual_eq_p20}} & {11'b0, mantissa[23:3 ]} |
                          {32{exp_qual_eq_p19}} & {12'b0, mantissa[23:4 ]} |
                          {32{exp_qual_eq_p18}} & {13'b0, mantissa[23:5 ]} |
                          {32{exp_qual_eq_p17}} & {14'b0, mantissa[23:6 ]} |
                          {32{exp_qual_eq_p16}} & {15'b0, mantissa[23:7 ]} |
                          {32{exp_qual_eq_p15}} & {16'b0, mantissa[23:8 ]} |
                          {32{exp_qual_eq_p14}} & {17'b0, mantissa[23:9 ]} |
                          {32{exp_qual_eq_p13}} & {18'b0, mantissa[23:10]} |
                          {32{exp_qual_eq_p12}} & {19'b0, mantissa[23:11]} |
                          {32{exp_qual_eq_p11}} & {20'b0, mantissa[23:12]} |
                          {32{exp_qual_eq_p10}} & {21'b0, mantissa[23:13]} |
                          {32{exp_qual_eq_p9 }} & {22'b0, mantissa[23:14]} |
                          {32{exp_qual_eq_p8 }} & {23'b0, mantissa[23:15]} |
                          {32{exp_qual_eq_p7 }} & {24'b0, mantissa[23:16]} |
                          {32{exp_qual_eq_p6 }} & {25'b0, mantissa[23:17]} |
                          {32{exp_qual_eq_p5 }} & {26'b0, mantissa[23:18]} |
                          {32{exp_qual_eq_p4 }} & {27'b0, mantissa[23:19]} |
                          {32{exp_qual_eq_p3 }} & {28'b0, mantissa[23:20]} |
                          {32{exp_qual_eq_p2 }} & {29'b0, mantissa[23:21]} |
                          {32{exp_qual_eq_p1 }} & {30'b0, mantissa[23:22]} | 
                          {32{exp_qual_eq_p0 }} & {31'b0, mantissa[23   ]} ;

wire [22:0] pos_exp_fraction_part;
assign pos_exp_fraction_part = {23{exp_qual_eq_p15}} & {mantissa[7:0 ], 15'b0} |                           
                               {23{exp_qual_eq_p14}} & {mantissa[8:0 ], 14'b0} |                           
                               {23{exp_qual_eq_p13}} & {mantissa[9:0 ], 13'b0} |                           
                               {23{exp_qual_eq_p12}} & {mantissa[10:0], 12'b0} |
                               {23{exp_qual_eq_p11}} & {mantissa[11:0], 11'b0} |
                               {23{exp_qual_eq_p10}} & {mantissa[12:0], 10'b0} |
                               {23{exp_qual_eq_p9 }} & {mantissa[13:0],  9'b0} |
                               {23{exp_qual_eq_p8 }} & {mantissa[14:0],  8'b0} |
                               {23{exp_qual_eq_p7 }} & {mantissa[15:0],  7'b0} |
                               {23{exp_qual_eq_p6 }} & {mantissa[16:0],  6'b0} |
                               {23{exp_qual_eq_p5 }} & {mantissa[17:0],  5'b0} |
                               {23{exp_qual_eq_p4 }} & {mantissa[18:0],  4'b0} |
                               {23{exp_qual_eq_p3 }} & {mantissa[19:0],  3'b0} |
                               {23{exp_qual_eq_p2 }} & {mantissa[20:0],  2'b0} |
                               {23{exp_qual_eq_p1 }} & {mantissa[21:0],  1'b0} | 
                               {23{exp_qual_eq_p0 }} & {mantissa[22:0]       } ;

wire [22:0] neg_exp_fraction_part;
assign neg_exp_fraction_part = mantissa_shift[22:0];

wire [22:0] exp_fraction_part;
assign exp_fraction_part = exp_qual[7] ? neg_exp_fraction_part : pos_exp_fraction_part;

wire [32:0] exp_fraction_2n1;
wire [32:0] exp_fraction_2n2;
wire [32:0] exp_fraction_2n3;
wire [32:0] exp_fraction_2n4;
wire [32:0] exp_fraction_2n5;
wire [32:0] exp_fraction_2n6;
wire [32:0] exp_fraction_2n7;
wire [32:0] exp_fraction_2n8;
wire [32:0] exp_fraction_2n9;
wire [32:0] exp_fraction_2n10;
wire [32:0] exp_fraction_2n11;
wire [32:0] exp_fraction_2n12;
wire [32:0] exp_fraction_2n13;
wire [32:0] exp_fraction_2n14;
wire [32:0] exp_fraction_2n15;
wire [32:0] exp_fraction_2n16;
wire [32:0] exp_fraction_2n17;
wire [32:0] exp_fraction_2n18;
wire [32:0] exp_fraction_2n19;
wire [32:0] exp_fraction_2n20;
wire [32:0] exp_fraction_2n21;
wire [32:0] exp_fraction_2n22;
wire [32:0] exp_fraction_2n23;

assign exp_fraction_2n1  = {32{exp_fraction_part[22]}} & 32'd5_0000_0000;
assign exp_fraction_2n2  = {32{exp_fraction_part[21]}} & 32'd2_5000_0000;
assign exp_fraction_2n3  = {32{exp_fraction_part[20]}} & 32'd1_2500_0000;
assign exp_fraction_2n4  = {32{exp_fraction_part[19]}} & 32'd0_6250_0000;
assign exp_fraction_2n5  = {32{exp_fraction_part[18]}} & 32'd0_3125_0000;
assign exp_fraction_2n6  = {32{exp_fraction_part[17]}} & 32'd0_1562_5000;
assign exp_fraction_2n7  = {32{exp_fraction_part[16]}} & 32'd0_0781_2500;
assign exp_fraction_2n8  = {32{exp_fraction_part[15]}} & 32'd0_0390_6250;
assign exp_fraction_2n9  = {32{exp_fraction_part[14]}} & 32'd0_0195_3125;
assign exp_fraction_2n10 = {32{exp_fraction_part[13]}} & 32'd0_0097_6562;
assign exp_fraction_2n11 = {32{exp_fraction_part[12]}} & 32'd0_0048_8281;
assign exp_fraction_2n12 = {32{exp_fraction_part[11]}} & 32'd0_0024_4140;
assign exp_fraction_2n13 = {32{exp_fraction_part[10]}} & 32'd0_0012_2070;
assign exp_fraction_2n14 = {32{exp_fraction_part[9 ]}} & 32'd0_0006_1035;
assign exp_fraction_2n15 = {32{exp_fraction_part[8 ]}} & 32'd0_0003_0517;
assign exp_fraction_2n16 = {32{exp_fraction_part[7 ]}} & 32'd0_0001_5258;
assign exp_fraction_2n17 = {32{exp_fraction_part[6 ]}} & 32'd0_0000_7629;
assign exp_fraction_2n18 = {32{exp_fraction_part[5 ]}} & 32'd0_0000_3814;
assign exp_fraction_2n19 = {32{exp_fraction_part[4 ]}} & 32'd0_0000_1907;
assign exp_fraction_2n20 = {32{exp_fraction_part[3 ]}} & 32'd0_0000_0953;
assign exp_fraction_2n21 = {32{exp_fraction_part[2 ]}} & 32'd0_0000_0476;
assign exp_fraction_2n22 = {32{exp_fraction_part[1 ]}} & 32'd0_0000_0238;
assign exp_fraction_2n23 = {32{exp_fraction_part[0 ]}} & 32'd0_0000_0119;

wire [31:0] exp_fraction_dec;
wire [31:0] exp_fraction_dec_lv0_0 ;
wire [31:0] exp_fraction_dec_lv0_1 ;
wire [31:0] exp_fraction_dec_lv0_2 ;
wire [31:0] exp_fraction_dec_lv0_3 ;
wire [31:0] exp_fraction_dec_lv0_4 ;
wire [31:0] exp_fraction_dec_lv0_5 ;
wire [31:0] exp_fraction_dec_lv0_6 ;
wire [31:0] exp_fraction_dec_lv0_7 ;
wire [31:0] exp_fraction_dec_lv0_8 ;
wire [31:0] exp_fraction_dec_lv0_9 ;
wire [31:0] exp_fraction_dec_lv0_10;
wire [31:0] exp_fraction_dec_lv1_0 ;
wire [31:0] exp_fraction_dec_lv1_1 ;
wire [31:0] exp_fraction_dec_lv1_2 ;
wire [31:0] exp_fraction_dec_lv1_3 ;
wire [31:0] exp_fraction_dec_lv1_4 ;
wire [31:0] exp_fraction_dec_lv1_5 ;
wire [31:0] exp_fraction_dec_lv2_0 ;
wire [31:0] exp_fraction_dec_lv2_1 ;
wire [31:0] exp_fraction_dec_lv2_2 ;
wire [31:0] exp_fraction_dec_lv3;

wire [31:0] exp_fraction_dec_lv0_0_q;
wire [31:0] exp_fraction_dec_lv0_1_q;
wire [31:0] exp_fraction_dec_lv0_2_q;
wire [31:0] exp_fraction_dec_lv0_3_q;
wire [31:0] exp_fraction_dec_lv0_4_q;
wire [31:0] exp_fraction_dec_lv0_5_q;
wire [31:0] exp_fraction_dec_lv0_6_q;
wire [31:0] exp_fraction_dec_lv0_7_q;
wire [31:0] exp_fraction_dec_lv0_8_q;
wire [31:0] exp_fraction_dec_lv0_9_q;
wire [31:0] exp_fraction_dec_lv0_10_q;
wire [31:0] exp_fraction_dec_lv1_0_q;
wire [31:0] exp_fraction_dec_lv1_1_q;
wire [31:0] exp_fraction_dec_lv1_2_q;
wire [31:0] exp_fraction_dec_lv1_3_q;
wire [31:0] exp_fraction_dec_lv1_4_q;
wire [31:0] exp_fraction_dec_lv1_5_q;
wire [31:0] exp_fraction_dec_lv2_0_q;
wire [31:0] exp_fraction_dec_lv2_1_q;
wire [31:0] exp_fraction_dec_lv2_2_q;
wire [31:0] exp_fraction_dec_lv3_q;

assign exp_fraction_dec_lv0_0  = exp_fraction_2n1 + exp_fraction_2n2;
assign exp_fraction_dec_lv0_1  = exp_fraction_2n3 + exp_fraction_2n4;
assign exp_fraction_dec_lv0_2  = exp_fraction_2n5 + exp_fraction_2n6;
assign exp_fraction_dec_lv0_3  = exp_fraction_2n7 + exp_fraction_2n8;
assign exp_fraction_dec_lv0_4  = exp_fraction_2n9 + exp_fraction_2n10;
assign exp_fraction_dec_lv0_5  = exp_fraction_2n11 + exp_fraction_2n12;
assign exp_fraction_dec_lv0_6  = exp_fraction_2n13 + exp_fraction_2n14;
assign exp_fraction_dec_lv0_7  = exp_fraction_2n15 + exp_fraction_2n16;
assign exp_fraction_dec_lv0_8  = exp_fraction_2n17 + exp_fraction_2n18;
assign exp_fraction_dec_lv0_9  = exp_fraction_2n19 + exp_fraction_2n20;
assign exp_fraction_dec_lv0_10 = exp_fraction_2n21 + exp_fraction_2n22 + exp_fraction_2n23;

dflip_en #(32) exp_fraction_dec_lv0_0_ff  (.clk(clk), .rst(rst), .en(cvt_lv0_en), .d(exp_fraction_dec_lv0_0 ), .q(exp_fraction_dec_lv0_0_q));
dflip_en #(32) exp_fraction_dec_lv0_1_ff  (.clk(clk), .rst(rst), .en(cvt_lv0_en), .d(exp_fraction_dec_lv0_1 ), .q(exp_fraction_dec_lv0_1_q));
dflip_en #(32) exp_fraction_dec_lv0_2_ff  (.clk(clk), .rst(rst), .en(cvt_lv0_en), .d(exp_fraction_dec_lv0_2 ), .q(exp_fraction_dec_lv0_2_q));
dflip_en #(32) exp_fraction_dec_lv0_3_ff  (.clk(clk), .rst(rst), .en(cvt_lv0_en), .d(exp_fraction_dec_lv0_3 ), .q(exp_fraction_dec_lv0_3_q));
dflip_en #(32) exp_fraction_dec_lv0_4_ff  (.clk(clk), .rst(rst), .en(cvt_lv0_en), .d(exp_fraction_dec_lv0_4 ), .q(exp_fraction_dec_lv0_4_q));
dflip_en #(32) exp_fraction_dec_lv0_5_ff  (.clk(clk), .rst(rst), .en(cvt_lv0_en), .d(exp_fraction_dec_lv0_5 ), .q(exp_fraction_dec_lv0_5_q));
dflip_en #(32) exp_fraction_dec_lv0_6_ff  (.clk(clk), .rst(rst), .en(cvt_lv0_en), .d(exp_fraction_dec_lv0_6 ), .q(exp_fraction_dec_lv0_6_q));
dflip_en #(32) exp_fraction_dec_lv0_7_ff  (.clk(clk), .rst(rst), .en(cvt_lv0_en), .d(exp_fraction_dec_lv0_7 ), .q(exp_fraction_dec_lv0_7_q));
dflip_en #(32) exp_fraction_dec_lv0_8_ff  (.clk(clk), .rst(rst), .en(cvt_lv0_en), .d(exp_fraction_dec_lv0_8 ), .q(exp_fraction_dec_lv0_8_q));
dflip_en #(32) exp_fraction_dec_lv0_9_ff  (.clk(clk), .rst(rst), .en(cvt_lv0_en), .d(exp_fraction_dec_lv0_9 ), .q(exp_fraction_dec_lv0_9_q));
dflip_en #(32) exp_fraction_dec_lv0_10_ff (.clk(clk), .rst(rst), .en(cvt_lv0_en), .d(exp_fraction_dec_lv0_10), .q(exp_fraction_dec_lv0_10_q));

assign exp_fraction_dec_lv1_0  = exp_fraction_dec_lv0_0_q + exp_fraction_dec_lv0_1_q;
assign exp_fraction_dec_lv1_1  = exp_fraction_dec_lv0_2_q + exp_fraction_dec_lv0_3_q;
assign exp_fraction_dec_lv1_2  = exp_fraction_dec_lv0_4_q + exp_fraction_dec_lv0_5_q;
assign exp_fraction_dec_lv1_3  = exp_fraction_dec_lv0_6_q + exp_fraction_dec_lv0_7_q;
assign exp_fraction_dec_lv1_4  = exp_fraction_dec_lv0_8_q + exp_fraction_dec_lv0_8_q;
assign exp_fraction_dec_lv1_5  = exp_fraction_dec_lv0_9_q + exp_fraction_dec_lv0_10_q;

dflip_en #(32) exp_fraction_dec_lv1_0_ff  (.clk(clk), .rst(rst), .en(cvt_lv1_en), .d(exp_fraction_dec_lv1_0 ), .q(exp_fraction_dec_lv1_0_q));
dflip_en #(32) exp_fraction_dec_lv1_1_ff  (.clk(clk), .rst(rst), .en(cvt_lv1_en), .d(exp_fraction_dec_lv1_1 ), .q(exp_fraction_dec_lv1_1_q));
dflip_en #(32) exp_fraction_dec_lv1_2_ff  (.clk(clk), .rst(rst), .en(cvt_lv1_en), .d(exp_fraction_dec_lv1_2 ), .q(exp_fraction_dec_lv1_2_q));
dflip_en #(32) exp_fraction_dec_lv1_3_ff  (.clk(clk), .rst(rst), .en(cvt_lv1_en), .d(exp_fraction_dec_lv1_3 ), .q(exp_fraction_dec_lv1_3_q));
dflip_en #(32) exp_fraction_dec_lv1_4_ff  (.clk(clk), .rst(rst), .en(cvt_lv1_en), .d(exp_fraction_dec_lv1_4 ), .q(exp_fraction_dec_lv1_4_q));
dflip_en #(32) exp_fraction_dec_lv1_5_ff  (.clk(clk), .rst(rst), .en(cvt_lv1_en), .d(exp_fraction_dec_lv1_5 ), .q(exp_fraction_dec_lv1_5_q));

assign exp_fraction_dec_lv2_0  = exp_fraction_dec_lv1_0_q + exp_fraction_dec_lv1_1_q;
assign exp_fraction_dec_lv2_1  = exp_fraction_dec_lv1_2_q + exp_fraction_dec_lv1_3_q;
assign exp_fraction_dec_lv2_2  = exp_fraction_dec_lv1_4_q + exp_fraction_dec_lv1_5_q;

dflip_en #(32) exp_fraction_dec_lv2_0_ff  (.clk(clk), .rst(rst), .en(cvt_lv2_en), .d(exp_fraction_dec_lv2_0 ), .q(exp_fraction_dec_lv2_0_q));
dflip_en #(32) exp_fraction_dec_lv2_1_ff  (.clk(clk), .rst(rst), .en(cvt_lv2_en), .d(exp_fraction_dec_lv2_1 ), .q(exp_fraction_dec_lv2_1_q));
dflip_en #(32) exp_fraction_dec_lv2_2_ff  (.clk(clk), .rst(rst), .en(cvt_lv2_en), .d(exp_fraction_dec_lv2_2 ), .q(exp_fraction_dec_lv2_2_q));

assign exp_fraction_dec_lv3  = exp_fraction_dec_lv2_0_q + exp_fraction_dec_lv2_1_q + exp_fraction_dec_lv2_2_q;
dflip_en #(32) exp_fraction_dec_lv3_2_ff  (.clk(clk), .rst(rst), .en(cvt_lv3_en), .d(exp_fraction_dec_lv3), .q(exp_fraction_dec));

wire input_is0;
assign input_is0 = ~(|input_754);
assign fraction_dec_qual = input_is0 ? 32'b0 : exp_fraction_dec;
assign int_dec_qual      = input_is0 ? 16'b0 : integer_part_dec;

wire signed [31:0] frac_dec_0;
wire signed [31:0] frac_dec_1;
wire signed [31:0] frac_dec_2;
wire signed [31:0] frac_dec_3;
wire signed [31:0] frac_dec_4;
wire signed [31:0] frac_dec_5;

assign frac_dec_0 = fraction_dec_qual - 32'd1_0000_0000;
assign frac_dec_1 = fraction_dec_qual - 32'd0_1000_0000;
assign frac_dec_2 = fraction_dec_qual - 32'd0_0100_0000;
assign frac_dec_3 = fraction_dec_qual - 32'd0_0010_0000;
assign frac_dec_4 = fraction_dec_qual - 32'd0_0001_0000;
assign frac_dec_5 = fraction_dec_qual - 32'd0_0000_1000;

assign lead0_num = frac_dec_0[31] & frac_dec_1[31] & frac_dec_2[31] & frac_dec_3[31] & frac_dec_4[31] & frac_dec_5[31] ? 3'd6 : 
                   frac_dec_0[31] & frac_dec_1[31] & frac_dec_2[31] & frac_dec_3[31] & frac_dec_4[31]                  ? 3'd5 : 
                   frac_dec_0[31] & frac_dec_1[31] & frac_dec_2[31] & frac_dec_3[31]                                   ? 3'd4 : 
                   frac_dec_0[31] & frac_dec_1[31] & frac_dec_2[31]                                                    ? 3'd3 : 
                   frac_dec_0[31] & frac_dec_1[31]                                                                     ? 3'd2 : 
                   frac_dec_0[31]                                                                                      ? 3'd1 : 3'd0;

endmodule;
