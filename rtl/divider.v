module divider(
    clk,
    rst,
    div_start,
    inputa_754,
    inputb_754,
    div_result_754,
    div_done
); 

input clk;
input rst;
input div_start;
input  [31:0] inputa_754;
input  [31:0] inputb_754;
output [31:0] div_result_754;
output div_done;

wire fsmdiv_in_idle;
wire fsmdiv_in_init;
wire fsmdiv_in_exe ;
wire fsmdiv_in_done;

wire fsmdiv_idle_to_init;
wire fsmdiv_init_to_exe ;
wire fsmdiv_exe_to_done ;
wire fsmdiv_done_to_idle;

wire [`FSMDIV_STATE_WIDTH-1:0] fsmdiv_curr_state;
wire [`FSMDIV_STATE_WIDTH-1:0] fsmdiv_next_state;
wire fsmdiv_state_upd;

wire exe_done;

//FSMDIV
assign fsmdiv_in_idle  = fsmdiv_curr_state[0];
assign fsmdiv_in_init  = fsmdiv_curr_state[1];
assign fsmdiv_in_exe   = fsmdiv_curr_state[2];
assign fsmdiv_in_done  = fsmdiv_curr_state[3];

assign fsmdiv_idle_to_init = fsmdiv_in_idle & div_start;
assign fsmdiv_init_to_exe  = fsmdiv_in_init ;
assign fsmdiv_exe_to_done  = fsmdiv_in_exe  & exe_done;
assign fsmdiv_done_to_idle = fsmdiv_in_done ;

