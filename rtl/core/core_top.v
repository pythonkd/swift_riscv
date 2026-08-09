/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-07-12 16:12:15
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-09 22:42:53
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
    wire reg_we_pipe2;
    wire mem_we_pipe2;
    wire csr_we_pipe2;
    wire jump_en_pipe2;
    wire div_op_start;
    wire alu_hold_flag_pipe2;
    wire data_err;
    wire instruction_err;
    wire instruction_decode_err;
    wire ecall_except_pipe2;
    wire ebreak_except_pipe2;
    wire exception;
    wire mret_occurred_pipe2;
    wire mret_jump;
    wire [`REG_WIDTH - 1:0]mem_rd_data_pipe2;
    wire [`REG_WIDTH - 1:0]mem_addr_pipe2;
    wire [`REG_WIDTH - 1:0]mem_wr_data_pipe2;
    wire [`INST_RD_WIDTH  - 1: 0]rd_index_pipe1;
    wire [`INST_RD_WIDTH  - 1: 0]rd_index_pipe2;
    wire [`REG_WIDTH - 1: 0]rd_data_pipe2;
    wire [`REG_WIDTH - 1: 0]csr_rd_data_pipe1;
    wire [`REG_WIDTH - 1: 0]csr_rd_data_pipe2;
    wire [`REG_WIDTH - 1: 0]csr_wr_data_pipe2;
    wire [`INST_JUMP_WIDTH - 1: 0]jump_pipe2;
    wire [`REG_WIDTH - 1: 0]cur_pc_pipe0;
    wire [`REG_WIDTH - 1: 0]cur_pc_pipe1;
    wire [`REG_WIDTH - 1: 0]cur_pc_pipe2;
    wire [`REG_WIDTH - 1: 0]nx_pc;
    wire [`INST_WIDTH-1: 0]instruction_pipe0;
    wire [`INST_WIDTH-1: 0]instruction_pipe1;
    wire [`INST_WIDTH-1: 0]instruction_pipe2;
    wire [`REG_WIDTH - 1: 0]imm_pipe2;
    wire [`INST_RS1_WIDTH  - 1: 0]rs1_index_pipe1;
    wire [`INST_RS1_WIDTH  - 1: 0]rs2_index_pipe1;
    wire [`REG_WIDTH - 1: 0]rs1_data_pipe1;
    wire [`REG_WIDTH - 1: 0]rs1_data_pipe2;
    wire [`REG_WIDTH - 1: 0]rs2_data_pipe1;
    wire [`REG_WIDTH - 1: 0]rs2_data_pipe2;
    wire [`REG_WIDTH - 1: 0]csr_mtvec;
    wire [`REG_WIDTH - 1: 0]csr_mepc;
    wire [`INST_CSR_WIDTH - 1: 0]csr_rd_addr_pipe1;
    wire [`INST_CSR_WIDTH - 1: 0]csr_wr_addr_pipe2;
    wire global_int_en;
    wire mtimer_int_en;
    wire ex_int_en;
    wire clint_we;
    wire [`INST_CSR_WIDTH - 1: 0]clint_rd_addr;
    wire [`INST_CSR_WIDTH - 1: 0]clint_wr_addr;
    wire [`REG_WIDTH - 1: 0]clint_wr_data;
    wire [`REG_WIDTH - 1: 0]clint_rd_data;
    wire [`INTERRUPT_MAX_NUM-1: 0]ex_int_src_pipe0;
    wire [`INTERRUPT_MAX_NUM-1: 0]ex_int_src_pipe1;
    wire [`INTERRUPT_MAX_NUM-1: 0]ex_int_src_pipe2;
    wire mtimer_int;
    wire ex_int_process;
    wire sync_except;
    wire async_except;
    wire [`REG_WIDTH - 1: 0]ilm_to_cpu_data_pipe0;
    wire [`REG_WIDTH - 1: 0]dlm_to_cpu_data;
    wire cpu_w_dlm_en_pipe2;
    wire cpu_w_ilm_en_pipe2;
    wire cpu_w_external_en;
    wire [`REG_WIDTH - 1: 0]cpu_to_ilm_r_addr_pipe0;
    wire [`REG_WIDTH - 1: 0]cpu_to_ilm_w_addr_pipe2;
    wire [`REG_WIDTH - 1: 0]cpu_to_ilm_data_pipe2;
    wire [`REG_WIDTH - 1: 0]cpu_to_dlm_addr_pipe2;
    wire [`REG_WIDTH - 1: 0]cpu_to_dlm_data_pipep2;
    wire [`REG_WIDTH - 1: 0]cpu_to_external_addr;
    wire [`REG_WIDTH - 1: 0]cpu_to_external_data;
    wire [`REG_DATA_DEPTH - 1: 0]external_to_cpu_rd_data;
    wire bus_hold_cpu;
    wire hold_cpu;
    wire clint_hold_flag;

    assign sync_except = instruction_err || instruction_decode_err || ebreak_except_pipe2 || ecall_except_pipe2 || data_err;
    assign async_except = ex_int_process || (mtimer_int & mtimer_int_en);
    assign exception = sync_except || (async_except & global_int_en);
    assign hold_cpu = bus_hold_cpu || alu_hold_flag_pipe2 || clint_hold_flag;
    pc_reg u_pc_reg(
        //input
        .clk(clk),
        .rst_n(rst_n),
        .nx_pc(nx_pc),
        //output
        .pc(cur_pc_pipe0),
        .stop(stop)
    );

    pc_mux u_pc_mux(
        // input
        .stop(stop),
        .cur_pc0(cur_pc_pipe0),
        .cur_pc2(cur_pc_pipe2),
        .imm(imm_pipe2),
        .rs1_data(rs1_data_pipe2),
        .jump(jump_pipe2),
        .jump_en(jump_en_pipe2),
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
        .instruction_w_data(cpu_to_ilm_data_pipe2),
        .instruction_we(cpu_w_ilm_en_pipe2),
        .instruction_r_addr(cpu_to_ilm_r_addr_pipe0),
        .instruction_w_addr(cpu_to_ilm_w_addr_pipe2),
        //output
        .instruction(ilm_to_cpu_data_pipe0),
        .instruction_err(instruction_err)
    );

    d_lm u_dlm(
        //input
        .clk(clk),
        .rst_n(rst_n),
        .mem_addr(cpu_to_dlm_addr_pipe2),
        .mem_wr_data(cpu_to_dlm_data_pipep2),
        .mem_we(cpu_w_dlm_en_pipe2),
        //output
        .mem_rd_data(mem_rd_data_pipe2),
        .data_err(data_err)
    );

    reg_file u_reg_file(
        //input
        .clk(clk),
        .rst_n(rst_n),
        .reg_we(reg_we_pipe2),
        .rd_index(rd_index_pipe2),
        .rd_data(rd_data_pipe2),
        .rs1_index(rs1_index_pipe1),
        .rs2_index(rs2_index_pipe1),
        //output
        .rs1_data(rs1_data_pipe1),
        .rs2_data(rs2_data_pipe1)
    );

    if_to_decode_dff u_if_to_decode_dff(
        // input
        .clk(clk),
        .rst_n(rst_n),
        .hold_cpu(hold_cpu),
        .instruction_pipe0(instruction_pipe0),
        .cur_pc_pipe0(cur_pc_pipe0),
        .ex_int_src_pipe0(ex_int_src_pipe0),
        // output
        .ex_int_src_pipe1(ex_int_src_pipe1),
        .instruction_pipe1(instruction_pipe1),
        .cur_pc_pipe1(cur_pc_pipe1)
    );

    decode u_decode(
        //input
        .instruction(instruction_pipe1),
        //output
        .csr_index(csr_rd_addr_pipe1),
        .rd_index(rd_index_pipe1),
        .rs1_index(rs1_index_pipe1),
        .rs2_index(rs2_index_pipe1),
        .instruction_decode_err(instruction_decode_err)
    );

    decode_to_alu_dff u_decode_to_alu_dff(
        .clk(clk),
        .rst_n(rst_n),
        .hold_cpu(hold_cpu),
        .rs1_data_pipe1(rs1_data_pipe1),
        .rs2_data_pipe1(rs2_data_pipe1),
        .rd_index_pipe1(rd_index_pipe1),
        .instruction_pipe1(instruction_pipe1),
        .cur_pc_pipe1(cur_pc_pipe1),
        .csr_rd_data_pipe1(csr_rd_data_pipe1),
        .ex_int_src_pipe1(ex_int_src_pipe1),
        .rs1_data_pipe2(rs1_data_pipe2),
        .rs2_data_pipe2(rs2_data_pipe2),
        .rd_index_pipe2(rd_index_pipe2),
        .instruction_pipe2(instruction_pipe2),
        .cur_pc_pipe2(cur_pc_pipe2),
        .csr_rd_data_pipe2(csr_rd_data_pipe2),
        .ex_int_src_pipe2(ex_int_src_pipe2)
    );

    alu u_alu(
        //input
        .clk(clk),
        .rst_n(rst_n),
        .instruction(instruction_pipe2),
        .instruction_addr(cur_pc_pipe2),
        .rs1_data(rs1_data_pipe2),
        .rs2_data(rs2_data_pipe2),
        .csr_rd_data(csr_rd_data_pipe2),
        .mem_rd_data(mem_rd_data_pipe2),
        //output
        .reg_we(reg_we_pipe2),
        .mem_we(mem_we_pipe2),
        .csr_we(csr_we_pipe2),
        .jump_en(jump_en_pipe2),
        .div_op_start(div_op_start),
        .alu_hold_flag(alu_hold_flag_pipe2),
        .ecall_except(ecall_except_pipe2),
        .ebreak_except(ebreak_except_pipe2),
        .jump(jump_pipe2),
        .imm(imm_pipe2),
        .rd_data(rd_data_pipe2),
        .mem_wr_data(mem_wr_data_pipe2),
        .mem_addr(mem_addr_pipe2),
        .csr_wr_data(csr_wr_data_pipe2),
        .csr_wr_addr(csr_wr_addr_pipe2),
        .mret_occurred(mret_occurred_pipe2)
    );

    csr_reg u_csr_reg(
        // input
        .clk(clk),
        .rst_n(rst_n),
        .ex_we(csr_we_pipe2),
        .csr_rd_addr(csr_rd_addr_pipe1),
        .csr_wr_addr(csr_wr_addr_pipe2),
        .csr_wr_data(csr_wr_data_pipe2),
        .clint_we(clint_we),
        .clint_rd_addr(clint_rd_addr),
        .clint_wr_addr(clint_wr_addr),
        .clint_wr_data(clint_wr_data),
        .ecall_except(ecall_except_pipe2),
        .ebreak_except(ebreak_except_pipe2),
        .instruction_decode_err(instruction_decode_err),
        .data_err(data_err),
        .ex_int(ex_int_process),
        .mtimer_int(mtimer_int),
        .mret_occurred(mret_occurred_pipe2),
        //output
        .global_int_en(global_int_en),
        .mtimer_int_en(mtimer_int_en),
        .ex_int_en(ex_int_en),
        .mret_jump(mret_jump),
        .csr_rd_data(csr_rd_data_pipe1),
        .clint_rd_data(clint_rd_data),
        .csr_mtvec_data(csr_mtvec),
        .csr_mepc_data(csr_mepc)
        
    );

    int_switch u_int_switch(
        // input
        .uart_int(uart_int),
        // output
        .int_src(ex_int_src_pipe0)
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
        .instruction_addr(cur_pc_pipe0),
        .mem_addr(mem_addr_pipe2),
        .mem_wr_data(mem_wr_data_pipe2),
        .external_to_cpu_rd_data(external_to_cpu_rd_data),
        .ilm_to_cpu_data(ilm_to_cpu_data_pipe0),
        .dlm_to_cpu_data(dlm_to_cpu_data),
        .data_we(mem_we_pipe2),
        // output
        .instruction(instruction_pipe0),
        .cpu_w_dlm_en(cpu_w_dlm_en_pipe2),
        .cpu_w_ilm_en(cpu_w_ilm_en_pipe2),
        .cpu_w_external_en(cpu_w_external_en),
        .mem_rd_data(mem_rd_data_pipe2),
        .cpu_to_ilm_r_addr(cpu_to_ilm_r_addr_pipe0),
        .cpu_to_ilm_w_addr(cpu_to_ilm_w_addr_pipe2),
        .cpu_to_ilm_data(cpu_to_ilm_data_pipe2),
        .cpu_to_dlm_addr(cpu_to_dlm_addr_pipe2),
        .cpu_to_dlm_data(cpu_to_dlm_data_pipep2),
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
        .clk(clk),
        .rst_n(rst_n),
        .instruction_addr(cur_pc_pipe2),
        .mret_occurred(mret_occurred),
        .global_int_en(global_int_en),
        .ex_int_en(ex_int_en),
        .hold_flag(alu_hold_flag_pipe2),
        .interrupts(ex_int_src_pipe2),
        .clint_csr_we(clint_csr_we),
        .clint_wr_addr(clint_wr_addr),
        .clint_wr_data(clint_wr_data),
        .clint_hold_flag(clint_hold_flag),
        .ex_int_process(ex_int_process)
    );
endmodule