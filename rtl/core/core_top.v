/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-07-12 16:12:15
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-04 22:51:44
 * @FilePath: /swift_riscv/rtl/core/core_top.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */

module core_top (
    input clk,
    input mtimer_clk,
    input rst_n,
    input uart_int,
    input [`REG_WIDTH - 1: 0]slv_r_data,
    input slv_ready,
    output p_enable,
    output mst_we,
    output [`REG_WIDTH - 1: 0]mst_addr,
    output [`REG_WIDTH - 1: 0]mst_wdata
);

    wire stop;
    wire reg_we;
    wire mem_we;
    wire csr_we;
    wire jump_en;
    wire div_op_start;
    wire alu_hold_flag;
    wire data_err;
    wire instruction_err;
    wire instruction_decode_err;
    wire ecall_except;
    wire ebreak_except;
    wire exception;
    wire mret_occurred;
    wire mret_jump;
    wire [`REG_WIDTH - 1:0]mem_rd_data;
    wire [`REG_WIDTH - 1:0]mem_addr;
    wire [`REG_WIDTH - 1:0]mem_wr_data;
    wire [`INST_RD_WIDTH  - 1: 0]rd_index;
    wire [`REG_WIDTH - 1: 0]rd_data;
    wire [`REG_WIDTH - 1: 0]csr_rd_data;
    wire [`REG_WIDTH - 1: 0]csr_wr_data;
    wire [`INST_JUMP_WIDTH - 1: 0]jump;
    wire [`REG_WIDTH - 1: 0]cur_pc;
    wire [`REG_WIDTH - 1: 0]nx_pc;
    wire [`INST_WIDTH-1: 0]instruction;
    wire [`REG_WIDTH - 1: 0]imm;
    wire [`INST_RS1_WIDTH  - 1: 0]rs1_index;
    wire [`INST_RS1_WIDTH  - 1: 0]rs2_index;
    wire [`REG_WIDTH - 1: 0]rs1_data;
    wire [`REG_WIDTH - 1: 0]rs2_data;
    wire [`REG_WIDTH - 1: 0]csr_mtvec;
    wire [`REG_WIDTH - 1: 0]csr_mepc;
    wire [`INST_CSR_WIDTH - 1: 0]csr_rd_addr;
    wire [`INST_CSR_WIDTH - 1: 0]csr_wr_addr;
    wire global_int_en;
    wire mtimer_int_en;
    wire ex_int_en;
    wire clint_we;
    wire [`INST_CSR_WIDTH - 1: 0]clint_rd_addr;
    wire [`INST_CSR_WIDTH - 1: 0]clint_wr_addr;
    wire [`REG_WIDTH - 1: 0]clint_wr_data;
    wire [`REG_WIDTH - 1: 0]clint_rd_data;
    wire [`INTERRUPT_MAX_NUM-1: 0]ex_int_src;
    wire mtimer_int;
    wire ex_int;
    wire sync_except;
    wire csr_mcause_int;
    wire [`REG_WIDTH - 1: 0]ilm_to_cpu_data;
    wire [`REG_WIDTH - 1: 0]dlm_to_cpu_data;
    wire cpu_w_dlm_en;
    wire cpu_w_ilm_en;
    wire cpu_w_external_en;
    wire [`REG_WIDTH - 1: 0]cpu_to_ilm_addr;
    wire [`REG_WIDTH - 1: 0]cpu_to_ilm_data;
    wire [`REG_WIDTH - 1: 0]cpu_to_dlm_addr;
    wire [`REG_WIDTH - 1: 0]cpu_to_dlm_data;
    wire [`REG_WIDTH - 1: 0]cpu_to_external_addr;
    wire [`REG_WIDTH - 1: 0]cpu_to_external_data;
    wire [`REG_DATA_DEPTH - 1: 0]external_to_cpu_rd_data;
    wire bus_hold_cpu;
    wire hold_cpu;

    assign ex_int = |ex_int_src;
    assign sync_except = instruction_err || instruction_decode_err || ebreak_except || ecall_except || data_err;
    assign csr_mcause_int = ex_int || (mtimer_int & mtimer_int_en);
    assign exception = sync_except || (csr_mcause_int & global_int_en);
    assign hold_cpu = bus_hold_cpu | alu_hold_flag;
    pc_reg u_pc_reg(
        //input
        .clk(clk),
        .rst_n(rst_n),
        .nx_pc(nx_pc),
        //output
        .pc(cur_pc),
        .stop(stop)
    );

    pc_mux u_pc_mux(
        // input
        .stop(stop),
        .pc(cur_pc),
        .imm(imm),
        .rs1_data(rs1_data),
        .jump(jump),
        .jump_en(jump_en),
        .hold_flag(hold_cpu),
        .csr_mtvec(csr_mtvec),
        .csr_mepc(csr_mepc),
        .exception(exception),
        .mret_jump(mret_jump),
        //output
        .nx_pc(nx_pc)
    );
    
    i_lm u_ilm(
        //input
        .clk(clk),
        .instruction_w_data(cpu_to_ilm_data),
        .instruction_we(cpu_w_ilm_en),
        .addr(cpu_to_ilm_addr),
        //output
        .instruction(ilm_to_cpu_data),
        .instruction_err(instruction_err)
    );

    d_lm u_dlm(
        //input
        .clk(clk),
        .rst_n(rst_n),
        .mem_addr(cpu_to_dlm_addr),
        .mem_wr_data(cpu_to_dlm_data),
        .mem_we(cpu_w_dlm_en),
        //output
        .mem_rd_data(dlm_to_cpu_data),
        .data_err(data_err)
    );

    reg_file u_reg_file(
        //input
        .clk(clk),
        .rst_n(rst_n),
        .reg_we(reg_we),
        .rd_index(rd_index),
        .rd_data(rd_data),
        .rs1_index(rs1_index),
        .rs2_index(rs2_index),
        //output
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    decode u_decode(
        //input
        .instruction(instruction),
        //output
        .csr_index(csr_rd_addr),
        .rd_index(rd_index),
        .rs1_index(rs1_index),
        .rs2_index(rs2_index),
        .instruction_decode_err(instruction_decode_err)
    );

    alu u_alu(
        //input
        .clk(clk),
        .rst_n(rst_n),
        .instruction(instruction),
        .instruction_addr(cur_pc),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .csr_rd_data(csr_rd_data),
        .mem_rd_data(mem_rd_data),
        //output
        .reg_we(reg_we),
        .mem_we(mem_we),
        .csr_we(csr_we),
        .jump_en(jump_en),
        .div_op_start(div_op_start),
        .alu_hold_flag(alu_hold_flag),
        .ecall_except(ecall_except),
        .ebreak_except(ebreak_except),
        .jump(jump),
        .imm(imm), 
        .rd_data(rd_data),
        .mem_wr_data(mem_wr_data),
        .mem_addr(mem_addr),
        .csr_wr_data(csr_wr_data),
        .csr_wr_addr(csr_wr_addr),
        .mret_occurred(mret_occurred)
    );

    csr_reg u_csr_reg(
        // input
        .clk(clk),
        .rst_n(rst_n),
        .ex_we(csr_we),
        .csr_rd_addr(csr_rd_addr),
        .csr_wr_addr(csr_wr_addr),
        .csr_wr_data(csr_wr_data),
        .clint_we(clint_we),
        .clint_rd_addr(clint_rd_addr),
        .clint_wr_addr(clint_wr_addr),
        .clint_wr_data(clint_wr_data),
        .ecall_except(ecall_except),
        .ebreak_except(ebreak_except),
        .instruction_decode_err(instruction_decode_err),
        .data_err(data_err),
        .ex_int(ex_int),
        .mtimer_int(mtimer_int),
        .mret_occurred(mret_occurred),
        //output
        .global_int_en(global_int_en),
        .mtimer_int_en(mtimer_int_en),
        .ex_int_en(ex_int_en),
        .mret_jump(mret_jump),
        .csr_rd_data(csr_rd_data),
        .clint_rd_data(clint_rd_data),
        .csr_mtvec_data(csr_mtvec),
        .csr_mepc_data(csr_mepc)
        
    );

    int_switch u_int_switch(
        // input
        .uart_int(uart_int),
        // output
        .int_src(ex_int_src)
    );

    mtimer u_mtimer(
        // input
        .mtimer_clk(mtimer_clk),
        .rst_n(rst_n),
        // output
        .mtimer_int(mtimer_int)
    );

    addr_mux u_addr_mux(
        // input
        .instruction_addr(cur_pc),
        .mem_addr(mem_addr),
        .mem_wr_data(mem_wr_data),
        .external_to_cpu_rd_data(external_to_cpu_rd_data),
        .ilm_to_cpu_data(ilm_to_cpu_data),
        .dlm_to_cpu_data(dlm_to_cpu_data),
        .data_we(mem_we),
        // output
        .instruction(instruction),
        .cpu_w_dlm_en(cpu_w_dlm_en),
        .cpu_w_ilm_en(cpu_w_ilm_en),
        .cpu_w_external_en(cpu_w_external_en),
        .mem_rd_data(mem_rd_data),
        .cpu_to_ilm_addr(cpu_to_ilm_addr),
        .cpu_to_ilm_data(cpu_to_ilm_data),
        .cpu_to_dlm_addr(cpu_to_dlm_addr),
        .cpu_to_dlm_data(cpu_to_dlm_data),
        .cpu_to_external_addr(cpu_to_external_addr),
        .cpu_to_external_data(cpu_to_external_data)
    );

    cpu_to_bus u_cpu_to_bus(
        // input
        .clk(clk),
        .rst_n(rst_n),
        .cpu_addr(cpu_to_external_addr),
        .cpu_wdata(cpu_to_external_data),
        .cpu_we(cpu_w_external_en),
        .slv_r_data(slv_r_data),
        .slv_ready(slv_ready),
        // output
        .p_enable(p_enable),
        .mst_we(mst_we),
        .mst_addr(mst_addr),
        .mst_wdata(mst_wdata),
        .cpu_r_data(external_to_cpu_rd_data),
        .bus_hold_cpu(bus_hold_cpu)
    );

    clint u_clint(
        .interrupts(ex_int_src)
    );
endmodule