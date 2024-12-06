module cal_top(
	//input
	clk,
	rst_n,
 up_btn,
 down_btn,
 left_btn,
 mid_btn, 
	mode,
// usr_in_vld,
//output?//7 segment display pins (how many bits?)
seg_anode_act,//which segment LED to update
seg_led_val //segment led value
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
input [3:0] mode;

//decode and module selection (total should be 11 operations, 4 switches --> 4 bit control code)
wire    add_vld;
wire    sub_vld;
wire    mult_vld;
wire    div_vld;
wire    sqrt_vld;
wire    sin_vld;
wire    cos_vld;
wire    tan_vld;
wire    log_vld;
wire		  exp_vld;

//debouncing circuit (3ff) for all input involving switches and buttons 
wire up_btn_d1;
wire up_btn_d2;
wire up_btn_final;
wire down_btn_d1;
wire down_btn_d2;
wire down_btn_final;
wire left_btn_d1;
wire left_btn_d2;
wire left_btn_final;
wire right_btn_d1;
wire right_btn_d2;
wire right_btn_final;
wire mid_btn_d1;
wire mid_btn_d2;
wire mid_btn_final;

dffr #(1) up_btn_ff1 (.clk(clk), .rst_n(rst_n), .d(up_btn), .q(up_btn_d1));
dffr #(1) up_btn_ff2 (.clk(clk), .rst_n(rst_n), .d(up_btn_d1), .q(up_btn_d2));
dffr #(1) dn_btn_ff1 (.clk(clk), .rst_n(rst_n), .d(down_btn), .q(down_btn_d1));
dffr #(1) dn_btn_ff2 (.clk(clk), .rst_n(rst_n), .d(down_btn_d1), .q(down_btn_d2));
dffr #(1) lft_btn_ff1 (.clk(clk), .rst_n(rst_n), .d(left_btn), .q(left_btn_d1));
dffr #(1) lft_btn_ff2 (.clk(clk), .rst_n(rst_n), .d(left_btn_d1), .q(left_btn_d2));
dffr #(1) rt_btn_ff1 (.clk(clk), .rst_n(rst_n), .d(right_btn), .q(right_btn_d1));
dffr #(1) rt_btn_ff2 (.clk(clk), .rst_n(rst_n), .d(right_btn_d1), .q(right_btn_d2));
dffr #(1) mid_btn_ff1 (.clk(clk), .rst_n(rst_n), .d(mid_btn), .q(mid_btn_d1));
dffr #(1) mid_btn_ff2 (.clk(clk), .rst_n(rst_n), .d(right_btn_d1), .q(right_btn_d2));

assign up_btn_final    = up_btn_d1 & ~up_btn_d2;
assign down_btn_final  = down_btn_d1 & ~down_btn_d2;
assign left_btn_final  = left_btn_d1 & ~left_btn_d2;
assign right_btn_final = right_btn_d1 & ~right_btn_d2;

//calc state control (input mode, processing state, output state)
//1. fsm for each digit input value 
wire [3:0] cur_num;
reg [3:0] nxt_num;

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
					            if(up_btn_final) begin
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

//input values 

wire [1:0] cur_digit;
reg  [1:0] nxt_digit;

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
//input values & input value checking 
wire [15:0] in_num_a;
wire [15:0] in_num_b;

wire [2:0][3:0] in_digits_a;
wire [2:0][3:0] in_digits_b;

wire in_digit_1_wr_en;
wire in_digit_2_wr_en;
wire in_digit_3_wr_en;
wire in_sign_wr_en; 


assign in_digit_1_wr_en = (cur_digit == 2'b00) & (left_btn_final); 
assign in_digit_2_wr_en = (cur_digit == 2'b01) & (left_btn_final | wr_btn_final);
assign in_digit_3_wr_en = (cur_digit == 2'b10) & (left_btn_final | wr_btn_final);
assign in_sign_wr_en    = (cur_digit == 2'b11) ; //last input to select +ve/-ve then press confirm


//input switching & pstate fsm //if sin/cos/tan, exp, log dont need input b right? 
wire [1:0] cur_pstate;
reg  [1:0] nxt_pstate;

case(cur_pstate)
    2'b00: begin//in num A 
	              if(mid_btn_final) begin
                   nxt_pstate = 2'b01;
               end
           end
    2'b01: begin//in num A 
	              if(mid_btn_final) begin
                   nxt_pstate = 2'b01;
               end
															else if(in_err) begin
                   nxt_pstate = 2'b00;
               end
           end
    2'b10: begin//in num A 
	              if(rstl_vld) begin
                   nxt_pstate = 2'b11;
               end
           end
    2'b11: begin//in num A 
	              if(mid_btn_final) begin
                   nxt_pstate = 2'b00;
               end
           end
endcase 

dffr #(1) cur_pstate_fsm (.clk(clk), .rst_n(rst_n), .d(nxt_pstate), .q(cur_pstate));

wire in_num_a_wr_en;
wire in_num_b_wr_en;

wire [15:0] in_num_a_wr_data;//convert the 3 digits into 16 bit sign extended binary 
wire [15:0] in_num_b_wr_data; 
assign in_num_a_wr_en = (cur_pstate == 2'b00) & mid_btn_final;
assign in_num_b_wr_en = (cur_pstate == 2'b01) & mid_btn_final;

//convert the 4 digits into 16 bit sign extended binary  


//declare and establish connections to all modules (add/minus/mult/div/sin/cos ...)


//output processing 
//prob need an output moduel 
//need binary --> decimal --> segment display 
//floating point or no floaing point, how many significant figures 
wire rslt_num;



endmodule
