defn jedec-jep106-bank1.tcl  2023-06-13
#============= jedec-jep106-bank1.tcl =================
# 
#  2023-06-13  pds   initial cut


incl jedec-jep106-util.tcl  ;# helper for constructing the bankid

# JEP106BG, rev. JEP106BF.01, May 2023, Page 2
# this bank has 126 lines, and starts with line 1
# each name is 70 chars max, including string terminator
# first element repeats 0x7F (contin char) once for each bank num
# https://www.jedec.org/standards-documents/docs/jep-106ab

# EXAMPLE:
#  mfrid.linenum<6:0> = (JTAG_IDCODE >> 0) & ((1 << 7) - 1)  ;# 7-bits at bit-position 0
#  mfrid.name = [lindex $::JEDEC_JEP106_BANKn $linenum]
#  bankid =  [lindex $::JEDEC_JEP106_BANKn 0], as binary, [format %08b [lindex $::JEDEC_JEP106_BANKn 0]]

namespace eval JEDEC {
  variable JEDEC_JEP106_BANK1

  set JEDEC_JEP106_BANK1  [list [jedec-jep106-bankid 1] \
    "AMD"                               \
    "AMI"                               \
    "Fairchild"                         \
     ...                                \
  ]
}
