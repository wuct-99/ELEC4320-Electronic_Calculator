module power(
    clk,
    rst,
    power_start,
    power_rst,
    unsign_inputa,
    unsign_inputb,
    inputa_sign,
    
    power_done,
    power_result,
    power_sign,
    power_overflow
);

input clk;
input rst;
input power_start;
input power_rst;
input [15:0] unsign_inputa;
input [15:0] unsign_inputb;
input inputa_sign;
    
output power_done;
output [31:0] power_result;
output power_sign;
output power_overflow;

//Divider Counter
wire [4:0] pwr_cnt;
wire [4:0] pwr_cnt_q;
assign pwr_cnt_en = power_start & ~power_done | power_rst;
assign pwr_cnt = power_rst ? 5'd0 : pwr_cnt_q + 5'b1;
dflip_en #(5) pwr_cnt_ff (.clk(clk), .rst(rst), .en(pwr_cnt_en), .d(pwr_cnt), .q(pwr_cnt_q));
assign power_done = pwr_cnt == unsign_inputb[4:0] ;


wire [63:0] pwr_result;
wire [63:0] pwr_result_q;

assign pwr_result = ~(|pwr_cnt_q) ? {16'b0, unsign_inputa} : unsign_inputa * pwr_result_q; 
dflip_en #(64) mul_result_ff (.clk(clk), .rst(rst), .en(pwr_cnt_en), .d(pwr_result), .q(pwr_result_q));

assign power_result = ~(|unsign_inputb) ? 16'b1 : pwr_result[31:0]; 
assign power_sign =   (|unsign_inputb[3:1]) & ~unsign_inputb[0] ? 1'b0 : inputa_sign;
assign power_overflow = |pwr_result[63:32];

endmodule
