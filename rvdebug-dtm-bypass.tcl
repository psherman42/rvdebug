defn rvdebug-dtm-bypass.tcl 2023-06-13
#============= rvdebug-dtm-bypass.tcl =================
# 
#  2023-06-13  pds   initial cut


incl rvdebug-dtm.tcl  ;# the data transport module, to which bypass belongs

#
# BYPASS REGISTER
#

namespace eval DTM::BYPASS {
  proc xfer {} {
    variable INSTR_CODE
    variable DATA_LEN

    # only one TAP allowed not BYPASSed.
    # required before any active command

    DTM::xfer $INSTR_CODE $DATA_LEN 0  ;# junk data, ignore result
  }
}
