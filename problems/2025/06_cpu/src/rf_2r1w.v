module rf_2r1w(
    input  wire        clk,

    input  wire  [4:0] i_rd_addr_1port,
    input  wire  [4:0] i_rd_addr_2port,
    output wire [31:0] o_rd_data_1port,
    output wire [31:0] o_rd_data_2port,

    input  wire   [4:0] i_wr_addr,
    input  wire  [31:0] i_wr_data,
    input  wire         i_wr_en
);


reg [31:0] r[31:0]; // Unpacked array

assign o_rd_data_1port = (i_rd_addr_1port == 0) ? 0 : r[i_rd_addr_1port];
assign o_rd_data_2port = (i_rd_addr_2port == 0) ? 0 : r[i_rd_addr_2port];

always @(posedge clk) begin
    if (i_wr_en) begin
        r[i_wr_addr] <= i_wr_data;
    end
end

endmodule