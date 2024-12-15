#Default Variable
seed := $(shell perl -e "print int(rand(10000000))")
tb = add_tb
mode = sim_test
fsdb_file_name = $(tb)
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
          -f ${ELEC4320_RTL}/cal.f\
          ./tb/$(tb).sv 		  \
          -Mdir=$(csrc_folder_name)\
          -l $(mode)/log/uvm_compile.log\
		  -o $(mode)/simv               

#=======================================================================
cmp: 
	$(GEN_MODE)
	$(VCS) 

sim: 
	./$(mode)/simv +ntb_random_seed=$(seed)\
                   +fsdb+autoflush\
                   -l $(mode)/log/$(fsdb_file_name).log\
                   -cg_coverage_control=$(sim_fcov_opts)\
                   $(sim_ccov_opts)

run: cmp sim

cov:
	verdi -cov &

verdi: 
	verdi ./tb/$(tb).sv -f ${ELEC4320_RTL}/cal.f &

clean: 
	rm -rf core *_csrc simv* vc_hdrs.h ucli.key urg* *.log *.fsdb novas.* verdiLog vdCovLog
