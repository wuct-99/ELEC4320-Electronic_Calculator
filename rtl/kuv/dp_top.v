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
    dp_res_done
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
output              dp_res_done;

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

assign  add_res_signed  = signed_src1 + signed_src2;
assign  add_res         = (add_res_signed[15])? (~add_res_signed + 1'b1) : add_res_signed;
assign  add_sign        = add_res_signed[15];

dffre #(16) (.clk(clk), .rst_n(rst_n), .en(is_add), .d(add_res), .q(add2output_res));
dffre #(1)  (.clk(clk), .rst_n(rst_n), .en(is_add), .d(add_sign), .q(add2output_sign));
// =================================== //

// Subtraction Datapath ============== //
wire signed [15:0]  sub_res_signed;
wire        [15:0]  sub_res;
wire                sub_sign;
wire        [15:0]  sub2output_res;
wire                sub2output_sign;

assign  sub_res_signed  = signed_src1 - signed_src2;
assign  sub_res         = (sub_res_signed[15])? (~sub_res_signed + 1'b1) : sub_res_signed;
assign  sub_sign        = sub_res_signed[15];

dffre #(16) (.clk(clk), .rst_n(rst_n), .en(is_sub), .d(sub_res), .q(sub2output_res));
dffre #(1)  (.clk(clk), .rst_n(rst_n), .en(is_sub), .d(sub_sign), .q(sub2output_sign));
// =================================== //

// Multiplication Datapath =========== //
wire    [31:0]      mul_res;
wire                mul_sign;
wire    [31:0]      mul2output_res;
wire                mul2output_sign;

assign  mul_res     = unsigned_src1 * unsigned_src2;
assign  mul_sign    = src1_sign ^ src2_sign;
dffre #(32) (.clk(clk), .rst_n(rst_n), .en(is_mul), .d(mul_res), .q(mul2output_res));
dffre #(1)  (.clk(clk), .rst_n(rst_n), .en(is_mul), .d(mul_sign), .q(mul2output_sign));
// =================================== //

// Division Datapath ================= //
// TODO: check whether div_done is needed
wire    [31:0]      div_res;
wire                div_sign;
wire                div_done;
wire                div_res_vld;
wire    [31:0]      div2output_res;
wire                div2output_sign;

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
    .div_done       (div_done),
    .div_res_vld    (div_res_vld)
);

dffre #(32) (.clk(clk), .rst_n(rst_n), .en(div_res_vld), .d(div_res), .q(div2output_res));
dffre #(1)  (.clk(clk), .rst_n(rst_n), .en(div_res_vld), .d(div_sign), .q(div2output_sign));
// =================================== //

// Trigonometry Datapath ============= //
// TODO: instantiate division datapath into trigo datapath
wire                trig_vld;
wire    [31:0]      trig_res;
wire                trig_sign;
wire    [31:0]      trig2output_res;
wire                trig2output_sign;
wire                trig_res_vld;

assign  trig_vld = is_sin | is_cos | is_tan;

trigonometry u_trigonometry (
    .clk            (clk),
    .rst_n          (rst_n),
    .src1           (signed_src1),
    .trig_vld       (trig_vld),
    .trig_sin_res   (trig_sin_res),
    .trig_cos_res   (trig_cos_res),
    .trig_sin_sign  (trig_sin_sign),
    .trig_cos_sign  (trig_cos_sign),
    .trig_done      (trig_done)
);

dffre #(32) (.clk(clk), .rst_n(rst_n), .en(trig_done), .d(trig_res), .q(trig2output_res));
dffre #(1)  (.clk(clk), .rst_n(rst_n), .en(trig_done), .d(trig_sign), .q(trig2output_sign));
// =================================== //

// Square Root Datapath ============== //
sqrt u_sqrt (
    .clk            (clk),
    .rst_n          (rst_n),

);
// =================================== //

// Power Datapath ==================== //
// Need bit to specify power data output display format
wire    [31:0]      pow_res;
wire                pow_sign;
wire                pow_done;

power u_power (
    .clk            (clk),
    .rst_n          (rst_n),
    .pow_vld        (is_pow),
    .src1           (dp_src1),
    .src2           (dp_src2),
    .src1_sign      (dp_src1_sign),
    .src2_sign      (dp_src2_sign),
    .pow_res        (pow_res),
    .pow_done       (pow_done),
    .pow_sign       (pow_sign)
);
// =================================== //

// Exponential Datapath ============== //
// TODO: instantiate division datapath into exponential datapath
exponential u_exponential (
    .clk            (clk),
    .rst_n          (rst_n),

);
// =================================== //

// Logarithm Datapath ================ //
logarithm u_logarithm (
    .clk            (clk),
    .rst_n          (rst_n),

);
// =================================== //

// Datapath Module Output ============ //

// =================================== //

endmodule