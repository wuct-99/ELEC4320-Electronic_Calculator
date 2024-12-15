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
output          div_res_vld;

// Internal Signals
wire            div_by_zero;
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
wire            div_cnt_done;
wire            div_cnt_vld;

// Division Datapath
// - Total cycles = number of bits + number of fraction bits = 32 + 16 = 48 (0 - 47)
// 1. Left shift dividend into accumulator
// 2. Check accumulator >= divisor?
//      - Accumulator >= divisor: accumulator = accumulator - divisor, quotient[0] = 1
//      - Accumulator < divisor: continue
// 3. Left shift quotient
// End Condition:
//  1. Divide by zero
//  2. Calculation done (counter done)
assign  div_by_zero = (src2 == 32'b0);
assign  div_res_vld = (div_by_zero | div_cnt_done) & div_vld;
assign  div_res     = (div_by_zero)? 32'hffff_ffff : quotient;
assign  div_sign    = src1_sign ^ src2_sign;

assign  dividend    = src1;
assign  divisor     = src2;

assign  accumulator_shift   = (div_cnt_vld)? ({accumulator[30:0]}, dividend[31]) : 32'b0;
assign  accumulator_nc      = (accumulator_shift >= divisor)? (accumulator_shift - divisor) : (accumulator_shift);
assign  quotient_shift      = (div_cnt_vld)? ({quotient[30:0], 1'b0}) : 32'b0;
assign  quotient_nc         = (accumulator_shift >= divisor)? ({quotient_shift[30:1], 1'b1}) : quotient_shift;

dffr #(32) accumulator_ff  (.clk(clk), .rst_n(rst_n), .d(accumulator_nc), .q(accumulator));
dffr #(32) quotient_ff     (.clk(clk), .rst_n(rst_n), .d(quotient_nc), .q(quotient));

// Division Counter
assign  div_cnt_vld     = div_vld & ~(div_by_zero | div_cnt_done);
assign  div_cnt_nc      = (div_cnt_vld)? (div_cnt + 1'b1) : 6'b0;
assign  div_cnt_done    = (div_cnt == 6'd48);
dffr #(6) div_counter (.clk(clk), .rst_n(rst_n), .d(div_cnt_nc), .q(div_cnt));

endmodule