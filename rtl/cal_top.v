//`include "define.v"
module cal_top(
	//input
	clk,
	rst,
    board_cal_button,
    board_cal_switchs,
    cal_board_digit_ctrl,
    cal_board_digit_seg,
    cal_board_exe_done,
    cal_board_display_stage
);

input clk;
input rst;

//PORT
input [`BUTTON_WIDTH-1:0] board_cal_button;
input [`SWITCH_WIDTH-1:0] board_cal_switchs;
output [3:0] cal_board_digit_ctrl;
output [7:0] cal_board_digit_seg;
output cal_board_exe_done;
output [2:0] cal_board_display_stage;

//Internal wire define
//button qualify
wire [`BUTTON_WIDTH - 1:0] debounce_button;
wire [`BUTTON_WIDTH - 1:0] button_qual;
wire button_up;
wire button_down;
wire button_left;
wire button_right;
wire button_mid;

//input digit
wire [`DIGIT_WIDTH -1 :0] digit0_d;
wire [`DIGIT_WIDTH -1 :0] digit0_q;
wire [`DIGIT_WIDTH -1 :0] digit1_d;
wire [`DIGIT_WIDTH -1 :0] digit1_q;
wire [`DIGIT_WIDTH -1 :0] digit2_d;
wire [`DIGIT_WIDTH -1 :0] digit2_q;
wire sign_d;
wire sign_q;
wire digit0_en;
wire digit1_en;
wire digit2_en;
wire sign_en;

//input a/b
wire [`DIGIT_WIDTH - 1 : 0] a_digit0;
wire [`DIGIT_WIDTH - 1 : 0] a_digit1;
wire [`DIGIT_WIDTH - 1 : 0] a_digit2;
wire [`DIGIT_WIDTH - 1 : 0] b_digit0;
wire [`DIGIT_WIDTH - 1 : 0] b_digit1;
wire [`DIGIT_WIDTH - 1 : 0] b_digit2;
wire a_sign;
wire b_sign;
wire a_sign_qual;
wire b_sign_qual;
wire a_digit_en;
wire b_digit_en;

//7-segment driver
wire [1:0] digit_cnt_d;
wire [1:0] digit_cnt_q;
wire digit_cnt_en;
wire digit_cnt_rst;
wire digit_cnt_id0;
wire digit_cnt_id1;
wire digit_cnt_id2;
wire digit_cnt_id3;
wire [`DIGIT_WIDTH- 1:0] digit_val;
wire [`DIGIT_WIDTH -1:0] input_digit_curr;
wire [`DIGIT_WIDTH -1:0] output_int_lv0;
wire [`DIGIT_WIDTH -1:0] output_int_lv1;
wire [`DIGIT_WIDTH -1:0] output_int_lv2;

//Init counter for converting decimal to binary
wire [1:0] init_cnt_d;
wire [1:0] init_cnt_q;
wire init_cnt_en;

wire init_cnt_lv0_en;
wire init_cnt_lv1_en;
wire init_cnt_lv2_en;
wire init_cnt_lv3_en;

wire [1:0] dec2bin_cnt;

//FSME Define
wire [`FSME_STATE_WIDTH - 1:0] fsme_curr_state;
wire [`FSME_STATE_WIDTH - 1:0] fsme_next_state;
wire fsme_idle_to_init;
wire fsme_init_to_single;
wire fsme_init_to_multi;
wire fsme_init_to_done;
wire fsme_single_to_done;
wire fsme_multi_to_done;
wire fsme_done_to_idle;
wire fsme_in_idle;
wire fsme_in_init;
wire fsme_in_single;
wire fsme_in_multi;
wire fsme_in_done;
wire fsme_state_upd;
wire fsme_next_idle;
wire fsme_next_init;
wire fsme_next_done;
//FSMC
wire [`FSMC_STATE_WIDTH - 1:0] fsmc_curr_state;
wire [`FSMC_STATE_WIDTH - 1:0] fsmc_next_state;
wire fsmc_idle_to_inputa;
wire fsmc_inputa_to_inputb;
wire fsmc_inputb_to_exe;
wire fsmc_exe_to_convert;
wire fsmc_convert_to_setup;
wire fsmc_setup_to_display;
wire fsmc_display_to_inputa;
wire fsmc_state_upd;
wire fsmc_in_idle;
wire fsmc_in_inputa;
wire fsmc_in_inputb;
wire fsmc_in_exe;
wire fsmc_in_convert;
wire fsmc_in_setup  ;
wire fsmc_in_display;
wire fsmc_next_inputa;
wire fsmc_next_inputb;
wire fsmc_next_exe   ;
wire fsmc_next_display;
//FSMIN
wire [`FSMIN_STATE_WIDTH - 1:0] fsmin_curr_state;
wire [`FSMIN_STATE_WIDTH - 1:0] fsmin_next_state;
wire fsmin_idle_to_digit0;
wire fsmin_digit0_to_digit1;
wire fsmin_digit1_to_digit0;
wire fsmin_digit1_to_digit2;
wire fsmin_digit2_to_digit1;
wire fsmin_digit2_to_sign;
wire fsmin_sign_to_digit2;
wire fsmin_in_idle;
wire fsmin_in_digit0;
wire fsmin_in_digit1;
wire fsmin_in_digit2;
wire fsmin_in_sign;
wire fsmin_state_upd;
wire fsmin_state_rst;

//decimal to binary
wire [`RESULT_WIDTH-1:0] unsign_inputa; 
wire [`RESULT_WIDTH-1:0] unsign_inputb;
wire signed [`RESULT_WIDTH-1:0] inputa; 
wire signed [`RESULT_WIDTH-1:0] inputb;

//switch
wire switch_en;
wire [`SWITCH_WIDTH - 1:0] switchs_in_exe;
//exe op
wire [`SWITCH_WIDTH - 1:0] op_qual;
wire [`SWITCH_WIDTH - 1:0] op_qual_lv1;
wire int_result_op;
wire single_cyc_op;
wire multi_cyc_op;
wire single_cyc_op_lv1;
wire multi_cyc_op_lv1;

//exe
wire signed [`RESULT_WIDTH-1:0] add_result;
wire [`RESULT_WIDTH-1:0] add_result_q;

wire signed [`RESULT_WIDTH-1:0] sub_result;
wire [`RESULT_WIDTH-1:0] sub_result_q;

wire signed [31:0] mul_result;
wire [31:0] mul_result_q;

wire [31:0] cos_result;
wire [31:0] sin_result;

wire [15:0] div_result_int;
wire [23:0] div_result_frac;

wire [31:0] int_pwr_result;
wire [31:0] pos_pwr_result;

wire [39:0] pos_exp_result;
wire [15:0] int_exp_result;
wire [23:0] exp_result_frac;

wire [31:0] sqrt_result;

wire [31:0] log2_a_result;
wire [31:0] log2_b_result;
wire [31:0] log_result;

wire add_result_en;
wire sub_result_en;
wire mul_result_en;

wire div_start;
wire [31:0] div_inputa;
wire [31:0] div_inputb;
wire div_signa;
wire div_signb;

wire cos_sign;
wire sin_sign;
wire div_sign;
wire pwr_sign;

wire div_done;
wire pos_power_done;
wire neg_power_done;
wire pos_exp_done;
wire neg_exp_done;
wire cos_sin_done;
wire tri_done;
wire sqrt_done;
wire pwr_done;
wire log2_done;
wire log2_done_pre;
wire logn_done;

//result
wire exe_done;
wire cvt_done;
wire frac2int_done;
wire init_done;

wire overflow;
wire signed [31:0] int_result_qual;
wire signed [31:0] int_result_cvt_pre;
wire signed [31:0] int_result_cvt_pre_q;

wire [15:0] add_result_unsign;
wire [15:0] sub_result_unsign;
wire [31:0] mul_result_unsign;

//Invalid  checking
wire invld_result;
wire invld_input;
wire invld_input_lv1;
wire invld_div;
wire invld_sqrt;
wire invld_pwr;
wire invld_log_0in;
wire invld_log_negin;
wire invld_op;
wire pwr_overflow;
wire div_invld;
wire div_invld_qual; 

//convert fraction binary to decimal
wire frac2int_start;
wire [23:0] frac_part;

