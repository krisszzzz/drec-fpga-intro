//================================
// ALU operation group (will be executed on ALU)
`include "alu.vh"

`define ALU_R_TYPE_OPCODE 7'b0110011

`define ADD_OPCODE `ALU_R_TYPE_OPCODE
`define ADD_FUNCT3 3'h00
`define ADD_FUNCT7 7'h00

`define SUB_OPCODE `ALU_R_TYPE_OPCODE
`define SUB_FUNCT3 3'h00
`define SUB_FUNCT7 7'h20

`define XOR_OPCODE `ALU_R_TYPE_OPCODE
`define XOR_FUNCT3 3'h04
`define XOR_FUNCT7 7'h00

`define OR_OPCODE `ALU_R_TYPE_OPCODE
`define OR_FUNCT3 3'h06
`define OR_FUNCT7 7'h00

`define AND_OPCODE `ALU_R_TYPE_OPCODE
`define AND_FUNCT3 3'h07
`define AND_FUNCT7 7'h00

`define SLL_OPCODE `ALU_R_TYPE_OPCODE
`define SLL_FUNCT3 3'h01
`define SLL_FUNCT7 7'h00

`define SRL_OPCODE `ALU_R_TYPE_OPCODE
`define SRL_FUNCT3 3'h05
`define SRL_FUNCT7 7'h00

`define SRA_OPCODE `ALU_R_TYPE_OPCODE
`define SRA_FUNCT3 3'h05
`define SRA_FUNCT7 7'h20

`define SLT_OPCODE `ALU_R_TYPE_OPCODE
`define SLT_FUNCT3 3'h02
`define SLT_FUNCT7 7'h00

`define SLTU_OPCODE `ALU_R_TYPE_OPCODE
`define SLTU_FUNCT3 3'h03
`define SLTU_FUNCT7 7'h00


`define ALU_I_TYPE_OPCODE 7'b0010011
`define IGNORE_IMM11_5 7'b???????

`define ADDI_OPCODE `ALU_I_TYPE_OPCODE
`define ADDI_IMM11_5 `IGNORE_IMM11_5
`define ADDI_FUNCT3 3'h00

`define XORI_OPCODE `ALU_I_TYPE_OPCODE
`define XORI_IMM11_5 `IGNORE_IMM11_5
`define XORI_FUNCT3 3'h04

`define ORI_OPCODE `ALU_I_TYPE_OPCODE
`define ORI_IMM11_5 `IGNORE_IMM11_5
`define ORI_FUNCT3 3'h06

`define ANDI_OPCODE `ALU_I_TYPE_OPCODE
`define ANDI_IMM11_5 `IGNORE_IMM11_5
`define ANDI_FUNCT3 3'h07

`define SLLI_OPCODE `ALU_I_TYPE_OPCODE
`define SLLI_FUNCT3 3'h01
// requirement for imm[11:5] to be 0x00
`define SLLI_IMM11_5 7'h00

`define SRLI_OPCODE `ALU_I_TYPE_OPCODE
`define SRLI_FUNCT3 3'h05
`define SRLI_IMM11_5 7'h00

`define SRAI_OPCODE `ALU_I_TYPE_OPCODE
`define SRAI_FUNCT3 3'h05
`define SRAI_IMM11_5 7'h20

`define SLTI_OPCODE `ALU_I_TYPE_OPCODE
`define SLTI_IMM11_5 `IGNORE_IMM11_5
`define SLTI_FUNCT3 3'h02

`define SLTIU_OPCODE `ALU_I_TYPE_OPCODE
`define SLTIU_IMM11_5 `IGNORE_IMM11_5
`define SLTIU_FUNCT3 3'h03

`define ALU_U_TYPE_OPCODE 7'b0010111

// no funct3 or funct7
`define AUIPC_OPCODE `ALU_U_TYPE_OPCODE

`define ALU_SEL1_UIMM 2'b00
`define ALU_SEL1_BIMM 2'b01
`define ALU_SEL1_JIMM 2'b10
`define ALU_SEL1_SRC1 2'b11

`define ALU_SEL2_SRC2 2'b00
`define ALU_SEL2_IIMM 2'b01
`define ALU_SEL2_SIMM 2'b10
`define ALU_SEL2_PC   2'b11

//================================

//================================
// LSU operation group (will be executed on LSU)

`define LSU_I_TYPE_OPCODE 7'b0000011
`define LB_OPCODE `LSU_I_TYPE_OPCODE
`define LB_FUNCT3 3'h00
`define LH_OPCODE `LSU_I_TYPE_OPCODE
`define LH_FUNCT3 3'h01
`define LW_OPCODE `LSU_I_TYPE_OPCODE
`define LW_FUNCT3 3'h02
`define LBU_OPCODE `LSU_I_TYPE_OPCODE
`define LBU_FUNCT3 3'h04
`define LHU_OPCODE `LSU_I_TYPE_OPCODE
`define LHU_FUNCT3 3'h05

`define LSU_S_TYPE_OPCODE 7'b0100011
`define SB_OPCODE `LSU_S_TYPE_OPCODE
`define SB_FUNCT3 3'h00
`define SH_OPCODE `LSU_S_TYPE_OPCODE
`define SH_FUNCT3 3'h01
`define SW_OPCODE `LSU_S_TYPE_OPCODE
`define SW_FUNCT3 3'h02

//================================

//================================
// CBU operation group (will be executed on CBU)
`include "cbu.vh"

`define CBU_B_TYPE_OPCODE 7'b1100011
`define BEQ_OPCODE `CBU_B_TYPE_OPCODE
`define BEQ_FUNCT3 3'h00
`define BNE_OPCODE `CBU_B_TYPE_OPCODE
`define BNE_FUNCT3 3'h01
`define BLT_OPCODE `CBU_B_TYPE_OPCODE
`define BLT_FUNCT3 3'h04
`define BGE_OPCODE `CBU_B_TYPE_OPCODE
`define BGE_FUNCT3 3'h05
`define BLTU_OPCODE `CBU_B_TYPE_OPCODE
`define BLTU_FUNCT3 3'h06
`define BGEU_OPCODE `CBU_B_TYPE_OPCODE
`define BGEU_FUNCT3 3'h07

`define CBU_J_TYPE_OPCODE 7'b1101111
`define JAL_OPCODE `CBU_J_TYPE_OPCODE
`define JAL_FUNCT3 3'b00

`define CBU_I_TYPE_OPCODE 7'b1100111
`define JALR_OPCODE `CBU_I_TYPE_OPCODE
`define JALR_FUNCT3 3'b00

// LUI do not require alu, cbu or lsu
// it handled separately
`define LUI_OPCODE 7'b0110111

//================================

//================================
// Writeback selector

`define WB_SEL_UIMM  2'b00
`define WB_SEL_ALU   2'b01
`define WB_SEL_LSU   2'b10
`define WB_SEL_PCINC 2'b11
//================================

