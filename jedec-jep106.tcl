defn jedec-jep106.tcl  2023-06-13
#=============== jedec-jep106.tcl =====================
# 
#  2023-06-13  pds   initial cut

# JEP106BG, rev. JEP106BF.01, May 2023
# mfr id has 15 banks, starting with bank 1
# each bank has 126 lines, and starts with line 1
# first element of each bank table repeats 0x7F (contin char) once for each bank num
# mfr id name is 70-char max, including string terminator
# https://www.jedec.org/standards-documents/docs/jep-106ab
#
#                 +----------+     +------------+
#                 | JED106   |     | JED106BANK |
#                 +----------+     +------------+
# mfrid.banknum---+ banknum  |     |            |
#                 | bankname +=====+ bankname   |
#                 +----------+     |            |
# mfrid.linenum--------------------+ linenum    |
#                                  | bankid     +------mfrid.bankid
#                                  | mfrname    +------mfrid.name
#                                  +------------+
# EXAMPLE:
#  mfrid<10:0> = (JTAG_IDCODE >> 1) & ((1 << 10) - 1)  ;# 10-bits at bit-position 1
#  mfrid.banknum<3:0> = (JTAG_IDCODE >> 7) & ((1 << 4) - 1)  ;# 4-bits at bit-position 7
#  mfrid.linenum<6:0> = (JTAG_IDCODE >> 0) & ((1 << 7) - 1)  ;# 7-bits at bit-position 0
#  mfrid.name = [lindex $[lindex $::JEDEC_JEP106 $banknum] $linenum]  ;# 3NF table look-up
#  bankid =              [lindex [expr [lindex $::JEDEC_JEP106 $banknum]] 0]    ;# hex
#  bankid = [format %08b [lindex [expr [lindex $::JEDEC_JEP106 $banknum]] 0] ]  ;# binary
#  banknum=1, bankid=0x00 (0)
#  banknum=2, bankid=0x7F (01111111)
#  banknum=3, bankid=0x7F7F (111111101111111)
#  banknum=4, bankid=0x7F7F7F (11111110111111101111111)

incl jedec-jep106-bank1.tcl
incl jedec-jep106-bank2.tcl
incl jedec-jep106-bank3.tcl
incl jedec-jep106-bank4.tcl
incl jedec-jep106-bank5.tcl
incl jedec-jep106-bank6.tcl
incl jedec-jep106-bank7.tcl
incl jedec-jep106-bank8.tcl
incl jedec-jep106-bank9.tcl
incl jedec-jep106-bank10.tcl
incl jedec-jep106-bank11.tcl
incl jedec-jep106-bank12.tcl
incl jedec-jep106-bank13.tcl
incl jedec-jep106-bank14.tcl
incl jedec-jep106-bank15.tcl
# add more bank files above, and list entries below, as needed

namespace eval JEDEC {
  proc jep106_mfr_name {banknum linenum} {
    variable JEDEC_JEP106_BANK1
    variable JEDEC_JEP106_BANK2
    variable JEDEC_JEP106_BANK3
    variable JEDEC_JEP106_BANK4
    variable JEDEC_JEP106_BANK5
    variable JEDEC_JEP106_BANK6
    variable JEDEC_JEP106_BANK7
    variable JEDEC_JEP106_BANK8
    variable JEDEC_JEP106_BANK9
    variable JEDEC_JEP106_BANK10
    variable JEDEC_JEP106_BANK11
    variable JEDEC_JEP106_BANK12
    variable JEDEC_JEP106_BANK13
    variable JEDEC_JEP106_BANK14
    variable JEDEC_JEP106_BANK15

    variable JEDEC_JEP106

    set JEDEC_JEP106 [list \
      [list $JEDEC_JEP106_BANK1 ] \
      [list $JEDEC_JEP106_BANK2 ] \
      [list $JEDEC_JEP106_BANK3 ] \
      [list $JEDEC_JEP106_BANK4 ] \
      [list $JEDEC_JEP106_BANK5 ] \
      [list $JEDEC_JEP106_BANK6 ] \
      [list $JEDEC_JEP106_BANK7 ] \
      [list $JEDEC_JEP106_BANK8 ] \
      [list $JEDEC_JEP106_BANK9 ] \
      [list $JEDEC_JEP106_BANK10] \
      [list $JEDEC_JEP106_BANK11] \
      [list $JEDEC_JEP106_BANK12] \
      [list $JEDEC_JEP106_BANK13] \
      [list $JEDEC_JEP106_BANK14] \
      [list $JEDEC_JEP106_BANK15] \
    ]

    return [lindex $[lindex $JEDEC_JEP106 $banknum] $linenum]  ;# 3NF table look-up
  }
}
