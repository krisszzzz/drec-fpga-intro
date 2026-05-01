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

    // Done loading B or storing C
    output logic                        o_done,

    // AXI4 Master Read Address Channel
    output logic [AXI_ADDR_WIDTH - 1:0] araddr,
    output logic                  [7:0] arlen,
    output logic                  [2:0] arsize,
    output logic                  [1:0] arburst,
    output logic                        arvalid,
    input  logic                        arready,

    // AXI4 Master Read Channel (part of it, to check B load status)
    input  logic                        rvalid,
    input  logic                        rready,
    input  logic                        rlast,

    // AXI4 Master Write Address Channel
    output logic [AXI_ADDR_WIDTH - 1:0] awaddr,
    output logic                  [7:0] awlen,
    output logic                  [2:0] awsize,
    output logic                  [1:0] awburst,
    output logic                        awvalid,
    input  logic                        awready,

    // Write Response Channel (part of it, to check C store status)
    input  logic                        bvalid,
    input  logic                        bready
);

localparam AXI_DATA_WIDTH = WIDTH * SIZE;
localparam BURST_LEN = SIZE;

// FSM states
localparam IDLE = 2'b00; // do nothing, init state
localparam BUSY_RW = 2'b01; // Read B or write C
localparam DONE = 2'b10; // raise o_done

logic [1:0] state;

assign arsize = $clog2(AXI_DATA_WIDTH / 8);
assign awsize = $clog2(AXI_DATA_WIDTH / 8);

// INCR Burst
assign arburst = 2'b01;
assign awburst = 2'b01;

assign arlen = BURST_LEN - 1;
assign awlen = BURST_LEN - 1;

assign araddr = base_addr_ab;
assign awaddr = base_addr_c;


always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state   <= IDLE;
        arvalid <= 1'b0;
        awvalid <= 1'b0;
        o_done  <= 1'b0;
    end else begin
        case (state)
            IDLE: begin
                if (i_start) begin
                    state   <= BUSY_RW;
                    arvalid <= 1'b1;
                    // write only if not loading B
                    awvalid <= !is_b;
                    // reset only at the start of the next operation
                    o_done <= 1'b0;
                end
            end

            BUSY_RW: begin
                if (arvalid && arready) begin
                    arvalid <= 1'b0;
                end
                
                if (awvalid && awready) begin
                    awvalid <= 1'b0;
                end

                // LOAD B
                if (is_b) begin
                    if (rvalid & rready & rlast) begin
                        state <= DONE;
                    end
                // COMPUTE C
                end else begin 
                    if (bvalid & bready) begin
                        state <= DONE;
                    end
                end
            end

            DONE: begin
                o_done <= 1;
                state <= IDLE;
            end

            default: state <= IDLE;
        endcase
    end
end

endmodule