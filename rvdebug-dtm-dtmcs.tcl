defn rvdebug-dtm-dtmcs.tcl 2023-06-13
#============== rvdebug-dtm-dtmcs.tcl =================
# 
#  2023-06-13  pds   initial cut


incl rvdebug-dtm.tcl  ;# the data transport module, to which dtmcs belongs

#
# DTMCS REGISTER
#
#
# dtmcs.zero1        [31:18]=0 (always)
# dtmcs.dtmhardreset [17] 0=norm, 1=reset (was dmihardreset) returns all registers and internal states to their reset value
# dtmcs.dmireset     [16] 0=norm, 1=reset
# dtmcs.zero0        [15]=0 (always)
# dtmcs.idle         [14:12]=num-run-test-idle-cycles-desired (0..N)
# dtmcs.dmistat      [11:10] 0=no-error, 1=same-as-2, 2=op-failed, 3=dmi-access-in-progress
# dtmcs.abits        [9:4] size of address in dmi
# dtmcs.version      [3:0] 0=0.11, 1=0.13, 15=undescribed/unsupported (all 1's)
#
# Rename dtmc.dmihardreset field to dtmhardreset #833
# https://github.com/riscv/riscv-debug-spec/pull/833
#
# NOTE: dtmcs.dmistat vs. dmi.op
#   dtmcs.dmistat is a read-only alias of dmi.op
#   https://github.com/riscv/riscv-debug-spec/pull/720.
#   "the value of `op` that was the result of the most recent DMI access")
#   https://lists.riscv.org/g/tech-debug/message/674
#   if dmi.op == 3 (DMI req in progress)
#   then dtmcs.dmireset = 1
#   and delay between Update-DR (Update-IR) and Capture-DR
#
# EXAMPLE:
#    set dtmcs_0 [dtm_dtmcs 0 0]  ;# dtmhardreset dmireset (0=norm, 1=reset)
#    echo "dtmcs.dtmcs=[dtm_dtmcs_val $dtmcs_0]"
#    echo "dtmcs.abits=[dtm_dtmcs_abits $dtmcs_0]"
#    echo "dtmcs.idle=[dtm_dtmcs_idle $dtmcs_0]"
#    echo "dtmcs.dmistat=[dtm_dtmcs_dmistat $dtmcs_0]"
#    echo "dtmcs.version=[dtm_dtmcs_version $dtmcs_0]"
#    echo "dtmcs.version_str=[dtm_dtmcs_verstr $dtmcs_0]"
#    echo "dtmcs.dtmcs_str=[dtm_dtmcs_str $dtmcs_0]"

namespace eval DTM::DTMCS {
  proc xfer {dtmhardreset dmireset} {
    variable INSTR_CODE
    variable DATA_LEN

    # convert string to numeric ... DO NOT use braces of expr when strings are involved
    set dtmhardreset [expr $dtmhardreset]
    set dmireset [expr $dmireset]

    # assemble numeric value from bit-fields ... MUST use braces of expr when numerics are involved
    # leave read-only fields as zero (unspecified here)
    set data_x 0
    set data_x [expr { $data_x | (($dtmhardreset & ((1 << 1) - 1)) << 17) }]  ;# [17]
    set data_x [expr { $data_x | (($dmireset & ((1 << 1) - 1)) << 16) }]      ;# [16]

    set data_x [DTM::xfer $INSTR_CODE $DATA_LEN [expr { $data_x }]]

    # convert string of hex digits to numeric
    scan $data_x "%x" data_x

    # extract bit-fields from numeric value ... MUST use braces of expr when numerics are involved
    set dtmhardreset_x [expr { ($data_x >> 17) & ((1 << 1) - 1) }]  ;# [17]
    set dmireset_x     [expr { ($data_x >> 16) & ((1 << 1) - 1) }]  ;# [16]
    set idle_x         [expr { ($data_x >> 12) & ((1 << 3) - 1) }]  ;# [14:12]
    set dmistat_x      [expr { ($data_x >> 10) & ((1 << 2) - 1) }]  ;# [11:10]
    set abits_x        [expr { ($data_x >>  4) & ((1 << 6) - 1) }]  ;# [9:4]
    set version_x      [expr { ($data_x >>  0) & ((1 << 4) - 1) }]  ;# [3:0]

#    vanity output style, single-line
#    echo -n "dtm:dtmcs ($dtmhardreset $dmireset):"
#    echo -n " dtmhardreset=$dtmhardreset_x"
#    echo -n " dmireset=$dmireset_x"
#    echo -n " idle=$idle_x"
#    echo -n " dmistat=$dmistat_x"
#    echo -n " abits=$abits_x"
#    echo -n " version=$version_x"
#    echo    " (all=[format 0x%08x $data_x])"

    # returns dictionary of type dtmcs_t
    return [dict create \
      dtmcs         $data_x \
      dtmhardreset  $dtmhardreset_x\
      dmireset      $dmireset_x\
      idle          $idle_x\
      dmistat       $dmistat_x\
      abits         $abits_x\
      version       $version_x\
    ]
  }

  proc abits {dtmcs_t} { return [dict get $dtmcs_t abits] }
  proc idle {dtmcs_t} { return [dict get $dtmcs_t idle] }
  proc dmistat {dtmcs_t} { return [dict get $dtmcs_t dmistat] }
  proc version {dtmcs_t} { return [dict get $dtmcs_t version] }

  proc dtmcs_val {dtmcs_t} { return [dict get $dtmcs_t dtmcs] }
  proc dtmcs_str {dtmcs_t} { return [format 0x%08x [dict get $dtmcs_t dtmcs]] }

  proc verstr {dtmcs_t} {
    # similar to dmi.dmstatus.version
    switch [dict get $dtmcs_t version] {
      0 { set str "Debug Module version 0.11" }
      1 { set str "Debug Module version 0.13" }
      15 { set str "non-described Debug Module (all 1s, power okay?" }
      default { set str "unknown Debug Transport Module version [dict get $dtmcs_t version]" }
    }
  }
}