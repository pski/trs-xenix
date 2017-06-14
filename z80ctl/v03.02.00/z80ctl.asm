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

; A 256 byte ring buffer that messages are put into they are
; displayed on the console.  See ring_putc
ringbuf		equ	03c00h

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
_3ff0:		defb	09bh			
checksum:	word	00a9eh
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
; This section isn't about the checksum.  Somehow a high byte in
; RAM controls a particular variable.  Presumably something set up
; by the bootstrap process or perhaps something that naturally
; indicates a hardware difference.
		ld	a,(_3ff0)
		ld	b,a
		ld	a,(07fffh)
		and	07fh
		ex	de,hl
		cp	035h
		ld	a,019h
		jr	z,_40a8
		ld	a,01eh
_40a8:		ld	(_75c4),a
; Back to the checksum checking.
		ld	a,(checksum)
		ld	c,a
		or	a
		sbc	hl,bc			; NOP this instruction out to disable checksum.
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
		ldir	
		ld	hl,03d00h
		ld	de,03d01h
		ld	bc,002ffh
		ld	(hl),0ffh
		ldir	
		ld	a,0c3h
		ld	(00038h),a
		ld	(00035h),a
		ld	hl,_4311
		ld	(00039h),hl
		ld	hl,_43c9
		ld	(00036h),hl
		ld	a,080h
		ld	(0017fh),a
		out	(0ffh),a
		ld	a,004h
		ld	(0015eh),a
		out	(0deh),a
		ld	a,000h
		ld	(0015fh),a
		out	(0dfh),a
		ld	bc,(08000h)
		ld	de,0fd04h
		ld	(08000h),de
		ld	a,(0015eh)
		or	001h
		out	(0deh),a
		ld	hl,(08000h)
		and	0feh
		out	(0deh),a
		ld	(08000h),bc
		or	a
		sbc	hl,de
		jr	z,_415a
		call	panic
		ascii	'NewPal - Hardware Modification Required',13,10,0
_415a:		ld	de,(08006h)
		ld	a,00ch
		ld	(0015eh),a
		out	(0deh),a
		ld	a,000h
		ld	(0015eh),a
		out	(0deh),a
_416c:		ld	hl,(08006h)
		or	a
		sbc	hl,de
		jr	z,_416c
		ld	de,(08006h)
		ld	l,d
		ld	h,e
		set	7,h
		res	6,h
		ld	(00186h),hl
		ld	hl,(00186h)
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
		call	_769c
		call	_444f
		call	_4291
		call	_77d7
		call	_7638
		call	_451a
		call	_5004
		call	_6f58
		ld	hl,splash
		call	ring_print
		call	ring_printimm
		ascii	13,10,10,0
		call	_626a
		call	_6ce9
		call	_5965
		ld	hl,(00186h)
		ld	de,005afh
		add	hl,de
		ld	a,(hl)
		ld	(_5943),a
		ld	(_41de),sp
		call	_7536
		ld	hl,00000h
		ld	(08006h),hl
		jr	_41e0

_41dc:		nop	
_41dd:		nop	
_41de:		nop	
		nop	
_41e0:		xor	a
		ld	hl,_41dc
		di	
		or	(hl)
		ld	(hl),000h
		ei	
_41e9:		call	nz,_421b
		ld	a,(003bfh)
		or	a
		call	nz,_5052
		call	_59d0
		call	_6cd1
		call	_4579
		ei	
		call	_75c5
		call	_677c
		ld	hl,00000h
		add	hl,sp
		ld	de,(_41de)
		or	a
		sbc	hl,de
		jp	z,_41e0
		call	panic
		ascii	'SckMud',0
_421b:		ld	hl,(00190h)
		ld	b,(hl)
		inc	hl
		ld	a,(hl)
		cp	b
		ret	z
		inc	a
		ld	(hl),a
		inc	hl
		and	01fh
		rlca	
		ld	e,a
		ld	d,000h
		add	hl,de
		call	_4233
		jp	_421b

_4233:		ld	a,(hl)
		ld	c,a
		and	0f0h
		jp	m,_4250
		rrca	
		rrca	
		ld	e,a
		inc	hl
		ld	a,(hl)
		ld	b,a
		and	001h
		rlca	
		or	e
		ld	e,a
		ld	hl,_425c
		ld	d,000h
		add	hl,de
		ld	e,(hl)
		inc	hl
		ld	h,(hl)
		ld	l,e
		jp	(hl)

_4250:		call	panic
		ascii	'BadMaj',13,10,0
_425c:		word	_459b
		word	_4274
		word	_506f
		word	_4274
		word	_6869
		word	_68b0
		word	_59f2
		word	_4274
		word	_6cf9
		word	_6ef8
		word	_5731
		word	_572a
_4274:		call	_42ab
		ascii	'Bd68Rq - Code: ',0
		call	ring_preqhex
		call	ring_printimm
		ascii	13,10,0
		ret	

_4291:		ld	de,(00186h)
		ld	hl,0056ch
		add	hl,de
		ld	(00190h),hl
		xor	a
		ld	(_41dd),a
		ret	

_42a1:		push	hl
		ld	hl,_41dc
		ld	(hl),001h
		pop	hl
		ei	
		reti	

_42ab:		call	ring_printimm
		ascii	13,10,'Bugchk: ',0
		jp	ring_printimm

panic:		di	
		ld	a,0ffh
		out	(0efh),a
		ld	a,004h
		ld	(0015eh),a
		out	(0deh),a
		ld	a,080h
		ld	(0017fh),a
		out	(0ffh),a
		call	_4307
		call	ring_printimm
		ascii	13,10,0
		call	printimm
		ascii	27,'RD',0
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
		ascii	27,'R@',0
		call	printimm
		ascii	13,10,0
		ex	(sp),hl
		jp	_571b

_4307:		call	printimm
		ascii	27,'Y7',10,13,0
		ret	

