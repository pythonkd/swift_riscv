/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-07-12 16:38:32
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-07-19 17:26:24
 * @FilePath: /SwiftRiscv/rtl/pc_reg.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */


module pc_reg(
    input clk,
    input rst_n,
    input [`REG_WIDTH - 1: 0]nx_pc,
    output reg [`REG_WIDTH - 1: 0]pc,
    output reg stop
);

    // assign stop = !rst_n;
    always @(posedge clk or negedge rst_n)
        if (!rst_n)
            stop <= 1'b1;
        else
            stop <= 1'b0;
    
    always @(posedge clk or negedge rst_n)
        if (!rst_n)
            pc <= `REG_WIDTH'b0;
        else
            pc <= nx_pc;
    
endmodule