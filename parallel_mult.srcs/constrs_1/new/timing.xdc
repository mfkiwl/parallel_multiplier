create_clock -period 8 -name input_clk [get_ports clkin]

create_clock -period 8 -name test_clk [get_ports clk]
