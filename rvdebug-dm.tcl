defn rvdebug-dm.tcl 2023-06-17
#============= rvdebug-dtm-dmi-dm.tcl =================
# 
#  2023-06-17  pds   initial cut


#incl rvdebug-dtm.tcl  ;# for primitives to use the DMI access bus

# for abstr_natural_word_size....
incl rvdebug-dm-abstractcs.tcl
incl rvdebug-dm-command.tcl
incl rvdebug-dm-progbuf.tcl
incl rvdebug-dm-data.tcl
incl rv32-instr-ext.tcl        ;# the concrete extensions of the RV32 ISA (CSR, I, A, M, F, D)

#
# DEBUG MODULE (DM)
#
#    all registers must implement
#    an DMI_ADDR for the DMI transaction, and
#    an "xfer" procedure that knows how to use it.
#

namespace eval DM {
  #-----
  # DM access bus primitives:
  #   ...
  #
  proc write {addr data} {         DTM::DMI::write $addr $data }
  proc read  {addr}      { return [DTM::DMI::read  $addr 0]    }
  proc xfer  {addr data} { write $addr $data ; return [read $addr] }  ;# both above
  #-----

  #=========================================
  # should be in DM::AI (Abstract Interface)
  #

  proc is_configured {} {
    variable progbuf_size_
    variable databuf_size_
    return [expr { ($progbuf_size_ != -1) && ($databuf_size_ != -1) }]
  }

  proc validate_ {value min max} {  ;# same as DTM::DMI::validate
    variable x
    if { $value < $min } { 
      set x $min
    } elseif { $value > $max } {
      set x $max
    } else {
      set x $value
    }
    return $x
  }

  #----- size of program buffer of an AI command
  #

  variable progbuf_size_  -1  ;# managed by hartinfo

  proc set_progbuf_size {size} {
    variable progbuf_size_   ;# managed by business logic, sourced from hartinfo.dataaddr
    set progbuf_size_ [validate_ $size 1 16]  ;# insure 1 <= num-pbuf-regs <= 16
  }

  #----- size of program buffer of an AI command
  #

  variable databuf_size_  -1  ;# managed by hartinfo

  proc set_databuf_size {size} {
    variable databuf_size_   ;# managed by business logic, sourced from hartinfo.datasize
    set databuf_size_ [validate_ $size 1 12]  ;# insure 1 <= num-dbuf-regs <= 12
  }

  #
  # resulting status of an AM command response
  #

  variable cmdstat_  ;# managed by implementations of xfer_

  proc cmd_fail {} {  ;# need to <<pulse dtmcs.dmireset>> and re-send ai instr in this case
    variable cmdstat_
    return [expr { $cmdstat_ == 1 }]
  }

  # rvdebug-dm-instr.tcl
  # data-buf <- reg-list <- cmd <- reg-list [<- prog-buf [, data-buf]]
  proc abstr_instr_r_type {regno dbuf} {
  }

  proc abstr_instr_e_type {instr rs2 rs1 rd} {
  }

  # rvdebug-dm-instr-ext.tcl
  proc abstr_instr_reg_rd {rs1}  { return [abstr-instr-r-type $csr 0] }
  proc abstr_instr_reg_wr {rd}  { return [abstr-instr-r-type $csr 0] }
#  proc abstr_instr_csr_rd {rd csr}  { return [abstr-instr-e-type $csr $rd] }
  proc abstr_instr_csr_wr {csr rs1} { return [abstr-instr-e-type $csr $rs1] }

  proc abstr_instr_csr_rd {csr regno} {
    # convert string to numeric ... DO NOT use braces of expr when strings are involved
    set csr [expr $csr]
    set regno [expr $regno]

    # define the program
    DM::PROGBUF::xfer 0 [::RV32::INSTR::CSR::rv32_instr_csrrs $regno $csr 0] 1  ;# progbuf0: (csrrs rd, csr, x0), write
    DM::PROGBUF::xfer 1 [::RV32::INSTR::CSR::rv32_instr_ebreak] 1               ;# progbuf1: (ebreak), write

    # execute the program
    abstr_prog

    # fetch program results and return them
    return [abstr_reg $regno 0]  ;# mode=read, (regtypestr=GPR)
  }
  #---?

