defn rvdebug-dtm-bypass-1fh.tcl 2023-06-13
#============ rvdebug-dtm-bypass1fh.tcl ===============
# 
#  2023-06-13  pds   initial cut


incl rvdebug-dtm.tcl  ;# the data transport module, to which bypass 1fh belongs

#
# BYPASS 1FH REGISTER
#
#   somewhat similar to DTM::BYPASS in many respects, reqd here nevertheless
#

namespace eval DTM::BYPASS_1FH {
  proc xfer {} {
    variable INSTR_CODE
    variable DATA_LEN

    # only one TAP allowed not BYPASSed.
    # required before any active command

    DTM::xfer $INSTR_CODE $DATA_LEN 0  ;# junk data, ignore result
  }
}
