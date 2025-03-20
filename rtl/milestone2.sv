//MILESTONE-2 CODE 
//Abaan Khan - khana454 - 400428399
//Someshwar Ganesan - ganesans - 400430923

`timescale 1ns/100ps

`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"


module milestone2(
		input logic clock,		
		input logic resetn,
		input logic start,		
		output logic [17:0] SRAM_address,
		output logic [15:0] SRAM_write_data,
		output logic done,
		output logic SRAM_we_n,
		input logic [15:0] SRAM_read_data
);

M2_state_type state; //states defined in define.h

parameter PRE_IDCT_OFFSET = 18'd76800;
parameter Y_OFFSET = 18'd0;
parameter U_OFFSET = 18'd38400;
parameter V_OFFSET = 18'd57600;

//counters
logic[5:0] block_col; // used for both y and uv blocks
logic[5:0] block_row; // used for both y and uv blocks

logic M2_Fetch_start_flag, M2_Ct_start_flag, M2_Cs_start_flag, M2_Write_start_flag;
logic M2_Fetch_done_flag, M2_Ct_done_flag, M2_Cs_done_flag, M2_Write_done_flag;

logic [31:0] M2_Fetch_SRAM_address, M2_Write_SRAM_address;
logic [15:0] M2_Fetch_SRAM_write_data, M2_Write_SRAM_write_data;
logic M2_Fetch_SRAM_we_n, M2_Write_SRAM_we_n;
logic [15:0] M2_Fetch_SRAM_read_data, M2_Write_SRAM_read_data;

logic sel;

//module instantiations for all files
M2_Fetch M2_Fetch_inst(
	.Clock(clock),
	.resetn(resetn),
	.M2_Fetch_start(M2_Fetch_start_flag),
	.M2_Fetch_SRAM_address(M2_Fetch_SRAM_address),
	.M2_Fetch_SRAM_write_data(M2_Fetch_SRAM_write_data),
	.M2_Fetch_done(M2_Fetch_done_flag),
	.M2_Fetch_SRAM_we_n(M2_Fetch_SRAM_we_n),
	.M2_Fetch_SRAM_read_data(SRAM_read_data),
	.block_col(block_col),
	.block_row(block_row),
	.sel(sel)
);

M2_Ct M2_Ct_inst(
	.Clock(clock),
	.resetn(resetn),
	.M2_Ct_start(M2_Ct_start_flag),
	.M2_Ct_done(M2_Ct_done_flag)
);

M2_Cs M2_Cs_inst(
	.Clock(clock),
	.resetn(resetn),
	.M2_Cs_start(M2_Cs_start_flag),
	.M2_Cs_done(M2_Cs_done_flag)
);

M2_Write M2_Write_inst(
	.Clock(clock),
	.resetn(resetn),
	.M2_Write_start(M2_Write_start_flag),
	.M2_Write_SRAM_address(M2_Write_SRAM_address),
	.M2_Write_SRAM_write_data(M2_Write_SRAM_write_data),
	.M2_Write_done(M2_Write_done_flag),
	.M2_Write_SRAM_we_n(M2_Write_SRAM_we_n),
	.M2_Write_SRAM_read_data(SRAM_read_data),
	.block_col(block_col),
	.block_row(block_row),
	.sel(sel)
);

logic [2:0] c_increment;

logic [11:0] total_block_counter;

//shifting from Y to UV in fetch
logic [5:0] col_block_count;

