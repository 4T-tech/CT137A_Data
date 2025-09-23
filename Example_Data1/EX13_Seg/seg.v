module seg(
    input   wire            clk     ,
    input   wire            rst     ,
    output  reg     [7:0]   seg     ,
    output  reg     [7:0]   sel
);

//seg code
localparam  [7:0]   DIGIT0 = 8'hC0  ;
localparam  [7:0]   DIGIT1 = 8'hF9  ;
localparam  [7:0]   DIGIT2 = 8'hA4  ;
localparam  [7:0]   DIGIT3 = 8'hB0  ;
localparam  [7:0]   DIGIT4 = 8'h99  ;
localparam  [7:0]   DIGIT5 = 8'h92  ;
localparam  [7:0]   DIGIT6 = 8'h82  ;
localparam  [7:0]   DIGIT7 = 8'hF8  ;
localparam  [7:0]   DIGIT8 = 8'h80  ;
localparam  [7:0]   DIGIT9 = 8'h90  ;

localparam          DSP_COUNT = 20'd50000			;
reg         [19:0]  dsp_count               		;
reg         [3:0]   bits                            ;

//1ms counter
always @(posedge clk or negedge rst) begin
    if(!rst) 
        dsp_count <= 20'd0;
    else begin
        if(dsp_count == DSP_COUNT - 1) begin
            dsp_count <= 20'd0;
        end
        else
            dsp_count <= dsp_count + 20'd1;
    end
end


//dynamic display
always @(posedge clk or negedge rst) begin
    if(!rst) begin
        seg  <= 8'b1111_1111;
        sel  <= 8'b1111_1111;
    end else begin
        if(dsp_count == DSP_COUNT - 1) begin
            if(bits == 4'd8)
                bits <= 4'd0;
            else
                bits <= bits + 4'd1;
            case(bits)
                4'd0:   begin	sel <= 8'b1111_1110;   seg <= DIGIT0;  end
                4'd1:   begin	sel <= 8'b1111_1101;   seg <= DIGIT1;  end  
                4'd2:   begin	sel <= 8'b1111_1011;   seg <= DIGIT2;  end
                4'd3:   begin	sel <= 8'b1111_0111;   seg <= DIGIT3;  end
                4'd4:   begin	sel <= 8'b1110_1111;   seg <= DIGIT4;  end
                4'd5:   begin	sel <= 8'b1101_1111;   seg <= DIGIT5;  end
                4'd6:   begin	sel <= 8'b1011_1111;   seg <= DIGIT6;  end
                4'd7:   begin	sel <= 8'b0111_1111;   seg <= DIGIT7;  end
            endcase
        end
    end      
end

endmodule