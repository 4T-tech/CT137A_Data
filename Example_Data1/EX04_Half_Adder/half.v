`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/26 14:06:27
// Design Name: 
// Module Name: half
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


module half(
    input   wire    A,      //S1
    input   wire    B,      //S2
    output  wire    S,      //LD1
    output  wire    C       //LD8
    );
    
assign S = A ^ B;
assign C = A & B;

endmodule
