# activate waveform simulation

view wave

# format signal names in waveform

configure wave -signalnamewidth 1
configure wave -timeline 0
configure wave -timelineunits us

# add signals to waveform

add wave -divider -height 20 {Top-level signals}
add wave -bin UUT/CLOCK_50_I
add wave -bin UUT/resetn
add wave UUT/top_state
add wave -uns UUT/UART_timer

add wave -divider -height 10 {SRAM signals}
add wave -uns UUT/SRAM_address
add wave -hex UUT/SRAM_write_data
add wave -bin UUT/SRAM_we_n
add wave -hex UUT/SRAM_read_data

add wave -divider -height 10 {VGA signals}
add wave -bin UUT/VGA_unit/VGA_HSYNC_O
add wave -bin UUT/VGA_unit/VGA_VSYNC_O
add wave -uns UUT/VGA_unit/pixel_X_pos
add wave -uns UUT/VGA_unit/pixel_Y_pos
add wave -hex UUT/VGA_unit/VGA_red
add wave -hex UUT/VGA_unit/VGA_green
add wave -hex UUT/VGA_unit/VGA_blue

add wave -divider -height 20 {Top-level signals}
add wave -bin UUT/CLOCK_50_I	
add wave -bin UUT/resetn
add wave UUT/M2_unit/state

add wave -uns UUT/M2_unit/SRAM_address
add wave -bin UUT/M2_unit/SRAM_we_n
add wave -uns UUT/M2_unit/SRAM_read_data
add wave -uns UUT/M2_unit/SRAM_write_data

add wave UUT/M2_unit/M2_Fetch_inst/state
add wave -bin UUT/M2_unit/M2_Fetch_inst/M2_Fetch_start
add wave -dec UUT/M2_unit/M2_Fetch_inst/M2_Fetch_SRAM_address
add wave -hex UUT/M2_unit/M2_Fetch_inst/M2_Fetch_SRAM_read_data
add wave -hex UUT/M2_unit/M2_Fetch_inst/fetch_buffer
add wave -hex UUT/M2_unit/M2_Fetch_inst/address_fetch_a
add wave -hex UUT/M2_unit/M2_Fetch_inst/write_data_a
add wave -hex UUT/M2_unit/M2_Fetch_inst/write_enable_a
add wave -bin UUT/M2_unit/M2_Fetch_inst/M2_Fetch_done


add wave -divider -height 20 {M2_Ct signals}
add wave UUT/M2_unit/M2_Ct_inst/state
add wave -bin UUT/M2_unit/M2_Ct_inst/M2_Ct_start


add wave -hex UUT/M2_unit/M2_Ct_inst/address_fetch_b
add wave -hex UUT/M2_unit/M2_Ct_inst/read_data_b

add wave -bin UUT/M2_unit/M2_Ct_inst/M2_Ct_done




