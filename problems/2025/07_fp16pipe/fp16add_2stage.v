
module fp16add_2stage(
    input wire clk,
    input wire [15:0] i_a,
    input wire [15:0] i_b,
    output wire [15:0] o_res
);

///
/// F0 stage
///

///
/// Subtract exponent
///

wire f0_sign_a = i_a[15];
wire [4:0] f0_exp_a = i_a[14:10];

wire f0_sign_b = i_b[15];
wire [4:0] f0_exp_b = i_b[14:10];

wire[4:0] f0_exp_diff = f0_exp_a - f0_exp_b;

///
/// Move right number with smaller mantissa
///
reg [11:0] f0_mant_a;
reg [11:0] f0_mant_b;

always @(*) begin
    f0_mant_a = { 1'b1, i_a[9:0], 1'b0 };
    f0_mant_b = { 1'b1, i_b[9:0], 1'b0 };
    // exp_a < exp_b
    if (f0_exp_diff[4]) begin
        f0_mant_a = f0_mant_a >> -f0_exp_diff;
    end else begin
        f0_mant_b = f0_mant_b >> f0_exp_diff;
    end
end

///
/// Sign adder
///
wire f0_do_sub = f0_sign_a ^ f0_sign_b;

// +1 bit for case when mant_a < mant_b, exp_a == exp_b
reg [13:0] f0_sum_mant;
reg f0_res_sign;

always @(*) begin
    if (f0_do_sub) begin
        f0_sum_mant = {2'b00, f0_mant_a} - {2'b00, f0_mant_b};
        f0_res_sign = f0_sum_mant[13] ? f0_sign_b : f0_sign_a;
    end
    else begin
        f0_sum_mant = {2'b00, f0_mant_a} + {2'b00, f0_mant_b};
        f0_res_sign = f0_sign_a;
    end
end

reg [13:0] f1_sum_mant;
reg [4:0] f1_exp_a;
reg [4:0] f1_exp_b;
reg [4:0] f1_exp_diff;
reg f1_res_sign;

always @(posedge clk) begin
    f1_res_sign <= f0_res_sign;
    f1_exp_a <= f0_exp_a;
    f1_exp_b <= f0_exp_b;
    f1_exp_diff <= f0_exp_diff;
    f1_sum_mant <= f0_sum_mant;
end

///
/// F1 stage
///

// get rid of sign bit
wire [12:0] f1_abs_sum_mant = f1_sum_mant[13] ? -f1_sum_mant : f1_sum_mant;


///
/// Leading one detector
///

reg [4:0] f1_leading_one;

// calculate the exponent at which summation was performed
wire [4:0] f1_sum_exp = f1_exp_diff[4] ? f1_exp_b : f1_exp_a;

always @(*) begin
    casez (f1_abs_sum_mant)
        13'b1????????????:
            f1_leading_one = 5'd0;
        13'b01???????????:
            f1_leading_one = 5'd1;
        13'b001??????????:
            f1_leading_one = 5'd2;
        13'b0001?????????:
            f1_leading_one = 5'd3;
        13'b00001????????:
            f1_leading_one = 5'd4;
        13'b000001???????:
            f1_leading_one = 5'd5;
        13'b0000001??????:
            f1_leading_one = 5'd6;
        13'b00000001?????:
            f1_leading_one = 5'd7;
        13'b000000001????:
            f1_leading_one = 5'd8;
        13'b0000000001???:
            f1_leading_one = 5'd9;
        13'b00000000001??:
            f1_leading_one = 5'd10;
        13'b000000000001?:
            f1_leading_one = 5'd11;
        13'b0000000000001:
            f1_leading_one = 5'd12;
        default:
            f1_leading_one = f1_sum_exp;
    endcase
    // update result exponent
end

///
/// Normalize
///

wire [12:0] f1_shifted_mant = f1_abs_sum_mant << f1_leading_one;
reg [12:0] f1_normalized_mant;
reg [4:0] f1_res_exp;

always @(*) begin
    f1_res_exp = f1_sum_exp - f1_leading_one;
    // update exponent
    if (f1_shifted_mant[12]) begin
        f1_normalized_mant = f1_shifted_mant >> 1;
        f1_res_exp = f1_res_exp + 1;
    end else begin
        f1_normalized_mant = f1_shifted_mant;
    end
end

assign o_res = f1_res_exp != 0 ? {f1_res_sign, f1_res_exp, f1_normalized_mant[10:1]} : {16'h0};

endmodule
