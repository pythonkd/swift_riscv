module addr_mux(
    input [`REG_WIDTH - 1: 0]instruction_addr,
    input [`REG_WIDTH - 1: 0]mem_addr,
    input [`REG_WIDTH - 1: 0]mem_wr_data,
    input [`REG_WIDTH - 1:0]external_to_cpu_rd_data,
    input [`REG_WIDTH - 1: 0]ilm_to_cpu_data,
    input [`REG_WIDTH - 1: 0]dlm_to_cpu_data,
    input data_we,
    output reg cpu_w_dlm_en,
    output reg cpu_w_ilm_en,
    output reg cpu_w_external_en,
    output reg [`REG_WIDTH - 1:0]mem_rd_data,
    output reg [`REG_WIDTH - 1: 0]cpu_to_ilm_addr,
    output reg [`REG_WIDTH - 1: 0]cpu_to_ilm_data,
    output reg [`REG_WIDTH - 1: 0]cpu_to_dlm_addr,
    output reg [`REG_WIDTH - 1: 0]cpu_to_dlm_data,
    output reg [`REG_WIDTH - 1: 0]cpu_to_external_addr,
    output reg [`REG_WIDTH - 1: 0]cpu_to_external_data
);

    always @(*)
        if (instruction_addr < `ILM_END_ADDR_BASE) begin
            cpu_to_ilm_addr = instruction_addr;
            cpu_to_external_addr = 0;
            cpu_w_ilm_en = 0;
            mem_rd_data = ilm_to_cpu_data;
        end else begin
            cpu_to_external_addr = instruction_addr;
            cpu_w_ilm_en = 0;
            mem_rd_data = external_to_cpu_rd_data;
        end

    always @(*) begin
        cpu_w_ilm_en = 0;
        cpu_w_dlm_en = 0;
        cpu_w_external_en = 0;
        if ((mem_addr < `ILM_END_ADDR_BASE) && data_we) begin
            cpu_to_ilm_addr = mem_addr;
            cpu_w_ilm_en = data_we;
            cpu_to_ilm_data = mem_wr_data;
        end else if(mem_addr < `DLM_END_ADDR_BASE) begin
            cpu_to_dlm_addr = mem_addr;
            cpu_w_dlm_en = data_we;
            cpu_to_dlm_data = mem_wr_data;
            mem_rd_data = dlm_to_cpu_data;
        end else begin
            cpu_to_external_addr = mem_addr;
            cpu_w_external_en = data_we;
            cpu_to_external_data = mem_wr_data;
            mem_rd_data = external_to_cpu_rd_data;
        end
    end

endmodule