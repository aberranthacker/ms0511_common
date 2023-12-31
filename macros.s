# vim: set fileformat=unix filetype=gas tabstop=8 expandtab shiftwidth=4 autoindent :

.macro .ppudo_enqueue cmd:req, arg=0
  .if \arg != 0
    MOV  \arg, @$PPUCommandArg
  .endif
    MOV  \cmd, @$CCH0OD
.endm

.macro .ppudo_enqueue_ensure cmd:req, arg=0
    TSTB @$CCH0OS
    BPL  .-4
   .ppudo_enqueue \cmd, \arg
.endm

.macro .ppudo cmd:req
    MOV  \cmd, @$CCH2OD
.endm

.macro .ppudo_ensure cmd:req
    TSTB @$CCH2OS
    BPL  .-4
    .ppudo \cmd
.endm

.macro .inform_and_hang str
   .ppudo_enqueue_ensure $PPU_DebugPrintAt, $inform_and_hang_string\@
    BR   .
inform_and_hang_string\@:
   .byte 0, 1
   .asciz "\str"
   .even
.endm

.macro .inform_and_hang2 str
   .ppudo_enqueue_ensure $PPU_DebugPrintAt, $inform_and_hang2_string\@
    BR   .
inform_and_hang2_string\@:
   .byte 0, 2
   .asciz "\str"
   .even
.endm

.macro .inform_and_hang3 str
   .ppudo_enqueue_ensure $PPU_DebugPrintAt, $inform_and_hang3_string\@
    BR   .
inform_and_hang3_string\@:
   .byte 0, 3
   .asciz "\str"
   .even
.endm

.macro .check_for_loading_error file_name
    BCC no_loading_error\@
   .inform_and_hang2 "\file_name loading error"

no_loading_error\@:
.endm

# generic macros
.macro call addr
    JSR  PC,\addr
.endm

.macro .call cond=none, dst:req # CALL cc,nn
  .if \cond == "EQ" # equal (z)
    BNE  .+6
  .elseif \cond == "ZE" # zero
    BNE  .+6
  .elseif \cond == "NE" # not equal (nz)
    BEQ  .+6
  .elseif \cond == "NZ" # not zero
    BEQ  .+6
  .else
    .error "Unknown condition for conditional call"
  .endif
    JSR  PC,\dst
.endm

.macro .jmp cond=none, dst:req # JP cc,nn
  .if \cond == "EQ" # equal (z)
    BNE  .+6
  .elseif \cond == "ZE" # zero
    BNE  .+6
  .elseif \cond == "NE" # not equal (nz)
    BEQ  .+6
  .elseif \cond == "NZ" # not zero
    BEQ  .+6
  .elseif \cond == "CC" # carry clear
    BCS  .+6
  .elseif \cond == "CS" # carry set
    BCC  .+6
  .else
    .error "Unknown condition for conditional jump"
  .endif
    JMP  \dst
.endm

.macro return
    RTS  PC
.endm

.macro push reg
    MOV  \reg,-(SP)
.endm

.macro pop reg
    MOV  (SP)+,\reg
.endm

.macro bze dst
    BEQ  \dst
.endm

.macro bnz dst
    BNE  \dst
.endm

# RT-11 dependent macros
.macro .exit
    EMT  0350
.endm

.macro .tty_print addr
    MOV  \addr,R0
    EMT  0351
.endm

.macro .screen_lines_table
   .word 0x0180, 0x01D0, 0x0220, 0x0270, 0x02C0, 0x0310, 0x0360, 0x03B0 #  0
   .word 0x0400, 0x0450, 0x04A0, 0x04F0, 0x0540, 0x0590, 0x05E0, 0x0630 #  1
   .word 0x0680, 0x06D0, 0x0720, 0x0770, 0x07C0, 0x0810, 0x0860, 0x08B0 #  2
   .word 0x0900, 0x0950, 0x09A0, 0x09F0, 0x0A40, 0x0A90, 0x0AE0, 0x0B30 #  3
   .word 0x0B80, 0x0BD0, 0x0C20, 0x0C70, 0x0CC0, 0x0D10, 0x0D60, 0x0DB0 #  4
   .word 0x0E00, 0x0E50, 0x0EA0, 0x0EF0, 0x0F40, 0x0F90, 0x0FE0, 0x1030 #  5
   .word 0x1080, 0x10D0, 0x1120, 0x1170, 0x11C0, 0x1210, 0x1260, 0x12B0 #  6
   .word 0x1300, 0x1350, 0x13A0, 0x13F0, 0x1440, 0x1490, 0x14E0, 0x1530 #  7
   .word 0x1580, 0x15D0, 0x1620, 0x1670, 0x16C0, 0x1710, 0x1760, 0x17B0 #  8
   .word 0x1800, 0x1850, 0x18A0, 0x18F0, 0x1940, 0x1990, 0x19E0, 0x1A30 #  9
   .word 0x1A80, 0x1AD0, 0x1B20, 0x1B70, 0x1BC0, 0x1C10, 0x1C60, 0x1CB0 # 10
   .word 0x1D00, 0x1D50, 0x1DA0, 0x1DF0, 0x1E40, 0x1E90, 0x1EE0, 0x1F30 # 11
   .word 0x1F80, 0x1FD0, 0x2020, 0x2070, 0x20C0, 0x2110, 0x2160, 0x21B0 # 12
   .word 0x2200, 0x2250, 0x22A0, 0x22F0, 0x2340, 0x2390, 0x23E0, 0x2430 # 13
   .word 0x2480, 0x24D0, 0x2520, 0x2570, 0x25C0, 0x2610, 0x2660, 0x26B0 # 14
   .word 0x2700, 0x2750, 0x27A0, 0x27F0, 0x2840, 0x2890, 0x28E0, 0x2930 # 15
   .word 0x2980, 0x29D0, 0x2A20, 0x2A70, 0x2AC0, 0x2B10, 0x2B60, 0x2BB0 # 16
   .word 0x2C00, 0x2C50, 0x2CA0, 0x2CF0, 0x2D40, 0x2D90, 0x2DE0, 0x2E30 # 17
   .word 0x2E80, 0x2ED0, 0x2F20, 0x2F70, 0x2FC0, 0x3010, 0x3060, 0x30B0 # 18
   .word 0x3100, 0x3150, 0x31A0, 0x31F0, 0x3240, 0x3290, 0x32E0, 0x3330 # 19
   .word 0x3380, 0x33D0, 0x3420, 0x3470, 0x34C0, 0x3510, 0x3560, 0x35B0 # 20
   .word 0x3600, 0x3650, 0x36A0, 0x36F0, 0x3740, 0x3790, 0x37E0, 0x3830 # 21
   .word 0x3880, 0x38D0, 0x3920, 0x3970, 0x39C0, 0x3A10, 0x3A60, 0x3AB0 # 22
   .word 0x3B00, 0x3B50, 0x3BA0, 0x3BF0, 0x3C40, 0x3C90, 0x3CE0, 0x3D30 # 23
   .word 0x3D80, 0x3DD0, 0x3E20, 0x3E70, 0x3EC0, 0x3F10, 0x3F60, 0x3FB0 # 24
.endm
