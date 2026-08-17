/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-08-13 21:37:12
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-16 16:03:01
 * @FilePath: /swift_riscv/rtl/flash/flash.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */

module flash(
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
    localparam FLASH_ADDR_WIDTH = 18;
    localparam FLASH_MEM_DEPTH = 18'h20000;

    wire flash_wr;
    wire flash_rd;
    reg flash_rd_ready;
    reg flash_wr_ready;
    reg [`REG_WIDTH-1: 0]local_mem[0:FLASH_MEM_DEPTH - 1];

    assign slv_ready = slv_we ? flash_wr_ready : flash_rd_ready;
    assign flash_wr = slv_sel && slv_we && ~slv_penable;
    assign flash_rd = slv_sel && (!slv_we) && slv_penable;

    always @(posedge clk or negedge rst_n)
        if (!rst_n) begin
            flash_wr_ready <= 0;
        end else if(flash_wr) begin
            local_mem[slv_addr[FLASH_ADDR_WIDTH+1:2]] <= slv_wdata;
            flash_wr_ready <= 1'b1;
        end else begin
            flash_wr_ready <= 1'b0;
        end
    
    always @(*)
        if (!rst_n) begin
            flash_rd_ready = 0;
        end else if (flash_rd) begin
            slv_rdata = local_mem[slv_addr[FLASH_ADDR_WIDTH+1:2]];
            flash_rd_ready = 1'b1;
        end else begin
            flash_rd_ready = 1'b0;
        end

endmodule