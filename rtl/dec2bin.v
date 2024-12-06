module dec2bin(
    clk,
    rst,
    init_cnt_q,
    digit0,
    digit1,
    digit2,
    digit_sign,
    unsign_dec,
    sign_dec,
    input_qual,
    i754_dec
);

input clk;
input rst;
input [1:0] init_cnt_q;
input [`DIGIT_WIDTH-1:0] digit0;
input [`DIGIT_WIDTH-1:0] digit1;
input [`DIGIT_WIDTH-1:0] digit2;
input digit_sign;
output [`RESULT_WIDTH-1:0] unsign_dec;
output [`RESULT_WIDTH-1:0] sign_dec;
output [`RESULT_WIDTH-1:0] input_qual;
output [31:0] i754_dec;

//init counter
wire init_lv1_en;
wire init_lv2_en  ;
wire init_lv3_en  ;
wire init_lv4_en  ;

wire [`RESULT_WIDTH-1:0] digit0_sl0;
wire [`RESULT_WIDTH-1:0] digit1_sl3;
wire [`RESULT_WIDTH-1:0] digit1_sl1;
wire [`RESULT_WIDTH-1:0] digit2_sl6;
wire [`RESULT_WIDTH-1:0] digit2_sl5;
wire [`RESULT_WIDTH-1:0] digit2_sl2;

wire [`RESULT_WIDTH-1:0] lv1_0;
wire [`RESULT_WIDTH-1:0] lv1_1;
wire [`RESULT_WIDTH-1:0] lv1_2;
wire [`RESULT_WIDTH-1:0] lv1_0_q;
wire [`RESULT_WIDTH-1:0] lv1_1_q;
wire [`RESULT_WIDTH-1:0] lv1_2_q;
wire [`RESULT_WIDTH-1:0] lv2;
wire [`RESULT_WIDTH-1:0] lv3;
wire [31:0] lv4;

wire [7:0] exp;
wire [22:0] frac;

//Init Counter
assign init_lv1_en = init_cnt_q == 2'b0;
assign init_lv2_en = init_cnt_q == 2'b1;
assign init_lv3_en = init_cnt_q == 2'b10;
assign init_lv4_en = init_cnt_q == 2'b11;

//Covert decimal input to binary
assign digit0_sl0 = {12'b0, digit0} ;
assign digit1_sl3 = {9'b0 , digit1, 3'b0};
assign digit1_sl1 = {11'b0, digit1, 1'b0};
assign digit2_sl6 = {6'b0 , digit2, 6'b0};
assign digit2_sl5 = {7'b0 , digit2, 5'b0};
assign digit2_sl2 = {10'b0, digit2, 2'b0};
//Lv1
assign lv1_0 = digit1_sl3 + digit1_sl1;
assign lv1_1 = digit2_sl6 + digit2_sl5;
assign lv1_2 = digit0_sl0 + digit2_sl2;
dflip_en #(`RESULT_WIDTH) lv1_0_ff (.clk(clk), .rst(rst), .en(init_lv1_en), .d(lv1_0), .q(lv1_0_q));
dflip_en #(`RESULT_WIDTH) lv1_1_ff (.clk(clk), .rst(rst), .en(init_lv1_en), .d(lv1_1), .q(lv1_1_q));
dflip_en #(`RESULT_WIDTH) lv1_2_ff (.clk(clk), .rst(rst), .en(init_lv1_en), .d(lv1_2), .q(lv1_2_q));

//Lv2
assign lv2 = lv1_0_q + lv1_1_q + lv1_2_q;
dflip_en #(`RESULT_WIDTH) a_lv2_ff   (.clk(clk), .rst(rst), .en(init_lv2_en), .d(lv2), .q(unsign_dec));

//Lv3
assign sign_dec = ~unsign_dec + 1;
assign lv3 = digit_sign ? sign_dec : unsign_dec; 
dflip_en #(`RESULT_WIDTH) a_lv3_ff   (.clk(clk), .rst(rst), .en(init_lv3_en), .d(lv3), .q(input_qual));


assign exp = unsign_dec[15] ? 8'd142 :
             unsign_dec[14] ? 8'd141 : 
             unsign_dec[13] ? 8'd140 : 
             unsign_dec[12] ? 8'd139 : 
             unsign_dec[11] ? 8'd138 : 
             unsign_dec[10] ? 8'd137 : 
             unsign_dec[9]  ? 8'd136 : 
             unsign_dec[8]  ? 8'd135 : 
             unsign_dec[7]  ? 8'd134 : 
             unsign_dec[6]  ? 8'd133 : 
             unsign_dec[5]  ? 8'd132 : 
             unsign_dec[4]  ? 8'd131 : 
             unsign_dec[3]  ? 8'd130 : 
             unsign_dec[2]  ? 8'd129 : 
             unsign_dec[1]  ? 8'd128 : 
             unsign_dec[0]  ? 8'd127 : 8'd0;

assign frac = unsign_dec[15] ? {unsign_dec[14:0], 8'h0} :
              unsign_dec[14] ? {unsign_dec[13:0], 9'h0} : 
              unsign_dec[13] ? {unsign_dec[12:0], 10'h0} : 
              unsign_dec[12] ? {unsign_dec[11:0], 11'h0} : 
              unsign_dec[11] ? {unsign_dec[10:0], 12'h0} : 
              unsign_dec[10] ? {unsign_dec[9:0], 13'h0} : 
              unsign_dec[9]  ? {unsign_dec[8:0], 14'h0} : 
              unsign_dec[8]  ? {unsign_dec[7:0], 15'h0} : 
              unsign_dec[7]  ? {unsign_dec[6:0], 16'h0} : 
              unsign_dec[6]  ? {unsign_dec[5:0], 17'h0} : 
              unsign_dec[5]  ? {unsign_dec[4:0], 18'h0} : 
              unsign_dec[4]  ? {unsign_dec[3:0], 19'h0} : 
              unsign_dec[3]  ? {unsign_dec[2:0], 20'h0} : 
              unsign_dec[2]  ? {unsign_dec[1:0], 21'h0} : 
              unsign_dec[1]  ? {unsign_dec[0]  , 22'h0} : 
              unsign_dec[0]  ? 23'h0 : 23'h0;

assign lv4 = {digit_sign, exp, frac};

dflip_en #(32) a_lv4_ff   (.clk(clk), .rst(rst), .en(init_lv4_en), .d(lv4), .q(i754_dec));

endmodule
