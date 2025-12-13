SIM ?= verilator

TOPLEVEL_LANG = verilog

VERILOG_SOURCES += \
	axi_sa_top.sv \
	sa_flow_ctl.sv \
	addr_gen/addr_gen.sv \
	sa/sa_top.sv \
	sa/sa_core.sv \
	sa/pe.sv \
	sa/sr.sv \
	flow_ctl/credit_cnt.sv \
	flow_ctl/fifo.sv \
	flow_ctl/rf_1r1w.sv


TOPLEVEL = axi_sa_top
MODULE   = axi_sa_top_tb

ifeq ($(SIM), verilator)
    EXTRA_ARGS += --trace --trace-fst --trace-structs
endif

include $(shell cocotb-config --makefiles)/Makefile.sim