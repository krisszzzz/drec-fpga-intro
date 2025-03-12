`timescale 1ns/1ps

module testbench;

reg clk = 1'b0;

always begin
    #1 clk <= ~clk;
end

initial begin
    #1 in_bit = 1'b1;
    repeat (8) @(posedge clk);
    #1 w_en = 1'b1;
    #1 w_data = 8'b01010101;
end

reg in_bit = 1'b0;
reg [7:0] w_data = 8'd0;
reg w_en = 1'b0;
wire out_bit;

shiftreg shiftreg( .clk(clk), .in_bit(in_bit), .w_data(w_data), .w_en(w_en), .out_bit(out_bit));

initial begin
    $dumpvars;      /* Open for dump of signals */
    $display("Test started...");   /* Write to console */
    #50 $finish;    /* Stop simulation after 50ns */
end

endmodule