`timescale 1ns / 1ps

// RAM 存储器
module ram(input clk, input ce, input we, // 时钟信号、输出控制、输入控制
                input [4:0] addr, // 地址
                output reg [31:0] rdata, input [31:0] wdata); //读端口、写端口
    reg [31:0] ramunit [0:31]; // 32 个 32 bit 的内存单元
    
    // 读操作：
    always@(*)
    begin
        if(ce == 1'b0) // 禁止输出
        begin
            rdata <= 32'bz; // 高阻态
        end
        else if(we == 1'b1) // 如果有读信号的同时有写信号，则返回写数据
        begin
            rdata <= wdata;
        end
        else
        begin
            rdata <= ramunit[addr];
        end
    end

    // 写操作：
    always@(posedge clk)
    begin
        if(we == 1'b1) // 有写信号
        begin
            ramunit[addr] <= wdata;
        end
    end
endmodule
