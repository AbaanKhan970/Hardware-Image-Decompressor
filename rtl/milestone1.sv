//MILESTONE-1 CODE
//Abaan Khan - khana454 - 400428399
//Someshwar Ganesan - ganesans - 400430923

`timescale 1ns/100ps

`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"

module milestone1(
		input logic clock,		
		input logic resetn,
		input logic start,		
		output logic [17:0] SRAM_address,
		output logic [15:0] SRAM_write_data,
		output logic done,
		output logic SRAM_we_n,
		input logic [15:0] SRAM_read_data
);

M1_state_type state; //states defined in define.h

//offsets from 
parameter Y_OFFSET   = 18'd0;
parameter U_OFFSET   = 18'd38400;
parameter V_OFFSET   = 18'd57600;
parameter RGB_OFFSET = 18'd146944;

//calculated values
logic [31:0] r_even; 
logic [31:0] r_odd;
logic [31:0] g_even;
logic [31:0] g_odd;
logic [31:0] b_even;
logic [31:0] b_odd;

// clipped values of above calculated values to keep within 0-255
logic [7:0] r_even_clip; 
logic [7:0] r_odd_clip;
logic [7:0] g_even_clip;
logic [7:0] g_odd_clip;
logic [7:0] b_even_clip;
logic [7:0] b_odd_clip;

logic [7:0] y_even;
logic [7:0] y_odd
;
logic [15:0] u_buffer; 
logic [15:0] v_buffer;

logic [31:0] u_odd;			
logic [31:0] v_odd;

logic [7:0] uj5;  // u((j+5)/2)
logic [7:0] ujm5; // u((j-5)/2)
logic [7:0] uj3;  // u((j+3)/2)
logic [7:0] ujm3; // u((j-3)/2)
logic [7:0] uj1;  // u((j+1)/2)
logic [7:0] ujm1; // u((j-1)/2)

logic [7:0] vj5;  // v((j+5)/2)
logic [7:0] vjm5; // v((j-5)/2)
logic [7:0] vj3;  // v((j+3)/2)
logic [7:0] vjm3; // v((j-3)/2)
logic [7:0] vj1;  // v((j+1)/2)
logic [7:0] vjm1; // v((j-1)/2)

logic [31:0] a1;
logic [31:0] a2;
logic [31:0] a3;

logic [31:0] m1op1;
logic [31:0] m1op2;
logic [31:0] m2op1;
logic [31:0] m2op2;
logic [31:0] m3op1;
logic [31:0] m3op2;

logic [31:0] m1; 
logic [31:0] m2;
logic [31:0] m3;

logic [63:0] m1_long; 
logic [63:0] m2_long;
logic [63:0] m3_long;

//operands to determine read address offsets
logic [8:0] y_data_counter; 
logic [8:0] u_data_counter;
logic [8:0] v_data_counter;  
// operdand to determine write address offset
logic [17:0] rgb_counter; 

// to keep track of how many LI -> CC -> LO cycles (rows) are completed
logic [17:0] y_row_counter; 
logic [16:0] uv_row_counter;

