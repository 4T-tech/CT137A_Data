module uart_rx 
#(
    parameter       CLOCK = 26'd50_000_000,
    parameter       BAUD = 9600,
    parameter       CHECK_BIT = "None"
)
(
    input   wire    clk,        
    input   wire    rst,  
    input   wire    rx,  
    output  wire    rx_data_vld,     
    output  [7:0]   rx_data
);

localparam  MAX_1bit = CLOCK/BAUD;

localparam  IDLE     = 4'b0001,
            START    = 4'b0010,
            DATA     = 4'b0100,
            CHECK    = 4'b1000;

reg     [4:0]   cstate;
reg     [4:0]   nstate;

wire IDLE_START;
wire START_DATA;
wire DATA_IDLE;
wire DATA_CHECK;
wire CHECK_IDLE;

reg [19:0]  cnt_baud;
wire        add_cnt_baud;
wire        end_cnt_baud;

reg [2:0]   cnt_bit;
wire        add_cnt_bit;
wire        end_cnt_bit;

reg [3:0]   bit_max;

reg [7:0]   rx_temp;
reg         rx_check;
wire        check_val;

reg         rx_r1;
reg         rx_r2;
wire         rx_nege;

always @(posedge clk or negedge rst) begin
    if(!rst)begin
        rx_r1 <= 1;
        rx_r2 <= 1;
    end else begin
        rx_r1 <= rx;
        rx_r2 <= rx_r1;
    end
end

assign rx_nege = ~rx_r1 && rx_r2;

always @(posedge clk or negedge rst) begin
    if(!rst)
        cnt_baud <= 0;
    else begin
        if(add_cnt_baud)begin
            if(end_cnt_baud)begin
                cnt_baud <= 0;
            end else
                cnt_baud <= cnt_baud + 1;
        end
    end
end

assign add_cnt_baud = cstate != IDLE;
assign end_cnt_baud = add_cnt_baud && cnt_baud == MAX_1bit - 1;

always @(posedge clk or negedge rst) begin
    if(!rst)
        cnt_bit <= 0;
    else begin
        if(add_cnt_bit)begin
            if(end_cnt_bit)begin
                cnt_bit <= 0;
            end else
                cnt_bit <= cnt_bit + 1;
        end
    end
end

assign add_cnt_bit = end_cnt_baud;
assign end_cnt_bit = add_cnt_bit && cnt_bit == bit_max - 1;

always @(*) begin
    case (cstate)
        IDLE:    bit_max = 'd0;
        START:   bit_max = 'd1;
        DATA:    bit_max = 'd8;
        CHECK:   bit_max = 'd1;
        default: bit_max = 'd0;
    endcase
end

assign IDLE_START = (cstate == IDLE) && rx_nege;
assign START_DATA = (cstate == START) && end_cnt_bit;
assign DATA_IDLE = (cstate == DATA) && end_cnt_bit && (CHECK_BIT == "None");
assign DATA_CHECK = (cstate == DATA) && end_cnt_bit;
assign CHECK_IDLE = (cstate == CHECK) && end_cnt_bit;

always @(posedge clk or negedge rst) begin
    if(!rst)begin
        cstate <= IDLE;
    end else
        cstate <= nstate;
end

always @(*) begin
    case (cstate)
        IDLE : begin if(IDLE_START)nstate = START;else nstate = cstate;end 
        START: begin if(START_DATA)nstate = DATA;else nstate = cstate;end 
        DATA: begin if(DATA_IDLE)nstate = IDLE;else if(DATA_CHECK)nstate = CHECK;else nstate = cstate;end
        CHECK: begin if(CHECK_IDLE)nstate = IDLE;else nstate = cstate;end
        default: nstate = IDLE;
    endcase
end

always @(posedge clk or negedge rst) begin
    if(!rst)begin
        rx_temp <= 0;
    end else begin
        if(cstate == DATA && cnt_baud == MAX_1bit >> 1)begin
            rx_temp[cnt_bit] <= rx_r1;
        end else
            rx_temp <= rx_temp;
    end
end

assign rx_data = rx_temp;

always @(posedge clk or negedge rst) begin
    if(!rst)begin
        rx_check <= 0;
    end else begin
        if(cstate == CHECK && cnt_baud == MAX_1bit >> 1)begin
            rx_check <= rx_r1;
        end 
    end
end

assign checkc_val = (CHECK_BIT == "Odd") ? ~^rx_temp : ^rx_temp;

assign rx_data_vld = (CHECK_BIT == "None") ? DATA_IDLE
                        :(CHECK_IDLE && (check_val == rx_check))?1
                        :0;

endmodule