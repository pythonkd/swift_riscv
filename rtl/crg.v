/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-08-02 14:19:05
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-02 22:23:28
 * @FilePath: /swift_riscv/rtl/crg.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */

module crg(
    input clk,
    input rst_n,
    output core_clk,
    output core_rst,
    output apb_clk,
    output uart_clk,
    output uart_rst
);
    clk_div  #(
        .DIV_WIDTH(2)
    ) u_apbclk_div(
        // input
        .clk(clk),
        .rst_n(rst_n),
        .divider(2'b10),
        .rst_val(1'b0),
        // output
        .clk_out(apb_clk)
    );

    clk_div   #(
        .DIV_WIDTH(2)
    ) u_core_clk_div(
        // input
        .clk(clk),
        .rst_n(rst_n),
        .divider(2'b01),
        .rst_val(1'b0),
        // output
        .clk_out(core_clk)
    );

    clk_div  #(
        .DIV_WIDTH(3)
    ) u_uart_clk_div(
        // input
        .clk(clk),
        .rst_n(rst_n),
        .divider(3'h4),
        .rst_val(1'b0),
        // output
        .clk_out(uart_clk)
    );

    gen_zero_dff #(
        .DW(1),
        .STAGS(2)
    ) u_gen_zero_dff_uart_deassert(
        .clk(apb_clk),
        .rst_n(rst_n),
        .din(rst_n),
        .dout(core_rst)
    );
endmodule