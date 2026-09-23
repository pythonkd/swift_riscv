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
    input [`REG_WIDTH -1: 0]instruction_addr,
    input instruction_valid,
    input [`REG_WIDTH - 1: 0]current_pc,
    input [`REG_WIDTH - 1: 0]ras_top_addr,
    output reg ras_push,
    output reg [`REG_WIDTH - 1: 0]ras_push_addr,
    output reg ras_pop,
    output reg predict_jump_en,
    output reg [`REG_WIDTH - 1: 0]predict_jump_addr
);
    wire [`INST_OPCODE_WIDTH - 1: 0]opcode = instruction[`INST_OPCODE_BASE + `INST_OPCODE_WIDTH - 1: `INST_OPCODE_BASE];
    wire [`INST_RD_WIDTH - 1:0] rd = instruction[`INST_RD_BASE+`INST_RD_WIDTH-1:`INST_RD_BASE];
    wire [`INST_RS1_WIDTH - 1:0] rs1 = instruction[`INST_RS1_BASE+`INST_RS1_WIDTH-1:`INST_RS1_BASE];
    reg [`REG_WIDTH - 1: 0] imm;

    always @(*) begin
        predict_jump_en = 1'b0;
        predict_jump_addr = 0;
        ras_push = 0;
        ras_push_addr = 0;
        ras_pop = 0;
        if (instruction_valid) begin
            case(opcode)
                `INST_OPCODE_B_TYPE: begin
                    imm = {{20{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
                    if (imm[31]) begin
                        predict_jump_addr = current_pc + imm;
                        predict_jump_en = 1'b1;
                    end
                end
                `INST_OPCODE_JAL_TYPE: begin
                    predict_jump_en = 1'b1;
                    imm = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
                    predict_jump_addr = current_pc + imm;
                    // call保存到ras
                    if ((rd == `RA_INDEX) || (rd == `X5_INDEX)) begin
                        ras_push = 1'b1;
                        ras_push_addr = instruction_addr + `REG_WIDTH'h4;
                    end else begin
                        ras_push = 1'b0;
                        ras_push_addr = `REG_WIDTH'b0;
                    end
                end
                `INST_OPCODE_JALR_TYPE: begin
                    if ((rd != `RA_INDEX) && (rd != `X5_INDEX) && ((rs1 == `RA_INDEX) || (rs1 == `X5_INDEX))) begin
                        predict_jump_addr = ras_top_addr;
                        predict_jump_en = 1'b1;
                        ras_pop = 1'b1;
                    end else if ((rd == `RA_INDEX) | (rd == `X5_INDEX)) begin
                        ras_push = 1'b1;
                        ras_push_addr = instruction_addr + `REG_WIDTH'h4;
                        if ((rd != rs1) && ((rs1 == `RA_INDEX) || (rs1 == `X5_INDEX))) begin
                            ras_pop = 1'b1;
                            predict_jump_addr = ras_top_addr;
                            predict_jump_en = 1'b1;
                        end else begin
                            ras_pop = 1'b0;
                        end
                    end
                end
                default: begin
                end
            endcase
        end
    end
endmodule