  proc abstr_prog {} {
    # clear status
    DM::ABSTRACTCS::xfer 7  ;# cmderr=0b111 clear status bits

    # run the program
    #                   cmdtype aarsize regno  transfer write aarpostincrement postexec
    DM::COMMAND::xfer  0x00    2       0x0000 0        0     0                1    ;# reg, 32-bit, x, no-reg/mem, x, x, exec

    # check status
    DM::ABSTRACTCS::xfer 0  ;# cmderr=0 check status
  }

  proc abstr_reg {regno {mode 0} {regtyp GPR}} {  ;# mode (0=read, 1=write), regtyp (CSR, GPR, FPR, VR, XXR)
    # convert string to numeric ... DO NOT use braces of expr when strings are involved
    set regno [expr $regno]
    set mode [expr $mode]

    # map regno to its abstract command address -- see Table 3.3 of Debug Specification
    # GPR must always exist on any core per Unprivileged Specification
    # NOTE: on E31 Complex CSR are reachable only by abstract progbuf (i.e., csrxxx instructions)
    switch $regtyp {
      CSR { incr regno 0x0000 }
      GPR { incr regno 0x1000 }
      FPR { incr regno 0x1200 }
      VR  { incr regno 0x1400 }
      XXR { incr regno 0xC000 }
      default {}
    }

    # clear status
    DM::ABSTRACTCS::xfer 7  ;# cmderr=0b111 clear status bits

    # run program
    #            cmdtype aarsize regno  transfer write aarpostincrement postexec
    DM::COMMAND::xfer  0x00    2       $regno 1        $mode 0                0    ;# reg, 32-bit, s0, reg/mem, read/write, no-incr, no-exec

    # check status
    DM::ABSTRACTCS::xfer 0  ;# cmderr=0 check status

    # get result
    set reg_x [DM::DATA::xfer 0 0 0]  ;# data0, 0x0, read
    #DM::DATA::xfer 1 0 0  ;# data1, 0x0, read
    #DM::DATA::xfer 2 0 0  ;# data2, 0x0, read
    #DM::DATA::xfer 3 0 0  ;# data3, 0x0, read

    return $reg_x
  }

  proc abstr_natural_word_size {} {
    # search backward for largest aarsize which doesnt give an abstract command err
    # meaning the requested register size exists in the system

    for {set regsz 4} {$regsz >= 0} {incr regsz -1} {
      # clear status
      DM::ABSTRACTCS::xfer 7  ;# cmderr=0b111 clear status bits

      # run program ... use only the x0 GPR register, guaranteed to exist and not bother other code-in-process
      #                  cmdtype aarsize regno  transfer write aarpostincrement postexec
      DM::COMMAND::xfer  0x00    $regsz  0x1000 1        0     0                0    ;# reg, 32-bit, x0, reg/mem, read, no-incr, no-exec

      # check status
      set x [DM::ABSTRACTCS::xfer 0]  ;# cmderr=0 check status

      #  regsz exists if NO error(s) ... exception=3 otherwise
      if {[DM::ABSTRACTCS::cmderr $x] == 0} { break }
    }

    # resolve regsz to number of bits
    set regsz [expr { 8 * (1 << $regsz) }]  ;# 0=8-bits, 1=16-bits, ..., 4=128-bits

    return $regsz
  }

  #
  # should be in DM::AI (Abstract Interface)
  #=========================================
}

# required, per Debug Specification
namespace eval DM::DMCONTROL    { variable DMI_ADDR  0x10 }
namespace eval DM::DMSTATUS     { variable DMI_ADDR  0x11 }
namespace eval DM::HARTINFO     { variable DMI_ADDR  0x12 }

