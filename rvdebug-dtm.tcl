defn rvdebug-dtm.tcl 2023-06-13
#================ rvdebug-dtm.tcl =====================
# 
#  2023-06-13  pds   initial cut

#
# DEBUG TRANSPORT MODULE (DTM)
#
#    all registers must implement pairs, one or more, of
#    an INSTR_CODE for the IR-SCAN transaction,
#    a DATA_LEN for the DR-SCAN transaction(s), and
#    an "xfer" procedure that knows how to use them.
#

namespace eval DTM {
  # DTM access primitives:
  #   sends instr with n-bits of data to the TAP,
  #   receives n-bits of data from it,
  #   leaves the TAP back to its safe idle state
  #
  proc xfer {instr nbits data} {
            irscan riscv.cpu $instr -endstate IRPAUSE
    return [drscan riscv.cpu $nbits $data]
  }

  proc xfer_start {instr nbits} {}  ;# must be followed by xfer_stop
  proc xfer_data {data} {}  ;# must be between xfer_start and xfer_stop
  proc xfer_stop {} {}  ;# must be preceded by xfer_start
}

# required, per JTAG Specification
namespace eval DTM::BYPASS     { variable INSTR_CODE 0x00 ; variable DATA_LEN  1 }  ;#  always 1-bit
namespace eval DTM::IDCODE     { variable INSTR_CODE 0x01 ; variable DATA_LEN 32 }  ;#  always 32-bits
namespace eval DTM::BYPASS_1FH { variable INSTR_CODE 0x1F ; variable DATA_LEN  1 }  ;#  always 1-bit

# implemented, per Debug Specification
namespace eval DTM::DTMCS      { variable INSTR_CODE 0x10 ; variable DATA_LEN 32 }  ;#  always 32-bit
namespace eval DTM::DMI        { variable INSTR_CODE 0x11 ; variable DATA_LEN -1 }  ;#  alen=(dtmcs.abits), dlen=32-bit, olen=2

# reserved, not yet implemented
namespace eval DTM::RISCV_RSVD { 
  variable RISCV_RSVD_12H_INSTR_CODE 0x12 ; variable RISCV_RSVD_12H_DATA_LEN 16     ;#  16-bit?
  variable RISCV_RSVD_13H_INSTR_CODE 0x13 ; variable RISCV_RSVD_13H_DATA_LEN 16     ;#  16-bit?
  variable RISCV_RSVD_14H_INSTR_CODE 0x14 ; variable RISCV_RSVD_14H_DATA_LEN 16     ;#  16-bit?
  variable RISCV_RSVD_15H_INSTR_CODE 0x15 ; variable RISCV_RSVD_15H_DATA_LEN 16     ;#  16-bit?
  variable RISCV_RSVD_16H_INSTR_CODE 0x16 ; variable RISCV_RSVD_16H_DATA_LEN 16     ;#  16-bit?
  variable RISCV_RSVD_17H_INSTR_CODE 0x17 ; variable RISCV_RSVD_17H_DATA_LEN 16     ;#  16-bit?
}
