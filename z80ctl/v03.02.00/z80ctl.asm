; z80ctl 03.02.00 disassembly.
;
; Can be reassembled with zmac.  Suggested workflow is to make changes
; and verify that file still assembles to the original.  Under windows:
;
;	zmac z80ctl.asm
;	fc /b zout/z80ctl.cim z80ctl
;
; For Mac and Linux:
;
;	zmac z80ctl.asm
;	cmp zout/z80ctl.cim z80ctl
;
; If a code section needs to be converted to data, consult zout/z80ctl.lst
; to easily determine the data bytes.
;
; Ultimately this will be full source code that can be altered at will.
; Until then it should be good enough for patches to work.  That is, where
; calls are put over existing code that go to the end of the program where
; new functionality is added.
;
; Current status:
;	Not all data areas have been identified.
;	Much information from the Anonymous disassembly to import.
;	Not likely to work if any changes are made -- I think there are
;		addresses in data sections that need to be symbols.

		org	$70
vram_pos:	defs	2	; top left corner of screen in video RAM
cursor_xy:	defs	2	; cursor XY position (high = Y, low = X)
console_vec:	defs	2	; routine to handle next console output byte
console_flags:	defs	1	; output flags (guessing inverse mode, etc)
	; bit 1 - characters ^ and up output as byte 0, 1, 2, ...
	; bit 2 - output inverse characters if set

; $80 .. $17f is shadow copies of data send to I/O ports 0 .. $ff.
; However, the shadow copies are not always updated.  Probably only when
; single bits may need to be changed.

		org	$80
port_shadow:	defs	$100

sh_a0		equ	$120	; port shadow for $A0 - speaker
sh_de		equ	$15e	; port shadow for $DE - tranfer control latch
sh_df		equ	$15f	; port shadow for $DF - upper address latch
sh_ff		equ	$17f	; port shadow for $FF

; Data area $180 .. $3cff is initialized to 0.

prev_tick	equ	$180	; previous tick count
tick		equ	$181	; 30 HZ real time clock count
cnt_to_second	equ	$182	; countdown timer running at 1 Hz.
cnt_to_tick2	equ	$183	; countdown timer every 2 ticks
cnt_to_tick8	equ	$184	; countdown timer every 8 ticks (turns off bell)

base0		equ	$186	; base pointer of some common page0 memory block
clock0		equ	$188	; base0 + 0; real time clock related; 2 bytes
base0_4		equ	$18A	; base0 + 4; purpose unknown
base0_32	equ	$18C	; base0 + $20; purpose unknown
base0_60	equ	$18E	; base0 + $3c; purpose unknown
cmdbuf0		equ	$190	; base0 + $56c; 2 byte ptrs and 32 word command ring buffer
inputq0		equ	$192	; base0 + $368; where we send character input
base0_724	equ	$194	; base0 + $2d4; purpose unknown
console0	equ	$196	; base0 + $58; seems associated with console

; (base0) + 2 is halt shutdown flags.  Low 6 bits must be $15 for
; shutdown/restart to occur on cmd_halt or cmd_reboot.  And bit 6 ($40)
; disables some of the shutdown processing.

; Data buffers for output queued for each character device.  These are
; not ring buffers and appear to have no obvious protection from overflow.

		org	$198
dbuf_sio_A	defs	32
dbuf_sio_B	defs	32
dbuf_dev_4	defs	32
dbuf_dev_5	defs	32
dbuf_dev_6	defs	32
dbuf_dev_7	defs	32
dbuf_dev_8	defs	32
dbuf_dev_9	defs	32
dbuf_dev_10	defs	32
dbuf_dev_11	defs	32
dbuf_dev_12	defs	32
dbuf_printer	defs	32
dbuf_console	defs	32

