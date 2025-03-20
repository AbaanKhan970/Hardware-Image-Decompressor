//MILESTONE-2 CODE
//Abaan Khan - khana454 - 400428399
//Someshwar Ganesan - ganesans - 400430923

//T = S' x C code

`timescale 1ns/100ps

`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"

module M2_Ct(
		input logic Clock,		
		input logic resetn,
		input logic M2_Ct_start,		
		output logic M2_Ct_done
);

M2_Ct_state_type state;

logic [6:0] address_fetch_a, address_fetch_b;
logic [6:0] address_fetch_c, address_fetch_d;
logic [31:0] write_data_a[1:0];
logic [31:0] write_data_b[1:0];
logic [31:0] read_data_a[1:0];
logic [31:0] read_data_b[1:0];
logic write_enable_a[1:0];
logic write_enable_b[1:0];

dual_port_fetch_s dual_port_RAM_inst0 (
	.address_a ( address_fetch_a ),
	.address_b ( address_fetch_b ),
	.clock ( Clock ),
	.data_a ( write_data_a[0] ),
	.data_b ( 32'h00),
	.wren_a ( write_enable_a[0] ),
	.wren_b ( 1'b0 ),
	.q_a ( read_data_a[0] ),
	.q_b ( read_data_b[0] )
	);
	
// DPRAM for T
dual_port_T dual_port_RAM_inst1(
	.address_a ( address_fetch_c ),
	.address_b ( address_fetch_d ),
	.clock ( Clock ),
	.data_a (write_data_a[1] ),
	.data_b (write_data_b[1]),
	.wren_a ( write_enable_a[1]),
	.wren_b (write_enable_b[1]),
	.q_a ( read_data_a[1] ),
	.q_b ( read_data_b[1] )
	);	




logic [3:0] Ct_row_counter; // used to go from row to row in S' x C multiplication
logic [31:0] Ct_buffer;

logic [2:0] c_increment;

//multipliers and adders
logic [31:0] a1;
logic [31:0] a2;

logic [31:0] m1op1;
logic [31:0] m2op1;
logic [31:0] m3op1;

logic [31:0] C1;
logic [31:0] C2;
logic [31:0] C3;

logic [4:0] c_m1;
logic [4:0] c_m2;
logic [4:0] c_m3;

logic [31:0] m1;
logic [31:0] m2;
logic [31:0] m3;

logic [63:0] m1_long;
logic [63:0] m2_long;
logic [63:0] m3_long;

assign m1_long = m1op1 * C1;
assign m2_long = m2op1 * C2;
assign m3_long = m3op1 * C3;

assign m1 = m1_long[31:0];
assign m2 = m2_long[31:0];
assign m3 = m3_long[31:0];



always_ff @ (posedge Clock or negedge resetn) begin
	if (resetn == 1'b0) begin	

		c_increment <= 3'd0;
			
		write_enable_a[0] <= 1'b0;		
		write_data_a[0] <= 32'd0;		
		
		state <= M2_Ct_IDLE;
		
	end else begin
		case (state)
		M2_Ct_IDLE: begin
			if(M2_Ct_start) begin
				state <= Ct_LI0;
			end			
		end

		Ct_LI0: begin
			address_fetch_b <= 0;
			state <= Ct_LI1;		
		end 
		
		Ct_LI1: begin
			address_fetch_b <= address_fetch_b + 1;
			
			Ct_buffer <= read_data_b[0];
			
			m1op1 <= read_data_b[0][31:16];
			c_m1 <= 5'd0;
			
			m2op1 <= read_data_b[0][31:16];
			c_m2 <= 5'd0;
			
			m3op1 <= read_data_b[0][15:0];
			c_m3 <= 5'd0;
			
			state <= Ct_LI2;		
		end
		
		Ct_LI2: begin
		
			m1op1 <= Ct_buffer[15:0];
			c_m1 <= c_m1 + 5'd4;
			
			m2op1 <= read_data_b[0][31:16];
			c_m2 <= c_m2 + 5'd4;
			
			m3op1 <= read_data_b[0][31:16];
			c_m3 <= c_m3 + 5'd4;
			
			a1 <= m1 + m3;
			a2 <= m2;
			
			state <= Ct_CC3;		
		end
		
		Ct_CC1: begin
			address_fetch_b <= address_fetch_b + 1;
			
			Ct_buffer <= read_data_b[0];
			
			m1op1 <= read_data_b[0][31:16];
			c_m1 <= c_increment;
			
			m2op1 <= read_data_b[0][31:16];
			c_m2 <= c_increment;
			
			m3op1 <= read_data_b[0][15:0];
			c_m3 <= c_increment;
			
			a1 <= a1 + m1;
			a2 <= a2 + m2;
			
			state <= Ct_CC2;		
		end
		
		Ct_CC2: begin
			
			m1op1 <= Ct_buffer[16:0];
			c_m1 <= c_m1 + 5'd4;
			
			m2op1 <= read_data_b[0][31:16];
			c_m2 <= c_m2 + 5'd4;
			
			m3op1 <= read_data_b[0][31:16];
			c_m3 <= c_m3 + 5'd4;
			
			a1 <= m1 + m3;
			a2 <= m2;
			
			write_data_a[1] <= a1 >> 8;
			write_data_b[1] <= a2 >> 8;
			
			write_enable_a[1] <= 1'b1;
			write_enable_b[1] <= 1'b1;
			
		
			
			state <= Ct_CC3;		
		end
		
		Ct_CC3: begin
			address_fetch_b <= address_fetch_b + 1;
			
			if(c_increment) begin
				address_fetch_c <= address_fetch_c + 2; // updating address later to start from zero
				address_fetch_d <= address_fetch_d + 2;
			end
			
			write_enable_a[1] <= 1'b0;
			write_enable_b[1] <= 1'b0;
			
			m1op1 <= read_data_b[0][15:0];
			c_m1 <= c_m1 + 5'd4;
			
			m2op1 <= read_data_b[0][15:0];
			c_m2 <= c_m2 + 5'd4;
			
			a1 <= a1 + m2;
			a2 <= a2 + m1 + m3;
			
			state <= Ct_CC4;						
		end
		
		Ct_CC4: begin
			address_fetch_b <= address_fetch_b + 1;
			
			Ct_buffer <= read_data_b[0];
			
			m1op1 <= read_data_b[0][31:16];
			c_m1 <= c_m1 + 5'd4;
			
			m2op1 <= read_data_b[0][31:16];
			c_m2 <= c_m2 + 5'd4;
			
			m3op1 <= read_data_b[0][15:0];
			c_m3 <= c_m3 + 5'd4;
			
			a1 <= a1 + m1;
			a2 <= a2 + m2;
			
			state <= Ct_CC5;		
		end
		
		Ct_CC5: begin
		
			m1op1 <= Ct_buffer[31:16];
			c_m1 <= c_m1 + 5'd4;
			
			m2op1 <= read_data_b[0][31:16];
			c_m2 <= c_m2 + 5'd4;
			
			m3op1 <= read_data_b[0][31:16];
			c_m3 <= c_m3 + 5'd4;
			
			a1 <= a1 + m1 + m3;
			a2 <= a2 + m2;
			
			if(c_increment == 2'd3) begin
				state <= Ct_LO1;
			end else begin
				state <= Ct_CC6;
			end		
		end
		
		Ct_CC6: begin
			address_fetch_b <= 0;
			
			m1op1 <= Ct_buffer[15:0];
			c_m1 <= c_m1 + 5'd4;
			
			m2op1 <= read_data_b[0][15:0];
			c_m2 <= c_m2 + 5'd4;
			
			a1 <= a1 + m2;
			a2 <= a2 + m1 + m3;
			
			c_increment <= c_increment + 2'd1;
			
			state <= Ct_CC1;		
		end
		
		Ct_LO1: begin
			
			m1op1 <= read_data_b[0][15:0];
			c_m1 <= c_m1 + 5'd4;
			
			m2op1 <= read_data_b[0][15:0];
			c_m2 <= c_m2 + 5'd4;
			
			a1 <= a1 + m2;
			a2 <= a2 + m1 + m3;
			
			state <= Ct_LO2;		
		end
		
		Ct_LO2: begin
			
			a1 <= a1 + m1;
			a2 <= a2 + m2;
			
			state <= Ct_LO3;		
		end
		
		Ct_LO3: begin
			
			a1 <= a1 + m1;
			a2 <= a2 + m2;
			
			write_data_a[1] <= a1 >> 8;
			write_data_b[1] <= a2 >> 8;
			
			write_enable_a[1] <= 1'b1;
			write_enable_b[1] <= 1'b1;
			
			Ct_row_counter <= Ct_row_counter + 3'd1;
			
			state <= Ct_LO4;	
		end
		
		Ct_LO4: begin
			
			write_enable_a[1] <= 1'b0;
			write_enable_b[1] <= 1'b0;
						
			if(Ct_row_counter == 3'd7) begin
				M2_Ct_done <= 1'b1;
				state <= M2_Ct_IDLE;
			end else begin			
				state <= Ct_LI1;
			end	
		end
	endcase
	end
end

//C Matrix for C indices used in m1
always_comb begin
	case(c_m1)
	0:  C1 = 32'sd1448;   //C00
	1:  C1 = 32'sd1448;   //C02
	2:  C1 = 32'sd1448;   //C04
	3:  C1 = 32'sd1448;   //C06
	4:  C1 = 32'sd1702;   //C11
	5:  C1 = 32'sd399;    //C13
	6:  C1 = -32'sd1137;  //C15
	7:  C1 = -32'sd2008;  //C17
	8:  C1 = 32'sd1702;   //C30
	9:  C1 = -32'sd2008;  //C32
	10:  C1 = 32'sd1137;   //C34
	11:  C1 = 32'sd399;    //C36
	12:  C1 = 32'sd1448;   //C40
	13:  C1 = -32'sd1448;  //C42
	14:  C1 = 32'sd1448;   //C44
	15:  C1 = -32'sd1448;  //C46
	16:  C1 = -32'sd2008;  //C51
	17:  C1 = 32'sd1702;   //C53
	18:  C1 = -32'sd399;   //C55
	19:  C1 = -32'sd1137;  //C57
	20:  C1 = 32'sd399;    //C70
   21:  C1 = 32'sd1702;   //C72
   22:  C1 = 32'sd2008;   //C74
   23:  C1 = 32'sd1137;   //C76
	endcase
end

//C Matrix for C indices used in m2
always_comb begin
	case(c_m2)
	0:  C2 = 32'sd1448;   //C01
	1:  C2 = 32'sd1448;   //C03
	2:  C2 = 32'sd1448;   //C05
	3:  C2 = 32'sd1448;   //C07
	4:  C2 = 32'sd1892;   //C20
	5:  C2 = -32'sd783;   //C22
	6:  C2 = -32'sd1892;  //C24
	7:  C2 = 32'sd783;    //C26
	8:  C2 = -32'sd399;   //C31
	9:  C2 = -32'sd1137;  //C33
	10:  C2 = 32'sd2008;   //C35
	11:  C2 = -32'sd1702;  //C37
	12:  C2 = -32'sd1448;  //C41
	13:  C2 = 32'sd1448;   //C43
	14:  C2 = -32'sd1448;  //C45
	15:  C2 = 32'sd1448;   //C47
	16:  C2 = 32'sd783;    //C60
	17:  C2 = 32'sd1892;   //C62
	18:  C2 = -32'sd783;   //C64
	19:  C2 = -32'sd1892;  //C66
   20:  C2 = -32'sd1137;  //C71
   21:  C2 = -32'sd2008;  //C73
   22:  C2 = -32'sd1702;  //C75
   23:  C2 = -32'sd399;   //C77
	endcase
end

//C Matrix for C indices used in m3
always_comb begin
	case(c_m3)
	0:  C3 = 32'sd2008;   //C10
	1:  C3 = 32'sd1137;   //C12
	2:  C3 = -32'sd399;   //C14
	3:  C3 = -32'sd1702;  //C16
	4:  C3 = 32'sd783;    //C21
	5:  C3 = -32'sd1892;  //C23
	6:  C3 = -32'sd783;   //C25
	7:  C3 = 32'sd1892;   //C27
	8:  C3 = 32'sd1137;   //C50
	9:  C3 = 32'sd399;    //C52
	10:  C3 = -32'sd1702;  //C54
	11:  C3 = 32'sd2008;   //C56
	12:  C3 = -32'sd1892;  //C61
	13:  C3 = -32'sd783;   //C63
	14:  C3 = 32'sd1892;   //C65
	15:  C3 = 32'sd783;    //C67
	endcase
end

endmodule