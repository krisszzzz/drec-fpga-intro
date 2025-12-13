
module credit_cnt #(
    parameter WIDTH = 2,
    parameter MAX_CREDITS = 4
)(
    input  logic clk,

    input  logic rst_n,
    input  logic i_fifo_inc_sgnl,
    input  logic i_vld,
    output logic o_vld,

    output logic o_ready
);

// suppress warnings
logic [WIDTH-1:0] credit_cnt = MAX_CREDITS[WIDTH - 1:0];
logic can_send;

assign can_send = (credit_cnt > 0);
assign o_ready = can_send;

// do not send data if no credit left
assign o_vld = i_vld && can_send;

// should decrement/increment
logic decr;
logic incr;

assign decr = i_vld && can_send;
assign incr = i_fifo_inc_sgnl;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        credit_cnt <= MAX_CREDITS[WIDTH - 1:0];
    end else begin
        if (decr && incr) begin
            // do nothing
        end else if (decr) begin
            credit_cnt <= credit_cnt - 1;
        end else if (incr) begin
            credit_cnt <= credit_cnt + 1;
        end
    end
end

endmodule