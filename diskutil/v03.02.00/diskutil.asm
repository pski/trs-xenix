; diskutil 3.2.0 disassembly.
;
; Can be reassembled with zmac.  Suggested workflow is to make changes
; and verify that file still assembles to the original.  Under windows:
;
;	zmac diskutil.asm
;	fc /b zout/diskutil.cim DISKUTIL
;
; For Mac and Linux:
;
;	zmac diskutil.asm
;	cmp zout/diskutil.cim DISKUTIL
;
; If a code section needs to be converted to data, consult zout/z80ctl.lst
; to easily determine the data bytes.
;
; I think have most of the addresses decoded so reassembly with change may work.


; Data for console output.  A simplified version of that in z80ctl as it
; does not handle escape codes to change into inverse video mode and the like.
; As a consequence, doesn't need console_vec as output state never changes.
		org	$70
vram_pos:	defs	2	; top left corner of screen in video RAM
cursor_xy:	defs	2	; cursor XY position (high = Y, low = X)
console_vec:	defs	2	; routine to handle next console output byte

; Interrupt mode 2 is used and the interrupt vector table is at $F700.
; But only seems to apply to the disk cartridge system.

video_RAM	equ	$f800

; This initial chunk appears to be some kind of header.  I'm not entirely
; certain if the execution and load addresses are little or big endian.
; To be safe simply choose addresses that are a multiple of 256.

		org	$1fcc
_begin:		defb	002h
		defb	006h
		defb	000h
		defb	014h
		defb	000h
		defb	000h
		defb	041h
		defb	09ah
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
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
		word	_start		; Load address
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

_start:		di	
		ld	sp,_start
		ld	a,0c9h		; RET
		ld	(00066h),a	; NMI vector
		call	_2378
		call	printimm
_200f:		ascii	'Diskutil  Version 3(42)   3-Mar-87             ',13,10,0
		call	printimm
		ascii	'Copyright 1987 Tandy Corporation',13,10,0
		call	printimm
		ascii	10,10,0
		call	printimm
		ascii	'Diskutil: format or copy floppy diskettes',13,10,0
		call	printimm
		ascii	'          format hard disks',13,10,0
		call	printimm
		ascii	'          format or copy disk cartridges',13,10,0
		call	printimm
		ascii	10,0
		call	printimm
		ascii	'At any time you may type <break> or press RESET to',13,10,0
		call	printimm
		ascii	'abort the procedure.  The backspace key may be used',13,10,0
		call	printimm
		ascii	'to correct single characters of your input.  End each',13,10,0
		call	printimm
		ascii	'line you type by typing <ENTER>.',13,10,10,0
restart:	ld	sp,_start
		ld	a,0ffh
		ld	(0016fh),a
		out	(0efh),a
		call	_6023
		ld	hl,003d3h
		ld	(hl),000h
		ld	de,003d4h
		ld	bc,001ffh
		ldir	
_21dd:		call	printimm
		ascii	13,10,'Diskutil: Hard, floppy, or cartridge (h, f, or c)? ',0
		call	getstr
		ld	a,(00186h)
		or	a
		jr	nz,_21dd
		ld	a,(00185h)
		cp	'f'
		jp	z,_239f
		cp	'h'
		jp	z,_33f9
		cp	'c'
		jp	z,_4cfe
		jr	_21dd

_2233:		call	printimm
		ascii	13,10,'Type <enter> to proceed or <break> to abort: ',0
_2266:		call	waitkey
		cp	3		; BREAK key scancode (or ctl-C)
		jr	z,_2288
		cp	13		; ENTER key scancode
		jr	nz,_2266
		call	printimm
		ascii	13,10,0
		ret	

_2278:		ld	hl,_228b
_227b:		ld	(_2288+1),hl
_227e:		call	havekey
		ret	z
		call	waitkey
		cp	3		; BREAK key scancode
		ret	nz
_2288:		jp	_228b

_228b:		xor	a
		ld	(_4895),a
_228f:		call	printimm
		ascii	12,'Press RESET to re-boot',13,10,0
		jp	restart

getstr:		push	bc
		push	de
		ld	hl,00185h
		ld	(hl),000h
_22b6:		call	waitkey
		cp	3		; BREAK key scancode
		jp	z,_228f
		cp	00dh
		jr	z,_22fd
		cp	8		; backspace
		jr	z,_22e7
		cp	' '
		jr	c,_22b6
		cp	'A'
		jr	c,_22d4
		cp	'Z'+1
		jr	nc,_22d4
		add	a,020h		; lowercase input
_22d4:		ex	de,hl
		ld	hl,001d4h
		or	a
		sbc	hl,de
		ex	de,hl
		jr	z,_22b6
		ld	(hl),a
		call	putc
		inc	hl
		ld	(hl),000h
		jr	_22b6

_22e7:		ex	de,hl
		ld	hl,00185h
		or	a
		sbc	hl,de
		ex	de,hl
		jr	z,_22b6
		dec	hl
		ld	(hl),000h
		call	printimm
		ascii	8,' ',8,0
		jr	_22b6

_22fd:		call	printimm
		ascii	13,10,0
		ld	hl,00185h
		pop	de
		pop	bc
		ret	

; Display A in decimal.
putdec:		push	af
		push	hl
		ld	h,000h
		ld	l,a
		call	putdecHL
		pop	hl
		pop	af
		ret	

; Display HL in decimal but saving most registers.
putdecHL:	push	af
		push	bc
		push	de
		push	hl
		call	putdec16
		pop	hl
		pop	de
		pop	bc
		pop	af
		ret	

; Display HL in decimal.
putdec16:	push	hl
		ld	de,10
		or	a
		sbc	hl,de
		pop	hl
		jr	c,_2334
		call	divmod
		push	hl
		ld	h,b
		ld	l,c
		call	putdec16
		pop	hl
_2334:		ld	a,l
		add	a,'0'
		jp	putc

; Convert string at HL from ASCII decimal to binary in DE.
; Stops at first non-numeric character.
; Returns Z if string started with a digit (i.e., NZ on input error).
atoi:		push	bc
		ld	de,00000h
		ld	b,000h
_2340:		ld	a,(hl)
		or	a
		jr	z,_2365
		inc	hl
		sub	'0'
		cp	10
		jr	nc,_2340
		dec	b
_234c:		ex	de,hl
		push	bc
		ld	b,h
		ld	c,l
		add	hl,hl		; * 2
		add	hl,hl		; * 4
		add	hl,bc		; * 5
		add	hl,hl		; * 10
		ld	c,a
		ld	b,0
		add	hl,bc
		pop	bc
		ex	de,hl
		ld	a,(hl)
		or	a
		jr	z,_2365
		inc	hl
		sub	'0'
		cp	10
		jr	c,_234c
_2365:		inc	b
		pop	bc
		ret	

_2368:		call	printimm
		ascii	13,10,0
		ld	a,0ffh
		ld	(0016fh),a
		out	(0efh),a
		jp	restart

_2378:		ld	a,000h
		ld	(00179h),a
		out	(0f9h),a
		ld	a,00eh
		ld	(0015eh),a
		out	(0deh),a
		ld	a,081h
		ld	(0017fh),a
		out	(0ffh),a
		ld	a,000h
		ld	(0015fh),a
		out	(0dfh),a
		ld	a,006h
		ld	(0015eh),a
		out	(0deh),a
		call	_4cbb
		ret	

_239f:		call	printimm
		ascii	'Copy or format (c or f)? ',0
		call	getstr
		ld	a,(00186h)
		or	a
		jr	nz,_239f
		xor	a
		ld	(00183h),a
		ld	a,(00185h)
		cp	'f'
		jp	z,_26f6
		cp	'c'
		jr	nz,_239f
		ld	a,0ffh
		ld	(00183h),a
_23da:		call	printimm
		ascii	'Source drive number (0..3)? ',0
		call	getstr
		ld	a,(00185h)
		sub	'0'
		cp	004h
		jr	nc,_23da
		ld	(00181h),a
		ld	b,a
_240a:		call	printimm
		ascii	'Destination drive number (0..3)? ',0
		call	getstr
		ld	a,(00185h)
		sub	'0'
		cp	004h
		jr	nc,_240a
		ld	(00180h),a
		cp	b
		jr	nz,_247b
		call	printimm
		ascii	13,10,'Copying a disk to itself is of questionable value.',13,10,0
_247b:		ld	a,0ffh
		ld	(0016fh),a
		out	(0efh),a
		call	printimm
		ascii	13,10,'Insert source disk in drive ',0
		ld	a,(00181h)
		call	putdec
		call	printimm
		ascii	13,10,'Insert destination disk in drive ',0
		ld	a,(00180h)
		call	putdec
		call	printimm
		ascii	13,10,0
		call	_2233
		ld	a,(00180h)
		call	_2dc5
		call	_2c53
		call	_2c70
		ld	a,(00181h)
		call	_2dc5
		call	_2c53
		call	_2d72
		call	printimm
		ascii	13,10,'This will take about ',0
		ld	iy,003c1h
		ld	l,(iy+02h)
		ld	c,(iy+08h)
		ld	h,000h
		ld	b,000h
		call	multiply
		call	putdecHL
		call	printimm
		ascii	' seconds.',13,10,0
		xor	a
		ld	(001d6h),a
		ld	(001d8h),a
_253d:		ld	a,(0016fh)
		and	07fh
		ld	(0016fh),a
		out	(0efh),a
		ld	iy,003c1h
		ld	ix,_2fd1
		ld	a,(001d8h)
		ld	c,a
		ld	a,(001d6h)
		or	c
		jr	z,_256d
		bit	0,(iy+09h)
		jr	z,_256d
		ld	ix,_2fe5
		ld	a,(0016fh)
		or	080h
		ld	(0016fh),a
		out	(0efh),a
_256d:		call	printimm
		ascii	13,'   Copying cylinder ',0
		ld	a,(001d8h)
		call	putdec
		call	printimm
		ascii	', side ',0
		ld	a,(001d6h)
		call	putdec
		ld	c,005h
_259f:		dec	c
		jp	z,_2637
		ld	a,(00180h)
		call	_2dc5
		xor	a
		call	_2e3d
		ld	a,000h
		call	z,_2e3d
		jr	nz,_259f
		call	_2f5e
		call	_2f40
		ld	a,(00181h)
		call	_2dc5
		or	0ffh
		call	_2e3d
		ld	b,00bh
		call	z,_2ecb
		jp	nz,_266a
		ld	a,(00180h)
		call	_2dc5
		or	0ffh
		call	_2e3d
		call	z,_2ea9
		ld	b,001h
		call	z,_2ecb
		jr	nz,_259f
		ld	iy,003c1h
		ld	a,002h
		call	_2e8d
		ld	a,(001d6h)
		inc	a
		ld	(001d6h),a
		cp	(iy+08h)
		jp	c,_253d
		ld	a,005h
		call	_2e8d
		xor	a
		ld	(001d6h),a
		ld	a,(001d8h)
		inc	a
		ld	(001d8h),a
		cp	(iy+02h)
		jp	c,_253d
		call	printimm
		ascii	13,10,'Disk copy and verify complete.',13,10,0
		jp	_247b

_2637:		call	printimm
		ascii	13,10,10,'*** Write to destination disk failed ***',13,10,0
		jr	_2696

_266a:		call	printimm
		ascii	13,10,'*** Read from source disk failed ***',13,10,0
_2696:		call	printimm
		ascii	9,' (track ',0
		ld	a,(001d8h)
		call	putdec
		call	printimm
		ascii	', side ',0
		ld	a,(001d6h)
		call	putdec
		call	printimm
		ascii	', sector ',0
		in	a,(0e6h)
		call	putdec
		call	printimm
		ascii	')',13,10,10,'Destination disk is unusable.',13,10,0
		jp	_2368

_26f6:		call	printimm
		ascii	'Format floppy disk in drive number (0..3)? ',0
		call	getstr
		ld	a,(00186h)
		or	a
		jr	nz,_26f6
		ld	a,(00185h)
		sub	'0'
		cp	4
		jr	nc,_26f6
		ld	(00180h),a
_273a:		call	printimm
		ascii	'Select the format to be used:',13,10,0
		call	printimm
		ascii	'  x  or ENTER for Tandy 16/6000 XENIX format.',13,10,0
		call	printimm
		ascii	'  i  for SD 128x26 (3740/4960) format.  (x, ENTER or i)? ',0
		call	getstr
		ld	a,(00185h)
		or	a
		jr	z,_27ea
		xor	a
		ld	(00184h),a
		ld	(iy+09h),000h
		ld	a,(00185h)
		cp	'i'
		jr	z,_27f5
		cp	'x'
		jp	nz,_273a
_27ea:		or	0ffh
		ld	(00184h),a
		ld	(iy+09h),003h
		jr	_285b

_27f5:		call	printimm
		ascii	'Note:',9,'3740/4960 media formatting selected.',13,10,0
		call	printimm
		ascii	9,'IBM index tracks are not generated by diskutil.',13,10,0
_285b:		ld	hl,_285b
		push	hl
		ld	a,0ffh
		ld	(0016fh),a
		out	(0efh),a
		call	printimm
		ascii	13,10,'About to format ',0
		ld	a,(00184h)
		or	a
		jr	z,_2893
		call	printimm
		ascii	'Tandy Xenix',0
		jr	_28a9

_2893:		call	printimm
		ascii	'IBM single-density',0
_28a9:		call	printimm
		ascii	' floppy disk in drive ',0
		ld	a,(00180h)
		call	putdec
		call	printimm
		ascii	'.',13,10,0
		call	_2233
		ld	a,(00180h)
		call	_2dc5
		call	_2c70
		call	printimm
		ascii	13,10,'This will take about ',0
		ld	iy,003c1h
		ld	l,(iy+02h)
		ld	c,(iy+08h)
		ld	h,000h
		ld	b,000h
		call	multiply
		ld	de,2
		call	divmod
		ld	h,b
		ld	l,c
		call	putdecHL
		call	printimm
		ascii	' seconds.',13,10,0
		xor	a
		ld	(001d6h),a
		ld	(001d8h),a
_2929:		xor	a
		call	_2e3d
		ld	a,(0016fh)
		and	07fh
		ld	(0016fh),a
		out	(0efh),a
		ld	ix,_2fd1
		ld	a,(001d6h)
		ld	c,a
		ld	a,(001d8h)
		or	c
		jr	z,_2959
		ld	a,(00184h)
		or	a
		jr	z,_2959
		ld	ix,_2fe5
		ld	a,(0016fh)
		or	080h
		ld	(0016fh),a
		out	(0efh),a
_2959:		call	printimm
		ascii	13,'   Formatting cylinder ',0
		ld	a,(001d8h)
		call	putdec
		call	printimm
		ascii	', side ',0
		ld	a,(001d6h)
		call	putdec
		ld	c,005h
