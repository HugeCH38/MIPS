`timescale 1ns / 1ps

// RAM �洢��
module ram(input clk, input ce, input we, // ʱ���źš�������ơ��������
                input [4:0] addr, // ��ַ
                output reg [31:0] rdata, input [31:0] wdata); //���˿ڡ�д�˿�
    reg [31:0] ramunit [0:31]; // 32 �� 32 bit ���ڴ浥Ԫ
    
    // ��������
    always@(*)
    begin
        if(ce == 1'b0) // ��ֹ���
        begin
            rdata <= 32'bz; // ����̬
        end
        else if(we == 1'b1) // ����ж��źŵ�ͬʱ��д�źţ��򷵻�д����
        begin
            rdata <= wdata;
        end
        else
        begin
            rdata <= ramunit[addr];
        end
    end

    // д������
    always@(posedge clk)
    begin
        if(we == 1'b1) // ��д�ź�
        begin
            ramunit[addr] <= wdata;
        end
    end
endmodule
