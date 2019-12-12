`timescale 1ns / 1ps

// 4 路数据选择器
module mux4(input [31:0] in0, input [31:0] in1, input [31:0] in2, input [31:0] in3,
            input [1:0] select, output reg [31:0] out);
    always @(*)
    begin
        case(select)
            2'b00: out <= in0;
            2'b01: out <= in1;
            2'b10: out <= in2;
            2'b11: out <= in3;
            default: out <= in0;
        endcase
    end
endmodule
