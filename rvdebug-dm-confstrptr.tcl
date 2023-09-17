defn rvdebug-dm-confstrptr.tcl 2023-06-13
#============ rvdebug-dmi-confstrptr.tcl ==============
# 
#  2023-06-13  pds   initial cut


incl rvdebug-dm.tcl  ;# the debug module, to which confstrptr belongs

#
# CONFIGURATION STRING POINTER REGISTERS (THRU DMI)
#

namespace eval DM::CONFSTRPTR {
  proc xfer {confnum confstr {mode 0}} {  ;# mode: 0=read, 1=write-read
    variable CONFSTRPTR0_DMI_ADDR
    variable CONFSTRPTR1_DMI_ADDR
    variable CONFSTRPTR2_DMI_ADDR
    variable CONFSTRPTR3_DMI_ADDR

    # convert string to numeric ... DO NOT use braces of expr when strings are involved
    set confnum [expr $confnum]
    set confstr [expr $confstr]
    set mode [expr $mode]

    # assemble numeric value from bit-fields ... MUST use braces of expr when numerics are involved
    set data_x 0
    set data_x [expr { $data_x | (($confstr & ((1 << 32) - 1)) << 0) }]  ;# [31:0]

    switch $confnum {
      0 { set confstrptr_addr $CONFSTRPTR0_DMI_ADDR }
      1 { set confstrptr_addr $CONFSTRPTR1_DMI_ADDR }
      2 { set confstrptr_addr $CONFSTRPTR2_DMI_ADDR }
      3 { set confstrptr_addr $CONFSTRPTR3_DMI_ADDR }
      default { echo "only data regs 0..3 allowed, not $confnum" }
    }

    if [expr { $mode == 1 }] {
                DTM::DMI::write $confstrptr_addr $data_x  ;# addr data
    }

    set data_x [DTM::DMI::read $confstrptr_addr 0]  ;# addr data

    # vanity output style, many-line
    #echo "dtm:dmi_confstrptr ($confnum $confstr $mode): [format %d $confnum]: confstr=[format 0x%08x $data_x]"

    return $data_x
  }
}
