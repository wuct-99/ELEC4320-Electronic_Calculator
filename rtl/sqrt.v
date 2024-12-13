module sqrt(
    clk,
    rst,
    sqrt_rst,
    sqrt_start,
    inputa,
    sqrt_result,    
    sqrt_done
);

input clk;
input rst;
input sqrt_start;
input sqrt_rst;
input [15:0] inputa;
output [31:0] sqrt_result;
output sqrt_done;

wire [4:0] sqrt_cnt_d;
wire [4:0] sqrt_cnt_q;
wire sqrt_cnt_en;

wire [63:0] shift_acc;
wire [63:0] acc;
wire [63:0] acc_q;

wire signed [31:0] sign_test;
wire signed [31:0] sign_test_q;

wire [31:0] shift_square_root;
wire [31:0] square_root;
wire [31:0] square_root_q;

assign sqrt_cnt_d = sqrt_rst ? 5'b0 : sqrt_cnt_q + 5'b1;
assign sqrt_cnt_en = sqrt_start | sqrt_rst;
dflip_en #(5) sqrt_cnt_ff (.clk(clk), .rst(rst), .en(sqrt_cnt_en), .d(sqrt_cnt_d), .q(sqrt_cnt_q));
//32bit result + 16bit fraction / 2 = 24cycles
assign sqrt_done = sqrt_cnt_d == 5'd23;


//Method: log route

//Left shift input by two places
assign shift_acc = ~(|sqrt_cnt_q) ? {32'b0, inputa, 16'b0, 2'b0} : {acc_q[61:0], 2'b0};
//Sign test by ACC -{square root, 2'b01}
assign sign_test = ~(|sqrt_cnt_q) ? 32'hFFFF_FFFF : shift_acc[63:32] - {square_root_q, 2'b01};
//if sign test >= 0, keep sign test value for next round
assign acc[63:32] = ~sign_test[31] ? sign_test : shift_acc[63:32];
assign acc[31:0] = shift_acc[31:0];

//Left shift Square root 
assign shift_square_root = ~(|sqrt_cnt_q) ? 32'h0 : {square_root_q[30:0], 1'b0};
//if sign test >= 0, set the square root last bit to 1
assign square_root[0] = ~sign_test[31];
assign square_root[31:1] = shift_square_root[31:1];

dflip_en #(64) acc_ff         (.clk(clk), .rst(rst), .en(sqrt_cnt_en), .d(acc        ), .q(acc_q        ));
dflip_en #(32) sign_test_ff   (.clk(clk), .rst(rst), .en(sqrt_cnt_en), .d(sign_test  ), .q(sign_test_q  ));
dflip_en #(32) square_root_ff (.clk(clk), .rst(rst), .en(sqrt_cnt_en), .d(square_root), .q(square_root_q));

assign sqrt_result = square_root;

endmodule;
