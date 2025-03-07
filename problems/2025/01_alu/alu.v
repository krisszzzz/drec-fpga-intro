
/*
 * perform R operation of RV32I instruction set
 */

module alu(
    input wire [31:0] i_a, i_b,
    input wire [3:0] i_op,
    output reg [31:0] o_res
);

always @(*) begin
    case (i_op)
    /* add  */ 4'b0000: o_res = i_a + i_b;
    /* sub  */ 4'b0001: o_res = i_a - i_b;
    /* sll  */ 4'b0010: o_res = i_a << i_b[3:0];
    /* slt  */ 4'b0011: o_res = $signed(i_a) < $signed(i_b);
    /* sltu */ 4'b0100: o_res = $unsigned(i_a) < $unsigned(i_b);
    /* xor  */ 4'b0101: o_res = i_a ^ i_b;
    /* srl  */ 4'b0110: o_res = i_a >> i_b[3:0];
    /* sra  */ 4'b0111: o_res = i_a >>> i_b[3:0];
    /* or   */ 4'b1000: o_res = i_a | i_b;
    /* and  */ 4'b1001: o_res = i_a & i_b;
    default: o_res = 32'dX;
    endcase
end

endmodule