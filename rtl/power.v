module power (
    clk,
    rst_n,
    pow_vld,
    src1,
    src2,
    src1_sign,
    src2_sign,
    pow_res,
    pow_done,
    pow_sign
);

// Module Interface
input           clk;
input           rst_n;
input           pow_vld;
input   [15:0]  src1;
input   [15:0]  src2;
input           src1_sign;
input           src2_sign;

output  [31:0]  pow_res;
output          pow_done;
output          pow_sign;

// Internal Signals
wire            power_ovf; 
wire    [32:0]  power_data;
wire    [32:0]  power_data_nc;
wire    [3:0]   cnt;
wire    [3:0]   cnt_nc;
wire            cnt_en;

// Control Logic
assign  cnt_en = pow_vld & ~pow_done;
assign  cnt_nc = (pow_vld)? (cnt + 1'b1) : 4'b0;
dffre #(4) counter (.clk(clk), .rst_n(rst_n), .en(cnt_en), .d(cnt_nc), .q(cnt));
assign  pow_done = (cnt == src2[3:0]);

// Power Datapath
assign  pow_sign        = (~src2_sign)? 1'b0 : src1_sign;
assign  pow_res         = (src2 == 16'b0)? 32'b0 : (power_ovf)? 32'hFFFF_FFFF : power_data[31:0];
assign  power_ovf       = power_data[32];
assign  power_data_nc   = (pow_done)? 33'b0 : (power_data * src1);
dffre #(32) power_data (.clk(clk), .rst_n(rst_n), .en(cnt_en), .d(power_data_nc), .q(power_data)); 

endmodule