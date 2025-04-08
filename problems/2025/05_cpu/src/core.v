
module core(
    input wire         clk,
    input wire         rst_n,
    input wire  [31:0] i_instr_data,
    output wire [29:0] o_instr_addr,
    output wire [29:0] o_mem_addr,
    output wire [31:0] o_mem_data,
    output wire        o_mem_we,
    output wire [3:0]  o_mem_mask,
    input wire  [31:0] i_mem_data
);

// TODO: watch legal wire
wire legal;

wire [1:0] alusel1;
wire [1:0] alusel2;
wire [3:0] alu_op;
wire [2:0] cmp_op;
wire branch;
wire jump;
wire [1:0] wb_sel;
wire rf_we;
wire lsu_we;

reg [29:0]  pc = 30'h00;
wire [29:0] pc_inc = pc + 29'd1;

/*
   31  30  29  28  27  26  25  24  23  22  21  20  19  18  17  16  15  14  13  12  11   10  9  8  7  6  5  4  3  2  1  0
I: |                 imm[11:0]                 |                               ...                                     |
S: |       imm[11:5]       |                        ...                             |  imm[4:0]   |                    |
B: |      imm[12|10:5]     |                        ...                             | imm[4:1|11] |                    |
U: |                            imm[31:12]                                     |                  ...                  |
J: |                        imm[20|10:1|11|19:12]                              |                  ...                  |
 */

// sign extended immidiate
wire [31:0] uimm = { i_instr_data[31:12], { 12{ 1'b0 } } };
wire [31:0] bimm = { { 19 { i_instr_data[31] } }, i_instr_data[31], i_instr_data[7],
                     i_instr_data[30:25], i_instr_data[11:8], 1'b0 };
wire [31:0] jimm = { { 11 { i_instr_data[31] } }, i_instr_data[31], i_instr_data[19:12],
                     i_instr_data[20], i_instr_data[30:21], 1'b0 };


wire [31:0] iimm = { { 20{ i_instr_data[31] } }, i_instr_data[31:20] };
wire [31:0] simm = { { 20{ i_instr_data[31] } }, i_instr_data[31:25], i_instr_data[11:7] };

wire [4:0] rs1 = i_instr_data[19:15];
wire [4:0] rs2 = i_instr_data[24:20];
wire [4:0] rd  = i_instr_data[11:7];

wire [31:0] rf_src1;
wire [31:0] rf_src2;
wire [31:0] alu_src1;
wire [31:0] alu_src2;
wire [31:0] alu_res;
wire [31:0] wb_res;
wire [31:0] lsu_res;

wire branch_taken;
wire taken;

decoder decoder(.i_instr(i_instr_data),
                .o_legal(legal),
                .o_alusel1(alusel1),
                .o_alusel2(alusel2),
                .o_alu_op(alu_op),
                .o_cmp_op(cmp_op),
                .o_branch(branch),
                .o_jump(jump),
                .o_wb_sel(wb_sel),
                .o_rf_we(rf_we),
                .o_lsu_we(lsu_we));

rf_2r1w rf(.clk(clk),
           .i_rd_addr_1port(rs1),
           .i_rd_addr_2port(rs2),
           .o_rd_data_1port(rf_src1),
           .o_rd_data_2port(rf_src2),
           .i_wr_addr(rd),
           .i_wr_data(wb_res),
           .i_wr_en(rf_we));

mux4 alu_src1_mux4(.i0(uimm),
                   .i1(bimm),
                   .i2(jimm),
                   .i3(rf_src1),
                   .sel(alusel1),
                   .out(alu_src1));

mux4 alu_src2_mux4(.i0(rf_src2),
                   .i1(iimm),
                   .i2(simm),
                   .i3({ pc, 2'b00 }),
                   .sel(alusel2),
                   .out(alu_src2));

alu alu(.i_a(alu_src1),
        .i_b(alu_src2),
        .i_op(alu_op),
        .o_res(alu_res));

cbu cbu(.i_a(rf_src1),
        .i_b(rf_src2),
        .i_cmp_op(cmp_op),
        .o_taken(branch_taken));

mux4 wb_mux4(.i0(uimm),
             .i1(alu_res),
             .i2(i_mem_data),
             .i3({ pc_inc, 2'b00 }),
             .sel(wb_sel),
             .out(wb_res));

assign o_instr_addr = pc;
assign o_mem_addr = alu_res >> 2;
assign o_mem_data = rf_src2;
assign o_mem_we = lsu_we;
assign o_mem_mask = 4'b1111;

// either it's conditional branch and it's taken or it's uncoditional jump
assign taken = ( branch_taken & branch ) | jump;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pc <= 30'h00;
    end
    else begin
        pc <= (taken) ? alu_res >> 2 : pc_inc;
    end
end

endmodule