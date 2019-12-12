`timescale 1ns / 1ps

// �Ĵ�����
module regfile(input clk, input oc, // ʱ���źź��������
                input [4:0] raddr1, output reg [31:0] rdata1, // ���˿� 1
                    input [4:0] raddr2, output reg [31:0] rdata2, // ���˿� 2
                        input we, input [4:0] waddr, input [31:0] wdata); // д�˿�
    reg [31:0] registers [0:31]; // 32 �� 32 bit �ļĴ���
    
    // ������ 1��
    always@(*)
    begin
        if(oc == 1'b1) // ��ֹ���
        begin
            rdata1 <= 32'bz; // ����̬
        end
        else if(raddr1 == 5'b00000) // 0 �żĴ�����ֵ�̶�Ϊ 32'b0
        begin
            rdata1 <= 32'b0;
        end
        else if((raddr1 == waddr) && (we == 1'b1))
            // ����˿� 1 ����ַ������д��ַ���򷵻�д����
        begin
            rdata1 <= wdata;
        end
        else
        begin
            rdata1 <= registers[raddr1];
        end
    end
    
    // ������ 2��
    always@(*)
    begin
        if(oc == 1'b1) // ��ֹ���
        begin
            rdata2 <= 32'bz; // ����̬
        end
        else if(raddr2 == 5'b00000) // 0 �żĴ�����ֵ�̶�Ϊ 32'b0
        begin
            rdata2 <= 32'b0;
        end
        else if((raddr2 == waddr) && (we == 1'b1))
            // ����˿� 2 ����ַ������д��ַ���򷵻�д����
        begin
            rdata2 <= wdata;
        end
        else
        begin
            rdata2 <= registers[raddr2];
        end
    end
    
    // д������
    always@(posedge clk)
    begin
        if((we == 1'b1) && (waddr != 5'b00000)) // ��д�źţ���д��ַ��Ϊ 0 �żĴ�����ַ
        begin
            registers[waddr] <= wdata;
            $monitor($time,, "write %d to R %d", wdata, waddr);
        end
    end
endmodule
