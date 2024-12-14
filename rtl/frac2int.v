module frac2int(
    clk,
    rst,
    frac2int_start,
    frac_part,
    fraction_in_dec,
    lead0_num,
    frac2int_done
);

input clk;
input rst;
input frac2int_start;
input [23:0] frac_part;
output [31:0] fraction_in_dec;
output [2:0]  lead0_num;
output frac2int_done;

wire [23:0] frac_part_lv0;

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
wire [32:0] exp_fraction_2n24;

wire [31:0] exp_fraction_dec;
wire [31:0] exp_fraction_dec_lv0_0;
wire [31:0] exp_fraction_dec_lv0_1;
wire [31:0] exp_fraction_dec_lv0_2;
wire [31:0] exp_fraction_dec_lv0_3;
wire [31:0] exp_fraction_dec_lv0_4;
wire [31:0] exp_fraction_dec_lv0_5;
wire [31:0] exp_fraction_dec_lv0_6;
wire [31:0] exp_fraction_dec_lv0_7;
wire [31:0] exp_fraction_dec_lv1_0;
wire [31:0] exp_fraction_dec_lv1_1;
wire [31:0] exp_fraction_dec_lv1_2;
wire [31:0] exp_fraction_dec_lv1_3;
wire [31:0] exp_fraction_dec_lv2_0;
wire [31:0] exp_fraction_dec_lv2_1;
wire [31:0] exp_fraction_dec_lv3_0;
wire exp_fraction_dec_lv3_1;
wire [31:0] exp_fraction_dec_lv4;

wire [31:0] exp_fraction_dec_lv0_0_q;
wire [31:0] exp_fraction_dec_lv0_1_q;
wire [31:0] exp_fraction_dec_lv0_2_q;
wire [31:0] exp_fraction_dec_lv0_3_q;
wire [31:0] exp_fraction_dec_lv0_4_q;
wire [31:0] exp_fraction_dec_lv0_5_q;
wire [31:0] exp_fraction_dec_lv0_6_q;
wire [31:0] exp_fraction_dec_lv0_7_q;
wire [31:0] exp_fraction_dec_lv1_0_q;
wire [31:0] exp_fraction_dec_lv1_1_q;
wire [31:0] exp_fraction_dec_lv1_2_q;
wire [31:0] exp_fraction_dec_lv1_3_q;
wire [31:0] exp_fraction_dec_lv2_0_q;
wire [31:0] exp_fraction_dec_lv2_1_q;
wire [31:0] exp_fraction_dec_lv3_0_q;
wire exp_fraction_dec_lv3_1_q;
wire [31:0] exp_fraction_dec_lv4_q;

wire signed [31:0] frac_dec_0_lv5;
wire signed [31:0] frac_dec_1_lv5;
wire signed [31:0] frac_dec_2_lv5;
wire signed [31:0] frac_dec_3_lv5;
wire signed [31:0] frac_dec_4_lv5;
wire signed [31:0] frac_dec_5_lv5;
wire frac_dec_0c_lv5;
wire frac_dec_1c_lv5;
wire frac_dec_2c_lv5;
wire frac_dec_3c_lv5;
wire frac_dec_4c_lv5;
wire frac_dec_5c_lv5;
wire signed [31:0] frac_dec_0_lv5_q;
wire signed [31:0] frac_dec_1_lv5_q;
wire signed [31:0] frac_dec_2_lv5_q;
wire signed [31:0] frac_dec_3_lv5_q;
wire signed [31:0] frac_dec_4_lv5_q;
wire signed [31:0] frac_dec_5_lv5_q;
wire frac_dec_0c_lv5_q;
wire frac_dec_1c_lv5_q;
wire frac_dec_2c_lv5_q;
wire frac_dec_3c_lv5_q;
wire frac_dec_4c_lv5_q;
wire frac_dec_5c_lv5_q;
wire signed [31:0] frac_dec_0_lv6;
wire signed [31:0] frac_dec_1_lv6;
wire signed [31:0] frac_dec_2_lv6;
wire signed [31:0] frac_dec_3_lv6;
wire signed [31:0] frac_dec_4_lv6;
wire signed [31:0] frac_dec_5_lv6;
wire frac_dec_0s_lv6;
wire frac_dec_1s_lv6;
wire frac_dec_2s_lv6;
wire frac_dec_3s_lv6;
wire frac_dec_4s_lv6;
wire frac_dec_5s_lv6;
wire [2:0] lead0_num_lv6;


