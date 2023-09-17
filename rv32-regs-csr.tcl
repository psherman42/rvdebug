defn rv32-regs-csr.tcl 2023-06-13
#============== rv32-regs-csr.tcl =====================
# 
#  2023-06-13  pds   initial cut


incl rv32-regs.tcl  ;# the rv32 register set, to which these registers belong

#
# RV32 CONTROL AND STATUS REGISTER SET (CSR)
#
#   see Section 2.2 of RISC-V Privileged Specification
#
#   lives in riscv/riscv-opcodes/encoding.h                      -- as (GDB_REGNO_CSR0 + CSR_...) terms
#   and openocd/riscv-013.c (line 851) access_register_command() -- as ( GDB_REGNO_CSR0 = (65 + ...) - 65 )
#
# CSR[11:10] group (0=., 1=., 2=., 3=.)
# CSR[9:8] privmode (0=U, 1=S, 2=H, 3=M)
# CSR[7:4] sub-group (0=., 1=., 2=., 3=.)
# CSR[3:0] csrnum

namespace eval RV32::REGS::CSR {
  # machine information registers
  variable MVENDORID   [expr { 0xF11 }]
  variable MARCHID     [expr { 0xF12 }]
  variable MIMPID      [expr { 0xF13 }]
  variable MHARTID     [expr { 0xF14 }]
  variable MCONFIGPTR  [expr { 0xF15 }]

  # machine trap setup
  variable MSTATUS     [expr { 0x300 }]
  variable MISA        [expr { 0x301 }]
  variable MEDELEG     [expr { 0x302 }]
  variable MIDELEG     [expr { 0x303 }]
  variable MIE         [expr { 0x304 }]
  variable MTVEC       [expr { 0x305 }]
  variable MCOUNTEREN  [expr { 0x306 }]
  variable MSTATUSH    [expr { 0x310 }]

  # machine machine trap handling
  variable MSCRATCH    [expr { 0x340 }]
  variable MEPC        [expr { 0x341 }]
  variable MCAUSE      [expr { 0x342 }]
  variable MTVAL       [expr { 0x343 }]
  variable MIP         [expr { 0x344 }]
  variable MTINST      [expr { 0x34A }]
  variable MTVAL2      [expr { 0x34B }]

  # machine memory protection (0x380-0x3ef)
  variable PMPCFG0    [expr { 0x3A0 }]
  variable PMPCFG0    [expr { 0x3A1 }]
  variable PMPCFG0    [expr { 0x3A2 }]
  variable PMPCFG0    [expr { 0x3A3 }]
  variable PMPADDR0   [expr { 0x3B0 }]
  variable PMPADDR1   [expr { 0x3B1 }]
  variable PMPADDR2   [expr { 0x3B2 }]
  variable PMPADDR3   [expr { 0x3B3 }]
  variable PMPADDR4   [expr { 0x3B4 }]
  variable PMPADDR5   [expr { 0x3B5 }]
  variable PMPADDR6   [expr { 0x3B6 }]
  variable PMPADDR7   [expr { 0x3B7 }]
  variable PMPADDR8   [expr { 0x3B8 }]
  variable PMPADDR9   [expr { 0x3B9 }]
  variable PMPADDR10  [expr { 0x3BA }]
  variable PMPADDR11  [expr { 0x3BB }]
  variable PMPADDR12  [expr { 0x3BC }]
  variable PMPADDR13  [expr { 0x3BD }]
  variable PMPADDR14  [expr { 0x3BE }]
  variable PMPADDR15  [expr { 0x3BF }]

