`ifndef TC_SANITY_SV
`define TC_SANITY_SV

`define tc_name tc_sanity

class `tc_name extends tc_base;
    `uvm_component_utils(`tc_name)
   	extern function new(string name="tc_sanity", uvm_component parent=null);
   	extern function void build_phase(uvm_phase phase);
   	extern task run_phase(uvm_phase phase);
endclass

function `tc_name::new(string name="tc_sanity", uvm_component parent=null);
    super.new(name, parent);
endfunction

function void `tc_name::build_phase(uvm_phase phase);
   	super.build_phase(phase);
endfunction

task `tc_name::run_phase(uvm_phase phase);
    //utype_default_seq utype_seq = utype_default_seq::type_id::create("utype_seq"); 	
    //default_preload_cfg_vseq preload_cfg_vseq = default_preload_cfg_vseq::type_id::create("vseq"); 	

    //utype_seq.start(null);
    //preload_cfg_vseq.vir_cfg_seqr = env.cfg_agt.cfg_seqr;
    //preload_cfg_vseq.start(null);
endtask

`undef tc_name
`endif
