create_clock -period "50.0 MHz" [get_ports CLK]

derive_clock_uncertainty

set_false_path -from *    -to TXD
set_false_path -from RXD  -to [all_clocks]
set_false_path -from * -to [get_ports OE]
set_false_path -from * -to [get_ports DS]
set_false_path -from * -to [get_ports STCP]
set_false_path -from * -to [get_ports SHCP]
set_false_path -from [get_ports RSTN] -to [all_clocks]