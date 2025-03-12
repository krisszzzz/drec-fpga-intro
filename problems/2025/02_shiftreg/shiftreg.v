module shiftreg(
    input wire clk,
    input wire in_bit,
    input wire[7:0] w_data,
    input wire w_en,
    output wire out_bit
);

reg[7:0] shift_data = 8'b0;
assign out_bit = shift_data[7];

always @(posedge clk) begin
    if ( w_en )
        shift_data <= w_data;
    else
        shift_data <= { shift_data[6:0], in_bit };
end

endmodule