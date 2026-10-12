
module cache_way #(
    parameter CACHELINE_SIZE = 32, // cacheline大小
    parameter CACHELINES = 64 //每一路有多少个cacheline
) (
    input clk,
    input rst_n,
    input update_cacheline,
    input [CACHELINE_SIZE * 8 -1: 0]cacheline_data,
    input [`REG_WIDTH -1: 0]addr,
    input read_en,
    input write_en,
    input [`REG_WIDTH - 1: 0]write_data,
    input save_dirty_data_done,
    input [1:0]size, // 00:1, 01:2, 10:4, 11:8
    output [`REG_WIDTH -1: 0] read_data,
    output dirty_status,
    output hit,
    output [CACHELINE_SIZE * 8 -1: 0]dirty_data
);
    localparam CACHE_OFFSET_WIDTH = $clog2(CACHELINE_SIZE);
    localparam CACHE_INDEX_WIDTH = $clog2(CACHELINES);
    localparam CACHE_OFFSET_TAG_WIDTH = `REG_WIDTH - CACHE_OFFSET_WIDTH - CACHE_INDEX_WIDTH;
    wire [CACHE_OFFSET_WIDTH - 1: 0]offset;
    wire [CACHE_OFFSET_WIDTH + 2: 0]offset_base;
    wire [CACHE_INDEX_WIDTH - 1: 0]index;
    wire [CACHE_OFFSET_TAG_WIDTH - 1: 0]tag;
    reg [CACHELINES - 1: 0]dirty;
    reg [CACHELINES - 1: 0]valid;
    reg [CACHE_OFFSET_TAG_WIDTH - 1: 0]tag_data[0: CACHELINES - 1];
    reg [CACHELINE_SIZE * 8 -1: 0]data[0: CACHELINES - 1];
    assign tag = addr[`REG_WIDTH-1: `REG_WIDTH - CACHE_OFFSET_TAG_WIDTH];
    assign index = addr[CACHE_INDEX_WIDTH + CACHE_OFFSET_WIDTH -1: CACHE_OFFSET_WIDTH];
    assign offset = addr[CACHE_OFFSET_WIDTH -1: 0];
    assign offset_base = offset << 3;
    assign hit = (read_en | write_en) & valid[index] & (tag_data[index] == tag);
    assign read_data = !hit ? 0:
                        size == 2'b00 ? {{(`REG_WIDTH - 8 ){1'b0}}, {data[index][offset_base +: 8]}}:
                        size == 2'b01 ? {{(`REG_WIDTH - 16 << 3){1'b0}}, {data[index][offset_base +: 16]}}:
                        {{(`REG_WIDTH- 32){1'b0}}, {data[index][offset_base +: 32]}};
    assign dirty_status = dirty[index];
    assign dirty_data = data[index];
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid <= 'b0;
            dirty <= 'b0;
        end else if (update_cacheline & dirty_status) begin
            if (save_dirty_data_done) begin
                dirty[index] <= 1'b0;
                valid[index] <= 1'b1;
                tag_data[index] <= tag;
                data[index] <= cacheline_data;
            end else begin
            end
        end else if (update_cacheline) begin
            data[index] <= cacheline_data;
            valid[index] <= 1'b1;
            tag_data[index] <= tag;
            dirty[index] <= 1'b0;
        end else if (write_en) begin
            if (hit) begin
                dirty[index] <= 1'b1;
                case(size)
                    2'b00: data[index][offset_base +: 8] <= write_data[7:0];
                    2'b01: data[index][offset_base +: 16] <= write_data[15:0];
                    2'b10: data[index][offset_base +: 32] <= write_data[31:0];
                    default: data[index] <= data[index];
                endcase
            end else begin
            end
        end
    end
endmodule

module cache #(
    parameter WAYS = 4, //默认4路
    parameter CACHELINE_SIZE = 32, // cacheline大小
    parameter CACHESIZE = 8 // cache大小默认8K
) (
    input clk,
    input rst_n,
    input update_cacheline,
    input [CACHELINE_SIZE * 8 -1: 0]cacheline_data,
    input [`REG_WIDTH -1: 0]addr,
    input read_en,
    input write_en,
    input [`REG_WIDTH -1:0]write_data,
    input [1:0]size,
    input save_dirty_data_done,
    output hit,
    output [`REG_WIDTH -1: 0]read_data,
    output dirty_status,
    output [2:0]cur_state,
    output [CACHELINE_SIZE * 8 -1: 0]dirty_data
);
    localparam DEPTH = $clog2(WAYS);
    localparam CACHELINES = (1024 * CACHESIZE) / (WAYS * CACHELINE_SIZE); //每一路有多少个cacheline
    localparam CACHE_OFFSET_WIDTH = $clog2(CACHELINE_SIZE);
    localparam CACHE_INDEX_WIDTH = $clog2(CACHELINES);
    localparam CACHE_OFFSET_TAG_WIDTH = `REG_WIDTH - CACHE_OFFSET_WIDTH - CACHE_INDEX_WIDTH;

    wire [WAYS - 1 : 0]update_cacheline_onehot;
    wire [WAYS - 1 : 0]hit_ways;
    wire [WAYS - 1 : 0]dirty_status_ways;
    wire [CACHELINE_SIZE * 8 -1: 0]dirty_data_ways[0: WAYS - 1];
    wire [`REG_WIDTH -1: 0]read_data_ways[0: WAYS - 1];
    wire [`REG_WIDTH -1: 0]cacheline_align_pc;
    wire [CACHE_INDEX_WIDTH - 1: 0]index;
    reg [1:0]state;
    reg [1:0]nx_state;

    assign cacheline_align_pc = addr & ~(CACHELINE_SIZE - 1);
    assign hit = |hit_ways;
    assign dirty_status = |dirty_status_ways;
    assign cur_state = state;
    reg  [2 << DEPTH - 2: 0]plru_bits[0: CACHELINES -1]; //4 路的plru bits
    assign index = addr[CACHE_INDEX_WIDTH + CACHE_OFFSET_WIDTH -1: CACHE_OFFSET_WIDTH];
    assign dirty_data = dirty_status_ways[0] ? dirty_data_ways[0]:
                        dirty_status_ways[1] ? dirty_data_ways[1]:
                        dirty_status_ways[2] ? dirty_data_ways[2]:
                        dirty_status_ways[3] ? dirty_data_ways[3]: 0;
    assign read_data = hit_ways[0] ? read_data_ways[0]:
                       hit_ways[1] ? read_data_ways[1]:
                       hit_ways[2] ? read_data_ways[2]:
                       hit_ways[3] ? read_data_ways[3]: 0;

    assign update_cacheline_onehot = !update_cacheline | dirty_status ? 4'b0000 :
                                    (plru_bits[index] == 3'b000) ? 4'b0001:
                                    (plru_bits[index] == 3'b001) ? 4'b0010:
                                    (plru_bits[index] == 3'b010) ? 4'b0001:
                                    (plru_bits[index] == 3'b011) ? 4'b0010:
                                    (plru_bits[index] == 3'b100) ? 4'b0100:
                                    (plru_bits[index] == 3'b101) ? 4'b0100:
                                    (plru_bits[index] == 3'b110) ? 4'b1000 : 4'b1000;
    always @(*) begin
        if ((read_en | write_en) & hit) begin
            case (hit_ways)
                4'b0001: begin
                    plru_bits[index][0] = 1'b1;
                    plru_bits[index][2] = 1'b1;
                end
                4'b0010: begin
                    plru_bits[index][0] = 1'b1;
                    plru_bits[index][2] = 1'b0;
                end
                4'b0100: begin
                    plru_bits[index][0] = 1'b0;
                    plru_bits[index][1] = 1'b1;
                end
                4'b1000: begin
                    plru_bits[index][0] = 1'b0;
                    plru_bits[index][1] = 1'b0;
                end
                default: begin
                    plru_bits[index] = 3'b000;
                end
            endcase
        end else begin
            plru_bits[index] = 3'b000;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= `CACHE_IDLE;
        end else begin
            state <= nx_state;
        end
    end



    always @(*) begin
        case (state)
            `CACHE_IDLE: begin
                if ((read_en | write_en) & !hit) begin
                    nx_state = `CACHE_WAIT_UPDATE;
                end else begin
                    nx_state = `CACHE_IDLE;
                end
            end
            `CACHE_WAIT_UPDATE: begin
                if (update_cacheline & dirty_status) begin
                    nx_state = `CACHE_WAIT_WRITE_2_MEM;
                end else if (update_cacheline) begin
                    nx_state = `CACHE_IDLE;
                end else begin
                    nx_state = `CACHE_WAIT_UPDATE;
                end
            end
            `CACHE_WAIT_WRITE_2_MEM: begin
                if (save_dirty_data_done) begin
                    nx_state = `CACHE_IDLE;
                end else begin
                    nx_state = `CACHE_WAIT_WRITE_2_MEM;
                end
            end
            default: nx_state = `CACHE_IDLE;
        endcase
    end

    generate
    for (genvar i = 0; i < WAYS; i = i + 1) begin : gen_cache_way
            cache_way #(
                .CACHELINE_SIZE(CACHELINE_SIZE),
                .CACHELINES(CACHELINES)) u_cache_way(
                    .clk(clk),
                    .rst_n(rst_n),
                    .update_cacheline(update_cacheline_onehot[i]),
                    .cacheline_data(cacheline_data),
                    .addr(addr),
                    .read_en(read_en),
                    .write_en(write_en),
                    .write_data(write_data),
                    .save_dirty_data_done(save_dirty_data_done),
                    .size(size),
                    .read_data(read_data_ways[i]),
                    .dirty_status(dirty_status_ways[i]),
                    .hit(hit_ways[i]),
                    .dirty_data(dirty_data_ways[i])
            );
    end
    endgenerate

endmodule