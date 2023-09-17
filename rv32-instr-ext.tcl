defn rv32-instr-ext.tcl 2023-06-13
#================ rv32-instr.tcl ======================
# 
#  2023-06-13  pds   initial cut


incl rv32-instr.tcl  ;# the rv32 instruction set, to which these extensions belongs

# should split into separate files like this
# rv32-instr-csr.tcl
# rv32-instr-i.tcl
# rv32-instr-a.tcl
# rv32-instr-m.tcl
# rv32-instr-f.tcl
# rv32-instr-f.tcl

#------------------------------------------------------
#
# CSR OPERATIONS -- I-EXTENSION
#
#    SSSSSSSSSSSS rrrrr fff rrrrr ooooooo  ;# o=opcode, f=func, r=reg, S=short-imm, L=long-imm
#    |----------| |---| |-| |---| |-----|
#  0b001100000001 00000 010 01000 1110011  ;# csrrs 0x0, 0x301, 0x8
#  0b000000000001 00000 000 00000 1110011  ;# ebreak

namespace eval RV32::INSTR::CSR {
  proc rv32_instr_csrrc  {rd csr rs1}   { return [::RV32::INSTR::rv32_instr_i_type $csr $rs1   0b011 $rd 0b1110011] }
  proc rv32_instr_csrrci {rd csr zimm5} { return [::RV32::INSTR::rv32_instr_i_type $csr $zimm5 0b111 $rd 0b1110011] }
  proc rv32_instr_csrrs  {rd csr rs1}   { return [::RV32::INSTR::rv32_instr_i_type $csr $rs1   0b010 $rd 0b1110011] }
  proc rv32_instr_csrrsi {rd csr zimm5} { return [::RV32::INSTR::rv32_instr_i_type $csr $zimm5 0b110 $rd 0b1110011] }
  proc rv32_instr_csrrw  {rd csr rs1}   { return [::RV32::INSTR::rv32_instr_i_type $csr $rs1   0b001 $rd 0b1110011] }
  proc rv32_instr_csrrwi {rd csr zimm5} { return [::RV32::INSTR::rv32_instr_i_type $csr $zimm5 0b101 $rd 0b1110011] }

  proc rv32_instr_ebreak {} { return [::RV32::INSTR::rv32_instr_i_type 0b000000000001 0b00000 0b000 0b00000 0b1110011] }
  proc rv32_instr_ecall  {} { return [::RV32::INSTR::rv32_instr_i_type 0b000000000000 0b00000 0b000 0b00000 0b1110011] }

  proc rv32_instr_fence       {} { return 0 }
  proc rv32_instr_fence_i     {} { return 0 }
  proc rv32_instr_sfence_vma  {} { return 0 }
}

#------------------------------------------------------
#
# INTEGER ARITHMETIC OPERATIONS -- I EXTENSION
#

namespace eval RV32::INSTR::I {
  proc rv32_instr_add    {} { return 0 }
  proc rv32_instr_addi   {} { return 0 }
  proc rv32_instr_sub    {} { return 0 }
  proc rv32_instr_slt    {} { return 0 }
  proc rv32_instr_slti   {} { return 0 }
  proc rv32_instr_sltiu  {} { return 0 }
  proc rv32_instr_sltu   {} { return 0 }

  #------------------------------------------------------
  #
  # INTEGER LOGICAL OPERATIONS -- I EXTENSION
  #

  proc rv32_instr_and  {} { return 0 }
  proc rv32_instr_andi {} { return 0 }
  proc rv32_instr_or   {} { return 0 }
  proc rv32_instr_ori  {} { return 0 }
  proc rv32_instr_xor  {} { return 0 }
  proc rv32_instr_xori {} { return 0 }

  #------------------------------------------------------
  #
  # LONG IMMEDIATE OPERATIONS -- I EXTENSION
  #

  proc rv32_instr_auipc {} { return 0 }
  proc rv32_instr_lui   {} { return 0 }

  #------------------------------------------------------
  #
  # CONDITIONAL JUMPS (BRANCHES) -- I EXTENSION
  #

  proc rv32_instr_beq  {} { return 0 }
  proc rv32_instr_bge  {} { return 0 }
  proc rv32_instr_bgeu {} { return 0 }
  proc rv32_instr_blt  {} { return 0 }
  proc rv32_instr_bltu {} { return 0 }
  proc rv32_instr_bne  {} { return 0 }

  #------------------------------------------------------
  # 
  # UNCONDITIONAL JUMPS -- I EXTENSION
  #

  proc rv32_instr_jal  {} { return 0 }
  proc rv32_instr_jalr {} { return 0 }

  #------------------------------------------------------
  #
  # INTEGER MEMORY LOADS AND STORE OPERATIONS -- I EXTENSION
  #

