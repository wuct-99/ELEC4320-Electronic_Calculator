module cal_top(
	//input
	clk,
	rst_n,
 up_btn,
 down_btn,
 left_btn,
 mid_btn, 
	mode_sw,
// usr_in_vld,
//output?//7 segment display pins (how many bits?)
seg_anode_act,//which segment LED to update
seg_led_val, //segment led value
out_led
);

//Core input
input clk;
input rst_n;
input up_btn;
input down_btn;
input left_btn;
input right_btn;
input mid_btn;
//input usr_in_vld;
input [10:0] mode_sw;

output [3:0] seg_anode_act;
output [7:0] seg_led_val;
output out_led;
//debouncing circuit (3ff) for all input involving switches and buttons 
wire up_btn_d1;
wire up_btn_d2;
wire up_btn_d3;
wire up_btn_d4;
wire up_btn_final;
wire down_btn_d1;
wire down_btn_d2;
wire down_btn_d3;
wire down_btn_d4;
wire down_btn_final;
wire left_btn_d1;
wire left_btn_d2;
wire left_btn_d3;
wire left_btn_d4;
wire left_btn_final;
wire right_btn_d1;
wire right_btn_d2;
wire right_btn_d3;
wire right_btn_d4;
wire right_btn_final;
wire mid_btn_d1;
wire mid_btn_d2;
wire mid_btn_d3;
wire mid_btn_d4;
wire mid_btn_final;
wire mid_btn_final_d1; //for decimal to binary conversion 
wire [10:0] mode_sw_d1;
wire [10:0] mode_sw_d2;
wire [10:0] mode_sw_d3;
wire [10:0] mode_sw_d4;
//input control signals
wire in_num_invld;
wire in_mode_invld;
//1. fsm for each digit input value 
wire [3:0] cur_num;
reg [3:0] nxt_num;
//input digit value fsm
wire [1:0] cur_digit;
reg  [1:0] nxt_digit;
//processings state fsm
wire [1:0] cur_pstate;
reg  [1:0] nxt_pstate;

//async input debounce
dffr #(1) up_btn_ff1 (.clk(clk), .rst_n(rst_n), .d(up_btn), .q(up_btn_d1));
dffr #(1) up_btn_ff2 (.clk(clk), .rst_n(rst_n), .d(up_btn_d1), .q(up_btn_d2));
dffr #(1) up_btn_ff3 (.clk(clk), .rst_n(rst_n), .d(up_btn_d2), .q(up_btn_d3));
dffr #(1) up_btn_ff4 (.clk(clk), .rst_n(rst_n), .d(up_btn_d3), .q(up_btn_d4));
dffr #(1) dn_btn_ff1 (.clk(clk), .rst_n(rst_n), .d(down_btn), .q(down_btn_d1));
dffr #(1) dn_btn_ff2 (.clk(clk), .rst_n(rst_n), .d(down_btn_d1), .q(down_btn_d2));
dffr #(1) dn_btn_ff3 (.clk(clk), .rst_n(rst_n), .d(down_btn_d2), .q(down_btn_d3));
dffr #(1) dn_btn_ff4 (.clk(clk), .rst_n(rst_n), .d(down_btn_d3), .q(down_btn_d4));
dffr #(1) lft_btn_ff1 (.clk(clk), .rst_n(rst_n), .d(left_btn), .q(left_btn_d1));
dffr #(1) lft_btn_ff2 (.clk(clk), .rst_n(rst_n), .d(left_btn_d1), .q(left_btn_d2));
dffr #(1) lft_btn_ff3 (.clk(clk), .rst_n(rst_n), .d(left_btn_d2), .q(left_btn_d3));
dffr #(1) lft_btn_ff4 (.clk(clk), .rst_n(rst_n), .d(left_btn_d3), .q(left_btn_d4));
dffr #(1) rt_btn_ff1 (.clk(clk), .rst_n(rst_n), .d(right_btn), .q(right_btn_d1));
dffr #(1) rt_btn_ff2 (.clk(clk), .rst_n(rst_n), .d(right_btn_d1), .q(right_btn_d2));
dffr #(1) rt_btn_ff3 (.clk(clk), .rst_n(rst_n), .d(right_btn_d2), .q(right_btn_d3));
dffr #(1) rt_btn_ff4 (.clk(clk), .rst_n(rst_n), .d(right_btn_d3), .q(right_btn_d4));
dffr #(1) mid_btn_ff1 (.clk(clk), .rst_n(rst_n), .d(mid_btn), .q(mid_btn_d1));
dffr #(1) mid_btn_ff2 (.clk(clk), .rst_n(rst_n), .d(right_btn_d1), .q(right_btn_d2));
dffr #(1) mid_btn_ff4 (.clk(clk), .rst_n(rst_n), .d(right_btn_d2), .q(right_btn_d3));
dffr #(1) mid_btn_ff4 (.clk(clk), .rst_n(rst_n), .d(right_btn_d3), .q(right_btn_d4));
dffr #(1) mid_btn_final_ff (.clk(clk), .rst_n(rst_n), .d(mid_btn_final), .q(mid_btn_final_d1));

