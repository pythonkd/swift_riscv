/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-08-08 10:59:04
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-17 21:57:24
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
    output reg p_enable,
    output mst_we,
    output [`BUS_ADDR_WIDTH -1 : 0]mst_addr,
    output [`BUS_ADDR_DATA_WIDTH - 1: 0]mst_wdata,
    output [`BUS_ADDR_DATA_WIDTH - 1: 0]cpu_rd_data,
    output extern_data_ready
);
    reg [`BUS_STATE_WIDTH -1 : 0]state;
    assign mst_addr = cpu_addr;
    assign mst_wdata = cpu_wdata;
    assign mst_we = cpu_we;
    assign cpu_rd_data = (slv_ready && p_enable) ? slv_rd_data : 0;
    assign extern_data_ready = (slv_ready && p_enable) ? 1 : 0;

    always@(posedge clk or negedge rst_n)
        if (!rst_n) begin
            state <= `BUS_STATE_IDLE;
            p_enable <= 1'b0;
        end
        else begin
            case(state)
                `BUS_STATE_IDLE: begin
                    p_enable    <= 1'b0;
                    if (cpu_addr) begin
                        state       <= `BUS_STATE_SETUP;
                    end
                end
                `BUS_STATE_SETUP: begin
                    p_enable    <= 1'b1;
                    state       <= `BUS_STATE_PENABLE;
                end
                `BUS_STATE_PENABLE: begin
                    if (slv_ready) begin
                        state <= `BUS_STATE_IDLE;
                        p_enable <= 1'b0;
                    end else begin
                        state <= state;
                        p_enable <= p_enable;
                    end
                end
                default: begin
                    state <= `BUS_STATE_IDLE;
                end
            endcase
        end
endmodule