///
/// primitive fp16 multiplier
///

module fp16mul(
    input wire [15:0] i_a,
    input wire [15:0] i_b,
    output wire [15:0] o_res
);


///
/// Mantissa multiplication, exponent addition, sign evaluation
///

localparam BIAS = 15;

wire sign_a = i_a[15];
wire [4:0] exp_a = i_a[14:10];
wire [9:0] mant_a = i_a[9:0];

wire sign_b = i_b[15];
wire [4:0] exp_b = i_b[14:10];
wire [9:0] mant_b = i_b[9:0];

wire sign_c = sign_a ^ sign_b;

reg [21:0] mant_axb;
reg [4:0] exp_axb;

always @(*) begin
    mant_axb = {1'b1, mant_a} * {1'b1, mant_b};
    exp_axb = exp_a + exp_b - BIAS;
end

///
/// Normalize mantissa (M should be in range [0, 1))
///

always @(*) begin
    // mantissa greater than 2, should be normalized
    if (mant_axb[21:20] >= 2'b10) begin
        exp_axb = exp_axb + 1;
        mant_axb = mant_axb >> 1;
    end
end

///
/// Rounding
///

/// round to zero

wire [4:0] exp_c = exp_axb;
wire [9:0] mant_c = exp_axb == 5'h00 ? 10'h00 : mant_axb[19:10];
reg [15:0] res;

always @(*) begin
    res = { sign_c, exp_c, mant_c };
end

assign o_res = res;

endmodule