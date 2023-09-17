defn rvdebug-dm-command.tcl 2023-06-13
#=========== rvdebug-dmi-abstract.tcl =================
# 
#  2023-06-13  pds   initial cut


incl rvdebug-dm.tcl  ;# the debug module, to which the abstract program facility belongs

#
# ABSTRACT COMMAND REGISTER (THRU DMI)
#
#  see Table 3.3 of Abstract Commands Section 3.6 in Debug Specification for this information
#
#  cmdtype<7:0> 0=reg, 1=quick (no reg/mem), 2=mem
#  aarsize<2:0> 0=8-bit, 1=16-bit, 2=32-bit, 3=64-bit, 4=128-bit, 5=256-bit, 6=512-bit, 7=1024-bit
#  aarpostincrement 0=no-incr-regno, 1=incr-regno
#  postexec 0=no-exec-progbuf, 1=exec-progbuf
#  transfer 0=ignore-reg/mem-op, 1=do-reg/mem-op
#  write 0=reg-to-mem, 1=mem-to-reg (0=mem1-to-mem0, 1=mem0-to-mem1)
#  regno<15:0> 0-0xfff=CSR, 0x1000-0x101F=GPR, 0x1020-0x103F=FPR
#

namespace eval DM::COMMAND {
  proc xfer {cmdtype aarsize regno transfer write aarpostincrement postexec} {
    variable DMI_ADDR

    # convert string to numeric ... DO NOT use braces of expr when strings are involved
    set cmdtype [expr $cmdtype]
    set aarsize [expr $aarsize]
    set regno [expr $regno]
    set transfer [expr $transfer]
    set write [expr $write]
    set aarpostincrement [expr $aarpostincrement]
    set postexec [expr $postexec]

    # assemble numeric value from bit-fields ... MUST use braces of expr when numerics are involved
    set data_x 0
    set data_x [expr { $data_x | (($cmdtype & ((1 << 8) - 1)) << 24) }]           ;# [31:24]
    set data_x [expr { $data_x | (($aarsize & ((1 << 3) - 1)) << 20) }]           ;# [22:20]
    set data_x [expr { $data_x | (($aarpostincrement & ((1 << 1) - 1)) << 19) }]  ;# [19]
    set data_x [expr { $data_x | (($postexec & ((1 << 1) - 1)) << 18) }]          ;# [18]
    set data_x [expr { $data_x | (($transfer & ((1 << 1) - 1)) << 17) }]          ;# [17]
    set data_x [expr { $data_x | (($write & ((1 << 1) - 1)) << 16) }]             ;# [16]
    set data_x [expr { $data_x | (($regno & ((1 << 16) - 1)) << 0) }]             ;# [15:0]

                DTM::DMI::write $DMI_ADDR $data_x         ;# addr data
#   set data_x [DTM::DMI::read  $DMI_ADDR 0            ]  ;# addr data... maybe unreadable, by spec?

    # extract bit-fields from numeric value ... MUST use braces of expr when numerics are involved
    set cmdtype_x           [expr { ($data_x >> 24) & ((1 << 8) - 1) }]  ;# [31:24]
    set aarsize_x           [expr { ($data_x >> 20) & ((1 << 3) - 1) }]  ;# [20]
    set aarpostincrement_x  [expr { ($data_x >> 19) & ((1 << 1) - 1) }]  ;# [19]
    set postexec_x          [expr { ($data_x >> 18) & ((1 << 1) - 1) }]  ;# [18]
    set transfer_x          [expr { ($data_x >> 17) & ((1 << 1) - 1) }]  ;# [17]
    set write_x             [expr { ($data_x >> 16) & ((1 << 1) - 1) }]  ;# [16]
    set regno_x             [expr { ($data_x >> 0) & ((1 << 16) - 1) }]  ;# [15:0]

    # vanity output style, many-line
#    echo "dtm:dmi_abstractcmd ([format %d $cmdtype]): cmdtype=[format 0x%02x $cmdtype_x]"
#    echo "dtm:dmi_abstractcmd ($aarsize): aarsize=$aarsize_x"
#    echo "dtm:dmi_abstractcmd ($aarpostincrement): aarpostincrement=[format 0x%02x $aarpostincrement_x]"
#    echo "dtm:dmi_abstractcmd ($postexec): postexec=[format 0x%02x $postexec_x]"
#    echo "dtm:dmi_abstractcmd ($transfer): transfer=[format 0x%02x $transfer_x]"
#    echo "dtm:dmi_abstractcmd ($write): write=[format 0x%02x $write_x]"
#    echo "dtm:dmi_abstractcmd ([format 0x%04x $regno]): regno=[format 0x%04x $regno_x]"
  }
}
