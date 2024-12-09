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
    div_result,
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
input  div_sign;
output div_invld;
output [31:0] div_result;
output div_done;

//step2: Prepare   
wire [31:0] dividend;
wire [31:0] divisor;

assign dividend = unsign_inputa;
assign divisor  = unsign_inputb;
assign div_invld = ~(|divisor);

//Divider Counter
wire [5:0] div_cnt;
wire [5:0] div_cnt_q;
assign div_cnt_en = div_start | div_rst;
assign div_cnt = div_rst ? 6'd0 : div_cnt_q + 6'b1;
dflip_en #(6) div_cnt_ff (.clk(clk), .rst(rst), .en(div_cnt_en), .d(div_cnt), .q(div_cnt_q));
assign div_done = div_cnt == 6'd47;

wire [63:0] shift_acc;
wire [63:0] acc;
wire [63:0] acc_q;
wire [31:0] shift_quo;
wire [31:0] quotient;
wire [31:0] quotient_q;

assign shift_acc = ~(|div_cnt_q) ? {31'b0, dividend[31:0], 1'b0} : {acc_q[62:0], 1'b0};
assign acc[63:32] = shift_acc[63:32] >= divisor ? shift_acc[63:32] - divisor : shift_acc[63:32];
assign acc[31:0] = shift_acc[31:0];

assign shift_quo = {quotient_q[30:0], 1'b0}; 
assign quotient[31:1] = shift_quo[31:1];
assign quotient[0] = shift_acc[63:32] >= divisor;

wire exe_en = div_start;

dflip_en #(64) acc_ff      (.clk(clk), .rst(rst), .en(exe_en), .d(acc), .q(acc_q));
dflip_en #(32) quotient_ff (.clk(clk), .rst(rst), .en(exe_en), .d(quotient), .q(quotient_q)); 


assign div_sign = (inputa_sign ^ inputb_sign);
assign div_result = quotient;

endmodule;
