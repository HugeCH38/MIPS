`timescale 1ns / 1ps

module top(input clk, input rst, input [3:0] n, output [11:0] result);
    wire [31:0] pcnext;
    wire [31:0] pcaddr;
    
    wire [31:0] in0;
    wire [31:0] in1;
    wire [31:0] in2;
    wire [31:0] in3;
    
    wire [31:0] instrument; // 指令
    
    wire [5:0] opcode; // MIPS 指令类型
    wire [5:0] func; // MIPS 指令功能码
    wire [4:0] rs; // rs 寄存器地址
    wire [4:0] rt; // rt 寄存器地址
    wire [4:0] rd; // rd 寄存器地址
    wire [4:0] sa; // shamt 寄存器地址
    wire [15:0] immediate; // 立即数
    wire [25:0] address; // 跳转指令地址
    
    wire z; // 是否为 0 标志
    
    wire [1:0] pcsource; // pc 值的来源
    wire [3:0] aluOP; // alu 的运算类型
    wire regWE; // 是否写寄存器
    wire imm; // 是否产生立即数
    wire shift; // 是否移位
    wire isrt; // 目的寄存器地址，=1 则选择 rt，否则选择 rd
    wire sign_ext; // 立即数扩展，=1 则符号扩展，否则零扩展
    wire jal; // 是否调用子程序跳转
    wire ce; // 是否将数据从内存/开关读入到寄存器中
    wire we; // 是否将数据写入内存 / led
    
    wire [31:0] extendedImmediate;
    
    wire [4:0] raddr1; // 寄存器的输出端地址 1
    wire [31:0] rdata1; // 寄存器的输出端数据 1
    wire [31:0] rdata2; // 寄存器的输出端数据 2
    wire [4:0] waddr; // 寄存器的输入端地址
    wire [31:0] wdata; // 寄存器的输入端数据
    
    wire [31:0] b;
    wire [31:0] f;
    
    // wire [3:0] switch; // 从开关读取的数据 n
    wire [31:0] dout; // 输出数据 (从内存或开关读取的数据)
    wire [31:0] displaydata; // 输出到 led 的数据
    
    // assign switch = 10; // 计算 fib(10)
    
    // ① IF 取指令 (Instrument Fetch)：
    // 实例化 PC 程序计数器 (Program Counter)
    pc mypc(.clk(clk), .rst(rst), .pcnext(pcnext), .pcaddr(pcaddr));
    mux4 mymux4(.in0(in0), .in1(in1), .in2(in2), .in3(in3), .select(pcsource), .out(pcnext));
    assign in0 = pcaddr + 4;
    assign in1 = pcaddr + (extendedImmediate << 2);
    assign in2 = raddr1; // shift = 0， raddr1 = rs，rdata1 = [rs]；
    assign in3 = {pcaddr[31:28], address, 2'b00};
    // 实例化 ROM
    myrom rom(.a(pcaddr[6:2]), .spo(instrument)); // 取指令 ID ← ROM[PC]
    
    // ② ID 指令译码 (Instrument Decode)：
    // 实例化 ID 指令译码器 (Instrument Decoder)
    id myid(.instrument(instrument), .opcode(opcode), .func(func),
                        .rs(rs), .rt(rt), .rd(rd), .sa(sa),
                        .immediate(immediate), .address(address));
    // 实例化 CU 控制单元 (Control Unit)
    cu mycu(.opcode(opcode), .func(func), .z(z),
            .pcsource(pcsource), .aluOP(aluOP),
            .regWE(regWE), .imm(imm), .shift(shift),
            .isrt(isrt), .sign_ext(sign_ext), .jal(jal),
            .ce(ce), .we(we));
    
    // 实例化 extend 立即数扩展器
    extend myet(.sign_ext(sign_ext), .immediate(immediate[15:0]), .result(extendedImmediate));
    // 实例化 regfile 寄存器堆
    regfile myrf(.clk(clk), .oc(1'b0),
                    .raddr1(raddr1), .rdata1(rdata1),
                    .raddr2(rt), .rdata2(rdata2),
                    .we(regWE), .waddr(waddr), .wdata(wdata));
    // ALU 的 a 输入端选择 (根据 shift 控制信号来选择)
    // a = rdata1；
    // shift = 1，raddr1 = sa，rdata1 = [sa]；
    // shift = 0， raddr1 = rs，rdata1 = [rs]；
    assign raddr1 = shift ? sa : rs;
    // ALU 的 b 输入端选择 (根据 imm 控制信号来选择)
    // raddr2 = rt, rdata2 = [rt]；
    // 寄存器的输入端地址选择 waddr (根据 isrt、jal 两个控制信号来选择)
    assign waddr = jal ? 5'b11111: (isrt ? rt : rd); // 5'b11111 = 31
    // 寄存器的输入端数据选择 wdata (根据 ce、jal 两个控制信号来选择)
    assign wdata = jal ? (pcaddr + 4) : (ce ? dout : f);
    
    // ③ EXE 指令执行 (Execute)：
    // 实例化 ALU 算术逻辑单元 (Arithmetic Logic Unit)
    alu myalu(.a(rdata1), .b(b), .op(aluOP), .f(f), .z(z));
    // ALU 的 a 输入端选择 (根据 shift 控制信号来选择)
    // a = rdata1；
    // shift = 1，raddr1 = sa，rdata1 = [sa]；
    // shift = 0， raddr1 = rs，rdata1 = [rs]；
    // ALU 的 b 输入端选择 (根据 imm 控制信号来选择)
    // raddr2 = rt, rdata2 = [rt]；
    assign b = imm ? extendedImmediate : rdata2;
    
    // ④ MEM 存储器访问 (Memory Access) (只有 LW 和 SW 指令进入存储器访问阶段 MEM)：
    
    // ⑤ WB 写回 (Write Back)：
    // 实例化 IOManager
    IOManager myio(.clk(clk), .ce(ce), .we(we), .addr(f[5:0]), .switch(n),
                    .din(rdata2), .dout(dout), .displaydata(displaydata));
    // addr = rs + offset = rs + immediate，地址，0xxxxx 为内存地址，1xxxxx 为开关或 led 地址
    // din = [rt]，raddr2 = rt, rdata2 = [rt]；
    
    assign result = displaydata[11:0];
    
    // 辅助测试：
    always @(*)
    begin
        // ① IF 取指令 (Instrument Fetch)
        $monitor($time,, "rst = %d, pcnext = %d, pcaddr = %d, instrument = %h",
                    rst, pcnext, pcaddr, instrument);
        $monitor($time,, "in0 = %d, in1 = %d, in2 = %d, in3 = %d", in0, in1, in2, in3);
        // ② ID 指令译码 (Instrument Decode)
        $monitor($time,, "opcode = %b, func = %b, rs = %d, rt = %d, rd = %d, sa = %d",
                    opcode, func, rs, rt, rd, sa);
        $monitor($time,, "immediate = %d, extendedImmediate = %d, address = %d", immediate, extendedImmediate, address);
        $monitor($time,, "z = %b, pcsource = %b, aluOP = %b", z, pcsource, aluOP);
        $monitor($time,, "regWE = %b, imm = %b, shift = %b, isrt = %b, sign_ext = %b",
                    regWE, imm, shift, isrt, sign_ext);
        $monitor($time, "jal = %b, ce = %b, we = %b", jal, ce, we);
        // ③ EXE 指令执行 (Execute)
        $monitor($time,, "a = %d, b = %d, aluOP = %b, f = %d, z = %b",
                    rdata1, b, aluOP, f, z);
        // ④ MEM 存储器访问 (Memory Access) (只有 LW 和 SW 指令进入存储器访问阶段 MEM)：
        // ⑤ WB 写回 (Write Back)：
        $monitor($time,, "ce = %b, we = %b, addr = %d, switch = %d", ce, we, f[5:0], n);
        $monitor($time,, "din = %d, dout = %d, displaydata = %d", rdata2, dout, displaydata);
    end
endmodule