dflip #(1) cvt_lv0_en_ff (.clk(clk), .rst(rst), .d(frac2int_start), .q(cvt_lv0_en   ));
dflip #(1) cvt_lv1_en_ff (.clk(clk), .rst(rst), .d(cvt_lv0_en    ), .q(cvt_lv1_en   ));
dflip #(1) cvt_lv2_en_ff (.clk(clk), .rst(rst), .d(cvt_lv1_en    ), .q(cvt_lv2_en   ));
dflip #(1) cvt_lv3_en_ff (.clk(clk), .rst(rst), .d(cvt_lv2_en    ), .q(cvt_lv3_en   ));
dflip #(1) cvt_lv4_en_ff (.clk(clk), .rst(rst), .d(cvt_lv3_en    ), .q(cvt_lv4_en   ));
dflip #(1) cvt_lv5_en_ff (.clk(clk), .rst(rst), .d(cvt_lv4_en    ), .q(cvt_lv5_en   ));
dflip #(1) cvt_lv6_en_ff (.clk(clk), .rst(rst), .d(cvt_lv5_en    ), .q(cvt_lv6_en   ));
dflip #(1) cvt_lv7_en_ff (.clk(clk), .rst(rst), .d(cvt_lv6_en    ), .q(cvt_lv7_en   ));
dflip #(1) cvt_lv8_en_ff (.clk(clk), .rst(rst), .d(cvt_lv7_en    ), .q(frac2int_done));
dflip_en #(24) input_frac_lv0_ff  (.clk(clk), .rst(rst), .en(frac2int_start), .d(frac_part   ), .q(frac_part_lv0));

assign exp_fraction_2n1  = {32{frac_part_lv0[23]}} & 32'd5_0000_0000; //2^-1
assign exp_fraction_2n2  = {32{frac_part_lv0[22]}} & 32'd2_5000_0000; //2^-2 
assign exp_fraction_2n3  = {32{frac_part_lv0[21]}} & 32'd1_2500_0000; //2^-3 
assign exp_fraction_2n4  = {32{frac_part_lv0[20]}} & 32'd0_6250_0000; //2^-4 
assign exp_fraction_2n5  = {32{frac_part_lv0[19]}} & 32'd0_3125_0000; //2^-5 
assign exp_fraction_2n6  = {32{frac_part_lv0[18]}} & 32'd0_1562_5000; //2^-6 
assign exp_fraction_2n7  = {32{frac_part_lv0[17]}} & 32'd0_0781_2500; //2^-7 
assign exp_fraction_2n8  = {32{frac_part_lv0[16]}} & 32'd0_0390_6250; //2^-8 
assign exp_fraction_2n9  = {32{frac_part_lv0[15]}} & 32'd0_0195_3125; //2^-9 
assign exp_fraction_2n10 = {32{frac_part_lv0[14]}} & 32'd0_0097_6562; //2^-10
assign exp_fraction_2n11 = {32{frac_part_lv0[13]}} & 32'd0_0048_8281; //2^-11
assign exp_fraction_2n12 = {32{frac_part_lv0[12]}} & 32'd0_0024_4140; //2^-12
assign exp_fraction_2n13 = {32{frac_part_lv0[11]}} & 32'd0_0012_2070; //2^-13
assign exp_fraction_2n14 = {32{frac_part_lv0[10]}} & 32'd0_0006_1035; //2^-14
assign exp_fraction_2n15 = {32{frac_part_lv0[9 ]}} & 32'd0_0003_0517; //2^-15
assign exp_fraction_2n16 = {32{frac_part_lv0[8 ]}} & 32'd0_0001_5258; //2^-16
assign exp_fraction_2n17 = {32{frac_part_lv0[7 ]}} & 32'd0_0000_7629; //2^-17
assign exp_fraction_2n18 = {32{frac_part_lv0[6 ]}} & 32'd0_0000_3814; //2^-18
assign exp_fraction_2n19 = {32{frac_part_lv0[5 ]}} & 32'd0_0000_1907; //2^-19
assign exp_fraction_2n20 = {32{frac_part_lv0[4 ]}} & 32'd0_0000_0953; //2^-20
assign exp_fraction_2n21 = {32{frac_part_lv0[3 ]}} & 32'd0_0000_0476; //2^-21
assign exp_fraction_2n22 = {32{frac_part_lv0[2 ]}} & 32'd0_0000_0238; //2^-22
assign exp_fraction_2n23 = {32{frac_part_lv0[1 ]}} & 32'd0_0000_0119; //2^-23
assign exp_fraction_2n24 = {32{frac_part_lv0[0 ]}} & 32'd0_0000_0059; //2^-24


