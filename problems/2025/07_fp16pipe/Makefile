TB_LIST := src/cpu_top_tb.v

RTL_LIST := 		\
	fp16add.v	\

sim: $(TB_LIST) $(RTL_LIST)
	iverilog -I./src/ $^ -o sim
	./sim

waves: dump.vcd
	gtkwave dump.vcd &

samples:
	$(MAKE) -C samples/

syn:
	quartus_sh --flow compile fpga

gui:
	quartus fpga &

fpga:
	quartus_pgm -c "USB-Blaster" -m JTAG -o "p;output/fpga.sof"

clean:
	rm -rf sim dump.vcd
	rm -rf db incremental_db output fpga.qws greybox_tmp *.bak
	$(MAKE) -C samples/ clean

.PHONY: syn fpga clean samples gui sim waves
