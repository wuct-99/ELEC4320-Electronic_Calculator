`include "cfg_interface.sv"

package cfg_package;
    import uvm_pkg::*;
				
    `include "cfg_transaction.sv"
    `include "cfg_driver.sv" 
    `include "cfg_monitor.sv" 
    `include "cfg_agent.sv"
    `include "cfg_default_seq.sv" 	
endpackage
