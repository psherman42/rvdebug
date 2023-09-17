defn rvdebug-handler.tcl 2023-06-13
#============== rvdebug-handler.tcl ===================
# 
#  2023-06-13  pds   initial cut

#
# DEFINE EXCEPTION GROUPS AND THEIR BASE LEVELS
#
# 0=top-group, 100=2nd-group, 200=3rd-group, ...
#
set ::EXCEP_GROUP_RVDEBUG         4 ; set ::EXCEP_LEVEL_RVDEBUG         [expr { 200 +  0 }]
                                    ; set ::EXCEP_LEVEL_RVDEBUG_EXAMINE [expr { 200 + 10 }]  ;# 1st sub-group
set ::EXCEP_GROUP_OCD_JTAG        3 ; set ::EXCEP_LEVEL_OCD_JTAG        [expr { 100 +  0 }]  ;# defd by ocd
set ::EXCEP_GROUP_OCD             2 ; set ::EXCEP_LEVEL_OCD             [expr { 0 }]
set ::EXCEP_GROUP_TCL             1 ; set ::EXCEP_LEVEL_TCL             [expr { 0 }]
set ::EXCEP_GROUP_NONE            0 ; set ::EXCEP_LEVEL_NONE            [expr { 0 }]

#
# SPECIFY INDIVIDTUAL EXCEPTIONS WITHIN EACH GROUP
#
# from rvdebug.tcl

set ::RVDEBUG_OK_OCD_JTAG_INIT                [expr {   0                          }] ;# jtag_init comes here when OK
set ::RVDEBUG_INIT_OK                         [expr {   0 - $::EXCEP_LEVEL_RVDEBUG }]
set ::RVDEBUG_INIT_ERR_ID_STUCK_HIGH          [expr {  -1 - $::EXCEP_LEVEL_RVDEBUG }]
set ::RVDEBUG_INIT_ERR_ID_STUCK_LOW           [expr {  -2 - $::EXCEP_LEVEL_RVDEBUG }]
set ::RVDEBUG_INIT_ERR_ID_UNKNOWN             [expr {  -3 - $::EXCEP_LEVEL_RVDEBUG }]
set ::RVDEBUG_INIT_ERR_ID_NONCONFORM          [expr {  -4 - $::EXCEP_LEVEL_RVDEBUG }]
set ::RVDEBUG_INIT_ERR_DMI_NO_CONFIG          [expr {  -5 - $::EXCEP_LEVEL_RVDEBUG }]
set ::RVDEBUG_INIT_ERR_STARTUP_RACE_CONDITION [expr {  -6 - $::EXCEP_LEVEL_RVDEBUG }]
set ::RVDEBUG_INIT_ERR_SYS_EXAMINE            [expr {  -7 - $::EXCEP_LEVEL_RVDEBUG }]

# from rvdebug-utils-examine.tcl

set ::RVDEBUG_EXAMINE_OK                      [expr {   0 - $::EXCEP_LEVEL_RVDEBUG_EXAMINE }]
set ::RVDEBUG_EXAMINE_ERR_NO_HARTS            [expr {  -1 - $::EXCEP_LEVEL_RVDEBUG_EXAMINE }]
set ::RVDEBUG_EXAMINE_ERR_NO_WORD_SIZE        [expr {  -2 - $::EXCEP_LEVEL_RVDEBUG_EXAMINE }]
set ::RVDEBUG_EXAMINE_ERR_NO_CONFIG           [expr {  -3 - $::EXCEP_LEVEL_RVDEBUG_EXAMINE }]
set ::RVDEBUG_EXAMINE_ERR_NO_ISA              [expr {  -4 - $::EXCEP_LEVEL_RVDEBUG_EXAMINE }]

# defined in OpenOCD/src/jtag/jtag.h (lines 590-608)
set ::OCD_ERROR_JTAG_INIT_FAILED              [expr {   0 - $::EXCEP_LEVEL_OCD_JTAG }]
set ::OCD_ERROR_JTAG_INVALID_INTERFACE        [expr {  -1 - $::EXCEP_LEVEL_OCD_JTAG }]
set ::OCD_ERROR_JTAG_NOT_IMPLEMENTED          [expr {  -2 - $::EXCEP_LEVEL_OCD_JTAG }]
set ::OCD_ERROR_JTAG_TRST_ASSERTED            [expr {  -3 - $::EXCEP_LEVEL_OCD_JTAG }]
set ::OCD_ERROR_JTAG_QUEUE_FAILED             [expr {  -4 - $::EXCEP_LEVEL_OCD_JTAG }]
set ::OCD_ERROR_JTAG_NOT_STABLE_STATE         [expr {  -5 - $::EXCEP_LEVEL_OCD_JTAG }]
set ::OCD_ERROR_JTAG_DEVICE_ERROR             [expr {  -7 - $::EXCEP_LEVEL_OCD_JTAG }]
set ::OCD_ERROR_JTAG_STATE_INVALID            [expr {  -8 - $::EXCEP_LEVEL_OCD_JTAG }]
set ::OCD_ERROR_JTAG_TRANSITION_INVALID       [expr {  -9 - $::EXCEP_LEVEL_OCD_JTAG }]
set ::OCD_ERROR_JTAG_INIT_SOFT_FAIL           [expr { -10 - $::EXCEP_LEVEL_OCD_JTAG }]