; Device Control Block offsets
d_cnt		equ	4	; count of bytes in data buffer
d_num		equ	5	; device number
d_port		equ	6	; I/O port (some don't have this)
d_bufp		equ	7	; pointer to put next char in data buffer
d_buf		equ	9	; pointer to data buffer
d_write		equ	11	; write buffered data to device routine pointer
d_config	equ	13	; configure device (serial devices only)

; Device numbers (which index into the DCB table)
dev_console	equ	0
dev_printer	equ	3

num_dev		equ	13	; total number of devices

; $3600 .. $3cff is where all character device input is queued.  Organized as 6
; blocks of 256 bytes each.  The first byte is the number of input pairs in
; a block.  The second byte I think means that we're finished with the block
; and it can be queued for delivery (if flushed or something).
; Each pair is the device number followed by the data.  With 2 bookkeeping
; bytes per block there is room for 127 device/data pairs.  The device
; number may have the high bit set which seems to indicate the data is
; device status information rather than actual received input.
; Multiterminal may also put frame/overrun/parity error bits in 6 .. 4.

iq_writep	equ	$8d3	; pointer where next input is written
iq_writecnt	equ	$8d5	; number of blocks in queue
iq_writeblk	equ	$8d6	; block we're writing to, should always by
				; high(iq_writep - input_queue).
iq_readblk	equ	$8d7	; next block to be read from queue
iq_tmp		equ	$8d8	; temporary storage

iq_blk_num	equ	6
; Offsets from the start of the block.
iq_pair_cnt	equ	0	; byte 0 is count of pairs in block
iq_flag		equ	1	; byte 1 block ready to be queued
iq_pairs	equ	2	; byte 2 and on is pair storage

		org	$3600
input_queue	defs	iq_blk_num * 256

; Data area $3d00 .. $3fff is initialized to $ff.

; 68000 memory is accessed in pages via 16 KB window $8000 ... $BFFF.
; The upper 9 bits of the address (A22 .. A14) are the PG register.
; (A22 .. A15) of PG are set via port $DF (UAL).  A14 of PG is bit 7 of
; port $DE (TCL).

; Interrupt mode 2 is used and the interrupt vector table is at $7C00.

; A 256 byte ring buffer that messages are put into they are
; displayed on the console.  See ring_putc
ringbuf		equ	03c00h

video_RAM	equ	0f800h

; This initial chunk appears to be some kind of header.  I'm not entirely
; certain if the execution and load addresses are little or big endian.
; To be safe simply choose addresses that are a multiple of 256.

		org	03dcch
_begin:		defb	002h
		defb	006h
		defb	000h
		defb	014h
		defb	000h
		defb	000h
		defb	03dh
		defb	002h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		word	_start		; Execution address
		defb	000h
		defb	086h
		defb	000h
		defb	000h
		defb	001h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		word	int_copyright	; Load address
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h

; The program and data loaded into memory.

; Internal copyright message easily visible to anyone who looks at the file.
int_copyright:	ascii	'The use of this software is restricted by Copyright laws and the',10
		ascii	'licensing agreement.  Refer to the "Limited Warranty Statement",',10
		ascii	'Article IV, Parts D, F and G.',10
		ascii	'This software is not supported if any modifications are made',10
		ascii	'that were not supplied by Tandy System Software.',10
		ascii	'It is a federal crime to remove or alter a copyright message.',10
_3f4c:		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
checksum:	word	09e9bh		; note: read in big-endian order.
		defb	00ah
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
_start:		jp	boot

splash:		ascii	'[Z80 Control System  '
version:	ascii	' Version  3(120)  23-Mar-87]     ',0
		ascii	'Copyright (C) 1984,85,86,87 Tandy Corporation',10,'All Rights Reserved',10
boot:		di	
		ld	sp,035fah
; Compute checksum of entire program for copy protection purposes.
		ld	de,00000h
		ld	hl,_start
		ld	bc,03c02h
_4089:		ld	a,(hl)
		inc	hl
		add	a,e
		ld	e,a
		jr	nc,_4090
		inc	d
_4090:		dec	c
		jr	nz,_4089
		dec	b
		jr	nz,_4089
		ld	a,(checksum)
		ld	b,a
; This section is mostly not about the checksum.
;
; Perhaps also a bit of a trap to those who might blindly nop-out
; the checksum code as the value changed defaults to 0 so presumably
; it won't have a valid value.
;
; Ah, it is setting up the real time clock frequency.  0x7fff has a '5'
; if the real time clock is 25 Hz (i.e., half PAL frame rate).  Must be
; something set up by the boot code.
;
		ld	a,(07fffh)
		and	07fh
		ex	de,hl		; Oh, this is for the checksum
		cp	035h
		ld	a,019h		; 25 RTC interrupts/second
		jr	z,is_pal
		ld	a,01eh		; 30 RTC interrupts/second
is_pal:		ld	(rtc_hz),a
; Back to the checksum checking.
		ld	a,(checksum+1)
		ld	c,a
		or	a
		sbc	hl,bc		; NOP this instruction out to disable checksum.
; 4 meaningless instructions whose ASCII value is 'FDIV'.
; A signature/easter egg of legendary Tandy programmer Frank Durda IV.
		ld	b,(hl)
		ld	b,h
		ld	c,c
		ld	d,(hl)
		jr	z,checksum_OK
; Checksum didn't match, replace version string 'unsupported' message.
		ld	hl,checksum_fail_msg
		ld	de,version
_40be:		ld	a,(hl)
		rra	
		ccf	
		rla	
		ld	(de),a
		dec	hl
		inc	de
		or	a
		jr	nz,_40be
checksum_OK:	ld	hl,00180h
		ld	de,00181h
		ld	bc,03b7fh
		ld	(hl),000h
		ldir			; zero $180 .. $3cff
		ld	hl,03d00h
		ld	de,03d01h
		ld	bc,002ffh
		ld	(hl),0ffh
		ldir			; $3d00 .. $3fff set to $ff
		ld	a,0c3h		; JP opcode
		ld	(00038h),a
		ld	(00035h),a
		ld	hl,rst38	; RST 38 vector
		ld	(00039h),hl	; RST 38 will jump to the vector
		ld	hl,_43c9
		ld	(00036h),hl
		ld	a,080h
		ld	(sh_ff),a
		out	(0ffh),a
		ld	a,004h
		ld	(sh_de),a
		out	(0deh),a	; Halt 68000
; This z80ctl is only guaranteed to work with the new PAL so detect the
; old PAL and panic if found.  In particular, the new PAL changes bit 0
; of $DE to be a burst mode.  When set to 1 the Z-80 is given complete
; control of the 68000 memory bus.  In the old PAL bit 0 turns on some
; kind of byte-swapping mode and was unused in previous versions.
		ld	a,000h
		ld	(sh_df),a
		out	(0dfh),a
		ld	bc,(08000h)
		ld	de,0fd04h	
		ld	(08000h),de	; write known data
		ld	a,(sh_de)
		or	001h
		out	(0deh),a	; Turn on little-endian or burst mode
		ld	hl,(08000h)	; read known data
		and	0feh
		out	(0deh),a	; Turn off little-endian or burst mode
		ld	(08000h),bc	; restor test location.
		or	a
		sbc	hl,de		; HL != DE if little-endian mode
		jr	z,_415a
		call	panic
		ascii	'NewPal - Hardware Modification Required',13,10,0

_415a:		ld	de,(08006h)
		ld	a,00ch
		ld	(sh_de),a
		out	(0deh),a	; Reset 68000 (requires HALT bit, too)
		ld	a,000h
		ld	(sh_de),a
		out	(0deh),a	; 68000 can run free now
_416c:		ld	hl,(08006h)
		or	a
		sbc	hl,de
		jr	z,_416c
		ld	de,(08006h)
		ld	l,d
		ld	h,e
		set	7,h
		res	6,h
		ld	(base0),hl
		ld	hl,(base0)
		ld	de,005aeh
		add	hl,de
		ld	a,(00077h)
		ld	(hl),a
		ld	a,(00078h)
		inc	hl
		ld	(hl),a
		nop	
		nop	
		nop	
		call	page_0
		call	setup_intrvec
		call	get_cmdbuf0
		call	dma_init
		call	clock_init
		call	fdc_init
		call	hd_init
		call	console_init
		ld	hl,splash
		call	ring_print
		call	ring_printimm
		ascii	13,10,10,0
		call	char_dev_init
		call	_6ce9
		call	_5965
		ld	hl,(base0)
		ld	de,005afh
		add	hl,de
		ld	a,(hl)
		ld	(_5943),a
		ld	(stack_base),sp
		call	_7536
		ld	hl,00000h
		ld	(08006h),hl
		jr	main_loop

; cmd_go must be constantly set to 1 in order for 68000 commands to be dispatched.
; Interrupt $19 does that.

cmd_go:		defb	0
_41dd:		defb	0		; unused flag
stack_base:	word	0

main_loop:	xor	a
		ld	hl,cmd_go
		di	
		or	(hl)
		ld	(hl),0
		ei	
dispatch_call:	call	nz,dispatch_cmds ; patched to CALL in Model II
		ld	a,(003bfh)
		or	a
		call	nz,_5052
		call	_59d0
		call	console_update
		call	_4579
		ei	
		call	clock_update
		call	char_io_update
; Check if stack growing (or, less likely, shrinking).  If so then 
; something is going wrong.
		ld	hl,0
		add	hl,sp
		ld	de,(stack_base)
		or	a
		sbc	hl,de
		jp	z,main_loop
		call	panic
		ascii	'SckMud',0

dispatch_cmds:	ld	hl,(cmdbuf0)
		ld	b,(hl)		; get ring write point (head)
		inc	hl
		ld	a,(hl)		; get ring read point (tail)
		cp	b
		ret	z		; cmd buffer empty if head == tail
		inc	a
		ld	(hl),a		; consume command
		inc	hl
		and	01fh		; keep within 32 words of buffer
		rlca	
		ld	e,a
		ld	d,0
		add	hl,de		; HL now pointers to command
		call	exec_cmd
		jp	dispatch_cmds

; Commands from the 68000 are sent as follows:
; of them stored two bytes:  "0 CMD DEVN" and "xxxx xxx #".  The bits
; "CMD#" are combined to look up the handler in cmd_tab.
; BUG: Their table only has 13 entries; older code checked $0x .. $6x range.
; The first command byte is saved in C register, the second in B.
; (C & $F) is the device number.
; Bit 1 of B is used but that's all I see so far.

exec_cmd:	ld	a,(hl)
		ld	c,a		; save device number
		and	0f0h
		jp	m,panic_badmaj	; command must be in $0x .. $7x range
		rrca	
		rrca	
		ld	e,a		; command / 4
		inc	hl
		ld	a,(hl)
		ld	b,a
		and	1
		rlca	
		or	e
		ld	e,a
		ld	hl,cmd_tab
		ld	d,0
		add	hl,de
		ld	e,(hl)
		inc	hl
		ld	h,(hl)
		ld	l,e
		jp	(hl)

panic_badmaj:	call	panic
		ascii	'BadMaj',13,10,0

cmd_tab:	word	_459b		; x 000 xxxx  xxxx xxx 0
		word	bad_cmd		; x 000 xxxx  xxxx xxx 1
		word	_506f		; x 001 xxxx  xxxx xxx 0
		word	bad_cmd		; x 001 xxxx  xxxx xxx 1
		word	cmd_write	; x 010 xxxx  xxxx xxC 0 (C=1 cancel)
		word	cmd_config	; x 010 xxxx  xxxx xxx 1
		word	_59f2		; x 011 xxxx  xxxx xxx 0
		word	bad_cmd		; x 011 xxxx  xxxx xxx 1
		word	_6cf9		; x 100 xxxx  xxxx xxx 0
		word	_6ef8		; x 100 xxxx  xxxx xxx 1
		word	cmd_halt	; x 101 xxxx  xxxx xxx 0
		word	cmd_reboot	; x 101 xxxx  xxxx xxx 1

bad_cmd:	call	bugchk_print	; x 110 xxxx  xxxx xxx 0
		ascii	'Bd68Rq - Code: ',0
		call	ring_preqhex
		call	ring_printimm
		ascii	13,10,0
		ret	

get_cmdbuf0:	ld	de,(base0)
		ld	hl,0056ch
		add	hl,de
		ld	(cmdbuf0),hl
		xor	a
		ld	(_41dd),a	; seemingly only written once (and 0 initially)
		ret	

enable_cmds:	push	hl
		ld	hl,cmd_go
		ld	(hl),1
		pop	hl
		ei	
		reti	

bugchk_print:	call	ring_printimm
		ascii	13,10,'Bugchk: ',0
		jp	ring_printimm

panic:		di	
		ld	a,0ffh
		out	(0efh),a
		ld	a,004h
		ld	(sh_de),a
		out	(0deh),a	; Halt 68000
		ld	a,080h
		ld	(sh_ff),a
		out	(0ffh),a
		call	cursor_to_bottom
		call	ring_printimm
		ascii	13,10,0
		call	printimm
		ascii	27,'RD',0	; inverse character mode
		call	ring_printimm
		ascii	'Bughlt: ',0
		ex	(sp),hl
_42ec:		ld	a,(hl)
		inc	hl
		or	a
		jr	z,_42f6
		call	ring_putc
		jr	_42ec

_42f6:		call	printimm
		ascii	27,'R@',0	; normal character mode
		call	printimm
		ascii	13,10,0
		ex	(sp),hl
		jp	_571b

cursor_to_bottom:
		call	printimm
		ascii	27,'Y7',10,13,0	; bottom line of screen and start new line
		ret	

; RST 38 vector.  Some Model 12/16/6000 machines had bad chips that caused phantom
; opcode fetches of 0xFF.  This handler looks at the instruction before the return
; address and does a halt if a RST 38 called it.  Otherwise it prints a warning and
; returns back to the original address assuming it was a phantom fetch and that a
; retry will operate correctly.

rst38:		ex	(sp),hl
		push	af
		dec	hl
		ld	a,(hl)
		cp	0ffh
		jr	z,_4334
		call	bugchk_print
		ascii	'Rst7  Fetch',0
		call	ring_preqhex16
		call	ring_printimm
		ascii	13,10,0
		pop	af
		ex	(sp),hl
		ret	

_4334:		pop	af
		ex	(sp),hl
		di	
		push	hl
		push	af
		call	cursor_to_bottom
		call	ring_printimm
		ascii	13,10,0
		call	printimm
		ascii	27,'RD',0	; inverse character mode
		call	ring_printimm
		ascii	'Bughlt: Rst7  Additional:',0
; Show Z-80 registers and top of stack.
z80dump:	pop	hl
		call	ring_preqhex16
		push	bc
		pop	hl
		call	ring_preqhex16
		push	de
		pop	hl
		call	ring_preqhex16
		pop	hl
		call	ring_preqhex16
		push	ix
		pop	hl
		call	ring_preqhex16
		push	iy
		pop	hl
		call	ring_preqhex16
		ld	hl,00000h
		add	hl,sp
		call	ring_preqhex16
		call	ring_printimm
		ascii	13,10,'                         ',0
		pop	hl
		call	ring_preqhex16
		pop	hl
		call	ring_preqhex16
		pop	hl
		call	ring_preqhex16
		pop	hl
		call	ring_preqhex16
		pop	hl
		call	ring_preqhex16
		pop	hl
		call	ring_preqhex16
		pop	hl
		call	ring_preqhex16
		jp	_571b

_43c9:		di	
		push	hl
		push	af
		call	cursor_to_bottom
		call	ring_printimm
		ascii	13,10,0
		call	printimm
		ascii	27,'RD',0	; inverse character mode
		call	ring_printimm
		ascii	'Bughlt: Wnd7  Additional:',0
		jp	z80dump

a_ret:		ret	


ignore_intr:	ei	
		reti	

unknown_1:	push	af
		ld	a,1
		jr	unknown_interrupt_A

unknown_2:	push	af
		ld	a,2
		jr	unknown_interrupt_A

unknown_3:		push	af
		ld	a,3
		jr	unknown_interrupt_A

unknown_4:		push	af
		ld	a,4
		jr	unknown_interrupt_A

unknown_5:	push	af
		ld	a,5
unknown_interrupt_A:
		push	de
		push	hl
		ld	e,a
		ld	d,000h
		ld	hl,unkint_msg+15
		add	hl,de
		add	a,'0'
		ld	(hl),a
		pop	hl
		pop	de
		call	bugchk_print
unkint_msg:	ascii	'UnkInt - Code: ........',13,10,0
		pop	af
		ei	
		reti	

		push	de		; TODO!
		ld	e,(hl)
		inc	hl
		ld	d,(hl)
		ex	de,hl
		pop	de
jphl:		jp	(hl)

a_reti:		reti	

setup_intrvec:	im	2
		ld	a,07ch
		ld	i,a
		ld	b,004h
_4457:		call	a_reti		; clear pending interrupts?
		djnz	_4457
		ld	bc,$23*2
		ld	hl,intrvec
		ld	de,07c00h
		ldir			; set all $23 (35) interrupt vectors
		ret	

intrvec:	word	mt0_0_tx_intr	; $00
		word	mt0_1_tx_intr	; $01
		word	mt0_2_tx_intr	; $02
		word	ignore_intr	; $03
		word	mt1_0_tx_intr	; $04
		word	mt1_1_tx_intr	; $05
		word	mt1_2_tx_intr	; $06
		word	ignore_intr	; $07
		word	mt2_0_tx_intr	; $08
		word	mt2_1_tx_intr	; $09
		word	mt2_2_tx_intr	; $0A
		word	ignore_intr	; $0B
		word	00000h		; $0C
		word	00000h		; $0D
		word	00000h		; $0E
		word	00000h		; $0F
		word	sio_b_send_intr	; $10
		word	_64e4		; $11	SIO channel B receive?
		word	_648d		; $12	SIO channel B receive?
		word	_64b2		; $13	SIO channel B receive?
		word	sio_a_send_intr	; $14
		word	_64d8		; $15	SIO channel A receive?
		word	_6486		; $16	SIO channel A receive?
		word	_64ac		; $17	SIO channel A receive?
		word	unknown_1	; $18
		word	enable_cmds	; $19
		word	unknown_2	; $1A
		word	key_intr	; $1B
		word	_5487		; $1C
		word	unknown_3	; $1D
		word	unknown_4	; $1E
		word	unknown_5	; $1F
		word	_4747		; $20
		word	printer_intr	; $21
		word	_59c3		; $22
; Unreferenced data?
		defb	0b9h,0bbh,0b6h,0a9h
; Hidden message.  Stored in reverse with lower bit flipped.
; Says: '-  Unsupported Version]'.
		ascii	1,92,'onhrsdW!edusnqqtroT!!'
checksum_fail_msg:
		ascii	','
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	

fdc_init:	ld	hl,_456c
		ld	(00351h),hl
		xor	a
		ld	(00357h),a
		ld	(00358h),a
		ld	(0035ah),a
		ld	(00359h),a
		ld	ix,00004h
		ld	de,(base0)
		add	ix,de
		ld	(base0_4),ix
		ld	(ix+14h),a
		dec	a
		ld	(0033eh),a
		ld	iy,00361h
		ld	de,0000bh
		ld	b,004h
_454b:		ld	(iy+00h),000h
		ld	(iy+01h),000h
		add	iy,de
		djnz	_454b
		ld	hl,fdc_port_init
		jp	send_portz

fdc_port_init:	defb	0efh,0ffh	; FDC select
		defb	0e4h,0d0h	; FDC status
		defb	0e2h,040h	; PIO port A
		defb	0e2h,0cfh
		defb	0e2h,0f7h
		defb	0e2h,0b7h
		defb	0e2h,0feh
		defb	000h

_456c:		call	panic
		ascii	'UEXFIRQ',13,10,0

_4579:		ld	a,(00359h)
		or	a
		ret	z
		xor	a
		ld	(00359h),a
		ld	ix,(base0_4)
		ld	iy,(0033ah)
		ld	hl,(00351h)
		jp	(hl)

_458e:		call	bugchk_print
		ascii	'FdNoGo',13,10,0
		ret	

_459b:		ld	ix,(base0_4)
		bit	0,(ix+14h)
		jr	z,_458e
_45a5:		di	
		ld	b,001h
		call	_7786
		jr	z,_45b8
		ei	
		ld	hl,_45a5
		ld	(00351h),hl
		ld	(00359h),a
		ret	

_45b8:		ld	a,0ffh
		ld	(00357h),a
		xor	a
		ld	(0033dh),a
_45c1:		ld	a,004h
		ld	(00354h),a
		ld	a,003h
		ld	(00356h),a
		ei	
		ld	(ix+17h),000h
		ld	a,(ix+14h)
		ld	b,a
		and	01ch
		ld	(0033ch),a
		ld	a,b
		cpl	
		cp	(ix+15h)
		jr	z,_45ec
		call	panic
		ascii	'0FDCMD',13,10,0

_45ec:		ld	a,(0033eh)
		cp	(ix+16h)
		jp	z,_462d
		ld	a,(ix+16h)
		cp	004h
		jp	nc,_47e4
		ld	b,0feh
		ld	iy,00361h
		ld	de,0000bh
_4606:		or	a
		jr	z,_4610
		rlc	b
		add	iy,de
		dec	a
		jr	_4606

_4610:		ld	a,b
		or	040h
		ld	(0016fh),a
		out	(0efh),a
		ld	(0033ah),iy
		ld	a,(iy+01h)
		out	(0e5h),a
		ld	a,(ix+16h)
		ld	(0033eh),a
		ld	b,0f7h
_4629:		djnz	_4629
		jr	_4631

_462d:		ld	iy,(0033ah)
_4631:		in	a,(0e0h)
		and	004h
		jr	z,_464e
		bit	2,(ix+19h)
		jr	z,_464e
		ld	(iy+00h),000h
		ld	a,0ffh
		out	(0efh),a
		ld	b,0f7h
_4647:		djnz	_4647
		ld	a,(0016fh)
		out	(0efh),a
_464e:		ld	a,(0033ch)
		cp	010h
		jp	z,_4832
		cp	000h
		jr	nz,_4666
		ld	hl,00001h
		ld	(0033fh),hl
		ld	(00341h),hl
		jp	_46ff

_4666:		bit	0,(iy+00h)
		ld	b,008h
		jp	z,_47e6
		ld	h,(ix+04h)
		ld	l,(ix+05h)
		ld	(0033fh),hl
		ld	(00341h),hl
		ld	hl,008d9h
		ld	(0034dh),hl
		ld	(0034fh),hl
		ld	a,(ix+07h)
		ld	(00345h),a
		ld	a,(ix+09h)
		ld	(00347h),a
		ld	a,(ix+0bh)
		ld	(00343h),a
		bit	1,(iy+09h)
		jr	z,_46ac
		bit	0,(iy+09h)
		jr	z,_46c9
		ld	a,(00345h)
		ld	h,a
		ld	a,(00347h)
		or	h
		jr	nz,_46c9
_46ac:		ld	a,(0016fh)
		and	07fh
		ld	(0016fh),a
		out	(0efh),a
		bit	0,(iy+09h)
		jr	z,_46d3
		ld	hl,00080h
		ld	(00349h),hl
		ld	a,01ah
		ld	(0034bh),a
		jr	_46e2

_46c9:		ld	a,(0016fh)
		or	080h
		ld	(0016fh),a
		out	(0efh),a
_46d3:		ld	h,(iy+05h)
		ld	l,(iy+04h)
		ld	(00349h),hl
		ld	a,(iy+06h)
		ld	(0034bh),a
_46e2:		ld	a,(00347h)
		cp	(iy+08h)
		jp	nc,_47e4
		ld	a,(0034bh)
		ld	c,a
		ld	a,(00343h)
		cp	c
		jp	nc,_47e4
		ld	a,(00345h)
		cp	(iy+02h)
		jp	nc,_47e4
_46ff:		ld	a,02dh
		ld	(00355h),a
		ld	a,008h
		ld	(00353h),a
		jp	_4832

_470c:		ld	a,(00357h)
		or	a
		jr	nz,_4729
		ld	a,(00356h)
		or	a
		ret	z
		dec	a
		ld	(00356h),a
		ret	nz
		ld	a,0ffh
		ld	(0033eh),a
		ld	a,0ffh
		ld	(0016fh),a
		out	(0efh),a
		ret	

_4729:		ld	a,(00354h)
		dec	a
		ld	(00354h),a
		ret	nz
		push	ix
		push	iy
		ld	ix,(base0_4)
		ld	iy,(0033ah)
		ld	b,004h
		call	_47e6
		pop	iy
		pop	ix
		ret	

_4747:		push	af
		xor	a
		ld	(00358h),a
		ld	(_6f4e),a
		ld	a,(_6f4d)
		out	(083h),a
		call	is_page_0
		jr	z,_4763
		ld	a,(00357h)
		ld	(00359h),a
		pop	af
		ei	
		reti	

_4763:		push	hl
		push	bc
		push	de
		push	ix
		push	iy
		call	a_reti
		ei	
		ld	ix,(base0_4)
		ld	iy,(0033ah)
		ld	hl,(00351h)
		call	jphl
		pop	iy
		pop	ix
		pop	de
		pop	bc
		pop	hl
		pop	af
		ei	
		ret	

_4786:		di	
		ld	hl,00000h
		ld	(0033fh),hl
		ld	(00341h),hl
		ld	a,(00357h)
		or	a
		jr	z,_47d9
		ld	a,(0033ch)
		cp	008h
		jr	nz,_47b7
		bit	6,(ix+14h)
		jr	nz,_47b7
		bit	0,(ix+19h)
		jr	z,_47b7
		ld	a,(0033dh)
		or	a
		jr	nz,_47b7
		ld	a,001h
		ld	(0033dh),a
		jp	_45c1

_47b7:		xor	a
		ld	(00357h),a
		ld	(00358h),a
		ld	(0033dh),a
		ld	(_6f4e),a
		ld	a,(ix+14h)
		or	020h
		and	0feh
		ld	(ix+14h),a
		ld	a,(sh_de)
		or	020h
		out	(0deh),a	; send CONT5 interrupt to 68000
		and	0dfh
		out	(0deh),a	; clear CONT5
_47d9:		ld	b,001h
		ld	a,(00339h)
		cp	b
		call	z,_779f
		ei	
		ret	

_47e4:		ld	b,020h
_47e6:		di	
		ld	a,(0016fh)
		ld	(ix+1ah),a
		in	a,(0e5h)
		ld	(ix+07h),a
		ld	a,(00347h)
		ld	(ix+09h),a
		in	a,(0e6h)
		ld	(ix+0bh),a
		ld	a,0d0h
		ld	(00164h),a
		out	(0e4h),a
		ld	a,b
		cp	004h
		jr	nz,_4818
		ld	a,0ffh
		ld	(0033eh),a
		ld	(0016fh),a
		out	(0efh),a
		ld	a,096h
_4815:		dec	a
		jr	nz,_4815
_4818:		ld	(ix+17h),b
		set	6,(ix+14h)
		in	a,(0e4h)
		and	002h
		jr	z,_4827
		in	a,(0e7h)
_4827:		ld	a,b
		cp	001h
		jp	nz,_4786
		ei	
		ret	

		nop	
		nop	
		nop	

_4832:		in	a,(0e4h)
		ld	(ix+1bh),a
		and	080h
		jr	z,_4868
		bit	1,(ix+19h)
		jr	z,_4863
_4841:		ld	a,(00355h)
		dec	a
		ld	(00355h),a
		jr	z,_4863
		ld	a,2
		ld	(cnt_to_tick2),a
		ret	

per_tick2:	ld	ix,(base0_4)
		ld	iy,(0033ah)
		in	a,(0e4h)		; floppy disk status register
		ld	(ix+1bh),a
		and	080h
		jr	z,_4868
		jr	_4841

_4863:		ld	b,004h
		jp	_47e6

_4868:		ld	a,(0033ch)
		cp	000h
		jp	z,_4b1f
		cp	010h
		jp	z,_4d49
		ld	a,(00345h)
		cp	(iy+01h)
		jp	nz,_49ca
		ld	a,(0033ch)
		cp	008h
		jr	z,_4887
		jr	_48b1

_4887:		ld	a,(0033dh)
		or	a
		jr	nz,_48db
		in	a,(0e4h)
		and	040h
		ld	b,010h
		jp	nz,_47e6
		ld	hl,(0034dh)
		ld	de,(0034fh)
		or	a
		sbc	hl,de
		jr	nz,_48a6
		call	_4a7e
		ret	nz
_48a6:		ld	hl,(0034dh)
		call	_77e8
		ld	b,0a0h
		jp	_48e5

_48b1:		ld	hl,(0034dh)
		ld	de,(00349h)
		add	hl,de
		ld	b,h
		ld	c,l
		ld	de,(0034fh)
		or	a
		sbc	hl,de
		jr	z,_48cb
		ld	hl,02000h
		add	hl,de
		or	a
		sbc	hl,bc
_48cb:		jr	nz,_48d1
		call	_4a7e
		ret	nz
_48d1:		ld	hl,(0034dh)
		call	_7802
		ld	b,080h
		jr	_48e5

_48db:		ld	hl,028d9h
		call	_7802
		ld	b,080h
		jr	_48e5

_48e5:		ld	a,(00343h)
		inc	a
		out	(0e6h),a
		ld	hl,_492e
		ld	(00351h),hl
		ld	a,(00347h)
		or	a
		jr	z,_4905
		ld	a,(0016fh)
		and	0bfh
		ld	(0016fh),a
		out	(0efh),a
		ld	a,00ah
		jr	_4911

_4905:		ld	a,(0016fh)
		or	040h
		ld	(0016fh),a
		out	(0efh),a
		ld	a,002h
_4911:		push	af
		call	_4d0c
		pop	af
		ld	a,b
		ld	(00164h),a
		out	(0e4h),a
		ld	a,003h
		ld	(00356h),a
		ld	a,004h
		ld	(00354h),a
		ld	a,0ffh
		ld	(00358h),a
		jp	_4a7e

_492e:		in	a,(0e4h)
		ld	(ix+1bh),a
		ld	c,a
		and	09ch
		jr	z,_4954
		xor	a
		bit	7,c
		ld	b,004h
		jp	nz,_47e6
		ld	a,(00353h)
		dec	a
		ld	(00353h),a
		ld	b,002h
		jp	z,_47e6
		cp	006h
		jp	z,_4a10
		jp	_4832

_4954:		ld	a,(00353h)
		cp	003h
		jr	nc,_4960
		ld	b,001h
		call	_47e6
_4960:		ld	hl,(0034dh)
		ld	de,(00349h)
		add	hl,de
		ld	(0034dh),hl
		ld	de,028d9h
		or	a
		sbc	hl,de
		jr	c,_4979
		ld	hl,008d9h
		ld	(0034dh),hl
_4979:		ld	hl,(0033fh)
		dec	hl
		ld	(0033fh),hl
		ld	a,h
		or	l
		jr	nz,_4991
_4984:		ld	hl,(00341h)
		ld	a,h
		or	l
		jp	z,_4786
		call	_4a7e
		jr	_4984

_4991:		ld	a,008h
		ld	(00353h),a
		ld	a,(0034bh)
		ld	b,a
		ld	a,(00343h)
		inc	a
		ld	(00343h),a
		cp	b
		jr	c,_49c7
		xor	a
		ld	(00343h),a
		ld	a,(00347h)
		inc	a
		ld	(00347h),a
		cp	(iy+08h)
		jr	c,_49c7
		xor	a
		ld	(00347h),a
		ld	a,(00345h)
		inc	a
		ld	(00345h),a
		cp	(iy+02h)
		jr	c,_49c7
		jp	_47e4

_49c7:		jp	_4832

_49ca:		ld	a,(0016fh)
		or	040h
		and	07fh
		ld	b,a
		bit	1,(iy+09h)
		jr	z,_49e6
		ld	a,(00345h)
		or	a
		jr	nz,_49e4
		bit	0,(iy+09h)
		jr	nz,_49e6
_49e4:		set	7,b
_49e6:		ld	a,b
		out	(0efh),a
		ld	a,(00345h)
		out	(0e7h),a
		ld	hl,_4a4b
		ld	(00351h),hl
		ld	a,(ix+18h)
		or	01ch
		ld	(00164h),a
		out	(0e4h),a
		ld	a,003h
		ld	(00356h),a
		ld	a,004h
		ld	(00354h),a
		ld	a,0ffh
		ld	(00358h),a
		jp	_4a7e

_4a10:		ld	a,(0016fh)
		or	040h
		and	07fh
		ld	b,a
		bit	1,(iy+09h)
		jr	z,_4a26
		bit	0,(iy+09h)
		jr	nz,_4a26
		set	7,b
_4a26:		ld	a,b
		out	(0efh),a
		ld	hl,_4a4b
		ld	(00351h),hl
		ld	a,(ix+18h)
		or	00ch
		ld	(00164h),a
		out	(0e4h),a
		ld	a,003h
		ld	(00356h),a
		ld	a,004h
		ld	(00354h),a
		ld	a,0ffh
		ld	(00358h),a
		jp	_4a7e

_4a4b:		ld	a,(0016fh)
		out	(0efh),a
		in	a,(0e4h)
		ld	(ix+1bh),a
		ld	c,a
		and	098h
		jr	z,_4a76
		bit	7,c
		ld	b,004h
		jp	nz,_47e6
		ld	a,(00353h)
		dec	a
		ld	(00353h),a
		cp	006h
		jp	z,_4a10
		or	a
		jp	nz,_49ca
		ld	b,002h
		jp	_47e6

_4a76:		in	a,(0e5h)
		ld	(iy+01h),a
		jp	_4832

_4a7e:		di	
		ld	a,(0035ah)
		or	a
		jr	z,_4a87
_4a85:		ei	
		ret	

_4a87:		ld	a,(0033ch)
		cp	004h
		jr	z,_4ab7
		cp	000h
		jr	z,_4a85
		ld	hl,(00341h)
		ld	a,h
		or	l
		jr	z,_4a85
		ld	hl,(0034fh)
		ld	de,(00349h)
		add	hl,de
		ld	b,h
		ld	c,l
		ld	de,(0034dh)
		or	a
		sbc	hl,de
		jr	z,_4a85
		ld	hl,02000h
		add	hl,de
		or	a
		sbc	hl,bc
		jr	z,_4a85
		jr	_4ac3

_4ab7:		ld	hl,(0034dh)
		ld	de,(0034fh)
		or	a
		sbc	hl,de
		jr	z,_4a85
_4ac3:		ld	a,001h
		ld	(0035ah),a
		ei	
		ld	bc,(00349h)
		ld	hl,(0034fh)
		ld	a,(0033ch)
		cp	004h
		jr	nz,_4adc
		call	copy_to_68k
		jr	_4adf

_4adc:		call	copy_from_68k
_4adf:		di	
		xor	a
		ld	(0035ah),a
		ld	hl,(00341h)
		dec	hl
		ld	(00341h),hl
		ld	de,(00349h)
		ld	l,(ix+03h)
		ld	h,(ix+02h)
		add	hl,de
		ld	(ix+03h),l
		ld	(ix+02h),h
		jr	nc,_4b01
		inc	(ix+01h)
_4b01:		ld	hl,(0034fh)
		add	hl,de
		ld	(0034fh),hl
		ld	de,028d9h
		or	a
		sbc	hl,de
		jr	c,_4b17
		ld	hl,008d9h
		ld	(0034fh),hl
		ei	
_4b17:		ld	a,(00358h)
		or	a
		ret	z
		jp	_4a7e

_4b1f:		ld	(iy+09h),000h
		ld	hl,_4b3b
		ld	(00351h),hl
		ld	a,(ix+18h)
		or	008h
		out	(0e4h),a
		ld	a,003h
		ld	(00356h),a
		ld	a,004h
		ld	(00354h),a
		ret	

_4b3b:		in	a,(0e4h)
		and	040h
		jr	z,_4b49
		set	4,(iy+09h)
		set	4,(ix+13h)
_4b49:		ld	a,002h
		ld	(00353h),a
		ld	a,(0016fh)
		and	07fh
		or	040h
		ld	(0016fh),a
		out	(0efh),a
		ld	hl,_4b78
		ld	(00351h),hl
_4b60:		ld	hl,0035bh
		call	_7802
		call	_4d0c
		ld	a,0c0h
		out	(0e4h),a
		ld	a,003h
		ld	(00356h),a
		ld	a,004h
		ld	(00354h),a
		ret	

_4b78:		in	a,(0e4h)
		and	09ch
		jr	z,_4bd2
		ld	a,(00353h)
		dec	a
		ld	(00353h),a
		jr	nz,_4b60
		ld	a,002h
		ld	(00353h),a
		ld	hl,_4bb4
		ld	(00351h),hl
		ld	a,(0016fh)
		or	080h
		ld	(0016fh),a
		out	(0efh),a
_4b9c:		ld	hl,0035bh
		call	_7802
		call	_4d0c
		ld	a,0c0h
		out	(0e4h),a
		ld	a,003h
		ld	(00356h),a
		ld	a,004h
		ld	(00354h),a
		ret	

_4bb4:		in	a,(0e4h)
		ld	(ix+1bh),a
		and	09ch
		jr	z,_4bcb
		ld	a,(00353h)
		dec	a
		ld	(00353h),a
		jr	nz,_4b9c
		ld	b,040h
		jp	_47e6

_4bcb:		set	1,(iy+09h)
		jp	_4c8c

_4bd2:		ld	a,(0035eh)
		ld	(_4d03),a
		ld	a,001h
		out	(0e7h),a
		ld	hl,_4bf4
		ld	(00351h),hl
		ld	a,(ix+18h)
		or	018h
		out	(0e4h),a
		ld	a,003h
		ld	(00356h),a
		ld	a,004h
		ld	(00354h),a
		ret	

_4bf4:		in	a,(0e4h)
		inc	(iy+01h)
		ld	hl,_4c26
		ld	(00351h),hl
		ld	a,(0016fh)
		or	080h
		ld	(0016fh),a
		out	(0efh),a
		ld	a,002h
		ld	(00353h),a
_4c0e:		ld	hl,0035bh
		call	_7802
		call	_4d0c
		ld	a,0c0h
		out	(0e4h),a
		ld	a,003h
		ld	(00356h),a
		ld	a,004h
		ld	(00354h),a
		ret	

_4c26:		in	a,(0e4h)
		and	09ch
		jr	z,_4c7b
		ld	a,(00353h)
		dec	a
		ld	(00353h),a
		jr	nz,_4c0e
		ld	a,002h
		ld	(00353h),a
		ld	hl,_4c62
		ld	(00351h),hl
		ld	a,(0016fh)
		and	07fh
		ld	(0016fh),a
		out	(0efh),a
_4c4a:		ld	hl,0035bh
		call	_7802
		call	_4d0c
		ld	a,0c0h
		out	(0e4h),a
		ld	a,003h
		ld	(00356h),a
		ld	a,004h
		ld	(00354h),a
		ret	

_4c62:		in	a,(0e4h)
		ld	(ix+1bh),a
		and	09ch
		jr	z,_4c79
		ld	a,(00353h)
		dec	a
		ld	(00353h),a
		jr	nz,_4c4a
		ld	b,040h
		jp	_47e6

_4c79:		jr	_4c8c

_4c7b:		ld	a,(_4d03)
		or	a
		ld	b,040h
		jp	nz,_47e6
		set	0,(iy+09h)
		set	1,(iy+09h)
_4c8c:		ld	a,(0035eh)
		ld	b,a
		inc	b
		ld	hl,00040h
_4c94:		add	hl,hl
		djnz	_4c94
		ld	(iy+04h),l
		ld	(iy+05h),h
		bit	1,(iy+09h)
		ld	hl,_4d04
		jr	z,_4ca9
		ld	hl,_4d08
_4ca9:		ld	c,a
		ld	b,000h
		add	hl,bc
		ld	a,(hl)
		ld	(iy+06h),a
		ld	(iy+02h),04dh
		ld	(iy+03h),000h
		ld	(ix+0dh),04dh
		ld	(ix+0ch),000h
		ld	a,(iy+04h)
		ld	(ix+0fh),a
		ld	a,(iy+05h)
		ld	(ix+0eh),a
		ld	a,(iy+06h)
		ld	(ix+11h),a
		ld	(ix+10h),000h
		in	a,(0e4h)
		in	a,(0e0h)
		and	002h
		ld	a,001h
		jr	z,_4ce2
		inc	a
_4ce2:		ld	(iy+08h),a
		ld	(ix+12h),a
		ld	a,(iy+09h)
		ld	(ix+13h),a
		ld	hl,00000h
		ld	(0033fh),hl
		ld	(00341h),hl
		ld	(iy+00h),001h
		ld	a,000h
		ld	(00164h),a
		jp	_4786

_4d03:		nop	
_4d04:		ld	a,(de)
		dec	c
		ex	af,af'
		inc	b
_4d08:		inc	(hl)
		ld	a,(de)
		djnz	_4d13+1
_4d0c:		ld	a,(_6f4d)
		and	0fdh
		out	(083h),a
_4d13:		ld	(_6f4e),a
		ret	

		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
_4d49:		ld	b,001h
		call	_779f
		ld	(iy+02h),000h
		ld	a,(ix+05h)
		ld	(_5000),a
		ld	hl,_4dab
		ld	(00351h),hl
		ld	a,(ix+18h)
		ld	(_5001),a
		or	008h
		di	
		out	(0e4h),a
		ld	a,003h
		ld	(00356h),a
		ld	a,004h
		ld	(00354h),a
		ld	a,0ffh
		ld	(00358h),a
		ld	ix,_4f8c
		ld	(ix+01h),001h
		in	a,(0e0h)
		and	002h
		rrca	
		ld	(ix+04h),a
		ld	(ix+05h),a
		xor	001h
		ld	(ix+03h),a
		xor	001h
		ld	ix,_4fca
		ld	(_5002),ix
		ld	(ix+04h),a
		ld	(ix+01h),001h
		ld	(ix+05h),000h
		ld	(ix+03h),000h
		ei	
		ret	

_4dab:		in	a,(0e4h)
		ld	b,a
		and	0d8h
		jp	nz,_4f18
_4db3:		di	
		ld	b,001h
		call	_7786
		ei	
		jr	z,_4dc6
		ld	(00359h),a
		ld	hl,_4db3
		ld	(00351h),hl
		ret	

_4dc6:		ld	ix,(_5002)
		ld	a,(_5000)
		or	a
		jr	z,_4deb
		ld	a,(ix+03h)
		or	(ix+05h)
		jr	z,_4deb
		ld	a,(0016fh)
		or	080h
		ld	(0016fh),a
		out	(0efh),a
		ld	de,_4f94
		ld	ix,_4f8c
		jr	_4dfc

_4deb:		ld	de,_4fd2
		ld	ix,_4fca
		ld	a,(0016fh)
		and	07fh
		ld	(0016fh),a
		out	(0efh),a
_4dfc:		ld	(_5002),ix
		push	de
		ld	hl,008d9h
		ld	b,(ix+00h)
_4e07:		push	bc
		call	_4f2b
		ld	a,(ix+01h)
		cp	(ix+00h)
		jr	nz,_4e14
		xor	a
_4e14:		inc	a
		ld	(ix+01h),a
		pop	bc
		djnz	_4e07
		pop	de
		ld	a,(de)
		ld	b,a
		ld	c,004h
		inc	de
		ld	a,(de)
_4e22:		push	bc
_4e23:		ld	(hl),a
		inc	hl
		djnz	_4e23
		pop	bc
		dec	c
		jr	nz,_4e22
		ld	hl,out_F8_1
		ld	bc,00ef8h
		otir	
		call	_4d0c
		ld	hl,_4e60
		ld	(00351h),hl
		ld	a,0f0h
		di	
		out	(0e4h),a
		ld	a,003h
		ld	(00356h),a
		ld	a,004h
		ld	(00354h),a
		ld	a,0ffh
		ld	(00358h),a
		ei	
		ret	

out_F8_1:	defb	079h,0d9h,008h,0c4h,028h,014h,028h,085h,0e7h,08ah,0cfh,005h,0cfh,087h
_4e60:		in	a,(0e4h)
		ld	b,a
		and	0f0h
		jp	nz,_4f18
		ld	b,08ah
_4e6a:		djnz	_4e6a
		ld	ix,(_5002)
		ld	a,(ix+05h)
		cp	(ix+04h)
		jr	z,_4e94
		inc	a
		ld	(ix+05h),a
		call	_4f02
		ld	b,(ix+00h)
		ld	a,(ix+06h)
		add	a,(ix+01h)
		dec	a
		cp	b
		jr	c,_4e8d
		sub	b
_4e8d:		inc	a
		ld	(ix+01h),a
		jp	_4dc6

_4e94:		ld	(ix+05h),000h
		call	_4f02
		ld	a,(ix+03h)
		cp	04ch
		jr	z,_4edc
		inc	a
		ld	(ix+03h),a
		ld	b,001h
		call	_779f
		ld	b,(ix+00h)
		ld	a,(ix+07h)
		add	a,(ix+01h)
		dec	a
		cp	b
		jr	c,_4eb9
		sub	b
_4eb9:		inc	a
		ld	(ix+01h),a
		ld	hl,_4dab
		ld	(00351h),hl
		ld	a,(_5001)
		or	058h
		di	
		out	(0e4h),a
		ld	a,003h
		ld	(00356h),a
		ld	a,004h
		ld	(00354h),a
		ld	a,0ffh
		ld	(00358h),a
		ei	
		ret	

_4edc:		ld	(ix+05h),000h
		call	_4f02
		ld	hl,_4786
		ld	(00351h),hl
		ld	a,(_5001)
		or	008h
		di	
		out	(0e4h),a
		ld	a,003h
		ld	(00356h),a
		ld	a,004h
		ld	(00354h),a
		ld	a,0ffh
		ld	(00358h),a
		ei	
		ret	

_4f02:		ld	a,(ix+05h)
		and	001h
		xor	001h
		rrca	
		rrca	
		ld	b,a
		ld	a,(0016fh)
		and	0bfh
		or	b
		ld	(0016fh),a
		out	(0efh),a
		ret	

_4f18:		ld	ix,(base0_4)
		ld	(ix+1bh),b
		bit	6,a
		ld	b,010h
		jp	nz,_47e6
		ld	b,002h
		jp	_47e6

_4f2b:		ld	a,(de)
		inc	de
		inc	a
		jr	z,_4f67
		inc	a
		jr	z,_4f56
		dec	a
		dec	a
		jr	z,_4f40
		ld	b,a
		ld	a,(de)
		inc	de
_4f3a:		ld	(hl),a
		inc	hl
		djnz	_4f3a
		jr	_4f2b

_4f40:		ld	b,a
		ld	a,(de)
		inc	de
		ld	(hl),a
		inc	hl
		ld	a,(de)
		inc	de
		ld	(hl),a
		push	de
		ld	d,h
		ld	e,l
		inc	de
		dec	hl
		ld	bc,000feh
		ldir	
		ex	de,hl
		pop	de
		jr	_4f2b

_4f56:		ld	a,(ix+03h)
		ld	(hl),a
		inc	hl
		ld	a,(ix+05h)
		ld	(hl),a
		inc	hl
		ld	a,(ix+01h)
		ld	(hl),a
		inc	hl
		jr	_4f2b

_4f67:		ld	a,(de)
		ld	c,a
		inc	de
		ld	a,(de)
		ld	d,a
		ld	e,c
		ret	

		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
_4f8c:		defb	010h			
		defb	001h			
		defb	04ch			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	00fh			
		defb	00bh			
_4f94:		defb	080h			
		defb	04eh			
		defb	00ch			
		defb	000h			
		defb	003h			
		defb	0f5h			
		defb	001h			
		defb	0feh			
		defb	0feh			
		defb	001h			
		defb	002h			
		defb	001h			
		defb	0f7h			
		defb	016h			
		defb	04eh			
		defb	00ch			
		defb	000h			
		defb	003h			
		defb	0f5h			
		defb	001h			
		defb	0fbh			
		defb	000h			
		defb	06dh			
		defb	0b6h			
		defb	000h			
		defb	06dh			
		defb	0b6h			
		defb	001h			
		defb	0f7h			
		defb	036h			
		defb	04eh			
		defb	0ffh			
		defb	096h			
		defb	04fh			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
_4fca:		defb	01ah			
		defb	001h			
		defb	04ch			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	01ah			
		defb	014h			
_4fd2:		defb	028h			
		defb	0ffh			
		defb	006h			
		defb	000h			
		defb	001h			
		defb	0feh			
		defb	0feh			
		defb	001h			
		defb	000h			
		defb	001h			
		defb	0f7h			
		defb	00bh			
		defb	0ffh			
		defb	006h			
		defb	000h			
		defb	001h			
		defb	0fbh			
		defb	080h			
		defb	0e5h			
		defb	001h			
		defb	0f7h			
		defb	01bh			
		defb	0ffh			
		defb	0ffh			
		defb	0d4h			
		defb	04fh			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
_5000:		defb	000h			
_5001:		defb	000h			
_5002:		defb	000h			
		defb	000h			

hd_init:	ld	ix,00020h
		ld	de,(base0)
		add	ix,de
		ld	(base0_32),ix
		xor	a
		ld	(003b8h),a
		ld	(ix+14h),a
		ld	(003b7h),a
		dec	a
		ld	(003aah),a
		ld	hl,_54c0
		ld	(003b4h),hl
		call	_5615
		ld	hl,hd_port_init
		call	send_portz
		ld	iy,003c7h
		ld	de,00143h
		ld	b,004h
		ld	a,080h
_503a:		ld	(iy+00h),000h
		ld	(iy+0ah),a
		rrca	
		add	iy,de
		djnz	_503a
		ret	

hd_port_init:	defb	0c1h,00eh
		defb	0c4h,038h
		defb	0c4h,003h
		defb	0c4h,0d7h
		defb	0c4h,001h
		defb	000h

_5052:		xor	a
		ld	(003bfh),a
		ld	ix,(base0_32)
		ld	iy,(003a6h)
		ld	hl,(003c0h)
		jp	(hl)

_5062:		call	bugchk_print
		ascii	'HdNoGo',13,10,0
		ret	

_506f:		ld	ix,(base0_32)
		ld	a,(ix+14h)
		bit	0,a
		jr	z,_5062
		and	00ch
		ld	(003a8h),a
		ld	a,001h
		ld	(003b8h),a
		ld	hl,(base0_32)
		inc	hl
		ld	a,(hl)
		ld	(003c4h),a
		inc	hl
		ld	d,(hl)
		inc	hl
		ld	e,(hl)
		ld	(003c5h),de
		inc	hl
		ld	d,(hl)
		inc	hl
		ld	e,(hl)
		inc	hl
		ld	(003ach),de
		ld	d,(hl)
		inc	hl
		ld	e,(hl)
		inc	hl
		inc	hl
		ld	c,(hl)
		inc	hl
		inc	hl
		ld	a,(hl)
		ld	(003aeh),a
		ld	hl,003aah
		ld	a,(ix+16h)
		cp	(hl)
		jr	z,_50ec
		cp	004h
		jp	nc,_550f
		ld	(hl),a
		ld	iy,003c7h
		or	a
		jr	z,_50c9
		ld	b,a
		ex	de,hl
		ld	de,00143h
_50c4:		add	iy,de
		djnz	_50c4
		ex	de,hl
_50c9:		ld	(003a6h),iy
		rlca	
		rlca	
		rlca	
		or	020h
		ld	(0014eh),a
		out	(0ceh),a
		ld	a,(iy+19h)
		ld	(00149h),a
		out	(0c9h),a
		in	a,(0cfh)
		and	0e2h
		cp	040h
		jr	z,_50fe
		ld	b,004h
		jp	_5515

_50ec:		ld	iy,(003a6h)
		ld	hl,(003b0h)
		or	a
		sbc	hl,de
		jr	nz,_50fe
		ld	a,(003b2h)
		cp	c
		jr	z,_5109
_50fe:		ld	a,c
		ld	(003b2h),a
		ld	(003b0h),de
		call	_5686
_5109:		ld	a,(003a8h)
		cp	000h
		jp	z,_5299
		cp	008h
		jp	nz,_5211
		in	a,(0c0h)
		and	(iy+0ah)
		jp	nz,_5193
		ld	a,(003b2h)
		ld	(003beh),a
		ld	hl,(003b0h)
		ld	(003bch),hl
		ld	hl,(003ach)
		ld	(003bah),hl
		ld	hl,_5149
		ld	(003c2h),hl
		ld	hl,_5198
		ld	(003b4h),hl
_513c:		xor	a
		ld	(003b6h),a
		ld	a,(003aeh)
		inc	a
		ld	(0014bh),a
		out	(0cbh),a
_5149:		ld	a,030h
		out	(0cfh),a
		ld	a,00ah
		ld	(003b7h),a
_5152:		ld	b,002h
		di	
		call	_7786
		jr	z,_5169
		ei	
		ld	hl,_5152
_515e:		ld	(003c0h),hl
		ld	a,(003b8h)
		ld	(003bfh),a
		ei	
		ret	

; TODO: $3c4 is a 24 bit 68000 pointer

_5169:		ld	de,(003c5h)
		ld	b,d
		set	7,d
		res	6,d
		rl	b
		ld	a,(003c4h)
		rl	a
		ld	(sh_df),a
		out	(0dfh),a
		ld	a,(sh_de)
		rla	
		rl	b
		rra	
		ld	(sh_de),a
		out	(0deh),a
		ei	
		call	_78c8
		xor	a
		ld	(00339h),a
		ret	

_5193:		ld	b,010h
		jp	_5515

_5198:		in	a,(0cfh)
		xor	040h
		and	041h
		jp	nz,_5513
		ld	hl,(003ach)
		dec	hl
		ld	a,l
		or	h
		jp	z,_51b3
		ld	(003ach),hl
		call	_5459
		jp	_513c

_51b3:		bit	0,(ix+19h)
		jp	z,_54c0
		ld	a,(ix+0bh)
		ld	(003aeh),a
		ld	a,(003beh)
		ld	(003b2h),a
		ld	de,(003bch)
		ld	(003b0h),de
		call	_5686
		ld	hl,_51ea
		ld	(003c2h),hl
		ld	hl,_51f4
		ld	(003b4h),hl
_51dd:		xor	a
		ld	(003b6h),a
		ld	a,(003aeh)
		inc	a
		ld	(0014bh),a
		out	(0cbh),a
_51ea:		ld	a,020h
		out	(0cfh),a
		ld	a,00ah
		ld	(003b7h),a
		ret	

_51f4:		in	a,(0cfh)
		xor	040h
		and	041h
		jp	nz,_5513
		call	_5615
		ld	hl,(003bah)
		dec	hl
		ld	a,l
		or	h
		jp	z,_54c0
		ld	(003bah),hl
		call	_5466
		jr	_51dd

_5211:		ld	hl,_522a
		ld	(003c2h),hl
		ld	hl,_5253
		ld	(003b4h),hl
_521d:		xor	a
		ld	(003b6h),a
		ld	a,(003aeh)
		inc	a
		ld	(0014bh),a
		out	(0cbh),a
_522a:		di	
		ld	a,020h
		out	(0cfh),a
		ld	a,00ah
		ld	(003b7h),a
		ld	hl,(003c5h)
		ld	b,h
		set	7,h
		res	6,h
		ld	(_5297),hl
		rl	b
		ld	a,(003c4h)
		rla	
		ld	h,a
		ld	a,(sh_de)
		rla	
		rl	b
		rra	
		ld	l,a
		ld	(_5295),hl
		ei	
		ret	

_5253:		in	a,(0cfh)
		xor	040h
		and	041h
		jp	nz,_5513
_525c:		ld	b,002h
		di	
		call	_7786
		jr	nz,_528e
		ld	hl,(_5295)
		ld	(sh_de),hl
		ld	a,h
		out	(0dfh),a
		ld	a,l
		out	(0deh),a
		ei	
		ld	de,(_5297)
		call	_781a
		xor	a
		ld	(00339h),a
		ld	hl,(003ach)
		dec	hl
		ld	a,l
		or	h
		jp	z,_54c0
		ld	(003ach),hl
		call	_5459
		jp	_521d

_528e:		ei	
		ld	hl,_525c
		jp	_515e

_5295:		nop	
		nop	
_5297:		nop	
		nop	
_5299:		ld	a,00eh
		ld	(00141h),a
		out	(0c1h),a
		call	_5615
		ld	(ix+13h),000h
		res	4,(ix+13h)
		in	a,(0c0h)
		and	(iy+0ah)
		jr	z,_52b6
		set	4,(ix+13h)
_52b6:		ld	a,(iy+00h)
		or	a
		jr	z,_52c7
		set	6,(ix+14h)
		ld	(ix+17h),000h
		jp	_54c0

_52c7:		in	a,(0cfh)
		bit	6,a
		ld	b,004h
		jp	z,_5515
		ld	a,0aah
		out	(0cah),a
		in	a,(0cah)
		cp	0aah
		jp	nz,_5515
		ld	hl,_5299
		ld	(003c2h),hl
		ld	a,001h
		out	(0cah),a
		xor	a
		out	(0cdh),a
		ld	a,005h
		out	(0cch),a
		ld	hl,_52f7
		ld	(003b4h),hl
		ld	a,070h
		out	(0cfh),a
		ret	

_52f7:		in	a,(0cfh)
		and	011h
		jr	z,_52f7
		call	_5615
		ld	hl,_530b
		ld	(003b4h),hl
		ld	a,013h
		out	(0cfh),a
		ret	

_530b:		in	a,(0cfh)
		and	011h
		jr	z,_530b
		call	_5615
		ld	hl,_5323
		ld	(003b4h),hl
		ld	a,001h
		out	(0cch),a
		ld	a,070h
		out	(0cfh),a
		ret	

_5323:		in	a,(0cfh)
		and	011h
		jr	z,_5323
		in	a,(0ceh)
		and	0f8h
		ld	(0014eh),a
		out	(0ceh),a
		xor	a
		ld	(003b2h),a
		ld	(0014ch),a
		out	(0cch),a
		ld	(0014dh),a
		out	(0cdh),a
		ld	hl,00000h
		ld	(003b0h),hl
		inc	a
		ld	(0014bh),a
		out	(0cbh),a
		ld	hl,_535c
		ld	(003b4h),hl
		ld	a,020h
		out	(0cfh),a
		ld	a,00ah
		ld	(003b7h),a
		ret	

_535c:		in	a,(0cfh)
		xor	040h
		and	041h
		jp	nz,_5513
		push	iy
		pop	hl
		ld	de,0000bh
		add	hl,de
		push	hl
		ld	bc,010c8h
		inir	
		pop	hl
		call	_5615
		ld	e,(hl)
		inc	hl
		ld	d,(hl)
		ld	hl,$702e
		or	a
		sbc	hl,de
		jp	z,_5387
		ld	b,040h
		jp	_5515

_5387:		ld	a,003h
		ld	(0014bh),a
		out	(0cbh),a
		ld	hl,_539e
		ld	(003b4h),hl
		ld	a,020h
		out	(0cfh),a
		ld	a,00ah
		ld	(003b7h),a
		ret	

_539e:		in	a,(0cfh)
		xor	040h
		and	041h
		jp	nz,_5513
		push	iy
		pop	hl
		ld	de,0001bh
		add	hl,de
		push	hl
		ld	b,008h
		ld	c,0c8h
		inir	
		ld	b,060h
_53b7:		in	d,(c)
		in	e,(c)
		in	a,(c)
		in	a,(c)
		ld	(hl),e
		inc	hl
		ld	(hl),a
		inc	hl
		ld	(hl),d
		inc	hl
		djnz	_53b7
		pop	hl
		call	_5615
		ld	e,(hl)
		inc	hl
		ld	d,(hl)
		ld	hl,_622e
		or	a
		sbc	hl,de
		jr	z,_53e6
		ld	(iy+21h),000h
		ld	(iy+22h),000h
		ld	(iy+1fh),000h
		ld	(iy+20h),000h
_53e6:		ld	h,(iy+1fh)
		ld	l,(iy+20h)
		ld	d,(iy+13h)
		ld	e,(iy+14h)
		call	divmod
		ld	a,h
		or	l
		sub	001h
		ccf	
		ld	h,(iy+11h)
		ld	l,(iy+12h)
		sbc	hl,bc
		ld	(iy+02h),l
		ld	(iy+03h),h
		ld	(ix+0dh),l
		ld	(ix+0ch),h
		ld	h,(iy+17h)
		ld	l,(iy+18h)
		ld	(ix+0fh),l
		ld	(ix+0eh),h
		ld	(iy+04h),l
		ld	(iy+05h),h
		ld	h,(iy+15h)
		ld	l,(iy+16h)
		ld	(ix+10h),h
		ld	(ix+11h),l
		ld	(iy+06h),l
		ld	(iy+07h),h
		ld	l,(iy+14h)
		ld	(ix+12h),l
		ld	(iy+08h),l
		ld	h,(iy+19h)
		ld	l,(iy+1ah)
		srl	h
		rr	l
		srl	h
		rr	l
		ld	a,l
		ld	(iy+19h),a
		ld	(00149h),a
		out	(0c9h),a
		ld	(iy+00h),0ffh
		jp	_54c0

_5459:		ld	hl,003c6h
		ld	a,(hl)
		add	a,002h
		ld	(hl),a
		jr	nc,_5466
		ld	hl,003c4h
		inc	(hl)
_5466:		ld	hl,003aeh
		inc	(hl)
		ld	a,011h
		cp	(hl)
		ret	nz
		ld	(hl),000h
		ld	hl,003b2h
		inc	(hl)
		ld	a,(iy+08h)
		cp	(hl)
		jp	nz,_5686
		ld	(hl),000h
		ld	hl,(003b0h)
		inc	hl
		ld	(003b0h),hl
		jp	_5686

_5487:		push	af
		push	hl
		call	is_page_0
		jr	z,_549f
		ld	a,(003b8h)
		ld	(003bfh),a
		ld	hl,(003b4h)
		ld	(003c0h),hl
		pop	hl
		pop	af
		ei	
		reti	

_549f:		push	bc
		push	de
		push	ix
		push	iy
		call	a_reti
		ei	
		ld	ix,(base0_32)
		ld	iy,(003a6h)
		ld	hl,(003b4h)
		call	jphl
		pop	iy
		pop	ix
		pop	de
		pop	bc
		pop	hl
		pop	af
		ret	

_54c0:		di	
		ld	a,(ix+14h)
		or	020h
		and	0feh
		ld	(ix+14h),a
		ld	a,(sh_de)
		or	020h
		out	(0deh),a	; send CONT5 interrupt to 68000
		and	0dfh
		out	(0deh),a	; CONT5 off
		ld	hl,_54c0
		ld	(003b4h),hl
		xor	a
		ld	(003b8h),a
		ld	(003b7h),a
		ei	
		ret	

_54e5:		di	
		ld	a,(003b7h)
		or	a
		jr	nz,_54ee
		ei	
		ret	

_54ee:		dec	a
		ld	(003b7h),a
		ei	
		ret	nz
		ld	ix,(base0_32)
		ld	iy,(003a6h)
		call	bugchk_print
		ascii	'HdTimeOut',13,10,0
		ld	b,002h
		jr	_5515

_550f:		ld	b,020h
		jr	_5515

_5513:		ld	b,001h
_5515:		in	a,(0cfh)
		ld	(ix+1bh),a
		ld	c,a
		call	_5615
		in	a,(0c9h)
		ld	(ix+1ah),a
		ld	a,b
		cp	020h
		jr	z,_553e
		in	a,(0cdh)
		ld	(ix+06h),a
		in	a,(0cch)
		ld	(ix+07h),a
		in	a,(0ceh)
		and	007h
		ld	(ix+09h),a
		in	a,(0cbh)
		ld	(ix+0bh),a
_553e:		ld	(ix+17h),b
		ld	a,b
		cp	001h
		jr	nz,_554c
		ld	a,(003b6h)
		or	a
		jr	z,_5561
_554c:		set	6,(ix+14h)
		ld	a,b
		cp	004h
		jr	z,_5574
		cp	002h
		jr	z,_5574
		cp	001h
		jp	nz,_54c0
		ld	a,(003b6h)
_5561:		inc	a
		cp	004h
		jr	nz,_556d
		ld	(ix+17h),002h
		jp	_54c0

_556d:		ld	(003b6h),a
		ld	hl,(003c2h)
		jp	(hl)

_5574:		ld	a,0ffh
		ld	(003aah),a
		ld	a,010h
		out	(0c1h),a
		call	_560f
		ld	a,00ch
		out	(0c1h),a
		call	_560f
		call	_5627
		call	_560f
		in	a,(0cfh)
		bit	6,a
		push	af
		call	z,_55e1
		ld	d,001h
		ld	c,000h
		call	_5632
		ld	a,001h
		out	(0cch),a
		ld	a,070h
		out	(0cfh),a
_55a4:		in	a,(0cfh)
		and	011h
		jr	z,_55a4
		call	_5615
		ld	a,00eh
		out	(0c1h),a
		pop	af
		jp	nz,_54c0
		in	a,(0cfh)
		call	ring_puthex_spc
		call	ring_printimm
		ascii	13,10,0
		jp	_54c0

		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
_55e1:		call	bugchk_print
		ascii	'HDFail - Additional ',0
		ld	b,a
		ld	a,c
		call	ring_puthex_spc
		ld	a,b
		call	ring_puthex_spc
		ld	a,(003b7h)
		call	ring_puthex_spc
		ld	a,(ix+14h)
		call	ring_puthex_spc
		ret	

_560f:		ld	a,032h
_5611:		dec	a
		jr	nz,_5611
		ret	

_5615:		in	a,(0cfh)
		and	002h
		ret	z
		ld	a,010h
		out	(0c1h),a
		ld	a,00eh
		out	(0c1h),a
		ld	a,00dh
_5624:		dec	a
		jr	nz,_5624
_5627:		ld	a,(0014eh)
		out	(0ceh),a
		ld	a,(00149h)
		out	(0c9h),a
		ret	

_5632:		ld	a,c
		rlca	
		rlca	
		rlca	
		or	020h
		ld	(0014eh),a
		out	(0ceh),a
		ld	a,032h
_563f:		dec	a
		jr	nz,_563f
		ld	a,d
		or	a
		ld	a,013h
		jr	nz,_5657
		ld	h,(iy+02h)
		ld	l,(iy+03h)
		dec	hl
		ld	a,l
		out	(0cch),a
		ld	a,h
		out	(0cdh),a
		ld	a,070h
_5657:		out	(0cfh),a
		push	bc
_565a:		in	a,(0cfh)
		ld	b,a
		in	a,(0cfh)
		cp	b
		jr	nz,_565a
		bit	7,a
		jr	nz,_565a
		pop	bc
		ret	

		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
_5686:		ld	a,(iy+22h)
		or	a
		jr	z,_56a0
		ld	b,a
		ld	hl,(003a6h)
		ld	de,00023h
		add	hl,de
		ld	de,00003h
		ld	a,(003b0h)
_569a:		cp	(hl)
		jr	z,_56bd
_569d:		add	hl,de
_569e:		djnz	_569a
_56a0:		ld	hl,(003b0h)
		ld	a,(003b2h)
		ld	c,a
_56a7:		in	a,(0ceh)
		and	0f8h
		or	c
		ld	(0014eh),a
		out	(0ceh),a
		ld	a,l
		out	(0cch),a
		ld	a,h
		out	(0cdh),a
		ret	

_56b8:		dec	hl
		ld	a,c
		jp	_569d

_56bd:		ld	c,a
		inc	hl
		ld	a,(003b2h)
		cp	(hl)
		jr	nz,_56b8
		inc	hl
		ld	a,(003b1h)
		cp	(hl)
		jr	z,_56d1
		inc	hl
		ld	a,c
		jp	_569e

_56d1:		ld	a,(iy+22h)
		sub	b
		ld	e,a
		ld	c,(iy+14h)
		ld	b,008h
		xor	a
_56dc:		sla	e
		rla	
		cp	c
		jr	c,_56e4
		sub	c
		inc	e
_56e4:		djnz	_56dc
		ld	c,a
		ld	d,000h
		ld	l,(iy+02h)
		ld	h,(iy+03h)
		add	hl,de
		jp	_56a7

		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	

_571b:		di	
		ld	a,(_5943)
		ld	(reboot_on_halt),a
		call	page_0
		ld	hl,_5943
		jr	_5749

cmd_reboot:	ld	a,001h
		ld	(reboot_on_halt),a
		jr	shutdown

cmd_halt:	xor	a
		ld	(reboot_on_halt),a

shutdown:	call	page_0_ei
		ld	de,(base0)
		ld	hl,00002h
		add	hl,de
		ld	a,(hl)
		and	03fh
		cp	015h
		ret	nz
		ld	(_5964),a
_5749:		push	hl
		di	
		ld	de,(base0)
		ld	hl,00002h
		add	hl,de
		ld	a,(hl)
		and	040h
		jp	z,_584b
		ld	hl,ring_head
		ld	de,ringbuf
		ld	e,(hl)
		ld	bc,halt_msg
_5763:		ld	a,(bc)
		cp	000h
		jr	z,_576d
		ld	(de),a
		inc	e
		inc	bc
		jr	_5763

_576d:		ld	(hl),e
		di	
		ld	ix,(console0)
		push	ix
_5775:		ld	a,(ix+03h)
		cp	(ix+02h)
		jr	z,_57bb
		pop	hl
		push	hl
		ld	bc,00004h
		add	hl,bc
		ld	c,a
		ld	b,000h
		add	hl,bc
		ld	d,(hl)
		inc	a
		and	07fh
		ld	(ix+03h),a
		pop	hl
		push	hl
		ld	bc,00084h
		add	hl,bc
		ld	b,(ix+00h)
		ld	c,(ix+01h)
		add	hl,bc
		ld	(hl),d
		inc	bc
		ld	hl,001f8h
		or	a
		sbc	hl,bc
		ld	(ix+00h),b
		ld	(ix+01h),c
		jr	nz,_5775
		ld	(ix+00h),000h
		ld	(ix+01h),000h
		jr	_5775

_57b5:		defb	02eh,06dh,073h,067h,000h,000h
_57bb:		pop	hl
		ld	de,00084h
		add	hl,de
		ld	de,008e1h
		ld	bc,001f8h
		ldir	
		ld	de,008d9h
		ld	hl,_57b5
		ld	bc,00006h
		ldir	
		ld	b,(ix+00h)
		ld	c,(ix+01h)
		ld	a,(ring_head)
		ld	d,a
		ld	iy,ringbuf
_57e1:		ld	hl,008e1h
		add	hl,bc
		ld	a,(iy+00h)
		ld	(hl),a
		inc	iy
		inc	bc
		ld	hl,001f8h
		or	a
		sbc	hl,bc
		jr	nz,_57f7
		ld	bc,00000h
_57f7:		dec	d
		jr	nz,_57e1
		ld	a,b
		ld	(008dfh),a
		ld	a,c
		ld	(008e0h),a
		ld	b,037h
		ld	hl,_5814
		xor	a
_5808:		add	a,(hl)
		inc	hl
		djnz	_5808
		cp	0e9h
		jp	nz,_584b
		ld	hl,008d9h
_5814:		in	a,(0cfh)
		and	002h
		jr	z,_5827
		ld	a,010h
		out	(0c1h),a
		ld	a,00eh
		out	(0c1h),a
		ld	a,00ch
_5824:		dec	a
		jr	nz,_5824
_5827:		xor	a
		out	(0cch),a
		out	(0cdh),a
		ld	a,020h
		out	(0ceh),a
		ld	a,011h
		out	(0cbh),a
		ld	a,030h
		out	(0cfh),a
		ld	bc,000c8h
		otir	
		otir	
_583f:		in	a,(0cfh)
		ld	b,a
		in	a,(0cfh)
		cp	b
		jr	nz,_583f
		bit	7,a
		jr	nz,_583f
_584b:		pop	hl
		ld	a,(reboot_on_halt)
		or	a
		jr	nz,_5868
		ld	a,(hl)
		and	080h
		jp	z,_58bb
		call	printimm
		ascii	13,10,'[Parking',0
		jr	_5878

_5868:		call	printimm
		ascii	13,10,'[Restoring',0
_5878:		call	printimm
		ascii	' Hard Drive:',0
		ld	iy,003c7h
		ld	de,00143h
		ld	b,004h
		ld	c,000h
		ld	a,00ch
		out	(0c1h),a
_5897:		ld	a,(iy+00h)
		or	a
		jr	z,_58b1
		ld	a,020h
		call	putc
		ld	a,c
		add	a,030h
		call	putc
		push	de
		ld	a,(reboot_on_halt)
		ld	d,a
		call	_5632
		pop	de
_58b1:		inc	c
		add	iy,de
		djnz	_5897
		call	printimm
		ascii	']',0
_58bb:		ld	a,004h
		ld	(sh_de),a
		out	(0deh),a	; Halt 68000
		ld	hl,halt_msg
		call	print
		ld	a,(reboot_on_halt)
		or	a
		jr	nz,reboot
		ld	ix,(clock0)
		res	1,(ix+00h)
_58d6:		call	clock_update
		jr	_58d6

reboot:		di	
		ld	a,000h
		out	(0ffh),a
		ld	a,0c3h
		ld	b,006h
_58e4:		out	(0f8h),a
		djnz	_58e4
		ld	a,003h
		out	(0c4h),a
		out	(0c5h),a
		out	(0c6h),a
		out	(0c7h),a
		out	(0f0h),a
		out	(0f1h),a
		out	(0f2h),a
		out	(0f3h),a
		out	(074h),a
		out	(075h),a
		out	(076h),a
		out	(077h),a
		out	(064h),a
		out	(065h),a
		out	(066h),a
		out	(067h),a
		ld	a,018h
		out	(0f6h),a
		out	(0f7h),a
		ld	a,000h
		out	(083h),a
		ld	bc,00000h
		ld	a,00ah
_5919:		dec	c		; fairly considerable pause
		jr	nz,_5919
		dec	b
		jr	nz,_5919
		dec	a
		jr	nz,_5919
		ld	a,010h
		out	(0c1h),a
		ld	a,0ffh
		out	(0efh),a
		ld	a,0d0h
		out	(0e4h),a
		ld	a,008h
		out	(041h),a
		ld	b,004h
_5934:		djnz	_5934
		xor	a
		out	(041h),a
		out	(0c1h),a
		ld	a,001h
		out	(0f9h),a	; enable boot ROM
		jp	00000h		; restart the system

reboot_on_halt:	defb	0
_5943:		nop	
halt_msg:	ascii	13,10,'[Z80 Control System Halted]',13,10,0

_5964:		nop	

_5965:		ld	ix,0003ch
		ld	de,(base0)
		add	ix,de
		ld	(base0_60),ix
		xor	a
		ld	(ix+14h),a
		ld	(0039fh),a
		ld	(0039ah),a
		ld	(00399h),a
		ld	hl,_59c3
		ld	(00394h),hl
		ld	hl,_5fab
		ld	(07c44h),hl
		ld	a,0bbh
		out	(042h),a
		in	a,(042h)
		or	a
		jr	z,_59af
		ld	iy,003a0h
		ld	de,00003h
		ld	b,002h
_599e:		ld	(iy+00h),000h
		ld	(iy+01h),000h
		ld	(iy+02h),000h
		add	iy,de
		djnz	_599e
		ret	

_59af:		ld	de,_59fc
		ld	hl,_59bb
		ld	bc,00003h
		ldir	
		ret	

_59bb:		jp	_59be

_59be:		ld	b,004h
		jp	_616e

_59c3:		call	bugchk_print
		ascii	'IoFake',13,10,0
		ret	

_59d0:		ld	a,(00399h)
		or	a
		ret	z
		xor	a
		ld	(00399h),a
_59d9:		ld	ix,(base0_60)
		ld	iy,(0038dh)
		ld	hl,(0039bh)
		jp	(hl)

_59e5:		call	bugchk_print
		ascii	'IoNoGo',13,10,0
		ret	

_59f2:		ld	ix,(base0_60)
		bit	0,(ix+14h)
		jr	z,_59e5
_59fc:		ld	a,001h
		ld	(0039ah),a
		xor	a
		ld	(ix+17h),a
		ld	a,(ix+14h)
		ld	b,a
		and	09ch
		ld	(0038fh),a
		ld	a,(ix+16h)
		cp	002h
		jp	nc,_6039
		rrca	
		rrca	
		rrca	
		ld	(_61cc),a
		ld	iy,003a0h
		or	a
		jr	z,_5a28
		ld	de,00003h
		add	iy,de
_5a28:		ld	(0038dh),iy
		ld	(iy+01h),000h
		ld	hl,(base0_60)
		ld	de,00004h
		add	hl,de
		ld	d,(hl)
		inc	hl
		ld	e,(hl)
		ld	(00392h),de
		inc	hl
		ld	de,_61cd
		ld	bc,00004h
		ldir	
		ld	a,(0038fh)
		and	07fh
		jp	z,_5c19
		cp	010h
		jp	z,_5d04
		bit	0,(iy+00h)
		jp	z,_6039
		cp	004h
		jr	z,_5a7c
		bit	0,(iy+02h)
		ld	b,010h
		jp	nz,_603f
		cp	008h
		jp	z,_5b3c
		call	bugchk_print
		ascii	'IoBozo',13,10,0
		jp	_5fed

_5a7c:		ld	hl,_5aac
		ld	(00397h),hl
		ld	hl,_5af7
		ld	(00394h),hl
		ld	a,028h
		ld	(out_40),a
_5a8d:		ld	b,004h
		di	
		call	_7786
		ei	
		jp	z,_5aa8
		ld	hl,_5a8d
_5a9a:		ld	(0039bh),hl
		ld	a,(0039ah)
		ld	(00399h),a
		ei	
		ret	

_5aa5:		call	_5c00
_5aa8:		xor	a
		ld	(00396h),a
_5aac:		ld	hl,(00392h)
		ld	de,0002ch
		or	a
		sbc	hl,de
		jr	nc,_5abb
		ld	de,(00392h)
_5abb:		ld	(_61d3),de
		ld	h,e
		ld	l,d
		dec	hl
		ld	(out_F8_2+2),hl
_5ac5:		call	_5ebc
		jp	z,_5ad3
		jp	c,_603f
		ld	hl,_5ac5
		jr	_5a9a

_5ad3:		call	_5f4b
		ld	hl,out_F8_2
		ld	bc,00cf8h
		otir	
		ld	a,0c1h
		out	(041h),a
		ret	

out_F8_2:	defb	06dh,040h,001h,000h,02ch,010h,0cdh,0d9h,008h,09ah,0cfh,087h
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
_5af7:		in	a,(041h)
		rlca	
		jr	nc,_5b2e
		ld	a,083h
		out	(0f8h),a
		in	a,(040h)
		call	_5f1d
		jp	nz,_603d
		bit	0,(iy+00h)
		jp	z,_5c8c
		ld	a,(_61d3)
		ld	b,a
		ld	c,000h
		ld	hl,008d9h
		call	_7978
		ld	hl,(00392h)
		ld	de,(_61d3)
		or	a
		sbc	hl,de
		ld	(00392h),hl
		jp	nz,_5aa5
		jp	_5fed

_5b2e:		call	bugchk_print
		ascii	'IoFakeI',13,10,0
		ret	

_5b3c:		ld	b,004h
		di	
		call	_7786
		ei	
		jp	z,_5b4c
		ld	hl,_5b3c
		jp	_5a9a

_5b4c:		ld	hl,_5bc6
		ld	(00394h),hl
		ld	hl,_5b6a
		ld	(00397h),hl
		ld	a,02ah
		bit	0,(ix+19h)
		jp	z,_5b63
		ld	a,02eh
_5b63:		ld	(out_40),a
_5b66:		xor	a
		ld	(00396h),a
_5b6a:		ld	hl,(00392h)
		ld	de,0002ch
		or	a
		sbc	hl,de
		jr	nc,_5b79
		ld	de,(00392h)
_5b79:		ld	(_61d3),de
		ld	b,e
		ld	c,d
		dec	bc
		ld	(out_F8_3+3),bc
		bit	0,(iy+00h)
		jr	z,_5b91
		inc	bc
		ld	hl,008d9h
		call	_7a47
_5b91:		call	_5ebc
		jp	z,_5ba0
		jp	c,_603f
		ld	hl,_5b91
		jp	_5a9a

_5ba0:		call	_5f4b
		ld	hl,out_F8_3
		ld	bc,00ef8h
		otir	
		ld	a,0c1h
		out	(041h),a
		ret	

out_F8_3:	defb	079h,0d9h,008h,001h,000h,014h,028h,0c5h,040h,09ah,0cfh,005h,0cfh,087h
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
_5bc6:		in	a,(041h)
		rlca	
		jp	nc,_5b2e
		ld	a,083h
		out	(0f8h),a
		in	a,(040h)
		call	_5f1d
		jp	nz,_603d
		bit	0,(iy+00h)
		jp	z,_5bf5
		ld	hl,(00392h)
		ld	de,(_61d3)
		or	a
		sbc	hl,de
		ld	(00392h),hl
		jp	z,_5fed
		call	_5c00
		jp	_5b66

_5bf5:		ld	a,(0038fh)
		cp	010h
		jp	z,_5e98
		jp	_5cda

_5c00:		ld	a,(_61d3)
		ld	d,a
		ld	e,000h
		or	a
		ld	hl,_61d0
_5c0a:		adc	a,(hl)
		ld	(hl),a
		jp	nc,_5c15
		dec	hl
		ld	a,000h
		jp	_5c0a

_5c15:		ex	de,hl
		jp	add_ptr_hl

_5c19:		bit	7,(ix+14h)
		jp	nz,_5ce1
		bit	0,(iy+00h)
		jp	nz,_6039
		res	4,(ix+13h)
		xor	a
		ld	(iy+02h),a
		ld	(00396h),a
		ld	hl,_5c38
		ld	(00397h),hl
_5c38:		call	_5ebc
		jr	z,_5c46
		jp	c,_603f
		ld	hl,_5c38
		jp	_5a9a

_5c46:		ld	hl,_61d5
		call	_5f3b
		call	_5f00
		jp	nz,_603d
_5c52:		call	_5ebc
		jr	z,_5c60
		jp	c,_603f
		ld	hl,_5c52
		jp	_5a9a

_5c60:		ld	hl,_61e3
		call	_5f3b
_5c66:		in	a,(041h)
		cp	0b8h
		jr	z,_5c72
		ld	hl,_5c66
		jp	_5a9a

_5c72:		call	_5f00
		jp	nz,_603d
		call	_5c7e
		jp	_5a7c

_5c7e:		ld	hl,00000h
		ld	(_61cd),hl
		ld	(_61cf),hl
		inc	hl
		ld	(00392h),hl
		ret	

_5c8c:		ld	hl,008d9h
		ld	e,(hl)
		inc	hl
		ld	d,(hl)
		ld	hl,$702e
		or	a
		sbc	hl,de
		jp	z,_5ca5
		ld	b,004h
		call	_779f
		ld	b,040h
		jp	_603f

_5ca5:		ld	hl,008dfh
		ld	d,(hl)
		inc	hl
		ld	e,(hl)
		ld	(ix+0dh),e
		ld	(ix+0ch),d
		ld	hl,008e5h
		ld	d,(hl)
		inc	hl
		ld	e,(hl)
		ld	(ix+0fh),e
		ld	(ix+0eh),d
		ld	hl,008e3h
		ld	d,(hl)
		inc	hl
		ld	e,(hl)
		ld	(ix+10h),d
		ld	(ix+11h),e
		ld	a,(008e2h)
		ld	(ix+12h),a
		call	_5c7e
		ld	a,001h
		ld	(_61d0),a
		jp	_5b4c

_5cda:		set	0,(iy+00h)
		jp	_5fed

_5ce1:		call	_5ebc
		jr	z,_5cef
		jp	c,_603f
		ld	hl,_5ce1
		jp	_5a9a

_5cef:		ld	hl,_61dc
		call	_5f3b
		call	_5f00
		ld	a,01eh
		ld	(iy+01h),a
		res	0,(iy+00h)
		jp	_5fed

_5d04:		res	0,(iy+00h)
		xor	a
		ld	(00396h),a
		ld	hl,_5d12
		ld	(00397h),hl
_5d12:		call	_5ebc
		jr	z,_5d20
		jp	c,_603f
		ld	hl,_5d12
		jp	_5a9a

_5d20:		ld	hl,_61d5
		call	_5f3b
		call	_5f00
		jp	nz,_603d
_5d2c:		call	_5ebc
		jr	z,_5d3a
		jp	c,_603f
		ld	hl,_5d2c
		jp	_5a9a

_5d3a:		ld	hl,(00392h)
		ld	a,(_6207+4)
		and	0c0h
		or	l
		ld	(_6207+4),a
		ld	a,(_620e+1)
		and	0c0h
		or	l
		ld	(_620e+1),a
		ld	a,(_6215+4)
		and	0c0h
		or	l
		ld	(_6215+4),a
		ld	hl,_6206
		call	_5f3b
		ld	hl,_620d
		call	_6024
		call	_5f00
		jp	nz,_603d
		ld	hl,_5d76
_5d6d:		ld	a,001h
		ld	(0039fh),a
		ld	(0039bh),hl
		ret	

_5d76:		call	_5ebc
		jr	z,_5d84
		jp	c,_603f
		ld	hl,_5d76
		jp	_5a9a

_5d84:		in	a,(041h)
		bit	4,a
		jr	z,_5d84
		cp	0b8h
		jr	nz,_5d97
		call	_5f00
		ld	hl,_5d76
		jp	_5d6d

_5d97:		ld	hl,_61f8
		call	_5f3b
_5d9d:		in	a,(041h)
		cp	098h
		jr	z,_5da9
		ld	hl,_5d9d
		jp	_5a9a

_5da9:		ld	hl,_6226
		call	_6012
		call	_5f00
		ld	a,(_622e)
		and	07fh
		ld	b,a
		ld	a,(_6228)
		or	b
		ld	b,040h
		jp	nz,_603f
_5dc1:		call	_5ebc
		jp	c,_603f
		jr	z,_5dcf
		ld	hl,_5dc1
		jp	_5a9a

_5dcf:		ld	hl,_6214
		call	_5f3b
		call	_5f00
		ld	hl,_5dde
		jp	_5d6d

_5dde:		call	_5ebc
		jr	z,_5dec
		jp	c,_603f
		ld	hl,_5dde
		jp	_5a9a

_5dec:		in	a,(041h)
		bit	4,a
		jr	z,_5dec
		cp	0b8h
		jr	nz,_5dff
		call	_5f00
		ld	hl,_5dde
		jp	_5d6d

_5dff:		ld	hl,_61f8
		call	_5f3b
_5e05:		in	a,(041h)
		cp	098h
		jr	z,_5e11
		ld	hl,_5e05
		jp	_5a9a

_5e11:		ld	hl,_6226
		call	_6012
		call	_5f00
		ld	a,(_622e)
		and	07fh
		ld	b,a
		ld	a,(_6228)
		or	b
		jp	nz,_5e9b
_5e27:		call	_5ebc
		jr	z,_5e35
		jp	c,_603f
		ld	hl,_5e27
		jp	_5a9a

_5e35:		ld	hl,_621b
		call	_5f3b
_5e3b:		in	a,(041h)
		cp	098h
		jr	z,_5e47
		ld	hl,_5e3b
		jp	_5a9a

_5e47:		ld	hl,_6226
		call	_6012
		call	_5f00
_5e50:		ld	b,004h
		di	
		call	_7786
		ei	
		jr	z,_5e5f
		ld	hl,_5e50
		jp	_5a9a

_5e5f:		ld	hl,(_5eb0)
		ld	a,(_6227)
		or	a
		jr	z,_5e6b
		ld	hl,(_5eb0+2)
_5e6b:		ld	(_5ea0+6),hl
		ld	hl,_5ea0
		ld	de,008d9h
		ld	bc,00010h
		ldir	
		ld	h,d
		ld	l,e
		inc	de
		ld	(hl),000h
		ld	bc,000efh
		ldir	
		ld	de,008f9h
		ld	hl,splash
_5e89:		ld	a,(hl)
		or	a
		jr	z,_5e92
		ld	(de),a
		inc	de
		inc	hl
		jr	_5e89

_5e92:		call	_5c7e
		jp	_5b4c

_5e98:		jp	_5ce1

_5e9b:		ld	b,040h
		jp	_603f

_5ea0:		defb	02eh,070h,076h,068h,000h,010h,001h,032h,000h,001h,000h,080h,001h,000h,000h,000h
_5eb0:		ld	bc,00232h
		adc	a,(hl)
		ld	l,062h
		ld	h,c
		ld	h,h
		nop	
		nop	
		nop	
		nop	
_5ebc:		in	a,(041h)
		or	a
		ret	nz
		ld	a,001h
		out	(040h),a
		ld	a,004h
		out	(041h),a
		ld	bc,00064h
_5ecb:		in	a,(041h)
		bit	7,a
		jr	nz,_5ef9
		djnz	_5ecb
		dec	c
		jr	nz,_5ecb
		ld	a,008h
		out	(041h),a
		ld	b,004h
_5edc:		djnz	_5edc
		ld	a,000h
		out	(041h),a
		ld	a,(0039eh)
		inc	a
		cp	014h
		jr	z,_5eef
		ld	(0039eh),a
		or	a
		ret	

_5eef:		xor	a
		ld	(0039eh),a
		ld	b,002h
		cp	0fdh
		scf	
		ret	

_5ef9:		xor	a
		out	(041h),a
		ld	(0039eh),a
		ret	

_5f00:		ld	bc,00000h
		ld	d,012h
_5f05:		in	a,(041h)
		cp	0b8h
		jp	z,_5f1b
		dec	bc
		ld	a,b
		or	c
		jr	nz,_5f05
		dec	d
		jr	nz,_5f05
		ld	a,00eh
		or	a
		ld	(0039dh),a
		ret	

_5f1b:		in	a,(040h)
_5f1d:		ld	(0039dh),a
		ld	b,a
_5f21:		in	a,(041h)
		cp	0f8h
		jr	nz,_5f21
		in	a,(040h)
		in	a,(041h)
		bit	2,a
		jr	z,_5f32
		xor	a
		out	(041h),a
_5f32:		in	a,(041h)
		or	a
		jr	nz,_5f32
		ld	a,b
		and	00bh
		ret	

_5f3b:		ld	b,(hl)
		inc	hl
		inc	hl
		ld	a,(hl)
		and	01fh
		ld	c,a
		ld	a,(_61cc)
		or	c
		ld	(hl),a
		dec	hl
		jp	_5f50

_5f4b:		ld	b,00ah
		ld	hl,out_40
_5f50:		ld	c,040h
_5f52:		in	a,(041h)
		cp	0b0h
		jr	nz,_5f52
		outi	
		jp	nz,_5f52
		ret	

_5f5e:		ld	a,(0039fh)
		or	a
		jr	z,_5f6b
		xor	a
		ld	(0039fh),a
		jp	_59d9

_5f6b:		ld	iy,003a0h
		ld	b,002h
		ld	c,000h
_5f73:		ld	a,(iy+01h)
		or	a
		jr	z,_5f7f
		dec	a
		jr	z,_5f88
		ld	(iy+01h),a
_5f7f:		ld	de,00003h
		add	iy,de
		inc	c
		djnz	_5f73
		ret	

_5f88:		ld	a,(0039ah)
		or	a
		jr	nz,_5f7f
		ld	a,c
		rrca	
		rrca	
		rrca	
		ld	(_61cc),a
		call	_5ebc
		jr	z,_5f9d
		jr	c,_5fa6
		ret	

_5f9d:		ld	hl,_61ea
		call	_5f3b
		call	_5f00
_5fa6:		ld	(iy+01h),000h
		ret	

_5fab:		push	af
		push	hl
		ld	a,002h
		out	(041h),a
		call	is_page_0
		jp	z,_5fc8
		ld	a,(0039ah)
		ld	(00399h),a
		ld	hl,(00394h)
		ld	(0039bh),hl
		pop	hl
		pop	af
		ei	
		reti	

_5fc8:		push	bc
		push	de
		push	ix
		push	iy
		xor	a
		ld	(00399h),a
		call	a_reti
		ld	ix,(base0_60)
		ld	iy,(0038dh)
		ld	hl,(00394h)
		call	jphl
		ei	
		pop	iy
		pop	ix
		pop	de
		pop	bc
		pop	hl
		pop	af
		ret	

_5fed:		di	
		ld	a,(ix+14h)
		or	020h
		and	0feh
		ld	(ix+14h),a
		ld	a,(sh_de)
		or	020h
		out	(0deh),a	; send CONT5 interrupt to 68000
		and	0dfh
		out	(0deh),a	; turn off CONT5
		xor	a
		ld	(0039ah),a
		ld	b,004h
		ld	a,(00339h)
		cp	b
		call	z,_779f
		ei	
		ret	

_6012:		ld	c,040h
_6014:		in	a,(041h)
		ld	b,a
		and	0e8h
		cp	0a8h
		ret	z
		bit	4,b
		jr	z,_6014
		ini	
		jr	_6014

_6024:		ld	c,040h
		ld	b,(hl)
		inc	hl
_6028:		in	a,(041h)
		ld	d,a
		and	0e8h
		cp	0a8h
		ret	z
		bit	4,d
		jr	z,_6028
		outi	
		jr	nz,_6028
		ret	

_6039:		ld	b,020h
		jr	_603f

_603d:		ld	b,001h
_603f:		ld	a,(0039dh)
		and	008h
		jp	nz,_616a
		ld	hl,_622e
		ld	(hl),000h
		ld	a,0ffh
		ld	(ix+1ah),a
		ld	(ix+1bh),a
		ld	(ix+17h),b
		ld	a,b
		cp	001h
		jp	nz,_6171
		call	_5ebc
		jr	z,_606f
		jr	c,_606a
		ld	hl,_603f
		jp	_5a9a

_606a:		ld	b,004h
		jp	_6171

_606f:		ld	hl,_61f8
		call	_5f3b
_6075:		in	a,(041h)
		cp	098h
		jr	z,_6081
		ld	hl,_6075
		jp	_5a9a

_6081:		ld	hl,_6226
		call	_6012
		call	_5f00
		ld	a,(_6228)
		and	00fh
		ld	(ix+1ah),a
		ld	b,a
		ld	a,(_622e)
		ld	(ix+1bh),a
		and	07fh
		ld	c,a
		ld	hl,_6198
_609f:		ld	de,00005h
		ld	a,b
		cp	(hl)
		jr	nz,_60b5
		inc	hl
		dec	de
		ld	a,c
		and	(hl)
		inc	hl
		dec	de
		cp	(hl)
		jr	nz,_60b5
		inc	hl
		ld	e,(hl)
		inc	hl
		ld	d,(hl)
		ex	de,hl
		jp	(hl)

_60b5:		add	hl,de
		xor	a
		cp	(hl)
		jr	nz,_609f
		call	bugchk_print
		ascii	'IoUnkEr - Sense: ',0
		ld	a,b
		call	ring_puthex_spc
		ld	a,c
		call	ring_puthex_spc
		call	ring_printimm
		ascii	13,10,0
		ld	b,002h
		jp	_616e

		bit	0,(iy+00h)
		jp	z,_614e
		ld	b,008h
		jp	_616e

		set	4,(ix+13h)
		ld	(iy+02h),001h
		ld	a,(0038fh)
		cp	000h
		jp	z,_5cda
		ld	b,010h
		jp	_616e

		ld	b,020h
		ld	c,002h
		jp	_6160

_610a:		call	_5ebc
		jr	z,_6118
		jp	c,_6154
		ld	hl,_610a
		jp	_5a9a

_6118:		ld	hl,_61ff
		call	_5f3b
		call	_5f00
		jp	nz,_6154
_6124:		call	_5ebc
		jr	z,_6131
		jr	c,_6154
_612b:		ld	hl,_6124
		jp	_5a9a

_6131:		in	a,(041h)
		and	028h
		cp	028h
		jr	nz,_613d
		in	a,(040h)
		jr	_612b

_613d:		ld	hl,_61f8
		call	_5f3b
		ld	hl,_6226
		call	_6012
		call	_5f00
		jr	nz,_6154
_614e:		ld	b,002h
		ld	c,003h
		jr	_6160

_6154:		ld	b,004h
		jr	_616e

		ld	b,040h
		jr	_616e

		ld	b,004h
		ld	c,002h
_6160:		ld	a,(00396h)
		inc	a
		ld	(00396h),a
		cp	c
		jr	nc,_616e
_616a:		ld	hl,(00397h)
		jp	(hl)

_616e:		ld	(ix+17h),b
_6171:		set	6,(ix+14h)
		ld	a,(_622e)
		and	080h
		jp	z,_5fed
		ld	a,(_6229)
		ld	(ix+06h),a
		ld	a,(_622a)
		ld	(ix+07h),a
		ld	a,(_622b)
		ld	(ix+08h),a
		ld	a,(_622c)
		ld	(ix+09h),a
		jp	_5fed

_6198:		defb	007h,0ffh,017h,0eeh,060h
		defb	009h,0ffh,01fh,0eeh,060h
		defb	006h,0ffh,000h,0e2h,060h
		defb	003h,0ffh,00ah,058h,061h
		defb	003h,0e8h,000h,04eh,061h
		defb	005h,000h,000h,003h,061h
		defb	004h,0ffh,023h,05ch,061h
		defb	004h,0f0h,000h,05ch,061h
		defb	002h,0ffh,009h,05ch,061h
		defb	004h,0ffh,015h,00ah,061h
		defb	000h
out_40:		defb	000h
_61cc:		defb	000h
_61cd:		defb	000h
		defb	000h
_61cf:		defb	000h
_61d0:		defb	000h
		defb	000h
		defb	000h
_61d3:		defb	000h
		defb	000h
_61d5:		defb	006h
		defb	01eh,000h,000h,000h,001h,000h
_61dc:		defb	006h
		defb	01eh,000h,000h,000h,000h,000h
_61e3:		defb	006h
		defb	01bh,000h,000h,000h,001h,000h
_61ea:		defb	006h
		defb	01bh,000h,000h,000h,000h,000h
		defb	006h
		defb	003h,000h,000h,000h,004h,000h
_61f8:		defb	006h
		defb	003h,000h,000h,000h,009h,000h
_61ff:		defb	006h
		defb	001h,000h,000h,000h,000h,000h
_6206:		defb	006h
_6207:		defb	004h,016h,000h,000h,000h,000h
_620d:		defb	006h
_620e:		defb	080h,040h,000h,000h,000h,000h
_6214:		defb	006h
_6215:		defb	004h,000h,000h,000h,000h,000h
_621b:		defb	00ah
		defb	025h,000h,000h,000h,000h,000h,000h,000h,000h,000h
_6226:		defb	000h
_6227:		defb	000h
_6228:		defb	000h
_6229:		defb	000h
_622a:		defb	000h
_622b:		defb	000h
_622c:		defb	000h
		defb	000h
_622e:		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h

; Generally initialize all the character devices.  And a few other things
; like detecting Model II vs Model 16/6000.

char_dev_init:	ld	hl,various_port_init
		call	send_portz
		ld	hl,sio_a_port_init
		call	send_portz
		ld	hl,sio_b_port_init
		call	send_portz
		ld	a,047h
		out	(0f1h),a
		ld	a,0ffh
		out	(0f1h),a
		ld	b,00fh
_6286:		djnz	_6286
		in	a,(0f1h)
		cp	0fch
		sbc	a,a
		ld	(00338h),a
		ld	hl,model_2_msg
		ld	a,0cdh		; opcode for CALL
		jr	nz,is_model_2
		ld	hl,model_6000_16_msg
		ld	a,0c7h
		out	(0f1h),a
		ld	a,001h
		out	(0f1h),a
		jr	is_model_16

; cmd dispatch cannot be disabled on the Model II.
is_model_2:	ld	(dispatch_call),a

is_model_16:	ld	de,video_RAM + 64 ; upper right of video display
		ld	bc,15
		ldir	

		in	a,(0fch)	; clear out keyboard scancode

; Map all the 68000 DCB zero page offsets to addresses

		ld	ix,dcb_addrs
		ld	de,(base0)
		ld	bc,4
		ld	a,num_dev
dcb68map:	ld	l,(ix+02h)
		ld	h,(ix+03h)
		add	hl,de
		ld	(ix+02h),l
		ld	(ix+03h),h
		add	ix,bc
		dec	a
		jr	nz,dcb68map

; Initializing the input queue.

		ld	ix,00368h
		add	ix,de
		ld	(inputq0),ix
		xor	a
		ld	(ix+00h),a
		ld	(ix+01h),a
		ld	(ix+02h),a
		ld	(iq_writecnt),a
		ld	(iq_readblk),a
		ld	(iq_writeblk),a
		ld	hl,input_queue + iq_pairs
		ld	(iq_writep),hl
		ld	b,iq_blk_num
		ld	hl,input_queue
emptyiq:	ld	(hl),a		; empty all input queue blocks
		inc	h
		djnz	emptyiq
		ld	de,002e6h
		ld	hl,(base0)
		add	hl,de
		ex	de,hl
		ld	a,num_dev
_6306:		ld	bc,0000ah
		ld	hl,_6345
		ldir	
		dec	a
		jr	nz,_6306
		ld	hl,(_6c77)
		ld	de,00009h
		add	hl,de
		ld	(hl),007h

; Detect if devices 4 through 12 are present
		in	a,(079h)
		ld	d,a
		in	a,(069h)
		or	d
		ret	nz
		ld	a,0c9h		; opcode for RET
		ld	(_6844),a	; disable Multiterminal status poll
		ret	

model_2_msg:	ascii	'[Model II]     '
model_6000_16_msg:
		ascii	'[Model 6000/16]'

_6345:		defb	000h,000h,000h,000h,010h,000h,00dh,000h,000h,000h

various_port_init:
		defb	0f0h,030h	; CTC channel 0
		defb	0f3h,0c7h	; CTC channel 3
		defb	0f3h,001h
		defb	079h,000h	; MT0 channel 0
		defb	079h,000h
		defb	079h,000h
		defb	079h,040h
		defb	07bh,000h	; MT0 channel 1
		defb	07bh,000h
		defb	07bh,000h
		defb	07bh,040h
		defb	07dh,000h	; MT0 channel 2
		defb	07dh,000h
		defb	07dh,000h
		defb	07dh,040h
		defb	069h,000h	; MT1 channel 0
		defb	069h,000h
		defb	069h,000h
		defb	069h,040h
		defb	06bh,000h	; MT1 channel 1
		defb	06bh,000h
		defb	06bh,000h
		defb	06bh,040h
		defb	06dh,000h	; MT1 channel 2
		defb	06dh,000h
		defb	06dh,000h
		defb	06dh,040h
		defb	059h,000h	; MT2 channel 0
		defb	059h,000h
		defb	059h,000h
		defb	059h,040h
		defb	05bh,000h	; MT2 channel 1
		defb	05bh,000h
		defb	05bh,000h
		defb	05bh,040h
		defb	05dh,000h	; MT2 channel 2
		defb	05dh,000h
		defb	05dh,000h
		defb	05dh,040h
		defb	073h,036h	; MT0 channel 0
		defb	070h,00dh
		defb	070h,000h
		defb	073h,076h	; MT0 channel 1
		defb	071h,00dh
		defb	071h,000h
		defb	073h,0b6h	; MT0 channel 2
		defb	072h,00dh
		defb	072h,000h
		defb	063h,036h	; MT1 channel 0
		defb	060h,00dh
		defb	060h,000h
		defb	063h,076h	; MT1 channel 1
		defb	061h,00dh
		defb	061h,000h
		defb	063h,0b6h	; MT1 channel 2
		defb	062h,00dh
		defb	062h,000h
		defb	053h,036h	; MT2 channel 0
		defb	050h,00dh
		defb	050h,000h
		defb	053h,076h	; MT2 channel 1
		defb	051h,00dh
		defb	051h,000h
		defb	053h,0b6h	; MT2 channel 2
		defb	052h,00dh
		defb	052h,000h
		defb	074h,000h	; MT0 channel 0 control/interrupt
		defb	064h,008h	; MT1 channel 0 control/interrupt
		defb	054h,010h	; MT2 channel 0 control/interrupt
		defb	074h,0c5h	; MT0 channel 0 control/interrupt
		defb	074h,001h
		defb	075h,0c5h	; MT0 channel 1 control/interrupt
		defb	075h,001h
		defb	076h,0c5h	; MT0 channel 2 control/interrupt
		defb	076h,001h
		defb	064h,0c5h	; MT1 channel 0 control/interrupt
		defb	064h,001h
		defb	065h,0c5h	; MT1 channel 1 control/interrupt
		defb	065h,001h
		defb	066h,0c5h	; MT1 channel 2 control/interrupt
		defb	066h,001h
		defb	054h,0c5h	; MT2 channel 0 control/interrupt
		defb	054h,001h
		defb	055h,0c5h	; MT2 channel 1 control/interrupt
		defb	055h,001h
		defb	056h,0c5h	; MT2 channel 2 control/interrupt
		defb	056h,001h
		defb	077h,047h	; doc says not used; go figure
		defb	067h,047h	; doc says not used; go figure
		defb	057h,047h	; doc says not used; go figure
		defb	079h,04eh	; MT0 channel 0
		defb	079h,037h
		defb	078h,000h
		defb	079h,036h
		defb	07bh,04eh	; MT0 channel 1
		defb	07bh,037h
		defb	07ah,000h
		defb	07bh,036h
		defb	07dh,04eh	; MT0 channel 2
		defb	07dh,037h
		defb	07ch,000h
		defb	07dh,036h
		defb	069h,04eh	; MT1 channel 0
		defb	069h,037h
		defb	068h,000h
		defb	069h,036h
		defb	06bh,04eh	; MT1 channel 1
		defb	06bh,037h
		defb	06ah,000h
		defb	06bh,036h
		defb	06dh,04eh	; MT1 channel 2
		defb	06dh,037h
		defb	06ch,000h
		defb	06dh,036h
		defb	059h,04eh	; MT2 channel 0
		defb	059h,037h
		defb	058h,000h
		defb	059h,036h
		defb	05bh,04eh	; MT2 channel 1
		defb	05bh,037h
		defb	05ah,000h
		defb	05bh,036h
		defb	05dh,04eh	; MT2 channel 2
		defb	05dh,037h
		defb	05ch,000h
		defb	05dh,036h
		defb	0e3h,042h	; CTC port B
		defb	0e3h,00fh
		defb	0e3h,007h
		defb	0e0h,000h	; Printer
		defb	0e0h,008h
		defb	0e0h,000h
		defb	0e3h,083h	; CTC port B
		defb	000h

sio_a_port_init:
		defb	0f6h,018h
		defb	0f6h,004h
		defb	0f6h,044h
		defb	0f6h,005h
		defb	0f6h,068h
		defb	0f6h,001h
		defb	0f6h,017h
		defb	0f6h,003h
		defb	0f6h,0c1h
		defb	000h

		nop	

sio_b_port_init:
		defb	0f7h,018h
		defb	0f7h,004h
		defb	0f7h,044h
		defb	0f7h,005h
		defb	0f7h,068h
		defb	0f7h,001h
		defb	0f7h,017h
		defb	0f7h,003h
		defb	0f7h,0c1h
		defb	0f7h,002h
		defb	0f7h,020h
		defb	000h

		nop	

_6486:		exx	
		ld	bc,001f6h
		jp	_6491

_648d:		exx	
		ld	bc,002f7h
_6491:		ex	af,af'
		in	a,(c)
		and	001h
		jr	z,_64a7
_6498:		dec	c
		dec	c
		in	a,(c)		; SIO data
		call	dev_q_input
		inc	c
		inc	c
		in	a,(c)		; SIO status
		and	001h
		jr	nz,_6498
_64a7:		ex	af,af'
		exx	
		ei	
		reti	

_64ac:		exx	
		ld	bc,001f6h
		jr	_64b6

_64b2:		exx	
		ld	bc,002f7h
_64b6:		ex	af,af'
_64b7:		in	a,(c)
		bit	0,a
		jr	z,_64a7
		push	bc
		ld	a,001h
		out	(c),a
		in	a,(c)
		and	030h
		jr	z,_64ca
		or	b
		ld	b,a
_64ca:		dec	c
		dec	c
		in	a,(c)
		call	dev_q_input
		pop	bc
		ld	a,030h
		out	(c),a
		jr	_64b7

_64d8:		exx	
		push	iy
		ld	bc,001f6h
		ld	iy,sio_A_dcb
		jr	_64ee

_64e4:		exx	
		push	iy
		ld	bc,002f7h
		ld	iy,sio_B_dcb
_64ee:		ex	af,af'
		ld	a,010h
		out	(c),a
		ld	e,000h
		in	a,(c)
		bit	5,a
		jr	z,_64fd
		set	1,e
_64fd:		bit	3,a
		jr	z,_6503
		set	0,e
_6503:		bit	4,a
		jr	z,_6509
		set	2,e
_6509:		bit	7,a
		jr	z,_6516
		set	6,b
		dec	c
		dec	c
		in	a,(c)
		call	dev_q_input
_6516:		ld	a,e
		cp	(iy+02h)
		ld	(iy+02h),a
		jr	z,_6524
		set	7,b
		call	dev_q_input
_6524:		ex	af,af'
		exx	
		pop	iy
		ei	
		reti	

sio_a_send_intr:
		exx	
		push	iy
		ld	bc,001f6h
		ld	iy,sio_A_dcb
		jr	sio_send

sio_b_send_intr:
		exx	
		push	iy
		ld	bc,002f7h
		ld	iy,sio_B_dcb
sio_send:	ex	af,af'
		call	sio_xmit
		ex	af,af'
		exx	
		pop	iy
		ei	
		reti	

; With IY pointing to a DCB for a serial I/O device, transmit a character
; from its buffer.

dcb_sio_xmit:	ld	b,(iy + d_num)
		ld	c,(iy + d_port)
sio_xmit:	in	a,(c)		; SIO command/status
		and	004h
		ret	z
		call	dcb_get_char
		jr	z,_6565
		dec	c
		dec	c
		out	(c),a		; SIO data
		inc	c
		inc	c
		jp	nc,sio_xmit
_6565:		ld	a,028h
		out	(c),a		; SIO command/status
		ret	

		jr	sio_xmit	; TODO: why unreferenced?

mt0_0_tx_intr:	exx	
		push	iy
		ld	bc,00479h	; B = device number, C = I/O port
		ld	iy,mt0_0_dcb
		jp	mt_tx_intr

mt0_1_tx_intr:	exx	
		push	iy
		ld	bc,0057bh	; B = device number, C = I/O port
		ld	iy,mt0_1_dcb
		jp	mt_tx_intr

mt0_2_tx_intr:	exx	
		push	iy
		ld	bc,0067dh	; B = device number, C = I/O port
		ld	iy,mt0_2_dcb
		jp	mt_tx_intr

mt1_0_tx_intr:	exx	
		push	iy
		ld	bc,00769h	; B = device number, C = I/O port
		ld	iy,mt1_0_dcb
		jp	mt_tx_intr

mt1_1_tx_intr:	exx	
		push	iy
		ld	bc,0086bh	; B = device number, C = I/O port
		ld	iy,mt1_1_dcb
		jp	mt_tx_intr

mt1_2_tx_intr:	exx	
		push	iy
		ld	bc,0096dh	; B = device number, C = I/O port
		ld	iy,mt1_2_dcb
		jp	mt_tx_intr

mt2_0_tx_intr:	exx	
		push	iy
		ld	bc,00a59h	; B = device number, C = I/O port
		ld	iy,mt2_0_dcb
		jp	mt_tx_intr

mt2_1_tx_intr:	exx	
		push	iy
		ld	bc,00b5bh	; B = device number, C = I/O port
		ld	iy,mt2_1_dcb
		jp	mt_tx_intr

mt2_2_tx_intr:	exx	
		push	iy
		ld	bc,00c5dh	; B = device number, C = I/O port
		ld	iy,mt2_2_dcb
mt_tx_intr:	ex	af,af'
		call	a_reti
_65e2:		in	a,(c)
		ld	d,a
		and	(iy+0fh)	; dcb+15 related to usart status
		jr	nz,_65f0
		ex	af,af'
		exx	
		pop	iy
		ei	
		ret	

_65f0:		push	af
		and	002h		; RX RDY?
		call	nz,_661b	; grab an input byte while we're here
		pop	af
		rrca
		jp	nc,_65e2	; TX RDY?  No, then go poll again
		call	dcb_get_char
		jr	z,disable_tx
		dec	c
		out	(c),a		; data out to Multiterminal port
		inc	c
		jp	nc,_65e2
; No buffer data so transmit complete interrupt of no use
disable_tx:	ld	hl,port_shadow
		ld	e,c
		ld	d,000h
		add	hl,de
		ld	a,(hl)
		and	0feh
		ld	(hl),a
		out	(c),a		; disable transmit?
		res	0,(iy+0fh)	; ignore tx ready
		jp	_65e2

_661b:		dec	c
		in	e,(c)		; MT receive character
		inc	c
		ld	a,038h		; frame error | overrun | parity error
		and	d
		ld	d,b
		jp	z,_6636
		rlca			; error bits into upper nybble
		or	b
		ld	b,a		; B = 0 fe ov pe <dev#>
		push	bc
		ld	b,0
		ld	hl,port_shadow
		add	hl,bc
		ld	a,(hl)
		or	010h
		out	(c),a		; assert BREAK?
		pop	bc
_6636:		ld	a,e
		call	dev_q_input	; may have error bits
		ld	b,d
		ret	

; Convert keyboard scancode in A into a character to input in A.

scan2char:	ld	e,a
		or	a
		jp	p,scanlow
		sub	0a1h		; ctl-1 scancode
		cp	6
		ld	hl,_6685
		jr	c,xlate_scan
		sub	01eh		; ctl-? scancode
		cp	002h
		ld	hl,_668b
		jr	c,xlate_scan
		jr	retkey

scanlow:	jr	z,hold_key
		sub	01ch
		cp	004h
		jr	nc,retkey
		push	af
		ld	a,01bh		; send ESC character
		call	dev_q_input
		pop	af
		ld	hl,arrow_esc	; and then the translated arrow key
xlate_scan:	ld	e,a
		ld	d,0
		add	hl,de
		ld	e,(hl)
retkey:		xor	a
		ld	(hold),a
		ld	a,e
		ret	

; "HOLD" key alternates between outputting ctrl-S and ctrl-Q, the standard
; flow control characters.

hold_key:	ld	a,(hold)
		cpl	
		ld	(hold),a
		or	a
		ld	a,011h		; ctl-S
		ret	z
		ld	a,013h		; ctl-Q
		ret	

hold:		byte	0	

; Translate arrow key scancodes $1C .. $1F (left, right, up, down)

arrow_esc:	byte	'D'
		byte	'C'
		byte	'A'
		byte	'B'

; Translation table for scancodes $A1 .. $A6
; Which are: ctl-1 ctl-" ctl-3 ctl-4 ctl-5 ctl-7

_6685:		byte	'|'
		byte	'`'
		byte	$1d
		byte	$1e
		byte	$1f
		byte	$1c

_668b:		defb	05ch
		nop	

key_intr:	ex	af,af'
		in	a,(0ffh)
		and	$80
		jr	z,no_key
		in	a,(0fch)	; get key scancode and clear key intr
		call	_6f99		; weird console fiddle
		cp	0abh
		jr	z,no_key
		cp	0beh		; CTL-,
		jr	nz,no_spec_key
		ld	a,(_6fd4)
		xor	001h
		ld	(_6fd4),a	; toggle cursor blink?
		jr	z,no_key
		call	_6fce
		jr	no_key

no_spec_key:	exx	
		ld	b,dev_console
		call	scan2char
		call	dev_q_input
		exx	
no_key:		ex	af,af'
		ei	
		reti	

printer_intr:	ex	af,af'
		in	a,(0e0h)
		and	0e0h
		jr	nz,printer_busy
		exx	
		push	iy
		ld	iy,printer_dcb
		call	printer_output
		pop	iy
		exx	
printer_busy:	ex	af,af'
		ei	
		reti	

printer_write:	in	a,(0e0h)
		and	0e0h
		ret	nz

printer_output:	ld	b,dev_printer
		call	dcb_get_char
		ret	z
		out	(0e1h),a	; send data to printer
		ret	

		and	07fh		; TODO!

; Called after output data is queued for a Multiterminal port.  Instead
; of trying to send data it seems we only need enable transmission.  It
; must send a transmit ready interrupt to get the data out.

mt_tx_enable:	ld	c,(iy + d_port)
		ld	b,0
		ld	hl,port_shadow
		add	hl,bc
		di	
		set	0,(iy+0fh)	; pay attention to tx ready
		set	0,(hl)		; enable transmission
		outi			; and tell MT that.
		ei	
		ret	

; Add character A from device B to global input queue.
; High bit of B can be set.  In that character it means A is some kind
; of device status information.  I think the RS-232 status lines in some
; cases.

dev_q_input:	ld	hl,(iq_writep)
		ld	(hl),b		; device number
		inc	l
		ld	(hl),a		; character to send
		inc	l
		jr	z,blkend	; reached end of current block?
		cp	013h		; ctl-Q
		jr	z,finish_blk
		ld	(iq_writep),hl
		ld	l,iq_pair_cnt
		inc	(hl)		; count one more pair
		ret	

finish_blk:	ld	a,(iq_writecnt)
		cp	iq_blk_num
		jr	nz,blkend
		ld	(iq_writep),hl
		ld	l,iq_flag
		ld	(hl),l		; queue block for delivery next chance you get
		dec	l
		inc	(hl)		; count one more pair
		ret	

blkend:		ld	l,iq_pair_cnt
		inc	(hl)		; count one more pair
q_input_blk:	ld	hl,iq_writecnt
		inc	(hl)		; increment block sequence number
		inc	hl
		ld	a,(hl)		; get current write block #
		inc	a
		cp	iq_blk_num
		jr	nz,noblkwrap
		xor	a
noblkwrap:	ld	(hl),a		; save current write block # mod 6
		ld	hl,input_queue
		add	a,h
		ld	h,a
		ld	(hl),0		; block has 0 pairs stored
		inc	hl
		ld	(hl),0		; and flag is 0 (don't queue it)
		inc	hl
		ld	(iq_writep),hl	; save pointer to current block
		ret

; Get rid of all data queued for output to a device.

dcb_cancel_write:
		di	
		ld	a,(iy + d_cnt)
		or	a
		jr	z,no_data
		sub	(ix+05h)	; bytes available - N
		neg	
		ld	(ix+05h),a	; N - bytes available
		xor	a
		ld	(iy + d_cnt),a	; all bytes in buffer are consumed
		ld	b,(iy + d_num)
		ld	a,b
		cp	4
		jr	c,dev0123
		ld	c,(iy + d_port)	; I/O port # for these devices
		ld	hl,port_shadow
		ld	b,0
		add	hl,bc
		ld	a,(hl)
		and	0feh		; disable TX interrupt
		ld	(hl),a
		out	(c),a
		res	0,(iy+0fh)	; ignore TX ready
dev0123:	ld	a,(ix+04h)
		or	010h
		and	0feh
		ld	(ix+04h),a
		bit	4,a
		call	nz,send_cont6	; uh, that "or $10" means we always call
no_data:	ei	
		ret	

; Two things done here.  One is to notify the 68000 if we have any devices that
; have empty data buffers (so it can send more if it wants?)
; The second is to pass device input data up to the 68000.

char_io_update:	ld	b,num_dev
		ld	hl,dcb_empty_notified + num_dev - 1
		xor	a
ntflp:		or	(hl)
		jr	z,notified
		ld	(hl),0
		push	bc
		push	hl
		ld	a,b
		dec	a
		call	get_dcb
		di	
		ld	a,(ix+04h)
		or	010h
		and	0feh
		ld	(ix+04h),a
		bit	4,a
		call	nz,send_cont6	; tell 68000 we have space for data?
		ei	
		pop	hl
		pop	bc
		xor	a
notified:	dec	hl
		djnz	ntflp

		ld	a,(iq_writecnt)
		or	a
		jr	nz,have_input

		; We might have a partially written block of data that we've
		; been asked to send anyways.
		di	
		ld	hl,(iq_writep)
		ld	l,iq_flag
		ld	a,(hl)
		or	a
		jr	nz,flushed_block	
		ei	
		ret	

flushed_block:	call	q_input_blk
		ei	
have_input:	ld	a,(iq_readblk)
		ld	hl,input_queue
		add	a,h
		ld	h,a
		ld	c,(hl)		; number of pairs in block
		inc	hl
		inc	hl		; HL points to pairs
; Feels like we're figuring out how much space the 68000 has in its input buffer.
		ld	de,(inputq0)
		ld	a,(de)
		dec	c
		add	a,c
		ld	(iq_tmp),a
		push	af
		jr	nc,_67d8
		ld	b,a
		ld	a,c
		sub	b
		dec	a
		ld	c,a
_67d8:		ld	a,(de)
_67d9:		add	a,002h
		push	hl
		ld	l,a
		ld	h,0
		rl	h
		add	hl,hl
		add	hl,de
		ex	de,hl
		ex	(sp),hl
		inc	c
		ld	b,000h
		sla	c
		rl	b
		ldir			; appending input data to 68000 buffer
		pop	de
		pop	af
		jr	nc,_67f7
		ld	c,a
		xor	a
		push	af
		jr	_67d9

_67f7:		ld	a,(iq_tmp)	; new 68000 pair count - 1
		inc	a
		ld	(de),a		; set new 68000 input pair count
		ld	hl,iq_writecnt
		dec	(hl)		; one less block in queue
		ld	hl,iq_readblk
		ld	a,(hl)
		inc	a
		cp	iq_blk_num
		jr	nz,_680a
		xor	a
_680a:		ld	(hl),a		; and move to next block to read
		ex	de,hl
		inc	hl
		inc	hl
; Use bit 4 of the device number in the first pair to indicate the 68000
; has been notified of the input.  If the bit is set then we've already told it.
; Otherwise, set the bit and send an interrupt.
		bit	4,(hl)
		ret	nz
		set	4,(hl)
		jp	send_cont6	; notify 68000

; Get next buffered byte from a DCB at IY and B as device number.
; On return:
;	Zero set:	byte in A
;	Zero clear:	no data available
;	Carry clear:	buffer still has data
;	Carry set:	buffer now empty

dcb_get_char:	ld	a,(iy + d_cnt)
		or	a
		ret	z		; do nothing if no data queued
		ld	h,(iy + d_bufp + 1)
		ld	l,(iy + d_bufp)	; data buffer pointer
		ld	a,(hl)		; get byte
		inc	hl
		ld	(iy + d_bufp + 1),h
		ld	(iy + d_bufp),l	; update buffer pointer
		dec	(iy + d_cnt)	; 1 less byte in buffer
		ret	nz
		ld	e,b
		ld	hl,dcb_empty_notified
		ld	d,0
		adc	hl,de
		ld	(hl),1
		scf	
		ret	

; Called periodically to make any queued character input available for
; sending to the 68000.

flush_input_queue:
		di	
		ld	a,(iq_writep)
		cp	iq_pairs
		call	nz,q_input_blk	; call if current input block had data
		ei	
		ret	

_6844:		ld	ix,_6c85
		ld	b,num_dev - 4
_684a:		ld	l,(ix+00h)
		ld	h,(ix+01h)
		push	hl
		pop	iy
		ld	l,(ix+02h)
		ld	h,(ix+03h)
		push	hl
		ex	(sp),ix
		call	_6a25
		pop	ix
		ld	de,00004h
		add	ix,de
		djnz	_684a
		ret	

; If bit 1 of B == 0 then 68000 has data to write to a device.
; Otherwise it cancels the current write to the device in progress.

; TODO: capture what we know about the 68K DCB (we know 4+2 of 10 bytes)

cmd_write:	ld	a,c
		and	$F
		call	get_dcb
		bit	1,b
		jp	nz,dcb_cancel_write
		ld	l,(iy + d_buf)
		ld	(iy + d_bufp),l
		ld	h,(iy + d_buf + 1)
		ld	(iy + d_bufp + 1),h
		ld	c,(ix+05h)	; 68000 DCB + 5 must be byte count
		ld	b,0
		call	copy_from_68k	; 68000 DCB + 0 must be data pointer
		di	
		ld	(iy + d_cnt),c
		ld	l,(iy + d_write)
		ld	h,(iy + d_write + 1)
		call	jphl
		ei	
		ret	

; Given the device number in A return IY pointing to Z-80 DCB and 0:IX
; to the 68000 DCB for the device.

get_dcb:	push	de
		ld	hl,dcb_addrs
		rlca	
		rlca	
		ld	e,a
		ld	d,0
		add	hl,de
		ld	e,(hl)
		inc	hl
		ld	d,(hl)
		inc	hl
		push	de
		pop	iy
		ld	e,(hl)
		inc	hl
		ld	d,(hl)
		push	de
		pop	ix
		pop	de
		ret	

; Seems to ensure that the serial port configuration is up to
; date and send back the port status through the input queue if it
; has changed.  Only the SIO and Multiterminal devices have
; non-empty d_config vectors.

cmd_config:	ld	a,c
		and	00fh
		call	get_dcb
		ld	l,(iy + d_config)
		ld	h,(iy + d_config + 1)
		jp	(hl)

; Rough guess that this ensuring that the SIO hardware is configured according
; the 68000's parameters.  And the serial port status is send back up through
; the input queue if it has changed.

sio_config:	ld	e,(ix+07h)
		ld	d,(ix+08h)
		ld	l,(ix+06h)
		ld	a,(iy+00h)
		cp	e
		jr	nz,_68d9
		ld	a,(iy+01h)
		cp	d
		jr	nz,_68d9
		ld	a,(iy+03h)
		cp	l
		jp	z,_69db
_68d9:		ld	(iy+00h),e
		ld	(iy+01h),d
		ld	a,l
		and	030h
		cp	030h
		jr	nz,_68ec
		ld	a,0c0h
		ld	h,068h
		jr	_6904

_68ec:		cp	020h
		jr	nz,_68f6
		ld	a,040h
		ld	h,028h
		jr	_6904

_68f6:		cp	010h
		jr	nz,_6900
		ld	a,080h
		ld	h,048h
		jr	_6904

_6900:		ld	a,000h
		ld	h,008h
_6904:		bit	0,e
		jr	nz,_690a
		or	001h
_690a:		ld	b,a
		ld	a,h
		bit	0,d
		jr	z,_6912
		or	002h
_6912:		bit	1,d
		jr	z,_6918
		or	080h
_6918:		bit	4,e
		jr	z,_691e
		or	010h
_691e:		ld	h,a
		ld	a,l
		and	00fh
		push	hl
		push	bc
		cp	00eh
		jr	nc,_692d
		call	_69e4
		jr	nz,_6940
_692d:		ld	a,(iy+03h)
		ld	(ix+06h),a
		call	_69e4
		jr	nz,_6940
		ld	a,03dh
		ld	(ix+06h),a
		call	_69e4
_6940:		ld	(_69dd),a
		inc	hl
		ld	a,(hl)
		push	af
		inc	hl
		ld	a,(hl)
		ld	(_69de),a
		pop	af
		pop	bc
		pop	hl
		bit	5,e
		jr	z,_6954
		or	001h
_6954:		bit	6,e
		jr	nz,_695a
		or	002h
_695a:		or	004h
		bit	7,e
		jr	z,_6962
		or	00ch
_6962:		ld	e,a
		ld	d,b
		di	
		ld	c,(iy + d_port)
		ld	a,004h
		out	(c),a
		out	(c),e
		ld	a,005h
		out	(c),a
		out	(c),h
		ld	a,003h
		out	(c),a
		out	(c),d
		ld	a,l
		and	00fh
		ld	l,a
		ld	a,(iy+03h)	; buad rate?
		and	00fh
		cp	l
		jr	z,_69ad
		ld	a,(_69de)
		ld	d,a
		ld	a,(_69dd)
		ld	b,a
		ld	(iy+03h),l
		ld	a,(iy + d_num)
		cp	002h
		jr	z,_69a8
		ld	c,0f0h
		call	out_c_db
		ld	c,0f1h
		ld	a,(00338h)
		or	a
		call	nz,out_c_db
		jr	_69ad

_69a8:		ld	c,0f2h
		call	out_c_db
_69ad:		ei	
		ld	c,(iy + d_port)
		ld	a,(iy+02h)
		and	0f8h
		in	e,(c)
		bit	5,e
		jr	z,_69be
		or	002h
_69be:		bit	3,e
		jr	z,_69c4
		or	001h
_69c4:		bit	4,e
		jr	z,_69ca
		or	004h
_69ca:		di	
		cp	(iy+02h)	; dcb+2 is RS-232 port status?
		jr	z,_69db
		ld	(iy+02h),a
		ld	b,(iy + d_num)
		set	7,b
		call	dev_q_input
_69db:		ei	
		ret	

_69dd:		defb	000h
_69de:		defb	047h

out_c_db:	out	(c),d
		out	(c),b
		ret	

_69e4:		push	bc
		and	00fh
		ld	b,a
		add	a,a
		add	a,b
		ld	c,a
		ld	b,000h
		ld	hl,_69f5
		add	hl,bc
		ld	a,(hl)
		or	a
		pop	bc
		ret	

_69f5:		defb	000h,000h,000h
		defb	09ch,080h,007h
		defb	0d0h,040h,007h
		defb	08eh,040h,007h
		defb	074h,040h,007h
		defb	068h,040h,007h
		defb	04eh,040h,007h
		defb	034h,040h,007h
		defb	0d0h,040h,047h
		defb	068h,040h,047h
		defb	045h,040h,047h
		defb	034h,040h,047h
		defb	01ah,040h,047h
		defb	00dh,040h,047h
		defb	000h,000h,000h
		defb	000h,000h,000h

; Involves Multiterminal port.  Definitely picking up the usart status
; flags and packaging them for delivery to the 68000 via the input queue.
; It seems to care if any error bit has changed but only passes DSR back.
; Eh, maybe it is just a DSR check.

_6a25:		push	bc
		ld	c,(iy + d_port)
		in	b,(c)
		ld	a,(iy+02h)	; usart status mirror?  or just DSR?
		and	0f8h
		or	006h
		bit	7,b
		jr	z,_6a38
		or	001h
_6a38:		cp	(iy+02h)
		jr	z,_6a4c
		ld	(iy+02h),a
		di	
		ld	b,(iy + d_num)
		set	7,b
		push	hl
		call	dev_q_input
		pop	hl
		ei	
_6a4c:		pop	bc
		ret	

; Seems like we're getting the parameters the 68000 has for the
; Multiterminal port and applying them to the hardware.

mt_config:	ld	b,(ix+06h)
		ld	c,(ix+08h)
		ld	e,(ix+07h)
		ld	a,(iy+03h)
		cp	b
		jr	nz,_6a68
		ld	a,(iy+01h)
		cp	c
		jr	nz,_6a68
		ld	a,(iy+00h)
		cp	e
		ret	z
_6a68:		ld	a,b
		and	030h
		cp	030h
		jr	nz,_6a73
		ld	a,00eh
		jr	_6a85

_6a73:		cp	020h
		jr	nz,_6a7b
		ld	a,00ah
		jr	_6a85

_6a7b:		cp	010h
		jr	nz,_6a83
		ld	a,006h
		jr	_6a85

_6a83:		ld	a,002h
_6a85:		bit	5,e
		jr	z,_6a91
		or	010h
		bit	6,e
		jr	nz,_6a91
		or	020h
_6a91:		or	040h
		bit	7,e
		jr	z,_6a99
		or	0c0h
_6a99:		ld	l,a
		ld	a,011h
		bit	0,e
		jr	nz,_6aa2
		or	004h
_6aa2:		bit	4,e
		jr	z,_6aa8
		or	008h
_6aa8:		bit	0,c
		jr	z,_6aae
		or	020h
_6aae:		bit	1,c
		jr	z,_6ab4
		or	002h
_6ab4:		ld	h,a
		ld	(iy+01h),c
		ld	(iy+00h),e
		ex	de,hl
		ld	c,(iy + d_port)
		di	
		ld	a,040h
		out	(c),a
		nop	
		nop	
		out	(c),e
		nop	
		nop	
		out	(c),d
		ld	(iy+0fh),002h	; pay attention to RX ready
		res	0,d
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		out	(c),d
		ld	a,d
		ld	e,c
		ld	d,000h
		ld	hl,port_shadow
		add	hl,de
		ld	(hl),a
		ld	a,(iy+03h)	; current baud rate
		ld	(iy+03h),b	; new baud rate
		push	af
		ld	a,b
		and	00fh
		ld	b,a
		pop	af
		and	00fh
		cp	b
		call	nz,mt_set_baud
		ei	
		ret	

mt_set_baud:	ld	c,(iy + d_num)
		ld	a,(iy+03h)	; dcb+3 must be baud rate
		and	00fh
		cp	011h		; well, this will always generate carry
		ret	nc
		add	a,a
		ld	e,a
		ld	d,000h
		ld	hl,baud_clock
		add	hl,de
		ld	e,(hl)
		inc	hl
		ld	d,(hl)
		ld	a,d
		or	e
		ret	z
		ld	a,c
		cp	num_dev
		ret	nc
		sub	004h
		ld	c,a
		add	a,a
		add	a,c
		ld	c,a
		ld	b,000h
		ld	hl,_6b4c
		add	hl,bc
		ld	c,(hl)
		inc	hl
		ld	a,(hl)
		out	(c),a
		inc	hl
		ld	c,(hl)
		out	(c),e
		out	(c),d
		ret	

baud_clock:	word	00000h
		word	009c4h		; 50 baud
		word	00683h		; 75 baud
		word	00470h		; 110 baud
		word	003a4h
		word	00341h		; 150 baud
		word	00271h
		word	001a1h		; 300 baud
		word	000d0h		; 600 baud
		word	00068h		; 1200 baud
		word	00045h
		word	00034h		; 2400 baud
		word	0001ah		; 4800 baud
		word	0000dh		; 9600 baud
		word	00000h
		word	00000h

_6b4c:		defb	073h,036h,070h
		defb	073h,076h,071h
		defb	073h,0b6h,072h
		defb	063h,036h,060h
		defb	063h,076h,061h
		defb	063h,0b6h,062h
		defb	053h,036h,050h
		defb	053h,076h,051h
		defb	053h,0b6h,052h

console_write:	ld	a,(console_dcb + d_cnt)
		or	a
		ret	z
		ld	b,dev_console
		call	dcb_get_char
		ei	
		call	nz,putc
		ret	

printer_update:	di	
		ld	a,(printer_dcb + d_cnt)
		or	a
		jr	z,no_print
		in	a,(0e0h)
		and	0e0h
		jr	nz,no_print
		ld	iy,printer_dcb
		call	printer_output
no_print:	ei	
		ret	

send_cont6:	ld	a,(sh_de)
		or	040h
		out	(0deh),a	; send CONT6 interrupt to 68000
		and	0bfh
		out	(0deh),a	; turn off CONT6
		ret	

; Device Control Blocks for all the character devices.  As opposed to
; block devices such as floppy and hard drives.

console_dcb:	defb	000h		; +0	
		defb	000h		; +1	
		defb	000h		; +2	
		defb	000h		; +3	
		defb	000h		; +4
		defb	0		; +5 device 0
		defb	000h		; +6
		word	0		; +7
		word	dbuf_console	; +9	XXX console

		word	console_write	; +11
		word	a_ret		; +13

sio_A_dcb:	defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	1		; device 1	
		defb	$f6		; SIO Channel A command/status port
		word	0
		word	dbuf_sio_A

		word	dcb_sio_xmit
		word	sio_config

		defb	000h			

sio_B_dcb:	defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	2		; device 2			
		defb	$f7		; SIO Channel B command/status port
		word	0
		word	dbuf_sio_B

		word	dcb_sio_xmit
		word	sio_config

		defb	000h			

printer_dcb:	defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	3		; device 3	
		defb	000h			
		word	0		; printer data buffer pointer
		word	dbuf_printer

		word	printer_write
		word	a_ret

		defb	000h			

; 9 devices in groups of 3 for up to 3 Multiterminal Interface boards.
; The Multiterminal Interface boards adds 3 RS-232 ports to the machine.

mt0_0_dcb:	defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	4		; device 4			
		defb	079h		; I/O port
		word	0
		word	dbuf_dev_4

		word	mt_tx_enable
		word	mt_config

		defb	000h			

mt0_1_dcb:	defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	5		; device 5
		defb	07bh		; I/O port
		word	0
		word	dbuf_dev_5

		word	mt_tx_enable
		word	mt_config

		defb	000h			

mt0_2_dcb:	defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	6		; device 6
		defb	07dh		; I/O port
		word	0
		word	dbuf_dev_6

		word	mt_tx_enable
		word	mt_config

		defb	000h			

mt1_0_dcb:	defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	7		; device 7
		defb	069h		; I/O port
		word	0
		word	dbuf_dev_7

		word	mt_tx_enable
		word	mt_config

		defb	000h			

mt1_1_dcb:	defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	8		; device 8
		defb	06bh		; I/O port
		word	0
		word	dbuf_dev_8

		word	mt_tx_enable
		word	mt_config

		defb	000h			

mt1_2_dcb:	defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	9		; device 9
		defb	06dh		; I/O port
		word	0
		word	dbuf_dev_9

		word	mt_tx_enable
		word	mt_config

		defb	000h			
mt2_0_dcb:	defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	10		; device 10
		defb	059h		; I/O port
		word	0
		word	dbuf_dev_10

		word	mt_tx_enable
		word	mt_config

		defb	000h			

mt2_1_dcb:	defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	11		; device 11
		defb	05bh		; I/O port
		word	0
		word	dbuf_dev_11

		word	mt_tx_enable
		word	mt_config

		defb	000h			

mt2_2_dcb:	defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	12		; device 12
		defb	05dh		; I/O port
		word	0
		word	dbuf_dev_12

		word	mt_tx_enable
		word	mt_config

		defb	000h			

; Flags set indicating which device control blocks with empty data buffers
; have been reported to the 68000 (so it knows it can write more data).

dcb_empty_notified:
		defb	0,0,0,0,0,0,0,0,0,0,0,0,0

		defb	001h

; Table of DCB address pairs, the first the DCB in Z-80 memory and the
; second the address of associated device data in 68000 page 0 memory.
; Which is an offset off (base0) initialized at the start (and it only does 13).
; TODO: Add to map of the base0 68000 memory area.
; 10 bytes each.  First 4 are a pointer, 4th is a status byte.

dcb_addrs:	word	console_dcb
_6c77:		word	$2e6

		word	sio_A_dcb
		word	$2f0

		word	sio_B_dcb
		word	$2fa

		word	printer_dcb
		word	$304

_6c85:		word	mt0_0_dcb
		word	$30e

		word	mt0_1_dcb
		word	$318

		word	mt0_2_dcb
		word	$322

		word	mt1_0_dcb
		word	$32c

		word	mt1_1_dcb
		word	$336

		word	mt1_2_dcb
		word	$340

		word	mt2_0_dcb
		word	$34a

		word	mt2_1_dcb
		word	$354

		word	mt2_2_dcb
		word	$35e

		word	0
		word	0

		word	0
		word	0

		word	0
		word	0

		word	0
		word	0

		word	0
		word	0

		word	0
		word	0

		word	0
		word	0

		word	0
		word	0

		word	0
		word	0

		word	0
		word	0

; Copy buffered output to the screen (if any).
; TODO: figure out what carry returned by "putc" means.  Wild guess is it
; means the display has scrolled so only do a line at a time.

console_update:	ld	a,(console_dcb + d_cnt)
		or	a
		ret	z
		ld	iy,console_dcb
		ld	b,dev_console
_6cdc:		di	
		call	dcb_get_char
		ei	
		ret	z
		call	putc
		ret	c
		jp	_6cdc

_6ce9:		ld	de,(base0)
		ld	hl,002d4h
		add	hl,de
		ld	(base0_724),hl
		xor	a
		ld	(_6f4e),a
		ret	

_6cf9:		call	page_0_ei
		ld	ix,(base0_724)
		bit	0,(ix+0ch)
		jp	z,_6d92
		ld	a,(ix+0ch)
		ld	(_6e03),a
		add	a,(ix+0dh)
		inc	a
		jp	nz,_6dcd
		ld	a,(_6e03)
		and	00ch
		ld	(_6e03),a
		call	_6f99
		ld	a,(ix+0eh)
		cp	000h
		jp	z,_6e0a
		ld	a,(_6e03)
		cp	00ch
		jr	z,_6d7e
		cp	004h
		jr	z,_6d35
		or	a
		jr	z,_6d7e
_6d35:		call	_6dd9
		ld	de,(_6e06)
		ld	a,d
		or	e
		jp	z,_6da0
		ld	hl,(_6e04)
		add	hl,de
		ex	de,hl
		ld	hl,00780h
		or	a
		sbc	hl,de
		jp	c,_6da0
_6d4f:		ld	hl,(_6e08)
		ld	de,(_6e06)
		ld	a,d
		or	e
		jr	z,_6d7e
		add	hl,de
		jr	nc,_6d74
		ld	(_6e06),hl
		ex	de,hl
		or	a
		sbc	hl,de
		ld	b,h
		ld	c,l
		ld	hl,(_6e08)
		call	_6da5
		ld	hl,video_RAM
		ld	(_6e08),hl
		jr	_6d4f

_6d74:		ld	hl,(_6e08)
		ld	bc,(_6e06)
		call	_6da5
_6d7e:		ld	bc,00000h
		xor	a
_6d82:		xor	a
		ld	(ix+0fh),b
		di	
		ld	a,c
		or	020h
		ld	(ix+0ch),a
		call	send_cont6
		ei	
		ret	

_6d92:		call	bugchk_print
		ascii	'SrNoGo',13,10,0
		jr	_6d82

_6da0:		ld	bc,00240h
		jr	_6d82

_6da5:		ld	a,h
		and	0f0h
		cp	0f0h
		jr	nz,_6dc0
		push	bc
		ld	a,(_6e03)
		cp	004h
		jr	z,_6db9
		call	copy_from_68k
		jr	_6dbc

_6db9:		call	copy_to_68k
_6dbc:		pop	hl
		jp	add_ptr_hl

_6dc0:		call	panic
		ascii	'SRBADDR',13,10,0

_6dcd:		call	panic
		ascii	'SRXCSR',13,10,0

_6dd9:		ld	hl,(vram_pos)
		ld	a,h
		or	0f8h
		ld	h,a
		ld	d,(ix+0ah)
		ld	e,(ix+0bh)
		ld	(_6e04),de
		add	hl,de
		jr	nc,_6df5
		ld	de,video_RAM
		add	hl,de
		ld	a,h
		or	0f8h
		ld	h,a
_6df5:		ld	(_6e08),hl
		ld	d,(ix+06h)
		ld	e,(ix+07h)
		ld	(_6e06),de
		ret	

_6e03:		defb	000h
_6e04:		word	00000h
_6e06:		word	00000h
_6e08:		word	00000h

_6e0a:		call	_6ef8
		ld	a,(_6e03)
		cp	000h
		jp	z,_6ee4
		cp	00ch
		jp	z,_6ee4
		ld	h,(ix+06h)
		ld	l,(ix+07h)
		ld	a,l
		or	h
		jp	z,_6ee4
		ld	(_6f4f),hl
		call	deref_PG_ix
		ld	(_6f56),de
		ex	de,hl
_6e30:		ld	bc,(_6f4f)
		add	hl,bc
		ld	de,0c000h
		jr	c,_6e42
		or	a
		sbc	hl,de
		ld	h,b
		ld	l,c
		jp	c,_6e49
_6e42:		ld	hl,(_6f56)
		ex	de,hl
		or	a
		sbc	hl,de
_6e49:		ld	(_6f51),hl
		ld	(_6f53),hl
_6e4f:		ld	a,(_6f4a)
		ld	b,a
		ld	a,050h
		sub	b
		ld	c,a
		ld	hl,(_6f51)
		ld	b,000h
		or	a
		sbc	hl,bc
		jr	nc,_6e64
		ld	a,(_6f51)
_6e64:		ld	(_6f55),a
		ld	b,a
		ld	c,082h
		ld	hl,(_6f56)
		ld	a,(_6e03)
		cp	004h
		jr	z,_6e79
		otir	
		jp	_6e7b

_6e79:		inir	
_6e7b:		ld	a,(_6f55)
		ld	c,a
		ld	a,(_6f4a)
		add	a,c
		ld	(_6f4a),a
		ld	b,000h
		ld	hl,(_6f51)
		or	a
		sbc	hl,bc
		ld	(_6f51),hl
		jp	z,_6ea1
		ld	hl,(_6f56)
		add	hl,bc
		ld	(_6f56),hl
		call	_6ec4
		jp	_6e4f

_6ea1:		ld	hl,(_6f4f)
		ld	de,(_6f53)
		or	a
		sbc	hl,de
		jr	z,_6ee1
		ld	(_6f4f),hl
		call	page_inc
		ld	hl,08000h
		ld	(_6f56),hl
		ld	a,(_6f4a)
		cp	050h
		call	z,_6ec4
		jp	_6e30

_6ec4:		ld	a,(_6f4c)
		and	001h
		ret	z
		ld	a,000h
		out	(080h),a
		ld	(_6f4a),a
		ld	a,(_6f4b)
		inc	a
		cp	0f0h
		jp	nz,_6edb
		xor	a
_6edb:		ld	(_6f4b),a
		out	(081h),a
		ret	

_6ee1:		call	page_0_ei
_6ee4:		ld	(ix+0fh),000h
		ld	a,(ix+0ch)
		and	0feh
		or	020h
		di	
		ld	(ix+0ch),a
		call	send_cont6
		ei	
		ret	

_6ef8:		ld	a,(ix+08h)
		ld	(_6f4a),a
		out	(080h),a
		ld	a,(ix+09h)
		ld	(_6f4b),a
		out	(081h),a
		ld	a,(ix+11h)
		ld	(_6f4d),a
		ld	b,a
		ld	a,(_6f4e)
		or	a
		jp	z,_6f18
		res	1,b
_6f18:		ld	a,b
		out	(083h),a
		ld	a,(ix+10h)
		ld	(_6f4c),a
		ret	

		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
_6f4a:		nop	
_6f4b:		nop	
_6f4c:		nop	
_6f4d:		nop	
_6f4e:		nop	
_6f4f:		nop	
		nop	
_6f51:		nop	
		nop	
_6f53:		nop	
		nop	
_6f55:		nop	
_6f56:		nop	
		nop	

console_init:	ld	ix,$58
		ld	de,(base0)
		add	ix,de
		ld	(console0),ix
		ld	hl,conout_start
		ld	(console_vec),hl
		xor	a
		ld	(console_flags),a
		ld	a,0
		ld	(sh_a0),a
		out	(0a0h),a		; speaker off
		call	printimm
		ascii	12,0
		ret	

; Put character A into ringbuf and display on console.
ring_putc:	push	hl
		push	de
		ld	hl,ring_head
		ld	de,ringbuf
		ld	e,(hl)
		ld	(de),a
		inc	de
		ld	(hl),e
		pop	de
		pop	hl
; Display character in A on console.
putc:		push	af
		push	bc
		push	de
		push	hl
		and	07fh
		ld	hl,(console_vec)
		push	hl
		ld	hl,(cursor_xy)
		ret	

_6f99:		push	af
		jr	_6fa5

; Called when the character output handling is complete and the we are to
; start from the beginning scanning for escape codes.

char_restart:	ld	hl,conout_start
char_done:	ld	(console_vec),hl
char_done_noxy:	pop	hl
		pop	de
		pop	bc
_6fa5:		ld	a,(_6fd6)
		or	a
		jr	nz,_6faf
		ld	a,0a0h
		out	(0ffh),a
_6faf:		ld	a,(_6fd7)
		ld	(_6fd6),a
		pop	af
		ret	

; I daresay this has something to do with cursor blink, just because of
; the 60 counter there.  Update: not so convinced.

_6fb7:		ld	hl,_6fd4
		ld	a,(hl)
		or	a
		ret	z
		inc	hl
		dec	(hl)
		ret	nz
		ld	(hl),03ch
		inc	hl
		ld	a,(hl)
		or	a
		ret	z
		dec	a
		ld	(hl),a
		ret	nz
_6fc9:		ld	a,0e0h
		out	(0ffh),a
		ret	

_6fce:		xor	a
		ld	(_6fd6),a
		jr	_6fc9

_6fd4:		defb	001h
		defb	03ch
_6fd6:		defb	014h
_6fd7:		defb	014h
ring_head:	defb	000h

conout_start:	cp	' '
		jp	nc,char_normal
		cp	13
		jp	z,char_cr
		cp	10
		jp	z,char_lf
		cp	9
		jr	z,char_tab
		cp	8
		jr	z,char_bs
		cp	12
		jp	z,cls
		cp	7
		jr	z,char_bell
		cp	01bh
		jp	nz,char_done_noxy
		ld	hl,conout_esc
		jp	char_done

char_bs:	dec	l
		jp	p,_7090
		jp	char_done_noxy

char_cr:	ld	l,0
		jp	_7090

char_tab:	ld	a,l
		or	7
		inc	a
		ld	l,a
		jp	_7067

char_bell:	ld	a,(sh_a0)
		and	1
		jp	nz,char_done_noxy	; don't lengthen bell if already on
		ld	a,1
		ld	(sh_a0),a
		out	(0a0h),a		; speaker on
		ld	a,8
		ld	(cnt_to_tick8),a
		jp	char_done_noxy

speaker_off:	ld	a,0
		ld	(sh_a0),a
		out	(0a0h),a		; speaker off
		ret	

char_normal:	ld	b,a
		call	xy2vram_addr
		ld	a,(console_flags)
		bit	1,a
		jp	z,_7050
		ld	a,b
		sub	05eh
		jp	c,_704d
		dec	a
		and	07fh
		ld	b,a
_704d:		ld	a,(console_flags)
_7050:		bit	2,a
		jp	z,_7057
		set	7,b
_7057:		ld	(hl),b
		ld	hl,(cursor_xy)
		inc	l
		jp	_7066

conout_done:	ld	de,conout_start
		ld	(console_vec),de
_7066:		ld	a,l
_7067:		cp	050h
		jp	c,_706f
		ld	l,000h
char_lf:	inc	h
_706f:		ld	a,h
		cp	018h
		jp	c,_7090
		ld	h,017h
		push	hl
		ld	hl,(vram_pos)
		ld	de,00050h
		add	hl,de
		ld	a,h
		and	03fh
		ld	h,a
		call	set_vram_pos
		ld	hl,01700h
		ld	bc,00050h
		call	_70aa
		pop	hl
_7090:		ld	(cursor_xy),hl
		call	xy2vram_off
		ld	a,00eh
		ld	c,0fdh
		out	(0fch),a
		out	(c),h
		ld	a,00fh
		out	(0fch),a
		out	(c),l
		jp	char_done_noxy

_70a7:		ld	a,b
		or	c
		ret	z
_70aa:		push	de
		push	hl
		call	xy2vram_addr
		push	hl
		xor	a
		adc	hl,bc
		jr	c,_70c5
		pop	hl
		ld	(hl),020h
		dec	bc
		ld	a,b
		or	c
		jr	z,_70c2
		ld	d,h
		ld	e,l
		inc	de
		ldir	
_70c2:		pop	hl
		pop	de
		ret	

_70c5:		push	hl
		push	bc
		ld	b,h
		ld	c,l
		ld	hl,video_RAM
		ld	(hl),' '
		jr	z,_70da
		dec	bc
		ld	a,b
		or	c
		jr	z,_70da
		ld	d,h
		ld	e,l
		inc	de
		ldir	
_70da:		pop	hl
		pop	bc
		pop	de
		xor	a
		sbc	hl,bc
		jr	z,_70f0
		ld	b,h
		ld	c,l
		ld	h,d
		ld	l,e
		ld	(hl),020h
		dec	bc
		ld	a,b
		or	c
		jr	z,_70f0
		inc	de
		ldir	
_70f0:		pop	hl
		pop	de
		ret	

; Clear console and home cursor.
cls:		ld	hl,video_RAM
		ld	de,video_RAM+1
		ld	bc,24*80-1
		ld	(hl),' '
		ldir	
		ld	hl,0
		call	set_vram_pos
		ld	de,conout_start
		ld	(console_vec),de
		jp	_7090

conout_esc:	sub	'A'
		cp	50
		jp	nc,char_restart
		push	hl
		ld	hl,conout_start
		ld	(console_vec),hl
		ld	hl,escape_codes
		add	a,a
		ld	c,a
		ld	b,0
		add	hl,bc
		ld	a,(hl)
		inc	hl
		ld	h,(hl)
		ld	l,a
		ex	(sp),hl
		ret	

; Version 3.2.0 has 50 escape codes slots where 1.3.5 had 27.

escape_codes:	word	cursor_up	; esc-A
		word	cursor_down	; esc-B
		word	cursor_right	; esc-C
		word	cursor_left	; esc-D
		word	cls		; esc-E
		word	char_done_noxy	; esc-F
		word	char_done_noxy	; esc-G
		word	_71b6		; esc-H
		word	char_done_noxy	; esc-I
		word	_71da		; esc-J
		word	_71ce		; esc-K
		word	_7224		; esc-L
		word	_7248		; esc-M
		word	char_done_noxy	; esc-N
		word	char_done_noxy	; esc-O
		word	_71f8		; esc-P
		word	_720f		; esc-Q
		word	esc_r		; esc-R
		word	char_done_noxy	; esc-S
		word	char_done_noxy	; esc-T
		word	char_done_noxy	; esc-U
		word	char_done_noxy	; esc-V
		word	char_done_noxy	; esc-W
		word	char_done_noxy	; esc-X
		word	esc_y		; esc-Y
		word	char_done_noxy	; esc-Z
		word	esc_std		; esc-[
		word	char_done_noxy	; esc-\
		word	char_done_noxy	; esc-]
		word	_726c		; esc-^
		word	_7274		; esc-_
		word	_7277		; esc-`
		word	char_done_noxy	; esc-a
		word	char_done_noxy	; esc-b
		word	char_done_noxy	; esc-c
		word	char_done_noxy	; esc-d
		word	char_done_noxy	; esc-e
		word	char_done_noxy	; esc-f
		word	char_done_noxy	; esc-g
		word	char_done_noxy	; esc-h
		word	char_done_noxy	; esc-i
		word	char_done_noxy	; esc-j
		word	char_done_noxy	; esc-k
		word	char_done_noxy	; esc-l
		word	char_done_noxy	; esc-m
		word	_729a		; esc-n
		word	_728d		; esc-o
		word	char_done_noxy	; esc-p
		word	char_done_noxy	; esc-q
		word	char_done_noxy	; esc-r

cursor_left:	ld	a,l
		or	a
		jp	z,char_done_noxy
		dec	l
		jp	_7090

cursor_right:	ld	a,l
		cp	04fh
		jp	z,char_done_noxy
		inc	l
		jp	_7090

cursor_up:	ld	a,h
		or	a
		jp	z,char_done_noxy
		dec	h
		jp	_7090

cursor_down:	ld	a,h
		cp	017h
		jp	z,char_done_noxy
		inc	h
		jp	_7090

_71b6:		ld	hl,00000h
		jp	_7090

esc_y:		ld	hl,conout_esc_y
		jp	char_done

esc_r:		ld	hl,conout_esc_r
		jp	char_done

esc_std:	ld	hl,conout_esc_std
		jp	char_done

_71ce:		ld	a,050h
		sub	l
		ld	c,a
		ld	b,000h
		call	nz,_70aa
		jp	char_done_noxy

_71da:		ld	a,l
		or	h
		jp	z,cls
		ld	a,050h
		sub	l
		ld	e,a
		ld	d,000h
		ld	a,017h
		sub	h
		push	hl
		push	de
		call	line_offset
		pop	de
		add	hl,de
		ld	b,h
		ld	c,l
		pop	hl
		call	_70a7
		jp	char_done_noxy

_71f8:		ld	a,04fh
		sub	l
		ld	c,a
		ld	b,000h
		ld	l,04fh
		call	xy2vram_addr
		ld	d,h
		ld	e,l
		dec	hl
		call	_7404
		inc	hl
		ld	(hl),' '
		jp	char_done_noxy

_720f:		ld	a,04fh
		sub	l
		ld	c,a
		ld	b,000h
		call	xy2vram_addr
		ld	d,h
		ld	e,l
		inc	hl
		call	_73ce
		dec	hl
		ld	(hl),' '
		jp	char_done_noxy

_7224:		push	hl
		ld	a,017h
		sub	h
		call	line_offset
		ld	b,h
		ld	c,l
		ld	hl,0174fh
		call	xy2vram_addr
		ld	d,h
		ld	e,l
		ld	hl,0ffb0h
		add	hl,de
		call	_7404
		pop	hl
		ld	l,000h
		ld	bc,00050h
		call	_70aa
		jp	_7090

_7248:		ld	a,017h
		sub	h
		push	hl
		call	line_offset
		ld	b,h
		ld	c,l
		pop	hl
		ld	l,000h
		call	xy2vram_addr
		ld	d,h
		ld	e,l
		ld	hl,00050h
		add	hl,de
		call	_73ce
		ld	hl,01700h
		ld	bc,00050h
		call	_70aa
		jp	char_done_noxy

_726c:		ld	a,001h
_726e:		ld	(_6fd4),a
		jp	char_done_noxy

_7274:		xor	a
		jr	_726e

_7277:		ld	hl,_727d
		jp	char_done

_727d:		ld	hl,conout_start
		ld	(console_vec),hl
		sub	020h
		jp	z,char_done_noxy
		ld	(_6fd7),a
		jr	_726c

_728d:		ld	a,(_6f4d)
		or	001h
_7292:		ld	(_6f4d),a
		out	(083h),a
		jp	char_done_noxy

_729a:		ld	a,(_6f4d)
		and	0feh
		jr	_7292

conout_esc_y:	sub	020h
		cp	018h
		jp	nc,char_restart
		ld	h,a
		ld	(cursor_xy),hl
		ld	hl,_72b2
		jp	char_done

_72b2:		sub	020h
		cp	050h
		jp	nc,conout_done
		ld	l,a
		ld	(cursor_xy),hl
		jp	conout_done

conout_esc_r:	push	hl
		ld	hl,console_flags
		cp	'@'
		jr	z,inv_off
		cp	'D'
		jr	z,inv_on
		cp	'C'
		jr	z,_72e8
		cp	'c'
		jr	z,_72f6
		cp	'G'
		jr	z,_7308
		cp	'g'
		jr	z,_730c
cnd:		pop	hl
		jp	char_restart

inv_off:	res	2,(hl)		; clear inverse character mode
		jr	cnd

inv_on:		set	2,(hl)		; enter inverse character mode
		jr	cnd

_72e8:		ld	a,(_7315)
		ld	(_7312+1),a
		ld	hl,_7310
		call	send_portz
		jr	cnd

_72f6:		ld	a,(_7315)
		and	01fh
		or	020h
		ld	(_7312+1),a
		ld	hl,_7310
		call	send_portz
		jr	cnd

_7308:		set	1,(hl)		; enter bit 1 mode
		jr	cnd

_730c:		res	1,(hl)		; clear bit 1 mode
		jr	cnd

_7310:		defb	0fch,00ah
_7312:		defb	0fdh,069h
		defb	000h

_7315:		defb	$69

conout_esc_std:	cp	'?'
		jr	nz,_7320
		ld	hl,_7329
		jp	char_done

_7320:		ld	(_737d),a
		ld	hl,_7372
		jp	char_done

_7329:		cp	033h
		jp	nz,char_restart
		ld	hl,_7334
		jp	char_done

_7334:		cp	033h
		jp	nz,char_restart
		ld	hl,_733f
		jp	char_done

_733f:		cp	068h
		jr	z,_735c
		cp	06ch
		jp	nz,char_restart
		ld	a,(_7315)
		and	01fh
		ld	(_7315),a
		ld	(_7312+1),a
		ld	hl,_7310
		call	send_portz
		jp	char_restart

_735c:		ld	a,(_7315)
		and	01fh
		or	060h
		ld	(_7315),a
		ld	(_7312+1),a
		ld	hl,_7310
		call	send_portz
		jp	char_restart

_7372:		cp	020h
		jp	nz,char_restart
		ld	hl,_737e
		jp	char_done

_737d:		ld	e,a
_737e:		cp	071h
		jp	nz,char_restart
		ld	a,(_737d)
		cp	05fh
		jr	z,_73aa
		cp	07fh
		jp	nz,char_restart
		ld	a,(_7315)
		and	060h
		or	001h
		ld	(_7315),a
		ld	(_73c7+1),a
		ld	a,008h
		ld	(_73cb+1),a
		ld	hl,_73c5
		call	send_portz
		jp	char_restart

_73aa:		ld	a,(_7315)
		and	060h
		or	009h
		ld	(_7315),a
		ld	(_73c7+1),a
		ld	a,009h
		ld	(_73cb+1),a
		ld	hl,_73c5
		call	send_portz
		jp	char_restart

_73c5:		defb	0fch,00ah
_73c7:		defb	0fdh,009h
		defb	0fch,00bh
_73cb:		defb	0fdh,009h
		defb	000h

_73ce:		ld	a,b
		or	c
		ret	z
		ld	a,h
		or	0f8h
		ld	h,a
		ld	a,d
		or	0f8h
		ld	d,a
		push	bc
		push	de
		push	hl
		push	hl
		add	hl,bc
		pop	hl
		jr	nc,_73e8
		xor	a
		sub	l
		ld	c,a
		ld	a,000h
		sbc	a,h
		ld	b,a
_73e8:		ex	de,hl
		push	hl
		add	hl,bc
		pop	hl
		jr	nc,_73f5
		xor	a
		sub	l
		ld	c,a
		ld	a,000h
		sbc	a,h
		ld	b,a
_73f5:		pop	hl
		pop	de
		push	bc
		ldir	
		pop	bc
		ex	(sp),hl
		or	a
		sbc	hl,bc
		ld	b,h
		ld	c,l
		pop	hl
		jr	_73ce

_7404:		ld	a,b
		or	c
		ret	z
		ld	a,h
		or	0f8h
		ld	h,a
		ld	a,d
		or	0f8h
		ld	d,a
		push	bc
		push	de
		push	hl
		ld	a,h
		and	007h
		ld	h,a
		inc	hl
		ld	a,d
		and	007h
		ld	d,a
		inc	de
		push	hl
		or	a
		sbc	hl,bc
		pop	hl
		jr	nc,_7425
		ld	b,h
		ld	c,l
_7425:		ex	de,hl
		push	hl
		or	a
		sbc	hl,bc
		pop	hl
		jr	nc,_742f
		ld	b,h
		ld	c,l
_742f:		pop	hl
		pop	de
		push	bc
		lddr	
		pop	bc
		ex	(sp),hl
		or	a
		sbc	hl,bc
		ld	b,h
		ld	c,l
		pop	hl
		jr	_7404

; Convert HL = (X,Y) into VRAM offset in HL.

xy2vram_off:	ld	a,h
		ld	c,l
		ld	b,0
		call	line_offset
		add	hl,bc
		ld	bc,(vram_pos)
		add	hl,bc
		ld	a,h
		and	03fh
		ld	h,a
		ret	

; Convert HL = (X,Y) into VRAM address in HL.

xy2vram_addr:	push	bc
		call	xy2vram_off
		pop	bc
		ld	a,h
		or	high(video_RAM)
		ld	h,a
		ret	

; Return HL = A * 80 (i.e., offset to line A of video display).
line_offset:	ld	l,a
		add	a,a
		add	a,a
		add	a,l
		add	a,a
		ld	l,a
		ld	h,000h
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ret	

; Set the top left corner of the screen to start displaying at VRAM address HL.
; Preserves interrupt enable state.

set_vram_pos:	ld	a,i
		push	af
		ld	(vram_pos),hl
		ld	c,0fch
		ld	d,00dh
		ld	a,l
		di	
		out	(c),d
		dec	d
		out	(0fdh),a
		out	(c),d
		inc	c
		out	(c),h
		pop	af
		ret	po
		ei

		ret	

; Wait until a key is pressed and return scancode in A.
; (Apparently unused)
waitkey:	in	a,(0ffh)
		and	080h
		jr	z,waitkey
		in	a,(0fch)
		and	07fh
		ret	

; Display message appearing immediately after the CALL.
printimm:	ex	(sp),hl
		push	af
		call	print
		pop	af
		ex	(sp),hl
		ret	

; Display message pointed to by HL.
print:		ld	a,(hl)
		inc	hl
		or	a
		ret	z
		call	putc
		jr	print

; Put message appearing immediately after the CALL into ring buffer
; and display on console.
ring_printimm:	ex	(sp),hl
		push	af
		call	ring_print
		pop	af
		ex	(sp),hl
		ret	

; Put message at HL in ring buffer and display on console.
ring_print:	ld	a,(hl)
		inc	hl
		or	a
		ret	z
		call	ring_putc
		jr	ring_print

; Display A register as '=HEX '
; (Apparently unused)
preqhex:	push	af
		ld	a,03dh
		call	putc
		pop	af
		push	af
		call	puthex
		ld	a,020h
		call	putc
		pop	af
		ret	

; Display A register in hexadecimal.
puthex:		push	af
		rrca	
		rrca	
		rrca	
		rrca	
		call	hex1
		pop	af
hex1:		call	hexdig
		jp	putc

; Put A register as '=HEX ' into ring buffer and display on console.
ring_preqhex:	push	af
		ld	a,03dh
		call	ring_putc
		pop	af
; Put A register as hexadecimal into ring buffer followed by space and display.
ring_puthex_spc:
		push	af
		call	ring_puthex
		ld	a,020h
		call	ring_putc
		pop	af
		ret	

; Put A register in hexadecimal into ring and display on console.
ring_puthex:	push	af
		rrca	
		rrca	
		rrca	
		rrca	
		call	rhex1
		pop	af
rhex1:		call	hexdig
		jp	ring_putc

		push	af
		jr	_74f8

		push	af
		ld	a,03dh
		call	putc
_74f8:		call	_7507
		ld	a,020h
		call	putc
		pop	af
		ret	

		ld	a,020h
		call	putc
_7507:		push	hl
		ld	a,h
		call	puthex
		pop	hl
		ld	a,l
		jr	puthex

; Put HL register as '=HEX ' into ring buffer and display on console.
ring_preqhex16:	ld	a,020h
		call	ring_putc
		push	hl
		ld	a,h
		call	ring_puthex
		pop	hl
		ld	a,l
		jr	ring_puthex

		push	af
		rlca	
		rlca	
		rlca	
		rlca	
		call	_7527
		pop	af
_7527:		call	hexdig
		ld	(hl),a
		inc	hl
		ret	

; Convert low nybble of A into ASCII hexadecimal '0' .. '9' 'A' .. 'F'
hexdig:		and	00fh
		add	a,090h
		daa	
		adc	a,040h
		daa	
		ret	

_7536:		ld	a,(ring_head)
		or	a
		ret	z
		ld	hl,ringbuf
		ld	iy,ring_head
		ld	b,000h
		ld	ix,(console0)
		ld	c,(ix+02h)
		push	ix
		ld	de,00004h
		add	ix,de
_7552:		ei	
		push	ix
		ld	a,c
		and	07fh
		ld	e,a
		add	ix,de
		inc	c
		ld	a,(hl)
		ld	(ix+00h),a
		pop	ix
		inc	hl
		inc	b
		ld	a,b
		di	
		cp	(iy+00h)
		jr	nz,_7552
		ld	(iy+00h),000h
		ei	
		ld	a,c
		and	07fh
		pop	ix
		ld	(ix+02h),a
		ret	

		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	

rtc_intr:	push	af
		ld	a,(sh_de)
		or	010h
		out	(0deh),a	; send CONT4 interrupt to 68000
		and	0efh
		out	(0deh),a	; turn off CONT4
		ld	a,(tick)
		inc	a
		ld	(tick),a
		in	a,(0feh)	; clear 30Hz real time clock interrupt
		pop	af
		retn	

_75c3:		nop	
rtc_hz:		defb	0	

clock_update:	ld	a,(tick)
		ld	hl,prev_tick
		cp	(hl)
		ret	z		; do nothing if an RTC hasn't passed
		ld	(hl),a
		ld	hl,cnt_to_second
		dec	(hl)
		call	z,per_second
		call	flush_input_queue
		call	printer_update
		ld	hl,cnt_to_tick2
		xor	a
		or	(hl)
		jr	z,no_tick2
		dec	(hl)
		call	z,per_tick2
no_tick2:	ld	hl,cnt_to_tick8
		xor	a
		or	(hl)
		ret	z
		dec	(hl)
		call	z,speaker_off
		ret	

per_second:	ld	a,(rtc_hz)
		ld	(hl),a
		ld	hl,(clock0)
		ld	a,(hl)
		set	0,(hl)
		xor	003h
		and	003h
		ld	hl,_75c3
		jp	nz,_761d
		dec	(hl)
		jr	nz,_761f
		ld	a,(_5964)
		or	a
		jr	nz,_761f
		call	panic
		ascii	'68k crashed',0

_761d:		ld	(hl),006h
_761f:		ld	a,(003b8h)
		or	a
		call	nz,_54e5
		di	
		call	_470c
		ei	
		call	_5f5e
		call	_6844
		call	_6fb7
		call	_7536
		ret	

clock_init:	ld	ix,(base0)
		ld	de,00000h
		add	ix,de
		ld	(clock0),ix
		xor	a
		ld	(ix+00h),a
		ld	(tick),a
		ld	(cnt_to_tick8),a
		ld	(cnt_to_tick2),a
		ld	a,(rtc_hz)
		ld	(cnt_to_second),a
		ld	(ix+01h),a
		ld	hl,nmi_jp
		ld	de,00066h
		ld	bc,00003h
		ldir			; have NMI intr go to rtc_intr
		ld	a,(sh_ff)
		or	020h
		ld	(sh_ff),a
		out	(0ffh),a	; enable real time clock interrupt
		in	a,(0feh)	; clear real time clock interrupt
		ret	

nmi_jp:		jp	rtc_intr

; Follow big-endian 32 bit pointer at PG:ix
; Returns with PG:de pointing at the new location.
; Only 23 bits are significant so it ignores the highest byte at (ix+0).

deref_PG_ix:	ld	d,(ix+02h)	; A16 .. A8
		ld	b,d
		ld	e,(ix+03h)	;  A7 .. A0
		set	7,d
		res	6,d		; bits 0 .. 13 mapped to $8000 .. $BFFF
		rl	b		; A14 .. A8 carry
		ld	a,(ix+01h)	; A23   ..   A16
		rl	a		; A22 .. A15 A14
		di	
		ld	(sh_df),a
		out	(0dfh),a
		ld	a,(sh_de)
		rla			; shift out A14 from TCL
		rl	b		; carry = A14
		rra			; put new A14 into TCL
		ld	(sh_de),a
		out	(0deh),a
		ei	
		ret	

; Set PG register to 0 (used when interrupts disabled)

page_0:		ld	a,(sh_de)
		and	07fh		; A14 = 0
		ld	(sh_de),a
		out	(0deh),a
		xor	a		; (A22 .. A15) = 0
		ld	(sh_df),a
		out	(0dfh),a
		ret	

; Set PG register to 0  (used when interrupts enabled)

page_0_ei:	ld	a,(sh_de)
		and	07fh
		di	
		ld	(sh_de),a
		out	(0deh),a
		xor	a
		ld	(sh_df),a
		out	(0dfh),a
		ei	
		ret	

; Return Z if PG is 0.  
; Or if PG is $1FF which can't happen with memory limited to 1 MB
; which 1988 computer catalog list as the maximum for the 6000 HD.

is_page_0:	ld	a,(sh_de)
		rlca	
		ld	a,(sh_df)
		adc	a,0
		ret	

; Increment PG register

page_inc:	ld	a,(sh_de)
		add	a,080h
		di	
		ld	(sh_de),a
		out	(0deh),a
		jp	nc,_76e1
		ld	a,(sh_df)
		inc	a
		ld	(sh_df),a
		out	(0dfh),a
_76e1:		ei	
		ret	

; Copy BC bytes from HL to 32 bit big-endian pointer at PG:ix in 68000 memory.
; Note: destination pointer is at PG:ix; that isn't the destination itself.
; Reasonably straightforward but must account for crossing the window boundary.

copy_to_68k:	push	bc
		push	de
		push	hl
		push	bc
		call	deref_PG_ix	; PG:de at 68K address
		pop	bc
next_chunk:	push	hl
		push	bc
		ld	hl,0ffffh
		or	a
		sbc	hl,de
		res	7,h
		res	6,h
		inc	hl		; HL = bytes from DE to window end
		or	a
		sbc	hl,bc		; compare with number of bytes to copy
		jr	nc,inwin
		add	hl,bc		; restore count to end of window
		ld	b,h
		ld	c,l		; and set up to copy that many bytes
inwin:		pop	hl		; get original copy count
		or	a
		sbc	hl,bc		; subtract amount we wish to copy
		ex	(sp),hl		; save remainder on stack, get source ptr
		ldir			; copy first chunk
		pop	bc		; get remaining byte count
		call	page_inc	; move window to next 16K page
		res	6,d		; ensure $8000 <= DE <= $BFFF
		ld	a,c
		or	b
		jr	nz,next_chunk	; continue copying if data remains
		pop	hl
		pop	de
		pop	bc
		jp	page_0_ei	; restore PG to 0

; Copy BC bytes from 32 bit big-endian pointer at PG:ix in 68000 memory to HL.
; Note: source pointer is at PG:ix; that isn't the source itself.
; Reasonably straightforward but must account for crossing the window boundary.

copy_from_68k:	push	bc
		push	de
		push	hl
		push	bc
		call	deref_PG_ix
		pop	bc
_771f:		push	hl
		push	bc
		ld	hl,0ffffh
		or	a
		sbc	hl,de
		res	7,h
		res	6,h
		inc	hl
		or	a
		sbc	hl,bc
		jr	nc,_7734
		add	hl,bc
		ld	b,h
		ld	c,l
_7734:		pop	hl
		or	a
		sbc	hl,bc
		ex	(sp),hl
		ex	de,hl
		ldir	
		ex	de,hl
		pop	bc
		call	page_inc
		res	6,d
		ld	a,c
		or	b
		jr	nz,_771f
		pop	hl
		pop	de
		pop	bc
		jp	page_0_ei

; Add HL to 32 bit big-endian pointer at (IX).

add_ptr_hl:	ld	a,(ix+03h)
		add	a,l
		ld	(ix+03h),a
		ld	a,(ix+02h)
		adc	a,h
		ld	(ix+02h),a
		ret	nc
		inc	(ix+01h)
		ret	
; Output data to ports with HL pointing to a 0 terminated list of
; port,data pairs.

send_portz:	push	bc
		ld	b,000h
ptz_lp:		ld	a,(hl)
		inc	hl
		or	a
		jr	z,ptz_dn
		ld	c,a
		ld	a,(hl)
		inc	hl
		push	hl
		ld	hl,port_shadow
		add	hl,bc
		ld	(hl),a
		out	(c),a
		pop	hl
		jr	ptz_lp

ptz_dn:		pop	bc
		ret	

; Return HL = HL % DE and BC = HL / DE.
divmod:		ld	bc,00000h
		or	a
_777c:		sbc	hl,de
		jp	c,_7784
		inc	bc
		jr	_777c

_7784:		add	hl,de
		ret	

_7786:		xor	a
		ld	hl,00339h
		or	(hl)
		jr	nz,_778f
		ld	(hl),b
		ret	

_778f:		cp	b
		ret	nz
		call	bugchk_print
		ascii	'DbLock',13,10,0
		xor	a
		ret	

_779f:		ld	a,(00339h)
		cp	b
		jr	nz,_77aa
		xor	a
		ld	(00339h),a
		ret	

_77aa:		call	bugchk_print
		ascii	'IlUlRq Additional: c o',0
		ld	a,b
		call	ring_puthex_spc
		ld	a,(00339h)
		call	ring_puthex_spc
		call	printimm
		ascii	13,10,0
		or	001h
		ret	

dma_init:	push	bc
		push	hl
		ld	hl,out_F8_4
		ld	bc,004f8h
		otir	
		pop	hl
		pop	bc
		ret	

out_F8_4:	defb	0c3h,083h,08bh,0afh

_77e8:		ld	(out_F8_5+1),hl
		ld	hl,out_F8_5
		ld	bc,00ef8h
		otir	
		ret	

out_F8_5:	defb	079h,000h,000h,0ffh,001h,014h,028h,085h,0e7h,08ah,0cfh,005h,0cfh,087h

_7802:		ld	(out_F8_6+7),hl
		ld	hl,out_F8_6
		ld	bc,00cf8h
		otir	
		ret	

out_F8_6:	defb	06dh,0e7h,0ffh,001h,02ch,010h,08dh,000h,000h,08ah,0cfh,087h

_781a:		ld	bc,00200h
		ld	(_78b7),bc
		ex	de,hl
		ld	(out_F8_7+7),hl
		add	hl,bc
		ld	de,0c000h
		or	a
		sbc	hl,de
		ld	h,b
		ld	l,c
		jr	c,_7837
		ld	hl,(out_F8_7+7)
		ex	de,hl
		or	a
		sbc	hl,de
_7837:		ld	(_78b9),hl
_783a:		ld	de,00100h
		or	a
		sbc	hl,de
		jr	nc,_7846
		ld	de,(_78b9)
_7846:		ld	(_78bb),de
		ld	hl,00022h
		or	a
		sbc	hl,de
		jr	c,_785f
		ld	b,e
		ld	hl,(out_F8_7+7)
		ld	c,0c8h
		inir	
		ld	(out_F8_7+7),hl
		jr	_7886

_785f:		ld	hl,(out_F8_7+7)
		add	hl,de
		dec	de
		ex	de,hl
		ld	(out_F8_7+2),hl
		ld	hl,out_F8_7
		ld	bc,00bf8h
		otir	
		ld	(out_F8_7+7),de
		ld	a,(sh_de)
		ld	b,a
		or	001h
		di	
		out	(0deh),a	; Turn on burst mode
		ld	a,087h
		out	(0f8h),a
		nop	
		ld	a,b
		out	(0deh),a	; Turn off burst mode
		ei	
_7886:		ld	de,(_78bb)
		ld	hl,(_78b7)
		or	a
		sbc	hl,de
		ld	a,h
		or	l
		jp	z,page_0_ei
		ld	(_78b7),hl
		ld	hl,(_78b9)
		or	a
		sbc	hl,de
		ld	a,h
		or	l
		jr	z,_78a8
		ld	(_78b9),hl
		jp	_783a

_78a8:		call	page_inc
		ld	hl,08000h
		ld	(out_F8_7+7),hl
		ld	hl,(_78b7)
		jp	_7837

_78b7:		nop	
		nop	
_78b9:		nop	
		nop	
_78bb:		nop	
		nop	
out_F8_7:	defb	06dh,0c8h,0ffh,001h,02ch,010h,0cdh,000h,000h,092h,0cfh
_78c8:		ld	bc,00200h
		ld	(_7965),bc
		ex	de,hl
		ld	(out_F8_8+1),hl
		add	hl,bc
		ld	de,0c000h
		or	a
		sbc	hl,de
		ld	h,b
		ld	l,c
		jr	c,_78e5
		ld	hl,(out_F8_8+1)
		ex	de,hl
		or	a
		sbc	hl,de
_78e5:		ld	(_7967),hl
_78e8:		ld	de,00100h
		or	a
		sbc	hl,de
		jr	nc,_78f4
		ld	de,(_7967)
_78f4:		ld	(_7969),de
		ld	hl,00022h
		or	a
		sbc	hl,de
		jr	c,_790d
		ld	b,e
		ld	hl,(out_F8_8+1)
		ld	c,0c8h
		otir	
		ld	(out_F8_8+1),hl
		jr	_7934

_790d:		ld	hl,(out_F8_8+1)
		add	hl,de
		dec	de
		ex	de,hl
		ld	(out_F8_8+3),hl
		ld	hl,out_F8_8
		ld	bc,00df8h
		otir	
		ld	(out_F8_8+1),de
		ld	a,(sh_de)
		ld	b,a
		or	001h
		di	
		out	(0deh),a	; Turn on burst mode.
		ld	a,087h
		out	(0f8h),a
		nop	
		ld	a,b
		out	(0deh),a	; Turn off burst mode.
		ei	
_7934:		ld	de,(_7969)
		ld	hl,(_7965)
		or	a
		sbc	hl,de
		ld	a,h
		or	l
		jp	z,page_0_ei
		ld	(_7965),hl
		ld	hl,(_7967)
		or	a
		sbc	hl,de
		ld	a,h
		or	l
		jr	z,_7956
		ld	(_7967),hl
		jp	_78e8

_7956:		call	page_inc
		ld	hl,08000h
		ld	(out_F8_8+1),hl
		ld	hl,(_7965)
		jp	_78e5

_7965:		nop	
		nop	
_7967:		nop	
		nop	
_7969:		nop	
		nop	
out_F8_8:	defb	079h,000h,000h,000h,000h,014h,028h,0c5h,0c8h,092h,0cfh,005h,0cfh
_7978:		ld	(_7a30),hl
		ld	(_7a34),bc
		push	bc
		call	deref_PG_ix
		pop	bc
		ld	(_7a32),de
		ex	de,hl
_7989:		add	hl,bc
		ld	de,0c000h
		or	a
		sbc	hl,de
		ld	h,b
		ld	l,c
		jr	c,_799c
		ex	de,hl
		ld	de,(_7a32)
		or	a
		sbc	hl,de
_799c:		ld	(_7a36),hl
_799f:		ld	de,00100h
		or	a
		sbc	hl,de
		jr	nc,_79ab
		ld	de,(_7a36)
_79ab:		ld	(_7a38),de
		ld	hl,00022h
		or	a
		sbc	hl,de
		jr	c,_79cb
		ld	b,d
		ld	c,e
		ld	de,(_7a32)
		ld	hl,(_7a30)
		ldir	
		ld	(_7a32),de
		ld	(_7a30),hl
		jr	_79fe

_79cb:		ld	hl,(_7a30)
		ld	(out_F8_9+1),hl
		add	hl,de
		ld	(_7a30),hl
		ld	hl,(_7a32)
		ld	(out_F8_9+8),hl
		add	hl,de
		ld	(_7a32),hl
		dec	de
		ld	(out_F8_9+3),de
		ld	hl,out_F8_9
		ld	bc,00df8h
		otir	
		ld	a,(sh_de)
		ld	b,a
		or	001h
		di	
		out	(0deh),a	; Turn on burst mode.
		ld	a,087h
		out	(0f8h),a
		nop	
		ld	a,b
		out	(0deh),a	; Turn off burst mode.
		ei	
_79fe:		ld	de,(_7a38)
		ld	hl,(_7a34)
		or	a
		sbc	hl,de
		ld	a,h
		or	l
		jp	z,page_0_ei
		ld	(_7a34),hl
		ld	hl,(_7a36)
		or	a
		sbc	hl,de
		ld	a,h
		or	l
		jr	z,_7a20
		ld	(_7a36),hl
		jp	_799f

_7a20:		call	page_inc
		ld	hl,08000h
		ld	(_7a32),hl
		ld	bc,(_7a34)
		jp	_7989

_7a30:		nop	
		nop	
_7a32:		nop	
		nop	
_7a34:		nop	
		nop	
_7a36:		nop	
		nop	
_7a38:		nop	
		nop	
out_F8_9:	defb	07dh,000h,000h,000h,000h,014h,010h,0cdh,000h,000h,09ah,0cfh,0b3h
_7a47:		ld	(_7a32),hl
		ld	(_7a34),bc
		push	bc
		call	deref_PG_ix
		pop	bc
		ld	(_7a30),de
		ex	de,hl
_7a58:		add	hl,bc
		ld	de,0c000h
		or	a
		sbc	hl,de
		ld	h,b
		ld	l,c
		jr	c,_7a6b
		ex	de,hl
		ld	de,(_7a30)
		or	a
		sbc	hl,de
_7a6b:		ld	(_7a36),hl
_7a6e:		ld	de,00100h
		or	a
		sbc	hl,de
		jr	nc,_7a7a
		ld	de,(_7a36)
_7a7a:		ld	(_7a38),de
		ld	hl,00022h
		or	a
		sbc	hl,de
		jr	c,_7a9b
		ld	b,d
		ld	c,e
		ld	de,(_7a32)
		ld	hl,(_7a30)
		ldir	
		ld	(_7a32),de
		ld	(_7a30),hl
		jp	_7ace

_7a9b:		ld	hl,(_7a30)
		ld	(out_F8_9+1),hl
		add	hl,de
		ld	(_7a30),hl
		ld	hl,(_7a32)
		ld	(out_F8_9+8),hl
		add	hl,de
		ld	(_7a32),hl
		dec	de
		ld	(out_F8_9+3),de
		ld	hl,out_F8_9
		ld	bc,00df8h
		otir	
		ld	a,(sh_de)
		ld	b,a
		or	001h
		di	
		out	(0deh),a	; Turn on burst mode.
		ld	a,087h
		out	(0f8h),a
		nop	
		ld	a,b
		out	(0deh),a	; Turn off burst mode.
		ei	
_7ace:		ld	de,(_7a38)
		ld	hl,(_7a34)
		or	a
		sbc	hl,de
		ld	a,h
		or	l
		jr	z,_7aef
		ld	(_7a34),hl
		ld	hl,(_7a36)
		or	a
		sbc	hl,de
		ld	a,h
		or	l
		jr	z,_7af2
		ld	(_7a36),hl
		jp	_7a6e

_7aef:		jp	page_0_ei

_7af2:		call	page_inc
		ld	hl,08000h
		ld	(_7a30),hl
		ld	bc,(_7a34)
		jp	_7a58

_end		equ	$

		end	_start
