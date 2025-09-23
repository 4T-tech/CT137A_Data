module top( 
   	input	wire			clk			,
   	input	wire			rst			,
   	output  wire       		scl     	,
   	inout   wire       		sda     
);								 

//
reg            	wr_req		;
reg    	[7:0]   wr_data		;
reg		[31:0]	count		;

//
always@(posedge clk or negedge rst)begin
	if(!rst)begin
		wr_req <= 1'b0;
		wr_data <= 8'h70;
	end else begin
			if(count == 32'd1_000_000) begin
				count <= 0;
				wr_data <= wr_data + 8'd1;
				wr_req <= 1'b1;
				if(wr_data < 8'h70)
					wr_data <= 8'h70;
			end
			else begin
				count <= count + 1;
				wr_req <= 0;
			end
	end
end

//dac module 
dac dac_inst(
	.clk		 	(clk)			,
	.rst	     	(rst)			,
	.wr_req      	(wr_req)		,
	.rd_req      	()				,
	.device_id   	(7'b100_1100)	,
	.reg_addr    	()				,
	.reg_addr_vld	()				,
	.wr_data     	(wr_data)		,
	.wr_data_vld 	(wr_req)		,
	.rd_data     	()				,
	.rd_data_vld 	()				,
	.ready       	()				,
	.scl         	(scl)			,
	.sda         	(sda)
);

endmodule
