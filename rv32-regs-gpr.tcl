defn rv32-regs-gpr.tcl 2023-06-13
#============== rv32-regs-gpr.tcl =====================
# 
#  2023-06-13  pds   initial cut


incl rv32-regs.tcl  ;# the rv32 register set, to which these registers belong

#
# RV32 GENERAL PURPOSE REGISTER SET (GPR)
#

namespace eval RV32::REGS::GPR {
  #some of these should have name RV32IC...
  # except for those temps and function args unreachable by compressed branch forms
  variable RV32I_X0   [expr {     0 }] ; variable RV32I_ZERO $RV32I_X0                           ;# hardwired zero
  variable RV32I_X1   [expr {     1 }] ; variable RV32I_RA   $RV32I_X1                           ;# return address
  variable RV32I_X2   [expr {     2 }] ; variable RV32I_SP   $RV32I_X2                           ;# stack pointer
  variable RV32I_X3   [expr {     3 }] ; variable RV32I_GP   $RV32I_X3                           ;# global pointer
  variable RV32I_X4   [expr {     4 }] ; variable RV32I_TP   $RV32I_X4                           ;# thread pointer
  variable RV32I_X5   [expr {     5 }] ; variable RV32I_T0   $RV32I_X5                           ;# temporary
  variable RV32I_X6   [expr {     6 }] ; variable RV32I_T1   $RV32I_X6                           ;# temporary
  variable RV32I_X7   [expr {     7 }] ; variable RV32I_T2   $RV32I_X7                           ;# temporary
  variable RV32I_X8   [expr {     8 }] ; variable RV32I_S0   $RV32I_X8  ; variable RV32I_FP $RV32I_X8 ;# saved register, frame pointer
  variable RV32I_X9   [expr {     9 }] ; variable RV32I_S1   $RV32I_X9                           ;# saved register
  variable RV32I_X10  [expr {    10 }] ; variable RV32I_A0   $RV32I_X10                          ;# function argument, return value
  variable RV32I_X11  [expr {    11 }] ; variable RV32I_A1   $RV32I_X11                          ;# function argument, return value
  variable RV32I_X12  [expr {    12 }] ; variable RV32I_A2   $RV32I_X12                          ;# function argument
  variable RV32I_X13  [expr {    13 }] ; variable RV32I_A3   $RV32I_X13                          ;# function argument
  variable RV32I_X14  [expr {    14 }] ; variable RV32I_A4   $RV32I_X14                          ;# function argument
  variable RV32I_X15  [expr {    15 }] ; variable RV32I_A5   $RV32I_X15                          ;# function argument
  variable RV32I_X16  [expr {    16 }] ; variable RV32I_A6   $RV32I_X16                          ;# function argument
  variable RV32I_X17  [expr {    17 }] ; variable RV32I_A7   $RV32I_X17                          ;# function argument
  variable RV32I_X18  [expr {    18 }] ; variable RV32I_S2   $RV32I_X18                          ;# saved register
  variable RV32I_X19  [expr {    19 }] ; variable RV32I_S3   $RV32I_X19                          ;# saved register
  variable RV32I_X20  [expr {    20 }] ; variable RV32I_S4   $RV32I_X20                          ;# saved register
  variable RV32I_X21  [expr {    21 }] ; variable RV32I_S5   $RV32I_X21                          ;# saved register
  variable RV32I_X22  [expr {    22 }] ; variable RV32I_S6   $RV32I_X22                          ;# saved register
  variable RV32I_X23  [expr {    23 }] ; variable RV32I_S7   $RV32I_X23                          ;# saved register
  variable RV32I_X24  [expr {    24 }] ; variable RV32I_S8   $RV32I_X24                          ;# saved register
  variable RV32I_X25  [expr {    25 }] ; variable RV32I_S9   $RV32I_X25                          ;# saved register
  variable RV32I_X26  [expr {    26 }] ; variable RV32I_S10  $RV32I_X26                          ;# saved register
  variable RV32I_X27  [expr {    27 }] ; variable RV32I_S11  $RV32I_X27                          ;# saved register
  variable RV32I_X28  [expr {    28 }] ; variable RV32I_T3   $RV32I_X28                          ;# temporary
  variable RV32I_X29  [expr {    29 }] ; variable RV32I_T4   $RV32I_X29                          ;# temporary
  variable RV32I_X30  [expr {    30 }] ; variable RV32I_T5   $RV32I_X30                          ;# temporary
  variable RV32I_X31  [expr {    31 }] ; variable RV32I_T6   $RV32I_X31                          ;# temporary
  variable RV32I_PC   [expr { 0 }]  ;# program counter
}
