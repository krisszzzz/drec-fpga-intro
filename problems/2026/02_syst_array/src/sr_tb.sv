`timescale 1ns / 1ps

module tb_sr;

localparam int WIDTH  = 16;
localparam int LENGTH = 2;  // Тестируем LENGTH = 1

logic clk = 0;
logic i_vld;
logic [WIDTH-1:0] in_data;
logic o_vld;
logic [WIDTH-1:0] out_data;
logic tst_vld;

// DUT
sr #(
    .WIDTH(WIDTH),
    .LENGTH(LENGTH)
) dut (
    .clk(clk),
    .i_vld(i_vld),
    .in_data(in_data),
    .o_vld(o_vld),
    .out_data(out_data),
    .tst_vld(tst_vld)
);

// Clock generation
always #1 clk = ~clk;

// Test stimulus
initial begin
    // Initialize
    clk = 0;
    i_vld = 0;
    in_data = '0;

    // Wait for reset-like state
    #1;

    // Test case 1: send valid data
    i_vld = 1;
    in_data = 16'hABCD;

    #2
    // Deassert valid
    i_vld = 0;
    in_data = '0;
    #2;

    // Test case 2: send another value
    i_vld = 1;
    in_data = 16'h1234;
    #2;

    // Hold
    i_vld = 0;
    #2;

    // Finish simulation
    $display("Simulation finished.");
    $finish;
end

// Optional: waveform dumping (for tools like Verilator + GTKWave)
initial begin
    $dumpfile("tb_sr.vcd");
    $dumpvars(0, tb_sr);
end

endmodule