`include "decoder.vh"

module decoder(
    input wire [31:0] i_instr,
    output reg        o_legal,
    output reg [1:0]  o_alusel1,
    output reg [1:0]  o_alusel2,
    output reg [3:0]  o_alu_op,
    output reg [2:0]  o_cmp_op,
    output reg        o_branch,
    output reg        o_jump,
    output reg [1:0]  o_wb_sel,
    output reg        o_rf_we,
    output reg [3:0]  o_mask,
    output reg        o_lsu_we
);

wire[6:0] opcode = i_instr[6:0];
wire [2:0] funct3 = i_instr[14:12];
wire [6:0] funct7 = i_instr[31:25];
wire[11:0] iimm = i_instr[31:20];

always @(*) begin
    // avoid latches, so set default values
    o_legal = 1'b1;
    o_branch = 1'b0;
    o_jump = 1'b0;
    o_rf_we = 1'b0;
    o_lsu_we = 1'b0;
    o_wb_sel = 2'b00;
    o_alu_op = `ALU_OP_INV;
    o_cmp_op = `CBU_OP_INV;
    o_alusel1 = 2'b00;
    o_alusel2 = 2'b00;
    o_mask = 4'b0000;
    //

    case (opcode)
        //===============
        // ALU operations
        `ALU_R_TYPE_OPCODE: begin
            o_alusel1 = `ALU_SEL1_SRC1;
            o_alusel2 = `ALU_SEL2_SRC2;
            o_wb_sel = `WB_SEL_ALU;
            o_rf_we = 1'b1;

            case ({funct3, funct7})
                {`ADD_FUNCT3,  `ADD_FUNCT7 }: o_alu_op = `ALU_OP_ADD;
                {`SUB_FUNCT3,  `SUB_FUNCT7 }: o_alu_op = `ALU_OP_SUB;
                {`XOR_FUNCT3,  `XOR_FUNCT7 }: o_alu_op = `ALU_OP_XOR;
                {`OR_FUNCT3,   `OR_FUNCT7  }: o_alu_op = `ALU_OP_OR;
                {`AND_FUNCT3,  `AND_FUNCT7 }: o_alu_op = `ALU_OP_AND;
                {`SLL_FUNCT3,  `SLL_FUNCT7 }: o_alu_op = `ALU_OP_SLL;
                {`SRL_FUNCT3,  `SRL_FUNCT7 }: o_alu_op = `ALU_OP_SRL;
                {`SRA_FUNCT3,  `SRA_FUNCT7 }: o_alu_op = `ALU_OP_SRA;
                {`SLT_FUNCT3,  `SLT_FUNCT7 }: o_alu_op = `ALU_OP_SLT;
                {`SLTU_FUNCT3, `SLTU_FUNCT7}: o_alu_op = `ALU_OP_SLTU;
                default: begin
                    o_legal = 1'b0;
                    o_alu_op = `ALU_OP_INV;
                end
            endcase
        end
        `ALU_I_TYPE_OPCODE: begin
            o_alusel1 = `ALU_SEL1_SRC1;
            o_alusel2 = `ALU_SEL2_IIMM;
            o_wb_sel = `WB_SEL_ALU;
            o_rf_we = 1'b1;

            casez ({funct3, iimm[11:5]})
                {`ADDI_FUNCT3,  `ADDI_IMM11_5 }: o_alu_op = `ALU_OP_ADD;
                {`XORI_FUNCT3,  `XORI_IMM11_5 }: o_alu_op = `ALU_OP_XOR;
                {`ORI_FUNCT3,   `ORI_IMM11_5  }: o_alu_op = `ALU_OP_OR;
                {`ANDI_FUNCT3,  `ANDI_IMM11_5 }: o_alu_op = `ALU_OP_AND;
                {`SLLI_FUNCT3,  `SLLI_IMM11_5 }: o_alu_op = `ALU_OP_SLL;
                {`SRLI_FUNCT3,  `SRLI_IMM11_5 }: o_alu_op = `ALU_OP_SRL;
                {`SRAI_FUNCT3,  `SRAI_IMM11_5 }: o_alu_op = `ALU_OP_SRA;
                {`SLTI_FUNCT3,  `SLTI_IMM11_5 }: o_alu_op = `ALU_OP_SLT;
                {`SLTIU_FUNCT3, `SLTIU_IMM11_5}: o_alu_op = `ALU_OP_SLTU;
                default: begin
                    o_legal = 1'b0;
                    o_alu_op = `ALU_OP_INV;
                end
            endcase
        end

        `ALU_U_TYPE_OPCODE: begin
            // auipc
            o_alusel1 = `ALU_SEL1_UIMM;
            o_alusel2 = `ALU_SEL2_PC;
            o_alu_op = `ALU_OP_ADD;
            o_wb_sel = `WB_SEL_UIMM;
            o_rf_we = 1'b1;
        end

        //===============
        // LSU operation
        `LSU_I_TYPE_OPCODE: begin
            o_alusel1 = `ALU_SEL1_SRC1;
            o_alusel2 = `ALU_SEL2_IIMM;
            o_alu_op = `ALU_OP_ADD;
            o_wb_sel = `WB_SEL_LSU;
            o_rf_we = 1'b1;

            case (funct3)
                // FIXME: lh should sign-extend half word
                `LB_FUNCT3:  o_mask = 4'b0001;
                `LH_FUNCT3:  o_mask = 4'b0011;
                `LW_FUNCT3:  o_mask = 4'b1111;
                `LBU_FUNCT3: o_mask = 4'b0001;
                `LHU_FUNCT3: o_mask = 4'b0011;
                default: o_legal = 1'b0;
            endcase

        end

        `LSU_S_TYPE_OPCODE: begin
            o_alusel1 = `ALU_SEL1_SRC1;
            o_alusel2 = `ALU_SEL2_SIMM;
            o_alu_op = `ALU_OP_ADD;
            o_lsu_we = 1'b1;

            case (funct3)
                `SB_FUNCT3: o_mask = 4'b0001;
                `SH_FUNCT3: o_mask = 4'b0011;
                `SW_FUNCT3: o_mask = 4'b1111;
                default: o_legal = 1'b0;
            endcase
        end

        //===============
        // CBU operation
        `CBU_B_TYPE_OPCODE: begin
            o_alusel1 = `ALU_SEL1_BIMM;
            o_alusel2 = `ALU_SEL2_PC;
            o_alu_op = `ALU_OP_ADD;
            o_branch = 1'b1;

            case (funct3)
                `BEQ_FUNCT3:  o_cmp_op = `CBU_OP_EQ;
                `BNE_FUNCT3:  o_cmp_op = `CBU_OP_NE;
                `BLT_FUNCT3:  o_cmp_op = `CBU_OP_LT;
                `BGE_FUNCT3:  o_cmp_op = `CBU_OP_GE;
                `BLTU_FUNCT3: o_cmp_op = `CBU_OP_LTU;
                `BGEU_FUNCT3: o_cmp_op = `CBU_OP_GEU;
                default: begin
                    o_legal = 1'b0;
                    o_cmp_op = `CBU_OP_INV;
                end
            endcase
        end

        `CBU_J_TYPE_OPCODE: begin
            o_alusel1 = `ALU_SEL1_JIMM;
            o_alusel2 = `ALU_SEL2_PC;
            o_alu_op = `ALU_OP_ADD;
            o_jump = 1'b1;
            o_wb_sel = `WB_SEL_PCINC;
            o_rf_we = 1'b1;

            case (funct3)
                `JAL_FUNCT3: /* do nothing */;
                default: o_legal = 1'b0;
            endcase
        end

        `CBU_I_TYPE_OPCODE: begin
            o_alusel1 = `ALU_SEL1_SRC1;
            o_alusel2 = `ALU_SEL2_IIMM;
            o_alu_op = `ALU_OP_ADD;
            o_jump = 1'b1;
            o_wb_sel = `WB_SEL_PCINC;
            o_rf_we = 1'b1;

            case (funct3)
                `JALR_FUNCT3: /* do nothing */;
                default: o_legal = 1'b0;
            endcase
        end
        //===============

        //===============
        // LUI instruction
        `LUI_OPCODE: begin
            o_wb_sel = `WB_SEL_UIMM;
            o_rf_we = 1'b1;

        end

        //===============

        default: begin
            o_legal = 1'b0;
            o_branch = 1'b0;
            o_jump = 1'b0;
            o_rf_we = 1'b0;
            o_lsu_we = 1'b0;
            o_wb_sel = 2'b00;
            o_alu_op = `ALU_OP_INV;
            o_cmp_op = `CBU_OP_INV;
            o_alusel1 = 2'b00;
            o_alusel2 = 2'b00;
        end
    endcase
end

endmodule