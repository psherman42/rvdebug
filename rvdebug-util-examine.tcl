defn rvdebug-util-examine.tcl 2023-06-13
#============ rvdebug-util-examine.tcl ================
# 
#  2023-06-13  pds   initial cut

# this coordinates with rvdebug-handler.tcl:
set RVDEBUG_EXAMINE_OK 0
set RVDEBUG_EXAMINE_ERR_NO_HARTS   [expr { -1 - 200 - 10 }]  ;# 1=top-lvl, 10=2nd-lvl, 20=3rd-lvl, ...
set RVDEBUG_EXAMINE_ERR_NO_ISA     [expr { -2 - 200 - 10 }]  ;# 1=top-lvl, 10=2nd-lvl, 20=3rd-lvl, ...

incl rvdebug-dm-dmcontrol.tcl        ;# for ndmreset race-condition avoidance, halting, and resuming
incl rvdebug-dm-dmstatus.tcl         ;# to check version and compare to dtm.dtmcs.version
incl rvdebug-dm-hartinfo.tcl         ;# for hart states, like existing, running, and halting
incl rvdebug-dm-haltsum.tcl          ;# for listing every possible hart on a system
incl rvdebug-dm-sbcs.tcl             ;# access to the system bus (not always implemented)
incl rvdebug-dm-confstrptr.tcl       ;# configuration string pointers

incl rv32-regs-gpr.tcl  ;# for direct use of reg. S0 (X8)
incl rv32-regs-csr.tcl  ;# for the CSRs so can read machine-mode special registers

incl rvdebug-dm.tcl       ;# for abstr stuff, for now

###incl rvdebug-dtm-dtmcs.tcl           ;# to use dtmhartreset for doing a clean startup
###incl rvdebug-dmi-abstract-utils.tcl  ;# to figure out natural word size
###incl rvdebug-dmi-abstract-instr.tcl  ;# to read out all the CSRs of a system

#
# EXAMINE SYSTEM PROCEDURE
#
#        datacount = dmi.abstractcs.datacount
#        progbuf = dmi.abstractcs.progbufsize
#        n = count(dmcontrol.hartsel) with dmstatus.nonexistent=0 and dmstatus.running or dmstatus.halted
#        MXLEN = misa[XLEN-1:XLEN-2] (0=16-bit, 1=32-bit, 2=64-bit, 3=128-bit)
#        misa = dmi.data0 after dmi.command reg-type, 32-bit, misa (65+0x301), reg/mem, read, no-incr, no-exec
#
#(target)set_examined
# riscv_count_harts
#
#  echo "Info : datacount=$datacount progbuf=$progbuf"              ;# dmi.abstractcs.datacount=1  dmi.abstractcs.progbufsize=0
#  echo "Info : Disabling abstract command reads from CSRs."        ;# dmi.dmcontrol.haltreq=1 dmi.dmcontrol.dmactive=1
#  echo "Info : Examined RISC-V core; found $n harts"               ;# count(dmcontrol.hartsel) with dmstatus.nonexistent=0
#  echo "Info :  hart $h: XLEN=$xlen, misa=[format 0x%08x misa_x]"  ;# for each hartsel, misa (65 + 0x301)
#
#  sample output:
#        Info : datacount=1 progbufsize=16                     
#        Info : Disabling abstract command reads from CSRs.
#        Info : Examined RISC-V core; found 1 harts
#        Info :  hart 0: XLEN=32, misa=0x40101105

