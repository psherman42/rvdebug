defn rv32-regs-fpr.tcl 2023-06-13
#============== rv32-regs-fpr.tcl =====================
# 
#  2023-06-13  pds   initial cut


incl rv32-regs.tcl  ;# the rv32 register set, to which these registers belong

#
# RV32 FLOATING POINT REGISTER SET (FPR)
#

namespace eval RV32::REGS::FPR {
  variable RV32FD_F0   [expr {     0 }] ; variable RV32FD_FT0   $RV32FD_F0           ;# fp temporary
  variable RV32FD_F1   [expr {     1 }] ; variable RV32FD_FT1   $RV32FD_F1           ;# fp temporary
  variable RV32FD_F2   [expr {     2 }] ; variable RV32FD_FT2   $RV32FD_F2           ;# fp temporary
  variable RV32FD_F3   [expr {     3 }] ; variable RV32FD_FT3   $RV32FD_F3           ;# fp temporary
  variable RV32FD_F4   [expr {     4 }] ; variable RV32FD_FT4   $RV32FD_F4           ;# fp temporary
  variable RV32FD_F5   [expr {     5 }] ; variable RV32FD_FT5   $RV32FD_F5           ;# fp temporary
  variable RV32FD_F6   [expr {     6 }] ; variable RV32FD_FT6   $RV32FD_F6           ;# fp temporary
  variable RV32FD_F7   [expr {     7 }] ; variable RV32FD_FT7   $RV32FD_F7           ;# fp temporary
  variable RV32FD_F8   [expr {     8 }] ; variable RV32FD_FS0   $RV32FD_F8           ;# fp saved register
  variable RV32FD_F9   [expr {     9 }] ; variable RV32FD_FS1   $RV32FD_F9           ;# fp saved register
  variable RV32FD_F10  [expr {    10 }] ; variable RV32FD_FA0   $RV32FD_F10          ;# fp function argument, return value
  variable RV32FD_F11  [expr {    11 }] ; variable RV32FD_FA1   $RV32FD_F11          ;# fp function argument, return value
  variable RV32FD_F12  [expr {    12 }] ; variable RV32FD_FA2   $RV32FD_F12          ;# fp function argument
  variable RV32FD_F13  [expr {    13 }] ; variable RV32FD_FA3   $RV32FD_F13          ;# fp function argument
  variable RV32FD_F14  [expr {    14 }] ; variable RV32FD_FA4   $RV32FD_F14          ;# fp function argument
  variable RV32FD_F15  [expr {    15 }] ; variable RV32FD_FA5   $RV32FD_F15          ;# fp function argument
  variable RV32FD_F16  [expr {    16 }] ; variable RV32FD_FA6   $RV32FD_F16          ;# fp function argument
  variable RV32FD_F17  [expr {    17 }] ; variable RV32FD_FA7   $RV32FD_F17          ;# fp function argument
  variable RV32FD_F18  [expr {    18 }] ; variable RV32FD_FS2   $RV32FD_F18          ;# fp saved register
  variable RV32FD_F19  [expr {    19 }] ; variable RV32FD_FS3   $RV32FD_F19          ;# fp saved register
  variable RV32FD_F20  [expr {    20 }] ; variable RV32FD_FS4   $RV32FD_F20          ;# fp saved register
  variable RV32FD_F21  [expr {    21 }] ; variable RV32FD_FS5   $RV32FD_F21          ;# fp saved register
  variable RV32FD_F22  [expr {    22 }] ; variable RV32FD_FS6   $RV32FD_F22          ;# fp saved register
  variable RV32FD_F23  [expr {    23 }] ; variable RV32FD_FS7   $RV32FD_F23          ;# fp saved register
  variable RV32FD_F24  [expr {    24 }] ; variable RV32FD_FS8   $RV32FD_F24          ;# fp saved register
  variable RV32FD_F25  [expr {    25 }] ; variable RV32FD_FS9   $RV32FD_F25          ;# fp saved register
  variable RV32FD_F26  [expr {    26 }] ; variable RV32FD_FS10  $RV32FD_F26          ;# fp saved register
  variable RV32FD_F27  [expr {    27 }] ; variable RV32FD_FS11  $RV32FD_F27          ;# fp saved register
  variable RV32FD_F28  [expr {    28 }] ; variable RV32FD_FT8   $RV32FD_F28          ;# fp temporary
  variable RV32FD_F29  [expr {    29 }] ; variable RV32FD_FT9   $RV32FD_F29          ;# fp temporary
  variable RV32FD_F30  [expr {    30 }] ; variable RV32FD_FT10  $RV32FD_F30          ;# fp temporary
  variable RV32FD_F31  [expr {    31 }] ; variable RV32FD_FT11  $RV32FD_F31          ;# fp temporary
}
