/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-07-12 18:02:19
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-16 18:25:15
 * @FilePath: /swift_riscv/rtl/core/pc_mux.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */


module pc_mux(
    input jump_en,
    input hold_flag,
    input exception,
    input [`REG_WIDTH - 1: 0]cur_pc0,
    input [`REG_WIDTH - 1: 0]cur_pc2,
    input [`INST_JUMP_WIDTH - 1: 0]jump,
    input [`REG_WIDTH - 1: 0]imm,
    input [`REG_WIDTH - 1: 0]rs1_data,
    input [`REG_WIDTH - 1: 0]csr_mtvec,
    input [`REG_WIDTH - 1: 0]csr_mepc,
    input mret_jump,
    output reg [`REG_WIDTH - 1: 0]nx_pc
);
    always @(*) begin
        nx_pc = cur_pc0 + `REG_WIDTH'h4;
        if (jump_en) begin
            case(jump)
                `INST_JUMP_JAL: nx_pc = cur_pc2 + imm;
                `INST_JUMP_JALR: nx_pc = imm + rs1_data;
                `INST_JUMP_B: nx_pc = cur_pc2 + imm;
                default: nx_pc = cur_pc0 + `REG_WIDTH'h4;
            endcase
        end else if(exception)
            nx_pc = csr_mtvec;
        else if (mret_jump)
            nx_pc = csr_mepc;
        else if(hold_flag)
            nx_pc = cur_pc0;
    end
endmodule
