
module fifo #(
    parameter ADDRW = 4,
    parameter DATAW = 8
)(
    input clk,

    input i_rd_en,
    output wire[DATAW - 1:0] o_rd_data,

    input i_wr_en,
    input wire [DATAW - 1:0] i_wr_data,

    output o_full,
    output o_empty
);

reg[ADDRW:0] rd_ptr = { { ADDRW{1'b0} }, 1'b0 };
reg[ADDRW:0] wr_ptr = { { ADDRW{1'b0} }, 1'b0 };

rf_1r1w #(.ADDRW(ADDRW), .DATAW(DATAW)) rf_1r1w (.clk(clk), .i_rd_addr(rd_ptr[ADDRW - 1:0]),
                                                 .o_rd_data(o_rd_data), .i_wr_addr(wr_ptr[ADDRW - 1:0]),
                                                 .i_wr_data(i_wr_data), .i_wr_en(i_wr_en));

assign o_full  = ( rd_ptr[ADDRW - 1:0] == wr_ptr[ADDRW - 1:0] ) & ( rd_ptr[ADDRW] != wr_ptr[ADDRW] );
assign o_empty = ( rd_ptr[ADDRW - 1:0] == wr_ptr[ADDRW - 1:0] ) & ( rd_ptr[ADDRW] == wr_ptr[ADDRW] );

always @(posedge clk) begin
    if ( i_rd_en ) begin
        rd_ptr <= rd_ptr + 1;
    end

    if ( i_wr_en ) begin
        wr_ptr <= wr_ptr + 1;
    end
end

endmodule
