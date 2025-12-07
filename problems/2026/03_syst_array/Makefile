RTL_LIST :=  \
	sa_flow_ctl.sv \
	sa/sa_top.sv \
	sa/sa_core.sv \
	sa/pe.sv \
	sa/sr.sv \
	flow_ctl/credit_cnt.sv \
	flow_ctl/fifo.sv \
	flow_ctl/rf_1r1w.sv



VCD_FILE := dump.vcd

ifeq ($(GUI), 1)
VSIM_FLAGS :=
else
VSIM_FLAGS := -c -do 'vcd file $(VCD_FILE); vcd add -r /$(TOP_TB_NAME)/*; run -all'
endif

vsim: $(RTL_LIST)
	vlog $^
	vsim work.$(TOP_TB_NAME) $(VSIM_FLAGS) $(VSIM_LIBS)

verilator: $(RTL_LIST)
	verilator --binary -Wno-fatal --trace $^

lint: $(RTL_LIST)
	verilator --lint-only $^

clean:
	rm -rf transcript work obj_dir

waves: $(VCD_FILE)
	gtkwave $(VCD_FILE) &

.PHONY: clean verilator waves vsim
