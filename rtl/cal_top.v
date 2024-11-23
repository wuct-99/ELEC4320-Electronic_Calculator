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

//Button
wire [`BUTTON_WIDTH - 1:0] debounce_button;
wire [`BUTTON_WIDTH - 1:0] button_qual;

wire invld_result;

//FSME Define
reg [`FSME_STATE_WIDTH - 1:0] fsme_curr_state;
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

//debouncing 
debounce #(`BUTTON_WIDTH) button_debounce (.clk(clk), .rst(rst), .data_in(board_cal_button), .data_out(debounce_button));

//Decode
wire button_up;
wire button_down;
wire button_left;
wire button_right;
wire button_mid;

assign button_qual = debounce_button[0] ? 5'b0_0001 :
                     debounce_button[1] ? 5'b0_0010 :
                     debounce_button[2] ? 5'b0_0100 :
                     debounce_button[3] ? 5'b0_1000 :
                     debounce_button[4] ? 5'b1_0000 : 5'b0_0000;

assign button_up   = button_qual[`BUTTON_UP];
assign button_down = button_qual[`BUTTON_DOWN];
assign button_left = button_qual[`BUTTON_LEFT];
assign button_right= button_qual[`BUTTON_RIGHT];
assign button_mid  = button_qual[`BUTTON_MID];

wire display_stage_en;
wire [2:0] display_stage  ;
reg  [2:0] display_stage_q;
wire display_last_stage;
//FSMC
reg [`FSMC_STATE_WIDTH - 1:0] fsmc_curr_state;
wire [`FSMC_STATE_WIDTH - 1:0] fsmc_next_state;

wire fsmc_idle_to_inputa;
wire fsmc_inputa_to_inputb;
wire fsmc_inputb_to_exe;
wire fsmc_exe_to_display;
wire fsmc_display_to_inputa;

wire fsmc_state_upd;

wire fsmc_in_idle;
wire fsmc_in_inputa;
wire fsmc_in_inputb;
wire fsmc_in_exe;
wire fsmc_in_display;

wire fsmc_next_inputa;
wire fsmc_next_inputb;
wire fsmc_next_exe   ;
wire fsmc_next_display;

assign fsmc_state_upd = fsmc_idle_to_inputa   |
                        fsmc_inputa_to_inputb |
                        fsmc_inputb_to_exe    |
                        fsmc_exe_to_display   |
                        fsmc_display_to_inputa;

assign fsmc_in_idle    = fsmc_curr_state[0];
assign fsmc_in_inputa  = fsmc_curr_state[1];
assign fsmc_in_inputb  = fsmc_curr_state[2];
assign fsmc_in_exe     = fsmc_curr_state[3];
assign fsmc_in_display = fsmc_curr_state[4];

assign fsmc_idle_to_inputa    = fsmc_in_idle   ;
assign fsmc_inputa_to_inputb  = fsmc_in_inputa  & button_mid;
assign fsmc_inputb_to_exe     = fsmc_in_inputb  & button_mid;
assign fsmc_exe_to_display    = fsmc_in_exe     & fsme_next_idle;
assign fsmc_display_to_inputa = fsmc_in_display & button_mid & display_last_stage;

assign fsmc_next_state = {`FSMC_STATE_WIDTH{fsmc_idle_to_inputa   }} & `FSMC_INPUTA |
                         {`FSMC_STATE_WIDTH{fsmc_inputa_to_inputb }} & `FSMC_INPUTB |
                         {`FSMC_STATE_WIDTH{fsmc_inputb_to_exe    }} & `FSMC_EXE    |
                         {`FSMC_STATE_WIDTH{fsmc_exe_to_display   }} & `FSMC_DISPLAY|
                         {`FSMC_STATE_WIDTH{fsmc_display_to_inputa}} & `FSMC_INPUTA ;

assign fsmc_next_inputa  = fsmc_next_state[1];
assign fsmc_next_inputb  = fsmc_next_state[2];
assign fsmc_next_exe     = fsmc_next_state[3];
assign fsmc_next_display = fsmc_next_state[4];

dflip_en #(`FSMC_STATE_WIDTH, 5'h1) fsmc_state_ff (.clk(clk), .rst(rst), .en(fsmc_state_upd), .d(fsmc_next_state), .q(fsmc_curr_state));

