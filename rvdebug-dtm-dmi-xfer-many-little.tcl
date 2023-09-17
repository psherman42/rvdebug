defn rvdebug-dtm-dmi-xfer-many-little.tcl 2023-06-13
#======== rvdebug-dmi-xfer-many-little.tcl ============
# 
#  2023-06-13  pds   initial cut


namespace eval DTM::DMI {
  proc xfer_many_little_ {addr data op} {
    variable INSTR_CODE
    #variable DATA_LEN  ;# must use alen_, dlen_, olen_, for now

    variable OP_NOP  ;# defined in parent

    variable alen_
    variable dlen_
    variable olen_
    variable idle_cycles_
    variable opstat_          ;# managed by implementations of method

    #---------- DMI access primitive (each drscan <= 32 bits)
    # no need to assemble numeric values from bit-fields in this method of dmi transfer
    #

    irscan riscv.cpu $INSTR_CODE -endstate RUN/IDLE

    #
    # perform the request
    #

    # send numeric value, ignoring garbage result
    drscan riscv.cpu [expr { $olen_ }] $op   -endstate DRPAUSE
    drscan riscv.cpu [expr { $dlen_ }] $data -endstate DRPAUSE
    drscan riscv.cpu [expr { $alen_ }] $addr -endstate RUN/IDLE

    #
    # digest the request -- dwell with cycles of TCK in Run/Test-Idle state
    #
    # dtmcs.idle hasn't been used to control idle/run_test which may result in get wrong values #493
    # https://github.com/riscv/riscv-openocd/issues/493
    # busy: An operation was attempted while a DMI request is still in progress. The data scanned
    # into dtm.dmi in this access will be ignored. This status is sticky and can be cleared by
    # writing dtm.dtmcs.dmireset in dtm.dtmcs. If a debugger sees this status, it needs to give the
    # target more TCK edges between Update-DR and Capture-DR. The simplest way to do that is to add
    # extra transitions in Run-Test/Idle.
    # https://github.com/riscv-software-src/riscv-isa-sim/blob/master/riscv/debug_defines.h
    # jtag pathmove RUN/IDLE  RUN/IDLE RUN/IDLE RUN/IDLE RUN/IDLE RUN/IDLE ;# eight args, max, for pathmove
    # runtest 50  ;# doesnt do anything
    #

    for {set i 0}  {$i < $idle_cycles_} {incr i} {  ;# typ. 5 = dtm.dtmcs.idle cycles of TCK
      jtag pathmove RUN/IDLE RUN/IDLE
    }

    #
    # fetch the result
    #

    # receive numeric value, specifying only non-garbage (i.e., OP) field(s)
    set op_x   [drscan riscv.cpu [expr { $olen_ }] $OP_NOP -endstate DRPAUSE]
    set data_x [drscan riscv.cpu [expr { $dlen_ }] 0       -endstate DRPAUSE]
    set addr_x [drscan riscv.cpu [expr { $alen_ }] 0       -endstate RUN/IDLE]

    #
    #---------- DMI access primitive

    set opstat_ $op_x  ;# make visible the current operation status

    # convert string of hex digits to numeric
    scan $op_x "%x" op_x
    scan $data_x "%x" data_x
    scan $addr_x "%x" addr_x

    # vanity output style, single-line
#    echo -n "dtm:dmi (many little scans) ([format 0x%02x $addr] [format 0x%08x $data] $op):"
#    echo -n " addr=[format 0x%02x $addr_x]"
#    echo -n " data=[format 0x%08x $data_x]"
#    echo -n " op=$op_x"
#    echo    ""

    return $data_x
  }
}
