`timescale 1ns/1ps

module cmp_tb;

localparam CMP_OP_BEGIN = 3'b000;
localparam CMP_OP_END = 3'b111;

wire [31:0] a = 32'd10;
wire [31:0] b = 32'd15;
reg [2:0] cmp_op = CMP_OP_BEGIN;
wire taken;

branch_unit branch_unit_inst(.i_a(a), .i_b(b), .cmp_op(cmp_op), .taken(taken));

always begin
    #1
    $display("[%t] a = %d, b = %d, op = %b, taken = %d", $realtime, $signed(a), $signed(b), cmp_op, taken);
    cmp_op = cmp_op + 1;

    if (cmp_op == CMP_OP_END) begin
        $display("[%t] Done", $realtime);
        $finish;
    end
end

initial begin
    $dumpvars;
    $display("[%t] Start", $realtime);
end

endmodule