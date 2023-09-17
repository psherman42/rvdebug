# rvdebug
Easy to use Tcl/OpenOCD based RISC-V debug tool

### First Things, *first*

Specify your hardware connection in `rvdebug.cfg` [Lines 25-68] for example as follows:

```
adapter driver ftdi
ftdi vid_pid 0x0403 0x6014
ftdi layout_init 0x0b08 0x0b1b  ;# TMS,TCK,TDI lines (out) and (push-pull)
```

For best results on a Windows system, use **Zadig** tool and install `libusbK` driver.

### Using `rvdebug`

`openocd -f rvdebug.cfg`

You should see either `---PASS---` or `***FAIL***` and a complete description of your target something like this:

```
testing TAP chain... bypass=01, bypass(0x1F)=00, riscv-rsvd=0000
identifying device... found mfrid=0x489 (SiFive Inc), partnum=0, ver=2 (0x20000913)
preparing transport module... found abits=7 idle=5 dmistat=0 version=1 (Debug Module version 0.13)
handling debug module ndmreset, to avoid startup race condition... hart halted
entering DMI-safe access area
examining system
number of hart(s)... found 1 with Debug Module version 0.13
natural word size... found XLEN=32
halt summary status... found haltsum<19:0>=0b00000000000000100001
hart information... found nscratch=1 dataaccess=1 datasize=1 dataaddr=0x380
preparing abstract module... found 16 program buffer(s) and 1 data buffer(s) , busy=0 , cmderr=0 (No Err)
system bus control and status... found version=0 busyerror=0 busy=0 readonaddr=0 access=0 autoincrement=0 readondata=0 error=0 asize=0 accesssupported=0
configuration string pointers... found 0x0, 0x0, 0x0, 0x0
examining system CSRs
mvendorid=0 (not implemented)
marchid=0 (not implemented)
mimpid=0 (not implemented)
mhartid=0 (not implemented)
misa=0x40101105 (MXLEN=32, RV32IMACU)
mcause=0x00000001 (Exception: Instruction access fault)
mtval=0x14009089
mepc=0x8e1a70b2
mtvec=0x00000000
mstatus=0x00001800 (sd=0, tsr=0, tw=0, tvm=0, mxr=0, sum=0, mprv=0, xs=U, fs=U, mpp=M, hpp=U, spp=U, pie=., ie=.)
mie=0x00000000 (ext=., tim=., sw=.)
leaving DMI-safe access area
Info : datacount=1 progbufsize=16
Info : Disabling abstract command reads from CSRs.
Info : Examined RISC-V core; found 1 harts
Info :  hart 0: XLEN=32, misa=0x40101105
Info : gdb port disabled
---PASS---
```

## What Can Go Wrong?

### The FTDI/USB cable might be unplugged

```
Error: no device found
Error: unable to open ftdi device with vid 0403, pid 6014, description 'C232HD-DDHSP-0', serial '*' at bus location '*'
ftdi failure, is USB unplugged? device_desc OK? pid_vid correct?
***FAIL***
```

### The target device might not have any power

```
testing TAP chain... bypass=01, bypass(0x1F)=01, riscv-rsvd=ffff
identifying device
cannot read chip id because TDO stuck high? maybe power? open-drain need pull-up? target latched up?
***FAIL***
```

### The JTAG cable wires might be very long or its signals very noisy

```
testing TAP chain... bypass=01, bypass(0x1F)=00, riscv-rsvd=0000
identifying device... found mfrid=0x1 (AMD), partnum=0, ver=0 (0x00000003)
preparing transport module... found abits=3 idle=0 dmistat=0 version=1 (Debug Module version 0.13)
handling debug module ndmreset, to avoid startup race condition... hart halted
entering DMI-safe access area
examining system
number of hart(s)...
no hart(s) found because dtm and dmi not healthy? maybe sel, halt, ack, reset logic not okay?
***FAIL***
```

Notice above that `mfrid` is suspiciously wrong even though the DTM appears to read out its information properly: `abits=3`, `version=1`, etc.

You might have seen an OpenOCD message like

```
Error: Unsupported DTM version: 8
Warn : target riscv.cpu.0 examination failed
Error: Target not examined yet
```

You might also have seen the *dreaded `unable to halt hart`* message like

```
Error: unable to halt hart 0
Error:   dmcontrol=0x80000001
Error:   dmstatus =0x00030c82
Error: Fatal: Hart 0 failed to halt during examine()
Warn : target riscv.cpu.0 examination failed
Error: Target not examined yet
```

All of these observations are often because the JTAG wires are too long, or because the JTAG signals are too noisy -- in particular the TCK signal. See below for an easy solution to remedy such signal line noise.

## How To Cure Noisy JTAG Signals

