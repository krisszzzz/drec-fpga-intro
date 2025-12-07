SIM ?= verilator

TOPLEVEL_LANG = verilog

VERILOG_SOURCES += \
	sa_flow_ctl.sv \
	sa/sa_top.sv \
	sa/sa_core.sv \
	sa/pe.sv \
	sa/sr.sv \
	flow_ctl/credit_cnt.sv \
	flow_ctl/fifo.sv \
	flow_ctl/rf_1r1w.sv


TOPLEVEL = sa_flow_ctl
MODULE   = sa_flow_ctl_tb

ifeq ($(SIM), verilator)
    EXTRA_ARGS += --trace --trace-fst --trace-structs
endif

include $(shell cocotb-config --makefiles)/Makefile.sim