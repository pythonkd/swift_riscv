module gshare #(
    parameter DW = 10
) (
    input clk,
    input rst_n,
    input update,
    input [DW-1: 0]write_index,
    input [DW-1: 0]read_index,
    input taken,
    output predict_taken
);
    wire [DW-1: 0]bhr_val;
    wire [DW-1 : 0]read_pht_addr;
    wire [DW-1 : 0]wirte_pht_addr;
    assign read_pht_addr = read_index ^ bhr_val;
    assign wirte_pht_addr = write_index ^ bhr_val;
    branch_history_register #(.DW(DW)) u_branch_history_register(
        .clk(clk),
        .rst_n(rst_n),
        .update(update),
        .taken(taken),
        .bhr_val(bhr_val)
    );
    pattern_history_table #(.DW(DW)) u_pattern_history_table (
        .clk(clk),
        .rst_n(rst_n),
        .taken(taken),
        .update(update),
        .read_pht_addr(read_pht_addr),
        .wirte_pht_addr(wirte_pht_addr),
        .predict_taken(predict_taken)
    );

endmodule

module branch_history_register #(
    parameter DW = 10
) (
    input clk,
    input rst_n,
    input update,
    input taken,
    output [DW - 1: 0]bhr_val
);
    reg [DW - 1: 0]bhr;
    assign bhr_val = bhr;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            bhr <= {DW{1'b1}};
        else if(update)
            bhr <= {{bhr[DW - 2: 0]}, {taken}};
        else
            bhr <= bhr;
    end
endmodule

module pattern_history_table #(
    parameter DW = 10
)
(
    input clk,
    input rst_n,
    input update,
    input taken,
    input [DW - 1: 0]read_pht_addr,
    input [DW - 1: 0]wirte_pht_addr,
    output predict_taken
);
localparam SAT_CNT_MAX = 1 << DW;
wire [SAT_CNT_MAX -1: 0]one_hot_update;
wire [SAT_CNT_MAX -1: 0]one_hot_taken;
wire [SAT_CNT_MAX -1: 0]one_hot_predict_taken;

assign one_hot_update = {{(SAT_CNT_MAX -1){1'b0}}, {update}} << wirte_pht_addr;
assign one_hot_taken = {{(SAT_CNT_MAX -1){1'b0}}, {taken}} << wirte_pht_addr;
assign predict_taken = one_hot_predict_taken[read_pht_addr];
generate
  for (genvar i = 0; i < SAT_CNT_MAX; i = i + 1) begin : sat_cnt
    saturating_counter u_saturating_counter(
        .clk(clk),
        .rst_n(rst_n),
        .update(one_hot_taken[i]),
        .taken(one_hot_update[i]),
        .predict_taken(one_hot_predict_taken[i])
    );
  end
endgenerate

endmodule

