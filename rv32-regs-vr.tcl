defn rv32-regs-vr.tcl 2023-06-13
#============== rv32-regs-vr.tcl ======================
# 
#  2023-06-13  pds   initial cut


incl rv32-regs.tcl  ;# the rv32 register set, to which these registers belong

#
# RV32 VECTOR REGISTER SET (VR)
#

namespace eval RV32::REGS::VR {
  variable RV32V_V0   [expr {     0 }] ; variable RV32V_VT0   $RV32V_V0         ;# v temporary
  variable RV32V_V1   [expr {     1 }] ; variable RV32V_VT1   $RV32V_V1         ;# v temporary
  variable RV32V_V2   [expr {     2 }] ; variable RV32V_VT2   $RV32V_V2         ;# v temporary
  variable RV32V_V3   [expr {     3 }] ; variable RV32V_VT3   $RV32V_V3         ;# v temporary
  variable RV32V_V4   [expr {     4 }] ; variable RV32V_VT4   $RV32V_V4         ;# v temporary
  variable RV32V_V5   [expr {     5 }] ; variable RV32V_VT5   $RV32V_V5         ;# v temporary
  variable RV32V_V6   [expr {     6 }] ; variable RV32V_VT6   $RV32V_V6         ;# v temporary
  variable RV32V_V7   [expr {     7 }] ; variable RV32V_VT7   $RV32V_V7         ;# v temporary
  variable RV32V_V8   [expr {     8 }] ; variable RV32V_VT8   $RV32V_V8         ;# v temporary
  variable RV32V_V9   [expr {     9 }] ; variable RV32V_VT9   $RV32V_V9         ;# v temporary
  variable RV32V_V10  [expr {    10 }] ; variable RV32V_VT10  $RV32V_V10        ;# v temporary
  variable RV32V_V11  [expr {    11 }] ; variable RV32V_VT11  $RV32V_V11        ;# v temporary
  variable RV32V_V12  [expr {    12 }] ; variable RV32V_VT12  $RV32V_V12        ;# v temporary
  variable RV32V_V13  [expr {    13 }] ; variable RV32V_VT13  $RV32V_V13        ;# v temporary
  variable RV32V_V14  [expr {    14 }] ; variable RV32V_VT14  $RV32V_V14        ;# v temporary
  variable RV32V_V15  [expr {    15 }] ; variable RV32V_VT15  $RV32V_V15        ;# v temporary
  variable RV32V_V16  [expr {    16 }] ; variable RV32V_VT16  $RV32V_V16        ;# v temporary
  variable RV32V_V17  [expr {    17 }] ; variable RV32V_VT17  $RV32V_V17        ;# v temporary
  variable RV32V_V18  [expr {    18 }] ; variable RV32V_VT18  $RV32V_V18        ;# v temporary
  variable RV32V_V19  [expr {    19 }] ; variable RV32V_VT19  $RV32V_V19        ;# v temporary
  variable RV32V_V20  [expr {    20 }] ; variable RV32V_VT20  $RV32V_V20        ;# v temporary
  variable RV32V_V21  [expr {    21 }] ; variable RV32V_VT21  $RV32V_V21        ;# v temporary
  variable RV32V_V22  [expr {    22 }] ; variable RV32V_VT22  $RV32V_V22        ;# v temporary
  variable RV32V_V23  [expr {    23 }] ; variable RV32V_VT23  $RV32V_V23        ;# v temporary
  variable RV32V_V24  [expr {    24 }] ; variable RV32V_VT24  $RV32V_V24        ;# v temporary
  variable RV32V_V25  [expr {    25 }] ; variable RV32V_VT25  $RV32V_V25        ;# v temporary
  variable RV32V_V26  [expr {    26 }] ; variable RV32V_VT26  $RV32V_V26        ;# v temporary
  variable RV32V_V27  [expr {    27 }] ; variable RV32V_VT27  $RV32V_V27        ;# v temporary
  variable RV32V_V28  [expr {    28 }] ; variable RV32V_VT28  $RV32V_V28        ;# v temporary
  variable RV32V_V29  [expr {    29 }] ; variable RV32V_VT29  $RV32V_V29        ;# v temporary
  variable RV32V_V30  [expr {    30 }] ; variable RV32V_VT30  $RV32V_V30        ;# v temporary
  variable RV32V_V31  [expr {    31 }] ; variable RV32V_VT31  $RV32V_V31        ;# v temporary
}
