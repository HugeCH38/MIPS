`timescale 1ns / 1ps

// Control Unit ���Ƶ�Ԫ
module cu(input [5:0] opcode, // MIPS ָ������
            input [5:0] func, // MIPS ָ�����
            input z, // �Ƿ�Ϊ 0 ��־
            output reg [1:0] pcsource, // pc ֵ����Դ
            output reg [3:0] aluOP, // alu ����������
            output reg regWE, // �Ƿ�д�Ĵ���
            output reg imm, // �Ƿ����������
            output reg shift, // �Ƿ���λ
            output reg isrt, // Ŀ�ļĴ�����ַ��=1 ��ѡ�� rt������ѡ�� rd
            output reg sign_ext, // ��������չ��=1 �������չ����������չ
            output reg jal, // �Ƿ�����ӳ�����ת
            output reg ce, // �Ƿ����ݴ��ڴ�/���ض��뵽�Ĵ�����
            output reg we); // �Ƿ�����д���ڴ� / led
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
    
    always @(*)
    begin
        // �����ú�Ĭ��ֵ
        pcsource <= 2'b00;
        aluOP <= 4'b0000;
        regWE <= 1'b0;
        imm <= 1'b0;
        shift <= 1'b0;
        isrt <= 1'b0;
        sign_ext <= 1'b0;
        jal <= 1'b0;
        ce <= 1'b0;
        we <= 1'b0;
        case(opcode)
            6'b000000: // add / sub / and / or / xor / sll / srl / sra / jr
            begin
                case(func)
                    6'b100000: // add��(rd) �� (rs) + (rt)
                    begin
                        aluOP <= A_ADD;
                        regWE <= 1'b1; // ��� f д�Ĵ���
                    end
                    6'b100010: // sub��(rd) �� (rs) - (rt)
                    begin
                        aluOP <= A_SUB;
                        regWE <= 1'b1; // ��� f д�Ĵ���
                    end
                    6'b100100: // and��(rd) �� (rs) AND (rt)
                    begin
                        aluOP <= A_AND;
                        regWE <= 1'b1; // ��� f д�Ĵ���
                    end
                    6'b100101: // or��(rd) �� (rs) OR (rt)
                    begin
                        aluOP <= A_OR;
                        regWE <= 1'b1; // ��� f д�Ĵ���
                    end
                    6'b100110: // xor��(rd) �� (rs) XOR (rt)
                    begin
                        aluOP <= A_XOR;
                        regWE <= 1'b1; // ��� f д�Ĵ���
                    end
                    6'b000000: // sll��(rd) �� (rt) << shamt
                    begin
                        aluOP <= A_SLL;
                        regWE <= 1'b1; // ��� f д�Ĵ���
                        shift <= 1'b1; // ��λ
                    end
                    6'b000010: // srl��(rd) �� (rt) >> shamt
                    begin
                        aluOP <= A_SRL;
                        regWE <= 1'b1; // ��� f д�Ĵ���
                        shift <= 1'b1; // ��λ
                    end
                    6'b000011: // sra��(rd) �� (rt) >> shamt (����λ�ƶ��ұ���)
                    begin
                        aluOP <= A_SRA;
                        regWE <= 1'b1; // ��� f д�Ĵ���
                        shift <= 1'b1; // ��λ
                    end
                    6'b001000: // jr
                    begin
                        pcsource <= 2'b10;
                    end
                endcase
            end
            6'b001000: // addi��(rt) �� (rs) + (Sign-Extend) immediate
            begin
                aluOP <= A_ADD;
                regWE <= 1'b1; // ��� f д�Ĵ���
                imm <= 1'b1; // ����������
                isrt <= 1'b1; // Ŀ�ļĴ�����ַѡ�� rt
                sign_ext <= 1'b1; // ���������з�����չ
            end
            6'b001100: // andi��(rt) �� (rs) AND (Zero-Extend) immediate
            begin
                aluOP <= A_AND;
                regWE <= 1'b1; // ��� f д�Ĵ���
                imm <= 1'b1; // ����������
                isrt <= 1'b1; // Ŀ�ļĴ�����ַѡ�� rt
            end
            6'b001101: // ori��(rt) �� (rs) OR (Zero-Extend) immediate
            begin
                aluOP <= A_OR;
                regWE <= 1'b1; // ��� f д�Ĵ���
                imm <= 1'b1; // ����������
                isrt <= 1'b1; // Ŀ�ļĴ�����ַѡ�� rt
            end
            6'b001110: // xori��(rt) �� (rs) XOR (Zero-Extend) immediate
            begin
                aluOP <= A_XOR;
                regWE <= 1'b1; // ��� f д�Ĵ���
                imm <= 1'b1; // ����������
                isrt <= 1'b1; // Ŀ�ļĴ�����ַѡ�� rt
            end
            6'b100011: // lw��(rt) �� Memory[(rs) + (Sign-Extend) offset]
            begin
                aluOP <= A_ADD;
                regWE <= 1'b1; // ��ȡ������ dout д�Ĵ���
                imm <= 1'b1; // ���������� offset
                isrt <= 1'b1; // Ŀ�ļĴ�����ַѡ�� rt
                ce <= 1'b1; // �����ݴ��ڴ�/���ض��뵽�Ĵ�����
            end
            6'b101011: // sw��Memory[(rs) + (Sign-Extend) offset] �� (rt)
            begin
                aluOP <= A_ADD;
                imm <= 1'b1; // ���������� offset
                we <= 1'b1; // ������д���ڴ� / led
            end
            6'b000100: // beq��if ((rt) == (rs)) then (PC) �� (PC) + 4 + ((Sign-Extend) offset << 2)
            begin
                aluOP <= A_SUB;
                if (z) // a == b���� f = 0���� z = 1
                begin
                    pcsource <= 2'b01;
                    sign_ext <= 1'b1; // ������ offset ���з�����չ
                end
            end
            6'b000101: // bne��if ((rt) != (rs)) then (PC) �� (PC) + 4 + ((Sign-Extend) offset << 2)
            begin
                aluOP <= A_SUB;
                if (~z) // a != b���� f != 0���� z = 0
                begin
                    pcsource <= 2'b01;
                    sign_ext <= 1'b1; // ������ offset ���з�����չ
                end
            end
            6'b001111: // lui��(rt) �� immediate << 16 & 0FFFF0000H
            begin
                aluOP <= A_LUI;
                regWE <= 1'b1; // ��� f д�Ĵ���
                imm <= 1'b1; // ����������
            end
            6'b000010: // j��(PC) �� ((Zero-Extend) address << 2)
            begin
                pcsource <= 2'b11;
            end
            6'b000011: // jal���� ($31) �� (PC) + 4���� (PC) �� ((Zero-Extend) address << 2)
            begin
                jal <= 1'b1;
                regWE <= 1'b1;
                pcsource <= 2'b11;
            end
        endcase
    end
endmodule
