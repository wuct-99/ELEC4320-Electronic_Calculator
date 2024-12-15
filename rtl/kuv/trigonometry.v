module trigonometry (
    clk,
    rst_n,
    src1,
    tri_vld,
    tri_mode,
    tri_res,
    tri_sign,
    tri_res_vld
);

// Module Interface
input           clk;
input           rst_n;
input   [15:0]  src1;
input           tri_vld;
input   [2:0]   tri_mode;

output  [31:0]  tri_res;
output          tri_sign;
output          tri_res_vld;

// CORDIC arctan Table
parameter angle00   = 32'd2949120;
parameter angle01   = 32'd1740992;
parameter angle02   = 32'd919872;
parameter angle03   = 32'd466944;
parameter angle04   = 32'd234368;
parameter angle05   = 32'd117312;
parameter angle06   = 32'd58688;
parameter angle07   = 32'd29312;
parameter angle08   = 32'd14656;
parameter angle09   = 32'd7360;
parameter angle10   = 32'd3648;
parameter angle11   = 32'd1856;
parameter angle12   = 32'd896;
parameter angle13   = 32'd448;
parameter angle14   = 32'd256;
parameter angle15   = 32'd128;
parameter K         = 32'h09b74;

// Internal Signals
wire            sin_vld;
wire            cos_vld;
wire            tan_vld;
wire    [31:0]  sin_res;
wire    [31:0]  cos_res;
wire    [31:0]  tan_res;
wire            sin_res_sign;
wire            cos_res_sign;
wire            tan_res_sign;
wire    [3:0]   tri_cnt_nc;
wire    [3:0]   tri_cnt;
wire            tri_cnt_done;
wire            tri_cnt_vld;
wire    [31:0]  tri2div_sin_res;
wire    [31:0]  tri2div_cos_res;
wire            tri2div_vld;
wire    [31:0]  div2tri_res;
wire            div2tri_res_vld;
wire    [31:0]  src1_unsigned;

// Control Logic
assign  sin_vld = tri_mode[0];
assign  cos_vld = tri_mode[1];
assign  tan_vld = tri_mode[2];

