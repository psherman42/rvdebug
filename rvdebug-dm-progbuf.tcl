defn rvdebug-dm-progbuf.tcl 2023-06-13
#=========== rvdebug-dmi-abstract.tcl =================
# 
#  2023-06-13  pds   initial cut


incl rvdebug-dm.tcl  ;# the debug module, to which the abstract program facility belongs

#
# ABSTRACT PROGRAM REGISTERS (THRU DMI)
#

namespace eval DM::PROGBUF {
  proc xfer {progbufnum progbuf {mode 0}} {  ;# mode: 0=read, 1=write-read
    variable PROGBUF0_DMI_ADDR
    variable PROGBUF1_DMI_ADDR
    variable PROGBUF2_DMI_ADDR
    variable PROGBUF3_DMI_ADDR
    variable PROGBUF4_DMI_ADDR
    variable PROGBUF5_DMI_ADDR
    variable PROGBUF6_DMI_ADDR
    variable PROGBUF7_DMI_ADDR
    variable PROGBUF8_DMI_ADDR
    variable PROGBUF9_DMI_ADDR
    variable PROGBUF10_DMI_ADDR
    variable PROGBUF11_DMI_ADDR
    variable PROGBUF12_DMI_ADDR
    variable PROGBUF13_DMI_ADDR
    variable PROGBUF14_DMI_ADDR
    variable PROGBUF15_DMI_ADDR

    # convert string to numeric ... DO NOT use braces of expr when strings are involved
    set progbufnum [expr $progbufnum]
    set progbuf [expr $progbuf]
    set mode [expr $mode]

    # assemble numeric value from bit-fields ... MUST use braces of expr when numerics are involved
    set data_x 0
    set data_x [expr { $data_x | (($progbuf & ((1 << 32) - 1)) << 0) }]  ;# [31:0]

    switch $progbufnum {
      0 { set progbuf_addr $PROGBUF0_DMI_ADDR }
      1 { set progbuf_addr $PROGBUF1_DMI_ADDR }
      2 { set progbuf_addr $PROGBUF2_DMI_ADDR }
      3 { set progbuf_addr $PROGBUF3_DMI_ADDR }
      4 { set progbuf_addr $PROGBUF4_DMI_ADDR }
      5 { set progbuf_addr $PROGBUF5_DMI_ADDR }
      6 { set progbuf_addr $PROGBUF6_DMI_ADDR }
      7 { set progbuf_addr $PROGBUF7_DMI_ADDR }
      8 { set progbuf_addr $PROGBUF8_DMI_ADDR }
      9 { set progbuf_addr $PROGBUF9_DMI_ADDR }
      10 { set progbuf_addr $PROGBUF10_DMI_ADDR }
      11 { set progbuf_addr $PROGBUF11_DMI_ADDR }
      12 { set progbuf_addr $PROGBUF12_DMI_ADDR }
      13 { set progbuf_addr $PROGBUF13_DMI_ADDR }
      14 { set progbuf_addr $PROGBUF14_DMI_ADDR }
      15 { set progbuf_addr $PROGBUF15_DMI_ADDR }
      default { echo "only progbuf regs 0..15 allowed" }
    }

    if [expr { $mode == 1 }] {
                DTM::DMI::write $progbuf_addr $data_x  ;# addr data
    }

    set data_x [DTM::DMI::read  $progbuf_addr 0        ]  ;# addr data

    # vanity output style, many-line
#    echo "dtm:dmi_abstractprog ($progbufnum [format 0x%08x $progbuf] $mode): i=[format %d $progbufnum], progbuf=[format 0x%08x $progbuf_x]"

    return $data_x
  }
}
