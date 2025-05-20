module mem_xbar #(
    parameter DATA_START = 0,
    parameter DATA_LIMIT = 0,
    parameter MMIO_START = 0,
    parameter MMIO_LIMIT = 0
)(
    input wire  [29:0] i_addr,
    input wire  [31:0] i_data,
    input wire         i_wren,
    input wire  [3:0]  i_mask,
    output wire [31:0] o_data,
    output wire [29:0] o_dmem_addr,
    output wire [31:0] o_dmem_data,
    output wire [3:0]  o_dmem_mask,
    output wire        o_dmem_wren,
    input wire  [31:0] i_dmem_data,
    output wire [29:0] o_mmio_addr,
    output wire [31:0] o_mmio_data,
    output wire        o_mmio_wren,
    output wire [3:0]  o_mmio_mask,
    input wire  [31:0] i_mmio_data
);

reg [31:0] data;

wire is_dmem = (i_addr >= DATA_START) &&
               (i_addr < DATA_START + DATA_LIMIT);

wire is_mmio = (i_addr >= MMIO_START) &&
               (i_addr < MMIO_START + MMIO_LIMIT);

assign o_dmem_wren = i_wren && is_dmem;
assign o_dmem_addr = i_addr - DATA_START;
assign o_dmem_mask = i_mask;
assign o_dmem_data = i_data;

assign o_mmio_wren = i_wren && is_mmio;
assign o_mmio_addr = i_addr - MMIO_START;
assign o_mmio_mask = i_mask;
assign o_mmio_data = i_data;
assign o_data = data;

always @(*) begin
    if (!is_dmem && !is_mmio) begin
        data <= 32'hXXXXXXXX;
    end
    else if (is_dmem) begin
        data <= i_dmem_data;
    end
    else begin // is_mmio (overlapping is impossible)
        data <= i_mmio_data;
    end
end

endmodule