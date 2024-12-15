//convert binary calculation results to bcd and either 4 digit and 8 digit 
 
module rslt_bin2bcd (
clk,
rst_n,

calc_rslt,
calc_rslt_sign,
calc_rslt_vld,
calc_num_or_mode_invld,
calc_mode,

rslt_digit_a,
rslt_digit_b,
rslt_sign,
rslt_is_fp,
rslt_8_digit,
rslt_dp_pos, //one hot 
bcd_conv_done
);

input clk;
input rst_n;

input [31:0] calc_rslt;
input        calc_rslt_sign;
input [10:0] calc_mode;
input 							calc_rslt_vld;
input        calc_num_or_mode_invld;

output       calc_rslt_invld;
output [15:0] rslt_digits_a;
output [15:0] rslt_digits_b;
output        rslt_sign;
output        rslt_is_fp;
output        bcd_conv_done;
output [15:0] rslt_dp_pos;

parameter bcd_width = 16'd16;
reg [48:0]         shift_reg_bcd_int;
reg [48:0]         shift_reg_bcd_flt;

reg [15:0]         rslt_int_part;
reg [15:0]         rslt_flt_part;

reg                int_bcd_conv_done;
reg                flt_bcd_conv_done;

reg [31:0]         int_bcd_conv_dat; 
reg [3:0]          shift_counter;
wire [3:0]         shift_counter_nxt;
reg [31:0]         int_cal_rslt; 
wire               conv_counter_rst;
wire 								 calc_rslt_int_en;
wire          calc_rslt_flt_en;
wire          calc_rslt_vld_d1;

wire [15:0]    calc_rslt_int_pt;
wire [15:0]    calc_rslt_flt_pt;

 //binary to bcd 
//flt_handling--> both output digits change to 0?
//shift counter 15-0 cycle, i new number came in then reset, else when rslt_vld then start count to 0 
assign calc_rslt_int_en = (|calc_mode[2:0]) & calc_rslt_vld;
assign calc_rslt_flt_en = (|calc_mode[10:3]) & calc_rslt_vld;
// according to mode 
//separates results to int part vs float part
assign calc_rslt_int = ({16{calc_rslt_int_en}} & calc_rslt[15:0])|
																					 ({16{calc_rslt_vld}}    & calc_rslt[31:16]);
assign calc_rslt_flt = ({16{calc_rslt_flt_en}} & calc_rslt[15:0]);
dffr #(1) prev_rslt_vld_ff (.clk(clk), .rst_n(rst_n), .d(calc_rslt_vld), .q(calc_rslt_vld_d1));
//only add, minus, mult is full integer outpot 
//multiply the fraction to make it into integer and apply double dabble 
assign conv_counter_rst = calc_rslt_vld & ~calc_rslt_vld_d1;
assign calc_rslt_invld =   calc_num_or_mode_invld | (~calc_rslt_sign & (&calc_rslt)) ;

//fraction part conversiono
//for now assume need 3 clocks to finish the adding 

wire        frac_2_dec_doing_d1;
wire        frac_2_dec_doing_d2;
wire        frac_2_dec_doint_d3;
wire        frac_2_dec_doint_d4;
wire        frac_2_dec_done;
wire        frac_2_bcd_done;;

dffr #(1) frac_2_dec_conv_done_ff_0 (.clk(clk), .rst_n(rst_n), .(conv_counter_rst), .(frac_2_dec_doing_d1));
dffr #(1) frac_2_dec_conv_done_ff_2 (.clk(clk), .rst_n(rst_n), .(frac_2_dec_doing_d1), .(frac_2_dec_doing_d2));
dffr #(1) frac_2_dec_conv_done_ff_3 (.clk(clk), .rst_n(rst_n), .(frac_2_dec_doing_d2), .(frac_2_dec_doing_d3));
dffr #(1) frac_2_dec_conv_done_ff_3 (.clk(clk), .rst_n(rst_n), .(frac_2_dec_doing_d3), .(frac_2_dec_doing_d4));

