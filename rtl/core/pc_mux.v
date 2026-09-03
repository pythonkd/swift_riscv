/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-07-12 18:02:19
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-31 21:56:53
 * @FilePath: /swift_riscv/rtl/core/pc_mux.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */


module pc_mux(
    input jump_en,
    input hold_flag,
    input flush_cpu,
    input exception,
    input [`REG_WIDTH - 1: 0]cur_pc0,
    input [`REG_WIDTH - 1: 0]cur_pc2,
    input [`INST_JUMP_WIDTH - 1: 0]jump,
    input [`REG_WIDTH - 1: 0]imm,
    input [`REG_WIDTH - 1: 0]rs1_data,
    input [`REG_WIDTH - 1: 0]csr_mtvec,
    input [`REG_WIDTH - 1: 0]csr_mepc,
    input mret_jump,
    input predict_jump_en,
    input [`REG_WIDTH - 1: 0]predict_jump_en_pipe2,
    input [`REG_WIDTH - 1: 0]predict_pc,
    output reg [`REG_WIDTH - 1: 0]nx_pc
);
    always @(*) begin
        if (flush_cpu && predict_jump_en_pipe2 && !jump_en)
            nx_pc = cur_pc2 + 32'h4;
        else if(exception)
            nx_pc = csr_mtvec;
        else if (jump_en&& !predict_jump_en_pipe2) begin
            case(jump)
                `INST_JUMP_JAL: nx_pc = cur_pc2 + imm;
                `INST_JUMP_JALR: nx_pc = imm + rs1_data;
                `INST_JUMP_B: nx_pc = cur_pc2 + imm;
                default: nx_pc = cur_pc0 + `REG_WIDTH'h4;
            endcase
        end else if (mret_jump)
            nx_pc = csr_mepc;
        else if (predict_jump_en)
            nx_pc = predict_pc;
        else if(hold_flag)
            nx_pc = cur_pc0;
        else
            nx_pc = cur_pc0 + `REG_WIDTH'h4;
    end
endmodule
