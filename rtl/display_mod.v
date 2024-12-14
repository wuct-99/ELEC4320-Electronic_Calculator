//***********************************************************************************************************88
// basic information regarding the display module 
// -- takes the translated bcd digits from both input and output stage and output to the 7segment display module 
//takes 1 clock cycle to prepare the output informations --> output will be shown next clock (with the "cur_" prefix):W
// signals with the "nxt_" prefix is the same clock as the input 
//**********************************************************************************************************88

module display_module(
.clk,
.rst_n,
.clk_disp,
.left_btn_final,
.right_btn_final,
.rslt_is_fp,
.rslt_8_digits,
.dp_pos,//decimal pt position
.pstate_in,
.proc_num_a_sign_bit,
.proc_num_b_sign_bit,
.excp_vld, //overflow, invalid input
.in_digits_a,
.in_digits_b,
.rslt_digits_a;
.rslt_digits_b;
.rslt_sign,
.out_anode,
.out_seg_val,
.out_led
);

input clk;
input rst_n;
input clk_disp;
input left_btn_final;
input right_btn_final;
input rslt_is_fp;
input rslt_8_digits;
input excp_vld;
input proc_num_a_sign_bit;
input proc_num_b_sign_bit;
input [7:0] dp_pos;
input [1:0] pstate_in;
input [3:0][3:0] in_digits_a;
input [3:0][3:0] in_digits_b;
input [15:0] rslt_digits_a;
input [15:0] rslt_digits_b;
input rslt_sign;

output [3:0] out_anode;
output [6:0] out_seg_val;
output out_led;

//output control
wire [1:0] cur_state;
assign cur_state = pstate_in;
wire [1:0] prev_state; 
wire [15:0] in_digits_a_unwrap;
wire [15:0] in_digits_b_unwrap;
wire [15:0] rslt_digits_a_unwrap;
wire [15:0] rslt_digits_b_unwrap;
wire [15:0] nxt_disp_stage_d_digits;//high low bank of the 8 digits of the display
wire [15:0] nxt_disp_digits;
wire        in_sign;
wire nxt_disp_digit_1st_en;
wire nxt_disp_digit_2nd_en;
wire nxt_disp_digit_3rd_en;
wire nxt_disp_digit_4th_en;
wire nxt_disp_digit_sign;
wire nxt_disp_digit_sign;
wire [3:0] nxt_disp_digit_1st;
wire [3:0] nxt_disp_digit_2nd;
wire [3:0] nxt_disp_digit_3rd;
wire [3:0] nxt_disp_digit_4th;
wire       nxt_disp_digit_dp;
wire [4:0] nxt_disp_digit_num; //digit to be displayed with dp information 
//mux to select display value from which state
wire       nxt_disp_from_a_en;
wire       nxt_disp_from_b_en;
wire       nxt_disp_from_c_en;
wire       nxt_disp_from_d_en;
//error msg 
reg [15:0] error_msg = 16'hffff;
//computing msg
reg [15:0] load_msg = 16'haaaa;

//unwrap the digits 
assign in_digits_a_unwrap = {{in_digits_a[3]},{in_digits_a[2]},{in_digits_a[1]},{in_digits_a[0]}};
assign in_digits_b_unwrap = {{in_digits_b[3]},{in_digits_b[2]},{in_digits_b[1]},{in_digits_b[0]}};
assign rslt_digits_a_unwrap = rslt_digits_a; //{{rslt_digits_a[3]},{rslt_digits_a[2]},{rslt_digits_a[1]},{rslt_digits_a[0]}};
assign rslt_digits_b_unwrap = rslt_digits_b;//{{rslt_digits_a[3]},{rslt_digits_a[2]},{rslt_digits_a[1]},{rslt_digits_a[0]}};

