`ifndef CFG_INTERFACE_SV
`define CFG_INTERFACE_SV

interface cfg_interface(input clk);
	logic [4:0] board_cal_button;
	logic [14:0] board_cal_switchs;

	clocking drv_cb @(posedge clk);
        //output start_pulse;
	    output board_cal_button;
        output board_cal_switchs;
    endclocking	

	clocking mon_cb @(posedge clk);
        //input start_pulse;
        //input core_rstn;
	    input board_cal_button;
        input board_cal_switchs;
    endclocking	
endinterface 
`endif
