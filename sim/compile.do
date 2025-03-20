
vlog -sv -work my_work +define+DISABLE_DEFAULT_NET +define+SIMULATION $rtl/SRAM_controller.sv
vlog -sv -work my_work +define+DISABLE_DEFAULT_NET $rtl/PB_controller.sv
vlog -sv -work my_work +define+DISABLE_DEFAULT_NET $rtl/VGA_controller.sv
vlog -sv -work my_work +define+DISABLE_DEFAULT_NET $rtl/convert_hex_to_seven_segment.sv
vlog -sv -work my_work +define+DISABLE_DEFAULT_NET +define+SIMULATION $rtl/UART_receive_controller.sv
vlog -sv -work my_work +define+DISABLE_DEFAULT_NET $rtl/UART_SRAM_interface.sv
vlog -sv -work my_work +define+DISABLE_DEFAULT_NET $rtl/VGA_SRAM_interface.sv
vlog -sv -work my_work +define+DISABLE_DEFAULT_NET $rtl/project.sv
vlog -sv -work my_work +define+DISABLE_DEFAULT_NET $rtl/milestone1.sv
vlog -sv -work my_work +define+DISABLE_DEFAULT_NET $rtl/milestone2.sv
vlog -sv -work my_work +define+DISABLE_DEFAULT_NET $rtl/M2_Fetch.sv
vlog -sv -work my_work +define+DISABLE_DEFAULT_NET $rtl/M2_Ct.sv
vlog -sv -work my_work +define+DISABLE_DEFAULT_NET $rtl/M2_Cs.sv
vlog -sv -work my_work +define+DISABLE_DEFAULT_NET $rtl/M2_Write.sv
vlog -sv -work my_work +define+DISABLE_DEFAULT_NET $rtl/M2_Write.sv
vlog -sv -work my_work +define+DISABLE_DEFAULT_NET $rtl/dual_port_fetch_s.v
vlog -sv -work my_work +define+DISABLE_DEFAULT_NET $rtl/dual_port_T.v
vlog -sv -work my_work +define+DISABLE_DEFAULT_NET $rtl/dual_port_T_bb.v
vlog -sv -work my_work +define+DISABLE_DEFAULT_NET $rtl/dual_port_Cs.v
vlog -sv -work my_work +define+DISABLE_DEFAULT_NET $rtl/dual_port_Cs_bb.v



vlog -sv -work my_work +define+DISABLE_DEFAULT_NET $tb/tb_SRAM_Emulator.sv
#vlog -sv -work my_work +define+DISABLE_DEFAULT_NET $tb/testbench.sv

# while trouble-shooting you should first use version 0 of the testbench (tb_project_v0.sv)
# this can be done by commenting the above vlog line and commenting out the one below

vlog -sv -work my_work +define+DISABLE_DEFAULT_NET $tb/tb_project_v0.sv

# once the project passes a given milestone for the version 0 of the testbench
# do a final check with version 1, which should help validate the top-level integration

#vlog -sv -work my_work +define+DISABLE_DEFAULT_NET $tb/tb_project_v1.sv


