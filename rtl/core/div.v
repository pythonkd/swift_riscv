/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-07-26 18:39:29
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-07-26 22:35:00
 * @FilePath: /SwiftRiscv/rtl/core/div.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */
module div_unit #(
    parameter DW = 32
)(
    input  clk,
    input  rst_n,
    input  start,
    input  [1:0] op,        // 00:DIV, 01:DIVU, 10:REM, 11:REMU
    input  [DW-1:0] dividend,
    input  [DW-1:0] divisor,
    output reg [DW-1:0] result,
    output reg ready,
    output reg busy
);

    // ---------- 状态机 ----------
    localparam IDLE = 2'b00, CALC = 2'b01, DONE = 2'b10;
    reg [1:0] state;
    reg [$clog2(DW+1)-1:0] cnt;   // 计数器宽度足够表示 0 ~ DW

    // ---------- 内部寄存器 ----------
    reg [DW-1:0] div_abs;         // 除数绝对值
    reg [DW-1:0] num_abs;         // 被除数绝对值
    reg                 sign_q, sign_r;   // 商的符号、余数的符号
    reg [DW-1:0] quo;             // 商（无符号）
    reg [2*DW-1:0] shift_reg;     // {余数, 被除数} 移位寄存器

    // ---------- 状态机与时序逻辑 ----------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            cnt   <= 0;
            ready <= 1'b0;
            busy  <= 1'b0;
            result <= {DW{1'b0}};
        end else begin
            case (state)
                IDLE: begin
                    ready <= 1'b0;
                    busy  <= 1'b0;
                    if (start && divisor != {DW{1'b0}}) begin
                        // 1. 符号处理
                        case (op)
                            2'b00, 2'b10: begin // 有符号
                                num_abs = (dividend[DW-1]) ? (~dividend + 1'b1) : dividend;
                                div_abs = (divisor[DW-1])  ? (~divisor  + 1'b1) : divisor;
                                sign_q  = dividend[DW-1] ^ divisor[DW-1];
                                sign_r  = dividend[DW-1];
                            end
                            2'b01, 2'b11: begin // 无符号
                                num_abs = dividend;
                                div_abs = divisor;
                                sign_q  = 1'b0;
                                sign_r  = 1'b0;
                            end
                        endcase
                        // 2. 初始化移位寄存器：高 DW 位为余数（0），低 DW 位为被除数
                        shift_reg <= { {DW{1'b0}}, num_abs };
                        quo <= {DW{1'b0}};
                        cnt <= 0;
                        state <= CALC;
                        busy <= 1'b1;
                    end
                end

                CALC: begin
                    // ---- 非恢复余数法一次迭代 ----
                    // 步骤1：左移 {余数, 被除数}
                    shift_reg <= shift_reg << 1;
                    // 步骤2：根据当前余数符号（shift_reg[2*DW-1]）加减除数
                    if (shift_reg[2*DW-1] == 1'b0) begin
                        // 余数为正：rem = rem - div
                        shift_reg[2*DW-1:DW] <= 
                            shift_reg[2*DW-1:DW] - div_abs;
                        // 商最低位设为 1
                        quo <= {quo[DW-2:0], 1'b1};
                    end else begin
                        // 余数为负：rem = rem + div
                        shift_reg[2*DW-1:DW] <= 
                            shift_reg[2*DW-1:DW] + div_abs;
                        // 商最低位设为 0
                        quo <= {quo[DW-2:0], 1'b0};
                    end
                    // 步骤3：判断是否完成所有位
                    if (cnt == DW - 1) begin
                        state <= DONE;    // 本次迭代后进入DONE
                    end else begin
                        cnt <= cnt + 1;
                    end
                end

                DONE: begin
                    // 从 shift_reg 中取出最终余数（高 DW 位）
                    // 注意：最后一次迭代后，余数可能为负，但算法保证最终余数符号正确
                    // 输出结果根据 op 选择商或余数，并调整符号
                    case (op)
                        2'b00: result = sign_q ? (~quo + 1'b1) : quo;          // DIV
                        2'b01: result = quo;                                   // DIVU
                        2'b10: result = sign_r ? (~shift_reg[2*DW-1:DW] + 1'b1) 
                                               : shift_reg[2*DW-1:DW]; // REM
                        2'b11: result = shift_reg[2*DW-1:DW];   // REMU
                    endcase
                    ready <= 1'b1;
                    busy  <= 1'b0;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule