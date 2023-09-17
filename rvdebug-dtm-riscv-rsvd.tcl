defn rvdebug-dtm-riscv-rsvd.tcl 2023-06-13
#=========== rvdebug-dtm-riscv-rsvd.tcl ===============
# 
#  2023-06-18  pds   initial cut


incl rvdebug-dtm.tcl  ;# the data transport module, to which bypass 1fh belongs

#
# RISCV RSVD REGISTERS
#

namespace eval DTM::RISCV_RSVD {
  proc xfer {} {
    variable RISCV_RSVD_12H_INSTR_CODE ; variable RISCV_RSVD_12H_DATA_LEN
    variable RISCV_RSVD_13H_INSTR_CODE ; variable RISCV_RSVD_13H_DATA_LEN
    variable RISCV_RSVD_14H_INSTR_CODE ; variable RISCV_RSVD_14H_DATA_LEN
    variable RISCV_RSVD_15H_INSTR_CODE ; variable RISCV_RSVD_15H_DATA_LEN
    variable RISCV_RSVD_16H_INSTR_CODE ; variable RISCV_RSVD_16H_DATA_LEN
    variable RISCV_RSVD_17H_INSTR_CODE ; variable RISCV_RSVD_17H_DATA_LEN

    # silly things, for now

    DTM::xfer $RISCV_RSVD_12H_INSTR_CODE $RISCV_RSVD_12H_DATA_LEN 0  ;# junk data, ignore result

    DTM::xfer $RISCV_RSVD_13H_INSTR_CODE $RISCV_RSVD_13H_DATA_LEN 0  ;# junk data, ignore result

    DTM::xfer $RISCV_RSVD_14H_INSTR_CODE $RISCV_RSVD_14H_DATA_LEN 0  ;# junk data, ignore result

    DTM::xfer $RISCV_RSVD_15H_INSTR_CODE $RISCV_RSVD_15H_DATA_LEN 0  ;# junk data, ignore result

    DTM::xfer $RISCV_RSVD_16H_INSTR_CODE $RISCV_RSVD_16H_DATA_LEN 0  ;# junk data, ignore result

    DTM::xfer $RISCV_RSVD_17H_INSTR_CODE $RISCV_RSVD_17H_DATA_LEN 0  ;# junk data, ignore result
  }
}
