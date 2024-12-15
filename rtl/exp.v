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
output [39:0] exp_result_out;
output exp_overflow;

//internal
wire [4:0] exp_cnt;
wire [4:0] exp_cnt_q;

wire [79:0] exp_result;
wire [79:0] exp_result_q;
wire [39:0] exp_result_shift;


parameter EULER =  40'b10_1011_0111_1110_0001_0101_0001;

//Divider Counter
assign exp_cnt_en = exp_start & ~exp_done | exp_rst;
assign exp_cnt = exp_rst ? 5'd0 : exp_cnt_q + 5'b1;
dflip_en #(5) exp_cnt_ff (.clk(clk), .rst(rst), .en(exp_cnt_en), .d(exp_cnt), .q(exp_cnt_q));

//The execution done when counter is equal to index a
assign exp_done = exp_cnt == unsign_inputa[4:0];

// 40bit x 40bit
// 16bit for integer
// 24bit for fraction

//if power is 1, it has't done multiplication yet so no need to shift fraction part
//when the result did multiplication, we need to shift 24 bit for aligning to e
assign exp_result_shift = exp_cnt_q  > 5'd1 ? exp_result_q[63:24] : exp_result_q[39:0];
//if counter is 0, reset the register 
//else e x previous result
assign exp_result = ~(|exp_cnt_q) ? {40'b0, EULER} : EULER * exp_result_shift ; 

dflip_en #(80) mul_result_ff (.clk(clk), .rst(rst), .en(exp_cnt_en), .d(exp_result), .q(exp_result_q));

assign exp_result_out = ~(|unsign_inputa)     ? 40'h100_0000 : 
                        unsign_inputa == 5'b1 ? EULER      : exp_result[63:24]; 
assign exp_overflow = |exp_result[79:64];

endmodule