_298e:		dec	c
		jp	m,_2a2b
		call	_2f5e
		call	_2f40
		ld	b,001h
		call	_2ecb
		jr	nz,_298e
		ld	iy,003c1h
		ld	a,002h
		call	_2e8d
		ld	a,(001d6h)
		inc	a
		ld	(001d6h),a
		cp	(iy+08h)
		jp	c,_2929
		ld	a,005h
		call	_2e8d
		xor	a
		ld	(001d6h),a
		ld	a,(001d8h)
		inc	a
		ld	(001d8h),a
		cp	(iy+02h)
		jp	c,_2929
		ld	a,00ah
		out	(0e4h),a
		call	_2bef
		ld	a,(iy+08h)
		cp	002h
		ld	a,000h
		ld	b,001h
		jr	nz,_29e1
		ld	a,001h
		ld	b,000h
_29e1:		ld	(001d6h),a
		ld	a,b
		ld	(001d8h),a
		xor	a
		call	_2e3d
		ld	a,000h
		call	_3be7
		ld	a,002h
		call	_2f1d
		jr	nz,_2a2b
		call	printimm
		ascii	13,10,10,'Disk format and verification complete.',13,10,0
		call	_4c69
		ret	

_2a2b:		call	_4c69
		call	printimm
		ascii	13,10,'*** Format verify failed ***',13,10,0
		call	printimm
		ascii	9,' (track ',0
		ld	a,(001d8h)
		call	putdec
		call	printimm
		ascii	', side ',0
		ld	a,(001d6h)
		call	putdec
		call	printimm
		ascii	', sector ',0
		in	a,(0e6h)
		call	putdec
		call	printimm
		ascii	')',13,10,10,'Disk is unusable.',13,10,0
		call	_4c69
		ld	hl,endbuf
		ld	de,_end
		ld	bc,_2ede+2
		ld	(hl),000h
		ldir	
		xor	a
		ld	(001d6h),a
		ld	(001d8h),a
		call	_2e3d
		call	_2f40
		ld	a,001h
		ld	(001d8h),a
		xor	a
		call	_2e3d
		call	_2f40
		jp	_4c69

_2acf:		ld	iy,003c1h
		ld	(iy+09h),000h
		ld	a,00ah
		out	(0e4h),a
		call	_2bef
		in	a,(0e4h)
		and	040h
		jr	z,_2ae8
		set	4,(iy+09h)
_2ae8:		ld	a,(0016fh)
		and	07fh
		ld	(0016fh),a
		out	(0efh),a
		ld	a,(0016fh)
		or	040h
		ld	(0016fh),a
		out	(0efh),a
		ld	hl,003cbh
		call	_4ce6
		ld	a,0c0h
		out	(0e4h),a
		call	_2bef
		in	a,(0e4h)
		and	09ch
		jr	z,_2b36
		ld	a,(0016fh)
		or	080h
		ld	(0016fh),a
		out	(0efh),a
		ld	hl,003cbh
		call	_4ce6
		ld	a,0c0h
		out	(0e4h),a
		call	_2bef
		in	a,(0e4h)
		and	09ch
		ld	b,002h
		jp	nz,_2be2
		set	1,(iy+09h)
		jp	_2b9c

_2b36:		ld	a,(003ceh)
		ld	(_2be6),a
		ld	a,001h
		out	(0e7h),a
		ld	a,01ah
		out	(0e4h),a
		call	_2bef
		in	a,(0e4h)
		inc	(iy+01h)
		ld	a,(0016fh)
		or	080h
		ld	(0016fh),a
		out	(0efh),a
		ld	hl,003cbh
		call	_4ce6
		ld	a,0c0h
		out	(0e4h),a
		call	_2bef
		in	a,(0e4h)
		and	09ch
		jr	z,_2b8b
		ld	a,(0016fh)
		and	07fh
		ld	(0016fh),a
		out	(0efh),a
		ld	hl,003cbh
		call	_4ce6
		ld	a,0c0h
		out	(0e4h),a
		call	_2bef
		in	a,(0e4h)
		and	09ch
		ld	b,002h
		jp	nz,_2be2
		jr	_2b9c

_2b8b:		ld	a,(_2be6)
		or	a
		ld	b,002h
		jp	nz,_2be2
		set	0,(iy+09h)
		set	1,(iy+09h)
_2b9c:		ld	a,(003ceh)
		ld	b,a
		inc	b
		ld	hl,00040h
_2ba4:		add	hl,hl
		djnz	_2ba4
		ld	(iy+04h),l
		ld	(iy+05h),h
		bit	1,(iy+09h)
		ld	hl,_2be7
		jr	z,_2bb9
		ld	hl,_2beb
_2bb9:		ld	c,a
		ld	b,000h
		add	hl,bc
		ld	a,(hl)
		ld	(iy+06h),a
		xor	a
_2bc2:		push	af
		in	a,(0e0h)
		and	002h
		ld	a,001h
		jr	z,_2bcc
		inc	a
_2bcc:		ld	(iy+08h),a
		ld	(iy+02h),04dh
		ld	a,(001d5h)
		ld	c,a
		ld	b,000h
		ld	hl,001dch
		add	hl,bc
		in	a,(0e5h)
		ld	(hl),a
		pop	af
		ret	

_2be2:		or	0ffh
		jr	_2bc2

_2be6:		nop	
_2be7:		ld	a,(de)
		dec	c
		ex	af,af'
		inc	b
_2beb:		inc	(hl)
		ld	a,(de)
		djnz	_2bf7
_2bef:		push	bc
		push	de
		push	hl
		ld	hl,00000h
_2bf5:		in	a,(0e0h)
_2bf7:		and	001h
		jr	nz,_2c4f
		call	_2278
		dec	hl
		ld	a,l
		or	h
		jr	nz,_2bf5
		call	printimm
		ascii	13,10,'Floppy disk operation aborted.',13,10,0
		call	printimm
		ascii	'Destination disk is unusable.',13,10,0
		jp	_2368

_2c4f:		pop	hl
		pop	de
		pop	bc
		ret	

_2c53:		push	bc
		push	de
		push	hl
		call	_2df5
		ld	a,00bh
		out	(0e4h),a
		call	_2bef
		ld	a,(001d5h)
		ld	c,a
		ld	b,000h
		ld	hl,001dch
		add	hl,bc
		ld	(hl),000h
		pop	hl
		pop	de
		pop	bc
		ret	

_2c70:		call	_2acf
		jr	nz,_2cd9
		call	printimm
		ascii	13,10,'*** Destination disk is not blank ***',13,10,0
		call	printimm
		ascii	'Any data on it now will be lost if you proceed',13,10,0
		call	_2233
_2cd9:		bit	4,(iy+09h)
		ret	z
		call	printimm
		ascii	'*** Destination disk is write-protected ***',13,10,10,0
		call	printimm
		ascii	'Affix a write-enable tab to the disk',13,10,0
		call	printimm
		ascii	'and replace the disk if you want to proceed.',13,10,0
		call	_2233
		jp	_2c70

_2d72:		call	_2acf
		jr	nz,_2d8b
		bit	0,(iy+09h)
		jr	z,_2d85
		ld	a,(iy+06h)
		cp	010h
		ret	z
		jr	_2d8b

_2d85:		ld	a,(iy+06h)
		cp	01ah
		ret	z
_2d8b:		call	printimm
		ascii	13,10,10,'Source disk not in TRS-XENIX or IBM SD format.',13,10,0
		jp	_2368

_2dc5:		push	bc
		push	de
		push	hl
		ld	(001d5h),a
		ld	c,a
		ld	b,000h
		ld	hl,001dch
		add	hl,bc
		ld	a,(hl)
		out	(0e5h),a
		ld	a,(001d5h)
		ld	b,0feh
_2dda:		or	a
		jr	z,_2de2
		rlc	b
		dec	a
		jr	_2dda

_2de2:		ld	a,(0016fh)
		or	00fh
		and	b
		ld	a,a
		ld	(0016fh),a
		out	(0efh),a
		call	_2df5
		pop	hl
		pop	de
		pop	bc
		ret	

_2df5:		push	hl
		ld	hl,00000h
_2df9:		in	a,(0e4h)
		and	080h
		jr	z,_2e3b
		ex	(sp),hl
		ex	(sp),hl
		dec	hl
		ld	a,l
		or	h
		jr	nz,_2df9
		call	printimm
		ascii	13,10,'Floppy disk drive ',0
		ld	a,(001d5h)
		call	putdec
		call	printimm
		ascii	' is not ready.',13,10,0
		jp	_2368

_2e3b:		pop	hl
		ret	

_2e3d:		push	bc
		push	de
		push	hl
		or	a
		ld	b,000h
		jr	z,_2e47
		ld	b,004h
_2e47:		ld	a,(0016fh)
		or	040h
		ld	(0016fh),a
		out	(0efh),a
		ld	a,(001d6h)
		or	a
		jr	z,_2e61
		ld	a,(0016fh)
		and	0bfh
		ld	(0016fh),a
		out	(0efh),a
_2e61:		ld	a,(001d8h)
		out	(0e7h),a
		ex	(sp),hl
		ex	(sp),hl
		ld	a,01bh
		or	b
		out	(0e4h),a
		call	_2bef
		ld	a,(001d5h)
		ld	c,a
		ld	b,000h
		ld	hl,001dch
		add	hl,bc
		in	a,(0e4h)
		and	098h
		in	a,(0e5h)
		ld	(hl),a
		ld	bc,0092eh
_2e84:		dec	bc
		ld	a,b
		or	c
		jr	nz,_2e84
		pop	hl
		pop	de
		pop	bc
		ret	

_2e8d:		push	bc
		push	de
		push	hl
		ld	hl,_3014
		ld	b,a
_2e94:		ld	a,(hl)
		cp	0ffh
		jr	z,_2ea5
		sub	b
		jr	z,_2e9f
		jp	p,_2ea1
_2e9f:		add	a,010h
_2ea1:		ld	(hl),a
		inc	hl
		jr	_2e94

_2ea5:		pop	hl
		pop	de
		pop	bc
		ret	

_2ea9:		push	bc
		push	de
		push	hl
		ld	hl,endbuf
		ld	e,(ix+00h)
		ld	d,(ix+01h)
_2eb5:		ld	a,(de)
		call	_2f1d
		jr	nz,_2ec7
		ld	c,(ix+12h)
		ld	b,(ix+13h)
		add	hl,bc
		inc	de
		ld	a,(de)
		inc	a
		jr	nz,_2eb5
_2ec7:		pop	hl
		pop	de
		pop	bc
		ret	

_2ecb:		push	bc
		push	de
		push	hl
		ld	hl,endbuf
		ld	e,(ix+00h)
		ld	d,(ix+01h)
_2ed7:		ld	a,(de)
		call	_2eef
		jr	nz,_2eeb
		push	bc
_2ede:		ld	c,(ix+12h)
		ld	b,(ix+13h)
		add	hl,bc
		pop	bc
		inc	de
		ld	a,(de)
		inc	a
		jr	nz,_2ed7
_2eeb:		pop	hl
		pop	de
		pop	bc
		ret	

_2eef:		push	bc
		push	de
		push	hl
		ld	c,a
_2ef3:		dec	b
		jp	m,_2f19
		push	bc
		push	de
		push	hl
		call	_4ce6
		pop	hl
		pop	de
		pop	bc
		ld	a,c
		out	(0e6h),a
		ex	(sp),hl
		ex	(sp),hl
		ld	a,080h
		out	(0e4h),a
		call	_2bef
		call	_4cbb
		in	a,(0e4h)
		bit	4,a
		jr	nz,_2f19
		and	09ch
		jr	nz,_2ef3
_2f19:		pop	hl
		pop	de
		pop	bc
		ret	

_2f1d:		push	bc
		push	de
		push	hl
		push	af
		call	_4ccc
		pop	af
		out	(0e6h),a
		ex	(sp),hl
		ex	(sp),hl
		ld	a,0a0h
		out	(0e4h),a
		call	_2bef
		call	_4cbb
		in	a,(0e4h)
		and	09ch
		push	af
		call	delay119
		pop	af
		pop	hl
		pop	de
		pop	bc
		ret	

_2f40:		push	bc
		push	de
		push	hl
		ld	hl,endbuf
		call	_4ccc
		ld	a,0f0h
		out	(0e4h),a
		call	_2bef
		call	_4cbb
		in	a,(0e4h)
		push	af
		call	delay119
		pop	af
		pop	hl
		pop	de
		pop	bc
		ret	

_2f5e:		push	bc
		push	de
		push	hl
		push	iy
		ld	de,endbuf
		ld	l,(ix+06h)
		ld	h,(ix+07h)
		ld	c,(ix+08h)
		ld	b,(ix+09h)
		ldir	
		ld	l,(ix+00h)
		ld	h,(ix+01h)
		push	hl
		pop	iy
_2f7d:		ld	l,(ix+0eh)
		ld	h,(ix+0fh)
		ld	a,(iy+00h)
		ld	(hl),a
		ld	l,(ix+0ah)
		ld	h,(ix+0bh)
		ld	a,(001d8h)
		ld	(hl),a
		ld	l,(ix+0ch)
		ld	h,(ix+0dh)
		ld	a,(001d6h)
		ld	(hl),a
		ld	l,(ix+02h)
		ld	h,(ix+03h)
		ld	c,(ix+04h)
		ld	b,(ix+05h)
		ldir	
		inc	iy
		ld	a,(iy+00h)
		cp	0ffh
		jr	nz,_2f7d
		ld	b,00ah
_2fb4:		push	bc
		ld	l,(ix+06h)
		ld	h,(ix+07h)
		ld	c,(ix+08h)
		ld	b,(ix+09h)
		ldir	
		pop	bc
		djnz	_2fb4
		pop	iy
		pop	hl
		pop	de
		pop	bc
		ret	

; Including the cost of the call this is a 119.5 microsecond delay
; with the Z-80 running at 4 MHz.
delay119:	ld	b,023h
_2fce:		djnz	_2fce
		ret	

_2fd1:		defb	0f9h
		defb	02fh
		defb	03fh
		defb	033h
		defb	0bah
		defb	000h
		defb	025h
		defb	030h
		defb	028h
		defb	000h
		defb	046h
		defb	033h
		defb	047h
		defb	033h
		defb	048h
		defb	033h
		defb	05dh
		defb	033h
		defb	080h
		defb	000h
_2fe5:		defb	014h
		defb	030h
		defb	0cdh
		defb	030h
		defb	072h
		defb	002h
		defb	04dh
		defb	030h
		defb	080h
		defb	000h
		defb	0ddh
		defb	030h
		defb	0deh
		defb	030h
		defb	0dfh
		defb	030h
		defb	008h
		defb	031h
		defb	000h
		defb	002h
		defb	001h
		defb	002h
		defb	003h
		defb	004h
		defb	005h
		defb	006h
		defb	007h
		defb	008h
		defb	009h
		defb	00ah
		defb	00bh
		defb	00ch
		defb	00dh
		defb	00eh
		defb	00fh
		defb	010h
		defb	011h
		defb	012h
		defb	013h
		defb	014h
		defb	015h
		defb	016h
		defb	017h
		defb	018h
		defb	019h
		defb	01ah
		defb	0ffh
