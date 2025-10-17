module dac
#(
    parameter                           SYS_CLK         = 28'd50_000_000           ,  //系统时钟频率
    parameter                           DAC_SCL         = 28'd100_000              ,  //ADC SCL时钟频率 
    parameter                           DEVICE_ADDR     = 7 'b1001_100                //IIC从机设备 器件地址
)
(
    input                               dac_clk                                    ,
    input                               dac_rst                                    ,
    input                               dac_start                                  , //开启写入DAC操作 
    output                              iic_scl                                    ,
    inout                               iic_sda                             
);

    reg                [  27: 0]        breath_cnt                                 ;
    reg                [   7: 0]        dac_data                                   ;

    wire               [   7: 0]        dac_data_high                              ;
    wire               [   7: 0]        dac_data_low                               ;

    assign                              dac_data_high     = {4'b0000,dac_data[7:4]};
    assign                              dac_data_low      = {dac_data[3:0],4'b0000};

always@(posedge dac_clk or negedge dac_rst)begin
    if(!dac_rst)
        breath_cnt <= 'd1; 
    else if(breath_cnt == 'd1_000_000)    
        breath_cnt <= 'd0;
    else 
        breath_cnt <= breath_cnt + 1'b1;
end

always@(posedge dac_clk or negedge dac_rst)begin
    if(!dac_rst)
        dac_data <= 'd0; 
    else if((breath_cnt == 'd1_000_000) && (dac_data < 8'h70))     
        dac_data <= 8'h70;
    else if(breath_cnt == 'd1_000_000)
        dac_data <= dac_data + 1'b1;
    else
        dac_data <= dac_data;
end

iic_drive#(
    .SYS_CLK                         (SYS_CLK                     ),
    .IIC_SCL                         (DAC_SCL                     ),
    .DEVICE_ADDR                     (DEVICE_ADDR                 ),
    .ADDR_BYTE_NUM                   (8'd0                        ), //这个DAC的IIC传输过程中不需要传输数据地址 
    .DATA_BYTE_NUM                   (8'd2                        )  
)
iic_drive_inst(
    .iic_clk                         (dac_clk                     ),
    .iic_rst                         (dac_rst                     ),
//IIC传输启动
    .iic_start                       (dac_start                   ),// 读写操作开始信号    0:     1:开始
    .iic_ready                       (                            ),// 设备忙、闲指示信号  0:繁忙  1:空闲
    .iic_rw_flag                     ('d0                         ),// 读写标志信号       0:写    1：读
//IIC写数据
    .iic_word_addr                   (8'h00                       ),// 读写的数据地址
    .iic_wdata                       ({dac_data_high,dac_data_low}),// 写的数据 (先写高字节数据 再写高位数据)
//IIC读数据
    .iic_rdata                       (                            ),// 读的数据 (先读高字节数据 再读高位数据)
    .iic_rdata_valid                 (                            ),// 读数据有效信号 高电平有效
//IIC操作失败
    .iic_ack_error                   (                            ),// 应答失败信号       0:应答正常 1:应答失败
//IIC物理IO
    .iic_scl                         (iic_scl                     ),// IIC SCL
    .iic_sda                         (iic_sda                     ) // IIC SDA
);

endmodule 