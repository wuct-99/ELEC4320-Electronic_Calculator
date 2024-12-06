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
input [`BUTTON_WIDTH - 1:0] board_cal_button;
input [14:0] board_cal_switchs;
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
wire a_sign;
wire [`DIGIT_WIDTH - 1 : 0] b_digit0;
wire [`DIGIT_WIDTH - 1 : 0] b_digit1;
wire [`DIGIT_WIDTH - 1 : 0] b_digit2;
wire b_sign;
wire a_digit_en;
wire b_digit_en;

//7-segment driver
wire [1:0] digit_cnt_d;
wire [1:0] digit_cnt_q;
wire digit_cnt_en;
wire digit_cnt_rst;
wire [`DIGIT_WIDTH- 1:0] digit_val;
wire [`DIGIT_WIDTH -1:0] input_digit_curr;

wire [`DIGIT_WIDTH -1:0] output_int_lv0;
wire [`DIGIT_WIDTH -1:0] output_int_lv1;
wire [`DIGIT_WIDTH -1:0] output_int_lv2;


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
wire signed [`RESULT_WIDTH-1:0] sign_inputa; 
wire signed [`RESULT_WIDTH-1:0] sign_inputb;
wire signed [`RESULT_WIDTH-1:0] inputa; 
wire signed [`RESULT_WIDTH-1:0] inputb;
wire [31:0] inputa_754; 
wire [31:0] inputb_754;

//switch
wire switch_en;
wire [`SWITCH_WIDTH - 1:0] switchs_in_exe;
//exe op
wire [`SWITCH_WIDTH - 1:0] op_qual;
wire int_result_op;
wire single_cyc_op;
wire multi_cyc_op;
//exe
wire signed [`RESULT_WIDTH-1:0] add_result;
wire signed [`RESULT_WIDTH-1:0] sub_result;
wire signed [31:0] mul_result;
//result
wire exe_pre_done;
wire cvt_done;


wire overflow;
wire signed [31:0] result_qual;
wire signed [31:0] result_cvt_pre;
wire signed [31:0] result_cvt_pre_q;
wire invld_result;
wire invld_input;
wire invld_div;
wire invld_sqrt;
wire invld_op;

//binary to decimal
wire [4:0] cvt_cnt;
wire [4:0] cvt_cnt_q;
wire cvt_cnt_en;
wire cvt_cnt_rst;

wire result_sign;
//wire [3:0] int_digit_9_for_display;
//wire [3:0] int_digit_8_for_display;
//wire [3:0] int_digit_7_for_display;
wire [3:0] output_digit9_for_display;
wire [3:0] output_digit8_for_display;
wire [3:0] output_digit7_for_display;

//wire [3:0] int_sign_for_lv1;
//wire [3:0] int_digit2_for_lv1;
//wire [3:0] int_digit1_for_lv1;
//wire [3:0] int_digit0_for_lv1;
//wire [3:0] int_sign_for_lv2;
//wire [3:0] int_digit2_for_lv2;
//wire [3:0] int_digit1_for_lv2;
//wire [3:0] int_digit0_for_lv2;
wire [3:0] output_sign_for_lv1;
wire [3:0] output_digit2_for_lv1;
wire [3:0] output_digit1_for_lv1;
wire [3:0] output_digit0_for_lv1;
wire [3:0] output_sign_for_lv2;
wire [3:0] output_digit2_for_lv2;
wire [3:0] output_digit1_for_lv2;
wire [3:0] output_digit0_for_lv2;

//display stage
wire [`DISP_STG_WIDTH-1:0] total_disp_stage_pre;
wire [2:0] int_stage_final; 
wire [2:0] frac_stage_final; 


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

//display dlk
assign clk_display_cnt_d = clk_display_cnt_q + 2'b01;
dflip #(10) clk_display_cnt_ff (.clk(clk), .rst(rst), .d(clk_display_cnt_d), .q(clk_display_cnt_q));