_3014:		defb	001h
		defb	002h
		defb	003h
		defb	004h
		defb	005h
		defb	006h
		defb	007h
		defb	008h
		defb	009h
		defb	00ah
		defb	00bh
		defb	00ch
		defb	00dh
		defb	00eh
		defb	00fh
		defb	010h

; dc N,M does N bytes filled with M.

		dc	41,$ff
		dc	128,$4e
		dc	12,$00

		defb	0f5h
		defb	0f5h
		defb	0f5h
		defb	0feh
		defb	000h
		defb	000h
		defb	001h
		defb	002h
		defb	0f7h

		dc	22,$4e

		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	0f5h
		defb	0f5h
		defb	0f5h
		defb	0fbh

_3108:		rept	256
		defb	$6d
		defb	$b6
		endm

		defb	0f7h

		dc	54,$4e

		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	0feh
		defb	000h
		defb	000h
		defb	001h
		defb	000h
		defb	0f7h

		dc	11,$ff

		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	0fbh

		dc	128,$e5

		defb	0f7h

		dc	27,$ff

_33f9:		ld	a,080h
		out	(0ffh),a
		ld	a,004h
		out	(0deh),a
		xor	a
		out	(0dfh),a
		ld	ix,0a000h
		ld	de,01234h
		ld	(ix+00h),e
		ld	(ix+01h),d
		ld	a,004h
		push	af
		or	001h
		out	(0deh),a
		ld	l,(ix+00h)
		ld	h,(ix+01h)
		pop	af
		out	(0deh),a
		xor	a
		or	a
		sbc	hl,de
		adc	a,000h
		ld	(_427f),a
		ld	a,006h
		out	(0deh),a
		ld	a,081h
		out	(0ffh),a
		ld	iy,001e7h
_3436:		call	printimm
		ascii	'Hard disk unit number (0..3)? ',0
		call	getstr
		ld	a,(00185h)
		sub	'0'
		jr	c,_3436
		cp	4
		jr	nc,_3436
		push	af
		xor	a
		ld	(_3bf0),a
		pop	af
		call	_43ce
		push	af
		call	_40c8
		pop	af
		jp	nz,_35a2
_3477:		xor	a
		ld	(_3bf0),a
		ld	a,(_427f)
		or	a
		jp	nz,_35a2
		call	printimm
		ascii	'Destructive or Non-destructive format (d or n)? ',0
		call	getstr
		ld	a,(00186h)
		or	a
		jr	nz,_3477
		ld	a,(00185h)
		cp	'd'
		jp	z,_35a2
		cp	'n'
		jr	nz,_3477
		ld	(_3bf0),a
_34ce:		ld	a,(iy+59h)
		cp	(iy+57h)
		jr	nz,_354b
		call	printimm
		ascii	'There are no more replacement tracks available on this disk.',13,10,'If you do not want to continue, press <BREAK>.',13,10,0
		jp	_35a2

_354b:		call	printimm
		ascii	'Do you wish to ADD any new bad tracks (y or n)? ',0
		call	getstr
		ld	a,(00185h)
		or	a
		jp	z,_35a2
		ld	a,(00186h)
		or	a
		jp	nz,_34ce
		ld	a,(00185h)
		cp	'n'
		jp	z,_35a2
		cp	'y'
		jp	nz,_34ce
		call	_450b
		jr	_35a2

_35a2:		ld	a,(_3bf0)
		or	a
		jp	nz,_36c4
		ld	hl,_3f30
		ld	bc,00010h
		ld	de,001f1h
		ldir	
		ld	hl,_3f40
		ld	bc,00188h
		ld	de,00239h
		ldir	
		call	printimm
		ascii	'Consult your computer manual, or the instruction sheet that',13,10,0
		call	printimm
		ascii	'accompanies your hard disk, for the answers to the following',13,10,0
		call	printimm
		ascii	'two questions:',13,10,10,0
_3657:		call	printimm
		ascii	'How many cylinders (tracks)? ',0
		call	getstr
		call	atoi
		jr	nz,_3657
		ld	hl,0001eh
		or	a
		sbc	hl,de
		jr	nc,_3657
		ld	hl,00400h
		or	a
		sbc	hl,de
		jr	c,_3657
		ld	(iy+10h),d
		ld	(iy+11h),e
_3696:		call	printimm
		ascii	'How many heads? ',0
		call	getstr
		call	atoi
		jr	nz,_3696
		ld	a,e
		cp	002h
		jr	c,_3696
		cp	009h
		jr	nc,_3696
		ld	(iy+12h),d
		ld	(iy+13h),e
		call	_4112
_36c4:		call	_44d8
		call	_4101
		ld	a,(_427f)
		or	a
		call	z,_4225
		ld	a,(_3bf0)
		or	a
		call	z,_45f2
		call	_3875
		ld	a,(0014eh)
		and	0f8h
		or	020h
		ld	a,a
		ld	(0014eh),a
		out	(0ceh),a
		ld	a,000h
		ld	(0014ch),a
		out	(0cch),a
		ld	a,000h
		ld	(0014dh),a
		out	(0cdh),a
		ld	a,(_3bf0)
		or	a
		jr	nz,_3721
		ld	a,001h
		ld	(0014bh),a
		out	(0cbh),a
		ld	hl,001f1h
		ld	de,endbuf
		ld	bc,00010h
		ldir	
		ld	h,d
		ld	l,e
		inc	de
		ld	(hl),000h
		ld	bc,00200h
		ldir	
		ld	hl,endbuf
		call	_3e16
		jp	nz,_37fa
_3721:		ld	hl,003c1h
		push	hl
		pop	de
		push	de
		inc	de
		ld	(hl),000h
		ld	bc,00200h
		ldir	
		pop	hl
		push	hl
		ld	de,00239h
		or	a
		sbc	hl,de
		ld	de,00010h
_373a:		or	a
		sbc	hl,de
		jr	nc,_373a
		add	hl,de
		ex	de,hl
		ld	hl,00010h
		or	a
		sbc	hl,de
		ex	de,hl
		pop	hl
		add	hl,de
		ld	de,00010h
		add	hl,de
		ex	de,hl
		ld	hl,_3855
		ld	bc,00020h
		ldir	
		ld	hl,_200f+18
_375a:		ld	a,(hl)
		or	a
		jr	z,_3763
		ld	(de),a
		inc	de
		inc	hl
		jr	_375a

_3763:		ld	a,003h
		ld	(0014bh),a
		out	(0cbh),a
		ld	hl,00239h
		call	_3e16
		jp	nz,_3803
		ld	a,(_3bf0)
		or	a
		jr	nz,_37f4
		call	printimm
		ascii	'Drive parameters and MEDIA ERROR MAP successfully written.',13,10,0
		call	printimm
		ascii	'Your hard disk is ready for the XENIX initialization.',13,10,0
_37f4:		call	_4c69
		jp	restart

_37fa:		call	printimm
		ascii	'PVH',0
		jr	_380f

_3803:		call	printimm
		ascii	'BT table',0
_380f:		call	_4c69
		call	printimm
		ascii	' disk write failed: Drive parameters cannot be written.',13,10,0
		call	_4c69
		jp	_3ee1

_3855:		ascii	'Copyright 1987  Tandy Corp.     '
_3875:		ld	a,066h
		ld	(_3af2),a
		ld	a,(_3bf0)
		or	a
		jr	nz,_38c3
		call	printimm
		ascii	'Full, partial, or no verify (f,p,n) ?  ',0
		call	getstr
		ld	a,(00185h)
		or	a
		jr	z,_38c3
		cp	'f'
		jr	z,_38c0
		cp	'p'
		jr	z,_38c0
		cp	'n'
		jr	nz,_3875
_38c0:		ld	(_3af2),a
_38c3:		call	printimm
		ascii	10,'About to format hard disk drive ',0
		ld	a,(001e0h)
		call	putdec
		call	printimm
		ascii	'.',13,10,0
		call	_4133
		call	_2233
		call	printimm
		ascii	10,0
		ld	a,0ffh
		ld	(_3a6f),a
		call	_40ea
		call	_3bf1
		ld	b,(iy+10h)
		ld	c,(iy+11h)
		ld	a,000h
		ld	(0014ch),a
		out	(0cch),a
		ld	a,000h
		ld	(0014dh),a
		out	(0cdh),a
_391f:		ld	a,(_3af2)
		cp	06eh
		call	z,_3a15
		ld	e,(iy+13h)
		ld	a,(0014eh)
		and	0f8h
		or	020h
		ld	a,a
		ld	(0014eh),a
		out	(0ceh),a
_3937:		push	bc
		push	de
		ld	a,(_3af2)
		cp	06eh
		call	nz,_3a15
		call	_3af3
		push	af
		ld	a,(_3bf0)
		or	a
		jr	z,_394e
		pop	af
		jr	_396e

_394e:		pop	af
		jr	nz,_396b
		ld	a,(_3af2)
		cp	06eh
		jr	z,_396e
		ld	a,001h
		call	_3b9e
		jr	nz,_396b
		ld	a,(_3af2)
		cp	066h
		jr	nz,_396e
		ld	a,000h
		call	_3b9e
_396b:		call	nz,_3a70
_396e:		pop	de
		pop	bc
		dec	e
		jr	z,_397f
		ld	a,(0014eh)
		inc	a
		ld	(0014eh),a
		out	(0ceh),a
		jp	_3937

_397f:		ld	a,(0014ch)
		add	a,001h
		ld	(0014ch),a
		out	(0cch),a
		ld	a,(0014dh)
		adc	a,000h
		ld	(0014dh),a
		out	(0cdh),a
		dec	bc
		ld	a,b
		or	c
		jp	nz,_391f
		ld	a,(_3bf0)
		or	a
		jr	nz,_39d9
		ld	bc,00000h
		ld	a,(iy+13h)
		ld	e,002h
		cp	003h
		jr	nc,_39b3
		ld	e,000h
		inc	c
		cp	002h
		jr	z,_39b3
		inc	c
_39b3:		ld	a,(0014eh)
		and	0f8h
		or	e
		ld	(0014eh),a
		out	(0ceh),a
		ld	a,c
		ld	(0014ch),a
		out	(0cch),a
		ld	a,b
		ld	(0014dh),a
		out	(0cdh),a
		ld	a,003h
		ld	(0014bh),a
		out	(0cbh),a
		ld	a,000h
		call	_3be7
		call	_3e16
_39d9:		call	printimm
		ascii	13,10,10,'Hard disk successfully ',0
		ld	a,(_3bf0)
		or	a
		jr	z,_3a04
		call	printimm
		ascii	're-',0
_3a04:		call	printimm
		ascii	'formatted.',13,10,0
		ret	

_3a15:		ld	a,(_3a6f)
		ld	l,a
		ld	a,(0014ch)
		cp	l
		ld	(_3a6f),a
		jr	z,_3a62
		call	printimm
		ascii	13,'   Formatting cylinder ',0
		ld	a,(0014ch)
		ld	l,a
		ld	a,(0014dh)
		ld	h,a
		call	putdecHL
		ld	a,(_3af2)
		cp	06eh
		ret	z
		call	printimm
		ascii	', head ',0
_3a5a:		ld	a,(0014eh)
		and	007h
		jp	putdec

_3a62:		ld	a,(_3af2)
		cp	06eh
		ret	z
		call	printimm
		ascii	8,0
		jr	_3a5a

_3a6f:		nop	
_3a70:		call	_4896
		ret	nz
		ld	a,(_3a6f)
		dec	a
		ld	(_3a6f),a
		call	printimm
		ascii	13,10,'      Entering in MEDIA ERROR MAP',13,10,0
		ld	a,(0014ch)
		ld	c,a
		ld	a,(0014dh)
		ld	b,a
		ld	a,(0014eh)
		and	007h
		ld	d,000h
		ld	e,a
		or	b
		or	c
		jp	nz,_48ca
		call	printimm
		ascii	13,10,'Cyl 0 head 0 is bad; the drive cannot be used.',13,10,0
		jp	_2368

_3af2:		nop	
_3af3:		ld	a,(_3bf0)
		or	a
		jr	z,_3b42
		call	_4896
		ret	nz
		call	_4280
		jr	z,_3b42
		call	printimm
		ascii	13,10,'      Error: can',39,'t read data on track. Skipping.',13,10,0
		ld	a,(_3a6f)
		dec	a
		ld	(_3a6f),a
		ret	

_3b42:		ld	a,011h
		ld	(0014ah),a
		out	(0cah),a
		ld	a,01eh
		ld	(0014bh),a
		out	(0cbh),a
		ld	a,(00149h)
		out	(0c9h),a
		ld	a,050h
		ld	(0014fh),a
		out	(0cfh),a
		ld	hl,endbuf
		ld	bc,000c8h
		call	_3d7c
		otir	
		otir	
		call	_3d59
		in	a,(0cfh)
		push	af
		call	_40c8
		pop	af
		xor	040h
		and	0e1h
		jr	z,_3b83
		ld	a,(_3bf0)
		or	a
		jp	nz,_496d
		or	0ffh
		ret	

_3b83:		ld	a,(_3bf0)
		or	a
		ret	z
		call	_43a8
		jp	nz,_496d
		xor	a
		ld	(_4335),a
		call	_4280
		ld	a,001h
		ld	(_4335),a
		ret	z
		jp	_496d

_3b9e:		push	bc
		push	de
		push	hl
		call	_3be7
		ld	b,011h
		ld	de,_3c6f
_3ba9:		ld	a,(de)
		inc	de
		push	de
		ld	c,a
		ld	(0014bh),a
		out	(0cbh),a
		call	_3e60
		pop	de
		jr	nz,_3be3
		djnz	_3ba9
		ld	b,011h
		ld	de,_3c6f
_3bbf:		ld	a,(de)
		inc	de
		push	de
		ld	c,a
		ld	(0014bh),a
		out	(0cbh),a
		push	bc
		ld	a,020h
		ld	(0014fh),a
		out	(0cfh),a
		call	_3d59
		in	a,(0cfh)
		and	001h
		push	af
		call	_40c8
		pop	af
		pop	bc
		pop	de
		jr	nz,_3be3
		djnz	_3bbf
		xor	a
_3be3:		pop	hl
		pop	de
		pop	bc
		ret	

_3be7:		or	a
		ld	hl,_3108
		ret	nz
		ld	hl,003d3h
		ret	

_3bf0:		nop	
_3bf1:		ld	hl,(interleave)
		ld	de,endbuf
_3bf7:		xor	a
		ld	(de),a
		inc	de
		ldi	
		ld	a,(hl)
		inc	a
		jr	nz,_3bf7
		ld	hl,0639ah
		or	a
		sbc	hl,de
		ld	b,h
		ld	c,l
		ld	h,d
		ld	l,e
		inc	de
		ld	(hl),000h
		ldir	
		ld	a,011h
		ld	(0014ah),a
		out	(0cah),a
		ret	

interleave:	word	_3ca5

interleave_table:
		word	_3c39
		word	_3c4b
		word	_3c5d
		word	_3c6f
		word	_3c81
		word	_3c93
		word	_3ca5
		word	_3cb7
		word	_3cc9
		word	_3cdb
		word	_3ced
		word	_3cff
		word	_3d11
		word	_3d23
		word	_3d35
		word	_3d47

