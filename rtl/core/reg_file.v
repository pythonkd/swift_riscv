/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-07-14 21:48:55
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-09 09:38:22
 * @FilePath: /swift_riscv/rtl/core/reg_file.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */

module reg_file(
    input clk,
    input rst_n,
    input reg_we,
    input [`INST_RD_WIDTH  - 1: 0]rd_index,
    input [`REG_WIDTH - 1: 0]rd_data,
    input [`INST_RS1_WIDTH  - 1: 0]rs1_index,
    input [`INST_RS2_WIDTH  - 1: 0]rs2_index,
    output reg [`REG_WIDTH - 1: 0]rs1_data,
    output reg [`REG_WIDTH - 1: 0]rs2_data
);
    reg [`REG_WIDTH-1:0] reg_f [0:`REG_DATA_DEPTH-1];

    always @(posedge clk or negedge rst_n)
        if (rst_n && (reg_we) && (rd_index != `INST_RD_WIDTH'b0))
            reg_f[rd_index] <= rd_data;
    
    always @(*)
        if (rs1_index == `INST_RS1_WIDTH'b0)
            rs1_data = `REG_WIDTH'b0;
        else if((rd_index == rs1_index) && reg_we) begin
            rs1_data = rd_data;
        end else begin
            rs1_data = reg_f[rs1_index];
        end
    
    always @(*) begin
        if (rs2_index == `INST_RS2_WIDTH'b0)
            rs2_data = `REG_WIDTH'b0;
        else if((rd_index == rs2_index) && reg_we) begin
            rs2_data = rd_data;
        end else begin
            rs2_data = reg_f[rs2_index];
        end
    end


    

endmodule