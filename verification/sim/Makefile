#Default Variable
seed := $(shell perl -e "print int(rand(10000000))")
tc = tc_sanity
mode = sim_test
printlv = UVM_LOW
fsdb_file_name = $(tc)_$(seed)
csrc_folder_name = $(mode)"_csrc"      
ccov = off
fcov = off
sim_ccov_opts = 
sim_fcov_opts = 0

#Command
GEN_MODE = mkdir -p $(mode) $(mode)/log $(mode)/wave $(mode)/cov
VCS = vcs -sverilog 	 		  \
          -ntb_opts uvm-1.2       \
          -timescale=1ns/1ns      \
          +vpi 					  \
          -debug_access           \
          -debug_region=cell+lib  \
          -debug_all              \
          -full64                 \
          -f ../cfg/sim_filelist.f\
          -top harness 		      \
          -Mdir=$(csrc_folder_name)\
          -l $(mode)/log/uvm_compile.log\
		  -o $(mode)/simv               \
          -cm line+cond+tgl             \
          -cm_count                   \
          -cm_dir $(mode)/cov/simv.vdb\
          -cm_log $(mode)/cov/cm.log  \
          -cm_name $(fsdb_file_name) 

#Make Mode
ifeq ($(ccov), on)
	sim_ccov_opts = -cm line+cond+tgl \
                    -cm_count         
endif
ifeq ($(fcov), on)
	sim_fcov_opts = 1
										          
endif


#=======================================================================
cmp: 
	$(GEN_MODE)
	$(VCS) 

sim: 
	./$(mode)/simv +UVM_TESTNAME=$(tc) \
                   +ntb_random_seed=$(seed)\
				   +UVM_VERBOSITY=$(printlv) \
                   +fsdb+autoflush\
                   -ucli -i ../cfg/dump_fsdb.tcl\
                   -l $(mode)/log/$(fsdb_file_name).log\
                   -cg_coverage_control=$(sim_fcov_opts)\
                   $(sim_ccov_opts)

regress: 
	./$(mode)/simv +UVM_TESTNAME=$(tc) \
                   +ntb_random_seed=$(seed)\
				   +UVM_VERBOSITY=UVM_NONE \
                   -l $(mode)/log/$(fsdb_file_name).log\
                   -cg_coverage_control=$(sim_fcov_opts)\
                   $(sim_ccov_opts)

run: cmp sim

cov:
	verdi -cov &

verdi: 
	verdi -f ../cfg/sim_filelist.f &

clean: 
	rm -rf core *_csrc simv* vc_hdrs.h ucli.key urg* *.log *.fsdb novas.* verdiLog vdCovLog

#For TCL script
export wave = 
export dump_fsdb_name = $(mode)/wave/$(fsdb_file_name)

#Maybe can use for IP
#+define+tc=$(tc_name) 
