`ifndef CFG_INTERFACE_SV
`define CFG_INTERFACE_SV

interface cfg_interface(input clk);
	logic start_pulse;
    logic core_rstn;

	clocking drv_cb @(posedge clk);
        output start_pulse;
        output core_rstn;
    endclocking	

	clocking mon_cb @(posedge clk);
        input start_pulse;
        input core_rstn;
    endclocking	
endinterface 
`endif
