/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-07-12 16:09:51
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-17 22:20:12
 * @FilePath: /swift_riscv/verification/tb_freertos/testbench.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */

// `include "kun_riscv_defines.v"

module SwiftRiscv ();

reg                  clk;
reg                  rst_n;

// register file
wire [`REG_WIDTH-1:0] zero_x0  = u_soc_top.u_core_top. u_reg_file. reg_f[0];
wire [`REG_WIDTH-1:0] ra_x1    = u_soc_top.u_core_top. u_reg_file. reg_f[1];
wire [`REG_WIDTH-1:0] sp_x2    = u_soc_top.u_core_top. u_reg_file. reg_f[2];
wire [`REG_WIDTH-1:0] gp_x3    = u_soc_top.u_core_top. u_reg_file. reg_f[3];
wire [`REG_WIDTH-1:0] tp_x4    = u_soc_top.u_core_top. u_reg_file. reg_f[4];
wire [`REG_WIDTH-1:0] t0_x5    = u_soc_top.u_core_top. u_reg_file. reg_f[5];
wire [`REG_WIDTH-1:0] t1_x6    = u_soc_top.u_core_top. u_reg_file. reg_f[6];
wire [`REG_WIDTH-1:0] t2_x7    = u_soc_top.u_core_top. u_reg_file. reg_f[7];
wire [`REG_WIDTH-1:0] s0_fp_x8 = u_soc_top.u_core_top. u_reg_file. reg_f[8];
wire [`REG_WIDTH-1:0] s1_x9    = u_soc_top.u_core_top. u_reg_file. reg_f[9];
wire [`REG_WIDTH-1:0] a0_x10   = u_soc_top.u_core_top. u_reg_file. reg_f[10];
wire [`REG_WIDTH-1:0] a1_x11   = u_soc_top.u_core_top. u_reg_file. reg_f[11];
wire [`REG_WIDTH-1:0] a2_x12   = u_soc_top.u_core_top. u_reg_file. reg_f[12];
wire [`REG_WIDTH-1:0] a3_x13   = u_soc_top.u_core_top. u_reg_file. reg_f[13];
wire [`REG_WIDTH-1:0] a4_x14   = u_soc_top.u_core_top. u_reg_file. reg_f[14];
wire [`REG_WIDTH-1:0] a5_x15   = u_soc_top.u_core_top. u_reg_file. reg_f[15];
wire [`REG_WIDTH-1:0] a6_x16   = u_soc_top.u_core_top. u_reg_file. reg_f[16];
wire [`REG_WIDTH-1:0] a7_x17   = u_soc_top.u_core_top. u_reg_file. reg_f[17];
wire [`REG_WIDTH-1:0] s2_x18   = u_soc_top.u_core_top. u_reg_file. reg_f[18];
wire [`REG_WIDTH-1:0] s3_x19   = u_soc_top.u_core_top. u_reg_file. reg_f[19];
wire [`REG_WIDTH-1:0] s4_x20   = u_soc_top.u_core_top. u_reg_file. reg_f[20];
wire [`REG_WIDTH-1:0] s5_x21   = u_soc_top.u_core_top. u_reg_file. reg_f[21];
wire [`REG_WIDTH-1:0] s6_x22   = u_soc_top.u_core_top. u_reg_file. reg_f[22];
wire [`REG_WIDTH-1:0] s7_x23   = u_soc_top.u_core_top. u_reg_file. reg_f[23];
wire [`REG_WIDTH-1:0] s8_x24   = u_soc_top.u_core_top. u_reg_file. reg_f[24];
wire [`REG_WIDTH-1:0] s9_x25   = u_soc_top.u_core_top. u_reg_file. reg_f[25];
wire [`REG_WIDTH-1:0] s10_x26  = u_soc_top.u_core_top. u_reg_file. reg_f[26];
wire [`REG_WIDTH-1:0] s11_x27  = u_soc_top.u_core_top. u_reg_file. reg_f[27];
wire [`REG_WIDTH-1:0] t3_x28   = u_soc_top.u_core_top. u_reg_file. reg_f[28];
wire [`REG_WIDTH-1:0] t4_x29   = u_soc_top.u_core_top. u_reg_file. reg_f[29];
wire [`REG_WIDTH-1:0] t5_x30   = u_soc_top.u_core_top. u_reg_file. reg_f[30];
wire [`REG_WIDTH-1:0] t6_x31   = u_soc_top.u_core_top. u_reg_file. reg_f[31];

