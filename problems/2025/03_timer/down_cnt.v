

module down_cnt(
    input clk,
    input ce,
    input wire rst_n,
    output wire[9:0] o_cnt
);

reg[9:0] cnt = 10'd600;
assign o_cnt = cnt;

always @(posedge clk or negedge rst_n) begin
    if ( !rst_n ) begin
        cnt <= 10'd600;
    end
    else if ( ce ) begin
        cnt <= ( cnt == 0 ) ? 10'd600 : cnt - 1;
    end
end

endmodule