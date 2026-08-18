/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-07-12 17:01:28
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-18 22:30:36
 * @FilePath: /swift_riscv/rtl/core/instruction_lm.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */


 module i_lm(
   input clk,
   input [`REG_WIDTH - 1: 0]instruction_rd_addr,
   input [`REG_WIDTH - 1: 0]instruction_wr_addr,
   input [`REG_WIDTH - 1: 0]instruction_wr_data,
   input instruction_we,
   output reg [`INST_WIDTH - 1: 0]instruction,
   output instruction_err
 );
 
   reg [`INST_WIDTH-1: 0]local_mem[0:`INST_MEM_DEPTH-1];

   // assign instruction_err = instruction_rd_addr[`INST_MEM_WIDTH+1: 2] > `INST_MEM_DEPTH-1 ? 1 : 0;
   assign instruction_err = 0;

   always @(posedge clk)
      if (!instruction_err & instruction_we)
         local_mem[instruction_wr_addr[`DATA_MEM_WIDTH+1:2]] <= instruction_wr_data;

   always @(*)
   if (instruction_err)
      instruction = `INST_WIDTH'b0;
   else if((instruction_wr_addr == instruction_rd_addr) && instruction_we) begin
      instruction = instruction_wr_data;
   end else begin
      instruction = local_mem[instruction_rd_addr[`INST_MEM_WIDTH+1: 2]];
   end;
   

 endmodule
