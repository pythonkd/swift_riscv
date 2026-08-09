/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-07-12 17:01:28
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-09 09:27:11
 * @FilePath: /swift_riscv/rtl/core/instruction_lm.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */


 module i_lm(
   input clk,
   input [`REG_WIDTH - 1: 0]instruction_r_addr,
   input [`REG_WIDTH - 1: 0]instruction_w_addr,
   input [`REG_WIDTH - 1: 0]instruction_w_data,
   input instruction_we,
   output reg [`INST_WIDTH - 1: 0]instruction,
   output instruction_err
 );
 
   reg [`INST_WIDTH-1: 0]local_mem[0:`INST_MEM_DEPTH-1];

   assign instruction_err = instruction_r_addr[`INST_MEM_WIDTH+1: 2] > `INST_MEM_DEPTH-1 ? 1 : 0;

   always @(posedge clk)
      if (!instruction_err & instruction_we)
         local_mem[instruction_w_addr[`DATA_MEM_WIDTH+1:2]] <= instruction_w_data;

   always @(*)
   if (instruction_err)
      instruction = `INST_WIDTH'b0;
   else if((instruction_w_addr == instruction_r_addr) && instruction_we) begin
      instruction = instruction_w_data;
   end else begin
      instruction = local_mem[instruction_r_addr[`INST_MEM_WIDTH+1: 2]];
   end;
   

 endmodule
