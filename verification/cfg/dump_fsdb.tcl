global env
if {$env(wave) == on} {
				fsdbDumpfile $env(dump_fsdb_name).fsdb
				fsdbDumpMDA
				fsdbDumpvars
}
run
