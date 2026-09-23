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
    input [`REG_WIDTH - 1: 0]jump_addr,
    input [`REG_WIDTH - 1: 0]csr_mtvec,
    input [`REG_WIDTH - 1: 0]csr_mepc,
    input mret_jump,
    input predict_jump_en,
    input predict_jump_en_pipe2,
    input [`REG_WIDTH - 1: 0]predict_jump_addr_pipe2,
    input [`REG_WIDTH - 1: 0]predict_jump_addr,
    output reg [`REG_WIDTH - 1: 0]nx_pc
);
    wire is_b    = jump_en && (jump == `INST_JUMP_B);
    wire is_jal  = jump_en && (jump == `INST_JUMP_JAL);
    wire is_jalr = jump_en && (jump == `INST_JUMP_JALR);

    wire [`REG_WIDTH-1:0] br_target   = jump_addr;
    wire [`REG_WIDTH-1:0] jalr_target = jump_addr;

    wire mispred_b    = is_b    && ( !predict_jump_en_pipe2);
    wire mispred_jal  = is_jal  && ( !predict_jump_en_pipe2 || predict_jump_addr_pipe2 != br_target );
    wire mispred_jalr = is_jalr && ( !predict_jump_en_pipe2 || predict_jump_addr_pipe2 != jalr_target );

    wire flush_mispredict = flush_cpu && predict_jump_en_pipe2 && !jump_en;

    always @(*) begin
        if (exception)                                 nx_pc = csr_mtvec;      // 异常优先
        else if (flush_mispredict)                     nx_pc = cur_pc2 + `REG_WIDTH'd4;
        else if (mispred_b || mispred_jal)             nx_pc = br_target;
        else if (mispred_jalr)                         nx_pc = jalr_target;
        else if (mret_jump)                            nx_pc = csr_mepc;
        else if (hold_flag)                            nx_pc = cur_pc0;        // hold 优先
        else if (predict_jump_en)                      nx_pc = predict_jump_addr;
        else                                           nx_pc = cur_pc0 + `REG_WIDTH'd4;
    end
endmodule
