`timescale 1ns / 1ps

// Arithmetic Logic Unit �����߼���Ԫ
module alu(input [31:0] a, input [31:0] b, input [3:0] op, output reg [31:0] f, output z);
    parameter A_NOP = 4'b0000; // ���㣬������
    parameter A_ADD = 4'b0001; // �ӷ�����
    parameter A_SUB = 4'b0010; // ��������
    parameter A_AND = 4'b0011; // ������
    parameter A_OR = 4'b0100; // ������
    parameter A_XOR = 4'b0101; // �������
    parameter A_SLL = 4'b0110; // sll
    parameter A_SRL = 4'b0111; // srl
    parameter A_SRA = 4'b1000; // sra
    parameter A_LUI = 4'b1001; // lui
    
    // wire [31:0] alu_out [3:0];
    
    // assign alu_out[A_NOP] = 32'b0; // ���㣬������
    // assign alu_out[A_ADD] = a + b; // �ӷ�����
    // assign alu_out[A_SUB] = a - b; // ��������
    // assign alu_out[A_AND] = a & b; // ������
    // assign alu_out[A_OR] = a | b; // ������
    // assign alu_out[A_XOR] = a ^ b; // �������
    
    // assign f = alu_out[op]; // ���� op ��ֵѡ������һ������Ľ��
    
    always @(*)
    begin
        case(op)
            A_NOP: f <= 32'b0; // ���㣬������
            A_ADD: f <= a + b; // �ӷ�����
            A_SUB: f <= a - b; // ��������
            A_AND: f <= a & b; // ������
            A_OR: f <= a | b; // ������
            A_XOR: f <= a ^ b; // �������
            A_SLL: f <= b << a; // sll
            A_SRL: f <= b >> a; // srl
            A_SRA: f <= b >>> a; // sra
            A_LUI: f <= {b[15:0], 16'b0}; // lui
            default: f <= 32'b0;
        endcase
    end
    
    assign z = ~(|f); // f == 0���� z = 1
endmodule
