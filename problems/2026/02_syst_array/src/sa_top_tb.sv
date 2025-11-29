`timescale 1ns / 1ps

module sa_top_tb;

localparam WIDTH = 16;
localparam SIZE  = 3;

logic clk = 1'b0;
logic i_we;
logic i_a_vld;
logic i_c_vld;
logic o_c_vld;

logic [SIZE-1:0][WIDTH-1:0] i_a_rows;
logic [SIZE-1:0][WIDTH-1:0] o_c_rows;

sa_top #(.WIDTH(WIDTH), .SIZE(SIZE)) dut (
  .clk       (clk),
  .i_we      (i_we),
  .i_a_vld   (i_a_vld),
  .i_a_rows  (i_a_rows),
  .i_c_vld   (i_c_vld),
  .o_c_vld   (o_c_vld),
  .o_c_rows  (o_c_rows)
);

import "DPI-C" function void set_sa_size(int size);
import "DPI-C" function void set_A_element(shortint elem, int offset);
import "DPI-C" function void set_B_element(shortint elem, int offset);
import "DPI-C" function void set_C_element(shortint elem, int offset);
import "DPI-C" function bit verify();

always begin
    #1 clk <= ~clk;
end

function shortint logic_to_shortint(logic [WIDTH - 1:0] val);
  return $signed(val);
endfunction

initial begin
  $dumpfile("dump.vcd");
  $dumpvars;
  // Initialize all inputs
  i_we      = 0;
  i_a_vld   = 0;
  i_c_vld   = 0;

  // Set matrix size in C++ model
  set_sa_size(SIZE);

  // Generate test matrices A and B
  // For simplicity, use small integers (e.g., A[i][j] = i*SIZE + j + 1, B[i][j] = 1)
  for (int i = 0; i < SIZE; i++) begin
    for (int j = 0; j < SIZE; j++) begin
      int idx = i * SIZE + j;
      shortint a_val = idx + 1; // e.g. A = [[1,2,3,4], [5,6,7,8], ...]
      shortint b_val = idx + 1; // e.g. B = [[1,2,3,4], [5,6,7,8], ...]
      set_A_element(a_val, idx);
      set_B_element(b_val, idx);
    end
  end

  @(posedge clk);

  // Load B matrix. NOTE: in reverse order across i index
  for (int i = SIZE - 1; i >= 0; i--) begin
    i_a_vld = 1;
    for (int j = 0; j < SIZE; j++) begin
        i_a_rows[j] = i * SIZE + j + 1;
    end
    // at the end set we
    if (i == 0) begin
      i_we = 1;
    end
    @(posedge clk);
  end

  i_we = 0;

  // Pass A matrix
  for (int i = 0; i < SIZE; i++) begin
    i_a_vld = 1;
    i_c_vld = 1;
    for (int j = 0; j < SIZE; j++) begin
      i_a_rows[j] = i * SIZE + j + 1;
    end
    @(posedge clk);
  end

  i_a_vld = 0;
  i_c_vld = 0;

  // Wait for result
  repeat (SIZE - 1) @(posedge clk);

  // Write result
  for (int i = 0; i < SIZE; i++) begin
   for (int j = 0; j < SIZE; j++) begin
      shortint c_val = logic_to_shortint(o_c_rows[j]);
      set_C_element(c_val, i * SIZE + j);
    end
    @(posedge clk);
  end

  // Call C++ verification
  if (verify()) begin
    $display("Verification PASSED");
  end else begin
    $display("Verification FAILED");
  end

  // End simulation
  #20 $finish;
end

endmodule