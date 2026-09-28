module saturating_counter (
    input clk,
    input rst_n,
    input update,
    input taken,
    output predict_taken
);
    localparam [1:0]STRONGLY_TAKEN = 2'b11;
    localparam [1:0]WEAKLY_TAKEN = 2'b10;
    localparam [1:0]WEAKLY_NOT_TAKEN = 2'b01;
    localparam [1:0]STRONGLY_NOT_TAKEN = 2'b00;
    reg [1:0] state;
    reg [1:0] nx_state;
    assign predict_taken = state[1];
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= WEAKLY_NOT_TAKEN;
        else
            state <= nx_state;
    end

    always @(*) begin
        case (state)
            STRONGLY_TAKEN :  nx_state = !update ? STRONGLY_TAKEN : taken ? STRONGLY_TAKEN : WEAKLY_TAKEN;
            WEAKLY_TAKEN : nx_state = !update ? WEAKLY_TAKEN : taken ? STRONGLY_TAKEN : WEAKLY_NOT_TAKEN;
            WEAKLY_NOT_TAKEN : nx_state = !update ? WEAKLY_NOT_TAKEN : taken ? WEAKLY_TAKEN : STRONGLY_NOT_TAKEN;
            STRONGLY_NOT_TAKEN : nx_state = !update ? STRONGLY_NOT_TAKEN : taken ? WEAKLY_NOT_TAKEN : STRONGLY_NOT_TAKEN;
            default: nx_state = STRONGLY_NOT_TAKEN;
        endcase
    end

endmodule