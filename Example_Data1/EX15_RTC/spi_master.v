module spi_master(
	input  	wire                    clk		,	
	input  	wire                    rst	,
	output 	wire                    nCS		,       
	output 	wire                    DCLK	,      
	output 	wire                    MOSI	,      
	input  	wire                    MISO	,      
	input  	wire                    CPOL	,
	input  	wire                    CPHA	,
	input  	wire                    nCS_ctrl,
	input	wire		[15:0]      clk_div	,
	input  	wire                    wr_req	,
	output 	wire                    wr_ack	,
	input	wire		[7:0]		data_in	,
	output	wire		[7:0]       data_out
);

//Reg define
reg                     DCLK_reg	;
reg			[7:0]      	MOSI_shift	;
reg			[7:0]      	MISO_shift	;
reg			[2:0]      	state		;
reg			[2:0]      	next_state	;
reg 		[15:0]		clk_cnt		;
reg			[4:0]       clk_edge_cnt;

localparam				IDLE            = 0;
localparam				DCLK_EDGE       = 1;
localparam				DCLK_IDLE       = 2;
localparam				ACK             = 3;
localparam				LAST_HALF_CYCLE = 4;
localparam				ACK_WAIT        = 5;

assign MOSI = MOSI_shift[7]		;							
assign data_out = MISO_shift	;							
assign nCS = nCS_ctrl			;									
assign DCLK = DCLK_reg			;									
assign wr_ack = (state == ACK)	;							

//
always@(posedge clk or posedge rst)	begin
	if(rst)
		state <= IDLE;
	else
		state <= next_state;
end

always@(*)	begin
	case(state)
		IDLE:
			if(wr_req == 1'b1)
				next_state <= DCLK_IDLE;
			else
				next_state <= IDLE;
		DCLK_IDLE:
			if(clk_cnt == clk_div)
				next_state <= DCLK_EDGE;
			else
				next_state <= DCLK_IDLE;
		DCLK_EDGE: 
			if(clk_edge_cnt == 5'd15)
				next_state <= LAST_HALF_CYCLE;
			else
				next_state <= DCLK_IDLE;	
		LAST_HALF_CYCLE:
			if(clk_cnt == clk_div)
				next_state <= ACK;
			else
				next_state <= LAST_HALF_CYCLE; 	
		ACK:
			next_state <= ACK_WAIT;
		ACK_WAIT:
			next_state <= IDLE;
		default:
			next_state <= IDLE;
	endcase
end

//
always@(posedge clk or posedge rst)	begin
	if(rst)
		DCLK_reg <= 1'b0;
	else if(state == IDLE)
		DCLK_reg <= CPOL;
	else if(state == DCLK_EDGE)
		DCLK_reg <= ~DCLK_reg;			
end

//
always@(posedge clk or posedge rst)	begin
	if(rst)
		clk_cnt <= 16'd0;
	else if(state == DCLK_IDLE || state == LAST_HALF_CYCLE) 
		clk_cnt <= clk_cnt + 16'd1;
	else
		clk_cnt <= 16'd0;
end

//
always@(posedge clk or posedge rst)	begin
	if(rst)
		clk_edge_cnt <= 5'd0;
	else if(state == DCLK_EDGE)
		clk_edge_cnt <= clk_edge_cnt + 5'd1;
	else if(state == IDLE)
		clk_edge_cnt <= 5'd0;
end

//
always@(posedge clk or posedge rst)	begin
	if(rst)
		MOSI_shift <= 8'd0;
	else if(state == IDLE && wr_req)
		MOSI_shift <= data_in;			
	else if(state == DCLK_EDGE)			
		if(CPHA == 1'b0 && clk_edge_cnt[0] == 1'b1)	
			MOSI_shift <= {MOSI_shift[6:0],MOSI_shift[7]};	
		else if(CPHA == 1'b1 && (clk_edge_cnt != 5'd0 && clk_edge_cnt[0] == 1'b0)) 
			MOSI_shift <= {MOSI_shift[6:0],MOSI_shift[7]};
end

//
always@(posedge clk or posedge rst)	begin
	if(rst)
		MISO_shift <= 8'd0;
	else if(state == IDLE && wr_req)
		MISO_shift <= 8'h00;
	else if(state == DCLK_EDGE)
		if(CPHA == 1'b0 && clk_edge_cnt[0] == 1'b0)
			MISO_shift <= {MISO_shift[6:0],MISO};
		else if(CPHA == 1'b1 && (clk_edge_cnt[0] == 1'b1))
			MISO_shift <= {MISO_shift[6:0],MISO};
end

endmodule 
