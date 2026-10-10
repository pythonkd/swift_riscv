/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-08-08 10:59:04
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-23 22:00:01
 * @FilePath: /swift_riscv/rtl/core/cpu_to_bus.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */

module cpu_to_bus(
    input clk,
    input rst_n,
    input [`BUS_ADDR_WIDTH -1 : 0]cpu_addr,
    input [`BUS_ADDR_DATA_WIDTH - 1: 0]cpu_wdata,
    input cpu_we,
    input [`BUS_ADDR_DATA_WIDTH - 1: 0]slv_rd_data,
    input slv_ready,
    input cpu_flush_bus,
    output reg p_enable,
    output mst_we,
    output [`BUS_ADDR_WIDTH -1 : 0]mst_addr,
    output [`BUS_ADDR_DATA_WIDTH - 1: 0]mst_wdata,
    output [`BUS_ADDR_DATA_WIDTH - 1: 0]cpu_rd_data,
    output ex_bus_idle,
    output extern_data_ready
);
    reg [`BUS_STATE_WIDTH -1 : 0]state;
    reg [`BUS_STATE_WIDTH -1 : 0]nx_state;
    assign mst_addr = state != `BUS_STATE_IDLE ? cpu_addr : 0;
    assign mst_wdata = state != `BUS_STATE_IDLE ? cpu_wdata : 0;
    assign mst_we = state != `BUS_STATE_IDLE ? cpu_we: 1'b0;
    assign extern_data_ready = (slv_ready && p_enable) ? 1 : 0;
    assign cpu_rd_data = extern_data_ready ? slv_rd_data : 0;
    assign p_enable = state == `BUS_STATE_PENABLE;
    assign ex_bus_idle = (state == `BUS_STATE_IDLE) & !mst_we;
    always @(posedge clk or negedge rst_n)
        if (!rst_n)
            state <= `BUS_STATE_IDLE;
        else
            state <= nx_state;

    always @(*) begin
        case (state)
            `BUS_STATE_IDLE: begin
                if (cpu_addr) begin
                    nx_state = `BUS_STATE_SETUP;
                end else begin
                    nx_state = `BUS_STATE_IDLE;
                end
            end
            `BUS_STATE_SETUP: begin
                nx_state = `BUS_STATE_PENABLE;
            end
            `BUS_STATE_PENABLE: begin
                if (slv_ready | cpu_flush_bus) begin
                    nx_state = `BUS_STATE_IDLE;
                end else begin
                    nx_state = `BUS_STATE_PENABLE;
                end
            end
            default: begin
                nx_state = `BUS_STATE_IDLE;
            end
        endcase
    end
endmodule