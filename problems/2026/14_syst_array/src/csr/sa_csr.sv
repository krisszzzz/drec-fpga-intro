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

   // Register Outputs
   output logic                        o_start_sgnl,
   output logic                        o_is_b,
   output logic     [ADDR_WIDTH - 1:0] o_addr_AB,
   output logic     [ADDR_WIDTH - 1:0] o_addr_C
);

localparam START_SGNL_MAPPED_ADDR = 32'h4000_0000;
localparam IS_B_MAPPED_ADDR       = 32'h4000_0004;
localparam ADDR_AB_MAPPED_ADDR    = 32'h4000_0008;
localparam ADDR_C_MAPPED_ADDR     = 32'h4000_000C;

logic start_sgnl;
logic is_b;
logic [ADDR_WIDTH - 1:0] addr_AB, addr_C;
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
      start_sgnl <= 0;
      is_b <= 0;
      addr_AB <= '0;
      addr_C <= '0;
   end else begin
      // start signal work as trigger to start loading/computation 
      start_sgnl <= 0;

      if (wr_en) begin
         case (wr_addr)
            START_SGNL_MAPPED_ADDR: start_sgnl <= wr_data[0];
            IS_B_MAPPED_ADDR:       is_b       <= wr_data[0];
            ADDR_AB_MAPPED_ADDR:    addr_AB    <= wr_data;
            ADDR_C_MAPPED_ADDR:     addr_C     <= wr_data;
            default: ;
         endcase
      end
   end
end

always_comb begin
   case (wr_addr)
      START_SGNL_MAPPED_ADDR,
      IS_B_MAPPED_ADDR,
      ADDR_AB_MAPPED_ADDR,
      ADDR_C_MAPPED_ADDR: reg_wr_okay = 1'b1;
      default:            reg_wr_okay = 1'b0;
   endcase
end

assign o_start_sgnl = start_sgnl;
assign o_is_b    = is_b;
assign o_addr_AB = addr_AB;
assign o_addr_C  = addr_C;

endmodule