  proc rv32_instr_lb   {} { return 0 }
  proc rv32_instr_lbu  {} { return 0 }
  proc rv32_instr_lh   {} { return 0 }
  proc rv32_instr_lhu  {} { return 0 }
  proc rv32_instr_lw   {} { return 0 }
  proc rv32_instr_sb   {} { return 0 }
  proc rv32_instr_sh   {} { return 0 }
  proc rv32_instr_sw   {} { return 0 }

  #------------------------------------------------------
  #
  # BIT-WISE SHIFT OPERATIONS -- I EXTENSION
  #

  proc rv32_instr_sll   {} { return 0 }
  proc rv32_instr_slli  {} { return 0 }
  proc rv32_instr_srl   {} { return 0 }
  proc rv32_instr_srli  {} { return 0 }
  proc rv32_instr_sra   {} { return 0 }
  proc rv32_instr_srai  {} { return 0 }

  #------------------------------------------------------
  #
  # INTERRUPT HANDLING OPERATIONS -- I EXTENSION
  #

  proc rv32_instr_ret   {} { return 0 }
  proc rv32_instr_mret  {} { return 0 }
  proc rv32_instr_hret  {} { return 0 }
  proc rv32_instr_sret  {} { return 0 }
  proc rv32_instr_uret  {} { return 0 }
  proc rv32_instr_wfi   {} { return 0 }
}

#------------------------------------------------------
#
# ATOMIC OPERATIONS -- A EXTENSION
#

namespace eval RV32::INSTR::A {
  proc rv32_instr_amoadd_w   {} { return 0 }
  proc rv32_instr_amoand_w   {} { return 0 }
  proc rv32_instr_amomax_w   {} { return 0 }
  proc rv32_instr_amomaxu_w  {} { return 0 }
  proc rv32_instr_amomin_w   {} { return 0 }
  proc rv32_instr_amominu_w  {} { return 0 }
  proc rv32_instr_amoor_w    {} { return 0 }
  proc rv32_instr_amoswap_w  {} { return 0 }
  proc rv32_instr_amoxor_w   {} { return 0 }
  proc rv32_instr_lr_w  A    {} { return 0 }
  proc rv32_instr_sc_w  A    {} { return 0 }
}

#------------------------------------------------------
#
# INTEGER MATHEMATICAL OPERATIONS -- M EXTENSION
#

namespace eval RV32::INSTR::M {
  proc rv32_instr_mul     {} { return 0 }
  proc rv32_instr_mulh    {} { return 0 }
  proc rv32_instr_mulhsu  {} { return 0 }
  proc rv32_instr_mulhu   {} { return 0 }
  proc rv32_instr_div     {} { return 0 }
  proc rv32_instr_divu    {} { return 0 }
  proc rv32_instr_rem     {} { return 0 }
  proc rv32_instr_remu    {} { return 0 }
}

#------------------------------------------------------
#
# SINGLE-PRECISION FLOATING POINT OPERATIONS -- F EXTENSION
#

namespace eval RV32::INSTR::F {
  proc rv32_instr_fadd_s      {} { return 0 }
  proc rv32_instr_fclass_s    {} { return 0 }
  proc rv32_instr_fcvt_s_w    {} { return 0 }
  proc rv32_instr_fcvt_s_wu   {} { return 0 }
  proc rv32_instr_fcvt_w_s    {} { return 0 }
  proc rv32_instr_fcvt_wu_s   {} { return 0 }
  proc rv32_instr_fdiv_s      {} { return 0 }
  proc rv32_instr_feq_s       {} { return 0 }
  proc rv32_instr_fle_s       {} { return 0 }
  proc rv32_instr_flt_s       {} { return 0 }
  proc rv32_instr_flw         {} { return 0 }
  proc rv32_instr_fmadd_s     {} { return 0 }
  proc rv32_instr_fmax_s      {} { return 0 }
  proc rv32_instr_fmin_s      {} { return 0 }
  proc rv32_instr_fmsub_s     {} { return 0 }
  proc rv32_instr_fmul_s      {} { return 0 }
  proc rv32_instr_fmv_w_x     {} { return 0 }
  proc rv32_instr_fmv_x_w     {} { return 0 }
  proc rv32_instr_fnmadd_s    {} { return 0 }
  proc rv32_instr_fnmsub_s    {} { return 0 }
  proc rv32_instr_fsgnj_s     {} { return 0 }
  proc rv32_instr_fsgnjn_s    {} { return 0 }
  proc rv32_instr_fsgnjx_s    {} { return 0 }
  proc rv32_instr_fsqrt_s     {} { return 0 }
  proc rv32_instr_fsub_s      {} { return 0 }
  proc rv32_instr_fsw         {} { return 0 }
}

#------------------------------------------------------
#
# DOUBLE-PRECISION FLOATING POINT OPERATIONS -- D EXTENSION
#

namespace eval RV32::INSTR::D {
  # same as F above, with .d (_d) suffix
}