Simple! As close as practical and possible to target, put a 1 Meg Ohm resistor and a 1000 pF capacitor in parallel from **TCK** to ground. Make sure the OpenOCD `adapter speed` setting is less than `4000` KHz.

Although not necessary, it is a good idea to apply same RC filter above to **TMS** and **TDI** lines. The **TDO** line, however, should see a 30 ~ 50 Ohm resistor in series between the target and the end of the long JTAG cable wire. Notice that there is almost never any need for external signals like **TRST** or **SRST** -- with a properly functioning hardware interface, reset happens naturally within the JTAG protocol and state machine itself.

This cure was discovered by JTAG connection success when probing of the TCK line with an oscilloscope probe accidentally set to **x1** rather than **x10**. Careful examination led to 1 M Ohm and 1000 pF as an optimal filter time constant. Further ideas came from the [discussion of JTAG signals](https://electronics.stackexchange.com/a/174134). The problem root cause is noise and reflection on **TCK** wire due to huge cable capacitance which confuses the JTAG TAP state machine.

## How `rvdebug` works

It's all in Tcl, thus, everying is a string and a little cryptic. For a quick refresher see [Tcl Crash Course](https://openocd.org/doc/html/Tcl-Crash-Course.html) from OpenOCD documentation. Full reference is in the [Tcl Language Documentation](https://www.tcl-lang.org/man/tcl/TclCmd/contents.htm) although not every aspect is included in the minimal implementation of jim-tcl by OpenOCD.

Every `.tcl` file has a `defn this-filename.tcl YYYY-MM-DD` line at the top, and when needed a `.tcl` file might have one or more `incl some-other-filename.tcl` lines. The `defn` and `incl` macros are in `rvdebug.cfg`.

The main top-level program is in `rvdebug.cfg`. This is where the main OpenOCD function `jtag_init` (usually contained `openocd/src/jtag/startup.tcl`) is overridden instead to invoke procedure `rvdebug`. After it runs, control is passed to `rvdebug-handler` to interpret the results.

The heart of the program is in `rvdebug.tcl` and is described by the pictorial below.

```
#  model of register "objects"
#  that implements the Debug Specification
#
#                        +-------+
#                        |  DTM  |
#                        +---+---+
#                            |
#      +------------+--------+---+------------------------+
#      |            |            |                        |
#  +---+----+  +----+---+    +---+---+                 +--+--+
#  | BYPASS |  | IDCODE |    | DTMCS |                 | DMI |
#  +--------+  +--+-----+    +-------+                 +--+--+
#                 |                                       |
#           +-----+--+          +-------+------+-------+--+----+------+------+----------+--------+
#           | JEDEC  |          |       |      |       |       |      |      |          |        |
#           | JEP106 |    +-----+-----+ | +----+-----+ | +-----+----+ | +----+----+  +--+-----+  |
#           +---+----+    | DMCONTROL | | | DMSTATUS | | | HARTINFO | | | HARTSUM |  | XFER   |--+---+
#               |         +-----------+ | +----------+ | +----------+ | +---------+  | MANY   | XFER |
#           +---o----+                  |              |              |              | LITTLE | ONE  |
#           | JEDEC  |                  |              |              |              +--------+ BIG  |
#           | JEP106 |            +-----+----+   +-----+------+    +--+---+                  +-------+
#           | BANKn  |            | ABSTRACT |   | CONFSTRPTR |    | SBCS |
#           +--------+            +-----+----+   +------------+    +------+
#                                       |
#                                    +--+--+
#                                    | ISA |
#                                    +--+--+
#                                       |
#                                   +---+-------------+
#                                   |                 |
#                              +----+-+           +---+---+
#                              | REGS |           | INSTR |
#                              +--+---+           +---+---+
#                                 |                   |
#                     +------+--+-+---+      +----+---+----+-----+---+
#                     |      |  |     |      |    |        |     |   |
#                     | +--+--+ | +--+--+    | +--+--+ | +-+-+ +-+-+ |
#                     | | CSR | | | GPR |    | | CSR | | | I | | D | |
#                     | +-----+ | +-----+    | +-----+ | +---+ +---+ |
#                   +-+---+   +-+--+       +-+-+     +-+-+         +-+-+
#                   | FPR |   | VR |       | A |     | M |         | F |
#                   +-----+   +----+       +---+     +---+         +---+
#
#  2023-06-13  pds   initial cut
```

Critical to understanding the RISC-V Debug Specification is to notice that, depending on the ideosyncracies of hardware implementation the potential for a startup race condition exists when performing an `NDMRESET` action. If there is less than 2.5 Seconds (yes, that's 2500 mS) after pulsing `NDMRESET` then the DM (Debug Module) will become stuck in a persistently busy state and become completely unreachable. Full power-cycle is the only way to regain control of the DM.

* must first enable DM only (dmactive=1 (haltreq=0, ndmreset=0)), then halt hart (haltreq=1 (dmactive=1, ndmreset=0)),

* lastly reset non-debug system (ndmreset=1->0 (dmactive=1, haltreq=1)), sequentially not simultaneously, and in that order.

* when ndmreset delay is too short, write or read op from any other register than dmcontrol results in persistent DM busy (op=3) state.

* in persistent DM busy state, DM is completely unreachable, thus power-cycle is the only way to regain control of the DM.

Any desired user activity can be done in the *DMI-safe access area* block. For example, the discovery of a target by `examine_system` which is described in `rvdebug-util-examine.tcl`. 

```
#----- DMI-safe access area: read DMI bus ONLY when selected hart is HALTED, or busy op=3 condition results
#
echo "entering DMI-safe access area"

# the sifive implementation of the debug spec requires that the core be halted before
# trying to execute abstract commands. when a debugger wants to halt a single hart it
# selects it in hartsel and sets haltreq, then waits for allhalted to indicate that
# the hart is halted before clearing haltreq to 0.
# https://forums.sifive.com/t/a-problem-about-debug-module/746
#

# TIP (per Debug Spec, Section B.3):
# leave dmcontrol.haltreq=1 to catch and re-halt a hart that gets reset while it is already halted

...

echo "leaving DMI-safe access area"
#
#----- DMI-safe access area
```

Examples for various abstract commands with the program and data buffer are shown in the *demonstraton area* of `rvdebug.tcl`.

```
#---------- demonstration area
#
incl rvdebug-dm-abstractcs.tcl  ;# abstract program control and status
incl rvdebug-dm-progbuf.tcl     ;# abstract program instruction buffer
incl rvdebug-dm-data.tcl        ;# abstract program data buffer
incl rvdebug-dm-command.tcl     ;# abstract program command execution

DM::ABSTRACTCS::xfer  0               ;# maxprogbufnum=abstractcs.progbufsize-1, maxdatabufnum=abstractcs.datacount
DM::PROGBUF::xfer     0 0x5555aaaa 1  ;# progbufnum prognum [mode] (0=read, 1=write, n=0..15, dmi.abstractcs.progbufsize: 0=one-reg, 1=two-regs, ...)
DM::DATA::xfer        0 0xaaaa5555 0  ;# databufnum databuf [mode] (0=read, 1=write, n=0..11, dmi.abstractcs.datacount: 0=unkn, 1=one-reg, 2=two-regs, ...)
DM::COMMAND::xfer ...                 ;# control cmdtype ... after write, wait for abstractcs.busy=0
DM::ABSTRACTCS::xfer  7               ;# wait for busy=0, check cmderr bits (3) ... write 1 to clear them

#                     cmdtype aarsize regno       transfer write aarpostincrement postexec
DM::ABSTRACTCS::xfer  7        ;# cmderr=0b111 clear status bits
DM::COMMAND::xfer     0x00    2       0x1001      1        0     0                0    ;# reg, 32-bit, misa, reg/mem, read, no-incr, no-exec
DM::ABSTRACTCS::xfer  0        ;# cmderr=0 check status
DM::DATA::xfer        0 0 0    ;# data0, 0x0, read

#                        ccccccccccccsssssfffdddddooooooo    ;# o=opcode, f=func, s=souce-reg, d=dest-reg, c=csr
#                        |----------||---||-||---||-----|
DM::PROGBUF::xfer    0 0b00110000000100000010010001110011 1  ;# progbuf0, (csrrs x0, MISA, s0), write
DM::PROGBUF::xfer    1 0b00000000000100000000000001110011 1  ;# progbuf1, (ebreak), write
DM::ABSTRACTCS::xfer 7        ;# cmderr=0b111 clear status bits
DM::COMMAND::xfer    0x00    2       0x0000      0        0     0                1    ;# reg, 32-bit, x, no-reg/mem, x, x, exec
DM::ABSTRACTCS::xfer 0        ;# cmderr=0 check status
#
DM::ABSTRACTCS::xfer 7        ;# cmderr=0b111 clear status bits
DM::COMMAND::xfer    0x00    2       0x1008      1        0     0                0    ;# reg, 32-bit, s0, reg/mem, read, no-incr, no-exec
DM::ABSTRACTCS::xfer 0        ;# cmderr=0 check status
#
DM::DATA::xfer        0 0 0   ;# data0, 0x0, read
#DM::DATA::xfer       1 0 0   ;# data1, 0x0, read
#DM::DATA::xfer       2 0 0   ;# data2, 0x0, read
#DM::DATA::xfer       3 0 0   ;# data3, 0x0, read
#
#---------- demonstration area
```
