module power (
    clk,
    rst_n,
    pow_vld,
    src1,
    src2,
    src1_sign,
    src2_sign,
    pow_res,
    pow_res_vld,
    pow_sign
);

// Module Interface
input           clk;
input           rst_n;
input           pow_vld;
input   [15:0]  src1;
input   [15:0]  src2;
input           src1_sign;
input           src2_sign;

output  [31:0]  pow_res;
output          pow_res_vld;
output          pow_sign;

// Internal Signals
wire            power_ovf; 
wire    [32:0]  power_data;
wire    [32:0]  power_data_nc;
wire    [32:0]  power_data_pre;
wire            power_cnt_done;
wire            pos_exponent_done;
wire            neg_exponent_done;
wire            exponent_is_0;
wire            result_invld;
wire    [3:0]   cnt;
wire    [3:0]   cnt_nc;
wire            cnt_en;
wire    [31:0]  pow2div_src1;
wire    [31:0]  pow2div_src2;
wire            pow2div_src1_sign;
wire            pow2div_src2_sign;
wire            pow2div_vld;
wire    [31:0]  div2pow_res;
wire            div2pow_res_vld;

// Control Logic
assign  exponent_is_0 = (src2 == 16'b0);
assign  cnt_en = pow_vld & ~power_cnt_done;
assign  cnt_nc = (pow_vld)? (cnt + 1'b1) : 4'b0;
dffre #(4) counter (.clk(clk), .rst_n(rst_n), .en(cnt_en), .d(cnt_nc), .q(cnt));
assign  power_cnt_done      = (cnt == src2[3:0]);
assign  result_invld        = exponent_is_0 | power_ovf;
assign  pos_exponent_done   = power_cnt_done & ~src2_sign;
assign  neg_exponent_done   = src2_sign & div2pow_res_vld;

// Power Datapath
//      - Exponent = 0, output = 1
//      - Exponent +ve, src1 * src1
//      - Exponent -ve, src1 * src1, --> to divider
//      - Source +ve, src1 * src1, +ve  
//      - Source -ve, src1 * src1
//          - Exponent odd, -ve
//          - Exponent even, +ve

assign  power_ovf       = power_data[32];
assign  power_data_pre  = (pow_vld)? power_data : {1'b0, src1};
assign  power_data_nc   = (power_cnt_done)? 33'b0 : (power_data_pre * src1);
dffre #(32) power_data (.clk(clk), .rst_n(rst_n), .en(cnt_en), .d(power_data_nc), .q(power_data)); 

// Negative Exponent Handling
//  - Sign is handled out here
assign  pow2div_src1        = 31'b1;
assign  pow2div_src1_sign   = 1'b0;
assign  pow2div_src2        = power_data;
assign  pow2div_src2_sign   = 1'b0;
assign  pow2div_vld         = src2_sign & power_cnt_done;

divider negative_exponent_divider (
    .clk            (clk),
    .rst_n          (rst_n),
    .src1           (pow2div_src1),
    .src2           (pow2div_src2),
    .src1_sign      (pow2div_src1_sign),
    .src2_sign      (pow2div_src2_sign),
    .div_vld        (pow2div_vld),
    .div_res        (div2pow_res),
    .div_sign       (),
    .div_done       (),
    .div_res_vld    (div2pow_res_vld)
);

// End Condition:
//  1. Result is invalid
//  2. +ve exponent done
//  3. -ve exponent + divider done
// MUX Output
assign  pow_res     = (({32{result_invld}}) & 32'b0) | (({32{pos_exponent_done}}) & power_data) |
                      (({32{neg_exponent_done}}) & div2pow_res);
assign  pow_sign    = src1_sign & src2[0];
assign  pow_res_vld = result_invld | pos_exponent_done | neg_exponent_done;

endmodule