_3c39:		defb	001h,002h,003h,004h,005h,006h,007h,008h
		defb	009h,00ah,00bh,00ch,00dh,00eh,00fh,010h
		defb	011h,0ffh
_3c4b:		defb	001h,00ah,002h,00bh,003h,00ch,004h,00dh
		defb	005h,00eh,006h,00fh,007h,010h,008h,011h
		defb	009h,0ffh
_3c5d:		defb	001h,007h,00dh,002h,008h,00eh,003h,009h
		defb	00fh,004h,00ah,010h,005h,00bh,011h,006h
		defb	00ch,0ffh
_3c6f:		defb	001h,00eh,00ah,006h,002h,00fh,00bh,007h
		defb	003h,010h,00ch,008h,004h,011h,00dh,009h
		defb	005h,0ffh
_3c81:		defb	001h,008h,00fh,005h,00ch,002h,009h,010h
		defb	006h,00dh,003h,00ah,011h,007h,00eh,004h
		defb	00bh,0ffh
_3c93:		defb	001h,004h,007h,00ah,00dh,010h,002h,005h
		defb	008h,00bh,00eh,011h,003h,006h,009h,00ch
		defb	00fh,0ffh
_3ca5:		defb	001h,006h,00bh,010h,004h,009h,00eh,002h
		defb	007h,00ch,011h,005h,00ah,00fh,003h,008h
		defb	00dh,0ffh
_3cb7:		defb	001h,010h,00eh,00ch,00ah,008h,006h,004h
		defb	002h,011h,00fh,00dh,00bh,009h,007h,005h
		defb	003h,0ffh
_3cc9:		defb	001h,003h,005h,007h,009h,00bh,00dh,00fh
		defb	011h,002h,004h,006h,008h,00ah,00ch,00eh
		defb	010h,0ffh
_3cdb:		defb	001h,00dh,008h,003h,00fh,00ah,005h,011h
		defb	00ch,007h,002h,00eh,009h,004h,010h,00bh
		defb	006h,0ffh
_3ced:		defb	001h,00fh,00ch,009h,006h,003h,011h,00eh
		defb	00bh,008h,005h,002h,010h,00dh,00ah,007h
		defb	004h,0ffh
_3cff:		defb	001h,00bh,004h,00eh,007h,011h,00ah,003h
		defb	00dh,006h,010h,009h,002h,00ch,005h,00fh
		defb	008h,0ffh
_3d11:		defb	001h,005h,009h,00dh,011h,004h,008h,00ch
		defb	010h,003h,007h,00bh,00fh,002h,006h,00ah
		defb	00eh,0ffh
_3d23:		defb	001h,00ch,006h,011h,00bh,005h,010h,00ah
		defb	004h,00fh,009h,003h,00eh,008h,002h,00dh
		defb	007h,0ffh
_3d35:		defb	001h,009h,011h,008h,010h,007h,00fh,006h
		defb	00eh,005h,00dh,004h,00ch,003h,00bh,002h
		defb	00ah,0ffh
_3d47:		defb	001h,011h,010h,00fh,00eh,00dh,00ch,00bh
		defb	00ah,009h,008h,007h,006h,005h,004h,003h
		defb	002h,0ffh

_3d59:		push	bc
		push	de
		ld	e,010h
_3d5d:		ld	bc,00000h
_3d60:		in	a,(0cfh)
		ld	d,a
		in	a,(0cfh)
		cp	d
		jr	nz,_3d60
		and	0d0h
		cp	050h
		jr	z,_3d9d
		call	_2278
		dec	bc
		ld	a,c
		or	b
		jr	nz,_3d60
		dec	e
		jr	nz,_3d5d
		jp	_3ee1

_3d7c:		push	bc
		push	de
		ld	e,010h
_3d80:		ld	bc,00000h
_3d83:		in	a,(0cfh)
		ld	d,a
		in	a,(0cfh)
		cp	d
		jr	nz,_3d83
		bit	3,a
		jr	nz,_3d9d
		call	_2278
		dec	bc
		ld	a,c
		or	b
		jr	nz,_3d83
		dec	e
		jr	nz,_3d80
		jp	_3ee1

_3d9d:		ld	a,(001e0h)
		ld	b,a
		inc	b
		in	a,(0c0h)
_3da4:		rlca	
		djnz	_3da4
		pop	de
		pop	bc
		ret	nc
		call	printimm
		ascii	13,10,'*** Drive cannot be write-protected ***',13,10,0
		call	printimm
		ascii	'Un-protect it and start over if you want to proceed.',13,10,0
		jp	_2368

_3e16:		push	bc
		push	hl
		call	_3ea7
		call	_40ea
		ld	a,030h
		ld	(0014fh),a
		out	(0cfh),a
		call	_3d7c
		ld	bc,000c8h
		otir	
		otir	
_3e2f:		in	a,(0cfh)
		ld	b,a
		in	a,(0cfh)
		cp	b
		jr	nz,_3e2f
		bit	7,a
		jr	nz,_3e2f
		in	a,(0cfh)
		and	001h
		bit	1,a
		jr	z,_3e48
		call	_40c8
		jr	_3e5b

_3e48:		ld	a,020h
		ld	(0014fh),a
		out	(0cfh),a
		call	_3d59
		in	a,(0cfh)
		push	af
		and	001h
		call	_40c8
		pop	af
_3e5b:		and	001h
		pop	hl
		pop	bc
		ret	

_3e60:		push	bc
		push	hl
		call	_3ea7
		call	_40ea
		ld	a,030h
		ld	(0014fh),a
		out	(0cfh),a
		call	_3d7c
		ld	bc,000c8h
		otir	
		otir	
_3e79:		in	a,(0cfh)
		ld	b,a
		in	a,(0cfh)
		cp	b
		jr	nz,_3e79
		bit	7,a
		jr	nz,_3e79
		in	a,(0cfh)
		and	001h
		pop	hl
		pop	bc
		ret	

		push	af
		ld	a,00eh
		out	(0c1h),a
		ld	a,00ah
_3e93:		dec	a
		jr	nz,_3e93
		pop	af
		ld	(001e0h),a
		rlca	
		rlca	
		rlca	
		and	0f8h
		or	020h
		ld	a,a
		ld	(0014eh),a
		out	(0ceh),a
_3ea7:		in	a,(0cfh)
		and	042h
		cp	040h
		ret	z
		call	printimm
		ascii	13,10,'Hard disk drive ',0
		ld	a,(001e0h)
		call	putdec
		call	printimm
		ascii	' is not ready.',13,10,0
		jp	_2368

_3ee1:		call	printimm
		ascii	13,10,'Hard disk operation aborted;',13,10,0
		call	printimm
		ascii	'Drive is not functioning properly.',13,10,0
		jp	_2368

_3f30:		defb	02eh,070h,076h,068h,000h,010h,001h,032h
		defb	000h,006h,000h,011h,002h,000h,000h,099h

_3f40:		defb	02eh,062h,061h,064h,000h,060h
		dc	386,0

_40c8:		in	a,(0cfh)
		and	002h
		ret	z
		ld	a,010h
		out	(0c1h),a
		call	_40e5
		ld	a,00eh
		out	(0c1h),a
		ld	a,00fh
_40da:		dec	a
		jr	nz,_40da
		ld	a,(0014eh)
		or	020h
		out	(0ceh),a
		ret	

_40e5:		ld	b,028h
_40e7:		djnz	_40e7
		ret	

_40ea:		push	hl
		ld	h,(iy+18h)
		ld	l,(iy+19h)
		srl	h
		rr	l
		srl	h
		rr	l
		ld	a,l
		out	(0c9h),a
		ld	(00149h),a
		pop	hl
		ret	

_4101:		ld	h,(iy+10h)
		ld	l,(iy+11h)
		srl	h
		rr	l
		ld	(iy+18h),h
		ld	(iy+19h),l
		ret	

_4112:		ld	b,(iy+12h)
		ld	c,(iy+13h)
		ld	h,(iy+10h)
		ld	l,(iy+11h)
		call	multiply
		ld	de,00bb8h
		or	a
		sbc	hl,de
		jr	c,_412d
		ld	a,060h
		jr	_412f

_412d:		ld	a,018h
_412f:		ld	(iy+57h),a
		ret	

_4133:		call	printimm
		ascii	'This will take about ',0
		ld	b,(iy+12h)
		ld	c,(iy+13h)
		ld	h,(iy+10h)
		ld	l,(iy+11h)
		call	multiply
		ld	bc,4
		call	multiply
		ld	(_4220),hl
		ld	a,(_3bf0)
		ld	de,00006h
		or	a
		jr	nz,_4181
		ld	a,(_3af2)
		cp	066h
		ld	de,00009h
		jr	z,_4181
		cp	070h
		ld	de,00013h
		jr	z,_4181
		ld	de,0006dh
_4181:		ld	hl,(_4220)
		call	divmod
		ld	(_421e),bc
		ld	hl,_420c
		ld	(_4222),hl
		ld	hl,0003bh
		or	a
		sbc	hl,bc
		ld	hl,(_421e)
		jr	nc,_41bb
		ld	hl,(_421e)
		ld	de,60
		call	divmod
		ld	(_421e),bc
		ld	hl,_4215
		ld	(_4222),hl
		ld	hl,0003bh
		ld	de,(_421e)
		or	a
		sbc	hl,de
		jr	c,_41ce
_41bb:		ld	hl,(_421e)
		call	putdecHL
		ld	hl,(_4222)
		call	print
		call	printimm
		ascii	13,10,0
		ret	

_41ce:		ld	hl,(_421e)
		ld	de,60
		call	divmod
		push	hl
		ld	h,b
		ld	l,c
		call	putdecHL
		call	printimm
		ascii	' hour(s), ',0
		pop	hl
		ld	bc,60
		call	multiply
		ld	de,100
		call	divmod
		ld	h,b
		ld	l,c
		call	putdecHL
		call	printimm
		ascii	' minutes',13,10,0
		ret	

_420c:		ascii	' seconds',0
_4215:		ascii	' minutes',0
_421e:		nop	
		nop	
_4220:		nop	
		nop	
_4222:		nop	
		nop	
		nop	
_4225:		ld	hl,_3c5d
		ld	(interleave),hl
		call	printimm
		ascii	'Desired interleave factor (<ENTER> for default)? ',0
		call	getstr
		ld	a,(hl)
		or	a
		ret	z
		call	atoi
		jr	nz,_4225
		ex	de,hl
		dec	hl
		ld	a,l
		cp	010h
		jr	nc,_4225
		add	hl,hl
		ld	de,interleave_table
		add	hl,de
		ld	e,(hl)
		inc	hl
		ld	d,(hl)
		ld	(interleave),de
		ret	

_427f:		byte	0	

_4280:		push	bc
		push	de
		push	hl
		xor	a
		ld	(_4334),a
		ld	hl,06969h
		ld	b,011h
		ld	de,_3c6f
_428f:		ld	a,(de)
		inc	de
		push	de
		ld	(0014bh),a
		out	(0cbh),a
		call	_4336
		pop	de
		jr	z,_42ca
		ld	a,(_4335)
		or	a
		jp	z,_432e
		ld	a,(_4334)
		or	a
		jr	nz,_42bf
		ld	a,001h
		ld	(_4334),a
		call	printimm
		ascii	'  Sector(s) ',0
_42bf:		ld	a,(0014bh)
		call	putdec
		call	printimm
		ascii	' ',0
_42ca:		push	bc
		ld	bc,000c8h
		inir	
		inir	
		pop	bc
		djnz	_428f
		ld	a,(_4334)
		or	a
		jr	z,_432b
		call	printimm
		ascii	'were not readable.',13,10,'All other sectors on this track were recovered.',13,10,0
		ld	a,(_3a6f)
		dec	a
		ld	(_3a6f),a
_432b:		xor	a
		jr	_4330

_432e:		or	001h
_4330:		pop	hl
		pop	de
		pop	bc
		ret	

_4334:		defb	000h
_4335:		defb	001h
_4336:		push	bc
		push	hl
		ld	b,005h
_433a:		push	bc
		call	_40c8
		in	a,(0cfh)
		bit	6,a
		jr	z,_435c
		ld	a,020h
		ld	(0014fh),a
		out	(0cfh),a
		call	_3d59
		pop	bc
		in	a,(0cfh)
		and	001h
		jr	z,_4359
		djnz	_433a
		or	0ffh
_4359:		pop	hl
		pop	bc
		ret	

_435c:		call	printimm
		ascii	13,10,'****** Hard Error - DRIVE NOT READY - Cannot Continue. *******',13,10,0
		call	_4c69
		jp	_2368

_43a8:		push	bc
		push	de
		push	hl
		ld	hl,06969h
		ld	b,011h
		ld	de,_3c6f
_43b3:		ld	a,(de)
		inc	de
		push	de
		ld	(0014bh),a
		out	(0cbh),a
		call	_3e16
		pop	de
		jr	nz,_43ca
		push	de
		ld	de,00200h
		add	hl,de
		pop	de
		djnz	_43b3
		xor	a
_43ca:		pop	hl
		pop	de
		pop	bc
		ret	

_43ce:		push	hl
		push	iy
		push	af
		in	a,(0cfh)
		bit	1,a
		jr	z,_43dc
		ld	a,010h
		out	(0c1h),a
_43dc:		ld	a,00eh
		ld	a,a
		ld	(00141h),a
		out	(0c1h),a
		ld	a,00ah
_43e6:		dec	a
		jr	nz,_43e6
		pop	af
		ld	(001e0h),a
		rlca	
		rlca	
		rlca	
		and	0f8h
		or	020h
		ld	a,a
		ld	(0014eh),a
		out	(0ceh),a
		call	_3ea7
_43fd:		ld	a,(001e0h)
		ld	b,a
		inc	b
		in	a,(0c0h)
_4404:		rlca	
		djnz	_4404
		jr	nc,_4468
		call	printimm
		ascii	13,10,'*** Drive is write-protected ***',13,10,0
		call	printimm
		ascii	'Un-protect it if you want to proceed.',13,10,0
		call	_2233
		call	printimm
		ascii	13,10,0
		jp	_43fd

_4468:		in	a,(0cch)
		inc	a
		ld	a,a
		ld	(0014ch),a
		out	(0cch),a
		ld	a,070h
		ld	a,a
		ld	(0014fh),a
		out	(0cfh),a
		call	_3d59
		xor	a
		ld	a,a
		ld	(0014ch),a
		out	(0cch),a
		ld	a,a
		ld	(0014dh),a
		out	(0cdh),a
		inc	a
		ld	a,a
		ld	(0014bh),a
		out	(0cbh),a
		call	_4336
		jr	nz,_44d4
		ld	hl,001f1h
		ld	bc,000c8h
		inir	
		call	_40c8
		ld	hl,(001f1h)
		ld	de,0702eh
		or	a
		sbc	hl,de
		jr	nz,_44d4
		ld	a,003h
		ld	a,a
		ld	(0014bh),a
		out	(0cbh),a
		call	_4336
		jr	nz,_44d4
		ld	hl,00239h
		ld	bc,000c8h
		inir	
		inir	
		call	_40c8
		ld	hl,(00239h)
		ld	de,0622eh
		or	a
		sbc	hl,de
		jr	nz,_44d4
		call	_44d8
		xor	a
