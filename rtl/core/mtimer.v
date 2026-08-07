/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-08-04 22:19:11
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-04 22:20:46
 * @FilePath: /swift_riscv/rtl/core/mtimer.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */
module mtimer(
    input mtimer_clk,
    input rst_n,
    output mtimer_int
);
    localparam MTIMER0_LO = 11'h0;
    localparam MTIMER0_HI = 11'h4;
    localparam MTIMER0_CMP_LO = 11'h8;
    localparam MTIMER0_CMP_HI = 11'hC;

    localparam MTIMER_WIDTH = 64;
    reg mtimer_happend;
    reg [MTIMER_WIDTH - 1: 0]mtimer;
    reg [MTIMER_WIDTH - 1: 0]mtimer_cmp;
    assign mtimer_int = mtimer_happend ? 1'b1: 1'b0;

    always @(posedge mtimer_clk or negedge rst_n) begin
        if(!rst_n)
            mtimer <= 0;
        else begin
            mtimer <= mtimer + 1;
        end
    end

    always @(posedge mtimer_clk or negedge rst_n) begin
        if(!rst_n)
            mtimer_happend <= 0;
        else if (mtimer >= mtimer_cmp) begin
            mtimer_happend <= 1;
        end else begin
            mtimer_happend <= 0;
        end
    end

endmodule