; RST 38 vector.  Some Model 12/16/6000 machines had bad chips that caused phantom
; opcode fetches of 0xFF.  This handler looks at the instruction before the return
; address and does a halt if a RST 38 called it.  Otherwise it prints a warning and
; returns back to the original address assuming it was a phantom fetch and that a
; retry will operate correctly.

_4311:		ex	(sp),hl
		push	af
		dec	hl
		ld	a,(hl)
		cp	0ffh
		jr	z,_4334
		call	_42ab
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
		call	_4307
		call	ring_printimm
		ascii	13,10,0
		call	printimm
		ascii	27,'RD',0
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
		call	_4307
		call	ring_printimm
		ascii	13,10,0
		call	printimm
		ascii	27,'RD',0
		call	ring_printimm
		ascii	'Bughlt: Wnd7  Additional:',0
		jp	z80dump

_43fc:		ret	


_43fd:		ei	
		reti	

_4400:		push	af
		ld	a,001h
		jr	_4417

_4405:		push	af
		ld	a,002h
		jr	_4417

_440a:		push	af
		ld	a,003h
		jr	_4417

_440f:		push	af
		ld	a,004h
		jr	_4417

_4414:		push	af
		ld	a,005h
_4417:		push	de
		push	hl
		ld	e,a
		ld	d,000h
		ld	hl,_4428+15
		add	hl,de
		add	a,030h
		ld	(hl),a
		pop	hl
		pop	de
		call	_42ab
_4428:		ascii	'UnkInt - Code: ........',13,10,0
		pop	af
		ei	
		reti	

		push	de
		ld	e,(hl)
		inc	hl
		ld	d,(hl)
		ex	de,hl
		pop	de
jphl:		jp	(hl)

_444d:		reti	

_444f:		im	2
		ld	a,07ch
		ld	i,a
		ld	b,004h
_4457:		call	_444d
		djnz	_4457
		ld	bc,00046h
		ld	hl,intrvec
		ld	de,07c00h
		ldir	
		ret	

intrvec:	word	_656c
		word	_6579
		word	_6586
		word	_43fd
		word	_6593
		word	_65a0
		word	_65ad
		word	_43fd
		word	_65ba
		word	_65c7
		word	_65d4
		word	_43fd
		word	00000h
		word	00000h
		word	00000h
		word	00000h
		word	_6537
		word	_64e4
		word	_648d
		word	_64b2
		word	_652b
		word	_64d8
		word	_6486
		word	_64ac
		word	_4400
		word	_42a1
		word	_4405
		word	_668d
		word	_5487
		word	_440a
		word	_440f
		word	_4414
		word	_4747
		word	_66be
		word	_59c3
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
_451a:		ld	hl,_456c
		ld	(00351h),hl
		xor	a
		ld	(00357h),a
		ld	(00358h),a
		ld	(0035ah),a
		ld	(00359h),a
		ld	ix,00004h
		ld	de,(00186h)
		add	ix,de
		ld	(0018ah),ix
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
		ld	hl,_455d
		jp	_7760

_455d:		defb	0efh,0ffh
		defb	0e4h,0d0h
		defb	0e2h,040h
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
		ld	ix,(0018ah)
		ld	iy,(0033ah)
		ld	hl,(00351h)
		jp	(hl)

_458e:		call	_42ab
		ascii	'FdNoGo',13,10,0
		ret	

_459b:		ld	ix,(0018ah)
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
		ld	ix,(0018ah)
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
		call	_76c0
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
		call	_444d
		ei	
		ld	ix,(0018ah)
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
		ld	a,(0015eh)
		or	020h
		out	(0deh),a
		and	0dfh
		out	(0deh),a
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
		ld	a,002h
		ld	(00183h),a
		ret	

_4850:		ld	ix,(0018ah)
		ld	iy,(0033ah)
		in	a,(0e4h)
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
		call	_76e3
		jr	_4adf

_4adc:		call	_7717
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

_4f18:		ld	ix,(0018ah)
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
_5004:		ld	ix,00020h
		ld	de,(00186h)
		add	ix,de
		ld	(0018ch),ix
		xor	a
		ld	(003b8h),a
		ld	(ix+14h),a
		ld	(003b7h),a
		dec	a
		ld	(003aah),a
		ld	hl,_54c0
		ld	(003b4h),hl
		call	_5615
		ld	hl,_5047
		call	_7760
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

_5047:		defb	0c1h,00eh
		defb	0c4h,038h
		defb	0c4h,003h
		defb	0c4h,0d7h
		defb	0c4h,001h
		defb	000h
_5052:		xor	a
		ld	(003bfh),a
		ld	ix,(0018ch)
		ld	iy,(003a6h)
		ld	hl,(003c0h)
		jp	(hl)

_5062:		call	_42ab
		ascii	'HdNoGo',13,10,0
		ret	

_506f:		ld	ix,(0018ch)
		ld	a,(ix+14h)
		bit	0,a
		jr	z,_5062
		and	00ch
		ld	(003a8h),a
		ld	a,001h
		ld	(003b8h),a
		ld	hl,(0018ch)
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

_5169:		ld	de,(003c5h)
		ld	b,d
		set	7,d
		res	6,d
		rl	b
		ld	a,(003c4h)
		rl	a
		ld	(0015fh),a
		out	(0dfh),a
		ld	a,(0015eh)
		rla	
		rl	b
		rra	
		ld	(0015eh),a
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
		ld	a,(0015eh)
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
		ld	(0015eh),hl
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
		ld	hl,_702c+2
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
		call	_76c0
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
		call	_444d
		ei	
		ld	ix,(0018ch)
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
		ld	a,(0015eh)
		or	020h
		out	(0deh),a
		and	0dfh
		out	(0deh),a
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
		ld	ix,(0018ch)
		ld	iy,(003a6h)
		call	_42ab
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
_55e1:		call	_42ab
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
		ld	(_5942),a
		call	_769c
		ld	hl,_5943
		jr	_5749

_572a:		ld	a,001h
		ld	(_5942),a
		jr	_5735

_5731:		xor	a
		ld	(_5942),a
