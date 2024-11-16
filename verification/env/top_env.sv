`ifndef TOP_ENV_SV
`define TOP_ENV_SV
class top_env extends uvm_env;
	
    cfg_agent cfg_agt;
    chk_agent chk_agt;

    top_global_rm global_rm;
    top_global_chk global_chk;
    //Define FIFO for connecting Monitor and Model
    uvm_tlm_analysis_fifo #(cfg_transaction) cfg_glbrm_fifo; 
    uvm_tlm_analysis_fifo #(chk_transaction) glbrm_glbchk_fifo; //Global RM to Global Checker
    uvm_tlm_analysis_fifo #(chk_transaction) chk_glbchk_fifo;   //CHK monitor to Global chk

    extern function new(string name="top_env", uvm_component parent=null);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    `uvm_component_utils(top_env)
endclass

function top_env::new(string name="top_env", uvm_component parent=null);
    super.new(name, parent);
endfunction

function void top_env::build_phase(uvm_phase phase);
    super.build_phase(phase);
    cfg_agt = cfg_agent::type_id::create("cfg_agt", this);
    chk_agt = chk_agent::type_id::create("chk_agt", this);


    global_rm = top_global_rm::type_id::create("global_rm", this); 
    global_chk = top_global_chk::type_id::create("global_chk", this); 

    cfg_glbrm_fifo = new("cfg_glbrm_fifo", this);
    chk_glbchk_fifo = new("chk_glbchk_fifo", this);
    glbrm_glbchk_fifo = new("glbrm_glbchk_fifo", this);
endfunction

function void top_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    //CFG agent to Global RM 
    cfg_agt.aly_port.connect(cfg_glbrm_fifo.analysis_export); 
    global_rm.blk_port.connect(cfg_glbrm_fifo.blocking_get_export);
    //CHK agent to Global Checker
    chk_agt.aly_port.connect(chk_glbchk_fifo.analysis_export); 
    global_chk.dut_chk_port.connect(chk_glbchk_fifo.blocking_get_export);
    //Global RM to Global Checker 
    global_rm.aly_port.connect(glbrm_glbchk_fifo.analysis_export);
    global_chk.rm_chk_port.connect(glbrm_glbchk_fifo.blocking_get_export);

    endfunction

`endif
