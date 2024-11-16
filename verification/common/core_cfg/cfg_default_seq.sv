`ifndef CFG_DEFAULT_SEQ_SV
`define CFG_DEFAULT_SEQ_SV
class cfg_default_seq extends uvm_sequence;
    `uvm_object_utils(cfg_default_seq);	

    function new(string name="cfg_default_seq");
        super.new(name);
	endfunction

    virtual task body();
        while(1) begin
            //cfg_transaction cfg_trans = cfg_transaction::type_id::create("cfg_trans");
		    //`uvm_info(get_type_name(), "Loop", UVM_HIGH);
            //start_item(cfg_trans);
            //cfg_trans.randomize();
            //finish_item(cfg_trans);
            //if(cfg_trans.start_pulse & cfg_trans.core_rstn) begin
		    //    `uvm_info(get_type_name(), $sformatf("Done"), UVM_HIGH);
            //    break;
            //end
		end
	endtask
endclass
`endif
