/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-07-31 22:25:44
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-01 18:13:56
 * @FilePath: /swift_riscv/rtl/core/mul.v
 * @Description: 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */
module mul_fast (
    input  wire [31:0] rs1,
    input  wire [31:0] rs2,
    input  wire [2:0]  func3,
    output wire [31:0] rd
);

    // RISC-V M 扩展 func3 编码
    localparam MUL    = 3'b000;
    localparam MULH   = 3'b001;
    localparam MULHSU = 3'b010;
    localparam MULHU  = 3'b011;

    // ---------- 操作数扩展为 33 位有符号数（补码） ----------
    wire signed [34:0] a;   
    wire signed [32:0] b;   

    // 根据指令类型决定符号扩展方式
    assign a = (func3 == MULHU) ? {3'b0, rs1} : {{3{rs1[31]}}, rs1};

    assign b = (func3 == MULHU || func3 == MUL) ? {1'b0, rs2} :
               (func3 == MULHSU) ? {1'b0, rs2} :
               {rs2[31], rs2};

    // ---------- 基4 Booth 编码，生成 17 个部分积 ----------
    // 部分积为 signed [65:0] 类型，以支持符号扩展
    wire signed [65:0] pp [0:16];

    genvar i;
    generate
        for (i = 0; i < 17; i = i + 1) begin : booth_loop
            // 取乘数 b 的相邻位（含前一位作为参考）
            wire b_2i_minus1 = (i == 0) ? 1'b0 : b[2*i - 1];
            wire b_2i        = (2*i <= 32) ? b[2*i] : b[32];     // 当 2i=32 时取符号位
            wire b_2i_plus1  = (2*i+1 <= 32) ? b[2*i+1] : b[32]; // 当 2i+1=33 时取符号位

            wire [2:0] sel = {b_2i_plus1, b_2i, b_2i_minus1};

            // 根据编码选择部分积值（33位有符号）
            reg signed [35:0] pp_val;
            always @(*) begin
                case (sel)
                    3'b000, 3'b111: pp_val = 36'sd0;
                    3'b001, 3'b010: pp_val = a;           // +1 × a
                    3'b011:         pp_val = a << 1;      // +2 × a
                    3'b100:         pp_val = -(a << 1);   // -2 × a
                    3'b101, 3'b110: pp_val = -a;          // -1 × a
                endcase
            end

            // 将部分积符号扩展到66位，并左移 2*i 位
            wire signed [65:0] pp_ext = {{30{pp_val[35]}}, pp_val};
            assign pp[i] = pp_ext << (2*i);
        end
    endgenerate

    // ---------- 多级加法树压缩 17 个部分积 ----------
    // 第一级：每4个一组（最后一组单独）
    wire signed [65:0] sum0_3  = pp[0]  + pp[1]  + pp[2]  + pp[3];
    wire signed [65:0] sum4_7  = pp[4]  + pp[5]  + pp[6]  + pp[7];
    wire signed [65:0] sum8_11 = pp[8]  + pp[9]  + pp[10] + pp[11];
    wire signed [65:0] sum12_15= pp[12] + pp[13] + pp[14] + pp[15];
    wire signed [65:0] sum16   = pp[16];

    // 第二级：合并
    wire signed [65:0] sum0_7  = sum0_3  + sum4_7;
    wire signed [65:0] sum8_15 = sum8_11 + sum12_15;

    // 第三级：最终合并
    wire signed [65:0] sum0_15 = sum0_7 + sum8_15;
    wire signed [65:0] prod_66 = sum0_15 + sum16;

    // 取低64位作为乘积（因为33位×33位的结果低64位就是32位×32位的结果）
    wire [63:0] prod64 = prod_66[63:0];

    // ---------- 根据指令选择输出 ----------
    wire [31:0] low  = prod64[31:0];
    wire [31:0] high = prod64[63:32];

    assign rd = (func3 == MUL) ? low :
                (func3 == MULHU || func3 == MULH || func3 == MULHSU) ? high : 32'b0;

endmodule