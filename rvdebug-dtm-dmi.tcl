defn rvdebug-dtm-dmi.tcl 2023-06-13
#=============== rvdebug-dtm-dmi.tcl ==================
# 
#  2023-06-13  pds   initial cut


incl rvdebug-dtm-dmi-xfer-many-little.tcl  ;# one implementation for how to access dmi bus
incl rvdebug-dtm-dmi-xfer-one-big.tcl      ;# another implementation for how to access dmi bus

#
# DMI REGISTER (FOR ACCESS TO DM)
#
#    Update-DR value to access DM over DMI
#    data returned from DM result of previous op
#
# Bit Twiddling TIPS:
#    put right-most n bits of X at bit position p:    (($X & ((1 << n) - 1)) << p
#    take right-most n bits of X from bit position p: ($X >> p) & ((1 << n) - 1)
#
# OpenOCD NOTE:
#    drscan ... n ... returns string of (n/4)+(n%4) hex digits for a specified n number of bits
#    drscan ... 2 ... returns string of one hex digit (i.e., 8-bits)
#    drscan ... 7 ... returns string of one hex digit (i.e., 8-bits)
#    drscan ... 32 ... returns string of eight hex digits (i.e., 32-bits)
#    drscan ... 41 ... returns string of twelve hex digits (i.e., 48-bits)

# dmi.address        [dtmcs.abits+33:34] addr<dtmcs.abits:0>
# dmi.data           [33:2] data<31:0>
# dmi.op             [1:0]=op (0=nop/op-success/rsvd, 1=rd, 2=wr/prev-op-failed, 3=rsvd/dmi-req-in-progress) ... wr/rd

namespace eval DTM::DMI {
  # DM REGISTER OPERATIONS (OP OF DMI)
  variable OP_NOP     0
  variable OP_READ    1
  variable OP_WRITE   2
  variable OP_RSVD    3

  proc is_configured {} {  ;# make sure len set (in some way) and idle cycles defined
    variable DATA_LEN
    variable alen_
    variable dlen_
    variable olen_
    variable idle_cycles_
    set ado_good [expr { ($alen_ != -1) && ($dlen_ != -1) && ($olen_ != -1) }]
    set len_good [expr { ($DATA_LEN != -1) || $ado_good }]
    return [expr { $len_good && ($idle_cycles_ != -1) }]
  }

  proc validate_ {value min max} {  ;# sanity clause, goldilocks test
    variable x
    if { $value < $min } { 
      set x $min
    } elseif { $value > $max } {
      set x $max
    } else {
      set x $value
    }
    return $x
  }

  #==================================
  # total length of a DMI transaction
  # (i.e., total number of bits to SCAN-DR)
  #

  #----- length of address portion of a DMI transaction
  #

  variable alen_  -1  ;# used by implementations of method (no default)

  proc set_addr_len {alen} {
    variable alen_   ;# managed by business logic, sourced from dtmcs.idle
    set alen_ [validate_ $alen 1 10]  ;# insure 1 <= num-addr-bits <= 10
  }

  #----- length of data portion of a DMI transaction
  #

  variable dlen_  -1  ;# used by implementations of method (no default)

  proc set_data_len {dlen} {
    variable dlen_   ;# managed by business logic, sourced from dtmcs.idle
    set dlen_ [validate_ $dlen 1 64]  ;# insure 1 <= num-data-bits <= 64
  }

  #----- length of operation code portion of a DMI transaction
  #

  variable olen_  -1  ;# used by implementations of method (no default)

  proc set_op_len {olen} {
    variable olen_   ;# managed by business logic, sourced from dtmcs.idle
    set olen_ [validate_ $olen 1 8]   ;# insure 1 <= num-op-bits <= 8
  }

  #
  # total length of a DMI transaction
  #==================================

  #
  # digestion time between DMI request and response transactions
  # (i.e., between pairs of SCAN-IR / SCAN-DR transactions)
  #

  variable idle_cycles_  -1  ;# used by implementations of method (no default)

  proc set_idle_cycles {n} {
    variable idle_cycles_   ;# managed by business logic, sourced from dtmcs.idle
    set idle_cycles_ [validate_ $n 1 100]  ;# insure 1 <= num-idle-cycles <= 100
  }

  #
  # resulting status of a DMI response transaction
  #

  variable opstat_  ;# managed by implementations of xfer_

  proc is_busy {} {  ;# need to power-cycle entire target in this case (race condition!)
    variable opstat_
    return [expr { $opstat_ == 3 }]
  }

  proc op_fail {} {  ;# need to pulse dtmcs.dmireset and re-send dmi in this case
    variable opstat_
    return [expr { $opstat_ == 2 }]
  }

  proc xfer_ {addr data op {method "DMI_MANY_LITTLE"}} {  ;# default no drscan longer than 32-bits
    if {![is_configured]} { return 0 }  ;# should really throw exception here

    # convert string to numeric ... DO NOT use braces of expr when strings are involved
    set addr [expr $addr]
    set data [expr $data]
    set op [expr $op]

#set method DMI_ONE_BIG

    set data_x 0

    switch -- $method {
      DMI_MANY_LITTLE {
        # openocd advises no drscan longer than 32 bits, so pause and do it piece-meal
        set data_x [ xfer_many_little_ $addr $data $op ]
      }
      DMI_ONE_BIG {
        set data_x [ xfer_one_big $addr $data $op ]
      }
      default {
        # should never see this (do NOT put comment outside of switch-case execution braces)
        echo -n "dmi.xfer: dont know what is a $method"
        set data_x [ xfer_many_little_ $addr $data $op ]  ;# be safe, continue gracefully
      }
    }

    return $data_x
  }

  proc write {addr data} {
    variable OP_WRITE
    xfer_ $addr $data $OP_WRITE  ;# returns nothing useful, really
  }

  proc read {addr data}  {
    variable OP_READ
    return [xfer_ $addr $data $OP_READ]
  }
}
