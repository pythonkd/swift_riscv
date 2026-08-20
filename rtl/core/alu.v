/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-07-14 22:22:10
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-20 22:01:27
 * @FilePath: /swift_riscv/rtl/core/alu.v
 * @Description: 统一译码的 ALU 模块
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */

module alu(
    input clk,
    input rst_n,
    input [`INST_WIDTH - 1: 0] instruction,
    input [`REG_WIDTH - 1: 0] instruction_addr,
    input [`REG_WIDTH - 1: 0] rs1_data,
    input [`REG_WIDTH - 1: 0] rs2_data,
    input [`REG_WIDTH - 1: 0] csr_rd_data,
    input [`REG_WIDTH - 1:0] mem_rd_data,
    input mem_rd_valid,
    output reg reg_we,
    output reg mem_we,
    output reg csr_we,
    output reg jump_en,
    output reg div_op_start,
    output alu_flush_flag,
    output alu_stall_flag,
    output reg ecall_except,
    output reg ebreak_except,
    output reg [`INST_JUMP_WIDTH - 1: 0] jump,
    output reg [`REG_WIDTH - 1: 0] imm,
    output reg [`REG_WIDTH - 1: 0] rd_data,
    output reg [`REG_WIDTH - 1:0] mem_wr_data,
    output reg [`REG_WIDTH - 1:0] mem_addr,
    output reg mem_req_valid,
    output reg [`REG_WIDTH - 1:0] csr_wr_data,
    output reg [`INST_CSR_WIDTH - 1:0] csr_wr_addr,
    output reg mret_occurred
);

    // 指令字段提取
    wire [`INST_OPCODE_WIDTH - 1: 0] opcode = instruction[`INST_OPCODE_BASE + `INST_OPCODE_WIDTH - 1: `INST_OPCODE_BASE];
    wire [`INST_RD_WIDTH - 1:0] rd = instruction[`INST_RD_BASE+`INST_RD_WIDTH-1:`INST_RD_BASE];
    wire [`INST_FUNC3_WIDTH - 1: 0] func3 = instruction[`INST_FUNC3_BASE + `INST_FUNC3_WIDTH - 1: `INST_FUNC3_BASE];
    wire [`INST_RS1_WIDTH - 1:0] rs1 = instruction[`INST_RS1_BASE+`INST_RS1_WIDTH-1:`INST_RS1_BASE];
    wire [`INST_RS2_WIDTH - 1:0] rs2 = instruction[`INST_RS2_BASE+`INST_RS2_WIDTH-1:`INST_RS2_BASE];
    wire [`INST_FUNC7_WIDTH - 1: 0] func7 = instruction[`INST_FUNC7_BASE + `INST_FUNC7_WIDTH - 1: `INST_FUNC7_BASE];
    wire [`INST_FUNC5_WIDTH - 1: 0] func5 = instruction[`INST_FUNC5_BASE + `INST_FUNC5_WIDTH - 1: `INST_FUNC5_BASE];
    wire [`INST_CSR_WIDTH - 1:0] csr = instruction[`INST_CSR_BASE+`INST_CSR_WIDTH-1:`INST_CSR_BASE];

    // 除法器相关信号
    reg div_stall_flag;
    wire div_ready;
    reg  [`REG_WIDTH-1:0] div_dividend;
    reg  [`REG_WIDTH-1:0] div_divisor;
    reg  [1:0] div_op;
    wire [`REG_WIDTH-1:0] div_result;
    wire div_busy;
    reg pre_ready;

    // 对外输出
    assign alu_flush_flag = ecall_except || ebreak_except || jump_en;
    assign alu_stall_flag = div_stall_flag;

    // ===================================================================
    // 乘法器实例
    // ===================================================================
    wire [`REG_WIDTH-1:0] mul_result;
    mul_fast u_mul_fast(
        .rs1   (rs1_data),
        .rs2   (rs2_data),
        .func3 (func3),
        .rd    (mul_result)
    );

    // ===================================================================
    // 除法器实例
    // ===================================================================
    div #(
        .DW (`REG_WIDTH)
    ) u_div (
        .clk      (clk),
        .rst_n    (rst_n),
        .start    (div_op_start),
        .op       (div_op),
        .dividend (div_dividend),
        .divisor  (div_divisor),
        .result   (div_result),
        .ready    (div_ready),
        .busy     (div_busy)
    );

    // ===================================================================
    // 主译码逻辑所有指令统一处理
    // ===================================================================
    always @(*) begin
        reg_we         = 1'b0;
        mem_we         = 1'b0;
        csr_we         = 1'b0;
        jump_en        = 1'b0;
        ecall_except   = 1'b0;
        ebreak_except  = 1'b0;
        mret_occurred  = 1'b0;
        div_op_start   = 1'b0;
        div_stall_flag  = 1'b0;
        mem_req_valid  = 1'b0;
        jump           = `INST_JUMP_WIDTH'b0;
        imm            = {`REG_WIDTH{1'b0}};
        rd_data        = {`REG_WIDTH{1'b0}};
        mem_wr_data    = {`REG_WIDTH{1'b0}};
        mem_addr       = {`REG_WIDTH{1'b0}};
        csr_wr_data    = {`REG_WIDTH{1'b0}};
        csr_wr_addr    = {`INST_CSR_WIDTH{1'b0}};

        // ---------- 根据 opcode 译码 ----------
        case (opcode)

            // ------------------------------------------------------------
            // 1. R 型指令（算术/逻辑/移位/乘除）
            // ------------------------------------------------------------
            `INST_OPCODE_R_TYPE: begin
                case (func7)
                    // -------- 基础运算 (ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND) --------
                    `INST_R_FUNC7_BASE_TYPE0,
                    `INST_R_FUNC7_BASE_TYPE1: begin
                        reg_we = 1'b1;
                        case (func3)
                            `INST_OPCODE_R_ADD:   rd_data = rs1_data + rs2_data;
                            `INST_OPCODE_R_SUB:   rd_data = rs1_data - rs2_data;
                            `INST_OPCODE_R_XOR:   rd_data = rs1_data ^ rs2_data;
                            `INST_OPCODE_R_OR:    rd_data = rs1_data | rs2_data;
                            `INST_OPCODE_R_AND:   rd_data = rs1_data & rs2_data;
                            `INST_OPCODE_R_SLL:   rd_data = rs1_data << rs2_data[4:0];
                            `INST_OPCODE_R_SRL:   rd_data = rs1_data >> rs2_data[4:0];
                            `INST_OPCODE_R_SRA:   rd_data = $signed(rs1_data) >>> rs2_data[4:0];
                            `INST_OPCODE_R_SLT:   rd_data = ($signed(rs1_data) < $signed(rs2_data)) ? `REG_WIDTH'b1 : `REG_WIDTH'b0;
                            `INST_OPCODE_R_SLTU:  rd_data = (rs1_data < rs2_data) ? `REG_WIDTH'b1 : `REG_WIDTH'b0;
                            default: ; // 保持默认
                        endcase
                    end

                    // -------- 乘法 (MUL, MULH, MULSU, MULU) --------
                    `INST_R_FUNC7_MUL_TYPE: begin
                        case (func3)
                            `INST_OPCODE_R_MUL,
                            `INST_OPCODE_R_MULH,
                            `INST_OPCODE_R_MULSU,
                            `INST_OPCODE_R_MULU: begin
                                reg_we = 1'b1;
                                rd_data = mul_result;
                            end
                            // -------- 除法 (DIV, DIVU, REM, REMU) --------
                            `INST_OPCODE_R_DIV,
                            `INST_OPCODE_R_DIVU,
                            `INST_OPCODE_R_REM,
                            `INST_OPCODE_R_REMU: begin
                                // 启动除法器，并停顿流水线
                                div_op      = func3[1:0];
                                div_dividend = rs1_data;
                                div_divisor  = rs2_data;
                                div_op_start = `DIV_OP_START;
                                div_stall_flag = 1'b1;
                                // 除法结果由独立的时序逻辑写回（见下方）
                            end
                            default: ;
                        endcase
                    end
                    default: ;
                endcase
            end

            // ------------------------------------------------------------
            // 2. I 型指令（立即数运算、移位、加载）
            // ------------------------------------------------------------
            `INST_OPCODE_I_TYPE: begin
                imm = {{(`REG_WIDTH-`INST_FUNC7_WIDTH-`INST_RS2_WIDTH){func7[`INST_FUNC7_WIDTH - 1]}}, func7, rs2};
                reg_we = 1'b1;
                case (func3)
                    `INST_OPCODE_I_ADDI:   rd_data = rs1_data + imm;
                    `INST_OPCODE_I_XORI:   rd_data = rs1_data ^ imm;
                    `INST_OPCODE_I_ORI:    rd_data = rs1_data | imm;
                    `INST_OPCODE_I_ANDI:   rd_data = rs1_data & imm;
                    `INST_OPCODE_I_SLLI:   rd_data = rs1_data << imm[4:0];
                    `INST_OPCODE_I_SLTI:   rd_data = ($signed(rs1_data) < $signed(imm)) ? `REG_WIDTH'b1 : `REG_WIDTH'b0;
                    `INST_OPCODE_I_SLTIU:  rd_data = (rs1_data < imm) ? `REG_WIDTH'b1 : `REG_WIDTH'b0;
                    `INST_OPCODE_I_SR: begin
                        case (func7)
                            `INST_I_FUNC7_BASE_TYPE0: rd_data = rs1_data >> imm[4:0];  // SRLI
                            `INST_I_FUNC7_BASE_TYPE1: rd_data = $signed(rs1_data) >>> imm[4:0]; // SRAI
                            default: ;
                        endcase
                    end
                    default: ;
                endcase
            end

            // ------------------------------------------------------------
            // 3. IL 型指令（加载）
            // ------------------------------------------------------------
            `INST_OPCODE_IL_TYPE: begin
                reg_we = 1'b1;
                imm = {{(`REG_WIDTH-`INST_FUNC7_WIDTH-`INST_RS2_WIDTH){func7[`INST_FUNC7_WIDTH - 1]}}, func7, rs2};
                mem_addr = rs1_data + imm;
                mem_req_valid = 1'b1;
                if (mem_rd_valid) begin
                    case (func3)
                        `INST_OPCODE_IL_LB:  rd_data = {{(`REG_WIDTH - 8){mem_rd_data[7]}}, mem_rd_data[7:0]};
                        `INST_OPCODE_IL_LH:  rd_data = {{(`REG_WIDTH - 16){mem_rd_data[15]}}, mem_rd_data[15:0]};
                        `INST_OPCODE_IL_LW:  rd_data = mem_rd_data[31:0];
                        `INST_OPCODE_IL_LBU: rd_data = {{(`REG_WIDTH - 8){1'b0}}, mem_rd_data[7:0]};
                        `INST_OPCODE_IL_LHU: rd_data = {{(`REG_WIDTH - 16){1'b0}}, mem_rd_data[15:0]};
                        default: ;
                    endcase
                end
            end

            // ------------------------------------------------------------
            // 4. S 型指令（存储）
            // ------------------------------------------------------------
            `INST_OPCODE_S_TYPE: begin
                mem_we = 1'b1;
                mem_req_valid = 1'b1;
                imm = {{(`REG_WIDTH-`INST_FUNC7_WIDTH-`INST_RD_WIDTH){func7[`INST_FUNC7_WIDTH - 1]}}, func7, rd};
                mem_addr = rs1_data + imm;
                case (func3)
                    `INST_OPCODE_S_SB: mem_wr_data = {mem_rd_data[`REG_WIDTH-1:8], rs2_data[7:0]};
                    `INST_OPCODE_S_SH: mem_wr_data = {mem_rd_data[`REG_WIDTH-1:16], rs2_data[15:0]};
                    `INST_OPCODE_S_SW: mem_wr_data = rs2_data[31:0];
                    default: ;
                endcase
            end

            // ------------------------------------------------------------
            // 5. B 型指令（分支）
            // ------------------------------------------------------------
            `INST_OPCODE_B_TYPE: begin
                jump = `INST_JUMP_B;
                imm = {{20{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
                case (func3)
                    `INST_OPCODE_B_BEQ:  jump_en = (rs1_data == rs2_data);
                    `INST_OPCODE_B_BNE:  jump_en = (rs1_data != rs2_data);
                    `INST_OPCODE_B_BLT:  jump_en = ($signed(rs1_data) < $signed(rs2_data));
                    `INST_OPCODE_B_BGE:  jump_en = ($signed(rs1_data) >= $signed(rs2_data));
                    `INST_OPCODE_B_BLTU: jump_en = (rs1_data < rs2_data);
                    `INST_OPCODE_B_BGEU: jump_en = (rs1_data >= rs2_data);
                    default: ;
                endcase
            end

            // ------------------------------------------------------------
            // 6. JAL 型指令（无条件跳转并链接）
            // ------------------------------------------------------------
            `INST_OPCODE_JAL_TYPE: begin
                reg_we  = 1'b1;
                jump_en = 1'b1;
                jump    = `INST_JUMP_JAL;
                imm     = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
                rd_data = instruction_addr + `REG_WIDTH'h4;
            end

            // ------------------------------------------------------------
            // 7. JALR 型指令（寄存器间接跳转并链接）
            // ------------------------------------------------------------
            `INST_OPCODE_JALR_TYPE: begin
                reg_we  = 1'b1;
                jump_en = 1'b1;
                jump    = `INST_JUMP_JALR;
                imm     = {{(`REG_WIDTH-`INST_FUNC7_WIDTH-`INST_RS2_WIDTH){func7[`INST_FUNC7_WIDTH - 1]}}, func7, rs2};
                rd_data = instruction_addr + `REG_WIDTH'h4;
            end

            // ------------------------------------------------------------
            // 8. AUIPC（PC 加立即数）
            // ------------------------------------------------------------
            `INST_OPCODE_AUIPC_TYPE: begin
                reg_we  = 1'b1;
                rd_data = instruction_addr + {instruction[31:12], {12{1'b0}}};
            end

            // ------------------------------------------------------------
            // 9. LUI（加载立即数到高20位）
            // ------------------------------------------------------------
            `INST_OPCODE_LUI_TYPE: begin
                reg_we  = 1'b1;
                rd_data = {instruction[31:12], {12{1'b0}}};
            end

            // ------------------------------------------------------------
            // 10. (ECALL, EBREAK, MRET, CSR)
            // ------------------------------------------------------------
            `INST_OPCODE_EI_TYPE: begin
                reg_we = 1'b1;      // CSR 指令默认写 rd
                csr_we = 1'b1;
                csr_wr_addr = csr;
                imm = {27'h0, instruction[19:15]};
                rd_data = csr_rd_data;   // 读 CSR 值

                case (func3)
                    `INST_FUNC3_EI_TYPE: begin   // ECALL/EBREAK/MRET
                        reg_we = 1'b0;           // 这些指令不写 rd
                        case (func7)
                            `INST_OPCODE_EI_ECALL: begin
                                ecall_except = 1;
                                csr_wr_data = instruction_addr;
                                csr_wr_addr = `CSR_MEPC;
                            end
                            `INST_OPCODE_EI_EREAK: begin
                                ebreak_except = 1;
                                csr_wr_data = instruction_addr;
                                csr_wr_addr = `CSR_MEPC;
                            end
                            `INST_OPCODE_EI_MRET: begin
                                mret_occurred = 1'b1;
                                csr_we = 1'b0;    // MRET 不写 CSR
                            end
                            default: ;
                        endcase
                    end
                    `INST_OPCODE_CSR_CSRRW:  csr_wr_data = rs1_data;
                    `INST_OPCODE_CSR_CSRRS:  csr_wr_data = csr_rd_data | rs1_data;
                    `INST_OPCODE_CSR_CSRRC:  csr_wr_data = csr_rd_data & (~rs1_data);
                    `INST_OPCODE_CSR_CSRRWI: csr_wr_data = imm;
                    `INST_OPCODE_CSR_CSRRSI: csr_wr_data = csr_rd_data | imm;
                    `INST_OPCODE_CSR_CSRRCI: csr_wr_data = csr_rd_data & ~imm;
                    default: ;
                endcase
            end

            // ------------------------------------------------------------
            // 11. FENCE（内存屏障）
            // ------------------------------------------------------------
            `INST_OPCODE_FENCE_TYPE: begin
                // 后续补全
            end

            // ------------------------------------------------------------
            // 12. NOP（空操作）
            // ------------------------------------------------------------
            `INST_OPCODE_NOP_TYPE: begin
                
            end

            default: ;
        endcase
    end

    // ===================================================================
    // 除法结果写回
    // ===================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pre_ready <= 1'b0;
        end else begin
            pre_ready <= div_ready;
            if ((pre_ready == 1'b0) && (div_ready == 1'b1)) begin
                reg_we    <= 1'b1;
                rd_data   <= div_result;
                div_stall_flag <= 1'b0;
            end
        end
    end

    // 当除法器忙时，禁止再次启动
    always @(*) begin
        if (div_busy) begin
            div_op_start = 1'b0;
        end
    end

endmodule