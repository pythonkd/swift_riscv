/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-08-08 11:36:08
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-09-01 22:52:01
 * @FilePath: /swift_riscv/rtl/core/addr_mux.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */

module addr_mux(
    input clk,
    input rst_n,
    input extern_data_ready,
    input [`REG_WIDTH - 1: 0]instruction_addr,
    input mem_req_valid,
    input [`STRB_WIDTH - 1: 0]mem_strb,
    input [`REG_WIDTH - 1: 0]mem_addr,
    input [`REG_WIDTH - 1: 0]mem_wr_data,
    input [`REG_WIDTH - 1:0]external_to_cpu_rd_data,
    input [`REG_WIDTH - 1: 0]ilm_to_cpu_inst_data,
    input [`REG_WIDTH - 1: 0]ilm_to_cpu_mem_data,
    input [`REG_WIDTH - 1: 0]dlm_to_cpu_data,
    input [`REG_WIDTH - 1: 0]mtimer_to_cpu_data,
    input [`REG_WIDTH - 1: 0]clint_to_cpu_data,
    input data_we,
    output cpu_wr_dlm_en,
    output cpu_wr_ilm_en,
    output cpu_wr_external_en,
    output cpu_wr_mtimer_en,
    output cpu_wr_clint_en,
    output bus_stall_cpu,
    output bus_stall_if,
    output instruction_valid,
    output mem_rd_valid,
    output [`REG_WIDTH - 1: 0]instruction,
    output [`REG_WIDTH - 1:0]mem_rd_data,
    output [`REG_WIDTH - 1: 0]cpu_to_ilm_rd_inst_addr,
    output [`REG_WIDTH - 1: 0]cpu_to_ilm_rd_mem_addr,
    output [`REG_WIDTH - 1: 0]cpu_to_ilm_wr_addr,
    output [`REG_WIDTH - 1: 0]cpu_to_ilm_data,
    output [`STRB_WIDTH - 1: 0]cpu_to_dlm_strb,
    output [`REG_WIDTH - 1: 0]cpu_to_dlm_addr,
    output [`REG_WIDTH - 1: 0]cpu_to_dlm_data,
    output [`REG_WIDTH - 1: 0]cpu_to_external_addr,
    output [`REG_WIDTH - 1: 0]cpu_to_external_data,
    output [`REG_WIDTH - 1: 0]cpu_to_mtimer_addr,
    output [`REG_WIDTH - 1: 0]cpu_to_mtimer_data,
    output [`REG_WIDTH - 1: 0]cpu_to_clint_addr,
    output [`REG_WIDTH - 1: 0]cpu_to_clint_data
);
    wire mem_need_external;
    wire if_need_external;
    wire external_grant_mem;

    assign mem_need_external = (mem_addr >= `CLINT_END_ADDR);
    assign if_need_external  = (instruction_addr >= `ILM_END_ADDR);
    assign external_grant_mem = mem_need_external && mem_req_valid ? 1'b1: 1'b0;

    assign bus_stall_cpu = (if_need_external && ~extern_data_ready);
    assign bus_stall_if = mem_need_external;
    assign instruction_valid = if_need_external ? extern_data_ready: 1'b1;
    assign mem_rd_valid = mem_need_external && (~data_we) ? extern_data_ready: 1'b1;

    assign cpu_wr_external_en = external_grant_mem ? data_we : 1'b0;
    assign cpu_to_external_addr = external_grant_mem ? mem_addr :
                                    if_need_external ? instruction_addr : {`REG_WIDTH{1'b0}};
    assign cpu_to_external_data = external_grant_mem ? mem_wr_data : {`REG_WIDTH{1'b0}};

    // inst type
    assign instruction = !external_grant_mem && if_need_external ? external_to_cpu_rd_data : ilm_to_cpu_inst_data;
    assign cpu_to_ilm_rd_inst_addr = !external_grant_mem && !if_need_external ? instruction_addr : 0;

    // mem type: cpu --> ilm
    wire cpu_to_ilm;
    assign cpu_to_ilm = mem_req_valid && (~mem_need_external) && (mem_addr < `ILM_END_ADDR);
    assign cpu_wr_ilm_en = cpu_to_ilm && data_we;
    assign cpu_to_ilm_wr_addr = cpu_wr_ilm_en ? mem_addr - `ILM_ADDR_BASE : 0;
    assign cpu_to_ilm_rd_mem_addr = cpu_to_ilm && !data_we ? mem_addr - `ILM_ADDR_BASE : 0;
    assign cpu_to_ilm_data = cpu_wr_ilm_en ? mem_wr_data: 0;

    // mem type: cpu --> dlm
    wire cpu_to_dlm;
    assign cpu_to_dlm = mem_req_valid  && (mem_addr >= `ILM_END_ADDR) && (mem_addr < `DLM_END_ADDR);
    assign cpu_wr_dlm_en = cpu_to_dlm && data_we;
    assign cpu_to_dlm_strb = cpu_to_dlm  ? mem_strb : `STRB_WIDTH'b1111;
    assign cpu_to_dlm_addr = cpu_to_dlm ? mem_addr - `DLM_ADDR_BASE : 0;
    assign cpu_to_dlm_data = cpu_wr_dlm_en ? mem_wr_data : 0;
    // mem type: cpu -> mtimer
    wire cpu_to_mtimer;
    assign cpu_to_mtimer = mem_req_valid && (mem_addr >= `DLM_END_ADDR) && (mem_addr < `MTIMER_END_ADDR);
    assign cpu_wr_mtimer_en = cpu_to_mtimer && data_we;
    assign cpu_to_mtimer_addr = cpu_to_mtimer ? mem_addr - `MTIMER_ADDR_BASE: 0;
    assign cpu_to_mtimer_data = cpu_wr_mtimer_en ? mem_wr_data : 0;
    // mem type: cpu -> clint
    wire cpu_to_clint;
    assign cpu_to_clint = mem_req_valid && (mem_addr >= `MTIMER_END_ADDR) && (mem_addr < `CLINT_END_ADDR);
    assign cpu_wr_clint_en = cpu_to_clint && data_we;
    assign cpu_to_clint_addr = cpu_to_clint ? mem_addr - `CLINT_ADDR_BASE: 0;
    assign cpu_to_clint_data = cpu_wr_clint_en ? mem_wr_data: 0;

    assign mem_rd_data = external_grant_mem ? external_to_cpu_rd_data:
                cpu_to_ilm ? ilm_to_cpu_mem_data:
                cpu_to_dlm ? dlm_to_cpu_data:
                cpu_to_mtimer ? mtimer_to_cpu_data:
                cpu_to_clint ? clint_to_cpu_data: 0;

    // cache u_dcache(

    // );
endmodule