/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-07-14 21:48:55
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-07-28 21:16:59
 * @FilePath: /SwiftRiscv/rtl/core/reg_file.v
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
    
    always @(*)
        if (rs1_index == `INST_RS1_WIDTH'b0)
            rs1_data = `REG_WIDTH'b0;
        else
            rs1_data = reg_f[rs1_index];
    
    always @(*)
        if (rs2_index == `INST_RS2_WIDTH'b0)
            rs2_data = `REG_WIDTH'b0;
        else
            rs2_data = reg_f[rs2_index];
    
    always @(posedge clk or negedge rst_n)
        if (rst_n && (reg_we) && (rd_index != `INST_RD_WIDTH'b0))
            reg_f[rd_index] = rd_data;

endmodule