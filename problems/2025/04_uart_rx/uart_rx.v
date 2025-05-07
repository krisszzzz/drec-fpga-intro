
module uart_rx #(
    parameter FREQ=50_000_000,
    parameter RATE=2_000_000)
(
  input  wire       clk,
  input  wire       rst_n,
  input  wire       i_rx,
  output wire [7:0] o_data,
  output wire       o_vld
);

localparam [3:0] IDLE  = 0,
                 START = 1,
                 BIT0  = 2,
                 BIT1  = 3,
                 BIT2  = 4,
                 BIT3  = 5,
                 BIT4  = 6,
                 BIT5  = 7,
                 BIT6  = 8,
                 BIT7  = 9,
                 STOP  = 10;

reg [3:0] state, next_state;

reg rx_d;
reg rx_fall;

always @(posedge clk) begin
    rx_d <= i_rx;
end

always @(*) begin
    rx_fall = rx_d & !i_rx;
end

reg load;

always @(*) begin
    load = (state == IDLE) & rx_fall;
end

wire en;

counter #(
    .CNT_WIDTH($clog2(FREQ/RATE)),
    .CNT_LOAD(FREQ/RATE/2),
    .CNT_MAX(FREQ/RATE-1)
) cnt(
    .clk   (clk),
    .rst_n (rst_n),
    .i_load(load),
    .o_en  (en)
);

always @(posedge clk or negedge rst_n)
   state <= !rst_n ? IDLE : next_state;

always @(*) begin
  case (state)
  IDLE:  next_state = rx_fall ? START : state;
  // back to idle if i_rx != 0
  START: next_state = en      ? (i_rx ? START : BIT0) : state;
  BIT0:  next_state = en      ? BIT1  : state;
  BIT1:  next_state = en      ? BIT2  : state;
  BIT2:  next_state = en      ? BIT3  : state;
  BIT3:  next_state = en      ? BIT4  : state;
  BIT4:  next_state = en      ? BIT5  : state;
  BIT5:  next_state = en      ? BIT6  : state;
  BIT6:  next_state = en      ? BIT7  : state;
  BIT7:  next_state = en      ? STOP  : state;
  STOP:  next_state = en      ? IDLE  : state;
  default: next_state = state;
  endcase
end

reg shift_en;
always @(*) begin
    case (state)
    IDLE, START, STOP: shift_en = 0;
    default: shift_en = en;
    endcase
end

reg [7:0] data;

always @(posedge clk) begin
    if (shift_en) begin
        data <= {i_rx, data[7:1]};
    end
end

assign o_data = data;

reg vld;
always @(*) begin
    vld = i_rx & (state == STOP) & en;
end

assign o_vld = vld;

endmodule