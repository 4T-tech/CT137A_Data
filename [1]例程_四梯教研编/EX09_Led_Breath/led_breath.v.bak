`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/29 12:29:37
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

module led_breath(

    input   wire                clk,        //system clock
    input   wire                rst   ,     //global reset
    output  reg     [7:0]       led         //led: ld1 - ld8
);

parameter   COUNTER_US = 6'd49;
parameter   COUNTER_MS = 10'd999;
parameter   COUNTER_1S = 10'd999;

reg [5:0]   count_us    ;
reg [9:0]   count_ms    ;
reg [9:0]   count_1s    ;
reg         cnt_1s_en   ;


//us counter  -- 50Mhz
always@(posedge clk or posedge rst)
    if(rst)
        count_us <= 6'b0;
    else if(count_us == COUNTER_US)
        count_us <= 6'b0;
    else
        count_us <= count_us + 1;

//ms counter  -- 1000us
always@(posedge clk or posedge rst)
    if(rst)
        count_ms <= 10'b0;
    else if(count_ms == COUNTER_MS && count_us == COUNTER_US)
        count_ms <= 10'b0;
    else if(count_us == COUNTER_US)
        count_ms <= count_ms + 1;

//1s counter -- 1000ms
always@(posedge clk or posedge rst)
    if(rst)
        count_1s <= 10'b0;
    else if(count_1s == COUNTER_1S && count_ms == COUNTER_MS && count_us == COUNTER_US)
        count_1s <= 10'b0;
    else if(count_ms == COUNTER_MS && count_us == COUNTER_US)
        count_1s <= count_1s + 1;


//
always@(posedge clk or posedge rst) begin
    if(rst) begin
        cnt_1s_en <= 1'b0;
    end else if(count_1s == COUNTER_1S && count_ms == COUNTER_MS && count_us == COUNTER_US) begin
        cnt_1s_en <= ~cnt_1s_en;
    end
end

//
always@(posedge clk or posedge rst) begin
    if(rst) begin
        led <= 8'b1111_1111;
    end else if((cnt_1s_en == 1 && count_ms < count_1s) ||  (cnt_1s_en == 1'b0 && count_ms > count_1s)) begin
        led <= 8'b1111_1111;
    end else begin
        led <= 8'b0000_0000;
    end
end

endmodule