_5735:		call	_76ad
		ld	de,(00186h)
		ld	hl,00002h
		add	hl,de
		ld	a,(hl)
		and	03fh
		cp	015h
		ret	nz
		ld	(_5964),a
_5749:		push	hl
		di	
		ld	de,(00186h)
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
		ld	ix,(00196h)
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
		ld	a,(_5942)
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
		ld	a,(_5942)
		ld	d,a
		call	_5632
		pop	de
_58b1:		inc	c
		add	iy,de
		djnz	_5897
		call	printimm
		ascii	']',0
_58bb:		ld	a,004h
		ld	(0015eh),a
		out	(0deh),a
		ld	hl,halt_msg
		call	print
		ld	a,(_5942)
		or	a
		jr	nz,_58db
		ld	ix,(00188h)
		res	1,(ix+00h)
_58d6:		call	_75c5
		jr	_58d6

_58db:		di	
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
_5919:		dec	c
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
		out	(0f9h),a
		jp	00000h

_5942:		nop	
_5943:		nop	
halt_msg:	ascii	13,10,'[Z80 Control System Halted]',13,10,0
_5964:		nop	
_5965:		ld	ix,0003ch
		ld	de,(00186h)
		add	ix,de
		ld	(0018eh),ix
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

_59c3:		call	_42ab
		ascii	'IoFake',13,10,0
		ret	

_59d0:		ld	a,(00399h)
		or	a
		ret	z
		xor	a
		ld	(00399h),a
_59d9:		ld	ix,(0018eh)
		ld	iy,(0038dh)
		ld	hl,(0039bh)
		jp	(hl)

_59e5:		call	_42ab
		ascii	'IoNoGo',13,10,0
		ret	

_59f2:		ld	ix,(0018eh)
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
		ld	hl,(0018eh)
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
		call	_42ab
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

_5b2e:		call	_42ab
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
		jp	_774d

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
		ld	hl,_702c+2
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
		call	_76c0
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
		call	_444d
		ld	ix,(0018eh)
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
		ld	a,(0015eh)
		or	020h
		out	(0deh),a
		and	0dfh
		out	(0deh),a
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
		call	_42ab
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
_626a:		ld	hl,_634f
		call	_7760
		ld	hl,_645a
		call	_7760
		ld	hl,_646e
		call	_7760
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
		ld	a,0cdh
		jr	nz,_62a4
		ld	hl,model_6000_16_msg
		ld	a,0c7h
		out	(0f1h),a
		ld	a,001h
		out	(0f1h),a
		jr	_62a7

_62a4:		ld	(_41e9),a
_62a7:		ld	de,0f840h
		ld	bc,0000fh
		ldir	
		in	a,(0fch)
		ld	ix,_6c75
		ld	de,(00186h)
		ld	bc,00004h
		ld	a,00dh
_62be:		ld	l,(ix+02h)
		ld	h,(ix+03h)
		add	hl,de
		ld	(ix+02h),l
		ld	(ix+03h),h
		add	ix,bc
		dec	a
		jr	nz,_62be
		ld	ix,00368h
		add	ix,de
		ld	(00192h),ix
		xor	a
		ld	(ix+00h),a
		ld	(ix+01h),a
		ld	(ix+02h),a
		ld	(008d5h),a
		ld	(008d7h),a
		ld	(008d6h),a
		ld	hl,03602h
		ld	(008d3h),hl
		ld	b,006h
		ld	hl,03600h
_62f8:		ld	(hl),a
		inc	h
		djnz	_62f8
		ld	de,002e6h
		ld	hl,(00186h)
		add	hl,de
		ex	de,hl
		ld	a,00dh
_6306:		ld	bc,0000ah
		ld	hl,_6345
		ldir	
		dec	a
		jr	nz,_6306
		ld	hl,(_6c77)
		ld	de,00009h
		add	hl,de
		ld	(hl),007h
		in	a,(079h)
		ld	d,a
		in	a,(069h)
		or	d
		ret	nz
		ld	a,0c9h
		ld	(_6844),a
		ret	

model_2_msg:	ascii	'[Model II]     '
model_6000_16_msg:
		ascii	'[Model 6000/16]'
_6345:		defb	000h,000h,000h,000h,010h,000h,00dh,000h,000h,000h
_634f:		defb	0f0h,030h
		defb	0f3h,0c7h
		defb	0f3h,001h
		defb	079h,000h
		defb	079h,000h
		defb	079h,000h
		defb	079h,040h
		defb	07bh,000h
		defb	07bh,000h
		defb	07bh,000h
		defb	07bh,040h
		defb	07dh,000h
		defb	07dh,000h
		defb	07dh,000h
		defb	07dh,040h
		defb	069h,000h
		defb	069h,000h
		defb	069h,000h
		defb	069h,040h
		defb	06bh,000h
		defb	06bh,000h
		defb	06bh,000h
		defb	06bh,040h
		defb	06dh,000h
		defb	06dh,000h
		defb	06dh,000h
		defb	06dh,040h
		defb	059h,000h
		defb	059h,000h
		defb	059h,000h
		defb	059h,040h
		defb	05bh,000h
		defb	05bh,000h
		defb	05bh,000h
		defb	05bh,040h
		defb	05dh,000h
		defb	05dh,000h
		defb	05dh,000h
		defb	05dh,040h
		defb	073h,036h
		defb	070h,00dh
		defb	070h,000h
		defb	073h,076h
		defb	071h,00dh
		defb	071h,000h
		defb	073h,0b6h
		defb	072h,00dh
		defb	072h,000h
		defb	063h,036h
		defb	060h,00dh
		defb	060h,000h
		defb	063h,076h
		defb	061h,00dh
		defb	061h,000h
		defb	063h,0b6h
		defb	062h,00dh
		defb	062h,000h
		defb	053h,036h
		defb	050h,00dh
		defb	050h,000h
		defb	053h,076h
		defb	051h,00dh
		defb	051h,000h
		defb	053h,0b6h
		defb	052h,00dh
		defb	052h,000h
		defb	074h,000h
		defb	064h,008h
		defb	054h,010h
		defb	074h,0c5h
		defb	074h,001h
		defb	075h,0c5h
		defb	075h,001h
		defb	076h,0c5h
		defb	076h,001h
		defb	064h,0c5h
		defb	064h,001h
		defb	065h,0c5h
		defb	065h,001h
		defb	066h,0c5h
		defb	066h,001h
		defb	054h,0c5h
		defb	054h,001h
		defb	055h,0c5h
		defb	055h,001h
		defb	056h,0c5h
		defb	056h,001h
		defb	077h,047h
		defb	067h,047h
		defb	057h,047h
		defb	079h,04eh
		defb	079h,037h
		defb	078h,000h
		defb	079h,036h
		defb	07bh,04eh
		defb	07bh,037h
		defb	07ah,000h
		defb	07bh,036h
		defb	07dh,04eh
		defb	07dh,037h
		defb	07ch,000h
		defb	07dh,036h
		defb	069h,04eh
		defb	069h,037h
		defb	068h,000h
		defb	069h,036h
		defb	06bh,04eh
		defb	06bh,037h
		defb	06ah,000h
		defb	06bh,036h
		defb	06dh,04eh
		defb	06dh,037h
		defb	06ch,000h
		defb	06dh,036h
		defb	059h,04eh
		defb	059h,037h
		defb	058h,000h
		defb	059h,036h
		defb	05bh,04eh
		defb	05bh,037h
		defb	05ah,000h
		defb	05bh,036h
		defb	05dh,04eh
		defb	05dh,037h
		defb	05ch,000h
		defb	05dh,036h
		defb	0e3h,042h
		defb	0e3h,00fh
		defb	0e3h,007h
		defb	0e0h,000h
		defb	0e0h,008h
		defb	0e0h,000h
		defb	0e3h,083h
		defb	000h
