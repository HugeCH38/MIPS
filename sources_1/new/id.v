`timescale 1ns / 1ps

// Instrument Decoder 指令译码器
module id(input [31:0] instrument, // 32 位定长格式指令
            output reg [5:0] opcode, // MIPS 指令类型
            output reg [5:0] func, // MIPS 指令功能码
            output reg [4:0] rs, // rs 寄存器地址
            output reg [4:0] rt, // rt 寄存器地址
            output reg [4:0] rd, // rd 寄存器地址
            output reg [4:0] sa, // shamt 寄存器地址
            output reg [15:0] immediate, // 立即数
            output reg [25:0] address); // 跳转指令地址
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
            // R 类型指令：
            6'b000000: // add / sub / and / or / xor / sll / srl / sra / jr
            begin
                rs <= instrument[25:21];
                rt <= instrument[20:16];
                rd <= instrument[15:11];
                sa <= instrument[10:6];
                func <= instrument[5:0];
            end
            // I 类型指令：
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
            // J 类型指令：
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