# defined in OpenOCD/src/helper/log.h (lines 140,141)
set ::OCD_ERROR_OK                            [expr {   0 - $::EXCEP_LEVEL_OCD_JTAG }]
set ::OCD_ERROR_UNKN                          [expr {  -1 - $::EXCEP_LEVEL_OCD_JTAG }]
set ::OCD_ERROR_NO_CONFIG_FILE                [expr {  -2 - $::EXCEP_LEVEL_OCD_JTAG }]
set ::OCD_ERROR_BUF_TOO_SMALL                 [expr {  -3 - $::EXCEP_LEVEL_OCD_JTAG }]
set ::OCD_ERROR_FAIL                          [expr {  -4 - $::EXCEP_LEVEL_OCD_JTAG }]
set ::OCD_ERROR_WAIT                          [expr {  -5 - $::EXCEP_LEVEL_OCD_JTAG }]

# defined in OpenOCD/src/....h (lines tbd)
set ::TCL_OK                                  [expr {   0 - $::EXCEP_LEVEL_TCL }]
set ::TCL_ERROR                               [expr {  -1 - $::EXCEP_LEVEL_TCL }]
set ::TCL_RETURN                              [expr {  -2 - $::EXCEP_LEVEL_TCL }]
set ::TCL_BREAK                               [expr {  -3 - $::EXCEP_LEVEL_TCL }]
set ::TCL_CONTINUE                            [expr {  -4 - $::EXCEP_LEVEL_TCL }]

proc rvdebug_handler_init {} {  ;# initialize error log dict
  set ::rvdebugErrorCode $::RVDEBUG_INIT_OK
  set ::rvdebugErrorOptions [dict create \
    {-what-went-wrong} {} \
    {-what-to-check} {} \
    {-what-to-do} {} \
  ]
}

