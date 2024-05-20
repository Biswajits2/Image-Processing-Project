
`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none	
`endif

`include "define_state.h"

module M2 (
	input logic clock,                   // 50 MHz clock
	input logic reset,

	input logic enable_M2,
	input logic [15:0] SRAM_read,
		
	output logic [17:0] SRAM_address_M2,
	output logic [15:0] SRAM_write_data,
	output logic SRAM_write_en,
	output logic stop_M2
	
);

M2_SRAM_state_type M2_SRAM_state;

logic [17:0] M2_data_counter;
logic [17:0] M2_SRAM_line_counter;
logic [17:0] M2_SRAM_line_adder;
logic [17:0] SRAM_write_counter;
logic [17:0] M2_block_counter;
logic [7:0] dp_0_address_counter;
logic [7:0] dp_0_read_counter;
logic [7:0] dp_1_address_counter;
logic [7:0] dp_1_read_counter;
logic [7:0] dp_2_address_counter;
logic [7:0] dp_2_read_counter;
logic [8:0]	Total_rows;
logic CC_counter;
logic Lead_out;
logic S_Fetch;
logic S_prime_write;
logic SRAM_write_lead;
logic SRAM_write;
logic U_flag;
logic U_write_flag;
logic SRAM_address_increment;
logic [7:0] Write_row_tracker;
logic [6:0] row_counter;
logic S_calculation;

logic signed [31:0] Buff [3:0];
logic signed [31:0] c_array [7:0][7:0];
logic signed [31:0] Summation[3:0];

 


//index [0] is DP-RAM 0
//index [1] is DP-RAM 1
//index [2] is DP-RAM 2
logic [6:0] address_0_A, address_0_B, address_1_A, address_1_B, address_2_A, address_2_B;
logic signed [31:0] data_a [2:0];
logic signed [31:0] data_b [2:0];
logic write_enable_a [2:0];
logic write_enable_b [2:0];
logic signed [31:0] read_data_a [2:0];
logic signed [31:0] read_data_b [2:0];


// instantiate RAM0
dual_port_RAM0 RAM_inst0 (
	.address_a ( address_0_A ),
	.address_b ( address_0_B ),
	.clock ( clock ),
	.data_a ( data_a[0] ),
	.data_b ( data_b[0] ),
	.wren_a ( write_enable_a[0] ),
	.wren_b ( write_enable_b[0] ),
	.q_a ( read_data_a[0] ),
	.q_b ( read_data_b[0] )
	);

// instantiate RAM1
dual_port_RAM1 RAM_inst1 (
	.address_a ( address_1_A ),
	.address_b ( address_1_B ),
	.clock ( clock ),
	.data_a ( data_a[1] ),
	.data_b ( data_b[1] ),
	.wren_a ( write_enable_a[1] ),
	.wren_b ( write_enable_b[1] ),
	.q_a ( read_data_a[1] ),
	.q_b ( read_data_b[1] )
	);

// instantiate RAM2
dual_port_RAM2 RAM_inst2 (
	.address_a ( address_2_A ),
	.address_b ( address_2_B ),
	.clock ( clock ),
	.data_a ( data_a[2] ),
	.data_b ( data_b[2] ),
	.wren_a ( write_enable_a[2] ),
	.wren_b ( write_enable_b[2] ),
	.q_a ( read_data_a[2] ),
	.q_b ( read_data_b[2] )
	); 

logic signed [31:0] Mult_op_1, Mult_op_2, Mult_op_3, Mult_op_4, Mult_op_5, Mult_op_6, Mult_op_7, Mult_op_8, Mult_result_1, Mult_result_2, Mult_result_3, Mult_result_4;
logic signed [63:0] Mult_result_long_1, Mult_result_long_2, Mult_result_long_3, Mult_result_long_4;

assign Mult_result_long_1 = Mult_op_1 * Mult_op_2;
assign Mult_result_1 = Mult_result_long_1[31:0];

assign Mult_result_long_2 = Mult_op_3 * Mult_op_4;
assign Mult_result_2 = Mult_result_long_2[31:0];

assign Mult_result_long_3 = Mult_op_5 * Mult_op_6;
assign Mult_result_3 = Mult_result_long_3;
assign Mult_result_long_4 = Mult_op_7 * Mult_op_8;
assign Mult_result_4 = Mult_result_long_4[31:0];


always_comb begin
	c_array[0][0] = 32'sd1448;
	c_array[0][1] = 32'sd1448;
	c_array[0][2] = 32'sd1448;
	c_array[0][3] = 32'sd1448;
	c_array[0][4] = 32'sd1448;
	c_array[0][5] = 32'sd1448;
	c_array[0][6] = 32'sd1448;
	c_array[0][7] = 32'sd1448;

	c_array[1][0] = 32'sd2008;
	c_array[1][1] = 32'sd1702;
	c_array[1][2] = 32'sd1137;
	c_array[1][3] = 32'sd399;
	c_array[1][4] = -32'sd399;
	c_array[1][5] = -32'sd1137;
	c_array[1][6] = -32'sd1702;
	c_array[1][7] = -32'sd2008;

	c_array[2][0] = 32'sd1892;
	c_array[2][1] = 32'sd783;
	c_array[2][2] = -32'sd783;
	c_array[2][3] = -32'sd1892;
	c_array[2][4] = -32'sd1892;
	c_array[2][5] = -32'sd783;
	c_array[2][6] = 32'sd783;
	c_array[2][7] = 32'sd1892;

	c_array[3][0] = 32'sd1702;
	c_array[3][1] = -32'sd399;
	c_array[3][2] = -32'sd2008;
	c_array[3][3] = -32'sd1137;
	c_array[3][4] = 32'sd1137;
	c_array[3][5] = 32'sd2008;
	c_array[3][6] = 32'sd399;
	c_array[3][7] = -32'sd1702;

	c_array[4][0] = 32'sd1448;
	c_array[4][1] = -32'sd1448;
	c_array[4][2] = -32'sd1448;
	c_array[4][3] = 32'sd1448;
	c_array[4][4] = 32'sd1448;
	c_array[4][5] = -32'sd1448;
	c_array[4][6] = -32'sd1448;
	c_array[4][7] = 32'sd1448;

	c_array[5][0] = 32'sd1137;
	c_array[5][1] = -32'sd2008;
	c_array[5][2] = 32'sd399;
	c_array[5][3] = 32'sd1702;
	c_array[5][4] = -32'sd1702;
	c_array[5][5] = -32'sd399;
	c_array[5][6] = 32'sd2008;
	c_array[5][7] = -32'sd1137;

	c_array[6][0] = 32'sd783;
	c_array[6][1] = -32'sd1892;
	c_array[6][2] = 32'sd1892;
	c_array[6][3] = -32'sd783;
	c_array[6][4] = -32'sd783;
	c_array[6][5] = 32'sd1892;
	c_array[6][6] = -32'sd1892;
	c_array[6][7] = 32'sd783;

	c_array[7][0] = 32'sd399;
	c_array[7][1] = -32'sd1137;
	c_array[7][2] = 32'sd1702;
	c_array[7][3] = -32'sd2008;
	c_array[7][4] = 32'sd2008;
	c_array[7][5] = -32'sd1702;
	c_array[7][6] = 32'sd1137;
	c_array[7][7] = -32'sd399;
end

always_ff @(posedge clock or negedge reset) begin
	if (~reset) begin
		SRAM_address_M2 <= M2_Y_START_ADDRESS;
		M2_data_counter <= 18'd1;
		SRAM_write_counter <= 18'd0;
		M2_SRAM_line_counter <= 18'd0;
		M2_SRAM_line_adder <= 18'd0;
		CC_counter <= 1'b0;
		row_counter <= 7'd0;
		M2_block_counter <= 11'd0;
		S_calculation <= 1'd0;
		S_Fetch <= 1'd0;
		Lead_out <= 1'd0;
		SRAM_write_lead <= 1'd0;
		SRAM_write <= 1'd0;
		S_prime_write <= 1'd0;
		SRAM_address_increment <= 1'd0;
		Write_row_tracker <= 8'd0;
		dp_0_address_counter <= 8'd0;
		dp_1_address_counter <= 8'd0;
		dp_2_address_counter <= 8'd0;
		dp_0_read_counter <= 8'd0;
		dp_1_read_counter <= 8'd0;
		dp_2_read_counter <= 8'd0;
		SRAM_write_en <= 1'd1;
		SRAM_write_data <= 16'd0;
		Total_rows <= 9'd0;
		U_flag <= 1'b0;
		U_write_flag <= 1'b0;
		Summation[0] <= 32'd0;
		Summation[1] <= 32'd0;
		Summation[2] <= 32'd0;
		Summation[3] <= 32'd0;
		Buff[0] <= 32'd0;
		Buff[1] <= 32'd0;
		Buff[2] <= 32'd0;
		Buff[3] <= 32'd0;
	
		Mult_op_1 <= 32'd0;
		Mult_op_2 <= 32'd0;
		Mult_op_3 <= 32'd0;
		Mult_op_4 <= 32'd0;
		Mult_op_5 <= 32'd0;
		Mult_op_6 <= 32'd0;
		Mult_op_7 <= 32'd0;
		Mult_op_8 <= 32'd0;

	
	end else begin
		case (M2_SRAM_state)
		
			M2_Idle:begin
				SRAM_address_M2 <= M2_Y_START_ADDRESS;
				M2_data_counter <= 18'd0;
				SRAM_write_counter <= 18'd0;
				M2_SRAM_line_counter <= 18'd0;
				CC_counter <= 1'b0;
				row_counter <= 7'd0;
				M2_block_counter <= 11'd0;
				M2_SRAM_line_adder <= 18'd0;
				S_calculation <= 1'd0;
				S_Fetch <= 1'd0;
				Lead_out <= 1'd0;
				S_prime_write <= 1'd0;
				SRAM_write <= 1'd0;
				SRAM_write_lead <= 1'd0;
				SRAM_address_increment <= 1'd0;
				Write_row_tracker <= 8'd0;
				dp_0_address_counter <= 8'd0;
				dp_1_address_counter <= 8'd0;
				dp_2_address_counter <= 8'd0;
				dp_0_read_counter <= 8'd0;
				dp_1_read_counter <= 8'd0;
				dp_2_read_counter <= 8'd0;
				SRAM_write_en <= 1'd1;
				SRAM_write_data <= 16'd0;
				Total_rows <= 9'd0;
				U_flag <= 1'b0;
				U_write_flag <= 1'b0;
				Summation[0] <= 32'd0;
				Summation[1] <= 32'd0;
				Summation[2] <= 32'd0;
				Summation[3] <= 32'd0;
				Buff[0] <= 32'd0;
				Buff[1] <= 32'd0;
				Buff[2] <= 32'd0;
				Buff[3] <= 32'd0;

				if (enable_M2) begin
					M2_SRAM_state <= M2_Lead_1;
				end

			end

			M2_Lead_1:begin
				//Reading from the SRAM into DP-RAM
				SRAM_address_M2 <= M2_Y_START_ADDRESS + M2_data_counter;
				M2_data_counter <= M2_data_counter + 18'd1;

				M2_SRAM_state <= M2_Lead_2;
				
			end

			M2_Lead_2:begin
				//Reading from the SRAM into DP-RAM
				SRAM_address_M2 <= M2_Y_START_ADDRESS + M2_data_counter;
				M2_data_counter <= M2_data_counter + 18'd1;

				M2_SRAM_state <= M2_Lead_3;
			end

			M2_Lead_3:begin
				//Reading from the SRAM into DP-RAM
				SRAM_address_M2 <= M2_Y_START_ADDRESS + M2_data_counter;
				M2_data_counter <= M2_data_counter + 18'd1;

				//Writing to the DP-RAM 0
				write_enable_a[0] <= 1'b1;
				address_0_A <= dp_0_address_counter;
				data_a[0] <= $signed(SRAM_read);

				M2_SRAM_state <= M2_Lead_4;
			end	

			M2_Lead_4:begin
				//Reading from the SRAM into DP-RAM
				SRAM_address_M2 <= M2_Y_START_ADDRESS + M2_data_counter;
				M2_data_counter <= M2_data_counter + 18'd1;

				//Writing to the DP-RAM 0
				write_enable_a[0] <= 1'b1;
				address_0_A <= dp_0_address_counter;
				data_a[0] <= $signed(SRAM_read);

				//Incrementing the DP 0 Counter
				dp_0_address_counter <= dp_0_address_counter + 1'd1;

				M2_SRAM_state <= M2_Lead_5;
			end

			M2_Lead_5:begin
				//Reading from the SRAM into DP-RAM
				SRAM_address_M2 <= M2_Y_START_ADDRESS + M2_data_counter;
				M2_data_counter <= M2_data_counter + 18'd1;

				//Writing to the DP-RAM 0
				address_0_A <= dp_0_address_counter;
				data_a[0] <= $signed(SRAM_read);

				//Incrementing the DP 0 Counter
				dp_0_address_counter <= dp_0_address_counter + 1'd1;

				M2_SRAM_state <= M2_Lead_6;
			end

			M2_Lead_6:begin
				//Reading from the SRAM into DP-RAM
				SRAM_address_M2 <= M2_Y_START_ADDRESS + M2_data_counter;
				M2_data_counter <= M2_data_counter + 18'd1;

				//Writing to the DP-RAM 0
				address_0_A <= dp_0_address_counter;
				data_a[0] <= $signed(SRAM_read);

				//Incrementing the DP 0 Counter
				dp_0_address_counter <= dp_0_address_counter + 1'd1;

				M2_SRAM_state <= M2_Lead_7;

			end

			M2_Lead_7:begin
				//Reading from the SRAM into DP-RAM
				SRAM_address_M2 <= M2_Y_START_ADDRESS + M2_data_counter;
				M2_data_counter <= M2_data_counter + 18'd1;

				//Writing to the DP-RAM 0
				address_0_A <= dp_0_address_counter;
				data_a[0] <= $signed(SRAM_read);

				//Reading from the DP_RAM_0
				if (dp_0_address_counter == 8'd59) begin
					address_0_B <= dp_0_read_counter;
					dp_0_read_counter <= dp_0_read_counter + 8'd1;
				end

				//Incrementing the DP 0 Counter
				dp_0_address_counter <= dp_0_address_counter + 1'd1;

				M2_SRAM_state <= M2_Lead_8;
			end	

			M2_Lead_8:begin
				//Reading from the SRAM into DP-RAM
				SRAM_address_M2 <= M2_Y_START_ADDRESS + M2_data_counter;
				M2_data_counter <= M2_data_counter + 18'd313;

				//Writing to the DP-RAM 0
				address_0_A <= dp_0_address_counter;
				data_a[0] <= $signed(SRAM_read);

				if (dp_0_address_counter == 8'd60) begin
					dp_0_address_counter <= dp_0_address_counter + 1'd1;
					address_0_B <= dp_0_read_counter;
					dp_0_read_counter <= dp_0_read_counter + 8'd1;
					Lead_out <= 1'd1;
					M2_SRAM_state <= M2_CC_1;
				end else begin
					//Incrementing the DP 0 Counter
					dp_0_address_counter <= dp_0_address_counter + 1'd1;
					M2_SRAM_state <= M2_Lead_9;
				end
			end

			M2_Lead_9:begin
				//Reading from the SRAM into DP-RAM
				SRAM_address_M2 <= M2_Y_START_ADDRESS + M2_data_counter;
				M2_data_counter <= M2_data_counter + 18'd1;

				//Writing to the DP-RAM 0
				address_0_A <= dp_0_address_counter;
				data_a[0] <= $signed(SRAM_read);

				//Incrementing the DP 0 Counter
				dp_0_address_counter <= dp_0_address_counter + 1'd1;

				M2_SRAM_state <= M2_Lead_10;
			end

			M2_Lead_10:begin
				//Reading from the SRAM into DP-RAM
				SRAM_address_M2 <= M2_Y_START_ADDRESS + M2_data_counter;
				M2_data_counter <= M2_data_counter + 18'd1;

				//Writing to the DP-RAM 0
				address_0_A <= dp_0_address_counter;
				data_a[0] <= $signed(SRAM_read);

				//Incrementing the DP 0 Counter
				dp_0_address_counter <= dp_0_address_counter + 1'd1;

				M2_SRAM_state <= M2_Lead_11;
			end

			M2_Lead_11:begin
				//Reading from the SRAM into DP-RAM
				SRAM_address_M2 <= M2_Y_START_ADDRESS + M2_data_counter;
				M2_data_counter <= M2_data_counter + 18'd1;

				//Writing to the DP-RAM 0
				address_0_A <= dp_0_address_counter;
				data_a[0] <= $signed(SRAM_read);
				//Incrementing the DP 0 Counter
				dp_0_address_counter <= dp_0_address_counter + 1'd1;
				CC_counter <= 1'b1;
				M2_SRAM_state <= M2_Lead_4;
			end

			M2_CC_1:begin
				if (dp_0_address_counter == 8'd61) begin
					address_0_A <= dp_0_address_counter;
					data_a[0] <= $signed(SRAM_read);
					dp_0_address_counter <= dp_0_address_counter + 1'd1;
				end else if (S_Fetch && S_calculation) begin
					//Reading from the SRAM into DP-RAM
					SRAM_address_M2 <= M2_Y_START_ADDRESS + M2_data_counter;
					M2_data_counter <= M2_data_counter + 18'd1;	
					if (S_prime_write) begin
						address_0_A <= dp_0_address_counter;
						data_a[0] <= $signed(SRAM_read);	
						//Incrementing the DP 0 Counter
						dp_0_address_counter <= dp_0_address_counter + 1'd1;						
					end			
				end

				if (SRAM_write) begin
					Buff[3] <= {Buff[3],read_data_b[2][7:0]};
					//reading from the DP-RAM 2
					address_2_B <= dp_2_read_counter;
					//incementing the DP-RAM 2 Counter
					dp_2_read_counter <= dp_2_read_counter + 8'd1;
					SRAM_address_M2 <= SRAM_write_counter;
					SRAM_write_en <= 1'b1;
					SRAM_write_data <= Buff[3];
				end

				if (S_calculation == 1'b1) begin
					//Reading from the DP-RAM 1 (T_Values)
					address_1_B <= 8'd16 + dp_1_read_counter;

					Mult_op_1 <= read_data_b[1];
					Mult_op_3 <= read_data_b[1];
					Mult_op_5 <= read_data_b[1];
					Mult_op_7 <= read_data_b[1];
				end else begin
					Mult_op_1 <= read_data_b[0];
					Mult_op_3 <= read_data_b[0];
					Mult_op_5 <= read_data_b[0];
					Mult_op_7 <= read_data_b[0];
				end
				
				Mult_op_2 <= c_array[0][0];
				Mult_op_4 <= c_array[0][1]; 
				Mult_op_6 <= c_array[0][2];
				Mult_op_8 <= c_array[0][3];			

				Summation[0] <= Summation[0] + Mult_result_1;
				Summation[1] <= Summation[1] + Mult_result_2;
				Summation[2] <= Summation[2] + Mult_result_3;
				Summation[3] <= Summation[3] + Mult_result_4;

				if (dp_0_read_counter < 8'd64) begin
					//Reading from the DP-RAM 0
					address_0_B <= dp_0_read_counter;
					//Increment DP-0-B Counter
					dp_0_read_counter <= dp_0_read_counter + 8'd1;
				end

				M2_SRAM_state <= M2_CC_2;
			end

			M2_CC_2:begin
				if (dp_0_address_counter == 8'd62) begin
					address_0_A <= dp_0_address_counter;
					data_a[0] <= $signed(SRAM_read);
					dp_0_address_counter <= dp_0_address_counter + 1'd1;
				end else if (S_Fetch && S_calculation) begin
					//Reading from the SRAM into DP-RAM
					SRAM_address_M2 <= M2_Y_START_ADDRESS + M2_data_counter;
					M2_data_counter <= M2_data_counter + 18'd1;	
					if (S_prime_write) begin
						address_0_A <= dp_0_address_counter;
						data_a[0] <= $signed(SRAM_read);	
						//Incrementing the DP 0 Counter
						dp_0_address_counter <= dp_0_address_counter + 1'd1;
					end			
				end

				if (SRAM_write) begin
					Buff[3] <= read_data_b[2][7:0];
					//reading from the DP-RAM 2
					address_2_B <= dp_2_read_counter;
					//incementing the DP-RAM 2 Counter
					dp_2_read_counter <= dp_2_read_counter + 8'd1;
					SRAM_address_M2 <= SRAM_write_counter;
					SRAM_write_en <= 1'b0;
					SRAM_write_data <= Buff[3];
					SRAM_write_counter <= SRAM_write_counter + 18'd1;
				end

				if (Lead_out && dp_2_address_counter == 8'd7) begin
					//Writing to DP-RAM 2 Port A
					address_2_A <= 7'd32 + dp_2_address_counter; 
					write_enable_a[2] <= 1'b1;
					//data_a[2] <= $signed(Summation[0] >>> 16);

					if (Summation[0][31] == 1'b1) begin
						data_a[2] <= 32'd0;
					end else if (|Summation[0][30:24] == 1'b1) begin
						data_a[2] <= 32'hFFFFFFFF;
					end else begin
						data_a[2] <= $signed(Summation[0] >>> 16);
					end

					//Writing to DP-RAM 2 Port B
					address_2_B <= 7'd40 + dp_2_address_counter;
					write_enable_b[2] <= 1'b1;
					//data_b[2] <= $signed(Summation[1] >>> 16);

					if (Summation[1][31] == 1'b1) begin
						data_b[2] <= 32'd0;
					end else if (|Summation[1][30:24] == 1'b1) begin
						data_b[2] <= 32'hFFFFFFFF;
					end else begin
						data_b[2] <= $signed(Summation[1] >>> 16);
					end

					//Buffering Summation 2 & 3
					Buff[0] <= Summation[2]; 
					Buff[1] <= Summation[3];
				end	

				if (CC_counter && !Lead_out) begin
					//Writing to DP-RAM 1 Port A
						address_1_A <= dp_1_address_counter; 
						write_enable_a[1] <= 1'b1;
						data_a[1] <= $signed(Summation[0] >>> 8);

						//Writing to DP-RAM 1 Port B
						address_1_B <= dp_1_address_counter + 1'd1; 
						write_enable_b[1] <= 1'b1;
						data_b[1] <= $signed(Summation[1] >>> 8);

						//Buffering Summation 2 & 3
						Buff[0] <= Summation[2]; 
						Buff[1] <= Summation[3];

						//Increment DP-1 Write Counter
						dp_1_address_counter <= dp_1_address_counter + 8'd2;

				end else if (dp_1_address_counter >= 58 && Lead_out) begin 
						address_1_A <= dp_1_address_counter; 
						write_enable_a[1] <= 1'b1;
						data_a[1] <= $signed(Summation[0] >>> 8);
						//Buffering Summation 1 & 2 & 3
						Buff[0] <= Summation[2]; 
						Buff[1] <= Summation[3];
						Buff[2] <= Summation[1]; 
						//Increment DP-1 Write Counter
						dp_1_address_counter <= dp_1_address_counter + 8'd1;

				end else if (S_calculation) begin

					//Writing to DP-RAM 2 Port A
					address_2_A <= 7'd32 + dp_2_address_counter; 
					write_enable_a[2] <= 1'b1;
					//data_a[2] <= $signed(Summation[0] >>> 16);

					if (Summation[0][31] == 1'b1) begin
						data_a[2] <= 32'd0;
					end else if (|Summation[0][30:24] == 1'b1) begin
						data_a[2] <= 32'hFFFFFFFF;
					end else begin
						data_a[2] <= $signed(Summation[0] >>> 16);
					end

					//Writing to DP-RAM 2 Port B
					address_2_B <= 7'd40 + dp_2_address_counter;
					write_enable_b[2] <= 1'b1;
					//data_b[2] <= $signed(Summation[1] >>> 16);

					if (Summation[1][31] == 1'b1) begin
						data_b[2] <= 32'd0;
					end else if (|Summation[1][30:24] == 1'b1) begin
						data_b[2] <= 32'hFFFFFFFF;
					end else begin
						data_b[2] <= $signed(Summation[1] >>> 16);
					end

					//Buffering Summation 2 & 3
					Buff[0] <= Summation[2]; 
					Buff[1] <= Summation[3];

				end

				if (S_calculation == 1'b1) begin
					//Reading from the DP-RAM 1 (T_Values)
					address_1_B <= 8'd24 + dp_1_read_counter;

					Mult_op_1 <= read_data_b[1];
					Mult_op_3 <= read_data_b[1];
					Mult_op_5 <= read_data_b[1];
					Mult_op_7 <= read_data_b[1];
				end else begin
					Mult_op_1 <= read_data_b[0];
					Mult_op_3 <= read_data_b[0];
					Mult_op_5 <= read_data_b[0];
					Mult_op_7 <= read_data_b[0];
				end
				
				Mult_op_2 <= c_array[1][0];
				Mult_op_4 <= c_array[1][1]; 
				Mult_op_6 <= c_array[1][2];
				Mult_op_8 <= c_array[1][3];

				Summation[0] <= Mult_result_1;
				Summation[1] <= Mult_result_2;
				Summation[2] <= Mult_result_3;
				Summation[3] <= Mult_result_4;

				if (dp_0_read_counter < 8'd64) begin
					//Reading from the DP-RAM
					address_0_B <= dp_0_read_counter;
					//Increment DP-0-B Counter
					dp_0_read_counter <= dp_0_read_counter + 8'd1;
				end

				M2_SRAM_state <= M2_CC_3;
			end

			M2_CC_3:begin
				if (dp_0_address_counter == 8'd63) begin
					address_0_A <= dp_0_address_counter;
					data_a[0] <= $signed(SRAM_read);
					S_Fetch <= 1'd0;
					S_prime_write <= 1'd0;
					M2_data_counter <= M2_data_counter - 17'd2560;
					Lead_out <= 1'b0;
				end	else if (S_Fetch && S_calculation) begin
					//Reading from the SRAM into DP-RAM
					SRAM_address_M2 <= M2_Y_START_ADDRESS + M2_data_counter;
					M2_data_counter <= M2_data_counter + 18'd1;	
					if (S_prime_write) begin
						address_0_A <= dp_0_address_counter;
						data_a[0] <= $signed(SRAM_read);	
						//Incrementing the DP 0 Counter
						dp_0_address_counter <= dp_0_address_counter + 1'd1;
					end
					S_prime_write <= 1'd1;			
				end		
				if (SRAM_write) begin
					Buff[3] <= {Buff[3],read_data_b[2][7:0]};
					//reading from the DP-RAM 2
					address_2_B <= dp_2_read_counter;
					//incementing the DP-RAM 2 Counter
					dp_2_read_counter <= dp_2_read_counter + 8'd1;
					SRAM_address_M2 <= SRAM_write_counter;
					SRAM_write_en <= 1'b1;
					SRAM_write_data <= Buff[3];
				end		
				if (Lead_out && dp_2_address_counter == 8'd7) begin

					//Writing to DP-RAM 2 Port A
					address_2_A <= 7'd48 + dp_2_address_counter; 
					//data_a[2] <= $signed(Buff[0] >>> 16);

					if (Buff[0][31] == 1'b1) begin
						data_a[2] <= 32'd0;
					end else if (|Buff[0][30:24] == 1'b1) begin
						data_a[2] <= 32'hFFFFFFFF;
					end else begin
						data_a[2] <= $signed(Buff[0] >>> 16);
					end


					//Writing to DP-RAM 2 Port B
					address_2_B <= 7'd56 + dp_2_address_counter; 
					//data_b[2] <= $signed(Buff[1] >>> 16);

					if (Buff[1][31] == 1'b1) begin
						data_b[2] <= 32'd0;
					end else if (|Buff[1][30:24] == 1'b1) begin
						data_b[2] <= 32'hFFFFFFFF;
					end else begin
						data_b[2] <= $signed(Buff[1] >>> 16);
					end

					SRAM_write <= 1'd1;
					SRAM_write_lead <= 1'd1;
				end	

				if (CC_counter && !Lead_out) begin
						//Writing to DP-RAM 1 Port A
						address_1_A <= dp_1_address_counter; 
						data_a[1] <= $signed(Buff[0] >>> 8);

						//Writing to DP-RAM 1 Port B
						address_1_B <= dp_1_address_counter + 1'd1; 
						data_b[1] <= $signed(Buff[1] >>> 8);

						//Increment DP-1 Write Counter
						dp_1_address_counter <= dp_1_address_counter + 8'd2;

				end else if (dp_1_address_counter >= 58 && Lead_out) begin 
						address_1_A <= dp_1_address_counter; 
						write_enable_a[1] <= 1'b1;
						data_a[1] <= $signed(Buff[2] >>> 8);

						//Increment DP-1 Write Counter
						dp_1_address_counter <= dp_1_address_counter + 8'd1;
				end else if (S_calculation)begin

					//Writing to DP-RAM 2 Port A
					address_2_A <= 7'd48 + dp_2_address_counter; 
					//data_a[2] <= $signed(Buff[0] >>> 16);

					if (Buff[0][31] == 1'b1) begin
						data_a[2] <= 32'd0;
					end else if (|Buff[0][30:24] == 1'b1) begin
						data_a[2] <= 32'hFFFFFFFF;
					end else begin
						data_a[2] <= $signed(Buff[0] >>> 16);
					end

					//Writing to DP-RAM 2 Port B
					address_2_B <= 7'd56 + dp_2_address_counter; 
					//data_b[2] <= $signed(Buff[1] >>> 16);

					if (Buff[1][31] == 1'b1) begin
						data_b[2] <= 32'd0;
					end else if (|Buff[1][30:24] == 1'b1) begin
						data_b[2] <= 32'hFFFFFFFF;
					end else begin
						data_b[2] <= $signed(Buff[1] >>> 16);
					end

					//Increment DP-1 Write Counter
					dp_2_address_counter <= dp_2_address_counter + 8'd1;						
				end	

				if (S_calculation == 1'b1) begin
					//Reading from the DP-RAM 1 (T_Values)
					address_1_B <= 8'd32 + dp_1_read_counter;

					Mult_op_1 <= read_data_b[1];
					Mult_op_3 <= read_data_b[1];
					Mult_op_5 <= read_data_b[1];
					Mult_op_7 <= read_data_b[1];
				end else begin
					Mult_op_1 <= read_data_b[0];
					Mult_op_3 <= read_data_b[0];
					Mult_op_5 <= read_data_b[0];
					Mult_op_7 <= read_data_b[0];
				end
				
				Mult_op_2 <= c_array[2][0];
				Mult_op_4 <= c_array[2][1]; 
				Mult_op_6 <= c_array[2][2];
				Mult_op_8 <= c_array[2][3];

				Summation[0] <= Summation[0] + Mult_result_1;
				Summation[1] <= Summation[1] + Mult_result_2;
				Summation[2] <= Summation[2] + Mult_result_3;
				Summation[3] <= Summation[3] + Mult_result_4;


				if (dp_0_read_counter < 8'd64) begin
					//Reading from the DP-RAM
					address_0_B <= dp_0_read_counter;
					//Increment DP-0-B Counter
					dp_0_read_counter <= dp_0_read_counter + 8'd1;
				end

				M2_SRAM_state <= M2_CC_4;
			end

			M2_CC_4:begin
				if (Lead_out && dp_2_address_counter == 8'd7) begin
					dp_2_address_counter <= 8'd0;
					Lead_out <= 1'b0;
					write_enable_a[2] <= 1'b0;
					write_enable_b[2] <= 1'b0;
				end					
				if (dp_1_address_counter >= 58 && Lead_out) begin 
					address_1_A <= dp_1_address_counter; 
					data_a[1] <= $signed(Buff[0] >>> 8);
					dp_1_address_counter <= dp_1_address_counter + 8'd1;
				end
				if (dp_0_address_counter == 8'd63) begin
					dp_0_address_counter <= 8'd0;
					write_enable_a[0] <= 1'b0;
				end	
				if (SRAM_write) begin
					Buff[3] <= read_data_b[2][7:0];
					//reading from the DP-RAM 2
					address_2_B <= dp_2_read_counter;
					//incementing the DP-RAM 2 Counter
					dp_2_read_counter <= dp_2_read_counter + 8'd1;
					if (!SRAM_write_lead) begin
						SRAM_address_M2 <= SRAM_write_counter;
						SRAM_write_en <= 1'b0;
						SRAM_write_data <= Buff[3];
						SRAM_write_counter <= SRAM_write_counter + 18'd1;
					end
				end
				if (S_Fetch && S_calculation && S_prime_write) begin
					//Reading from the SRAM into DP-RAM
					SRAM_address_M2 <= M2_Y_START_ADDRESS + M2_data_counter;
					M2_data_counter <= M2_data_counter + 18'd1;	

					//Writing to the DP-RAM 0
					write_enable_a[0] <= 1'b1;
					address_0_A <= dp_0_address_counter;
					data_a[0] <= $signed(SRAM_read);	

					//Incrementing the DP 0 Counter
					dp_0_address_counter <= dp_0_address_counter + 1'd1;						
				end

				if (S_calculation == 1'b1) begin
					//Reading from the DP-RAM 1 (T_Values)
					address_1_B <= 8'd40 + dp_1_read_counter;

					Mult_op_1 <= read_data_b[1];
					Mult_op_3 <= read_data_b[1];
					Mult_op_5 <= read_data_b[1];
					Mult_op_7 <= read_data_b[1];
				end else begin
					Mult_op_1 <= read_data_b[0];
					Mult_op_3 <= read_data_b[0];
					Mult_op_5 <= read_data_b[0];
					Mult_op_7 <= read_data_b[0];
				end
				
				Mult_op_2 <= c_array[3][0];
				Mult_op_4 <= c_array[3][1]; 
				Mult_op_6 <= c_array[3][2];
				Mult_op_8 <= c_array[3][3];

				Summation[0] <= Summation[0] + Mult_result_1;
				Summation[1] <= Summation[1] + Mult_result_2;
				Summation[2] <= Summation[2] + Mult_result_3;
				Summation[3] <= Summation[3] + Mult_result_4;


				if (dp_0_read_counter < 8'd64) begin
					//Reading from the DP-RAM
					address_0_B <= dp_0_read_counter;
					//Increment DP-0-B Counter
					dp_0_read_counter <= dp_0_read_counter + 8'd1;
				end

				M2_SRAM_state <= M2_CC_5;
			end

			M2_CC_5:begin
				if (dp_1_address_counter >= 58 & Lead_out) begin 
					address_1_A <= dp_1_address_counter; 
					data_a[1] <= $signed(Buff[1] >>> 8);
					//Increment DP-1 Write Counter
				end
				if (SRAM_write) begin
					Buff[3] <= {Buff[3],read_data_b[2][7:0]};
					//reading from the DP-RAM 2
					address_2_B <= dp_2_read_counter;
					//incementing the DP-RAM 2 Counter
					dp_2_read_counter <= dp_2_read_counter + 8'd1;
					if (!SRAM_write_lead) begin
						SRAM_address_M2 <= SRAM_write_counter;
						SRAM_write_en <= 1'b1;
						SRAM_write_data <= Buff[3];
					end
				end
				if (S_Fetch && S_calculation && S_prime_write) begin
					//Reading from the SRAM into DP-RAM
					SRAM_address_M2 <= M2_Y_START_ADDRESS + M2_data_counter;
					M2_data_counter <= M2_data_counter + 18'd1;	

					//Writing to the DP-RAM 0
					address_0_A <= dp_0_address_counter;
					data_a[0] <= $signed(SRAM_read);	

					//Incrementing the DP 0 Counter
					dp_0_address_counter <= dp_0_address_counter + 1'd1;						
				end

				if (S_calculation == 1'b1) begin
					//Reading from the DP-RAM 1 (T_Values)
					address_1_B <= 8'd48 + dp_1_read_counter;

					Mult_op_1 <= read_data_b[1];
					Mult_op_3 <= read_data_b[1];
					Mult_op_5 <= read_data_b[1];
					Mult_op_7 <= read_data_b[1];
				end else begin
					Mult_op_1 <= read_data_b[0];
					Mult_op_3 <= read_data_b[0];
					Mult_op_5 <= read_data_b[0];
					Mult_op_7 <= read_data_b[0];
				end
				
				Mult_op_2 <= c_array[4][0];
				Mult_op_4 <= c_array[4][1]; 
				Mult_op_6 <= c_array[4][2];
				Mult_op_8 <= c_array[4][3];

				Summation[0] <= Summation[0] + Mult_result_1;
				Summation[1] <= Summation[1] + Mult_result_2;
				Summation[2] <= Summation[2] + Mult_result_3;
				Summation[3] <= Summation[3] + Mult_result_4;

				if (dp_0_read_counter < 8'd64) begin
					//Reading from the DP-RAM
					address_0_B <= dp_0_read_counter;
					//Increment DP-0-B Counter
					dp_0_read_counter <= dp_0_read_counter + 8'd1;
				end

				M2_SRAM_state <= M2_CC_6;
			end

			M2_CC_6:begin
				if (dp_1_address_counter >= 58 & Lead_out) begin 
					dp_1_address_counter <= 8'd0;
					write_enable_a[1] <= 1'b0;
					Lead_out <= 1'd0;
				end
				if (S_Fetch && S_calculation && S_prime_write) begin
					//Reading from the SRAM into DP-RAM
					SRAM_address_M2 <= M2_Y_START_ADDRESS + M2_data_counter;
					M2_data_counter <= M2_data_counter + 18'd1;	

					//Writing to the DP-RAM 0
					address_0_A <= dp_0_address_counter;
					data_a[0] <= $signed(SRAM_read);	

					//Incrementing the DP 0 Counter
					dp_0_address_counter <= dp_0_address_counter + 1'd1;						
				end

				if (SRAM_write) begin
					if (Write_row_tracker == 8'd7) begin
						M2_block_counter <= M2_block_counter + 11'd1;
						M2_SRAM_line_counter <= M2_SRAM_line_counter + 17'd4;
						if (M2_block_counter == 11'd39) begin
							M2_SRAM_line_adder <= M2_SRAM_line_adder + 18'd1120;
							M2_block_counter <= 11'd0;
							Total_rows <= Total_rows + 9'd1;
						end
					end
					Buff[3] <= read_data_b[2][7:0];
					//reading from the DP-RAM 2
					address_2_B <= dp_2_read_counter;
					//incementing the DP-RAM 2 Counter
					dp_2_read_counter <= dp_2_read_counter + 8'd1;
						if (!SRAM_write_lead) begin
						SRAM_address_M2 <= SRAM_write_counter;
						SRAM_write_en <= 1'b0;
						SRAM_write_data <= Buff[3];
						if (U_write_flag) begin
							SRAM_write_counter <= SRAM_write_counter + 18'd77;
						end else begin
							SRAM_write_counter <= SRAM_write_counter + 18'd157;
						end
					end
				end

				if (S_calculation == 1'b1) begin
					//Reading from the DP-RAM 1 (T_Values)
					address_1_B <= 8'd56 + dp_1_read_counter;

					Mult_op_1 <= read_data_b[1];
					Mult_op_3 <= read_data_b[1];
					Mult_op_5 <= read_data_b[1];
					Mult_op_7 <= read_data_b[1];
				end else begin
					Mult_op_1 <= read_data_b[0];
					Mult_op_3 <= read_data_b[0];
					Mult_op_5 <= read_data_b[0];
					Mult_op_7 <= read_data_b[0];
				end
				
				Mult_op_2 <= c_array[5][0];
				Mult_op_4 <= c_array[5][1]; 
				Mult_op_6 <= c_array[5][2];
				Mult_op_8 <= c_array[5][3];

				Summation[0] <= Summation[0] + Mult_result_1;
				Summation[1] <= Summation[1] + Mult_result_2;
				Summation[2] <= Summation[2] + Mult_result_3;
				Summation[3] <= Summation[3] + Mult_result_4;

				if (dp_0_read_counter < 8'd64) begin
					//Reading from the DP-RAM
					address_0_B <= dp_0_read_counter;
					//Increment DP-0-B Counter
					dp_0_read_counter <= dp_0_read_counter - 8'd7;
				end

				M2_SRAM_state <= M2_CC_7;
			end

			M2_CC_7:begin
				if (S_Fetch && S_calculation && S_prime_write) begin
					//Reading from the SRAM into DP-RAM
					SRAM_address_M2 <= M2_Y_START_ADDRESS + M2_data_counter;
					M2_data_counter <= M2_data_counter + 18'd1;	

					//Writing to the DP-RAM 0
					address_0_A <= dp_0_address_counter;
					data_a[0] <= $signed(SRAM_read);	

					//Incrementing the DP 0 Counter
					dp_0_address_counter <= dp_0_address_counter + 1'd1;					
				end

				if (SRAM_write) begin
					if (Write_row_tracker == 8'd7) begin
						SRAM_write <= 1'd0;
						SRAM_write_en <= 1'd1;
						Write_row_tracker <= 8'd0;
						SRAM_write_counter <= M2_SRAM_line_adder + M2_SRAM_line_counter;
						SRAM_address_increment <= 1'd0;
					end else begin
						Buff[3] <= {Buff[3],read_data_b[2][7:0]};
						//reading from the DP-RAM 2
						address_2_B <= dp_2_read_counter;
						//incementing the DP-RAM 2 Counter
						dp_2_read_counter <= dp_2_read_counter + 8'd1;
							if (!SRAM_write_lead) begin
							SRAM_address_M2 <= SRAM_write_counter;
							SRAM_write_en <= 1'b1;
							SRAM_write_data <= Buff[3];
							Write_row_tracker <= Write_row_tracker + 8'd1;
						end
					end
					if (dp_2_read_counter > 8'd62) begin
						dp_2_read_counter <= 8'd0;
					end
				end

				if (S_calculation == 1'b1) begin
					//Reading from the DP-RAM 1 (T_Values)
					address_1_B <= dp_1_read_counter;

					Mult_op_1 <= read_data_b[1];
					Mult_op_3 <= read_data_b[1];
					Mult_op_5 <= read_data_b[1];
					Mult_op_7 <= read_data_b[1];
				end else begin
					Mult_op_1 <= read_data_b[0];
					Mult_op_3 <= read_data_b[0];
					Mult_op_5 <= read_data_b[0];
					Mult_op_7 <= read_data_b[0];
				end
				
				Mult_op_2 <= c_array[6][0];
				Mult_op_4 <= c_array[6][1]; 
				Mult_op_6 <= c_array[6][2];
				Mult_op_8 <= c_array[6][3];

				Summation[0] <= Summation[0] + Mult_result_1;
				Summation[1] <= Summation[1] + Mult_result_2;
				Summation[2] <= Summation[2] + Mult_result_3;
				Summation[3] <= Summation[3] + Mult_result_4;

				if (dp_0_read_counter < 8'd64) begin
					//Reading from the DP-RAM
					address_0_B <= dp_0_read_counter;
					//Increment DP-0-B Counter
					dp_0_read_counter <= dp_0_read_counter + 8'd1;
				end

				M2_SRAM_state <= M2_CC_8;
			end

			M2_CC_8:begin
				if (S_Fetch && S_calculation && S_prime_write) begin
					//Reading from the SRAM into DP-RAM
					SRAM_address_M2 <= M2_Y_START_ADDRESS + M2_data_counter;
					if (U_flag) begin
						M2_data_counter <= M2_data_counter + 18'd153;	
					end else begin
						M2_data_counter <= M2_data_counter + 18'd313;	
					end

					//Writing to the DP-RAM 0
					address_0_A <= dp_0_address_counter;
					data_a[0] <= $signed(SRAM_read);	

					//Incrementing the DP 0 Counter
					dp_0_address_counter <= dp_0_address_counter + 1'd1;						
				end

				if (SRAM_write) begin
					Buff[3] <= read_data_b[2][7:0];
					//reading from the DP-RAM 2
					address_2_B <= dp_2_read_counter;
					//incementing the DP-RAM 2 Counter
					dp_2_read_counter <= dp_2_read_counter + 8'd1;
					SRAM_address_M2 <= SRAM_write_counter;
					SRAM_write_en <= 1'b0;
					SRAM_write_data <= Buff[3];
					SRAM_write_counter <= SRAM_write_counter + 18'd1;
				end

				/*if (dp_1_address_counter < 8'd59 & CC_counter) begin
					//Writing to DP-RAM 1 Port A
					address_1_A <= dp_1_address_counter; 
					write_enable_a[1] <= 1'b1;
					data_a[1] <= $signed(Summation[0] >>> 8);

					//Writing to DP-RAM 1 Port B
					address_1_B <= dp_1_address_counter + 1'd1; 
					write_enable_b[1] <= 1'b1;
					data_b[1] <= $signed(Summation[1] >>> 8);

					//Buffering Summation 2 & 3
					Buff[0] <= Summation[2]; 
					Buff[1] <= Summation[3];

					//Increment DP-1 Write Counter
					dp_1_address_counter <= dp_1_address_counter + 8'd2;

				end else if (S_calculation) begin

					//Writing to DP-RAM 2 Port A
					address_2_A <= 7'd0 + dp_2_address_counter; 
					write_enable_a[2] <= 1'b1;
					data_a[2] <= $signed(Summation[0] >>> 16);

					//Writing to DP-RAM 2 Port B
					address_2_B <= 7'd8 + dp_2_address_counter;
					write_enable_b[2] <= 1'b1;
					data_b[2] <= $signed(Summation[1] >>> 16);

					//Buffering Summation 2 & 3
					Buff[0] <= Summation[2]; 
					Buff[1] <= Summation[3];				
				end*/

				if (S_calculation == 1'b1) begin
					//Reading from the DP-RAM 1 (T_Values)
					address_1_B <= 8'd8 + dp_1_read_counter;

					Mult_op_1 <= read_data_b[1];
					Mult_op_3 <= read_data_b[1];
					Mult_op_5 <= read_data_b[1];
					Mult_op_7 <= read_data_b[1];
				end else begin
					Mult_op_1 <= read_data_b[0];
					Mult_op_3 <= read_data_b[0];
					Mult_op_5 <= read_data_b[0];
					Mult_op_7 <= read_data_b[0];
				end
				
				Mult_op_2 <= c_array[7][0];
				Mult_op_4 <= c_array[7][1]; 
				Mult_op_6 <= c_array[7][2];
				Mult_op_8 <= c_array[7][3];

				/*Summation[0] <= Mult_result_1;
				Summation[1] <= Mult_result_2;
				Summation[2] <= Mult_result_3;
				Summation[3] <= Mult_result_4;*/

				Summation[0] <= Summation[0] + Mult_result_1;
				Summation[1] <= Summation[1] + Mult_result_2;
				Summation[2] <= Summation[2] + Mult_result_3;
				Summation[3] <= Summation[3] + Mult_result_4;

				if (dp_0_read_counter < 8'd64) begin
					//Reading from the DP-RAM
					address_0_B <= dp_0_read_counter;
					//Increment DP-0-B Counter
					dp_0_read_counter <= dp_0_read_counter + 8'd1;
				end

				M2_SRAM_state <= M2_CC_9;
			end

			M2_CC_9:begin
				if (S_Fetch && S_calculation && S_prime_write) begin
					//Reading from the SRAM into DP-RAM
					SRAM_address_M2 <= M2_Y_START_ADDRESS + M2_data_counter;
					M2_data_counter <= M2_data_counter + 18'd1;	

					//Writing to the DP-RAM 0
					address_0_A <= dp_0_address_counter;
					data_a[0] <= $signed(SRAM_read);	

					//Incrementing the DP 0 Counter
					dp_0_address_counter <= dp_0_address_counter + 1'd1;						
				end

				if (SRAM_write) begin
					Buff[3] <= {Buff[3],read_data_b[2][7:0]};
					//reading from the DP-RAM 2
					address_2_B <= dp_2_read_counter;
					//incementing the DP-RAM 2 Counter
					dp_2_read_counter <= dp_2_read_counter + 8'd1;
					SRAM_address_M2 <= SRAM_write_counter;
					SRAM_write_en <= 1'b1;
				end
				/*if (dp_1_address_counter < 8'd59 & CC_counter) begin
					//Writing to DP-RAM 1 Port A
					address_1_A <= dp_1_address_counter; 
					write_enable_a[1] <= 1'b1;
					data_a[1] <= $signed(Summation[0] >>> 8);

					//Writing to DP-RAM 1 Port B
					address_1_B <= dp_1_address_counter + 1'd1; 
					write_enable_b[1] <= 1'b1;
					data_b[1] <= $signed(Summation[1] >>> 8);

					//Buffering Summation 2 & 3
					Buff[0] <= Summation[2]; 
					Buff[1] <= Summation[3];

					//Increment DP-1 Write Counter
					dp_1_address_counter <= dp_1_address_counter + 8'd2;

				end else if (S_calculation) begin

					//Writing to DP-RAM 2 Port A
					address_2_A <= 7'd0 + dp_2_address_counter; 
					write_enable_a[2] <= 1'b1;
					data_a[2] <= $signed(Summation[0] >>> 16);

					//Writing to DP-RAM 2 Port B
					address_2_B <= 7'd8 + dp_2_address_counter;
					write_enable_b[2] <= 1'b1;
					data_b[2] <= $signed(Summation[1] >>> 16);

					//Buffering Summation 2 & 3
					Buff[0] <= Summation[2]; 
					Buff[1] <= Summation[3];				
				end*/
				/*if (dp_1_address_counter < 8'd59 && CC_counter) begin
					//Writing to DP-RAM 1 Port A
					address_1_A <= dp_1_address_counter; 
					data_a[1] <= $signed(Buff[0] >>> 8);

					//Writing to DP-RAM 1 Port B
					address_1_B <= dp_1_address_counter + 1'd1; 
					data_b[1] <= $signed(Buff[1] >>> 8);

					//Increment DP-1 Write Counter
					dp_1_address_counter <= dp_1_address_counter + 8'd2;

				end else if (S_calculation) begin

					//Writing to DP-RAM 2 Port A
					address_2_A <= 7'd16 + dp_2_address_counter; 
					data_a[2] <= $signed(Buff[0] >>> 16);

					//Writing to DP-RAM 2 Port B
					address_2_B <= 7'd24 + dp_2_address_counter; 
					data_b[2] <= $signed(Buff[1] >>> 16);
		
				end*/

				if (S_calculation == 1'b1) begin
					//Reading from the DP-RAM 1 (T_Values)
					address_1_B <= 8'd16 + dp_1_read_counter;

					Mult_op_1 <= read_data_b[1];
					Mult_op_3 <= read_data_b[1];
					Mult_op_5 <= read_data_b[1];
					Mult_op_7 <= read_data_b[1];
				end else begin
					Mult_op_1 <= read_data_b[0];
					Mult_op_3 <= read_data_b[0];
					Mult_op_5 <= read_data_b[0];
					Mult_op_7 <= read_data_b[0];
				end
				
				Mult_op_2 <= c_array[0][4];
				Mult_op_4 <= c_array[0][5]; 
				Mult_op_6 <= c_array[0][6];
				Mult_op_8 <= c_array[0][7];

				Summation[0] <= Summation[0] + Mult_result_1;
				Summation[1] <= Summation[1] + Mult_result_2;
				Summation[2] <= Summation[2] + Mult_result_3;
				Summation[3] <= Summation[3] + Mult_result_4;

				/*Summation[0] <= Mult_result_1;
				Summation[1] <= Mult_result_2;
				Summation[2] <= Mult_result_3;
				Summation[3] <= Mult_result_4;*/

				if (dp_0_read_counter < 8'd64) begin
					//Reading from the DP-RAM
					address_0_B <= dp_0_read_counter;
					//Increment DP-0-B Counter
					dp_0_read_counter <= dp_0_read_counter + 8'd1;
				end

				M2_SRAM_state <= M2_CC_10;
			end

			M2_CC_10:begin
				if (S_Fetch && S_calculation && S_prime_write) begin
					//Reading from the SRAM into DP-RAM
					SRAM_address_M2 <= M2_Y_START_ADDRESS + M2_data_counter;
					M2_data_counter <= M2_data_counter + 18'd1;	

					//Writing to the DP-RAM 0
					address_0_A <= dp_0_address_counter;
					data_a[0] <= $signed(SRAM_read);	

					//Incrementing the DP 0 Counter
					dp_0_address_counter <= dp_0_address_counter + 1'd1;						
				end
//*******************************************************************************************************
				if (SRAM_write) begin
					Buff[3] <= read_data_b[2][7:0];
					//reading from the DP-RAM 2
					address_2_B <= dp_2_read_counter;
					//incementing the DP-RAM 2 Counter
					dp_2_read_counter <= dp_2_read_counter + 8'd1;
					SRAM_address_M2 <= SRAM_write_counter;
					SRAM_write_en <= 1'b0;
					SRAM_write_data <= Buff[3];
					SRAM_write_counter <= SRAM_write_counter + 18'd1;
				end
				if (dp_1_address_counter < 8'd59 & CC_counter) begin
					//Writing to DP-RAM 1 Port A
					address_1_A <= dp_1_address_counter; 
					write_enable_a[1] <= 1'b1;
					data_a[1] <= $signed(Summation[0] >>> 8);

					//Writing to DP-RAM 1 Port B
					address_1_B <= dp_1_address_counter + 1'd1; 
					write_enable_b[1] <= 1'b1;
					data_b[1] <= $signed(Summation[1] >>> 8);

					//Buffering Summation 2 & 3
					Buff[0] <= Summation[2]; 
					Buff[1] <= Summation[3];

					//Increment DP-1 Write Counter
					dp_1_address_counter <= dp_1_address_counter + 8'd2;

				end else if (S_calculation) begin

					//Writing to DP-RAM 2 Port A
					address_2_A <= 7'd0 + dp_2_address_counter; 
					write_enable_a[2] <= 1'b1;
					//data_a[2] <= $signed(Summation[0] >>> 16);

					if (Summation[0][31] == 1'b1) begin
						data_a[2] <= 32'd0;
					end else if (|Summation[0][30:24] == 1'b1) begin
						data_a[2] <= 32'hFFFFFFFF;
					end else begin
						data_a[2] <= $signed(Summation[0] >>> 16);
					end

					//Writing to DP-RAM 2 Port B
					address_2_B <= 7'd8 + dp_2_address_counter;
					write_enable_b[2] <= 1'b1;
					//data_b[2] <= $signed(Summation[1] >>> 16);

					if (Summation[1][31] == 1'b1) begin
						data_b[2] <= 32'd0;
					end else if (|Summation[1][30:24] == 1'b1) begin
						data_b[2] <= 32'hFFFFFFFF;
					end else begin
						data_b[2] <= $signed(Summation[1] >>> 16);
					end

					//Buffering Summation 2 & 3
					Buff[0] <= Summation[2]; 
					Buff[1] <= Summation[3];				
				end
				//***********************************************************************************************************
				//************************************************************************************************************
				/*if (dp_1_address_counter < 8'd59 && CC_counter) begin
					//Writing to DP-RAM 1 Port A
					address_1_A <= dp_1_address_counter; 
					data_a[1] <= $signed(Buff[0] >>> 8);

					//Writing to DP-RAM 1 Port B
					address_1_B <= dp_1_address_counter + 1'd1; 
					data_b[1] <= $signed(Buff[1] >>> 8);

					//Increment DP-1 Write Counter
					dp_1_address_counter <= dp_1_address_counter + 8'd2;

				end else if (S_calculation) begin

					//Writing to DP-RAM 2 Port A
					address_2_A <= 7'd16 + dp_2_address_counter; 
					data_a[2] <= $signed(Buff[0] >>> 16);

					//Writing to DP-RAM 2 Port B
					address_2_B <= 7'd24 + dp_2_address_counter; 
					data_b[2] <= $signed(Buff[1] >>> 16);
				end*/
				//***********************************************************************************************************

				if (S_calculation == 1'b1) begin
					//Reading from the DP-RAM 1 (T_Values)
					address_1_B <= 8'd24 + dp_1_read_counter;

					Mult_op_1 <= read_data_b[1];
					Mult_op_3 <= read_data_b[1];
					Mult_op_5 <= read_data_b[1];
					Mult_op_7 <= read_data_b[1];
				end else begin
					Mult_op_1 <= read_data_b[0];
					Mult_op_3 <= read_data_b[0];
					Mult_op_5 <= read_data_b[0];
					Mult_op_7 <= read_data_b[0];
				end
				
				Mult_op_2 <= c_array[1][4];
				Mult_op_4 <= c_array[1][5]; 
				Mult_op_6 <= c_array[1][6];
				Mult_op_8 <= c_array[1][7];

				Summation[0] <= Summation[0] + Mult_result_1;
				Summation[1] <= Summation[1] + Mult_result_2;
				Summation[2] <= Summation[2] + Mult_result_3;
				Summation[3] <= Summation[3] + Mult_result_4;

				Summation[0] <= Mult_result_1;
				Summation[1] <= Mult_result_2;
				Summation[2] <= Mult_result_3;
				Summation[3] <= Mult_result_4;

				if (dp_0_read_counter < 8'd64) begin
					//Reading from the DP-RAM
					address_0_B <= dp_0_read_counter;
					//Increment DP-0-B Counter
					dp_0_read_counter <= dp_0_read_counter + 8'd1;
				end
		

				M2_SRAM_state <= M2_CC_11;
			end

			M2_CC_11:begin
				if (S_Fetch && S_calculation && S_prime_write) begin
					//Reading from the SRAM into DP-RAM
					SRAM_address_M2 <= M2_Y_START_ADDRESS + M2_data_counter;
					M2_data_counter <= M2_data_counter + 18'd1;	

					//Writing to the DP-RAM 0
					address_0_A <= dp_0_address_counter;
					data_a[0] <= $signed(SRAM_read);	

					//Incrementing the DP 0 Counter
					dp_0_address_counter <= dp_0_address_counter + 1'd1;						
				end

				if (SRAM_write) begin
					Buff[3] <= {Buff[3],read_data_b[2][7:0]};
					//reading from the DP-RAM 2
					address_2_B <= dp_2_read_counter;
					//incementing the DP-RAM 2 Counter
					dp_2_read_counter <= dp_2_read_counter + 8'd1;
					SRAM_address_M2 <= SRAM_write_counter;
					SRAM_write_en <= 1'b1;
					SRAM_write_data <= Buff[3];
				end
				//************************************************************************************************************
				if (dp_1_address_counter < 8'd59 && CC_counter) begin
					//Writing to DP-RAM 1 Port A
					address_1_A <= dp_1_address_counter; 
					data_a[1] <= $signed(Buff[0] >>> 8);

					//Writing to DP-RAM 1 Port B
					address_1_B <= dp_1_address_counter + 1'd1; 
					data_b[1] <= $signed(Buff[1] >>> 8);

					//Increment DP-1 Write Counter
					dp_1_address_counter <= dp_1_address_counter + 8'd2;

				end else if (S_calculation) begin

					//Writing to DP-RAM 2 Port A
					address_2_A <= 7'd16 + dp_2_address_counter; 
					//data_a[2] <= $signed(Buff[0] >>> 16);

					if (Buff[0][31] == 1'b1) begin
						data_a[2] <= 32'd0;
					end else if (|Buff[0][30:24] == 1'b1) begin
						data_a[2] <= 32'hFFFFFFFF;
					end else begin
						data_a[2] <= $signed(Buff[0] >>> 16);
					end

					//Writing to DP-RAM 2 Port B
					address_2_B <= 7'd24 + dp_2_address_counter; 
					//data_b[2] <= $signed(Buff[1] >>> 16);
					if (Buff[1][31] == 1'b1) begin
						data_b[2] <= 32'd0;
					end else if (|Buff[1][30:24] == 1'b1) begin
						data_b[2] <= 32'hFFFFFFFF;
					end else begin
						data_b[2] <= ($signed(Buff[1])) >>> 16;
					end

				end
				//***********************************************************************************************************
				if (S_calculation == 1'b1) begin
					//Reading from the DP-RAM 1 (T_Values)
					address_1_B <= 8'd32 + dp_1_read_counter;

					Mult_op_1 <= read_data_b[1];
					Mult_op_3 <= read_data_b[1];
					Mult_op_5 <= read_data_b[1];
					Mult_op_7 <= read_data_b[1];
				end else begin
					Mult_op_1 <= read_data_b[0];
					Mult_op_3 <= read_data_b[0];
					Mult_op_5 <= read_data_b[0];
					Mult_op_7 <= read_data_b[0];
				end
				
				Mult_op_2 <= c_array[2][4];
				Mult_op_4 <= c_array[2][5]; 
				Mult_op_6 <= c_array[2][6];
				Mult_op_8 <= c_array[2][7];

				Summation[0] <= Summation[0] + Mult_result_1;
				Summation[1] <= Summation[1] + Mult_result_2;
				Summation[2] <= Summation[2] + Mult_result_3;
				Summation[3] <= Summation[3] + Mult_result_4;

				if (dp_0_read_counter < 8'd64) begin
					//Reading from the DP-RAM
					address_0_B <= dp_0_read_counter;
					//Increment DP-0-B Counter
					dp_0_read_counter <= dp_0_read_counter + 8'd1;
				end

				M2_SRAM_state <= M2_CC_12;
			end

			M2_CC_12:begin
				if (S_Fetch && S_calculation && S_prime_write) begin
					//Reading from the SRAM into DP-RAM
					SRAM_address_M2 <= M2_Y_START_ADDRESS + M2_data_counter;
					M2_data_counter <= M2_data_counter + 18'd1;	

					//Writing to the DP-RAM 0
					address_0_A <= dp_0_address_counter;
					data_a[0] <= $signed(SRAM_read);	

					//Incrementing the DP 0 Counter
					dp_0_address_counter <= dp_0_address_counter + 1'd1;						
				end

				if (SRAM_write) begin
					Buff[3] <= read_data_b[2][7:0];
					//reading from the DP-RAM 2
					address_2_B <= dp_2_read_counter;
					//incementing the DP-RAM 2 Counter
					dp_2_read_counter <= dp_2_read_counter + 8'd1;
					SRAM_address_M2 <= SRAM_write_counter;
					SRAM_write_en <= 1'b0;
					SRAM_write_data <= Buff[3];
					SRAM_write_counter <= SRAM_write_counter + 18'd1;
					SRAM_write_lead <= 1'b0;
				end

				if (S_calculation == 1'b1) begin
					//Reading from the DP-RAM 1 (T_Values)
					address_1_B <= 8'd40 + dp_1_read_counter;

					Mult_op_1 <= read_data_b[1];
					Mult_op_3 <= read_data_b[1];
					Mult_op_5 <= read_data_b[1];
					Mult_op_7 <= read_data_b[1];
				end else begin
					Mult_op_1 <= read_data_b[0];
					Mult_op_3 <= read_data_b[0];
					Mult_op_5 <= read_data_b[0];
					Mult_op_7 <= read_data_b[0];
				end
				
				Mult_op_2 <= c_array[3][4];
				Mult_op_4 <= c_array[3][5]; 
				Mult_op_6 <= c_array[3][6];
				Mult_op_8 <= c_array[3][7];

				Summation[0] <= Summation[0] + Mult_result_1;
				Summation[1] <= Summation[1] + Mult_result_2;
				Summation[2] <= Summation[2] + Mult_result_3;
				Summation[3] <= Summation[3] + Mult_result_4;

				if (dp_0_read_counter < 8'd64) begin
					//Reading from the DP-RAM
					address_0_B <= dp_0_read_counter;
					//Increment DP-0-B Counter
					dp_0_read_counter <= dp_0_read_counter + 8'd1;
				end

				if (dp_1_address_counter == 8'd60) begin
					write_enable_b[1] <= 1'b0;
				end
				M2_SRAM_state <= M2_CC_13;
			end

			M2_CC_13:begin
				if (S_Fetch && S_calculation && S_prime_write) begin
					//Reading from the SRAM into DP-RAM
					SRAM_address_M2 <= M2_Y_START_ADDRESS + M2_data_counter;
					M2_data_counter <= M2_data_counter + 18'd1;	

					//Writing to the DP-RAM 0
					address_0_A <= dp_0_address_counter;
					data_a[0] <= $signed(SRAM_read);	

					//Incrementing the DP 0 Counter
					dp_0_address_counter <= dp_0_address_counter + 1'd1;						
				end

				if (SRAM_write) begin
					Buff[3] <= {Buff[3],read_data_b[2][7:0]};
					//reading from the DP-RAM 2
					address_2_B <= dp_2_read_counter;
					//incementing the DP-RAM 2 Counter
					dp_2_read_counter <= dp_2_read_counter + 8'd1;
					SRAM_address_M2 <= SRAM_write_counter;
					SRAM_write_en <= 1'b1;
					SRAM_write_data <= Buff[3];
				end

				if (S_calculation == 1'b1) begin
					//Reading from the DP-RAM 1 (T_Values)
					address_1_B <= 8'd48 + dp_1_read_counter;

					Mult_op_1 <= read_data_b[1];
					Mult_op_3 <= read_data_b[1];
					Mult_op_5 <= read_data_b[1];
					Mult_op_7 <= read_data_b[1];
				end else begin
					Mult_op_1 <= read_data_b[0];
					Mult_op_3 <= read_data_b[0];
					Mult_op_5 <= read_data_b[0];
					Mult_op_7 <= read_data_b[0];
				end
				
				Mult_op_2 <= c_array[4][4];
				Mult_op_4 <= c_array[4][5]; 
				Mult_op_6 <= c_array[4][6];
				Mult_op_8 <= c_array[4][7];

				Summation[0] <= Summation[0] + Mult_result_1;
				Summation[1] <= Summation[1] + Mult_result_2;
				Summation[2] <= Summation[2] + Mult_result_3;
				Summation[3] <= Summation[3] + Mult_result_4;

				if (dp_0_read_counter < 8'd64) begin
					//Reading from the DP-RAM
					address_0_B <= dp_0_read_counter;
					//Increment DP-0-B Counter
					dp_0_read_counter <= dp_0_read_counter + 8'd1;
				end

				M2_SRAM_state <= M2_CC_14;
			end

			M2_CC_14:begin
				if (S_Fetch && S_calculation && S_prime_write) begin
					//Reading from the SRAM into DP-RAM
					SRAM_address_M2 <= M2_Y_START_ADDRESS + M2_data_counter;
					M2_data_counter <= M2_data_counter + 18'd1;	

					//Writing to the DP-RAM 0
					address_0_A <= dp_0_address_counter;
					data_a[0] <= $signed(SRAM_read);	

					//Incrementing the DP 0 Counter
					dp_0_address_counter <= dp_0_address_counter + 1'd1;						
				end

				if (SRAM_write) begin
					Buff[3] <= read_data_b[2][7:0];
					//reading from the DP-RAM 2
					address_2_B <= dp_2_read_counter;
					//incementing the DP-RAM 2 Counter
					dp_2_read_counter <= dp_2_read_counter + 8'd1;
					SRAM_address_M2 <= SRAM_write_counter;
					SRAM_write_en <= 1'b0;
					SRAM_write_data <= Buff[3];
					if (U_flag && Total_rows > 8'd29) begin
					SRAM_write_counter <= SRAM_write_counter + 18'd77;
					U_write_flag <= 1'b1;
					end else begin
						SRAM_write_counter <= SRAM_write_counter + 18'd157;
					end
				end

				if (S_calculation == 1'b1) begin
					//Reading from the DP-RAM 1 (T_Values)
					address_1_B <= 8'd56 + dp_1_read_counter;
					if (dp_1_read_counter == 8'd7) begin
						//Reset DP1 Read counter
						dp_1_read_counter <= 8'd0;
					end else begin
						//Increment DP1 Read counter
						dp_1_read_counter <= dp_1_read_counter + 8'd1;
					end

					Mult_op_1 <= read_data_b[1];
					Mult_op_3 <= read_data_b[1];
					Mult_op_5 <= read_data_b[1];
					Mult_op_7 <= read_data_b[1];
				end else begin
					Mult_op_1 <= read_data_b[0];
					Mult_op_3 <= read_data_b[0];
					Mult_op_5 <= read_data_b[0];
					Mult_op_7 <= read_data_b[0];
				end
				
				Mult_op_2 <= c_array[5][4];
				Mult_op_4 <= c_array[5][5]; 
				Mult_op_6 <= c_array[5][6];
				Mult_op_8 <= c_array[5][7];

				Summation[0] <= Summation[0] + Mult_result_1;
				Summation[1] <= Summation[1] + Mult_result_2;
				Summation[2] <= Summation[2] + Mult_result_3;
				Summation[3] <= Summation[3] + Mult_result_4;

				if (dp_0_read_counter < 8'd64) begin
					//Reading from the DP-RAM
					address_0_B <= dp_0_read_counter;
					//Increment DP-0-B Counter
					dp_0_read_counter <= dp_0_read_counter + 8'd1;
				end else if (dp_2_address_counter == 8'd7) begin
					dp_0_read_counter <= 8'd0;
				end

				M2_SRAM_state <= M2_CC_15;
			end

			M2_CC_15:begin
				if (S_Fetch && S_calculation && S_prime_write) begin
					//Reading from the SRAM into DP-RAM
					SRAM_address_M2 <= M2_Y_START_ADDRESS + M2_data_counter;
					M2_data_counter <= M2_data_counter + 18'd1;	

					//Writing to the DP-RAM 0
					address_0_A <= dp_0_address_counter;
					data_a[0] <= $signed(SRAM_read);	

					//Incrementing the DP 0 Counter
					dp_0_address_counter <= dp_0_address_counter + 1'd1;						
				end

				if (SRAM_write) begin
					Buff[3] <= {Buff[3],read_data_b[2][7:0]};
					//reading from the DP-RAM 2
					address_2_B <= dp_2_read_counter;
					//incementing the DP-RAM 2 Counter
					dp_2_read_counter <= dp_2_read_counter + 8'd1;
					SRAM_address_M2 <= SRAM_write_counter;
					SRAM_write_en <= 1'b1;
					SRAM_write_data <= Buff[3];
					Write_row_tracker <= Write_row_tracker + 8'd1;
				end

				if (dp_1_address_counter > 8'd58 || S_calculation == 1'b1) begin					
					//Reading from the DP-RAM 1 (T_Values)
					address_1_B <= dp_1_read_counter;
				end
				if (S_calculation == 1'b1) begin
					Mult_op_1 <= read_data_b[1];
					Mult_op_3 <= read_data_b[1];
					Mult_op_5 <= read_data_b[1];
					Mult_op_7 <= read_data_b[1];
				end else begin
					Mult_op_1 <= read_data_b[0];
					Mult_op_3 <= read_data_b[0];
					Mult_op_5 <= read_data_b[0];
					Mult_op_7 <= read_data_b[0];
				end
				
				Mult_op_2 <= c_array[6][4];
				Mult_op_4 <= c_array[6][5]; 
				Mult_op_6 <= c_array[6][6];
				Mult_op_8 <= c_array[6][7];

				Summation[0] <= Summation[0] + Mult_result_1;
				Summation[1] <= Summation[1] + Mult_result_2;
				Summation[2] <= Summation[2] + Mult_result_3;
				Summation[3] <= Summation[3] + Mult_result_4;

				if (dp_0_read_counter < 8'd64) begin
					//Reading from the DP-RAM
					address_0_B <= dp_0_read_counter;
					//Increment DP-0-B Counter
					dp_0_read_counter <= dp_0_read_counter + 8'd1;
				end

				M2_SRAM_state <= M2_CC_16;
			end

			M2_CC_16: begin

				if (row_counter == 7'd6 && M2_block_counter == 18'd39 && !SRAM_address_increment) begin
					M2_data_counter <= M2_data_counter + 18'd2240;
					SRAM_address_increment <= 1'd1;
				end

				if (S_Fetch && S_calculation && S_prime_write) begin
					//Reading from the SRAM into DP-RAM
					SRAM_address_M2 <= M2_Y_START_ADDRESS + M2_data_counter;
					if (U_flag) begin
						M2_data_counter <= M2_data_counter + 18'd153;	
					end else begin
						M2_data_counter <= M2_data_counter + 18'd313;	
					end

					//Writing to the DP-RAM 0
					address_0_A <= dp_0_address_counter;
					data_a[0] <= $signed(SRAM_read);	

					//Incrementing the DP 0 Counter
					dp_0_address_counter <= dp_0_address_counter + 1'd1;						
				end

				if (SRAM_write) begin
					Buff[3] <= read_data_b[2][7:0];
					//reading from the DP-RAM 2
					address_2_B <= dp_2_read_counter;
					//incementing the DP-RAM 2 Counter
					dp_2_read_counter <= dp_2_read_counter + 8'd1;
					SRAM_address_M2 <= SRAM_write_counter;
					SRAM_write_en <= 1'b0;
					SRAM_write_data <= Buff[3];
					SRAM_write_counter <= SRAM_write_counter + 18'd1;
				end

				if (dp_1_address_counter > 8'd58 || S_calculation == 1'b1) begin					
					//Reading from the DP-RAM 1 (T_Values)
					address_1_B <= 8'd8 + dp_1_read_counter;
				end

				if (S_calculation == 1'b1) begin
					Mult_op_1 <= read_data_b[1];
					Mult_op_3 <= read_data_b[1];
					Mult_op_5 <= read_data_b[1];
					Mult_op_7 <= read_data_b[1];
				end else begin
					Mult_op_1 <= read_data_b[0];
					Mult_op_3 <= read_data_b[0];
					Mult_op_5 <= read_data_b[0];
					Mult_op_7 <= read_data_b[0];
				end
				
				Mult_op_2 <= c_array[7][4];
				Mult_op_4 <= c_array[7][5]; 
				Mult_op_6 <= c_array[7][6];
				Mult_op_8 <= c_array[7][7];

				Summation[0] <= Summation[0] + Mult_result_1;
				Summation[1] <= Summation[1] + Mult_result_2;
				Summation[2] <= Summation[2] + Mult_result_3;
				Summation[3] <= Summation[3] + Mult_result_4;

				row_counter <= row_counter + 7'd1;
				if (row_counter >= 7'd7) begin
					if (dp_2_address_counter == 8'd7) begin
						CC_counter <= 1'b1;
						S_calculation <= 1'b0;
						S_Fetch <= 1'b0;
					end else begin
						S_calculation <= 1'b1;
						S_Fetch <= 1'b1;
					end	
					if (address_0_A == 7'd63) begin
						M2_data_counter <= M2_data_counter + 17'd8;
						address_0_A <= 7'd0;
					end
					if (address_0_B == 7'd63) begin
						CC_counter <= 1'b0;
						address_0_B <= 7'd0;
					end
					Lead_out <= 1'b1;
					row_counter <= 7'd0;
					if (Total_rows == 8'd80 ) begin
						stop_M2 <= 1'b1;
					end
					M2_SRAM_state <= M2_CC_1;
				end
				if (dp_0_read_counter < 8'd64) begin
					//Reading from the DP-RAM
					address_0_B <= dp_0_read_counter;
					//Increment DP-0-B Counter
					dp_0_read_counter <= dp_0_read_counter + 8'd1;
				end
				if (Total_rows == 7'd29 && M2_block_counter == 18'd39) begin
					U_flag <= 1'b1;
				end
				M2_SRAM_state <= M2_CC_1;
			end
			default: M2_SRAM_state <= M2_Idle;
		endcase
	end
end


endmodule