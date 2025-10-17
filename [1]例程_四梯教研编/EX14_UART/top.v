module top 
#(
    parameter       SYS_CLK_FREQ = 26'd50_000_000,
    parameter       BAUD_RATE = 115200,
    parameter       CHECK_BIT = "None",
    parameter       UART_LEN = 5
)
(
    input wire              clk,
    input wire              rst,
    input wire  [3:0]       key_in,
    input wire              rx,

    output wire             tx
);

wire [3:0]  key_value;
wire start_send;
reg start_send_char;
reg start_send_status;
wire tx_done;

reg [7:0] char_idx;
reg [7:0] tx_buffer [0:255];

reg tx_done0;
reg tx_done1;
wire send_next;

reg [7:0] rxcnt;
wire [7:0] rx_data;
wire rxover;
reg rx_status;

wire rx_done;

reg rx_done0;
reg rx_done1;
wire rx_next;

// always @(posedge clk or posedge rst) begin
//     if(rst)begin
//         tx_buffer[0] <= "H";
//         tx_buffer[1] <= "E";
//         tx_buffer[2] <= "L";
//         tx_buffer[3] <= "L";
//         tx_buffer[4] <= "O";
//     end
    
// end

KEY key_inst(
    .key_clk    (clk),
    .key_rst    (rst),
    .key_in     (key_in),
    .key_value  (key_value)
);

uart_tx
#(
    .CLOCK      (SYS_CLK_FREQ),
    .BAUD       (BAUD_RATE),
    .CHECK_BIT  (CHECK_BIT)
)uart_tx_list(
    .clk        (clk),
    .rst        (rst),
    .tx_data    (tx_buffer[char_idx]),
    .tx_data_vld(start_send),
    .ready      (tx_done),
    .tx         (tx)
);

uart_rx
#(
    .CLOCK      (SYS_CLK_FREQ),
    .BAUD       (BAUD_RATE),
    .CHECK_BIT  (CHECK_BIT)
)uart_rx_list(
    .clk        (clk),
    .rst        (rst),
    .rx_data    (rx_data),
    .rx_data_vld(rx_done),
    .rx         (rx)
);

//复位时,tx_done = 1; 当前字符发送完成标志:tx_done从低电平切换到高电平
//->判断当前字符是否发送完成->需要判断tx_done的上升沿
always @(posedge clk or negedge rst) begin
    if(!rst) begin
        tx_done0 <= 0;
        tx_done1 <= 0;
    end else begin
        tx_done0 <= tx_done;
        tx_done1 <= tx_done0;
    end
end

assign send_next = ~tx_done1 && tx_done0;

always @(posedge clk or negedge rst) begin
    if(!rst)begin
        start_send_char <= 0;
    end else begin
        if(key_value == 4'b0001)begin
            start_send_char <= 1;
        end else begin
            start_send_char <= 0;
        end
    end
end

assign start_send = start_send_char || start_send_status;

always @(posedge clk or negedge rst) begin
    if(!rst)begin
        char_idx <= 0;
        start_send_status <= 0;
    end else begin
        if(start_send)begin
            if(char_idx < UART_LEN - 1 && rx_status == 0)begin
                start_send_status <= 1;
                if(send_next)begin
                    char_idx <= char_idx + 1;
                end
            end else begin
                start_send_status <= 0;
            end
        end else
            char_idx <= 0;
    end
end

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        rx_done0 <= 0;
        rx_done1 <= 0;
    end else begin
        rx_done0 <= rx_done;
        rx_done1 <= rx_done0;
    end
end

//检测上升沿
assign rx_next = ~rx_done1 && rx_done0;

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        rxcnt <= 0;
        rx_status <= 0;
    end else begin
        if(rxcnt < UART_LEN)begin
            rx_status <= 1;
            if(rx_next)begin
                tx_buffer[rxcnt] <= rx_data;
                rxcnt <= rxcnt + 1;
            end else begin
                rx_status <= 0;
            end
        end else begin
            rxcnt <= 0;
        end
    end        
end

assign rxover = rx_status;

endmodule