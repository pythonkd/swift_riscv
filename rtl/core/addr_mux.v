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
    input ex_bus_idle,
    output cpu_wr_dlm_en,
    output cpu_wr_ilm_en,
    output cpu_wr_external_en,
    output cpu_wr_mtimer_en,
    output cpu_wr_clint_en,
    output bus_stall_cpu,
    output bus_stall_ex,
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
    reg [`REG_WIDTH -1: 0]cacheline_align_pc;

    wire inst_dirty_status;
    wire inst_hit;
    wire inst_read_en;

    reg [`REG_WIDTH -1: 0]inst_cache_read_data;
    wire inst_update_cacheline;
    wire [2:0]inst_cache_state;
    wire [`REG_WIDTH -1: 0]cpu_to_icache_addr;
    reg [7:0] counter;
    reg [`REG_WIDTH -1: 0]cache_request_ex_addr;
    reg [`REG_WIDTH -1: 0]nx_cache_request_ex_addr;
    reg [`CACHELINE_SIZE * 8 -1: 0]cacheline_data;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            cache_request_ex_addr <= `REG_WIDTH'b0;
        else
            cache_request_ex_addr <= nx_cache_request_ex_addr;
    end

    always @(*) begin
        if (inst_cache_state == `CACHE_IDLE) begin
            nx_cache_request_ex_addr = cpu_to_icache_addr;
        end else if (inst_cache_state == `CACHE_WAIT_UPDATE) begin
            nx_cache_request_ex_addr = cacheline_align_pc + counter;
        end else begin
            nx_cache_request_ex_addr = 0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 7'b0;
        end else if (inst_cache_state == `CACHE_IDLE) begin
            counter <= 7'b0;
        end else if ((inst_cache_state == `CACHE_WAIT_UPDATE) & extern_data_ready & (counter < (`CACHELINE_SIZE))) begin
            counter <= counter + 7'd4;
        end else if ((inst_cache_state == `CACHE_WAIT_UPDATE) & extern_data_ready & (counter == (`CACHELINE_SIZE))) begin
            counter <= 7'b0;
        end else begin
            counter <= counter;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cacheline_data <= 'b0;
        end else begin
            case (counter)
                7'd0: cacheline_data[31:0] <= external_to_cpu_rd_data;
                7'd4: cacheline_data[63:32] <= external_to_cpu_rd_data;
                7'd8: cacheline_data[95:64] <= external_to_cpu_rd_data;
                7'd12: cacheline_data[127:96] <= external_to_cpu_rd_data;
                7'd16: cacheline_data[159:128] <= external_to_cpu_rd_data;
                7'd20: cacheline_data[191:160] <= external_to_cpu_rd_data;
                7'd24: cacheline_data[223:192] <= external_to_cpu_rd_data;
                7'd28: cacheline_data[255:224] <= external_to_cpu_rd_data;
                default: cacheline_data <= cacheline_data;
            endcase
        end
    end
    cache #(
        .WAYS(4),
        .CACHELINE_SIZE(`CACHELINE_SIZE),
        .CACHESIZE(`INST_CACHESIZE)
    ) u_icache (
        // input
        .clk(clk),
        .rst_n(rst_n),
        .update_cacheline(inst_update_cacheline),
        .cacheline_data(cacheline_data),
        .current_pc(cpu_to_icache_addr),
        .read_en(inst_read_en),
        .write_en(1'b0),
        .write_data('b0),
        .size(2'b10),
        .save_dirty_data_done(1'b0),
        // output
        .hit(inst_hit),
        .read_data(inst_cache_read_data),
        .dirty_status(inst_dirty_status),
        .cur_state(inst_cache_state),
        .dirty_data()
    );
    assign external_grant_mem = mem_need_external & mem_req_valid;
    assign inst_update_cacheline = (counter == (`CACHELINE_SIZE)) & extern_data_ready & (inst_cache_state == `CACHE_WAIT_UPDATE);
    assign if_need_external  = instruction_addr >= `ILM_END_ADDR;
    assign bus_stall_cpu = if_need_external & !inst_hit;
    assign instruction = !if_need_external ? ilm_to_cpu_inst_data: inst_hit ? inst_cache_read_data : 0;
    assign cpu_to_icache_addr = if_need_external ? instruction_addr : 0;
    assign cpu_to_ilm_rd_inst_addr = !if_need_external ? instruction_addr : 0;
    assign cacheline_align_pc = cpu_to_icache_addr & ~(`CACHELINE_SIZE - 1);
    assign instruction_valid = !if_need_external ? 1'b1 : inst_hit;
    assign inst_read_en = if_need_external;

    assign mem_need_external = (mem_addr >= `CLINT_END_ADDR);
    assign bus_stall_ex = mem_need_external & !extern_data_ready;
    assign mem_rd_valid = !mem_need_external ? 1'b1 : extern_data_ready;
    assign cpu_wr_external_en = external_grant_mem ? data_we : 1'b0;
    assign cpu_to_external_addr = external_grant_mem ? mem_addr :
                                    (inst_cache_state == `CACHE_WAIT_UPDATE) ? cache_request_ex_addr : {`REG_WIDTH{1'b0}};
    // mem type: cpu --> ilm
    assign cpu_to_external_data = external_grant_mem ? mem_wr_data : {`REG_WIDTH{1'b0}};
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
endmodule