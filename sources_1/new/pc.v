`timescale 1ns / 1ps

// Program Counter ³ÌÐò¼ÆÊýÆ÷
module pc(input clk, input rst, input [31:0] pcnext, output reg [31:0] pcaddr);
    always @(negedge clk)
    begin
        if(rst == 1'b0)
        begin
            pcaddr <= 32'h00000000;
        end
        else
        begin
            pcaddr <= pcnext;
        end
    end
endmodule
