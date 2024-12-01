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
//7-segment driver
wire [1:0] digit_cnt_d;
wire [1:0] digit_cnt_q;
wire digit_cnt_en;
wire digit_cnt_rst;
wire [`DIGIT_WIDTH- 1:0] digit_val;
wire [`DIGIT_WIDTH -1:0] input_digit_curr;
wire [`DIGIT_WIDTH -1:0] output_int_4digit;
wire [`DIGIT_WIDTH -1:0] output_int_remain;
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
wire fsmc_next_convert;
wire fsmc_next_setup  ;
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

wire [`RESULT_WIDTH-1:0] a_digit0_sl0;
wire [`RESULT_WIDTH-1:0] a_digit1_sl3;
wire [`RESULT_WIDTH-1:0] a_digit1_sl1;
wire [`RESULT_WIDTH-1:0] a_digit2_sl6;
wire [`RESULT_WIDTH-1:0] a_digit2_sl5;
wire [`RESULT_WIDTH-1:0] a_digit2_sl2;
wire [`RESULT_WIDTH-1:0] b_digit0_sl0;
wire [`RESULT_WIDTH-1:0] b_digit1_sl3;
wire [`RESULT_WIDTH-1:0] b_digit1_sl1;
wire [`RESULT_WIDTH-1:0] b_digit2_sl6;
wire [`RESULT_WIDTH-1:0] b_digit2_sl5;
wire [`RESULT_WIDTH-1:0] b_digit2_sl2;
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
wire signed [`RESULT_WIDTH-1:0] mul_result;
wire signed [`RESULT_WIDTH-1:0] div_result;
//result
wire exe_pre_done;
wire cvt_done;
wire overflow = 1'b0; //FIXME
wire signed [`RESULT_WIDTH-1:0] result_qual;
wire signed [`RESULT_WIDTH-1:0] result_cvt_pre;
wire invld_result;
wire invld_input;
wire invld_div;
wire invld_sqrt;
wire invld_op;

//binary to decimal
wire [3:0] cvt_cnt;
wire [3:0] cvt_cnt_q;
wire cvt_cnt_en;
wire cvt_cnt_rst;
wire [35:0] dec_digit;
wire [35:0] dec_digit_shift;
wire [35:0] dec_digit_q;
wire dec_digit_en;
wire [3:0] dec_digit_4;
wire [3:0] dec_digit_3;
wire [3:0] dec_digit_2;
wire [3:0] dec_digit_1;
wire [3:0] dec_digit_0;
wire dec_digit_4_is0;
wire dec_digit_43_is0;
wire dec_digit_42_is0;
wire dec_digit_41_is0;
wire result_sign;
wire [3:0] dec_digit_4_for_display;
wire [3:0] dec_digit_3_for_display;
wire [3:0] dec_digit_2_for_display;
wire [3:0] dec_digit_1_for_display;
wire [3:0] dec_digit_0_for_display;
wire [3:0] sign_for_remain;
wire [3:0] digit3_for_remain;

//display stage
wire [19:0] dec_digit_for_display;
wire [`DISP_STG_WIDTH-1:0] total_disp_stage_pre;
wire [`DISP_STG_WIDTH-1:0] total_disp_stage_qual;
wire [2:0] int_stage; 
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
assign fsmc_convert_to_setup   = fsmc_in_convert & cvt_done;
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
assign fsmc_next_convert = fsmc_next_state[4];
assign fsmc_next_setup   = fsmc_next_state[5];
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
dflip_en sign_ff (.clk(clk_display), .rst(rst), .en(sign_en), .d(sign_d), .q(sign_q));

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

