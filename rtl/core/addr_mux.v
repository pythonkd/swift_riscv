/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-08-08 11:36:08
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-19 22:24:28
 * @FilePath: /swift_riscv/rtl/core/addr_mux.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */

module addr_mux(
    input extern_data_ready,
    input [`REG_WIDTH - 1: 0]instruction_addr,
    input mem_req_valid,
    input [`REG_WIDTH - 1: 0]mem_addr,
    input [`REG_WIDTH - 1: 0]mem_wr_data,
    input [`REG_WIDTH - 1:0]external_to_cpu_rd_data,
    input [`REG_WIDTH - 1: 0]ilm_to_cpu_data,
    input [`REG_WIDTH - 1: 0]dlm_to_cpu_data,
    input [`REG_WIDTH - 1: 0]mtimer_to_cpu_data,
    input [`REG_WIDTH - 1: 0]clint_to_cpu_data,
    input data_we,
    output reg cpu_wr_dlm_en,
    output reg cpu_wr_ilm_en,
    output reg cpu_wr_external_en,
    output reg cpu_wr_mtimer_en,
    output reg cpu_wr_clint_en,
    output bus_stall_cpu,
    output bus_stall_if,
    output instruction_valid,
    output mem_rd_valid,
    output reg [`REG_WIDTH - 1: 0]instruction,
    output reg [`REG_WIDTH - 1:0]mem_rd_data,
    output reg [`REG_WIDTH - 1: 0]cpu_to_ilm_rd_addr,
    output reg [`REG_WIDTH - 1: 0]cpu_to_ilm_wr_addr,
    output reg [`REG_WIDTH - 1: 0]cpu_to_ilm_data,
    output reg [`REG_WIDTH - 1: 0]cpu_to_dlm_addr,
    output reg [`REG_WIDTH - 1: 0]cpu_to_dlm_data,
    output reg [`REG_WIDTH - 1: 0]cpu_to_external_addr,
    output reg [`REG_WIDTH - 1: 0]cpu_to_external_data,
    output reg[`REG_WIDTH - 1: 0]cpu_to_mtimer_addr,
    output reg[`REG_WIDTH - 1: 0]cpu_to_mtimer_data,
    output reg[`REG_WIDTH - 1: 0]cpu_to_clint_addr,
    output reg[`REG_WIDTH - 1: 0]cpu_to_clint_data
);
    wire mem_need_external;
    wire if_need_external;
    reg  external_grant_mem;

    assign mem_need_external = (mem_addr >= `CLINT_END_ADDR);
    assign if_need_external  = (instruction_addr >= `ILM_END_ADDR);

    assign bus_stall_cpu = (if_need_external && ~extern_data_ready);
    assign bus_stall_if = mem_need_external;
    assign instruction_valid = if_need_external ? extern_data_ready: 1'b1;
    assign mem_rd_valid = mem_need_external && (~data_we) ? extern_data_ready: 1'b1;
    always @(*) begin
        if(mem_need_external) begin
            external_grant_mem = 1'b1;
        end else begin
            external_grant_mem = 1'b0;
        end
    end

    always @(*)
        if (instruction_addr < `ILM_END_ADDR) begin
            cpu_to_ilm_rd_addr = instruction_addr;
            cpu_to_external_addr = 0;
            instruction = ilm_to_cpu_data;
        end else begin
            if (~external_grant_mem)
                instruction = external_to_cpu_rd_data;
        end

    always @(*) begin
        cpu_wr_ilm_en = 0;
        cpu_wr_dlm_en = 0;
        cpu_wr_external_en = 0;
        if (mem_req_valid) begin
            if ((mem_addr < `ILM_END_ADDR) && data_we) begin
                cpu_to_ilm_wr_addr = mem_addr - `ILM_ADDR_BASE;
                cpu_wr_ilm_en = data_we;
                cpu_to_ilm_data = mem_wr_data;
            end else if(mem_addr < `DLM_END_ADDR) begin
                cpu_to_dlm_addr = mem_addr - `DLM_ADDR_BASE;
                cpu_wr_dlm_en = data_we;
                cpu_to_dlm_data = mem_wr_data;
                mem_rd_data = dlm_to_cpu_data;
            end else if(mem_addr < `MTIMER_END_ADDR) begin
                cpu_to_mtimer_addr = mem_addr;
                cpu_wr_mtimer_en = data_we;
                cpu_to_mtimer_data = mem_wr_data;
                mem_rd_data = mtimer_to_cpu_data;
            end else if(mem_addr < `CLINT_END_ADDR) begin
                cpu_to_clint_addr = mem_addr;
                cpu_wr_clint_en = data_we;
                cpu_to_clint_data = mem_wr_data;
                mem_rd_data = clint_to_cpu_data;
            end else begin
                if (external_grant_mem) begin
                    mem_rd_data = external_to_cpu_rd_data;
                end
                cpu_to_external_addr = mem_addr;
                cpu_wr_external_en = data_we;
                cpu_to_external_data = mem_wr_data;
            end
        end
    end

    always @(*) begin
        cpu_to_external_addr = {`REG_WIDTH{1'b0}};
        cpu_to_external_data = {`REG_WIDTH{1'b0}};
        cpu_wr_external_en   = 1'b0;
        if(external_grant_mem) begin
            cpu_to_external_addr = mem_addr;
            cpu_to_external_data = mem_wr_data;
            cpu_wr_external_en   = data_we;
        end 
        else if(if_need_external) begin
            cpu_to_external_addr = instruction_addr;
            cpu_wr_external_en   = 1'b0;
        end
    end

endmodule