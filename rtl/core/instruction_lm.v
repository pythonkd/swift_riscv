/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-07-12 17:01:28
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-07-18 18:52:12
 * @FilePath: /SwiftRiscv/rtl/instruction_lm.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */


 module i_lm(
    input [`REG_WIDTH - 1: 0]pc,
    output reg [`INST_WIDTH - 1: 0]instruction,
    output instruction_err
 );
 
   reg [`INST_WIDTH-1: 0]local_mem[0:`INST_MEM_DEPTH-1];

   assign instruction_err = pc[`INST_MEM_WIDTH+1: 2] > `INST_MEM_DEPTH-1 ? 1 : 0;
   always @(*)
   if (instruction_err)
      instruction = `INST_WIDTH'b0;
   else
      instruction = local_mem[pc[`INST_MEM_WIDTH+1: 2]];

 endmodule