//binary to decimal
wire [4:0] cvt_cnt;
wire [4:0] cvt_cnt_q;
wire cvt_cnt_en;
wire cvt_cnt_rst;
wire [31:0] frac_dec_qual;
wire [31:0] int_dec_qual ;
wire [2:0] lead0_num     ;

wire bin2decdigit_init;
wire bin2decdigit_en;

wire result_sign;
wire [39:0] int_dec_digit;
wire [39:0] frac_dec_digit;

wire [39:0] int_digits_for_display;
wire [39:0] frac_digits_for_display;
wire [9:0] int_digits_idx_is0;
wire [9:0] frac_digits_idx_is0;

wire [39:0] int_digits_for_display_lv1;
wire [39:0] frac_digits_for_display_lv1;
wire [9:0] int_digits_idx_is0_lv1;
wire [9:0] frac_digits_idx_is0_lv1;

//display digit setup
wire setup_lv0_en;
wire setup_lv1_en;
wire setup_lv2_en;
wire setup_lv3_en;

wire int_part_is0;
wire frac_part_is0;
wire [39:0] int_digits_add_dots;
wire [39:0] frac_digits_for_display_adj;
wire [9:0]  int_digits_idx_is0_non0int_adj;
wire [9:0]  int_digits_idx_is0_adj;

wire int_part_is0_lv2;
wire frac_part_is0_lv2;
wire [39:0] int_digits_add_dots_lv2;
wire [39:0] frac_digits_for_display_adj_lv2;
wire [9:0]  int_digits_idx_is0_non0int_adj_lv2;
wire [9:0]  int_digits_idx_is0_adj_lv2;

wire [39:0] frac_digits_for_display_shift_lead0;
wire [39:0] frac_digits_for_display_align_non0int;
wire [39:0] frac_digits_for_display_align_int;
wire [39:0] mask_for_int_part;
wire [39:0] mask_for_frac_part;
wire [39:0] int_frac_digits_for_display;
wire [39:0] int_frac_digits_for_display_lv3;

wire [8:2] int_frac_digits_isa;
wire [39:0] output_digits_for_display;
wire [39:0] output_digits_for_display_lv4;
wire [15:0] output_digits_for_display_st2;
wire [15:0] output_digits_for_display_st3;

wire [`DISP_STG_WIDTH-1:0] total_disp_stage_pre;
wire [2:0] int_stage_final; 
wire [2:0] frac_stage_final; 

//Display digit for 7-segment
wire [3:0] output_digit2_for_st1;
wire [3:0] output_digit1_for_st1;
wire [3:0] output_digit0_for_st1;
wire [3:0] output_sign_for_st2;
wire [3:0] output_digit2_for_st2;
wire [3:0] output_digit1_for_st2;
wire [3:0] output_digit0_for_st2;
wire [3:0] output_sign_for_st3;
wire [3:0] output_digit2_for_st3;
wire [3:0] output_digit1_for_st3;
wire [3:0] output_digit0_for_st3;

//Display Stage
wire display_stage_en;
wire [2:0] display_stage  ;
wire [2:0] display_stage_q;
wire display_last_stage;

//display clk define
wire [9:0] clk_display_cnt_d;
wire [9:0] clk_display_cnt_q;
wire clk_display_en;
wire clk_display_state_d;
wire clk_display_state_q;
wire clk_display;

//------------------------------------------------
//Internal circuit 
//------------------------------------------------

//display clk 
//Divide clk with 1024 to get a slower clk for 7-segment dispaly
assign clk_display_cnt_d = clk_display_cnt_q + 2'b01;
dflip #(10) clk_display_cnt_ff (.clk(clk), .rst(rst), .d(clk_display_cnt_d), .q(clk_display_cnt_q));

assign clk_display_en = &clk_display_cnt_q;
//toggle the clk signal
assign clk_display_state_d = ~clk_display_state_q;
dflip_en #(1) clk_display_state_ff (.clk(clk), .rst(rst), .en(clk_display_en), .d(clk_display_state_d), .q(clk_display_state_q));
assign clk_display = clk_display_state_q;

//button debouncing 
debounce #(`BUTTON_WIDTH) button_debounce (.clk(clk), .rst(rst), .data_in(board_cal_button), .data_out(debounce_button));

//button decode and setup button pirority
//left > right > up > down > mid
assign button_qual[`BUTTON_LEFT ] = debounce_button[`BUTTON_LEFT ] ;
assign button_qual[`BUTTON_RIGHT] = debounce_button[`BUTTON_RIGHT] & ~(|debounce_button[`BUTTON_RIGHT - 1:0]);
assign button_qual[`BUTTON_UP   ] = debounce_button[`BUTTON_UP   ] & ~(|debounce_button[`BUTTON_UP    - 1:0]);  
assign button_qual[`BUTTON_DOWN ] = debounce_button[`BUTTON_DOWN ] & ~(|debounce_button[`BUTTON_DOWN  - 1:0]);
assign button_qual[`BUTTON_MID  ] = debounce_button[`BUTTON_MID  ] & ~(|debounce_button[`BUTTON_MID   - 1:0]);

