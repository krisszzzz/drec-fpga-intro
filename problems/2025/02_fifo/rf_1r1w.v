module rf_1r1w#(
    parameter ADDRW = 4,
    parameter DATAW = 8
)
(
    input  wire                clk,

    input  wire  [ADDRW - 1:0] i_rd_addr,
    output wire  [DATAW - 1:0] o_rd_data,

    input  wire  [ADDRW - 1:0] i_wr_addr,
    input  wire  [DATAW - 1:0] i_wr_data,
    input  wire                i_wr_en
);

reg [DATAW - 1:0] r[2 ** ADDRW - 1:0]; // Unpacked array

assign o_rd_data = r[i_rd_addr];

always @(posedge clk) begin
    if ( i_wr_en ) begin
        r[i_wr_addr] <= i_wr_data;
    end
end

endmodule