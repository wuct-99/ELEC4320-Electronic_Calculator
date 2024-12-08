module display_module(
.clk,
.rst_n,
.clk_disp,
.left_btn_final,
.right_btn_final,
.mid_btn_final,
.rslt_is_fp,
.rslt_8_digits,
.dp_pos,//decimal pt position
.pstate_in,
.in_digits_a,
.in_digits_b,
.rslt_digits_a;
.rslt_digits_b;
.display_mode,
.out_anode,
.out_seg_val,
.out_led
);

input clk;
input rst_n;
input clk_disp;
input left_btn_final;
input right_btn_final;
input mid_btn_final;
input rslt_is_fp;
input rslt_8_digits;
input [7:0] dp_pos;
input [1:0] pstate_in;
input [3:0][3:0] in_digits_a;
input [3:0][3:0] in_digits_b;
input [3:0][3:0] rslt_digits_a;
input [3:0][3:0] rslt_digits_b;
input [1:0]      display_mode;

output [3:0] out_anode;
output [6:0] out_seg_val;
output [1:0] out_led;

//output control
wire [1:0] cur_state;
assign cur_state = pstate_in;

wire [3:0][3:0] cur_out_digits;

//output digits fsm, output counter for cycling through digits 
parameter DIGITS = 4;
reg [1:0] cur_digit;
wire [1:0] nxt_digit;
//LUT for binary --> 7seg display cathode values

//error msg 



//output control;
assign cur_out_digits = (cur_state == 2'b00)? in_digits_a : (cur_state == 2'b01)? in_digits_b : (cur_state == 2'b11)? rslt_digits_



endmodule 
