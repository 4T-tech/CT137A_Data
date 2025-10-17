`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/29 11:19:17
// Design Name: 
// Module Name: led
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


module led(
    input   wire                clk,		//时钟信号
    input   wire                rst,		//复位信号
    output  reg     [7:0]       led			//LD1 - LD8
    );

reg             [31:0]  count;
reg				 [3:0]   stat;

//状态切换模式
always @(posedge clk, negedge rst) begin
    if(!rst) begin
        count <= 0;
		  led <= 8'b1111_1111;
		  stat <= 0;
    end else begin
        if(count == 5000000 - 1) begin
            count <= 0;
				led <= ~(1 << stat);
				if(stat == 8) begin
				    stat <= 0;
				end else begin
					 stat <= stat + 1;
				end
        end else begin
            count <= count + 1;
        end
    end
end

endmodule
