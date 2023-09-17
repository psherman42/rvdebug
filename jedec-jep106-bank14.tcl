defn jedec-jep106-bank14.tcl 2023-06-13
#============= jedec-jep106-bank14.tcl =================
# 
#  2023-06-13  pds   initial cut


incl jedec-jep106-util.tcl  ;# helper for constructing the bankid

# JEP106BG, rev. JEP106BF.01, May 2023, Page 41
# this bank has 126 lines, and starts with line 1
# each name is 70 chars max, including string terminator
# https://www.jedec.org/standards-documents/docs/jep-106ab

# EXAMPLE:
#  mfrid = (jep106bank % 16) << 7) | jep106line
#  mfrname = [lindex $::JEDEC_JEP106_BANKn $jep106line]
#  bankid =  [lindex $::JEDEC_JEP106_BANKn 0], as binary, [format %08b [lindex $::JEDEC_JEP106_BANKn 0]]

namespace eval JEDEC {
  variable JEDEC_JEP106_BANK14

  set JEDEC_JEP106_BANK14 [list [jedec-jep106-bankid 14] \
    "TECOTON"                              \
    "Abko Co Ltd"                          \
    "Shenzhen Feisrike Technology Co Ltd"  \
     ...                                   \
  ]
}
