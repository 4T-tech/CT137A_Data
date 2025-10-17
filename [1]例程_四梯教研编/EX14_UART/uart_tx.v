module uart_tx 
#(
    parameter       CLOCK = 26'd50_000_000,
    parameter       BAUD = 9600,
    parameter       CHECK_BIT = "None"
)
(
    input   wire    clk,        
    input   wire    rst,      
    input   [7:0]   tx_data,    
    input   wire    tx_data_vld,
    output  wire    ready,     
    output  reg     tx
);

localparam  MAX_1bit = CLOCK/BAUD;

localparam  IDLE     = 5'b00001,
            START    = 5'b00010,
            DATA     = 5'b00100,
            CHECK    = 5'b01000,
            STOP     = 5'b10000;
reg     [4:0]   cstate;
reg     [4:0]   nstate;

wire        IDLE_START;
wire        START_DATA;
wire        DATA_CHECK;
wire        CHECK_STOP;
wire        STOP_IDLE;

reg [19:0]  cnt_baud;
wire        add_cnt_baud;
wire        end_cnt_baud;

reg [2:0]   cnt_bit;
wire        add_cnt_bit;
wire        end_cnt_bit;

reg [3:0]   bit_max;
reg [7:0]   tx_data_r;

wire        check_val;

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
        STOP:    bit_max = 'd1;
        default: bit_max = 'd0;
    endcase
end

assign IDLE_START = (cstate == IDLE) && tx_data_vld;
assign START_DATA = (cstate == START) && end_cnt_bit;
assign DATA_STOP = (cstate == DATA) && end_cnt_bit && (CHECK_BIT == "None");
assign DATA_CHECK = (cstate == DATA) && end_cnt_bit;
assign CHECK_STOP = (cstate == CHECK) && end_cnt_bit;
assign STOP_IDLE = (cstate == STOP) && end_cnt_bit;

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
        DATA: begin if(DATA_STOP)nstate = STOP;else if(DATA_CHECK)nstate = CHECK;else nstate = cstate;end
        CHECK: begin if(CHECK_STOP)nstate = STOP;else nstate = cstate;end
        STOP: begin if(STOP_IDLE)nstate = IDLE;else nstate = cstate;end
        default: nstate = cstate;
    endcase
end

always @(posedge clk or negedge rst) begin
    if(!rst)begin
        tx_data_r <= 0;
    end else begin
        if(tx_data_vld)
            tx_data_r <= tx_data;
        else
            tx_data_r <= tx_data_r;
    end
end
//奇校验:tx_data_r->1是奇数,checkc_val=0;checkc_val = 1;
//奇校验:10101010 ->1的格式:4位,10101010->0,checkc_val=1;
assign checkc_val = (CHECK_BIT == "Odd") ? ~^tx_data_r : ^tx_data_r;

always @(*) begin
    case (cstate)
        IDLE: tx = 1'b1;
        START: tx = 1'b0;
        DATA:tx = tx_data_r[cnt_bit];
        CHECK:tx = check_val;
        STOP:tx = 1'b1;  
        default: tx = 1'b1;
    endcase
end

assign ready = cstate == IDLE;

endmodule