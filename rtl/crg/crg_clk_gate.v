/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-08-08 10:59:04
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-08 11:48:58
 * @FilePath: /swift_riscv/rtl/crg/crg_clk_gate.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */

module crgclk_gate(
    input clk,
    input rst_n,
    input clk_gate,
    output o_clk
);
    assign o_clk = clk_gate & clk;
endmodule