`timescale 1ns/1ps

module sign_ext_tb;

localparam N = 12;
localparam M = 32;

reg [N - 1:0] x = {N{1'b0}};
wire [M - 1:0] y;

always begin
    #1 $display("[%t] x = %b, y = %b", $realtime, x, y);
    x = x + 1;

    if (x == {N{1'b1}}) begin
        $display("[%t] Done", $realtime);
        $finish;
    end
end

// sign_ext #(.FROM_WIDTH(N), .TO_WIDTH(M)) sign_ext_inst(.in(x), .out(y));
sign_ext_gen #(.FROM_WIDTH(N), .TO_WIDTH(M)) sign_ext_inst(.in(x), .out(y));

initial begin
    $dumpvars;
    $display("[%t] Start", $realtime);
end

endmodule