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
