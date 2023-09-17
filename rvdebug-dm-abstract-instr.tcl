defn rvdebug-dmi-abstract-instr.tcl 2023-06-13
#========= rvdebug-dmi-abstract-instr.tcl =============
# 
#  2023-06-13  pds   initial cut


incl rvdebug-dmi-abstract.tcl  ;# the abstract programming facility, to which these instructions belong

incl rv32-instr-ext.tcl        ;# the concrete extensions of the RV32 ISA (CSR, I, A, M, F, D)


namespace eval DTM::DMI::DM::ABSTRACT {
  #
  # ABSTRACT COMMAND CSRRS INSTRUCTION (THRU DMI)
  #

  proc dtm_dmi_abstract_csrrs {csr regno} {
    # convert string to numeric ... DO NOT use braces of expr when strings are involved
    set csr [expr $csr]
    set regno [expr $regno]

    # define the program
    ::DTM::DMI::DM::ABSTRACT::dtm_dmi_abstractprog 0 [::RV32::INSTR::CSR::rv32_instr_csrrs $regno $csr 0] 1  ;# progbuf0: (csrrs rd, csr, x0), write
    ::DTM::DMI::DM::ABSTRACT::dtm_dmi_abstractprog 1 [::RV32::INSTR::CSR::rv32_instr_ebreak] 1               ;# progbuf1: (ebreak), write

    ::DTM::DMI::DM::ABSTRACT::dtm_dmi_abstract_prog
    ::DTM::DMI::DM::ABSTRACT::dtm_dmi_abstract_reg $regno 0  ;# mode=read, (regtypestr=GPR)
  }

  #
  # ABSTRACT COMMAND CSRRC INSTRUCTION (THRU DMI)
  #

  proc dtm_dmi_abstract_csrrc {csr regno} {
  }

  #
  # ABSTRACT COMMAND CSRRW INSTRUCTION (THRU DMI)
  #

  proc dtm_dmi_abstract_csrrw {csr regno} {
  }

  # ...
}
