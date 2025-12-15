module axis_fifo #(
    parameter DATA_WIDTH  = 32,
    parameter DEPTH       = 8
) (
    input  wire                      clk,
    input  wire                      rst_n,

    // Slave interface (input)
    input  wire                      s_axis_tvalid,
    output wire                      s_axis_tready,
    input  wire [DATA_WIDTH-1:0]     s_axis_tdata,

    // Master interface (output)
    output wire                      m_axis_tvalid,
    input  wire                      m_axis_tready,
    output wire [DATA_WIDTH-1:0]     m_axis_tdata
);

localparam ADDRW = $clog2(DEPTH);

logic fifo_full;
logic fifo_empty;


fifo #(
    .ADDRW(ADDRW),
    .DATAW(DATA_WIDTH)
) fifo_inst (
    .clk(clk),
    .rst_n(rst_n),

    // Read if master is ready
    .i_rd_en(m_axis_tready && m_axis_tvalid),
    .o_rd_data(m_axis_tdata),

    // Write if slave is ready
    .i_wr_en(s_axis_tvalid && s_axis_tready),
    .i_wr_data(s_axis_tdata),

    .o_full(fifo_full),
    .o_empty(fifo_empty)
);

assign s_axis_tready = !fifo_full;
assign m_axis_tvalid = !fifo_empty;

endmodule