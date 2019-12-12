`timescale 1ns / 1ps

// 寄存器堆
module regfile(input clk, input oc, // 时钟信号和输出控制
                input [4:0] raddr1, output reg [31:0] rdata1, // 读端口 1
                    input [4:0] raddr2, output reg [31:0] rdata2, // 读端口 2
                        input we, input [4:0] waddr, input [31:0] wdata); // 写端口
    reg [31:0] registers [0:31]; // 32 个 32 bit 的寄存器
    
    // 读操作 1：
    always@(*)
    begin
        if(oc == 1'b1) // 禁止输出
        begin
            rdata1 <= 32'bz; // 高阻态
        end
        else if(raddr1 == 5'b00000) // 0 号寄存器的值固定为 32'b0
        begin
            rdata1 <= 32'b0;
        end
        else if((raddr1 == waddr) && (we == 1'b1))
            // 如果端口 1 读地址正好是写地址，则返回写数据
        begin
            rdata1 <= wdata;
        end
        else
        begin
            rdata1 <= registers[raddr1];
        end
    end
    
    // 读操作 2：
    always@(*)
    begin
        if(oc == 1'b1) // 禁止输出
        begin
            rdata2 <= 32'bz; // 高阻态
        end
        else if(raddr2 == 5'b00000) // 0 号寄存器的值固定为 32'b0
        begin
            rdata2 <= 32'b0;
        end
        else if((raddr2 == waddr) && (we == 1'b1))
            // 如果端口 2 读地址正好是写地址，则返回写数据
        begin
            rdata2 <= wdata;
        end
        else
        begin
            rdata2 <= registers[raddr2];
        end
    end
    
    // 写操作：
    always@(posedge clk)
    begin
        if((we == 1'b1) && (waddr != 5'b00000)) // 有写信号，且写地址不为 0 号寄存器地址
        begin
            registers[waddr] <= wdata;
            $monitor($time,, "write %d to R %d", wdata, waddr);
        end
    end
endmodule
