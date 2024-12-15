module trigonometric(
    clk,
    rst,
    tri_rst,
    tri_start,
    input_angle,
    cos_data,
    cos_sign,
    sin_data,
    sin_sign,
    tri_done
);


input clk;
input rst;
input tri_start;
input tri_rst;
input [15:0] input_angle;
output [31:0] cos_data;
output [31:0] sin_data;
output cos_sign;
output sin_sign;
output tri_done;

wire [3:0] tri_cnt_d;
wire [3:0] tri_cnt_q;
wire tri_cnt_en;
wire [15:0] unsign_angle;

wire tri_done_pre_d0;

//Cordic 

assign tri_cnt_d = tri_rst ? 4'b0 : tri_cnt_q + 4'b1;
assign tri_cnt_en = tri_start | tri_rst;
dflip_en #(4) tri_cnt_ff (.clk(clk), .rst(rst), .en(tri_cnt_en), .d(tri_cnt_d), .q(tri_cnt_q));
assign tri_done_pre = &tri_cnt_q;

dflip #(1) tri_done_pre_d0_ff (.clk(clk), .rst(rst), .d(tri_done_pre   ), .q(tri_done_pre_d0));
dflip #(1) tri_done_pre_d1_ff (.clk(clk), .rst(rst), .d(tri_done_pre_d0), .q(tri_done       ));

//arctan table
parameter ang_00 = 32'd2949120; //45deg * 2^16
parameter ang_01 = 32'd1740992;
parameter ang_02 = 32'd919872;
parameter ang_03 = 32'd466944;
parameter ang_04 = 32'd234368;
parameter ang_05 = 32'd117312;
parameter ang_06 = 32'd58688;
parameter ang_07 = 32'd29312;
parameter ang_08 = 32'd14656;
parameter ang_09 = 32'd7360;
parameter ang_10 = 32'd3648;
parameter ang_11 = 32'd1856;
parameter ang_12 = 32'd896;
parameter ang_13 = 32'd448;
parameter ang_14 = 32'd256;
parameter ang_15 = 32'd128;
parameter K = 32'h09b74; //0.607253*2^16

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

wire signed [31:0] x00_q, y00_q, z00_q;
wire signed [31:0] x01_q, y01_q, z01_q;
wire signed [31:0] x02_q, y02_q, z02_q;
wire signed [31:0] x03_q, y03_q, z03_q;
wire signed [31:0] x04_q, y04_q, z04_q;
wire signed [31:0] x05_q, y05_q, z05_q;
wire signed [31:0] x06_q, y06_q, z06_q;
wire signed [31:0] x07_q, y07_q, z07_q;
wire signed [31:0] x08_q, y08_q, z08_q;
wire signed [31:0] x09_q, y09_q, z09_q;
wire signed [31:0] x10_q, y10_q, z10_q;
wire signed [31:0] x11_q, y11_q, z11_q;
wire signed [31:0] x12_q, y12_q, z12_q;
wire signed [31:0] x13_q, y13_q, z13_q;
wire signed [31:0] x14_q, y14_q, z14_q;
wire signed [31:0] x15_q, y15_q, z15_q;
wire signed [31:0] x16_q, y16_q, z16_q;

