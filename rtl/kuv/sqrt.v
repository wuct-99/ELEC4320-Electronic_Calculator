module sqrt (
    clk,
    rst_n,
    src1,
    src1_sign,
    sqr_vld,
    sqr_res,
    sqr_res_vld
);

// Module Interface
input           clk;
input           rst_n;
input   [15:0]  src1;
input           src1_sign;
input           sqr_vld;

output  [31:0]  sqr_res;
output          sqr_res_vld;

// Internal Signals
wire    [4:0]   sqr_cnt_nc;
wire    [4:0]   sqr_cnt;
wire            sqr_cnt_done;
wire            sqr_cnt_vld;
wire    [63:0]  accumulator_shift;
wire    [63:0]  accumulator;
wire    [63:0]  accumulator_nc;
wire    [31:0]  sqrt_shift;
wire    [31:0]  sqrt_nc;
wire    [31:0]  sqrt_data;

wire signed [31:0]  sign_test;
wire signed [31:0]  sign_test_nc;

// Control Logic
assign  sqr_cnt_vld     = sqr_vld & (~src1_sign);
assign  sqr_cnt_nc      = (sqr_cnt_vld)? (sqr_cnt + 1'b1) : 5'b0;
assign  sqr_cnt_done    = (sqr_cnt == 5'd23);
dffr #(5) counter (.clk(clk), .rst_n(rst_n), .d(sqr_cnt_nc), .q(sqr_cnt));

// Square Root Datapath
assign  accumulator_shift       = (sqr_cnt_vld)? {accumulator_nc[61:0], 2'b0} : {32'b0, src1, 16'b0};
assign  sign_test_nc            = (sqr_cnt_vld)? (accumulator_shift[63:32] - {sqrt_data, 2'b01}): 32'hffff_ffff;
assign  accumulator_nc[63:32]   = ~(sign_test[31])? sign_test : accumulator_shift[63:32];
assign  accumulator_nc[31:0]    = accumulator_shift[31:0];
assign  sqrt_shift              = (sqr_cnt_vld)? {sqrt_data[30:0], 1'b0} : 32'h0;
assign  sqrt_nc[31:1]           = sqrt_shift[31:1];
assign  sqrt_nc[0]              = ~sign_test[31];

dffr #(64) accumulator_ff   (.clk(clk), .rst_n(rst_n), .d(accumulator_nc), .q(accumulator));
dffr #(32) sign_test_ff     (.clk(clk), .rst_n(rst_n), .d(sign_test_nc), .q(sign_test));
dffr #(32) sqrt_ff          (.clk(clk), .rst_n(rst_n), .d(sqrt_nc), .q(sqrt_data));

assign  sqr_res         = (src1_sign)? 32'hffff_ffff : sqrt_nc;
assign  sqrt_res_vld    = src1_sign | sqr_cnt_done;

endmodule