

source rvdebug-handler.tcl        ;# messages and how to handle them
source rvdebug-dtm.tcl            ;# the debug transport module, and everything beneath
source rvdebug-utils.tcl          ;# examine, mem, and other high-level stuff
source rvdebug-dmi-dmcontrol.tcl  ;# REDUNDANT?
source rvdebug-dmi-abstract.tcl   ;# REDUNDANT? optional, for demonstration area

proc rvdebug { } {  ;# top level
  set idcode_0 [dtm_idcode]    ;# attempt to read chip id

  # go no further if nothing there
  # NOTE: (return -errorcode <num>) get OVERRIDEN by OpenOCD and turned into -4, use ::rvdebugErrorCode
  # NOTE: (return -options <dict>) get DESTROYED by OpenOCD, use ::rvdebugErrorOptions
  if 0 {
  } elseif [dtm_idcode_is_stuck_low $idcode_0] {
    set ::rvdebugErrorCode $::RVDEBUG_INIT_ERR_ID_STUCK_LOW
    set ::rvdebugErrorOptions [dict create \
      {-what-went-wrong} {cannot read chip id} \
      {-what-to-check} {TDO stuck low?} \
      {-what-to-do} {power? wiring? target latched up?} \
    ]
    adapter deassert srst
    return -code $::TCL_ERROR -errorinfo [list {main} {rvdebug.cfg} {check_idcode}]  ;# proc file line
  } elseif [dtm_idcode_is_stuck_high $idcode_0] {
    set ::rvdebugErrorCode $::RVDEBUG_INIT_ERR_ID_STUCK_HIGH
    set ::rvdebugErrorOptions [dict create \
      {-what-went-wrong} {cannot read chip id} \
      {-what-to-check} {TDO stuck high?} \
      {-what-to-do} {power? open-drain need pull-up? target latched up?} \
    ]
    adapter deassert srst
    return -code $::TCL_ERROR -errorinfo [list {main} {rvdebug.cfg} {check_idcode}]  ;# proc file line
  } elseif {[string length [dtm_idcode_mfrid_str $idcode_0]] eq 0} {
    set ::rvdebugErrorCode $::RVDEBUG_INIT_ERR_ID_UNKNOWN
    set ::rvdebugErrorOptions [dict create \
      {-what-went-wrong} {unexpected device} \
      {-what-to-check} {mfrid name in database?} \
      {-what-to-do} {update idcode mfrid JEDEC tables in rvdebug project} \
    ]
    adapter deassert srst
    return -code $::TCL_ERROR -errorinfo [list {main} {rvdebug.cfg} {check_idcode}]  ;# proc file line
  } else {
    set ::rvdebugErrorCode $::RVDEBUG_INIT_WARN_ID_PROBLEM
    set ::rvdebugErrorOptions [dict create \
      {-what-went-wrong} [concat {unknown chip id} [dtm_idcode_str $idcode_0] ]       \
      {-what-to-check} [concat \"[dtm_idcode_mfrid_str $idcode_0]\" {looks wrong} ]     \
      {-what-to-do} {power? wiring? TCK too fast or slow?} \
    ]
    return -code $::TCL_ERROR -errorinfo [list {main} {rvdebug.cfg} {check_idcode}]  ;# proc file line
  }
}
