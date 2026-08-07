module cpu_to_bus(
    input clk,
    input rst_n,
    input [`BUS_ADDR_WIDTH -1 : 0]cpu_addr,
    input [`BUS_ADDR_DATA_WIDTH - 1: 0]cpu_wdata,
    input cpu_we,
    input [`BUS_ADDR_DATA_WIDTH - 1: 0]slv_r_data,
    input slv_ready,
    output reg p_enable,
    output reg mst_we,
    output reg [`BUS_ADDR_WIDTH -1 : 0]mst_addr,
    output reg [`BUS_ADDR_DATA_WIDTH - 1: 0]mst_wdata,
    output reg [`BUS_ADDR_DATA_WIDTH - 1: 0]cpu_r_data,
    output reg bus_hold_cpu
);
    reg [`BUS_STATE_WIDTH -1 : 0]state;
    
    always@(posedge clk or negedge rst_n)
        if (!rst_n) begin
            state <= `BUS_STATE_IDLE;
            p_enable <= 1'b0;
            bus_hold_cpu <= 1'b0;
        end
        else if (slv_ready && (cpu_addr) && (state == `BUS_STATE_IDLE)) begin
            state <= `BUS_STATE_SETUP;
            mst_addr <= cpu_addr;
            mst_wdata<= cpu_wdata;
            mst_we <= cpu_we;
            p_enable <= 1'b0;
            bus_hold_cpu <= 1'b1;
        end else if(slv_ready && (state == `BUS_STATE_SETUP)) begin
            state <= `BUS_STATE_ENABLE;
            p_enable <= 1'b1;
            cpu_r_data <= slv_r_data;
            bus_hold_cpu <= 1'b0;
        end else begin
            state <= `BUS_STATE_IDLE;
            p_enable <= 1'b0;
            bus_hold_cpu <= 1'b0;
        end
endmodule