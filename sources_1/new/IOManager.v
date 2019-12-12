`timescale 1ns / 1ps

module IOManager(input clk, // ʱ���ź�
                    input ce, // ��ȡʹ�ܶ� / �������
                    input we, // д��ʹ�ܶ� / �������
                    input [5:0] addr, // ��ַ��0xxxxx Ϊ�ڴ��ַ��1xxxxx Ϊ���ػ� led ��ַ
                    input [3:0] switch, // �ӿ��ض�ȡ������
                    input [31:0] din, // �������� (��Ҫд�뵽�ڴ������� led ������)
                    output [31:0] dout, // ������� (���ڴ�򿪹ض�ȡ������)
                    output reg [31:0] displaydata); // ����� led ������
    wire ramCE; // �ڴ��ȡʹ�ܶ�
    wire ramWE; // �ڴ�д��ʹ�ܶ�
    wire [31:0] ramdout; // ���ڴ��ȡ������
    
    assign ramCE = ce & (~addr[5]); // ce = 1 ʱ��addr = 0xxxxx ����ڴ��ȡ���ݣ�����ӿ��ض�ȡ����
    assign ramWE = we & (~addr[5]); // we = 1 ʱ��addr = 0xxxxx ��������ڴ棬��������� led
    
    // ʵ���� RAM �洢�� (Random Access Memory)
    ram myram(.clk(clk), .ce(ramCE), .we(ramWE),
                .addr(addr[4:0]), .rdata(din), .wdata(ramdout));
    
    // addr = 1xxxxx ���ȡ���ص����ݣ������ȡ�ڴ������
    assign dout = addr[5] ? {{28{1'b0}}, switch} : ramdout;
    
    always @(posedge clk)
    begin
        if (addr[5] && we) // addr = 1xxxxx ������� led
        begin
            displaydata <= din;
        end
    end
endmodule
