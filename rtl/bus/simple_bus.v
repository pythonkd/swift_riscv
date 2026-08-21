module simple_bus(
    // master0
    input mst0_we,
    input mst0_penable,
    input [`BUS_ADDR_WIDTH -1 : 0]mst0_addr,
    input [`BUS_ADDR_DATA_WIDTH - 1: 0]mst0_wdata,
    input slv0_ready,
    input [`BUS_ADDR_DATA_WIDTH - 1: 0]slv0_rd_data,
    input slv1_ready,
    input [`BUS_ADDR_DATA_WIDTH - 1: 0]slv1_rd_data,
    // slave0
    output reg slv0_we,
    output reg slv0_sel,
    output reg slv0_penable,
    output reg [`BUS_ADDR_WIDTH -1 : 0]slv0_addr,
    output reg [`BUS_ADDR_DATA_WIDTH - 1: 0]slv0_wdata,
    // slave1
    output reg slv1_we,
    output reg slv1_sel,
    output reg slv1_penable,
    output reg [`BUS_ADDR_WIDTH -1 : 0]slv1_addr,
    output reg [`BUS_ADDR_DATA_WIDTH - 1: 0]slv1_wdata,
    output reg slv_ready,
    output reg [`BUS_ADDR_DATA_WIDTH - 1: 0]mst0_rdata
);
    wire [`MST_ADDR_SEL_WIDTH -1: 0]mst_sel_addr;

    assign mst_sel_addr = mst0_addr[`BUS_ADDR_WIDTH -1: `BUS_ADDR_WIDTH - `MST_ADDR_SEL_WIDTH];
    always @(*) begin
        slv0_sel = 0;
        slv1_sel = 0;
        slv_ready = 0;
        mst0_rdata = 0;
        slv0_penable = 0;
        slv1_penable = 0;
        slv0_we = 0;
        slv1_we = 0;
        case (mst_sel_addr)
            `SLV0_ADDR_HI: begin
                slv0_sel = 1;
                slv0_addr = mst0_addr;
                slv0_wdata = mst0_wdata;
                slv0_penable = mst0_penable;
                slv0_we = mst0_we;
                slv_ready = slv0_ready;
                mst0_rdata = slv0_rd_data;
            end
            `SLV1_ADDR_HI: begin
                slv1_sel = 1;
                slv1_addr = mst0_addr;
                slv1_wdata = mst0_wdata;
                slv1_penable = mst0_penable;
                slv1_we = mst0_we;
                slv_ready = slv1_ready;
                mst0_rdata = slv1_rd_data;
            end
        endcase
    end

endmodule