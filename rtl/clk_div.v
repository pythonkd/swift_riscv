/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-08-02 14:29:24
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-02 22:04:58
 * @FilePath: /swift_riscv/rtl/clk_div.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */

module clk_div #(
    parameter DIV_WIDTH = 16
) (
    input clk,
    input rst_n,
    input [DIV_WIDTH - 1: 0]divider,
    input rst_val,
    output wire clk_out
);
    reg [DIV_WIDTH - 1: 0] cnt;
    reg [DIV_WIDTH - 1: 0] div_cur;
    reg clk_out_tmp;

    assign clk_out = divider <= 1 ? clk : clk_out_tmp;
    always @(posedge clk or negedge rst_n)
        if (!rst_n) begin
            cnt <= 0;
            clk_out_tmp <= rst_val;
            div_cur <= 1;
        end
        else if (div_cur != divider) begin
            cnt <= 0;
            clk_out_tmp <= rst_val;
            div_cur <= divider ? divider : 1;
        end
        else if (cnt == ((div_cur >> 1) - 1)) begin
            clk_out_tmp <= ~clk_out_tmp;
            cnt <= 0;
        end
        else
            cnt <= cnt + 1;
endmodule

module crg_clk_gate_div #(
    parameter DW = 8,
    parameter DEFAULT_VAL = 0) (
        input clk,
        input rst_n,
        input [DW - 1: 0]div,
        output o_clk
);
    wire is_zero = div ? 0: 1;
    reg div_r1;
    reg div_r2;
    reg div_r3;
    reg [DW-1: 0]cnt;
    wire [DW-1: 0]cnt_nx;
    reg [DW-1: 0]div_latch;
    wire cnt_dec_done = ~(|cnt);
    assign cnt_nx = cnt_dec_done ? div_latch : cnt - 1;
    assign is_stable = div_r2 == div_r3;
    assign div_nx = is_stable ? (is_zero ? 1 : div) : div_latch;


    always @(posedge clk or negedge rst_n)
        if (!rst_n) begin
            div_r1 <= DEFAULT_VAL;
            div_r2 <= DEFAULT_VAL;
            div_r3 <= DEFAULT_VAL;
            cnt <= DEFAULT_VAL;
        end else begin
            div_r1 <= div;
            div_r2 <= div_r1;
            div_r3 <= div_r2;
            cnt <= cnt_nx;
            div_latch <= div_nx;
        end
endmodule