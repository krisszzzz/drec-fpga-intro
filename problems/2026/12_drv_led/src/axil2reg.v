module axil2reg #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter STRB_WIDTH = DATA_WIDTH/8
) (
    input  wire             clk,
    input  wire             rst_n,

    // AR
    input  wire [ADDR_WIDTH-1:0]  s_axil_araddr,
    input  wire            [2:0]  s_axil_arprot,
    input  wire                   s_axil_arvalid,
    output wire                   s_axil_arready,
    // R
    output wire [DATA_WIDTH-1:0]  s_axil_rdata,
    output wire            [1:0]  s_axil_rresp,
    output wire                   s_axil_rvalid,
    input  wire                   s_axil_rready,
    // AW
    input  wire [ADDR_WIDTH-1:0]  s_axil_awaddr,
    input  wire            [2:0]  s_axil_awprot,
    input  wire                   s_axil_awvalid,
    output wire                   s_axil_awready,
    // W
    input  wire [DATA_WIDTH-1:0]  s_axil_wdata,
    input  wire [STRB_WIDTH-1:0]  s_axil_wstrb,
    input  wire                   s_axil_wvalid,
    output wire                   s_axil_wready,
    // B
    output wire            [1:0]  s_axil_bresp,
    output wire                   s_axil_bvalid,
    input  wire                   s_axil_bready,
    // Register Read Interface
    output wire [ADDR_WIDTH-1:0]  reg_rd_addr,
    output wire                   reg_rd_en,
    input  wire [DATA_WIDTH-1:0]  reg_rd_data,
    input  wire                   reg_rd_okay,

    // Register Write Interface
    output wire [ADDR_WIDTH-1:0]  reg_wr_addr,
    output wire [DATA_WIDTH-1:0]  reg_wr_data,
    output wire [STRB_WIDTH-1:0]  reg_wr_strb,
    output wire                   reg_wr_en,
    input  wire                   reg_wr_okay
);

axil2reg_rd #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
) rd (
    .clk            (clk),
    .rst_n          (rst_n),
    .s_axil_araddr  (s_axil_araddr),
    .s_axil_arprot  (s_axil_arprot),
    .s_axil_arvalid (s_axil_arvalid),
    .s_axil_arready (s_axil_arready),
    .s_axil_rdata   (s_axil_rdata),
    .s_axil_rresp   (s_axil_rresp),
    .s_axil_rvalid  (s_axil_rvalid),
    .s_axil_rready  (s_axil_rready),
    .reg_rd_addr    (reg_rd_addr),
    .reg_rd_en      (reg_rd_en),
    .reg_rd_data    (reg_rd_data),
    .reg_rd_okay    (reg_rd_okay)
);

axil2reg_wr #(
    .DATA_WIDTH(DATA_WIDTH),
    .STRB_WIDTH(STRB_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
) wr (
    .clk            (clk),
    .rst_n          (rst_n),
    .s_axil_awaddr  (s_axil_awaddr),
    .s_axil_awprot  (s_axil_awprot),
    .s_axil_awvalid (s_axil_awvalid),
    .s_axil_awready (s_axil_awready),
    .s_axil_wdata   (s_axil_wdata),
    .s_axil_wstrb   (s_axil_wstrb),
    .s_axil_wvalid  (s_axil_wvalid),
    .s_axil_wready  (s_axil_wready),
    .s_axil_bresp   (s_axil_bresp),
    .s_axil_bvalid  (s_axil_bvalid),
    .s_axil_bready  (s_axil_bready),
    .reg_wr_addr    (reg_wr_addr),
    .reg_wr_data    (reg_wr_data),
    .reg_wr_strb    (reg_wr_strb),
    .reg_wr_en      (reg_wr_en),
    .reg_wr_okay    (reg_wr_okay)
);

endmodule