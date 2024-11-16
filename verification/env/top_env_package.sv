`ifndef TOP_ENV_PACKAGE_SV
`define TOP_ENV_PACKAGE_SV
package top_env_package;
    import uvm_pkg::*;
    import cfg_package::*;
    import chk_package::*;

    `include "top_env_def.sv"
    `include "top_global_rm.sv"
    `include "top_global_chk.sv"
    `include "top_env.sv"
endpackage 
`endif
