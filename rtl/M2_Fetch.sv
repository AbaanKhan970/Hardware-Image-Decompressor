//MILESTONE-2 CODE 
//Abaan Khan - khana454 - 400428399
//Someshwar Ganesan - ganesans - 400430923

`timescale 1ns/100ps

`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"

module M2_Fetch(
		input logic Clock,		
		input logic resetn,
		input logic M2_Fetch_start,		
		output logic [17:0] M2_Fetch_SRAM_address,
		output logic [15:0] M2_Fetch_SRAM_write_data,
		output logic M2_Fetch_done,
		output logic M2_Fetch_SRAM_we_n,
		input logic [15:0] M2_Fetch_SRAM_read_data,
		
		input logic [5:0] block_col,
		input logic [5:0] block_row,
		input logic sel
);

M2_Fetch_state_type state;

logic [6:0] address_fetch_a, address_fetch_b;
logic [31:0] write_data_a;
logic [31:0] write_data_b;
logic [31:0] read_data_a;
logic [31:0] read_data_b;
logic write_enable_a;
logic write_enable_b;

dual_port_fetch_s dual_port_RAM_inst0 (
	.address_a (address_fetch_a),
	.address_b (address_fetch_b),
	.clock (Clock),
	.data_a (write_data_a),
	.data_b (32'h00),
	.wren_a (write_enable_a),
	.wren_b ( 1'b0 ),
	.q_a (read_data_a),
	.q_b (read_data_b)
	);
	
parameter PRE_IDCT_OFFSET = 18'd76800;

logic [3:0] fetch_counter;
logic [3:0] row_counter;
logic [15:0] fetch_buffer;



always_ff @ (posedge Clock or negedge resetn) begin
	if (resetn == 1'b0) begin		
		write_enable_a <= 1'b0;		
		write_data_a <= 32'd0;		
		
		state <= M2_Fetch_IDLE;
		
		M2_Fetch_SRAM_address <= PRE_IDCT_OFFSET;
		
		row_counter <= 4'd0;
		fetch_counter <= 4'd0;
		
		fetch_buffer <= 16'd0;
		
	end else begin
		case (state)
		
		M2_Fetch_IDLE: begin
			write_enable_a <= 1'b0;	
		   M2_Fetch_done <= 1'b0;	
			fetch_buffer <= 16'd0;
			
			row_counter <= 4'd0;
			
			if(M2_Fetch_start) begin
				state <= Delay1;
			end			
		end	
		
		Delay1: begin
			if(M2_Fetch_start) begin
				state <= Fetch0;
			end			
		end
		
		Fetch0: begin					
			M2_Fetch_SRAM_we_n <= 1'b1;
			M2_Fetch_SRAM_address <= PRE_IDCT_OFFSET + fetch_counter +  (block_col << 3) + ((row_counter << 8) + (row_counter << 6)) + (((block_row<< 8) + (block_row << 6))<<3); // block column change + multiplication by 320 to change rows within a block
			fetch_counter <= fetch_counter + 4'd1;
			
			write_enable_a <= 1'b0;
			
			state <= Fetch1;
			
		end
		
		Fetch1: begin
			M2_Fetch_SRAM_address <= PRE_IDCT_OFFSET+ fetch_counter + (block_col << 3) + ((row_counter << 8) + (row_counter << 6)) + (((block_row<< 8) + (block_row << 6))<<3);
			fetch_counter <= fetch_counter + 4'd1;
			state <= Fetch2;
		end
		
		Fetch2:begin
			M2_Fetch_SRAM_address <= PRE_IDCT_OFFSET + fetch_counter + (block_col << 3) + ((row_counter << 8) + (row_counter << 6)) + (((block_row<< 8) + (block_row << 6))<<3);
			fetch_counter <= fetch_counter + 4'd1;
			
			//address_fetch_a <= 7'd0;	
			
			state <= Fetch3;			
		end
		
		Fetch3:begin
			M2_Fetch_SRAM_address <= PRE_IDCT_OFFSET + fetch_counter + (block_col << 3) + ((row_counter << 8) + (row_counter << 6)) + (((block_row<< 8) + (block_row << 6))<<3);
			fetch_counter <= fetch_counter + 4'd1;
		
			if(!row_counter) begin
				address_fetch_a <= 7'd0;
			end else begin
				address_fetch_a <= address_fetch_a + 1;
			end
		
			fetch_buffer <= M2_Fetch_SRAM_read_data;
			
			state <= Fetch4;
		end
		
		Fetch4: begin
			M2_Fetch_SRAM_address <= PRE_IDCT_OFFSET + fetch_counter + (block_col << 3) + ((row_counter << 8) + (row_counter << 6)) + (((block_row<< 8) + (block_row << 6))<<3);
			fetch_counter <= fetch_counter + 4'd1;
			
			write_data_a <= {fetch_buffer,M2_Fetch_SRAM_read_data};
			write_enable_a <= 1'b1;
			
			state <= Fetch5;			
		end
		
		Fetch5: begin
			M2_Fetch_SRAM_address <= PRE_IDCT_OFFSET + fetch_counter+ (block_col << 3) +((row_counter << 8) + (row_counter << 6)) + (((block_row<< 8) + (block_row << 6))<<3);
			fetch_counter <= fetch_counter + 4'd1;
		
			address_fetch_a <= address_fetch_a + 1;
			write_enable_a <= 1'b0;
		
			fetch_buffer <= M2_Fetch_SRAM_read_data;
			
			state <= Fetch6;		
		end
		
		Fetch6: begin
			M2_Fetch_SRAM_address <= PRE_IDCT_OFFSET + fetch_counter + (block_col << 3) +((row_counter << 8) + (row_counter << 6)) + (((block_row<< 8) + (block_row << 6))<<3);
			fetch_counter <= fetch_counter + 4'd1;
			
			write_data_a <= {fetch_buffer,M2_Fetch_SRAM_read_data};
			write_enable_a <= 1'b1;
			state <= Fetch7;
		end
		
		Fetch7: begin
			M2_Fetch_SRAM_address <= PRE_IDCT_OFFSET + fetch_counter + (block_col << 3) +((row_counter << 8) + (row_counter << 6)) + (((block_row<< 8) + (block_row << 6))<<3);
			fetch_counter <= fetch_counter + 4'd1;
		
			address_fetch_a <= address_fetch_a + 1;
			write_enable_a <= 1'b0;
		
			fetch_buffer <= M2_Fetch_SRAM_read_data;
			
			state <= Fetch8;		
		end
		
		Fetch8: begin	
			write_data_a <= {fetch_buffer,M2_Fetch_SRAM_read_data};
			write_enable_a <= 1'b1;
			state <= Fetch9;
		end
		
		Fetch9: begin
			address_fetch_a <= address_fetch_a + 1;
			write_enable_a <= 1'b0;
		
			fetch_buffer <= M2_Fetch_SRAM_read_data;
			
			state <= Fetch10; 		
		end
		
		Fetch10: begin	
			write_data_a <= {fetch_buffer,M2_Fetch_SRAM_read_data};
			write_enable_a <= 1'b1;
			state <= Fetch0;
			
			row_counter <= row_counter + 4'd1;
			fetch_counter <= 0;		
			
			if(row_counter == 7) begin // one block done
				state <= M2_Fetch_IDLE;
				M2_Fetch_done <= 1'b1;
			end
		end
		endcase
	end
end

endmodule