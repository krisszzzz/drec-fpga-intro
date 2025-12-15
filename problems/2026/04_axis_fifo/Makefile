SIM ?= verilator
WAVES ?= 0
COV ?= 0

VERILOG_SOURCES :=   \
	src/axis_fifo.sv \
	src/fifo.sv 	 \
	src/rf_1r1w.sv

.PHONY: lint

MODULE   = axis_fifo_tb
TOPLEVEL = axis_fifo

ifeq ($(SIM),verilator)
ifeq ($(WAVES),1)
	EXTRA_ARGS += --trace --trace-fst --trace-structs
endif
ifeq ($(COV),1)
	EXTRA_ARGS += --coverage
endif
endif

include $(shell cocotb-config --makefiles)/Makefile.sim

lint: $(VERILOG_SOURCES)
	verilator --lint-only $^