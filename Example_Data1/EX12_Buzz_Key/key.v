`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/12 18:28:36
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

module key(
    input   wire                clk,
    input   wire                rst,
    input   wire    [3:0]       key_in,
    output  reg     [2:0]       key_val
);

//10ms
parameter MS_MAX = 20'd499_999;
reg [19:0]  ms_count;

//
always@(posedge clk or negedge rst) begin
    if(!rst)
        ms_count <= 0;
    else begin
        if ((key_in[0] == 1) && (key_in[1] == 1) && (key_in[2] == 1) && (key_in[3] == 1))
            ms_count <= 0;
        else begin
             if(ms_count == MS_MAX)
                ms_count <= ms_count;
             else
                ms_count = ms_count + 1;    
        end
    end
end

//
always@(posedge clk or negedge rst)
    if(!rst)
        key_val <= 3'b000;
    else if (ms_count == MS_MAX - 1) begin
        if(key_in[0] == 0)
            key_val <= 3'b001; 
        else if(key_in[1] == 0)
            key_val <= 3'b010;
        else if(key_in[2] == 0)
            key_val <= 3'b011;
        else if(key_in[3] == 0)
            key_val <= 3'b100;  
    end else
        key_val <= 0;

endmodule