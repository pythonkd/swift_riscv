/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-08-08 10:59:04
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-08 11:48:37
 * @FilePath: /swift_riscv/rtl/core/int_switch.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */
module int_switch(
    input uart_int,
    output [`INTERRUPT_MAX_NUM-1: 0]int_src
);
    assign int_src[0] = 1'b0;
    assign int_src[1] = uart_int;
endmodule