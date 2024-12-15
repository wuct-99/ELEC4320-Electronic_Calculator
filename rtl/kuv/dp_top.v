module dp (
    clk,
    rst_n,
    mode,
    cal_stage_vld,
    signed_src1,
    signed_src2,
    unsigned_src1,
    unsigned_src2,
    src1_sign,
    src2_sign,
    dp_res,
    dp_res_sign,
    dp_res_vld,
    dp_mode
);

// Module Interface
input               clk;
input               rst_n;
input   [10:0]      mode;
input               cal_stage_vld;
input   [15:0]      signed_src1;
input   [15:0]      signed_src2;
input   [15:0]      unsigned_src1;
input   [15:0]      unsigned_src2;
input               src1_sign;
input               src2_sign;

// TODO: output separate integer part and fix point part?
output  [31:0]      dp_res;
output              dp_res_sign;
output              dp_res_vld;
output  [10:0]      dp_mode;

// Internal Signals
wire                is_add;
wire                is_sub;
wire                is_mul;
wire                is_div;
wire                is_sqr;
wire                is_sin;
wire                is_cos;
wire                is_tan;
wire                is_log;
wire                is_pow;
wire                is_exp;
wire    [10:0]      mode_vld;


// Control Logic
assign  mode_vld    = ({10{cal_stage_vld}}) & mode;
assign  is_add      = mode_vld[0];
assign  is_sub      = mode_vld[1];
assign  is_mul      = mode_vld[2];
assign  is_div      = mode_vld[3];
assign  is_sqr      = mode_vld[4];
assign  is_sin      = mode_vld[5];
assign  is_cos      = mode_vld[6];
assign  is_tan      = mode_vld[7];
assign  is_log      = mode_vld[8];
assign  is_pow      = mode_vld[9];
assign  is_exp      = mode_vld[10];

// TODO: add flop to result output

// Addition Datapath ================= //
wire signed [15:0]  add_res_signed;
wire        [15:0]  add_res;
wire                add_sign;
wire        [15:0]  add2output_res;
wire                add2output_sign;
wire                add2output_vld;

