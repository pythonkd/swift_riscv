/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-07-12 17:45:31
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-24 22:38:44
 * @FilePath: /swift_riscv/rtl/core/data_lm.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */

module d_lm(
   input clk,
   input rst_n,
   input [`STRB_WIDTH - 1: 0]mem_strb,
   input [`REG_WIDTH - 1:0]mem_addr,
   input [`REG_WIDTH - 1:0]mem_wr_data,
   input mem_we,
   output reg [`REG_WIDTH - 1:0]mem_rd_data,
   output reg data_err

);

   reg [`REG_WIDTH-1: 0]local_mem[0:`DATA_MEM_DEPTH-1];
   wire [1:0]addr_offset;
   wire [7:0]byte0;
   wire [7:0]byte1;
   wire [7:0]byte2;
   wire [7:0]byte3;

   assign addr_offset = addr[1:0];
   always @(posedge clk or negedge rst_n)
      if (!rst_n)
         data_err <= 0;
      else if(mem_addr[`DATA_MEM_WIDTH+1:2] > (`DATA_MEM_DEPTH - 1))
         data_err <= 1;
      else
         data_err <= 0;

   always @(posedge clk)
      if (!data_err & mem_we)
         local_mem[mem_addr[`DATA_MEM_WIDTH+1:2]] <= mem_wr_data;

   assign byte0 = local_mem[mem_addr[`DATA_MEM_WIDTH+1:2]][7:0];
   assign byte1 = local_mem[mem_addr[`DATA_MEM_WIDTH+1:2]][15:8];
   assign byte2 = local_mem[mem_addr[`DATA_MEM_WIDTH+1:2]][23:16];
   assign byte3 = local_mem[mem_addr[`DATA_MEM_WIDTH+1:2]][31:24];
   always @(*)
      if (data_err)
         mem_rd_data = `REG_WIDTH'b0;
      else begin
         case(addr_offset)
            2'b00: begin
               rdata_out[7:0]   = mem_strb[0] ? byte0 : 8'h00;
               rdata_out[15:8]  = mem_strb[1] ? byte1 : 8'h00;
               rdata_out[23:16] = mem_strb[2] ? byte2 : 8'h00;
               rdata_out[31:24] = mem_strb[3] ? byte3 : 8'h00;
            end
            2'b01: begin
               rdata_out[7:0]   = mem_strb[0] ? byte1 : 8'h00;
               rdata_out[15:8]  = mem_strb[1] ? byte2 : 8'h00;
               rdata_out[23:16] = mem_strb[2] ? byte3 : 8'h00;
            end
            2'b10: begin // access byte2, shift left 2 bytes
               rdata_out[7:0]   = mem_strb[0] ? byte2 : 8'h00;
               rdata_out[15:8]  = mem_strb[1] ? byte3 : 8'h00;
            end
            2'b11: begin
                  rdata_out[7:0]   = mem_strb[0] ? byte3 : 8'h00;
            end
         endcase
      end

endmodule
