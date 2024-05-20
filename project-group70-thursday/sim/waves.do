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

add wave -divider -height 10 {VGA signals}
add wave -bin UUT/VGA_unit/VGA_HSYNC_O
add wave -bin UUT/VGA_unit/VGA_VSYNC_O
add wave -uns UUT/VGA_unit/pixel_X_pos
add wave -uns UUT/VGA_unit/pixel_Y_pos
add wave -hex UUT/VGA_unit/VGA_red
add wave -hex UUT/VGA_unit/VGA_green
add wave -hex UUT/VGA_unit/VGA_blue

add wave -divider -height 10 {SRAM signals}
add wave -uns UUT/SRAM_address
add wave -hex UUT/SRAM_write_data
add wave -bin UUT/SRAM_we_n
add wave -hex UUT/SRAM_read_data

#add wave -divider -height 10 {M1 signals}
#add wave -bin UUT/M1/CC_tracker
#add wave -bin UUT/M1/End_case
#add wave -bin UUT/M1/End_case_y
#add wave -bin UUT/M1/Last_write
#add wave -bin UUT/M1/M1_SRAM_state
#add wave -uns UUT/M1/data_counter
#add wave -uns UUT/M1/Y_counter
#add wave -uns UUT/M1/Pixel_counter
#add wave -uns UUT/M1/RGB_counter
#add wave -divider -height 10 {SRAM data}
#add wave -hex {UUT/M1/U[0]}
#add wave -hex {UUT/M1/U[1]}
#add wave -hex {UUT/M1/U[2]}
#add wave -hex {UUT/M1/U[3]}
#add wave -hex {UUT/M1/U[4]}
#add wave -hex {UUT/M1/U[5]}
#add wave -hex UUT/M1/U_buff
#add wave -hex {UUT/M1/V[0]}
#add wave -hex {UUT/M1/V[1]}
#add wave -hex {UUT/M1/V[2]}
#add wave -hex {UUT/M1/V[3]}
#add wave -hex {UUT/M1/V[4]}
#add wave -hex {UUT/M1/V[5]}
#add wave -hex UUT/M1/V_buff
#add wave -hex UUT/M1/Y_even
#add wave -hex UUT/M1/Y_odd
#add wave -hex UUT/M1/U_prime
#add wave -hex UUT/M1/V_prime
#add wave -hex UUT/M1/U_e
#add wave -hex UUT/M1/V_e
#add wave -hex UUT/M1/Multi_p1_buff
#
#add wave -divider -height 10 {Multiplication signals}
#add wave -hex {UUT/M1/Mult_op_1}
#add wave -hex {UUT/M1/Mult_op_2}
#add wave -hex {UUT/M1/Mult_result_1}
#add wave -hex {UUT/M1/Mult_op_3}
#add wave -hex {UUT/M1/Mult_op_4}
#add wave -hex {UUT/M1/Mult_result_2}
#add wave -hex {UUT/M1/Mult_op_5}
#add wave -hex {UUT/M1/Mult_op_6}
#add wave -hex {UUT/M1/Mult_result_3}
#add wave -hex {UUT/M1/Mult_op_7}
#add wave -hex {UUT/M1/Mult_op_8}
#add wave -hex {UUT/M1/Mult_result_4}
#
#add wave -divider -height 10 {Writing  signals}
#
#add wave -hex {UUT/M1/Mult_result_1_preclip}
#add wave -hex {UUT/M1/Mult_result_2_preclip}
#add wave -hex {UUT/M1/Mult_result_3_preclip}
#add wave -hex {UUT/M1/Mult_result_4_preclip}
#add wave -hex {UUT/M1/Mult_result_5_preclip}
#add wave -hex {UUT/M1/Mult_result_6_preclip}
#
#add wave -hex {UUT/M1/Mult_result_1_clip}
#add wave -hex {UUT/M1/Mult_result_2_clip}
#add wave -hex {UUT/M1/Mult_result_3_clip}
#add wave -hex {UUT/M1/Mult_result_4_clip}
#add wave -hex {UUT/M1/Mult_result_5_clip}
#add wave -hex {UUT/M1/Mult_result_6_clip}
#
#add wave -hex {UUT/M1/CC_5_Mul_1}
#add wave -hex {UUT/M1/CC_5_Mul_2}
#add wave -hex {UUT/M1/CC_6_Mul_1}
#add wave -hex {UUT/M1/CC_6_Mul_2}
#add wave -hex {UUT/M1/CC_7_Mul_1}
#add wave -hex {UUT/M1/CC_7_Mul_2}