_645a:		defb	0f6h,018h
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
_646e:		defb	0f7h,018h
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
		in	a,(c)
		call	_66fa
		inc	c
		inc	c
		in	a,(c)
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
		call	_66fa
		pop	bc
		ld	a,030h
		out	(c),a
		jr	_64b7

_64d8:		exx	
		push	iy
		ld	bc,001f6h
		ld	iy,_6ba7
		jr	_64ee

_64e4:		exx	
		push	iy
		ld	bc,002f7h
		ld	iy,_6bb7
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
		call	_66fa
_6516:		ld	a,e
		cp	(iy+02h)
		ld	(iy+02h),a
		jr	z,_6524
		set	7,b
		call	_66fa
_6524:		ex	af,af'
		exx	
		pop	iy
		ei	
		reti	

_652b:		exx	
		push	iy
		ld	bc,001f6h
		ld	iy,_6ba7
		jr	_6541

_6537:		exx	
		push	iy
		ld	bc,002f7h
		ld	iy,_6bb7
_6541:		ex	af,af'
		call	_6552
		ex	af,af'
		exx	
		pop	iy
		ei	
		reti	

_654c:		ld	b,(iy+05h)
		ld	c,(iy+06h)
_6552:		in	a,(c)
		and	004h
		ret	z
		call	_6816
		jr	z,_6565
		dec	c
		dec	c
		out	(c),a
		inc	c
		inc	c
		jp	nc,_6552
_6565:		ld	a,028h
		out	(c),a
		ret	

		jr	_6552

_656c:		exx	
		push	iy
		ld	bc,00479h
		ld	iy,_6bd7
		jp	_65de

_6579:		exx	
		push	iy
		ld	bc,0057bh
		ld	iy,_6be7
		jp	_65de

_6586:		exx	
		push	iy
		ld	bc,0067dh
		ld	iy,_6bf7
		jp	_65de

_6593:		exx	
		push	iy
		ld	bc,00769h
		ld	iy,_6c07
		jp	_65de

_65a0:		exx	
		push	iy
		ld	bc,0086bh
		ld	iy,_6c17
		jp	_65de

_65ad:		exx	
		push	iy
		ld	bc,0096dh
		ld	iy,_6c27
		jp	_65de

_65ba:		exx	
		push	iy
		ld	bc,00a59h
		ld	iy,_6c37
		jp	_65de

_65c7:		exx	
		push	iy
		ld	bc,00b5bh
		ld	iy,_6c47
		jp	_65de

_65d4:		exx	
		push	iy
		ld	bc,00c5dh
		ld	iy,_6c57
_65de:		ex	af,af'
		call	_444d
_65e2:		in	a,(c)
		ld	d,a
		and	(iy+0fh)
		jr	nz,_65f0
		ex	af,af'
		exx	
		pop	iy
		ei	
		ret	

_65f0:		push	af
		and	002h
		call	nz,_661b
		pop	af
		rrca	
		jp	nc,_65e2
		call	_6816
		jr	z,_6607
		dec	c
		out	(c),a
		inc	c
		jp	nc,_65e2
_6607:		ld	hl,00080h
		ld	e,c
		ld	d,000h
		add	hl,de
		ld	a,(hl)
		and	0feh
		ld	(hl),a
		out	(c),a
		res	0,(iy+0fh)
		jp	_65e2

_661b:		dec	c
		in	e,(c)
		inc	c
		ld	a,038h
		and	d
		ld	d,b
		jp	z,_6636
		rlca	
		or	b
		ld	b,a
		push	bc
		ld	b,000h
		ld	hl,00080h
		add	hl,bc
		ld	a,(hl)
		or	010h
		out	(c),a
		pop	bc
_6636:		ld	a,e
		call	_66fa
		ld	b,d
		ret	

_663c:		ld	e,a
		or	a
		jp	p,_6655
		sub	0a1h
		cp	006h
		ld	hl,_6685
		jr	c,_6667
		sub	01eh
		cp	002h
		ld	hl,_668a+1
		jr	c,_6667
		jr	_666c

_6655:		jr	z,_6672
		sub	01ch
		cp	004h
		jr	nc,_666c
		push	af
		ld	a,01bh
		call	_66fa
		pop	af
		ld	hl,_6681
