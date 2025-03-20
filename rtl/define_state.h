`ifndef DEFINE_STATE

// for top state - we have more states than needed
typedef enum logic [1:0] {
    S_IDLE,
    S_UART_RX,
    MILESTONE_1,
	 MILESTONE_2
} top_state_type;

typedef enum logic [31:0] {
    M1_IDLE,
    LI1,
    LI2,
    LI3,
    LI4,
    LI5,
    LI6,
    LI7,
	 LI8,	
    CC1,
    CC2,
    CC3,
    CC4,
    CC5,
    CC6,
    CC7,
    LO1,
    LO2,
    LO3,
    LO4,
    LO5,
    LO6,
    LO7,
	 LO8
} M1_state_type;

typedef enum logic [31:0] {
    M2_IDLE,
	 Fetch_first,
	 Ct_first,
	 Mega_State_A,
	 Mega_State_B,
	 Cs_Last,
	 Write_Last
} M2_state_type;

typedef enum logic [31:0] {
	 M2_Fetch_IDLE,
	 Delay1,
    Fetch0,
	 Fetch1,
	 Fetch2,
	 Fetch3,
	 Fetch4,
	 Fetch5,
	 Fetch6,
	 Fetch7,
	 Fetch8,
	 Fetch9,
	 Fetch10
} M2_Fetch_state_type;

typedef enum logic [31:0] {
	 M2_Ct_IDLE,
    Ct_LI0,
	 Ct_LI1,
	 Ct_LI2,
	 Ct_CC1,
	 Ct_CC2,
	 Ct_CC3,
	 Ct_CC4,
	 Ct_CC5,
	 Ct_CC6,
	 Ct_LO1,
	 Ct_LO2,
	 Ct_LO3,
	 Ct_LO4	
} M2_Ct_state_type;

typedef enum logic [31:0] {
	 M2_Cs_IDLE,
    Cs_LI0,
	 Cs_LI1,
	 Cs_LI2,
	 Cs_CC1,
	 Cs_CC2,
	 Cs_CC3,
	 Cs_CC4,
	 Cs_CC5,
	 Cs_CC6,
	 Cs_LO1,
	 Cs_LO2,
	 Cs_LO3,
	 Cs_LO4	
} M2_Cs_state_type;

typedef enum logic [31:0] {
	 M2_Write_IDLE,
    Write_LI0,
	 Write_CC1,
	 Write_CC2,
	 Write_CC3,
	 Write_LO1
} M2_Write_state_type;

typedef enum logic [1:0] {
    S_RXC_IDLE,
    S_RXC_SYNC,
    S_RXC_ASSEMBLE_DATA,
    S_RXC_STOP_BIT
} RX_Controller_state_type;

typedef enum logic [2:0] {
    S_US_IDLE,
    S_US_STRIP_FILE_HEADER_1,
    S_US_STRIP_FILE_HEADER_2,
    S_US_START_FIRST_BYTE_RECEIVE,
    S_US_WRITE_FIRST_BYTE,
    S_US_START_SECOND_BYTE_RECEIVE,
    S_US_WRITE_SECOND_BYTE
} UART_SRAM_state_type;

typedef enum logic [3:0] {
    S_VS_WAIT_NEW_PIXEL_ROW,
    S_VS_NEW_PIXEL_ROW_DELAY_1,
    S_VS_NEW_PIXEL_ROW_DELAY_2,
    S_VS_NEW_PIXEL_ROW_DELAY_3,
    S_VS_NEW_PIXEL_ROW_DELAY_4,
    S_VS_NEW_PIXEL_ROW_DELAY_5,
    S_VS_FETCH_PIXEL_DATA_0,
    S_VS_FETCH_PIXEL_DATA_1,
    S_VS_FETCH_PIXEL_DATA_2,
    S_VS_FETCH_PIXEL_DATA_3
} VGA_SRAM_state_type;

parameter 
   VIEW_AREA_LEFT = 160,
   VIEW_AREA_RIGHT = 480,
   VIEW_AREA_TOP = 120,
   VIEW_AREA_BOTTOM = 360;

`define DEFINE_STATE 1
`endif