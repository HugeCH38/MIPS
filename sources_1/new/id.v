`timescale 1ns / 1ps

// Instrument Decoder ָ��������
module id(input [31:0] instrument, // 32 λ������ʽָ��
            output reg [5:0] opcode, // MIPS ָ������
            output reg [5:0] func, // MIPS ָ�����
            output reg [4:0] rs, // rs �Ĵ�����ַ
            output reg [4:0] rt, // rt �Ĵ�����ַ
            output reg [4:0] rd, // rd �Ĵ�����ַ
            output reg [4:0] sa, // shamt �Ĵ�����ַ
            output reg [15:0] immediate, // ������
            output reg [25:0] address); // ��תָ���ַ
    always @(*)
    begin
        opcode <= instrument[31:26];
        rs <= 5'b00000;
        rt <= 5'b00000;
        rd <= 5'b00000;
        sa <= 5'b00000;
        immediate <= 15'b0;
        address <= 25'b0;
        case(opcode)
            // R ����ָ�
            6'b000000: // add / sub / and / or / xor / sll / srl / sra / jr
            begin
                rs <= instrument[25:21];
                rt <= instrument[20:16];
                rd <= instrument[15:11];
                sa <= instrument[10:6];
                func <= instrument[5:0];
            end
            // I ����ָ�
            6'b001000, // addi
            6'b001100, // andi
            6'b001101, // ori
            6'b001110, // xori
            6'b100011, // lw
            6'b101011, // sw
            6'b000100, // beq
            6'b000101, // bne
            6'b001111: // lui
            begin
                rs <= instrument[25:21];
                rt <= instrument[20:16];
                immediate <= instrument[15:0];
            end
            // J ����ָ�
            6'b000010, // j
            6'b000011: // jal
            begin
                address <= instrument[25:0];
            end
            default:
            begin
                rs <= 5'b00000;
            end
        endcase
    end
endmodule
