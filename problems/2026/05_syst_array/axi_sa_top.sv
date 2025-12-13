module axi_sa_top #(
    parameter WIDTH = 16,
    parameter FIFO_STAGES = 8,
    parameter AXI_ADDR_WIDTH = 32
)(
    // Clock and reset
    input  logic                        clk,
    input  logic                        rst_n,

    // Control interface
    input  logic                        i_start,
    input  logic                        is_b,
    input  logic [AXI_ADDR_WIDTH - 1:0] base_addr_ab,
    input  logic [AXI_ADDR_WIDTH - 1:0] base_addr_c,

    // AXI4 Master Interface
    // Read Address Channel
    output logic [AXI_ADDR_WIDTH - 1:0] m_axi_araddr,
    output logic                        m_axi_arid,
    output logic                  [7:0] m_axi_arlen,
    output logic                  [2:0] m_axi_arsize,
    output logic                  [1:0] m_axi_arburst,
    output logic                  [2:0] m_axi_arprot,
    output logic                        m_axi_arvalid,
    input  logic                        m_axi_arready,

    // Read Data Channel
    input  logic [AXI_DATA_WIDTH - 1:0] m_axi_rdata,
    input  logic                        m_axi_rid,
    input  logic                  [1:0] m_axi_rresp,
    input  logic                        m_axi_rlast,
    input  logic                        m_axi_rvalid,
    output logic                        m_axi_rready,

    // Write Address Channel
    output logic [AXI_ADDR_WIDTH - 1:0] m_axi_awaddr,
    output logic                        m_axi_awid,
    output logic                  [7:0] m_axi_awlen,
    output logic                  [2:0] m_axi_awsize,
    output logic                  [1:0] m_axi_awburst,
    output logic                  [2:0] m_axi_awprot,
    output logic                        m_axi_awvalid,
    input  logic                        m_axi_awready,

    // Write Data Channel
    output logic [AXI_DATA_WIDTH - 1:0] m_axi_wdata,
    output logic                        m_axi_wvalid,
    input  logic                        m_axi_wready,
    output logic                        m_axi_wlast,

    // Write Response Channel
    input  logic                  [1:0] m_axi_bresp,
    input  logic                        m_axi_bid,
    input  logic                        m_axi_bvalid,
    output logic                        m_axi_bready
);

localparam SIZE = 4;
localparam AXI_DATA_WIDTH = SIZE * WIDTH;

    logic sa_i_vld;
    logic sa_i_ready;
    logic sa_o_vld;
    logic sa_o_ready;
    logic sa_is_b;
    logic [SIZE-1:0][WIDTH-1:0] sa_i_ab;
    logic [SIZE-1:0][WIDTH-1:0] sa_o_c;

    // Instantiate address generator
    addr_gen #(
        .WIDTH(WIDTH),
        .SIZE(SIZE),
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)
    ) addr_gen_inst (
        .clk(clk),
        .rst_n(rst_n),

        .i_start(i_start),
        .is_b(is_b),
        .base_addr_ab(base_addr_ab),
        .base_addr_c(base_addr_c),

        // AXI Read Address
        .araddr(m_axi_araddr),
        .arlen(m_axi_arlen),
        .arsize(m_axi_arsize),
        .arburst(m_axi_arburst),
        .arvalid(m_axi_arvalid),
        .arready(m_axi_arready),

        // AXI Write Address
        .awaddr(m_axi_awaddr),
        .awlen(m_axi_awlen),
        .awsize(m_axi_awsize),
        .awburst(m_axi_awburst),
        .awvalid(m_axi_awvalid),
        .awready(m_axi_awready)
    );


    assign sa_is_b = is_b;
    assign sa_i_ab = m_axi_rdata;
    assign sa_i_vld = m_axi_rvalid;
    assign m_axi_rready = sa_o_ready;

    assign m_axi_wdata  = sa_o_c;
    assign m_axi_wvalid = sa_o_vld;
    assign sa_i_ready = m_axi_wready;

    logic [$clog2(SIZE):0] count = 0;
    assign m_axi_wlast = (count == SIZE - 1) & sa_o_vld;

    assign m_axi_bready = 1;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= 0;
        else begin
            if (sa_o_vld)
                count <= (count == SIZE - 1) ? 0 : count + 1;
        end
    end

    // Instantiate systolic array
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