`timescale 1ns/1ps

module testbench;

reg clk   = 1'b0;

always begin
    #1 clk <= ~clk;
end

reg [4:0] rd_addr_1port = 5'b00000;
reg [4:0] rd_addr_2port = 5'b00000;

wire [31:0] rd_data_1port = 32'd0;
wire [31:0] rd_data_2port = 32'd0;

reg  [4:0] wr_addr = 5'b00000;
reg [31:0] wr_data = 32'd0;

reg wr_en = 1'b0;

//  initial begin
// always @(posedge clk) begin
//     wr_en <= 1'b1;
//     // wr_addr <= wr_addr + 1;
//     wr_data <= wr_data + 10;
// end

initial begin
    #1 rd_addr_1port = 5'b00001;
    #1 rd_addr_2port = 5'b00010;
    #1 wr_en = 1'b1;
    #1 wr_data = 32'd10;
    #1 wr_en = 1'b0;

    #1 rd_addr_1port = 5'b00000;
    #1 rd_addr_2port = 5'b00000;
end

rf_2r1w rf_2r1w(.clk(clk), .i_rd_addr_1port(rd_addr_1port), .i_rd_addr_2port(rd_addr_2port),
                .o_rd_data_1port(rd_data_1port), .o_rd_data_2port(rd_data_2port), .i_wr_addr(wr_addr),
                .i_wr_data(wr_data), .i_wr_en(wr_en));

initial begin
    $dumpvars;      /* Open for dump of signals */
    $display("Test started...");   /* Write to console */
    #1000 $finish;    /* Stop simulation after 50ns */
end

endmodule