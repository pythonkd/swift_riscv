/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-07-12 16:09:51
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-01 16:13:28
 * @FilePath: /swift_riscv/verification/tb/testbench.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */

// `include "kun_riscv_defines.v"

module SwiftRiscv ();

reg                  clk;
reg                  rst_n;

// register file
wire [`REG_WIDTH-1:0] zero_x0  = u_core_top. u_reg_file. reg_f[0];
wire [`REG_WIDTH-1:0] ra_x1    = u_core_top. u_reg_file. reg_f[1];
wire [`REG_WIDTH-1:0] sp_x2    = u_core_top. u_reg_file. reg_f[2];
wire [`REG_WIDTH-1:0] gp_x3    = u_core_top. u_reg_file. reg_f[3];
wire [`REG_WIDTH-1:0] tp_x4    = u_core_top. u_reg_file. reg_f[4];
wire [`REG_WIDTH-1:0] t0_x5    = u_core_top. u_reg_file. reg_f[5];
wire [`REG_WIDTH-1:0] t1_x6    = u_core_top. u_reg_file. reg_f[6];
wire [`REG_WIDTH-1:0] t2_x7    = u_core_top. u_reg_file. reg_f[7];
wire [`REG_WIDTH-1:0] s0_fp_x8 = u_core_top. u_reg_file. reg_f[8];
wire [`REG_WIDTH-1:0] s1_x9    = u_core_top. u_reg_file. reg_f[9];
wire [`REG_WIDTH-1:0] a0_x10   = u_core_top. u_reg_file. reg_f[10];
wire [`REG_WIDTH-1:0] a1_x11   = u_core_top. u_reg_file. reg_f[11];
wire [`REG_WIDTH-1:0] a2_x12   = u_core_top. u_reg_file. reg_f[12];
wire [`REG_WIDTH-1:0] a3_x13   = u_core_top. u_reg_file. reg_f[13];
wire [`REG_WIDTH-1:0] a4_x14   = u_core_top. u_reg_file. reg_f[14];
wire [`REG_WIDTH-1:0] a5_x15   = u_core_top. u_reg_file. reg_f[15];
wire [`REG_WIDTH-1:0] a6_x16   = u_core_top. u_reg_file. reg_f[16];
wire [`REG_WIDTH-1:0] a7_x17   = u_core_top. u_reg_file. reg_f[17];
wire [`REG_WIDTH-1:0] s2_x18   = u_core_top. u_reg_file. reg_f[18];
wire [`REG_WIDTH-1:0] s3_x19   = u_core_top. u_reg_file. reg_f[19];
wire [`REG_WIDTH-1:0] s4_x20   = u_core_top. u_reg_file. reg_f[20];
wire [`REG_WIDTH-1:0] s5_x21   = u_core_top. u_reg_file. reg_f[21];
wire [`REG_WIDTH-1:0] s6_x22   = u_core_top. u_reg_file. reg_f[22];
wire [`REG_WIDTH-1:0] s7_x23   = u_core_top. u_reg_file. reg_f[23];
wire [`REG_WIDTH-1:0] s8_x24   = u_core_top. u_reg_file. reg_f[24];
wire [`REG_WIDTH-1:0] s9_x25   = u_core_top. u_reg_file. reg_f[25];
wire [`REG_WIDTH-1:0] s10_x26  = u_core_top. u_reg_file. reg_f[26];
wire [`REG_WIDTH-1:0] s11_x27  = u_core_top. u_reg_file. reg_f[27];
wire [`REG_WIDTH-1:0] t3_x28   = u_core_top. u_reg_file. reg_f[28];
wire [`REG_WIDTH-1:0] t4_x29   = u_core_top. u_reg_file. reg_f[29];
wire [`REG_WIDTH-1:0] t5_x30   = u_core_top. u_reg_file. reg_f[30];
wire [`REG_WIDTH-1:0] t6_x31   = u_core_top. u_reg_file. reg_f[31];

integer r;

initial begin
    #(`SIM_PERIOD * 30000);
    $display("Time Out");
    $finish;
end