# required, per Debug Specification
namespace eval DM::HALTSUM {
  variable HALTSUM0_DMI_ADDR                         0x40
  variable HALTSUM1_DMI_ADDR                         0x13
  variable HALTSUM2_DMI_ADDR                         0x34
  variable HALTSUM3_DMI_ADDR                         0x35
}

# required, per Debug Specification
namespace eval DM::ABSTRACTCS   { variable DMI_ADDR  0x16 }
namespace eval DM::COMMAND      { variable DMI_ADDR  0x17 }
namespace eval DM::ABSTRACTAUTO { variable DMI_ADDR  0x18 }  ;# optional ?

namespace eval DM::PROGBUF {  ;# as many as shown in abstractcs.progbufsize
  variable PROGBUF0_DMI_ADDR             0x20
  variable PROGBUF1_DMI_ADDR             0x21
  variable PROGBUF2_DMI_ADDR             0x22
  variable PROGBUF3_DMI_ADDR             0x23
  variable PROGBUF4_DMI_ADDR             0x24
  variable PROGBUF5_DMI_ADDR             0x25
  variable PROGBUF6_DMI_ADDR             0x26
  variable PROGBUF7_DMI_ADDR             0x27
  variable PROGBUF8_DMI_ADDR             0x28
  variable PROGBUF9_DMI_ADDR             0x29
  variable PROGBUF10_DMI_ADDR            0x2A
  variable PROGBUF11_DMI_ADDR            0x2B
  variable PROGBUF12_DMI_ADDR            0x2C
  variable PROGBUF13_DMI_ADDR            0x2D
  variable PROGBUF14_DMI_ADDR            0x2E
  variable PROGBUF15_DMI_ADDR            0x2F
}

namespace eval DM::DATA {  ;# as many as shown in abstractcs.datacount
  variable DATA0_DMI_ADDR                0x04
  variable DATA1_DMI_ADDR                0x05
  variable DATA2_DMI_ADDR                0x06
  variable DATA3_DMI_ADDR                0x07
  variable DATA4_DMI_ADDR                0x08
  variable DATA5_DMI_ADDR                0x09
  variable DATA6_DMI_ADDR                0x0A
  variable DATA7_DMI_ADDR                0x0B
  variable DATA8_DMI_ADDR                0x0C
  variable DATA9_DMI_ADDR                0x0D
  variable DATA10_DMI_ADDR               0x0E
  variable DATA11_DMI_ADDR               0x0F
}

# reserved, not yet implemented
namespace eval DM::HARTARRAY {
  variable HAWINDOWSEL_DMI_ADDR          0x14
  variable HAWINDOW_DMI_ADDR             0x15
}

# reserved, not yet implemented
namespace eval DM::NEXTDM {
  variable NEXTDM_ADDR                   0x1D
}

# reserved, not yet implemented
namespace eval DM::SBCS {
  variable SBCS_DMI_ADDR                 0x38
  variable SBADDRESS0_DMI_ADDR           0x39   ;# [31:0]
  variable SBADDRESS1_DMI_ADDR           0x3A   ;# [63:32]
  variable SBADDRESS2_DMI_ADDR           0x3B   ;# [95:64]
  variable SBADDRESS3_DMI_ADDR           0x37   ;# [95:64]
  variable SBDATA0_DMI_ADDR              0x3C   ;# [31:0]
  variable SBDATA1_DMI_ADDR              0x3D   ;# [63:32]
  variable SBDATA2_DMI_ADDR              0x3E   ;# [95:64]
  variable SBDATA3_DMI_ADDR              0x3F   ;# [127:96]
}

# reserved, not yet implemented
namespace eval DM::CONFSTRPTR {
  variable CONFSTRPTR0_DMI_ADDR          0x19
  variable CONFSTRPTR1_DMI_ADDR          0x1A
  variable CONFSTRPTR2_DMI_ADDR          0x1B
  variable CONFSTRPTR3_DMI_ADDR          0x1C
}
