`ifndef TC_BASE_SV
`define TC_BASE_SV

class tc_base extends uvm_test;
    bit check_state = 0;
    `uvm_component_utils(tc_base)
    top_env env;
    uvm_report_server reporter;

    virtual cfg_interface cfg_intf;
    virtual chk_interface chk_intf;
	
   	extern function new(string name="tc_base", uvm_component parent=null);
   	extern function void build_phase(uvm_phase phase);
   	extern task run_phase(uvm_phase phase);
    extern function void phase_ready_to_end(uvm_phase phase);
    extern function void report_phase(uvm_phase phase);
    extern function void pre_abort();
endclass

function tc_base::new(string name="tc_base", uvm_component parent=null);
    super.new(name, parent);
endfunction

function void tc_base::build_phase(uvm_phase phase);
   	super.build_phase(phase);
   	env = top_env::type_id::create("env", this);
    //Stop simulation if Error
    set_report_max_quit_count(1);
    reporter = uvm_report_server::get_server();
endfunction

task tc_base::run_phase(uvm_phase phase);
endtask

function void tc_base::phase_ready_to_end(uvm_phase phase);
    if(phase.is(uvm_run_phase::get)) begin
        if(~check_state) begin
            phase.raise_objection(this, "Test Not Yet Ready to End");
            fork begin
                `uvm_info(get_type_name(), "Phase Ready Testing", UVM_LOW);
                #10000000;
                check_state = 1;
                phase.drop_objection(this, "Test Ready to End");
            end
            join_none
        end
    end
endfunction

function void tc_base::report_phase(uvm_phase phase);
    super.final_phase(phase);
    if(reporter.get_severity_count(UVM_FATAL) || reporter.get_severity_count(UVM_ERROR)) begin
        $display("=========");
        $display(" FAIL ");
        $display("=========");
    end
    else begin
        $display("=========");
        $display(" PASS ");
        $display("=========");
    end
endfunction

function void tc_base::pre_abort();
    $display("=========");
    $display(" FAIL ");
    $display("=========");
endfunction

`undef tc_name
`endif
