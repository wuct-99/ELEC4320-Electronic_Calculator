//***** binary to bcd double dapple converter
module bin_2_bcd_dd_mod(
clk,
rst_n,
conv_start,
conv_rslt_rdy,
in_bin_digits,
out_bcd_digits
);

input clk;
input rst_n;
input conv_start;
input [31:0] in_bin_digits;

output reg conv_rslt_rdy;
//output reg [39:0] out_bcd_digits;
output reg [31:0] out_bcd_digits;

//reg [39:0] bcd_buf;
reg [31:0] bcd_buf;
reg [31:0] bin_digits_buf;
reg conv_start_ff;
reg conv_rslt_rdy_pre;
reg out_bcd_digits_d;
reg converting;

assign out_bcd_digits = out_bcd_digits_d;
assign conv_rslt_rdy  = conv_rslt_rdy_pre;
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
       bcd_buf <= 'b0;
       bin_digits_buf <= 'b0;
       conv_start_ff <= 'b0;
       conv_rslt_rdy_pre <= 'b0;
       out_bcd_digits_d <= 'b0;
       converting <= 'b0;
    end
    else begin 
       conv_start_ff <= conv_start;
       if(conv_start & !converting) begin
           bin_digits_buf <= in_bin_digits;
           converting <= 1'b1;
       end
       if(conv_start_ff) begin
           for(i = 0; i < 32; i = i+1) begin
              //bcd_buf <= {bcd_buf[38:0],bin_digits_buf[31]};
              bcd_buf <= {bcd_buf[30:0],bin_digits_buf[31]};
              bin_digits_buf <= bin_digits_buf << 1;
              if(bcd_buf[3:0] > 4'h4) begin
                 bcd_buf[3:0] <= bcd_buf[3:0] + 4'h3;
              end
              if(bcd_buf[7:4] > 4'h4) begin
                 bcd_buf[7:4] <= bcd_buf[7:4] + 4'h3;
              end
              if(bcd_buf[11:8] > 4'h4) begin
                 bcd_buf[11:8] <= bcd_buf[3:0] + 4'h3;
              end
              if(bcd_buf[15:12] > 4'h4) begin
                 bcd_buf[15:12] <= bcd_buf[15:12] + 4'h3;
              end
              if(bcd_buf[19:16] > 4'h4) begin
                 bcd_buf[19:16] <= bcd_buf[19:16] + 4'h3;
              end
              if(bcd_buf[23:20] > 4'h4) begin
                 bcd_buf[23:20] <= bcd_buf[23:20] + 4'h3;
              end
              if(bcd_buf[27:24] > 4'h4) begin
                 bcd_buf[27:24] <= bcd_buf[27:24] + 4'h3;
              end
              if(bcd_buf[31:28] > 4'h4) begin
                 bcd_buf[31:28] <= bcd_buf[31:28] + 4'h3;
              end
              if(bcd_buf[35:32] > 4'h4) begin
                 bcd_buf[35:32] <= bcd_buf[35:32] + 4'h3;
              end
               if(bcd_buf[39:36] > 4'h4) begin
                 bcd_buf[39:36] <= bcd_buf[39:36] + 4'h3;
              end
           end
           conv_rslt_rdy <= 1'b1;
           converting <= 1'b0;
           out_bcd_digits_d <= bcd_buf;
        end
    end
end
endmodule
