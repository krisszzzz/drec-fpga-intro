module sa_core #(parameter WIDTH=16, parameter SIZE=4)(
    input logic clk,

    input logic i_we,
    input logic [SIZE - 1:0] i_a_vld,

    // pass 1 row of A or B
    input logic [SIZE - 1:0][WIDTH - 1:0] i_a_rows,

    input  logic [SIZE - 1:0] i_c_vld,
    output logic [SIZE - 1:0] o_c_vld,
    // get 1 row of C
    output logic [SIZE - 1:0][WIDTH - 1:0] o_c_rows
);

// +1 for input of left-most column and top-most row
logic               we[SIZE:0][SIZE:0];
logic               a_vld[SIZE:0][SIZE:0];
logic [WIDTH - 1:0] a[SIZE:0][SIZE:0];
logic [WIDTH - 1:0] c[SIZE:0][SIZE:0];
logic               c_vld[SIZE:0][SIZE:0];
generate

genvar i, j;

// Top boundary (i = 0) filled with zero
for (j = 0; j < SIZE; j++) begin : top_input
    assign c[0][j] = 0;
    assign c_vld[0][j] = i_c_vld[j];
    assign we[0][j]    = i_we;    // row-broadcast we
end

// Bottom boundary outputs (i = size-1, j = 0..size-1)
for (j = 0; j < SIZE; j++) begin : bottom_output
    assign o_c_rows[j] = c[SIZE][j];
    assign o_c_vld[j] = c_vld[SIZE][j];
end

// Left boundary (j = 0)
for (i = 0; i < SIZE; i++) begin : left_input
    assign a[i][0]     = i_a_rows[i];
    assign a_vld[i][0] = i_a_vld[i];
end

// NOTE: Right boundary output ignored

// Instantiate PE array
for (i = 0; i < SIZE; i++) begin : pe_array_outer
    for (j = 0; j < SIZE; j++) begin : pe_array_inner
        pe #(.WIDTH(WIDTH)) pe_inst (
            .clk      (clk),
            .i_we     (we[i][j]),
            .i_a_vld  (a_vld[i][j]),
            .i_a      (a[i][j]),
            .i_c_vld  (c_vld[i][j]),
            .i_c      (c[i][j]),
            .o_we     (we[i+1][j]),
            .o_a_vld  (a_vld[i][j+1]),
            .o_a      (a[i][j+1]),
            .o_c_vld  (c_vld[i+1][j]),
            .o_c      (c[i+1][j])
        );
    end
end

endgenerate
endmodule