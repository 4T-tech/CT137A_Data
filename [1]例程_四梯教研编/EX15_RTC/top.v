module top (
    input  wire                         sys_clk                     ,
    input  wire                         sys_rst                     ,
//RTC器件端口
    output wire                         ds1302_sclk                 ,//RTC器件 时钟	
    output wire                         ds1302_ce                   ,//RTC器件 使能
    inout  wire                         ds1302_io                   ,//RTC器件 数据端口
//数码管端口
    output wire        [   7: 0]        sel                         ,
    output wire        [   7: 0]        seg                
);

wire                      [   7: 0]        read_second              ;//读取 秒
wire                      [   7: 0]        read_minute              ;//读取 分
wire                      [   7: 0]        read_hour                ;//读取 时
wire                      [   7: 0]        read_date                ;//读取 天
wire                      [   7: 0]        read_month               ;//读取 月
wire                      [   7: 0]        read_week                ;//读取 周
wire                      [   7: 0]        read_year                ;//读取 年

//seg
seg seg_inst(
    .seg_clk                            (sys_clk                                         ),
    .seg_rst                            (sys_rst                                         ),
    .dsp_data                           ({read_hour,4'd10,read_minute,4'd10,read_second} ),
    .seg                                (seg                                             ),
    .sel                                (sel                                             ) 
);


ds1302_test ds1302_test_inst(
    .ds1302_clk                         (sys_clk                 ),
    .ds1302_rst                         (sys_rst                 ),
    .read_second                        (read_second             ),
    .read_minute                        (read_minute             ),
    .read_hour                          (read_hour               ),
    .read_date                          (read_date               ),
    .read_month                         (read_month              ),
    .read_week                          (read_week               ),
    .read_year                          (read_year               ),
    .ds1302_ce                          (ds1302_ce               ),// DS1302 复位引脚
    .ds1302_sclk                        (ds1302_sclk             ),// DS1302 时钟引脚
    .ds1302_io                          (ds1302_io               ) // DS1302 双向数据引脚
);

endmodule 
