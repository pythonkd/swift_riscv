module crgclk_gate(
    input clk,
    input rst_n,
    input clk_gate,
    output o_clk
);
    assign o_clk = clk_gate & clk;
endmodule