module dec2bin(
    clk,
    rst,
    init_cnt_q,
    digit0,
    digit1,
    digit2,
    digit_sign,
    unsign_dec,
    input_qual
);

input clk;
input rst;
input [1:0] init_cnt_q;
input [`DIGIT_WIDTH-1:0] digit0;
input [`DIGIT_WIDTH-1:0] digit1;
input [`DIGIT_WIDTH-1:0] digit2;
input digit_sign;
output [`RESULT_WIDTH-1:0] unsign_dec;
output [`RESULT_WIDTH-1:0] input_qual;

//init counter
wire init_lv1_en;
wire init_lv2_en  ;
wire init_lv3_en  ;

wire [`RESULT_WIDTH-1:0] digit0_sl0;
wire [`RESULT_WIDTH-1:0] digit1_sl3;
wire [`RESULT_WIDTH-1:0] digit1_sl1;
wire [`RESULT_WIDTH-1:0] digit2_sl6;
wire [`RESULT_WIDTH-1:0] digit2_sl5;
wire [`RESULT_WIDTH-1:0] digit2_sl2;

wire [`RESULT_WIDTH-1:0] lv1_0;
wire [`RESULT_WIDTH-1:0] lv1_1;
wire [`RESULT_WIDTH-1:0] lv1_0_q;
wire [`RESULT_WIDTH-1:0] lv1_1_q;
wire [`RESULT_WIDTH-1:0] lv2;
wire [`RESULT_WIDTH-1:0] lv3;

wire [`RESULT_WIDTH-1:0] sign_dec;

//Init Pipeline  Enable signal
assign init_lv1_en = init_cnt_q == 2'b01;
assign init_lv2_en = init_cnt_q == 2'b10;
assign init_lv3_en = init_cnt_q == 2'b11;

//Covert decimal input to binary
//Binary value = digit2 x 100 + digit1 x 10 + digit0
assign digit0_sl0 = {12'b0, digit0} ;      
assign digit1_sl3 = {9'b0 , digit1, 3'b0}; //x8
assign digit1_sl1 = {11'b0, digit1, 1'b0}; //x2
assign digit2_sl6 = {6'b0 , digit2, 6'b0}; //x64
assign digit2_sl5 = {7'b0 , digit2, 5'b0}; //x32
assign digit2_sl2 = {10'b0, digit2, 2'b0}; //x4

//Lv1
assign lv1_0 = digit1_sl3 + digit1_sl1 + digit0_sl0;
assign lv1_1 = digit2_sl6 + digit2_sl5 + digit2_sl2;
dflip_en #(`RESULT_WIDTH) lv1_0_ff (.clk(clk), .rst(rst), .en(init_lv1_en), .d(lv1_0), .q(lv1_0_q));
dflip_en #(`RESULT_WIDTH) lv1_1_ff (.clk(clk), .rst(rst), .en(init_lv1_en), .d(lv1_1), .q(lv1_1_q));
//Lv2
assign lv2 = lv1_0_q + lv1_1_q;
dflip_en #(`RESULT_WIDTH) a_lv2_ff   (.clk(clk), .rst(rst), .en(init_lv2_en), .d(lv2), .q(unsign_dec));
//Lv3
assign sign_dec = ~unsign_dec + 16'd1;
assign lv3 = digit_sign ? sign_dec : unsign_dec; 
dflip_en #(`RESULT_WIDTH) a_lv3_ff   (.clk(clk), .rst(rst), .en(init_lv3_en), .d(lv3), .q(input_qual));


endmodule
