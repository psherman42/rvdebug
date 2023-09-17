defn rvdebug-dmi-abstract-utils.tcl 2023-06-13
#======== rvdebug-dmi-abstract-utils.tcl ==============
# 
#  2023-06-13  pds   initial cut


incl rvdebug-dmi-abstract.tcl  ;# the abstract programming facility, to which these utilities belong

#
# ABSTRACT COMMAND REGISTER OPERATION
#

namespace eval DTM::DMI::DM::ABSTRACT {
  proc dtm_dmi_abstract_reg_exists {regsz} {
    # convert string to numeric ... DO NOT use braces of expr when strings are involved
    set regsz [expr $regsz]

    # map regsz to its abstract command size definition
    switch $regsz {
      128 { set regsz 4 }
      64 { set regsz 3 }
      32 { set regsz 2 }
      16 { set regsz 1}
      8 { set regsz 0 }
      default { set regsz 0 }
    }

    # clear status
    ::DTM::DMI::DM::ABSTRACT::dtm_dmi_abstractcs 7  ;# cmderr=0b111 clear status bits

    # run program ... use only the x0 GPR register, guaranteed to exist and not bother other code-in-process
    #                                             cmdtype aarsize regno  transfer write aarpostincrement postexec
    ::DTM::DMI::DM::ABSTRACT::dtm_dmi_abstractcmd  0x00    $regsz  0x1000 1        0     0                0    ;# reg, 32-bit, x0, reg/mem, read, no-incr, no-exec

    # check status
    set x [::DTM::DMI::DM::ABSTRACT::dtm_dmi_abstractcs 0]  ;# cmderr=0 check status

    # extract cmderr field ... regsz exists if NO error(s)
    set x [expr { !(($x >> 8) & ((1 << 3) - 1)) }]  ;# [10:8]

    return $x
  }

  proc dtm_dmi_abstract_reg {regno {mode 0} {regtyp GPR}} {  ;# mode (0=read, 1=write), regtyp (CSR, GPR, FPR, VR, XXR)
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
    ::DTM::DMI::DM::ABSTRACT::dtm_dmi_abstractcs 7  ;# cmderr=0b111 clear status bits

    # run program
    #                                            cmdtype aarsize regno  transfer write aarpostincrement postexec
    ::DTM::DMI::DM::ABSTRACT::dtm_dmi_abstractcmd  0x00    2       $regno 1        $mode 0                0    ;# reg, 32-bit, s0, reg/mem, read/write, no-incr, no-exec

    # check status
    ::DTM::DMI::DM::ABSTRACT::dtm_dmi_abstractcs 0  ;# cmderr=0 check status

    # get result
    set reg_x [DTM::DMI::DM::ABSTRACT::dtm_dmi_abstractdata 0 0 0]  ;# data0, 0x0, read
    #DTM::DMI::DM::ABSTRACT::dtm_dmi_abstractdata 1 0 0  ;# data1, 0x0, read
    #DTM::DMI::DM::ABSTRACT::dtm_dmi_abstractdata 2 0 0  ;# data2, 0x0, read
    #DTM::DMI::DM::ABSTRACT::dtm_dmi_abstractdata 3 0 0  ;# data3, 0x0, read

    return $reg_x
  }
}

#
# ABSTRACT COMMAND PROGRAM OPERATION
#

namespace eval DTM::DMI::DM::ABSTRACT {
  proc dtm_dmi_abstract_prog {} {
    # clear status
    ::DTM::DMI::DM::ABSTRACT::dtm_dmi_abstractcs 7  ;# cmderr=0b111 clear status bits

    # run the program
    #                                            cmdtype aarsize regno  transfer write aarpostincrement postexec
    ::DTM::DMI::DM::ABSTRACT::dtm_dmi_abstractcmd  0x00    2       0x0000 0        0     0                1    ;# reg, 32-bit, x, no-reg/mem, x, x, exec

    # check status
    ::DTM::DMI::DM::ABSTRACT::dtm_dmi_abstractcs 0  ;# cmderr=0 check status
  }
}