_44d4:		pop	iy
		pop	hl
		ret	

_44d8:		ld	h,(iy+56h)
		ld	l,(iy+57h)
		ld	d,(iy+12h)
		ld	e,(iy+13h)
		call	divmod
		ld	a,h
		or	l
		sub	001h
		ccf	
		ld	h,(iy+10h)
		ld	l,(iy+11h)
		sbc	hl,bc
		ld	(iy+02h),l
		ld	(iy+03h),h
		ld	l,(iy+15h)
		ld	(iy+06h),l
		ld	(iy+07h),000h
		ld	l,(iy+12h)
		ld	(iy+08h),l
		ret	

_450b:		call	printimm
		ascii	13,10,'Type in the list of Track and Head numbers you wish to add.',13,10,0
		call	printimm
		ascii	'For instance, if you wanted to add track 133, head 0 and',13,10,0
		call	printimm
		ascii	'track 174, head 3, you should type',13,10,0
		call	printimm
		ascii	9,'133,0 <enter>',13,10,0
		call	printimm
		ascii	9,'174,3 <enter>',13,10,0
		call	printimm
		ascii	9,'done <enter>',13,10,0
		jp	_4750

_45f2:		call	printimm
		ascii	'Find the MEDIA ERROR MAP and type in the list',13,10,0
		call	printimm
		ascii	'of TRACK and HEAD numbers as follows.',13,10,0
		ld	a,(_4895)
		or	a
		jp	nz,_4750
		dec	a
		ld	(_4895),a
		call	printimm
		ascii	'  For instance, if the list shows',13,10,0
		call	printimm
		ascii	9,'TRACK',9,'HEAD',9,'BYTE COUNT',9,'LENGTH',13,10,0
		call	printimm
		ascii	9,'133',9,'00',9,'01333',9,9,'02',13,10,0
		call	printimm
		ascii	9,'174',9,'03',9,'09826',9,9,'05',13,10,0
		call	printimm
		ascii	'you should type',13,10,0
		call	printimm
		ascii	9,'133,0 <enter>',13,10,0
		call	printimm
		ascii	9,'174,3 <enter>',13,10,0
		call	printimm
		ascii	9,'done <enter>',13,10,0
		call	printimm
		ascii	'If the list is empty, just type "done".',13,10,0
_4750:		call	printimm
		ascii	'At any time, you may type <break> to abort.',13,10,10,0
_4782:		call	printimm
		ascii	'enter next pair or "done": ',0
		call	getstr
		ld	de,(00185h)
		ld	hl,06f64h
		or	a
		sbc	hl,de
		ret	z
		ld	hl,00185h
		call	atoi
		jr	nz,_47fb
		ld	b,d
		ld	c,e
		call	atoi
		jr	nz,_47fb
		ld	a,b
		or	d
		or	e
		or	c
		jp	z,_4849
		push	de
		ex	de,hl
		ld	d,(iy+12h)
		ld	e,(iy+13h)
		or	a
		sbc	hl,de
		pop	de
		jp	nc,_480f
		push	de
		ld	h,b
		ld	l,c
		ld	d,(iy+10h)
		ld	e,(iy+11h)
		or	a
		sbc	hl,de
		pop	de
		jp	nc,_47fb
		ld	a,c
		ld	(0014ch),a
		ld	a,b
		ld	(0014dh),a
		ld	a,(0014eh)
		and	0f8h
		or	e
		ld	(0014eh),a
		call	_48ca
		jp	_4782

_47fb:		call	printimm
		ascii	10,'That cylinder',0
		jr	_481d

_480f:		call	printimm
		ascii	10,'That head',0
_481d:		call	printimm
		ascii	' number can',39,'t be right - try again.',13,10,0
		jp	_4782

_4849:		call	printimm
		ascii	10,' Cyl, Track - 0,0 can not be bad for disk to function - try again.',13,10,0
		jp	_4782

_4895:		nop	
_4896:		ld	a,(iy+59h)
		or	a
		ret	z
		push	iy
		ld	b,a
		ld	de,00004h
		ld	iy,00241h
_48a5:		ld	a,(0014dh)
		cp	(iy+00h)
		jr	nz,_48c1
		ld	a,(0014ch)
		cp	(iy+01h)
		jr	nz,_48c1
		ld	a,(0014eh)
		and	007h
		cp	(iy+03h)
		ld	a,0ffh
		jr	z,_48c6
_48c1:		add	iy,de
		djnz	_48a5
		xor	a
_48c6:		pop	iy
		or	a
		ret	

_48ca:		call	_4896
		ret	nz
		ld	a,(0014dh)
		ld	h,a
		ld	a,(0014ch)
		ld	l,a
		ld	b,(iy+03h)
		ld	c,(iy+02h)
		or	a
		sbc	hl,bc
		jp	c,_49da
		ld	b,000h
		ld	c,(iy+13h)
		call	multiply
		ld	a,(0014eh)
		and	007h
		ld	c,a
		ld	b,000h
		add	hl,bc
		ld	bc,4
		call	multiply
		ld	bc,00241h
		add	hl,bc
		push	hl
		ld	a,(hl)
		inc	hl
		or	(hl)
		inc	hl
		or	(hl)
		inc	hl
		or	(hl)
		jr	nz,_491a
_4907:		pop	hl
		ld	a,(0014dh)
		ld	(hl),a
		inc	hl
		ld	a,(0014ch)
		ld	(hl),a
		inc	hl
		inc	hl
		ld	a,(0014eh)
		and	007h
		ld	(hl),a
		ret	

_491a:		pop	hl
		push	hl
		ld	a,(0014dh)
		cp	(hl)
		jr	nz,_4936
		inc	hl
		ld	a,(0014ch)
		cp	(hl)
		jr	nz,_4936
		inc	hl
		inc	hl
		ld	b,(hl)
		ld	a,(0014eh)
		and	007h
		cp	b
		jr	nz,_4936
		pop	hl
		ret	

_4936:		pop	hl
		push	hl
		ld	a,(0014ch)
		ld	c,a
		ld	a,(0014dh)
		ld	b,a
		ld	a,(0014eh)
		push	bc
		push	af
		ld	a,(hl)
		ld	(0014dh),a
		inc	hl
		ld	a,(hl)
		ld	(0014ch),a
		ld	a,(0014eh)
		inc	hl
		inc	hl
		ld	c,(hl)
		and	0f8h
		or	c
		ld	(0014eh),a
		call	_49da
		pop	af
		ld	(0014eh),a
		pop	bc
		ld	a,c
		ld	(0014ch),a
		ld	a,b
		ld	(0014dh),a
		jp	_4907

_496d:		call	_3a70
		ld	a,(0014ch)
		ld	c,a
		ld	a,(0014dh)
		ld	b,a
		ld	a,(0014eh)
		push	bc
		push	af
		call	_4a53
		call	_43a8
		jr	z,_49c5
		call	printimm
		ascii	13,10,'Replacement track for data is bad. Can',39,'t continue.',13,10,0
		call	_4c69
		jp	restart

_49c5:		pop	af
		ld	a,a
		ld	(0014eh),a
		out	(0ceh),a
		pop	bc
		ld	a,c
		ld	(0014ch),a
		out	(0cch),a
		ld	a,b
		ld	(0014dh),a
		out	(0cdh),a
		ret	

_49da:		push	hl
		push	bc
		push	de
_49dd:		ld	a,(iy+59h)
		cp	(iy+57h)
		jp	z,_4a1a
		inc	(iy+59h)
		ld	l,a
		ld	h,000h
		sla	l
		rl	h
		sla	l
		rl	h
		ld	bc,00241h
		add	hl,bc
		push	hl
		ld	a,(hl)
		inc	hl
		or	(hl)
		inc	hl
		or	(hl)
		inc	hl
		or	(hl)
		pop	hl
		jr	nz,_49dd
		ld	a,(0014dh)
		ld	(hl),a
		inc	hl
		ld	a,(0014ch)
		ld	(hl),a
		inc	hl
		ld	(hl),000h
		inc	hl
		ld	a,(0014eh)
		and	007h
		ld	(hl),a
		pop	de
		pop	bc
		pop	hl
		ret	

_4a1a:		call	printimm
		ascii	13,10,'** Too many bad tracks, Formatting ABORTED. **',13,10,0
		jp	_2368

_4a53:		ld	hl,00241h
		ld	b,(iy+59h)
		ld	a,(0014eh)
		and	007h
		ld	c,a
		ld	a,(0014ch)
		ld	e,a
		ld	a,(0014dh)
		ld	d,a
_4a67:		ld	a,b
		or	a
		jr	z,_4a98
		ld	a,(hl)
		inc	hl
		sub	d
		ld	a,(hl)
		inc	hl
		inc	hl
		jr	nz,_4a7a
		sub	e
		jr	nz,_4a7a
		ld	a,c
		cp	(hl)
		jr	z,_4a7e
_4a7a:		inc	hl
		dec	b
		jr	_4a67

_4a7e:		ld	a,(iy+59h)
		sub	b
		ld	l,a
		ld	h,000h
		ld	d,(iy+12h)
		ld	e,(iy+13h)
		call	divmod
		ld	a,l
		ld	l,(iy+02h)
		ld	h,(iy+03h)
		add	hl,bc
		ex	de,hl
		ld	c,a
_4a98:		in	a,(0ceh)
		and	0f8h
		or	c
		ld	a,a
		ld	(0014eh),a
		out	(0ceh),a
		ld	a,e
		ld	(0014ch),a
		out	(0cch),a
		ld	a,d
		ld	(0014dh),a
		out	(0cdh),a
		ret	

putc:		push	af
		push	bc
		push	de
		push	hl
		ld	hl,conreset
		bit	0,(hl)
		ld	(hl),000h
		call	nz,console_reset
		and	07fh
		ld	hl,(console_vec)
		push	hl
		ld	hl,(cursor_xy)
		ret	

conreset:	defb	$ff

char_done:	pop	hl
		pop	de
		pop	bc
		pop	af
		ret	

conout_start:	cp	' '
		jp	nc,_4b0e
		cp	13		; carriage return
		jr	z,_4aef
		cp	10		; line feed
		jr	z,_4af4
		cp	8		; backspace
		jr	z,_4af8
		cp	9		; tab
		jr	z,_4b01
		cp	12		; formfeed
		jp	z,_4b7d
		cp	7		; bell
		jr	z,_4b09
		jp	char_done

_4aef:		ld	l,0
		jp	_4b18

_4af4:		inc	h
		jp	_4b18

_4af8:		ld	a,l
		or	a
		jp	z,_4b18
		dec	l
		jp	_4b18

_4b01:		ld	a,l
		or	007h
		inc	a
		ld	l,a
		jp	_4b18

_4b09:		call	_4c69
		jr	_4b18

_4b0e:		push	hl
		ld	b,a
		call	_4ba7
		ld	(hl),b
		pop	hl
		inc	l
		jr	_4b18

_4b18:		ld	de,conout_start
		ld	(console_vec),de
		ld	a,l
		cp	80
		jr	c,_4b27
		ld	l,0
		inc	h
_4b27:		ld	a,h
		cp	24
		jr	c,_4b43
		ld	h,24-1
		push	hl
		ld	hl,(vram_pos)
		ld	de,00050h
		add	hl,de
		call	_4bbe
		ld	hl,(24-1)*256+0
		ld	bc,80
		call	_4b60
		pop	hl
_4b43:		call	_4b49
		jp	char_done

_4b49:		push	hl
		ld	(cursor_xy),hl
		call	_4b93
		ld	a,00eh
		out	(0fch),a
		ld	a,h
		out	(0fdh),a
		ld	a,00fh
		out	(0fch),a
		ld	a,l
		out	(0fdh),a
		pop	hl
		ret	

_4b60:		push	de
		push	hl
		call	_4ba7
		ld	d,020h
_4b67:		ld	(hl),d
		inc	l
		jp	nz,_4b72
		inc	h
		jp	nz,_4b72
		ld	h,0f8h
_4b72:		dec	c
		jp	nz,_4b67
		dec	b
		jp	p,_4b67
		pop	hl
		pop	de
		ret	

_4b7d:		ld	hl,video_RAM
		ld	de,video_RAM+1
		ld	bc,24*80-1
		ld	(hl),' '
		ldir	
		ld	hl,0
		call	_4bbe
		jp	_4b18

_4b93:		push	bc
		ld	a,h
		ld	c,l
		ld	b,000h
		call	_4baf
		add	hl,bc
		ld	bc,(vram_pos)
		add	hl,bc
		ld	a,h
		and	03fh
		ld	h,a
		pop	bc
		ret	

_4ba7:		call	_4b93
		ld	a,h
		or	high(video_RAM)
		ld	h,a
		ret	

_4baf:		push	de
		add	a,a
		add	a,a
		add	a,a
		ld	l,a
		ld	h,000h
		add	hl,hl
		ld	d,h
		ld	e,l
		add	hl,hl
		add	hl,hl
		add	hl,de
		pop	de
		ret	

_4bbe:		ld	a,i
		push	af
		di	
		ld	(vram_pos),hl
		ld	a,00ch
		out	(0fch),a
		ld	a,h
		and	03fh
		out	(0fdh),a
		ld	a,00dh
		out	(0fch),a
		ld	a,l
		out	(0fdh),a
		pop	af
		ret	po
		ei	
		ret	

console_reset:	push	af
		ld	hl,0
		ld	(vram_pos),hl
		ld	(cursor_xy),hl
		ld	hl,conout_start
		ld	(console_vec),hl
		ld	a,0
		ld	(00120h),a
		out	(0a0h),a
		call	printimm
		ascii	12,0
		pop	af
		ret	

; Wait until a key is pressed and return scancode in A.
waitkey:	call	havekey
		jr	z,waitkey
		in	a,(0fch)
		and	07fh
		ret	

; Return NZ if keyboard input is available.
havekey:	in	a,(0ffh)
		and	080h
		ret	

printimm:	ex	(sp),hl
		push	af
		call	print
		pop	af
		ex	(sp),hl
		ret	

; Display message pointed to by HL
print:		ld	a,(hl)
		inc	hl
		or	a
		ret	z
		call	putc
		jr	print

; Display A register as '=HEX '
preqhex:	push	af
		ld	a,'='
		call	putc
		pop	af
		push	af
		call	puthex
		ld	a,' '
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

		push	af
		ld	a,'='
		call	putc
		ld	a,' '
		call	putc
		call	puthex16
		pop	af
		ret	

; Display HL register in hexadecimal.
puthex16:	push	hl
		ld	a,h
		call	puthex
		pop	hl
		ld	a,l
		jr	puthex

; Convert A register to hexadecimal and store at HL.
; (Apparently unused)
hexstr:		push	af
		rlca	
		rlca	
		rlca	
		rlca	
		call	hs1
		pop	af
