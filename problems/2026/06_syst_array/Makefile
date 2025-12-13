SIM ?= verilator

TOPLEVEL_LANG = verilog

VERILOG_SOURCES += axil2reg_wr.sv \
				   sa_csr.sv


TOPLEVEL = sa_csr
MODULE   = sa_csr_tb

ifeq ($(SIM), verilator)
    EXTRA_ARGS += --trace --trace-fst --trace-structs
endif

include $(shell cocotb-config --makefiles)/Makefile.sim