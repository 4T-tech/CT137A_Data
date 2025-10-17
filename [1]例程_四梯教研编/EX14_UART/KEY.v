module KEY (
    input   wire    key_clk,
    input   wire    key_rst,
    input   wire    [3:0]   key_in,
    
    output reg      [3:0]   key_value
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
reg [2:0]  key_status;

always @(posedge key_clk or negedge key_rst) begin
    if(!key_rst)
        key_count <= 0;
    else begin
        if(key_count == MS_MAX - 1)
            key_count <= 0;
        else
            key_count = key_count + 1;
    end 
end

always @(posedge key_clk or negedge key_rst) begin
    if(!key_rst)begin
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
    
endmodule