proc rvdebug_handler_is_fail {retval ocdResult ocdErrorOptions} {
  variable is_fail 1  ;# 0=PASS, 1=FAIL ... bad until proven good

  #
  # determine code and the group it belongs to (fuzzy logic)
  #

  set ocdErrorCode [dict get $ocdErrorOptions -code]

  # should really do this bit-wise
  if 0 {
  } elseif { $ocdErrorCode le $::EXCEP_LEVEL_RVDEBUG }         { set ocdErrorGroup $::EXCEP_GROUP_RVDEBUG
  } elseif { $ocdErrorCode le $::EXCEP_LEVEL_RVDEBUG_EXAMINE } { set ocdErrorGroup $::EXCEP_GROUP_RVDEBUG_EXAMINE
  } elseif { $ocdErrorCode le $::EXCEP_LEVEL_OCD_JTAG }        { set ocdErrorGroup $::EXCEP_GROUP_OCD_JTAG
  } elseif { $ocdErrorCode le $::EXCEP_LEVEL_OCD }             { set ocdErrorGroup $::EXCEP_GROUP_OCD
  } elseif { $ocdErrorCode le $::EXCEP_LEVEL_TCL }             { set ocdErrorGroup $::EXCEP_GROUP_TCL
  } else                                                       { set ocdErrorGroup $::EXCEP_GROUP_NONE
  }

  if {$ocdErrorCode ne $retval} {  ;# should never see this
    echo -n "possible mis-interpretation of exceptions"
    echo -n "because retval=$retval not same as ocdErrorCode=$ocdErrorCode"
    echo -n "please update fuzzy logic of rvdebug_handler"
    echo ""
  }

  #
  # apply the fuzzy business logic
  #

  if 0 {
  } elseif { $ocdErrorGroup eq $::EXCEP_GROUP_NONE } {
      set is_fail 0  ;# pass
  } elseif { $ocdErrorGroup eq $::EXCEP_GROUP_TCL } {
      if 0 {
      } elseif { $ocdErrorCode eq $::TCL_ERROR }    { echo "TCL ERROR"
      } elseif { $ocdErrorCode eq $::TCL_RETURN }   { echo "TCL RETURN"
      } elseif { $ocdErrorCode eq $::TCL_BREAK }    { echo "TCL BREAK"
      } elseif { $ocdErrorCode eq $::TCL_CONTINUE } { echo "TCL CONTINUE"
      } elseif { $ocdErrorCode eq $::TCL_OK }       { echo "TCL OK"
      } else {
          echo -n "unhandled openocd tcl errorOptions -code $ocdErrorCode"
          echo -n "please update EXCEP_GROUP_TCL part of rvdebug_handler"
          echo ""
      }
  } elseif { $ocdErrorGroup eq $::EXCEP_GROUP_OCD } {
      if 0 {
      } elseif { $ocdErrorCode eq $::OCD_ERROR_NO_CONFIG_FILE } { echo "no config file(s) specified"
      } elseif { $ocdErrorCode eq $::OCD_ERROR_BUF_TOO_SMALL }  { echo "buf too small"
      } elseif { $ocdErrorCode eq $::OCD_ERROR_WAIT }           { echo "general wait"
      } elseif { $ocdErrorCode eq $::OCD_ERROR_UNKN }           { echo "unknown error"
      } elseif { $ocdErrorCode eq $::OCD_ERROR_FAIL }           { echo "general error"
      } elseif { $ocdErrorCode eq $::OCD_ERROR_OK }             { set is_fail 0  ;# pass
      } else {
          echo -n "unhandled openocd general errorOptions -code $ocdErrorCode"
          echo -n "please update EXCEP_GROUP_OCD part of rvdebug_handler"
          echo ""
      }
  } elseif { $ocdErrorGroup eq $::EXCEP_GROUP_OCD_JTAG } {
     if 0 {
      } elseif { $ocdErrorCode eq $::OCD_ERROR_JTAG_INIT_FAILED }        { echo "ftdi failure, is USB unplugged? device_desc OK? pid_vid correct?"
      } elseif { $ocdErrorCode eq $::OCD_ERROR_JTAG_INVALID_INTERFACE }  { echo "bad jtag interface"
      } elseif { $ocdErrorCode eq $::OCD_ERROR_JTAG_NOT_IMPLEMENTED }    { echo "jtag not implemented"
      } elseif { $ocdErrorCode eq $::OCD_ERROR_JTAG_TRST_ASSERTED }      { echo "jtag trst asserted"
      } elseif { $ocdErrorCode eq $::OCD_ERROR_JTAG_QUEUE_FAILED }       { echo "jtag queue failed"
      } elseif { $ocdErrorCode eq $::OCD_ERROR_JTAG_NOT_STABLE_STATE }   { echo "unstable jtag state"
      } elseif { $ocdErrorCode eq $::OCD_ERROR_JTAG_DEVICE_ERROR }       { echo "device error"
      } elseif { $ocdErrorCode eq $::OCD_ERROR_JTAG_STATE_INVALID }      { echo "bad jtag state"
      } elseif { $ocdErrorCode eq $::OCD_ERROR_JTAG_TRANSITION_INVALID } { echo "bad jtag transition"
      } elseif { $ocdErrorCode eq $::OCD_ERROR_JTAG_INIT_SOFT_FAIL }     { echo "jtag init soft fail"
      } else {
            echo "unhandled openocd jtag errorOptions -code $ocdErrorCode"
            echo "please update EXCEP_GROUP_OCD_JTAG part of rvdebug_handler"
            echo ""
      } 
  } elseif { $ocdErrorGroup eq $::EXCEP_GROUP_RVDEBUG  } {
     if 0 {
      } elseif { $ocdErrorCode eq $::RVDEBUG_EXAMINE_OK }         { set is_fail 0  ;# pass
      } elseif { $ocdErrorCode eq $::RVDEBUG_OK_OCD_JTAG_INIT }   { set is_fail 0  ;# pass, from ocd jtag_init
      } elseif { $ocdErrorCode eq $::OCD_ERROR_JTAG_INIT_FAILED } { echo "ftdi failure, is USB unplugged? device_desc OK? pid_vid correct?"
      } else {
            echo -n "[dict get $::rvdebugErrorOptions {-what-went-wrong}]"
            if [dict exists $::rvdebugErrorOptions {-what-to-check}] {
               echo -n " because [dict get $::rvdebugErrorOptions {-what-to-check}]"
            }
            if [dict exists $::rvdebugErrorOptions {-what-to-do}] {
               echo -n " maybe [dict get $::rvdebugErrorOptions {-what-to-do}]"
            }
            echo ""
      } 
  } else {
      echo -n "unknown openocd exception please update default part of rvdebug_handler"
      echo -n "this info might help:"
      echo -n " rc=$retval"
      echo -n ", catch.rslt=$ocdResult"
      echo -n ", catch.rslt=$ocdErrorOptions"
      set code [dict get $ocdErrorOptions -code]
      set level [dict get $ocdErrorOptions -level]
      echo -n ", ocdErrorOptions.code=$code"
      echo -n ", ocdErrorOptions.level=$level"
      if [expr { ($code == 1) && ($level == 1) }] {
        echo -n ", ocdErrorOptions.errorCode=[dict get $ocdErrorOptions -errorcode]"
        echo -n ", ocdErrorOptions.errorInfo=[dict get $ocdErrorOptions -errorinfo]"
      }
      echo ""
  }
  return $is_fail
}