assign button_up   = button_qual[`BUTTON_UP];
assign button_down = button_qual[`BUTTON_DOWN];
assign button_left = button_qual[`BUTTON_LEFT];
assign button_right= button_qual[`BUTTON_RIGHT];
assign button_mid  = button_qual[`BUTTON_MID];

//FSMC: main programm flow
assign fsmc_state_upd = fsmc_idle_to_inputa    |
                        fsmc_inputa_to_inputb  |
                        fsmc_inputb_to_exe     |
                        fsmc_exe_to_convert    |
                        fsmc_convert_to_setup  |
                        fsmc_setup_to_display  |
                        fsmc_display_to_inputa ;

assign fsmc_in_idle    = fsmc_curr_state[0];
assign fsmc_in_inputa  = fsmc_curr_state[1];
assign fsmc_in_inputb  = fsmc_curr_state[2];
assign fsmc_in_exe     = fsmc_curr_state[3];
assign fsmc_in_convert = fsmc_curr_state[4]; //Binary to Decimal Convert
assign fsmc_in_setup   = fsmc_curr_state[5]; //Display digit setup
assign fsmc_in_display = fsmc_curr_state[6];

assign fsmc_idle_to_inputa     = fsmc_in_idle   ;
assign fsmc_inputa_to_inputb   = fsmc_in_inputa  & button_mid;
assign fsmc_inputb_to_exe      = fsmc_in_inputb  & button_mid;
assign fsmc_exe_to_convert     = fsmc_in_exe     & exe_done;
assign fsmc_convert_to_setup   = fsmc_in_convert & cvt_done;
assign fsmc_setup_to_display   = fsmc_in_setup   & init_done; 
assign fsmc_display_to_inputa  = fsmc_in_display & button_mid & display_last_stage;

assign fsmc_next_state = {`FSMC_STATE_WIDTH{fsmc_idle_to_inputa   }} & `FSMC_INPUTA |
                         {`FSMC_STATE_WIDTH{fsmc_inputa_to_inputb }} & `FSMC_INPUTB |
                         {`FSMC_STATE_WIDTH{fsmc_inputb_to_exe    }} & `FSMC_EXE    |
                         {`FSMC_STATE_WIDTH{fsmc_exe_to_convert   }} & `FSMC_CONVERT|
                         {`FSMC_STATE_WIDTH{fsmc_convert_to_setup }} & `FSMC_SETUP  |
                         {`FSMC_STATE_WIDTH{fsmc_setup_to_display }} & `FSMC_DISPLAY|
                         {`FSMC_STATE_WIDTH{fsmc_display_to_inputa}} & `FSMC_INPUTA ;

assign fsmc_next_inputa  = fsmc_next_state[1];
assign fsmc_next_inputb  = fsmc_next_state[2];
assign fsmc_next_exe     = fsmc_next_state[3];
assign fsmc_next_display = fsmc_next_state[6];

dflip_en #(`FSMC_STATE_WIDTH, 
           `FSMC_STATE_WIDTH'h1) fsmc_state_ff (.clk(clk), .rst(rst), .en(fsmc_state_upd), .d(fsmc_next_state), .q(fsmc_curr_state));

assign cal_board_exe_done = fsmc_in_display;

//FSMIN: for input control
assign fsmin_in_idle   = fsmin_curr_state[0];
assign fsmin_in_digit0 = fsmin_curr_state[1];
assign fsmin_in_digit1 = fsmin_curr_state[2];
assign fsmin_in_digit2 = fsmin_curr_state[3];
assign fsmin_in_sign   = fsmin_curr_state[4];

//when move to next stage, need to reset the FSMIN
assign fsmin_state_rst = fsmc_next_inputa | fsmc_next_inputb | fsmc_next_exe;

assign fsmin_idle_to_digit0   = fsmin_in_idle   & (fsmc_in_inputa | fsmc_in_inputb);
assign fsmin_digit0_to_digit1 = fsmin_in_digit0 & button_left  & ~fsmin_state_rst;
assign fsmin_digit1_to_digit0 = fsmin_in_digit1 & button_right & ~fsmin_state_rst;
assign fsmin_digit1_to_digit2 = fsmin_in_digit1 & button_left  & ~fsmin_state_rst;
assign fsmin_digit2_to_digit1 = fsmin_in_digit2 & button_right & ~fsmin_state_rst;
assign fsmin_digit2_to_sign   = fsmin_in_digit2 & button_left  & ~fsmin_state_rst;
assign fsmin_sign_to_digit2   = fsmin_in_sign   & button_right & ~fsmin_state_rst;
assign fsmin_digit0_to_idle   = fsmin_in_digit0 & fsmin_state_rst;
assign fsmin_digit1_to_idle   = fsmin_in_digit1 & fsmin_state_rst;
assign fsmin_digit2_to_idle   = fsmin_in_digit2 & fsmin_state_rst;
assign fsmin_sign_to_idle     = fsmin_in_sign   & fsmin_state_rst;

assign fsmin_next_state = {`FSMIN_STATE_WIDTH{fsmin_idle_to_digit0  }} & `FSMIN_DIGIT0 |
                          {`FSMIN_STATE_WIDTH{fsmin_digit0_to_digit1}} & `FSMIN_DIGIT1 |
                          {`FSMIN_STATE_WIDTH{fsmin_digit1_to_digit0}} & `FSMIN_DIGIT0 |
                          {`FSMIN_STATE_WIDTH{fsmin_digit1_to_digit2}} & `FSMIN_DIGIT2 |
                          {`FSMIN_STATE_WIDTH{fsmin_digit2_to_digit1}} & `FSMIN_DIGIT1 |
                          {`FSMIN_STATE_WIDTH{fsmin_digit2_to_sign  }} & `FSMIN_SIGN   |
                          {`FSMIN_STATE_WIDTH{fsmin_sign_to_digit2  }} & `FSMIN_DIGIT2 |
                          {`FSMIN_STATE_WIDTH{fsmin_digit0_to_idle  }} & `FSMIN_IDLE   |
                          {`FSMIN_STATE_WIDTH{fsmin_digit1_to_idle  }} & `FSMIN_IDLE   |
                          {`FSMIN_STATE_WIDTH{fsmin_digit2_to_idle  }} & `FSMIN_IDLE   |
                          {`FSMIN_STATE_WIDTH{fsmin_sign_to_idle    }} & `FSMIN_IDLE   ;

assign fsmin_state_upd = fsmin_idle_to_digit0   |
                         fsmin_digit0_to_digit1 |
                         fsmin_digit1_to_digit0 |
                         fsmin_digit1_to_digit2 |
                         fsmin_digit2_to_digit1 |
                         fsmin_digit2_to_sign   |
                         fsmin_sign_to_digit2   |
                         fsmin_digit0_to_idle   |
                         fsmin_digit1_to_idle   |
                         fsmin_digit2_to_idle   |
                         fsmin_sign_to_idle     ;

dflip_en #(`FSMIN_STATE_WIDTH, 5'h1) fsmin_state_ff (.clk(clk), 
                                                     .rst(rst), 
                                                     .en(fsmin_state_upd), 
                                                     .d(fsmin_next_state), 
                                                     .q(fsmin_curr_state));