assign cal_board_digit_ctrl = {`DIGIT_WIDTH{digit_cnt_q == 2'b00}} & `DIGIT_WIDTH'b1110 |
                              {`DIGIT_WIDTH{digit_cnt_q == 2'b01}} & `DIGIT_WIDTH'b1101 |
                              {`DIGIT_WIDTH{digit_cnt_q == 2'b10}} & `DIGIT_WIDTH'b1011 |
                              {`DIGIT_WIDTH{digit_cnt_q == 2'b11}} & `DIGIT_WIDTH'b0111 | 
                              {`DIGIT_WIDTH{~digit_cnt_en | invld_result & fsmc_in_display}} & `DIGIT_WIDTH'b1111 ;

assign input_digit_curr = {`DIGIT_WIDTH{digit_cnt_q == 2'b00}} & digit0_q |
                          {`DIGIT_WIDTH{digit_cnt_q == 2'b01}} & digit1_q |
                          {`DIGIT_WIDTH{digit_cnt_q == 2'b10}} & digit2_q |
                          {`DIGIT_WIDTH{digit_cnt_q == 2'b11}} & {3'b101, sign_q} ;

assign output_int_4digit = {`DIGIT_WIDTH{digit_cnt_q == 2'b00}} & dec_digit_2_for_display |
                           {`DIGIT_WIDTH{digit_cnt_q == 2'b01}} & dec_digit_3_for_display |
                           {`DIGIT_WIDTH{digit_cnt_q == 2'b10}} & dec_digit_4_for_display |
                           {`DIGIT_WIDTH{digit_cnt_q == 2'b11}} & {3'b101, result_sign}   ;

assign output_int_remain = {`DIGIT_WIDTH{digit_cnt_q == 2'b00}} & 4'ha |
                           {`DIGIT_WIDTH{digit_cnt_q == 2'b01}} & 4'ha |
                           {`DIGIT_WIDTH{digit_cnt_q == 2'b10}} & digit3_for_remain  |
                           {`DIGIT_WIDTH{digit_cnt_q == 2'b11}} & sign_for_remain;

//FIXME print output
assign digit_val = (fsmc_in_inputa | fsmc_in_inputb) ? input_digit_curr : 
                   (fsmc_in_display & (display_stage_q == 3'b1 | display_last_stage & ~(|total_disp_stage_qual))) ? output_int_4digit :
                   (fsmc_in_display & (display_last_stage & total_disp_stage_qual > 3'b0)) ? output_int_remain :  4'ha;

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
                       op_qual[`OP_MUL] |
                       op_qual[`OP_DIV] ;

assign multi_cyc_op = 1'b0;

//Covert decimal input to binary
assign a_digit0_sl0 = {12'b0, a_digit0} ;
assign a_digit1_sl3 = {12'b0, a_digit1} << 3'h3;
assign a_digit1_sl1 = {12'b0, a_digit1} << 3'h1;
assign a_digit2_sl6 = {12'b0, a_digit2} << 3'h6;
assign a_digit2_sl5 = {12'b0, a_digit2} << 3'h5;
assign a_digit2_sl2 = {12'b0, a_digit2} << 3'h2;

assign b_digit0_sl0 = {12'b0, b_digit0} ;
assign b_digit1_sl3 = {12'b0, b_digit1} << 3'h3;
assign b_digit1_sl1 = {12'b0, b_digit1} << 3'h1;
assign b_digit2_sl6 = {12'b0, b_digit2} << 3'h6;
assign b_digit2_sl5 = {12'b0, b_digit2} << 3'h5;
assign b_digit2_sl2 = {12'b0, b_digit2} << 3'h2;

//init counter
wire init_cnt_rst;
wire [1:0] init_cnt_d;
wire [1:0] init_cnt_q;
wire init_cnt_en;

assign init_cnt_rst = fsmc_next_exe; 
assign init_cnt_d = init_cnt_rst ? 2'b00 : init_cnt_q + 2'b01;
assign init_cnt_en = ~(&init_cnt_d);
dflip_en #(2) init_cnt_ff (.clk(clk), .rst(rst), .en(init_cnt_en), .d(init_cnt_d), .q(init_cnt_q));

wire [`RESULT_WIDTH-1:0] a_lv1_0;
wire [`RESULT_WIDTH-1:0] a_lv1_1;
wire [`RESULT_WIDTH-1:0] a_lv1_2;
wire [`RESULT_WIDTH-1:0] a_lv1_0_q;
wire [`RESULT_WIDTH-1:0] a_lv1_1_q;
wire [`RESULT_WIDTH-1:0] a_lv1_2_q;
wire [`RESULT_WIDTH-1:0] a_lv2;
wire [`RESULT_WIDTH-1:0] a_lv3;
wire [`RESULT_WIDTH-1:0] a_lv2_q;
wire [`RESULT_WIDTH-1:0] a_lv3_q;

wire a_lv1_0_en;
wire a_lv1_1_en;
wire a_lv1_2_en;
wire a_lv2_en;
wire a_lv3_en;

wire [`RESULT_WIDTH-1:0] b_lv1_0;
wire [`RESULT_WIDTH-1:0] b_lv1_1;
wire [`RESULT_WIDTH-1:0] b_lv1_2;
wire [`RESULT_WIDTH-1:0] b_lv1_0_q;
wire [`RESULT_WIDTH-1:0] b_lv1_1_q;
wire [`RESULT_WIDTH-1:0] b_lv1_2_q;
wire [`RESULT_WIDTH-1:0] b_lv2;
wire [`RESULT_WIDTH-1:0] b_lv3;
wire [`RESULT_WIDTH-1:0] b_lv2_q;
wire [`RESULT_WIDTH-1:0] b_lv3_q;

wire b_lv1_0_en;
wire b_lv1_1_en;
wire b_lv1_2_en;
wire b_lv2_en;
wire b_lv3_en;

assign a_lv1_0 = a_digit1_sl3 + a_digit1_sl1;
assign a_lv1_1 = a_digit2_sl6 + a_digit2_sl5;
assign a_lv1_2 = a_digit0_sl0 + a_digit2_sl2;

assign a_lv1_0_en = init_cnt_q == 2'b0;
assign a_lv1_1_en = init_cnt_q == 2'b0;
assign a_lv1_2_en = init_cnt_q == 2'b0;
assign a_lv2_en   = init_cnt_q == 2'b1;
assign a_lv3_en   = init_cnt_q == 2'b10;

dflip_en #(`RESULT_WIDTH) a_lv1_0_ff (.clk(clk), .rst(rst), .en(a_lv1_0_en), .d(a_lv1_0), .q(a_lv1_0_q));
dflip_en #(`RESULT_WIDTH) a_lv1_1_ff (.clk(clk), .rst(rst), .en(a_lv1_1_en), .d(a_lv1_1), .q(a_lv1_1_q));
dflip_en #(`RESULT_WIDTH) a_lv1_2_ff (.clk(clk), .rst(rst), .en(a_lv1_2_en), .d(a_lv1_2), .q(a_lv1_2_q));

assign a_lv2 = a_lv1_0_q + a_lv1_1_q;
dflip_en #(`RESULT_WIDTH) a_lv2_ff   (.clk(clk), .rst(rst), .en(a_lv2_en), .d(a_lv2), .q(a_lv2_q));
assign a_lv3 = a_lv2_q + a_lv1_2_q;
dflip_en #(`RESULT_WIDTH) a_lv3_ff   (.clk(clk), .rst(rst), .en(a_lv3_en), .d(a_lv3), .q(a_lv3_q));
assign unsign_inputa = a_lv3_q;

assign b_lv1_0 = b_digit1_sl3 + b_digit1_sl1;
assign b_lv1_1 = b_digit2_sl6 + b_digit2_sl5;
assign b_lv1_2 = b_digit0_sl0 + b_digit2_sl2;

assign b_lv1_0_en = init_cnt_q == 2'b0;
assign b_lv1_1_en = init_cnt_q == 2'b0;
assign b_lv1_2_en = init_cnt_q == 2'b0;
assign b_lv2_en   = init_cnt_q == 2'b1;
assign b_lv3_en   = init_cnt_q == 2'b10;

dflip_en #(`RESULT_WIDTH) b_lv1_0_ff (.clk(clk), .rst(rst), .en(b_lv1_0_en), .d(b_lv1_0), .q(b_lv1_0_q));
dflip_en #(`RESULT_WIDTH) b_lv1_1_ff (.clk(clk), .rst(rst), .en(b_lv1_1_en), .d(b_lv1_1), .q(b_lv1_1_q));
dflip_en #(`RESULT_WIDTH) b_lv1_2_ff (.clk(clk), .rst(rst), .en(b_lv1_2_en), .d(b_lv1_2), .q(b_lv1_2_q));

assign b_lv2 = b_lv1_0_q + b_lv1_1_q;
dflip_en #(`RESULT_WIDTH) b_lv2_ff   (.clk(clk), .rst(rst), .en(b_lv2_en), .d(b_lv2), .q(b_lv2_q));
assign b_lv3 = b_lv2_q + b_lv1_2_q;
dflip_en #(`RESULT_WIDTH) b_lv3_ff   (.clk(clk), .rst(rst), .en(b_lv3_en), .d(b_lv3), .q(b_lv3_q));
assign unsign_inputb = b_lv3_q;

assign sign_inputa = ~unsign_inputa + 1;
assign sign_inputb = ~unsign_inputb + 1;
assign inputa = a_sign ? sign_inputa : unsign_inputa; 
assign inputb = b_sign ? sign_inputb : unsign_inputb;

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

assign fsme_idle_to_init   = fsme_in_idle   & fsmc_in_exe;
assign fsme_init_to_single = fsme_in_init   & single_cyc_op & init_cnt_q[1];
assign fsme_init_to_multi  = fsme_in_init   & multi_cyc_op  & init_cnt_q[1];
assign fsme_init_to_done   = fsme_in_init   & invld_input   & init_cnt_q[1];
assign fsme_single_to_done = fsme_in_single ;
assign fsme_multi_to_done  = fsme_in_multi  & 1'b1; //FIXME
assign fsme_done_to_idle   = fsme_in_done   ;

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
assign div_result = inputa / inputb;

//result
assign invld_result = invld_input | overflow;
//overflow checking 
assign result_qual = {`RESULT_WIDTH{op_qual[`OP_ADD]}} & add_result |
                     {`RESULT_WIDTH{op_qual[`OP_SUB]}} & sub_result |
                     {`RESULT_WIDTH{op_qual[`OP_MUL]}} & mul_result |
                     {`RESULT_WIDTH{op_qual[`OP_DIV]}} & div_result ;

assign result_sign = result_qual[15];
assign result_cvt_pre = result_qual[15] ? ~result_qual + 16'b1 : result_qual;

//Binary to decimal convert
assign cvt_cnt_rst = exe_pre_done;
assign cvt_cnt_en = fsmc_in_convert | cvt_cnt_rst;
assign cvt_cnt = cvt_cnt_rst ? 4'b0000 : cvt_cnt_q + 4'b1;

dflip_en #(4) cvt_cnt_ff (.clk(clk), .rst(rst), .en(cvt_cnt_en), .d(cvt_cnt), .q(cvt_cnt_q));
assign cvt_done = &cvt_cnt_q;

assign dec_digit[15:0]  = dec_digit_q[15:0];
assign dec_digit[19:16] = dec_digit_q[19:16] >= 4'h5 ? dec_digit_q[19:16] + 4'h3 : dec_digit_q[19:16];
assign dec_digit[23:20] = dec_digit_q[23:20] >= 4'h5 ? dec_digit_q[23:20] + 4'h3 : dec_digit_q[23:20];
assign dec_digit[27:24] = dec_digit_q[27:24] >= 4'h5 ? dec_digit_q[27:24] + 4'h3 : dec_digit_q[27:24];
assign dec_digit[31:28] = dec_digit_q[31:28] >= 4'h5 ? dec_digit_q[31:28] + 4'h3 : dec_digit_q[31:28];
assign dec_digit[35:32] = dec_digit_q[35:31] >= 4'h5 ? dec_digit_q[35:31] + 4'h3 : dec_digit_q[35:31];
assign dec_digit_shift = ~(|cvt_cnt_q) ? {19'b0, result_cvt_pre, 1'b0} : dec_digit << 1'b1;
assign dec_digit_en = fsmc_in_convert;

dflip_en #(36) dec_digit_ff (.clk(clk), .rst(rst), .en(dec_digit_en), .d(dec_digit_shift), .q(dec_digit_q));

assign dec_digit_0 = dec_digit_q[19:16];
assign dec_digit_1 = dec_digit_q[23:20];
assign dec_digit_2 = dec_digit_q[27:24];
assign dec_digit_3 = dec_digit_q[31:28];
assign dec_digit_4 = dec_digit_q[35:31];

//display digit
assign dec_digit_4_is0  = ~(|dec_digit_4);
assign dec_digit_43_is0 = ~(|dec_digit_4) & ~(|dec_digit_3);
assign dec_digit_42_is0 = ~(|dec_digit_4) & ~(|dec_digit_3) & ~(|dec_digit_2);
assign dec_digit_41_is0 = ~(|dec_digit_4) & ~(|dec_digit_3) & ~(|dec_digit_2) & ~(|dec_digit_1);

assign dec_digit_for_display = dec_digit_41_is0 ? {dec_digit_q[19:16], 16'b0} :
                               dec_digit_42_is0 ? {dec_digit_q[23:16], 12'b0} :
                               dec_digit_43_is0 ? {dec_digit_q[27:16], 8'b0}  :
                               dec_digit_4_is0  ? {dec_digit_q[31:16], 4'b0}  : dec_digit_q[35:16];


assign dec_digit_0_for_display = (dec_digit_41_is0 | dec_digit_42_is0 | dec_digit_43_is0 | dec_digit_4_is0)? 4'ha : dec_digit_for_display[3:0];
assign dec_digit_1_for_display = (dec_digit_41_is0 | dec_digit_42_is0 | dec_digit_43_is0) ? 4'ha : dec_digit_for_display[7:4];
assign dec_digit_2_for_display = (dec_digit_41_is0 | dec_digit_42_is0) ? 4'ha : dec_digit_for_display[11:8];
assign dec_digit_3_for_display = (dec_digit_41_is0) ? 4'ha :dec_digit_for_display[15:12];
assign dec_digit_4_for_display = dec_digit_for_display[19:16];

assign sign_for_remain   = dec_digit_43_is0 ? dec_digit_0_for_display : dec_digit_1_for_display;
assign digit3_for_remain = dec_digit_43_is0 ? 4'ha : dec_digit_0_for_display;

//display stage
assign int_stage = ~(|dec_digit_4) & ~(|dec_digit_3) ? 3'b0 : 3'b1;
assign total_disp_stage_pre = {`DISP_STG_WIDTH{int_result_op}} & int_stage;

assign total_disp_stage_qual = (invld_result) ? 3'b000 : total_disp_stage_pre;
assign display_stage_en = fsmc_in_display & button_mid & ~display_last_stage | fsmc_in_setup;
assign display_stage = fsmc_in_setup ? total_disp_stage_qual : display_stage_q - 1'b1;
assign display_last_stage = ~(|display_stage_q);
dflip_en #(`DISP_STG_WIDTH) display_stage_ff (.clk(clk), .rst(rst), .en(display_stage_en), .d(display_stage), .q(display_stage_q));
assign cal_board_display_stage = display_stage_q;

endmodule
