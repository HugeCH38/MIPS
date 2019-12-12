// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.4 (win64) Build 2086221 Fri Dec 15 20:55:39 MST 2017
// Date        : Tue Dec  3 13:44:36 2019
// Host        : Stu86 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top myrom -prefix
//               myrom_ myrom_stub.v
// Design      : myrom
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tfgg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "dist_mem_gen_v8_0_12,Vivado 2017.4" *)
module myrom(a, spo)
/* synthesis syn_black_box black_box_pad_pin="a[4:0],spo[31:0]" */;
  input [4:0]a;
  output [31:0]spo;
endmodule
