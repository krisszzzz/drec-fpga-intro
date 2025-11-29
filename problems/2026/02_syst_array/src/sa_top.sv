
module sa_top #(parameter WIDTH = 16, parameter SIZE = 4)(
    input logic clk,

    input logic i_we,
    input logic i_a_vld,

    // pass 1 row of A or B
    input logic [SIZE - 1:0][WIDTH - 1:0] i_a_rows,

    input  logic i_c_vld,
    output logic o_c_vld,

    // get 1 row of C
    output logic [SIZE - 1:0][WIDTH - 1:0] o_c_rows
);

logic [SIZE - 1:0][WIDTH - 1:0] i_a_rows_top2core;
logic [SIZE - 1:0]              i_a_vld_top2core;
logic [SIZE - 1:0]              i_c_vld_top2core;

generate
for (genvar i = 0; i < SIZE; i++) begin : sr_gen_inputs
    if (i == 0) begin
        // no sr
        assign i_a_rows_top2core[i] = i_a_rows[i];
        assign i_a_vld_top2core[i]  = i_a_vld;
        assign i_c_vld_top2core[i]  = i_c_vld;
   end else begin
        sr #(.WIDTH(WIDTH), .LENGTH(i)) sr_a_inst (
            .clk     (clk),
            .i_vld   (i_a_vld),
            .in_data (i_a_rows[i]),
            .o_vld   (i_a_vld_top2core[i]),
            .out_data(i_a_rows_top2core[i])
        );

        // delay i_c_vld
        // can be modified to pass C matrix for GEMM-like operation:
        // C = A @ B + C
        sr #(.WIDTH(1), .LENGTH(i)) sr_c_vld_inst (
            .clk     (clk),
            .i_vld   (i_c_vld),
            .in_data (), // ignored
            .o_vld   (i_c_vld_top2core[i]),
            .out_data() // ignored
        );
    end
end
endgenerate

logic [SIZE - 1:0]              o_c_vld_core2top;
logic [SIZE - 1:0][WIDTH - 1:0] o_c_rows_core2top;

// generate sr to the output from the "bottom"-side of SA
sa_core #(.WIDTH(WIDTH), .SIZE(SIZE)) sa_core_inst(
    .clk(clk),
    .i_we(i_we),
    .i_a_vld(i_a_vld_top2core),
    .i_a_rows(i_a_rows_top2core),
    .i_c_vld(i_c_vld_top2core),
    .o_c_vld(o_c_vld_core2top),
    .o_c_rows(o_c_rows_core2top)
);

logic [SIZE - 1:0] o_c_vld_sr2top;

generate
for (genvar i = 0; i < SIZE; i++) begin : sr_gen_outputs
    if (i == SIZE - 1) begin
        // no sr
        assign o_c_vld_sr2top[i] = o_c_vld_core2top[i];
        assign o_c_rows[i] = o_c_rows_core2top[i];
    end else begin
        sr #(.WIDTH(WIDTH), .LENGTH(SIZE - 1 - i)) sr_inst (
            .clk     (clk),
            .i_vld   (o_c_vld_core2top[i]),
            .in_data (o_c_rows_core2top[i]),
            .o_vld   (o_c_vld_sr2top[i]),
            .out_data(o_c_rows[i])
        );
    end
end
endgenerate

assign o_c_vld = &o_c_vld_sr2top;

endmodule