//output control;
assign nxt_disp_from_a_en = (cur_state == 2'b00);
assign nxt_disp_from_b_en = (cur_state == 2'b01);
assign nxt_disp_from_c_en = (cur_state == 2'b10);
assign nxt_disp_from_d_en = (cur_state == 2'b11);

assign in_sign = (proc_num_a_sign_bit & nxt_disp_from_a_en) | (proc_num_b_sign_bit & nxt_disp_from_b_en);
//assign the digits output 
//state D output cycling; 2 stage output
wire state_d_out_bnk_en;
wire state_d_out_bnk;

assign state_d_out_bnk_en = ((prev_state != 2'b11 & cur_state == 2'b11) | left_btn_final | right_btn_final);
assign state_d_out_bnk = ((prev_state != 2'b11 & cur_state == 2'b11)  | left_btn) & rslt_8_digit);
assign nxt_disp_stage_d_digits = {{16(state_d_out_bnk)},  {rslt_digits_a}}|
																										       {{16(~state_d_out_bnk)}, {rslt_digits_b}}|
																																	{{16(excp_vld							)}, {error_msg}};
assign nxt_disp_digits = {{16(nxt_disp_from_a_en)}, {in_digits_a}}|
																								 {{16(nxt_disp_from_b_en}}, {in_digits_b}}|
																								 {{16(nxt_disp_from_c_en)}, {load_msg}}|
																								 {{16(nxt_disp_from_d_en)}, {nxt_disp_stage_d_digits}};

dffr #(2) prev_state_ff (.clk(clk), .rst_n(rst_n), .d(cur_state), .q(prev_state));
//fsm for changing state d output 
//ff for output digit cyclinbg
wire [3:0] nxt_digit;
wire [3:0] cur_digit;

assign nxt_digit = (cur_digit == 4'b0001) ? 4'b0010 : (cur_digit == 4'b0010) ? 4'b0100 : (cur_digit == 4'b0100) ? 4'b1000 : 4'b0001;
dffr #(4) disp_digit_ff (.clk(clk_disp), .rst_n(rst_n), .d(nxt_digit), .q(cur_digit));
assign nxt_disp_digit_sign_en = (~(|nxt_disp_digits[15:12]) & cur_state == 2'b11 & ((rslt_8_bit & state_d_out_bnk) | (~rslt_8_bit))) | cur_state == 4'b00 | cur_state == 4'b01;  
assign nxt_disp_digit_sign  = (in_sign & 4'b1010) | (~in_sign & 4'b1011);
assign nxt_disp_digit_1st_en = (cur_digit == 4'b0001);
assign nxt_disp_digit_2nd_en = (cur_digit == 4'b0010);
assign nxt_disp_digit_3rd_en = (cur_digit == 4'b0100);
assign nxt_disp_digit_4th_en = (cur_digit == 4'b1000);

assign nxt_disp_digit_1st = nxt_disp_digits[3:0];
assign nxt_disp_digit_2nd = nxt_disp_digits[7:4];
assign nxt_disp_digit_3rd = nxt_disp_digits[11:8];
assign nxt_disp_digit_4th = nxt_disp_digit_sign_en? nxt_disp_digit_sign : nxt_disp_digits[15:12];
assign nxt_disp_digit_num = ({4{nxt_disp_digit_1st_en}} & nxt_disp_digit_1st) |
																											 ({4{nxt_disp_digit_2nd_en}} & nxt_disp_digit_2nd) |
																											 ({4{nxt_disp_digit_3rd_en}} & nxt_disp_digit_3rd) |
																											 ({4{nxt_disp_digit_4th_en}} & nxt_disp_digit_4th) ;
//dffr #(4) disp_num_ff (.clk(clk), .rst_n(rst_n), d(nxt_disp_digit_num), .q(cur_disp_digit_num));//possible timing fix if fix just add one clock for readying of the display number
//LUT for 7seg output 
wire [6:0] nxt_7seg_num;
wire [7:0] nxt_7seg_val; //with decimal point
wire [7:0] cur_7seg_val;
wire [8:0] nxt_7seg_sign;// applicable to the 4th digit when sign is negative 
wire nxt_7seg_num_0_en;
wire nxt_7seg_num_1_en;
wire nxt_7seg_num_2_en;
wire nxt_7seg_num_3_en;
wire nxt_7seg_num_4_en;
wire nxt_7seg_num_5_en;
wire nxt_7seg_num_6_en;
wire nxt_7seg_num_7_en;
wire nxt_7seg_num_8_en;
wire nxt_7seg_num_9_en;
wire nxt_7seg_dash_en;
wire nxt_7seg_off_en;
parameter [6:0] 7SEG_0 = 7'b0000001;
parameter [6:0] 7SEG_1 = 7'b1001111;
parameter [6:0] 7SEG_2 = 7'b0010010;
parameter [6:0] 7SEG_3 = 7'b0000110;
parameter [6:0] 7SEG_4 = 7'b1001100;
parameter [6:0] 7SEG_5 = 7'b0100100;
parameter [6:0] 7SEG_6 = 7'b0100000;
parameter [6:0] 7SEG_7 = 7'b0001111;
parameter [6:0] 7SEG_8 = 7'b0000000;
parameter [6:0] 7SEG_9 = 7'b0000100;
parameter [7:0] 7SEG_DASH = 8'b11111101;
parameter [7:0] 7SEG_F = 8'b01110000;
parameter [7:0] 7SEG_OFF = 8'b11111111;
assign nxt_7seg_num_0_en = nxt_disp_digit_num[3:0] == 4'b0000;
assign nxt_7seg_num_1_en = nxt_disp_digit_num[3:0] == 4'b0001;
assign nxt_7seg_num_2_en = nxt_disp_digit_num[3:0] == 4'b0010;
assign nxt_7seg_num_3_en = nxt_disp_digit_num[3:0] == 4'b0011;
assign nxt_7seg_num_4_en = nxt_disp_digit_num[3:0] == 4'b0100;
assign nxt_7seg_num_5_en = nxt_disp_digit_num[3:0] == 4'b0101;
assign nxt_7seg_num_8_en = nxt_disp_digit_num[3:0] == 4'b1000;
assign nxt_7seg_num_9_en = nxt_disp_digit_num[3:0] == 4'b1001;
assign nxt_7seg_num_dash_en = nxt_disp_digit_num[3:0] == 4'b1010; 
assign nxt_7seg_num_f_en = nxt_disp_digit_num[3:0] == 4'b1111; 
assign nxt_7seg_off_en = nxt_disp_digit_num[3:0] == 4'b1011; 
assign nxt_7seg_val = ({8{nxt_7seg_num_0_en}} & {{7SEG_0}, ~nxt_disp_digit_dp})|
                      ({8{nxt_7seg_num_1_en}} & {{7SEG_1}, ~nxt_disp_digit_dp})|
                      ({8{nxt_7seg_num_2_en}} & {{7SEG_2}, ~nxt_disp_digit_dp})|
                      ({8{nxt_7seg_num_3_en}} & {{7SEG_3}, ~nxt_disp_digit_dp})|
                      ({8{nxt_7seg_num_4_en}} & {{7SEG_4}, ~nxt_disp_digit_dp})|
                      ({8{nxt_7seg_num_5_en}} & {{7SEG_5}, ~nxt_disp_digit_dp})|
                      ({8{nxt_7seg_num_6_en}} & {{7SEG_6}, ~nxt_disp_digit_dp})|
                      ({8{nxt_7seg_num_7_en}} & {{7SEG_7}, ~nxt_disp_digit_dp})|
                      ({8{nxt_7seg_num_8_en}} & {{7SEG_8}, ~nxt_disp_digit_dp})|
                      ({8{nxt_7seg_num_9_en}} & {{7SEG_9}, ~nxt_disp_digit_dp})|
                      ({8{nxt_7seg_num_f_en}} & 7SEG_F                        )|
                      ({8{nxt_7seg_off_en}}   & 7SEG_OFF                      )|
                      ({8{nxt_7seg_dash_en}}  & 7SEG_DASH                     );
dffr #(8) 7seg_disp_ff (.clk(clk_disp), .rst_n(rst_n), .d(nxt_7seg_val), .q(cur_7seg_val));
assign out_7seg_val = cur_7seg_val;
assign out_anode = cur_digit; 
assign out_led = state_d_out_bnk; 
//LUT for display values 
endmodule 