hs1:		call	hexdig
		ld	(hl),a
		inc	hl
		ret	

; Convert low nybble of A into ASCI hexadecimal '0' .. '9' 'A' .. 'F'
hexdig:		and	00fh
		add	a,090h
		daa	
		adc	a,040h
		daa	
		ret	

_4c69:		push	af
		push	hl
		ld	a,001h
		ld	(00120h),a
		out	(0a0h),a
		ld	hl,07000h
_4c75:		dec	hl
		ld	a,h
		or	l
		jr	nz,_4c75
		ld	a,000h
		ld	(00120h),a
		out	(0a0h),a
		pop	hl
		pop	af
		ret	

		push	bc
		ld	b,000h
_4c87:		ld	a,(hl)
		inc	hl
		or	a
		jr	z,_4c9a
		ld	c,a
		ld	a,(hl)
		inc	hl
		push	hl
		ld	hl,00080h
		add	hl,bc
		ld	(hl),a
		out	(c),a
		pop	hl
		jr	_4c87

_4c9a:		pop	bc
		ret	

; Return BC = HL / DE and HL = HL % DE
divmod:		ld	bc,0
		or	a
_4ca0:		sbc	hl,de
		jp	c,_4ca8
		inc	bc
		jr	_4ca0

_4ca8:		add	hl,de
		ret	

; Return HL = HL * BC
multiply:	push	bc
		push	de
		ex	de,hl
		ld	hl,0
_4cb0:		ld	a,b
		or	c
		jr	z,_4cb8
		add	hl,de
		dec	bc
		jr	_4cb0

_4cb8:		pop	de
		pop	bc
		ret	

_4cbb:		push	bc
		push	hl
		ld	hl,_4cc8
		ld	bc,004f8h
		otir	
		pop	hl
		pop	bc
		ret	

_4cc8:		defb	083h,08bh,0afh,0c3h
_4ccc:		ld	(_4cd8+1),hl
		ld	hl,_4cd8
		ld	bc,00ef8h
		otir	
		ret	

_4cd8:		defb	079h,000h,000h,0e0h,02eh,014h,028h,0c5h,0e7h,08ah,0cfh,005h,0cfh,087h
_4ce6:		ld	(_4cf2+7),hl
		ld	hl,_4cf2
		ld	bc,00cf8h
		otir	
		ret	

_4cf2:		defb	06dh,0e7h,000h,004h,02ch,010h,0cdh,000h,000h,08ah,0cfh,087h
_4cfe:		in	a,(042h)
		or	a
		jr	nz,_4d58
		call	printimm
		ascii	'You don',39,'t have the disk cartridge system installed.',13,10,0
		jp	_54fe

just_reti:	reti	

false_intr:	call	printimm
		ascii	13,10,'False Interrupt',13,10,0
; I think there should be a 'ret' here.
_4d58:		ld	hl,false_intr
		ld	(intr0_handler),hl
		ld	a,0ffh
		out	(042h),a
; Most IM 2 interrupt vectors set to "do nothing" here.
		ld	hl,just_reti
		ld	(0f700h),hl
		ld	hl,0f700h
		ld	a,h
		ld	de,0f702h
		ld	bc,00080h
		ldir	
		ld	i,a
		ld	hl,intr_vec_0
		ld	(0f700h),hl
		im	2
		ei	
_4d7f:		call	printimm
		ascii	'Copy or format (c or f)? ',0
		call	getstr
		ld	a,(00186h)
		or	a
		jr	nz,_4d7f
		xor	a
		ld	(00183h),a
		ld	a,(00185h)
		cp	'f'
		jp	z,_51ee
		cp	'c'
		jr	nz,_4d7f
		ld	hl,_5140
		ld	(_5546+1),hl
_4dbb:		call	printimm
		ascii	'Source drive number (0 or 1)? ',0
		call	getstr
		ld	a,(00185h)
		sub	'0'
		cp	2
		jr	nc,_4dbb
		ld	(00181h),a
		ld	b,a
_4ded:		call	printimm
		ascii	'Destination drive number (0 or 1)? ',0
		call	getstr
		ld	a,(00185h)
		sub	'0'
		cp	2
		jr	nc,_4ded
		ld	(00180h),a
		cp	b
		jr	nz,_4e63
		call	printimm
		ascii	13,10,'Copying a disk to itself is of questionable value.',13,10,0
		call	_2233
_4e63:		ld	hl,_5187
		call	_227b
		call	printimm
		ascii	13,10,'Insert source cartridge in drive ',0
		ld	a,(00181h)
		call	putdec
		call	printimm
		ascii	13,10,'Insert destination cartridge in drive ',0
		ld	a,(00180h)
		call	putdec
		call	printimm
		ascii	13,10,0
		call	_2233
		call	_6023
		ld	a,(00181h)
		call	_577f
		call	nz,_5541
		call	_559f
		jr	z,_4f24
		call	printimm
		ascii	'Source cartridge has not been formatted or is not usable.',13,10,0
		jp	_5140

_4f24:		call	_55d4
		ld	hl,(_57b0)
		ld	(_5049+1),hl
		ld	hl,(_57ae)
		push	hl
		pop	iy
		ld	de,_57b6
		ld	bc,00004h
		ldir	
		ld	a,(iy+04h)
		ld	(_57ba),a
		ld	ix,_57c0
		ld	(ix+00h),000h
		ld	(ix+01h),000h
		ld	(ix+02h),000h
		ld	(ix+03h),003h
		ld	a,(00180h)
		call	_577f
		call	nz,_5541
		call	_559f
		jr	z,_4faa
		call	printimm
		ascii	'Destination cartridge has not been formatted or is not usable.',13,10,0
		jp	_5140

_4faa:		call	_55d4
		ld	hl,(_57ae)
		push	hl
		pop	iy
		ld	de,_57bb
		ld	bc,00004h
		ldir	
		ld	a,(iy+04h)
		ld	(_57bf),a
		ld	ix,_57b6
		ld	iy,_57bb
		ld	a,(iy+03h)
		sub	(ix+03h)
		ld	a,(iy+02h)
		sbc	a,(ix+02h)
		ld	a,(iy+01h)
		sbc	a,(ix+01h)
		ld	a,(iy+00h)
		sbc	a,(ix+00h)
		jr	nc,_503d
		call	printimm
		ascii	'You can',39,'t put ',0
		ld	a,(_57ba)
		call	putdec
		call	printimm
		ascii	' meg of data onto a ',0
		ld	a,(_57bf)
		call	putdec
		call	printimm
		ascii	' meg cartridge.',13,10,0
		ld	a,(00181h)
		call	_578f
		ld	a,(00180h)
		call	_578f
		jp	_4e63

_503d:		ld	hl,_57b6
		ld	de,_57bb
		push	de
		ld	bc,00004h
		ldir	
_5049:		ld	hl,00000h
		pop	ix
		ld	a,(ix+03h)
		sub	l
		ld	(ix+03h),a
		ld	a,(ix+02h)
		sbc	a,h
		ld	(ix+02h),a
		ld	a,(ix+01h)
		sbc	a,000h
		ld	(ix+01h),a
		ld	a,(ix+00h)
		sbc	a,000h
		ld	(ix+00h),a
_506c:		call	_227e
		ld	ix,_57b6
		ld	iy,_57c0
		ld	a,(iy+03h)
		sub	(ix+03h)
		ld	a,(iy+02h)
		sbc	a,(ix+02h)
		ld	a,(iy+01h)
		sbc	a,(ix+01h)
		ld	a,(iy+00h)
		sbc	a,(ix+00h)
		jp	nc,_512a
		ld	hl,_57c0
		ld	de,_6170+2
		ld	bc,00004h
		push	bc
		push	hl
		ldir	
		pop	hl
		pop	bc
		ld	de,_6165+2
		ldir	
		call	_51bf
		ld	l,a
		ld	h,000h
		ld	(_5f29),hl
		ld	(_510a+1),a
		ld	a,(00181h)
		ld	(_6129),a
		call	printimm
		ascii	13,'Reading ',0
		ld	iy,_6170+2
		call	_51a0
		call	printimm
		ascii	'    ',0
		ld	a,001h
		ld	(_5f2f),a
		call	_5abd
		jp	nz,_5546
		ld	a,(00180h)
		ld	(_6129),a
		call	printimm
		ascii	'Writing ',0
		ld	iy,_6165+2
		call	_51a0
		ld	a,002h
		ld	(_5f2f),a
		call	_5abd
		jp	nz,_5546
		ld	iy,_57c0
		ld	a,(iy+03h)
_510a:		add	a,000h
		ld	(iy+03h),a
		ld	a,(iy+02h)
		adc	a,000h
		ld	(iy+02h),a
		ld	a,(iy+01h)
		adc	a,000h
		ld	(iy+01h),a
		ld	a,(iy+00h)
		adc	a,000h
		ld	(iy+00h),a
		jp	_506c

_512a:		call	printimm
		ascii	13,10,'Copy finished.',13,10,0
_5140:		call	_5146
		jp	_54fe

_5146:		call	printimm
		ascii	'Unlocking ',0
		ld	a,(00180h)
		add	a,'0'
		call	putc
		ld	a,(00180h)
		call	_578f
		call	printimm
		ascii	'   Unlocking ',0
		ld	a,(00181h)
		add	a,'0'
		call	putc
		call	printimm
		ascii	13,10,0
		ld	a,(00181h)
		jp	_578f

_5187:		call	printimm
		ascii	13,10,'Aborting',13,10,0
		call	_6023
		call	_5146
		jp	_228b

_51a0:		push	hl
		push	iy
		ld	a,(iy+00h)
		call	puthex
		ld	a,(iy+01h)
		call	puthex
		ld	a,(iy+02h)
		call	puthex
		ld	a,(iy+03h)
		call	puthex
		pop	iy
		pop	hl
		ret	

_51bf:		ld	ix,_57bb
		ld	iy,_57c0
		ld	a,(iy+03h)
		sub	(ix+03h)
		ld	a,(iy+02h)
		sbc	a,(ix+02h)
		ld	a,(iy+01h)
		sbc	a,(ix+01h)
		ld	a,(iy+00h)
		sbc	a,(ix+00h)
		ld	a,080h
		ret	c
		ld	ix,_57b6
		ld	a,(ix+03h)
		sub	(iy+03h)
		inc	a
		ret	

_51ee:		ld	hl,_53a6
		ld	(_5546+1),hl
		ld	hl,_54df
		call	_227b
_51fa:		call	printimm
		ascii	'Drive number (0 or 1)? ',0
		call	getstr
		ld	a,(hl)
		sub	'0'
		cp	2
		jr	nc,_51fa
		call	_54c1
		call	_55d4
		push	af
		ld	b,a
_5227:		call	printimm
		ascii	'Desired interleave factor (<ENTER> for default)? ',0
		call	getstr
		ld	a,(hl)
		or	a
		jr	z,_528b
		call	atoi
		jr	nz,_5227
		ld	a,e
		cp	021h
		jr	nc,_5227
		ld	a,b
		cp	014h
		ld	a,e
		jr	nz,_5277
		bit	0,a
		jr	nz,_529a
_5277:		push	bc
		ld	b,008h
		ld	c,000h
		or	a
_527d:		rla	
		jr	nc,_5281
		inc	c
_5281:		djnz	_527d
		ld	a,c
		cp	001h
		pop	bc
		jr	nz,_5227
		jr	_529a

_528b:		ld	a,b
		cp	00ah
		ld	e,008h
		jr	z,_529a
		cp	014h
		ld	e,005h
		jr	z,_529a
		ld	e,008h
_529a:		ld	hl,_612e+4
		ld	a,(hl)
		and	0c0h
		or	e
		ld	(hl),a
		ld	hl,_6135+4
		ld	a,(hl)
		and	0c0h
		or	e
		ld	(hl),a
		ld	hl,_613b+1
		ld	a,(hl)
		and	0c0h
		or	e
		ld	(hl),a
		call	printimm
		ascii	13,10,'About to format ',0
		pop	af
		call	putdec
		call	printimm
		ascii	' megabyte cartridge in drive ',0
		ld	a,(_6129)
		call	putdec
_52f3:		call	_2233
		call	printimm
		ascii	'Formatting',13,10,0
		ld	hl,_613b
		ld	de,endbuf
		ld	bc,00006h
		ldir	
		ld	a,080h
		ld	(endbuf),a
		ld	hl,_6134
		call	_5f5d
		call	nz,_5541
		ld	hl,_613b
		ld	de,endbuf
		ld	bc,00006h
		ldir	
		ld	a,008h
		ld	(endbuf),a
		ld	hl,_6134
		call	_5f5d
		call	nz,_5541
		ld	hl,_612d
		call	_5f5d
		call	nz,_5541
_5341:		call	_60ff
		jr	nz,_5355
		call	_227e
		ld	a,005h
		call	_579f
		ld	a,'.'
		call	putc
		jr	_5341

_5355:		call	printimm
		ascii	13,10,0
		ld	b,001h
		ld	hl,01388h
		call	_57a4
		ld	a,00dh
		ld	(_615e+4),a
		ld	hl,_615d
		call	_5f5d
		jr	nz,_5377
		call	_576e
		ld	a,b
		or	c
		jr	z,_53b2
_5377:		call	_56d8
		call	printimm
		ascii	'Format error. Cartridge is not usable.',13,10,0
_53a6:		call	_5504
		ld	a,(_6129)
		call	_578f
		jp	_54fe

_53b2:		ld	ix,_6165+2
		ld	(ix+00h),000h
		ld	(ix+01h),000h
		ld	(ix+02h),000h
		ld	(ix+03h),000h
		ld	(ix+05h),000h
		ld	(ix+06h),001h
		ld	hl,_5533
		ld	de,endbuf
		ld	bc,00006h
		ldir	
		ld	hl,(_57ac)
		ld	bc,00008h
		ldir	
		ld	h,d
		ld	l,e
		ld	(hl),000h
		inc	de
		ld	bc,00200h
		ldir	
		ld	hl,_6164
		call	_5f5d
		call	nz,_5541
		ld	a,002h
		ld	(_6165+5),a
		ld	hl,_5539
		ld	de,endbuf
		ld	bc,00008h
		ldir	
		ld	h,d
		ld	l,e
		ld	(hl),000h
		inc	de
		ld	bc,00200h
		ldir	
		ld	hl,_6164
		call	_5f5d
		call	nz,_5541
		ld	a,(_6129)
		call	_578f
		call	printimm
		ascii	'Cartridge successfully formatted.',13,10,0
		call	_4c69
		call	printimm
		ascii	'Format another (y or n)? ',0
		call	getstr
		ld	a,(hl)
		cp	'n'
		jp	z,restart
		cp	'N'
		jp	z,restart
		call	printimm
		ascii	13,10,'Insert the next cartridge to be formatted and press <ENTER>: ',0
		call	getstr
		call	_54be
		jp	_52f3

_54be:		ld	a,(_6129)
_54c1:		call	_577f
		ret	z
		ld	hl,_613b
		ld	de,endbuf
		ld	bc,00006h
		ldir	
		ld	a,008h
		ld	(endbuf),a
		ld	hl,_6134
		call	_5f5d
		ret	

		jp	_54fe

