`timescale 1ns/1ns
module  tb_iic_drive();
//时钟、复位信号

localparam ADDR_BYTE_NUM = 2;
localparam DATA_BYTE_NUM = 1;

reg                                          iic_clk                 ;
reg                                          iic_rst                 ;
reg                                          iic_start               ;
wire                                         iic_ready               ;  //模块空闲、繁忙 指示信号
reg                                          iic_rw_flag             ;
reg               [ADDR_BYTE_NUM*8 -1 :0]    iic_word_addr           ;  //
reg               [DATA_BYTE_NUM*8 -1 :0]    iic_wdata               ;
wire              [DATA_BYTE_NUM*8 -1 :0]    iic_rdata               ;
wire                                         iic_rdata_valid         ;
wire                                         iic_ack_error           ;
wire                                         iic_scl                 ;
wire                                         iic_sda                 ;

always  #10 iic_clk = ~iic_clk;

pullup(iic_scl    );
pullup(iic_sda   );

initial
begin
    iic_clk      =   1'b1  ;
    iic_start    =   1'b0  ;

//复位
    iic_rst      =   1'b0  ;
    #222
    iic_rst      =   1'b1  ;
    #1000

//写数据操作
    iic_rw_flag  =   1'b0  ; //写数据操作
    iic_word_addr=   16'd1  ; //数据地址
    iic_wdata    =   16'h55; //写入的数据
    #500;

//开启传输
    iic_start    =   1'b1  ;
    #20;
    iic_start    =   1'b0  ;

    #350000; // (AT24C02 在完成一次写入操作（如 Byte Write 或 Page Write）后，需要等待 5ms 的写周期时间，才能开始下一次写入操作。)

/*
//读数据操作
    iic_rw_flag  =   1'b1  ; //读数据操作
    iic_word_addr=   8'd1  ; //数据地址
    #500;

//开启传输
    iic_start    =   1'b1  ;
    #20;
    iic_start    =   1'b0  ;
    #8000000;
*/


    $stop;
end

iic_drive#(
    .SYS_CLK      (28'd50_000_000 ), //系统时钟频率
    .IIC_SCL      (28'd125_000    ), //IIC SCL时钟频率 (400Khz频率)
    .DEVICE_ADDR  (7'b1010_000    ), //IIC从机设备 器件地址
    .ADDR_BYTE_NUM(ADDR_BYTE_NUM           ), //IIC从机设备 操作地址字节数
    .DATA_BYTE_NUM(DATA_BYTE_NUM           )  //IIC一次操作 需传输的字节数
)
u_iic_drive(
    .iic_clk                          (iic_clk                     ),
    .iic_rst                          (iic_rst                     ),
    //IIC传输启动
    .iic_start                        (iic_start                   ),// 读写操作开始信号   1:开始
    .iic_ready                        (iic_ready                   ),// 设备忙工作指示信号，0：繁忙 1：空闲
    .iic_rw_flag                      (iic_rw_flag                 ),// 读写标志信号 1：读 0：写
    //IIC写数据
    .iic_word_addr                    (iic_word_addr               ),// 读写的数据地址
    .iic_wdata                        (iic_wdata                   ),// 写的数据         先写高字节数据 再写高位数据
    //IIC读数据
    .iic_rdata                        (iic_rdata                   ),// 读的数据
    .iic_rdata_valid                  (iic_rdata_valid             ),// 读数据有效信号 高电平有效
    //IIC操作失败
    .iic_ack_error                    (iic_ack_error               ),// 应答失败信号 1：应答失败
    //IIC物理IO
    .iic_scl                          (iic_scl                     ),// IIC SCL
    .iic_sda                          (iic_sda                     )// IIC SDA
);


//-------------eeprom_byte_rd_wr_inst-------------


//-------------eeprom_inst-------------
M24LC64  M24lc64_inst
(
    .A0     (1'b0       ),  //器件地址
    .A1     (1'b0       ),  //器件地址
    .A2     (1'b0       ),  //器件地址
    .WP     (1'b0       ),  //写保护信号,高电平有效
    .RESET  (~iic_rst   ),  //复位信号,高电平有效

    .SDA    (iic_sda    ),  //串行数据
    .SCL    (iic_scl    )  //串行时钟
);

endmodule


