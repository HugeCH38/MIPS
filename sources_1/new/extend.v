`timescale 1ns / 1ps

// ��������չ
module extend(input sign_ext, // ��������չ��=1 �������չ����������չ
                input [15:0] immediate, output [31:0] result);
    assign result = sign_ext ?
                        {{16{immediate[15]}}, immediate} : // ������չ
                            {16'b0, immediate}; // ����չ
endmodule
