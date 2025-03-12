
`timescale 1ns/1ps

module testbench;

reg clk   = 1'b0;

always begin
    #1 clk <= ~clk;
end

wire[7:0] lfsr_out;

lfsr lfsr(.clk(clk), .gen(lfsr_out));

initial begin
    $dumpvars;      /* Open for dump of signals */
    $display("Test started...");   /* Write to console */
    #50 $finish;    /* Stop simulation after 50ns */
end

endmodule