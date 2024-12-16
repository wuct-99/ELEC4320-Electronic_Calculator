module debounce(
    clk,
    rst,
    button_in, 
    button_out
);

input clk;
input rst;
input button_in;
output button_out;

wire [4:0] cnt;
wire [4:0] cnt_q;
wire button;
wire button_q;

assign cnt =  button_in            ? 5'b0 : 
             ~button_in & (&cnt_q) ? cnt_q : cnt_q + 5'b1;

dflip #(5) cnt_ff (.clk(clk), .rst(rst), .d(cnt), .q(cnt_q));

assign button = cnt == 5'h1e;
dflip button_ff (.clk(clk), .rst(rst), .d(button), .q(button_q));

assign button_out = button_q;

endmodule
