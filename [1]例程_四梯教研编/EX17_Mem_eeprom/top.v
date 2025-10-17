module top (
    input  wire                         sys_clk                  ,
    input  wire                         sys_rst                  ,

    input  wire        [   3: 0]        key_in                   ,

    output wire        [   7: 0]        seg                      ,
    output wire        [   7: 0]        sel                      ,

    output wire                         iic_scl                  ,
    inout  wire                         iic_sda                  
);

    localparam ADDR_BYTE_NUM = 'd1;
    localparam DATA_BYTE_NUM = 'd1;

//按键模块信号
    wire               [   3: 0]        key_value                 ;
    reg                [   7: 0]        cnt_key                   ;//按键控制的值

//数码管模块信号
    reg      [DATA_BYTE_NUM*8 -1 :0]    data_reg                  ;

//****************S1按键减数据 S2按键加数据 S3按键读出数据 S4按键写入数据****************************//

    reg                                        start                  ;
    wire                                       ready                  ;
    reg                                        rw_flag                ;
    reg      [DATA_BYTE_NUM*8 -1 :0]           wdata                  ;
    wire     [DATA_BYTE_NUM*8 -1 :0]           rdata                  ;
    wire                                       rdata_valid            ;
    wire                                       ack_error              ;

    always @(posedge sys_clk or negedge sys_rst) begin
        if(!sys_rst)
            cnt_key <= 8'h00;
        else 
        if((key_value == 4'b0100) && (cnt_key == 'd9))
            cnt_key <= 8'd0;
        else if((key_value == 4'b1000) && (cnt_key == 'd0))
            cnt_key <= 8'd9;       
        else if(key_value == 4'b0100)
            cnt_key <= cnt_key + 1'b1;
        else if(key_value == 4'b1000)
            cnt_key <= cnt_key - 1'b1; 
        else 
            cnt_key <= cnt_key;
    end

    //确认读写操作
    always @(posedge sys_clk or negedge sys_rst) begin
        if(!sys_rst)
            rw_flag <= 1'b0;
        else if((ready == 1'b1) && (key_value == 4'b0001))
            rw_flag <= 1'b0; //写
        else if((ready == 1'b1) && (key_value == 4'b0010))
            rw_flag <= 1'b1; //读
        else 
            rw_flag <= rw_flag;
    end

    //开启读写操作
    always @(posedge sys_clk or negedge sys_rst) begin
        if(!sys_rst)
            start <= 1'b0;
        else if((ready == 1'b1) && ((key_value == 4'b0010)||(key_value == 4'b0001)))
            start <= 1'b1;
        else 
            start <= 1'b0;
    end

    //从EEPROM中读取的数据 寄存一下 送给数码管显示用
    always @(posedge sys_clk or negedge sys_rst) begin
        if(!sys_rst)
            data_reg <= 'd0;
        else if(rdata_valid)
            data_reg <= rdata;
        else 
            data_reg <= data_reg;
    end

//按键模块
key key_inst(
    .key_clk                            (sys_clk                   ),
    .key_rst                            (sys_rst                   ),
    .key_in                             (key_in                    ),
    .key_value                          (key_value                 )
);

iic_drive#(
    .SYS_CLK      (28'd50_000_000 ),
    .IIC_SCL      (28'd100_000    ),
    .DEVICE_ADDR  (7 'b1010_000   ),
    .ADDR_BYTE_NUM(ADDR_BYTE_NUM),
    .DATA_BYTE_NUM(DATA_BYTE_NUM)
)
iic_drive_inst(
    .iic_clk                              (sys_clk                 ),
    .iic_rst                              (sys_rst                 ),
    //IIC传输启动
    .iic_start                            (start                   ),       // 读写操作开始信号    0:     1:开始
    .iic_ready                            (ready                   ),       // 设备忙、闲指示信号  0:繁忙  1:空闲
    .iic_rw_flag                          (rw_flag                 ),       // 读写标志信号       0:写    1：读
    //IIC写数据
    .iic_word_addr                        ('d0                     ),       // 读写的数据地址
    .iic_wdata                            (cnt_key                 ),       // 写的数据 (先写高字节数据 再写高位数据)
    //IIC读数据
    .iic_rdata                            (rdata                   ),       // 读的数据 (先读高字节数据 再读高位数据)
    .iic_rdata_valid                      (rdata_valid             ),       // 读数据有效信号 高电平有效
    //IIC操作失败
    .iic_ack_error                        (ack_error               ),       // 应答失败信号       0:应答正常 1:应答失败
    //IIC物理IO
    .iic_scl                              (iic_scl                 ),       // IIC SCL
    .iic_sda                              (iic_sda                 )        // IIC SDA
);

//0-7 一位数码管有8种显示状态 -> 0-F 16种显示状态 -> 4位宽 
//-> 8个数码管 所以data位宽为32
seg seg_inst(
    .seg_clk                            (sys_clk                 ),
    .seg_rst                            (sys_rst                 ),
    .dsp_data                           ({4'd10,4'd10,4'd10,4'd10,cnt_key,data_reg}),
    .seg                                (seg                     ),
    .sel                                (sel                     ) 
);

endmodule