dffr #(11) mode_sw_ff1 (.clk(clk), .rst_n(rst_n), .d(mode_sw), .q(mode_sw_d1));
dffr #(11) mode_sw_ff2 (.clk(clk), .rst_n(rst_n), .d(mode_sw_d1), .q(mode_sw_d2));
dffr #(11) mode_sw_ff3 (.clk(clk), .rst_n(rst_n), .d(mode_sw_d2), .q(mode_sw_d3));
dffr #(11) mode_sw_ff4 (.clk(clk), .rst_n(rst_n), .d(mode_sw_d3), .q(mode_sw_d4));
assign up_btn_final    = up_btn_d1    & up_btn_d2    & ~up_btn_d3    & ~up_btn_d4;
assign down_btn_final  = down_btn_d1  & down_btn_d2  & ~down_btn_d3  & ~down_btn_d4;
assign left_btn_final  = left_btn_d1  & left_btn_d2  & ~left_btn_d3  & ~left_btn_d4;
assign right_btn_final = right_btn_d1 & right_btn_d2 & ~right_btn_d3 & ~right_btn_d4;
assign mid_btn_final   = mid_btn_d1 & mid_btn_d2 & ~mid_btn_d3 & ~mid_btn_d4;
assign mode_sw_final   = mode_sw_d1 & mode_sw_d2 & ~mode_sw_d3 & ~mode_sw_d4;
//calc state control (input mode, processing state, output state)

case(cur_pstate)
    2'b00: begin//in num A 
	              if(mid_btn_final) begin
                   nxt_pstate = 2'b01;
               end
           end
    2'b01: begin//in num A 
	              if(mid_btn_final) begin
                   nxt_pstate = 2'b10;
               end

           end
    2'b10: begin//in num A 
	              if(rslt_vld) begin
                   nxt_pstate = 2'b11;
               end
				  else if(in_num_or_mode_invld) begin
                   nxt_pstate = 2'b11; //display error msg
               end
           end
    2'b11: begin//in num A 
	              if(mid_btn_final) begin 
                   nxt_pstate = 2'b00;
               end
           end
endcase 
dffr #(1) cur_pstate_fsm (.clk(clk), .rst_n(rst_n), .d(nxt_pstate), .q(cur_pstate));
//input stage signals
wire [3:0][3:0] in_stage_num_a_digits;
wire [3:0][3:0] in_stage_num_b_digits;
wire [10:0]     cal_op_vld;
wire            cal_stage_vld;
wire            in_num_or_mode_invld;
wire [15:0]     in_cal_proc_num_a;
wire [15:0]     in_cal_proc_num_b;
wire [15:0]     proc_num_a_unsign;
wire [15:0]     proc_num_b_unsign;
wire            proc_num_a_sign_bit;
wire            proc_num_b_sign_bit;
//processing stage signals
//output stage signals
//display module signals 
wire            clk_disp;
//clock divider
clock_divider disp_clk_gen(
.clk                      (clk),
.rst_n                    (rst_n),
.clk_1khz_out             (clk_disp)
);


/*connect to all other modules */
cal_in_proc cal_in_process (
.clk                      (                   clk),
.rst_n					  (                 rst_n),
.up_btn_final			  (			 up_btn_final),
.down_btn_final           (        down_btn_final),
.left_btn_final           (        left_btn_final),
.right_btn_final          (       right_btn_final),
.mid_btn_final            (         mid_btn_final),
.mode_sw_final            (         mode_sw_final),
.pstate_in                (            cur_pstate),
.num_a_digits             ( in_stage_num_a_digits),
.num_b_digits             ( in_stage_num_b_digits),
.cal_stage_vld            (         cal_stage_vld),
.cal_op_vld               (            cal_op_vld),
.in_num_or_mode_invld     (  in_num_or_mode_invld),
.proc_num_a               (     in_cal_proc_num_a),
.proc_num_b               (     in_cal_proc_num_b),
.proc_num_a_unsign        (     proc_num_a_unsign),
.proc_num_b_unsign        (     proc_num_b_unsign),
.proc_num_a_sign_bit      (   proc_num_a_sign_bit),
.proc_num_b_sign_bit      (   proc_num_b_sign_bit)
);
//processing state
//output processing state 
wire [31:0]     calc_rslt;
wire            calc_rslt_sign;
wire [10:0]     calc_mode;
wire            calc_rslt_vld;
wire            calc_num_or_mode_invld;
wire [15:0]     rstl_digits_a;
wire [15:0]     rslt_digits_b;
wire            rslt_sign;
wire            rslt_is_fp;
wire            rslt_8_digit;
wire [7:0]      rslt_dp_pos;
wire            bcd_conv_done;

rslt_bin2bcd rslt_bcd_conversion(
.clk                       (                    clk),
.rst_n                     (                  rst_n),
.calc_rslt                 (              calc_rslt),
.calc_rslt_vld             (          calc_rslt_vld),
.calc_num_or_mode_invld    ( calc_mode_or_num_invld),
.calc_mode                 (              calc_mode),
.rslt_digit_a              (           rslt_digit_a),
.rslt_digit_b              (           rslt_digit_b),
.rslt_sign                 (              rslt_sign),
.rslt_is_fp                (             rslt_is_fp),
.rslt_8_digit              (           rslt_8_digit),
.rslt_dp_pos               (            rslt_dp_pos),
.bcd_conv_done             (          bcd_conv_done)
);

//output_state
display_module 7seg_output(
.clk                       (clk),
.rst_n                     (rst_n),
.clk_disp                  (clk_disp),
.left_btn_final            (left_btn_final),
.right_btn_final           (right_btn_final),
.rslt_is_fp                (rslt_is_fp),
.rslt_8_digits             (rslt_8_digits),
.excp_vld                  (excp_vld),
.proc_num_a_sign_bit       (   proc_num_a_sign_bit),
.proc_num_b_sign_bit       (   proc_num_b_sign_bit)
.dp_pos                    (rslt_dp_pos),
.pstate_in                 (cur_pstate),
.in_digits_a               (in_stage_num_a_digits),
.in_digits_b               (in_stage_num_b_digits),
.rslt_digits_a             (rslt_digit_a),
.rslt_digits_b             (rslt_digit_b),
.rslt_sign                 (rslt_sign),
.out_anode                 (seg_anode_act),
.out_seg_val               (seg_led_val),
.out_led                   (out_led)
); 

endmodule                    
