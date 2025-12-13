
module sr #(
    parameter int WIDTH = 16,
    parameter int LENGTH = 1
) (
    input logic clk,
    input logic i_vld,
    input logic [WIDTH - 1:0] in_data,
    output logic o_vld,
    output logic [WIDTH - 1:0] out_data
);

logic [WIDTH - 1:0] reg_data[LENGTH - 1:0];
logic               reg_valid[LENGTH - 1:0];

always_ff @(posedge clk) begin
    reg_data[0] <= in_data;
    reg_valid[0] <= i_vld;

    for (int i = 1; i < LENGTH; i++) begin
        reg_data[i] <= reg_data[i - 1];
        reg_valid[i] <= reg_valid[i - 1];
    end
end

// Output is the last stage
assign out_data = reg_data[LENGTH - 1];
assign o_vld    = reg_valid[LENGTH - 1];

endmodule