_6667:		ld	e,a
		ld	d,000h
		add	hl,de
		ld	e,(hl)
_666c:		xor	a
		ld	(_6680),a
		ld	a,e
		ret	

_6672:		ld	a,(_6680)
		cpl	
		ld	(_6680),a
		or	a
		ld	a,011h
		ret	z
		ld	a,013h
		ret	

_6680:		nop	
; 'DCAB' but may not be meaningful.
_6681:		defb	044h,043h,041h,042h
_6685:		defb	07ch,060h,01dh,01eh,01fh
_668a:		defb	01ch,05ch
		nop	
_668d:		ex	af,af'
		in	a,(0ffh)
		and	080h
		jr	z,_66ba
		in	a,(0fch)
		call	_6f99
		cp	0abh
		jr	z,_66ba
		cp	0beh
		jr	nz,_66b0
		ld	a,(_6fd4)
		xor	001h
		ld	(_6fd4),a
		jr	z,_66ba
		call	_6fce
		jr	_66ba

_66b0:		exx	
		ld	b,000h
		call	_663c
		call	_66fa
		exx	
_66ba:		ex	af,af'
		ei	
		reti	

_66be:		ex	af,af'
		in	a,(0e0h)
		and	0e0h
		jr	nz,_66d2
		exx	
		push	iy
		ld	iy,_6bc7
		call	_66db
		pop	iy
		exx	
_66d2:		ex	af,af'
		ei	
		reti	

_66d6:		in	a,(0e0h)
		and	0e0h
		ret	nz
_66db:		ld	b,003h
		call	_6816
		ret	z
		out	(0e1h),a
		ret	

		and	07fh		; TODO!
_66e6:		ld	c,(iy+06h)
		ld	b,000h
		ld	hl,00080h
		add	hl,bc
		di	
		set	0,(iy+0fh)
		set	0,(hl)
		outi	
		ei	
		ret	

_66fa:		ld	hl,(008d3h)
		ld	(hl),b
		inc	l
		ld	(hl),a
		inc	l
		jr	z,_671e
		cp	013h
		jr	z,_670e
		ld	(008d3h),hl
		ld	l,000h
		inc	(hl)
		ret	

_670e:		ld	a,(008d5h)
		cp	006h
		jr	nz,_671e
		ld	(008d3h),hl
		ld	l,001h
		ld	(hl),l
		dec	l
		inc	(hl)
		ret	

_671e:		ld	l,000h
		inc	(hl)
_6721:		ld	hl,008d5h
		inc	(hl)
		inc	hl
		ld	a,(hl)
		inc	a
		cp	006h
		jr	nz,_672d
		xor	a
_672d:		ld	(hl),a
		ld	hl,03600h
		add	a,h
		ld	h,a
		ld	(hl),000h
		inc	hl
		ld	(hl),000h
		inc	hl
		ld	(008d3h),hl
		ret	

_673d:		di	
		ld	a,(iy+04h)
		or	a
		jr	z,_677a
		sub	(ix+05h)
		neg	
		ld	(ix+05h),a
		xor	a
		ld	(iy+04h),a
		ld	b,(iy+05h)
		ld	a,b
		cp	004h
		jr	c,_676b
		ld	c,(iy+06h)
		ld	hl,00080h
		ld	b,000h
		add	hl,bc
		ld	a,(hl)
		and	0feh
		ld	(hl),a
		out	(c),a
		res	0,(iy+0fh)
_676b:		ld	a,(ix+04h)
		or	010h
		and	0feh
		ld	(ix+04h),a
		bit	4,a
		call	nz,_6b8c
_677a:		ei	
		ret	

_677c:		ld	b,00dh
		ld	hl,_6c73
		xor	a
_6782:		or	(hl)
		jr	z,_67a2
		ld	(hl),000h
		push	bc
		push	hl
		ld	a,b
		dec	a
		call	_6897
		di	
		ld	a,(ix+04h)
		or	010h
		and	0feh
		ld	(ix+04h),a
		bit	4,a
		call	nz,_6b8c
		ei	
		pop	hl
		pop	bc
		xor	a
_67a2:		dec	hl
		djnz	_6782
		ld	a,(008d5h)
		or	a
		jr	nz,_67bb
		di	
		ld	hl,(008d3h)
		ld	l,001h
		ld	a,(hl)
		or	a
		jr	nz,_67b7
		ei	
		ret	

_67b7:		call	_6721
		ei	
_67bb:		ld	a,(008d7h)
		ld	hl,03600h
		add	a,h
		ld	h,a
		ld	c,(hl)
		inc	hl
		inc	hl
		ld	de,(00192h)
		ld	a,(de)
		dec	c
		add	a,c
		ld	(008d8h),a
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
		ld	h,000h
		rl	h
		add	hl,hl
		add	hl,de
		ex	de,hl
		ex	(sp),hl
		inc	c
		ld	b,000h
		sla	c
		rl	b
		ldir	
		pop	de
		pop	af
		jr	nc,_67f7
		ld	c,a
		xor	a
		push	af
		jr	_67d9

_67f7:		ld	a,(008d8h)
		inc	a
		ld	(de),a
		ld	hl,008d5h
		dec	(hl)
		ld	hl,008d7h
		ld	a,(hl)
		inc	a
		cp	006h
		jr	nz,_680a
		xor	a
_680a:		ld	(hl),a
		ex	de,hl
		inc	hl
		inc	hl
		bit	4,(hl)
		ret	nz
		set	4,(hl)
		jp	_6b8c

_6816:		ld	a,(iy+04h)
		or	a
		ret	z
		ld	h,(iy+08h)
		ld	l,(iy+07h)
		ld	a,(hl)
		inc	hl
		ld	(iy+08h),h
		ld	(iy+07h),l
		dec	(iy+04h)
		ret	nz
		ld	e,b
		ld	hl,_6c67
		ld	d,000h
		adc	hl,de
		ld	(hl),001h
		scf	
		ret	

