restart -f
vcom -check_synthesis ../vhd/adder.vhd ../vhd/multi_port_adder.vhd  ../vhd/tb_multi_port_adder.vhd
vsim work.tb_multi_port_adder

add wave *
