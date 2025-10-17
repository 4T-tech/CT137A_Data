`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/27 21:29:11
// Design Name: 
// Module Name: q_8
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


module q_8(
    output  reg     [7:0]   out,
    input   wire            clk,   
    input   wire            rst
    );

localparam  counter_width = 32;
reg[counter_width-1:0] count1;
reg[counter_width-1:0] count2;
reg[counter_width-1:0] count3;
reg[counter_width-1:0] count4;


always @(posedge clk, negedge rst) begin
    if (!rst) begin
        count1 <= 0;
        out[0] <= 1;
        out[1] <= 1;
    end else begin
        if (count1 == 50_000_000 - 1) begin
            out[0] <= ~out[0];
            out[1] <= ~out[1];
            count1 <= 0;
        end else begin
            count1 <= count1 + 1;
        end        
    end
end

always @(posedge clk, negedge rst) begin
    if (!rst) begin
        out[2] <= 1;
        out[3] <= 1;     
        count2 <= 0;
    end else begin
        if (count2 == 25_000_000 - 1) begin
            out[2] <= ~out[2];
            out[3] <= ~out[3];
            count2 <= 0;
        end else begin
            count2 <= count2 + 1;
        end        
    end
end

always @(posedge clk, negedge rst) begin
    if (!rst) begin
        out[4] <= 1;
        out[5] <= 1;     
        count3 <= 0;
    end else begin
        if (count3 == 16_666_667 - 1) begin
            out[4] <= ~out[4];
            out[5] <= ~out[5];
            count3 <= 0;
        end else begin
            count3 <= count3 + 1;
        end        
    end
end

always @(posedge clk, negedge rst) begin
    if (!rst) begin
        out[6] <= 1;
        out[7] <= 1;         
        count4 <= 0;
    end else begin
        if (count4 == 12_500_000  - 1) begin
            out[6] <= ~out[6];
            out[7] <= ~out[7];
            count4 <= 0;
        end else begin
            count4 <= count4 + 1;
        end        
    end
end 

endmodule