defn rvdebug-dm-abstractcs.tcl 2023-06-13
#=========== rvdebug-dmi-abstract.tcl =================
# 
#  2023-06-13  pds   initial cut


incl rvdebug-dm.tcl  ;# the debug module, to which the abstract program facility belongs

#
# ABSTRACTCS REGISTER (THRU DMI)
#
#   clear cmderr by writing all 1s to its bits
#

namespace eval DM::ABSTRACTCS {
  proc xfer {cmderr} {
    variable DMI_ADDR

    # convert string to numeric ... DO NOT use braces of expr when strings are involved
    set cmderr [expr $cmderr]

    # assemble numeric value from bit-fields ... MUST use braces of expr when numerics are involved
    set data_x 0
    set data_x [expr { $data_x | (($cmderr & ((1 << 3) - 1)) << 8) }]  ;# [10:8]

                DTM::DMI::write $DMI_ADDR $data_x       ;# addr data
    set data_x [DTM::DMI::read  $DMI_ADDR 0          ]  ;# addr data

    # extract bit-fields from numeric value ... MUST use braces of expr when numerics are involved
    set progbufsize_x  [expr { ($data_x >> 24) & ((1 << 5) - 1) }]  ;# [28:24]
    set busy_x         [expr { ($data_x >> 12) & ((1 << 1) - 1) }]  ;# [12]
    set cmderr_x       [expr { ($data_x >>  8) & ((1 << 3) - 1) }]  ;# [10:8]
    set datacount_x    [expr { ($data_x >>  0) & ((1 << 4) - 1) }]  ;# [3:0]

    # vanity output style, many-line
#    echo "dtm:dmi_abstractcs (): progbufsize=[format %d $progbufsize_x]"
#    echo "dtm:dmi_abstractcs (): busy=[format %d $busy_x]"
#    echo "dtm:dmi_abstractcs ($cmderr): cmderr=[format %d $cmderr_x]"
#    echo "dtm:dmi_abstractcs (): datacount=[format %d $datacount_x]"

    # returns dictionary of type abstractcs_t
    return [dict create \
      abstractcs   $data_x\
      progbufsize  $progbufsize_x\
      busy         $busy_x\
      cmderr       $cmderr_x\
      datacount    $datacount_x\
    ]
  }

  proc progbufsize {abstractcs_t} { return [dict get $abstractcs_t progbufsize] }
  proc busy {abstractcs_t} { return [dict get $abstractcs_t busy] }
  proc cmderr {abstractcs_t} { return [dict get $abstractcs_t cmderr] }
  proc datacount {abstractcs_t} { return [dict get $abstractcs_t datacount] }

  proc cmderrstr {abstractcs_t} {
    set x [cmderr $abstractcs_t]
    switch $x {
      0 { set str "No Err" }
      1 { set str "Busy" }
      2 { set str "Bad Command" }
      3 { set str "Exception" }
      4 { set str "Not Halted" }
      5 { set str "Bus Error" }
      7 { set str "Other Reason" }
      default { set str "Undefined error ($x)" }
    }
    return $str
  }

  proc abstractcs_val {abstractcs_t} { return [dict get $abstractcs_t abstractcs] }
  proc abstractcs_str {abstractcs_t} { return [format 0x%08x [dict get $abstractcs_t abstractcs]] }
}
