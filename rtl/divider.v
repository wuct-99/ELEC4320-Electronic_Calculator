module divider (
    clk,
    rst_n,
    src1,
    src2,
    src1_sign,
    src2_sign,
    div_vld,
    div_res,
    div_sign,
    div_done,
    div_res_vld
);

// Module Interface
input           clk;
input           rst_n;
input   [31:0]  src1;
input   [31:0]  src2;
input           src1_sign;
input           src2_sign;
input           div_vld;

output  [31:0]  div_res;
output          div_sign;
output          div_done;
output          div_res_vld;

// Internal Signals
wire            div_dp_vld;
wire            div_illegal;
wire    [31:0]  dividend;
wire    [31:0]  divisor;
wire    [31:0]  quotient_shift;
wire    [31:0]  quotient;
wire    [31:0]  quotient_nc;
wire    [31:0]  accumulator_shift;
wire    [31:0]  accumulator;
wire    [31:0]  accumulator_nc;
wire    [5:0]   div_cnt;
wire    [5:0]   div_cnt_nc;

// Division Datapath
// - Total cycles = number of bits + number of fraction bits
// 1. Left shift dividend into accumulator
// 2. Check accumulator >= divisor?
//      - Accumulator >= divisor: accumulator = accumulator - divisor, quotient[0] = 1
//      - Accumulator < divisor: continue
// 3. Left shift quotient

assign  dividend     = src1;
assign  divisor      = src2;

assign  accumulator_shift   = (div_done)? 32'b0 : ({accumulator[30:0], dividend[31]});
assign  accumulator_nc      = (accumulator_shift >= divisor)? (accumulator_shift - divisor) : (accumulator_shift);
assign  quotient_shift      = (div_done)? 32'b0 : ({quotient[30:0], 1'b0});
assign  quotient_nc         = (accumulator_shift >= divisor)? ({quotient_shift[30:1], 1'b1}) : quotient_shift;

dffre #(32) quotient_ff (.clk(clk), .rst_n(rst_n), .en(div_dp_vld), .d(quotient_nc), .q(quotient));
dffre #(32) accumulator_ff (.clk(clk), .rst_n(rst_n), .en(div_dp_vld), .d(accumulator_nc), .q(accumulator));

// TODO: check div res use quotient or quotient_nc
assign  div_res = quotient;

// Control Logic
assign  div_illegal     = (src2 == 32'b0);
assign  div_dp_vld      = div_vld & ~div_done;

dffre #(6) div_counter (.clk(clk), rst_n(rst_n), .en(div_dp_vld), .d(div_cnt_nc), .q(div_cnt));
assign  div_cnt_nc  = (div_dp_vld)? (div_cnt + 1'b1) : 6'd0;
assign  div_done    = (div_cnt == 6'd47) | div_illegal;
assign  div_res_vld = div_done & (~div_illegal);
assign  div_sign    = src1_sign ^ src2_sign;

endmodule

