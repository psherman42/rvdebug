defn jedec-jep106-bank12.tcl 2023-06-13
#============= jedec-jep106-bank12.tcl =================
# 
#  2023-06-13  pds   initial cut


incl jedec-jep106-util.tcl  ;# helper for constructing the bankid

# JEP106BG, rev. JEP106BF.01, May 2023, Page 35
# this bank has 126 lines, and starts with line 1
# each name is 70 chars max, including string terminator
# https://www.jedec.org/standards-documents/docs/jep-106ab

# EXAMPLE:
#  mfrid = (jep106bank % 16) << 7) | jep106line
#  mfrname = [lindex $::JEDEC_JEP106_BANKn $jep106line]
#  bankid =  [lindex $::JEDEC_JEP106_BANKn 0], as binary, [format %08b [lindex $::JEDEC_JEP106_BANKn 0]]

namespace eval JEDEC {
  variable JEDEC_JEP106_BANK12

  set JEDEC_JEP106_BANK12 [list [jedec-jep106-bankid 12] \
    "ABIT Electronics (Shenzhen) Co Ltd" \
    "Semidrive"                          \
    "MyTek Electronics Corp"             \
       ...                               \
  ]
}
