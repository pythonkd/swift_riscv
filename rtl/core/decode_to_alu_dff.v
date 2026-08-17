/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-08-08 17:53:32
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-16 22:58:03
 * @FilePath: /swift_riscv/rtl/core/decode_to_alu_dff.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */

 module decode_to_alu_dff(
    input clk,
    input rst_n,
    input flush_flag,
    input stall_flag,
    input [`REG_WIDTH - 1: 0]rs1_data_pipe1,
    input [`REG_WIDTH - 1: 0]rs2_data_pipe1,
    input [`INST_RD_WIDTH - 1: 0]rd_index_pipe1,
    input [`REG_WIDTH - 1: 0]instruction_pipe1,
    input instruction_valid_pipe1,
    input [`REG_WIDTH - 1: 0]cur_pc_pipe1,
    input [`REG_WIDTH - 1: 0]csr_rd_data_pipe1,
    input [`INTERRUPT_MAX_NUM - 1: 0]ex_int_src_pipe1,

    output [`REG_WIDTH - 1: 0]rs1_data_pipe2,
    output [`REG_WIDTH - 1: 0]rs2_data_pipe2,
    output [`INST_RD_WIDTH - 1: 0]rd_index_pipe2,
    output [`REG_WIDTH - 1: 0]instruction_pipe2,
    output instruction_valid_pipe2,
    output [`REG_WIDTH - 1: 0]cur_pc_pipe2,
    output [`REG_WIDTH - 1: 0]csr_rd_data_pipe2,
    input [`INTERRUPT_MAX_NUM - 1: 0]ex_int_src_pipe2
 );

    gen_stall_flush_default_dff #(
        .DW(`INST_RD_WIDTH),
        .STAGS(1)
    ) u_decode_to_alu_rd_addr(
        .clk(clk),
        .rst_n(rst_n),
        .flush_en(flush_flag),
        .stall_en(stall_flag),
        .din(rd_index_pipe1),
        .dout(rd_index_pipe2)
    );

    gen_stall_flush_default_dff #(
        .DW(`REG_WIDTH),
        .STAGS(1)
    ) u_decode_to_alu_rs1(
        .clk(clk),
        .rst_n(rst_n),
        .flush_en(flush_flag),
        .stall_en(stall_flag),
        .din(rs1_data_pipe1),
        .dout(rs1_data_pipe2)
    );
    gen_stall_flush_default_dff #(
        .DW(`REG_WIDTH),
        .STAGS(1)
    ) u_decode_to_alu_rs2(
        .clk(clk),
        .rst_n(rst_n),
        .flush_en(flush_flag),
        .stall_en(stall_flag),
        .din(rs2_data_pipe1),
        .dout(rs2_data_pipe2)
    );

    gen_stall_flush_default_dff #(
        .DW(1),
        .STAGS(1)
    ) u_decode_to_alu_instruction_valid(
        .clk(clk),
        .rst_n(rst_n),
        .flush_en(flush_flag),
        .stall_en(stall_flag),
        .din(instruction_valid_pipe1),
        .dout(instruction_valid_pipe2)
    );
    
    gen_stall_flush_default_dff #(
        .DW(`REG_WIDTH),
        .STAGS(1)
    ) u_decode_to_alu_instruction(
        .clk(clk),
        .rst_n(rst_n),
        .flush_en(flush_flag),
        .stall_en(stall_flag),
        .din(instruction_pipe1),
        .dout(instruction_pipe2)
    );
    gen_stall_flush_default_dff #(
        .DW(`REG_WIDTH),
        .STAGS(1)
    ) u_decode_to_alu_instruction_addr(
        .clk(clk),
        .rst_n(rst_n),
        .flush_en(flush_flag),
        .stall_en(stall_flag),
        .din(cur_pc_pipe1),
        .dout(cur_pc_pipe2)
    );

    gen_stall_flush_default_dff #(
        .DW(`REG_WIDTH),
        .STAGS(1)
    ) u_decode_to_alu_csr_data(
        .clk(clk),
        .rst_n(rst_n),
        .flush_en(flush_flag),
        .stall_en(stall_flag),
        .din(csr_rd_data_pipe1),
        .dout(csr_rd_data_pipe2)
    );

    gen_stall_flush_default_dff #(
        .DW(`INTERRUPT_MAX_NUM),
        .STAGS(1)
    ) u_pc_to_decode_int_src(
        .clk(clk),
        .rst_n(rst_n),
        .flush_en(flush_flag),
        .stall_en(stall_flag),
        .din(ex_int_src_pipe1),
        .dout(ex_int_src_pipe2)
    );
 endmodule