assign x00 = K;
assign y00 = 32'b0;
assign z00 = {input_angle, 16'b0};

//x(i+1) = x(i) - d_i (2^-1) (y(i))
//y(i+1) = y(i) - d_i (2^-1) (x(i))
//z(i+1) = z(i) - d_i artan(2^-i) 

assign x01 = z00_q[31] ? x00_q +  y00_q         : x00_q -  y00_q;
assign x02 = z01_q[31] ? x01_q + (y01_q >>> 1)  : x01_q - (y01_q >>> 1)  ;
assign x03 = z02_q[31] ? x02_q + (y02_q >>> 2)  : x02_q - (y02_q >>> 2)  ;
assign x04 = z03_q[31] ? x03_q + (y03_q >>> 3)  : x03_q - (y03_q >>> 3)  ;
assign x05 = z04_q[31] ? x04_q + (y04_q >>> 4)  : x04_q - (y04_q >>> 4)  ;
assign x06 = z05_q[31] ? x05_q + (y05_q >>> 5)  : x05_q - (y05_q >>> 5)  ;
assign x07 = z06_q[31] ? x06_q + (y06_q >>> 6)  : x06_q - (y06_q >>> 6)  ;
assign x08 = z07_q[31] ? x07_q + (y07_q >>> 7)  : x07_q - (y07_q >>> 7)  ;
assign x09 = z08_q[31] ? x08_q + (y08_q >>> 8)  : x08_q - (y08_q >>> 8)  ;
assign x10 = z09_q[31] ? x09_q + (y09_q >>> 9)  : x09_q - (y09_q >>> 9)  ;
assign x11 = z10_q[31] ? x10_q + (y10_q >>> 10) : x10_q - (y10_q >>> 10) ;
assign x12 = z11_q[31] ? x11_q + (y11_q >>> 11) : x11_q - (y11_q >>> 11) ;
assign x13 = z12_q[31] ? x12_q + (y12_q >>> 12) : x12_q - (y12_q >>> 12) ;
assign x14 = z13_q[31] ? x13_q + (y13_q >>> 13) : x13_q - (y13_q >>> 13) ;
assign x15 = z14_q[31] ? x14_q + (y14_q >>> 14) : x14_q - (y14_q >>> 14) ;
assign x16 = z15_q[31] ? x15_q + (y15_q >>> 15) : x15_q - (y15_q >>> 15) ;

assign y01 = z00_q[31] ? y00_q -  x00_q         : y00_q +  x00_q        ;
assign y02 = z01_q[31] ? y01_q - (x01_q >>> 1)  : y01_q + (x01_q >>> 1) ;
assign y03 = z02_q[31] ? y02_q - (x02_q >>> 2)  : y02_q + (x02_q >>> 2) ;
assign y04 = z03_q[31] ? y03_q - (x03_q >>> 3)  : y03_q + (x03_q >>> 3) ;
assign y05 = z04_q[31] ? y04_q - (x04_q >>> 4)  : y04_q + (x04_q >>> 4) ;
assign y06 = z05_q[31] ? y05_q - (x05_q >>> 5)  : y05_q + (x05_q >>> 5) ;
assign y07 = z06_q[31] ? y06_q - (x06_q >>> 6)  : y06_q + (x06_q >>> 6) ;
assign y08 = z07_q[31] ? y07_q - (x07_q >>> 7)  : y07_q + (x07_q >>> 7) ;
assign y09 = z08_q[31] ? y08_q - (x08_q >>> 8)  : y08_q + (x08_q >>> 8) ;
assign y10 = z09_q[31] ? y09_q - (x09_q >>> 9)  : y09_q + (x09_q >>> 9) ;
assign y11 = z10_q[31] ? y10_q - (x10_q >>> 10) : y10_q + (x10_q >>> 10);
assign y12 = z11_q[31] ? y11_q - (x11_q >>> 11) : y11_q + (x11_q >>> 11);
assign y13 = z12_q[31] ? y12_q - (x12_q >>> 12) : y12_q + (x12_q >>> 12);
assign y14 = z13_q[31] ? y13_q - (x13_q >>> 13) : y13_q + (x13_q >>> 13);
assign y15 = z14_q[31] ? y14_q - (x14_q >>> 14) : y14_q + (x14_q >>> 14);
assign y16 = z15_q[31] ? y15_q - (x15_q >>> 15) : y15_q + (x15_q >>> 15);

assign z01 = z00_q[31] ? z00_q + ang_00 : z00_q - ang_00;
assign z02 = z01_q[31] ? z01_q + ang_01 : z01_q - ang_01;
assign z03 = z02_q[31] ? z02_q + ang_02 : z02_q - ang_02;
assign z04 = z03_q[31] ? z03_q + ang_03 : z03_q - ang_03;
assign z05 = z04_q[31] ? z04_q + ang_04 : z04_q - ang_04;
assign z06 = z05_q[31] ? z05_q + ang_05 : z05_q - ang_05;
assign z07 = z06_q[31] ? z06_q + ang_06 : z06_q - ang_06;
assign z08 = z07_q[31] ? z07_q + ang_07 : z07_q - ang_07;
assign z09 = z08_q[31] ? z08_q + ang_08 : z08_q - ang_08;
assign z10 = z09_q[31] ? z09_q + ang_09 : z09_q - ang_09;
assign z11 = z10_q[31] ? z10_q + ang_10 : z10_q - ang_10;
assign z12 = z11_q[31] ? z11_q + ang_11 : z11_q - ang_11;
assign z13 = z12_q[31] ? z12_q + ang_12 : z12_q - ang_12;
assign z14 = z13_q[31] ? z13_q + ang_13 : z13_q - ang_13;
assign z15 = z14_q[31] ? z14_q + ang_14 : z14_q - ang_14;
assign z16 = z15_q[31] ? z15_q + ang_15 : z15_q - ang_15;

dflip #(32) x00_ff (.clk(clk), .rst(rst), .d(x00), .q(x00_q));
dflip #(32) x01_ff (.clk(clk), .rst(rst), .d(x01), .q(x01_q));
dflip #(32) x02_ff (.clk(clk), .rst(rst), .d(x02), .q(x02_q));
dflip #(32) x03_ff (.clk(clk), .rst(rst), .d(x03), .q(x03_q));
dflip #(32) x04_ff (.clk(clk), .rst(rst), .d(x04), .q(x04_q));
dflip #(32) x05_ff (.clk(clk), .rst(rst), .d(x05), .q(x05_q));
dflip #(32) x06_ff (.clk(clk), .rst(rst), .d(x06), .q(x06_q));
dflip #(32) x07_ff (.clk(clk), .rst(rst), .d(x07), .q(x07_q));
dflip #(32) x08_ff (.clk(clk), .rst(rst), .d(x08), .q(x08_q));
dflip #(32) x09_ff (.clk(clk), .rst(rst), .d(x09), .q(x09_q));
dflip #(32) x10_ff (.clk(clk), .rst(rst), .d(x10), .q(x10_q));
dflip #(32) x11_ff (.clk(clk), .rst(rst), .d(x11), .q(x11_q));
dflip #(32) x12_ff (.clk(clk), .rst(rst), .d(x12), .q(x12_q));
dflip #(32) x13_ff (.clk(clk), .rst(rst), .d(x13), .q(x13_q));
dflip #(32) x14_ff (.clk(clk), .rst(rst), .d(x14), .q(x14_q));
dflip #(32) x15_ff (.clk(clk), .rst(rst), .d(x15), .q(x15_q));
dflip #(32) x16_ff (.clk(clk), .rst(rst), .d(x16), .q(x16_q));

dflip #(32) y00_ff (.clk(clk), .rst(rst), .d(y00), .q(y00_q));
dflip #(32) y01_ff (.clk(clk), .rst(rst), .d(y01), .q(y01_q));
dflip #(32) y02_ff (.clk(clk), .rst(rst), .d(y02), .q(y02_q));
dflip #(32) y03_ff (.clk(clk), .rst(rst), .d(y03), .q(y03_q));
dflip #(32) y04_ff (.clk(clk), .rst(rst), .d(y04), .q(y04_q));
dflip #(32) y05_ff (.clk(clk), .rst(rst), .d(y05), .q(y05_q));
dflip #(32) y06_ff (.clk(clk), .rst(rst), .d(y06), .q(y06_q));
dflip #(32) y07_ff (.clk(clk), .rst(rst), .d(y07), .q(y07_q));
dflip #(32) y08_ff (.clk(clk), .rst(rst), .d(y08), .q(y08_q));
dflip #(32) y09_ff (.clk(clk), .rst(rst), .d(y09), .q(y09_q));
dflip #(32) y10_ff (.clk(clk), .rst(rst), .d(y10), .q(y10_q));
dflip #(32) y11_ff (.clk(clk), .rst(rst), .d(y11), .q(y11_q));
dflip #(32) y12_ff (.clk(clk), .rst(rst), .d(y12), .q(y12_q));
dflip #(32) y13_ff (.clk(clk), .rst(rst), .d(y13), .q(y13_q));
dflip #(32) y14_ff (.clk(clk), .rst(rst), .d(y14), .q(y14_q));
dflip #(32) y15_ff (.clk(clk), .rst(rst), .d(y15), .q(y15_q));
dflip #(32) y16_ff (.clk(clk), .rst(rst), .d(y16), .q(y16_q));

dflip #(32) z00_ff (.clk(clk), .rst(rst), .d(z00), .q(z00_q));
dflip #(32) z01_ff (.clk(clk), .rst(rst), .d(z01), .q(z01_q));
dflip #(32) z02_ff (.clk(clk), .rst(rst), .d(z02), .q(z02_q));
dflip #(32) z03_ff (.clk(clk), .rst(rst), .d(z03), .q(z03_q));
dflip #(32) z04_ff (.clk(clk), .rst(rst), .d(z04), .q(z04_q));
dflip #(32) z05_ff (.clk(clk), .rst(rst), .d(z05), .q(z05_q));
dflip #(32) z06_ff (.clk(clk), .rst(rst), .d(z06), .q(z06_q));
dflip #(32) z07_ff (.clk(clk), .rst(rst), .d(z07), .q(z07_q));
dflip #(32) z08_ff (.clk(clk), .rst(rst), .d(z08), .q(z08_q));
dflip #(32) z09_ff (.clk(clk), .rst(rst), .d(z09), .q(z09_q));
dflip #(32) z10_ff (.clk(clk), .rst(rst), .d(z10), .q(z10_q));
dflip #(32) z11_ff (.clk(clk), .rst(rst), .d(z11), .q(z11_q));
dflip #(32) z12_ff (.clk(clk), .rst(rst), .d(z12), .q(z12_q));
dflip #(32) z13_ff (.clk(clk), .rst(rst), .d(z13), .q(z13_q));
dflip #(32) z14_ff (.clk(clk), .rst(rst), .d(z14), .q(z14_q));
dflip #(32) z15_ff (.clk(clk), .rst(rst), .d(z15), .q(z15_q));
dflip #(32) z16_ff (.clk(clk), .rst(rst), .d(z16), .q(z16_q));

//Fill unsign angle for display
assign unsign_angle = input_angle[15] ?  ~input_angle + 16'b1 : input_angle;

//Sin(0) = 0
//Sin(90) = 1
assign sin_data = ~(|unsign_angle)         ? 32'h0      :
                  (unsign_angle == 16'd90) ? 32'h1_0000 : 
                  y16_q[31]                ? ~y16_q + 32'b1 : y16_q;
//cos(0) = 1
//cos(90) = 0
assign cos_data = ~(|unsign_angle)        ? 32'h1_0000 : 
                  unsign_angle == 16'd90  ? 32'h0      : 
                  x16_q[31]               ? ~x16_q + 32'b1 : x16_q;

assign sin_sign = ~(|unsign_angle)         ? 1'b0            : 
                  (unsign_angle == 16'd90) ? input_angle[15] : y16_q[31];

assign cos_sign = (unsign_angle == 16'd90) ? 1'b0            : 
                  ~(|unsign_angle)         ? input_angle[15] : x16_q[31];

endmodule
