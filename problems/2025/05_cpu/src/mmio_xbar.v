
module mmio_xbar(
    input wire  [29:0] i_mmio_addr,
    input wire  [31:0] i_mmio_data,
    input wire  [3:0]  i_mmio_mask,
    input wire         i_mmio_wren,
    output wire [31:0] o_mmio_data,
    output wire [15:0] o_hexd_data,
    output wire        o_hexd_wren
);

reg[15:0] hexd_data;
assign o_hexd_data = hexd_data;
assign o_hexd_wren = i_mmio_wren;
assign o_mmio_data = 32'hXXXXXXXX;

always @(*) begin
    if (i_mmio_wren) begin
        if (i_mmio_mask[0])
            hexd_data[7:0] = i_mmio_data[7:0];
        if (i_mmio_mask[1])
            hexd_data[15:8] = i_mmio_data[15:8];
        if (i_mmio_mask[2])
            /* */;
        if (i_mmio_mask[3])
            /* */;
    end
end

endmodule