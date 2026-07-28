/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-07-26 11:55:57
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-07-28 23:00:31
 * @FilePath: /SwiftRiscv/rtl/utils/dll.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */
module gen_zero_dff #(
    parameter DW=32,
    parameter STAGS = 1
) (
    input clk,
    input rst_n,
    input [DW-1:0]din,
    output reg [DW-1: 0]dout
);
    reg [DW-1: 0]pipe[0: STAGS-1];
    integer i;
    always @(posedge clk or negedge rst_n)
        if (!rst_n) begin
            for(i = 0; i < STAGS; i = i + 1)
                pipe[i] <= {DW{1'b0}};
        end
        else begin
            pipe[0] <= din;
            for(i=1; i < STAGS; i = i + 1)
                pipe[i] <= pipe[i-1];
        end

    always @(*)
        dout = pipe[STAGS - 1];

endmodule

module gen_one_dff #(
    parameter DW = 32,
    parameter STAGS = 1
) (
    input               clk,
    input               rst_n,
    input      [DW-1:0] din,
    output reg [DW-1:0] dout
);
  reg     [DW-1:0] pipe[0:STAGS-1];
  integer          i;
  always @(posedge clk or negedge rst_n)
    if (!rst_n) begin
      for (i = 0; i < STAGS; i = i + 1) pipe[i] <= {DW{1'b1}};
    end else begin
      pipe[0] <= din;
      for (i = 1; i < STAGS; i = i + 1) pipe[i] <= pipe[i-1];
    end

  always @(*) dout = pipe[STAGS-1];

endmodule

module gen_hold_default_dff #(
    parameter DW = 32,
    parameter STAGS = 1
) (
    input               clk,
    input               rst_n,
    input               hold_en,
    input               [DW-1: 0]default_val,
    input               [DW-1:0] din,
    output reg          [DW-1:0] dout
);
  reg     [DW-1:0] pipe[0:STAGS-1];
  integer          i;
  always @(posedge clk or negedge rst_n)
    if (!rst_n | hold_en) begin
        for(i = 0; i < STAGS; i = i + 1)
            pipe[i] <= default_val;
    end
    else begin
      pipe[0] <= din;
      for (i = 1; i < STAGS; i = i + 1) pipe[i] <= pipe[i-1];
    end

  always @(*) dout = pipe[STAGS-1];

endmodule
