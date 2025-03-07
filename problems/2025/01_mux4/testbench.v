`timescale 1ns/1ps

module mux4_tb;

localparam N = 8;

wire[N - 1:0] i0 = 8'd1;
wire[N - 1:0] i1 = 8'd13;
wire[N - 1:0] i2 = 8'd25;
wire[N - 1:0] i3 = 8'd33;

reg[1:0] sel;
wire[N - 1:0] out;

mux4 #(.WIDTH(N)) mux4_inst(.i0(i0), .i1(i1), .i2(i2), .i3(i3), .sel(sel), .out(out));

initial begin
    $dumpvars;

    // probably generate?
    sel = 2'b00;
    #1 $display("[%t] out = %d", $realtime, out);
    sel = 2'b01;
    #1 $display("[%t] out = %d", $realtime, out);
    sel = 2'b10;
    #1 $display("[%t] out = %d", $realtime, out);
    sel = 2'b11;
    #1 $display("[%t] out = %d", $realtime, out);

    $finish;
end

endmodule