assign fsmdiv_next_state = {`FSMDIV_STATE_WIDTH{fsmdiv_idle_to_init}} & `FSMDIV_INIT |
                           {`FSMDIV_STATE_WIDTH{fsmdiv_init_to_exe }} & `FSMDIV_EXE  |
                           {`FSMDIV_STATE_WIDTH{fsmdiv_exe_to_done }} & `FSMDIV_DONE |
                           {`FSMDIV_STATE_WIDTH{fsmdiv_done_to_idle}} & `FSMDIV_IDLE ;

assign fsmdiv_state_upd = fsmdiv_idle_to_init |
                          fsmdiv_init_to_exe  |
                          fsmdiv_exe_to_done  |
                          fsmdiv_done_to_idle ;

assign fsmdiv_next_exe  = fsmdiv_next_state[2];

dflip_en #(`FSMDIV_STATE_WIDTH, `FSMDIV_STATE_WIDTH'h1) fsmdiv_state_ff (.clk(clk), 
                                                                         .rst(rst), 
                                                                         .en(fsmdiv_state_upd), 
                                                                         .d(fsmdiv_next_state), 
                                                                         .q(fsmdiv_curr_state));

//Step 1: decode IEEE754
wire inputa_sign_754;
wire inputb_sign_754;
wire [7:0] inputa_exp;
wire [7:0] inputb_exp;
wire [22:0] inputa_mantissa;
wire [22:0] inputb_mantissa;

assign inputa_sign_754 = inputa_754[31]; 
assign inputb_sign_754 = inputb_754[31]; 
assign inputa_exp      = inputa_754[30:23];
assign inputb_exp      = inputb_754[30:23];
assign inputa_mantissa = inputa_754[22:0]; 
assign inputb_mantissa = inputb_754[22:0]; 

//step2: Prepare   
wire [31:0] dividend;
wire [31:0] divisor;

assign dividend ={1'b1, inputa_mantissa, 8'b0};
assign divisor  ={1'b1, inputb_mantissa, 8'b0};

//step 3: Calculate Quotient Exponential
wire [7:0] quotient_exp;
assign quotient_exp =  inputa_exp - inputb_exp + 8'd127;

//step 4:
wire [31:0] quotient;
wire [31:0] shift_divisor;

assign shift_divisor = ~(|divisor[31:0]) ? 32'd0        :
                       ~(|divisor[30:0]) ? divisor >> 5'd31:
                       ~(|divisor[29:0]) ? divisor >> 5'd30:
                       ~(|divisor[28:0]) ? divisor >> 5'd29:
                       ~(|divisor[27:0]) ? divisor >> 5'd28:
                       ~(|divisor[26:0]) ? divisor >> 5'd27:
                       ~(|divisor[25:0]) ? divisor >> 5'd26:
                       ~(|divisor[24:0]) ? divisor >> 5'd25:
                       ~(|divisor[23:0]) ? divisor >> 5'd24:
                       ~(|divisor[22:0]) ? divisor >> 5'd23:
                       ~(|divisor[21:0]) ? divisor >> 5'd22:
                       ~(|divisor[20:0]) ? divisor >> 5'd21:
                       ~(|divisor[19:0]) ? divisor >> 5'd20:
                       ~(|divisor[18:0]) ? divisor >> 5'd19:
                       ~(|divisor[17:0]) ? divisor >> 5'd18:
                       ~(|divisor[16:0]) ? divisor >> 5'd17:
                       ~(|divisor[15:0]) ? divisor >> 5'd16:
                       ~(|divisor[14:0]) ? divisor >> 5'd15:
                       ~(|divisor[13:0]) ? divisor >> 5'd14:
                       ~(|divisor[12:0]) ? divisor >> 5'd13:
                       ~(|divisor[11:0]) ? divisor >> 5'd12:
                       ~(|divisor[10:0]) ? divisor >> 5'd11:
                       ~(|divisor[9:0])  ? divisor >> 5'd10:
                       ~(|divisor[8:0])  ? divisor >> 5'd9 :
                       ~(|divisor[7:0])  ? divisor >> 5'd8 :
                       ~(|divisor[6:0])  ? divisor >> 5'd7 :
                       ~(|divisor[5:0])  ? divisor >> 5'd6 :
                       ~(|divisor[4:0])  ? divisor >> 5'd5 :
                       ~(|divisor[3:0])  ? divisor >> 5'd4 :
                       ~(|divisor[2:0])  ? divisor >> 5'd3 :
                       ~(|divisor[1:0])  ? divisor >> 5'd2 :
                       ~(|divisor[0])    ? divisor >> 5'd1 : divisor;


//assign quotient = dividend / shift_divisor;
wire [7:0] quotient_exp_q;
wire [31:0] divisor_q;
wire [31:0] dividend_q;
wire [31:0] shift_divisor_q;
wire init_en;

assign init_en = fsmdiv_in_init;
dflip_en #(8)  quotient_exp_ff (.clk(clk), .rst(rst), .en(init_en), .d(quotient_exp), .q(quotient_exp_q));
dflip_en #(32) dividend_ff (.clk(clk), .rst(rst), .en(init_en), .d(dividend), .q(dividend_q));
dflip_en #(32) divisr_ff (.clk(clk), .rst(rst), .en(init_en), .d(divisor), .q(divisor_q));
dflip_en #(32) shift_divisr_ff (.clk(clk), .rst(rst), .en(init_en), .d(shift_divisor), .q(shift_divisor_q));

//Divider Counter
wire [4:0] div_cnt;
wire [4:0] div_cnt_q;
assign div_cnt_rst = fsmdiv_next_exe;
assign div_cnt_en = fsmdiv_in_exe;
assign div_cnt = div_cnt_rst ? 5'b0000 : div_cnt_q + 4'b1;
dflip_en #(5) div_cnt_ff (.clk(clk), .rst(rst), .en(div_cnt_en), .d(div_cnt), .q(div_cnt_q));
assign exe_done = &div_cnt;

wire [63:0] shift_acc;
wire [63:0] acc;
wire [63:0] acc_q;
wire [31:0] shift_quo;
wire [31:0] quotient_q;

assign shift_acc = div_cnt_q == 0 ? {31'b0, dividend_q[31:0], 1'b0} : acc_q << 1'b1;
assign acc[63:32] = shift_acc[63:32] >= shift_divisor_q ? shift_acc[63:32] - shift_divisor_q : shift_acc[63:32];
assign acc[31:0] = shift_acc[31:0];

assign shift_quo = quotient_q << 1'b1; 
assign quotient[31:1] = shift_quo[31:1];
assign quotient[0] = shift_acc[63:32] >= shift_divisor_q;

wire exe_en;
assign exe_en = fsmdiv_in_exe;

dflip_en #(64) acc_ff (.clk(clk), .rst(rst), .en(exe_en), .d(acc), .q(acc_q));
dflip_en #(32) quotient_ff (.clk(clk), .rst(rst), .en(exe_en), .d(quotient), .q(quotient_q)); 

//
wire [31:0] shift_quotient;
assign shift_quotient = ~(|divisor_q[30:0]) ? quotient <<  5'd0 :
                        ~(|divisor_q[29:0]) ? quotient <<  5'd1 :
                        ~(|divisor_q[28:0]) ? quotient <<  5'd2 :
                        ~(|divisor_q[27:0]) ? quotient <<  5'd3 :
                        ~(|divisor_q[26:0]) ? quotient <<  5'd4 :
                        ~(|divisor_q[25:0]) ? quotient <<  5'd5 :
                        ~(|divisor_q[24:0]) ? quotient <<  5'd6 :
                        ~(|divisor_q[23:0]) ? quotient <<  5'd7 :
                        ~(|divisor_q[22:0]) ? quotient <<  5'd8 :
                        ~(|divisor_q[21:0]) ? quotient <<  5'd9 :
                        ~(|divisor_q[20:0]) ? quotient <<  5'd10:
                        ~(|divisor_q[19:0]) ? quotient <<  5'd11:
                        ~(|divisor_q[18:0]) ? quotient <<  5'd12:
                        ~(|divisor_q[17:0]) ? quotient <<  5'd13:
                        ~(|divisor_q[16:0]) ? quotient <<  5'd14:
                        ~(|divisor_q[15:0]) ? quotient <<  5'd15:
                        ~(|divisor_q[14:0]) ? quotient <<  5'd16:
                        ~(|divisor_q[13:0]) ? quotient <<  5'd17:
                        ~(|divisor_q[12:0]) ? quotient <<  5'd18:
                        ~(|divisor_q[11:0]) ? quotient <<  5'd19:
                        ~(|divisor_q[10:0]) ? quotient <<  5'd20: 
                        ~(|divisor_q[9:0 ]) ? quotient <<  5'd21: 
                        ~(|divisor_q[8:0 ]) ? quotient <<  5'd22: 
                        ~(|divisor_q[7:0 ]) ? quotient <<  5'd23: 
                        ~(|divisor_q[6:0 ]) ? quotient <<  5'd24: 
                        ~(|divisor_q[5:0 ]) ? quotient <<  5'd25: 
                        ~(|divisor_q[4:0 ]) ? quotient <<  5'd26: 
                        ~(|divisor_q[3:0 ]) ? quotient <<  5'd27: 
                        ~(|divisor_q[2:0 ]) ? quotient <<  5'd28: 
                        ~(|divisor_q[1:0 ]) ? quotient <<  5'd29: 
                        ~(|divisor_q[0   ]) ? quotient <<  5'd30: quotient;
//step 6
wire [31:0] norm_quotient;
assign norm_quotient = ~(|shift_quotient[31:0 ]) ? 32'd0                   :
                       ~(|shift_quotient[31:1 ]) ? shift_quotient << 5'd31 :
                       ~(|shift_quotient[31:2 ]) ? shift_quotient << 5'd30 :
                       ~(|shift_quotient[31:3 ]) ? shift_quotient << 5'd29 :
                       ~(|shift_quotient[31:4 ]) ? shift_quotient << 5'd28 :
                       ~(|shift_quotient[31:5 ]) ? shift_quotient << 5'd27 :
                       ~(|shift_quotient[31:6 ]) ? shift_quotient << 5'd26 :
                       ~(|shift_quotient[31:7 ]) ? shift_quotient << 5'd25 :
                       ~(|shift_quotient[31:8 ]) ? shift_quotient << 5'd24 :
                       ~(|shift_quotient[31:9 ]) ? shift_quotient << 5'd23 :
                       ~(|shift_quotient[31:10]) ? shift_quotient << 5'd22 :
                       ~(|shift_quotient[31:11]) ? shift_quotient << 5'd21 :
                       ~(|shift_quotient[31:12]) ? shift_quotient << 5'd20 :
                       ~(|shift_quotient[31:13]) ? shift_quotient << 5'd19 :
                       ~(|shift_quotient[31:14]) ? shift_quotient << 5'd18 :
                       ~(|shift_quotient[31:15]) ? shift_quotient << 5'd17 :
                       ~(|shift_quotient[31:16]) ? shift_quotient << 5'd16 :
                       ~(|shift_quotient[31:17]) ? shift_quotient << 5'd15 :
                       ~(|shift_quotient[31:18]) ? shift_quotient << 5'd14 :
                       ~(|shift_quotient[31:19]) ? shift_quotient << 5'd13 :
                       ~(|shift_quotient[31:20]) ? shift_quotient << 5'd12 :
                       ~(|shift_quotient[31:21]) ? shift_quotient << 5'd11 :
                       ~(|shift_quotient[31:22]) ? shift_quotient << 5'd10 :
                       ~(|shift_quotient[31:23]) ? shift_quotient << 5'd9  :
                       ~(|shift_quotient[31:24]) ? shift_quotient << 5'd8  :
                       ~(|shift_quotient[31:25]) ? shift_quotient << 5'd7  :
                       ~(|shift_quotient[31:26]) ? shift_quotient << 5'd6  :
                       ~(|shift_quotient[31:27]) ? shift_quotient << 5'd5  :
                       ~(|shift_quotient[31:28]) ? shift_quotient << 5'd4  :
                       ~(|shift_quotient[31:29]) ? shift_quotient << 5'd3  :
                       ~(|shift_quotient[31:30]) ? shift_quotient << 5'd2  :
                       ~(|shift_quotient[31   ]) ? shift_quotient << 5'd1  : shift_quotient ;

wire [7:0] norm_quotient_bias;
assign norm_quotient_bias = ~(|shift_quotient[31:0 ])  ? quotient_exp_q - 8'd32 :
                            ~(|shift_quotient[31:1 ])  ? quotient_exp_q - 8'd31 :
                            ~(|shift_quotient[31:2 ])  ? quotient_exp_q - 8'd30 :
                            ~(|shift_quotient[31:3 ])  ? quotient_exp_q - 8'd29 :
                            ~(|shift_quotient[31:4 ])  ? quotient_exp_q - 8'd28 :
                            ~(|shift_quotient[31:5 ])  ? quotient_exp_q - 8'd27 :
                            ~(|shift_quotient[31:6 ])  ? quotient_exp_q - 8'd26 :
                            ~(|shift_quotient[31:7 ])  ? quotient_exp_q - 8'd25 :
                            ~(|shift_quotient[31:8 ])  ? quotient_exp_q - 8'd24 :
                            ~(|shift_quotient[31:9 ])  ? quotient_exp_q - 8'd23 :
                            ~(|shift_quotient[31:10])  ? quotient_exp_q - 8'd22 :
                            ~(|shift_quotient[31:11])  ? quotient_exp_q - 8'd21 :
                            ~(|shift_quotient[31:12])  ? quotient_exp_q - 8'd20 :
                            ~(|shift_quotient[31:13])  ? quotient_exp_q - 8'd19 :
                            ~(|shift_quotient[31:14])  ? quotient_exp_q - 8'd18 :
                            ~(|shift_quotient[31:15])  ? quotient_exp_q - 8'd17 :
                            ~(|shift_quotient[31:16])  ? quotient_exp_q - 8'd16 :
                            ~(|shift_quotient[31:17])  ? quotient_exp_q - 8'd15 :
                            ~(|shift_quotient[31:18])  ? quotient_exp_q - 8'd14 :
                            ~(|shift_quotient[31:19])  ? quotient_exp_q - 8'd13 :
                            ~(|shift_quotient[31:20])  ? quotient_exp_q - 8'd12 :
                            ~(|shift_quotient[31:21])  ? quotient_exp_q - 8'd11 :
                            ~(|shift_quotient[31:22])  ? quotient_exp_q - 8'd10 :
                            ~(|shift_quotient[31:23])  ? quotient_exp_q - 8'd9  :
                            ~(|shift_quotient[31:24])  ? quotient_exp_q - 8'd8  :
                            ~(|shift_quotient[31:25])  ? quotient_exp_q - 8'd7  :
                            ~(|shift_quotient[31:26])  ? quotient_exp_q - 8'd6  :
                            ~(|shift_quotient[31:27])  ? quotient_exp_q - 8'd5  :
                            ~(|shift_quotient[31:28])  ? quotient_exp_q - 8'd4  :
                            ~(|shift_quotient[31:29])  ? quotient_exp_q - 8'd3  :
                            ~(|shift_quotient[31:30])  ? quotient_exp_q - 8'd2  :
                            ~(|shift_quotient[31   ])  ? quotient_exp_q - 8'd1  : quotient_exp_q;

wire [31:0] div_result_754_pre;
assign div_result_754_pre[31] = (inputa_sign_754 ^ inputb_sign_754);
assign div_result_754_pre[30:23] = norm_quotient_bias;
assign div_result_754_pre[22:0] = norm_quotient[7] ? norm_quotient[30:8] + 23'b1 : {norm_quotient[30:9], 1'b0};

wire [31:0] div_result_754_qual;
assign div_result_754_qual = ~(|inputa_754) ? 32'b0: div_result_754_pre;

wire div_pre_done;
assign div_pre_done = fsmdiv_in_done;
dflip_en #(32) div_result_ff (.clk(clk), .rst(rst), .en(div_pre_done), .d(div_result_754_qual), .q(div_result_754)); 
dflip #(1) div_done_ff (.clk(clk), .rst(rst), .d(div_pre_done), .q(div_done)); 


endmodule;
