
/*
 * sign extend N-bit number to M-bit number
 */

module sign_ext #(
    parameter FROM_WIDTH = 16,
    parameter TO_WIDTH = 32
)(
    input wire [FROM_WIDTH - 1:0] in,
    output wire [TO_WIDTH - 1:0] out
);

wire sign_bit = in[FROM_WIDTH - 1];
localparam REPEAT_COUNT = TO_WIDTH - FROM_WIDTH;
assign out = {{REPEAT_COUNT{sign_bit}}, in};

endmodule


/*
 * sign extend N-bit number to M-bit number (using generate keyword)
 */

 module sign_ext_gen #(
    parameter FROM_WIDTH = 16,
    parameter TO_WIDTH = 32
 )(
    input wire [FROM_WIDTH - 1:0] in,
    output wire [TO_WIDTH - 1:0] out
);

assign out[FROM_WIDTH - 1:0] = in;

generate
    genvar i;
    for (i = 0; i < TO_WIDTH - FROM_WIDTH; i = i + 1) begin : copy_1_bit
    assign out[i + FROM_WIDTH] = in[FROM_WIDTH - 1];
    end
endgenerate

endmodule