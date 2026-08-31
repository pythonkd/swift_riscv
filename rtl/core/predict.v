/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-08-31 21:31:43
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-31 22:37:23
 * @FilePath: /swift_riscv/rtl/core/predict.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */

module predict(
    input [`INST_WIDTH - 1: 0]instruction,
    input instruction_valid,
    input [`REG_WIDTH - 1: 0]current_pc,
    output reg predict_jump_en,
    output reg [`REG_WIDTH - 1: 0]predict_pc
);
    wire [`INST_OPCODE_WIDTH - 1: 0]opcode = instruction[`INST_OPCODE_BASE + `INST_OPCODE_WIDTH - 1: `INST_OPCODE_BASE];
    reg [`REG_WIDTH - 1: 0] imm;

    always @(*) begin
        predict_jump_en = 1'b0;
        predict_pc = 0;
        if (instruction_valid) begin
            case(opcode)
                `INST_OPCODE_B_TYPE: begin
                    imm = {{20{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
                    if (imm[31]) begin
                        predict_pc = current_pc + imm;
                        predict_jump_en = 1'b1;
                    end
                end
                `INST_OPCODE_JAL_TYPE: begin
                    predict_jump_en = 1'b1;
                    imm = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
                    predict_pc = current_pc + imm;
                end
            endcase
        end
    end
endmodule