assign clk_display_en = &clk_display_cnt_q;
assign clk_display_state_d = ~clk_display_state_q;
dflip_en #(1) clk_display_state_ff (.clk(clk), .rst(rst), .en(clk_display_en), .d(clk_display_state_d), .q(clk_display_state_q));
assign clk_display = clk_display_state_q;

//debouncing 
debounce #(`BUTTON_WIDTH) button_debounce (.clk(clk), .rst(rst), .data_in(board_cal_button), .data_out(debounce_button));

//button decode
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


//FSMC
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
assign fsmc_in_convert = fsmc_curr_state[4];
assign fsmc_in_setup   = fsmc_curr_state[5];
assign fsmc_in_display = fsmc_curr_state[6];

assign fsmc_idle_to_inputa     = fsmc_in_idle   ;
assign fsmc_inputa_to_inputb   = fsmc_in_inputa  & button_mid;
assign fsmc_inputb_to_exe      = fsmc_in_inputb  & button_mid;
assign fsmc_exe_to_convert     = fsmc_in_exe     & exe_pre_done;
assign fsmc_convert_to_setup   = fsmc_in_convert & cvt_done; //FIXME
assign fsmc_setup_to_display   = fsmc_in_setup; 
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

//FSMIN
assign fsmin_in_idle   = fsmin_curr_state[0];
assign fsmin_in_digit0 = fsmin_curr_state[1];
assign fsmin_in_digit1 = fsmin_curr_state[2];
assign fsmin_in_digit2 = fsmin_curr_state[3];
assign fsmin_in_sign   = fsmin_curr_state[4];

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
assign digit0_en = (fsmin_in_digit0 & (button_up | button_down)) | fsmin_state_rst;
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

assign sign_en = (fsmin_in_sign & (button_up | button_down)) | fsmin_state_rst;
assign sign_d = fsmin_state_rst ? 4'b0000 : sign_q + 1'b1;
dflip_en sign_ff (.clk(clk), .rst(rst), .en(sign_en), .d(sign_d), .q(sign_q));

//Save input a/b
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


//7-segment 
assign digit_cnt_rst = fsmc_next_inputa | fsmc_next_inputb | fsmc_next_exe | fsmc_next_display; 
assign digit_cnt_en = fsmc_in_inputa | fsmc_in_inputb | fsmc_in_display & ~invld_result | digit_cnt_rst;
assign digit_cnt_d = digit_cnt_rst ? 2'b00 : digit_cnt_q + 2'b01;

//digit 0 > digit 1 > digit2 > sign
dflip_en #(2) digit_cnt_ff (.clk(clk_display), .rst(rst), .en(digit_cnt_en), .d(digit_cnt_d), .q(digit_cnt_q));

wire digit_cnt_id0;
wire digit_cnt_id1;
wire digit_cnt_id2;
wire digit_cnt_id3;

assign digit_cnt_id0 = digit_cnt_q == 2'b00;
assign digit_cnt_id1 = digit_cnt_q == 2'b01;
assign digit_cnt_id2 = digit_cnt_q == 2'b10;
assign digit_cnt_id3 = digit_cnt_q == 2'b11;

