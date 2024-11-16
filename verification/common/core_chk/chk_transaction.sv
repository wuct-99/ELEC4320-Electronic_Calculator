`ifndef CHK_TRANSACTION_SV
`define CHK_TRANSACTION_SV
class chk_transaction extends uvm_sequence_item;
    //bit [31:0] ireg [32];
    //bit [31:0] pc;
    //bit [31:0] dmem [4][256];
    
	`uvm_object_utils_begin(chk_transaction)
    //`uvm_field_sarray_int(ireg, UVM_DEFAULT)
	`uvm_object_utils_end
	
	function new(string name="chk_transaction", uvm_component parent = null);
	    super.new(name);
    endfunction
	
endclass

`endif
