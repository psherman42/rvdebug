defn rvdebug-dtm-dmi-xfer-one-big.tcl 2023-06-13
#========== rvdebug-dmi-xfer-one-big.tcl ==============
# 
#  2023-06-13  pds   initial cut


namespace eval DTM::DMI {
  proc xfer_one_big_ {addr data op} {
    variable INSTR
    #variable DATA_LEN  ;# must use alen_, dlen_, olen_, for now

    variable OP_NOP  ;# defined in parent

    variable alen_
    variable dlen_
    variable olen_
    variable idle_cycles_
    variable opstat_          ;# managed by implementations of method

    #----- DMI access primitive (arbitrary drscan length)
    #

    irscan riscv.cpu $::INSTR_CODE -endstate RUN/IDLE

    #
    # perform the request
    #

    # assemble numeric value from bit-fields ... MUST use braces of expr when numerics are involved
    set data 0
    set data [expr { $data | (($addr & ((1 << $alen_) - 1)) << (0 + $olen_ + $dlen_)) }]  ;# [33+dtm.dtmcs.abits:34]
    set data [expr { $data | (($data & ((1 << $dlen_) - 1)) << (0 + $olen_         )) }]  ;# [33:2]
    set data [expr { $data | (($op   & ((1 << $olen_) - 1)) << (0                  )) }]  ;# [1:0]

    # send numeric value, ignoring garbage result
    drscan riscv.cpu [expr { $alen_ + $dlen_ + $olen_ }] $data -endstate RUN/IDLE

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

    # assemble numeric value from bit-fields ... MUST use braces of expr when numerics are involved
    set data [expr { (($::OP_NOP & ((1 << $olen_) - 1)) << 0) }]  ;# [1:0]

    # receive numeric value, specifying only non-garbage (i.e., OP) field(s)
    set data [drscan riscv.cpu [expr { $alen_ + $dlen_ + $olen_ }] $data -endstate RUN/IDLE]

    #
    #---------- DMI access primitive

    # convert string of hex digits to numeric
    scan $data "%x" data

    # extract bit-fields from numeric value ... MUST use braces of expr when numerics are involved
    set addr_x [expr { ($data >> (0 + $olen_ + $dlen_)) & ((1 << $alen_) - 1) }]  ;# [33+dtm.dtmcs.abits:34]
    set data_x [expr { ($data >> (0 + $olen_         )) & ((1 << $dlen_) - 1) }]  ;# [33:2]
    set op_x   [expr { ($data >> (0                  )) & ((1 << $olen_) - 1) }]  ;# [1:0]

    set opstat_ $op_x  ;# make visible the current operation status

    # vanity output style, single-line
    echo -n "dtm:dmi (one big scan) ([format 0x%02x $addr] [format 0x%08x $data] $op):"
    echo -n " addr=[format 0x%02x $addr_x]"
    echo -n " data=[format 0x%08x $data_x]"
    echo -n " op=$op_x"
    echo    ""

    return $data_x
  }
}
