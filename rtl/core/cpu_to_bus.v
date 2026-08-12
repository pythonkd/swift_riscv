/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-08-08 10:59:04
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-12 22:25:27
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
    output reg mst_we,
    output reg [`BUS_ADDR_WIDTH -1 : 0]mst_addr,
    output reg [`BUS_ADDR_DATA_WIDTH - 1: 0]mst_wdata,
    output reg [`BUS_ADDR_DATA_WIDTH - 1: 0]cpu_rd_data,
    output reg bus_hold_cpu
);
    reg [`BUS_STATE_WIDTH -1 : 0]state;
    
    always@(posedge clk or negedge rst_n)
        if (!rst_n) begin
            state <= `BUS_STATE_IDLE;
            p_enable <= 1'b0;
            bus_hold_cpu <= 1'b0;
        end
        else begin
            case(state)
                `BUS_STATE_IDLE: begin
                    p_enable    <= 1'b0;
                    bus_hold_cpu<= 1'b0;
                    if (cpu_addr) begin
                        state       <= BUS_STATE_SETUP;
                        mst_addr    <= cpu_addr;
                        mst_wdata   <= cpu_wdata;
                        mst_we      <= cpu_we;
                        bus_hold_cpu<= 1'b1;
                    end else begin
                        state <= state;
                    end
                end
                `BUS_STATE_SETUP: begin
                    p_enable <= 1'b1;
                    if (slv_ready) begin
                        state <= `BUS_STATE_IDLE;
                        bus_hold_cpu <= 1'b0;
                        cpu_rd_data <= slv_rd_data;
                        p_enable <= 1'b0;
                    end else begin
                        state <= state;
                    end
                end
                default: begin
                    state <= `BUS_STATE_IDLE;
                end
            endcase
        end
endmodule