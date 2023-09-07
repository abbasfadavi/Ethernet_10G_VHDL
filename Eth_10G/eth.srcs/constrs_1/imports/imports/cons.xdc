create_clock -period 5.000 [get_ports PL_CLK0_P]
set_property PACKAGE_PIN AK17 [get_ports PL_CLK0_P]
set_property IOSTANDARD LVDS [get_ports PL_CLK0_P]
set_property DIFF_TERM_ADV TERM_100 [get_ports PL_CLK0_P]
##################################################################
set_property -dict {PACKAGE_PIN E12 IOSTANDARD LVCMOS18} [get_ports LED1]
set_property -dict {PACKAGE_PIN F12 IOSTANDARD LVCMOS18} [get_ports LED2]
set_property -dict {PACKAGE_PIN L9 IOSTANDARD LVCMOS18} [get_ports LED3]
set_property -dict {PACKAGE_PIN H23 IOSTANDARD LVCMOS18} [get_ports LED4]
##################################################################
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
##################################################################
create_clock -period 6.400 [get_ports refclk_p]
set_property PACKAGE_PIN T6 [get_ports refclk_p]
##################################################################
set_property PACKAGE_PIN T2 [get_ports rxp]
set_property PACKAGE_PIN U4 [get_ports txp]
##################################################################
set_property -dict {PACKAGE_PIN AN11 IOSTANDARD LVCMOS18} [get_ports TX_DIS]
set_property -dict {PACKAGE_PIN AP9 IOSTANDARD LVCMOS18} [get_ports LOSS]
##################################################################
create_pblock my_pblock
add_cells_to_pblock [get_pblocks my_pblock] [get_cells -quiet [list Inst_eth_manager]]
resize_pblock [get_pblocks my_pblock] -add {SLICE_X119Y120:SLICE_X142Y179}

