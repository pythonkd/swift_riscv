/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-07-12 18:02:19
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-07-28 20:59:20
 * @FilePath: /SwiftRiscv/rtl/core/pc_mux.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */


module pc_mux(
    input stop,
    input jump_en,
    input [`REG_WIDTH - 1: 0]pc,
    input [`INST_JUMP_WIDTH - 1: 0]jump,
    input [`REG_WIDTH - 1: 0]imm,
    input [`REG_WIDTH - 1: 0]rs1_data,
    output reg [`REG_WIDTH - 1: 0]nx_pc
);
    always @(*)
        if (stop)
            nx_pc = pc;
        else if(jump == `INST_JUMP_JAL)
            nx_pc = pc + imm;
        else if(jump == `INST_JUMP_JALR)
            nx_pc = imm + rs1_data;
        else if(jump_en)
            nx_pc = pc + imm;
        else
            nx_pc = pc + `REG_WIDTH'h4;
endmodule