_6839:		di	
		ld	a,(008d3h)
		cp	002h
		call	nz,_6721
		ei	
		ret	

_6844:		ld	ix,_6c85
		ld	b,009h
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

_6869:		ld	a,c
		and	00fh
		call	_6897
		bit	1,b
		jp	nz,_673d
		ld	l,(iy+09h)
		ld	(iy+07h),l
		ld	h,(iy+0ah)
		ld	(iy+08h),h
		ld	c,(ix+05h)
		ld	b,000h
		call	_7717
		di	
		ld	(iy+04h),c
		ld	l,(iy+0bh)
		ld	h,(iy+0ch)
		call	jphl
		ei	
		ret	

_6897:		push	de
		ld	hl,_6c75
		rlca	
		rlca	
		ld	e,a
		ld	d,000h
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

_68b0:		ld	a,c
		and	00fh
		call	_6897
		ld	l,(iy+0dh)
		ld	h,(iy+0eh)
		jp	(hl)

_68bd:		ld	e,(ix+07h)
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
		ld	c,(iy+06h)
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
		ld	a,(iy+03h)
		and	00fh
		cp	l
		jr	z,_69ad
		ld	a,(_69de)
		ld	d,a
		ld	a,(_69dd)
		ld	b,a
		ld	(iy+03h),l
		ld	a,(iy+05h)
		cp	002h
		jr	z,_69a8
		ld	c,0f0h
		call	_69df
		ld	c,0f1h
		ld	a,(00338h)
		or	a
		call	nz,_69df
		jr	_69ad

_69a8:		ld	c,0f2h
		call	_69df
_69ad:		ei	
		ld	c,(iy+06h)
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
		cp	(iy+02h)
		jr	z,_69db
		ld	(iy+02h),a
		ld	b,(iy+05h)
		set	7,b
		call	_66fa
_69db:		ei	
		ret	

_69dd:		defb	000h
_69de:		defb	047h
_69df:		out	(c),d
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
_6a25:		push	bc
		ld	c,(iy+06h)
		in	b,(c)
		ld	a,(iy+02h)
		and	0f8h
		or	006h
		bit	7,b
		jr	z,_6a38
		or	001h
_6a38:		cp	(iy+02h)
		jr	z,_6a4c
		ld	(iy+02h),a
		di	
		ld	b,(iy+05h)
		set	7,b
		push	hl
		call	_66fa
		pop	hl
		ei	
_6a4c:		pop	bc
		ret	

_6a4e:		ld	b,(ix+06h)
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
		ld	c,(iy+06h)
		di	
		ld	a,040h
		out	(c),a
		nop	
		nop	
		out	(c),e
		nop	
		nop	
		out	(c),d
		ld	(iy+0fh),002h
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
		ld	hl,00080h
		add	hl,de
		ld	(hl),a
		ld	a,(iy+03h)
		ld	(iy+03h),b
		push	af
		ld	a,b
		and	00fh
		ld	b,a
		pop	af
		and	00fh
		cp	b
		call	nz,_6af7
		ei	
		ret	

_6af7:		ld	c,(iy+05h)
		ld	a,(iy+03h)
		and	00fh
		cp	011h
		ret	nc
		add	a,a
		ld	e,a
		ld	d,000h
		ld	hl,_6b2c
		add	hl,de
		ld	e,(hl)
		inc	hl
		ld	d,(hl)
		ld	a,d
		or	e
		ret	z
		ld	a,c
		cp	00dh
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

_6b2c:		word	00000h
		word	009c4h
		word	00683h
		word	00470h
		word	003a4h
		word	00341h
		word	00271h
		word	001a1h
		word	000d0h
		word	00068h
		word	00045h
		word	00034h
		word	0001ah
		word	0000dh
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

_6b67:		ld	a,(_6b9c)
		or	a
		ret	z
		ld	b,000h
		call	_6816
		ei	
		call	nz,putc
		ret	

_6b76:		di	
		ld	a,(_6bcb)
		or	a
		jr	z,_6b8a
		in	a,(0e0h)
		and	0e0h
		jr	nz,_6b8a
		ld	iy,_6bc7
		call	_66db
_6b8a:		ei	
		ret	

_6b8c:		ld	a,(0015eh)
		or	040h
		out	(0deh),a
		and	0bfh
		out	(0deh),a
		ret	

; as in 1.3.5 version there are bunches of addresses here...

_6b98:		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
_6b9c:		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	018h			
		defb	003h			

		word	_6b67
		word	_43fc

_6ba7:		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	001h			
		defb	0f6h			
		defb	000h			
		defb	000h			
		defb	098h			
		defb	001h			

		word	_654c
		word	_68bd

		defb	000h			
_6bb7:		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	002h			
		defb	0f7h			
		defb	000h			
		defb	000h			
		defb	0b8h			
		defb	001h			

		word	_654c
		word	_68bd

		defb	000h			
_6bc7:		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
_6bcb:		defb	000h			
		defb	003h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	0f8h			
		defb	002h			

		word	_66d6
		word	_43fc

		defb	000h			
_6bd7:		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	004h			
		defb	079h			
		defb	000h			
		defb	000h			
		defb	0d8h			
		defb	001h			

		word	_66e6
		word	_6a4e

		defb	000h			
_6be7:		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	005h			
		defb	07bh			
		defb	000h			
		defb	000h			
		defb	0f8h			
		defb	001h			

		word	_66e6
		word	_6a4e

		defb	000h			
_6bf7:		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	006h			
		defb	07dh			
		defb	000h			
		defb	000h			
		defb	018h			
		defb	002h			

		word	_66e6
		word	_6a4e

		defb	000h			
_6c07:		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	007h			
		defb	069h			
		defb	000h			
		defb	000h			
		defb	038h			
		defb	002h			

		word	_66e6
		word	_6a4e

		defb	000h			
_6c17:		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	008h			
		defb	06bh			
		defb	000h			
		defb	000h			
		defb	058h			
		defb	002h			

		word	_66e6
		word	_6a4e

		defb	000h			
