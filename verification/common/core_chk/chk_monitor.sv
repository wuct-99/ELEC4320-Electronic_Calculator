`ifndef CHK_MONITOR__SV
`define CHK_MONITOR__SV
class chk_monitor extends uvm_monitor;
    virtual chk_interface  vir_chk_intf;

    int tran_cnt;

    uvm_analysis_port #(chk_transaction) aly_port;

    extern function new(string name, uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    `uvm_component_utils(chk_monitor)
endclass

function chk_monitor::new(string name, uvm_component parent);
    super.new(name, parent);
endfunction

function void chk_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);

    aly_port = new("aly_port", this);

    //Get data from TC 
    if(!uvm_config_db #(virtual chk_interface)::get(this, "", "chk_interface", vir_chk_intf)) begin
        `uvm_error(get_type_name(), "DUT chk interface not found")
    end
endfunction

task chk_monitor::run_phase(uvm_phase phase);
    chk_transaction mon_chk_trans = chk_transaction::type_id::create("mon_chk_trans", this);

    while(1) begin
        @(posedge vir_chk_intf.clk);
        `uvm_info(get_type_name(), "Loop", UVM_HIGH)
        if(tran_cnt == 1000) begin
            `uvm_info(get_type_name(), "stop monitoring", UVM_HIGH)
             break;
        end
        tran_cnt = tran_cnt + 1;
        `uvm_info(get_type_name(), $sformatf("chk mon cnt = %d",tran_cnt), UVM_HIGH)
    end
endtask
`endif
