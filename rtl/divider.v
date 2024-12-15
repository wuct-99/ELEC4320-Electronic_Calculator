module divider(
    clk,
    rst,
    div_rst,
    div_start,
    inputa_sign,
    inputb_sign,
    unsign_inputa,
    unsign_inputb,
    div_invld,
    div_result_int,
    div_result_frac,
    div_sign,
    div_done
); 

input clk;
input rst;
input div_rst;
input div_start;
input inputa_sign;
input inputb_sign;
input [31:0] unsign_inputa;
input [31:0] unsign_inputb;
output  div_sign;
output div_invld;
output [15:0] div_result_int;
output [23:0] div_result_frac;
output div_done;

wire [79:0] shift_acc;
wire [79:0] acc;
wire [79:0] acc_q;
wire [39:0] shift_quo;
wire [39:0] quotient;
wire [39:0] quotient_q;

wire [31:0] dividend;
wire [31:0] divisor;

wire [5:0] div_cnt;
wire [5:0] div_cnt_q;

//long divison
assign dividend = unsign_inputa;
assign divisor  = unsign_inputb;
assign div_invld = ~(|divisor);

assign div_cnt_en = div_start | div_rst;
assign div_cnt = div_rst ? 6'd0 : div_cnt_q + 6'b1;
dflip_en #(6) div_cnt_ff (.clk(clk), .rst(rst), .en(div_cnt_en), .d(div_cnt), .q(div_cnt_q));
assign div_done = &div_cnt;

//Shift ACC to 1 bit left
assign shift_acc = ~(|div_cnt_q) ? {47'b0, dividend[31:0], 1'b0} : {acc_q[79:0], 1'b0};
//If ACC >= division, ACC - DiVisor
assign acc[79:40] = shift_acc[79:40] >= divisor ? shift_acc[79:40] - divisor : shift_acc[79:40];
assign acc[39:0] = shift_acc[39:0];

//Shift quotient to 1 bit left
assign shift_quo = {quotient_q[38:0], 1'b0}; 
assign quotient[39:1] = shift_quo[39:1];
//if ACC is 1, set quotient[0] to 1
assign quotient[0] = shift_acc[79:40] >= divisor;

wire exe_en = div_start;

dflip_en #(80) acc_ff      (.clk(clk), .rst(rst), .en(exe_en), .d(acc), .q(acc_q));
dflip_en #(40) quotient_ff (.clk(clk), .rst(rst), .en(exe_en), .d(quotient), .q(quotient_q)); 

assign div_sign = ~(|dividend) ? 1'b0 : (inputa_sign ^ inputb_sign);
//16 bit integer
assign div_result_int  = quotient[39:24];
//24 bit fraction
assign div_result_frac = quotient[23:0];

endmodule
