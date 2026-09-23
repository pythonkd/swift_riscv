module ras_stack
#(
    parameter DEPTH     = 8        // RAS栈深度
)(
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire                         push,  // call，压入返回地址
    input  wire                         pop,   // ret，弹出返回地址
    input  wire [`REG_WIDTH-1:0]         push_addr,
    output reg [`REG_WIDTH-1:0]          top_addr,
    output wire                         empty
);

// 存储数组
reg [`REG_WIDTH-1:0] ras_mem [0 : DEPTH-1];
reg [$clog2(DEPTH) - 1 : 0] sp_index;
reg [`REG_WIDTH - 1:0] tail_addr;

assign empty = (sp_index == 0);
assign full  = (sp_index == DEPTH);

always @(*) begin
    if(empty) begin
        top_addr = '0;
    end else begin
        top_addr = ras_mem[sp_index - 3'd1][`REG_WIDTH - 1: 0];
    end
end

integer i;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sp_index <= 0;
        for(i=0; i<DEPTH; i=i+1) begin
            ras_mem[i] <= '0;
        end
    end
    else begin
        if(push && pop) begin
            if(!empty) begin
                ras_mem[sp_index - 1'd1] <= push_addr;
            end
        end
        else if(pop && !push) begin
            if(!empty) begin
                sp_index <= sp_index - 1'd1;
            end
        end
        else if(push && !pop) begin
            if(!full) begin
                ras_mem[sp_index] <= push_addr;
                sp_index <= sp_index + 1'd1;
            end
            else begin
                for(i=0; i < DEPTH-1; i=i+1) begin
                    ras_mem[i] <= ras_mem[i + 1];
                end
                ras_mem[DEPTH - 1] <= push_addr;
            end
        end
        // else no op
    end
end

endmodule
