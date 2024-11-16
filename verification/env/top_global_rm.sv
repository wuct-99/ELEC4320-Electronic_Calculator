`ifndef TOP_GLOBAL_RM__SV
`define TOP_GLOBAL_RM__SV
class top_global_rm extends uvm_component;
    //static bit [31:0] env_imem [1024];
    int trans_cnt;

    //define port to connect monitor and scoreboard
    uvm_blocking_get_port #(cfg_transaction) blk_port;
    uvm_analysis_port     #(chk_transaction) aly_port;

    //extern function wr_ireg(bit[4:0] rdaddr, bit[31:0] wrdata);
    extern task pack_trans(chk_transaction trans);

    extern function new(string name, uvm_component parent);
    extern function void build_phase (uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);

    `uvm_component_utils(top_global_rm)
endclass

function top_global_rm::new(string name, uvm_component parent);
    super.new(name, parent);
endfunction

function void top_global_rm::build_phase(uvm_phase phase);
    super.build_phase(phase);
    blk_port = new("blk_port", this);
    aly_port = new("aly_port", this);
endfunction

task top_global_rm::run_phase(uvm_phase phase);
    cfg_transaction cfg_tr; 
    chk_transaction rm_chk_tr;
    super.main_phase(phase);
    while(1) begin
        blk_port.get(cfg_tr);

        //rm_chk_tr = new("rm_chk_tr");
        //pack_trans(rm_chk_tr);
        ////rm_chk_tr.print(); 
        //aly_port.write(rm_chk_tr); 
        trans_cnt = trans_cnt + 1;
        if(trans_cnt >= 1000) begin
            `uvm_info(get_type_name(), "RM shut down", UVM_LOW)
            break;
        end
    end
endtask

task top_global_rm::pack_trans(chk_transaction trans);
    //trans.pc = inst.pc;
endtask

//function top_global_rm::rd_dmem(bit[11:0] rdaddr, output bit[31:0] rddata);
//endfunction
`endif