assign cal_board_digit_ctrl = {`DIGIT_WIDTH{digit_cnt_id0}} & `DIGIT_WIDTH'b1110 |
                              {`DIGIT_WIDTH{digit_cnt_id1}} & `DIGIT_WIDTH'b1101 |
                              {`DIGIT_WIDTH{digit_cnt_id2}} & `DIGIT_WIDTH'b1011 |
                              {`DIGIT_WIDTH{digit_cnt_id3}} & `DIGIT_WIDTH'b0111 | 
                              {`DIGIT_WIDTH{~digit_cnt_en | invld_result & fsmc_in_display}} & `DIGIT_WIDTH'b1111 ;

assign input_digit_curr = {`DIGIT_WIDTH{digit_cnt_id0}} & digit0_q |
                          {`DIGIT_WIDTH{digit_cnt_id1}} & digit1_q |
                          {`DIGIT_WIDTH{digit_cnt_id2}} & digit2_q |
                          {`DIGIT_WIDTH{digit_cnt_id3}} & {3'b101, sign_q} ;

assign output_int_lv0 = {`DIGIT_WIDTH{digit_cnt_id0}} & output_digit7_for_display |
                        {`DIGIT_WIDTH{digit_cnt_id1}} & output_digit8_for_display |
                        {`DIGIT_WIDTH{digit_cnt_id2}} & output_digit9_for_display |
                        {`DIGIT_WIDTH{digit_cnt_id3}} & {3'b101, result_sign}   ;

assign output_int_lv1 = {`DIGIT_WIDTH{digit_cnt_id0}} & output_digit0_for_lv1 |
                        {`DIGIT_WIDTH{digit_cnt_id1}} & output_digit1_for_lv1 |
                        {`DIGIT_WIDTH{digit_cnt_id2}} & output_digit2_for_lv1 |
                        {`DIGIT_WIDTH{digit_cnt_id3}} & output_sign_for_lv1 ;

assign output_int_lv2 = {`DIGIT_WIDTH{digit_cnt_id0}} & output_digit0_for_lv2 |
                        {`DIGIT_WIDTH{digit_cnt_id1}} & output_digit1_for_lv2 |
                        {`DIGIT_WIDTH{digit_cnt_id2}} & output_digit2_for_lv2 |
                        {`DIGIT_WIDTH{digit_cnt_id3}} & output_sign_for_lv2 ;

assign digit_val = (fsmc_in_inputa | fsmc_in_inputb) ? input_digit_curr : 
                   (fsmc_in_display & (display_stage_q == 3'b00)) ? output_int_lv0 :
                   (fsmc_in_display & (display_stage_q == 3'b01)) ? output_int_lv1 : 
                   (fsmc_in_display & (display_stage_q == 3'b11)) ? output_int_lv2 : 4'ha;


//7-segment Ouput decoder
assign cal_board_digit_seg = {8{digit_val == `DIGIT_WIDTH'h0}} & 8'b0000_0011 |         
                             {8{digit_val == `DIGIT_WIDTH'h1}} & 8'b1001_1111 |         
                             {8{digit_val == `DIGIT_WIDTH'h2}} & 8'b0010_0101 |         
                             {8{digit_val == `DIGIT_WIDTH'h3}} & 8'b0000_1101 |         
                             {8{digit_val == `DIGIT_WIDTH'h4}} & 8'b1001_1001 |         
                             {8{digit_val == `DIGIT_WIDTH'h5}} & 8'b0100_1001 |         
                             {8{digit_val == `DIGIT_WIDTH'h6}} & 8'b0100_0001 |         
                             {8{digit_val == `DIGIT_WIDTH'h7}} & 8'b0001_1111 |         
                             {8{digit_val == `DIGIT_WIDTH'h8}} & 8'b0000_0001 |         
                             {8{digit_val == `DIGIT_WIDTH'h9}} & 8'b0001_1001 |         
                             {8{digit_val == `DIGIT_WIDTH'ha}} & 8'b1111_1111 | // None 
                             {8{digit_val == `DIGIT_WIDTH'hb}} & 8'b1111_1101 | // "-"; 
                             {8{digit_val == `DIGIT_WIDTH'hc}} & 8'b1111_1110 ; // "."  


//Operation decode
assign switch_en = fsmc_next_exe;
dflip_en #(`SWITCH_WIDTH) switch_ff (.clk(clk), .rst(rst), .en(switch_en), .d(board_cal_switchs), .q(switchs_in_exe));

//In Executioin Stage: D0
assign op_qual[`OP_ADD ] = switchs_in_exe[`OP_ADD ] ;
assign op_qual[`OP_SUB ] = switchs_in_exe[`OP_SUB ] & ~switchs_in_exe[0];
assign op_qual[`OP_MUL ] = switchs_in_exe[`OP_MUL ] & ~(|switchs_in_exe[1:0] );
assign op_qual[`OP_DIV ] = switchs_in_exe[`OP_DIV ] & ~(|switchs_in_exe[2:0] );
assign op_qual[`OP_SQRT] = switchs_in_exe[`OP_SQRT] & ~(|switchs_in_exe[3:0] );
assign op_qual[`OP_COS ] = switchs_in_exe[`OP_COS ] & ~(|switchs_in_exe[4:0] );
assign op_qual[`OP_SIN ] = switchs_in_exe[`OP_SIN ] & ~(|switchs_in_exe[5:0] );
assign op_qual[`OP_TAN ] = switchs_in_exe[`OP_TAN ] & ~(|switchs_in_exe[6:0] );
assign op_qual[`OP_ACOS] = switchs_in_exe[`OP_ACOS] & ~(|switchs_in_exe[7:0] );
assign op_qual[`OP_ASIN] = switchs_in_exe[`OP_ASIN] & ~(|switchs_in_exe[8:0] );
assign op_qual[`OP_ATAN] = switchs_in_exe[`OP_ATAN] & ~(|switchs_in_exe[9:0] );
assign op_qual[`OP_LOG ] = switchs_in_exe[`OP_LOG ] & ~(|switchs_in_exe[10:0]);
assign op_qual[`OP_POW ] = switchs_in_exe[`OP_POW ] & ~(|switchs_in_exe[11:0]);
assign op_qual[`OP_EXP ] = switchs_in_exe[`OP_EXP ] & ~(|switchs_in_exe[12:0]);
assign op_qual[`OP_FACT] = switchs_in_exe[`OP_FACT] & ~(|switchs_in_exe[13:0]);

assign int_result_op = op_qual[`OP_ADD] | op_qual[`OP_SUB] | op_qual[`OP_MUL];

assign single_cyc_op = op_qual[`OP_ADD] |
                       op_qual[`OP_SUB] |
                       op_qual[`OP_MUL] ;
assign multi_cyc_op = op_qual[`OP_DIV];


//init counter
wire init_cnt_rst;
wire [1:0] init_cnt_d;
wire [1:0] init_cnt_q;
wire init_cnt_en;

//assign init_cnt_rst = fsme_next_init; 
//assign init_cnt_d = init_cnt_rst ? 2'b00 : init_cnt_q + 2'b01;
//assign init_cnt_en = fsme_in_init | init_cnt_rst;
//dflip_en #(2) init_cnt_ff (.clk(clk), .rst(rst), .en(init_cnt_en), .d(init_cnt_d), .q(init_cnt_q));
//assign init_cnt_rst = fsme_next_init ; 
assign init_cnt_d = init_cnt_q + 2'b01;
assign init_cnt_en = fsme_in_init | fsme_in_done;
dflip_en #(2) init_cnt_ff (.clk(clk), .rst(rst), .en(init_cnt_en), .d(init_cnt_d), .q(init_cnt_q));

wire init_done;
assign init_done = &init_cnt_q;

dec2bin u_dec2bin_a(.clk(clk),
                    .rst(rst),
                    .init_cnt_q(init_cnt_q),
                    .digit0(a_digit0),
                    .digit1(a_digit1),
                    .digit2(a_digit2),
                    .digit_sign(a_sign),
                    .unsign_dec(unsign_inputa),
                    .sign_dec(sign_inputa),
                    .input_qual(inputa),
                    .i754_dec(inputa_754)
);

dec2bin u_dec2bin_b(.clk(clk),
                    .rst(rst),
                    .init_cnt_q(init_cnt_q),
                    .digit0(b_digit0),
                    .digit1(b_digit1),
                    .digit2(b_digit2),
                    .digit_sign(b_sign),
                    .unsign_dec(unsign_inputb),
                    .sign_dec(sign_inputb),
                    .input_qual(inputb),
                    .i754_dec(inputb_754)
);


//Check input constraint
assign invld_div  = op_qual[`OP_DIV ] & ~(|inputb); 
assign invld_sqrt = op_qual[`OP_SQRT] & a_sign;     

assign invld_op   = ~(|op_qual);     
assign invld_input = invld_div  |
                     invld_sqrt |
                     invld_op   ;

//FSME
assign fsme_in_idle   = fsme_curr_state[0];
assign fsme_in_init   = fsme_curr_state[1];
assign fsme_in_single = fsme_curr_state[2];
assign fsme_in_multi  = fsme_curr_state[3];
assign fsme_in_done   = fsme_curr_state[4];

wire div_done;

assign fsme_idle_to_init   = fsme_in_idle   & fsmc_in_exe;
assign fsme_init_to_single = fsme_in_init   & ~invld_input & single_cyc_op & init_done;
assign fsme_init_to_multi  = fsme_in_init   & ~invld_input & multi_cyc_op  & init_done;
assign fsme_init_to_done   = fsme_in_init   & invld_input & init_done;
assign fsme_single_to_done = fsme_in_single ;
assign fsme_multi_to_done  = fsme_in_multi  & div_done; //FIXME
assign fsme_done_to_idle   = fsme_in_done   & (int_result_op | init_done);

assign fsme_next_state = {`FSME_STATE_WIDTH{fsme_idle_to_init  }} & `FSME_INIT   |
                         {`FSME_STATE_WIDTH{fsme_init_to_single}} & `FSME_SINGLE |
                         {`FSME_STATE_WIDTH{fsme_init_to_multi }} & `FSME_MULTI  |
                         {`FSME_STATE_WIDTH{fsme_init_to_done  }} & `FSME_DONE   |
                         {`FSME_STATE_WIDTH{fsme_single_to_done}} & `FSME_DONE   |
                         {`FSME_STATE_WIDTH{fsme_multi_to_done }} & `FSME_DONE   |
                         {`FSME_STATE_WIDTH{fsme_done_to_idle  }} & `FSME_IDLE   ;

assign fsme_state_upd = fsme_idle_to_init   |
                        fsme_init_to_single |
                        fsme_init_to_multi  |
                        fsme_init_to_done   |
                        fsme_single_to_done |
                        fsme_multi_to_done  |
                        fsme_done_to_idle   ;

assign fsme_next_idle = fsme_next_state[0];
assign fsme_next_init = fsme_next_state[1];
assign fsme_next_done = fsme_next_state[4];

dflip_en #(`FSME_STATE_WIDTH, `FSME_STATE_WIDTH'h1) fsme_state_ff (.clk(clk), 
                                                                   .rst(rst), 
                                                                   .en(fsme_state_upd), 
                                                                   .d(fsme_next_state), 
                                                                   .q(fsme_curr_state));

assign exe_pre_done = fsme_next_idle;

//single cyc execute
assign add_result = inputa + inputb;
assign sub_result = inputa - inputb;
assign mul_result = inputa * inputb;

wire [`RESULT_WIDTH-1:0] add_result_q;
wire [`RESULT_WIDTH-1:0] sub_result_q;
wire [31:0] mul_result_q;
wire add_result_en;
wire sub_result_en;
wire mul_result_en;

assign add_result_en = fsme_in_single & op_qual[`OP_ADD];
assign sub_result_en = fsme_in_single & op_qual[`OP_SUB];
assign mul_result_en = fsme_in_single & op_qual[`OP_MUL];

dflip_en #(`RESULT_WIDTH) add_result_ff (.clk(clk), .rst(rst), .en(add_result_en), .d(add_result), .q(add_result_q));
dflip_en #(`RESULT_WIDTH) sub_result_ff (.clk(clk), .rst(rst), .en(sub_result_en), .d(sub_result), .q(sub_result_q));
dflip_en #(32)            mul_result_ff (.clk(clk), .rst(rst), .en(mul_result_en), .d(mul_result), .q(mul_result_q));

wire [31:0] div_result_754;
//Multi cycle execute
divider u_divider(.clk(clk), 
                  .rst(rst),
                  .div_start(fsme_in_multi & op_qual[`OP_DIV]),
                  .inputa_754(inputa_754),
                  .inputb_754(inputb_754),
                  .div_result_754(div_result_754), 
                  .div_done(div_done)
);

wire [31:0] frac_dec_qual;
wire [31:0] int_dec_qual     ;
wire [2:0] lead0_num        ;
wire i754_overflow;

frac2int u_frac2int(
    .clk(clk),
    .rst(rst),
    .cvt_cnt_q(init_cnt_q),
    .input_754(div_result_754),
    .fraction_dec_qual(frac_dec_qual),
    .int_dec_qual     (int_dec_qual ),
    .lead0_num        (lead0_num    ),
    .i754_overflow(i754_overflow)
);


//result
assign result_qual = {32{op_qual[`OP_ADD]}} & {{16{add_result_q[15]}}, add_result_q} |
                     {32{op_qual[`OP_SUB]}} & {{16{sub_result_q[15]}}, sub_result_q} |
                     {32{op_qual[`OP_MUL]}} & mul_result_q                         |
                     {32{op_qual[`OP_DIV]}} & int_dec_qual                         ;

assign result_sign = result_qual[31];

assign result_cvt_pre = result_qual[31] ? ~result_qual + 32'b1 : result_qual;
assign result_cvt_pre_en = fsme_next_idle;
dflip_en #(32) result_ff (.clk(clk), .rst(rst), .en(result_cvt_pre_en), .d(result_cvt_pre), .q(result_cvt_pre_q));

//overflow checking
wire div_overflow;
assign div_overflow = op_qual[`OP_DIV] & i754_overflow; 
assign overflow = 0;//mul_overflow;
assign invld_result = invld_input | overflow | div_overflow;

//Convert Stage
assign cvt_cnt_rst = exe_pre_done;
assign cvt_cnt_en = fsmc_in_convert | cvt_cnt_rst;
assign cvt_cnt = cvt_cnt_rst ? 5'b0000 : cvt_cnt_q + 4'b1;
dflip_en #(5) cvt_cnt_ff (.clk(clk), .rst(rst), .en(cvt_cnt_en), .d(cvt_cnt), .q(cvt_cnt_q));
assign cvt_done = &cvt_cnt_q;

wire bin2decdigit_init;
wire bin2decdigit_en;
assign bin2decdigit_init = ~(|cvt_cnt_q);
assign bin2decdigit_en = fsmc_in_convert;

wire [39:0] int_dec_digit;
wire [39:0] frac_dec_digit;
bin2decdigit u_bin2decdigit_for_int(
    .clk(clk),
    .rst(rst),
    .bin2decdigit_init(bin2decdigit_init),
    .bin2decdigit_en(bin2decdigit_en),
    .input_bin(result_cvt_pre_q),
    .output_dec(int_dec_digit)
);

bin2decdigit u_bin2decdigit_for_frac(
    .clk(clk),
    .rst(rst),
    .bin2decdigit_init(bin2decdigit_init),
    .bin2decdigit_en(bin2decdigit_en),
    .input_bin(frac_dec_qual),
    .output_dec(frac_dec_digit)
);

//Set up Stage
wire [39:0] int_digits_for_display;
wire [39:0] frac_digits_for_display;
wire [9:0] int_digits_idx_is0;
wire signed [9:0] frac_digits_idx_is0;

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


//display digit
//display frac
wire int_part_is0;
wire frac_part_is0;
assign int_part_is0 = &int_digits_idx_is0;
assign frac_part_is0 = &frac_digits_idx_is0;


wire [39:0] int_digits_add_dots;
assign int_digits_add_dots[39:36] = int_digits_for_display[39:36];
assign int_digits_add_dots[35:32] = (~int_digits_idx_is0[9] & int_digits_idx_is0[8]) | int_part_is0 ? 4'hc : int_digits_for_display[35:32];
assign int_digits_add_dots[31:28] = ~int_digits_idx_is0[8] & int_digits_idx_is0[7] ? 4'hc : int_digits_for_display[31:28];
assign int_digits_add_dots[27:24] = ~int_digits_idx_is0[7] & int_digits_idx_is0[6] ? 4'hc : int_digits_for_display[27:24];
assign int_digits_add_dots[23:20] = ~int_digits_idx_is0[6] & int_digits_idx_is0[5] ? 4'hc : int_digits_for_display[23:20];
assign int_digits_add_dots[19:16] = ~int_digits_idx_is0[5] & int_digits_idx_is0[4] ? 4'hc : int_digits_for_display[19:16];
assign int_digits_add_dots[15:12] = ~int_digits_idx_is0[4] & int_digits_idx_is0[3] ? 4'hc : int_digits_for_display[15:12];
assign int_digits_add_dots[11:8 ] = ~int_digits_idx_is0[3] & int_digits_idx_is0[2] ? 4'hc : int_digits_for_display[11:8 ];
assign int_digits_add_dots[7:4  ] = ~int_digits_idx_is0[2] & int_digits_idx_is0[1] ? 4'hc : int_digits_for_display[7:4  ];
assign int_digits_add_dots[3:0  ] = ~int_digits_idx_is0[1] & int_digits_idx_is0[0] ? 4'ha : int_digits_for_display[3:0  ];

wire [9:0] int_digits_idx_is0_non0int_adj;
assign int_digits_idx_is0_non0int_adj = {10{(~int_digits_idx_is0[9] & int_digits_idx_is0[8]) | 
                                            (~int_digits_idx_is0[8] & int_digits_idx_is0[7]) | 
                                            (~int_digits_idx_is0[7] & int_digits_idx_is0[6]) | 
                                            (~int_digits_idx_is0[6] & int_digits_idx_is0[5]) | 
                                            (~int_digits_idx_is0[5] & int_digits_idx_is0[4]) | 
                                            (~int_digits_idx_is0[4] & int_digits_idx_is0[3]) | 
                                            (~int_digits_idx_is0[3] & int_digits_idx_is0[2]) | 
                                            (~int_digits_idx_is0[2] & int_digits_idx_is0[1]) }} & {1'b0, int_digits_idx_is0[9:1]} ;
wire [9:0] int_digits_idx_is0_adj;
assign int_digits_idx_is0_adj = int_part_is0 ? 10'b00_1111_1111 : int_digits_idx_is0_non0int_adj;

wire [39:0] frac_digits_for_display_adj;
assign frac_digits_for_display_adj = {frac_digits_for_display[39:20], {5{4'ha}}};

wire [39:0] frac_digits_for_display_shift_lead0;
//assign frac_digits_for_display_shift_lead0 = frac_part_is0 ? {40'h00_0aaa_aaaa} : frac_digits_for_display_adj >> {lead0_num, 2'b00};
assign frac_digits_for_display_shift_lead0 = frac_digits_for_display_adj >> {lead0_num, 2'b00};

wire [39:0] frac_digits_for_display_align_non0int;
assign frac_digits_for_display_align_non0int = ~(|int_digits_idx_is0_non0int_adj[9:0]) ? frac_digits_for_display_shift_lead0 :
                                               ~(|int_digits_idx_is0_non0int_adj[9:1]) ? frac_digits_for_display_shift_lead0 >> 36 :
                                               ~(|int_digits_idx_is0_non0int_adj[9:2]) ? frac_digits_for_display_shift_lead0 >> 32 :
                                               ~(|int_digits_idx_is0_non0int_adj[9:3]) ? frac_digits_for_display_shift_lead0 >> 28 :
                                               ~(|int_digits_idx_is0_non0int_adj[9:4]) ? frac_digits_for_display_shift_lead0 >> 24 :
                                               ~(|int_digits_idx_is0_non0int_adj[9:5]) ? frac_digits_for_display_shift_lead0 >> 20 :
                                               ~(|int_digits_idx_is0_non0int_adj[9:6]) ? frac_digits_for_display_shift_lead0 >> 16 :
                                               ~(|int_digits_idx_is0_non0int_adj[9:7]) ? frac_digits_for_display_shift_lead0 >> 12 :
                                               ~(|int_digits_idx_is0_non0int_adj[9:8]) ? frac_digits_for_display_shift_lead0 >> 8  : frac_digits_for_display_shift_lead0 >> 4;

wire [39:0] frac_digits_for_display_align_int;
assign frac_digits_for_display_align_int = int_part_is0 ? {8'b0, frac_digits_for_display_shift_lead0[39:8]} : frac_digits_for_display_align_non0int;

wire [39:0] mask_for_int_part;
wire [39:0] mask_for_frac_part;

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
assign mask_for_int_part = ~mask_for_frac_part;

wire [39:0] int_frac_digits_for_display;
assign int_frac_digits_for_display = int_digits_add_dots & mask_for_int_part | frac_digits_for_display_align_int & mask_for_frac_part;

//wire [8:0] int_frac_digits_isa;
wire [8:2] int_frac_digits_isa;

assign int_frac_digits_isa[8] = int_frac_digits_for_display[35:32] == 4'ha;
assign int_frac_digits_isa[7] = int_frac_digits_for_display[31:28] == 4'ha;
assign int_frac_digits_isa[6] = int_frac_digits_for_display[27:24] == 4'ha;
assign int_frac_digits_isa[5] = int_frac_digits_for_display[23:20] == 4'ha;
assign int_frac_digits_isa[4] = int_frac_digits_for_display[19:16] == 4'ha;
assign int_frac_digits_isa[3] = int_frac_digits_for_display[15:12] == 4'ha;
assign int_frac_digits_isa[2] = int_frac_digits_for_display[11:8 ] == 4'ha;
//assign int_frac_digits_isa[1] = int_frac_digits_for_display[7:4  ] == 4'ha;
//assign int_frac_digits_isa[0] = int_frac_digits_for_display[3:0  ] == 4'ha;

//Display Digit Selection
wire [39:0] output_digits_for_display;
assign output_digits_for_display = int_result_op | frac_part_is0 ? int_digits_for_display : int_frac_digits_for_display;

assign output_digit7_for_display = output_digits_for_display[31:28];
assign output_digit8_for_display = output_digits_for_display[35:32];
assign output_digit9_for_display = output_digits_for_display[39:36];

wire [15:0] output_digits_for_display_lv1;
wire [15:0] output_digits_for_display_lv2;

assign output_digits_for_display_lv1 = {output_digits_for_display[27:12]};
assign output_digits_for_display_lv2 = {output_digits_for_display[11:0], 4'ha};

assign output_sign_for_lv1   = output_digits_for_display_lv1[15:12];
assign output_digit2_for_lv1 = output_digits_for_display_lv1[11:8];
assign output_digit1_for_lv1 = output_digits_for_display_lv1[7:4];
assign output_digit0_for_lv1 = output_digits_for_display_lv1[3:0];

assign output_sign_for_lv2   = output_digits_for_display_lv2[15:12];
assign output_digit2_for_lv2 = output_digits_for_display_lv2[11:8];
assign output_digit1_for_lv2 = output_digits_for_display_lv2[7:4];
assign output_digit0_for_lv2 = output_digits_for_display_lv2[3:0];

assign int_stage_final = |int_digits_idx_is0[9:6] ? 3'b01 :
                         |int_digits_idx_is0[5:2] ? 3'b10 : 3'b11;

assign frac_stage_final = |int_frac_digits_isa[8:6] ? 3'b01 :
                          |int_frac_digits_isa[5:2] ? 3'b10 : 3'b11;

assign total_disp_stage_pre = int_result_op ?  int_stage_final : frac_stage_final;

assign display_stage_en = fsmc_in_display & button_mid & ~display_last_stage | fsmc_in_setup;
assign display_stage = fsmc_in_setup ? 3'b0 : display_stage_q + 1'b1;
assign display_last_stage = (display_stage == total_disp_stage_pre) | invld_result;

dflip_en #(`DISP_STG_WIDTH) display_stage_ff (.clk(clk), .rst(rst), .en(display_stage_en), .d(display_stage), .q(display_stage_q));
assign cal_board_display_stage = display_stage_q + 3'b1;

endmodule