always_ff @(posedge clock or negedge resetn) begin
	if (~resetn) begin
		SRAM_address <= 18'd0;
		SRAM_write_data <= 15'b0;
		SRAM_we_n <= 1'b1;
		
		y_row_counter <= 18'd0;
		uv_row_counter <= 17'd0;		
	
		y_data_counter <= 8'd0;
		u_data_counter <= 8'd0;
		v_data_counter <= 8'd0;
		rgb_counter <= 18'd0;
		
		a1 <= 0;
		a2 <= 0;
		a3 <= 0;
		
		y_even <= 0;
		y_odd <= 0;
		
		u_buffer <= 0;
		v_buffer <=0;
		
		u_odd <= 0;
		v_odd <= 0;
		
		m1op1 <= 32'b0;
		m1op2 <= 32'b0;
		m2op1<= 32'b0;
		m2op2 <= 32'b0;
		m3op1 <= 32'b0;
		m3op2 <= 32'b0;
		
		done <= 1'b0;

	end else begin
		case(state)
		M1_IDLE: begin
			SRAM_we_n <= 1'd1;
			y_data_counter <= 9'd0;
			u_data_counter <= 8'd0;
			v_data_counter <= 8'd0;
			rgb_counter <= 18'd0;
			y_row_counter <= 18'd0;
			uv_row_counter <= 18'd0;
			
			//done <= 1'b0;	
			
			if(start == 1'b1) begin
				state <= LI1;
			end
		end
// LEAD-IN CASES
		LI1: begin
			SRAM_we_n <= 1'd1;

			SRAM_address <= Y_OFFSET + y_data_counter + y_row_counter;
			y_data_counter <= y_data_counter + 1;
			
			state <= LI2;
		end

		LI2: begin
			SRAM_address <= U_OFFSET + u_data_counter + uv_row_counter;
			u_data_counter <= u_data_counter + 18'd1;
			
			state <= LI3;
		end

		LI3: begin
			SRAM_address <= U_OFFSET + u_data_counter + uv_row_counter;
			u_data_counter <= u_data_counter + 18'd1;
			
			state <= LI4;
		end

		LI4: begin
			SRAM_address <= V_OFFSET + v_data_counter + uv_row_counter; 
			v_data_counter <= v_data_counter + 18'd1;
			
			y_even <= SRAM_read_data[15:8];
			y_odd <= SRAM_read_data[7:0];
			
			state <= LI5;
		end

		LI5: begin
			SRAM_address <= V_OFFSET + v_data_counter + uv_row_counter;
			v_data_counter <= v_data_counter + 18'd1;

			ujm5 <= SRAM_read_data[15:8];
			ujm3 <= SRAM_read_data[15:8];
			ujm1 <= SRAM_read_data[15:8];
			uj1 <= SRAM_read_data[7:0];		
		
			a3 <= y_even - 32'd16;
			
			state <= LI6;
		end

		LI6: begin
			uj3 <= SRAM_read_data[15:8];
			uj5 <= SRAM_read_data[7:0];

			a1 <= ujm5 + SRAM_read_data[7:0];			
			
			state <= LI7;
		end

		LI7: begin		
			vjm5 <= SRAM_read_data[15:8];
			vjm3 <= SRAM_read_data[15:8];
			vjm1 <= SRAM_read_data[15:8];
			vj1 <= SRAM_read_data[7:0];
			
			state <= LI8;
		end

		LI8: begin
			vj3 <= SRAM_read_data[15:8];
			vj5 <= SRAM_read_data[7:0];			
			
			a2 <= vjm5 + SRAM_read_data[7:0];			
			
			state <= CC1;
		end
//COMMON CASES
		CC1: begin
			SRAM_we_n <= 1'b1;
			SRAM_address <= Y_OFFSET + y_data_counter + y_row_counter;	
			
			a1 <= ujm3 + uj3;
			a2 <= vjm3 + vj3;
			a3 <= vjm1 - 18'd128;	
			
			m1op1 <= a1;
			m1op2 <= 32'd21;
			
			m2op1 <= a2;
			m2op2 <= 32'd21;
			
			m3op1 <= a3;
			m3op2 <= 32'd76284;			
			
			state <= CC2;			
		end

		CC2: begin
			if (y_data_counter< 9'd157) begin // last 3 Y values don't need new U V values
				if(y_data_counter & 1) begin // read U V values every alternate CC2, odd cycle
					SRAM_address <= U_OFFSET + u_data_counter + uv_row_counter;
					u_data_counter <= u_data_counter + 18'd1;
				end
			end
			
			a1 <= ujm1 + uj1;
			a2 <= vjm1 + vj1;
			a3 <= ujm1 - 32'd128;
			
			u_odd <= m1 + 32'd128;
			v_odd <= m2 + 32'd128;
			
			r_even <= m3;
			g_even <= m3;
			b_even <= m3;		
			
			m1op1 <= a1;
			m1op2 <= 32'd52;
			
			m2op1 <= a2;
			m2op2 <= 32'd52;
			
			m3op1 <= a3;
			m3op2 <= 32'd104595;			
			
			state <= CC3;
		end

		CC3: begin
			if (y_data_counter< 9'd157) begin // last 3 Y values don't need new U V values
				if(y_data_counter & 1) begin // read U V values every alternate CC2, odd cycle
					SRAM_address <= V_OFFSET + v_data_counter + uv_row_counter;
					v_data_counter <= v_data_counter + 18'd1;
				end
			end
			
			a3 <= vjm1 - 32'd128;
		
			u_odd <= u_odd - m1;
			v_odd <= v_odd - m2;
			
			r_even <= (r_even + m3);			
			
			m1op1 <= a1;
			m1op2 <= 18'd159;
			
			m2op1 <= a2;
			m2op2 <= 18'd159;
			
			m3op1 <= a3;
			m3op2 <= 18'd25624;				
			
			state <= CC4;
		end

		CC4: begin
			if (y_data_counter > 1'd1) begin
				SRAM_we_n <= 1'd0;
				SRAM_address <= RGB_OFFSET + rgb_counter;
				rgb_counter <= rgb_counter + 18'd1;
				SRAM_write_data <= {g_odd_clip, b_odd_clip};				
			end
			
			a1 <= y_odd - 32'd16;
			a2 <= ((v_odd + m2) >> 32'd8) - 32'd128;
			a3 <= ujm1 - 32'd128;
			
			u_odd <= (u_odd + m1) >> 32'd8;
			v_odd <= (v_odd + m2) >> 32'd8;
			
			g_even <= g_even - m3;			
			
			y_even <= SRAM_read_data[15:8];
			y_odd <= SRAM_read_data[7:0];			
			
			m3op1 <= a3;
			m3op2 <= 18'd53281;			
			
			state <= CC5;
		end

		CC5: begin			
			SRAM_we_n <= 1'd1;
			
			if (y_data_counter< 9'd157) begin // last 3 Y values don't need new U V values
				if(y_data_counter & 1) begin // read U V values every alternate CC2, odd cycle
					u_buffer <= SRAM_read_data;
				end
			end
			 
			a1 <= u_odd - 18'd128;
			a2 <= v_odd - 18'd128;
			
			g_even <= (g_even - m3);
			
			m1op1 = a1;
			m1op2 = 18'd76284;
			
			m2op1 = a2;
			m2op2 = 18'd104595;
			
			m3op1 = a3;
			m3op2 = 18'd132251;			
			
			state <= CC6;			
		end

		CC6: begin		
			SRAM_we_n <= 1'd0;
			SRAM_write_data <= {r_even_clip, g_even_clip};
			SRAM_address <= RGB_OFFSET + rgb_counter;
			rgb_counter <= rgb_counter + 18'd1;	
	
			if (y_data_counter< 9'd157) begin // last 3 Y values don't need new U V values
				if(y_data_counter & 1) begin // read U V values every alternate CC2, odd cycle
					v_buffer <= SRAM_read_data;
				end
			end		
			
			b_even <= (b_even + m3);			
			r_odd <= (m1 + m2) ;
			g_odd <= m1;
			b_odd <= m1;			
			
			m1op1 = a1;
			m1op2 = 18'd25624;
			
			m2op1 = a2;
			m2op2 = 18'd53281;
			
			m3op1 = a1;
			m3op2 = 18'd132251;		
			
			state <= CC7;
		end

		CC7: begin
			SRAM_we_n <= 1'd0;
			SRAM_write_data <= {b_even_clip, r_odd_clip};			
			SRAM_address <= RGB_OFFSET + rgb_counter;
			rgb_counter <= rgb_counter + 18'd1;			
			
			g_odd <= (g_odd - m1 - m2);
			b_odd <= (b_odd + m3);			
			
			ujm5 <= ujm3;
			ujm3 <= ujm1;
			ujm1 <= uj1;
			uj1 <= uj3;
			uj3 <= uj5;
			
			vjm5 <= vjm3;
			vjm3 <= vjm1;
			vjm1 <= vj1;
			vj1 <= vj3;
			vj3 <= vj5;
			
			a3 <= y_even - 32'd16;
			
			if (y_data_counter[0] == 1'd1 && (y_data_counter< 9'd157)) begin
				uj5 <= u_buffer[15:8];
				vj5 <= v_buffer[15:8];
				a1 <= ujm3 + u_buffer[15:8];
				a2 <= vjm3 + v_buffer[15:8];
			end else begin
				uj5 <= u_buffer[7:0];
				vj5 <= v_buffer[7:0];
				a1 <= ujm3 + u_buffer[7:0];
				a2 <= vjm3 + v_buffer[7:0];
			end		
			
			y_data_counter <= y_data_counter + 1'd1;
			
			if (y_data_counter == 9'd159) begin		
				state <= LO1; 
			end else begin
				
				state <= CC1;
			end			
		end
//LEAD OUT CASES		
		LO1: begin
			SRAM_we_n <= 1'd0;		
			SRAM_write_data <= {g_odd_clip, b_odd_clip};				
			SRAM_address <= RGB_OFFSET + rgb_counter;
			rgb_counter <= rgb_counter + 18'd1;
			
			a1 <= ujm3 + uj3;
			a2 <= vjm3 + vj3;
			a3 <= vjm1 - 18'd128;	
			
			m1op1 <= a1;
			m1op2 <= 18'd21;
			
			m2op1 <= a2;
			m2op2 <= 18'd21;
			
			m3op1 <= a3;
			m3op2 <= 18'd76284;			
			
			state <= LO2;			
		end
		
		LO2: begin
			SRAM_we_n <= 1'd1;
			
			a1 <= ujm1 + uj1;
			a2 <= vjm1 + vj1;
			a3 <= ujm1 - 8'd128;
			
			u_odd <= m1 + 18'd128;
			v_odd <= m2 + 18'd128;
			
			r_even <= m3;
			g_even <= m3;
			b_even <= m3;		
			
			m1op1 <= a1;
			m1op2 <= 18'd52;
			
			m2op1 <= a2;
			m2op2 <= 18'd52;
			
			m3op1 <= a3;
			m3op2 <= 18'd104595;		
			
			state <= LO3;
		end
		
		LO3: begin		
			a3 <= vjm1 - 32'd128;
			
			r_even <= (r_even + m3);				
			
			u_odd <= u_odd - m1;
			v_odd <= v_odd - m2;			
			
			m1op1 <= a1;
			m1op2 <= 18'd159;
			
			m2op1 <= a2;
			m2op2 <= 18'd159;
			
			m3op1 <= a3;
			m3op2 <= 18'd25624;				
			
			state <= LO4;
		end
		
		LO4: begin		
			a1 <= y_odd - 32'd16;
			a2 <= ((v_odd + m2) >> 32'd8) - 32'd128;
			a3 <= ujm1 - 32'd128;
			
			g_even <= g_even - m3;
			
			u_odd <= (u_odd + m1) >> 32'd8;
			v_odd <= (v_odd + m2) >> 32'd8;			
			
			m3op1 <= a3;
			m3op2 <= 18'd53281;  			
			
			state <= LO5;
		end
		
		LO5: begin		
			a1 <= u_odd - 32'd128;
			a2 <= v_odd - 32'd128;
			
			g_even <= (g_even - m3);			
			
			m1op1 = a1;
			m1op2 = 18'd76284;
			
			m2op1 = a2;
			m2op2 = 18'd104595;
			
			m3op1 = a3;
			m3op2 = 18'd132251;			
			
			state <= LO6;
		end
		
		LO6: begin
			SRAM_we_n <= 1'd0;
			SRAM_write_data <= {r_even_clip, g_even_clip};
			SRAM_address <= RGB_OFFSET + rgb_counter;
			rgb_counter <= rgb_counter + 18'd1;		
			
			b_even <= (b_even + m3);			
			
			r_odd <= (m1 + m2) ;
			g_odd <= m1;
			b_odd <= m1;			
			
			m1op1 = a1;
			m1op2 = 18'd25624;
			m2op1 = a2;
			m2op2 = 18'd53281;
			m3op1 = a1;
			m3op2 = 18'd132251;			
			
			state <= LO7;
		end
		
		LO7: begin
			SRAM_we_n <= 1'd0;
			SRAM_write_data <= {b_even_clip, r_odd_clip};			
			
			SRAM_address <= RGB_OFFSET + rgb_counter;
			rgb_counter <= rgb_counter + 18'd1;			
			
			g_odd <= (g_odd - m1 - m2) ;
			b_odd <= (b_odd + m3) ;
			
			state <= LO8;
		end
		
		LO8: begin
			SRAM_we_n <= 1'd0;
			SRAM_write_data <= {g_odd_clip, b_odd_clip};			
			
			SRAM_address <= RGB_OFFSET + rgb_counter;
			rgb_counter <= rgb_counter + 18'd1;
			
			/*
			y_data_counter <= 9'd0;
			u_data_counter <= 8'd0;
			v_data_counter <= 8'd0;
			*/
			
			if (y_row_counter +  y_data_counter == 18'd38400) begin 
				state <= M1_IDLE;
				done <= 1'b1;			
			end else begin
				y_data_counter <= 9'd0;
				y_row_counter <= y_row_counter + 18'd160; 
				uv_row_counter <= uv_row_counter + 17'd80; 
				
				y_data_counter <= 9'd0;
				u_data_counter <= 8'd0;
				v_data_counter <= 8'd0;
				
				state <= LI1;
			end			
		end		
		default: state <= M1_IDLE;		
		endcase
end
end

always_comb begin
	if (r_even[31] == 1'b1) r_even_clip = 0; //MSB = 1 -> negative value, clip result to zero
	else if(|r_even[30:24] == 1'b1) r_even_clip = 8'd255;//any bit 30:24 = 1 -> value above 255, clip result to 255
	else r_even_clip = r_even[23:16];//else keep value >> 16
end

always_comb begin
	if (r_odd[31] == 1'b1) r_odd_clip = 0;
	else if(|r_odd[30:24] == 1'b1) r_odd_clip = 8'd255;
	else r_odd_clip = r_odd[23:16];
end

always_comb begin
	if (g_even[31] == 1'b1) g_even_clip = 0;
	else if(|g_even[30:24] == 1'b1) g_even_clip = 8'd255;
	else g_even_clip = g_even[23:16];
end

always_comb begin
	if (g_odd[31] == 1'b1) g_odd_clip = 0;
	else if(|g_odd[30:24] == 1'b1) g_odd_clip = 8'd255;
	else g_odd_clip = g_odd[23:16];
end

always_comb begin
	if (b_even[31] == 1'b1) b_even_clip = 0;
	else if(|b_even[30:24] == 1'b1) b_even_clip = 8'd255;
	else b_even_clip = b_even[23:16];
end

always_comb begin
	if (b_odd[31] == 1'b1) b_odd_clip = 0;
	else if(|b_odd[30:24] == 1'b1) b_odd_clip = 8'd255;
	else b_odd_clip = b_odd[23:16];
end

assign m1_long = m1op1 * m1op2;
assign m2_long = m2op1 * m2op2;
assign m3_long = m3op1 * m3op2;

assign m1 = m1_long[31:0]; // keep only least significant 32 bits if multiplication result goes beyond 32 bits
assign m2 = m2_long[31:0];
assign m3 = m3_long[31:0];

endmodule