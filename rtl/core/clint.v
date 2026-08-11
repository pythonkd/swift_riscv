/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-08-04 21:35:19
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-11 21:30:19
 * @FilePath: /swift_riscv/rtl/core/clint.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */

module clint(
    input clk,
    input rst_n,
    input [`REG_WIDTH -1: 0]instruction_addr,
    input mret_occurred,
    input global_int_en,
    input ex_int_en,
    input hold_flag,
    input [`REG_WIDTH - 1: 0]clint_wr_addr,
    input [`REG_WIDTH - 1: 0]clint_wr_data,
    input clint_we,
    input [`INTERRUPT_MAX_NUM - 1: 0]interrupts,
    output reg [`REG_WIDTH - 1: 0]clint_rd_data,
    output reg clint_csr_we,
    output reg [`INST_CSR_WIDTH - 1: 0]clint_csr_wr_addr,
    output reg [`REG_WIDTH - 1: 0]clint_csr_wr_data,
    output reg clint_hold_flag,
    output reg ex_int_process
);
    localparam INTERRUPTS_EN_ADDR = 0;

    reg [`INTERRUPT_MAX_NUM - 1: 0]interrupts_en;
    reg [`INT_PROCESS_STATE_WIDTH - 1]curr_state;
    reg [`INT_PROCESS_STATE_WIDTH - 1]next_state;

    always @(posedge clk or negedge rst_n)
        if (!rst_n)
            interrupts_en = 0;
        else if(clint_we) begin
            case (clint_wr_addr)
                INTERRUPTS_EN_ADDR: interrupts_en <= clint_wr_data;
            endcase
        end
    
    always @(*)
        case (clint_wr_addr)
            INTERRUPTS_EN_ADDR: clint_rd_data = interrupts_en;
            default: clint_rd_data = 0;
        endcase

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
                if(global_int_en && ex_int_en && (|(interrupts & interrupts_en)) && (!hold_flag)) begin
                    next_state      = `INT_PROCESS_STATE_START;
                    clint_csr_wr_addr   = `CSR_MEPC;
                    clint_csr_wr_data   = instruction_addr;
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