proc examine_system {} {
  #----- determine number of hart(s) ... allow for possibility of non-contiguous hart ids, max 10 for now :(
  #
  echo -n "number of hart(s)... "

  # scan backwards so always finish with (first) hart 0
  set FIRST_HART 0
  set MAX_HARTS  10
  set NHARTS 0
  for {set i $MAX_HARTS} {$i >= $FIRST_HART} {incr i -1} {
    # WARNING! do NOT change haltsel unless already in a dmstatus.halted state ... do NOT change hartsel and haltreq same time
    #                   haltreq resumereq hartreset ackhavereset hasel hartsel setresethaltreq clrresethaltreq ndmreset dmactive
    DM::DMCONTROL::xfer 1       0         0         0            0     $i      0               0               0        1     ;# halt hart, keep halted ...

    set dmstatus_0 [DM::DMSTATUS::xfer]
    if {[DM::DMSTATUS::present $dmstatus_0]} { incr NHARTS }  ;# not nonexistent and either running or halted
  }
  unset i

  if { $NHARTS == 0 } {
    set ::rvdebugErrorCode $::RVDEBUG_EXAMINE_ERR_NO_HARTS
    set ::rvdebugErrorOptions [dict create \
      {-what-went-wrong} {no hart(s) found} \
      {-what-to-check} {dtm and dmi not healthy?} \
      {-what-to-do} {sel, halt, ack, reset logic not okay?} \
    ]
    return $::RVDEBUG_EXAMINE_ERR_NO_HARTS
  }
 
  echo -n "found $NHARTS"
  echo -n " with [DM::DMSTATUS::verstr $dmstatus_0]"
  echo ""
  #
  #----- determine number of hart(s)


  #----- determine natural word size of each hart
  #
  echo -n "natural word size... "

  set XLEN [DM::abstr_natural_word_size]

  if { $XLEN lt 0 } {
    set ::rvdebugErrorCode $::RVDEBUG_EXAMINE_ERR_NO_WORD_SIZE
    set ::rvdebugErrorOptions [dict create \
      {-what-went-wrong} {no word size(s) found} \
      {-what-to-check} {dtm and dmi not healthy?} \
      {-what-to-do} {sel, halt, ack, reset logic not okay?} \
    ]
    return $::RVDEBUG_EXAMINE_ERR_NO_WORD_SIZE
  }

  echo "found XLEN=$XLEN"
  #
  #----- determine natural word size of each hart


  #----- examine halt summary status
  #
  echo -n "halt summary status... "

  set haltsum_0 [DM::HALTSUM::xfer]

  echo -n "found"
  echo -n " haltsum<19:0>=[format 0b%020b $haltsum_0]"
  echo ""
  #
  #----- examine halt summary status


  #----- examining hart information
  #
  echo -n "hart information... "

  set hartinfo_0 [DM::HARTINFO::xfer]

  echo -n "found"
  echo -n " nscratch=[DM::HARTINFO::nscratch $hartinfo_0]"
  echo -n " dataaccess=[DM::HARTINFO::dataaccess $hartinfo_0]"
  echo -n " datasize=[DM::HARTINFO::datasize $hartinfo_0]"
  echo -n " dataaddr=[format 0x%x [DM::HARTINFO::dataaddr $hartinfo_0]]"
  echo ""
  #
  #----- examining hart information


  #----- abstract module
  #
  echo -n "preparing abstract module... "

  # configure the ai as target specifies (ask the dm and tell the ai)
  set abstractcs_0 [DM::ABSTRACTCS::xfer 0]
  DM::set_progbuf_size [DM::ABSTRACTCS::progbufsize $abstractcs_0]  ;# num abstr program buffers
  DM::set_databuf_size [DM::ABSTRACTCS::datacount $abstractcs_0]    ;# num abstr data buffers

  if {![DM::is_configured]} {
    set ::rvdebugErrorCode $::RVDEBUG_EXAMINE_ERR_NO_CONFIG
    set ::rvdebugErrorOptions [dict create \
      {-what-went-wrong} {ai parameters not configured} \
      {-what-to-check} {pbuf size? dbuf size?} \
      {-what-to-do} {hartinfo definition not correct? hartinfo.datasize? hartinfo.dataaddr?} \
    ]
    return $::RVDEBUG_EXAMINE_ERR_NO_CONFIG
  }

  echo -n "found"
  echo -n " [DM::ABSTRACTCS::progbufsize $abstractcs_0] program buffer(s)"
  echo -n " and [DM::ABSTRACTCS::datacount $abstractcs_0] data buffer(s)"
  echo -n " , busy=[DM::ABSTRACTCS::busy $abstractcs_0]"
  echo -n " , cmderr=[DM::ABSTRACTCS::cmderr $abstractcs_0]"
  echo -n " ([DM::ABSTRACTCS::cmderrstr $abstractcs_0])"
  echo ""
  #
  #----- preparing abstract module


  #--- system bus access
  #        not available on E31 Complex
  #
  echo -n "system bus control and status... "

  #       err bits ... write 1 to clear them
  #                          sbbusyerror sbreadonaddr sbaccess sbautoincrement sbreadondata sberror
  #                          ----------- ------------ -------- --------------- ------------ -------
  set sbcs_0 [DM::SBCS::xfer 0           0            0        0               0            0]

  echo -n "found"
  echo -n " version=[DM::SBCS::version $sbcs_0]"
  echo -n " busyerror=[DM::SBCS::busyerror $sbcs_0]"
  echo -n " busy=[DM::SBCS::busy $sbcs_0]"
  echo -n " readonaddr=[DM::SBCS::readonaddr $sbcs_0]"
  echo -n " access=[DM::SBCS::access $sbcs_0]"
  echo -n " autoincrement=[DM::SBCS::autoincrement $sbcs_0]"
  echo -n " readondata=[DM::SBCS::readondata $sbcs_0]"
  echo -n " error=[DM::SBCS::error $sbcs_0]"
  echo -n " asize=[DM::SBCS::asize $sbcs_0]"
  echo -n " accesssupported=[DM::SBCS::accesssupported $sbcs_0]"
  echo ""
  #
  #----- system bus access


  #----- configuration string pointers
  #
  echo -n "configuration string pointers... "

  set confstr_0a [DM::CONFSTRPTR::xfer 0 0]  ;# confnum confstr {mode}  (mode: 0=read, 1=write-read)
  set confstr_0b [DM::CONFSTRPTR::xfer 1 0]  ;# confnum confstr {mode}  (mode: 0=read, 1=write-read)
  set confstr_0c [DM::CONFSTRPTR::xfer 2 0]  ;# confnum confstr {mode}  (mode: 0=read, 1=write-read)
  set confstr_0d [DM::CONFSTRPTR::xfer 3 0]  ;# confnum confstr {mode}  (mode: 0=read, 1=write-read)

  echo -n "found"
  echo -n " [format 0x%x  $confstr_0a]"
  echo -n ", [format 0x%x  $confstr_0b]"
  echo -n ", [format 0x%x  $confstr_0c]"
  echo -n ", [format 0x%x  $confstr_0d]"
  echo ""
  #
  #----- configuration string pointers


  #----- examining system configuration
  #           
  echo "examining system CSRs"

  set tmpreg   [expr { $::RV32::REGS::GPR::RV32I_S0 }]  ;# temp work area, any non-trivial (not x0) GPR

  #----- mvendorid
  #
  set mvendorid [DM::abstr_instr_csr_rd $::RV32::REGS::CSR::MVENDORID $tmpreg]  ;# JEDEC mfr id (not on E31 Complex?)
  echo -n "mvendorid=$mvendorid"
  if { $mvendorid eq 0 } { echo " (not implemented)" }  ;# e.g., not on FE310-G002, etc
  #
  #----- mvendorid


  #----- marchid
  #
  set marchid [DM::abstr_instr_csr_rd $::RV32::REGS::CSR::MARCHID $tmpreg]      ;# base microarchitecture id (not on E31 Complex?)
  echo -n "marchid=$marchid"
  if { $marchid eq 0 } { echo " (not implemented)" }  ;# e.g., not on FE310-G002, etc
  #
  #----- marchid


  #----- mimpid
  #
  set mimpid [DM::abstr_instr_csr_rd $::RV32::REGS::CSR::MIMPID $tmpreg]        ;# version of implmentation of base microarchitecture (not on E31 Complex?)
  echo -n "mimpid=$mimpid"
  if { $mimpid eq 0 } { echo " (not implemented)" }  ;# e.g., not on FE310-G002, etc
  #
  #----- mimpid


  #----- mhartid
  #
  set mhartid [DM::abstr_instr_csr_rd $::RV32::REGS::CSR::MHARTID $tmpreg]      ;# current hart id (not on E31 Complex?)
  echo -n "mhartid=$mhartid"
  if { $mhartid eq 0 } { echo " (not implemented)" }  ;# e.g., not on FE310-G002, etc
  #
  #----- mhartid


  #----- misa
  #
  set misa [DM::abstr_instr_csr_rd $::RV32::REGS::CSR::MISA $tmpreg]

  echo -n "misa=[format 0x%08x $misa] ("

  # natural word size
  echo -n "MXLEN=[expr { 16 << (($misa >> ($XLEN-2)) & 0b11) }]"  ;# [XLEN-1:XLEN-2...XLEN-26]=MXL[1:0] 0=16, 1=32, 2=64, 3=128

  # A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
  # 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2
  # 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5

  # machine isa extension(s) ... shown in canonical order
  #                 I  M A C   B D E F G H J  K  L  N  O  P  Q  R  S  T  V  W  X  Y  Z   U
  set EXTLIST [list 8 12 0 2   1 3 4 5 6 7 9 10 11 13 14 15 16 17 18 19 21 22 23 24 25  20]
  echo -n ", RV32"
  set numext 0
  foreach i $EXTLIST {
    incr numext
    if { [expr { $misa & (1 << $i) }] } { echo -n "[format %c [expr {65 + $i}]]" }
  }
  echo ")"

  if { [expr { $numext == 0 }] } {
    set ::rvdebugErrorCode $::RVDEBUG_EXAMINE_ERR_NO_ISA
    set ::rvdebugErrorOptions [dict create \
      {-what-went-wrong} {no ISA extensions found} \
      {-what-to-check} {abstract commands and regs for csr instr?} \
      {-what-to-do} {abstract program correct?} \
    ]
    return $::RVDEBUG_EXAMINE_ERR_NO_ISA
  }

  #
  #----- misa


  #----- mcause
  #
  set mcause [DM::abstr_instr_csr_rd $::RV32::REGS::CSR::MCAUSE $tmpreg]        ;# machine trap cause

  switch [expr { $mcause & 0x80000000 }] {
    0 {
      set mcausetypstr "Exception"
      switch $mcause {
        0 { set mcausestr "Instruction address misaligned" }
        1 { set mcausestr "Instruction access fault" }
        2 { set mcausestr "Illegal instruction" }
        3 { set mcausestr "Breakpoint" }
        4 { set mcausestr "Load address misaligned" }
        5 { set mcausestr "Load access failt" }
        6 { set mcausestr "Store address misaligned" }
        7 { set mcausestr "Store access fault" }
        8 { set mcausestr "Environment call from U-mode" }
        9 { set mcausestr "Environment call from S-mode" }
        10 { set mcausestr "Environment call from H-mode" }
        11 { set mcausestr "Environment call from M-mode" }
        12 { set mcausestr "Instruction page fault" }
        13 { set mcausestr "Load page fault" }
        14 { set mcausestr "unkn $mcause" }
        15 { set mcausestr "Store page fault" }
        default { set mcausestr "unkn $mcause" }
      }
    }
    default {
      set mcausetypstr "Interrupt"
      switch [expr { $mcause & 0x7FFFFFFF }] {
        0 { set mcausestr "User software interrupt" }
        1 { set mcausestr "Supervisor software interrupt" }
        2 { set mcausestr "Hypervisor software interrupt" }
        3 { set mcausestr "Machine software interrupt" }
        4 { set mcausestr "User timer interrupt" }
        5 { set mcausestr "Supervisor timer interrupt" }
        6 { set mcausestr "Hypervisor timer interrupt" }
        7 { set mcausestr "Machine timer interrupt" }
        8 { set mcausestr "User external interrupt" }
        9 { set mcausestr "Supervisor external interrupt" }
        10 { set mcausestr "Hypervisor external interrupt" }
        11 { set mcausestr "Machine external interrupt" }
        12 { set mcausestr "unkn [expr { $mcause & 0x7FFFFFFF }]" }
        13 { set mcausestr "unkn [expr { $mcause & 0x7FFFFFFF }]" }
        14 { set mcausestr "unkn [expr { $mcause & 0x7FFFFFFF }]" }
        15 { set mcausestr "unkn [expr { $mcause & 0x7FFFFFFF }]" }
        default { set mcausestr "unkn [expr { $mcause & 0x7FFFFFFF }]" }
      }
    }
  }
  echo -n "mcause=[format 0x%08x $mcause] ("
  echo -n "$mcausetypstr:"
  echo -n " $mcausestr"
  echo    ")"
  #
  #-----  mcause


  #----- mtval
  #
  set mtval [DM::abstr_instr_csr_rd $::RV32::REGS::CSR::MTVAL $tmpreg]          ;# machine bad address or instruction
  echo "mtval=[format 0x%08x $mtval]"
  #----- mtval


  #----- mepc
  #
  set mepc [DM::abstr_instr_csr_rd $::RV32::REGS::CSR::MEPC $tmpreg]            ;# machine interrupt program counter
  echo "mepc=[format 0x%08x $mepc]"
  #----- mepc


  #----- mtvec
  #
  set mtvec [DM::abstr_instr_csr_rd $::RV32::REGS::CSR::MTVEC $tmpreg]          ;# machine trap handler base address
  echo "mtvec=[format 0x%08x $mtvec]"
  #----- mtvec


  #----- mstatus
  #
  set mstatus [DM::abstr_instr_csr_rd $::RV32::REGS::CSR::MSTATUS $tmpreg]      ;# machine status register

  #                  0 1 2 3
  set privmode [list U S H M]

  #                  0    1 2 3      4 5    6    7       8  9    A    B       C    D     E     F
  set privlist [list "."  U S "SU"   H "HU" "HS" "HSU"   M  "MU" "MS" "MSU"   "MH" "MHU" "MHS" "MHS" ]

  echo -n "mstatus=[format 0x%08x $mstatus] ("
  echo -n "sd=[expr { ($mstatus >> ($XLEN-1)) & 0b1 }]"                    ;# [XLEN-1]
  echo -n ", tsr=[expr { ($mstatus >> 22) & 0b1 }]"                        ;# [22]
  echo -n ", tw=[expr { ($mstatus >> 21) & 0b1 }]"                         ;# [21]
  echo -n ", tvm=[expr { ($mstatus >> 20) & 0b1 }]"                        ;# [20]
  echo -n ", mxr=[expr { ($mstatus >> 19) & 0b1 }]"                        ;# [19]
  echo -n ", sum=[expr { ($mstatus >> 18) & 0b1 }]"                        ;# [18]
  echo -n ", mprv=[expr { ($mstatus >> 17) & 0b1 }]"                       ;# [17]
  echo -n ", xs=[lindex $privmode [expr { ($mstatus >> 15) & 0b11 }] ]"    ;# [16:15]
  echo -n ", fs=[lindex $privmode [expr { ($mstatus >> 13) & 0b11 }] ]"    ;# [14:13]
  echo -n ", mpp=[lindex $privmode [expr { ($mstatus >> 11) & 0b11 }] ]"   ;# [12:11]
  echo -n ", hpp=[lindex $privmode [expr { ($mstatus >> 9) & 0b11 }] ]"    ;# [10:9]
  echo -n ", spp=[lindex $privmode [expr { ($mstatus >> 8) & 0b1 }] ]"     ;# [8]
  echo -n ", pie=[lindex $privlist [expr { ($mstatus >> 4) & 0b1111 }] ]"  ;# [7:4]
  echo -n ", ie=[lindex $privlist [expr { ($mstatus >> 0) & 0b1111 }] ]"   ;# [3:0]
  echo    ")"
  #
  #----- mstatus


  #----- mie
  #
  set mie [DM::abstr_instr_csr_rd $::RV32::REGS::CSR::MIE $tmpreg]              ;# machine interrupt enable register

  echo -n "mie=[format 0x%08x $mie] ("
  echo -n "ext=[lindex $privlist [expr { [expr { ($mie >> 8) & 0b1111 }] }] ]"   ;# [11:8]
  echo -n ", tim=[lindex $privlist [expr { [expr { ($mie >> 4) & 0b1111 }] }] ]"   ;# [7:4]
  echo -n ", sw=[lindex $privlist [expr { [expr { ($mie >> 0) & 0b1111 }] }] ]"   ;# [3:0]
  echo    ")"
  #
  #----- mie


  # cleanup
  unset EXTLIST
  unset privlist
  unset privmode

  return $::RVDEBUG_EXAMINE_OK
}
