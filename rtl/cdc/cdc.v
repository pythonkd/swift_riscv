/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-09-09 21:33:39
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-09-09 22:53:58
 * @FilePath: /swift_riscv/rtl/cdc/cdc.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */
//展宽
module fast2slow_one_bit_w_cdc #(
    E_DW = 4
)(
    input i_clk_f,
    input i_rst_n_f,
    input i_pulse_f,
    input i_clk_s,
    input i_rst_n_s,
    output o_pulse_s
);
reg [E_DW - 1: 0]r_pulse_f_d;
wire w_pulse_f;
always @(posedge i_clk_f or negedge i_rst_n_f) begin
    if (!i_rst_n_f) begin
        r_pulse_f_d <= {E_DW{1'b0}};
    end else begin
        r_pulse_f_d <= {r_pulse_f_d[E_DW -2: 0], i_pulse_f};
    end
end
assign w_pulse_f = |r_pulse_f_d;

reg [E_DW - 1: 0]r_pulse_s_d;
always@(posedge i_clk_s or negedge i_rst_n_s) begin
    if(!i_rst_n_s) begin
        r_pulse_s_d <= {(DW-1){1'b0}};
    end else begin
        r_pulse_s_d <= {r_pulse_s_d[DW-2: 0], w_pulse_f};
    end
end
assign o_pulse_s = r_pulse_s_d[DW-1];
endmodule

//脉冲电平，边沿检测
module fast2slow_edge_cdc(
    input i_clk_f,
    input i_rst_n_f,
    input i_pulse_f,
    input i_clk_s,
    input i_rst_n_s,
    output o_pulse_s
);
reg toggle_f;
always @(posedge i_clk_f or negedge i_rst_n_f) begin
    if (!i_rst_n_f) begin
        toggle_f <= 0;
    end else begin
        if (i_pulse_f)
            toggle_f <= ~toggle_f;
    end
end

reg [2:0]r_reg_s_d;

always @(posedge i_clk_s or negedge i_rst_n_s) begin
    if (!i_rst_n_s) begin
        r_reg_s_d <= 0;
    end else begin
        r_reg_s_d <= {r_reg_s_d[1:0], toggle_f};
    end
end
assign o_pulse_s = r_pulse_s_d[1] ^ r_pulse_s_d[2];

endmodule
// 慢到快，单bit，直接打两拍
module slow2fast_bit_cdc (
    input i_clk_f,
    input i_rst_n_f,
    input i_clk_s,
    input i_pulse_s,
    output o_pulse_f
);
reg [1: 0]r_reg_d_f;

always(posedge i_clk_f or negedge i_rst_n_f) begin
    if (!i_rst_n_f) begin
        r_reg_d_f <= 0;
    end else begin
        r_reg_d_f <= {r_reg_d_f[0], i_pulse_s};
    end
end
assign o_pulse_f = r_reg_d_f[1];
endmodule

module slow2fast_gray_cdc #(
    DW=32
) (
    input i_clk_f,
    input i_clk_s,
    input [DW-1: 0]i_data_s,
    output [DW-1: 0]o_data_f
);
wire [DW-1: 0]gray_data_s;
assign gray_data_s = (i_data_s >> 1) ^ i_data_s;
reg [DW-1: 0]r_gray_f_d0;
reg [DW-1: 0]r_gray_f_d1;
always(posedge i_clk_f or negedge i_rst_n_f) begin
    if (!i_rst_n_f) begin
        r_gray_f_d0 <= 0;
        r_gray_f_d1 <= 0;
    end else begin
        r_gray_f_d0 <= gray_data_s;
        r_gray_f_d1 <= r_gray_f_d0;
    end
end

reg [DW-1: 0]r_reg_tmp_f;
integer i;
always @(*) begin
    r_reg_tmp_f[DW-1] = r_gray_f_d1[DW-1];
    for(i=DW-2; i >= 0; i++) begin
        r_reg_tmp_f[i] = r_reg_tmp_f[i+1] ^ r_gray_f_d1[i];
    end
end
assign o_data_f = r_reg_tmp_f;
endmodule