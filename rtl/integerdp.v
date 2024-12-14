module integerdp (
    clk,
    rst_n,
    dp_src1,
    dp_src2,
    dp_src1_sign,
    dp_src2_sign,
    int_dp_mode,
    int_res,
    int_res_sign,
    int_res_vld
)

// Addition, Subtraction, Multiplication

// Module Interface
input           clk;
input           rst_n;
input   [2:0]   int_dp_mode;
input   [15:0]  dp_src1;
input   [15:0]  dp_src2;
input           dp_src1_sign;
input           dp_src2_sign;

output  [31:0]  int_res;
output          int_res_sign;
output          int_res_vld;

// Internal Signals
wire            add_vld;
wire            sub_vld;
wire            mul_vld;
wire    [31:0]  add_res_2scmp;
wire    [31:0]  sub_res_2scmp;
wire    [31:0]  add_res;
wire    [31:0]  sub_res;
wire    [31:0]  mul_res;
wire            mul_sign;

// Integer Datapath (1 Cycle)
assign  add_vld     = int_dp_mode[0];
assign  sub_vld     = int_dp_mode[1];
assign  mul_vld     = int_dp_mode[2];

assign  add_res_2scmp = dp_src1 + dp_src2;
assign  sub_res_2scmp = dp_src1 - dp_src2;

assign  add_res     = (add_res_2scmp[31])? ((~add_res_2scmp) + 1'b1) : add_res_2scmp;
assign  sub_res     = (sub_res_2scmp[31])? ((~sub_res_2scmp) + 1'b1) : sub_res_2scmp;  
assign  mul_res     = dp_src1 * dp_src2;
assign  mul_sign    = dp_src1_sign ^ dp_src2_sign;

assign  int_res  = ((32{add_vld}) & add_res) |
                   ((32{sub_vld}) & sub_res) |
                   ((32{mul_vld}) & mul_vld);

assign  int_res_sign = (add_vld & add_res_2scmp[31]) | (sub_vld & sub_res_2scmp) | 
                       (mul_vld & mul_sign);

assign  int_res_vld  = add_vld | sub_vld | mul_vld;

endmodule