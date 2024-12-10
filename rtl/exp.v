module exp(
    clk,
    rst,
    exp_start,
    exp_rst,
    unsign_inputa,
    
    exp_done,
    exp_result_out,
    exp_overflow
);

input clk;
input rst;
input exp_start;
input exp_rst;
input [15:0] unsign_inputa;
output exp_done;
output [31:0] exp_result_out;
output exp_overflow;

//Divider Counter
wire [4:0] exp_cnt;
wire [4:0] exp_cnt_q;
assign exp_cnt_en = exp_start & ~exp_done | exp_rst;
assign exp_cnt = exp_rst ? 5'd0 : exp_cnt_q + 5'b1;
dflip_en #(5) exp_cnt_ff (.clk(clk), .rst(rst), .en(exp_cnt_en), .d(exp_cnt), .q(exp_cnt_q));
assign exp_done = exp_cnt == unsign_inputa[4:0];


wire [63:0] exp_result;
wire [63:0] exp_result_q;

assign exp_result = ~(|exp_cnt_q) ? 64'b10_1011_0111_1110_0001   : 32'b10_1011_0111_1110_0001 * exp_result_q; 
dflip_en #(64) mul_result_ff (.clk(clk), .rst(rst), .en(exp_cnt_en), .d(exp_result), .q(exp_result_q));

assign exp_result_out = ~(|unsign_inputa) ? 32'h1_0000 : exp_result[47:16]; 
assign exp_overflow = |exp_result[63:48];

endmodule
