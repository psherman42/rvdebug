defn rvdebug-dm-data.tcl 2023-06-13
#=========== rvdebug-dmi-abstract.tcl =================
# 
#  2023-06-13  pds   initial cut


incl rvdebug-dm.tcl  ;# the debug module, to which the abstract program facility belongs

#
# ABSTRACT DATA REGISTERS (THRU DMI)
#

namespace eval DM::DATA {
  proc xfer {datanum data {mode 0}} {  ;# mode: 0=read, 1=write-read
    variable DATA0_DMI_ADDR
    variable DATA1_DMI_ADDR
    variable DATA2_DMI_ADDR
    variable DATA3_DMI_ADDR
    variable DATA4_DMI_ADDR
    variable DATA5_DMI_ADDR
    variable DATA6_DMI_ADDR
    variable DATA7_DMI_ADDR
    variable DATA8_DMI_ADDR
    variable DATA9_DMI_ADDR
    variable DATA10_DMI_ADDR
    variable DATA11_DMI_ADDR

    # convert string to numeric ... DO NOT use braces of expr when strings are involved
    set datanum [expr $datanum]
    set data [expr $data]
    set mode [expr $mode]

    # assemble numeric value from bit-fields ... MUST use braces of expr when numerics are involved
    set data_x 0
    set data_x [expr { $data_x | (($data & ((1 << 32) - 1)) << 0) }]  ;# [31:0]

    switch $datanum {
      0 { set data_addr $DATA0_DMI_ADDR }
      1 { set data_addr $DATA1_DMI_ADDR }
      2 { set data_addr $DATA2_DMI_ADDR }
      3 { set data_addr $DATA3_DMI_ADDR }
      4 { set data_addr $DATA4_DMI_ADDR }
      5 { set data_addr $DATA5_DMI_ADDR }
      6 { set data_addr $DATA6_DMI_ADDR }
      7 { set data_addr $DATA7_DMI_ADDR }
      8 { set data_addr $DATA8_DMI_ADDR }
      9 { set data_addr $DATA9_DMI_ADDR }
      10 { set data_addr $DATA10_DMI_ADDR }
      11 { set data_addr $DATA11_DMI_ADDR }
      default { echo "only data regs 0..11 allowed" }
    }

    if [expr { $mode == 1 }] {
                DTM::DMI::write $data_addr $data_x  ;# addr data
    }

    set data_x [DTM::DMI::read  $data_addr 0]       ;# addr data

    # vanity output style, many-line
#    echo "dtm:dmi_abstractdata ($datanum [format 0x%08x $data] $mode): i=[format %d $datanum], data=[format 0x%08x $data_x]"

    return $data_x
  }
}
