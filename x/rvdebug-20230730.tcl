defn rvdebug.tcl 2023-06-13
#================= rvdebug.tcl ========================
#
#  model of register "objects"
#  that implements the Debug Specification
#
#                        +-------+
#                        |  DTM  |
#                        +---+---+
#                            |
#      +------------+--------+---+------------------------+
#      |            |            |                        |
#  +---+----+  +----+---+    +---+---+                 +--+--+
#  | BYPASS |  | IDCODE |    | DTMCS |                 | DMI |
#  +--------+  +--+-----+    +-------+                 +--+--+
#                 |                                       |
#           +-----+--+          +-------+------+-------+--+----+------+------+----------+--------+
#           | JEDEC  |          |       |      |       |       |      |      |          |        |
#           | JEP106 |    +-----+-----+ | +----+-----+ | +-----+----+ | +----+----+  +--+-----+  |
#           +---+----+    | DMCONTROL | | | DMSTATUS | | | HARTINFO | | | HARTSUM |  | XFER   |--+---+
#               |         +-----------+ | +----------+ | +----------+ | +---------+  | MANY   | XFER |
#           +---o----+                  |              |              |              | LITTLE | ONE  |
#           | JEDEC  |                  |              |              |              +--------+ BIG  |
#           | JEP106 |            +-----+----+   +-----+------+    +--+---+                  +-------+
#           | BANKn  |            | ABSTRACT |   | CONFSTRPTR |    | SBCS |
#           +--------+            +-----+----+   +------------+    +------+
#                                       |
#                                    +--+--+
#                                    | ISA |
#                                    +--+--+
#                                       |
#                                   +---+-------------+
#                                   |                 |
#                              +----+-+           +---+---+
#                              | REGS |           | INSTR |
#                              +--+---+           +---+---+
#                                 |                   |
#                     +------+--+-+---+      +----+---+----+-----+---+
#                     |      |  |     |      |    |        |     |   |
#                     | +--+--+ | +--+--+    | +--+--+ | +-+-+ +-+-+ |
#                     | | CSR | | | GPR |    | | CSR | | | I | | D | |
#                     | +-----+ | +-----+    | +-----+ | +---+ +---+ |
#                   +-+---+   +-+--+       +-+-+     +-+-+         +-+-+
#                   | FPR |   | VR |       | A |     | M |         | F |
#                   +-----+   +----+       +---+     +---+         +---+
#
#  2023-06-13  pds   initial cut


incl rvdebug-handler.tcl           ;# messages and how to handle them
incl rvdebug-dtm-bypass.tcl        ;# a do-nothing transaction
incl rvdebug-dtm-bypass-1fh.tcl    ;# another do-nothing transaction
incl rvdebug-dtm-riscv-rsvd.tcl    ;# yet unimplemented functions
incl rvdebug-dtm-idcode.tcl        ;# the chip id and mfr id and name
incl rvdebug-dtm-dtmcs.tcl         ;# to use dtmhartreset for doing a clean startup
incl rvdebug-dtm-dmi.tcl           ;# for access to the dmi bus
incl rvdebug-dm-dmcontrol.tcl      ;# for ndmreset race-condition avoidance, halting, and resuming
incl rvdebug-dm-dmstatus.tcl       ;# to check version and compare to dtm.dtmcs.version


