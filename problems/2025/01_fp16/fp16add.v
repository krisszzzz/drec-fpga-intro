
module fp16add(
    input wire [15:0] i_a,
    input wire [15:0] i_b,
    output wire [15:0] o_res
);

///
/// Subtract exponent
///

wire sign_a = i_a[15];
wire [4:0] exp_a = i_a[14:10];

wire sign_b = i_b[15];
wire [4:0] exp_b = i_b[14:10];

wire[4:0] exp_diff = exp_a - exp_b;

///
/// Move right number with smaller mantissa
///
reg [11:0] mant_a;
reg [11:0] mant_b;

always @(*) begin
    mant_a = { 1'b1, i_a[9:0], 1'b0 };
    mant_b = { 1'b1, i_b[9:0], 1'b0 };
    // exp_a < exp_b
    if (exp_diff[4]) begin
        mant_a = mant_a >> -exp_diff;
    end else begin
        mant_b = mant_b >> exp_diff;
    end
end

///
/// Sign adder
///
wire do_sub = sign_a ^ sign_b;

// +1 bit for case when mant_a < mant_b, exp_a == exp_b
reg [13:0] sum_mant;
reg res_sign;

always @(*) begin
    if (do_sub) begin
        sum_mant = {2'b00, mant_a} - {2'b00, mant_b};
        res_sign = sum_mant[13] ? sign_b : sign_a;
    end
    else begin
        sum_mant = {2'b00, mant_a} + {2'b00, mant_b};
        res_sign = sign_a;
    end
end

// get rid of sign bit
wire [12:0] abs_sum_mant = sum_mant[13] ? -sum_mant : sum_mant;


///
/// Leading one detector
///

reg [4:0] leading_one;

// calculate the exponent at which summation was performed
wire [4:0] sum_exp = exp_diff[4] ? exp_b : exp_a;

always @(*) begin
    casez (abs_sum_mant)
        13'b1????????????:
            leading_one = 5'd0;
        13'b01???????????:
            leading_one = 5'd1;
        13'b001??????????:
            leading_one = 5'd2;
        13'b0001?????????:
            leading_one = 5'd3;
        13'b00001????????:
            leading_one = 5'd4;
        13'b000001???????:
            leading_one = 5'd5;
        13'b0000001??????:
            leading_one = 5'd6;
        13'b00000001?????:
            leading_one = 5'd7;
        13'b000000001????:
            leading_one = 5'd8;
        13'b0000000001???:
            leading_one = 5'd9;
        13'b00000000001??:
            leading_one = 5'd10;
        13'b000000000001?:
            leading_one = 5'd11;
        13'b0000000000001:
            leading_one = 5'd12;
        default:
            leading_one = sum_exp;
    endcase
    // update result exponent
end

///
/// Normalize
///

wire [12:0] shifted_mant = abs_sum_mant << leading_one;
reg [12:0] normalized_mant;
reg [4:0] res_exp;

always @(*) begin
    res_exp = sum_exp - leading_one;
    // update exponent
    if (shifted_mant[12]) begin
        normalized_mant = shifted_mant >> 1;
        res_exp = res_exp + 1;
    end else begin
        normalized_mant = shifted_mant;
    end
end

assign o_res = res_exp != 0 ? {res_sign, res_exp, normalized_mant[10:1]} : {16'h0};

endmodule