add wave -uns UUT/M2/enable_M2
add wave -uns UUT/M2/U_flag
add wave -uns UUT/M2/CC_counter
add wave -bin UUT/M2/M2_SRAM_state
add wave -uns UUT/M2/M2_data_counter
add wave -uns UUT/M2/M2_SRAM_line_counter
add wave -uns UUT/M2/M2_block_counter
add wave -uns UUT/M2/Total_rows
add wave -uns UUT/M2/row_counter
add wave -uns UUT/M2/S_calculation
add wave -uns UUT/M2/Lead_out
add wave -uns UUT/M2/S_Fetch
add wave -uns UUT/M2/S_prime_write
add wave -uns UUT/M2/SRAM_write
add wave -uns UUT/M2/SRAM_write_lead
add wave -uns UUT/M2/Write_row_tracker
add wave -uns UUT/M2/SRAM_write_counter
add wave -uns UUT/M2/M2_SRAM_line_adder
add wave -uns UUT/M2/SRAM_address_increment

add wave -divider -height 10 {DP 0 Write signals}
add wave -uns UUT/M2/address_0_A
add wave -uns UUT/M2/dp_0_address_counter
add wave -hex {UUT/M2/data_a[0]}
add wave -hex {UUT/M2/write_enable_a[0]}
#add wave -hex {UUT/M2/write_enable_b[0]}

add wave -divider -height 10 {DP 0 Read signals}
add wave -uns UUT/M2/address_0_B
add wave -uns UUT/M2/dp_0_read_counter
add wave -hex {UUT/M2/read_data_b[0]}

add wave -divider -height 10 {BUFF (Macho Man)}

add wave -hex {UUT/M2/Buff[0]}
add wave -hex {UUT/M2/Buff[1]}
add wave -hex {UUT/M2/Buff[2]}
add wave -hex {UUT/M2/Buff[3]}

add wave -divider -height 10 {M2 Multiplication signals}
add wave -hex {UUT/M2/Mult_op_1}
add wave -hex {UUT/M2/Mult_op_2}
add wave -hex {UUT/M2/Mult_result_1}
add wave -hex {UUT/M2/Mult_op_3}
add wave -hex {UUT/M2/Mult_op_4}
add wave -hex {UUT/M2/Mult_result_2}
add wave -hex {UUT/M2/Mult_op_5}
add wave -hex {UUT/M2/Mult_op_6}
add wave -hex {UUT/M2/Mult_result_3}
add wave -hex {UUT/M2/Mult_op_7}
add wave -hex {UUT/M2/Mult_op_8}
add wave -hex {UUT/M2/Mult_result_4}

add wave -hex {UUT/M2/Summation[0]}
add wave -hex {UUT/M2/Summation[1]}
add wave -hex {UUT/M2/Summation[2]}
add wave -hex {UUT/M2/Summation[3]}

add wave -divider -height 10 {DP 1 Write signals}
add wave -uns UUT/M2/address_1_A
add wave -uns UUT/M2/dp_1_address_counter
add wave -hex {UUT/M2/data_a[1]}
add wave -hex {UUT/M2/write_enable_a[1]}

add wave -uns UUT/M2/address_1_B
add wave -hex {UUT/M2/data_b[1]}
add wave -hex {UUT/M2/write_enable_b[1]}

add wave -divider -height 10 {DP 1 READ signals}
add wave -uns UUT/M2/address_1_B
add wave -uns UUT/M2/dp_1_read_counter
add wave -hex {UUT/M2/read_data_b[1]}

add wave -divider -height 10 {DP 2A Write signals}
add wave -uns UUT/M2/address_2_A
add wave -uns UUT/M2/dp_2_address_counter
add wave -hex {UUT/M2/data_a[2]}
add wave -hex {UUT/M2/write_enable_a[2]}


add wave -divider -height 10 {DP 2B Write signals}
add wave -uns UUT/M2/address_2_B
add wave -uns UUT/M2/dp_2_address_counter
add wave -hex {UUT/M2/data_b[2]}
add wave -hex {UUT/M2/read_data_b[2]}
add wave -hex {UUT/M2/write_enable_b[2]}

#add wave -hex {UUT/M2/Summation_1_clip}
#add wave -hex {UUT/M2/Summation_2_clip}
#add wave -hex {UUT/M2/Summation_3_clip}
#add wave -hex {UUT/M2/Summation_4_clip}

#add wave -hex {UUT/M2/Summation_shifted_1}
#add wave -hex {UUT/M2/Summation_shifted_2}
#add wave -hex {UUT/M2/Summation_shifted_3}
#add wave -hex {UUT/M2/Summation_shifted_4}