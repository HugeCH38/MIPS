`timescale 1ns / 1ps

module IOManager(input clk, // 时钟信号
                    input ce, // 读取使能端 / 输出控制
                    input we, // 写入使能端 / 输入控制
                    input [5:0] addr, // 地址，0xxxxx 为内存地址，1xxxxx 为开关或 led 地址
                    input [3:0] switch, // 从开关读取的数据
                    input [31:0] din, // 输入数据 (需要写入到内存或输出到 led 的数据)
                    output [31:0] dout, // 输出数据 (从内存或开关读取的数据)
                    output reg [31:0] displaydata); // 输出到 led 的数据
    wire ramCE; // 内存读取使能端
    wire ramWE; // 内存写入使能端
    wire [31:0] ramdout; // 从内存读取的数据
    
    assign ramCE = ce & (~addr[5]); // ce = 1 时，addr = 0xxxxx 则从内存读取数据，否则从开关读取数据
    assign ramWE = we & (~addr[5]); // we = 1 时，addr = 0xxxxx 则输出到内存，否则输出到 led
    
    // 实例化 RAM 存储器 (Random Access Memory)
    ram myram(.clk(clk), .ce(ramCE), .we(ramWE),
                .addr(addr[4:0]), .rdata(din), .wdata(ramdout));
    
    // addr = 1xxxxx 则读取开关的数据，否则读取内存的数据
    assign dout = addr[5] ? {{28{1'b0}}, switch} : ramdout;
    
    always @(posedge clk)
    begin
        if (addr[5] && we) // addr = 1xxxxx 则输出到 led
        begin
            displaydata <= din;
        end
    end
endmodule
