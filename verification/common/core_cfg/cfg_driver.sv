`ifndef CFG_DRIVER_SV
`define CFG_DRIVER_SV
class cfg_driver extends uvm_driver #(cfg_transaction);
    int delay;
    int cnt;
    uvm_event preload_trigger_event;
	`uvm_component_utils(cfg_driver)
	
	virtual cfg_interface cfg_intf;		
	
	extern function new(string name="cfg_driver", uvm_component parent=null);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

function cfg_driver::new(string name="cfg_driver", uvm_component parent=null);
	super.new(name, parent);
endfunction	

function void cfg_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);
    //Get the cfg_interface from TC
	if(!uvm_config_db#(virtual cfg_interface)::get(this, "", "cfg_interface", cfg_intf))
		`uvm_fatal(get_type_name(), "Could not get cfg interface")
endfunction 

task cfg_driver::run_phase(uvm_phase phase);
	super.run_phase(phase);
	while(1) begin
		cfg_transaction cfg_trans;
		`uvm_info(get_type_name(), "Wait for item for sequencer", UVM_HIGH)
        @(posedge cfg_intf.clk);	
		seq_item_port.get_next_item(cfg_trans);
        cfg_intf.drv_cb.board_cal_button  <= cfg_trans.board_cal_button;
        cfg_intf.drv_cb.board_cal_switchs <= cfg_trans.board_cal_switchs;
        repeat (2000) @(posedge cfg_intf.clk);	
		seq_item_port.item_done();
	end
endtask

`endif
