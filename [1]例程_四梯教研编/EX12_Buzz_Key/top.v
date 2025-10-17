`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/12 18:29:35
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
    input   wire            clk,
    input   wire            rst,
    input   wire    [3:0]   key_in,
	output	wire			buz

    );

wire    [2:0]       key_val;
reg                 start_buz;
   
key inst_key(
	.clk       (clk),
	.rst       (rst),
	.key_in    (key_in), 
	.key_val   (key_val)  
);


buzz inst_buz(
    .clk        (clk),
    .rst        (rst),
    .buz        (buz),
    .en_buz     (start_buz)
);


always@(posedge clk or negedge rst) begin
    if(!rst)
        start_buz <= 1'b0;
    else begin
        if(key_val == 3'b001)
            start_buz <= ~start_buz;
    end
end
        

endmodule
