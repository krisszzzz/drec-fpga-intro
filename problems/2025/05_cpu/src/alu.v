/*
 * perform R operation of RV32I instruction set
 */

`include "alu.vh"

module alu(
    input wire [31:0] i_a, i_b,
    input wire [3:0] i_op,
    output reg [31:0] o_res
);

always @(*) begin
    case (i_op)
        `ALU_OP_ADD:  o_res = i_a + i_b;
        `ALU_OP_SUB:  o_res = i_a - i_b;
        `ALU_OP_SLL:  o_res = i_a << i_b[3:0];
        `ALU_OP_SLT:  o_res = $signed(i_a) < $signed(i_b);
        `ALU_OP_SLTU: o_res = $unsigned(i_a) < $unsigned(i_b);
        `ALU_OP_XOR:  o_res = i_a ^ i_b;
        `ALU_OP_SRL:  o_res = i_a >> i_b[3:0];
        `ALU_OP_SRA:  o_res = i_a >>> i_b[3:0];
        `ALU_OP_OR:   o_res = i_a | i_b;
        `ALU_OP_AND:  o_res = i_a & i_b;
        default:      o_res = 32'dX;
    endcase
end

endmodule