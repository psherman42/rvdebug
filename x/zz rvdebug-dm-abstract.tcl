defn rvdebug-dmi-abstract.tcl 2023-06-13
#=========== rvdebug-dmi-abstract.tcl =================
# 
#  2023-06-13  pds   initial cut


incl rvdebug-dtm-dmi-dm.tcl  ;# the debug module, to which the abstract program facility belongs

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

                DTM::DMI::write $DMI_ADDR $data_x ;# addr data
    set data_x [DTM::DMI::read  $DMI_ADDR 0          ]  ;# addr data

    # extract bit-fields from numeric value ... MUST use braces of expr when numerics are involved
    set progbufsize_x  [expr { ($data_x >> 24) & ((1 << 5) - 1) }]  ;# [28:24]
    set busy_x         [expr { ($data_x >> 12) & ((1 << 1) - 1) }]  ;# [12]
    set cmderr_x       [expr { ($data_x >> 8) & ((1 << 3) - 1) }]  ;# [10:8]
    set datacount_x    [expr { ($data_x >> 0) & ((1 << 4) - 1) }]  ;# [3:0]

    # vanity output style, many-line
#    echo "dtm:dmi_abstractcs (): progbufsize=[format %d $progbufsize_x]"
#    echo "dtm:dmi_abstractcs (): busy=[format %d $busy_x]"
#    echo "dtm:dmi_abstractcs ($cmderr): cmderr=[format %d $cmderr_x]"
#    echo "dtm:dmi_abstractcs (): datacount=[format %d $datacount_x]"

    return $data_x
  }
}

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

                DTM::DMI::write $DMI_ADDR $data_x  ;# addr data
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
