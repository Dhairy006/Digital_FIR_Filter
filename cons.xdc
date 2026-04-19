
# For sequential circuits
create_clock -add -name sys_clk_pin -period 20.00 -waveform {0 5} [get_ports clk]

# For combinational circuits
set_max_delay 40 -from [all_inputs] -to [all_outputs]
  