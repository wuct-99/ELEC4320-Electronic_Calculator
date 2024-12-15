module cal_in_proc(
	//input
	clk,
	rst_n,
 up_btn_final,
 down_btn_final,
 left_btn_final,
 right_btn_final,
 mid_btn_final, 
	mode_sw_final,
// usr_in_vld,
 pstate_in,
//output?//7 segment display pins (how many bits?)
 num_a_digits,
 num_b_digits,
//receive and output fsm state changes 
 cal_op_vld,
 cal_stage_vld,
 in_num_or_mode_invld,
//input values send to calculation unit
 proc_num_a,
 proc_num_b,
 proc_num_a_unsign,
 proc_num_b_unsign,
 proc_num_a_sign_bit,
 proc_num_b_sign_bit
);

//Core input
input clk;
input rst_n;
input up_btn_final;
input down_btn_final;
input left_btn_final;
input right_btn_final;
input mid_btn_final;
//input usr_in_vld;
input [10:0] mode_final;
input [1:0] pstate_in;

//output calculation stage valids
output [10:0] cal_op_vld;
output        cal_stage_vld;
//output number 
output [15:0] proc_num_a;
output [15:0] proc_num_b;
output [15:0] proc_num_a_unsign;
output [15:0] proc_num_b_unsign;

output  proc_num_a_sign_bit;
output  proc_num_b_sign_bit;


//output digits for display
output [3:0][3:0] num_a_digits;
output [3:0][3:0] num_b_digits;
//decode and module selection (total should be 11 operations, 4 switches --> 4 bit control code)
wire [10:0] nxt_cal_op_vld;
wire   in_num_or_mode_invld; //detected this fsm will jump to output error directly
//1. fsm for each digit input value 
wire [3:0] cur_num;
reg [3:0] nxt_num;
//input digit value fsm
wire [1:0] cur_digit;
reg  [1:0] nxt_digit;
//processings state fsm
wire [1:0] cur_pstate;
wire [1:0] prev_pstate;
//input values & input value checking 
reg [3:0][3:0] in_digits_a;
reg [3:0][3:0] in_digits_b;

wire in_a_digit_1_wr_en;
wire in_a_digit_2_wr_en;
wire in_a_digit_3_wr_en;
wire in_a_sign_wr_en;
wire in_b_digit_1_wr_en;
wire in_b_digit_2_wr_en;
wire in_b_digit_3_wr_en;
wire in_b_sign_wr_en;

wire in_num_a_wr_en; 
wire in_num_b_wr_en;

wire [15:0] in_num_a_bin;
wire [15:0] in_num_b_bin;
wire [15:0] in_num_a_bin_unsign;
wire [15:0] in_num_b_bin_unsign;
wire        in_num_a_sign_bit;
wire        in_num_b_sign_bit;
//input value checking valid for checking + valid for calculation
wire num_chk_vld;
wire mode_in_vld;
//calc state control (input mode, processing state, output state)


