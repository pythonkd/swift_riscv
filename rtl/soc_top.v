/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-08-02 20:35:24
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-16 00:17:30
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
    wire core_rst;
    wire uart_rst;
    wire uart_int;
    wire mtimer_clk;
    wire flash_clk;
    wire flash_rst;
    wire mst0_penable;
    wire slv_ready;
    wire mst0_we;
    wire [`REG_WIDTH - 1: 0]mst0_rdata;
    wire [`REG_WIDTH - 1: 0]mst0_addr;
    wire [`REG_WIDTH - 1: 0]mst0_wdata;
    wire slv0_we;
    wire slv0_sel;
    wire slv0_ready;
    wire slv0_penable;
    wire [`REG_WIDTH - 1: 0]slv0_addr;
    wire [`REG_WIDTH - 1: 0]slv0_wdata;
    wire [`REG_WIDTH - 1: 0]slv0_rd_data;
    wire slv1_we;
    wire slv1_sel;
    wire slv1_ready;
    wire slv1_penable;
    wire [`REG_WIDTH - 1: 0]slv1_addr;
    wire [`REG_WIDTH - 1: 0]slv1_wdata;
    wire [`REG_WIDTH - 1: 0]slv1_rd_data;
    
    crg u_crg(
        // input
        .clk(clk),
        .rst_n(rst_n),
        // output
        .core_clk(core_clk),
        .mtimer_clk(mtimer_clk),
        .apb_clk(apb_clk),
        .uart_clk(uart_clk),
        .core_rst(core_rst),
        .uart_rst(uart_rst),
        .flash_clk(flash_clk),
        .flash_rst(flash_rst)
    );

    core_top u_core_top(
        //input
        .clk(core_clk),
        .rst_n(core_rst),
        .mtimer_clk(mtimer_clk),
        .uart_int(uart_int),
        .slv_rd_data(mst0_rdata),
        .slv_ready(slv_ready),
        .p_enable(mst0_penable),
        .mst_we(mst0_we),
        .mst_addr(mst0_addr),
        .mst_wdata(mst0_wdata)
    );

    simple_bus u_simple_bus (
        // input
        .mst0_we(mst0_we),
        .mst0_penable(mst0_penable),
        .mst0_addr(mst0_addr),
        .mst0_wdata(mst0_wdata),
        .slv0_ready(slv0_ready),
        .slv0_rd_data(slv0_rd_data),
        .slv1_ready(slv1_ready),
        .slv1_rd_data(slv1_rd_data),
        // output
        .slv0_we(slv0_we),
        .slv0_sel(slv0_sel),
        .slv0_penable(slv0_penable),
        .slv0_addr(slv0_addr),
        .slv0_wdata(slv0_wdata),
        .slv1_we(slv1_we),
        .slv1_sel(slv1_sel),
        .slv1_penable(slv1_penable),
        .slv1_addr(slv1_addr),
        .slv1_wdata(slv1_wdata),
        .slv_ready(slv_ready),
        .mst0_rdata(mst0_rdata)
    );

    uart u_uart(
        .clk(uart_clk),
        .rst_n(uart_rst),
        .slv_sel(slv1_sel),
        .slv_we(slv1_we),
        .slv_penable(slv1_penable),
        .slv_addr(slv1_addr),
        .slv_wdata(slv1_wdata),
        .slv_ready(slv1_ready),
        .slv_rdata(slv1_rd_data)
    );

    flash u_flash(
        .clk(flash_clk),
        .rst_n(flash_rst),
        .slv_sel(slv0_sel),
        .slv_we(slv0_we),
        .slv_penable(slv0_penable),
        .slv_addr(slv0_addr),
        .slv_wdata(slv0_wdata),
        .slv_ready(slv0_ready),
        .slv_rdata(slv0_rd_data)
    );

endmodule