//2^-1 + 2^-2 + ... + 2^-24
assign exp_fraction_dec_lv0_0 = exp_fraction_2n1  + exp_fraction_2n2;
assign exp_fraction_dec_lv0_1 = exp_fraction_2n3  + exp_fraction_2n4;
assign exp_fraction_dec_lv0_2 = exp_fraction_2n5  + exp_fraction_2n6;
assign exp_fraction_dec_lv0_3 = exp_fraction_2n7  + exp_fraction_2n8;
assign exp_fraction_dec_lv0_4 = exp_fraction_2n9  + exp_fraction_2n10 + exp_fraction_2n11 + exp_fraction_2n12;
assign exp_fraction_dec_lv0_5 = exp_fraction_2n13 + exp_fraction_2n14 + exp_fraction_2n15 + exp_fraction_2n16;
assign exp_fraction_dec_lv0_6 = exp_fraction_2n17 + exp_fraction_2n18 + exp_fraction_2n19 + exp_fraction_2n20;
assign exp_fraction_dec_lv0_7 = exp_fraction_2n21 + exp_fraction_2n22 + exp_fraction_2n23 + exp_fraction_2n24;

dflip_en #(32) exp_fraction_dec_lv0_0_ff  (.clk(clk), .rst(rst), .en(cvt_lv0_en), .d(exp_fraction_dec_lv0_0 ), .q(exp_fraction_dec_lv0_0_q));
dflip_en #(32) exp_fraction_dec_lv0_1_ff  (.clk(clk), .rst(rst), .en(cvt_lv0_en), .d(exp_fraction_dec_lv0_1 ), .q(exp_fraction_dec_lv0_1_q));
dflip_en #(32) exp_fraction_dec_lv0_2_ff  (.clk(clk), .rst(rst), .en(cvt_lv0_en), .d(exp_fraction_dec_lv0_2 ), .q(exp_fraction_dec_lv0_2_q));
dflip_en #(32) exp_fraction_dec_lv0_3_ff  (.clk(clk), .rst(rst), .en(cvt_lv0_en), .d(exp_fraction_dec_lv0_3 ), .q(exp_fraction_dec_lv0_3_q));
dflip_en #(32) exp_fraction_dec_lv0_4_ff  (.clk(clk), .rst(rst), .en(cvt_lv0_en), .d(exp_fraction_dec_lv0_4 ), .q(exp_fraction_dec_lv0_4_q));
dflip_en #(32) exp_fraction_dec_lv0_5_ff  (.clk(clk), .rst(rst), .en(cvt_lv0_en), .d(exp_fraction_dec_lv0_5 ), .q(exp_fraction_dec_lv0_5_q));
dflip_en #(32) exp_fraction_dec_lv0_6_ff  (.clk(clk), .rst(rst), .en(cvt_lv0_en), .d(exp_fraction_dec_lv0_6 ), .q(exp_fraction_dec_lv0_6_q));
dflip_en #(32) exp_fraction_dec_lv0_7_ff  (.clk(clk), .rst(rst), .en(cvt_lv0_en), .d(exp_fraction_dec_lv0_7 ), .q(exp_fraction_dec_lv0_7_q));

