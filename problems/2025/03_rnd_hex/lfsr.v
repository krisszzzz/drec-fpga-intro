
/*
 * linear feedback shift register for generating pseudo-random 16-bit number
 * p(x) = x^16 + x^14 + x^12 + x^10 + x^8 + x^6 + x^4 + x^2 + 1 in GF(2)
 */
module lfsr(
    input wire clk,
    input wire ce,
    input wire rst_n,
    output wire[15:0] gen
);

reg [15:0] shift_data = 16'b0;
reg in_bit = 1'b0;
assign gen = shift_data;

always @(posedge clk or negedge rst_n) begin
    if ( !rst_n ) begin
        shift_data <= 16'b0;
        in_bit <= 1'b0;
    end
    else if ( ce ) begin
        in_bit <= shift_data[15] ^ shift_data[13] ^ shift_data[11] ^ shift_data[9] ^
                  shift_data[7 ] ^ shift_data[5 ] ^ shift_data[3 ] ^ shift_data[1] ^ 1;
        shift_data <= { shift_data[14:0], in_bit };
    end
end

endmodule