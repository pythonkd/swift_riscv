/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-07-12 17:45:31
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-08 12:05:58
 * @FilePath: /swift_riscv/rtl/core/data_lm.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */

module d_lm(
   input clk,
   input rst_n,
   input [`REG_WIDTH - 1:0]mem_addr,
   input [`REG_WIDTH - 1:0]mem_wr_data,
   input mem_we,
   output reg [`REG_WIDTH - 1:0]mem_rd_data,
   output reg data_err

);

   reg [`REG_WIDTH-1: 0]local_mem[0:`DATA_MEM_DEPTH-1];

   always @(posedge clk)
      if (!rst_n)
         data_err <= 0;
      else if(mem_addr[`DATA_MEM_WIDTH+1:2] > (`DATA_MEM_DEPTH - 1))
         data_err <= 1;

   always @(posedge clk)
      if (!data_err & mem_we)
         local_mem[mem_addr[`DATA_MEM_WIDTH+1:2]] <= mem_wr_data;

   always @(*)
      if (data_err)
         mem_rd_data = `REG_WIDTH'b0;
      else
         mem_rd_data = local_mem[mem_addr[`DATA_MEM_WIDTH+1:2]];

endmodule
