	module sram_controller
(
	input	wire 					clk				,	
	input 	wire					rst				,	
	
	output	wire					we				,		
	output 	wire					oe				,		
	output 	wire					ce				,		

	inout	wire	[7:0]			data			,
//	input  	wire	[16:0]			addr			,
	input	wire	 				rd_request		,
	input 							wr_request		,
	input	wire	[7:0] 			wr_data			,
	output	reg		[7:0] 			rd_data			

);

//para define

`define    	DELAY_80NS        (cnt==3'd7)
parameter   IDLE    = 4'd0,
            WRT0    = 4'd1,
            WRT1    = 4'd2,
            REA0    = 4'd3,
            REA1    = 4'd4;

//reg define
reg	[25:0] 	delay			; 
reg	[2:0] 	cnt				;   
reg	[3:0] 	cstate,nstate	;
reg 		sdlink			;           

//
always @ (posedge clk or negedge rst) begin
    if(!rst) 
		cnt <= 3'd0;
    else if(cstate == IDLE) 	
		cnt <= 3'd0;
    else 
		cnt <= cnt+1'b1;
end
            
//Fsm
always @ (posedge clk or negedge rst)
    if(!rst) 
		cstate <= IDLE;
    else 
		cstate <= nstate;

//Fsm
always @ (cstate or wr_request or rd_request or cnt)
    case (cstate)
        IDLE: 
			if(wr_request) 
				nstate <= WRT0;
			else if(rd_request)
				nstate <= REA0;
			else 
				nstate <= IDLE;
        WRT0: 
			if(`DELAY_80NS) 
				nstate <= WRT1;
			else
				nstate <= WRT0;    
        WRT1: 		
			nstate <= IDLE;
        REA0: 
			if(`DELAY_80NS) 
				nstate <= REA1;
            else 
				nstate <= REA0;
        REA1: 		
			nstate <= IDLE;
		default: 	
			nstate <= IDLE;
     endcase           


//REA1 - Read data from sram.
always @ (posedge clk or negedge rst)
   	if(!rst) 
		rd_data <= 8'd0;
   	else if(cstate == REA1) begin 
		rd_data <= data; 
	end

//SRAM D0-D7 direction control	 
always @ (posedge clk or negedge rst) begin
    if(!rst) 
		sdlink <=1'b0;
    else begin
        case (cstate)
            IDLE: 
				if(wr_request) 
					sdlink <= 1'b1;
				else if(rd_request) 
					sdlink <= 1'b0;
				else 
					sdlink <= 1'b0;
            WRT0: 
				sdlink <= 1'b1;
            default: 
				sdlink <= 1'b0;
        endcase
	end
end


assign data = sdlink ? wr_data : 8'hz	;   
assign we 	= ~sdlink					;
assign oe 	= sdlink					;
assign ce 	= 1'b0						;

endmodule