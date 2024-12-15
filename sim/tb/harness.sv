//import uvm_pkg::*;
`include "uvm_macros.svh"

module harness;
    reg clk;
    reg rst;
    int a_digit1;
    int a_digit2;
    int a_digit3;
    int b_digit1;
    int b_digit2;
    int b_digit3;
    int inputa;
    int inputb;
    int inputa_qual;
    int inputb_qual;
    int a_sign;
    int b_sign;
    
    int tb_int_result;
    int tb_int_result_qual;
    int tb_sign_result;

    always @(*) begin
        #10
        clk <= ~clk;
    end
    
    initial begin
        clk = 0;
        #10 rst = 1'b1;
        #10 rst = 1'b0;
    end

    cfg_interface cfg_intf(.clk(clk));
    chk_interface chk_intf(.clk(clk));

    cal_top u_cal_top(
        .clk(clk                 ),
        .rst(rst                 ),
        .board_cal_button(cfg_intf.board_cal_button),
        .board_cal_switchs(cfg_intf.board_cal_switchs)
    );

    initial begin
        virtual cfg_interface vir_cfg_intf;
        virtual chk_interface vir_chk_intf;
        vir_cfg_intf = cfg_intf;
        vir_chk_intf = chk_intf;
        //Send the cfg_interface to TC
        uvm_config_db#(virtual cfg_interface)::set(null, "", "cfg_interface", vir_cfg_intf);
        uvm_config_db#(virtual chk_interface)::set(null, "", "chk_interface", vir_chk_intf);
        run_test();
    end

    always @(posedge clk) begin
    end

    always @(*) begin
    end

    initial begin
        //force u_cal_top.op_qual = 14'b1000; //Divide
        //force u_cal_top.op_qual = 14'b10000; //sqrt
        //force u_cal_top.op_qual = 14'b100000; //cos
        //force u_cal_top.op_qual = 14'b1000000; //sin
        //force u_cal_top.op_qual = 14'b1000_0000; //tan
        //force u_cal_top.op_qual = 14'b10_0000_0000; //power
        //force u_cal_top.op_qual = 14'b100_0000_0000; //exp
        //force u_cal_top.op_qual = 14'b1_0000_0000; //LOG
        //force u_cal_top.op_qual = 14'b100_0000_0000; //exp
       force u_cal_top.board_cal_switchs = 'b1;

       for(a_sign = 'd0; a_sign <= 1; a_sign++) begin
           for(inputa = 'd0; inputa <= 999; inputa++) begin
               for(b_sign = 'd0; b_sign <= 1; b_sign++) begin
                   for(inputb = 'd0; inputb <=999; inputb++) begin
                       inputa_qual = a_sign ? inputa * -1 : inputa;
                       inputb_qual = b_sign ? inputb * -1 : inputb;

                       tb_int_result = inputa_qual + inputb_qual;
                       tb_int_result_qual = tb_int_result < 0 ? tb_int_result * -1 : tb_int_result;
                       tb_sign_result = tb_int_result < 0;


                       a_digit3 = inputa / 100;
                       a_digit2 = (inputa - (a_digit3 * 100)) / 10 ;
                       a_digit1 = (inputa - (a_digit3 * 100) - (a_digit2 * 10));

                       b_digit3 = inputb / 100;
                       b_digit2 = (inputb - (b_digit3 * 100)) / 10 ;
                       b_digit1 = (inputb - (b_digit3 * 100) - (b_digit2 * 10));
 

                       $display("input a NUM: %d, %d", inputa, inputa_qual);
                       $display("a3, a2, a1: %d, %d, %d", a_digit3, a_digit2, a_digit1);
                       $display("input b NUM: %d, %d", inputb, inputb_qual);
                       $display("b3, b2, b1: %d, %d, %d", b_digit3, b_digit2, b_digit1);
                       $display("Result: %d ", tb_int_result_qual);

                       while(1) begin
                           @(posedge clk);
                           if(u_cal_top.fsmc_in_inputa) begin
                              $display("inputa");
                              #1000
                              force u_cal_top.board_cal_button = 'b1_0000;
                              #1000
                              release u_cal_top.board_cal_button;
                              $display("inputa break");
                              break;
                           end
                       end

                       while(1) begin
                           @(posedge clk);
                           if(u_cal_top.fsmc_in_inputb) begin
                              $display("inputb");
                              #1000
                              force u_cal_top.board_cal_button = 'b1_0000;

                              force u_cal_top.a_digit0 = a_digit1; 
                              force u_cal_top.a_digit1 = a_digit2; 
                              force u_cal_top.a_digit2 = a_digit3; 
                              force u_cal_top.a_sign   = a_sign; 
                              force u_cal_top.b_digit0 = b_digit1; 
                              force u_cal_top.b_digit1 = b_digit2; 
                              force u_cal_top.b_digit2 = b_digit3;
                              force u_cal_top.b_sign   = b_sign; 
                              #100
                              release u_cal_top.board_cal_button; //Release previous middle button
                              $display("inputb break");
                              break;
                           end
                       end

                       while(1) begin
                           @(posedge clk);
                           if(u_cal_top.fsmc_in_display) begin
                               $display("Display");
                               release u_cal_top.a_digit0; 
                               release u_cal_top.a_digit1; 
                               release u_cal_top.a_digit2; 
                               release u_cal_top.a_sign  ; 
                               release u_cal_top.b_digit0; 
                               release u_cal_top.b_digit1; 
                               release u_cal_top.b_digit2; 
                               release u_cal_top.b_sign  ;  

                               //Checking                            
                               $display("Check");
                               if(tb_int_result_qual != u_cal_top.int_result_cvt_pre_q) begin
                                   $fatal("Integer Mismatch: RTL %d, RM %d", u_cal_top.int_result_cvt_pre_q, tb_int_result_qual);
                               end
                               if(tb_sign_result != u_cal_top.result_sign) begin
                                   $fatal("Sign Mismatch: RTL %d, RM %d", u_cal_top.result_sign, tb_sign_result);
                               end

                               if(u_cal_top.cal_board_display_stage == 1) begin
                                   $display("last stage");
                                   force u_cal_top.board_cal_button = 'b1_0000;
                                   @(posedge clk);
                                   release u_cal_top.board_cal_button;
                                   break;
                               end
                               else begin
                                   repeat (u_cal_top.cal_board_display_stage) begin
                                       $display("loop");
                                       #1000
                                       force u_cal_top.board_cal_button = 'b1_0000;
                                       @(posedge clk);
                                       release u_cal_top.board_cal_button;
                                   end
                                   break;
                               end
                               $display("Display break");
                           end
                       end
                   end
               end
           end
       end
    end

endmodule