case(cur_num) 
    4'b0000: begin
					            if(up_btn_final) begin
                     nxt_num = 4'b0001;
                 end
                 else if(down_btn_final) begin;
                     nxt_num = 4'b1001;
                 end
             end 
   4'b0001: begin
																	if(cur_digit = 2'b11) begin //for sign digit
	                    if(up_btn_final | down_btn_final) begin
                         nxt_num = 4'b0000;
                     end
                 end
					            else if(up_btn_final) begin
                     nxt_num = 4'b0010;
                 end
                 else if(down_btn_final) begin;
                     nxt_num = 4'b0000;
                 end
             end 
   4'b0010: begin
					            if(up_btn_final) begin
                     nxt_num = 4'b0011;
                 end
                 else if(down_btn_final) begin;
                     nxt_num = 4'b0001;
                 end
             end 
   4'b0011: begin
					            if(up_btn_final) begin
                     nxt_num = 4'b0100;
                 end
                 else if(down_btn_final) begin;
                     nxt_num = 4'b0010;
                 end
             end 
   4'b0100: begin
					            if(up_btn_final) begin
                     nxt_num = 4'b0101;
                 end
                 else if(down_btn_final) begin;
                     nxt_num = 4'b0011;
                 end
             end 
   4'b0101: begin
					            if(up_btn_final) begin
                     nxt_num = 4'b0110;
                 end
                 else if(down_btn_final) begin;
                     nxt_num = 4'b100;
                 end
             end 
   4'b0110: begin
					            if(up_btn_final) begin
                     nxt_num = 4'b0101;
                 end
                 else if(down_btn_final) begin;
                     nxt_num = 4'b0101;
                 end
             end 
   4'b0111: begin
					            if(up_btn_final) begin
                     nxt_num = 4'b1000;
                 end
                 else if(down_btn_final) begin;
                     nxt_num = 4'b0110;
                 end
             end 
   4'b1000: begin
					            if(up_btn_final) begin
                     nxt_num = 4'b1001;
                 end
                 else if(down_btn_final) begin;
                     nxt_num = 4'b0111;
                 end
             end
			4'b1001: begin
					            if(up_btn_final) begin
                     nxt_num = 4'b0000;
                 end
                 else if(down_btn_final) begin;
                     nxt_num = 4'b1000;
                 end
            end
	  default:;
endcase 

dffr #(1) in_num_fsm (.clk(clk), .rst_n(rst_n), .d(nxt_num), .q(cur_num));
//save each digit fsm --> when change digit, save a copy of the current digit 


case(cur_digit) 
    2'b0: begin
	             if(left_btn_final) begin
           			    nxt_digit = 2'b01;
              end
              else if(right_btn_final)begin
                  nxt_digit = 2'b00;
              end
          end 
    2'b01: begin
	             if(left_btn_final) begin
           			    nxt_digit = 2'b10;
              end
              else if(right_btn_final)begin
                  nxt_digit = 2'b00;
              end
          end   
    2'b10: begin
	             if(left_btn_final) begin
           			    nxt_digit = 2'b11;
              end
              else if(right_btn_final)begin
                  nxt_digit = 2'b01;
              end
          end   
    2'b11: begin //digit for sign
	             if(left_btn_final) begin
           			    nxt_digit = 2'b11;
              end
              else if(right_btn_final)begin
                  nxt_digit = 2'b10;
              end
          end
				default:;
endcase
dffr #(1) digit_sel_fsm (.clk(clk), .rst_n(rst_n), .d(nxt_digit), .q(cur_digit));
//when left or right button pressed then save current digita
//in_vld until rslt_vld --> in_operation state, 
assign cur_pstate = pstate_in;
dffr #(2) prev_state_fsm (.clk(clk), .rst_n(rst_n), .d(cur_pstate), .q(prev_state));

assign in_a_digit_1_wr_en = (cur_digit == 2'b00) & (cur_pstate == 2'b00) & (left_btn_final | mid_btn_final); 
assign in_a_digit_2_wr_en = (cur_digit == 2'b01) & (cur_pstate == 2'b00) & (left_btn_final | mid_btn_final | right_btn_final);
assign in_a_digit_3_wr_en = (cur_digit == 2'b10) & (cur_pstate == 2'b00) & (left_btn_final | mid_btn_final | right_btn_final);
assign in_a_sign_wr_en    = (cur_digit == 2'b11) & (cur_pstate == 2'b00); //last input to select +ve/-ve then press confirm

assign in_b_digit_1_wr_en = (cur_digit == 2'b00) & (cur_pstate == 2'b01) & (left_btn_final | mid_btn_final); 
assign in_b_digit_2_wr_en = (cur_digit == 2'b01) & (cur_pstate == 2'b01) & (left_btn_final | mid_btn_final | right_btn_final);
assign in_b_digit_3_wr_en = (cur_digit == 2'b10) & (cur_pstate == 2'b01) & (left_btn_final | mid_btn_final | right_btn_final);
assign in_b_sign_wr_en    = (cur_digit == 2'b11) & (cur_pstate == 2'b01); //last input to select +ve/-ve then press confirm
//write each digit --> when press confirm save all digit --> next input 
dffre #(4) a_in_1_digit_ff (.clk(clk), .rst_n(rst_n), .en(in_a_digit_1_wr_en), .d(cur_num), .q(in_digits_a[0]));
dffre #(4) a_in_2_digit_ff (.clk(clk), .rst_n(rst_n), .en(in_a_digit_2_wr_en), .d(cur_num), .q(in_digits_a[1]));
dffre #(4) a_in_3_digit_ff (.clk(clk), .rst_n(rst_n), .en(in_a_digit_3_wr_en), .d(cur_num), .q(in_digits_a[2]));
dffre #(4) a_in_4_digit_ff (.clk(clk), .rst_n(rst_n), .en(in_a_digit_4_wr_en), .d(cur_num), .q(in_digits_a[3]));

dffre #(4) b_in_1_digit_ff (.clk(clk), .rst_n(rst_n), .en(in_b_digit_1_wr_en), .d(cur_num), .q(in_digits_b[0]));
dffre #(4) b_in_2_digit_ff (.clk(clk), .rst_n(rst_n), .en(in_b_digit_2_wr_en), .d(cur_num), .q(in_digits_b[1]));
dffre #(4) b_in_3_digit_ff (.clk(clk), .rst_n(rst_n), .en(in_b_digit_3_wr_en), .d(cur_num), .q(in_digits_b[2]));
dffre #(4) b_in_4_digit_ff (.clk(clk), .rst_n(rst_n), .en(in_b_digit_4_wr_en), .d(cur_num), .q(in_digits_b[3]));

assign num_a_digits = in_digits_a;
assign num_b_digits = in_digits_b;


assign in_num_a_wr_en = (cur_pstate == 2'b00) & mid_btn_final_d1;
assign in_num_b_wr_en = (cur_pstate == 2'b01) & mid_btn_final_d1;

//convert the 4 digits into 16 bit sign extended binary
bcd_convert_bin in_num_a_convert (.clk(clk), .rst_n(rst_n), .in_digits(in_digits_a),.bin_output(in_num_a_bin), .bin_output_unsign(in_num_a_bin_unsign), .output_sign(in_num_a_sign_bit));  
bcd_convert_bin in_num_b_convert (.clk(clk), .rst_n(rst_n), .in_digits(in_digits_b),.bin_output(in_num_b_bin), .bin_output_unsign(in_num_b_bin_unsign), .output_sign(in_num_b_sign_bit));  

//next clock for input validation 
dffr #(1) num_chk_vld_ff (.clk(clk), .rst_n(rst_n), .d(in_num_b_wr_en), .q(num_chk_vld);//state B + mid btn + 1 clock to wait for bin_conversion
//input qualification
assign nxt_cal_op_vld[0]   = mode_sw_final[0]  & ~(|mode_sw_final[1:10]) & num_chk_vld ;
assign nxt_cal_op_vld[1]   = mode_sw_final[1]  & ~mode_sw_final[0] & ~(|mode_sw_final[2:10]) & num_chk_vld ;
assign nxt_cal_op_vld[2]   = mode_sw_final[2]  & ~(|mode_sw_final[0:1]) & ~(|mode_sw_final[3:10]) & num_chk_vld ;
assign nxt_cal_op_vld[3]   = mode_sw_final[3]  & ~(|mode_sw_final[0:2]) & ~(|mode_sw_final[4:10]) & num_chk_vld ;
assign nxt_cal_op_vld[4]   = mode_sw_final[4]  & ~(|mode_sw_final[0:3]) & ~(|mode_sw_final[5:10]) & num_chk_vld & ~in_num_a_bin[15];
assign nxt_cal_op_vld[5]   = mode_sw_final[5]  & ~(|mode_sw_final[0:4]) & ~(|mode_sw_final[6:10]) & num_chk_vld ;
assign nxt_cal_op_vld[6]   = mode_sw_final[6]  & ~(|mode_sw_final[0:5]) & ~(|mode_sw_final[7:10]) & num_chk_vld ;
assign nxt_cal_op_vld[7]   = mode_sw_final[7]  & ~(|mode_sw_final[0:6]) & ~(|mode_sw_final[8:10]) & num_chk_vld ;
assign nxt_cal_op_vld[8]   = mode_sw_final[8]  & ~(|mode_sw_final[0:7]) & ~(|mode_sw_final[9:10]) & num_chk_vld & ~in_num_a_bin[15] & ~in_num_b_bin[15];
assign nxt_cal_op_vld[9]   = mode_sw_final[9]  & ~(|mode_sw_final[0:8]) & ~mode_sw_final[10] & num_chk_vld ;
assign nxt_cal_op_vld[10]  = mode_sw_final[10] & ~(|mode_sw_final[0:9]) & num_chk_vld ;
assign nxt_cal_stage_vld   = (~(prev_state == 2'b11 & cur_state == 2'b00)) | (cur_state == 2'b01 & (|nxt_cal_op_vld)) ;
//declare and establish connections to all modules (add/minus/mult/div/sin/cos ...) and connect all valid signals to the calculation modules
dffr #(1) cal_stage_vld_ff (.clk(clk), .rst_n(rst_n), .d(nxt_cal_stage_vld), .q(cal_stage_vld));
dffre #(11) cal_op_vld_ff (.clk(clk), .rst_n(rst_n), .en(num_chk_vld), .d(nxt_cal_op_vld), .q(cal_op_vld));
//if input not valid --> any_nxt_not valid
assign in_num_or_mode_invld = ~(|nxt_cal_stage_vld) & num_chk_vld;
assign proc_num_a = in_num_a_bin;
assign proc_num_b = in_num_b_bin; 
assign proc_num_a_unsign = in_num_a_bin_unsign; 
assign proc_num_b_unsign = in_num_b_bin_unsign; 
assign proc_num_a_sign_bit = in_num_a_sign_bit;
assign proc_num_b_sign_bit = in_num_b_sign_bit;


endmodule
