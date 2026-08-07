module simple_bus(
    // master0
    input [`BUS_ADDR_WIDTH -1 : 0]mst0_addr,
    input [`BUS_ADDR_DATA_WIDTH - 1: 0]mst0_wdata,
    input mst0_we,
    // master1
    input [`BUS_ADDR_WIDTH -1 : 0]mst1_addr,
    input [`BUS_ADDR_DATA_WIDTH - 1: 0]mst1_wdata,
    input mst1_we,

    input slv0_ready,
    input slv1_ready,
    input [`BUS_ADDR_DATA_WIDTH - 1: 0]slv0_r_data,
    input [`BUS_ADDR_DATA_WIDTH - 1: 0]slv1_r_data,

    output [`BUS_ADDR_DATA_WIDTH - 1: 0]mst0_rdata,
    output [`BUS_ADDR_DATA_WIDTH - 1: 0]mst1_rdata,
    output [`BUS_ADDR_WIDTH -1 : 0]slv0_addr,
    output [`BUS_ADDR_DATA_WIDTH - 1: 0]slv0_wdata,
    output slv0_we,
    output slv0_sel,
    output slv0_penable,
    output [`BUS_ADDR_WIDTH -1 : 0]slv1_addr,
    output [`BUS_ADDR_DATA_WIDTH - 1: 0]slv1_wdata,
    output slv1_we,
    output slv1_sel,
    output slv1_penable
);
    wire [1:0]mst_sel;
    wire [1:0]state;
    wire mst_addr
    always @(*)
        if (mst0_addr)
            mst_sel = 2'b01;
        else if (mst1_addr)
            mst_sel = 2'b10;

    wire [`MST_ADDR_SEL_WIDTH -1: 0]mst_sel_addr = mst0_addr[`BUS_ADDR_WIDTH -1: `MST_ADDR_SEL_WIDTH];

    // slv0
    always @(*)
        case(state)
            `BUS_STATE_IDLE: begin
                slv0_sel = 1'b0;
                slv0_penable = 1'b0;
                slv1_sel = 1'b0;
                slv1_penable = 1'b0;
            end
            `BUS_STATE_SETUP begin
                if (mst_sel_addr == ``SLV0_ADDR_HI) begin
                    slv0_sel = 1'b1;
                    slv0_penable = 1'b0;
                end else if (mst_sel_addr == ``SLV1_ADDR_HI) begin
                    slv1_sel = 1'b1;
                    slv1_penable = 1'b0;
                end
            end
            `BUS_STATE_ENABLE begin
                if (mst_sel_addr == ``SLV0_ADDR_HI) begin
                    slv0_sel = 1'b1;
                    slv0_penable = 1'b1;
                end else if (mst_sel_addr == ``SLV1_ADDR_HI) begin
                    slv1_sel = 1'b1;
                    slv1_penable = 1'b1;
                end
            end
        endcase


    assign slv0_sel = slv0_ready & mst_sel[0] & (mst_sel_addr == `SLV0_ADDR_HI);
    assign slv0_addr = mst0_addr;
    assign slv0_wdata = mst0_wdata;
    assign slv0_we = mst0_we;

    // slv1
    assign slv1_sel = slv1_ready & mst_sel[1] & (mst_sel_addr == `SLV1_ADDR_HI);
    assign slv1_addr = mst0_addr;
    assign slv1_wdata = mst0_wdata;
    assign slv1_we = mst0_we;
    // mst read
    assign mst0_rdata_comb = mst_sel[0] & slv0_ready & slv0_r_data;

    alwasy @(posedge clk or negedge rst_n)
        if (!rst_n)
            mst0_rdata <= 0;
        else 
endmodule