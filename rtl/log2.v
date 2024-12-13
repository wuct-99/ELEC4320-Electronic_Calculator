module log2(
    clk,
    rst,
    log2_start,
    log2_rst,
    input_value,
    log2_result_out,
    log2_done
);

input clk;
input rst;
input log2_start;
input log2_rst;
input [15:0] input_value;
output [31:0] log2_result_out;
output log2_done;

//normalize
wire [31:0] input_ext;
wire [31:0] input_div2i01;
wire [31:0] input_div2i02;
wire [31:0] input_div2i03;
wire [31:0] input_div2i04;
wire [31:0] input_div2i05;
wire [31:0] input_div2i06;
wire [31:0] input_div2i07;
wire [31:0] input_div2i08;
wire [31:0] input_div2i09;

wire [7:0] k_part;
wire [31:0] m_part;
wire log_cnt_en;
wire [4:0] log_cnt_d;
wire [4:0] log_cnt_q;
wire [63:0] m_sq2;
wire [31:0] m_sq2_final;
wire [31:0] m_sq2_q;
wire [23:0] log2_result;
wire [23:0] log2_result_q;

//log2,n base on binary search
//log2,n = k + log2,m for 1 <= m <= 2

//Counter
assign log_cnt_en = log2_start | log2_rst;
assign log_cnt_d = log2_rst ? 5'b0 : log_cnt_q + 5'b01;
dflip_en #(5) log_cnt_ff (.clk(clk), .rst(rst), .en(log_cnt_en), .d(log_cnt_d), .q(log_cnt_q));
//Using 24-1 cycle for 24bit 
//-1 is because of m * m in setup stage
assign log2_done = log_cnt_q == 5'd22;

//Get the K part
//The max input is 999 so the max K part is 9
assign input_ext = {input_value, 16'b0};

//Divide 2^i
assign input_div2i01 = {1'b0, input_ext[31:1]}; // 2^1
assign input_div2i02 = {2'b0, input_ext[31:2]}; // 2^2
assign input_div2i03 = {3'b0, input_ext[31:3]}; // 2^3
assign input_div2i04 = {4'b0, input_ext[31:4]}; // 2^4
assign input_div2i05 = {5'b0, input_ext[31:5]}; // 2^5
assign input_div2i06 = {6'b0, input_ext[31:6]}; // 2^6
assign input_div2i07 = {7'b0, input_ext[31:7]}; // 2^7
assign input_div2i08 = {8'b0, input_ext[31:8]}; // 2^8
assign input_div2i09 = {9'b0, input_ext[31:9]}; // 2^9

//Select k part if the integer is 1 after divide by 2^i
assign k_part = ~(|input_div2i01[31:17]) & input_div2i01[16] ? 8'd1 :
                ~(|input_div2i02[31:17]) & input_div2i02[16] ? 8'd2 :
                ~(|input_div2i03[31:17]) & input_div2i03[16] ? 8'd3 :
                ~(|input_div2i04[31:17]) & input_div2i04[16] ? 8'd4 :
                ~(|input_div2i05[31:17]) & input_div2i05[16] ? 8'd5 :
                ~(|input_div2i06[31:17]) & input_div2i06[16] ? 8'd6 :
                ~(|input_div2i07[31:17]) & input_div2i07[16] ? 8'd7 :
                ~(|input_div2i08[31:17]) & input_div2i08[16] ? 8'd8 : 8'd9;

//Select m part if the integer is 1 after divide by 2^i
assign m_part = ~(|input_div2i01[31:17]) & input_div2i01[16] ? {15'b0, input_div2i01[16:0]} :
                ~(|input_div2i02[31:17]) & input_div2i02[16] ? {15'b0, input_div2i02[16:0]} :
                ~(|input_div2i03[31:17]) & input_div2i03[16] ? {15'b0, input_div2i03[16:0]} :
                ~(|input_div2i04[31:17]) & input_div2i04[16] ? {15'b0, input_div2i04[16:0]} :
                ~(|input_div2i05[31:17]) & input_div2i05[16] ? {15'b0, input_div2i05[16:0]} :
                ~(|input_div2i06[31:17]) & input_div2i06[16] ? {15'b0, input_div2i06[16:0]} :
                ~(|input_div2i07[31:17]) & input_div2i07[16] ? {15'b0, input_div2i07[16:0]} :
                ~(|input_div2i08[31:17]) & input_div2i08[16] ? {15'b0, input_div2i08[16:0]} : {15'b0, input_div2i09[16:0]};

assign m_sq2 = ~(|log_cnt_q) ? m_part * m_part : m_sq2_q * m_sq2_q;
assign log2_result[23:1] = log2_result_q[22:0];
//if m*m >= 2, result[0] set 1
assign log2_result[0] = |m_sq2[63:33];
//remove 16bit fraction for next round
assign m_sq2_final = |m_sq2[63:33] ? m_sq2[48:17] : m_sq2[47:16];

dflip_en #(32) m_sq2_ff (.clk(clk), .rst(rst), .en(log_cnt_en), .d(m_sq2_final), .q(m_sq2_q));
dflip_en #(24) log2_result_ff (.clk(clk), .rst(rst), .en(log_cnt_en), .d(log2_result), .q(log2_result_q));

assign log2_result_out =  {k_part, log2_result};
endmodule;
