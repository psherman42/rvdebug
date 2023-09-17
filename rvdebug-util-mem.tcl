defn rvdebug-util-mem.tcl 2023-06-13
#============== rvdebug-util-mem.tcl ==================
# 
#  2021-11-22  pds   initial cut
#  2022-03-24  pds   mod asic_ram_load and asic_rom_load for deprecations: brace args of expr; replace mem2array with read_memory
#  2022-06-15  pds   create unbrick.cfg
#  2023-05-22  pds   revise for general devel and release forms
#  2023-06-13  pds   add numsecs; mod asic_rom_load allow for non-zero target load address; re-factor into rvdebug

proc numsecs {len {partnumstr ""}} {
  set len [expr { $len }]

  # 4K sectors, typ. most NOR flash
  # query defive RDSFDP 0x5A 8th Word JESD216A (Serial Flash Discoverable Parameters)
  # sector size also defined in ...src/flash/nor/core.h:45 (uint32_t) size
  switch $partnumstr {
    is25lp128d { set secsz 0x1000 }
    default { set secsz 0x1000 }
  }

  # w/modulus: tcl/tk, etc., and RISC-V ISA (w/RV32M remu instr)
  # w/o modulus: bash bc, and other ISA

  #-----
  # equivalent implementation in /bin/bash script, for use in, e.g., mk files, is shown below:
  #$(eval SECSZ=$(shell echo "ibase=16; 1000" | bc))
  #$(eval LEN=$(shell <${PROGRAM}-rom.bin wc -c))
  #$(eval ENDSEC=$(shell echo "(${LEN}/${SECSZ})+((${LEN}-(${LEN}/${SECSZ})*${SECSZ})>0)-1" | bc))
  #-----

  #              |<-----------------numsecs-------------------------->|
  #              |<--whole-->|   |<----------has remainder----------->|
##return [expr { ($len/$secsz) + (($len - ($len/$secsz) * $secsz) != 0) }]  ;# w/o modulus op
  return [expr { ($len/$secsz) + ((       $len % $secsz         ) != 0) }]  ;# with modulus op
}

proc x_test_case_numsecs {fname addr {ldaddr 0x00000000}} {
  set partnumstr "is25lp128d"  ;# RDSFDP (0x5A), 8th Word, see JESD216A

  set len [file size $fname]

  set begsec [expr { [numsecs $ldaddr $partnumstr] - 1 }]
  set endsec [expr { ${begsec} + [numsecs ${len} $partnumstr] - 1 }]

  echo "[test case] numsecs: addr=$addr ldaddr=$ldaddr begsec=$begsec endsec=$endsec"

  return 0
}

#--------------------------------------------------------------
#
# APPLICATION(S)
#

#
# asic_ram_load <pgm-name-prefix> [<addr> [no_run]]
#
#   Preverifies the target memory to make sure writing is even necessary.
#   Allows for loading only when other than default address specified,
#   such as when preparing overlay code or non-executable data.
#
#   Typical usage:
#   openocd -f fe310-g002.cfg -c "adapter speed 2000" -c init -c "asic_ram_load my_prog"\
#           -c shutdown -c exit
#   where my_prog-ram.bin has been linked for ram target addresses in the linker .lds script.

proc asic_ram_load { program {addr "0x80000000"} {no_run ""} } {
  halt 100  ;# includes wait_halt 100

  # in case of verify_image pass, message returned is ''
  # in case of verify_image fail, message returned is 'contents differ', diff lines, abrupt exit
  #

  set rc [catch {verify_image ${program}-ram.bin ${addr} bin} err]  ;# trap exit on verify fail
  if {[expr {$rc == 0}]} {
    echo "ram already up to date - nothing to do"
  } else {
    echo [load_image ${program}-ram.bin ${addr} bin]
    echo [verify_image ${program}-ram.bin ${addr} bin]
  }

  if {[expr {[string length $no_run] == 0}]} {
    echo [resume ${addr}]
  }
}

