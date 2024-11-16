-f $ELEC4320_RTL/cal.f

+incdir+$ELEC4320_VER/common/core_cfg
+incdir+$ELEC4320_VER/common/core_chk
+incdir+$ELEC4320_VER/env/
+incdir+$ELEC4320_VER/tc/instr_gen
+incdir+$ELEC4320_VER/tc/

$ELEC4320_VER/common/core_cfg/cfg_package.sv
$ELEC4320_VER/common/core_chk/chk_package.sv
$ELEC4320_VER/env/top_env_package.sv
$ELEC4320_VER/tc/tc_package.sv

-f $ELEC4320_VER/tc/tc.f
$ELEC4320_VER/th/harness.sv


