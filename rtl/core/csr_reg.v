/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-07-27 21:32:32
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-04 22:49:58
 * @FilePath: /swift_riscv/rtl/core/csr_reg.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */

module csr_reg(
    // input
    input clk,
    input rst_n,
    input ex_we,
    input [`INST_CSR_WIDTH - 1: 0]csr_rd_addr,
    input [`INST_CSR_WIDTH - 1: 0]csr_wr_addr,
    input [`REG_WIDTH - 1: 0]csr_wr_data,
    input clint_we,
    input [`INST_CSR_WIDTH - 1: 0]clint_rd_addr,
    input [`INST_CSR_WIDTH - 1: 0]clint_wr_addr,
    input [`REG_WIDTH - 1: 0]clint_wr_data,
    input [`CPU_ERR_WIDTH-1: 0]cpu_err,
    input ecall_except,
    input ebreak_except,
    input ext_int,
    input mtimer_int,
    // output
    output global_int_en,
    output mtimer_int_en,
    output ex_int_en,
    output reg [`REG_WIDTH - 1: 0]csr_rd_data,
    output reg [`REG_WIDTH - 1: 0]clint_rd_data,
    output reg [`REG_WIDTH - 1: 0]csr_mtvec_data
);
    reg [`REG_WIDTH - 1: 0]mepc;
    reg [`REG_WIDTH - 1: 0]mcause;
    reg [`REG_WIDTH - 1: 0]mstatus;
    reg [`REG_WIDTH - 1: 0]mtvec;
    reg [`REG_WIDTH - 1: 0]mtval;
    reg [`REG_WIDTH - 1: 0]mie;
    reg [`REG_WIDTH*2 - 1: 0]cycle;
    reg [`REG_WIDTH - 1: 0]mscratch;

    assign global_int_en = mstatus[3];
    assign mtimer_int_en = mie[7];
    assign ex_int_en = mstatus[7];

    always@(posedge clk or negedge rst_n) begin
        if (!rst_n)
            cycle <= 0;
        else
            cycle <= cycle + 1'b1;
    end

    always@(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mepc <= `REG_WIDTH'b0;
            mcause <= `REG_WIDTH'b0;
            mstatus <= `REG_WIDTH'b0;
            mtvec <= `REG_WIDTH'b0;
            mie <= `REG_WIDTH'b0;
            mtval <= `REG_WIDTH'b0;
            mscratch <= `REG_WIDTH'b0;
        end else if(clint_we) begin
            case(clint_wr_addr)
                `CSR_MTVEC: mtvec <= clint_wr_data;
                `CSR_MCAUSE: mcause <= clint_wr_data;
                `CSR_MEPC: mepc <= clint_wr_data;
                `CSR_MIE: mie <= clint_wr_data;
                `CSR_MSTATUS: mstatus <= clint_wr_data;
                `CSR_MSCRATCH: mscratch <= clint_wr_data;
            endcase
        end else if (ex_we) begin
            case(csr_wr_addr)
                `CSR_MTVEC: mtvec <= csr_wr_data;
                `CSR_MCAUSE: mcause <= csr_wr_data;
                `CSR_MEPC: mepc <= csr_wr_data;
                `CSR_MIE: mie <= csr_wr_data;
                `CSR_MSTATUS: mstatus <= csr_wr_data;
                `CSR_MSCRATCH: mscratch <= csr_wr_data;
            endcase
        end
    end

    always @(*) begin
        if((clint_rd_addr == csr_wr_addr) && (ex_we)) begin
            csr_rd_data = csr_wr_data;
        end else begin
            case(clint_rd_addr)
                `CSR_MTVEC: csr_rd_data = mtvec;
                `CSR_MCAUSE: csr_rd_data = mcause;
                `CSR_MEPC: csr_rd_data = mepc;
                `CSR_MIE: csr_rd_data = mie;
                `CSR_MSTATUS: csr_rd_data = mstatus;
                `CSR_MSCRATCH: csr_rd_data = mscratch;
                `CSR_CYCLE: csr_rd_data = cycle[31:0];
                `CSR_CYCLEH: csr_rd_data = cycle[63: 32];
                default: csr_rd_data = `REG_WIDTH'b0;
            endcase
        end
    end

    always @(*) begin
        if((csr_rd_addr == clint_wr_addr) && (clint_we)) begin
            clint_rd_data = clint_wr_data;
        end else begin
            case(csr_rd_addr)
                `CSR_MTVEC: clint_rd_data = mtvec;
                `CSR_MCAUSE: clint_rd_data = mcause;
                `CSR_MEPC: clint_rd_data = mepc;
                `CSR_MIE: clint_rd_data = mie;
                `CSR_MSTATUS: clint_rd_data = mstatus;
                `CSR_MSCRATCH: clint_rd_data = mscratch;
                `CSR_CYCLE: clint_rd_data = cycle[31:0];
                `CSR_CYCLEH: clint_rd_data = cycle[63: 32];
                default: clint_rd_data = `REG_WIDTH'b0;
            endcase
        end
    end

endmodule