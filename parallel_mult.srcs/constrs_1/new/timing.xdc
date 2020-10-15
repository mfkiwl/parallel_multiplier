create_clock -period 8 -name input_clk [get_ports clkin]

create_clock -period 2.5 -name sim_clk [get_ports clk]
