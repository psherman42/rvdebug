defn rvdebug-dm-haltsum.tcl 2023-06-13
#============ rvdebug-dmi-haltsum.tcl =================
# 
#  2023-06-13  pds   initial cut


incl rvdebug-dm.tcl  ;# the debug module, to which haltsum belongs


#
# HALTSUM REGISTERS (THRU DMI)
#

namespace eval DM::HALTSUM {
  proc xfer {} {
    variable HALTSUM0_DMI_ADDR
    variable HALTSUM1_DMI_ADDR
    variable HALTSUM2_DMI_ADDR
    variable HALTSUM3_DMI_ADDR

    set data0_x [DTM::DMI::read $HALTSUM0_DMI_ADDR 0]  ;# addr data ... hartsum[31:0] hart(s) 1..32 hartsum[31:0]
    set data1_x [DTM::DMI::read $HALTSUM1_DMI_ADDR 0]  ;# addr data ... hartsum[1023:32] hart(s) 33-1024
    set data2_x [DTM::DMI::read $HALTSUM2_DMI_ADDR 0]  ;# addr data ... hartsum[32767:1024] hart(s) 1025-32768
    set data3_x [DTM::DMI::read $HALTSUM3_DMI_ADDR 0]  ;# addr data ... hartsum[0xFFFFF:32768] hart(s) 32769-many

    # 1 hart: haltsum0=1, haltsum1=1, haltsum2=0, haltsum3=0  ... why haltsum<19:0>=0b00000000000000100001 ?

    # rearrange modulo-32 split fields as needed, implementing Debug Specification description
    # msb=hartsel[19:5],5’h1f                                      lsb=hartsel[19:5],5’h0
    # msb=hartsel[19:10],10’h3e0 through hartsel[19:10],10’h3ff    lsb=hartsel[19:10],10’h0 through hartsel[19:10],10’h1f
    # msb=hartsel[19:15],15’h7c00 through hartsel[19:15],15’h7fff  lsb=hartsel[19:15],15’h0 through hartsel[19:15],15’h3ff
    # msb=               20’hf8000 through               20’hfffff lsb=               20’h0 through                20’h7fff
    #
    #            ----------- hartsello-------------  --------hartselhi--------
    # dmcontrol  [15  .  .  .  .     .  .  .  .  6]  [25 . . . .   . . . . 16]
    # hartsel     19 18 17 16 15    14 13 12 11 10     9 8 7 6 5   4 3 2 1  0
    #                                                                          # MSB-HI  MSB-LO      LSB-HI  LSB-LO
    # hartsum0                                                     1 1 1 1  1  # 0x0001F:0x00000 ... 0x00000:0x00000
    # hartsum1                                         1 1 1 1 1   . . . .  .  # 0x003FF:0x003E0 ... 0x0001F:0x00000
    # hartsum2                       1  1  1  1  1     . . . . .   . . . .  .  # 0x07FFF:0x07C00 ... 0x003FF:0x00000
    # hartsum3     1  1  1  1  1     .  .  .  .  .     . . . . .   . . . .  .  # 0xFFFFF:0xF8000 ... 0x07FFF:0x00000

    set data_x [expr { 0
      | ( ($data3_x & ((1 << 5) - 1)) << 15 )
      | ( ($data2_x & ((1 << 5) - 1)) << 10 )
      | ( ($data1_x & ((1 << 5) - 1)) << 5  )
      | ( ($data0_x & ((1 << 5) - 1)) << 0  )
     }]

    # vanity output style, many-line
    #echo "dtm:dmi_haltsum (): haltsum<19:0>=[format 0b%020b $data_x]"

    return $data_x
  }
}
