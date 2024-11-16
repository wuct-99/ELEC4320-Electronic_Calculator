`ifndef CFG_TRANSACTION_SV
`define CFG_TRANSACTION_SV
class cfg_transaction extends uvm_sequence_item;
    //rand bit core_rstn;

	`uvm_object_utils_begin(cfg_transaction)
        //`uvm_field_int(start_pulse, UVM_DEFAULT)
	`uvm_object_utils_end
	
	function new(string name="cfg_transaction", uvm_component parent = null);
	    super.new(name);
    endfunction

    //extern constraint cons_start_pulse;
endclass

`endif
