create_clock -period 20.000000000000 -name m00_axis_aclk -waveform {0.000000000000 10.000000000000} [get_ports m00_axis_aclk]
create_clock -period 20.000000000000 -name s00_axi_aclk -waveform {0.000000000000 10.000000000000} [get_ports s00_axi_aclk]
create_clock -period 20.000000000000 -name s00_axis_aclk -waveform {0.000000000000 10.000000000000} [get_ports s00_axis_aclk]
