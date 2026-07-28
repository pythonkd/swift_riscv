/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-07-12 22:00:12
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-07-28 22:49:15
 * @FilePath: /SwiftRiscv/rtl/core/decode_ctrl.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */


module decode(
    input [`INST_WIDTH - 1: 0]instruction,
    output reg [`INST_RD_WIDTH  - 1: 0]rd_index,
    output reg [`INST_RS1_WIDTH  - 1: 0]rs1_index,
    output reg [`INST_RS2_WIDTH  - 1: 0]rs2_index,
    output reg [`INST_CSR_WIDTH - 1: 0]csr_index,
    output reg instruction_decode_err
);
    wire [`INST_OPCODE_WIDTH - 1: 0]opcode = instruction[`INST_OPCODE_BASE + `INST_OPCODE_WIDTH - 1: `INST_OPCODE_BASE];
    wire [`INST_RD_WIDTH - 1: 0]rd = instruction[`INST_RD_BASE + `INST_RD_WIDTH - 1: `INST_RD_BASE];
    wire [`INST_FUNC3_WIDTH - 1: 0]func3 = instruction[`INST_FUNC3_BASE + `INST_FUNC3_WIDTH - 1: `INST_FUNC3_BASE];
    wire [`INST_RS1_WIDTH - 1: 0]rs1 = instruction[`INST_RS1_BASE + `INST_RS1_WIDTH - 1: `INST_RS1_BASE];
    wire [`INST_RS2_WIDTH - 1: 0]rs2 = instruction[`INST_RS2_BASE + `INST_RS2_WIDTH - 1: `INST_RS2_BASE];
    wire [`INST_FUNC7_WIDTH - 1: 0]func7 = instruction[`INST_FUNC7_BASE + `INST_FUNC7_WIDTH - 1: `INST_FUNC7_BASE];
    wire [`INST_FUNC5_WIDTH - 1: 0]func5 = instruction[`INST_FUNC5_BASE + `INST_FUNC5_WIDTH - 1: `INST_FUNC5_BASE];
    wire [`INST_CSR_WIDTH - 1: 0]csr = instruction[`INST_CSR_BASE + `INST_CSR_WIDTH - 1: `INST_CSR_BASE];
    always @(*) begin
        instruction_decode_err = 0;
        case (opcode)
            `INST_OPCODE_R_TYPE: begin
                rs1_index = rs1;
                rs2_index = rs2;
                rd_index = rd;
            end
            `INST_OPCODE_I_TYPE, `INST_OPCODE_IL_TYPE: begin
                rs1_index = rs1;
                rd_index = rd;
            end
            `INST_OPCODE_S_TYPE: begin
                rs1_index = rs1;
                rs2_index = rs2;
            end
            `INST_OPCODE_B_TYPE: begin
                rs1_index = rs1;
                rs2_index = rs2;
            end
            `INST_OPCODE_AUIPC_TYPE, `INST_OPCODE_LUI_TYPE, `INST_OPCODE_JAL_TYPE: begin
                rd_index = rd;
            end
            `INST_OPCODE_JALR_TYPE: begin
                rd_index = rd;
                rs1_index = rs1;
            end
            `INST_ECALL, `INST_EBREAK, `INST_FENCE: begin
                rd_index = `INST_RD_WIDTH'b0;
            end
            `INST_OPCODE_ATOMIC_TYPE: begin
                case(func5)
                    `INST_OPCODE_ATOMIC_LR: begin
                        rs1_index = rs1;
                    end
                    `INST_OPCODE_ATOMIC_SC: begin
                        rs1_index = rs1;
                        rs2_index = rs2;
                    end
                    `INST_OPCODE_ATOMIC_ADD, `INST_OPCODE_ATOMIC_SWAP, `INST_OPCODE_ATOMIC_AND, `INST_OPCODE_ATOMIC_OR, `INST_OPCODE_ATOMIC_MAX, `INST_OPCODE_ATOMIC_MIN: begin
                        rs1_index = rs1;
                        rs2_index = rs2;
                    end
                endcase
            end
            `INST_OPCODE_CSR_TYPE:
                case(func3)
                    `INST_OPCODE_CSR_CSRRW, `INST_OPCODE_CSR_CSRRS, `INST_OPCODE_CSR_CSRRC: begin
                        csr_index = csr;
                        rs1_index = rs1;
                    end
                    `INST_OPCODE_CSR_CSRRWI, `INST_OPCODE_CSR_CSRRSI, `INST_OPCODE_CSR_CSRRCI: begin
                        csr_index = csr;
                    end
                endcase
            default: instruction_decode_err = 1;
        endcase
    end


endmodule
