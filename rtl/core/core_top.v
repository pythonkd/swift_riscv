/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-07-12 16:12:15
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-31 22:33:15
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
    input [`REG_WIDTH - 1: 0]slv_rd_data,
    input slv_ready,
    output p_enable,
    output mst_we,
    output [`REG_WIDTH - 1: 0]mst_addr,
    output [`REG_WIDTH - 1: 0]mst_wdata
);
    wire clint_csr_we;
    wire stop;
    wire alu_reg_we;
    wire alu_mem_we;
    wire alu_csr_we;
    wire jump_en_pipe2;
    wire div_op_start;
    wire alu_flush_flag;
    wire alu_stall_flag;
    wire data_err;
    wire instruction_err;
    wire instruction_decode_err;
    wire ecall_except;
    wire ebreak_except;
    wire exception;
    wire mret_occurred;
    wire mret_jump;
    wire mem_req_valid;
    wire mem_rd_valid;
    wire [`REG_WIDTH - 1:0]alu_mem_rd_data;
    wire [`REG_WIDTH - 1:0]alu_mem_addr;
    wire [`REG_WIDTH - 1:0]alu_mem_wr_data;
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
    wire instruction_valid_pipe0;
    wire instruction_valid_pipe1;
    wire instruction_valid_pipe2;
    wire [`REG_WIDTH - 1: 0]jump_addr_pipe2;
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
    wire [`INST_CSR_WIDTH - 1: 0]clint_csr_wr_addr;
    wire [`REG_WIDTH - 1: 0]clint_csr_wr_data;
    wire [`REG_WIDTH - 1: 0]clint_rd_data;
    wire [`INTERRUPT_MAX_NUM-1: 0]ex_int_src_pipe0;
    wire [`INTERRUPT_MAX_NUM-1: 0]ex_int_src_pipe1;
    wire [`INTERRUPT_MAX_NUM-1: 0]ex_int_src_pipe2;
    wire mtimer_int;
    wire ex_int_process;
    wire mtimer_int_process;
    wire sync_except;
    wire async_except;
    wire [`REG_WIDTH - 1: 0]ilm_to_cpu_data_pipe0;
    wire [`REG_WIDTH - 1: 0]dlm_to_cpu_data;
    wire cpu_wr_dlm_en_pipe2;
    wire cpu_wr_ilm_en_pipe2;
    wire cpu_wr_external_en;
    wire [`REG_WIDTH - 1: 0]cpu_to_ilm_rd_mem_addr;
    wire [`REG_WIDTH - 1: 0]ilm_to_cpu_mem_data;
    wire [`REG_WIDTH - 1: 0]cpu_to_ilm_rd_addr_pipe0;
    wire [`REG_WIDTH - 1: 0]cpu_to_ilm_wr_addr_pipe2;
    wire [`REG_WIDTH - 1: 0]cpu_to_ilm_data_pipe2;
    wire [`REG_WIDTH - 1: 0]cpu_to_dlm_addr_pipe2;
    wire [`REG_WIDTH - 1: 0]cpu_to_dlm_data_pipep2;
    wire [`REG_WIDTH - 1: 0]cpu_to_external_addr;
    wire [`REG_WIDTH - 1: 0]cpu_to_external_data;
    wire [`REG_DATA_DEPTH - 1: 0]external_to_cpu_rd_data;
    wire cpu_wr_mtimer_en;
    wire [`REG_WIDTH - 1: 0]mtimer_to_cpu_data;
    wire [`REG_WIDTH - 1: 0]cpu_to_mtimer_addr;
    wire [`REG_WIDTH - 1: 0]cpu_to_mtimer_data;
    wire cpu_wr_clint_en;
    wire [`REG_WIDTH - 1: 0]clint_to_cpu_data;
    wire [`REG_WIDTH - 1: 0]cpu_to_clint_addr;
    wire [`REG_WIDTH - 1: 0]cpu_to_clint_data;
    wire [`STRB_WIDTH - 1: 0]mem_strb;
    wire [`STRB_WIDTH - 1: 0]cpu_to_dlm_strb;
    wire extern_data_ready;
    wire bus_stall_if;
    wire bus_stall_cpu;
    wire hold_cpu;
    wire flush_cpu;
    wire clint_flush_flag;
    wire if_flush_flag;
    wire if_stall_flag;
    wire decode_flush_flag;
    wire decode_stall_flag;
    wire predict_jump_en_pipe0;
    wire predict_jump_en_pipe1;
    wire predict_jump_en_pipe2;
    wire [`REG_WIDTH -1 : 0]predict_jump_addr_pipe0;
    wire [`REG_WIDTH -1 : 0]predict_jump_addr_pipe1;
    wire [`REG_WIDTH -1 : 0]predict_jump_addr_pipe2;
    wire ras_push;
    wire ras_pop;
    wire [`REG_WIDTH - 1 : 0]ras_push_addr;
    wire [`REG_WIDTH - 1: 0]ras_top_addr;
    wire ras_empty;

    assign sync_except = instruction_err || instruction_decode_err || ebreak_except || ecall_except || data_err;
    assign async_except = ex_int_process || mtimer_int_process;
    assign exception = sync_except || async_except;
    assign decode_flush_flag = alu_flush_flag || clint_flush_flag || exception;
    assign decode_stall_flag = alu_stall_flag || bus_stall_cpu;

    assign if_flush_flag = decode_flush_flag;
    assign if_stall_flag = decode_stall_flag || bus_stall_if;
    assign hold_cpu = stop || bus_stall_cpu || alu_stall_flag || bus_stall_if;
    assign flush_cpu = alu_flush_flag || decode_flush_flag || if_flush_flag;
    pc_reg u_pc_reg(
        //input
        .clk(clk),
        .rst_n(rst_n),
        .nx_pc(nx_pc),
        //output
        .pc(cur_pc_pipe0),
        .stop(stop)
    );

    predict u_predict(
        // input
        .instruction(instruction_pipe0),
        .instruction_addr(cur_pc_pipe0),
        .instruction_valid(instruction_valid_pipe0),
        .current_pc(cur_pc_pipe0),
        .ras_top_addr(ras_top_addr),
        // output
        .ras_push(ras_push),
        .ras_push_addr(ras_push_addr),
        .ras_pop(ras_pop),
        .predict_jump_en(predict_jump_en_pipe0),
        .predict_jump_addr(predict_jump_addr_pipe0)
    );

    pc_mux u_pc_mux(
        // input
        .cur_pc0(cur_pc_pipe0),
        .cur_pc2(cur_pc_pipe2),
        .jump_addr(jump_addr_pipe2),
        .jump(jump_pipe2),
        .jump_en(jump_en_pipe2),
        .flush_cpu(flush_cpu),
        .hold_flag(hold_cpu),
        .csr_mtvec(csr_mtvec),
        .csr_mepc(csr_mepc),
        .exception(exception),
        .mret_jump(mret_jump),
        .predict_jump_en_pipe2(predict_jump_en_pipe2),
        .predict_jump_addr_pipe2(predict_jump_addr_pipe2),
        .predict_jump_en(predict_jump_en_pipe0),
        .predict_jump_addr(predict_jump_addr_pipe0),
        //output
        .nx_pc(nx_pc)
    );
    
    i_lm u_ilm(
        //input
        .clk(clk),
        .mem_rd_addr(cpu_to_ilm_rd_mem_addr),
        .mem_wr_data(cpu_to_ilm_data_pipe2),
        .instruction_we(cpu_wr_ilm_en_pipe2),
        .instruction_rd_addr(cpu_to_ilm_rd_addr_pipe0),
        .mem_wr_addr(cpu_to_ilm_wr_addr_pipe2),
        //output
        .instruction(ilm_to_cpu_data_pipe0),
        .mem_rd_data(ilm_to_cpu_mem_data),
        .instruction_err(instruction_err)
    );

    d_lm u_dlm(
        //input
        .clk(clk),
        .rst_n(rst_n),
        .mem_strb(cpu_to_dlm_strb),
        .mem_addr(cpu_to_dlm_addr_pipe2),
        .mem_wr_data(cpu_to_dlm_data_pipep2),
        .mem_we(cpu_wr_dlm_en_pipe2),
        //output
        .mem_rd_data(dlm_to_cpu_data),
        .data_err(data_err)
    );

    reg_file u_reg_file(
        //input
        .clk(clk),
        .rst_n(rst_n),
        .reg_we(alu_reg_we),
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
        .flush_flag(if_flush_flag),
        .stall_flag(if_stall_flag),
        .instruction_pipe0(instruction_pipe0),
        .instruction_valid_pipe0(instruction_valid_pipe0),
        .cur_pc_pipe0(cur_pc_pipe0),
        .ex_int_src_pipe0(ex_int_src_pipe0),
        .predict_jump_en_pipe0(predict_jump_en_pipe0),
        .predict_jump_addr_pipe0(predict_jump_addr_pipe0),
        // output
        .ex_int_src_pipe1(ex_int_src_pipe1),
        .instruction_valid_pipe1(instruction_valid_pipe1),
        .instruction_pipe1(instruction_pipe1),
        .cur_pc_pipe1(cur_pc_pipe1),
        .predict_jump_en_pipe1(predict_jump_en_pipe1),
        .predict_jump_addr_pipe1(predict_jump_addr_pipe1)
    );

    decode u_decode(
        //input
        .instruction_valid(instruction_valid_pipe1),
        .instruction(instruction_pipe1),
        //output
        .csr_index(csr_rd_addr_pipe1),
        .rd_index(rd_index_pipe1),
        .rs1_index(rs1_index_pipe1),
        .rs2_index(rs2_index_pipe1)
    );

    decode_to_alu_dff u_decode_to_alu_dff(
        // input
        .clk(clk),
        .rst_n(rst_n),
        .flush_flag(decode_flush_flag),
        .stall_flag(decode_stall_flag),
        .rs1_data_pipe1(rs1_data_pipe1),
        .rs2_data_pipe1(rs2_data_pipe1),
        .rd_index_pipe1(rd_index_pipe1),
        .instruction_pipe1(instruction_pipe1),
        .instruction_valid_pipe1(instruction_valid_pipe1),
        .cur_pc_pipe1(cur_pc_pipe1),
        .csr_rd_data_pipe1(csr_rd_data_pipe1),
        .ex_int_src_pipe1(ex_int_src_pipe1),
        .predict_jump_en_pipe1(predict_jump_en_pipe1),
        .predict_jump_addr_pipe1(predict_jump_addr_pipe1),
        // output
        .rs1_data_pipe2(rs1_data_pipe2),
        .rs2_data_pipe2(rs2_data_pipe2),
        .rd_index_pipe2(rd_index_pipe2),
        .instruction_valid_pipe2(instruction_valid_pipe2),
        .instruction_pipe2(instruction_pipe2),
        .cur_pc_pipe2(cur_pc_pipe2),
        .csr_rd_data_pipe2(csr_rd_data_pipe2),
        .ex_int_src_pipe2(ex_int_src_pipe2),
        .predict_jump_en_pipe2(predict_jump_en_pipe2),
        .predict_jump_addr_pipe2(predict_jump_addr_pipe2)
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
        .mem_rd_valid(mem_rd_valid),
        .mem_rd_data(alu_mem_rd_data),
        .predict_jump_en(predict_jump_en_pipe2),
        .predict_jump_addr(predict_jump_addr_pipe2),
        //output
        .reg_we(alu_reg_we),
        .mem_we(alu_mem_we),
        .csr_we(alu_csr_we),
        .jump_en(jump_en_pipe2),
        .div_op_start(div_op_start),
        .alu_flush_flag(alu_flush_flag),
        .alu_stall_flag(alu_stall_flag),
        .ecall_except(ecall_except),
        .ebreak_except(ebreak_except),
        .jump(jump_pipe2),
        .jump_addr(jump_addr_pipe2),
        .rd_data(rd_data_pipe2),
        .mem_wr_data(alu_mem_wr_data),
        .mem_addr(alu_mem_addr),
        .mem_strb(mem_strb),
        .mem_req_valid(mem_req_valid),
        .csr_wr_data(csr_wr_data_pipe2),
        .csr_wr_addr(csr_wr_addr_pipe2),
        .mret_occurred(mret_occurred),
        .instruction_decode_err(instruction_decode_err)
    );

    csr_reg u_csr_reg(
        // input
        .clk(clk),
        .rst_n(rst_n),
        .ex_we(alu_csr_we),
        .csr_rd_addr(csr_rd_addr_pipe1),
        .csr_wr_addr(csr_wr_addr_pipe2),
        .csr_wr_data(csr_wr_data_pipe2),
        .clint_we(clint_csr_we),
        .clint_rd_addr(clint_rd_addr),
        .clint_wr_addr(clint_csr_wr_addr),
        .clint_wr_data(clint_csr_wr_data),
        .ecall_except(ecall_except),
        .ebreak_except(ebreak_except),
        .instruction_decode_err(instruction_decode_err),
        .data_err(data_err),
        .ex_int(ex_int_process),
        .mtimer_int(mtimer_int_process),
        .mret_occurred(mret_occurred),
        .cur_pc_pipe2(cur_pc_pipe2),
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
        .mtimer_clk(clk),
        .rst_n(rst_n),
        .mtimer_addr(cpu_to_mtimer_addr),
        .mtimer_wr_data(cpu_to_mtimer_data),
        .mtimer_we(cpu_wr_mtimer_en),        
        // output
        .mtimer_rd_data(mtimer_to_cpu_data),
        .mtimer_int(mtimer_int)
    );

    addr_mux u_addr_mux(
        // input
        .instruction_addr(cur_pc_pipe0),
        .mem_req_valid(mem_req_valid),
        .mem_strb(mem_strb),
        .mem_addr(alu_mem_addr),
        .mem_wr_data(alu_mem_wr_data),
        .external_to_cpu_rd_data(external_to_cpu_rd_data),
        .ilm_to_cpu_inst_data(ilm_to_cpu_data_pipe0),
        .ilm_to_cpu_mem_data(ilm_to_cpu_mem_data),
        .dlm_to_cpu_data(dlm_to_cpu_data),
        .mtimer_to_cpu_data(mtimer_to_cpu_data),
        .clint_to_cpu_data(clint_to_cpu_data),
        .data_we(alu_mem_we),
        .extern_data_ready(extern_data_ready),
        // output
        .bus_stall_if(bus_stall_if),
        .bus_stall_cpu(bus_stall_cpu),
        .cpu_wr_dlm_en(cpu_wr_dlm_en_pipe2),
        .cpu_wr_ilm_en(cpu_wr_ilm_en_pipe2),
        .cpu_wr_external_en(cpu_wr_external_en),
        .cpu_wr_mtimer_en(cpu_wr_mtimer_en),
        .cpu_wr_clint_en(cpu_wr_clint_en),
        .instruction(instruction_pipe0),
        .instruction_valid(instruction_valid_pipe0),
        .mem_rd_data(alu_mem_rd_data),
        .mem_rd_valid(mem_rd_valid),
        .cpu_to_ilm_rd_inst_addr(cpu_to_ilm_rd_addr_pipe0),
        .cpu_to_ilm_rd_mem_addr(cpu_to_ilm_rd_mem_addr),
        .cpu_to_ilm_wr_addr(cpu_to_ilm_wr_addr_pipe2),
        .cpu_to_ilm_data(cpu_to_ilm_data_pipe2),
        .cpu_to_dlm_strb(cpu_to_dlm_strb),
        .cpu_to_dlm_addr(cpu_to_dlm_addr_pipe2),
        .cpu_to_dlm_data(cpu_to_dlm_data_pipep2),
        .cpu_to_external_addr(cpu_to_external_addr),
        .cpu_to_external_data(cpu_to_external_data),
        .cpu_to_mtimer_addr(cpu_to_mtimer_addr),
        .cpu_to_mtimer_data(cpu_to_mtimer_data),
        .cpu_to_clint_addr(cpu_to_clint_addr),
        .cpu_to_clint_data(cpu_to_clint_data)
    );

    cpu_to_bus u_cpu_to_bus(
        // input
        .clk(clk),
        .rst_n(rst_n),
        .cpu_addr(cpu_to_external_addr),
        .cpu_wdata(cpu_to_external_data),
        .cpu_we(cpu_wr_external_en),
        .slv_rd_data(slv_rd_data),
        .slv_ready(slv_ready),
        .cpu_flush_bus(decode_flush_flag),
        // output
        .p_enable(p_enable),
        .mst_we(mst_we),
        .mst_addr(mst_addr),
        .mst_wdata(mst_wdata),
        .cpu_rd_data(external_to_cpu_rd_data),
        .extern_data_ready(extern_data_ready)
    );

    clint u_clint(
        // input
        .clk(clk),
        .rst_n(rst_n),
        .instruction_addr(cur_pc_pipe2),
        .mret_occurred(mret_occurred),
        .global_int_en(global_int_en),
        .ex_int_en(ex_int_en),
        .alu_stall_flag(alu_stall_flag),
        .clint_wr_addr(cpu_to_clint_addr),
        .clint_wr_data(cpu_to_clint_data),
        .clint_we(cpu_wr_clint_en),
        .interrupts(ex_int_src_pipe2),
        .mtimer_int(mtimer_int),
        .mtimer_int_en(mtimer_int_en),
        // output
        .clint_rd_data(clint_to_cpu_data),
        .clint_csr_we(clint_csr_we),
        .clint_csr_wr_addr(clint_csr_wr_addr),
        .clint_csr_wr_data(clint_csr_wr_data),
        .clint_flush_flag(clint_flush_flag),
        .ex_int_process(ex_int_process),
        .mtimer_int_process(mtimer_int_process)
    );

    ras_stack #(
        .DEPTH(8)
    ) u_ras_stack(
        // input
        .clk(clk),
        .rst_n(rst_n),
        .push(ras_push),
        .pop(ras_pop),
        .push_addr(ras_push_addr),
        // output
        .top_addr(ras_top_addr),
        .empty(ras_empty)
    );

endmodule