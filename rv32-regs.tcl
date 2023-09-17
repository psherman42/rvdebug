defn rv32-regs.tcl 2023-06-13
#================== rv32-regs.tcl =====================
# 
#  2023-06-13  pds   initial cut


incl rv32.tcl  ;# the rv32 isa, to which this register set belongs

namespace eval RV32::REGS {}  ;# the RV32 register set

namespace eval RV32::REGS::CSR {}  ;# control and status registers of this set

namespace eval RV32::REGS::GPR {}  ;# general purpose registers of this set

namespace eval RV32::REGS::FPR {}  ;# floating point registers of this set

namespace eval RV32::REGS::VR {}   ;# vector registers of this set
