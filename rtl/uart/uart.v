/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-08-13 21:34:40
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-16 00:30:50
 * @FilePath: /swift_riscv/rtl/uart/uart.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */
module uart(
    input clk,
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
    reg [`REG_WIDTH - 1: 0]uart_run_ret;
    reg [`REG_WIDTH - 1: 0]uart_tx;
    assign slv_ready = 1'b1;
    assign uart_wr = slv_sel && slv_we && ~slv_penable;
    assign uart_rd = slv_sel && (!slv_we) && ~slv_penable;
    assign addr = slv_addr[UART_ADDR_WIDTH - 1: 0];

    always @(posedge clk or negedge rst_n)
        if (!rst_n) begin
            uart_tx <= 0;
            uart_run_ret <= 0;
        end else begin
            if(uart_wr) begin
                case (addr)
                    UART_RUN_RET_ADDR: uart_run_ret <= slv_wdata;
                    UART_TX_ADDR: uart_tx <= slv_wdata;
                endcase
            end
        end
    
    always @(*)
        if (uart_rd) begin
            case (addr)
                UART_RUN_RET_ADDR: slv_rdata <= uart_run_ret;
                UART_TX_ADDR: slv_rdata <= uart_tx;
            endcase
        end
endmodule