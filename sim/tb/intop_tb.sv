//import uvm_pkg::*;
`include "uvm_macros.svh"

module intop_tb;
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

    wire [4:0] board_cal_button;
    wire [11:0] board_cal_switchs;
    assign board_cal_button  = 'b0;
    assign board_cal_switchs = 'b0;
    
    int op;
    string tb_op;


    always @(*) begin
        #10
        clk <= ~clk;
    end
    
    initial begin
        clk = 0;
        #10 rst = 1'b1;
        #10 rst = 1'b0;
    end


    cal_top u_cal_top(
        .clk(clk                 ),
        .rst(rst                 ),
        .board_cal_button (board_cal_button),
        .board_cal_switchs(board_cal_switchs)
    );

    initial begin
        $fsdbDumpfile("./wave/intop_tb.fsdb");
        $fsdbDumpvars(0, intop_tb, "+all", "+mda", "+parameter");
        force u_cal_top.board_cal_switchs = 'b1;
        repeat(100) begin
            randcase
                1: op = 11'h1; //add
                1: op = 11'h2; //sub
                1: op = 11'h4; //mul
            endcase
            force u_cal_top.board_cal_switchs = op;

            a_digit3 = $urandom_range(0,9);
            a_digit2 = $urandom_range(0,9);
            a_digit1 = $urandom_range(0,9);
            a_sign   = $urandom_range(0,1);
            b_digit3 = $urandom_range(0,9);
            b_digit2 = $urandom_range(0,9);
            b_digit1 = $urandom_range(0,9);
            b_sign   = $urandom_range(0,1);
            
            inputa = a_digit3 * 100 + a_digit2 * 10 + a_digit1;
            inputb = b_digit3 * 100 + b_digit2 * 10 + b_digit1;
            inputa_qual = a_sign ? inputa * -1 : inputa;
            inputb_qual = b_sign ? inputb * -1 : inputb;

            case(op)
                11'h1: tb_int_result = inputa_qual + inputb_qual;
                11'h2: tb_int_result = inputa_qual - inputb_qual;
                11'h4: tb_int_result = inputa_qual * inputb_qual;
            endcase
            case(op)
                11'h1: tb_op = "add";
                11'h2: tb_op = "sub";
                11'h4: tb_op = "mul";
            endcase

            tb_int_result_qual = tb_int_result < 0 ? tb_int_result * -1 : tb_int_result;
            tb_sign_result = tb_int_result < 0;
            
            $display("OP: %s", tb_op);
            $display("input a NUM: %d, %d", inputa, inputa_qual);
            $display("a3, a2, a1: %d, %d, %d", a_digit3, a_digit2, a_digit1);
            $display("input b NUM: %d, %d", inputb, inputb_qual);
            $display("b3, b2, b1: %d, %d, %d", b_digit3, b_digit2, b_digit1);
            $display("Result: %d ", tb_int_result_qual);
            
            wait(u_cal_top.fsmc_in_inputa);
            $display("inputa");
            repeat(10) @(posedge clk);
            force u_cal_top.board_cal_button = 'b1_0000;
            repeat(2) @(posedge clk);
            release u_cal_top.board_cal_button;
            $display("inputa break");
            
            wait (u_cal_top.fsmc_in_inputb == 1);
            $display("inputb");
            force u_cal_top.a_digit0 = a_digit1; 
            force u_cal_top.a_digit1 = a_digit2; 
            force u_cal_top.a_digit2 = a_digit3; 
            force u_cal_top.a_sign   = a_sign; 
            force u_cal_top.b_digit0 = b_digit1; 
            force u_cal_top.b_digit1 = b_digit2; 
            force u_cal_top.b_digit2 = b_digit3;
            force u_cal_top.b_sign   = b_sign; 
            repeat(10) @(posedge clk);
            force u_cal_top.board_cal_button = 'b1_0000;
            repeat(2) @(posedge clk);
            release u_cal_top.board_cal_button; //Release previous middle button
            
            
            $display("inputb break");
            
            wait (u_cal_top.fsmc_in_display==1);
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
            
            while (u_cal_top.fsmc_in_display) begin
                $display("last stage");
                repeat(10) @(posedge clk);
                force u_cal_top.board_cal_button = 5'b1_0000;
                @(posedge clk);
                release u_cal_top.board_cal_button;
            end
        end
        $display("FInish");
        $finish;
    end

endmodule
