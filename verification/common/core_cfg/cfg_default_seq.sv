`ifndef CFG_DEFAULT_SEQ_SV
`define CFG_DEFAULT_SEQ_SV
class cfg_default_seq extends uvm_sequence;
    `uvm_object_utils(cfg_default_seq);	

    function new(string name="cfg_default_seq");
        super.new(name);
	endfunction

    virtual task body();
        repeat(1000) begin
            cfg_transaction cfg_trans = cfg_transaction::type_id::create("cfg_trans");
		    `uvm_info(get_type_name(), "Loop", UVM_HIGH);
            start_item(cfg_trans);
            cfg_trans.randomize();
            finish_item(cfg_trans);
		end
	endtask
endclass
`endif