//input digit Control
//up and down to control
assign digit0_en = (fsmin_in_digit0 & (button_up | button_down)) | fsmin_state_rst;
//if digit value is 9, press up will change back to 0
//if digit value is 0, press down will change back to 9
//else press down, current value - 1
//else press up, current value + 1
assign digit0_d = {`DIGIT_WIDTH{fsmin_state_rst                               }} & (`DIGIT_WIDTH'b0000) | 
                  {`DIGIT_WIDTH{button_up   & (digit0_q == `DIGIT_WIDTH'b1001)}} & (`DIGIT_WIDTH'b0000) |   
                  {`DIGIT_WIDTH{button_up   & (digit0_q <  `DIGIT_WIDTH'b1001)}} & (digit0_q + 4'b1   ) | 
                  {`DIGIT_WIDTH{button_down & (digit0_q == `DIGIT_WIDTH'b0000)}} & (`DIGIT_WIDTH'b1001) | 
                  {`DIGIT_WIDTH{button_down & (digit0_q >  `DIGIT_WIDTH'b0000)}} & (digit0_q - 4'b1   ) ;
dflip_en #(`DIGIT_WIDTH) digit0_ff (.clk(clk), .rst(rst), .en(digit0_en), .d(digit0_d), .q(digit0_q));

assign digit1_en = (fsmin_in_digit1 & (button_up | button_down)) | fsmin_state_rst;
assign digit1_d = {`DIGIT_WIDTH{fsmin_state_rst                               }} & (`DIGIT_WIDTH'b0000) | 
                  {`DIGIT_WIDTH{button_up   & (digit1_q == `DIGIT_WIDTH'b1001)}} & (`DIGIT_WIDTH'b0000) |       
                  {`DIGIT_WIDTH{button_up   & (digit1_q <  `DIGIT_WIDTH'b1001)}} & (digit1_q + 4'b1   ) | 
                  {`DIGIT_WIDTH{button_down & (digit1_q == `DIGIT_WIDTH'b0000)}} & (`DIGIT_WIDTH'b1001) | 
                  {`DIGIT_WIDTH{button_down & (digit1_q >  `DIGIT_WIDTH'b0000)}} & (digit1_q - 4'b1   ) ;
dflip_en #(`DIGIT_WIDTH) digit1_ff (.clk(clk), .rst(rst), .en(digit1_en), .d(digit1_d), .q(digit1_q));

assign digit2_en = (fsmin_in_digit2 & (button_up | button_down)) | fsmin_state_rst;
assign digit2_d = {`DIGIT_WIDTH{fsmin_state_rst                               }} & (`DIGIT_WIDTH'b0000) | 
                  {`DIGIT_WIDTH{button_up   & (digit2_q == `DIGIT_WIDTH'b1001)}} & (`DIGIT_WIDTH'b0000) |       
                  {`DIGIT_WIDTH{button_up   & (digit2_q <  `DIGIT_WIDTH'b1001)}} & (digit2_q + 4'b1   ) | 
                  {`DIGIT_WIDTH{button_down & (digit2_q == `DIGIT_WIDTH'b0000)}} & (`DIGIT_WIDTH'b1001) | 
                  {`DIGIT_WIDTH{button_down & (digit2_q >  `DIGIT_WIDTH'b0000)}} & (digit2_q - 4'b1   ) ;
dflip_en #(`DIGIT_WIDTH) digit2_ff (.clk(clk), .rst(rst), .en(digit2_en), .d(digit2_d), .q(digit2_q));

//if press up / down, just toggle the value
assign sign_en = (fsmin_in_sign & (button_up | button_down)) | fsmin_state_rst;
assign sign_d = fsmin_state_rst ? 4'b0000 : sign_q + 1'b1;
dflip_en sign_ff (.clk(clk), .rst(rst), .en(sign_en), .d(sign_d), .q(sign_q));

//Save input a/b for execution
assign a_digit_en = fsmc_next_inputb;
assign b_digit_en = fsmc_next_exe;

dflip_en #(`DIGIT_WIDTH) a_digit0_ff (.clk(clk), .rst(rst), .en(a_digit_en), .d(digit0_q), .q(a_digit0));
dflip_en #(`DIGIT_WIDTH) b_digit0_ff (.clk(clk), .rst(rst), .en(b_digit_en), .d(digit0_q), .q(b_digit0));
dflip_en #(`DIGIT_WIDTH) a_digit1_ff (.clk(clk), .rst(rst), .en(a_digit_en), .d(digit1_q), .q(a_digit1));
dflip_en #(`DIGIT_WIDTH) b_digit1_ff (.clk(clk), .rst(rst), .en(b_digit_en), .d(digit1_q), .q(b_digit1));
dflip_en #(`DIGIT_WIDTH) a_digit2_ff (.clk(clk), .rst(rst), .en(a_digit_en), .d(digit2_q), .q(a_digit2));
dflip_en #(`DIGIT_WIDTH) b_digit2_ff (.clk(clk), .rst(rst), .en(b_digit_en), .d(digit2_q), .q(b_digit2));
dflip_en a_sign_ff (.clk(clk), .rst(rst), .en(a_digit_en), .d(sign_q), .q(a_sign));
dflip_en b_sign_ff (.clk(clk), .rst(rst), .en(b_digit_en), .d(sign_q), .q(b_sign));

//7-segment driver
assign digit_cnt_rst = fsmc_next_inputa | fsmc_next_inputb | fsmc_next_exe | fsmc_next_display; 
assign digit_cnt_en = fsmc_in_inputa | fsmc_in_inputb | fsmc_in_display & ~invld_result | digit_cnt_rst;
assign digit_cnt_d = digit_cnt_rst ? 2'b00 : digit_cnt_q + 2'b01;

//digit 0 > digit 1 > digit2 > sign
dflip_en #(2) digit_cnt_ff (.clk(clk_display), .rst(rst), .en(digit_cnt_en), .d(digit_cnt_d), .q(digit_cnt_q));

assign digit_cnt_id0 = digit_cnt_q == 2'b00;
assign digit_cnt_id1 = digit_cnt_q == 2'b01;
assign digit_cnt_id2 = digit_cnt_q == 2'b10;
assign digit_cnt_id3 = digit_cnt_q == 2'b11;
//counter is 0 turn on digit 0 
//counter is 1 turn on digit 1 
//counter is 2 turn on digit 2 
//counter is 3 turn on sign digit 
//if invalid result, disable display
assign cal_board_digit_ctrl = {`DIGIT_WIDTH{digit_cnt_id0}} & `DIGIT_WIDTH'b1110 |
                              {`DIGIT_WIDTH{digit_cnt_id1}} & `DIGIT_WIDTH'b1101 |
                              {`DIGIT_WIDTH{digit_cnt_id2}} & `DIGIT_WIDTH'b1011 |
                              {`DIGIT_WIDTH{digit_cnt_id3}} & `DIGIT_WIDTH'b0111 | 
                              {`DIGIT_WIDTH{~digit_cnt_en | invld_result & fsmc_in_display}} & `DIGIT_WIDTH'b1111 ;

//get input digit
assign input_digit_curr = {`DIGIT_WIDTH{digit_cnt_id0}} & digit0_q |
                          {`DIGIT_WIDTH{digit_cnt_id1}} & digit1_q |
                          {`DIGIT_WIDTH{digit_cnt_id2}} & digit2_q |
                          {`DIGIT_WIDTH{digit_cnt_id3}} & {3'b101, sign_q} ;

//get output digit
//stage 1
assign output_int_lv0 = {`DIGIT_WIDTH{digit_cnt_id0}} & output_digit0_for_st1 |
                        {`DIGIT_WIDTH{digit_cnt_id1}} & output_digit1_for_st1 |
                        {`DIGIT_WIDTH{digit_cnt_id2}} & output_digit2_for_st1 |
                        {`DIGIT_WIDTH{digit_cnt_id3}} & {3'b101, result_sign}   ;
//stage 2: if output has more than 3 digits
assign output_int_lv1 = {`DIGIT_WIDTH{digit_cnt_id0}} & output_digit0_for_st2 |
                        {`DIGIT_WIDTH{digit_cnt_id1}} & output_digit1_for_st2 |
                        {`DIGIT_WIDTH{digit_cnt_id2}} & output_digit2_for_st2 |
                        {`DIGIT_WIDTH{digit_cnt_id3}} & output_sign_for_st2 ;

//stage 3: if output has more than 7 digits
assign output_int_lv2 = {`DIGIT_WIDTH{digit_cnt_id0}} & output_digit0_for_st3 |
                        {`DIGIT_WIDTH{digit_cnt_id1}} & output_digit1_for_st3 |
                        {`DIGIT_WIDTH{digit_cnt_id2}} & output_digit2_for_st3 |
                        {`DIGIT_WIDTH{digit_cnt_id3}} & output_sign_for_st3 ;

//Select digit depend on input stage or output satge 
assign digit_val = (fsmc_in_inputa | fsmc_in_inputb) ? input_digit_curr : 
                   (fsmc_in_display & (display_stage_q == 3'b00)) ? output_int_lv0 :
                   (fsmc_in_display & (display_stage_q == 3'b01)) ? output_int_lv1 : 
                   (fsmc_in_display & (display_stage_q == 3'b10)) ? output_int_lv2 : 4'ha;

//7-segment Ouput decoder
assign cal_board_digit_seg = {8{digit_val == `DIGIT_WIDTH'h0}} & 8'b0000_0011 | // 0
                             {8{digit_val == `DIGIT_WIDTH'h1}} & 8'b1001_1111 | // 1     
                             {8{digit_val == `DIGIT_WIDTH'h2}} & 8'b0010_0101 | // 2     
                             {8{digit_val == `DIGIT_WIDTH'h3}} & 8'b0000_1101 | // 3     
                             {8{digit_val == `DIGIT_WIDTH'h4}} & 8'b1001_1001 | // 4     
                             {8{digit_val == `DIGIT_WIDTH'h5}} & 8'b0100_1001 | // 5     
                             {8{digit_val == `DIGIT_WIDTH'h6}} & 8'b0100_0001 | // 6     
                             {8{digit_val == `DIGIT_WIDTH'h7}} & 8'b0001_1111 | // 7     
                             {8{digit_val == `DIGIT_WIDTH'h8}} & 8'b0000_0001 | // 8     
                             {8{digit_val == `DIGIT_WIDTH'h9}} & 8'b0001_1001 | // 9     
                             {8{digit_val == `DIGIT_WIDTH'ha}} & 8'b1111_1111 | // None 
                             {8{digit_val == `DIGIT_WIDTH'hb}} & 8'b1111_1101 | // "-"; 
                             {8{digit_val == `DIGIT_WIDTH'hc}} & 8'b1111_1110 ; // "."  

//init counter
assign init_cnt_d = init_cnt_q + 2'b01;
assign init_cnt_en = fsmc_in_exe & fsme_in_init | fsmc_in_setup;
dflip_en #(2) init_cnt_ff (.clk(clk), .rst(rst), .en(init_cnt_en), .d(init_cnt_d), .q(init_cnt_q));
assign init_done = &init_cnt_q;

assign init_cnt_lv1_en = init_cnt_q == 2'b0;
assign init_cnt_lv2_en = init_cnt_q == 2'b1;
assign init_cnt_lv3_en = init_cnt_q == 2'b10;
assign init_cnt_lv4_en = init_cnt_q == 2'b11;

//Operation decode & setup priority
assign switch_en = fsmc_next_exe;
dflip_en #(`SWITCH_WIDTH) switch_ff (.clk(clk), .rst(rst), .en(switch_en), .d(board_cal_switchs), .q(switchs_in_exe));
//add > sub > mul > div > square root > cos > sin > tan > log > power > exp
assign op_qual[`OP_ADD ] = switchs_in_exe[`OP_ADD ] ;
assign op_qual[`OP_SUB ] = switchs_in_exe[`OP_SUB ] & ~switchs_in_exe[0];
assign op_qual[`OP_MUL ] = switchs_in_exe[`OP_MUL ] & ~(|switchs_in_exe[1:0] );
assign op_qual[`OP_DIV ] = switchs_in_exe[`OP_DIV ] & ~(|switchs_in_exe[2:0] );
assign op_qual[`OP_SQRT] = switchs_in_exe[`OP_SQRT] & ~(|switchs_in_exe[3:0] );
assign op_qual[`OP_COS ] = switchs_in_exe[`OP_COS ] & ~(|switchs_in_exe[4:0] );
assign op_qual[`OP_SIN ] = switchs_in_exe[`OP_SIN ] & ~(|switchs_in_exe[5:0] );
assign op_qual[`OP_TAN ] = switchs_in_exe[`OP_TAN ] & ~(|switchs_in_exe[6:0] );
assign op_qual[`OP_LOG ] = switchs_in_exe[`OP_LOG ] & ~(|switchs_in_exe[7:0]);
assign op_qual[`OP_POW ] = switchs_in_exe[`OP_POW ] & ~(|switchs_in_exe[8:0]);
assign op_qual[`OP_EXP ] = switchs_in_exe[`OP_EXP ] & ~(|switchs_in_exe[9:0]);

dflip_en #(`SWITCH_WIDTH) switch_after_init_ff (.clk(clk), .rst(rst), .en(init_cnt_lv1_en), .d(op_qual), .q(op_qual_lv1));

//Only add, sub, mul must output integer result
assign int_result_op = op_qual_lv1[`OP_ADD] | 
                       op_qual_lv1[`OP_SUB] | 
                       op_qual_lv1[`OP_MUL] ;

//single cycle operation
assign single_cyc_op = op_qual_lv1[`OP_ADD] |
                       op_qual_lv1[`OP_SUB] |
                       op_qual_lv1[`OP_MUL] ;

//multi cycle operation
assign multi_cyc_op = op_qual_lv1[`OP_SQRT] |
                      op_qual_lv1[`OP_COS]  |
                      op_qual_lv1[`OP_SIN]  |
                      op_qual_lv1[`OP_TAN]  |
                      op_qual_lv1[`OP_POW]  |
                      op_qual_lv1[`OP_EXP]  |
                      op_qual_lv1[`OP_LOG]  ;

//Check input constraint
//COS,SIN, TAN input range from -99 to 99
assign invld_tri = (op_qual_lv1[`OP_COS] | op_qual_lv1[`OP_SIN] | op_qual_lv1[`OP_TAN]) & (|a_digit2 );     
//Square root does not support negative value
assign invld_sqrt = op_qual_lv1[`OP_SQRT] & a_sign;     
//Power does not support 0^0
assign invld_pwr  = op_qual_lv1[`OP_POW] & (~(|a_digit2) & ~(|a_digit1) & ~(|a_digit0)) & (~(|b_digit2) & ~(|b_digit1) & ~(|b_digit0));
//Log does not support any negative and 0 input
assign invld_log_0in  = op_qual_lv1[`OP_LOG] & ((~(|a_digit2) & ~(|a_digit1) & ~(|a_digit0)) | (~(|b_digit2) & ~(|b_digit1) & ~(|b_digit0))) ;
assign invld_log_negin  = op_qual_lv1[`OP_LOG] & (a_sign | b_sign) ;

//No opeartion selected
assign invld_op   = ~(|op_qual_lv1);     

assign invld_input = invld_tri       |
                     invld_sqrt      |
                     invld_pwr       |
                     invld_log_0in   |
                     invld_log_negin |
                     invld_op        ;

dflip_en #(1) invld_input_ff   (.clk(clk), .rst(rst), .en(init_cnt_lv2_en), .d(invld_input  ), .q(invld_input_lv1  ));
dflip_en #(1) single_cyc_op_ff (.clk(clk), .rst(rst), .en(init_cnt_lv2_en), .d(single_cyc_op), .q(single_cyc_op_lv1));
dflip_en #(1) multi_cyc_op_ff  (.clk(clk), .rst(rst), .en(init_cnt_lv2_en), .d(multi_cyc_op ), .q(multi_cyc_op_lv1 ));

//Convert decimal digit to binary
assign dec2bin_cnt = {2{fsme_in_init}} & init_cnt_q;
dec2bin u_dec2bin_a(.clk(clk),
                    .rst(rst),
                    .init_cnt_q(dec2bin_cnt),
                    .digit0(a_digit0),
                    .digit1(a_digit1),
                    .digit2(a_digit2),
                    .digit_sign(a_sign),
                    .unsign_dec(unsign_inputa),
                    .input_qual(inputa)
);

dec2bin u_dec2bin_b(.clk(clk),
                    .rst(rst),
                    .init_cnt_q(dec2bin_cnt),
                    .digit0(b_digit0),
                    .digit1(b_digit1),
                    .digit2(b_digit2),
                    .digit_sign(b_sign),
                    .unsign_dec(unsign_inputb),
                    .input_qual(inputb)
);
//if input value is 0, remove the sign signal
assign a_sign_qual = a_sign & (|inputa);
assign b_sign_qual = b_sign & (|inputb);

//FSME: for main execution operation
assign fsme_in_idle   = fsme_curr_state[0];
assign fsme_in_init   = fsme_curr_state[1];
assign fsme_in_single = fsme_curr_state[2];
assign fsme_in_multi  = fsme_curr_state[3];
assign fsme_in_div    = fsme_curr_state[4];
assign fsme_in_done   = fsme_curr_state[5];

assign fsme_idle_to_init   = fsme_in_idle   & fsmc_in_exe;
assign fsme_init_to_single = fsme_in_init   & ~invld_input_lv1 & single_cyc_op_lv1 & init_done;
assign fsme_init_to_multi  = fsme_in_init   & ~invld_input_lv1 & multi_cyc_op_lv1  & init_done;
assign fsme_init_to_div    = fsme_in_init   & ~invld_input_lv1 & op_qual_lv1[`OP_DIV]  & init_done;
assign fsme_init_to_done   = fsme_in_init   & invld_input_lv1  & init_done;
assign fsme_single_to_done = fsme_in_single ;
assign fsme_multi_to_done  = fsme_in_multi  & (cos_sin_done | sqrt_done | pos_power_done | pos_exp_done | log2_done); //FIXME
assign fsme_multi_to_div   = fsme_in_multi  & (tri_done | neg_power_done | neg_exp_done | logn_done); //FIXME
assign fsme_div_to_done    = fsme_in_div    & div_done;
assign fsme_done_to_idle   = fsme_in_done   & (int_result_op | frac2int_done);

assign fsme_next_state = {`FSME_STATE_WIDTH{fsme_idle_to_init  }} & `FSME_INIT   |
                         {`FSME_STATE_WIDTH{fsme_init_to_single}} & `FSME_SINGLE |
                         {`FSME_STATE_WIDTH{fsme_init_to_multi }} & `FSME_MULTI  |
                         {`FSME_STATE_WIDTH{fsme_init_to_div   }} & `FSME_DIV    |
                         {`FSME_STATE_WIDTH{fsme_init_to_done  }} & `FSME_DONE   |
                         {`FSME_STATE_WIDTH{fsme_single_to_done}} & `FSME_DONE   |
                         {`FSME_STATE_WIDTH{fsme_multi_to_done }} & `FSME_DONE   |
                         {`FSME_STATE_WIDTH{fsme_multi_to_div  }} & `FSME_DIV    |
                         {`FSME_STATE_WIDTH{fsme_div_to_done   }} & `FSME_DONE   |
                         {`FSME_STATE_WIDTH{fsme_done_to_idle  }} & `FSME_IDLE   ;

assign fsme_state_upd = fsme_idle_to_init   |
                        fsme_init_to_single |
                        fsme_init_to_multi  |
                        fsme_init_to_div    |
                        fsme_init_to_done   |
                        fsme_single_to_done |
                        fsme_multi_to_done  |
                        fsme_multi_to_div   |
                        fsme_div_to_done    |
                        fsme_done_to_idle   ;

assign fsme_next_idle  = fsme_next_state[0];
assign fsme_next_init  = fsme_next_state[1];
assign fsme_next_multi = fsme_next_state[3];
assign fsme_next_div   = fsme_next_state[4];
assign fsme_next_done  = fsme_next_state[5];

dflip_en #(`FSME_STATE_WIDTH, `FSME_STATE_WIDTH'h1) fsme_state_ff (.clk(clk), 
                                                                   .rst(rst), 
                                                                   .en(fsme_state_upd), 
                                                                   .d(fsme_next_state), 
                                                                   .q(fsme_curr_state));

assign exe_done = fsme_next_idle;

//single cyc execute
assign add_result = inputa + inputb;
assign sub_result = inputa - inputb;
assign mul_result = inputa * inputb;

assign add_result_en = fsme_in_single & op_qual_lv1[`OP_ADD];
assign sub_result_en = fsme_in_single & op_qual_lv1[`OP_SUB];
assign mul_result_en = fsme_in_single & op_qual_lv1[`OP_MUL];

dflip_en #(`RESULT_WIDTH) add_result_ff (.clk(clk), .rst(rst), .en(add_result_en), .d(add_result), .q(add_result_q));
dflip_en #(`RESULT_WIDTH) sub_result_ff (.clk(clk), .rst(rst), .en(sub_result_en), .d(sub_result), .q(sub_result_q));
dflip_en #(32)            mul_result_ff (.clk(clk), .rst(rst), .en(mul_result_en), .d(mul_result), .q(mul_result_q));

assign div_start = fsme_in_div;
//Tangent: sin / cos
//Negative power index: 1 / a^b
//Negative exp index: 1 / e^a
assign div_inputa = {32{op_qual_lv1[`OP_DIV]}} & {unsign_inputa} |
                    {32{op_qual_lv1[`OP_TAN]}} & sin_result      |
                    {32{op_qual_lv1[`OP_POW]}} & 32'b1           |
                    {32{op_qual_lv1[`OP_EXP]}} & 32'h1_0000      |
                    {32{op_qual_lv1[`OP_LOG]}} & log2_b_result   ;

assign div_inputb = {32{op_qual_lv1[`OP_DIV]}} & {unsign_inputb}      |
                    {32{op_qual_lv1[`OP_TAN]}} & cos_result           |
                    {32{op_qual_lv1[`OP_POW]}} & pos_pwr_result       | 
                    {32{op_qual_lv1[`OP_EXP]}} & pos_exp_result[39:8] |
                    {32{op_qual_lv1[`OP_LOG]}} & log2_a_result        ;

assign div_signa  = op_qual_lv1[`OP_DIV] ? a_sign_qual : sin_sign;
assign div_signb  = op_qual_lv1[`OP_DIV] ? b_sign_qual : cos_sign;

//Multi cycle execute
divider u_divider(.clk(clk), 
                  .rst(rst),
                  .div_rst(fsme_next_div),
                  .div_start(div_start),
                  .inputa_sign(div_signa),
                  .inputb_sign(div_signb),
                  .unsign_inputa(div_inputa),
                  .unsign_inputb(div_inputb),
                  .div_invld(div_invld), 
                  .div_result_int(div_result_int), 
                  .div_result_frac(div_result_frac), 
                  .div_sign(div_sign), 
                  .div_done(div_done)
);

trigonometric u_trigonometric(
    .clk(clk),
    .rst(rst),
    .tri_start(fsme_in_multi & (op_qual_lv1[`OP_SIN] | op_qual_lv1[`OP_COS] | op_qual_lv1[`OP_TAN])),
    .input_angle(inputa),
    .cos_data(cos_result),
    .sin_data(sin_result),
    .cos_sign(cos_sign),
    .sin_sign(sin_sign),
    .tri_done(tri_done)
);
assign cos_sin_done = (op_qual_lv1[`OP_SIN] | op_qual_lv1[`OP_COS]) & tri_done;

power u_power(
    .clk(clk),
    .rst(rst),
    .power_start(fsme_in_multi & op_qual_lv1[`OP_POW]),
    .power_rst(fsme_next_multi),
    .unsign_inputa(unsign_inputa),
    .unsign_inputb(unsign_inputb),
    .inputa_sign(a_sign_qual),
    
    .power_done(pwr_done),
    .power_result(pos_pwr_result),
    .power_sign(pwr_sign),
    .power_overflow(pwr_overflow)
);

assign int_pwr_result = {32{~b_sign_qual}} & pos_pwr_result;
assign pos_power_done = ~b_sign_qual & pwr_done;
assign neg_power_done = b_sign_qual  & pwr_done;

exp u_exp(
    .clk(clk),
    .rst(rst),
    .exp_start(fsme_in_multi & op_qual_lv1[`OP_EXP]),
    .exp_rst(fsme_next_multi),
    .unsign_inputa(unsign_inputa),
    
    .exp_done(exp_done),
    .exp_result_out(pos_exp_result),
    .exp_overflow(exp_overflow)
);

assign int_exp_result = {16{~a_sign_qual}} &  pos_exp_result[39:24];
assign exp_result_frac = a_sign_qual ? div_result_frac : pos_exp_result[23:0];
assign pos_exp_done = ~a_sign_qual & exp_done;
assign neg_exp_done = a_sign_qual  & exp_done;

sqrt u_sqrt(
    .clk(clk),
    .rst(rst),
    .sqrt_rst(fsme_next_multi) ,
    .sqrt_start(fsme_in_multi & op_qual_lv1[`OP_SQRT]) ,
    .inputa(inputa),
    .sqrt_result(sqrt_result),    
    .sqrt_done(sqrt_done)
);

log2 u_log2_a(
    .clk(clk),
    .rst(rst),
    .log2_rst(fsme_next_multi),
    .log2_start(fsme_in_multi & op_qual_lv1[`OP_LOG]),
    .input_value(unsign_inputa),
    .log2_result_out(log2_a_result),
    .log2_done()
);

log2 u_log2_b(
    .clk(clk),
    .rst(rst),
    .log2_rst(fsme_next_multi),
    .log2_start(fsme_in_multi & op_qual_lv1[`OP_LOG]),
    .input_value(unsign_inputb),
    .log2_result_out(log2_b_result),
    .log2_done(log2_done_pre)
);

assign log_result = unsign_inputa == 16'd2 ? log2_b_result : {div_result_int[7:0], div_result_frac};
assign log2_done = (unsign_inputa == 16'd2) & log2_done_pre;
assign logn_done = (unsign_inputa != 16'd2) & log2_done_pre;

//Select fraction binary
dflip #(1) frac2int_start_ff (.clk(clk), .rst(rst), .d(fsme_next_done), .q(frac2int_start));

assign frac_part = {24{op_qual_lv1[`OP_DIV ]}} & div_result_frac           |
                   {24{op_qual_lv1[`OP_SQRT]}} & {sqrt_result[15:0], 8'b0} |
                   {24{op_qual_lv1[`OP_COS ]}} & {cos_result[15:0],  8'b0} |
                   {24{op_qual_lv1[`OP_SIN ]}} & {sin_result[15:0],  8'b0} |
                   {24{op_qual_lv1[`OP_TAN ]}} & div_result_frac           |
                   {24{op_qual_lv1[`OP_POW ]}} & div_result_frac           |
                   {24{op_qual_lv1[`OP_EXP ]}} & exp_result_frac           |
                   {24{op_qual_lv1[`OP_LOG ]}} & log_result[23:0]          ;
//Convert fraction binary to decimal
frac2int u_frac2int(
    .clk(clk),
    .rst(rst),
    .frac2int_start   (frac2int_start),
    .frac_part        (frac_part    ),
    .fraction_in_dec  (frac_dec_qual),
    .lead0_num        (lead0_num    ),
    .frac2int_done    (frac2int_done)
);

//Convert signed value to unsign for display
assign add_result_unsign = add_result_q[15] ? ~add_result_q + 1 : add_result_q;
assign sub_result_unsign = sub_result_q[15] ? ~sub_result_q + 1 : sub_result_q;
assign mul_result_unsign = mul_result_q[31] ? ~mul_result_q + 1 : mul_result_q;

//result
assign int_result_qual = {32{op_qual_lv1[`OP_ADD ]}} & {16'b0, add_result_unsign} |
                         {32{op_qual_lv1[`OP_SUB ]}} & {16'b0, sub_result_unsign} |
                         {32{op_qual_lv1[`OP_MUL ]}} & mul_result_unsign          |
                         {32{op_qual_lv1[`OP_DIV ]}} & {16'b0, div_result_int   } |
                         {32{op_qual_lv1[`OP_SQRT]}} & {16'b0, sqrt_result[31:16]}|
                         {32{op_qual_lv1[`OP_COS ]}} & {16'b0, cos_result[31:16]} |
                         {32{op_qual_lv1[`OP_SIN ]}} & {16'b0, sin_result[31:16]} |
                         {32{op_qual_lv1[`OP_TAN ]}} & {16'b0, div_result_int   } |
                         {32{op_qual_lv1[`OP_POW ]}} & int_pwr_result             |
                         {32{op_qual_lv1[`OP_EXP ]}} & {16'b0, int_exp_result   } |
                         {32{op_qual_lv1[`OP_LOG ]}} & {24'b0, log_result[31:24]} ;

assign result_sign = op_qual_lv1[`OP_ADD ] & add_result_q[15] |
                     op_qual_lv1[`OP_SUB ] & sub_result_q[15] |
                     op_qual_lv1[`OP_MUL ] & mul_result_q[31] |
                     op_qual_lv1[`OP_DIV ] & div_sign         |
                     op_qual_lv1[`OP_SQRT] & 1'b0             |
                     op_qual_lv1[`OP_COS ] & cos_sign         |
                     op_qual_lv1[`OP_SIN ] & sin_sign         |
                     op_qual_lv1[`OP_TAN ] & div_sign         |
                     op_qual_lv1[`OP_POW ] & pwr_sign         |
                     op_qual_lv1[`OP_EXP ] & 1'b0             |
                     op_qual_lv1[`OP_LOG ] & 1'b0             ;

dflip_en #(32) int_result_ff  (.clk(clk), .rst(rst), .en(exe_done), .d(int_result_qual), .q(int_result_cvt_pre_q));

//overflow checking
assign div_invld_qual = div_invld & (op_qual_lv1[`OP_DIV]               | 
                                     op_qual_lv1[`OP_TAN]               | 
                                     op_qual_lv1[`OP_POW] & b_sign_qual |
                                     op_qual_lv1[`OP_EXP] & a_sign_qual );

assign invld_result = invld_input_lv1 |
                      div_invld_qual  | 
                      pwr_overflow    |
                      exp_overflow    ;//FIXME

//Convert binary to display value
assign cvt_cnt_rst = exe_done;
assign cvt_cnt_en = fsmc_in_convert | cvt_cnt_rst;
assign cvt_cnt = cvt_cnt_rst ? 5'b0000 : cvt_cnt_q + 4'b1;
dflip_en #(5) cvt_cnt_ff (.clk(clk), .rst(rst), .en(cvt_cnt_en), .d(cvt_cnt), .q(cvt_cnt_q));
assign cvt_done = &cvt_cnt_q;

assign bin2decdigit_init = ~(|cvt_cnt_q);
assign bin2decdigit_en = fsmc_in_convert;

//Interger side
bin2decdigit u_bin2decdigit_for_int(
    .clk(clk),
    .rst(rst),
    .bin2decdigit_init(bin2decdigit_init),
    .bin2decdigit_en(bin2decdigit_en),
    .input_bin(int_result_cvt_pre_q),
    .output_dec(int_dec_digit)
);

//fraction side
bin2decdigit u_bin2decdigit_for_frac(
    .clk(clk),
    .rst(rst),
    .bin2decdigit_init(bin2decdigit_init),
    .bin2decdigit_en(bin2decdigit_en),
    .input_bin(frac_dec_qual),
    .output_dec(frac_dec_digit)
);

//Display Set up
assign setup_lv0_en = fsmc_in_setup & init_cnt_q == 2'b00;
assign setup_lv1_en = fsmc_in_setup & init_cnt_q == 2'b01;
assign setup_lv2_en = fsmc_in_setup & init_cnt_q == 2'b10;
assign setup_lv3_en = fsmc_in_setup & init_cnt_q == 2'b11;

//Level 0
digit_shift u_digit_shift_for_int(
    .clk(clk),
    .rst(rst),
    .input_dec(int_dec_digit),
    .output_digits(int_digits_for_display),
    .digit_idx_is0(int_digits_idx_is0)
);

digit_shift u_digit_shift_for_frac(
    .clk(clk),
    .rst(rst),
    .input_dec(frac_dec_digit),
    .output_digits(frac_digits_for_display),
    .digit_idx_is0(frac_digits_idx_is0)
);

dflip_en #(40) int_digits_for_display_ff  (.clk(clk), .rst(rst), .en(setup_lv0_en), .d(int_digits_for_display ), .q(int_digits_for_display_lv1 ));
dflip_en #(40) frac_digits_for_display_ff (.clk(clk), .rst(rst), .en(setup_lv0_en), .d(frac_digits_for_display), .q(frac_digits_for_display_lv1));
dflip_en #(10) int_digits_idx_is0_ff      (.clk(clk), .rst(rst), .en(setup_lv0_en), .d(int_digits_idx_is0     ), .q(int_digits_idx_is0_lv1     ));
dflip_en #(10) frac_digits_idx_is0_ff     (.clk(clk), .rst(rst), .en(setup_lv0_en), .d(frac_digits_idx_is0    ), .q(frac_digits_idx_is0_lv1    ));

//Level 1
//display digit
assign int_part_is0 = &int_digits_idx_is0_lv1;
assign frac_part_is0 = &frac_digits_idx_is0_lv1;

//Add "." into display buffer
//Add shift digit to the leftest part if the leftest digits are 0
assign int_digits_add_dots[39:36] = int_digits_for_display_lv1[39:36];
assign int_digits_add_dots[35:32] = (~int_digits_idx_is0_lv1[9] & int_digits_idx_is0_lv1[8]) | int_part_is0 ? 4'hc : int_digits_for_display_lv1[35:32];
assign int_digits_add_dots[31:28] = ~int_digits_idx_is0_lv1[8] & int_digits_idx_is0_lv1[7] ? 4'hc : int_digits_for_display_lv1[31:28];
assign int_digits_add_dots[27:24] = ~int_digits_idx_is0_lv1[7] & int_digits_idx_is0_lv1[6] ? 4'hc : int_digits_for_display_lv1[27:24];
assign int_digits_add_dots[23:20] = ~int_digits_idx_is0_lv1[6] & int_digits_idx_is0_lv1[5] ? 4'hc : int_digits_for_display_lv1[23:20];
assign int_digits_add_dots[19:16] = ~int_digits_idx_is0_lv1[5] & int_digits_idx_is0_lv1[4] ? 4'hc : int_digits_for_display_lv1[19:16];
assign int_digits_add_dots[15:12] = ~int_digits_idx_is0_lv1[4] & int_digits_idx_is0_lv1[3] ? 4'hc : int_digits_for_display_lv1[15:12];
assign int_digits_add_dots[11:8 ] = ~int_digits_idx_is0_lv1[3] & int_digits_idx_is0_lv1[2] ? 4'hc : int_digits_for_display_lv1[11:8 ];
assign int_digits_add_dots[7:4  ] = ~int_digits_idx_is0_lv1[2] & int_digits_idx_is0_lv1[1] ? 4'hc : int_digits_for_display_lv1[7:4  ];
assign int_digits_add_dots[3:0  ] = ~int_digits_idx_is0_lv1[1] & int_digits_idx_is0_lv1[0] ? 4'ha : int_digits_for_display_lv1[3:0  ];

assign int_digits_idx_is0_non0int_adj = {10{(~int_digits_idx_is0_lv1[9] & int_digits_idx_is0_lv1[8]) | 
                                            (~int_digits_idx_is0_lv1[8] & int_digits_idx_is0_lv1[7]) | 
                                            (~int_digits_idx_is0_lv1[7] & int_digits_idx_is0_lv1[6]) | 
                                            (~int_digits_idx_is0_lv1[6] & int_digits_idx_is0_lv1[5]) | 
                                            (~int_digits_idx_is0_lv1[5] & int_digits_idx_is0_lv1[4]) | 
                                            (~int_digits_idx_is0_lv1[4] & int_digits_idx_is0_lv1[3]) | 
                                            (~int_digits_idx_is0_lv1[3] & int_digits_idx_is0_lv1[2]) | 
                                            (~int_digits_idx_is0_lv1[2] & int_digits_idx_is0_lv1[1]) }} & {1'b0, int_digits_idx_is0_lv1[9:1]} ;

assign int_digits_idx_is0_adj = int_part_is0 ? 10'b00_1111_1111 : int_digits_idx_is0_non0int_adj;

//mask out digit which outside 4 significant digits
assign frac_digits_for_display_adj = {frac_digits_for_display_lv1[39:24], {6{4'ha}}};

dflip_en #(40) int_digits_add_dots_ff            (.clk(clk), .rst(rst), .en(setup_lv1_en), .d(int_digits_add_dots            ), .q(int_digits_add_dots_lv2            ));
dflip_en #(40) frac_digits_for_display_adj_ff    (.clk(clk), .rst(rst), .en(setup_lv1_en), .d(frac_digits_for_display_adj    ), .q(frac_digits_for_display_adj_lv2    ));
dflip_en #(10) int_digits_idx_is0_non0int_adj_ff (.clk(clk), .rst(rst), .en(setup_lv1_en), .d(int_digits_idx_is0_non0int_adj ), .q(int_digits_idx_is0_non0int_adj_lv2 ));
dflip_en #(10) int_digits_idx_is0_adj_ff         (.clk(clk), .rst(rst), .en(setup_lv1_en), .d(int_digits_idx_is0_adj         ), .q(int_digits_idx_is0_adj_lv2         ));
dflip_en #(1)  int_part_is0_ff                   (.clk(clk), .rst(rst), .en(setup_lv1_en), .d(int_part_is0                   ), .q(int_part_is0_lv2                   ));
dflip_en #(1)  frac_part_is0_ff                  (.clk(clk), .rst(rst), .en(setup_lv1_en), .d(frac_part_is0                  ), .q(frac_part_is0_lv2                  ));

//Level 2
//shift fraction to correct side 
//0.0001 the lead0 number is 3 so need to move 12bit, because 4 bits for 1 digit display
assign frac_digits_for_display_shift_lead0 = frac_digits_for_display_adj_lv2 >> {lead0_num, 2'b00};
//shift fraction part base on integer digit and "."
assign frac_digits_for_display_align_non0int = ~(|int_digits_idx_is0_non0int_adj_lv2[9:0]) ? frac_digits_for_display_shift_lead0 :
                                               ~(|int_digits_idx_is0_non0int_adj_lv2[9:1]) ? frac_digits_for_display_shift_lead0 >> 36 :
                                               ~(|int_digits_idx_is0_non0int_adj_lv2[9:2]) ? frac_digits_for_display_shift_lead0 >> 32 :
                                               ~(|int_digits_idx_is0_non0int_adj_lv2[9:3]) ? frac_digits_for_display_shift_lead0 >> 28 :
                                               ~(|int_digits_idx_is0_non0int_adj_lv2[9:4]) ? frac_digits_for_display_shift_lead0 >> 24 :
                                               ~(|int_digits_idx_is0_non0int_adj_lv2[9:5]) ? frac_digits_for_display_shift_lead0 >> 20 :
                                               ~(|int_digits_idx_is0_non0int_adj_lv2[9:6]) ? frac_digits_for_display_shift_lead0 >> 16 :
                                               ~(|int_digits_idx_is0_non0int_adj_lv2[9:7]) ? frac_digits_for_display_shift_lead0 >> 12 :
                                               ~(|int_digits_idx_is0_non0int_adj_lv2[9:8]) ? frac_digits_for_display_shift_lead0 >> 8  : frac_digits_for_display_shift_lead0 >> 4;

assign frac_digits_for_display_align_int = int_part_is0_lv2 ? {8'b0, frac_digits_for_display_shift_lead0[39:8]} : frac_digits_for_display_align_non0int;

//Prepare mask for fraction 
assign mask_for_frac_part  = {{4{int_digits_idx_is0_adj[9]}}, 
                              {4{int_digits_idx_is0_adj[8]}}, 
                              {4{int_digits_idx_is0_adj[7]}}, 
                              {4{int_digits_idx_is0_adj[6]}}, 
                              {4{int_digits_idx_is0_adj[5]}}, 
                              {4{int_digits_idx_is0_adj[4]}}, 
                              {4{int_digits_idx_is0_adj[3]}}, 
                              {4{int_digits_idx_is0_adj[2]}}, 
                              {4{int_digits_idx_is0_adj[1]}}, 
                              {4{int_digits_idx_is0_adj[0]}}};
//Prepare mask for integer
assign mask_for_int_part = ~mask_for_frac_part;

//Combine integer and fraction
assign int_frac_digits_for_display = int_digits_add_dots_lv2 & mask_for_int_part | frac_digits_for_display_align_int & mask_for_frac_part;
dflip_en #(40) int_frac_digits_for_display_ff (.clk(clk), .rst(rst), .en(setup_lv2_en), .d(int_frac_digits_for_display), .q(int_frac_digits_for_display_lv3));

//Lv3
assign int_frac_digits_isa[8] = int_frac_digits_for_display_lv3[35:32] == 4'ha;
assign int_frac_digits_isa[7] = int_frac_digits_for_display_lv3[31:28] == 4'ha;
assign int_frac_digits_isa[6] = int_frac_digits_for_display_lv3[27:24] == 4'ha;
assign int_frac_digits_isa[5] = int_frac_digits_for_display_lv3[23:20] == 4'ha;
assign int_frac_digits_isa[4] = int_frac_digits_for_display_lv3[19:16] == 4'ha;
assign int_frac_digits_isa[3] = int_frac_digits_for_display_lv3[15:12] == 4'ha;
assign int_frac_digits_isa[2] = int_frac_digits_for_display_lv3[11:8 ] == 4'ha;

//Display Digit Selection
assign output_digits_for_display = int_result_op | frac_part_is0_lv2 ? int_digits_for_display_lv1 : int_frac_digits_for_display_lv3;
dflip_en #(40) output_digits_for_display_ff (.clk(clk), .rst(rst), .en(setup_lv3_en), .d(output_digits_for_display), .q(output_digits_for_display_lv4));

//Shift the digit to for different stage
assign output_digits_for_display_st2 = {output_digits_for_display_lv4[27:12]};
assign output_digits_for_display_st3 = {output_digits_for_display_lv4[11:0], 4'ha};

assign output_digit0_for_st1 = output_digits_for_display_lv4[31:28];
assign output_digit1_for_st1 = output_digits_for_display_lv4[35:32];
assign output_digit2_for_st1 = output_digits_for_display_lv4[39:36];

assign output_sign_for_st2   = output_digits_for_display_st2[15:12];
assign output_digit2_for_st2 = output_digits_for_display_st2[11:8];
assign output_digit1_for_st2 = output_digits_for_display_st2[7:4];
assign output_digit0_for_st2 = output_digits_for_display_st2[3:0];

assign output_sign_for_st3   = output_digits_for_display_st3[15:12];
assign output_digit2_for_st3 = output_digits_for_display_st3[11:8];
assign output_digit1_for_st3 = output_digits_for_display_st3[7:4];
assign output_digit0_for_st3 = output_digits_for_display_st3[3:0];

//Display stage
//More than 7 digit need to use 3 stages to dispaly
//4-7 digit need to use 2 stages to dispaly
//3 digit need to use 1 stages to dispaly
assign int_stage_final = |int_digits_idx_is0[9:6] ? 3'b01 :
                         |int_digits_idx_is0[5:2] ? 3'b10 : 3'b11;

assign frac_stage_final = |int_frac_digits_isa[8:6] ? 3'b01 :
                          |int_frac_digits_isa[5:2] ? 3'b10 : 3'b11;
//choose integer digit if integer result
assign total_disp_stage_pre = int_result_op ?  int_stage_final : frac_stage_final;

//press mid to next display stage
assign display_stage_en = fsmc_in_display & button_mid & ~display_last_stage | fsmc_in_setup;
//reset display stage in dispaly setup
//else display stage + 1
assign display_stage = fsmc_in_setup ? 3'b0 : display_stage_q + 1'b1;
//Check if it is last stage 
//if invld result, it will move to the last stage
assign display_last_stage = (display_stage == total_disp_stage_pre) | invld_result;
dflip_en #(`DISP_STG_WIDTH) display_stage_ff (.clk(clk), .rst(rst), .en(display_stage_en), .d(display_stage), .q(display_stage_q));

//display stage LED, display in board
assign cal_board_display_stage = {`DISP_STG_WIDTH{fsmc_in_display}} & (total_disp_stage_pre - display_stage_q);

endmodule
