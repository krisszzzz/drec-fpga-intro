module addr_gen #(
    parameter WIDTH = 16,
    parameter SIZE = 4,
    parameter AXI_ADDR_WIDTH = 32
)(
    input  logic                        clk,
    input  logic                        rst_n,

    input  logic                        i_start,
    input  logic                        is_b,
    input  logic [AXI_ADDR_WIDTH - 1:0] base_addr_ab,
    input  logic [AXI_ADDR_WIDTH - 1:0] base_addr_c,

    // AXI4 Master Read Address Channel
    output logic [AXI_ADDR_WIDTH - 1:0] araddr,
    output logic                  [7:0] arlen,
    output logic                  [2:0] arsize,
    output logic                  [1:0] arburst,
    output logic                        arvalid,
    input  logic                        arready,

    // AXI4 Master Write Address Channel
    output logic [AXI_ADDR_WIDTH - 1:0] awaddr,
    output logic                  [7:0] awlen,
    output logic                  [2:0] awsize,
    output logic                  [1:0] awburst,
    output logic                        awvalid,
    input  logic                        awready
);

localparam AXI_DATA_WIDTH = WIDTH * SIZE;
localparam BURST_LEN = SIZE;

// FSM states
localparam WAIT_AB = 0;
localparam SAVE_C  = 1;

logic state;

assign arsize = $clog2(AXI_DATA_WIDTH / 8)[2:0];
assign awsize = $clog2(AXI_DATA_WIDTH / 8)[2:0];

// INCR Burst
assign arburst = 2'b01;
assign awburst = 2'b01;

assign arlen = BURST_LEN - 1;
assign awlen = BURST_LEN - 1;

assign arvalid = i_start & state == WAIT_AB;
assign araddr = state == WAIT_AB ? base_addr_ab : 0;

// write C if A passed
assign awvalid = i_start & state == WAIT_AB & is_b == 0;
assign awaddr = (state == WAIT_AB & is_b == 0) ? base_addr_c : 0;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= WAIT_AB;
    end else begin
        case (state)
            WAIT_AB: begin
                if (arvalid & arready & awvalid & awready) begin
                    state <= SAVE_C;
                end
            end

            SAVE_C: begin
                state <= WAIT_AB;
            end
        endcase
    end
end

endmodule