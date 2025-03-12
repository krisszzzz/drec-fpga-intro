`timescale 1ns/1ps

module testbench;

reg clk = 1'b0;

always begin
    #1 clk <= ~clk;
end

localparam DATAW = 8;
localparam ADDRW = 3;

reg rd_en = 1'b0;
wire[DATAW - 1:0] rd_data;

reg wr_en = 1'b1;
reg[DATAW - 1:0] wr_data = 8'd15;

wire full;
wire empty;


fifo #(.ADDRW(ADDRW), .DATAW(DATAW)) fifo(.clk(clk), .i_rd_en(rd_en), .o_rd_data(rd_data), .i_wr_en(wr_en),
                                          .i_wr_data(wr_data), .o_full(full), .o_empty(empty));

initial begin
    // write till depth of fifo
    repeat (2**ADDRW) @(posedge clk) begin
        wr_data <= wr_data + 8'd1;
    end

    #1 // wait for result

    // expect fifo to be full
    if ( full != 1'b1 ) begin
        $display( "Error: at 16 clk expected FIFO to be full!");
    end

    repeat (1) @(posedge clk) begin
        wr_en <= 1'b0;
        rd_en <= 1'b1;
        wr_data <= 8'd15;
    end

    repeat (2**ADDRW) @(posedge clk) begin
        wr_data <= wr_data + 8'd1;
        #1 // wait for result
        if ( rd_data != wr_data ) begin
            $display( "Error: read %d, but expected %d", rd_data, wr_data);
        end
    end

    repeat (1) @(posedge clk) begin
        wr_en <= 1'b0;
        rd_en <= 1'b0;
    end



end

initial begin
    $dumpvars;      /* Open for dump of signals */
    $display("Test started...");   /* Write to console */
    #200 $finish;    /* Stop simulation after 50ns */
end

endmodule