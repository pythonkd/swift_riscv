compile:
	vcs -f ../tb/tb.f \
	-timescale=1ns/1ps \
	-full64 +v2k -sverilog -Mupdate +define+DUMP_FSDB \
	-debug_access+all -debug_region+cell+encrypt \
	-kdb -lca \
	|tee vcs.log 

compile_freertos:
	vcs -f ../tb_freertos/tb.f \
	-timescale=1ns/1ps \
	-full64 +v2k -sverilog -Mupdate +define+DUMP_FSDB \
	-debug_access+all -debug_region+cell+encrypt \
	-kdb -lca \
	|tee vcs.log 

run_freertos:
	vcs -f ../tb_freertos/tb.f \
	-timescale=1ns/1ps \
	-full64 +v2k -sverilog -Mupdate +define+DUMP_FSDB \
	-R \
	-debug_access+all -debug_region+cell+encrypt \
	-kdb -lca \
	|tee vcs.log 

run_test:
	vcs -f ../ttesb/tb.f \
	-timescale=1ns/1ps \
	-full64 +v2k -sverilog -Mupdate +define+DUMP_FSDB \
	-R \
	-debug_access+all -debug_region+cell+encrypt \
	-kdb -lca \
	|tee vcs.log 

sim:
	./simv +vcs+loopdetect+100000 |tee sim.log

verdi:
	verdi -f ../tb/tb.f -ssf sim_out.fsdb &

verdi_freertos:
	verdi -f ../tb_freertos/tb.f -ssf sim_out.fsdb &

clean:
	rm -rf csrc DVEfiles novas* *.log simv* *fsdb* ucli.key *.vpd verdiLog