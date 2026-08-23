/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-08-13 21:34:40
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-23 22:32:07
 * @FilePath: /swift_riscv/rtl/uart/uart.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */
module uart(
    input pclk,
    input rst_n,
    input slv_sel,
    input slv_we,
    input slv_penable,
    input [`REG_WIDTH - 1: 0]slv_addr,
    input [`REG_WIDTH - 1: 0]slv_wdata,
    output slv_ready,
    output reg [`REG_WIDTH - 1: 0]slv_rdata
);
    localparam UART_ADDR_WIDTH = 8;
    localparam UART_RUN_RET_ADDR = 8'h0;
    localparam UART_TX_ADDR = 8'h4;

    wire uart_wr;
    wire uart_rd;
    wire [UART_ADDR_WIDTH - 1: 0]addr;
    reg uart_rd_ready;
    reg uart_wr_ready;
    reg [`REG_WIDTH - 1: 0]uart_run_ret;
    reg [`REG_WIDTH - 1: 0]uart_tx;

    assign uart_wr = slv_sel && slv_we && ~slv_penable;
    assign uart_rd = slv_sel && (!slv_we) && ~slv_penable;
    assign addr = slv_addr[UART_ADDR_WIDTH - 1: 0];
    assign slv_ready = uart_wr_ready || uart_rd_ready;


    always @(posedge pclk or negedge rst_n)
        if (!rst_n) begin
            uart_tx <= 0;
            uart_run_ret <= 0;
            uart_wr_ready <= 0;
        end else if(uart_wr) begin
            case (addr)
                UART_RUN_RET_ADDR: uart_run_ret <= slv_wdata;
                UART_TX_ADDR: uart_tx <= slv_wdata;
            endcase
            uart_wr_ready <= 1'b1;
        end else begin
            uart_wr_ready <= 1'b0;
        end
    
    always @(*)
        if (!rst_n) begin
            uart_rd_ready = 0;
        end else if (uart_rd) begin
            case (addr)
                UART_RUN_RET_ADDR: slv_rdata = uart_run_ret;
                UART_TX_ADDR: slv_rdata <= uart_tx;
            endcase
            uart_rd_ready = 1'b1;
        end else begin
            uart_rd_ready = 1'b0;
        end

endmodule