_54df:		call	printimm
		ascii	13,10,'Aborting',13,10,0
		call	_6023
		call	_5504
		ld	a,(_6129)
		call	_578f
		jp	_228b

_54fe:		call	_4c69
		jp	restart

_5504:		ld	hl,endbuf
		ld	de,_end
		ld	bc,00320h
		ld	(hl),000h
		ldir	
		ld	ix,_6165+2
		ld	(ix+00h),000h
		ld	(ix+01h),000h
		ld	(ix+02h),000h
		ld	(ix+03h),000h
		ld	(ix+05h),000h
		ld	(ix+06h),003h
		ld	hl,_6164
		jp	_5f5d

_5533:		defb	02eh,070h,076h,068h,000h,010h
_5539:		defb	02eh,062h,061h,064h,000h,060h,000h,000h
_5541:		call	_56d8
		ret	z
		pop	hl
_5546:		jp	m,_54fe
		cp	001h
		jr	z,_5553
_554d:		call	_2233
		jp	_4cfe

_5553:		ld	a,(_6129)
		call	_578f
		call	printimm
		ascii	'You need to unprotect the cartridge if you want to copy to it.',13,10,0
		jr	_554d

_559f:		ld	hl,_6141
		call	_5f5d
		ld	ix,_6170+2
		ld	(ix+00h),000h
		ld	(ix+01h),000h
		ld	(ix+02h),000h
		ld	(ix+03h),000h
		ld	(ix+05h),000h
		ld	(ix+06h),001h
		ld	hl,_616f
		call	_5f5d
		call	nz,_5541
		ld	hl,(endbuf)
		ld	de,0702eh
		or	a
		sbc	hl,de
		ret	

_55d4:		ld	hl,_6141
		call	_5f5d
		ld	a,00dh
		ld	(_615e+4),a
		ld	a,009h
		ld	(061a1h),a
		ld	hl,_615d
		call	_5f5d
		call	nz,_5541
		ld	hl,_6188
		call	_5f5d
		call	nz,_5541
		ld	ix,endbuf
		ld	iy,_56b5
		ld	de,00011h
_5601:		ld	a,(iy+00h)
		cp	0ffh
		jr	z,_562c
		ld	a,(ix+00h)
		cp	(iy+00h)
		jr	nz,_5628
		ld	a,(ix+01h)
		cp	(iy+01h)
		jr	nz,_5628
		ld	a,(ix+02h)
		cp	(iy+02h)
		jr	nz,_5628
		ld	a,(ix+03h)
		cp	(iy+03h)
		jr	z,_567b
_5628:		add	iy,de
		jr	_5601

_562c:		call	printimm
		ascii	'Unknown size of cartridge in drive ',0
		ld	a,(_6129)
		call	putdec
		call	printimm
		ascii	'. Using 10 meg defaults.',13,10,0
		ld	iy,_56b5
_567b:		ld	(_57ae),iy
		ld	a,(iy+09h)
		ld	(_57b1),a
		ld	a,(iy+0ah)
		ld	(_57b0),a
		ld	a,(iy+10h)
		ld	(_5539+5),a
		ld	a,(iy+0dh)
		sub	(iy+0eh)
		ld	(_57b2),a
		ld	a,(iy+0fh)
		ld	(_57b4),a
		ld	a,(iy+0eh)
		ld	(_57b3),a
		ld	de,00004h
		add	iy,de
		ld	a,(iy+00h)
		inc	iy
		ld	(_57ac),iy
		ret	

_56b5:		defb	000h,000h,098h,0ffh,00ah,001h,032h,000h
		defb	001h,000h,080h,001h,000h,046h,006h,004h
		defb	018h,000h,001h,046h,0ffh,014h,002h,08eh
		defb	000h,001h,000h,080h,001h,000h,046h,006h
		defb	004h,018h,0ffh

_56d8:		call	_576e
		ld	ix,cartmsg
		ld	de,00006h
_56e2:		ld	a,(ix+00h)
		cp	0ffh
		jr	z,_56f6
		cp	b
		jr	nz,_56f2
		ld	a,(ix+01h)
		cp	c
		jr	z,_56f6
_56f2:		add	ix,de
		jr	_56e2

_56f6:		ld	a,(ix+03h)
		or	a
		ld	a,(ix+02h)
		jr	z,_5739
		ld	l,(ix+04h)
		ld	h,(ix+05h)
		push	af
		push	hl
		call	_573b
		pop	hl
		call	print
		ld	a,(ix+03h)
		and	002h
		jr	z,_5732
		call	printimm
		ascii	' (',0
		ld	a,(0619dh)
		call	puthex
		ld	a,(0619eh)
		call	puthex
		ld	a,(0619fh)
		call	puthex
		ld	a,')'
		call	putc
_5732:		call	printimm
		ascii	13,10,0
		pop	af
_5739:		or	a
		ret	

_573b:		call	printimm
		ascii	'Error on drive ',0
		ld	a,(_6129)
		add	a,'0'
		call	putc
		call	printimm
		ascii	': (',0
		push	bc
		call	_576e
		push	bc
		pop	hl
		call	puthex16
		call	printimm
		ascii	') ',0
		pop	bc
		ret	

_576e:		ld	iy,endbuf
		ld	a,(iy+02h)
		and	00fh
		ld	b,a
		ld	a,(iy+08h)
		and	07fh
		ld	c,a
		ret	

_577f:		ld	(_6129),a
		ld	hl,_617a
		call	_5f5d
		ret	nz
		ld	hl,_614f
		jp	_5f5d

_578f:		ld	(_6129),a
		ld	hl,_6181
		call	_5f5d
		ret	nz
		ld	hl,_6156
		jp	_5f5d

_579f:		rlca	
		ld	b,a
_57a1:		ld	hl,00000h
_57a4:		dec	hl
		ld	a,h
		or	l
		jr	nz,_57a4
		djnz	_57a1
		ret	

_57ac:		nop	
		nop	
_57ae:		nop	
		nop	
_57b0:		nop	
_57b1:		nop	
_57b2:		nop	
_57b3:		nop	
_57b4:		nop	
		nop	
_57b6:		nop	
		nop	
		nop	
		nop	
_57ba:		nop	
_57bb:		nop	
		nop	
		nop	
		nop	
_57bf:		nop	
_57c0:		nop	
		nop	
		nop	
		nop	

cartmsg:	defb	000h,000h,000h,000h
		word	_5918
		defb	001h,018h,000h,001h
		word	_59ba
		defb	001h,01dh,000h,001h
		word	_59ca
		defb	002h,000h,0fch,001h
		word	_5884
		defb	002h,004h,0fch,001h
		word	_5968
		defb	002h,009h,0fch,001h
		word	_5884
		defb	003h,001h,0fch,001h
		word	_59f6
		defb	003h,003h,0fch,001h
		word	_5a15
		defb	003h,00ah,0fch,001h
		word	_5921
		defb	003h,011h,0fch,001h
		word	_5a21
		defb	003h,012h,0fch,001h
		word	_5a06
		defb	003h,013h,0fch,001h
		word	_5a2b
		defb	003h,014h,0fch,001h
		word	_59da
		defb	004h,001h,0fch,001h
		word	_5945
		defb	004h,004h,0fch,001h
		word	_597c
		defb	004h,015h,0fch,001h
		word	_59eb
		defb	004h,016h,0fch,001h
		word	_5988
		defb	004h,01bh,002h,001h
		word	_59a1
		defb	004h,023h,0fch,001h
		word	_5994
		defb	005h,000h,0fch,001h
		word	_5900
		defb	005h,00ah,002h,003h
		word	_5a83
		defb	005h,01ah,0fch,001h
		word	_5a72
		defb	005h,020h,002h,001h
		word	_5a4c
		defb	005h,021h,002h,003h
		word	_5a5c
		defb	006h,000h,000h,000h
		word	_58ee
		defb	007h,017h,001h,001h
		word	_589c
		defb	009h,01fh,0fch,001h
		word	_58b9
		defb	009h,006h,0fch,001h
		word	_5954
		defb	009h,01ch,0fch,001h
		word	_5a39
		defb	009h,01dh,0fch,001h
		word	_5aa9
		defb	009h,01eh,0fch,001h
		word	_5a95
		defb	0ffh,000h,0fch,001h
		word	_5937

_5884:		ascii	'Cartridge is not loaded',0
_589c:		ascii	'Cartridge is write protected',0
_58b9:		ascii	'Cannot write on a 10 meg cartridge in a 20 meg drive',0
_58ee:		ascii	'Cartridge changed',0
_5900:		ascii	'Invalid Command Request',0
_5918:		ascii	'No Error',0
_5921:		ascii	'Insufficient capacity',0
_5937:		ascii	'Unknown error',0
_5945:		ascii	'Hardware Fault',0
_5954:		ascii	'Cannot read Z track',0
_5968:		ascii	'No cable continuity',0
_597c:		ascii	'Spinup Fail',0
_5988:		ascii	'DMA Timeout',0
_5994:		ascii	'Parity Error',0
_59a1:		ascii	'Data transfer incomplete',0
_59ba:		ascii	'ECC was invoked',0
_59ca:		ascii	'Retries invoked',0
_59da:		ascii	'Sector not found',0
_59eb:		ascii	'Seek Error',0
_59f6:		ascii	'No index signal',0
_5a06:		ascii	'IDAM not found',0
_5a15:		ascii	'Write Fault',0
_5a21:		ascii	'CRC Error',0
_5a2b:		ascii	'DAM not found',0
_5a39:		ascii	'Prewrite CRC Error',0
_5a4c:		ascii	'Invalid command',0
_5a5c:		ascii	'Illegal block address',0
_5a72:		ascii	'Interleave Error',0
_5a83:		ascii	'Cartridge is full',0
_5a95:		ascii	'Flag sector failure',0
_5aa9:		ascii	'Unrecoverable error',0

_5abd:		ld	ix,_5f36
		ld	a,001h
		ld	(_5f2e),a
		ld	(ix+17h),000h
		ld	a,(_5f2f)
		cp	001h
		ld	hl,_5b14
		jr	z,_5ad7
		ld	hl,_5b94
_5ad7:		ld	de,_5adc
		push	de
		jp	(hl)

_5adc:		ld	a,(_5f31)
		or	a
		jr	z,_5aeb
		ld	hl,(_5f32)
		xor	a
		ld	(_5f31),a
		jr	_5ad7

_5aeb:		ld	a,(_5f2e)
		or	a
		jr	nz,_5adc
		ld	a,(ix+17h)
		or	a
		ret	z
		cp	008h
		jr	nz,_5afc
		xor	a
		ret	

_5afc:		or	a
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

_5b09:		ld	(_5f32),hl
		ld	a,(_5f2e)
		ld	(_5f31),a
		ei	
		ret	

_5b14:		xor	a
		ld	(_5f26),a
		ld	hl,_5b1e
		ld	(_5f27),hl
_5b1e:		ld	de,(_5f29)
		ld	(_5f2b),de
_5b26:		call	_5c64
		jr	z,_5b30
		jp	c,_5d0b
		jr	_5b26

_5b30:		call	_5c01
		ld	hl,_5b65
		ld	(intr0_handler),hl
		ld	a,(_5f2b)
		ld	h,a
		ld	l,000h
		dec	hl
		ld	(_5b57+5),hl
		ld	hl,out_F8_1
		call	otir_F8
		ld	hl,_5f04
		call	_5cac
		ld	a,087h
		di	
		out	(0f8h),a
		ei	
		ret	

out_F8_1:	defb	00eh
_5b57:		defb	083h,08bh,0c3h,06dh,040h,001h,000h,02ch,010h,0cdh,099h,061h,09ah,0cfh

_5b65:		in	a,(041h)
		rlca	
		jr	nc,_5b7e
		ld	a,083h
		out	(0f8h),a
		in	a,(040h)
		ld	b,a
		and	00bh
		push	af
		call	_5c25
		pop	af
		jp	nz,_5d09
		jp	_5ceb

_5b7e:		call	printimm
		ascii	'False Interrupt',13,10,0
		ret	

_5b94:		xor	a
		ld	(_5f26),a
		ld	hl,_5b9e
		ld	(_5f27),hl
_5b9e:		ld	de,(_5f29)
		ld	(_5f2b),de
_5ba6:		call	_5c64
		jr	z,_5bb0
		jp	c,_5d0b
		jr	_5ba6

_5bb0:		ld	hl,_5be7
		ld	(intr0_handler),hl
		call	_5c01
		ld	a,(_5f2b)
		ld	h,a
		ld	l,000h
		dec	hl
		ld	(_5bd7+6),hl
		ld	hl,out_F8_2
		call	otir_F8
		ld	hl,_5f0f
		call	_5cac
		di	
		ld	a,087h
		out	(0f8h),a
		ei	
		ret	

out_F8_2:	defb	010h
_5bd7:		defb	083h,08bh,0c3h,079h,099h,061h,001h,000h,014h,028h,0c5h,040h,09ah,0cfh,005h,0cfh

_5be7:		in	a,(041h)
		rlca	
		jp	nc,_5b7e
		ld	a,083h
		out	(0f8h),a
		in	a,(040h)
		ld	b,a
		and	00bh
		push	af
		call	_5c25
		pop	af
		jp	nz,_5d09
		jp	_5ceb

_5c01:		ld	a,0c1h
		out	(041h),a
		ret	

_5c06:		ld	bc,00000h
		ld	d,012h
_5c0b:		in	a,(041h)
		cp	0b8h
		jr	z,_5c20
		dec	bc
		ld	a,b
		or	c
		jr	nz,_5c0b
		dec	d
		jr	nz,_5c0b
		ld	a,00eh
		or	a
		ld	(_5f2d),a
		ret	

_5c20:		in	a,(040h)
		ld	(_5f2d),a
_5c25:		in	a,(041h)
		cp	0f8h
		jr	nz,_5c25
		in	a,(040h)
		in	a,(041h)
		bit	2,a
		jr	z,_5c36
		xor	a
		out	(041h),a
_5c36:		in	a,(041h)
		or	a
		jr	nz,_5c36
		ld	a,(_5f2d)
		and	00bh
		ret	

intr_vec_0:	push	af
		push	bc
		push	de
		push	hl
		push	ix
		push	iy
		ld	a,002h
		out	(041h),a
		xor	a
		ld	(_5f31),a
		ld	hl,(intr0_handler)
		ld	de,intr_finish
		push	de
		jp	(hl)

intr_finish:	ei	
		pop	iy
		pop	ix
		pop	hl
		pop	de
		pop	bc
		pop	af
		reti	

_5c64:		in	a,(041h)
		or	a
		ret	nz
		ld	a,001h
		out	(040h),a
		ld	a,004h
		out	(041h),a
		ld	bc,00064h
_5c73:		in	a,(041h)
		bit	7,a
		jr	nz,_5ca3
		djnz	_5c73
		dec	c
		jr	nz,_5c73
		ld	a,008h
		out	(041h),a
		ld	b,004h
