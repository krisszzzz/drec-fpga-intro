module fpga_top(
   input  wire        CLK,
   input  wire [15:0] i_a,
   input  wire [15:0] i_b,
   output reg  [15:0] o_res
);

reg  [15:0] a;
reg  [15:0] b;
wire [15:0] res;

always @( posedge CLK ) begin
   a     <= i_a;
   b     <= i_b;
   o_res <= res;
end

fp16add_2stage fp16add_inst(
   .clk  (CLK),
   .i_a  (a  ),
   .i_b  (b  ),
   .o_res(res)
);

endmodule