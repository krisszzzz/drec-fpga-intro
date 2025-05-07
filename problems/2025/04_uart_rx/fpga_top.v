module fpga_top(
    input  wire CLK,
    input  wire RSTN,
    input  wire RXD,
    output wire TXD,

    output wire STCP,
    output wire SHCP,
    output wire DS,
    output wire OE
);

localparam RATE = 2_000_000;

// RSTN synchronizer
reg rst_n, RSTN_d;

always @(posedge CLK) begin
    rst_n <= RSTN_d;
    RSTN_d <= RSTN;
end

wire [7:0] o_data;
wire o_vld;

uart_rx #(
    .FREQ(50_000_000),
    .RATE(      RATE)
)
uart_rx (
    .clk        (CLK    ),
    .rst_n      (rst_n  ),
    .i_rx       (RXD    ),
    .o_data     (o_data ),
    .o_vld      (o_vld  )
);

wire  [3:0] anodes;
wire  [7:0] segments;

hex_display hex_display(CLK, rst_n, o_data, anodes, segments);

ctrl_74hc595 ctrl(
    .clk    (CLK                ),
    .rst_n  (rst_n              ),
    .i_data ({segments, anodes} ),
    .o_stcp (STCP               ),
    .o_shcp (SHCP               ),
    .o_ds   (DS                 ),
    .o_oe   (OE                 )
);

endmodule
