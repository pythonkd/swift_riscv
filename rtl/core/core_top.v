/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-07-12 16:12:15
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-07-31 23:16:25
 * @FilePath: /swift_riscv/rtl/core/core_top.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */

module core_top (
    input clk,
    input rst_n,
    input uart_int
);

    wire stop;
    wire reg_we;
    wire mem_we;
    wire csr_we;
    wire jump_en;
    wire div_op_start;
    wire hold_flag;
    wire data_err;
    wire instruction_err;
    wire instruction_decode_err;
    wire exception;
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
    wire [`CPU_ERR_WIDTH-1: 0]cpu_err;
    wire [`REG_WIDTH - 1: 0]imm;
    wire [`INST_RS1_WIDTH  - 1: 0]rs1_index;
    wire [`INST_RS1_WIDTH  - 1: 0]rs2_index;
    wire [`REG_WIDTH - 1: 0]rs1_data;
    wire [`REG_WIDTH - 1: 0]rs2_data;
    wire [`REG_WIDTH - 1: 0]csr_mtvec;
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
    [`INTERRUPT_MAX_NUM-1: 0]int_src;

    assign cpu_err = {{(`CPU_ERR_WIDTH - 3){1'b0}}, instruction_decode_err, data_err, instruction_err};
    pc_reg u_pc_reg(
        //input
        .clk(clk),
        .rst_n(rst_n),
        .nx_pc(nx_pc),
        .cpu_err(cpu_err),
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
        .hold_flag(hold_flag),
        .csr_mtvec(csr_mtvec),
        //output
        .nx_pc(nx_pc)
    );
    
    i_lm u_ilm(
        //input
        .pc(cur_pc),
        //output
        .instruction(instruction),
        .instruction_err(instruction_err)
    );

    d_lm u_dlm(
        //input
        .clk(clk),
        .rst_n(rst_n),
        .mem_addr(mem_addr),
        .mem_wr_data(mem_wr_data),
        .mem_we(mem_we),
        //output
        .mem_rd_data(mem_rd_data),
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
        .hold_flag(hold_flag),
        .reg_we(reg_we),
        .mem_we(mem_we),
        .csr_we(csr_we),
        .jump_en(jump_en),
        .div_op_start(div_op_start),
        .jump(jump),
        .imm(imm), 
        .rd_data(rd_data),
        .mem_wr_data(mem_wr_data),
        .mem_addr(mem_addr),
        .csr_wr_data(csr_wr_data),
        .csr_wr_addr(csr_wr_addr)
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
        //output
        .global_int_en(global_int_en),
        .mtimer_int_en(mtimer_int_en),
        .ex_int_en(ex_int_en),
        .csr_rd_data(csr_rd_data),
        .clint_rd_data(clint_rd_data)
    );

    int_switch u_int_switch(
        .uart_int(uart_int),
        .int_src(int_src)
    );
endmodule