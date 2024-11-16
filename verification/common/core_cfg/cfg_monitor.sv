`ifndef CFG_MONITOR__SV
`define CFG_MONITOR__SV
class cfg_monitor extends uvm_monitor;
    virtual cfg_interface  vir_cfg_intf;
    uvm_analysis_port #(cfg_transaction) aly_port;

    extern function new(string name, uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    `uvm_component_utils(cfg_monitor)
endclass

function cfg_monitor::new(string name, uvm_component parent);
    super.new(name, parent);
endfunction

function void cfg_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);

    aly_port = new("aly_port", this);

    //Get data from TC 
    if(!uvm_config_db #(virtual cfg_interface)::get(this, "", "cfg_interface", vir_cfg_intf)) begin
        `uvm_error(get_type_name(), "DUT interface not found")
    end
endfunction

task cfg_monitor::run_phase(uvm_phase phase);
    cfg_transaction mon_cfg_trans = cfg_transaction::type_id::create("mon_cfg_trans", this);
    while(1) begin
        `uvm_info(get_type_name(), "Loop", UVM_HIGH)
        @(posedge vir_cfg_intf.clk);
        //mon_cfg_trans.start_pulse = vir_cfg_intf.mon_cb.start_pulse; 
        //mon_cfg_trans.core_rstn   = vir_cfg_intf.mon_cb.core_rstn; 
        //aly_port.write(mon_cfg_trans);
        //if(vir_cfg_intf.mon_cb.start_pulse & vir_cfg_intf.mon_cb.core_rstn) begin
        //    `uvm_info(get_type_name(), "Stop CFG mon", UVM_HIGH)
        //    break;
        //end
    end
endtask
`endif
