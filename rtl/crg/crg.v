/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-08-02 14:19:05
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-14 21:27:30
 * @FilePath: /swift_riscv/rtl/crg/crg.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */

module crg(
    input clk,
    input rst_n,
    output core_clk,
    output mtimer_clk,
    output core_rst,
    output apb_clk,
    output flash_clk,
    output flash_rst,
    output uart_clk,
    output uart_rst
);

    clk_div #(
        .DW(2),
        .DEFAULT_VAL(0)
    ) u_apb_clk_div (
        .clk(clk),
        .rst_n(rst_n),
        .div(2'b10),
        .o_clk(apb_clk)
    );

    clk_div #(
        .DW(1),
        .DEFAULT_VAL(0)
    ) u_core_clk_div (
        .clk(clk),
        .rst_n(core_rst),
        .div(1'b1),
        .o_clk(core_clk)
    );


    clk_div #(
        .DW(3),
        .DEFAULT_VAL(0)
    ) u_uart_clk_div (
        .clk(clk),
        .rst_n(rst_n),
        .div(3'h4),
        .o_clk(uart_clk)
    );

    clk_div #(
        .DW(6),
        .DEFAULT_VAL(0)
    ) u_mtimer_clk_div (
        .clk(clk),
        .rst_n(core_rst),
        .div(6'h32),
        .o_clk(mtimer_clk)
    );

    clk_div #(
        .DW(1),
        .DEFAULT_VAL(0)
    ) u_flash_clk_div (
        .clk(clk),
        .rst_n(rst_n),
        .div(1'b1),
        .o_clk(flash_clk)
    );

    gen_zero_def_dff #(
        .DW(1),
        .STAGS(2)
    ) u_gen_zero_dff_core_deassert(
        .clk(apb_clk),
        .rst_n(rst_n),
        .din(rst_n),
        .dout(core_rst)
    );

    gen_zero_def_dff #(
        .DW(1),
        .STAGS(2)
    ) u_gen_zero_dff_uart_deassert(
        .clk(apb_clk),
        .rst_n(rst_n),
        .din(rst_n),
        .dout(uart_rst)
    );

    gen_zero_def_dff #(
        .DW(1),
        .STAGS(2)
    ) u_gen_zero_dff_flash_deassert(
        .clk(clk),
        .rst_n(rst_n),
        .din(rst_n),
        .dout(flash_rst)
    );

endmodule