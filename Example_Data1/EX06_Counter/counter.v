`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/26 16:31:34
// Design Name: 
// Module Name: counter
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


module counter(
    input   wire    clk,
    input   wire    rst,
    output  reg     led
    );

localparam  counter_width = 32;
reg[counter_width:0] count;

always @(posedge clk, negedge rst) begin
    if(!rst) begin
        count <= 0;
        led <= 1;
    end else begin
        if(count == 50_000_000) begin
            count <= 0;
            led <= ~led;
        end else begin
            count <= count + 1;
        end
    end
end

endmodule
