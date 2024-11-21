`ifndef CFG_INTERFACE_SV
`define CFG_INTERFACE_SV

interface cfg_interface(input clk);
	logic [4:0] board_cal_button;

	clocking drv_cb @(posedge clk);
        //output start_pulse;
	    output board_cal_button;
    endclocking	

	clocking mon_cb @(posedge clk);
        //input start_pulse;
        //input core_rstn;
	    input board_cal_button;
    endclocking	
endinterface 
`endif
