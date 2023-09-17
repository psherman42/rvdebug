defn rvdebug-dm-dmcontrol.tcl 2023-06-13
#======== rvdebug-dmi-dmcontrol.tcl ===================
# 
#  2023-06-13  pds   initial cut


incl rvdebug-dm.tcl  ;# the debug module, to which dmcontrol belongs

# DMCONTROL REGISTER (THRU DMI)
#
#   STARTUP RACE CONDITION
#   Must first enable only the DM (dmactive=1 (haltreq=0, dmi.ndmreset=0)),
#   then halt hart (haltreq=1 (dmactive=1, ndmreset=0)), lastly reset non-debug system
#   (ndmreset=1->0 (dmactive=1, haltreq=1)), sequentially not simultaneously, and in that order.
#   Must provide for a significant and suitably very long time for non-debug system to come out of reset.
#   When NDMRESET_DELAY is too short, write or read op from any register other than dmcontrol results in
#   persistent DM busy (dmi.op=3) state. See section 3.2 of Debug Specification, "while ndmreset is
#   asserted, the only supported DM operation is accessing dmcontrol. The behavior of other accesses
#   is undefined."
#   In persistent DM busy (dmi.op=3) state created by insufficient NDMRESET_DELAY, the DM latches up and
#   is completely unreachable. This DM busy (dmi.op=3) state is NOT clearable by dtmcs.dmireset. Thus,
#   power-cycle is the only way to regain control of the DM in case of insufficient hardware
#   platform-specific NDMRESET_DELAY
#
#   DMI-SAFE ACCESS AREA
#   Write or read the DMI bus ONLY when selected hart is HALTED, or a DM busy (dmi.op=3) condition
#   will result.
#   The sifive implementation of the Debug Specification requires that a core be halted before trying to
#   execute abstract commands on it. When a debugger wants to halt a single hart it selects it in hartsel
#   and sets haltreq, then waits for allhalted to indicate that the hart is halted before clearing
#   haltreq to 0.
#   https://forums.sifive.com/t/a-problem-about-debug-module/746

namespace eval DM::DMCONTROL {
  proc xfer {haltreq resumereq hartreset ackhavereset hasel hartsel setresethaltreq clrresethaltreq ndmreset dmactive} {
    variable DMI_ADDR

    # convert string to numeric ... DO NOT use braces of expr when strings are involved
    set haltreq [expr $haltreq]
    set resumereq [expr $resumereq]
    set hartreset [expr $hartreset]
    set ackhavereset [expr $ackhavereset]
    set hasel [expr $hasel]
    set hartsel [expr $hartsel]
    set setresethaltreq [expr $setresethaltreq]
    set clrresethaltreq [expr $clrresethaltreq]
    set ndmreset [expr $ndmreset]
    set dmactive [expr $dmactive]

    # rearrange weirdly split fields as needed
    set hartselhi [expr { ($hartsel >> 10) }]
    set hartsello [expr { ($hartsel >> 0) }]

    # assemble numeric value from bit-fields ... MUST use braces of expr when numerics are involved
    set data_x 0
    set data_x [expr { $data_x  | (($haltreq & ((1 << 1) - 1)) << 31) }]         ;# [31]
    set data_x [expr { $data_x  | (($resumereq & ((1 << 1) - 1)) << 30) }]       ;# [30]
    set data_x [expr { $data_x  | (($hartreset & ((1 << 1) - 1)) << 29) }]       ;# [29]

    set data_x [expr { $data_x  | (($ackhavereset & ((1 << 1) - 1)) << 28) }]    ;# [28]

    set data_x [expr { $data_x  | (($hasel & ((1 << 1) - 1)) << 26) }]           ;# [26]
    set data_x [expr { $data_x  | (($hartsello & ((1 << 10) - 1)) << 16) }]      ;# [25:16]=hartsel[9:0]
    set data_x [expr { $data_x  | (($hartselhi & ((1 << 10) - 1)) << 6) }]       ;# [15:6]=hartsel[19:10]
    set data_x [expr { $data_x  | (($setresethaltreq & ((1 << 1) - 1)) << 3) }]  ;# [3]
    set data_x [expr { $data_x  | (($clrresethaltreq & ((1 << 1) - 1)) << 2) }]  ;# [2]
    set data_x [expr { $data_x  | (($ndmreset & ((1 << 1) - 1)) << 1) }]         ;# [1]
    set data_x [expr { $data_x  | (($dmactive & ((1 << 1) - 1)) << 0) }]         ;# [0]

                 DTM::DMI::write $DMI_ADDR $data_x    ;# addr data
    set data_x  [DTM::DMI::read  $DMI_ADDR $data_x ]  ;# addr data

    # extract bit-fields from numeric value ... MUST use braces of expr when numerics are involved
    set haltreq_x         [expr { ($data_x   >> 31) & ((1 << 1) - 1) }]   ;# [31]
    set resumereq_x       [expr { ($data_x   >> 30) & ((1 << 1) - 1) }]   ;# [30]
    set hartreset_x       [expr { ($data_x   >> 29) & ((1 << 1) - 1) }]   ;# [29]
    set ackhavereset_x    [expr { ($data_x   >> 28) & ((1 << 1) - 1) }]   ;# [28]
    set hasel_x           [expr { ($data_x   >> 26) & ((1 << 1) - 1) }]   ;# [26]
    set hartsello_x       [expr { ($data_x   >> 16) & ((1 << 10) - 1) }]  ;# [25:16]=hartsel[9:0]
    set hartselhi_x       [expr { ($data_x   >> 6) & ((1 << 10) - 1) }]   ;# [15:6]=hartsel[19:10]
    set setresethaltreq_x [expr { ($data_x   >> 3) & ((1 << 1) - 1) }]    ;# [3]
    set clrresethaltreq_x [expr { ($data_x   >> 2) & ((1 << 1) - 1) }]    ;# [2]
    set ndmreset_x        [expr { ($data_x   >> 1) & ((1 << 1) - 1) }]    ;# [1]
    set dmactive_x        [expr { ($data_x   >> 0) & ((1 << 1) - 1) }]    ;# [0]

    # rearrange weirdly split fields as needed
    set hartsel_x [expr { 0
      | ($hartselhi_x << 10)
      | ($hartsello_x << 0)
     }]

    # vanity output style, many-line
#    echo "dtm:dmi_dmcontrol (): haltreq=[format %d $haltreq_x]"
#    echo "dtm:dmi_dmcontrol (): resumereq=[format %d $resumereq_x]"
#    echo "dtm:dmi_dmcontrol (): hartreset=[format %d $hartreset_x]"
#    echo "dtm:dmi_dmcontrol (): ackhavereset=[format %d $ackhavereset_x]"
#    echo "dtm:dmi_dmcontrol (): hasel=[format %d $hasel_x]"
#    echo "dtm:dmi_dmcontrol (): hartsel<19:0>=[format 0x%05x $hartsel_x]"
#    echo "dtm:dmi_dmcontrol (): setresethaltreq=[format %d $setresethaltreq_x]"
#    echo "dtm:dmi_dmcontrol (): clrresethaltreq=[format %d $clrresethaltreq_x]"
#    echo "dtm:dmi_dmcontrol (): ndmreset=[format %d $ndmreset_x]"
#    echo "dtm:dmi_dmcontrol (): dmactive=[format %d $dmactive_x]"
  }
}
