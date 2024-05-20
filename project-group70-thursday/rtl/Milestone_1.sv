/*
Copyright by Henry Ko and Nicola Nicolici
Department of Electrical and Computer Engineering
McMaster University
Ontario, Canada
*/

`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"

// This is the top module
// It connects the UART, SRAM and VGA together.
// It gives access to the SRAM for UART and VGA
module Milestone_1 (
		/////// board clocks                      ////////////
		input logic clock,                   // 50 MHz clock
		input logic reset,
		
		input logic enable_M1,
		input logic [15:0] SRAM_read,
		
		output logic stop_M1,
		output logic [17:0] SRAM_address_M1,
		output logic [15:0] SRAM_write_data,
		output logic SRAM_write_en

);

M1_SRAM_state_type M1_SRAM_state;
	


logic [17:0] data_counter;
logic [17:0] Y_counter;
logic [17:0] RGB_counter;
logic [17:0] Pixel_counter;

logic [7:0] U [5:0];
logic [7:0] V [5:0];
logic [7:0] Y_even;
logic [7:0] Y_odd;
logic [15:0] V_buff;
logic [15:0] U_buff; 

logic [7:0] U_e;
logic [7:0] V_e;


logic [31:0] Multi_p1_buff;

logic [31:0] U_prime;
logic [31:0] V_prime;

logic CC_tracker;
logic End_case;
logic End_case_y;
logic Last_write;


logic [31:0] Mult_op_1, Mult_op_2, Mult_op_3, Mult_op_4, Mult_op_5, Mult_op_6, Mult_op_7, Mult_op_8, Mult_result_1, Mult_result_2, Mult_result_3, Mult_result_4;
logic [63:0] Mult_result_long_1, Mult_result_long_2, Mult_result_long_3, Mult_result_long_4;

assign Mult_result_long_1 = Mult_op_1 * Mult_op_2;
assign Mult_result_1 = Mult_result_long_1[31:0];

assign Mult_result_long_2 = Mult_op_3 * Mult_op_4;
assign Mult_result_2 = Mult_result_long_2[31:0];

assign Mult_result_long_3 = Mult_op_5 * Mult_op_6;
assign Mult_result_3 = Mult_result_long_3[31:0];

assign Mult_result_long_4 = Mult_op_7 * Mult_op_8;
assign Mult_result_4 = Mult_result_long_4[31:0];

logic [31:0] Mult_result_1_preclip, Mult_result_2_preclip, Mult_result_3_preclip, Mult_result_4_preclip, Mult_result_5_preclip, Mult_result_6_preclip;

assign Mult_result_1_preclip = Mult_result_1 + Mult_result_4;
assign Mult_result_2_preclip = Mult_result_1 + Mult_result_2 + Mult_result_3;
assign Mult_result_3_preclip = Multi_p1_buff + Mult_result_3;
assign Mult_result_4_preclip = Mult_result_1 + Mult_result_4;
assign Mult_result_5_preclip = Mult_result_1 + Mult_result_2 + Mult_result_4;
assign Mult_result_6_preclip = Mult_result_1 + Mult_result_3;


logic [31:0] Mult_result_1_clip, Mult_result_2_clip, Mult_result_3_clip, Mult_result_4_clip, Mult_result_5_clip, Mult_result_6_clip;

assign Mult_result_1_clip = (Mult_result_1_preclip[31] == 1'b1) ? 32'd0 : (|Mult_result_1_preclip[30:24] == 1'b1) ? 32'hFFFFFFFF : Mult_result_1_preclip;
assign Mult_result_2_clip = (Mult_result_2_preclip[31] == 1'b1) ? 32'd0 : (|Mult_result_2_preclip[30:24] == 1'b1) ? 32'hFFFFFFFF : Mult_result_2_preclip;
assign Mult_result_3_clip = (Mult_result_3_preclip[31] == 1'b1) ? 32'd0 : (|Mult_result_3_preclip[30:24] == 1'b1) ? 32'hFFFFFFFF : Mult_result_3_preclip;
assign Mult_result_4_clip = (Mult_result_4_preclip[31] == 1'b1) ? 32'd0 : (|Mult_result_4_preclip[30:24] == 1'b1) ? 32'hFFFFFFFF : Mult_result_4_preclip;
assign Mult_result_5_clip = (Mult_result_5_preclip[31] == 1'b1) ? 32'd0 : (|Mult_result_5_preclip[30:24] == 1'b1) ? 32'hFFFFFFFF : Mult_result_5_preclip;
assign Mult_result_6_clip = (Mult_result_6_preclip[31] == 1'b1) ? 32'd0 : (|Mult_result_6_preclip[30:24] == 1'b1) ? 32'hFFFFFFFF : Mult_result_6_preclip;


logic [31:0] CC_5_Mul_1, CC_5_Mul_2, CC_6_Mul_1, CC_6_Mul_2, CC_7_Mul_1, CC_7_Mul_2;

assign CC_5_Mul_1 = (Mult_result_1_clip >>> 16);
assign CC_5_Mul_2 = (Mult_result_2_clip >>> 16);

assign CC_6_Mul_1 = (Mult_result_3_clip >>> 16);
assign CC_6_Mul_2 = (Mult_result_4_clip >>> 16);

assign CC_7_Mul_1 = (Mult_result_5_clip >>> 16);
assign CC_7_Mul_2 = (Mult_result_6_clip >>> 16);


always_ff @(posedge clock or negedge reset) begin
		if (~reset) begin
			SRAM_address_M1 <= 18'd0;
			SRAM_write_data <= 16'd0;
			data_counter <= 18'd0;
			RGB_counter <= 18'd0;
			Y_counter <= 18'd0;
			Pixel_counter <= -18'sd2;
			stop_M1 <= 1'b0;
			Last_write <= 1'b0;
			CC_tracker <= 1'b0;
			End_case <= 1'b1;
			End_case_y <= 1'b1;
			SRAM_write_en <= 1'b1;
			U_prime <= 32'd0;
			V_prime <= 32'd0;
			U_e <= 8'd0;
			V_e <= 8'd0;
			U [0] <= 16'd0;
			U [1] <= 16'd0;
			U [2] <= 16'd0;
			U [3] <= 16'd0;
			U [4] <= 16'd0;
			U [5] <= 16'd0;

			V [0] <= 16'd0;
			V [1] <= 16'd0;
			V [2] <= 16'd0;
			V [3] <= 16'd0;
			V [4] <= 16'd0;
			V [5] <= 16'd0;
			Y_even <= 8'd0;
			Y_odd <= 8'd0;
			V_buff <= 16'd0;
			U_buff <= 16'd0;
			Multi_p1_buff <= 32'd0;
			stop_M1 <= 1'b0;
			M1_SRAM_state <= M1_Idle;
		end else begin
			case (M1_SRAM_state)
			
			M1_Idle:begin
				SRAM_address_M1 <= 18'd0;
				SRAM_write_data <= 16'd0;
				data_counter <= 18'd0;
				RGB_counter <= 18'd0;
				Y_counter <= 18'd0;
				Pixel_counter <= -18'sd2;
				stop_M1 <= 1'b0;
				Last_write <= 1'b0;
				CC_tracker <= 1'b0;
				End_case <= 1'b1;
				End_case_y <= 1'b1;
				SRAM_write_en <= 1'b1;
				U_prime <= 32'd0;
				V_prime <= 32'd0;
				U_e <= 8'd0;
				V_e <= 8'd0;
				U [0] <= 16'd0;
				U [1] <= 16'd0;
				U [2] <= 16'd0;
				U [3] <= 16'd0;
				U [4] <= 16'd0;
				U [5] <= 16'd0;

				V [0] <= 16'd0;
				V [1] <= 16'd0;
				V [2] <= 16'd0;
				V [3] <= 16'd0;
				V [4] <= 16'd0;
				V [5] <= 16'd0;
				Y_even <= 8'd0;
				Y_odd <= 8'd0;
				V_buff <= 16'd0;
				U_buff <= 16'd0;
				Multi_p1_buff <= 32'd0;
				stop_M1 <= 1'b0;
				if (enable_M1) begin
					M1_SRAM_state <= Lead_1;
				end
			end

			Lead_1: begin
				SRAM_address_M1 <= U_START_ADDRESS + data_counter;
				U_prime <= 32'd128;
				V_prime <= 32'd128;
				SRAM_write_en <= 1'b1;
				M1_SRAM_state <= Lead_2;
			end
			
			Lead_2: begin
				SRAM_address_M1 <= V_START_ADDRESS + data_counter;
				M1_SRAM_state <= Lead_3;
			end
			
			Lead_3: begin
				SRAM_address_M1 <= Y_START_ADDRESS + Y_counter;
				data_counter <= data_counter + 18'd1;
				M1_SRAM_state <= Lead_4;
			end
			
			Lead_4: begin
				SRAM_address_M1 <= U_START_ADDRESS + data_counter;
				U[2] <= SRAM_read[15:8];
				U[3] <= SRAM_read[7:0];

				U[1] <= SRAM_read[15:8];
				U[0] <= SRAM_read[15:8];
				M1_SRAM_state <= Lead_5;
			end
			
			Lead_5: begin
				SRAM_address_M1 <= V_START_ADDRESS + data_counter;
				V[2] <= SRAM_read[15:8];
				V[3] <= SRAM_read[7:0];

				V[1] <= SRAM_read[15:8];
				V[0] <= SRAM_read[15:8];
				M1_SRAM_state <= Lead_6;
			end
			
			Lead_6: begin
				Y_even = SRAM_read[15:8];
				Y_odd = SRAM_read[7:0];
				data_counter <= data_counter + 18'd1;
				M1_SRAM_state <= Lead_7;
			end
			
			Lead_7: begin
				U[4] <= SRAM_read[15:8];
				U[5] <= SRAM_read[7:0];
				M1_SRAM_state <= Lead_8;
			end
			
			Lead_8: begin
				V[4] <= SRAM_read[15:8];
				V[5] <= SRAM_read[7:0];
				CC_tracker <= 1'b1;
				M1_SRAM_state <= CC_1;
			end
			
			CC_1: begin
				SRAM_write_en <= 1'b1;
				//Decision on when to read from SRAM
				if (CC_tracker & End_case) begin
					SRAM_address_M1 <= V_START_ADDRESS + data_counter;
				end
				
				V_e <= V[2];
				U_e <= U[2];

				// V[5] x 21
				Mult_op_1 <= V[5];
				Mult_op_2 <= 32'sd21;  

				// V[1] x -52
				Mult_op_3 <= V[1];
				Mult_op_4 <= -32'sd52;

				// V[0] x 21
				Mult_op_5 <= V[0];
				Mult_op_6 <= 32'sd21;

				// V[3] x 159
				Mult_op_7 <= V[3];
				Mult_op_8 <= 32'sd159;
				
				M1_SRAM_state <= CC_2;
			end
			
			CC_2: begin
				//Decision on when to read from SRAM
				if (CC_tracker & End_case) begin
					SRAM_address_M1 <= U_START_ADDRESS + data_counter;
					if (Pixel_counter == 18'd306) begin
						data_counter <= data_counter; 
					end else begin
						data_counter <= data_counter + 18'd1;
					end
				end

				if (End_case_y) begin
					//Increment of Y_counter
					Y_counter <= Y_counter + 18'd1;
				end


				Pixel_counter <= Pixel_counter + 18'sd2;

				//V_Prime Addition
				V_prime <= V_prime + Mult_result_1 + Mult_result_2 + Mult_result_3 + Mult_result_4; 

				// U[0] x 21
				Mult_op_1 <= U[0];
				Mult_op_2 <= 32'sd21;  

				// V[2] x 159
				Mult_op_3 <= V[2];
				Mult_op_4 <= 32'sd159;

				// U[2] x 159
				Mult_op_5 <= U[2];
				Mult_op_6 <= 32'sd159;

				// V[4] x -52
				Mult_op_7 <= V[4];
				Mult_op_8 <= -32'sd52;

				M1_SRAM_state <= CC_3;
			end
			
			CC_3: begin
				if(End_case_y) begin
					SRAM_address_M1 <= Y_START_ADDRESS + Y_counter;
				end

				//V_Prime Addition
				V_prime <= (V_prime + Mult_result_2 + Mult_result_4) >>> 8; 

				//U_Prime Addition
				U_prime <= U_prime + Mult_result_1 + Mult_result_3; 

				// U[1] x -52
				Mult_op_1 <= U[1];
				Mult_op_2 <= -32'sd52;  

				// U[4] x -52
				Mult_op_3 <= U[4];
				Mult_op_4 <= -32'sd52;

				// U[3] x 159
				Mult_op_5 <= U[3];
				Mult_op_6 <= 32'sd159;

				// U[5] x 21
				Mult_op_7 <= U[5];
				Mult_op_8 <= 32'sd21;

				M1_SRAM_state <= CC_4;
			end
			
			CC_4: begin

				//(Y_even - 16) x 76284
				Mult_op_1 <= (Y_even - 16);
				Mult_op_2 <= 32'sd76284;

				//(U_e - 128) x -25624
				Mult_op_3 <= (U_e - 128);
				Mult_op_4 <= -32'sd25624;

				//(V_e - 128) x -53281
				Mult_op_5 <= (V_e - 128);
				Mult_op_6 <= -32'sd53281; 

				//(V_e - 128) x 104595
				Mult_op_7 <= (V_e - 128);
				Mult_op_8 <= 32'sd104595;  

				if (CC_tracker & End_case) begin
					V_buff <= SRAM_read;
				end				

				//U_Prime Addition
				U_prime <= (U_prime + Mult_result_1 + Mult_result_2 + Mult_result_3 + Mult_result_4) >>> 8;

				M1_SRAM_state <= CC_5;
			end
			
			CC_5: begin
				Multi_p1_buff <= Mult_result_1;

				//(Y_odd - 16) x 76284
				Mult_op_1 <= (Y_odd - 16);
				Mult_op_2 <= 32'sd76284;

				//(V_prime - 128) x -53281
				Mult_op_3 <= (V_prime - 128);
				Mult_op_4 <= -32'sd53281;

				//(U_e - 128) x 132251
				Mult_op_5 <= (U_e - 128);
				Mult_op_6 <= 32'sd132251; 

				//(V_prime - 128) x 104595
				Mult_op_7 <= (V_prime - 128);
				Mult_op_8 <= 32'sd104595;


				SRAM_write_data <= {CC_5_Mul_1[7:0], CC_5_Mul_2[7:0]};
				SRAM_address_M1 <= RGB_START_ADDRESS + RGB_counter;
				SRAM_write_en <= 1'b0;
				RGB_counter <= RGB_counter + 1'b1;

				if (CC_tracker & End_case) begin
					U_buff <= SRAM_read;
				end	

				M1_SRAM_state <= CC_6;
			end
			
			CC_6: begin

				//(U_prime - 128) x 132251
				Mult_op_5 <= (U_prime - 128);
				Mult_op_6 <= 32'sd132251; 

				//(U_prime - 128) x -25624
				Mult_op_7 <= (U_prime - 128);
				Mult_op_8 <= -32'sd25624;

				SRAM_write_data <= {CC_6_Mul_1[7:0], CC_6_Mul_2[7:0]};
				SRAM_address_M1 <= RGB_START_ADDRESS + RGB_counter;
				RGB_counter <= RGB_counter + 1'b1;
				
				if (End_case_y) begin
					Y_even = SRAM_read[15:8];
					Y_odd = SRAM_read[7:0];
				end
				M1_SRAM_state <= CC_7;
			end
			
			CC_7: begin

				SRAM_write_data <= {CC_7_Mul_1[7:0], CC_7_Mul_2[7:0]};
				SRAM_address_M1 <= RGB_START_ADDRESS + RGB_counter;
				RGB_counter <= RGB_counter + 1'b1;

				if (Y_counter == 18'd38398) begin
					Last_write <= 1'b1;
				end
				End_case <= 1'b0;
				if (Pixel_counter == 18'd314) begin
					V[0] <= V[1];
					V[1] <= V[2];
					V[2] <= V[3];
					V[3] <= V[4];

					U[0] <= U[1];
					U[1] <= U[2];
					U[2] <= U[3];
					U[3] <= U[4];

					M1_SRAM_state <= CC_1;
				end else if (Pixel_counter == 18'd316) begin
					End_case_y <= 1'b0;
					V[0] <= V[1];
					V[1] <= V[2];
					V[2] <= V[3];

					U[0] <= U[1];
					U[1] <= U[2];
					U[2] <= U[3];

					M1_SRAM_state <= CC_1;
				end else if (Pixel_counter > 18'd317) begin
						if (Last_write == 1'b1) begin
							stop_M1 <= 1'b1;
						end else begin
						End_case <= 1'b1;
						End_case_y <= 1'b1;
						Pixel_counter <= -18'sd2;
						data_counter <= data_counter + 18'd1;
						Y_counter <= Y_counter + 18'd1;

						U_buff <= 16'd0;
						V_buff <= 16'd0;
						M1_SRAM_state <= Lead_1;
					end
				end else begin
					End_case_y <= 1'b1;

					if (Pixel_counter < 18'd310) begin
						End_case <= 1'b1;
					end else if (Pixel_counter == 18'd312) begin
						U[4] <= U[5];
						V[4] <= V[5];
					end

					//Shifting values of V by 1
					V[0] <= V[1];
					V[1] <= V[2];
					V[2] <= V[3];
					V[3] <= V[4];
					V[4] <= V[5];

					//Shifting values of U by 1
					U[0] <= U[1];
					U[1] <= U[2];
					U[2] <= U[3];
					U[3] <= U[4];
					U[4] <= U[5];

					if (Pixel_counter < 18'd311) begin
						if (CC_tracker) begin
							V[5] <= V_buff[15:8];
							U[5] <= U_buff[15:8];
							V_buff[15:8] <= 8'd0;
							U_buff[15:8] <= 8'd0;
						end else begin
							V[5] <= V_buff[7:0];
							V_buff[7:0] <= 8'd0;
							U[5] <= U_buff[7:0];
							U_buff[7:0] <= 8'd0;					
						end
					end

					M1_SRAM_state <= CC_1;
				end
				CC_tracker <= ~CC_tracker;
				V_prime <= 32'd128;
				U_prime <= 32'd128;
			end
			default: M1_SRAM_state <= Lead_1;
		endcase
		end 
	end


endmodule
 