//FSMIN
reg [`FSMIN_STATE_WIDTH - 1:0] fsmin_curr_state;
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
//Digit Control
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

assign digit0_en = (fsmin_in_digit0 & (button_up | button_down)) | fsmin_state_rst;
assign digit0_d = {`DIGIT_WIDTH{fsmin_state_rst                    }} & (4'b0000        ) | 
                  {`DIGIT_WIDTH{button_up   & (digit0_q == 4'b1001)}} & (4'b0000        ) |       
                  {`DIGIT_WIDTH{button_up   & (digit0_q <  4'b1001)}} & (digit0_q + 4'b1) | 
                  {`DIGIT_WIDTH{button_down & (digit0_q == 4'b0000)}} & (4'b1001        ) | 
                  {`DIGIT_WIDTH{button_down & (digit0_q >  4'b0000)}} & (digit0_q - 4'b1) ;

dflip_en #(`DIGIT_WIDTH) digit0_ff (.clk(clk), .rst(rst), .en(digit0_en), .d(digit0_d), .q(digit0_q));

assign digit1_en = (fsmin_in_digit1 & (button_up | button_down)) | fsmin_state_rst;
assign digit1_d = {`DIGIT_WIDTH{fsmin_state_rst                    }} & (4'b0000        ) | 
                  {`DIGIT_WIDTH{button_up   & (digit1_q == 4'b1001)}} & (4'b0000        ) |       
                  {`DIGIT_WIDTH{button_up   & (digit1_q <  4'b1001)}} & (digit1_q + 4'b1) | 
                  {`DIGIT_WIDTH{button_down & (digit1_q == 4'b0000)}} & (4'b1001        ) | 
                  {`DIGIT_WIDTH{button_down & (digit1_q >  4'b0000)}} & (digit1_q - 4'b1) ;

dflip_en #(`DIGIT_WIDTH) digit1_ff (.clk(clk), .rst(rst), .en(digit1_en), .d(digit1_d), .q(digit1_q));

assign digit2_en = (fsmin_in_digit2 & (button_up | button_down)) | fsmin_state_rst;
assign digit2_d = {`DIGIT_WIDTH{fsmin_state_rst                    }} & (4'b0000        ) | 
                  {`DIGIT_WIDTH{button_up   & (digit2_q == 4'b1001)}} & (4'b0000        ) |       
                  {`DIGIT_WIDTH{button_up   & (digit2_q <  4'b1001)}} & (digit2_q + 4'b1) | 
                  {`DIGIT_WIDTH{button_down & (digit2_q == 4'b0000)}} & (4'b1001        ) | 
                  {`DIGIT_WIDTH{button_down & (digit2_q >  4'b0000)}} & (digit2_q - 4'b1) ;

dflip_en #(`DIGIT_WIDTH) digit2_ff (.clk(clk), .rst(rst), .en(digit2_en), .d(digit2_d), .q(digit2_q));

assign sign_en = (fsmin_in_sign & (button_up | button_down)) | fsmin_state_rst;;
assign sign_d = fsmin_state_rst ? 4'b0000 : sign_q + 1'b1;

dflip_en sign_ff (.clk(clk), .rst(rst), .en(sign_en), .d(sign_d), .q(sign_q));

//Save input a/b
reg [`DIGIT_WIDTH - 1 : 0] a_digit0;
reg [`DIGIT_WIDTH - 1 : 0] a_digit1;
reg [`DIGIT_WIDTH - 1 : 0] a_digit2;
reg a_sign;
reg [`DIGIT_WIDTH - 1 : 0] b_digit0;
reg [`DIGIT_WIDTH - 1 : 0] b_digit1;
reg [`DIGIT_WIDTH - 1 : 0] b_digit2;
reg b_sign;

wire a_digit_en;
wire b_digit_en;

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
wire [1:0] digit_cnt_d;
reg [1:0] digit_cnt_q;

wire digit_cnt_en;
wire digit_cnt_rst;

wire [7:0] digit_val;
wire [`DIGIT_WIDTH -1 :0] input_digit_curr;

assign digit_cnt_rst = fsmc_next_inputa | fsmc_next_inputb | fsmc_next_exe | fsmc_next_display; 
assign digit_cnt_en = fsmc_in_inputa | fsmc_in_inputb | fsmc_in_display & ~invld_result | digit_cnt_rst;
assign digit_cnt_d = digit_cnt_rst ? 2'b00 : digit_cnt_q + 2'b01;
//digit 0 > digit 1 > digit2 > sign
dflip_en #(2) digit_cnt_ff (.clk(clk), .rst(rst), .en(digit_cnt_en), .d(digit_cnt_d), .q(digit_cnt_q));

assign cal_board_digit_ctrl = {`DIGIT_WIDTH{digit_cnt_q == 2'b00}} & 4'b1110 |
                              {`DIGIT_WIDTH{digit_cnt_q == 2'b01}} & 4'b1101 |
                              {`DIGIT_WIDTH{digit_cnt_q == 2'b10}} & 4'b1011 |
                              {`DIGIT_WIDTH{digit_cnt_q == 2'b11}} & 4'b0111 | 
                              {`DIGIT_WIDTH{~digit_cnt_en       }} & 4'b1111 ;

assign input_digit_curr = {`DIGIT_WIDTH{digit_cnt_q == 2'b00}} & digit0_q |
                          {`DIGIT_WIDTH{digit_cnt_q == 2'b01}} & digit1_q |
                          {`DIGIT_WIDTH{digit_cnt_q == 2'b10}} & digit2_q |
                          {`DIGIT_WIDTH{digit_cnt_q == 2'b11}} & sign_q   ;
//FIXME print output

assign digit_val = {8{fsmc_in_inputa | fsmc_in_inputb}} & input_digit_curr;

assign cal_board_digit_seg = {8{digit_val == 8'h0}} & 8'b1111_1100 |
                             {8{digit_val == 8'h1}} & 8'b0110_0000 |
                             {8{digit_val == 8'h2}} & 8'b1101_1010 |
                             {8{digit_val == 8'h3}} & 8'b1111_0010 |
                             {8{digit_val == 8'h4}} & 8'b0110_0110 |
                             {8{digit_val == 8'h5}} & 8'b1011_0110 |
                             {8{digit_val == 8'h6}} & 8'b1011_1110 |
                             {8{digit_val == 8'h7}} & 8'b1110_0000 |
                             {8{digit_val == 8'h8}} & 8'b1111_1110 |
                             {8{digit_val == 8'h9}} & 8'b1110_0110 |
                             {8{digit_val == 8'ha}} & 8'b0000_0001 ; // 8'ha is "."
//Operation decode
wire switch_en;
wire [`SWITCH_WIDTH - 1:0] op_qual;
reg [`SWITCH_WIDTH - 1:0] switchs_in_exe;

assign switch_en = fsmc_next_exe;
dflip_en #(`SWITCH_WIDTH) switch_ff (.clk(clk), .rst(rst), .en(switch_en), .d(board_cal_switchs), .q(switchs_in_exe));

//In Executioin Stage: D0
assign op_qual[`OP_ADD ] = switchs_in_exe[0]  ;
assign op_qual[`OP_SUB ] = switchs_in_exe[1]  & ~switchs_in_exe[0];
assign op_qual[`OP_MUL ] = switchs_in_exe[2]  & ~(|switchs_in_exe[1:0] );
assign op_qual[`OP_DIV ] = switchs_in_exe[3]  & ~(|switchs_in_exe[2:0] );
assign op_qual[`OP_SQRT] = switchs_in_exe[4]  & ~(|switchs_in_exe[3:0] );
assign op_qual[`OP_COS ] = switchs_in_exe[5]  & ~(|switchs_in_exe[4:0] );
assign op_qual[`OP_SIN ] = switchs_in_exe[6]  & ~(|switchs_in_exe[5:0] );
assign op_qual[`OP_TAN ] = switchs_in_exe[7]  & ~(|switchs_in_exe[6:0] );
assign op_qual[`OP_ACOS] = switchs_in_exe[8]  & ~(|switchs_in_exe[7:0] );
assign op_qual[`OP_ASIN] = switchs_in_exe[9]  & ~(|switchs_in_exe[8:0] );
assign op_qual[`OP_ATAN] = switchs_in_exe[10] & ~(|switchs_in_exe[9:0] );
assign op_qual[`OP_LOG ] = switchs_in_exe[11] & ~(|switchs_in_exe[10:0]);
assign op_qual[`OP_POW ] = switchs_in_exe[12] & ~(|switchs_in_exe[11:0]);
assign op_qual[`OP_EXP ] = switchs_in_exe[13] & ~(|switchs_in_exe[12:0]);
assign op_qual[`OP_FACT] = switchs_in_exe[14] & ~(|switchs_in_exe[13:0]);

wire single_cyc_op;
//wire multi_cyc_op;

assign single_cyc_op = op_qual[`OP_ADD] |
                       op_qual[`OP_SUB] |
                       op_qual[`OP_MUL] |
                       op_qual[`OP_DIV] ;

//Covert decimal input to binary
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

assign a_digit0_sl0 = {12'b0, a_digit0} ;
assign a_digit1_sl3 = {12'b0, a_digit1} << 3'h3;
assign a_digit1_sl1 = {12'b0, a_digit1} << 3'h1;
assign a_digit2_sl6 = {12'b0, a_digit2} << 3'h6;
assign a_digit2_sl5 = {12'b0, a_digit2} << 3'h5;
assign a_digit2_sl2 = {12'b0, a_digit2} << 3'h2;

assign unsign_inputa = a_digit0_sl0 +
                       a_digit1_sl3 + a_digit1_sl1 +
                       a_digit2_sl6 + a_digit2_sl5 + a_digit2_sl2;

assign b_digit0_sl0 = {12'b0, b_digit0} ;
assign b_digit1_sl3 = {12'b0, b_digit1} << 3'h3;
assign b_digit1_sl1 = {12'b0, b_digit1} << 3'h1;
assign b_digit2_sl6 = {12'b0, b_digit2} << 3'h6;
assign b_digit2_sl5 = {12'b0, b_digit2} << 3'h5;
assign b_digit2_sl2 = {12'b0, b_digit2} << 3'h2;

assign unsign_inputb = b_digit0_sl0 +
                       b_digit1_sl3 + b_digit1_sl1 +
                       b_digit2_sl6 + b_digit2_sl5 + b_digit2_sl2;

assign sign_inputa = ~unsign_inputa + 1;
assign sign_inputb = ~unsign_inputb + 1;
assign inputa = a_sign ? sign_inputa : unsign_inputa; 
assign inputb = b_sign ? sign_inputb : unsign_inputb;

//Check input constraint
wire invld_input;
wire invld_div;
wire invld_sqrt;

assign invld_div  = op_qual[`OP_DIV ] & ~(|inputb); 
assign invld_sqrt = op_qual[`OP_SQRT] & a_sign;     
assign invld_input = invld_div  |
                     invld_sqrt ;

//FSME
assign fsme_in_idle   = fsme_curr_state[0];
assign fsme_in_init   = fsme_curr_state[1];
assign fsme_in_single = fsme_curr_state[2];
assign fsme_in_multi  = fsme_curr_state[3];
assign fsme_in_done   = fsme_curr_state[4];

assign fsme_idle_to_init   = fsme_in_idle   & fsmc_in_exe;
assign fsme_init_to_single = fsme_in_init   & single_cyc_op;
assign fsme_init_to_multi  = fsme_in_init   & 1'b0 ;
assign fsme_init_to_done   = fsme_in_init   & invld_input;
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

wire exe_pre_done;
assign exe_pre_done = fsme_next_idle;

//single cyc execute
wire signed [`RESULT_WIDTH-1:0] add_result;
wire signed [`RESULT_WIDTH-1:0] sub_result;
wire signed [`RESULT_WIDTH-1:0] mul_result;
wire signed [`RESULT_WIDTH-1:0] div_result;

assign add_result = inputa + inputb;
assign sub_result = inputa - inputb;
assign mul_result = inputa * inputb;
assign div_result = inputa / inputb;

//result
wire overflow = 1'b0;
assign invld_result = invld_input | overflow;
//overflow checking FIXME

//Result display
wire [`DISP_STG_WIDTH-1:0] add_disp_stage;
wire [`DISP_STG_WIDTH-1:0] sub_disp_stage;

wire total_disp_stage_en;
wire [`DISP_STG_WIDTH-1:0] total_disp_stage_pre;
wire [`DISP_STG_WIDTH-1:0] total_disp_stage_qual;

assign add_disp_stage = (add_result > `RESULT_WIDTH'd999 | add_result < -`RESULT_WIDTH'd999) ? 3'b001 : 3'b000;
assign sub_disp_stage = (sub_result > `RESULT_WIDTH'd999 | sub_result < -`RESULT_WIDTH'd999) ? 3'b001 : 3'b000;

assign total_disp_stage_en = fsmc_next_display;
assign total_disp_stage_pre = {`DISP_STG_WIDTH{op_qual[`OP_ADD]}} & add_disp_stage |
                              {`DISP_STG_WIDTH{op_qual[`OP_SUB]}} & sub_disp_stage ;

assign total_disp_stage_qual = (invld_result) ? 3'b000 : total_disp_stage_pre;

assign display_stage_en = fsmc_in_display & button_mid | exe_pre_done;
assign display_stage = exe_pre_done ? total_disp_stage_qual : display_stage_q - 1'b1;
assign display_last_stage = ~(|display_stage_q);

dflip_en #(`DISP_STG_WIDTH) display_stage_ff (.clk(clk), .rst(rst), .en(display_stage_en), .d(display_stage), .q(display_stage_q));

endmodule
