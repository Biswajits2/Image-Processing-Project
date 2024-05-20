`ifndef DEFINE_STATE

// for top state - we have more states than needed
typedef enum logic [1:0] {
	S_IDLE,
	S_UART_RX,
	S_M2,
	S_M1
} top_state_type;

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

 typedef enum logic [3:0] {
	M1_Idle,
	 Lead_1,
	 Lead_2,
	 Lead_3,
	 Lead_4,
	 Lead_5,
	 Lead_6,
	 Lead_7,
	 Lead_8,
	 CC_1,
	 CC_2,
	 CC_3,
	 CC_4,
	 CC_5,
	 CC_6,
	 CC_7
 }M1_SRAM_state_type;

  typedef enum logic [4:0] {
	M2_Idle,
	M2_Lead_1,
	M2_Lead_2,
	M2_Lead_3,
	M2_Lead_4,
	M2_Lead_5,
	M2_Lead_6,
	M2_Lead_7,
	M2_Lead_8,
	M2_Lead_9,
	M2_Lead_10,
	M2_Lead_11,
	M2_CC_1,
	M2_CC_2,
	M2_CC_3,
	M2_CC_4,
	M2_CC_5,
	M2_CC_6,
	M2_CC_7,
	M2_CC_8,
	M2_CC_9,
	M2_CC_10,
	M2_CC_11,
	M2_CC_12,
	M2_CC_13,
	M2_CC_14,
	M2_CC_15,
	M2_CC_16
 }M2_SRAM_state_type;
	 
parameter 
   VIEW_AREA_LEFT = 160,
   VIEW_AREA_RIGHT = 480,
   VIEW_AREA_TOP = 120,
   VIEW_AREA_BOTTOM = 360,
 
	U_START_ADDRESS = 18'd38400,
	V_START_ADDRESS = 18'd57600,
	Y_START_ADDRESS = 18'd0,
	RGB_START_ADDRESS = 18'd146944,

	M2_Y_START_ADDRESS = 18'd76800;
	


`define DEFINE_STATE 1
`endif