always begin
    wait(s10_x26 == 32'b1)   // wait sim end, when x26 == 1
        #(`SIM_PERIOD * 1 + 1)
        if (s11_x27 == 32'b1) begin
            $display("~~~~~~~~~~~~~~~~~~~ %s PASS ~~~~~~~~~~~~~~~~~~~",inst_name);
            #(`SIM_PERIOD * 1);
            reg_mem_clear;
        end 
        else begin
            $display("~~~~~~~~~~~~~~~~~~~ %s FAIL ~~~~~~~~~~~~~~~~~~~~",inst_name);
            $display("fail testnum = %2d", gp_x3);
            #(`SIM_PERIOD * 1);
            // $stop;
            for (r = 0; r < 32; r = r + 1)
                $display("x%2d = 0x%x", r, u_core_top. u_reg_file. reg_f[r]);
            $display("=== Simulation stopped due to failure ===");
            $fsdbDumpflush();  // 强制刷新波形缓存
            $finish;      
        end
end
localparam NAME_LEN = 17*8-1;
reg [NAME_LEN:0] inst_list [0:50];
reg [NAME_LEN:0] inst_name;
initial begin
    inst_list[0]  = "../../inst/ADD";   inst_list[1]  = "../../inst/SUB";   inst_list[2]  = "../../inst/XOR";
    inst_list[3]  = "../../inst/OR";    inst_list[4]  = "../../inst/AND";   inst_list[5]  = "../../inst/SLL";
    inst_list[6]  = "../../inst/SRL";   inst_list[7]  = "../../inst/SRA";   inst_list[8]  = "../../inst/SLT";
    inst_list[9]  = "../../inst/SLTU";  inst_list[10] = "../../inst/ADDI";  inst_list[11] = "../../inst/XORI";
    inst_list[12] = "../../inst/ORI";   inst_list[13] = "../../inst/ANDI";  inst_list[14] = "../../inst/SLLI";
    inst_list[15] = "../../inst/SRLI";  inst_list[16] = "../../inst/SRAI";  inst_list[17] = "../../inst/SLTI";
    inst_list[18] = "../../inst/SLTIU"; inst_list[19] = "../../inst/LB";    inst_list[20] = "../../inst/LH";
    inst_list[21] = "../../inst/LW";    inst_list[22] = "../../inst/LBU";   inst_list[23] = "../../inst/LHU";
    inst_list[24] = "../../inst/SB";    inst_list[25] = "../../inst/SH";    inst_list[26] = "../../inst/SW";
    inst_list[27] = "../../inst/BEQ";   inst_list[28] = "../../inst/BNE";   inst_list[29] = "../../inst/BLT";
    inst_list[30] = "../../inst/BGE";   inst_list[31] = "../../inst/BLTU";  inst_list[32] = "../../inst/BGEU";
    inst_list[33] = "../../inst/JAL";   inst_list[34] = "../../inst/JALR";  inst_list[35] = "../../inst/LUI";
    inst_list[36] = "../../inst/AUIPC"; inst_list[37] = "../../inst/DIV";   inst_list[38] = "../../inst/DIVU";
    inst_list[39] = "../../inst/REM";   inst_list[40] = "../../inst/REMU";  inst_list[41] = "../../inst/MUL";
    inst_list[42] = "../../inst/MULH";  inst_list[43] = "../../inst/MULHSU";inst_list[44] = "../../inst/MULHU";
end

integer k;
initial begin
    #(`SIM_PERIOD/2);
    clk = 1'b0;
    for (k = 0; k <= 44; k++) begin
        reset;
        inst_name = inst_list[k];
        inst_load(inst_name);
    end
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
    input [NAME_LEN:0] inst_name;
    begin
        // $display("inst_name:%s", inst_name);
        $readmemh (inst_name, u_core_top. u_ilm. local_mem);
        #(`SIM_PERIOD * 500);
    end
endtask

task reg_mem_clear;
    begin
        $readmemh ("../../data/data_mem_clear.data", u_core_top. u_dlm. local_mem);
        $readmemh ("../../data/reg_file_clear.data", u_core_top. u_reg_file. reg_f);
    end
endtask

core_top u_core_top(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         )
);

// iverilog 
initial begin
    $fsdbDumpfile("sim_out.fsdb");
    $fsdbDumpvars("+all");
end

endmodule
