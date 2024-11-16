//import uvm_pkg::*;
`include "uvm_macros.svh"

module harness;
    reg clk;

    always @(*) begin
        #10
        clk <= ~clk;
    end
    
    initial begin
        clk = 0;
    end

    cfg_interface cfg_intf(.clk(clk));
    chk_interface chk_intf(.clk(clk));

    cal_top u_cal_top(
        .clk(clk                 )
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

endmodule
