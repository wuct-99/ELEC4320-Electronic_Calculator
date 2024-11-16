`include "chk_interface.sv"

package chk_package;
    import uvm_pkg::*;
				
    `include "chk_transaction.sv"
    `include "chk_monitor.sv"
    `include "chk_agent.sv"
endpackage
