
module top (
	input	wire			clk			,	
	input 	wire			rst_n		,	

	input 	wire	[3:0]	key_in		,		
	output	wire			we			,		
	output 	wire			oe			,		
	output 	wire			ce			,		
	output	wire	[16:0]	addr		,		
	inout	wire	[7:0]	data		,		
	output 	wire 	[7:0] 	seg_number	,	
	output 	wire 	[7:0]	seg_choice		
);


wire				[7:0]	rd_data		;
reg							wr_req		;
reg					[7:0]	wr_data		;
assign addr = 17'b0_0000_0000_0000_0000 ;

//
always@(posedge clk or negedge rst_n)
	if(!rst_n) begin
		wr_req <= 1'b1;
		wr_data <= 8'b1100_0011;
	end else
		wr_req <= 1'b0;

//seg module
segdisplay inst_seg(
	.clk 				(clk)												,
	.rst 				(rst_n)												,	
	.seg_number_in 		({4'd13,4'd10,4'd10,4'd10,4'd10,4'd10,rd_data})		,
	.seg_number 		(seg_number)										,
	.seg_choice 		(seg_choice)


);

//sram module
sram_controller u_sram_controller
(
	.clk				(clk)						,
	.rst	    		(rst_n)						,

	.we					(we)						,		
	.oe					(oe)						,		
	.ce 				(ce)						,		

	.data				(data)						,
//	.addr				(addr)						,
	.wr_request			(wr_req)					,
	.rd_request			(~key_in[0])				,
	.wr_data			(wr_data)					,
	.rd_data			(rd_data)
);


endmodule 
 