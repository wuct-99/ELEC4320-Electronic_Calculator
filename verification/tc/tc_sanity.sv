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
    cfg_default_seq input_seq = cfg_default_seq::type_id::create("input_seq"); 	
    input_seq.start(env.cfg_agt.cfg_seqr);
endtask

`undef tc_name
`endif
