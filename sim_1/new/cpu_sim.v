`timescale 1ns / 1ps

module cpu_sim(output [11:0] result); // 时钟信号仿真
    parameter clk_period = 10;
    reg clk = 1'b0;
    
    initial
    begin
        forever
        begin
            #(clk_period / 2) clk = ~clk;
        end
    end
    
    reg rst = 1'b0;
    
    initial
    begin
        #10 rst = 1'b1;
        #1000 $finish; // $finish 仿真结束
    end
    
    top mytop(.clk(clk), .rst(rst), .n(4'b1010), .result(result));
endmodule
