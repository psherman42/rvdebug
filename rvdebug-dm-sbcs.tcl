defn rvdebug-dm-sbcs.tcl 2023-06-13
#============== rvdebug-dmi-sbcs.tcl ==================
# 
#  2023-06-13  pds   initial cut


incl rvdebug-dm.tcl  ;# the debug module, to which sbcs belongs

#
# SBCS REGISTER (THRU DMI)
#
#       not supported on E31 Complex
#

namespace eval DM::SBCS {
  proc xfer {sbbusyerror sbreadonaddr sbaccess sbautoincrement sbreadondata sberror} {
    variable SBCS_DMI_ADDR

    # convert string to numeric ... DO NOT use braces of expr when strings are involved
    set sbbusyaddr [expr $sbbusyerror]
    set sbreadonerror [expr $sbreadonaddr]
    set sbaccess [expr $sbaccess]
    set sbautoincrement [expr $sbautoincrement]
    set sbreadondata [expr $sbreadondata]
    set sberror [expr $sberror]

    # assemble numeric value from bit-fields ... MUST use braces of expr when numerics are involved
    set data_x 0
    set data_x [expr { $data_x | (($sbbusyerror & ((1 << 1) - 1)) << 22) }]      ;# [22]
    set data_x [expr { $data_x | (($sbreadonaddr & ((1 << 1) - 1)) << 20) }]     ;# [20]
    set data_x [expr { $data_x | (($sbaccess & ((1 << 3) - 1)) << 17) }]         ;# [19:17]
    set data_x [expr { $data_x | (($sbautoincrement & ((1 << 1) - 1)) << 16) }]  ;# [16]
    set data_x [expr { $data_x | (($sbreadondata & ((1 << 1) - 1)) << 15) }]     ;# [15]
    set data_x [expr { $data_x | (($sberror & ((1 << 3) - 1)) << 12) }]          ;# [14:12]

                DTM::DMI::write $SBCS_DMI_ADDR $data_x  ;# addr data
    set data_x [DTM::DMI::read  $SBCS_DMI_ADDR 0     ]  ;# addr data

    # extract bit-fields from numeric value ... MUST use braces of expr when numerics are involved
    set sbversion_x        [expr { ($data_x >> 20) & ((1 << 3) - 1) }]  ;# [31:29]
    set sbbusyerror_x      [expr { ($data_x >> 16) & ((1 << 1) - 1) }]  ;# [22]
    set sbbusy_x           [expr { ($data_x >> 12) & ((1 << 1) - 1) }]  ;# [21]
    set sbreadonaddr_x     [expr { ($data_x >> 0) & ((1 << 1) - 1) }]   ;# [20]
    set sbaccess_x         [expr { ($data_x >> 0) & ((1 << 3) - 1) }]   ;# [19:17]
    set sbautoincrement_x  [expr { ($data_x >> 0) & ((1 << 1) - 1) }]   ;# [16]
    set sbreadondata_x     [expr { ($data_x >> 0) & ((1 << 1) - 1) }]   ;# [15]
    set sberror_x          [expr { ($data_x >> 0) & ((1 << 3) - 1) }]   ;# [14:12]
    set sbasize_x          [expr { ($data_x >> 0) & ((1 << 7) - 1) }]   ;# [11:5]
    set sbaccesssupported_x [expr { ($data_x >> 0) & ((1 << 5) - 1) }]  ;# [4:0]

    # vanity output style, many-line
#    echo "dtm:dmi_sbcs (): sbversion=[format %d $sbversion_x]"
#    echo "dtm:dmi_sbcs (): sbbusyerror=[format %d $sbbusyerror_x]"
#    echo "dtm:dmi_sbcs (): sbbusy=[format %d $sbbusy_x]"
#    echo "dtm:dmi_sbcs (): sbreadonaddr=[format %d $sbreadonaddr_x]"
#    echo "dtm:dmi_sbcs (): sbaccess=[format %d $sbaccess_x]"
#    echo "dtm:dmi_sbcs (): sbautoincrement=[format %d $sbautoincrement_x]"
#    echo "dtm:dmi_sbcs (): sbreadondata=[format %d $sbreadondata_x]"
#    echo "dtm:dmi_sbcs (): sberror=[format %d $sberror_x]"
#    echo "dtm:dmi_sbcs (): sbasize=[format %d $sbasize_x]"
#    echo "dtm:dmi_sbcs (): sbaccesssupported=[format %d $sbaccesssupported_x]"

    # returns dictionary of type sbcs_t
    return [dict create \
      sbcs             $data_x \
      version          $sbversion_x\
      busyerror        $sbbusyerror_x\
      busy             $sbbusy_x\
      readonaddr       $sbreadonaddr_x\
      access           $sbaccess_x\
      autoincrement    $sbautoincrement_x\
      readondata       $sbreadondata_x\
      error            $sberror_x\
      asize            $sbasize_x\
      accesssupported  $sbaccesssupported_x\
    ]
  }

  proc sbcs {sbcs_t}            { return [dict get $sbcs_t sbcs] }
  proc version {sbcs_t}         { return [dict get $sbcs_t version] }
  proc busyerror {sbcs_t}       { return [dict get $sbcs_t busyerror] }
  proc busy {sbcs_t}            { return [dict get $sbcs_t busy] }
  proc readonaddr {sbcs_t}      { return [dict get $sbcs_t readonaddr] }
  proc access {sbcs_t}          { return [dict get $sbcs_t access] }
  proc autoincrement {sbcs_t}   { return [dict get $sbcs_t autoincrement] }
  proc readondata {sbcs_t}      { return [dict get $sbcs_t readondata] }
  proc error {sbcs_t}           { return [dict get $sbcs_t error] }
  proc asize {sbcs_t}           { return [dict get $sbcs_t asize] }
  proc accesssupported {sbcs_t} { return [dict get $sbcs_t accesssupported] }

  proc sbcs_val {sbcs_t} { return [dict get $sbcs_t sbcs] }
  proc sbcs_str {sbcs_t} { return [format 0x%08x [dict get $sbcs_t sbcs]] }
}