_6c27:		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	009h			
		defb	06dh			
		defb	000h			
		defb	000h			
		defb	078h			
		defb	002h			

		word	_66e6
		word	_6a4e

		defb	000h			
_6c37:		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	00ah			
		defb	059h			
		defb	000h			
		defb	000h			
		defb	098h			
		defb	002h			

		word	_66e6
		word	_6a4e

		defb	000h			
_6c47:		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	00bh			
		defb	05bh			
		defb	000h			
		defb	000h			
		defb	0b8h			
		defb	002h			

		word	_66e6
		word	_6a4e

		defb	000h			
_6c57:		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	00ch			
		defb	05dh			
		defb	000h			
		defb	000h			
		defb	0d8h			
		defb	002h			

		word	_66e6
		word	_6a4e

		defb	000h			
_6c67:		defb	000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
_6c73:		defb	000h,001h

_6c75:		word	_6b98
_6c77:		word	$02e6

		word	_6ba7
		word	$2f0

		word	_6bb7
		word	$2fa

		word	_6bc7
		word	$304

_6c85:		word	_6bd7
		word	$30e

		word	_6be7
		word	$318

		word	_6bf7
		word	$322

		word	_6c07
		word	$32c

		word	_6c17
		word	$336

		word	_6c27
		word	$340

		word	_6c37
		word	$34a

		word	_6c47
		word	$354

		word	_6c57
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

_6cd1:		ld	a,(_6b9c)
		or	a
		ret	z
		ld	iy,_6b98
		ld	b,000h
_6cdc:		di	
		call	_6816
		ei	
		ret	z
		call	putc
		ret	c
		jp	_6cdc

_6ce9:		ld	de,(00186h)
		ld	hl,002d4h
		add	hl,de
		ld	(00194h),hl
		xor	a
		ld	(_6f4e),a
		ret	

_6cf9:		call	_76ad
		ld	ix,(00194h)
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
		call	_6b8c
		ei	
		ret	

_6d92:		call	_42ab
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
		call	_7717
		jr	_6dbc

_6db9:		call	_76e3
_6dbc:		pop	hl
		jp	_774d

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
		call	_7676
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
		call	_76ca
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

_6ee1:		call	_76ad
_6ee4:		ld	(ix+0fh),000h
		ld	a,(ix+0ch)
		and	0feh
		or	020h
		di	
		ld	(ix+0ch),a
		call	_6b8c
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

_6f58:		ld	ix,00058h
		ld	de,(00186h)
		add	ix,de
		ld	(00196h),ix
		ld	hl,conout_start
		ld	(console_vec),hl
		xor	a
		ld	(console_flags),a
		ld	a,000h
		ld	(00120h),a
		out	(0a0h),a
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
; the 60 counter there.

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

char_bell:	ld	a,(00120h)
		and	001h
		jp	nz,char_done_noxy
		ld	a,001h
		ld	(00120h),a
		out	(0a0h),a
		ld	a,008h
		ld	(00184h),a
_702c:		jp	char_done_noxy

_702f:		ld	a,000h
		ld	(00120h),a
		out	(0a0h),a
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
		jr	z,_72e0
		cp	'D'
		jr	z,_72e4
		cp	'C'
		jr	z,_72e8
		cp	'c'
		jr	z,_72f6
		cp	'G'
		jr	z,_7308
		cp	'g'
		jr	z,_730c
_72dc:		pop	hl
		jp	char_restart

_72e0:		res	2,(hl)
		jr	_72dc

_72e4:		set	2,(hl)
		jr	_72dc

_72e8:		ld	a,(_7315)
		ld	(_7312+1),a
		ld	hl,_7310
		call	_7760
		jr	_72dc

_72f6:		ld	a,(_7315)
		and	01fh
		or	020h
		ld	(_7312+1),a
		ld	hl,_7310
		call	_7760
		jr	_72dc

_7308:		set	1,(hl)
		jr	_72dc

_730c:		res	1,(hl)
		jr	_72dc

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
		call	_7760
		jp	char_restart

_735c:		ld	a,(_7315)
		and	01fh
		or	060h
		ld	(_7315),a
		ld	(_7312+1),a
		ld	hl,_7310
		call	_7760
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
		call	_7760
		jp	char_restart

_73aa:		ld	a,(_7315)
		and	060h
		or	009h
		ld	(_7315),a
		ld	(_73c7+1),a
		ld	a,009h
		ld	(_73cb+1),a
		ld	hl,_73c5
		call	_7760
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
		ld	ix,(00196h)
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
_75ab:		push	af
		ld	a,(0015eh)
		or	010h
		out	(0deh),a
		and	0efh
		out	(0deh),a
		ld	a,(00181h)
		inc	a
		ld	(00181h),a
		in	a,(0feh)
		pop	af
		retn	

_75c3:		nop	
_75c4:		nop	
_75c5:		ld	a,(00181h)
		ld	hl,00180h
		cp	(hl)
		ret	z
		ld	(hl),a
		ld	hl,00182h
		dec	(hl)
		call	z,_75f1
		call	_6839
		call	_6b76
		ld	hl,00183h
		xor	a
		or	(hl)
		jr	z,_75e6
		dec	(hl)
		call	z,_4850
_75e6:		ld	hl,00184h
		xor	a
		or	(hl)
		ret	z
		dec	(hl)
		call	z,_702f
		ret	

_75f1:		ld	a,(_75c4)
		ld	(hl),a
		ld	hl,(00188h)
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

_7638:		ld	ix,(00186h)
		ld	de,00000h
		add	ix,de
		ld	(00188h),ix
		xor	a
		ld	(ix+00h),a
		ld	(00181h),a
		ld	(00184h),a
		ld	(00183h),a
		ld	a,(_75c4)
		ld	(00182h),a
		ld	(ix+01h),a
		ld	hl,_7673
		ld	de,00066h
		ld	bc,00003h
		ldir	
		ld	a,(0017fh)
		or	020h
		ld	(0017fh),a
		out	(0ffh),a
		in	a,(0feh)
		ret	