proc rvdebug { } {  ;# top level
  #--- testing TAP chain
  #
  echo -n "testing TAP chain"
  echo -n "... bypass=[DTM::BYPASS::xfer]"
  echo -n ", bypass(0x1F)=[DTM::BYPASS_1FH::xfer]"
  echo -n ", riscv-rsvd=[DTM::RISCV_RSVD::xfer]"
  echo ""
  #
  #--- testing TAP chain

  #--- identify target device
  #
  echo -n "identifying device"

  set idcode_0 [DTM::IDCODE::xfer]    ;# attempt to read chip id

  # go no further if nothing there
  # NOTE: (return -errorcode <num>) get OVERRIDEN by OpenOCD and turned into -4, use ::rvdebugErrorCode
  # NOTE: (return -options <dict>) get DESTROYED by OpenOCD, use ::rvdebugErrorOptions
  if 0 {
  } elseif [DTM::IDCODE::is_stuck_low $idcode_0] {
    set ::rvdebugErrorCode $::RVDEBUG_INIT_ERR_ID_STUCK_LOW
    set ::rvdebugErrorOptions [dict create \
      {-what-went-wrong} {cannot read chip id} \
      {-what-to-check} {TDO stuck low?} \
      {-what-to-do} {power? wiring? target latched up?} \
    ]
    return -code $::TCL_ERROR -errorinfo [list {main} {rvdebug.cfg} {check_idcode}]  ;# proc file line

  } elseif [DTM::IDCODE::is_stuck_high $idcode_0] {
   set ::rvdebugErrorCode $::RVDEBUG_INIT_ERR_ID_STUCK_HIGH
   set ::rvdebugErrorOptions [dict create \
      {-what-went-wrong} {cannot read chip id} \
      {-what-to-check} {TDO stuck high?} \
      {-what-to-do} {power? open-drain need pull-up? target latched up?} \
    ]
    return -code $::TCL_ERROR -errorinfo [list {main} {rvdebug.cfg} {check_idcode}]  ;# proc file line

  } elseif {[string length [DTM::IDCODE::mfrid_str $idcode_0]] == 0} {
    set ::rvdebugErrorCode $::RVDEBUG_INIT_ERR_ID_UNKNOWN
    set ::rvdebugErrorOptions [dict create \
      {-what-went-wrong} [concat {unexpected device} [idcode_str $idcode_0] ] \
      {-what-to-check} {mfrid name in database?} \
      {-what-to-do} {update idcode mfrid JEDEC tables in rvdebug project} \
    ]
    return -code $::TCL_ERROR -errorinfo [list {main} {rvdebug.cfg} {check_idcode}]  ;# proc file line

  } elseif {([DTM::IDCODE::idcode_val $idcode_0] & 0x1) != 0x1} {
    set ::rvdebugErrorCode $::RVDEBUG_INIT_ERR_ID_NONCONFORM
    set ::rvdebugErrorOptions [dict create \
      {-what-went-wrong} {non-conforming id code} \
      {-what-to-check} [concat {lsb of} [idcode_str $idcode_0] {is not 1} ] \
      {-what-to-do} {wiring or phase of TDI, TDO, TCK?} \
    ]
    return -code $::TCL_ERROR -errorinfo [list {main} {rvdebug.cfg} {check_idcode}]  ;# proc file line

  } else {
  }

  echo -n "... found mfrid=[DTM::IDCODE::mfrid $idcode_0]"
  echo -n " ([DTM::IDCODE::mfrid_str $idcode_0])"
  echo -n ", partnum=[DTM::IDCODE::partnum $idcode_0]"
  echo -n ", ver=[DTM::IDCODE::version $idcode_0]"
  echo -n " ([DTM::IDCODE::idcode_str $idcode_0])"
  echo ""

  #
  #--- identify target device


  #--- preparing debug transport module to known good initial state
  #
  echo -n "preparing transport module"

  # configure the dmi as target specifies (ask the dtm and tell the dmi)
  set dtmcs_0 [DTM::DTMCS::xfer 0 0]  ;# dtmhardreset dmireset (0=norm, 1=reset)
  DTM::DMI::set_addr_len    [DTM::DTMCS::abits $dtmcs_0]  ;# num address bits
  DTM::DMI::set_data_len    32  ;# always, for now, per Debug Specification
  DTM::DMI::set_op_len       2  ;# always, for now, per Debug Specification
  DTM::DMI::set_idle_cycles [DTM::DTMCS::idle $dtmcs_0]   ;# transaction dwell (num. TCK cycles)

  # return all registers and internal state to their reset values
  # purge any outstanding DMI transactions
  #set dtmcs_0 [DTM::DTMCS::xfer 1 0]  ;# dtmhardreset dmireset (0=norm, 1=reset)

  # clear sticky DMI op=3 result
  set dtmcs_0 [DTM::DTMCS::xfer 0 1]  ;# dtmhardreset dmireset (0=norm, 1=reset)

#  if {![DTM::DMI::is_configured]} {
#    set ::rvdebugErrorCode $::RVDEBUG_INIT_ERR_DMI_NO_CONFIG
#    set ::rvdebugErrorOptions [dict create \
#      {-what-went-wrong} {dmi parameters not configured} \
#      {-what-to-check} {addr len? data len? op len?} \
#      {-what-to-do} {dtmcs definition not correct? dtmcs.abits? dtmcs.idle?} \
#    ]
#    return -code $::TCL_ERROR -errorinfo [list {main} {rvdebug.cfg} {check_idcode}]  ;# proc file line
#  }

  echo -n "... found"
  echo -n " abits=[DTM::DTMCS::abits $dtmcs_0]"
  echo -n " idle=[DTM::DTMCS::idle $dtmcs_0]"
  echo -n " dmistat=[DTM::DTMCS::dmistat $dtmcs_0]"
  echo -n " version=[DTM::DTMCS::version $dtmcs_0]"
  echo -n " ([DTM::DTMCS::verstr $dtmcs_0])"
  echo ""
  #
  #--- preparing debug transport module to known good initial state


  # JTAG Clock Speed 500 KHz, Olimex ARM-USB-TINY-H (FT2232H), LoFive-R1
  set FE310_NDMRESET_PULSE_WIDTH  10    ;# 10ms, typ.
  set FE310_NDMRESET_DELAY        2500  ;# OKAY: 3000 2000 1500 1100 1050    NOT-OKAY: 1000 1025

  set NDMRESET_PULSE_WIDTH  [expr { $FE310_NDMRESET_PULSE_WIDTH }]  ;# modest assertion time to trigger reset logic
  set NDMRESET_DELAY        [expr { $FE310_NDMRESET_DELAY }]        ;# BEWARE: Non-DM system takes arbitrarily lone to stop in its tracks


  #------------------------------------------------------------------------------------------------------------
  #

  #----- STARTUP RACE CONDITION
  #
  echo -n "handling debug module ndmreset, to avoid startup race condition"

  # must first enable DM only (dmactive=1 (haltreq=0, ndmreset=0)), then halt hart (haltreq=1 (dmactive=1, ndmreset=0)),
  # lastly reset non-debug system (ndmreset=1->0 (dmactive=1, haltreq=1)), sequentially not simultaneously, and in that order.
  # when ndmreset delay is too short, write or read op from any other register than dmcontrol results in persistent DM busy (op=3) state.
  # in persistent DM busy state, DM is completely unreachable, thus power-cycle is the only way to regain control of the DM.
  #
  #                   haltreq resumereq hartreset ackhavereset hasel hartsel setresethaltreq clrresethaltreq ndmreset dmactive
  #                   ------- --------- --------- ------------ ----- ------- --------------- --------------- -------- --------
  DM::DMCONTROL::xfer 0       0         0         0            0     0x00000 0               0               0        1     ;# halt hart, first, before ...
  DM::DMCONTROL::xfer 1       0         0         0            0     0x00000 0               0               0        1     ;# halt hart, first, before ...
  DM::DMCONTROL::xfer 1       0         0         0            0     0x00000 0               0               1        1     ;# assert non-debug system reset
  sleep [expr { $NDMRESET_PULSE_WIDTH }]                                                                                  ;# non-debug system reset pulse width
  DM::DMCONTROL::xfer 1       0         0         0            0     0x00000 0               0               0        1     ;# deassert non-debug system reset
  sleep [expr { $NDMRESET_DELAY }]                                                                                        ;# non-debug system reset delay

  if { [DTM::DMI::is_busy] } {
    set ::rvdebugErrorCode $::RVDEBUG_INIT_ERR_STARTUP_RACE_CONDITION
    set ::rvdebugErrorOptions [dict create \
      {-what-went-wrong} {dmi access path unreachable} \
      {-what-to-check} {internal dmi latch-up?} \
      {-what-to-do} {MUST cycle power both, e.g., core 1V8 and debug 3V3} \
    ]
    return -code $::TCL_ERROR -errorinfo [list {main} {rvdebug.cfg} {handle_ndmreset}]  ;# proc file line
  }

  echo "... hart halted"
  #
  #----- STARTUP RACE CONDITION

  #----- DMI-safe access area: read DMI bus ONLY when selected hart is HALTED, or busy op=3 condition results
  #
  echo "entering DMI-safe access area"

  # the sifive implementation of the debug spec requires that the core be halted before
  # trying to execute abstract commands. when a debugger wants to halt a single hart it
  # selects it in hartsel and sets haltreq, then waits for allhalted to indicate that
  # the hart is halted before clearing haltreq to 0.
  # https://forums.sifive.com/t/a-problem-about-debug-module/746
  #

  # TIP (per Debug Spec, Section B.3):
  # leave dmcontrol.haltreq=1 to catch and re-halt a hart that gets reset while it is already halted


  #----- system examination
  #
  echo "examining system"

  set exam_result [examine_system]

  if {$exam_result ne $::RVDEBUG_EXAMINE_OK } {
    # just in case not set by examine_system before it bubbles up
    set no_rvEC [expr { ![info exists ::rvdebugErrorCode] }]
    set no_rvEO [expr { ![dict exists $::rvdebugErrorOptions {-what-went-wrong}] }]
    if { $no_rvEC || $no_rvEO } {
      set ::rvdebugErrorCode $::RVDEBUG_INIT_ERR_SYS_EXAMINE
      set ::rvdebugErrorOptions [dict create \
        {-what-went-wrong} {examine system missing explanations}           \
        {-what-to-check} {no rvdebugErrorCode or rvdebugErrorOptions set?} \
        {-what-to-do} {check sections of debug-util-examine.tcl}           \
      ]
    }
    return -code $::TCL_ERROR -errorinfo [list {rvdebug} {rvdebug-util-examine.tcl} {examine_system}]  ;# proc file line
  }
  #
  #----- system examination

#---------- demonstration area
#
#incl rvdebug-dm-abstractcs.tcl  ;# abstract program control and status
#incl rvdebug-dm-progbuf.tcl     ;# abstract program instruction buffer
#incl rvdebug-dm-data.tcl        ;# abstract program data buffer
#incl rvdebug-dm-command.tcl     ;# abstract program command execution

# DM::ABSTRACTCS::xfer  0                 ;# maxprogbufnum=abstractcs.progbufsize-1, maxdatabufnum=abstractcs.datacount
# DM::PROGBUF::xfer     0 0x5555aaaa 1  ;# progbufnum prognum [mode] (0=read, 1=write, n=0..15, dmi.abstractcs.progbufsize: 0=one-reg, 1=two-regs, ...)
# DM::DATA::xfer        0 0xaaaa5555 0  ;# databufnum databuf [mode] (0=read, 1=write, n=0..11, dmi.abstractcs.datacount: 0=unkn, 1=one-reg, 2=two-regs, ...)
# DM::COMMAND::xfer ...              ;# control cmdtype ... after write, wait for abstractcs.busy=0
# DM::ABSTRACTCS::xfer  7               ;# wait for busy=0, check cmderr bits (3) ... write 1 to clear them

  #                     cmdtype aarsize regno       transfer write aarpostincrement postexec
# DM::ABSTRACTCS::xfer  7        ;# cmderr=0b111 clear status bits
# DM::COMMAND::xfer     0x00    2       0x1001      1        0     0                0    ;# reg, 32-bit, misa, reg/mem, read, no-incr, no-exec
# DM::ABSTRACTCS::xfer  0        ;# cmderr=0 check status
# DM::DATA::xfer        0 0 0  ;# data0, 0x0, read

#  #                        ccccccccccccsssssfffdddddooooooo    ;# o=opcode, f=func, s=souce-reg, d=dest-reg, c=csr
#  #                        |----------||---||-||---||-----|
#  DM::PROGBUF::xfer    0 0b00110000000100000010010001110011 1  ;# progbuf0, (csrrs x0, MISA, s0), write
#  DM::PROGBUF::xfer    1 0b00000000000100000000000001110011 1  ;# progbuf1, (ebreak), write
#  DM::ABSTRACTCS::xfer 7        ;# cmderr=0b111 clear status bits
#  DM::COMMAND::xfer    0x00    2       0x0000      0        0     0                1    ;# reg, 32-bit, x, no-reg/mem, x, x, exec
#  DM::ABSTRACTCS::xfer 0        ;# cmderr=0 check status
#  #
#  DM::ABSTRACTCS::xfer 7        ;# cmderr=0b111 clear status bits
#  DM::COMMAND::xfer    0x00    2       0x1008      1        0     0                0    ;# reg, 32-bit, s0, reg/mem, read, no-incr, no-exec
#  DM::ABSTRACTCS::xfer 0        ;# cmderr=0 check status
#  #
#  DM::DATA::xfer       0 0 0  ;# data0, 0x0, read
#  #DM::DATA::xfer       1 0 0  ;# data1, 0x0, read
#  #DM::DATA::xfer       2 0 0  ;# data2, 0x0, read
#  #DM::DATA::xfer       3 0 0  ;# data3, 0x0, read
#
#---------- demonstration area

  echo "leaving DMI-safe access area"
  #
  #----- DMI-safe access area


  # Disable the DM when OpenOCD exits.
  # Should deinit_target() deassert dmactive? #200
  # https://github.com/riscv/riscv-openocd/commit/0e2ff30389f72d6a214d990f38383e978dd15f1f
  #
  # BUT BUT BUT ... see CRITICAL NOTE below
  #
  #                    haltreq resumereq hartreset ackhavereset hasel hartsel setresethaltreq clrresethaltreq ndmreset dmactive
  #                    ------- --------- --------- ------------ ----- ------- --------------- --------------- -------- --------
  #DM::DMCONTROL::xfer 0       1         0         0            0     0x00000 0               0               0        1     ;# ... to here, resume hart

  return $exam_result
}

