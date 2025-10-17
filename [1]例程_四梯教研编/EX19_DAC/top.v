module top(
    input  wire                         sys_clk                 ,
    input  wire                         sys_rst                 ,
    output wire                         iic_scl                 ,
    inout  wire                         iic_sda                  
);

dac 
#(
    .SYS_CLK                          (28'd50_000_000            ),
    .DAC_SCL                          (28'd100_000               ),
    .DEVICE_ADDR                      (7 'b1001_100              ) 
)dac_inst(
    .dac_clk                          (sys_clk                   ),
    .dac_rst                          (sys_rst                   ),
    .dac_start                        (1'b1                      ),// 开启写入DAC操作
    .iic_scl                          (iic_scl                   ),
    .iic_sda                          (iic_sda                   ) 
);

endmodule
