defn rvdebug-dm-dmstatus.tcl 2023-06-13
#========= rvdebug-dmi-dmstatus.tcl ===================
# 
#  2023-06-13  pds   initial cut


incl rvdebug-dm.tcl  ;# the debug module, to which dmstatus belongs

#
# DMSTATUS REGISTER (THRU DMI)
#
# EXAMPLE:
#    set dmstatus_0 [dtm_dmi_dmstatus]
#    echo "dmi.dmstatus.nonexistent=[dtm_dmi_dmstatus_nonexistent $dmstatus_0]"
#    echo "dmi.dmstatus.halted=[dtm_dmi_dmstatus_halted $dmstatus_0]"
#    echo "dmi.dmstatus.running=[dtm_dmi_dmstatus_running $dmstatus_0]"
#    echo "dmi.dmstatus.version=[dtm_dmi_dmstatus_version $dmstatus_0]"
#    echo "dmi.dmstatus.present=[dtm_dmi_dmstatus_present $dmstatus_0]"

namespace eval DM::DMSTATUS {
  proc xfer {} {
    variable DMI_ADDR

    set data_x [DTM::DMI::read $DMI_ADDR 0]  ;# addr data

    # extract bit-fields from numeric value ... MUST use braces of expr when numerics are involved
    set impebreak_x        [expr { ($data_x >> 22) & ((1 << 1) - 1) }]  ;# [22]
    set havereset_x        [expr { ($data_x >> 18) & ((1 << 2) - 1) }]  ;# [19:18]=(all:any)...
    set resumeack_x        [expr { ($data_x >> 16) & ((1 << 2) - 1) }]  ;# [17:16]=(all:any)...
    set nonexistent_x      [expr { ($data_x >> 14) & ((1 << 2) - 1) }]  ;# [15:14]=(all:any)...
    set unavail_x          [expr { ($data_x >> 12) & ((1 << 2) - 1) }]  ;# [13:12]=(all:any)...
    set running_x          [expr { ($data_x >> 10) & ((1 << 2) - 1) }]  ;# [11:10]=(all:any)...
    set halted_x           [expr { ($data_x >> 8) & ((1 << 2) - 1) }]   ;# [9:8]=(all:any)...
    set authenticated_x    [expr { ($data_x >> 7) & ((1 << 1) - 1) }]   ;# [7]
    set authbusy_x         [expr { ($data_x >> 6) & ((1 << 1) - 1) }]   ;# [6]
    set hasresethaltreq_x  [expr { ($data_x >> 5) & ((1 << 1) - 1) }]   ;# [5]
    set confstrptrvalid_x  [expr { ($data_x >> 4) & ((1 << 1) - 1) }]   ;# [4]
    set version_x          [expr { ($data_x >> 0) & ((1 << 4) - 1) }]   ;# [3:0]

    # vanity output style, many-line
#    echo "dtm:dmi_dmstatus (): impebreak=[format %d $impebreak_x]"
#    echo "dtm:dmi_dmstatus (): havereset (all/any)=[format 0b%02b $havereset_x]"
#    echo "dtm:dmi_dmstatus (): resumeack (all/any)=[format 0b%02b $resumeack_x]"
#    echo "dtm:dmi_dmstatus (): nonexistent (all/any)=[format 0b%02b $nonexistent_x]"
#    echo "dtm:dmi_dmstatus (): unavail (all/any)=[format 0b%02b $_unavail_x]"
#    echo "dtm:dmi_dmstatus (): running (all/any)=[format 0b%02b $running_x]"
#    echo "dtm:dmi_dmstatus (): halted (all/any)=[format 0b%02b $halted_x]"
#    echo "dtm:dmi_dmstatus (): authenticated=[format %d $authenticated_x]"
#    echo "dtm:dmi_dmstatus (): authbusy=[format %d $authbusy_x]"
#    echo "dtm:dmi_dmstatus (): hasresethaltreq=[format %d $hasresethaltreq_x]"
#    echo "dtm:dmi_dmstatus (): confstrptrvalid=[format %d $confstrptrvalid_x]"
#    echo "dtm:dmi_dmstatus (): version=[format %d $version_x]"

    # returns dictionary of type dmstatus_t
    return [dict create \
      impebreak        $impebreak_x\
      havereset        $havereset_x\
      resumeack        $resumeack_x\
      nonexistent      $nonexistent_x\
      unavail          $unavail_x\
      running          $running_x\
      halted           $halted_x\
      authenticated    $authenticated_x\
      authbusy         $authbusy_x\
      hasresethaltreq  $hasresethaltreq_x\
      confstrptrvalid  $confstrptrvalid_x\
      version          $version_x\
    ]
  }

  proc halted {dmstatus_t} { return [dict get $dmstatus_t halted] }
  proc running {dmstatus_t} { return [dict get $dmstatus_t running] }

  proc verstr {dmstatus_t} {
    switch [dict get $dmstatus_t version] {
      0 { set str "no Debug Module present" }
      1 { set str "Debug Module version 0.11" }
      2 { set str "Debug Module version 0.13" }
      15 { set str "non-conforming Debug Module" }
      default { set str "unknown Debug Module version $str" }
    }
    return $str
  }

  proc present {dmstatus_t} {
    return [expr { 1\
      && ([dict get $dmstatus_t nonexistent] == 0)\
      && (([dict get $dmstatus_t halted] != 0) || ([dict get $dmstatus_t running] != 0))\
    }]
  }
}
