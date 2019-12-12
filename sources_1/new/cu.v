`timescale 1ns / 1ps

// Control Unit 控制单元
module cu(input [5:0] opcode, // MIPS 指令类型
            input [5:0] func, // MIPS 指令功能码
            input z, // 是否为 0 标志
            output reg [1:0] pcsource, // pc 值的来源
            output reg [3:0] aluOP, // alu 的运算类型
            output reg regWE, // 是否写寄存器
            output reg imm, // 是否产生立即数
            output reg shift, // 是否移位
            output reg isrt, // 目的寄存器地址，=1 则选择 rt，否则选择 rd
            output reg sign_ext, // 立即数扩展，=1 则符号扩展，否则零扩展
            output reg jal, // 是否调用子程序跳转
            output reg ce, // 是否将数据从内存/开关读入到寄存器中
            output reg we); // 是否将数据写入内存 / led
    parameter A_NOP = 4'b0000; // 清零，无运算
    parameter A_ADD = 4'b0001; // 加法运算
    parameter A_SUB = 4'b0010; // 减法运算
    parameter A_AND = 4'b0011; // 与运算
    parameter A_OR = 4'b0100; // 或运算
    parameter A_XOR = 4'b0101; // 异或运算
    parameter A_SLL = 4'b0110; // sll
    parameter A_SRL = 4'b0111; // srl
    parameter A_SRA = 4'b1000; // sra
    parameter A_LUI = 4'b1001; // lui
    
    always @(*)
    begin
        // 先设置好默认值
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
                    6'b100000: // add，(rd) ← (rs) + (rt)
                    begin
                        aluOP <= A_ADD;
                        regWE <= 1'b1; // 结果 f 写寄存器
                    end
                    6'b100010: // sub，(rd) ← (rs) - (rt)
                    begin
                        aluOP <= A_SUB;
                        regWE <= 1'b1; // 结果 f 写寄存器
                    end
                    6'b100100: // and，(rd) ← (rs) AND (rt)
                    begin
                        aluOP <= A_AND;
                        regWE <= 1'b1; // 结果 f 写寄存器
                    end
                    6'b100101: // or，(rd) ← (rs) OR (rt)
                    begin
                        aluOP <= A_OR;
                        regWE <= 1'b1; // 结果 f 写寄存器
                    end
                    6'b100110: // xor，(rd) ← (rs) XOR (rt)
                    begin
                        aluOP <= A_XOR;
                        regWE <= 1'b1; // 结果 f 写寄存器
                    end
                    6'b000000: // sll，(rd) ← (rt) << shamt
                    begin
                        aluOP <= A_SLL;
                        regWE <= 1'b1; // 结果 f 写寄存器
                        shift <= 1'b1; // 移位
                    end
                    6'b000010: // srl，(rd) ← (rt) >> shamt
                    begin
                        aluOP <= A_SRL;
                        regWE <= 1'b1; // 结果 f 写寄存器
                        shift <= 1'b1; // 移位
                    end
                    6'b000011: // sra，(rd) ← (rt) >> shamt (符号位移动且保留)
                    begin
                        aluOP <= A_SRA;
                        regWE <= 1'b1; // 结果 f 写寄存器
                        shift <= 1'b1; // 移位
                    end
                    6'b001000: // jr
                    begin
                        pcsource <= 2'b10;
                    end
                endcase
            end
            6'b001000: // addi，(rt) ← (rs) + (Sign-Extend) immediate
            begin
                aluOP <= A_ADD;
                regWE <= 1'b1; // 结果 f 写寄存器
                imm <= 1'b1; // 产生立即数
                isrt <= 1'b1; // 目的寄存器地址选择 rt
                sign_ext <= 1'b1; // 立即数进行符号扩展
            end
            6'b001100: // andi，(rt) ← (rs) AND (Zero-Extend) immediate
            begin
                aluOP <= A_AND;
                regWE <= 1'b1; // 结果 f 写寄存器
                imm <= 1'b1; // 产生立即数
                isrt <= 1'b1; // 目的寄存器地址选择 rt
            end
            6'b001101: // ori，(rt) ← (rs) OR (Zero-Extend) immediate
            begin
                aluOP <= A_OR;
                regWE <= 1'b1; // 结果 f 写寄存器
                imm <= 1'b1; // 产生立即数
                isrt <= 1'b1; // 目的寄存器地址选择 rt
            end
            6'b001110: // xori，(rt) ← (rs) XOR (Zero-Extend) immediate
            begin
                aluOP <= A_XOR;
                regWE <= 1'b1; // 结果 f 写寄存器
                imm <= 1'b1; // 产生立即数
                isrt <= 1'b1; // 目的寄存器地址选择 rt
            end
            6'b100011: // lw，(rt) ← Memory[(rs) + (Sign-Extend) offset]
            begin
                aluOP <= A_ADD;
                regWE <= 1'b1; // 读取的数据 dout 写寄存器
                imm <= 1'b1; // 产生立即数 offset
                isrt <= 1'b1; // 目的寄存器地址选择 rt
                ce <= 1'b1; // 将数据从内存/开关读入到寄存器中
            end
            6'b101011: // sw，Memory[(rs) + (Sign-Extend) offset] ← (rt)
            begin
                aluOP <= A_ADD;
                imm <= 1'b1; // 产生立即数 offset
                we <= 1'b1; // 将数据写入内存 / led
            end
            6'b000100: // beq，if ((rt) == (rs)) then (PC) ← (PC) + 4 + ((Sign-Extend) offset << 2)
            begin
                aluOP <= A_SUB;
                if (z) // a == b，则 f = 0，则 z = 1
                begin
                    pcsource <= 2'b01;
                    sign_ext <= 1'b1; // 立即数 offset 进行符号扩展
                end
            end
            6'b000101: // bne，if ((rt) != (rs)) then (PC) ← (PC) + 4 + ((Sign-Extend) offset << 2)
            begin
                aluOP <= A_SUB;
                if (~z) // a != b，则 f != 0，则 z = 0
                begin
                    pcsource <= 2'b01;
                    sign_ext <= 1'b1; // 立即数 offset 进行符号扩展
                end
            end
            6'b001111: // lui，(rt) ← immediate << 16 & 0FFFF0000H
            begin
                aluOP <= A_LUI;
                regWE <= 1'b1; // 结果 f 写寄存器
                imm <= 1'b1; // 产生立即数
            end
            6'b000010: // j，(PC) ← ((Zero-Extend) address << 2)
            begin
                pcsource <= 2'b11;
            end
            6'b000011: // jal，① ($31) ← (PC) + 4，② (PC) ← ((Zero-Extend) address << 2)
            begin
                jal <= 1'b1;
                regWE <= 1'b1;
                pcsource <= 2'b11;
            end
        endcase
    end
endmodule