wire [31:0] frac_2_dec_buf;
wire [31:0] frac_2_dec_buf_d1;
wire [31:0] frac_2_dec_bit_0_add_amt;
wire [31:0] frac_2_dec_bit_1_add_amt;
wire [31:0] frac_2_dec_bit_2_add_amt;
wire [31:0] frac_2_dec_bit_3_add_amt;
wire [31:0] frac_2_dec_bit_4_add_amt;
wire [31:0] frac_2_dec_bit_5_add_amt;
wire [31:0] frac_2_dec_bit_6_add_amt;
wire [31:0] frac_2_dec_bit_7_add_amt;
wire [31:0] frac_2_dec_bit_8_add_amt;
wire [31:0] frac_2_dec_bit_9_add_amt;
wire [31:0] frac_2_dec_bit_10_add_amt;
wire [31:0] frac_2_dec_bit_11_add_amt;
wire [31:0] frac_2_dec_bit_12_add_amt;
wire [31:0] frac_2_dec_bit_13_add_amt;
wire [31:0] frac_2_dec_bit_14_add_amt;
wire [31:0] frac_2_dec_bit_15_add_amt;

wire [31:0] frac_2_dec_bit_add_01_buf;
wire [31:0] frac_2_dec_bit_add_23_buf;
wire [31:0] frac_2_dec_bit_add_45_buf;
wire [31:0] frac_2_dec_bit_add_67_buf;
wire [31:0] frac_2_dec_bit_add_89_buf;
wire [31:0] frac_2_dec_bit_add_1011_buf;
wire [31:0] frac_2_dec_bit_add_1213_buf;
wire [31:0] frac_2_dec_bit_add_1415_buf;

wire [31:0] frac_2_dec_bit_add_01_buf_d1;
wire [31:0] frac_2_dec_bit_add_23_buf_d1;
wire [31:0] frac_2_dec_bit_add_45_buf_d1;
wire [31:0] frac_2_dec_bit_add_67_buf_d1;
wire [31:0] frac_2_dec_bit_add_89_buf_d1;
wire [31:0] frac_2_dec_bit_add_1011_buf_d1;
wire [31:0] frac_2_dec_bit_add_1213_buf_d1;
wire [31:0] frac_2_dec_bit_add_1415_buf_d1;

wire [31:0] frac_2_dec_bit_add_0123_buf;
wire [31:0] frac_2_dec_bit_add_4567_buf;
wire [31:0] frac_2_dec_bit_add_891011_buf;
wire [31:0] frac_2_dec_bit_add_12131415_buf;
//d2 just because d1 is for 01,23 addition 
wire [31:0] frac_2_dec_bit_add_0123_buf_d2;
wire [31:0] frac_2_dec_bit_add_4567_buf_d2;
wire [31:0] frac_2_dec_bit_add_891011_buf_d2;
wire [31:0] frac_2_dec_bit_add_12131415_buf_d2;
//d3 is because d2 is for 0123, 4567 addition 
wire [31:0] frac_2_dec_bit_add_0_7_buf;
wire [31:0] frac_2_dec_bit_add_8_15_buf;
wire [31:0] frac_2_dec_bit_add_0_7_buf_d3;
wire [31:0] frac_2_dec_bit_add_8_15_buf_d3;

wire [31:0] frac_2_dec_bit_add_0_15_buf;
wire [31:0] frac_2_dec_bit_add_0_15_buf_d4;

