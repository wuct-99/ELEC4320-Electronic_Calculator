// DFF with reset & enable 

module dffre #(parameter BIT_WIDTH = 1)(
clk,
rst_n,
en,
d,
q);

input clk;
input rst_n;
input en;
input [BIT_WIDTH -1:0] q;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        q <= {BIT_WIDTH{1'b0}};
	   end
    else if(en) begin
        q <= d;
    end
end 

endmodule