assign col_block_count = (sel == 2'd0)? 6'd39 : 6'd19; // within this file
parameter row_block_count = 6'd29; // within this file

logic started;

always_ff @ (posedge clock or negedge resetn) begin
	if (resetn == 1'b0) begin	
		M2_Fetch_start_flag <= 1'b0;
		M2_Ct_start_flag <= 1'b0;
		M2_Cs_start_flag <= 1'b0;
		M2_Write_start_flag <= 1'b0;

		M2_Fetch_done_flag <= 1'b0;
		M2_Ct_done_flag <= 1'b0;
		M2_Cs_done_flag <= 1'b0;
		M2_Write_done_flag <= 1'b0;

		state <= M2_IDLE;

		block_col <= 6'd0;
		block_row <= 6'd0;	
		
		c_increment <= 3'd0;

		total_block_counter <= 12'd0;
		
		started <= 1'b0;
		
		
	end else begin
		case (state)

		M2_IDLE: begin
			M2_Fetch_start_flag <= 1'b0;
			M2_Ct_start_flag <= 1'b0;
			M2_Cs_start_flag <= 1'b0;
			M2_Write_start_flag <= 1'b0;

			M2_Fetch_done_flag <= 1'b0;
			M2_Ct_done_flag <= 1'b0;
			M2_Cs_done_flag <= 1'b0;
			M2_Write_done_flag <= 1'b0;
			
			started <= 1'b0;
			if (start) begin
				state <= Fetch_first;
			end
		end

		Fetch_first: begin
			M2_Fetch_start_flag <= 1'b1;	
			if (M2_Fetch_done_flag) begin

				block_col <= block_col + 1;

				M2_Fetch_start_flag <= 1'b0;

				total_block_counter <= total_block_counter + 12'd1;
				
				M2_Ct_start_flag <= 1'b1;
				state <= Ct_first;
				
			end	
		end	

		Ct_first: begin
			
			if (M2_Ct_done_flag) begin
				M2_Ct_start_flag <= 1'b0;
				state <= Mega_State_A;
			end	
		end

		Mega_State_A: begin // Cs of current cycle and Fetch of following cycle
			
			if(!started) begin
				M2_Cs_start_flag <= 1'b1;
				M2_Fetch_start_flag <= 1'b1;
				started <= 1'b1;
			end

			if(block_col == col_block_count) begin
				block_col <= 0;
				block_row <= block_row + 6'd1;
				if(block_row == row_block_count) begin
					block_row <= 0;
					if(!sel) begin
						sel <= 1'b1;
					end								
				end
			end
			
			if(M2_Fetch_done_flag) begin
				M2_Fetch_start_flag <= 1'b0;
			end

			if(M2_Cs_done_flag) begin
				M2_Cs_start_flag <= 1'b0;
			end

			if (M2_Fetch_done_flag && M2_Cs_done_flag) begin
				if(block_col == col_block_count) begin
					block_col <= 0;
					block_row <= block_row + 6'd1;
					if(block_row == row_block_count) begin
						block_row <= 0;
						if(!sel) begin
							sel <= 1'b1;
						end								
					end
				end else begin
					block_col <= block_col + 1;
				end

				total_block_counter <= total_block_counter + 12'd1;
				
				started <= 1'b0;
				state <= Mega_State_B;
				
			end
		end

		Mega_State_B: begin // Write of current cycle and Ct of following cycle
			if(!started) begin
				M2_Ct_start_flag <= 1'b1;
				M2_Write_start_flag <= 1'b1;
				started <= 1'b1;
			end

			if(M2_Ct_done_flag) begin
				M2_Ct_start_flag <= 1'b0;
			end

			if(M2_Write_done_flag) begin
				M2_Write_start_flag <= 1'b0;
			end
			

			if (M2_Ct_done_flag && M2_Write_done_flag) begin
				
				if(total_block_counter == 12'd2) begin
					state <= Cs_Last;
				end else begin
					started <= 1'b0;
					state <= Mega_State_A;					
				end
			end
		end

		Cs_Last: begin
			M2_Cs_start_flag <= 1'b1;
			if (M2_Cs_done_flag) begin
				M2_Cs_start_flag <= 1'b0;
				state <= Write_Last;
			end	
		end

		Write_Last: begin
			M2_Write_start_flag <= 1'b1;
			if (M2_Write_done_flag) begin
				M2_Write_start_flag <= 1'b0;
				state <= M2_IDLE;
			end	
		end		

		endcase
   end
end

always_comb begin
	SRAM_address = 18'd230400;
	SRAM_we_n = 1'b1;
	SRAM_write_data = 16'd0;
	if ((state == Fetch_first) || (state == Mega_State_A)) begin
		SRAM_address = M2_Fetch_SRAM_address;
		SRAM_we_n = 1'b1;
		SRAM_write_data = 16'd0;
	end 
	if ((state == Write_Last) || (state == Mega_State_B)) begin
		SRAM_address = M2_Write_SRAM_address;
		SRAM_we_n = M2_Write_SRAM_we_n;
		SRAM_write_data = M2_Write_SRAM_write_data;
	end 
end



endmodule