#
# asic_rom_load <pgm-name-prefix> [<addr> [no_run]]
#
#   Preverifies the target memory to make sure writing is even necessary.
#   When writing is necessary, prechecks the target memory to make sure
#   erasing is even necessary.
#   Determines smallest portion of target memory to work with, for
#   best programming speed and target memory endurance (lifetime).
#   Allows for loading only when other than default address specified,
#   such as when preparing overlay code or non-executable data.
#
#   assumes only one target, at position tap position 0, for now.
#
#   Typical usage:
#   openocd -f fe310-g002.cfg -c "adapter speed 2000" -c init -c "asic_rom_load my_prog"\
#           -c shutdown -c exit
#   where my_prog-rom.bin has been linked for rom target addresses in the linker .lds script.
#
#   --------------------------------------------------------------------
#   Fixes the following bugs and issues:
#
#   [flash erase_check num]
#   Does not work, and takes a very long time, because of
#   message 'Running slow fallback erase check - add working memory'
#   All sectors are being tested, not just the ones which will be programmed.
#   See src/flash/nor/core.c:344 default_flash_mem_blank_check(),
#   src/flash/nor/core.c:391 default_flash_blank_check(),
#   src/flash/nor/fespi.c:1077 fespi_flash = { .erase_check=default_flash_blank_check; },
#   Suggest adding member 'int is_needed;' to struct flash_sector (nor/core.h:41)
#   to make default implementations of blank_check more intelligent.
#
#   [flash write_image erase unlock filename offset type]
#   Does not work, because of
#   messages 'Warn : Failed to write memory via program buffer.'
#   and 'Warn : Failed to write memory via abstract access.'
#   and also very long running time due to above problem when 'erase' specified.
#
#   [program filename preverify verify offset]
#   Does not work, because of
#   messages 'Warn : Failed to write memory via program buffer.'
#   and 'Warn : Failed to write memory via abstract access.'
#
#   [flash verify_image filename offset type]
#   seems to work okay.
#   --------------------------------------------------------------------
#

proc asic_rom_load { program {addr "0x20000000"} {no_run ""} } {
  halt 100  ;# includes wait_halt 100

  set len [file size ${program}-rom.bin]
  set begsec 0
  set endsec [expr { ${begsec} + ([numsecs ${len} is25lp128d] - 1) }]

echo "beg=$begsec end=$endsec len=$len"

  set erased_value 255  ;# also defined in ...src/flash/nor/core.h:104 (uint8_t) erased_value
  set is_erased 1
  for {set i 0} { ($i <= $endsec) && $is_erased } {incr i} {
    #riscv.cpu.0 mem2array buf 8 [expr {${addr} + ${secsz} * $i}] ${secsz}  ;# list wid addr cnt
    set buf [riscv.cpu.0 read_memory [expr {${addr} + ${secsz} * $i}] 8 ${secsz}]  ;# addr wid cnt
    foreach idx [array names buf] {
      if {$buf($idx) != ${erased_value}} {
        set is_erased 0
      }
    }
  }

  # in case of verify_bank pass, message returned is 'contents match'
  # in case of verify_bank fail, message returned is 'contents differ', diff lines, abrupt exit
  #

  set rc [catch {flash verify_bank 0 ${program}-rom.bin} err]  ;# trap exit on verify fail
  if {[expr {$rc == 0}]} {
    echo "flash device already up to date - nothing to do"
  } else {
    echo [flash protect 0 ${begsec} ${endsec} off]
    if {! $is_erased} {
      echo [flash erase_sector 0 ${begsec} ${endsec}]
    }
    echo [flash write_bank 0 ${program}-rom.bin]
    echo [flash verify_bank 0 ${program}-rom.bin]
    echo [flash protect 0 ${begsec} ${endsec} on]
  }

  if {[expr {[string length $no_run] == 0}]} {
    echo [resume ${addr}]
  }
}
