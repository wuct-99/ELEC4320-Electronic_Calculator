module clock_divider(
clk,
rst_n,
clk_1khz_out
);

input clk;
input rst_n;
output clk_1khz_out;
//assume clock in is 200Mhz
parameter DIVISOR = 11'd2000;
reg [10:0] counter;
reg out_clk;

always @(posedge clk or negedge rst_n) begin
    if(rst_n) begin
        counter <= 11'b0;
        out_clk <= 1'b0;
    end
    else begin
	       if(counter < 1000) begin
            out_clk <= 1'b1;
        end
        if(counter > 1000) begin
            out_clk <= 1'b0;
        end

        if(counter >= (DIVISOR - 1)) begin
            counter <= 28'b0;
        end
        counter <= counter + 1;
    end
end

assign clk_1khz_out = out_clk; 

