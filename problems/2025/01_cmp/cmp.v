
module branch_unit(
    input wire [31:0] i_a, i_b,
    input wire [2:0] cmp_op,
    output reg taken
);

always @(*) begin
    case (cmp_op)
    /* beq  */ 3'b000: taken = i_a == i_b;
    /* bne  */ 3'b001: taken = i_a != i_b;
    /* blt  */ 3'b010: taken = $signed(i_a) < $signed(i_b);
    /* bge  */ 3'b011: taken = $signed(i_a) >= $signed(i_b);
    /* bltu */ 3'b100: taken = i_a < i_b;
    /* bgeu */ 3'b101: taken = i_a >= i_b;
    default: taken = 1'bX;
    endcase
end

endmodule