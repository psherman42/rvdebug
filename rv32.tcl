defn rv32.tcl 2023-06-16
#================== rv32-regs.tcl =====================
# 
#  2023-06-16  pds   initial cut


#incl isa.tcl  ;# the isa, to which this isa belongs ... top level, for now :(

namespace eval RV32 {}  ;# the RV32 isa

namespace eval RV32::REGS {}   ;# register set (aka, programmers model) of this isa

namespace eval RV32::INSTR {}  ;# instruction set of this isa
