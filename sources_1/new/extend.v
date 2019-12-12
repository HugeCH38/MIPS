`timescale 1ns / 1ps

// 立即数扩展
module extend(input sign_ext, // 立即数扩展，=1 则符号扩展，否则零扩展
                input [15:0] immediate, output [31:0] result);
    assign result = sign_ext ?
                        {{16{immediate[15]}}, immediate} : // 符号扩展
                            {16'b0, immediate}; // 零扩展
endmodule
