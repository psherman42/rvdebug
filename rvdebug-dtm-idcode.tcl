defn rvdebug-dtm-idcode.tcl 2023-06-13
#=========== rvdebug-dtm-idcode.tcl ===================
# 
#  2023-06-13  pds   initial cut


incl rvdebug-dtm.tcl  ;# the data transport module, to which idcode belongs

incl jedec-jep106.tcl   ;# for the chip id and their names

#
# IDCODE REGISTER
#
#
# idcode.ver         [31:28]=release of this part
# idcode.partnum     [27:12]=designers part number of this part
# idcode.jep106bank  [11:8]=bank num of JEDEC JEP106 (count mod 16 of num contin chars (0x7F))
# idcode.jep106line  [7:1]=line num of JEDEC JEP106
# idcode.one         [0]=1 (always)
#
# EXAMPLE:
#    set idcode_0 [dtm_idcode]
#    echo "idcode=[dtm_idcode_val $idcode_0]"
#    echo "idcode.version=[dtm_idcode_version $idcode_0]"
#    echo "idcode.partnum=[dtm_idcode_partnum $idcode_0]"
#    echo "idcode.mfrid=[dtm_idcode_partnum $idcode_0]"
#    echo "idcode.mfrid_str=[dtm_idcode_mfridstr $idcode_0]"
#    echo "idcode_str=[dtm_idcode_str $idcode_0]"

namespace eval DTM::IDCODE {
  proc xfer {} {
    variable INSTR_CODE
    variable DATA_LEN

    set data [DTM::xfer $INSTR_CODE $DATA_LEN 0]  ;# junk data

    # convert string of hex digits to numeric
    scan $data "%x" data

    # extract bit-fields from numeric value ... MUST use braces of expr when numerics are involved
    set version_x [expr { ($data >> 28) & ((1 << 4) - 1) }]    ;# [31:28]
    set partnum_x [expr { ($data >> 12) & ((1 << 16) - 1) }]   ;# [27:12]
    set jep106bank_x [expr { ($data >> 8) & ((1 << 4) - 1) }]  ;# [11:8]
    set jep106line_x [expr { ($data >> 1) & ((1 << 7) - 1) }]  ;# [7:1]

    # vanity output style, single-line
#    echo -n "dtm:idcode: [format 0x%08x $data] ("
#    echo -n "ver=$version_x"
#    echo -n ", partnum=$partnum_x"
#    echo -n ", mfrid=[format 0x%x [expr { (($jep106bank_x % 16) << 7) | $jep106line_x }]] ("
#    echo -n     "jep106bank=[expr { $jep106bank_x + 1 }]"  ;# JEDEC JEP bank starts at 1
#    echo -n   ", jep106line=$jep106line_x"
#    echo -n   ")"
#    echo    ")"

    # returns dictionary of type idcode_t
    return [dict create \
      idcode         $data\
      version        $version_x\
      partnum        $partnum_x\
      jep106bank     $jep106bank_x\
      jep106line     $jep106line_x\
    ]
  }

  proc version {idcode_t} { return [dict get $idcode_t version] }
  proc partnum {idcode_t} { return [dict get $idcode_t partnum] }

  proc mfrid {idcode_t} {
    # designer/mfr id code per Section 6.1.3 of Debug Specification and per JEDEC JEP106
    return [format 0x%x [expr { (([dict get $idcode_t jep106bank] % 16) << 7) | [dict get $idcode_t jep106line] }]]
  }

  proc idcode_val {idcode_t} { return [dict get $idcode_t idcode] }
  proc idcode_str {idcode_t} { return [format 0x%08x [dict get $idcode_t idcode]] }

  proc mfrid_str {idcode_t} {
    set banknum [dict get $idcode_t jep106bank]
    set linenum [expr { [dict get $idcode_t jep106line] }]
    return [JEDEC::jep106_mfr_name $banknum $linenum]
  }

  proc is_stuck_low {idcode_t} { return [expr { [dict get $idcode_t idcode] == 0x00000000 }] }
  proc is_stuck_high {idcode_t} { return [expr { [dict get $idcode_t idcode] == 0xFFFFFFFF }] }
}