assign exp_fraction_dec_lv1_0  = exp_fraction_dec_lv0_0_q + exp_fraction_dec_lv0_1_q;
assign exp_fraction_dec_lv1_1  = exp_fraction_dec_lv0_2_q + exp_fraction_dec_lv0_3_q;
assign exp_fraction_dec_lv1_2  = exp_fraction_dec_lv0_4_q + exp_fraction_dec_lv0_5_q;
assign exp_fraction_dec_lv1_3  = exp_fraction_dec_lv0_6_q + exp_fraction_dec_lv0_7_q;

dflip_en #(32) exp_fraction_dec_lv1_0_ff  (.clk(clk), .rst(rst), .en(cvt_lv1_en), .d(exp_fraction_dec_lv1_0 ), .q(exp_fraction_dec_lv1_0_q));
dflip_en #(32) exp_fraction_dec_lv1_1_ff  (.clk(clk), .rst(rst), .en(cvt_lv1_en), .d(exp_fraction_dec_lv1_1 ), .q(exp_fraction_dec_lv1_1_q));
dflip_en #(32) exp_fraction_dec_lv1_2_ff  (.clk(clk), .rst(rst), .en(cvt_lv1_en), .d(exp_fraction_dec_lv1_2 ), .q(exp_fraction_dec_lv1_2_q));
dflip_en #(32) exp_fraction_dec_lv1_3_ff  (.clk(clk), .rst(rst), .en(cvt_lv1_en), .d(exp_fraction_dec_lv1_3 ), .q(exp_fraction_dec_lv1_3_q));

assign exp_fraction_dec_lv2_0  = exp_fraction_dec_lv1_0_q + exp_fraction_dec_lv1_1_q;
assign exp_fraction_dec_lv2_1  = exp_fraction_dec_lv1_2_q + exp_fraction_dec_lv1_3_q;

dflip_en #(32) exp_fraction_dec_lv2_0_ff  (.clk(clk), .rst(rst), .en(cvt_lv2_en), .d(exp_fraction_dec_lv2_0 ), .q(exp_fraction_dec_lv2_0_q));
dflip_en #(32) exp_fraction_dec_lv2_1_ff  (.clk(clk), .rst(rst), .en(cvt_lv2_en), .d(exp_fraction_dec_lv2_1 ), .q(exp_fraction_dec_lv2_1_q));

assign {exp_fraction_dec_lv3_1, exp_fraction_dec_lv3_0[15:0]} = exp_fraction_dec_lv2_0_q[15:0]  + exp_fraction_dec_lv2_1_q[15:0];
assign exp_fraction_dec_lv3_0[31:16]                          = exp_fraction_dec_lv2_0_q[31:16] + exp_fraction_dec_lv2_1_q[31:16];

dflip_en #(32) exp_fraction_dec_lv3_0_ff  (.clk(clk), .rst(rst), .en(cvt_lv3_en), .d(exp_fraction_dec_lv3_0), .q(exp_fraction_dec_lv3_0_q));
dflip_en #(1)  exp_fraction_dec_lv3_1_ff  (.clk(clk), .rst(rst), .en(cvt_lv3_en), .d(exp_fraction_dec_lv3_1), .q(exp_fraction_dec_lv3_1_q));

