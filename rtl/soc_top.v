/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-08-02 20:35:24
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-02 21:00:35
 * @FilePath: /swift_riscv/rtl/soc_top.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */

module soc_top (
    input clk,
    input rst_n
);
    wire core_clk;
    wire apb_clk;
    wire uart_clk;
    
    crg u_crg(
        // input
        .clk(clk),
        .rst_n(rst_n),
        // output
        .core_clk(core_clk),
        .apb_clk(apb_clk),
        .uart_clk(uart_clk)
    );

    core_top u_core_top(
        .clk(core_clk),
        .rst_n(rst_n)
    );

endmodule