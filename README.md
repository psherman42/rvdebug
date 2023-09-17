# rvdebug
Easy to use Tcl/OpenOCD based RISC-V debug tool

### First Things, *first*

Specify your hardware connection in `rvdebug.cfg` [Lines 25-68] for example as follows:

```
adapter driver ftdi

ftdi vid_pid 0x0403 0x6014

ftdi layout_init 0x0b08 0x0b1b  ;# TMS,TCK,TDI lines (out) and (push-pull)
```

For best results, use **Zadig** tool and install `libusbK` driver.

### Using `rvdebug`

`openocd -f rvdebug.cfg`

You should see either `---PASS---` or `***FAIL***` and a complete description something like this:

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

All of these observations are often because of JTAG wires too long, or JTAG signals too noisy -- in particular the TCK signal. See below for an easy solution to remedy such signal line noise.

## How To Cure Noisy JTAG Signals

Simple! As close as practical and possible to target, put 1 Meg Ohm and 1000 pF in parallel from TCK to ground. Make sure the OpenOCD `adapter speed` setting is less than `4000` KHz.

For best results, apply same RC filter to TMS and TDI lines, too.

The TDO line should see a 30 ~ 50 Ohm resistor in series with the end of the long JTAG cable wire.