#----- CRITICAL NOTE
# MUST leave jtag_init procedure in a halted state
#
#    WARNING: arp_init and arp_examine leave target in stuck unreachable state requiring power-cycle :(
#             because they do not know how to properly and safely use dmcontrol.ndmreset and/or halt a hart
#
# arp_init
#  if {[catch { jtag arp_init-reset } err]} { echo "arp_init: $err" }  ;# do reset_config then validate scan chain, throws "jtag_trst == 0" when assert trst
#  if {[catch { jtag arp_init } err]} { echo "arp_init: $err" }        ;# validate scan chain only, without trst or srst, throws "jtag_trst == 0" when assert trst
# reports
#   Info : JTAG tap: riscv.cpu tap/device found: 0x20000913 (mfg: 0x489 (SiFive Inc), part: 0x0000, ver: 0x2)
#   Info : datacount=1 progbufsize=16
#
# arp_examine [-allow-defer]
#  if {[catch { riscv.cpu.0 arp_examine } err]} { echo "arp_examine: $err" }               ;# unstable and buggy. throws "..." when ...
# reports
#   Info : datacount=1 progbufsize=16                     
#   Info : Disabling abstract command reads from CSRs.
#  Info : Examined RISC-V core; found 1 harts
#   Info :  hart 0: XLEN=32, misa=0x40101105
#----- CRITICAL NOTE