  # machine counter/timers
  # lower 32-bits
  variable mcycle        [expr { 0xB00 }]
  variable minstret      [expr { 0xB02 }]
  variable mhpmcounter3  [expr { 0xB03 }]
  variable mhpmcounter4  [expr { 0xB04 }]
  variable mhpmcounter5  [expr { 0xB05 }]
  variable mhpmcounter6  [expr { 0xB06 }]
  variable mhpmcounter7  [expr { 0xB07 }]
  variable mhpmcounter8  [expr { 0xB08 }]
  variable mhpmcounter9  [expr { 0xB09 }]
  variable mhpmcounter10 [expr { 0xB0A }]
  variable mhpmcounter11 [expr { 0xB0B }]
  variable mhpmcounter12 [expr { 0xB0C }]
  variable mhpmcounter13 [expr { 0xB0D }]
  variable mhpmcounter14 [expr { 0xB0E }]
  variable mhpmcounter15 [expr { 0xB0F }]
  variable mhpmcounter16 [expr { 0xB10 }]
  variable mhpmcounter17 [expr { 0xB11 }]
  variable mhpmcounter18 [expr { 0xB12 }]
  variable mhpmcounter19 [expr { 0xB13 }]
  variable mhpmcounter20 [expr { 0xB14 }]
  variable mhpmcounter21 [expr { 0xB15 }]
  variable mhpmcounter22 [expr { 0xB16 }]
  variable mhpmcounter23 [expr { 0xB17 }]
  variable mhpmcounter24 [expr { 0xB18 }]
  variable mhpmcounter25 [expr { 0xB19 }]
  variable mhpmcounter26 [expr { 0xB1A }]
  variable mhpmcounter27 [expr { 0xB1B }]
  variable mhpmcounter28 [expr { 0xB1C }]
  variable mhpmcounter29 [expr { 0xB1D }]
  variable mhpmcounter30 [expr { 0xB1E }]
  variable mhpmcounter31 [expr { 0xB1F }]
  # upper 32-bits
  variable mcycleh        [expr { 0xB80 }]
  variable minstreth      [expr { 0xB82 }]
  variable mhpmcounter3h  [expr { 0xB83 }]
  variable mhpmcounter4h  [expr { 0xB84 }]
  variable mhpmcounter5h  [expr { 0xB85 }]
  variable mhpmcounter6h  [expr { 0xB86 }]
  variable mhpmcounter7h  [expr { 0xB87 }]
  variable mhpmcounter8h  [expr { 0xB88 }]
  variable mhpmcounter9h  [expr { 0xB89 }]
  variable mhpmcounter10h [expr { 0xB8A }]
  variable mhpmcounter11h [expr { 0xB8B }]
  variable mhpmcounter12h [expr { 0xB8C }]
  variable mhpmcounter13h [expr { 0xB8D }]
  variable mhpmcounter14h [expr { 0xB8E }]
  variable mhpmcounter15h [expr { 0xB8F }]
  variable mhpmcounter16h [expr { 0xB90 }]
  variable mhpmcounter17h [expr { 0xB91 }]
  variable mhpmcounter18h [expr { 0xB92 }]
  variable mhpmcounter19h [expr { 0xB93 }]
  variable mhpmcounter20h [expr { 0xB94 }]
  variable mhpmcounter21h [expr { 0xB95 }]
  variable mhpmcounter22h [expr { 0xB96 }]
  variable mhpmcounter23h [expr { 0xB97 }]
  variable mhpmcounter24h [expr { 0xB98 }]
  variable mhpmcounter25h [expr { 0xB99 }]
  variable mhpmcounter26h [expr { 0xB9A }]
  variable mhpmcounter27h [expr { 0xB9B }]
  variable mhpmcounter28h [expr { 0xB9C }]
  variable mhpmcounter29h [expr { 0xB9D }]
  variable mhpmcounter30h [expr { 0xB9E }]
  variable mhpmcounter31h [expr { 0xB9F }]

  # machine counter setup
  variable MCOUNTINHIBIT [expr { 0x320 }]
  variable MHPMEVENT3    [expr { 0x323 }]
  variable MHPMEVENT4    [expr { 0x324 }]
  variable MHPMEVENT5    [expr { 0x325 }]
  variable MHPMEVENT6    [expr { 0x326 }]
  variable MHPMEVENT7    [expr { 0x327 }]
  variable MHPMEVENT8    [expr { 0x328 }]
  variable MHPMEVENT9    [expr { 0x329 }]
  variable MHPMEVENT10   [expr { 0x32A }]
  variable MHPMEVENT11   [expr { 0x32B }]
  variable MHPMEVENT12   [expr { 0x32C }]
  variable MHPMEVENT13   [expr { 0x32D }]
  variable MHPMEVENT14   [expr { 0x32E }]
  variable MHPMEVENT15   [expr { 0x32F }]
  variable MHPMEVENT16   [expr { 0x330 }]
  variable MHPMEVENT17   [expr { 0x331 }]
  variable MHPMEVENT18   [expr { 0x332 }]
  variable MHPMEVENT19   [expr { 0x333 }]
  variable MHPMEVENT20   [expr { 0x334 }]
  variable MHPMEVENT21   [expr { 0x335 }]
  variable MHPMEVENT22   [expr { 0x336 }]
  variable MHPMEVENT23   [expr { 0x337 }]
  variable MHPMEVENT24   [expr { 0x338 }]
  variable MHPMEVENT25   [expr { 0x339 }]
  variable MHPMEVENT26   [expr { 0x33A }]
  variable MHPMEVENT27   [expr { 0x33B }]
  variable MHPMEVENT28   [expr { 0x33C }]
  variable MHPMEVENT29   [expr { 0x33D }]
  variable MHPMEVENT30   [expr { 0x33E }]
  variable MHPMEVENT31   [expr { 0x33F }]

  # debug/trace registers
  variable tselect    [expr { 0x7A0 }]
  variable tdata1     [expr { 0x7A1 }]
  variable tdata2     [expr { 0x7A2 }]
  variable tdata3     [expr { 0x7A3 }]

  # debug mode registers
  variable DCSR       [expr { 0x7B0 }]
  variable DPC        [expr { 0x7B1 }]
  variable DSCRATCH0  [expr { 0x7B2 }]
  variable DSCRATCH1  [expr { 0x7B3 }] 

  # machine configuration (0x30a-0x757)
  # machine non-maskable interrupt handling (0x740-0x744)

  variable PRIV       [expr {  4161 }]
}
