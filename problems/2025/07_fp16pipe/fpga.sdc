create_clock -period "50.0 MHz" [get_ports CLK]

derive_clock_uncertainty

set_false_path -from * -to [get_ports STCP]
set_false_path -from * -to [get_ports SHCP]
set_false_path -from * -to [get_ports DS]
set_false_path -from * -to [get_ports OE]
# set_false_path -from [get_ports system_top:system_top|cpu_top:cpu_top|core:core|pc[0]] -to [get_ports system_top:system_top|mmio_xbar:mmio_xbar|hexd_data[1]]
set_false_path -from [get_ports RSTN] -to [all_clocks]
