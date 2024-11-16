`ifndef TOP_GLOBAL_CHK__SV
`define TOP_GLOBAL_CHK__SV
class top_global_chk extends uvm_scoreboard;
    chk_transaction rm_chk_trans;
    chk_transaction dut_chk_trans;

    uvm_blocking_get_port #(chk_transaction) rm_chk_port;
    uvm_blocking_get_port #(chk_transaction) dut_chk_port;

    chk_transaction rm_pack_q[$];
    chk_transaction dut_pack_q[$];

    int tran_cnt;

    uvm_table_printer printer;
    uvm_comparer comp;
    `uvm_component_utils(top_global_chk)

    extern function new(string name, uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);

    extern task get_rm_pack();
    extern task get_dut_pack();
    extern task compare_pack();
endclass

function top_global_chk::new(string name, uvm_component parent);
    super.new(name, parent);
endfunction

function void top_global_chk::build_phase(uvm_phase phase);
    rm_chk_port = new("rm_chk_port", this);
    dut_chk_port = new("dut_chk_port", this);

    comp = new();
    comp.policy = UVM_DEEP;
    comp.show_max = 10;

    printer = new();
    printer.knobs.begin_elements = -1;
endfunction

task top_global_chk::run_phase(uvm_phase phase);
    while(1) begin
        fork
            begin
                get_rm_pack();
            end
            begin
                get_dut_pack();
            end
            begin
                compare_pack();
            end
        join
    end
endtask

task top_global_chk::get_rm_pack();
    chk_transaction rm_pack = new();
    rm_chk_port.get(rm_pack);
    rm_pack_q.push_back(rm_pack); 
    `uvm_info(get_type_name(), "push rm pack", UVM_MEDIUM)
endtask

task top_global_chk::get_dut_pack();
    chk_transaction dut_pack = new();
    dut_chk_port.get(dut_pack);
    dut_pack_q.push_back(dut_pack); 
    `uvm_info(get_type_name(), "push dut pack", UVM_MEDIUM)
endtask

task top_global_chk::compare_pack();
    chk_transaction rm_comp_pack = new("RM");
    chk_transaction dut_comp_pack = new("DUT");
    `uvm_info(get_type_name(), "Loop", UVM_MEDIUM)
    if(rm_pack_q.size() > 0 && dut_pack_q.size() > 0) begin
        `uvm_info(get_type_name(), "Compare Package", UVM_MEDIUM)
        rm_comp_pack = rm_pack_q.pop_front(); 
        dut_comp_pack = dut_pack_q.pop_front(); 
        
        //rm_comp_pack.print(printer);
        //$display("above rm, below dut");
        //dut_comp_pack.print(printer);
    
        if(~comp.compare_object("chk trans",rm_comp_pack, dut_comp_pack)) begin
            `uvm_error(get_type_name(), "Mismatch Package")
        end
    end
endtask


`endif
