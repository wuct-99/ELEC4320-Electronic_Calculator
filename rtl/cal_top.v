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

input [`BUTTON_WIDTH - 1:0] board_cal_button;
input [14:0] board_cal_switchs;
output [3:0] cal_board_digit_ctrl;
output [7:0] cal_board_digit_seg;
output cal_board_exe_done;
output [2:0] cal_board_display_stage;


wire [`BUTTON_WIDTH - 1:0] debounce_button;
wire [`BUTTON_WIDTH - 1:0] button_qual;

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

//FSMC
reg [`FSMC_STATE_WIDTH - 1:0] fsmc_curr_state;
wire [`FSMC_STATE_WIDTH - 1:0] fsmc_next_state;

wire fsmc_idle_to_inputa;
wire fsmc_inputa_to_inputb;
wire fsmc_inputb_to_exe;
wire fsmc_exe_to_display;
wire fsmc_display_to_inputa;

wire fsmc_state_upd;
reg [2:0] display_stage = 3'b0;

wire fsmc_in_idle;
wire fsmc_in_inputa;
wire fsmc_in_inputb;
wire fsmc_in_exe;
wire fsmc_in_display;

wire fsmc_next_inputa;
wire fsmc_next_inputb;
wire fsmc_next_exe   ;

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

assign fsmc_idle_to_inputa    = (fsmc_in_idle   );
assign fsmc_inputa_to_inputb  = (fsmc_in_inputa ) & (button_mid);
assign fsmc_inputb_to_exe     = (fsmc_in_inputb ) & (button_mid);
assign fsmc_exe_to_display    = (fsmc_in_exe    ); //FIXME
assign fsmc_display_to_inputa = (fsmc_in_display) & (button_mid) & (display_stage == 3'b000);

assign fsmc_next_state = {`FSMC_STATE_WIDTH{fsmc_idle_to_inputa   }} & `FSMC_INPUTA |
                         {`FSMC_STATE_WIDTH{fsmc_inputa_to_inputb }} & `FSMC_INPUTB |
                         {`FSMC_STATE_WIDTH{fsmc_inputb_to_exe    }} & `FSMC_EXE    |
                         {`FSMC_STATE_WIDTH{fsmc_exe_to_display   }} & `FSMC_DISPLAY|
                         {`FSMC_STATE_WIDTH{fsmc_display_to_inputa}} & `FSMC_INPUTA ;

assign fsmc_next_inputa = fsmc_next_state[1];
assign fsmc_next_inputb = fsmc_next_state[2];
assign fsmc_next_exe    = fsmc_next_state[3];

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
wire fsmin_in_digit1;
wire fsmin_in_digit2;
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

assign digit_cnt_rst = fsmc_next_inputa | fsmc_next_inputb | fsmc_next_exe; 
assign digit_cnt_en = fsmc_in_inputa | fsmc_in_inputb | digit_cnt_rst;
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
                             {8{digit_val == 8'ha}} & 8'b0000_0001 | 8'b0; // 8'ha is "."
endmodule
