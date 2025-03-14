module hex_display #(
    parameter CNT_WIDTH = 14
)(
   input  wire        clk,
   input  wire        rst_n,
   input  wire [15:0] i_data,
   output wire [3:0]  o_anodes,
   output reg  [7:0]  o_segments
);

reg  [CNT_WIDTH-1:0] cnt;
wire [1:0] pos = cnt[CNT_WIDTH-1:CNT_WIDTH-2];
wire [3:0] digit;

mux4 #(.WIDTH(4)) mux4(i_data[3:0], i_data[7:4], i_data[11:8], i_data[15:12], pos, digit);

always @(posedge clk or negedge rst_n)
   cnt <= !rst_n ? {CNT_WIDTH{1'b0}} : (cnt + 1'b1);

assign o_anodes = ~(4'b1 << pos);

always @(*) begin
   case (digit)
       4'h0: o_segments = 8'b11111100;
       4'h1: o_segments = 8'b01100000;
       4'h2: o_segments = 8'b11011010;
       4'h3: o_segments = 8'b11110010;
       4'h4: o_segments = 8'b01100010;
       4'h5: o_segments = 8'b10110110;
       4'h6: o_segments = 8'b11111010;
       4'h7: o_segments = 8'b11100000;
       4'h8: o_segments = 8'b11111110;
       4'h9: o_segments = 8'b11110110;
       4'hA: o_segments = 8'b11101110;
       4'hB: o_segments = 8'b10111110;
       4'hC: o_segments = 8'b10011100;
       4'hD: o_segments = 8'b00111110;
       4'hE: o_segments = 8'b10011110;
       4'hF: o_segments = 8'b10001110;
   endcase
end

endmodule