assign frac_2_dec_bit_0_add_amt    = ({32{calc_rslt_flt[0]}} & 32'd50000);
assign frac_2_dec_bit_1_add_amt    = ({32{calc_rslt_flt[1]}} & 32'd25000);
assign frac_2_dec_bit_2_add_amt    = ({32{calc_rslt_flt[2]}} & 32'd12500);
assign frac_2_dec_bit_3_add_amt    = ({32{calc_rslt_flt[3]}} & 32'd6250);
assign frac_2_dec_bit_4_add_amt    = ({32{calc_rslt_flt[4]}} & 32'd3125);
assign frac_2_dec_bit_5_add_amt    = ({32{calc_rslt_flt[5]}} & 32'd1562);
assign frac_2_dec_bit_6_add_amt    = ({32{calc_rslt_flt[6]}} & 32'd781);
assign frac_2_dec_bit_7_add_amt    = ({32{calc_rslt_flt[7]}} & 32'd390);
assign frac_2_dec_bit_8_add_amt    = ({32{calc_rslt_flt[8]}} & 32'd195);
assign frac_2_dec_bit_9_add_amt    = ({32{calc_rslt_flt[9]}} & 32'd97);
assign frac_2_dec_bit_10_add_amt   = ({32{calc_rslt_flt[10]}} & 32'd48);
assign frac_2_dec_bit_11_add_amt   = ({32{calc_rslt_flt[11]}} & 32'd24);
assign frac_2_dec_bit_12_add_amt   = ({32{calc_rslt_flt[12]}} & 32'd12);
assign frac_2_dec_bit_13_add_amt   = ({32{calc_rslt_flt[13]}} & 32'd6);
assign frac_2_dec_bit_14_add_amt   = ({32{calc_rslt_flt[14]}} & 32'd3);
assign frac_2_dec_bit_15_add_amt   = ({32{calc_rslt_flt[15]}} & 32'd1);

assign frac_2_dec_bit_add_01_buf   = frac_2_dec_bit_0_add_amt + frac_2_dec_bit_1_add_amt;  
assign frac_2_dec_bit_add_23_buf   = frac_2_dec_bit_2_add_amt + frac_2_dec_bit_3_add_amt;
assign frac_2_dec_bit_add_45_buf   = frac_2_dec_bit_4_add_amt + frac_2_dec_bit_5_add_amt;
assign frac_2_dec_bit_add_67_buf   = frac_2_dec_bit_6_add_amt + frac_2_dec_bit_7_add_amt;
assign frac_2_dec_bit_add_89_buf   = frac_2_dec_bit_8_add_amt + frac_2_dec_bit_9_add_amt;
assign frac_2_dec_bit_add_1011_buf = frac_2_dec_bit_10_add_amt + frac_2_dec_bit_11_add_amt;  
assign frac_2_dec_bit_add_1213_buf = frac_2_dec_bit_12_add_amt + frac_2_dec_bit_13_add_amt;
assign frac_2_dec_bit_add_1415_buf = frac_2_dec_bit_14_add_amt + frac_2_dec_bit_15_add_amt;

dffr #(32) frac_2_dec_bit_add_01_buf_ff (.clk(clk), .rst_n(rst_n), .d(frac_2_dec_bit_add_01_buf), .q(frac_2_dec_bit_add_01_buf_d1)); 
dffr #(32) frac_2_dec_bit_add_23_buf_ff (.clk(clk), .rst_n(rst_n), .d(frac_2_dec_bit_add_23_buf), .q(frac_2_dec_bit_add_23_buf_d1)); 
dffr #(32) frac_2_dec_bit_add_45_buf_ff (.clk(clk), .rst_n(rst_n), .d(frac_2_dec_bit_add_45_buf), .q(frac_2_dec_bit_add_45_buf_d1)); 
dffr #(32) frac_2_dec_bit_add_67_buf_ff (.clk(clk), .rst_n(rst_n), .d(frac_2_dec_bit_add_67_buf), .q(frac_2_dec_bit_add_67_buf_d1)); 
dffr #(32) frac_2_dec_bit_add_89_buf_ff (.clk(clk), .rst_n(rst_n), .d(frac_2_dec_bit_add_89_buf), .q(frac_2_dec_bit_add_89_buf_d1)); 
dffr #(32) frac_2_dec_bit_add_1011_buf_ff (.clk(clk), .rst_n(rst_n), .d(frac_2_dec_bit_add_1011_buf), .q(frac_2_dec_bit_add_1011_buf_d1)); 
dffr #(32) frac_2_dec_bit_add_1213_buf_ff (.clk(clk), .rst_n(rst_n), .d(frac_2_dec_bit_add_1213_buf), .q(frac_2_dec_bit_add_1213_buf_d1)); 
dffr #(32) frac_2_dec_bit_add_1415_buf_ff (.clk(clk), .rst_n(rst_n), .d(frac_2_dec_bit_add_1415_buf), .q(frac_2_dec_bit_add_1415_buf_d1)); 

assign frac_2_dec_bit_add_0123_buf     = frac_2_dec_bit_add_01_buf + frac_2_dec_bit_add_23_buf;
assign frac_2_dec_bit_add_4567_buf     = frac_2_dec_bit_add_45_buf + frac_2_dec_bit_add_67_buf;
assign frac_2_dec_bit_add_891011_buf   = frac_2_dec_bit_add_89_buf + frac_2_dec_bit_add_1011_buf;
assign frac_2_dec_bit_add_12131415_buf = frac_2_dec_bit_add_1213_buf + frac_2_dec_bit_add_1415_buf;

dffr #(32) frac_2_dec_bit_add_0123_buf_ff (.clk(clk), .rst_n(rst_n), .d(frac_2_dec_bit_add_0123_buf), .q(frac_2_dec_bit_add_0123_buf_d2)); 
dffr #(32) frac_2_dec_bit_add_4567_buf_ff (.clk(clk), .rst_n(rst_n), .d(frac_2_dec_bit_add_4567_buf), .q(frac_2_dec_bit_add_4567_buf_d2)); 
dffr #(32) frac_2_dec_bit_add_891011_buf_ff (.clk(clk), .rst_n(rst_n), .d(frac_2_dec_bit_add_891011_buf), .q(frac_2_dec_bit_add_891011_buf_d2f)); 
dffr #(32) frac_2_dec_bit_add_12131415_buf_ff (.clk(clk), .rst_n(rst_n), .d(frac_2_dec_bit_add_12131415_buf), .q(frac_2_dec_bit_add_12131415_buf_d2)); 

assign frac_2_dec_bit_add_0_7_buf      = frac_2_dec_bit_add_0123_buf_d2 + frac_2_dec_bit_add_4567_buf_d2 ;
assign frac_2_dec_bit_add_8_15_buf     = frac_2_dec_bit_add_891011_buf_d2 + frac_2_dec_bit_add_12131415_buf_d2;

dffr #(32) frac_2_dec_bit_add_891011_buf_ff (.clk(clk), .rst_n(rst_n),  .d(frac_2_dec_bit_add_0_7_buf  ), .q(frac_2_dec_bit_add_0_7_buf_d3  )); 
dffr #(32) frac_2_dec_bit_add_12131415_buf_ff (.clk(clk), .rst_n(rst_n),.d(frac_2_dec_bit_add_8_15_buf ), .q(frac_2_dec_bit_add_8_15_buf_d3 )); 

assign frac_2_dec_bit_add_0_15_buf     = frac_2_dec_bit_add_0_7_buf_d3 + frac_2_dec_bit_add_8_15_d3;

dffr #(32) frac_2_dec_bit_add_0_15_buf_ff (.clk(clk), .rst_n(rst_n), .d(frac_2_dec_bit_add_0_15_buf), .q(frac_2_dec_bit_add_0_15_buf_d4));

//need a conversion done bit to signal the start of the application of the double dabble algo for fraction --> start convert d4 
//wire [39:0] frac_2_bcd_buf;
wire [31:0] frac_2_bcd_buf;
bin_2_bcd_dd_mod fraction_part_conv (.clk(clk), .rst_n(rst_n), .conv_start(frac_2_dec_doing_d4), .conv_rslt_rdy(frac_2_bcd_done), .in_digits(frac_2_dec_bit_add_0_15_buf_d4), .out_digits(frac_2_bcd_buf));
//fraction part done then move to converting int part 
wire calc_rslt_int_part_expand = {{16'b0}, calc_rslt_int};
wire int_bcd_conv_rdy;
assign int_bcd_conv_rdy = 
//wire [39:0] int_bcd_conv_rslt;
wire [31:0] int_bcd_conv_rslt;
bin_2_bcd_dd_mod int_part_conv  (.clk(clk), .rst_n(rst_n), .conv_start(conv_counter_rst), .conv_rslt_rdy(int_bcd_conv_rdy), .in_digits(calc_rslt_in_part_expand), .out_digits(int_bcd_conv_rslt));
    
//after bin_2_bcd --> concat the results and send to aligner to output the final 8 digit bcd results 
wire [63:0] aligner_in_bcd_int_flt_concat;
wire        aligner_start_en;
wire [31:0] aligned_rslt_comb;
wire        aligned_rslt_8_digit;
wire        aligned_rslt_vld;
wire [7:0]  aligned_rslt_dp_pos;

assign align_in_bcd_int_flt_concat = (~calc_rslt_flt_en & calc_rslt_int_en) ? {32'b0,int_bcd_conv_rslt} : {int_bcd_conv_rslt,frac_2_bcd_buf};
bin_2_bcd_comb combined_rslt_align (.clk(clk), .rst_n(rst_n), .align_in_data(aligner_in_bcd_int_flt_concat), .align_start_en(aligner_start_en), .align_rslt_data(aligned_rslt_comb),
                                    .align_rslt_vld(aligned_rslt_vld), .align_data_dp_pos(aligned_rslt_dp_pos), .align_rslt_8_bit(aligned_rslt_8_digit));

assign rslt_digit_a =  aligned_rslt_comb[31:16];
assign rslt_digit_b =  aligned_rslt_comb[15:0];
assign rslt_8_digit = aligned_rslt_8_digit;
assign rslt_dp_pos  = aligned_rslt_dp_pos;
assign rslt_is_fp   = calc_rslt_flt_en; 
assign bcd_conv_done= aligned_rslt_vld;
assign rslt_sign    = calc_rslt_sign;
 
//aligner module
endmodule 





