module top
(
	input		wire  		clk			,
	input  	wire			rst      ,
	output	wire			tx       ,
	input		wire			rx   	   , 
	output   reg  [7:0]	led		
);


wire [7:0] 		tx_data          	;
wire				done   				;

uart_tx inst_tx( 
    .clk					(clk)			,
    .rst					(rst)			,
    .tx_data         (tx_data)	,
    .tx_data_vld		(done)		,
    .ready     		(1'b1)		,
    .tx              (tx)
);

uart_rx inst_rx( 
    .clk					(clk)       ,
    .rst					(rst)       ,
    .rx					(rx)        ,
    .rx_data_vld		(done)      ,
    .rx_data         (tx_data)
);	

always @(posedge clk or negedge rst) begin
	if(!rst) begin
		led <= 8'b1111_1111;
	end else begin
		if(done)
			led <= tx_data;
		else
			led <= led;
	end
end

endmodule
