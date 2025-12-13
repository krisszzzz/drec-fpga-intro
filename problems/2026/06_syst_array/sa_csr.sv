module sa_csr #(
   parameter ADDR_WIDTH = 32,
   parameter DATA_WIDTH = 32
)(
   input  logic clk,
   input  logic rst_n,

   // AW
   input  logic     [ADDR_WIDTH - 1:0] s_axil_awaddr,
   input  logic                  [2:0] s_axil_awprot,
   input  logic                        s_axil_awvalid,
   output logic                        s_axil_awready,
   // W
   input  logic     [DATA_WIDTH - 1:0] s_axil_wdata,
   input  logic [DATA_WIDTH / 8 - 1:0] s_axil_wstrb, // STRB_WIDTH = DATA_WIDTH / 8
   input  logic                        s_axil_wvalid,
   output logic                        s_axil_wready,
   // B
   output logic                  [1:0] s_axil_bresp,
   output logic                        s_axil_bvalid,
   input  logic                        s_axil_bready,
   // AR (unused)
   input  logic [ADDR_WIDTH-1:0]  s_axil_araddr,
   input  logic            [2:0]  s_axil_arprot,
   input  logic                   s_axil_arvalid,
   output logic                   s_axil_arready,
   // R (unused)
   output logic [DATA_WIDTH-1:0]  s_axil_rdata,
   output logic            [1:0]  s_axil_rresp,
   output logic                   s_axil_rvalid,
   input  logic                   s_axil_rready,
   // Register Outputs
   output logic     [ADDR_WIDTH - 1:0] o_addr_A,
   output logic     [ADDR_WIDTH - 1:0] o_addr_B,
   output logic     [ADDR_WIDTH - 1:0] o_addr_C
);

localparam ADDR_A_MAPPED_ADDR = 32'h0000_0000;
localparam ADDR_B_MAPPED_ADDR = 32'h0000_0004;
localparam ADDR_C_MAPPED_ADDR = 32'h0000_0008;

logic [ADDR_WIDTH - 1:0] addr_A, addr_B, addr_C;
logic reg_wr_okay; // response: OK or SLVERR

// signals from axil2reg_wr
logic [ADDR_WIDTH - 1:0] wr_addr;
logic [DATA_WIDTH - 1:0] wr_data;
logic                    wr_en;

// AXI-lite write register adapter
axil2reg_wr #(
   .ADDR_WIDTH(ADDR_WIDTH),
   .DATA_WIDTH(DATA_WIDTH)
) u_axil2reg_wr (
   .clk           (clk),
   .rst_n         (rst_n),

   .s_axil_awaddr (s_axil_awaddr),
   .s_axil_awprot (s_axil_awprot),
   .s_axil_awvalid(s_axil_awvalid),
   .s_axil_awready(s_axil_awready),

   .s_axil_wdata  (s_axil_wdata),
   .s_axil_wstrb  (s_axil_wstrb),
   .s_axil_wvalid (s_axil_wvalid),
   .s_axil_wready (s_axil_wready),

   .s_axil_bresp  (s_axil_bresp),
   .s_axil_bvalid (s_axil_bvalid),
   .s_axil_bready (s_axil_bready),

   .reg_wr_addr   (wr_addr),
   .reg_wr_data   (wr_data),
   .reg_wr_strb   (),
   .reg_wr_en     (wr_en),
   .reg_wr_okay   (reg_wr_okay)
);

always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) begin
      addr_A <= '0;
      addr_B <= '0;
      addr_C <= '0;
   end else if (wr_en) begin
      case (wr_addr)
         ADDR_A_MAPPED_ADDR: addr_A <= wr_data;
         ADDR_B_MAPPED_ADDR: addr_B <= wr_data;
         ADDR_C_MAPPED_ADDR: addr_C <= wr_data;
         default: ;
      endcase
   end
end

always_comb begin
   case (wr_addr)
      ADDR_A_MAPPED_ADDR,
      ADDR_B_MAPPED_ADDR,
      ADDR_C_MAPPED_ADDR: reg_wr_okay = 1'b1;
      default:            reg_wr_okay = 1'b0;
   endcase
end

assign o_addr_A = addr_A;
assign o_addr_B = addr_B;
assign o_addr_C = addr_C;

endmodule