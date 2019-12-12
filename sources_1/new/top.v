`timescale 1ns / 1ps

module top(input clk, input rst, input [3:0] n, output [11:0] result);
    wire [31:0] pcnext;
    wire [31:0] pcaddr;
    
    wire [31:0] in0;
    wire [31:0] in1;
    wire [31:0] in2;
    wire [31:0] in3;
    
    wire [31:0] instrument; // ָ��
    
    wire [5:0] opcode; // MIPS ָ������
    wire [5:0] func; // MIPS ָ�����
    wire [4:0] rs; // rs �Ĵ�����ַ
    wire [4:0] rt; // rt �Ĵ�����ַ
    wire [4:0] rd; // rd �Ĵ�����ַ
    wire [4:0] sa; // shamt �Ĵ�����ַ
    wire [15:0] immediate; // ������
    wire [25:0] address; // ��תָ���ַ
    
    wire z; // �Ƿ�Ϊ 0 ��־
    
    wire [1:0] pcsource; // pc ֵ����Դ
    wire [3:0] aluOP; // alu ����������
    wire regWE; // �Ƿ�д�Ĵ���
    wire imm; // �Ƿ����������
    wire shift; // �Ƿ���λ
    wire isrt; // Ŀ�ļĴ�����ַ��=1 ��ѡ�� rt������ѡ�� rd
    wire sign_ext; // ��������չ��=1 �������չ����������չ
    wire jal; // �Ƿ�����ӳ�����ת
    wire ce; // �Ƿ����ݴ��ڴ�/���ض��뵽�Ĵ�����
    wire we; // �Ƿ�����д���ڴ� / led
    
    wire [31:0] extendedImmediate;
    
    wire [4:0] raddr1; // �Ĵ���������˵�ַ 1
    wire [31:0] rdata1; // �Ĵ�������������� 1
    wire [31:0] rdata2; // �Ĵ�������������� 2
    wire [4:0] waddr; // �Ĵ���������˵�ַ
    wire [31:0] wdata; // �Ĵ��������������
    
    wire [31:0] b;
    wire [31:0] f;
    
    // wire [3:0] switch; // �ӿ��ض�ȡ������ n
    wire [31:0] dout; // ������� (���ڴ�򿪹ض�ȡ������)
    wire [31:0] displaydata; // ����� led ������
    
    // assign switch = 10; // ���� fib(10)
    
    // �� IF ȡָ�� (Instrument Fetch)��
    // ʵ���� PC ��������� (Program Counter)
    pc mypc(.clk(clk), .rst(rst), .pcnext(pcnext), .pcaddr(pcaddr));
    mux4 mymux4(.in0(in0), .in1(in1), .in2(in2), .in3(in3), .select(pcsource), .out(pcnext));
    assign in0 = pcaddr + 4;
    assign in1 = pcaddr + (extendedImmediate << 2);
    assign in2 = raddr1; // shift = 0�� raddr1 = rs��rdata1 = [rs]��
    assign in3 = {pcaddr[31:28], address, 2'b00};
    // ʵ���� ROM
    myrom rom(.a(pcaddr[6:2]), .spo(instrument)); // ȡָ�� ID �� ROM[PC]
    
    // �� ID ָ������ (Instrument Decode)��
    // ʵ���� ID ָ�������� (Instrument Decoder)
    id myid(.instrument(instrument), .opcode(opcode), .func(func),
                        .rs(rs), .rt(rt), .rd(rd), .sa(sa),
                        .immediate(immediate), .address(address));
    // ʵ���� CU ���Ƶ�Ԫ (Control Unit)
    cu mycu(.opcode(opcode), .func(func), .z(z),
            .pcsource(pcsource), .aluOP(aluOP),
            .regWE(regWE), .imm(imm), .shift(shift),
            .isrt(isrt), .sign_ext(sign_ext), .jal(jal),
            .ce(ce), .we(we));
    
    // ʵ���� extend ��������չ��
    extend myet(.sign_ext(sign_ext), .immediate(immediate[15:0]), .result(extendedImmediate));
    // ʵ���� regfile �Ĵ�����
    regfile myrf(.clk(clk), .oc(1'b0),
                    .raddr1(raddr1), .rdata1(rdata1),
                    .raddr2(rt), .rdata2(rdata2),
                    .we(regWE), .waddr(waddr), .wdata(wdata));
    // ALU �� a �����ѡ�� (���� shift �����ź���ѡ��)
    // a = rdata1��
    // shift = 1��raddr1 = sa��rdata1 = [sa]��
    // shift = 0�� raddr1 = rs��rdata1 = [rs]��
    assign raddr1 = shift ? sa : rs;
    // ALU �� b �����ѡ�� (���� imm �����ź���ѡ��)
    // raddr2 = rt, rdata2 = [rt]��
    // �Ĵ���������˵�ַѡ�� waddr (���� isrt��jal ���������ź���ѡ��)
    assign waddr = jal ? 5'b11111: (isrt ? rt : rd); // 5'b11111 = 31
    // �Ĵ��������������ѡ�� wdata (���� ce��jal ���������ź���ѡ��)
    assign wdata = jal ? (pcaddr + 4) : (ce ? dout : f);
    
    // �� EXE ָ��ִ�� (Execute)��
    // ʵ���� ALU �����߼���Ԫ (Arithmetic Logic Unit)
    alu myalu(.a(rdata1), .b(b), .op(aluOP), .f(f), .z(z));
    // ALU �� a �����ѡ�� (���� shift �����ź���ѡ��)
    // a = rdata1��
    // shift = 1��raddr1 = sa��rdata1 = [sa]��
    // shift = 0�� raddr1 = rs��rdata1 = [rs]��
    // ALU �� b �����ѡ�� (���� imm �����ź���ѡ��)
    // raddr2 = rt, rdata2 = [rt]��
    assign b = imm ? extendedImmediate : rdata2;
    
    // �� MEM �洢������ (Memory Access) (ֻ�� LW �� SW ָ�����洢�����ʽ׶� MEM)��
    
    // �� WB д�� (Write Back)��
    // ʵ���� IOManager
    IOManager myio(.clk(clk), .ce(ce), .we(we), .addr(f[5:0]), .switch(n),
                    .din(rdata2), .dout(dout), .displaydata(displaydata));
    // addr = rs + offset = rs + immediate����ַ��0xxxxx Ϊ�ڴ��ַ��1xxxxx Ϊ���ػ� led ��ַ
    // din = [rt]��raddr2 = rt, rdata2 = [rt]��
    
    assign result = displaydata[11:0];
    
    // �������ԣ�
    always @(*)
    begin
        // �� IF ȡָ�� (Instrument Fetch)
        $monitor($time,, "rst = %d, pcnext = %d, pcaddr = %d, instrument = %h",
                    rst, pcnext, pcaddr, instrument);
        $monitor($time,, "in0 = %d, in1 = %d, in2 = %d, in3 = %d", in0, in1, in2, in3);
        // �� ID ָ������ (Instrument Decode)
        $monitor($time,, "opcode = %b, func = %b, rs = %d, rt = %d, rd = %d, sa = %d",
                    opcode, func, rs, rt, rd, sa);
        $monitor($time,, "immediate = %d, extendedImmediate = %d, address = %d", immediate, extendedImmediate, address);
        $monitor($time,, "z = %b, pcsource = %b, aluOP = %b", z, pcsource, aluOP);
        $monitor($time,, "regWE = %b, imm = %b, shift = %b, isrt = %b, sign_ext = %b",
                    regWE, imm, shift, isrt, sign_ext);
        $monitor($time, "jal = %b, ce = %b, we = %b", jal, ce, we);
        // �� EXE ָ��ִ�� (Execute)
        $monitor($time,, "a = %d, b = %d, aluOP = %b, f = %d, z = %b",
                    rdata1, b, aluOP, f, z);
        // �� MEM �洢������ (Memory Access) (ֻ�� LW �� SW ָ�����洢�����ʽ׶� MEM)��
        // �� WB д�� (Write Back)��
        $monitor($time,, "ce = %b, we = %b, addr = %d, switch = %d", ce, we, f[5:0], n);
        $monitor($time,, "din = %d, dout = %d, displaydata = %d", rdata2, dout, displaydata);
    end
endmodule
