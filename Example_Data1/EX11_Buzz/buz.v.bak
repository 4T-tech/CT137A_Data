module buzz(
    input       wire            clk,
    input       wire            rst,
    output      reg             buz
);

//1.25KHz
parameter   SIG_MAX = 16'd40000;
reg     [15:0]  count;

//
always@(posedge clk or posedge rst) begin
    if(rst)
        count <= 16'd0;
    else begin
        if (count == SIG_MAX)
            count <= 16'd0;
        else
            count <= count + 16'd1;
    end
end

//
always@(posedge clk or posedge rst) begin
    if(rst)
        buz <= 0;
    else begin
        //50% duty cycle
        if (count >= (SIG_MAX >> 1'b1))
            buz <= 1'b1;
        else
            buz <= 1'b0;
    end
end

endmodule