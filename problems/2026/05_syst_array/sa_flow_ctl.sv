module sa_flow_ctl #(parameter WIDTH = 16,
                     parameter SIZE = 4,
                     parameter FIFO_STAGES = 2 * SIZE)
(
    input logic clk,
    input logic rst_n,

    input logic i_vld,
    input logic is_b,
    input logic [SIZE - 1:0][WIDTH - 1:0] i_ab,
    input logic i_ready,

    output logic o_vld,
    output logic [SIZE - 1:0][WIDTH - 1:0] o_c,
    output logic o_ready
);

logic sa_i_we;
assign sa_i_we = is_b ? 1'b1 : 1'b0;
// from credit_cnt
logic sa_i_a_vld;

logic sa_i_c_vld;
assign sa_i_c_vld = is_b ? 1'b0 : sa_i_a_vld;

logic sa_o_c_vld;
logic [SIZE - 1:0][WIDTH - 1:0] sa_o_c_rows;

sa_top #(.WIDTH(WIDTH), .SIZE(SIZE)) sa (
    .clk(clk),
    .i_we(sa_i_we),
    .i_a_vld(sa_i_a_vld),
    .i_a_rows(i_ab),
    .i_c_vld(sa_i_c_vld),
    .o_c_vld(sa_o_c_vld),
    .o_c_rows(sa_o_c_rows)
);

logic fifo_o_full;
logic fifo_o_empty;

logic fifo_i_wr_en;
assign fifo_i_wr_en = !fifo_o_full & sa_o_c_vld;
logic fifo_i_rd_en;
assign fifo_i_rd_en = !fifo_o_empty & i_ready;
assign o_vld = !fifo_o_empty;

fifo #(.ADDRW($clog2(FIFO_STAGES + 1)), .DATAW(SIZE * WIDTH)) fifo_inst (
    .clk(clk),
    .i_rd_en(fifo_i_rd_en),
    .o_rd_data(o_c),
    .i_wr_en(fifo_i_wr_en),
    .i_wr_data(sa_o_c_rows),
    .o_full(fifo_o_full),
    .o_empty(fifo_o_empty)
);

logic fifo_inc_sgnl;
assign fifo_inc_sgnl = o_vld & i_ready;

credit_cnt #(.WIDTH($clog2(FIFO_STAGES + 1)), .MAX_CREDITS(FIFO_STAGES)) credit_cnt_inst (
    .clk(clk),
    .rst_n(rst_n),
    .i_fifo_inc_sgnl(fifo_inc_sgnl),
    .i_vld(i_vld),
    .o_vld(sa_i_a_vld),
    .o_ready(o_ready)
);

endmodule