integer r;

initial begin
    #(`SIM_PERIOD * 30000);
    $display("Time Out");
    $finish;
end
localparam TEST_PASS = 32'habcd0000;
localparam TEST_FAIL = 32'habcd0001;
localparam TEST_END_ADDR = 8'h0;
localparam TEST_PRT_ADDR = 8'h4;
`define SW_TEST_CLOCK u_soc_top.u_crg.uart_clk
logic  [7:0]sw_test_prt;
logic sw_test_flag;
logic sw_test_prt_flag;
logic sw_sel;
assign sw_sel = u_soc_top.u_uart.uart_wr;
assign sw_test_flag = u_soc_top.u_uart.uart_run_ret[`REG_WIDTH-1:0];
assign sw_test_prt_flag = sw_sel && (u_soc_top.u_uart.addr[7:0] == TEST_PRT_ADDR);
assign sw_test_prt = u_soc_top.u_uart.uart_tx[7:0];

initial begin
    #(`SIM_PERIOD * 3000);
    $display("Time Out");
    $finish;
end

always @(posedge `SW_TEST_CLOCK)
    if(sw_test_prt_flag && (sw_test_prt > 32'h5) && (sw_test_prt < 32'h7f)) begin
        $write("%c", sw_test_prt[7:0]);
        $fflush();
    end

always begin
    wait((sw_test_flag == TEST_PASS) || (sw_test_flag == TEST_FAIL))   // wait sim end
        #(`SIM_PERIOD * 2 + 1)
        if (sw_test_flag == TEST_PASS) begin
            $display("~~~~~~~~~~~~~~~~~~~ PASS ~~~~~~~~~~~~~~~~~~~");
            #(`SIM_PERIOD * 1);
            $fsdbDumpflush();  // 强制刷新波形缓存
            $finish; 
        end 
        else begin
            $display("~~~~~~~~~~~~~~~~~~~ FAIL ~~~~~~~~~~~~~~~~~~~~");
            #(`SIM_PERIOD * 1);
            $display("=== Simulation stopped due to failure ===");
            $fsdbDumpflush();  // 强制刷新波形缓存
            $finish;      
        end
end

initial begin
    #(`SIM_PERIOD/2);
    clk = 1'b0;
    reset;
    inst_load();
    #(`SIM_PERIOD * 50);
    $fsdbDumpflush();  // 强制刷新波形缓存
    $finish;  
end

always #(`SIM_PERIOD/2) clk = ~clk;

task reset;                // reset 1 clock
    begin
        rst_n = 0; 
        #(`SIM_PERIOD * 1);
        rst_n = 1;
    end
endtask

task inst_load;
    begin
        $readmemh ("../../c_test/FreeRTOS/demo/freertos.data", u_soc_top.u_flash. local_mem);
        #(`SIM_PERIOD * 500);
    end
endtask

task reg_mem_clear;
    begin
        $readmemh ("../../data/data_mem_clear.data", u_soc_top.u_core_top. u_dlm. local_mem);
        $readmemh ("../../data/reg_file_clear.data", u_soc_top.u_core_top. u_reg_file. reg_f);
    end
endtask

soc_top u_soc_top(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         )
);

// iverilog 
initial begin
    $fsdbDumpfile("sim_out.fsdb");
    $fsdbDumpvars("+all");
end

endmodule
