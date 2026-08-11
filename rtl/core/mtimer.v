/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-08-04 22:19:11
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-11 21:30:32
 * @FilePath: /swift_riscv/rtl/core/mtimer.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */
module mtimer(
    input mtimer_clk,
    input rst_n,
    input [`REG_WIDTH - 1: 0]mtimer_addr,
    input [`REG_WIDTH - 1: 0]mtimer_wr_data,
    input mtimer_we,
    output reg [`REG_WIDTH - 1: 0]mtimer_rd_data,
    output mtimer_int
);
    localparam MTIMER0_LO = 11'h0;
    localparam MTIMER0_HI = 11'h4;
    localparam MTIMER0_CMP_LO = 11'h8;
    localparam MTIMER0_CMP_HI = 11'hC;

    localparam MTIMER_WIDTH = 64;
    reg mtimer_happend;
    reg [MTIMER_WIDTH - 1: 0]mtimer_counter;
    reg [MTIMER_WIDTH - 1: 0]mtimer_cmp;
    assign mtimer_int = mtimer_happend ? 1'b1: 1'b0;

    always @(posedge mtimer_clk or negedge rst_n) begin
        if(!rst_n)
            mtimer_counter <= 0;
        else begin
            mtimer_counter <= mtimer_counter + 1;
        end
    end

    always @(*)
        case(mtimer_addr)
            MTIMER0_LO: mtimer_rd_data = mtimer_counter[31:0];
            MTIMER0_HI: mtimer_rd_data = mtimer_counter[63:32];
            MTIMER0_CMP_LO: mtimer_rd_data = mtimer_cmp[31:0];
            MTIMER0_CMP_HI: mtimer_rd_data = mtimer_cmp[63:32];
            default: mtimer_rd_data = 0;
        endcase
    
    always @(posedge mtimer_clk or negedge rst_n)
        if(mtimer_we) begin
            case (mtimer_addr)
                MTIMER0_LO: mtimer_counter[31:0] <= mtimer_wr_data;
                MTIMER0_HI: mtimer_counter[63:32] <= mtimer_wr_data;
                MTIMER0_CMP_LO: mtimer_cmp[31:0] <= mtimer_wr_data;
                MTIMER0_CMP_HI: mtimer_cmp[63:32] <= mtimer_wr_data;
            endcase
        end

    always @(posedge mtimer_clk or negedge rst_n) begin
        if(!rst_n)
            mtimer_happend <= 0;
        else if (mtimer_counter >= mtimer_cmp) begin
            mtimer_happend <= 1;
        end else begin
            mtimer_happend <= 0;
        end
    end

endmodule