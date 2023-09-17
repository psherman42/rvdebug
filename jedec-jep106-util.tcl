defn jedec-jep106-util.tcl  2023-06-16
#============ jedec-jep106-util.tcl ===================
# 
#  2023-06-16  pds   initial cut

# JEP106BG, rev. JEP106BF.01, May 2023
# first element of each bank table repeats 0x7F (contin char) once for each bank num
# https://www.jedec.org/standards-documents/docs/jep-106ab

# EXAMPLE:
#  mfrid<10:0> = (JTAG_IDCODE >> 1) & ((1 << 10) - 1)  ;# 10-bits at bit-position 1
#  mfrid.banknum<3:0> = (JTAG_IDCODE >> 7) & ((1 << 4) - 1)  ;# 4-bits at bit-position 7
#  bankid =              [lindex [expr [lindex $::JEDEC_JEP106 $banknum]] 0]    ;# hex
#  bankid = [format %08b [lindex [expr [lindex $::JEDEC_JEP106 $banknum]] 0] ]  ;# binary
#  banknum=1, bankid=0x00 (0)
#  banknum=2, bankid=0x7F (01111111)
#  banknum=3, bankid=0x7F7F (111111101111111)
#  banknum=4, bankid=0x7F7F7F (11111110111111101111111)

namespace eval JEDEC {
  proc jedec-jep106-bankid {b} {
    if {$b eq 1} {
      return {}
    } else {
      return [expr { [format 0x%x 0x[string repeat 7F [expr {$b - 1}]]] }]
    }
  }
}

# NOTE: each sub-list should be defined as follows
# with first element as dummy number index, because jedec tables are option base 1.
# set JEDEC_JEP106_BANK1  [list  0          ...]  ;# 0b0
# set JEDEC_JEP106_BANK2  [list  0x7F       ...]  ;# 0b01111111
# set JEDEC_JEP106_BANK3  [list  0x7F7F     ...]  ;# 0b11111110111111101111111
# set JEDEC_JEP106_BANK4  [list  0x7F7F7F   ...]  ;# 0b1111111011111110111111101111111
# set JEDEC_JEP106_BANK5  [list  0x7F7F7F7F ...]  ;# 0b111111101111111011111110111111101111111
# set JEDEC_JEP106_BANKn  [list  [expr {"0x[string repeat 7F [expr {$n - 1}] ...]

#
# SAMPLE TEST CASE
#
#echo "base-10"
#set x [expr {"[string repeat 10 1]"}] ; echo "bank=1, num=0x[format %0x $x] [format %d $x] ([format %08b $x])"
#set x [expr {"[string repeat 10 2]"}] ; echo "bank=2, num=0x[format %0x $x] [format %d $x] ([format %08b $x])"
#set x [expr {"[string repeat 10 3]"}] ; echo "bank=3, num=0x[format %0x $x] [format %d $x] ([format %08b $x])"
#set x [expr {"[string repeat 10 4]"}] ; echo "bank=4, num=0x[format %0x $x] [format %d $x] ([format %08b $x])"
#set x [expr {"[string repeat 10 5]"}] ; echo "bank=5, num=0x[format %0x $x] [format %d $x] ([format %08b $x])"
#echo "base-16"
#set x [expr {"0x[string repeat 7F 1]"}] ; echo "bank=1, num=0x[format %0x $x] ([format %d $x]) ([format %08b $x])"
#set x [expr {"0x[string repeat 7F 2]"}] ; echo "bank=2, num=0x[format %0x $x] ([format %d $x]) ([format %08b $x])"
#set x [expr {"0x[string repeat 7F 3]"}] ; echo "bank=3, num=0x[format %0x $x] ([format %d $x]) ([format %08b $x])"
#set x [expr {"0x[string repeat 7F 4]"}] ; echo "bank=4, num=0x[format %0x $x] ([format %d $x]) ([format %08b $x])"
#set x [expr {"0x[string repeat 7F 5]"}] ; echo "bank=5, num=0x[format %0x $x] ([format %d $x]) ([format %08b $x])"
#
#set b 2 ; set SOME_A [list [expr {"0x[string repeat 7F [expr {$b - 1}] ]"}] "A"  "B"  "C"  ...]
#set b 3 ; set SOME_B [list [expr {"0x[string repeat 7F [expr {$b - 1}] ]"}] "D"  "E"  "F"  ...]
#set b 4 ; set SOME_C [list [expr {"0x[string repeat 7F [expr {$b - 1}] ]"}] "G"  "H"  "I"  ...]
#set b 5 ; set SOME_D [list [expr {"0x[string repeat 7F [expr {$b - 1}] ]"}] "J"  "K"  "L"  ...]
#set b 6 ; set SOME_E [list [expr {"0x[string repeat 7F [expr {$b - 1}] ]"}] "M"  "N"  "O"  ...]
#set b 7 ; set SOME_F [list [expr {"0x[string repeat 7F [expr {$b - 1}] ]"}] "P"  "Q"  "R"  ...]
#set MANY [list [list $::SOME_A] [list $::SOME_B] [list $::SOME_C] [list $::SOME_D] [list $::SOME_E] [list $::SOME_F] ...]
#
# 3NF table look-up somenum from SOME within MANY
#
#set m 0 ; set s 2 ; set name [lindex $[lindex $::MANY $m] $s] ; echo "m=$m, s=$s, name=$name mid=[lindex [expr [lindex $::MANY $m]] 0] ([format 0b%08b [lindex [expr [lindex $::MANY $m]] 0] ])"
#set m 1 ; set s 2 ; set name [lindex $[lindex $::MANY $m] $s] ; echo "m=$m, s=$s, name=$name mid=[lindex [expr [lindex $::MANY $m]] 0] ([format 0b%08b [lindex [expr [lindex $::MANY $m]] 0] ])"
#set m 2 ; set s 2 ; set name [lindex $[lindex $::MANY $m] $s] ; echo "m=$m, s=$s, name=$name mid=[lindex [expr [lindex $::MANY $m]] 0] ([format 0b%08b [lindex [expr [lindex $::MANY $m]] 0] ])"
#set m 3 ; set s 2 ; set name [lindex $[lindex $::MANY $m] $s] ; echo "m=$m, s=$s, name=$name mid=[lindex [expr [lindex $::MANY $m]] 0] ([format 0b%08b [lindex [expr [lindex $::MANY $m]] 0] ])"
#set m 4 ; set s 2 ; set name [lindex $[lindex $::MANY $m] $s] ; echo "m=$m, s=$s, name=$name mid=[lindex [expr [lindex $::MANY $m]] 0] ([format 0b%08b [lindex [expr [lindex $::MANY $m]] 0] ])"
#set m 5 ; set s 2 ; set name [lindex $[lindex $::MANY $m] $s] ; echo "m=$m, s=$s, name=$name mid=[lindex [expr [lindex $::MANY $m]] 0] ([format 0b%08b [lindex [expr [lindex $::MANY $m]] 0] ])"
