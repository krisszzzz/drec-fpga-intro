
/*
 * linear feedback shift register for generating pseudo-random 8-bit number
 * p(x) = x^8 + x^6 + x^4 + x^2 + 1 in GF(2)
 */
module lfsr(
    input wire clk,
    output wire[7:0] gen
);

reg[7:0] shift_data = 8'b0;
reg in_bit = 1'b0;
assign gen = shift_data;

always @(posedge clk) begin
    in_bit <= shift_data[7] ^ shift_data[5] ^ shift_data[3] ^ shift_data[1] ^ 1;
    shift_data <= { shift_data[6:0], in_bit };
end

endmodule