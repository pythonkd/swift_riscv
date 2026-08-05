/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-07-14 22:22:10
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-04 22:06:11
 * @FilePath: /swift_riscv/rtl/core/alu.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */

module alu(
    input clk,
    input rst_n,
    input [`INST_WIDTH - 1: 0]instruction,
    input [`REG_WIDTH - 1: 0]instruction_addr,
    input [`REG_WIDTH - 1: 0]rs1_data,
    input [`REG_WIDTH - 1: 0]rs2_data,
    input [`REG_WIDTH - 1: 0]csr_rd_data,
    input [`REG_WIDTH - 1:0]mem_rd_data,
    output reg reg_we,
    output reg mem_we,
    output reg csr_we,
    output reg jump_en,
    output reg div_op_start,
    output reg hold_flag,
    output reg ecall_except,
    output reg ebreak_except,
    output reg [`INST_JUMP_WIDTH - 1: 0]jump,
    output reg [`REG_WIDTH - 1: 0]imm,
    output reg [`REG_WIDTH - 1: 0]rd_data,
    output reg [`REG_WIDTH - 1:0]mem_wr_data,
    output reg [`REG_WIDTH - 1:0]mem_addr,
    output reg [`REG_WIDTH - 1:0]csr_wr_data,
    output reg [`INST_CSR_WIDTH - 1:0]csr_wr_addr
    output reg mret_occurred;
);
    wire [`INST_OPCODE_WIDTH - 1: 0]opcode = instruction[`INST_OPCODE_BASE + `INST_OPCODE_WIDTH - 1: `INST_OPCODE_BASE];
    wire [`INST_RD_WIDTH - 1:0] rd = instruction[`INST_RD_BASE+`INST_RD_WIDTH-1:`INST_RD_BASE];
    wire [`INST_FUNC3_WIDTH - 1: 0]func3 = instruction[`INST_FUNC3_BASE + `INST_FUNC3_WIDTH - 1: `INST_FUNC3_BASE];
    wire [`INST_RS1_WIDTH - 1:0] rs1 = instruction[`INST_RS1_BASE+`INST_RS1_WIDTH-1:`INST_RS1_BASE];
    wire [`INST_RS2_WIDTH - 1:0] rs2 = instruction[`INST_RS2_BASE+`INST_RS2_WIDTH-1:`INST_RS2_BASE];
    wire [`INST_FUNC7_WIDTH - 1: 0]func7 = instruction[`INST_FUNC7_BASE + `INST_FUNC7_WIDTH - 1: `INST_FUNC7_BASE];
    wire [`INST_FUNC5_WIDTH - 1: 0]func5 = instruction[`INST_FUNC5_BASE + `INST_FUNC5_WIDTH - 1: `INST_FUNC5_BASE];
    wire [`INST_CSR_WIDTH - 1:0] csr = instruction[`INST_CSR_BASE+`INST_CSR_WIDTH-1:`INST_CSR_BASE];

    // EI, ECALL/EBREAK
    always @(*) begin
        ecall_except = 0;
        ebreak_except = 0;
        mret_occurred = 0;
        case (opcode)
            `INST_OPCODE_EI_TYPE: begin
                reg_we = 1'b0;
                mem_we = 1'b0;
                jump_en = 1'b0;
                case (func7)
                    `INST_OPCODE_EI_ECALL: begin
                        ecall_except = 1;
                        csr_we = 1'b1;
                        csr_wr_data = instruction_addr;
                        csr_wr_addr = `CSR_MEPC;
                    end
                    `INST_OPCODE_EI_EREAK: begin
                        ebreak_except = 1;
                        csr_we = 1'b1;
                        csr_wr_data = instruction_addr;
                        csr_wr_addr = `CSR_MEPC;
                    end
                    `INST_OPCODE_EI_MRET: begin
                        mret_occurred = 1'b1;
                        csr_we = 1'b0;
                    end
                endcase
            end
        endcase
    end
    // FENCE
    always @(*) begin
        case (opcode)
            `INST_OPCODE_FENCE_TYPE: begin
                reg_we = 1'b0;
                mem_we = 1'b0;
                csr_we = 1'b0;
                jump_en = 1'b0;
            end
        endcase
    end

    // OP R except mul
    always @(*) begin
        case (opcode)
            `INST_OPCODE_R_TYPE: begin
                case(func7)
                    `INST_R_FUNC7_BASE_TYPE0: begin
                        reg_we = 1'b1;
                        mem_we = 1'b0;
                        csr_we = 1'b0;
                        jump_en = 1'b0;
                        case(func3)
                            `INST_OPCODE_R_ADD: begin
                                rd_data = rs1_data + rs2_data;
                            end
                            `INST_OPCODE_R_XOR: begin
                                rd_data = rs1_data ^ rs2_data;
                            end
                            `INST_OPCODE_R_OR: begin
                                rd_data = rs1_data | rs2_data;
                            end
                            `INST_OPCODE_R_AND: begin
                                rd_data = rs1_data & rs2_data;
                            end
                            `INST_OPCODE_R_SLL: begin
                                rd_data = rs1_data << rs2_data[4:0];
                            end
                            `INST_OPCODE_R_SRL: begin
                                rd_data = rs1_data >> rs2_data[4:0];
                            end
                            `INST_OPCODE_R_SLT: begin
                                rd_data = $signed(rs1_data) < $signed(rs2_data) ? `REG_WIDTH'b1 : `REG_WIDTH'b0;
                            end
                            `INST_OPCODE_R_SLTU: begin
                                rd_data = rs1_data < rs2_data ? `REG_WIDTH'b1 : `REG_WIDTH'b0;
                            end
                        endcase
                    end
                    `INST_R_FUNC7_BASE_TYPE1: begin
                        reg_we = 1'b1;
                        mem_we = 1'b0;
                        csr_we = 1'b0;
                        jump_en = 1'b0;
                        case(func3)
                            `INST_OPCODE_R_SUB: begin
                                rd_data = rs1_data - rs2_data;
                            end
                            `INST_OPCODE_R_SRA: begin
                                rd_data = $signed(rs1_data) >>> rs2_data[4:0];
                            end
                        endcase
                    end
                endcase
            end
        endcase
    end
    // OP I
    always @(*) begin
        case (opcode)
            `INST_OPCODE_I_TYPE: begin
                imm = {{(`REG_WIDTH-`INST_FUNC7_WIDTH-`INST_RS2_WIDTH){func7[`INST_FUNC7_WIDTH - 1]}}, func7, rs2};
                reg_we = 1'b1;
                mem_we = 1'b0;
                csr_we = 1'b0;
                jump_en = 1'b0;
                case(func3)
                    `INST_OPCODE_I_ADDI: begin
                        rd_data = rs1_data + imm;
                    end
                    `INST_OPCODE_I_XORI: begin
                        rd_data = rs1_data ^ imm;
                    end
                    `INST_OPCODE_I_ORI: begin
                        rd_data = rs1_data | imm;
                    end
                    `INST_OPCODE_I_ANDI: begin
                        rd_data = rs1_data & imm;
                    end
                    `INST_OPCODE_I_SLLI: begin
                        rd_data = rs1_data << imm[4:0];
                    end
                    `INST_OPCODE_I_SLTI: begin
                        rd_data = $signed(rs1_data) < $signed(imm) ? `REG_WIDTH'b1 : `REG_WIDTH'b0;
                    end
                    `INST_OPCODE_I_SLTIU: begin
                        rd_data = rs1_data < imm ? `REG_WIDTH'b1 : `REG_WIDTH'b0;
                    end
                    `INST_OPCODE_I_SR: begin
                        case(func7)
                            // SRLI
                            `INST_I_FUNC7_BASE_TYPE0: begin
                                rd_data = rs1_data >> imm[4:0];
                            end
                            `INST_I_FUNC7_BASE_TYPE1: begin
                                rd_data = $signed(rs1_data) >>> imm[4:0];
                            end
                        endcase
                    end
                endcase
            end
        endcase
    end
    // OP IL
    always @(*) begin
        case (opcode)
            `INST_OPCODE_IL_TYPE: begin
                reg_we = 1'b1;
                mem_we = 1'b0;
                csr_we = 1'b0;
                jump_en = 1'b0;
                mem_addr = rs1_data + imm;
                imm = {{(`REG_WIDTH-`INST_FUNC7_WIDTH-`INST_RS2_WIDTH){func7[`INST_FUNC7_WIDTH - 1]}}, func7, rs2};
                case(func3)
                    `INST_OPCODE_IL_LB: begin
                        rd_data = {{(`REG_WIDTH - 8){mem_rd_data[7]}}, mem_rd_data[7: 0]};
                    end
                    `INST_OPCODE_IL_LH: begin
                        rd_data = {{(`REG_WIDTH - 16){mem_rd_data[15]}}, mem_rd_data[15: 0]};
                    end
                    `INST_OPCODE_IL_LW: begin
                        rd_data = mem_rd_data[31: 0];
                    end
                    `INST_OPCODE_IL_LBU: begin
                        rd_data = {{(`REG_WIDTH - 8){1'b0}}, mem_rd_data[7: 0]};
                    end
                    `INST_OPCODE_IL_LHU: begin
                        rd_data = {{(`REG_WIDTH - 16){1'b0}}, mem_rd_data[15: 0]};
                    end
                endcase
            end
        endcase
    end
    // OP S
    always @(*) begin
        case (opcode)
            `INST_OPCODE_S_TYPE: begin
                reg_we = 1'b0;
                mem_we = 1'b1;
                csr_we = 1'b0;
                jump_en = 1'b0;
                imm = {{(`REG_WIDTH-`INST_FUNC7_WIDTH-`INST_RD_WIDTH){func7[`INST_FUNC7_WIDTH - 1]}}, func7, rd};
                mem_addr = rs1_data + imm;
                case(func3)
                    `INST_OPCODE_S_SB: begin
                        mem_wr_data = {mem_rd_data[`REG_WIDTH-1: 8], rs2_data[7: 0]};
                    end
                    `INST_OPCODE_S_SH: begin
                        mem_wr_data = {mem_rd_data[`REG_WIDTH-1: 16], rs2_data[15: 0]};
                    end
                    `INST_OPCODE_S_SW: begin
                        mem_wr_data = rs2_data[31: 0];
                    end
                endcase
            end
        endcase
    end

    // OP B
    always @(*) begin
        case (opcode)
            `INST_OPCODE_B_TYPE: begin
                reg_we = 1'b0;
                mem_we = 1'b0;
                csr_we = 1'b0;
                jump = `INST_JUMP_B;
                imm = {{20{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
                case(func3)
                    `INST_OPCODE_B_BEQ: begin
                        jump_en = rs1_data == rs2_data;
                    end
                    `INST_OPCODE_B_BNE: begin
                        jump_en = rs1_data != rs2_data;
                    end
                    `INST_OPCODE_B_BLT: begin
                        jump_en = $signed(rs1_data) < $signed(rs2_data);
                    end
                    `INST_OPCODE_B_BGE: begin
                        jump_en = $signed(rs1_data) >= $signed(rs2_data);
                    end
                    `INST_OPCODE_B_BLTU: begin
                        jump_en = rs1_data < rs2_data;
                    end
                    `INST_OPCODE_B_BGEU: begin
                        jump_en = rs1_data >= rs2_data;
                    end
                endcase
            end
        endcase
    end
    // JAL
    always @(*) begin
        case (opcode)
            `INST_OPCODE_JAL_TYPE: begin
                reg_we = 1'b1;
                mem_we = 1'b0;
                csr_we = 1'b0;
                jump_en = 1'b1;
                imm = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
                jump = `INST_JUMP_JAL;
                rd_data = instruction_addr + `REG_WIDTH'h4;
            end
        endcase
    end
    // JALR
    always @(*) begin
        case (opcode)
            `INST_OPCODE_JALR_TYPE: begin
                reg_we = 1'b1;
                mem_we = 1'b0;
                csr_we = 1'b0;
                jump_en = 1'b1;
                imm = {{(`REG_WIDTH-`INST_FUNC7_WIDTH-`INST_RS2_WIDTH){func7[`INST_FUNC7_WIDTH - 1]}}, func7, rs2};
                jump = `INST_JUMP_JALR;
                rd_data = instruction_addr + `REG_WIDTH'h4;
            end
        endcase
    end

    // AUIPC
    always @(*) begin
        case (opcode)
            `INST_OPCODE_AUIPC_TYPE: begin
                rd_data = instruction_addr + {instruction[31:12], {12{1'b0}}};
                reg_we = 1'b1;
                mem_we = 1'b0;
                jump_en = 1'b0;
                csr_we = 1'b0;
            end
        endcase
    end
    // LUI
    always @(*) begin
        case (opcode)
            `INST_OPCODE_LUI_TYPE: begin
                rd_data = {instruction[31:12], {12{1'b0}}};
                reg_we = 1'b1;
                mem_we = 1'b0;
                jump_en = 1'b0;
                csr_we = 1'b0;
            end
        endcase
    end
    // NOP
    always @(*) begin
        case (opcode)
            `INST_OPCODE_NOP_TYPE: begin
                reg_we = 1'b0;
                csr_we = 1'b0;
                mem_we = 1'b0;
                jump_en = 1'b0;
            end
        endcase
    end

    // CSR
    always @(*) begin
        case (opcode)
            `INST_OPCODE_CSR_TYPE: begin
                rd_data = csr_rd_data;
                reg_we = 1'b1;
                csr_we = 1'b1;
                mem_we = 1'b0;
                jump_en = 1'b0;
                imm = {27'h0, instruction[19:15]};
                csr_wr_addr = csr;
                case(func3)
                    `INST_OPCODE_CSR_CSRRW: begin
                        csr_wr_data = rs1_data;
                    end
                    `INST_OPCODE_CSR_CSRRS: begin
                        csr_wr_data = csr_rd_data | rs1_data;
                    end
                    `INST_OPCODE_CSR_CSRRC: begin
                        csr_wr_data = csr_rd_data & (~rs1_data);
                    end
                    `INST_OPCODE_CSR_CSRRWI: begin
                        csr_wr_data = imm;
                    end
                    `INST_OPCODE_CSR_CSRRSI: begin
                        csr_wr_data = csr_rd_data | imm;
                    end
                    `INST_OPCODE_CSR_CSRRCI: begin
                        csr_wr_data = csr_rd_data & ~imm;
                    end
                endcase
            end
        endcase
    end
    // MUL
    wire [`REG_WIDTH-1: 0] mul_result;
    always @(*) begin
        case (opcode)
            `INST_OPCODE_R_TYPE: begin
                case (func7)
                    `INST_R_FUNC7_MUL_TYPE: begin
                        case (func3)
                            `INST_OPCODE_R_MUL, `INST_OPCODE_R_MULH,
                            `INST_OPCODE_R_MULSU, `INST_OPCODE_R_MULU: begin
                                reg_we = 1'b1;
                                csr_we = 1'b0;
                                mem_we = 1'b0;
                                jump_en = 1'b0;
                                rd_data = mul_result;
                            end
                        endcase
                    end
                endcase
            end
        endcase
    end

    mul_fast u_mul_fast(
        // input
        .rs1(rs1_data),
        .rs2(rs2_data),
        .func3(func3),
        // output
        .rd(mul_result)
    );
    // DIV
    wire                    div_ready;
    reg  [`REG_WIDTH-1:0]   div_dividend;
    reg  [`REG_WIDTH-1:0]   div_divisor;
    reg  [1:0]             div_op;
    wire [`REG_WIDTH-1:0]   div_result;
    wire div_busy;
    reg pre_ready;

    always @(*) begin
        case (opcode)
            `INST_OPCODE_R_TYPE: begin
                case (func7)
                    `INST_R_FUNC7_MUL_TYPE: begin
                        case (func3)
                            `INST_OPCODE_R_DIV, `INST_OPCODE_R_DIVU,
                            `INST_OPCODE_R_REM, `INST_OPCODE_R_REMU: begin
                                div_op = func3[1:0];
                                div_dividend = rs1_data;
                                div_divisor  = rs2_data;
                                div_op_start = `DIV_OP_START;
                                hold_flag = 1'b1;
                                csr_we = 1'b0;
                                mem_we = 1'b0;
                                jump_en = 1'b0;
                            end
                        endcase
                    end
                endcase
            end
        endcase
    end

    always @(*) 
        if (div_busy) begin
            div_op_start = 1'b0;
        end
    
    always @(posedge clk or negedge rst_n)
        if (!rst_n) begin
            pre_ready <= 0;
        end else if ((pre_ready == 1'b0) && (div_ready == 1'b1)) begin
            reg_we <= 1'b1;
            rd_data <= div_result;
            hold_flag <= 1'b0;
        end else begin
            pre_ready <= div_ready;
        end

    div #(
        .DW (`REG_WIDTH)
    ) u_div (
        // input
        .clk      (clk),
        .rst_n    (rst_n),
        .start    (div_op_start),
        .op       (div_op),
        .dividend (div_dividend),
        .divisor  (div_divisor),
        // output
        .result   (div_result),
        .ready    (div_ready),
        .busy     (div_busy)
    );

endmodule
