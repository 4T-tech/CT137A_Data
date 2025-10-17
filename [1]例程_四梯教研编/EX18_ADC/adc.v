module adc
#(
    parameter                           SYS_CLK         = 28'd50_000_000  ,  //系统时钟频率
    parameter                           ADC_SCL         = 28'd125_000     ,  //ADC SCL时钟频率 
    parameter                           DEVICE_ADDR     = 7 'b1010_100       //IIC从机设备 器件地址
)
(
    input                               adc_clk                            ,
    input                               adc_rst                            ,

    input                               adc_start                          , //开启读取ADC操作 强制置1就一直读 

    output reg         [  31: 0]        dsp_data                           , //从ADC读出的数据转换给 数码显示用的数据
        
    output                              iic_scl                            ,
    inout                               iic_sda                           
);


//ADC采集数据处理 用于送入数码管正常显示
wire               [   7: 0]        adc_data                               ;//ADC中读取到的原始值
reg                [  11: 0]        adc_bcd                                ;//ADC数值转换 中间寄存器

//IIC底层驱动 从ADC读出的数据
wire               [  15: 0]        iic_rdata                              ;//
wire                                iic_rdata_valid                        ;
reg                [  15: 0]        iic_rdata_reg                          ;



//寄存冲ADC读出的数据
always@(posedge adc_clk or negedge adc_rst)begin
    if(!adc_rst)
        iic_rdata_reg <= 'd0; 
    else if(iic_rdata_valid)   
        iic_rdata_reg <= iic_rdata;
    else 
        iic_rdata_reg <= iic_rdata_reg;
end

assign adc_data = {iic_rdata_reg[11:8],iic_rdata_reg[7:4]}; //从ADC两字节的数据 提取一字节的ADC值（具体见数据手册）


//对ADC中读取的8bit数值进行装换 到 数码管能正常显示的数据 
always@(posedge adc_clk or negedge adc_rst)begin
    if(!adc_rst) begin
        dsp_data <= {4'd10,4'd10,4'd10,4'd10,4'd10,4'd10,4'd10,4'd10};
    end 
	else if(adc_data < 10)
		dsp_data <= {4'd10,4'd10,4'd10,4'd10,4'd10,4'd10,4'd10,adc_data[3:0]};
	else if(adc_data >= 10 && adc_data <100)begin
		adc_bcd[7:4] <= adc_data / 10;
		adc_bcd[3:0] <= adc_data % 10;
		dsp_data <= {4'd10,4'd10,4'd10,4'd10,4'd10,4'd10,adc_bcd[7:4], adc_bcd[3:0]};
	end
	else begin
		adc_bcd[11:8] <= adc_data / 100   ;
		adc_bcd[ 7:4] <= adc_data % 100/10;
		adc_bcd[ 3:0] <= adc_data % 10    ;
		dsp_data <= {4'd10,4'd10,4'd10,4'd10,4'd10,adc_bcd[11:8],adc_bcd[7:4], adc_bcd[3:0]};
	end
end


iic_drive#(
    .SYS_CLK                          (SYS_CLK                 ),
    .IIC_SCL                          (ADC_SCL                 ),
    .DEVICE_ADDR                      (DEVICE_ADDR             ),
    .ADDR_BYTE_NUM                    (8'd2                    ),
    .DATA_BYTE_NUM                    (8'd2                    )  
)
iic_drive_inst(
    .iic_clk                          (adc_clk                 ),
    .iic_rst                          (adc_rst                 ),
//IIC传输启动
    .iic_start                        (adc_start               ),// 读写操作开始信号    0:     1:开始
    .iic_ready                        (                        ),// 设备忙、闲指示信号  0:繁忙  1:空闲
    .iic_rw_flag                      ('d1                     ),// 读写标志信号       0:写    1：读
//IIC写数据
    .iic_word_addr                    (8'h0                    ),// 读写的数据地址
    .iic_wdata                        (                        ),// 写的数据 (先写高字节数据 再写高位数据)
//IIC读数据
    .iic_rdata                        (iic_rdata               ),// 读的数据 (先读高字节数据 再读高位数据)
    .iic_rdata_valid                  (iic_rdata_valid         ),// 读数据有效信号 高电平有效
//IIC操作失败
    .iic_ack_error                    (                        ),// 应答失败信号       0:应答正常 1:应答失败
//IIC物理IO
    .iic_scl                          (iic_scl                 ),// IIC SCL
    .iic_sda                          (iic_sda                 ) // IIC SDA
);

endmodule 