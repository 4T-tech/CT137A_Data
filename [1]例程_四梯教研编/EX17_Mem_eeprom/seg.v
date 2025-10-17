module seg (
    input   wire    seg_clk,
    input   wire    seg_rst,
    input   wire    [31:0] dsp_data,

    output  reg     [7:0]   seg,
    output  reg     [7:0]   sel
);

//段码值
parameter [7:0] DIGIT0 = 8'hC0;
parameter [7:0] DIGIT1 = 8'hF9;
parameter [7:0] DIGIT2 = 8'hA4;
parameter [7:0] DIGIT3 = 8'hB0;
parameter [7:0] DIGIT4 = 8'h99;
parameter [7:0] DIGIT5 = 8'h92;
parameter [7:0] DIGIT6 = 8'h82;
parameter [7:0] DIGIT7 = 8'hF8;
parameter [7:0] DIGIT8 = 8'h80;
parameter [7:0] DIGIT9 = 8'h90;
parameter [7:0] DIGIFF = 8'hFF;

parameter [15:0] COUNTER_MAX = 16'd50000;
reg [15:0] counter;
reg [3:0]  bits;
reg [3:0] bcd;

always @(posedge seg_clk or negedge seg_rst) begin
    if(!seg_rst)
       counter <= 0;
    else begin
        if(counter == COUNTER_MAX - 1)
            counter <= 0;
        else
            counter = counter + 1'b1;
    end   
end

always @(posedge seg_clk or negedge seg_rst) begin
    if(!seg_rst)begin
        bits <= 0;
        sel <= 8'b1111_1111;
    end else begin
        if(counter == COUNTER_MAX - 1)begin
            if(bits == 4'd8)
                bits <= 0;
            else
                bits <= bits + 1'b1;
            case (bits)
                4'd0:   begin   sel <= 8'b1111_1110;    bcd <= dsp_data[31:28];  end
                4'd1:   begin   sel <= 8'b1111_1101;    bcd <= dsp_data[27:24];  end
                4'd2:   begin   sel <= 8'b1111_1011;    bcd <= dsp_data[23:20];  end
                4'd3:   begin   sel <= 8'b1111_0111;    bcd <= dsp_data[19:16];  end
                4'd4:   begin   sel <= 8'b1110_1111;    bcd <= dsp_data[15:12];  end
                4'd5:   begin   sel <= 8'b1101_1111;    bcd <= dsp_data[11:8];  end
                4'd6:   begin   sel <= 8'b1011_1111;    bcd <= dsp_data[7:4];  end
                4'd7:   begin   sel <= 8'b0111_1111;    bcd <= dsp_data[3:0];  end
                default: 
                begin   sel <= 8'b1111_1111;     end
            endcase
        end
    end
end

always @(posedge seg_clk or negedge seg_rst) begin
    if(!seg_rst)
        seg <= DIGIFF;
    else
        case (bcd)
            0:   seg <= DIGIT0;
            1:   seg <= DIGIT1;
            2:   seg <= DIGIT2;
            3:   seg <= DIGIT3;
            4:   seg <= DIGIT4;
            5:   seg <= DIGIT5;
            6:   seg <= DIGIT6;
            7:   seg <= DIGIT7;
            8:   seg <= DIGIT8;
            9:   seg <= DIGIT9;
            default: seg <= DIGIFF;
        endcase
end
    
endmodule