/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-08-04 21:35:19
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-09 22:44:03
 * @FilePath: /swift_riscv/rtl/core/clint.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */

module clint(
    input clk,
    input rst_n,
    input instruction_addr,
    input mret_occurred,
    input global_int_en,
    input ex_int_en,
    input hold_flag,
    input [`INTERRUPT_MAX_NUM - 1: 0]interrupts,
    output reg clint_csr_we,
    output reg [`INST_CSR_WIDTH - 1: 0]clint_wr_addr,
    output reg [`REG_WIDTH - 1: 0]clint_wr_data,
    output reg clint_hold_flag,
    output reg ex_int_process
);
    // reg [`INTERRUPT_MAX_NUM - 1: 0]interrupts_en;
    wire ex_int_occurred = |interrupts;
    reg [`INT_PROCESS_STATE_WIDTH - 1]curr_state;
    reg [`INT_PROCESS_STATE_WIDTH - 1]next_state;

    always @(posedge clk or negedge rst_n)
        if (!rst_n)
            curr_state <= `INT_PROCESS_STATE_END;
        else
            curr_state <= next_state;

    always @(*) begin
        clint_csr_we = 0;
        clint_hold_flag = 0;
        ex_int_process = 0;
        case (curr_state)
            `INT_PROCESS_STATE_END: begin
                if(global_int_en && ex_int_en && ex_int_occurred && (!hold_flag)) begin
                    next_state      = `INT_PROCESS_STATE_START;
                    clint_wr_addr   = `CSR_MEPC;
                    clint_wr_data   = instruction_addr;
                    clint_csr_we    = 1'b1;
                    clint_hold_flag = 1'b1;
                    ex_int_process  = 1'b1;
                end
            end
            `INT_PROCESS_STATE_START: begin
                if(mret_occurred) begin
                    next_state = `INT_PROCESS_STATE_END;
                end
            end
        endcase
    end

endmodule