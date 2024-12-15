//import uvm_pkg::*;
`include "uvm_macros.svh"

module tri_tb;
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
    
    real tb_result;
    real tb_frac_result;
    real dut_frac_result;
    real tb_frac_result_pre;
    real tb_frac_result_diff;
    real rad_a;

    int tb_result_qual;
    int tb_int_result;
    int tb_sign_result;

    wire [4:0] board_cal_button;
    wire [11:0] board_cal_switchs;
    assign board_cal_button  = 'b0;
    assign board_cal_switchs = 'b0;
    
    int op;
    string tb_op;

    bit invalid;

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
        $fsdbDumpfile("./wave/tri_tb.fsdb");
        $fsdbDumpvars(0, tri_tb, "+all", "+mda", "+parameter");
        force u_cal_top.board_cal_switchs = 'b1;
        repeat(1000) begin
            $display("--------NEW--------------");
            randcase
                //1: op = 11'h1; //add
                //1: op = 11'h2; //sub
                //1: op = 11'h4; //mul
                //1: op = 11'h8; //division
                1: op = 11'h20; //cos
                1: op = 11'h40; //sin
                1: op = 11'h80; //tan
            endcase
            force u_cal_top.board_cal_switchs = op;

            a_digit2 = $urandom_range(0,9);
            a_digit1 = $urandom_range(0,9);
            a_sign   = $urandom_range(0,1);
            b_digit3 = $urandom_range(0,9);
            b_digit2 = $urandom_range(0,9);
            b_digit1 = $urandom_range(0,9);
            b_sign   = $urandom_range(0,1);

            if(op == 11'h20 | op == 11'h40 | op == 11'h80) begin //cos
                randcase
                    1: a_digit3 = $urandom_range(0,9);
                    9: a_digit3 = 0;
                endcase 
            end
            else begin
                a_digit3 = $urandom_range(0,9);
            end

            inputa = a_digit3 * 100 + a_digit2 * 10 + a_digit1;
            inputb = b_digit3 * 100 + b_digit2 * 10 + b_digit1;
            inputa_qual = a_sign ? inputa * -1 : inputa;
            inputb_qual = b_sign ? inputb * -1 : inputb;
            rad_a = inputa_qual * 3.1415/180.0;
            
            invalid = 0;
            case(op)
                11'h8 : invalid = inputb == 0;
                11'h20: invalid = inputa > 90;
                11'h40: invalid = inputa > 90;
                11'h80: invalid = inputa >= 90;
            endcase

            case(op)
                11'h1 : tb_result = inputa_qual + inputb_qual;
                11'h2 : tb_result = inputa_qual - inputb_qual;
                11'h4 : tb_result = inputa_qual * inputb_qual;
                11'h8 : tb_result = 1.0 * inputa_qual / inputb_qual;
                11'h20: tb_result = 1.0 * $cos(rad_a);
                11'h40: tb_result = 1.0 * $sin(rad_a);
                11'h80: tb_result = 1.0 * $tan(rad_a);
            endcase

            case(op)
                11'h1 : tb_int_result = inputa_qual + inputb_qual;
                11'h2 : tb_int_result = inputa_qual - inputb_qual;
                11'h4 : tb_int_result = inputa_qual * inputb_qual;
                11'h8 : tb_int_result = inputa_qual / inputb_qual;
                11'h20: tb_int_result = $cos(rad_a) > 0 ? $floor($cos(rad_a)) : $ceil($cos(rad_a));
                11'h40: tb_int_result = $sin(rad_a) > 0 ? $floor($sin(rad_a)) : $ceil($sin(rad_a));
                11'h80: tb_int_result = $tan(rad_a) > 0 ? $floor($tan(rad_a) + 0.0001) : $ceil($tan(rad_a) + 0.0001);
            endcase

            //special case
            
            case(op)
                11'h1 : tb_op = "add";
                11'h2 : tb_op = "sub";
                11'h4 : tb_op = "mul";
                11'h8 : tb_op = "div";
                11'h20: tb_op = "cos";
                11'h40: tb_op = "sin";
                11'h80: tb_op = "tan";
            endcase

            tb_frac_result_pre = (tb_result - tb_int_result*1.0);
            tb_frac_result = tb_result < 0 ? tb_frac_result_pre * -1.0 : tb_frac_result_pre;

            tb_result_qual = tb_int_result < 0 ? tb_int_result * -1 : tb_int_result;
            tb_sign_result = tb_result < 0;

            //Special
            if(op == 11'h40) begin //sin
                tb_result_qual = inputa == 90 ? 1 : tb_result_qual;
                tb_frac_result = inputa == 90 ? 0 : tb_frac_result;
            end
            else if(op == 11'h80) begin //tan
                tb_result_qual = inputa == 0  ? 0 :
                                 inputa == 45 ? 1 : tb_result_qual;
                tb_frac_result = inputa == 0  ? 0 :
                                 inputa == 45 ? 0 : tb_frac_result;
            end




            
            $display("OP: %s", tb_op);
            $display("input a NUM: %d, %d", inputa, inputa_qual);
            $display("a3, a2, a1: %d, %d, %d", a_digit3, a_digit2, a_digit1);
            $display("input b NUM: %d, %d", inputb, inputb_qual);
            $display("b3, b2, b1: %d, %d, %d", b_digit3, b_digit2, b_digit1);

            $display("Result: %f ", tb_result);
            $display("Sign Result: %d ", tb_sign_result);
            $display("Int Result: %d ", tb_result_qual);
            $display("Frac Result: %f ", tb_frac_result);
            $display("Invalid: %d ", invalid);
            
            wait(u_cal_top.fsmc_in_inputa);
            //$display("inputa");
            repeat(10) @(posedge clk);
            force u_cal_top.board_cal_button = 'b1_0000;
            repeat(2) @(posedge clk);
            release u_cal_top.board_cal_button;
            //$display("inputa break");
            
            wait (u_cal_top.fsmc_in_inputb == 1);
            //$display("inputb");
            force u_cal_top.a_digit0 = a_digit1; 
            force u_cal_top.a_digit1 = a_digit2; 
            force u_cal_top.a_digit2 = a_digit3; 
            force u_cal_top.a_sign   = a_sign; 
            force u_cal_top.b_digit0 = b_digit1; 
            force u_cal_top.b_digit1 = b_digit2; 
            force u_cal_top.b_digit2 = b_digit3;
            force u_cal_top.b_sign   = b_sign; 
            repeat(100) @(posedge clk);
            force u_cal_top.board_cal_button = 'b1_0000;
            repeat(2) @(posedge clk);
            release u_cal_top.board_cal_button; //Release previous middle button
            
            
            //$display("inputb break");
            
            wait (u_cal_top.fsmc_in_display==1);
            //$display("Display");
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
            if(~invalid) begin
                if(tb_result_qual != u_cal_top.int_result_cvt_pre_q) begin
                    $fatal("Integer Mismatch: RTL %d, RM %d", u_cal_top.int_result_cvt_pre_q, tb_result_qual);
                end
                if(tb_sign_result != u_cal_top.result_sign) begin
                    $fatal("Sign Mismatch: RTL %d, RM %d", u_cal_top.result_sign, tb_sign_result);
                end

                dut_frac_result = 0;
                dut_frac_result = u_cal_top.frac_part[23] * 2.0**(-1) +  
                                 u_cal_top.frac_part[22] * 2.0**(-2) +  
                                 u_cal_top.frac_part[21] * 2.0**(-3) +  
                                 u_cal_top.frac_part[20] * 2.0**(-4) +  
                                 u_cal_top.frac_part[19] * 2.0**(-5) +  
                                 u_cal_top.frac_part[18] * 2.0**(-6) +  
                                 u_cal_top.frac_part[17] * 2.0**(-7) +  
                                 u_cal_top.frac_part[16] * 2.0**(-8) +  
                                 u_cal_top.frac_part[15] * 2.0**(-9) +  
                                 u_cal_top.frac_part[14] * 2.0**(-10) +  
                                 u_cal_top.frac_part[13] * 2.0**(-11) +  
                                 u_cal_top.frac_part[12] * 2.0**(-12) +  
                                 u_cal_top.frac_part[11] * 2.0**(-13) +  
                                 u_cal_top.frac_part[10] * 2.0**(-14) +  
                                 u_cal_top.frac_part[ 9] * 2.0**(-15) +  
                                 u_cal_top.frac_part[ 8] * 2.0**(-16) +  
                                 u_cal_top.frac_part[ 7] * 2.0**(-17) +  
                                 u_cal_top.frac_part[ 6] * 2.0**(-18) +  
                                 u_cal_top.frac_part[ 5] * 2.0**(-19) +  
                                 u_cal_top.frac_part[ 4] * 2.0**(-20) +  
                                 u_cal_top.frac_part[ 3] * 2.0**(-21) +  
                                 u_cal_top.frac_part[ 2] * 2.0**(-22) +  
                                 u_cal_top.frac_part[ 1] * 2.0**(-23) +  
                                 u_cal_top.frac_part[ 0] * 2.0**(-24) ;  

                tb_frac_result_diff = tb_frac_result - dut_frac_result;
                $display("Frac diff: %f", tb_frac_result_diff);

                if(tb_frac_result_diff > 0.005 ) begin
                    $fatal("Frac Mismatch: RTL %f, RM %f", dut_frac_result, tb_frac_result);
                end
            end
            else begin
                if(~u_cal_top.invld_result) begin
                    $fatal("DUT invld result is 0");
                end
            end
            
            while (u_cal_top.fsmc_in_display) begin
                //$display("last stage");
                repeat(5000) @(posedge clk);
                force u_cal_top.board_cal_button = 5'b1_0000;
                @(posedge clk);
                release u_cal_top.board_cal_button;
            end
        end
        $display("FInish");
        $finish;
    end

endmodule
