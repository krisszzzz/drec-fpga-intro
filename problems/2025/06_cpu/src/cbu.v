`include "cbu.vh"

module cbu(
    input wire [31:0] i_a, i_b,
    input wire [2:0] i_cmp_op,
    output reg o_taken
);

always @(*) begin
    case (i_cmp_op)
    `CBU_OP_EQ:  o_taken = i_a == i_b;
    `CBU_OP_NE:  o_taken = i_a != i_b;
    `CBU_OP_LT:  o_taken = $signed(i_a) < $signed(i_b);
    `CBU_OP_GE:  o_taken = $signed(i_a) >= $signed(i_b);
    `CBU_OP_LTU: o_taken = i_a < i_b;
    `CBU_OP_GEU: o_taken = i_a >= i_b;
    default:     o_taken = 1'bX;
    endcase
end

endmodule