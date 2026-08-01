/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-07-26 18:39:29
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-07-31 22:47:18
 * @FilePath: /swift_riscv/rtl/core/div.v
 * @Description:  
 * 1. start 只需单周期高脉冲，不需要持续有效
 * 2. busy=1 表示正在计算；ready=1 表示商/余数有效（仅1周期）
 * 3. 外部输入在start脉冲时刻自动锁存，计算期间外部信号变化不影响运算
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */


module div #(
    parameter DW = 32
)(
    input  wire                      clk,
    input  wire                      rst_n,

    input  wire [DW-1:0]      dividend,
    input  wire [DW-1:0]      divisor,
    input  wire                      start,
    input  wire [1:0]                op,

    output reg                       ready,
    output reg                       busy,
    output reg [DW-1:0]       result
);

    // 指令编码（与 RISC-V 一致）
    localparam OP_DIV  = 2'b00;
    localparam OP_DIVU = 2'b01;
    localparam OP_REM  = 2'b10;
    localparam OP_REMU = 2'b11;

    // 状态定义
    localparam STATE_IDLE = 2'b00;
    localparam STATE_CALC = 2'b01;
    localparam STATE_END  = 2'b10;

    reg [1:0] cur_state, next_state;

    // 锁存的操作数与符号标志
    reg [DW-1:0] divd_r;        // 原始被除数（锁存）
    reg [DW-1:0] divs_r;        // 原始除数（锁存）
    reg [1:0]           op_r;          // 锁存的操作码
    reg                 quo_neg_flag;  // 商符号（有符号时为 1 表示负）
    reg                 rem_neg_flag;  // 余数符号（有符号时为 1 表示负）

    // 绝对值（扩展为 33 位，防止 -2³¹ 溢出）
    reg [DW:0]   dividend_abs;
    reg [DW:0]   divisor_abs;

    // 迭代寄存器
    reg [DW:0]   rem_r;         // 余数（33 位）
    reg [DW-1:0] quo_r;         // 商（32 位）
    reg [4:0]           cnt;           // 迭代计数器（0~31）

    // 组合逻辑：判断操作类型
    wire op_div  = (op_r == OP_DIV);
    wire op_divu = (op_r == OP_DIVU);
    wire op_rem  = (op_r == OP_REM);
    wire op_remu = (op_r == OP_REMU);

    // ----------------------------------------
    // 状态机时序部分
    // ----------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            cur_state <= STATE_IDLE;
        else
            cur_state <= next_state;
    end

    // ----------------------------------------
    // 状态转移组合逻辑
    // ----------------------------------------
    always @(*) begin
        next_state = cur_state;
        case (cur_state)
            STATE_IDLE: begin
                if (start)
                    next_state = STATE_CALC;
            end
            STATE_CALC: begin
                if (cnt == DW - 1)
                    next_state = STATE_END;
            end
            STATE_END: begin
                next_state = STATE_IDLE;
            end
        endcase
    end

    // ----------------------------------------
    // 运算与时序输出
    // ----------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ready        <= 1'b0;
            busy         <= 1'b0;
            result       <= '0;

            divd_r       <= '0;
            divs_r       <= '0;
            op_r         <= OP_DIV;
            quo_neg_flag <= 1'b0;
            rem_neg_flag <= 1'b0;
            dividend_abs <= '0;
            divisor_abs  <= '0;
            rem_r        <= '0;
            quo_r        <= '0;
            cnt          <= '0;
        end else begin
            // 默认 ready 为 0（只拉高一个周期）
            ready <= 1'b0;

            case (cur_state)
                STATE_IDLE: begin
                    busy <= 1'b0;
                    if (start) begin
                        busy <= 1'b1;
                        // 锁存输入
                        divd_r <= dividend;
                        divs_r <= divisor;
                        op_r   <= op;

                        // ---------- 计算绝对值（33 位） ----------
                        if (op_div || op_rem) begin
                            // 有符号
                            dividend_abs <= (dividend[DW-1]) ?
                                            {1'b0, -dividend} : {1'b0, dividend};
                            divisor_abs  <= (divisor[DW-1]) ?
                                            {1'b0, -divisor}  : {1'b0, divisor};
                            quo_neg_flag <= (dividend[DW-1] ^ divisor[DW-1]);
                            rem_neg_flag <= dividend[DW-1];
                        end else begin
                            // 无符号
                            dividend_abs <= {1'b0, dividend};
                            divisor_abs  <= {1'b0, divisor};
                            quo_neg_flag <= 1'b0;
                            rem_neg_flag <= 1'b0;
                        end

                        // 初始化迭代寄存器
                        rem_r <= '0;
                        quo_r <= '0;
                        cnt   <= '0;
                    end
                end

                STATE_CALC: begin
                    busy <= 1'b1;
                    if (divs_r == 0) begin
                        // 除数为零，直接跳到结束
                        cnt <= DW - 1;
                    end else begin
                        // ---------- 恢复余数除法核心迭代 ----------
                        // 使用临时变量避免多次非阻塞赋值冲突
                        reg [DW:0] next_rem;
                        reg [DW-1:0] next_quo;

                        // 左移一位并加入被除数的当前位
                        next_rem = {rem_r[DW-1:0], dividend_abs[DW-1 - cnt]};
                        if (next_rem >= divisor_abs) begin
                            next_rem = next_rem - divisor_abs;
                            next_quo = {quo_r[DW-2:0], 1'b1};
                        end else begin
                            next_quo = {quo_r[DW-2:0], 1'b0};
                        end

                        // 更新寄存器
                        rem_r <= next_rem;
                        quo_r <= next_quo;
                        cnt   <= cnt + 1'b1;
                    end
                end

                STATE_END: begin
                    busy  <= 1'b0;
                    ready <= 1'b1;

                    // ---------- 输出结果 ----------
                    if (divs_r == 0) begin
                        // RISC-V 除数为零规范
                        if (op_div || op_divu)
                            result <= {DW{1'b1}};  // 全 1
                        else  // REM / REMU
                            result <= divd_r;
                    end else begin
                        // 正常除法结果
                        reg [DW-1:0] quot, rem;

                        // 商的绝对值（32 位）
                        quot = quo_r;
                        // 余数的绝对值（取 rem_r 的低 32 位）
                        rem  = rem_r[DW-1:0];

                        // 符号修正
                        if (op_div && quo_neg_flag)
                            quot = -quot;
                        if (op_rem && rem_neg_flag)
                            rem  = -rem;

                        // 根据操作类型选择输出
                        if (op_div || op_divu)
                            result <= quot;
                        else // REM / REMU
                            result <= rem;
                    end
                end
            endcase
        end
    end

endmodule