assign  tri_cnt_vld     = ~(tri_cnt_done);
assign  tri_cnt_nc      = (tri_vld)? (tri_cnt + 1'b1) : 4'b0;
assign  tri_cnt_done    = (tri_cnt == 4'b1111) & tri_vld;
dffre   #(4) counter (.clk(clk), .rst_n(rst_n), .en(tri_cnt_vld), .d(tri_cnt_nc), .q(tri_cnt));

// CORDIC Algorithm
wire signed [31:0] x00_nc, y00_nc, z00_nc;
wire signed [31:0] x01_nc, y01_nc, z01_nc;
wire signed [31:0] x02_nc, y02_nc, z02_nc;
wire signed [31:0] x03_nc, y03_nc, z03_nc;
wire signed [31:0] x04_nc, y04_nc, z04_nc;
wire signed [31:0] x05_nc, y05_nc, z05_nc;
wire signed [31:0] x06_nc, y06_nc, z06_nc;
wire signed [31:0] x07_nc, y07_nc, z07_nc;
wire signed [31:0] x08_nc, y08_nc, z08_nc;
wire signed [31:0] x09_nc, y09_nc, z09_nc;
wire signed [31:0] x10_nc, y10_nc, z10_nc;
wire signed [31:0] x11_nc, y11_nc, z11_nc;
wire signed [31:0] x12_nc, y12_nc, z12_nc;
wire signed [31:0] x13_nc, y13_nc, z13_nc;
wire signed [31:0] x14_nc, y14_nc, z14_nc;
wire signed [31:0] x15_nc, y15_nc, z15_nc;
wire signed [31:0] x16_nc, y16_nc, z16_nc;
wire signed [31:0] x00, y00, z00;
wire signed [31:0] x01, y01, z01;
wire signed [31:0] x02, y02, z02;
wire signed [31:0] x03, y03, z03;
wire signed [31:0] x04, y04, z04;
wire signed [31:0] x05, y05, z05;
wire signed [31:0] x06, y06, z06;
wire signed [31:0] x07, y07, z07;
wire signed [31:0] x08, y08, z08;
wire signed [31:0] x09, y09, z09;
wire signed [31:0] x10, y10, z10;
wire signed [31:0] x11, y11, z11;
wire signed [31:0] x12, y12, z12;
wire signed [31:0] x13, y13, z13;
wire signed [31:0] x14, y14, z14;
wire signed [31:0] x15, y15, z15;
wire signed [31:0] x16, y16, z16;

assign  x00_nc = K;
assign  y00_nc = 32'b0;
assign  z00_nc = {src1, 16'b0};

assign  x01_nc = z00[31]? (x00 + y00)           : (x00 - y00);
assign  x02_nc = z01[31]? (x01 + (y01 >>> 1))   : (x01 - (y01 >>> 1));
assign  x03_nc = z02[31]? (x02 + (y02 >>> 2))   : (x02 - (y02 >>> 2));
assign  x04_nc = z03[31]? (x03 + (y03 >>> 3))   : (x03 - (y03 >>> 3));
assign  x05_nc = z04[31]? (x04 + (y04 >>> 4))   : (x04 - (y04 >>> 4));
assign  x06_nc = z05[31]? (x05 + (y05 >>> 5))   : (x05 - (y05 >>> 5));
assign  x07_nc = z06[31]? (x06 + (y06 >>> 6))   : (x06 - (y06 >>> 6));
assign  x08_nc = z07[31]? (x07 + (y07 >>> 7))   : (x07 - (y07 >>> 7));
assign  x09_nc = z08[31]? (x08 + (y08 >>> 8))   : (x08 - (y08 >>> 8));
assign  x10_nc = z09[31]? (x09 + (y09 >>> 9))   : (x09 - (y09 >>> 9));
assign  x11_nc = z10[31]? (x10 + (y10 >>> 10))  : (x10 - (y10 >>> 10));
assign  x12_nc = z11[31]? (x11 + (y11 >>> 11))  : (x11 - (y11 >>> 11));
assign  x13_nc = z12[31]? (x12 + (y12 >>> 12))  : (x12 - (y12 >>> 12));
assign  x14_nc = z13[31]? (x13 + (y13 >>> 13))  : (x13 - (y13 >>> 13));
assign  x15_nc = z14[31]? (x14 + (y14 >>> 14))  : (x14 - (y14 >>> 14));
assign  x16_nc = z15[31]? (x15 + (y15 >>> 15))  : (x15 - (y15 >>> 15));

assign  y01_nc = z00[31]? (y00 - x00)           : (y00 + x00);
assign  y02_nc = z01[31]? (y01 - (x01 >>> 1))   : (y01 + (x01 >>> 1));
assign  y03_nc = z02[31]? (y02 - (x02 >>> 2))   : (y02 + (x02 >>> 2));
assign  y04_nc = z03[31]? (y03 - (x03 >>> 3))   : (y03 + (x03 >>> 3));
assign  y05_nc = z04[31]? (y04 - (x04 >>> 4))   : (y04 + (x04 >>> 4));
assign  y06_nc = z05[31]? (y05 - (x05 >>> 5))   : (y05 + (x05 >>> 5));
assign  y07_nc = z06[31]? (y06 - (x06 >>> 6))   : (y06 + (x06 >>> 6));
assign  y08_nc = z07[31]? (y07 - (x07 >>> 7))   : (y07 + (x07 >>> 7));
assign  y09_nc = z08[31]? (y08 - (x08 >>> 8))   : (y08 + (x08 >>> 8));
assign  y10_nc = z09[31]? (y09 - (x09 >>> 9))   : (y09 + (x09 >>> 9));
assign  y11_nc = z10[31]? (y10 - (x10 >>> 10))  : (y10 + (x10 >>> 10));
assign  y12_nc = z11[31]? (y11 - (x11 >>> 11))  : (y11 + (x11 >>> 11));
assign  y13_nc = z12[31]? (y12 - (x12 >>> 12))  : (y12 + (x12 >>> 12));
assign  y14_nc = z13[31]? (y13 - (x13 >>> 13))  : (y13 + (x13 >>> 13));
assign  y15_nc = z14[31]? (y14 - (x14 >>> 14))  : (y14 + (x14 >>> 14));
assign  y16_nc = z15[31]? (y15 - (x15 >>> 15))  : (y15 + (x15 >>> 15));

assign  z01_nc = z00[31]? (z00 + angle00) : (z00 - angle00);
assign  z02_nc = z01[31]? (z01 + angle01) : (z01 - angle01);
assign  z03_nc = z02[31]? (z02 + angle02) : (z02 - angle02);
assign  z04_nc = z03[31]? (z03 + angle03) : (z03 - angle03);
assign  z05_nc = z04[31]? (z04 + angle04) : (z04 - angle04);
assign  z06_nc = z05[31]? (z05 + angle05) : (z05 - angle05);
assign  z07_nc = z06[31]? (z06 + angle06) : (z06 - angle06);
assign  z08_nc = z07[31]? (z07 + angle07) : (z07 - angle07);
assign  z09_nc = z08[31]? (z08 + angle08) : (z08 - angle08);
assign  z10_nc = z09[31]? (z09 + angle09) : (z09 - angle09);
assign  z11_nc = z10[31]? (z10 + angle10) : (z10 - angle10);
assign  z12_nc = z11[31]? (z11 + angle11) : (z11 - angle11);
assign  z13_nc = z12[31]? (z12 + angle12) : (z12 - angle12);
assign  z14_nc = z13[31]? (z13 + angle13) : (z13 - angle13);
assign  z15_nc = z14[31]? (z14 + angle14) : (z14 - angle14);
assign  z16_nc = z15[31]? (z15 + angle15) : (z15 - angle15);

dffr #(32) x00_ff (.clk(clk), .rst_n(rst_n), .d(x00_nc), .q(x00));
dffr #(32) x01_ff (.clk(clk), .rst_n(rst_n), .d(x01_nc), .q(x01));
dffr #(32) x02_ff (.clk(clk), .rst_n(rst_n), .d(x02_nc), .q(x02));
dffr #(32) x03_ff (.clk(clk), .rst_n(rst_n), .d(x03_nc), .q(x03));
dffr #(32) x04_ff (.clk(clk), .rst_n(rst_n), .d(x04_nc), .q(x04));
dffr #(32) x05_ff (.clk(clk), .rst_n(rst_n), .d(x05_nc), .q(x05));
dffr #(32) x06_ff (.clk(clk), .rst_n(rst_n), .d(x06_nc), .q(x06));
dffr #(32) x07_ff (.clk(clk), .rst_n(rst_n), .d(x07_nc), .q(x07));
dffr #(32) x08_ff (.clk(clk), .rst_n(rst_n), .d(x08_nc), .q(x08));
dffr #(32) x09_ff (.clk(clk), .rst_n(rst_n), .d(x09_nc), .q(x09));
dffr #(32) x10_ff (.clk(clk), .rst_n(rst_n), .d(x10_nc), .q(x10));
dffr #(32) x11_ff (.clk(clk), .rst_n(rst_n), .d(x11_nc), .q(x11));
dffr #(32) x12_ff (.clk(clk), .rst_n(rst_n), .d(x12_nc), .q(x12));
dffr #(32) x13_ff (.clk(clk), .rst_n(rst_n), .d(x13_nc), .q(x13));
dffr #(32) x14_ff (.clk(clk), .rst_n(rst_n), .d(x14_nc), .q(x14));
dffr #(32) x15_ff (.clk(clk), .rst_n(rst_n), .d(x15_nc), .q(x15));
dffr #(32) x16_ff (.clk(clk), .rst_n(rst_n), .d(x16_nc), .q(x16));

dffr #(32) y00_ff (.clk(clk), .rst_n(rst_n), .d(y00_nc), .q(y00));
dffr #(32) y01_ff (.clk(clk), .rst_n(rst_n), .d(y01_nc), .q(y01));
dffr #(32) y02_ff (.clk(clk), .rst_n(rst_n), .d(y02_nc), .q(y02));
dffr #(32) y03_ff (.clk(clk), .rst_n(rst_n), .d(y03_nc), .q(y03));
dffr #(32) y04_ff (.clk(clk), .rst_n(rst_n), .d(y04_nc), .q(y04));
dffr #(32) y05_ff (.clk(clk), .rst_n(rst_n), .d(y05_nc), .q(y05));
dffr #(32) y06_ff (.clk(clk), .rst_n(rst_n), .d(y06_nc), .q(y06));
dffr #(32) y07_ff (.clk(clk), .rst_n(rst_n), .d(y07_nc), .q(y07));
dffr #(32) y08_ff (.clk(clk), .rst_n(rst_n), .d(y08_nc), .q(y08));
dffr #(32) y09_ff (.clk(clk), .rst_n(rst_n), .d(y09_nc), .q(y09));
dffr #(32) y10_ff (.clk(clk), .rst_n(rst_n), .d(y10_nc), .q(y10));
dffr #(32) y11_ff (.clk(clk), .rst_n(rst_n), .d(y11_nc), .q(y11));
dffr #(32) y12_ff (.clk(clk), .rst_n(rst_n), .d(y12_nc), .q(y12));
dffr #(32) y13_ff (.clk(clk), .rst_n(rst_n), .d(y13_nc), .q(y13));
dffr #(32) y14_ff (.clk(clk), .rst_n(rst_n), .d(y14_nc), .q(y14));
dffr #(32) y15_ff (.clk(clk), .rst_n(rst_n), .d(y15_nc), .q(y15));
dffr #(32) y16_ff (.clk(clk), .rst_n(rst_n), .d(y16_nc), .q(y16));

dffr #(32) z00_ff (.clk(clk), .rst_n(rst_n), .d(z00_nc), .q(z00));
dffr #(32) z01_ff (.clk(clk), .rst_n(rst_n), .d(z01_nc), .q(z01));
dffr #(32) z02_ff (.clk(clk), .rst_n(rst_n), .d(z02_nc), .q(z02));
dffr #(32) z03_ff (.clk(clk), .rst_n(rst_n), .d(z03_nc), .q(z03));
dffr #(32) z04_ff (.clk(clk), .rst_n(rst_n), .d(z04_nc), .q(z04));
dffr #(32) z05_ff (.clk(clk), .rst_n(rst_n), .d(z05_nc), .q(z05));
dffr #(32) z06_ff (.clk(clk), .rst_n(rst_n), .d(z06_nc), .q(z06));
dffr #(32) z07_ff (.clk(clk), .rst_n(rst_n), .d(z07_nc), .q(z07));
dffr #(32) z08_ff (.clk(clk), .rst_n(rst_n), .d(z08_nc), .q(z08));
dffr #(32) z09_ff (.clk(clk), .rst_n(rst_n), .d(z09_nc), .q(z09));
dffr #(32) z10_ff (.clk(clk), .rst_n(rst_n), .d(z10_nc), .q(z10));
dffr #(32) z11_ff (.clk(clk), .rst_n(rst_n), .d(z11_nc), .q(z11));
dffr #(32) z12_ff (.clk(clk), .rst_n(rst_n), .d(z12_nc), .q(z12));
dffr #(32) z13_ff (.clk(clk), .rst_n(rst_n), .d(z13_nc), .q(z13));
dffr #(32) z14_ff (.clk(clk), .rst_n(rst_n), .d(z14_nc), .q(z14));
dffr #(32) z15_ff (.clk(clk), .rst_n(rst_n), .d(z15_nc), .q(z15));
dffr #(32) z16_ff (.clk(clk), .rst_n(rst_n), .d(z16_nc), .q(z16));

assign  src1_unsigned   = ~src1 + 1'b1;
assign  sin_res         = (src1_unsigned == 16'd0)  ? 32'h0 :
                          (src1_unsigned == 16'd90) ? 32'h10000:
                          y16[31]                   ? (~y16 + 1'b1):
                          y16;
assign  cos_res         = (src1_unsigned == 16'd0)  ? 32'h10000 :
                          (src1_unsigned == 16'd90) ? 32'h0:
                          x16[31]                   ? (~x16 + 1'b1):
                          x16;

assign  sin_res_sign    = ((src1_unsigned != 16'd0) | (src1_unsigned != 16'd90))? src1[15] : y16[31];
assign  cos_res_sign    = ((src1_unsigned != 16'd0) | (src1_unsigned != 16'd90))? src1[15] : x16[31];
assign  tan_res_sign    = sin_res_sign ^ cos_res_sign;

assign  tri2div_sin_res = sin_res;
assign  tri2div_cos_res = cos_res;
assign  tri2div_vld     = tan_vld & tri_cnt_done;

divider tan_res (
    .clk            (clk),
    .rst_n          (rst_n),
    .src1           (tri2div_sin_res),
    .src2           (tri2div_cos_res),
    .src1_sign      (1'b0),
    .src2_sign      (1'b0),
    .div_vld        (tri2div_vld),
    .div_res        (div2tri_res),
    .div_sign       (),
    .div_res_vld    (div2tri_res_vld)
);

assign  tan_res = div2tri_res;

assign  tri_res         = ({32{sin_vld}}) & sin_res |
                          ({32{cos_vld}}) & cos_res |
                          ({32{tan_vld}}) & tan_res;

assign  tri_res_sign    = ({32{sin_vld}}) & sin_res_sign |
                          ({32{cos_vld}}) & cos_res_sign |
                          ({32{tan_vld}}) & tan_res_sign;

assign  tri_res_vld     = (sin_vld & tri_cnt_done) | (cos_vld & tri_cnt_done) |
                          (tan_vld & div2tri_res_vld);

endmodule