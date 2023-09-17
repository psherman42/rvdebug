defn rvdebug-dm-hartinfo.tcl 2023-06-13
#============ rvdebug-dmi-hartinfo.tcl ================
# 
#  2023-06-13  pds   initial cut


incl rvdebug-dm.tcl  ;# the debug module, to which hartinfo belongs


#
# HARTINFO REGISTER (THRU DMI)
#
#                    dataaccess=0 (CSR)  dataaccess=1 (MEM)   MAX
#   datasize<3:0>:   num-csrs            num-mem-words (32-bit)     12
#   dataaddr<3:0>:   first-csr-addr      first-mem-rel-x0

namespace eval DM::HARTINFO {
  proc xfer {} {
    variable DMI_ADDR

    set data_x [DTM::DMI::read $DMI_ADDR 0]  ;# addr data

    # extract bit-fields from numeric value ... MUST use braces of expr when numerics are involved
    set nscratch_x    [expr { ($data_x >> 20) & ((1 << 4) - 1) }]  ;# [23:20]
    set dataaccess_x  [expr { ($data_x >> 16) & ((1 << 1) - 1) }]  ;# [16]
    set datasize_x    [expr { ($data_x >> 12) & ((1 << 4) - 1) }]  ;# [15:12]
    set dataaddr_x    [expr { ($data_x >> 0) & ((1 << 12) - 1) }]  ;# [11:0]

    # vanity output style, many-line
#    echo "dtm:dmi_hartinfo (): nscratch=[format %d $nscratch_x]"
#    echo "dtm:dmi_hartinfo (): dataaccess=[format %d $dataaccess_x]"
#    echo "dtm:dmi_hartinfo (): datasize=[format %d $datasize_x]"
#    echo "dtm:dmi_hartinfo (): dataaddr=[format 0x%03x $dataaddr_x]"

    # returns dictionary of type hartinfo_t
    return [dict create \
      hartinfo    $data_x \
      nscratch    $nscratch_x\
      dataaccess  $dataaccess_x\
      datasize    $datasize_x\
      dataaddr    $dataaddr_x\
    ]
  }

  proc nscratch {hartinfo_t} { return [dict get $hartinfo_t nscratch] }
  proc dataaccess {hartinfo_t} { return [dict get $hartinfo_t dataaccess] }
  proc datasize {hartinfo_t} { return [dict get $hartinfo_t datasize] }
  proc dataaddr {hartinfo_t} { return [dict get $hartinfo_t dataaddr] }

  proc hartinfo_val {hartinfo_t} { return [dict get $hartinfo_t hartinfo] }
  proc hartinfo_str {hartinfo_t} { return [format 0x%08x [dict get $hartinfo_t hartinfo]] }
}
