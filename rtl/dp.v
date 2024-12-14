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
wire                src_is_sign;
wire    [10:0]      mode_vld;
wire    [15:0]      dp_src1;
wire    [15:0]      dp_src2;
wire                dp_src1_sign;
wire                dp_src2_sign;

wire    [2:0]       int_dp_mode;
wire    [31:0]      int_dp_res;
wire                int_res_sign;
wire                int_res_vld;

wire                div_vld;
wire    [31:0]      div_src1_pre;
wire    [31:0]      div_src2_pre;
wire    [31:0]      div_src1;
wire    [31:0]      div_src2;
wire    [31:0]      div_res;
wire                div_sign;
wire                div_done;
wire                div_res_vld;

wire                trig_vld;
wire                trig_done;
wire    [31:0]      trig_sin_res;
wire    [31:0]      trig_cos_res;
wire                trig_sin_sign;
wire                trig_cos_sign;

wire                sqrt_done;
wire                log_done;
wire                pow_done;
wire                exp_done;

// Control Logic
assign  mode_vld    = (10{cal_stage_vld}) & mode;
assign  int_dp_mode = mode_vld[2:0];

assign  is_add = mode_vld[0];
assign  is_sub = mode_vld[1];
assign  is_mul = mode_vld[2];
assign  is_div = mode_vld[3];
assign  is_sqr = mode_vld[4];
assign  is_sin = mode_vld[5];
assign  is_cos = mode_vld[6];
assign  is_tan = mode_vld[7];
assign  is_log = mode_vld[8];
assign  is_pow = mode_vld[9];
assign  is_exp = mode_vld[10];

assign  src_is_sign     = is_add | is_sub | is_sin | is_cos | is_tan;
assign  dp_src1         = (src_is_sign)? signed_src1 : unsigned_src1;
assign  dp_src2         = (src_is_sign)? signed_src2 : unsigned_src2;
assign  dp_src1_sign    = src1_sign;
assign  dp_src2_sign    = src2_sign;

// TODO: add flop to result output

// 1 Cycle Addition, Subtraction, Multiplication
integerdp u_integerdp (
    .clk            (clk),
    .rst_n          (rst_n),
    .dp_src1        (dp_src1),
    .dp_src2        (dp_src2),
    .dp_src1_sign   (dp_src1_sign),
    .dp_src2_sign   (dp_src2_sign),
    .int_dp_mode    (int_dp_mode),
    .int_res        (int_dp_res),
    .int_res_sign   (int_res_sign),
    .int_res_vld    (int_res_vld)
);

// Division Datapath
assign  div_vld     = is_div | (is_tan & trig_done) | (is_pow & pow_to_div_vld);

// TODO: add power input to div
assign  div_src1_pre    = {16'b0, dp_src1};
assign  div_src2_pre    = {16'b0, dp_src2};
assign  div_src1        = ((32{is_div}) & div_src1_pre) | ((32{trig_done}) & trig_sin_res);
assign  div_src2        = ((32{is_div}) & div_src2_pre) | ((32{trig_done}) & trig_cos_res);

divider u_dividier (
    .clk            (clk),
    .rst_n          (rst_n),
    .src1           (div_src1),
    .src2           (div_src2),
    .src1_sign      (dp_src1_sign),
    .src2_sign      (dp_src2_sign),
    .div_vld        (div_vld),
    .div_res        (div_res),
    .div_sign       (div_sign),
    .div_done       (div_done),
    .div_res_vld    (div_res_vld)
);

// Trigonometry Datapath
assign  trig_vld = is_sin | is_cos | is_tan;

trigonometry u_trigonometry (
    .clk            (clk),
    .rst_n          (rst_n),
    .src1           (dp_src1),
    .trig_vld       (trig_vld),
    .trig_sin_res   (trig_sin_res),
    .trig_cos_res   (trig_cos_res),
    .trig_sin_sign  (trig_sin_sign),
    .trig_cos_sign  (trig_cos_sign),
    .trig_done      (trig_done)
);

// Square Root Datapath
sqrt u_sqrt (


);

// Power Datapath
// TODO: add power to div datapath
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

// Exponential Datapath
exponential u_exponential (


);

// Logarithm Datapath
logarithm u_logarithm (


);

// Datapath Module Output

endmodule