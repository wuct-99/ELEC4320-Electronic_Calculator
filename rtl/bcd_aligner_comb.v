//aligner for both operations involving integer and floating point 

module bin_2_bcd_comb(
clk,
rst_n,
align_in_data,
align_rslt_vld,
align_rslt_data,
align_data_dp_pos,
align_rslt_8_bit
);

input clk;
input rst_n;

input [63:0] align_in_data;
input        align_start_en;//need to pass by ff? assume toggle signal

output [31:0] align_rslt_data;
output        align_rslt_vld;
output [7:0]  align_data_dp_pos;
output        align_rslt_8_bit;


reg        aligning; 
reg [63:0] align_in_data_buf;
reg        align_shift_end;
reg [7:0]  starting_dp_pos;//onehot


assign align_rslt_8_bit = (|align_rslt_data[32:16]);
assign align_rslt_vld = align_shift_end;
assign align_rslt_data = align_in_data_buf;
assign align_data_dp_pos = starting_dp_pos; 
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin 
        align_in_data_buf <='b0;
        align_shift_end <= 'b0;
        starting_dp_pos <= 'b0;
    end 
    else if(align_start_en & aligning) begin
        align_in_data_buf <= align_in_data;
        starting_dp_pos <= 8'b10000000;
        aligining <= 1'b1;
    end 
    else if (aligning) begin
        if(~(|align_in_data_buf[4:0])) begin
            align_in_data_buf <= align_in_data_buf >> 4'd4;
            starting_dp_pos <= starting_dp_pos >> 'b1 ;
        end
        else begin 
            align_shift_end <= 1'b1;
			         aligning <= 1'b0;
        end
    end
end
endmodule 
