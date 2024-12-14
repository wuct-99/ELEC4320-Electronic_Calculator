module sqrt (
    clk,
    rst_n,
    src1,
    sqrt_vld,
    sqrt_done,
    sqrt_res,
);

// Module Interface
input           clk;
input           rst_n;
input   [15:0]  src1;
input           sqrt_vld;

output  [31:0]  sqrt_res;
output          sqrt_done;

// Internal Signals
wire    [4:0]   cnt_nc;
wire    [4:0]   cnt;
wire    []

// Square Root Datapath


// Control Logic
assign  cnt_nc      = (sqrt_vld)? (cnt + 1'b1) : 5'b0;
assign  sqrt_done   = (cnt_nc == 5'd23)
dffre #(5) counter (.clk(clk), .rst_n(rst_n), .en(sqrt_vld), .d(cnt_nc), .q(cnt));

endmodule