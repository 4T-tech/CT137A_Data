module top(
	input   wire            clk         ,   		
	input   wire            rst       ,		
	output  wire            rtc_sclk    ,	
	output  wire            rtc_ce      ,		
	inout   wire            rtc_data    ,	
	output  wire    [7:0]   seg_choice  ,	
	output  wire    [7:0]   seg_number	
);

wire                [7:0]   read_second ;
wire                [7:0]   read_minute ;
wire                [7:0]   read_hour   ;
wire                [7:0]   read_date   ;
wire                [7:0]   read_month  ;
wire                [7:0]   read_week   ;
wire                [7:0]   read_year   ;

//seg
segdisplay segdisplay_inst(
	.clk 				(clk),
	.rst 			    (rst),	
	.seg_number_in      ({read_hour,4'd10,read_minute,4'd10,read_second}),
	.seg_number 	    (seg_number),
	.seg_choice 	    (seg_choice)


);

//ds1302
ds1302_test ds1302_test_m0(
    .rst                (~rst),
    .clk                (clk),
    .ds1302_ce          (rtc_ce),
    .ds1302_sclk        (rtc_sclk),
    .ds1302_io          (rtc_data),
    .read_second        (read_second),
    .read_minute        (read_minute),
    .read_hour          (read_hour),
    .read_date          (read_date),
    .read_month         (read_month),
    .read_week          (read_week),
    .read_year          (read_year)
);

endmodule 
