module axi_sa_top #(
    parameter WIDTH = 16,
    parameter FIFO_STAGES = 8,
    parameter AXI_ADDR_WIDTH = 32
)(
    // Clock and reset
    input  wire                        clk,
    input  wire                        rst_n,

    output wire                        o_irq,

    // AXI4 Master Interface
    // Read Address Channel
    output wire [AXI_ADDR_WIDTH - 1:0] m_axi_araddr,
    output wire                        m_axi_arid,
    output wire                  [7:0] m_axi_arlen,
    output wire                  [2:0] m_axi_arsize,
    output wire                  [1:0] m_axi_arburst,
    output wire                  [2:0] m_axi_arprot,
    output wire                        m_axi_arvalid,
    input  wire                        m_axi_arready,

    // Read Data Channel
    // AXI_DATA_WIDTH = SIZE * WIDTH = 4 * WIDTH
    input  wire      [4 * WIDTH - 1:0] m_axi_rdata,
    input  wire                        m_axi_rid,
    input  wire                  [1:0] m_axi_rresp,
    input  wire                        m_axi_rlast,
    input  wire                        m_axi_rvalid,
    output wire                        m_axi_rready,

    // Write Address Channel
    output wire      [4 * WIDTH - 1:0] m_axi_awaddr,
    output wire                        m_axi_awid,
    output wire                  [7:0] m_axi_awlen,
    output wire                  [2:0] m_axi_awsize,
    output wire                  [1:0] m_axi_awburst,
    output wire                  [2:0] m_axi_awprot,
    output wire                        m_axi_awvalid,
    input  wire                        m_axi_awready,

    // Write Data Channel
    output wire      [4 * WIDTH - 1:0] m_axi_wdata,
    output wire                        m_axi_wvalid,
    input  wire                        m_axi_wready,
    output wire                        m_axi_wlast,

    // Write Response Channel
    input  wire                  [1:0] m_axi_bresp,
    input  wire                        m_axi_bid,
    input  wire                        m_axi_bvalid,
    output wire                        m_axi_bready,

    // AXI4 Lite Slave Interface
    input  wire      [AXI_ADDR_WIDTH - 1:0] s_axil_awaddr,
    input  wire                       [2:0] s_axil_awprot,
    input  wire                             s_axil_awvalid,
    output wire                             s_axil_awready,

    // AXIL_DATA_WIDTH = AXI_ADDR_WIDTH
    input  wire          [AXI_ADDR_WIDTH - 1:0] s_axil_wdata,
    input  wire      [AXI_ADDR_WIDTH / 8 - 1:0] s_axil_wstrb,
    input  wire                                 s_axil_wvalid,
    output wire                                 s_axil_wready,

    output wire                           [1:0] s_axil_bresp,
    output wire                                 s_axil_bvalid,
    input  wire                                 s_axil_bready,

    input  wire          [AXI_ADDR_WIDTH - 1:0] s_axil_araddr,
    input  wire                           [2:0] s_axil_arprot,
    input  wire                                 s_axil_arvalid,
    output wire                                 s_axil_arready,

    output wire           [AXI_ADDR_WIDTH - 1:0] s_axil_rdata,
    output wire                            [1:0] s_axil_rresp,
    output wire                                  s_axil_rvalid,
    input  wire                                  s_axil_rready
);

localparam SIZE = 4;
localparam AXI_DATA_WIDTH = SIZE * WIDTH;
localparam AXIL_ADDR_WIDTH = AXI_ADDR_WIDTH;
localparam AXIL_DATA_WIDTH = AXI_ADDR_WIDTH;

wire sa_i_vld;
wire sa_i_ready;
wire sa_o_vld;
wire sa_o_ready;
wire sa_is_b;
wire [AXI_DATA_WIDTH - 1:0] sa_i_ab;
wire [AXI_DATA_WIDTH - 1:0] sa_o_c;

wire csr_start_sgnl;
wire csr_is_b;
wire [AXI_ADDR_WIDTH - 1:0] csr_ab_addr;
wire [AXI_ADDR_WIDTH - 1:0] csr_c_addr;

reg [$clog2(SIZE):0] count; 

assign m_axi_arid    = 1'b0;
assign m_axi_arprot  = 3'b000;
assign m_axi_awid    = 1'b0;
assign m_axi_awprot  = 3'b000;

sa_csr #(
    .ADDR_WIDTH(AXIL_ADDR_WIDTH),
    .DATA_WIDTH(AXIL_DATA_WIDTH)
) sa_csr_inst (
    .clk(clk),
    .rst_n(rst_n),
    .s_axil_awaddr(s_axil_awaddr),
    .s_axil_awprot(s_axil_awprot),
    .s_axil_awvalid(s_axil_awvalid),
    .s_axil_awready(s_axil_awready),
    .s_axil_wdata(s_axil_wdata),
    .s_axil_wstrb(s_axil_wstrb),
    .s_axil_wvalid(s_axil_wvalid),
    .s_axil_wready(s_axil_wready),
    .s_axil_bresp(s_axil_bresp),
    .s_axil_bvalid(s_axil_bvalid),
    .s_axil_bready(s_axil_bready),
    .o_start_sgnl(csr_start_sgnl),
    .o_is_b(csr_is_b),
    .o_addr_AB(csr_ab_addr),
    .o_addr_C(csr_c_addr)
);

addr_gen #(
    .WIDTH(WIDTH),
    .SIZE(SIZE),
    .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)
) addr_gen_inst (
    .clk(clk),
    .rst_n(rst_n),
    .i_start(csr_start_sgnl),
    .is_b(csr_is_b),
    .base_addr_ab(csr_ab_addr),
    .base_addr_c(csr_c_addr),
    .o_done(o_irq),
    .araddr(m_axi_araddr),
    .arlen(m_axi_arlen),
    .arsize(m_axi_arsize),
    .arburst(m_axi_arburst),
    .arvalid(m_axi_arvalid),
    .arready(m_axi_arready),
    .rvalid(m_axi_rvalid),
    .rready(m_axi_rready),
    .rlast(m_axi_rlast),
    .awaddr(m_axi_awaddr),
    .awlen(m_axi_awlen),
    .awsize(m_axi_awsize),
    .awburst(m_axi_awburst),
    .awvalid(m_axi_awvalid),
    .awready(m_axi_awready),
    .bvalid(m_axi_bvalid),
    .bready(m_axi_bready)
);

assign sa_is_b      = csr_is_b;
assign sa_i_ab      = m_axi_rdata;
assign sa_i_vld     = m_axi_rvalid;
assign m_axi_rready = sa_o_ready;

assign m_axi_wdata  = sa_o_c;
assign m_axi_wvalid = sa_o_vld;
assign sa_i_ready   = m_axi_wready;

assign m_axi_wlast  = (count == (SIZE - 1)) && sa_o_vld;
assign m_axi_bready = 1'b1;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count <= 4'd0;
    end else begin
        if (sa_o_vld && m_axi_wready) begin
            if (count == (SIZE - 1))
                count <= 4'd0;
            else
                count <= count + 1'b1;
        end
    end
end

sa_flow_ctl #(
    .WIDTH(WIDTH),
    .SIZE(SIZE),
    .FIFO_STAGES(FIFO_STAGES)
) sa_flow_ctl_inst (
    .clk(clk),
    .rst_n(rst_n),
    .i_vld(sa_i_vld),
    .is_b(sa_is_b),
    .i_ab(sa_i_ab),
    .i_ready(sa_i_ready),
    .o_vld(sa_o_vld),
    .o_c(sa_o_c),
    .o_ready(sa_o_ready)
);

endmodule