assign  add_res_signed  = signed_src1 + signed_src2;
assign  add_res         = (add_res_signed[15])? (~add_res_signed + 1'b1) : add_res_signed;
assign  add_sign        = add_res_signed[15];

dffre   #(16)   add2output_res      (.clk(clk), .rst_n(rst_n), .en(is_add), .d(add_res), .q(add2output_res));
dffre   #(1)    add2output_sign     (.clk(clk), .rst_n(rst_n), .en(is_add), .d(add_sign), .q(add2output_sign));
dffr    #(1)    add2output_vld      (.clk(clk), ,rst_n(rst_n), .d(is_add), .q(add2output_vld));
// =================================== //

// Subtraction Datapath ============== //
wire signed [15:0]  sub_res_signed;
wire        [15:0]  sub_res;
wire                sub_sign;
wire        [15:0]  sub2output_res;
wire                sub2output_sign;
wire                sub2output_vld;

assign  sub_res_signed  = signed_src1 - signed_src2;
assign  sub_res         = (sub_res_signed[15])? (~sub_res_signed + 1'b1) : sub_res_signed;
assign  sub_sign        = sub_res_signed[15];

dffre   #(16)   sub2output_res      (.clk(clk), .rst_n(rst_n), .en(is_sub), .d(sub_res), .q(sub2output_res));
dffre   #(1)    sub2output_sign     (.clk(clk), .rst_n(rst_n), .en(is_sub), .d(sub_sign), .q(sub2output_sign));
dffr    #(1)    sub2output_vld      (.clk(clk), .rst_n(rst_n), .d(is_sub), .q(sub2output_vld));
// =================================== //

// Multiplication Datapath =========== //
wire    [31:0]      mul_res;
wire                mul_sign;
wire    [31:0]      mul2output_res;
wire                mul2output_sign;
wire                mul2output_vld;

assign  mul_res     = unsigned_src1 * unsigned_src2;
assign  mul_sign    = src1_sign ^ src2_sign;
dffre   #(32)   mul2output_res      (.clk(clk), .rst_n(rst_n), .en(is_mul), .d(mul_res), .q(mul2output_res));
dffre   #(1)    mul2output_sign     (.clk(clk), .rst_n(rst_n), .en(is_mul), .d(mul_sign), .q(mul2output_sign));
dffr    #(1)    mul2output_vld      (.clk(clk), .rst_n(rst_n), .d(is_mul), .q(is_mul));
// =================================== //

// Division Datapath ================= //
wire    [31:0]      div_res;
wire                div_sign;
wire                div_res_vld;
wire    [31:0]      div2output_res;
wire                div2output_sign;
wire                div2output_vld;

divider u_divider (
    .clk            (clk),
    .rst_n          (rst_n),
    .src1           (unsigned_src1),
    .src2           (unsigned_src2),
    .src1_sign      (src1_sign),
    .src2_sign      (src2_sign),
    .div_vld        (is_div),
    .div_res        (div_res),
    .div_sign       (div_sign),
    .div_res_vld    (div_res_vld)
);

dffre   #(32) div2output_res    (.clk(clk), .rst_n(rst_n), .en(div_res_vld), .d(div_res), .q(div2output_res));
dffre   #(1)  div2output_sign   (.clk(clk), .rst_n(rst_n), .en(div_res_vld), .d(div_sign), .q(div2output_sign));
dffr    #(1)  div2output_vld    (.clk(clk), .rst_n(rst_n), .d(div_res_vld), .q(div2output_vld));
// =================================== //

// Trigonometry Datapath ============= //
wire                is_tri;
wire    [2:0]       tri_mode;
wire    [31:0]      tri_res;
wire                tri_sign;
wire                tri_res_vld;
wire    [31:0]      tri2output_res;
wire                tri2output_sign;
wire                tri2output_vld;

assign  is_tri      = is_sin | is_cos | is_tan;
assign  tri_mode    = {is_tan, is_cos, is_sin};

trigonometry u_trigonometry (
    .clk            (clk),
    .rst_n          (rst_n),
    .src1           (signed_src1),
    .tri_vld        (is_tri),
    .tri_mode       (tri_mode),
    .tri_res        (tri_res),
    .tri_sign       (tri_sign),
    .tri_res_vld    (tri_res_vld)
);

dffre   #(32) tri2output_res    (.clk(clk), .rst_n(rst_n), .en(tri_res_vld), .d(tri_res), .q(tri2output_res));
dffre   #(1)  tri2output_sign   (.clk(clk), .rst_n(rst_n), .en(tri_res_vld), .d(tri_sign), .q(tri2output_sign));
dffr    #(1)  tri2output_vld    (.clk(clk), .rst_n(rst_n), .d(tri_res_vld), .q(tri2output_vld));
// =================================== //

// Square Root Datapath ============== //
wire    [31:0]      sqr_res;
wire                sqr_res_vld;
wire    [31:0]      sqr2output_res;
wire                sqr2output_sign;
wire                sqr2output_vld;

sqrt u_sqrt (
    .clk            (clk),
    .rst_n          (rst_n),
    .src1           (signed_src1),
    .src1_sign      (src1_sign),
    .sqr_vld        (is_sqr),
    .sqr_res        (sqr_res),
    .sqr_res_vld    (sqr_res_vld)
);

assign  sqr2output_sign = 1'b0;
dffre   #(32) sqr2output_res    (.clk(clk), .rst_n(rst_n), .en(sqr_res_vld), .d(sqr_res), .q(sqr2output_res));
dffr    #(1)  sqr2output_vld    (.clk(clk), .rst_n(rst_n), .d(sqr_res_vld), .q(sqr2output_vld));
// =================================== //

// Power Datapath ==================== //
// Need bit to specify power data output display format
wire    [31:0]      pow_res;
wire                pow_sign;
wire                pow_res_vld;
wire    [31:0]      pow2output_res;
wire                pow2output_sign;
wire                pow2output_vld;

power u_power (
    .clk            (clk),
    .rst_n          (rst_n),
    .pow_vld        (is_pow),
    .src1           (dp_src1),
    .src2           (dp_src2),
    .src1_sign      (dp_src1_sign),
    .src2_sign      (dp_src2_sign),
    .pow_res        (pow_res),
    .pow_res_vld    (pow_res_vld),
    .pow_sign       (pow_sign)
);
// =================================== //

//// Exponential Datapath ============== //
//exponential u_exponential (
//    .clk            (clk),
//    .rst_n          (rst_n),
//
//);
//// =================================== //
//
//// Logarithm Datapath ================ //
//logarithm u_logarithm (
//    .clk            (clk),
//    .rst_n          (rst_n),
//
//);
//// =================================== //

// Datapath Module Output ============ //
assign  dp_res      = ({32{is_add}}) & ({16'b0, add2output_res}) |
                      ({32{is_sub}}) & ({16'b0, sub2output_res}) | 
                      ({32{is_mul}}) & mul2output_res |
                      ({32{is_div}}) & div2output_res |
                      ({32{is_tri}}) & tri2output_res |
                      ({32{is_sqr}}) & sqr2output_res |
                      ({32{is_pow}}) & pow2output_res;

assign  dp_res_sign = ({32{is_add}}) & add2output_sign |
                      ({32{is_sub}}) & sub2output_sign | 
                      ({32{is_mul}}) & mul2output_sign |
                      ({32{is_div}}) & div2output_sign |
                      ({32{is_tri}}) & tri2output_sign |
                      ({32{is_sqr}}) & sqr2output_sign |
                      ({32{is_pow}}) & pow2output_sign;

assign  dp_res_vld  = add2output_vld | sub2output_vld | mul2output_vld | div2output_vld |
                      tri2output_vld | sqr2output_vld | pow2output_vld;
assign  dp_mode     = mode;

// =================================== //

endmodule