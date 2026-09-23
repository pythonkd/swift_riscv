module ras_stack
#(
    parameter DEPTH = 8                                 // RAS 深度
)(
    input  wire                          clk,
    input  wire                          rst_n,
    input  wire                          push,           // call：压入返回地址
    input  wire                          pop,            // ret ：弹出返回地址
    input  wire [`REG_WIDTH-1:0]         push_addr,
    output wire [`REG_WIDTH-1:0]         top_addr,
    output wire                          empty,
    output wire                          full
);

    // 指针需要表示 0 ~ DEPTH，共 DEPTH+1 个状态
    localparam PW = $clog2(DEPTH + 1);

    reg [`REG_WIDTH-1:0] ras_mem [0:DEPTH-1];
    reg [PW-1:0]         sp_index;

    // ---------- 状态指示 ----------
    assign empty = (sp_index == {PW{1'b0}});
    assign full  = (sp_index == DEPTH);

    // ---------- 栈顶（组合读） ----------
    assign top_addr = empty ? {`REG_WIDTH{1'b0}}
                            : ras_mem[sp_index - 1'b1];

    // ---------- 时序更新 ----------
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sp_index <= {PW{1'b0}};
            for (i = 0; i < DEPTH; i = i + 1)
                ras_mem[i] <= {`REG_WIDTH{1'b0}};
        end
        else begin
            case ({push, pop})
                // 只 push：非满时写入并递增
                2'b10: begin
                    if (!full) begin
                        ras_mem[sp_index] <= push_addr;
                        sp_index          <= sp_index + 1'b1;
                    end
                end

                // 只 pop：非空时递减
                2'b01: begin
                    if (!empty)
                        sp_index <= sp_index - 1'b1;
                end

                // push 与 pop 同时：净效果是栈深度不变
                2'b11: begin
                    if (empty) begin
                        // 空栈：pop 是空操作，push 生效
                        ras_mem[sp_index] <= push_addr;
                        sp_index          <= sp_index + 1'b1;
                    end
                    else begin
                        // 非空：用新地址替换栈顶
                        ras_mem[sp_index - 1'b1] <= push_addr;
                    end
                end

                default: ;   // 2'b00：保持
            endcase
        end
    end

endmodule