module uart_rx( 
    input				clk,
    input				rst,
    input            rx,
    output           rx_data_vld,
    output   [7:0]	rx_data            
);								 


parameter   MAX_BPS = 115200;
parameter   CLOCK = 50_000_000;
parameter   MAX_1bit = CLOCK/MAX_BPS;
parameter   CHECK_BIT = "None";


localparam  IDLE   = 'b0001,
            START  = 'b0010,
            DATA   = 'b0100,
            CHECK  = 'b1000;

reg 	[3:0]	cstate     	;
reg	[3:0]	nstate     		;
    
wire			IDLE_START;
wire    		START_DATA;
wire    		DATA_IDLE;
wire    		DATA_CHECK;
wire    		CHECK_IDLE;
 
reg	[8:0]	cnt_baud	   	;
wire			add_cnt_baud	;
wire			end_cnt_baud	;
 
reg	[2:0]	cnt_bit	   	;
wire			add_cnt_bit	;
wire			end_cnt_bit	;
    
reg	[3:0]	bit_max;
 
reg	[7:0]	rx_temp;
reg			rx_check;
wire			check_val; 
 
reg			rx_r1;
reg			rx_r2;
wire			rx_nege;
 
//
always @(posedge clk or negedge rst) begin
	if (!rst) begin
		rx_r1 <= 1;
		rx_r2 <= 1;
		end
	else begin
		rx_r1 <= rx;
		rx_r2 <= rx_r1;
		end
	end
 
assign rx_nege = ~rx_r1 && rx_r2;
 
//
always @(posedge clk or negedge rst)begin 
	if(!rst)begin
		cnt_baud <= 'd0;
		end 
	else if(add_cnt_baud)begin 
		if(end_cnt_baud)begin 
			cnt_baud <= 'd0;
			end
		else begin 
			cnt_baud <= cnt_baud + 1'd1;
			end 
		end
	end 
    
assign add_cnt_baud = cstate != IDLE;
assign end_cnt_baud = add_cnt_baud && cnt_baud == MAX_1bit - 1'd1;
    
//
always @(posedge clk or negedge rst)begin 
	if(!rst)begin
		cnt_bit <= 'd0;
		end 
	else if(add_cnt_bit)begin 
		if(end_cnt_bit)begin 
			cnt_bit <= 'd0;
			end
		else begin 
			cnt_bit <= cnt_bit + 1'd1;
			end 
		end
	end 
    
assign add_cnt_bit = end_cnt_baud;
assign end_cnt_bit = add_cnt_bit && cnt_bit == bit_max -1'd1;
    
//
always @(*)begin 
	case (cstate)
		IDLE :bit_max = 'd0;
		START:bit_max = 'd1;
		DATA :bit_max = 'd8;
		CHECK:bit_max = 'd1;
		default: bit_max = 'd0;
	endcase
end

assign IDLE_START = (cstate == IDLE) && rx_nege;
assign START_DATA = (cstate == START) && end_cnt_bit;
assign DATA_IDLE = (cstate == DATA) && end_cnt_bit && CHECK_BIT == "None";
assign DATA_CHECK = (cstate == DATA) && end_cnt_bit;
assign CHECK_IDLE = (cstate == CHECK) && end_cnt_bit;

//
always @(posedge clk or negedge rst)begin 
	if(!rst)begin
		cstate <= IDLE;
		end 
	else begin 
		cstate <= nstate;
		end 
	end
    
//
always @(*) begin
	case(cstate)
		IDLE  :begin
			if (IDLE_START) begin
				nstate = START;
				end
			else begin
				nstate = cstate;
				end
			end
		START :begin
			if (START_DATA) begin
				nstate = DATA;
				end
			else begin
				nstate = cstate;
				end
			end
		DATA  :begin
			if (DATA_IDLE) begin
				nstate = IDLE;
				end
			else if (DATA_CHECK) begin
				nstate = CHECK;
				end
			else begin
				nstate = cstate;
				end
			end
		CHECK:begin
			if (CHECK_IDLE) begin
				nstate = IDLE;
				end
			else begin
				nstate = cstate;
				end
			end
		default : nstate = IDLE;
	endcase
end

//
always @(posedge clk or negedge rst) begin
	if (!rst) begin
		rx_check <= 0;
		end
	else if (cstate == CHECK && cnt_baud == MAX_1bit >>1) begin
		rx_check <= rx_r1;
		end
	end

assign check_val = (CHECK_BIT == "Odd") ? ~^rx_temp : ^rx_temp;
//
always @(posedge clk or negedge rst) begin
	if (!rst) begin
		rx_temp <= 0;
		end
	else if (cstate == DATA && cnt_baud == MAX_1bit >> 1) begin
		rx_temp[cnt_bit] <= rx_r1;
	end else begin
		rx_temp <= rx_temp;
	end
end
assign rx_data = rx_temp;
assign rx_data_vld  = (CHECK_BIT == "None") ? DATA_IDLE
                          :(CHECK_IDLE && (check_val == rx_check)) ? 1
                          : 0;
    
endmodule