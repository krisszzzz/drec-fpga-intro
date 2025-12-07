module pe#(parameter WIDTH=16)(
    input logic clk,
    input logic i_we,
    input logic i_a_vld,
    input logic [WIDTH - 1:0] i_a,
    input logic i_c_vld,
    input logic [WIDTH - 1:0] i_c,
    output logic o_we,
    output logic o_a_vld,
    output logic [WIDTH - 1:0] o_a,
    output logic o_c_vld,
    output logic [WIDTH - 1:0] o_c
);

logic[WIDTH - 1:0] b = 0;

always_ff @(posedge clk) begin
    if (i_we) begin
        b <= i_a;
    end
end

always_ff @(posedge clk) begin
    o_a <= i_a;
    o_c <= i_a * b + i_c;
end

always_ff @(posedge clk) begin
    o_a_vld <= i_a_vld;
    o_c_vld <= (i_a_vld & i_c_vld);
    o_we <= i_we;
end

endmodule