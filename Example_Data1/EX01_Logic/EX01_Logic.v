`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/25 17:56:46
// Design Name: 
// Module Name: logic
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


module EX01_Logic (
    input   wire    A,      //输入线A - SW1
    input   wire    B,      //输入线B - SW2
    input   wire    C,      //输入线C - SW3
    input   wire    D,      //输入线D - SW4
    output  wire    F       //输出线F - LD1      
);


assign F = A & B & C & D;
    
endmodule