assign exp_fraction_dec_lv4[31:16] = exp_fraction_dec_lv3_0_q[31:16] + {15'b0, exp_fraction_dec_lv3_1_q};
assign exp_fraction_dec_lv4[15:0]  = exp_fraction_dec_lv3_0_q[15:0];

dflip_en #(32) exp_fraction_dec_lv4_ff  (.clk(clk), .rst(rst), .en(cvt_lv4_en), .d(exp_fraction_dec_lv4), .q(fraction_in_dec));


//-1_0000_0000 
assign {frac_dec_0c_lv5, frac_dec_0_lv5[15:0]} = fraction_in_dec[15:0 ] + 16'h1F00;
assign                   frac_dec_0_lv5[31:16] = fraction_in_dec[31:16] + 16'hFA0A;

//-1000_0000 'hFF67_6980
assign {frac_dec_1c_lv5, frac_dec_1_lv5[15:0]} = fraction_in_dec[15:0 ] + 16'h6980;
assign                   frac_dec_1_lv5[31:16] = fraction_in_dec[31:16] + 16'hFF67;

//-100_0000 'hFFF0_BDC0
assign {frac_dec_2c_lv5, frac_dec_2_lv5[15:0]} = fraction_in_dec[15:0 ] + 16'hBDC0;
assign                   frac_dec_2_lv5[31:16] = fraction_in_dec[31:16] + 16'hFFF0;

//-10_0000 'hFFFE_7960
assign {frac_dec_3c_lv5, frac_dec_3_lv5[15:0]} = fraction_in_dec[15:0 ] + 16'h7960;
assign                   frac_dec_3_lv5[31:16] = fraction_in_dec[31:16] + 16'hFFFE;

//-1_0000 'hFFFF_D8F0
assign {frac_dec_4c_lv5, frac_dec_4_lv5[15:0]} = fraction_in_dec[15:0 ] + 16'hD8F0;
assign                   frac_dec_4_lv5[31:16] = fraction_in_dec[31:16] + 16'hFFFF;

//-10000
assign {frac_dec_5c_lv5, frac_dec_5_lv5[15:0]} = fraction_in_dec[15:0 ] + 16'hD8F0;
assign                   frac_dec_5_lv5[31:16] = fraction_in_dec[31:16] + 16'hFFFF;

dflip_en #(32) frac_dec_0_lv5_ff    (.clk(clk), .rst(rst), .en(cvt_lv5_en), .d(frac_dec_0_lv5), .q(frac_dec_0_lv5_q));
dflip_en #(32) frac_dec_1_lv5_ff    (.clk(clk), .rst(rst), .en(cvt_lv5_en), .d(frac_dec_1_lv5), .q(frac_dec_1_lv5_q));
dflip_en #(32) frac_dec_2_lv5_ff    (.clk(clk), .rst(rst), .en(cvt_lv5_en), .d(frac_dec_2_lv5), .q(frac_dec_2_lv5_q));
dflip_en #(32) frac_dec_3_lv5_ff    (.clk(clk), .rst(rst), .en(cvt_lv5_en), .d(frac_dec_3_lv5), .q(frac_dec_3_lv5_q));
dflip_en #(32) frac_dec_4_lv5_ff    (.clk(clk), .rst(rst), .en(cvt_lv5_en), .d(frac_dec_4_lv5), .q(frac_dec_4_lv5_q));
dflip_en #(32) frac_dec_5_lv5_ff    (.clk(clk), .rst(rst), .en(cvt_lv5_en), .d(frac_dec_5_lv5), .q(frac_dec_5_lv5_q));
dflip_en #(1)  frac_dec_0c_lv5_ff   (.clk(clk), .rst(rst), .en(cvt_lv5_en), .d(frac_dec_0c_lv5), .q(frac_dec_0c_lv5_q));
dflip_en #(1)  frac_dec_1c_lv5_ff   (.clk(clk), .rst(rst), .en(cvt_lv5_en), .d(frac_dec_1c_lv5), .q(frac_dec_1c_lv5_q));
dflip_en #(1)  frac_dec_2c_lv5_ff   (.clk(clk), .rst(rst), .en(cvt_lv5_en), .d(frac_dec_2c_lv5), .q(frac_dec_2c_lv5_q));
dflip_en #(1)  frac_dec_3c_lv5_ff   (.clk(clk), .rst(rst), .en(cvt_lv5_en), .d(frac_dec_3c_lv5), .q(frac_dec_3c_lv5_q));
dflip_en #(1)  frac_dec_4c_lv5_ff   (.clk(clk), .rst(rst), .en(cvt_lv5_en), .d(frac_dec_4c_lv5), .q(frac_dec_4c_lv5_q));
dflip_en #(1)  frac_dec_5c_lv5_ff   (.clk(clk), .rst(rst), .en(cvt_lv5_en), .d(frac_dec_5c_lv5), .q(frac_dec_5c_lv5_q));

assign frac_dec_0_lv6[31:16] = frac_dec_0_lv5_q[31:16] + {15'b0, frac_dec_0c_lv5_q};
assign frac_dec_0_lv6[15:0]  = frac_dec_0_lv5_q[15:0];

assign frac_dec_1_lv6[31:16] = frac_dec_1_lv5_q[31:16] + {15'b0, frac_dec_1c_lv5_q};
assign frac_dec_1_lv6[15:0]  = frac_dec_1_lv5_q[15:0];

assign frac_dec_2_lv6[31:16] = frac_dec_2_lv5_q[31:16] + {15'b0, frac_dec_2c_lv5_q};
assign frac_dec_2_lv6[15:0]  = frac_dec_2_lv5_q[15:0];

assign frac_dec_3_lv6[31:16] = frac_dec_3_lv5_q[31:16] + {15'b0, frac_dec_3c_lv5_q};
assign frac_dec_3_lv6[15:0]  = frac_dec_3_lv5_q[15:0];

assign frac_dec_4_lv6[31:16] = frac_dec_4_lv5_q[31:16] + {15'b0, frac_dec_4c_lv5_q};
assign frac_dec_4_lv6[15:0]  = frac_dec_4_lv5_q[15:0];

assign frac_dec_5_lv6[31:16] = frac_dec_5_lv5_q[31:16] + {15'b0, frac_dec_5c_lv5_q};
assign frac_dec_5_lv6[15:0]  = frac_dec_5_lv5_q[15:0];

//Try to get leading 0
//e.g 0.0003686, leading 0 is 3
dflip_en #(1) frac_dec_0s_lv6_ff  (.clk(clk), .rst(rst), .en(cvt_lv6_en), .d(frac_dec_0_lv6[31]), .q(frac_dec_0s_lv6));
dflip_en #(1) frac_dec_1s_lv6_ff  (.clk(clk), .rst(rst), .en(cvt_lv6_en), .d(frac_dec_1_lv6[31]), .q(frac_dec_1s_lv6));
dflip_en #(1) frac_dec_2s_lv6_ff  (.clk(clk), .rst(rst), .en(cvt_lv6_en), .d(frac_dec_2_lv6[31]), .q(frac_dec_2s_lv6));
dflip_en #(1) frac_dec_3s_lv6_ff  (.clk(clk), .rst(rst), .en(cvt_lv6_en), .d(frac_dec_3_lv6[31]), .q(frac_dec_3s_lv6));
dflip_en #(1) frac_dec_4s_lv6_ff  (.clk(clk), .rst(rst), .en(cvt_lv6_en), .d(frac_dec_4_lv6[31]), .q(frac_dec_4s_lv6));
dflip_en #(1) frac_dec_5s_lv6_ff  (.clk(clk), .rst(rst), .en(cvt_lv6_en), .d(frac_dec_5_lv6[31]), .q(frac_dec_5s_lv6));

assign lead0_num_lv6 = frac_dec_0s_lv6 & frac_dec_1s_lv6 & frac_dec_2s_lv6 & frac_dec_3s_lv6 & frac_dec_4s_lv6 & frac_dec_5s_lv6 ? 3'd6 : 
                       frac_dec_0s_lv6 & frac_dec_1s_lv6 & frac_dec_2s_lv6 & frac_dec_3s_lv6 & frac_dec_4s_lv6                   ? 3'd5 : 
                       frac_dec_0s_lv6 & frac_dec_1s_lv6 & frac_dec_2s_lv6 & frac_dec_3s_lv6                                     ? 3'd4 : 
                       frac_dec_0s_lv6 & frac_dec_1s_lv6 & frac_dec_2s_lv6                                                       ? 3'd3 : 
                       frac_dec_0s_lv6 & frac_dec_1s_lv6                                                                         ? 3'd2 : 
                       frac_dec_0s_lv6                                                                                           ? 3'd1 : 3'd0;

dflip_en #(3) lead0_num_ff (.clk(clk), .rst(rst), .en(cvt_lv7_en), .d(lead0_num_lv6), .q(lead0_num));

endmodule
