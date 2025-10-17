`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/26 15:49:12
// Design Name: 
// Module Name: dff
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


module d_ff(
    input   wire    clk,        //时钟信号 50MHz晶振
    input   wire    d,          //输入信号 S1
    input   wire    reset,      //复位信号 RESET
    output  reg     q           //输出信号 LD1
    );

always @(posedge clk, negedge reset) begin
    if(!reset) begin
        q <= 1'b0;
    end else begin
        q <= d;
    end 
end

endmodule