_7673:		jp	_75ab

_7676:		ld	d,(ix+02h)
		ld	b,d
		ld	e,(ix+03h)
		set	7,d
		res	6,d
		rl	b
		ld	a,(ix+01h)
		rl	a
		di	
		ld	(0015fh),a
		out	(0dfh),a
		ld	a,(0015eh)
		rla	
		rl	b
		rra	
		ld	(0015eh),a
		out	(0deh),a
		ei	
		ret	

_769c:		ld	a,(0015eh)
		and	07fh
		ld	(0015eh),a
		out	(0deh),a
		xor	a
		ld	(0015fh),a
		out	(0dfh),a
		ret	

_76ad:		ld	a,(0015eh)
		and	07fh
		di	
		ld	(0015eh),a
		out	(0deh),a
		xor	a
		ld	(0015fh),a
		out	(0dfh),a
		ei	
		ret	

_76c0:		ld	a,(0015eh)
		rlca	
		ld	a,(0015fh)
		adc	a,000h
		ret	

_76ca:		ld	a,(0015eh)
		add	a,080h
		di	
		ld	(0015eh),a
		out	(0deh),a
		jp	nc,_76e1
		ld	a,(0015fh)
		inc	a
		ld	(0015fh),a
		out	(0dfh),a
_76e1:		ei	
		ret	

_76e3:		push	bc
		push	de
		push	hl
		push	bc
		call	_7676
		pop	bc
_76eb:		push	hl
		push	bc
		ld	hl,0ffffh
		or	a
		sbc	hl,de
		res	7,h
		res	6,h
		inc	hl
		or	a
		sbc	hl,bc
		jr	nc,_7700
		add	hl,bc
		ld	b,h
		ld	c,l
_7700:		pop	hl
		or	a
		sbc	hl,bc
		ex	(sp),hl
		ldir	
		pop	bc
		call	_76ca
		res	6,d
		ld	a,c
		or	b
		jr	nz,_76eb
		pop	hl
		pop	de
		pop	bc
		jp	_76ad

_7717:		push	bc
		push	de
		push	hl
		push	bc
		call	_7676
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
		call	_76ca
		res	6,d
		ld	a,c
		or	b
		jr	nz,_771f
		pop	hl
		pop	de
		pop	bc
		jp	_76ad

_774d:		ld	a,(ix+03h)
		add	a,l
		ld	(ix+03h),a
		ld	a,(ix+02h)
		adc	a,h
		ld	(ix+02h),a
		ret	nc
		inc	(ix+01h)
		ret	

_7760:		push	bc
		ld	b,000h
_7763:		ld	a,(hl)
		inc	hl
		or	a
		jr	z,_7776
		ld	c,a
		ld	a,(hl)
		inc	hl
		push	hl
		ld	hl,00080h
		add	hl,bc
		ld	(hl),a
		out	(c),a
		pop	hl
		jr	_7763

_7776:		pop	bc
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
		call	_42ab
		ascii	'DbLock',13,10,0
		xor	a
		ret	

_779f:		ld	a,(00339h)
		cp	b
		jr	nz,_77aa
		xor	a
		ld	(00339h),a
		ret	

_77aa:		call	_42ab
		ascii	'IlUlRq Additional: c o',0
		ld	a,b
		call	ring_puthex_spc
		ld	a,(00339h)
		call	ring_puthex_spc
		call	printimm
		ascii	13,10,0
		or	001h
		ret	

_77d7:		push	bc
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
		ld	a,(0015eh)
		ld	b,a
		or	001h
		di	
		out	(0deh),a
		ld	a,087h
		out	(0f8h),a
		nop	
		ld	a,b
		out	(0deh),a
		ei	
_7886:		ld	de,(_78bb)
		ld	hl,(_78b7)
		or	a
		sbc	hl,de
		ld	a,h
		or	l
		jp	z,_76ad
		ld	(_78b7),hl
		ld	hl,(_78b9)
		or	a
		sbc	hl,de
		ld	a,h
		or	l
		jr	z,_78a8
		ld	(_78b9),hl
		jp	_783a

_78a8:		call	_76ca
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
		ld	a,(0015eh)
		ld	b,a
		or	001h
		di	
		out	(0deh),a
		ld	a,087h
		out	(0f8h),a
		nop	
		ld	a,b
		out	(0deh),a
		ei	
_7934:		ld	de,(_7969)
		ld	hl,(_7965)
		or	a
		sbc	hl,de
		ld	a,h
		or	l
		jp	z,_76ad
		ld	(_7965),hl
		ld	hl,(_7967)
		or	a
		sbc	hl,de
		ld	a,h
		or	l
		jr	z,_7956
		ld	(_7967),hl
		jp	_78e8

_7956:		call	_76ca
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
		call	_7676
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
		ld	a,(0015eh)
		ld	b,a
		or	001h
		di	
		out	(0deh),a
		ld	a,087h
		out	(0f8h),a
		nop	
		ld	a,b
		out	(0deh),a
		ei	
_79fe:		ld	de,(_7a38)
		ld	hl,(_7a34)
		or	a
		sbc	hl,de
		ld	a,h
		or	l
		jp	z,_76ad
		ld	(_7a34),hl
		ld	hl,(_7a36)
		or	a
		sbc	hl,de
		ld	a,h
		or	l
		jr	z,_7a20
		ld	(_7a36),hl
		jp	_799f

_7a20:		call	_76ca
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
		call	_7676
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
		ld	a,(0015eh)
		ld	b,a
		or	001h
		di	
		out	(0deh),a
		ld	a,087h
		out	(0f8h),a
		nop	
		ld	a,b
		out	(0deh),a
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

_7aef:		jp	_76ad

_7af2:		call	_76ca
		ld	hl,08000h
		ld	(_7a30),hl
		ld	bc,(_7a34)
		jp	_7a58

_end		equ	$
video_RAM	equ	0f800h

		end	_start
