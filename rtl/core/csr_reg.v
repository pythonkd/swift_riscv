/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-07-27 21:32:32
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-16 00:41:22
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
    input ecall_except,
    input ebreak_except,
    input instruction_decode_err,
    input data_err,
    input ex_int,
    input mtimer_int,
    input mret_occurred,
    // output
    output global_int_en,
    output mtimer_int_en,
    output ex_int_en,
    output reg mret_jump,
    output reg [`REG_WIDTH - 1: 0]csr_rd_data,
    output reg [`REG_WIDTH - 1: 0]clint_rd_data,
    output reg [`REG_WIDTH - 1: 0]csr_mtvec_data,
    output reg [`REG_WIDTH - 1: 0]csr_mepc_data
);
    // mstatus
    localparam MIE_BIT    = 3;
    localparam MPIE_BIT   = 7;
    localparam MPP_HI     = 12;
    localparam MPP_LO     = 11;
    // mie
    localparam MIE_MSIE_BIT = 3;
    localparam MIE_MTIE_BIT = 7;
    localparam MIE_MEIE_BIT = 11;

    reg [`REG_WIDTH - 1: 0]mepc;
    reg [`REG_WIDTH - 1: 0]mcause;
    reg [`REG_WIDTH - 1: 0]mstatus;
    reg [`REG_WIDTH - 1: 0]mtvec;
    reg [`REG_WIDTH - 1: 0]mtval;
    reg [`REG_WIDTH - 1: 0]mie;
    reg [`REG_WIDTH*2 - 1: 0]cycle;
    reg [`REG_WIDTH - 1: 0]mscratch;
    wire       mstatus_mie;

    assign mstatus_mie  = mstatus[MIE_BIT];
    assign global_int_en = mstatus[MIE_BIT];
    assign mtimer_int_en = mie[MIE_MTIE_BIT];
    assign ex_int_en = mie[MIE_MEIE_BIT];
    assign csr_mtvec_data = mtvec;
    assign csr_mepc_data = mepc;

    // exception start
    always@(posedge clk or negedge rst_n) begin
        if (ebreak_except) begin
            mcause = {{1{1'b0}}, {20{1'b0}}, `EXCEPTION_CODE_BREAKPOINT};
            mstatus[MPIE_BIT] = mstatus_mie;
            mstatus[MPP_HI:MPP_LO] = `CPU_M_MODE;
            mstatus[MIE_BIT] = 1'b0;
        end else if(ecall_except) begin
            mcause = {{1{1'b0}}, {20{1'b0}}, `EXCEPTION_CODE_ECALL_M_MODE};
            mstatus[MPIE_BIT] = mstatus_mie;
            mstatus[MPP_HI:MPP_LO] = `CPU_M_MODE;
            mstatus[MIE_BIT] = 1'b0;
        end else if(instruction_decode_err) begin
            mcause = {{1{1'b0}}, {20{1'b0}}, `EXCEPTION_CODE_ILLEGAL_INSTRUCTION};
            mstatus[MPIE_BIT] = mstatus_mie;
            mstatus[MPP_HI:MPP_LO] = `CPU_M_MODE;
            mstatus[MIE_BIT] = 1'b0;
        end else if(global_int_en && ex_int_en && ex_int) begin
            mcause = {{1{1'b1}}, {20{1'b0}}, `EXCEPTION_CODE_EXTERNAL_INT};
            mstatus[MPIE_BIT] = mstatus_mie;
            mstatus[MPP_HI:MPP_LO] = `CPU_M_MODE;
            mstatus[MIE_BIT] = 1'b0;
        end else if(global_int_en  && mtimer_int_en && mtimer_int) begin
            mcause = {{1{1'b1}}, {20{1'b0}}, `EXCEPTION_CODE_MTIMER_INT};
            mstatus[MPIE_BIT] = mstatus_mie;
            mstatus[MPP_HI:MPP_LO] = `CPU_M_MODE;
            mstatus[MIE_BIT] = 1'b0;
        end
    end

    // except end
    always@(*) begin
        mret_jump <= 1'b0;
        if (mret_occurred) begin
            mstatus[MIE_BIT] = mstatus[MPIE_BIT];
            mret_jump <= 1'b1;
        end
    end

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