_5c84:		djnz	_5c84
		ld	a,000h
		out	(041h),a
		ld	a,(_5f30)
		inc	a
		cp	014h
		jr	z,_5c99
		ld	(_5f30),a
		cp	0fdh
		ccf	
		ret	

_5c99:		xor	a
		ld	(_5f30),a
		ld	b,0fch
		scf	
		cp	0fdh
		ret	

_5ca3:		ld	a,000h
		out	(041h),a
		ld	(_5f30),a
		xor	a
		ret	

_5cac:		ld	b,(hl)
		inc	hl
		ld	a,(hl)
		cp	028h
		jr	z,_5cbb
		cp	02eh
		jr	z,_5cbb
		cp	02ah
		jr	nz,_5cd0
_5cbb:		push	hl
		push	bc
		ex	de,hl
		ld	hl,_57c0
		ld	bc,00004h
		inc	de
		inc	de
		ldir	
		inc	de
		inc	de
		ld	a,(_5f2b)
		ld	(de),a
		pop	bc
		pop	hl
_5cd0:		inc	hl
		ld	a,(hl)
		and	01fh
		ld	(hl),a
		ld	a,(_6129)
		rrca	
		rrca	
		rrca	
		or	(hl)
		ld	(hl),a
		dec	hl
		ld	c,040h
_5ce0:		in	a,(041h)
		cp	0b0h
		jr	nz,_5ce0
		outi	
		jr	nz,_5ce0
		ret	

_5ceb:		xor	a
		ld	(_5f2e),a
		ret	

_5cf0:		ld	c,040h
_5cf2:		in	a,(041h)
		ld	b,a
		and	0e8h
		cp	0a8h
		ret	z
		bit	4,b
		jr	z,_5cf2
		ini	
		jr	_5cf2

; Output block of bytes at HL+1 with length (HL) to port F8.
otir_F8:	ld	b,(hl)
		inc	hl
		ld	c,0f8h
		otir	
		ret	

_5d09:		ld	b,008h
_5d0b:		ld	a,(_5f2d)
		and	008h
		jp	nz,_5e7b
		ld	hl,_5f22
		ld	(hl),000h
		ld	a,0ffh
		ld	(ix+1ah),a
		ld	(ix+1bh),a
		ld	(ix+17h),b
		ld	a,b
		cp	008h
		jp	nz,_5e9a
		call	_5c64
		jr	z,_5d3b
		jr	c,_5d36
		ld	hl,_5d0b
		jp	_5b09

_5d36:		ld	b,0fch
		jp	_5e9a

_5d3b:		ld	hl,_5ef6
		call	_5cac
_5d41:		in	a,(041h)
		cp	098h
		jr	z,_5d4d
		ld	hl,_5d41
		jp	_5b09

_5d4d:		ld	hl,_5f1a
		call	_5cf0
		call	_5c06
		call	printimm
		ascii	13,10,'Cartridge Error, Sense',0
		ld	a,(_5f1c)
		call	preqhex
		ld	a,(_5f22)
		call	puthex
		ld	a,(_5f1c)
		and	00fh
		ld	(ix+1ah),a
		ld	b,a
		ld	a,(_5f22)
		ld	(ix+1bh),a
		and	07fh
		ld	c,a
		call	printimm
		ascii	' ',0
		push	bc
		push	ix
		ld	ix,cartmsg
		ld	de,00006h
_5d9f:		ld	a,(ix+00h)
		cp	0ffh
		jr	z,_5db3
		cp	b
		jr	nz,_5daf
		ld	a,(ix+01h)
		cp	c
		jr	z,_5db3
_5daf:		add	ix,de
		jr	_5d9f

_5db3:		ld	l,(ix+04h)
		ld	h,(ix+05h)
		call	print
		call	printimm
		ascii	13,10,0
		pop	ix
		pop	bc
		ld	hl,_5ec1
_5dc8:		ld	de,00005h
		ld	a,b
		cp	(hl)
		jr	nz,_5dde
		inc	hl
		dec	de
		ld	a,c
		and	(hl)
		inc	hl
		dec	de
		cp	(hl)
		jr	nz,_5dde
		inc	hl
		ld	e,(hl)
		inc	hl
		ld	d,(hl)
		ex	de,hl
		jp	(hl)

_5dde:		add	hl,de
		xor	a
		cp	(hl)
		jr	nz,_5dc8
		call	printimm
		ascii	'Unknown Error, Sense',0
		ld	a,b
		call	preqhex
		ld	a,c
		call	puthex
		call	printimm
		ascii	13,10,0
		ld	b,0fch
		jp	_5e97

_5e0e:		jp	_5e62

_5e11:		ld	b,001h
		jp	_5e97

_5e16:		ld	b,0fch
		ld	c,002h
		jp	_5e71

_5e1d:		call	_5c64
		jr	z,_5e2b
		jp	c,_5e68
		ld	hl,_5e1d
		jp	_5b09

_5e2b:		ld	hl,_5efd
		call	_5cac
		call	_5c06
		jp	nz,_5e68
_5e37:		call	_5c64
		jr	z,_5e44
		jr	c,_5e68
_5e3e:		ld	hl,_5e37
		jp	_5b09

_5e44:		in	a,(041h)
		and	028h
		cp	028h
		jr	nz,_5e50
		in	a,(040h)
		jr	_5e3e

_5e50:		ld	hl,_5ef6
		call	_5cac
		ld	hl,_5f1a
		call	_5cf0
		call	_5c06
		jp	nz,_5e68
_5e62:		ld	b,0fch
		ld	c,003h
		jr	_5e71

_5e68:		ld	b,0fch
		jp	_5e97

_5e6d:		ld	b,0fch
		ld	c,002h
_5e71:		ld	a,(_5f26)
		inc	a
		ld	(_5f26),a
		cp	c
		jr	nc,_5e97
_5e7b:		call	printimm
		ascii	'Retrying Operation',13,10,0
		ld	hl,(_5f27)
		jp	(hl)

_5e97:		ld	(ix+17h),b
_5e9a:		set	6,(ix+14h)
		ld	a,(_5f22)
		and	080h
		jp	z,_5ceb
		ld	a,(_5f1d)
		ld	(ix+06h),a
		ld	a,(_5f1e)
		ld	(ix+07h),a
		ld	a,(_5f1f)
		ld	(ix+08h),a
		ld	a,(_5f20)
		ld	(ix+09h),a
		jp	_5ceb

_5ec1:		defb	007h,0ffh,017h
		word	_5e11
		defb	009h,0ffh,01fh
		word	_5e11
		defb	006h,0ffh,000h
		word	_5e0e
		defb	003h,0e8h,000h
		word	_5e62
		defb	005h,000h,000h
		word	_5e16
		defb	004h,0ffh,023h
		word	_5e6d
		defb	004h,0f0h,000h
		word	_5e6d
		defb	002h,0ffh,009h
		word	_5e6d
		defb	004h,0ffh,015h
		word	_5e1d

		defb	000h,006h,003h,000h,000h,000h,004h,000h

_5ef6:		defb	006h,003h,000h,000h,000h,009h,000h
_5efd:		defb	006h,001h,000h,000h,000h,000h,000h
_5f04:		defb	00ah,028h,000h,000h,000h,000h,000h,000h,000h,000h,000h
_5f0f:		defb	00ah,02eh,000h,000h,000h,000h,000h,000h,000h,000h,000h

_5f1a:		nop	
		nop	
_5f1c:		nop	
_5f1d:		nop	
_5f1e:		nop	
_5f1f:		nop	
_5f20:		nop	
		nop	
_5f22:		nop	
		nop	
		nop	
		nop	
_5f26:		nop	
_5f27:		nop	
		nop	
_5f29:		nop	
		nop	
_5f2b:		nop	
		nop	
_5f2d:		nop	
_5f2e:		nop	
_5f2f:		nop	
_5f30:		nop	
_5f31:		nop	
_5f32:		nop	
		nop	
intr0_handler:	word	0
_5f36:		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		ld	a,001h
		defb	006h

_5f5d:		xor	a
		ld	(_5ffd),a
		ld	(_5ffe),a
		ld	(_612c),hl
		xor	a
		ld	(_6193),a
		ld	(_6194),a
		call	_5fc0
_5f71:		call	_60ff
		jr	z,_5f71
_5f76:		in	a,(041h)
		or	a
		jr	z,_5f92
		ld	c,a
		and	012h
		cp	010h
		jr	nz,_5f76
		ld	a,c
		and	068h
		ld	hl,_5fb0
		call	_6111
		jr	c,_5f92
		call	jphl
		jr	_5f76

_5f92:		ld	a,(_6193)
		or	a
		ret	z
		push	af
		ld	hl,(_612c)
		inc	hl
		ld	a,(hl)
		cp	003h
		jr	z,_5fac
		ld	a,00dh
		ld	(_615e+4),a
		ld	hl,_615d
		call	_5f5d
_5fac:		pop	af
		or	a
		ret	

jphl:		jp	(hl)

_5fb0:		defb	020h
		word	_5fff
		defb	000h
		word	_6083
		defb	008h
		word	_6035
		defb	028h
		word	_60d1
		defb	068h
		word	_60ea
		defb	0ffh

_5fc0:		push	hl
		pop	ix
		ld	a,(ix+02h)
		and	01fh
		ld	b,a
		ld	a,(_6129)
		rrca	
		rrca	
		rrca	
		or	b
		ld	(ix+02h),a
		ret	

_5fd4:		in	a,(041h)
		and	068h
		cp	020h
		ret	z
		ld	a,001h
		out	(040h),a
_5fdf:		in	a,(041h)
		bit	7,a
		jr	nz,_5fdf
		ld	a,004h
		out	(041h),a
_5fe9:		in	a,(041h)
		and	0feh
		jr	z,_5ff3
		bit	7,a
		jr	z,_5fe9
_5ff3:		ld	a,(_5ffd)
		out	(041h),a
		xor	a
		ld	(_5ffd),a
		ret	

_5ffd:		nop	
_5ffe:		nop	
_5fff:		ld	hl,(_612c)
		ld	b,(hl)
		inc	hl
		ld	c,040h
_6006:		in	a,(041h)
		ld	e,a
		and	012h
		cp	010h
		jr	nz,_6006
		ld	a,e
		and	068h
		cp	020h
		jr	nz,_601a
		outi	
		jr	nz,_6006
_601a:		ld	hl,003e8h
_601d:		dec	hl
		ld	a,h
		or	l
		jr	nz,_601d
		ret	

_6023:		ld	a,008h
		out	(041h),a
		ex	(sp),hl
		ex	(sp),hl
		xor	a
		out	(041h),a
		ld	hl,01388h
_602f:		dec	hl
		ld	a,h
		or	l
		jr	nz,_602f
		ret	

_6035:		ld	hl,endbuf
		ld	c,040h
		ld	ix,_612a
		ld	(ix+00h),000h
		ld	(ix+01h),000h
		ld	a,(_5ffe)
		or	a
		jr	z,_6068
		xor	a
		ld	(_5ffe),a
_6050:		in	a,(041h)
		ld	e,a
		and	012h
		cp	010h
		jr	nz,_6050
		ld	a,e
		and	068h
		cp	008h
		ret	nz
		ld	b,000h
		inir	
		inc	(ix+01h)
		jr	_6050

_6068:		in	a,(041h)
		ld	e,a
		and	012h
		cp	010h
		jr	nz,_6068
		ld	a,e
		and	068h
		cp	008h
		ret	nz
		ini	
		inc	(ix+00h)
		jr	nz,_6068
		inc	(ix+01h)
		jr	_6068

_6083:		ld	hl,endbuf
		ld	c,040h
		ld	ix,_612a
		ld	(ix+00h),000h
		ld	(ix+01h),000h
		ld	a,(_5ffe)
		or	a
		jr	z,_60b6
		xor	a
		ld	(_5ffe),a
_609e:		in	a,(041h)
		ld	e,a
		and	012h
		cp	010h
		jr	nz,_609e
		ld	a,e
		and	068h
		cp	000h
		ret	nz
		ld	b,000h
		otir	
		inc	(ix+01h)
		jr	_609e

_60b6:		in	a,(041h)
		ld	e,a
		and	012h
		cp	010h
		jr	nz,_60b6
		ld	a,e
		and	068h
		cp	000h
		ret	nz
		outi	
		inc	(ix+00h)
		jr	nz,_60b6
		inc	(ix+01h)
		jr	_60b6

_60d1:		ld	c,040h
_60d3:		in	a,(041h)
		ld	e,a
		and	012h
		cp	010h
		jr	nz,_60d3
		ld	a,e
		and	068h
		cp	028h
		ret	nz
		in	a,(040h)
		and	09fh
		ld	(_6193),a
		ret	

_60ea:		in	a,(041h)
		ld	e,a
		and	012h
		cp	010h
		jr	nz,_60ea
		ld	a,e
		and	068h
		cp	068h
		ret	nz
		in	a,(040h)
		ld	(_6194),a
		ret	

_60ff:		call	_5fd4
		in	a,(041h)
		push	af
		call	_60d1
		call	_60ea
		pop	af
		and	0feh
		cp	0b8h
		ret	

_6111:		ld	c,a
		ld	b,000h
_6114:		ld	a,(hl)
		cp	0ffh
		scf	
		ret	z
		cp	c
		jr	z,_6122
		inc	hl
		inc	hl
		inc	hl
		inc	b
		jr	_6114

_6122:		inc	hl
		ld	a,(hl)
		inc	hl
		ld	h,(hl)
		ld	l,a
		or	a
		ret	

_6129:		nop	
_612a:		nop	
		nop	
_612c:		nop	
_612d:		defb	006h
_612e:		defb	004h,000h,000h,000h,008h,000h
_6134:		defb	006h
_6135:		defb	004h,016h,000h,000h,008h,000h
_613b:		defb	000h,048h,002h,000h,000h,000h
_6141:		defb	006h
		defb	000h,000h,000h,000h,000h,000h
; Apparently unused data.
		defb	006h
		defb	001h,000h,000h,000h,000h,000h
_614f:		defb	006h
		defb	01bh,000h,000h,000h,001h,000h
_6156:		defb	006h
		defb	01bh,001h,000h,000h,000h,000h
_615d:		defb	006h
_615e:		defb	003h,000h,000h,000h,004h,000h
_6164:		defb	00ah
_6165:		defb	02ah,000h,000h,000h,000h,000h,000h,000h,001h,000h
_616f:		defb	00ah
_6170:		defb	028h,000h,000h,000h,000h,000h,000h,000h,001h,000h
_617a:		defb	006h
		defb	01eh,000h,000h,000h,001h,000h
_6181:		defb	006h
		defb	01eh,000h,000h,000h,000h,000h
_6188:		defb	00ah
		defb	025h,000h,000h,000h,000h,000h,000h,000h,000h,000h
_6193:		defb	000h
_6194:		defb	000h
; Signature of Frank Durda IV (legendary Tandy programmer)
		ascii	'fdiv'
; Buffer at end of program used variously.
endbuf:		nop	
_end		equ	$

		end	_start
