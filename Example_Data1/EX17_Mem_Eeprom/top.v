module top( 
	input	wire			clk			,
   	input	wire			rst			,
	input	wire	[3:0]	key			,
	output 	wire	[7:0] 	seg_number	,	
	output 	wire 	[7:0]	seg_choice	,
   	output         			scl     	,
   	inout          			sda     
);								 

//wire define
wire    [7:0]   	rd_data		;
wire            	rd_data_vld	;

//reg define
reg    	[7:0]   	wr_data		;
reg                 wr_req      ;

//
always @(posedge clk or negedge rst) begin
	if(!rst) begin
		wr_data <= 8'b1100_0011;
	end else
	    wr_req <= 1'b0;
end

//eeprom module 
eeprom inst_eeprom(
	.clk		 		(clk)			,
	.rst	     		(rst)			,
	.wr_req      		(wr_req)		,
	.rd_req      		(~key[0])		,	//read data from EEPROM
	.device_id   		()				,
	.reg_addr    		(8'h03)			,
	.reg_addr_vld		(1'b1)			,
	.wr_data     		(wr_data)		,
	.wr_data_vld 		(wr_req)		,
	.rd_data     		(rd_data)		,
	.rd_data_vld 		(rd_data_vld)	,
	.ready       		()				,
	.scl         		(scl)			,
	.sda         		(sda)
);

//seg module
segdisplay inst_segdisplay(
	.clk 				(clk)													,
	.rst 				(rst)													,	
	.seg_number_in 		({4'd14, 4'd14, 4'd10, 4'd10, 4'd10, 4'd10, rd_data})	,	
	.seg_number 		(seg_number)											,
	.seg_choice 		(seg_choice)
);

endmodule
