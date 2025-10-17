module KEY_LED (
    input   wire    clk,
    input   wire    rst,
    input   wire    [3:0]   key_in,

    output reg      [7:0]   led
);

parameter MS_MAX = 20'd500_000;

parameter key_val_S1 = 4'b0001;
parameter key_val_S2 = 4'b0010;
parameter key_val_S3 = 4'b0100;
parameter key_val_S4 = 4'b1000;
parameter key_val_NONE = 4'b1111;

parameter IDLE = 0;
parameter PRESS = 1;
parameter RELESE = 2;

reg [19:0]  key_count;
reg [3:0]  key_value;
reg [2:0]  key_status;

always @(posedge clk or negedge rst) begin
    if(!rst)
        key_count <= 0;
    else begin
        if(key_count == MS_MAX - 1)
            key_count <= 0;
        else
            key_count = key_count + 1;
    end 
end

always @(posedge clk or negedge rst) begin
    if(!rst)begin
        key_value <= key_val_NONE;
        key_status <= IDLE;
    end else begin
        if(key_value == key_val_NONE)begin
            if(key_count == MS_MAX - 1)begin
                if(key_status == IDLE)begin
                    if(key_in != 4'b1111)
                        key_status <= PRESS;
                end else if(key_status == PRESS)begin
                    case (key_in)
                        4'b1110:begin key_value <= key_val_S1;key_status <= RELESE;end
                        4'b1101:begin key_value <= key_val_S2;key_status <= RELESE;end
                        4'b1011:begin key_value <= key_val_S3;key_status <= RELESE;end
                        4'b0111:begin key_value <= key_val_S4;key_status <= RELESE;end 
                        default:begin key_value <= key_val_NONE;key_status <= IDLE;end
                    endcase
                end else begin
                    if(key_in == 4'b1111)
                        key_status <= IDLE;
                end
            end
        end else
            key_value <= key_val_NONE;
    end
end

always @(posedge clk or negedge rst) begin
    if(!rst)
        led <= 8'b1111_1111;
    else 
        case (key_value)
            key_val_S1:led <= 8'b0111_1110; 
            key_val_S2:led <= 8'b1011_1101; 
            key_val_S3:led <= 8'b1101_1011; 
            key_val_S4:led <= 8'b1110_0111; 
           
        endcase
end
    
endmodule