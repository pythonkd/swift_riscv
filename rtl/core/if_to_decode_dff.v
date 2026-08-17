/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-08-08 17:44:01
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-16 22:58:12
 * @FilePath: /swift_riscv/rtl/core/if_to_decode_dff.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */
module if_to_decode_dff(
    input clk,
    input rst_n,
    input [`REG_WIDTH - 1: 0]instruction_pipe0,
    input instruction_valid_pipe0,
    input [`REG_WIDTH - 1: 0]cur_pc_pipe0,
    input [`INTERRUPT_MAX_NUM - 1: 0]ex_int_src_pipe0,
    input flush_flag,
    input stall_flag,
    output [`INTERRUPT_MAX_NUM - 1: 0]ex_int_src_pipe1,
    output instruction_valid_pipe1,
    output [`REG_WIDTH - 1: 0]instruction_pipe1,
    output [`REG_WIDTH - 1: 0]cur_pc_pipe1
);
    gen_stall_flush_default_dff #(
        .DW(1),
        .STAGS(1)
    ) u_pc_to_decode_instrution_valid(
        .clk(clk),
        .rst_n(rst_n),
        .flush_en(flush_flag),
        .stall_en(stall_flag),
        .din(instruction_valid_pipe0),
        .dout(instruction_valid_pipe1)
    );

    gen_stall_flush_default_dff #(
        .DW(`REG_WIDTH),
        .STAGS(1)
    ) u_pc_to_decode_instrution(
        .clk(clk),
        .rst_n(rst_n),
        .flush_en(flush_flag),
        .stall_en(stall_flag),
        .din(instruction_pipe0),
        .dout(instruction_pipe1)
    );

    gen_stall_flush_default_dff #(
        .DW(`REG_WIDTH),
        .STAGS(1)
    ) u_pc_to_decode_instrution_addr(
        .clk(clk),
        .rst_n(rst_n),
        .flush_en(flush_flag),
        .stall_en(stall_flag),
        .din(cur_pc_pipe0),
        .dout(cur_pc_pipe1)
    );

    gen_stall_flush_default_dff #(
        .DW(`INTERRUPT_MAX_NUM),
        .STAGS(1)
    ) u_pc_to_decode_int_src(
        .clk(clk),
        .rst_n(rst_n),
        .flush_en(flush_flag),
        .stall_en(stall_flag),
        .din(ex_int_src_pipe0),
        .dout(ex_int_src_pipe1)
    );
endmodule