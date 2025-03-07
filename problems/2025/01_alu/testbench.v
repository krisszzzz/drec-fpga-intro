`timescale 1ns/1ps

module alu_tb;

localparam BEGIN_OP = 4'b0000;
localparam END_OP = 4'b1111;

reg[31:0] a = -32'd1;
reg[31:0] b = 32'd11;
wire[31:0] res;

reg[3:0] op = BEGIN_OP;

alu alu_inst(.i_a(a), .i_b(b), .i_op(op), .o_res(res));

always begin
    #1
    // add, sub, slt, sltu show in decimal
    if (op == 4'b0000 || op == 4'b0001 || op == 4'b0011 || op == 4'b0100)
        $display("[%t] a = %d, b = %d, op = %b, res = %d", $realtime, $signed(a), $signed(b), op, $signed(res));
    // otherwise binary
    else
        $display("[%t] a = %b, b = %b, op = %b, res = %b", $realtime, a, b, op, res);
    op = op + 1;

    if (op == END_OP) begin
        $display("[%t] Done", $realtime);
        $finish;
    end
end

initial begin
    $dumpvars;
    $display("[%t] Start", $realtime);
end

endmodule