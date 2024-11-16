`ifndef CFG_AGENT_SV
`define CFG_AGENT_SV
class cfg_agent extends uvm_agent;
    `uvm_component_utils(cfg_agent)
    cfg_driver cfg_drv;
    cfg_monitor cfg_mon;
    //Sequencer
    uvm_sequencer #(cfg_transaction) cfg_seqr;
    //Port
    uvm_analysis_port #(cfg_transaction) aly_port;

    extern function new(string name="cfg_agent", uvm_component parent=null);
    extern function void build_phase(uvm_phase phase);	
    extern function void connect_phase(uvm_phase phase);	
endclass

function cfg_agent::new(string name="cfg_agent", uvm_component parent=null);
    super.new(name, parent);
endfunction

function void cfg_agent::build_phase(uvm_phase phase);	
    super.build_phase(phase);
    cfg_seqr = uvm_sequencer#(cfg_transaction)::type_id::create("cfg_seqr", this);
    cfg_drv = cfg_driver::type_id::create("cfg_drv", this);
    cfg_mon = cfg_monitor::type_id::create("cfg_mon", this);
endfunction

function void cfg_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
	//Connect cfg_sequencer output to cfg_driver input
    cfg_drv.seq_item_port.connect(cfg_seqr.seq_item_export);
    aly_port = cfg_mon.aly_port;
endfunction

`endif
