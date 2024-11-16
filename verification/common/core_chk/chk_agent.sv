`ifndef CHK_AGENT_SV
`define CHK_AGENT_SV
class chk_agent extends uvm_agent;
    `uvm_component_utils(chk_agent)

    chk_monitor chk_mon;

    uvm_analysis_port #(chk_transaction) aly_port;

    extern function new(string name="chk_agent", uvm_component parent=null);
    extern function void build_phase(uvm_phase phase);	
    extern function void connect_phase(uvm_phase phase);	
endclass

function chk_agent::new(string name="chk_agent", uvm_component parent=null);
    super.new(name, parent);
endfunction

function void chk_agent::build_phase(uvm_phase phase);	
    super.build_phase(phase);
    chk_mon = chk_monitor::type_id::create("chk_mon", this);
endfunction

function void chk_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    //Connect chk_sequencer output to chk_driver input
    aly_port = chk_mon.aly_port;
endfunction

`endif
