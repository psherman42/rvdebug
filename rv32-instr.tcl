defn rv32-instr.tcl 2023-06-13
#============== rv32-instr-types.tcl ==================
# 
#  2023-06-13  pds   initial cut


incl rv32.tcl  ;# the rv32 isa, to which this instruction set belongs

#
# RV32 INSTRUCTIONS
#
#   The RISC-V Reader (https://www.riscbook.com/)
#   Unprivileged Specification (https://riscv.org/technical/specifications/)
#   Privileged Specification (https://riscv.org/technical/specifications/)
#

namespace eval RV32::INSTR {

  #    fffffff rrrrr rrrrr fff rrrrr ooooooo  ;# o=opcode, f=func, r=reg, S=short-imm, L=long-imm
  #    |-----| |---| |---| |-| |---| |-----|

  proc rv32_instr_r_type {func7 rs2 rs1 func3 rd op} {
    return [set x [expr { 0
     | ([expr $func7] & ((1 << 7) - 1)) << 25
     | ([expr $rs2]   & ((1 << 5) - 1)) << 20
     | ([expr $rs1]   & ((1 << 5) - 1)) << 15
     | ([expr $func3] & ((1 << 3) - 1)) << 12
     | ([expr $rd]    & ((1 << 5) - 1)) << 7
     | ([expr $op]    & ((1 << 7) - 1)) << 0
    }]]
  }

  #    SSSSSSSSSSSS rrrrr fff rrrrr ooooooo  ;# o=opcode, f=func, r=reg, S=short-imm, L=long-imm
  #    |----------| |---| |-| |---| |-----|

  proc rv32_instr_i_type {shortimm rs1 func3 rd op} {
    return [set x [expr { 0
     | ([expr $shortimm] & ((1 << 12) - 1)) << 20
     | ([expr $rs1]      & ((1 <<  5) - 1)) << 15
     | ([expr $func3]    & ((1 <<  3) - 1)) << 12
     | ([expr $rd]       & ((1 <<  5) - 1)) << 7
     | ([expr $op]       & ((1 <<  7) - 1)) << 0
    }]]
  }

  #    SSSSSSSSSSSS rrrrr rrrrr fff rrrrr ooooooo  ;# o=opcode, f=func, r=reg, S=short-imm, L=long-imm
  #    |----------| |---| |---| |-| |---| |-----|

  proc rv32_instr_s_type {shortimm rs2 rs1 func3 op} {
    return [set x [expr { 0
     | ([expr $shortimm] & ((1 << 7) - 1)) << 25
     | ([expr $rs2]      & ((1 << 5) - 1)) << 20
     | ([expr $rs1]      & ((1 << 5) - 1)) << 15
     | ([expr $func3]    & ((1 << 3) - 1)) << 12
     | ([expr $shortimm] & ((1 << 5) - 1)) << 7
     | ([expr $op]       & ((1 << 7) - 1)) << 0
    }]]
  }

  #    SSSSSSSSSSSS rrrrr rrrrr fff ooooooo  ;# o=opcode, f=func, r=reg, S=short-imm, L=long-imm
  #    |----------| |---| |---| |-| |-----|

  proc rv32_instr_b_type {shortimm rs2 rs1 func3 op} {  ;#  i12 i10-5 rs2 rs1 f3 i4-1 i11 o
    return [set x [expr { 0
     | ([expr $shortimm] & ((1 <<  1) - 1)) << 31
     | ([expr $shortimm] & ((1 <<  6) - 1)) << 25
     | ([expr $rs2]      & ((1 <<  5) - 1)) << 20
     | ([expr $rs1]      & ((1 <<  5) - 1)) << 15
     | ([expr $func3]    & ((1 <<  3) - 1)) << 12
     | ([expr $shortimm] & ((1 <<  4) - 1)) << 8
     | ([expr $shortimm] & ((1 <<  1) - 1)) << 7
     | ([expr $op]       & ((1 <<  7) - 1)) << 0
    }]]
  }

  #    LLLLLLLLLLLLLLLLLLLL ddddd ooooooo  ;# o=opcode, f=func, r=reg, S=short-imm, L=long-imm
  #    |------------------| |---| |-----|

  proc rv32_instr_u_type {longimm rd op} {
    return [set x [expr { 0
     | ([expr $longimm] & ((1 << 20) - 1)) << 12      
     | ([expr $rd]      & ((1 <<  5) - 1)) << 7
     | ([expr $op]      & ((1 <<  7) - 1)) << 0
    }]]
  }

  #    LLLLLLLLLLLLLLLLLLLL ddddd ooooooo  ;# o=opcode, f=func, r=reg, S=short-imm, L=long-imm
  #    |------------------| |---| |-----|

  proc rv32_instr_j_type {longimm rd op} {
    return [set x [expr { 0
     | ([expr $shortimm] & ((1 <<  1) - 1)) << 31
     | ([expr $shortimm] & ((1 << 10) - 1)) << 21
     | ([expr $shortimm] & ((1 <<  1) - 1)) << 20
     | ([expr $shortimm] & ((1 <<  8) - 1)) << 12
     | ([expr $rd]       & ((1 <<  5) - 1)) << 7
     | ([expr $op]       & ((1 <<  7) - 1)) << 0
    }]]
  }
}

namespace eval RV32::INSTR::CSR {}
namespace eval RV32::INSTR::I {}
namespace eval RV32::INSTR::A {}
namespace eval RV32::INSTR::M {}
namespace eval RV32::INSTR::F {}
namespace eval RV32::INSTR::D {}

