//MILESTONE-2 CODE 
//Abaan Khan - khana454 - 400428399
//Someshwar Ganesan - ganesans - 400430923

`timescale 1ns/100ps

`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"

module M2_Write(
		input logic Clock,		
		input logic resetn,
		input logic M2_Write_start,		
		output logic [17:0] M2_Write_SRAM_address,
		output logic [15:0] M2_Write_SRAM_write_data,
		output logic M2_Write_done,
		output logic M2_Write_SRAM_we_n,
		input logic [15:0] M2_Write_SRAM_read_data,
		
		input logic [5:0] block_col,
		input logic [5:0] block_row,
		input logic sel
);

M2_Write_state_type state;

logic [6:0] address_fetch_e, address_fetch_f;
logic [31:0] write_data_a[1:0];
logic [31:0] write_data_b[1:0];
logic [31:0] read_data_a[1:0];
logic [31:0] read_data_b[1:0];
logic write_enable_a[1:0];
logic write_enable_b[1:0];

logic [7:0] a_clip, b_clip;


dual_port_Cs dual_port_RAM_inst2 (
	.address_a ( address_fetch_e ),
	.address_b ( address_fetch_f ),
	.clock ( Clock ),
	.data_a (write_data_a[2] ),
	.data_b (write_data_b[2]),
	.wren_a ( write_enable_a[2]),
	.wren_b (write_enable_b[2]),
	.q_a ( read_data_a[2] ),
	.q_b ( read_data_b[2] )
	);
	
parameter PRE_IDCT_OFFSET = 18'd76800;
parameter Y_OFFSET = 18'd0;


logic [3:0] row_counter;
logic [5:0] read_s_address;
logic [31:0] write_counter;



always_ff @ (posedge Clock or negedge resetn) begin
	if (resetn == 1'b0) begin		
		write_enable_a[0] <= 1'b0;		
		write_data_a[0] <= 32'd0;		
		
		state <= M2_Write_IDLE;
		
		M2_Write_SRAM_address <= PRE_IDCT_OFFSET;
		
		row_counter <= 4'd0;
		fetch_counter <= 4'd0;
		
	end else begin
		case (state)
		
		M2_Write_IDLE: begin
			write_enable_a[2] <= 1'b0;		
			write_enable_b[2] <= 1'b0;

			M2_Write_SRAM_we_n <= 1'b1;
				
			if(M2_Write_start) begin
				state <= Write_LI0;
			end	
		end	

		Write_LI0: begin
			address_fetch_e <= (read_s_address << 3) ; //8*n
			address_fetch_f <= (read_s_address << 3) + 1; //8*n + 1 		
			
			state <= Write_CC1;
		end
		
		Write_CC1: begin								
			address_fetch_e <= address_fetch_e + 2; 
			address_fetch_f <= address_fetch_f + 2; 	

			M2_Write_SRAM_we_n <= 1'b0;

			M2_Write_SRAM_write_data <= {a_clip, b_clip};
			
			M2_Write_SRAM_address <= Y_OFFSET + write_counter + (block_col << 2) + ((row_counter << 7) + (row_counter << 5))  + (((block_row<< 7) + (block_row << 5)) << 2); // block column change + multiplication by 160 to change rows within a block
			write_counter <= write_counter + 4'd1;		

			state <= Write_CC2;
			
		end
		
		Write_CC2: begin								
			address_fetch_e <= address_fetch_e + 2; 
			address_fetch_f <= address_fetch_f + 2; 	

			M2_Write_SRAM_we_n <= 1'b0;

			M2_Write_SRAM_write_data <= {a_clip, b_clip};
			
			M2_Write_SRAM_address <= Y_OFFSET + write_counter + (block_col << 2) + ((row_counter << 7) + (row_counter << 5))  + (((block_row<< 7) + (block_row << 5)) << 2); // block column change + multiplication by 160 to change rows within a block
			write_counter <= write_counter + 4'd1;		

			state <= Write_CC3;
		end

		Write_CC3: begin								
			address_fetch_e <= address_fetch_e + 2; 
			address_fetch_f <= address_fetch_f + 2; 	

			M2_Write_SRAM_we_n <= 1'b0;

			M2_Write_SRAM_write_data <= {a_clip, b_clip};
			
			M2_Write_SRAM_address <= Y_OFFSET + write_counter + (block_col << 2) + ((row_counter << 7) + (row_counter << 5))  + (((block_row<< 7) + (block_row << 5)) << 2); // block column change + multiplication by 160 to change rows within a block
			write_counter <= write_counter + 4'd1;		

			state <= Write_LO1;
			
		end

		Write_LO1: begin	
			M2_Write_SRAM_we_n <= 1'b0;

			M2_Write_SRAM_write_data <= {a_clip, b_clip};
			
			M2_Write_SRAM_address <= Y_OFFSET + write_counter + (block_col << 2) + ((row_counter << 7) + (row_counter << 5))  + (((block_row<< 7) + (block_row << 5)) << 2); // block column change + multiplication by 160 to change rows within a block
			row_counter <= row_counter + 4'd1;
			write_counter <= 0;	

			read_s_address <= read_s_address + 6'd1;

			state <= Write_LI0;
		end
        endcase
	end
end

always_comb begin
	if (read_data_a[2][31] == 1'b1) a_clip = 0;
	else if(|read_data_a[2][30:24] == 1'b1) a_clip = 8'd255;
	else a_clip = read_data_a[2][23:16];
end

always_comb begin
	if (read_data_b[2][31] == 1'b1) b_clip = 0;
	else if(|read_data_b[2][30:24] == 1'b1) b_clip = 8'd255;
	else b_clip = read_data_b[2][23:16];
end

endmodule