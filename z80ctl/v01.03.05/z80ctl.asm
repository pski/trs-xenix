; z80ctl 01.03.05 disassembly.
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

; This initial chunk appears to be some kind of header.  I'm not entirely
; certain if the execution and load addresses are little or big endian.
; To be safe simply choose addresses that are a multiple of 256.

		org	04fcch
_begin:		defb	002h
		defb	006h
		defb	000h
		defb	014h
		defb	000h
		defb	000h
		defb	029h
		defb	01ah
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		defb	000h
		word	_start		; Execution address.
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

_start:		jp	_5088

		ascii	10,'TRS-XENIX z80 control program',10,'RDP 1/3/83',10,'Copyright (C) 1983 Microsoft Corporation',10,'All Rights Reserved',10,'Licensed to Tandy Corporation',10
_5088:		di	
		ld	sp,017c1h
		ld	hl,00180h
		ld	de,00181h
		ld	bc,01641h
		ld	(hl),000h
		ldir	
		ld	hl,017c2h
		ld	de,017c3h
		ld	bc,0383dh
		ld	(hl),0ffh
		ldir	
		ld	a,0c3h
		ld	(00038h),a
		ld	hl,_53d3
		ld	(00039h),hl
		ld	a,080h
		ld	(0017fh),a
		out	(0ffh),a
		ld	a,004h
		ld	(0015eh),a
		out	(0deh),a
		ld	a,000h
		ld	(0015fh),a
		out	(0dfh),a
		ld	de,(08006h)
		ld	a,00ch
		ld	(0015eh),a
		out	(0deh),a
		ex	(sp),hl
		ex	(sp),hl
		ex	(sp),hl
		ex	(sp),hl
		ex	(sp),hl
		ex	(sp),hl
		ld	a,000h
		ld	(0015eh),a
		out	(0deh),a
_50de:		ld	hl,(08006h)
		or	a
		sbc	hl,de
		jr	z,_50de
		ld	de,(08006h)
		ld	l,d
		ld	h,e
		set	7,h
		res	6,h
		ld	(00191h),hl
		ld	hl,(00191h)
		ld	de,001c2h
		add	hl,de
		ld	a,(00077h)
		ld	(hl),a
		nop	
		nop	
		nop	
		call	_5435
		call	_78d3
		call	_761f
		call	_5488
		call	_5c48
		call	_64e8
		call	_5314
		call	_6f27
		jr	_5139

		ascii	'<< *** Version 1.3.2 *** >>',10,13,0
_5139:		ld	hl,00000h
		ld	(08006h),hl
		ei	
		jr	_5146

_5142:		defb	000h			
_5143:		defb	000h			
_5144:		defb	000h			
		defb	000h			
_5146:		call	_76e8
		ld	iy,(0019bh)
		ld	a,(002e4h)
		or	a
		jr	z,_5163
		ld	a,(_5142)
		ld	b,a
		ld	a,(iy+00h)
		sub	b
		jp	m,_516e
		call	_5189
		jr	_516e

_5163:		ld	a,(_5142)
		ld	b,a
		ld	a,(_5143)
		sub	b
		call	p,_5189
_516e:		call	_6eea
		call	_54fd
		call	_5c91
		call	_6a4f
		call	_6d86
		call	_75ae
		call	_6f3a
		call	_63dc
		jp	_5146

_5189:		ld	iy,(0019bh)
		ld	b,(iy+00h)
		ld	a,(iy+01h)
		cp	b
		ret	z
		inc	a
		push	af
		push	iy
		pop	de
		ld	hl,00002h
		add	hl,de
		ex	de,hl
		and	01fh
		ld	l,a
		ld	h,000h
		add	hl,hl
		add	hl,de
		call	_51b4
		pop	af
		ld	(iy+01h),a
		ld	hl,_5142
		inc	(hl)
		jp	_5189

_51b4:		ld	a,(hl)
		push	af
		rrca	
		rrca	
		rrca	
		rrca	
		and	00fh
		cp	007h
		call	nc,_5203
		rlca	
		ld	b,a
		rlca	
		add	a,b
		ld	e,a
		inc	hl
		ld	a,(hl)
		or	a
		call	m,_51e5
		cp	003h
		call	nc,_5221
		rlca	
		add	a,e
		ld	e,a
		ld	d,000h
		pop	af
		and	00fh
		ld	hl,_523f
		add	hl,de
		ld	e,(hl)
		inc	hl
		ld	d,(hl)
		ex	de,hl
		call	jphl
		ret	

_51e5:		call	panic
		ascii	'<< *** DIAG:QOVFLW *** >>',0
		ret	

_5203:		call	panic
		ascii	'<< *** DIAG:BADMAJ *** >>',0
		ret	

_5221:		call	panic
		ascii	'<< *** DIAG:BADCMD *** >>',0
		ret	

_523f:		word	_5278
		word	_5282
		word	_527d
		word	_5287
		word	_5291
		word	_528c
		word	_5296
		word	_52a0
		word	_529b
		word	_52c7
		word	_52c7
		word	_52c7
		word	_52a9
		word	_52b4
		word	_52ae
		word	_52ba
		word	_52bf
		word	_52c3
		word	_5269
		word	_526e
		word	_5273
_5269:		ld	hl,_52f5
		inc	(hl)
		ret	

_526e:		ld	a,0a1h
		jp	_52cb

_5273:		ld	a,0a2h
		jp	_52cb

_5278:		ld	hl,_52f1
		inc	(hl)
		ret	

_527d:		ld	a,0d1h
		jp	_52cb

_5282:		ld	a,0d2h
		jp	_52cb

_5287:		ld	hl,_52f2
		inc	(hl)
		ret	

_528c:		ld	a,0d3h
		jp	_52cb

_5291:		ld	a,0d4h
		jp	_52cb

_5296:		ld	hl,_52f6
		jr	_52a3

_529b:		ld	hl,_5300
		jr	_52a3

_52a0:		ld	hl,_530a
_52a3:		ld	e,a
		ld	d,000h
		add	hl,de
		inc	(hl)
		ret	

_52a9:		ld	a,0c0h
		jp	_52cb

_52ae:		ld	hl,_52f0
		ld	(hl),0ffh
		ret	

_52b4:		ld	hl,_52f0
		ld	(hl),000h
		ret	

_52ba:		ld	hl,_52f3
		jr	_52a3

_52bf:		ld	a,0b1h
		jr	_52cb

_52c3:		ld	a,0b2h
		jr	_52cb

_52c7:		ld	a,0a0h
		jr	_52cb

_52cb:		call	printimm
		ascii	'<<  *** DIAG:BDRQ',0
		call	preqhex
		call	printimm
		ascii	' *** >>',10,0
		ret	

_52f0:		nop	
_52f1:		nop	
_52f2:		nop	
_52f3:		nop	
_52f4:		nop	
_52f5:		nop	
_52f6:		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
_5300:		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
_530a:		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
_5314:		call	_76e8
		ld	de,(00191h)
		ld	hl,00180h
		add	hl,de
		ld	(0019bh),hl
		ld	de,00000h
		add	hl,de
		ld	a,(hl)
		ld	(_5143),a
		inc	a
		ld	(_5142),a
		ld	a,(_75ac)
		ld	b,01eh
		add	a,b
		ld	(_5144),a
		ret	

_5338:		push	af
		push	de
		push	hl
		call	_5433
		ld	a,(0015eh)
		ld	d,a
		ld	a,(0015fh)
		ld	e,a
		call	_76e8
		ld	hl,(0019bh)
		ld	a,(hl)
		ld	(_5143),a
		ld	a,e
		ld	(0015fh),a
		out	(0dfh),a
		ld	a,d
		ld	(0015eh),a
		out	(0deh),a
		pop	hl
		pop	de
		pop	af
		ei	
		ret	

; Display panic message on console.
panic:		di	
		ld	a,0ffh
		out	(0efh),a
		ld	a,004h
		ld	(0015eh),a
		out	(0deh),a
		ld	a,080h
		ld	(0017fh),a
		out	(0ffh),a
		call	_53a8
		call	printimm
		ascii	13,10,27,'RD z80 panic: ',0
		ex	(sp),hl
_538d:		ld	a,(hl)
		inc	hl
		or	a
		jr	z,_5397
		call	putc
		jr	_538d

_5397:		call	printimm
		ascii	27,'R@',0
		call	printimm
		ascii	13,10,0
		ex	(sp),hl
		jp	_53f7

_53a8:		call	printimm
		ascii	27,'Y7',10,13,0
		ret	

_53b2:		call	printimm
		ascii	10,13,0
_53b8:		call	printimm
		ascii	27,'RD',0
		ex	(sp),hl
_53c0:		ld	a,(hl)
		inc	hl
		or	a
		jr	z,_53ca
		call	putc
		jr	_53c0

_53ca:		ex	(sp),hl
		call	printimm
		ascii	27,'R@',0
		ret	

_53d3:		di	
		call	_53a8
		call	printimm
		ascii	'<< *** DIAG:00RST7 *** >>',0
		jp	_53f7

_53f7:		call	_53a8
		call	_53b2
		ascii	' system halted. ',0
_540e:		halt	
		jr	_540e

		ret	

_5412:		call	panic
		ascii	'Unknown z80 interrupt.',0
		push	de
		ld	e,(hl)
		inc	hl
		ld	d,(hl)
		ex	de,hl
		pop	de
jphl:		jp	(hl)

_5433:		reti	

_5435:		im	2
		ld	a,07ah
		ld	i,a
		ld	b,004h
_543d:		call	_5433
		djnz	_543d
		ld	bc,00034h
		ld	hl,intrvec
		ld	de,07a00h
		ldir	
		ret	

intrvec:	word	_6746
		word	_6754
		word	_6762
		word	_5412
		word	_6770
		word	_677e
		word	_678c
		word	_5412
		word	_6666
		word	_6666
		word	_6666
		word	_6666
		word	_6666
		word	_6666
		word	_6666
		word	_6666
		word	_5412
		word	_5338
		word	_5412
		word	_6896
		word	_5f44
		word	_5412
		word	_5412
		word	_5412
		word	_5737
		word	_68d6
; Unreferenced data?
		defb	0adh,0bbh,0afh,0b4h,0abh,0bdh
_5488:		call	_76e8
		ld	hl,_54da
		ld	(002fdh),hl
		xor	a
		ld	(00303h),a
		ld	(00305h),a
		ld	(00304h),a
		ld	ix,00008h
		ld	de,(00191h)
		add	ix,de
		ld	(00197h),ix
		ld	(ix+14h),a
		dec	a
		ld	(002eah),a
		ld	iy,0030ch
		ld	de,0000ah
		ld	b,004h
_54b9:		ld	(iy+00h),000h
		ld	(iy+01h),000h
		add	iy,de
		djnz	_54b9
		ld	hl,_54cb
		jp	_7890

_54cb:		defb	0efh,0ffh
		defb	0e4h,0d0h
		defb	0e2h,030h
		defb	0e2h,0cfh
		defb	0e2h,0f7h
		defb	0e2h,0b7h
		defb	0e2h,0feh
		defb	000h			
_54da:		call	panic
		ascii	10,13,'Unexpected floppy interrupt',0
_54fb:		jr	_54fb

_54fd:		ld	a,(_52f1)
		or	a
		ret	z
		ld	a,(00303h)
		or	a
		jr	nz,_5538
		call	_78c7
		jr	nz,_5559
		call	_76e8
		ld	ix,(00197h)
		bit	0,(ix+14h)
		jr	z,_557a
		di	
		ld	a,0ffh
		ld	(00303h),a
		ld	hl,_52f1
		dec	(hl)
		ld	a,004h
		ld	(00300h),a
		ld	a,004h
		ld	(00302h),a
		ei	
		call	_55a0
		di	
		call	z,_5769
		ei	
		ret	

_5538:		call	printimm
		ascii	'<< *** DIAG:0FDBSY *** >>',10,13,0
		jr	_559a

_5559:		call	printimm
		ascii	'<< *** DIAG:0FDLCK *** >>',10,13,0
		jr	_559a

_557a:		call	printimm
		ascii	'<< **** DIAG:0FDNGO *** >>',10,13,0
_559a:		ld	hl,_52f1
		ld	(hl),000h
		ret	

_55a0:		ld	(ix+17h),000h
		ld	a,(ix+14h)
		ld	b,a
		and	00ch
		ld	(002e8h),a
		ld	a,b
		cpl	
		cp	(ix+15h)
		jr	z,_55d1
		call	panic
		ascii	'<< *** DIAG:0FDCMD *** >>',0
_55d1:		ld	a,(002eah)
		cp	(ix+16h)
		jp	z,_560f
		ld	a,(ix+16h)
		cp	004h
		ld	b,020h
		jp	nc,_57d3
		ld	b,0feh
		ld	iy,0030ch
		ld	de,0000ah
_55ed:		or	a
		jr	z,_55f7
		rlc	b
		add	iy,de
		dec	a
		jr	_55ed

_55f7:		ld	a,b
		or	040h
		ld	a,a
		ld	(0016fh),a
		out	(0efh),a
		ld	(002e6h),iy
		ld	a,(iy+01h)
		out	(0e5h),a
		ld	a,(ix+16h)
		ld	(002eah),a
_560f:		ld	iy,(002e6h)
		in	a,(0e0h)
		and	004h
		jr	z,_5634
		bit	2,(ix+19h)
		jr	z,_5634
		ld	(iy+00h),000h
		ld	b,0f7h
_5625:		djnz	_5625
		ld	a,0ffh
		out	(0efh),a
		ld	b,0f7h
_562d:		djnz	_562d
		ld	a,(0016fh)
		out	(0efh),a
_5634:		ld	a,(002e8h)
		cp	000h
		jr	nz,_5647
		ld	hl,00001h
		ld	(002ebh),hl
		ld	(002edh),hl
		jp	_56e4

_5647:		bit	0,(iy+00h)
		ld	b,008h
		jp	z,_57d3
		ld	h,(ix+04h)
		ld	l,(ix+05h)
		ld	(002ebh),hl
		ld	(002edh),hl
		ld	hl,00631h
		ld	(002f9h),hl
		ld	(002fbh),hl
		ld	a,(ix+07h)
		ld	(002f1h),a
		ld	a,(ix+09h)
		ld	(002f3h),a
		ld	a,(ix+0bh)
		ld	(002efh),a
		bit	1,(iy+09h)
		jr	z,_568f
		bit	0,(iy+09h)
		jr	z,_56ac
		ld	a,(002f1h)
		or	a
		jr	nz,_56ac
		ld	a,(002f3h)
		or	a
		jr	nz,_56ac
_568f:		ld	a,(0016fh)
		and	07fh
		ld	(0016fh),a
		out	(0efh),a
		bit	0,(iy+09h)
		jr	z,_56b6
		ld	hl,00080h
		ld	(002f5h),hl
		ld	a,01ah
		ld	(002f7h),a
		jr	_56c5

_56ac:		ld	a,(0016fh)
		or	080h
		ld	(0016fh),a
		out	(0efh),a
_56b6:		ld	h,(iy+05h)
		ld	l,(iy+04h)
		ld	(002f5h),hl
		ld	a,(iy+06h)
		ld	(002f7h),a
_56c5:		ld	a,(002f3h)
		cp	(iy+08h)
		ld	b,020h
		jp	nc,_57d3
		ld	a,(002f7h)
		ld	c,a
		ld	a,(002efh)
		cp	c
		jp	nc,_57d3
		ld	a,(002f1h)
		cp	(iy+02h)
		jp	nc,_57d3
_56e4:		xor	a
		ld	(002e9h),a
		ld	a,02dh
		ld	(00301h),a
		ld	a,008h
		ld	(002ffh),a
		ld	hl,_580f
		ld	(002fdh),hl
		xor	a
		ret	

_56fa:		ld	a,(00303h)
		or	a
		jr	nz,_571a
		ld	a,(00302h)
		or	a
		jr	z,_5736
		dec	a
		ld	(00302h),a
		jr	nz,_5736
		ld	a,0ffh
		ld	(002eah),a
		ld	a,0ffh
		ld	(0016fh),a
		out	(0efh),a
		jr	_5736

_571a:		push	ix
		push	iy
		ld	ix,(00197h)
		ld	iy,(002e6h)
		ld	a,(00300h)
		dec	a
		ld	(00300h),a
		ld	b,004h
		call	z,_57d3
		pop	iy
		pop	ix
_5736:		ret	

_5737:		push	af
		push	bc
		push	de
		push	hl
		push	ix
		push	iy
		ld	a,(0015eh)
		ld	h,a
		ld	a,(0015fh)
		ld	l,a
		push	hl
		call	_5433
		xor	a
		ld	(00305h),a
		call	_5769
		pop	hl
		ld	a,l
		ld	(0015fh),a
		out	(0dfh),a
		ld	a,h
		ld	(0015eh),a
		out	(0deh),a
		pop	iy
		pop	ix
		pop	hl
		pop	de
		pop	bc
		pop	af
		ei	
		ret	

_5769:		call	_76e8
		ld	ix,(00197h)
		ld	iy,(002e6h)
		ld	hl,(002fdh)
		call	jphl
		ld	a,004h
		ld	(00302h),a
		ld	a,004h
		ld	(00300h),a
		ld	hl,(002ebh)
		ld	a,h
		or	l
		ret	nz
		ld	hl,(002edh)
		ld	a,h
		or	l
		ret	nz
		jr	_5792

_5792:		ld	a,i
		push	af
		di	
		ld	hl,00000h
		ld	(002ebh),hl
		ld	(002edh),hl
		ld	a,(00303h)
		or	a
		jr	z,_57c8
		xor	a
		ld	(00303h),a
		set	5,(ix+14h)
		res	0,(ix+14h)
		ld	ix,(00191h)
		ld	de,00004h
		add	ix,de
		inc	(ix+02h)
		ld	a,(0015eh)
		or	020h
		out	(0deh),a
		and	0dfh
		out	(0deh),a
_57c8:		call	_78d3
		pop	af
		jp	po,_57d0
		ei	
_57d0:		or	0ffh
		ret	

_57d3:		di	
		ld	a,(0016fh)
		ld	(ix+1ah),a
		in	a,(0e5h)
		ld	(ix+07h),a
		ld	a,(002f3h)
		ld	(ix+09h),a
		in	a,(0e6h)
		ld	(ix+0bh),a
		ld	a,b
		cp	004h
		jr	nz,_5801
		ld	a,0d0h
		ld	(00164h),a
		out	(0e4h),a
		ld	a,0ffh
		ld	(002eah),a
		ld	a,a
		ld	(0016fh),a
		out	(0efh),a
_5801:		ld	(ix+17h),b
		set	6,(ix+14h)
		ld	a,b
		cp	001h
		jp	nz,_5792
		ret	

_580f:		ld	hl,(002ebh)
		ld	a,h
		or	l
		jp	z,_5a50
		ld	a,(00303h)
		or	a
		ret	z
		in	a,(0e4h)
		ld	(ix+1bh),a
		and	080h
		jr	z,_5845
		bit	1,(ix+19h)
		jr	z,_5840
		ld	hl,_580f
		ld	(002fdh),hl
		ld	a,(00301h)
		dec	a
		ld	(00301h),a
		ld	hl,_5769
		ld	a,002h
		jp	nz,_765c
_5840:		ld	b,004h
		jp	_57d3

_5845:		ld	a,(002e8h)
		cp	000h
		jp	z,_5ae9
		ld	a,(002f1h)
		cp	(iy+01h)
		jp	nz,_5997
		ld	a,(002e8h)
		cp	008h
		jr	z,_585f
		jr	_5880

_585f:		in	a,(0e4h)
		and	040h
		ld	b,010h
		jp	nz,_57d3
		ld	hl,(002f9h)
		ld	de,(002fbh)
		or	a
		sbc	hl,de
		jp	z,_5a50
		ld	hl,(002f9h)
		call	_78e8
		ld	b,0a0h
		jp	_58b1

_5880:		ld	hl,(002f9h)
		ld	de,(002f5h)
		add	hl,de
		ld	b,h
		ld	c,l
		ld	de,(002fbh)
		or	a
		sbc	hl,de
		jr	z,_589a
		ld	hl,00c00h
		add	hl,de
		or	a
		sbc	hl,bc
_589a:		jp	z,_5a50
		ld	hl,(002f9h)
		call	_7902
		ld	b,080h
		jr	_58b1

_58a7:		ld	hl,01231h
		call	_7902
		ld	b,080h
		jr	_58b1

_58b1:		ld	a,(002efh)
		inc	a
		out	(0e6h),a
		ld	hl,_58eb
		ld	(002fdh),hl
		ld	a,(002f3h)
		or	a
		jr	z,_58d1
		ld	a,(0016fh)
		and	0bfh
		ld	(0016fh),a
		out	(0efh),a
		ld	a,00ah
		jr	_58dd

_58d1:		ld	a,(0016fh)
		or	040h
		ld	(0016fh),a
		out	(0efh),a
		ld	a,002h
_58dd:		ld	a,b
		ld	(00164h),a
		out	(0e4h),a
		ld	a,0ffh
		ld	(00305h),a
		jp	_5a50

_58eb:		in	a,(0e4h)
		ld	(ix+1bh),a
		ld	c,a
		and	09ch
		jr	z,_5914
		xor	a
		ld	(002e9h),a
		bit	7,c
		ld	b,004h
		jp	nz,_57d3
		ld	a,(002ffh)
		dec	a
		ld	(002ffh),a
		ld	b,002h
		jp	z,_57d3
		cp	006h
		jp	z,_59d4
		jp	_580f

_5914:		ld	a,(002e8h)
		cp	008h
		jr	nz,_592c
		bit	0,(ix+19h)
		jr	z,_592c
		ld	a,(002e9h)
		xor	0ffh
		ld	(002e9h),a
		jp	nz,_58a7
_592c:		ld	a,(002ffh)
		cp	003h
		jr	nc,_5938
		ld	b,001h
		call	_57d3
_5938:		ld	hl,(002ebh)
		dec	hl
		ld	(002ebh),hl
		ld	a,h
		or	l
		jr	z,_597b
		ld	a,008h
		ld	(002ffh),a
		ld	a,(002f7h)
		ld	b,a
		ld	a,(002efh)
		inc	a
		ld	(002efh),a
		cp	b
		jr	c,_597b
		xor	a
		ld	(002efh),a
		ld	a,(002f3h)
		inc	a
		ld	(002f3h),a
		cp	(iy+08h)
		jr	c,_597b
		xor	a
		ld	(002f3h),a
		ld	a,(002f1h)
		inc	a
		ld	(002f1h),a
		cp	(iy+02h)
		jr	c,_597b
		ld	b,020h
		jp	_57d3

_597b:		ld	hl,(002f9h)
		ld	de,(002f5h)
		add	hl,de
		ld	(002f9h),hl
		ld	de,01231h
		or	a
		sbc	hl,de
		jr	c,_5994
		ld	hl,00631h
		ld	(002f9h),hl
_5994:		jp	_580f

_5997:		ld	a,(0016fh)
		or	040h
		and	07fh
		ld	b,a
		bit	1,(iy+09h)
		jr	z,_59b3
		ld	a,(002f1h)
		or	a
		jr	nz,_59b1
		bit	0,(iy+09h)
		jr	nz,_59b3
_59b1:		set	7,b
_59b3:		ld	a,b
		out	(0efh),a
		ld	a,(002f1h)
		out	(0e7h),a
		ld	hl,_5a06
		ld	(002fdh),hl
		ld	a,(ix+18h)
		or	01ch
		ld	a,a
		ld	(00164h),a
		out	(0e4h),a
		ld	a,0ffh
		ld	(00305h),a
		jp	_5a50

_59d4:		ld	a,(0016fh)
		or	040h
		and	07fh
		ld	b,a
		bit	1,(iy+09h)
		jr	z,_59ea
		bit	0,(iy+09h)
		jr	nz,_59ea
		set	7,b
_59ea:		ld	a,b
		out	(0efh),a
		ld	hl,_5a06
		ld	(002fdh),hl
		ld	a,(ix+18h)
		or	00ch
		ld	a,a
		ld	(00164h),a
		out	(0e4h),a
		ld	a,0ffh
		ld	(00305h),a
		jp	_5a50

_5a06:		ld	a,(0016fh)
		out	(0efh),a
		in	a,(0e4h)
		ld	(ix+1bh),a
		ld	c,a
		and	098h
		jr	z,_5a35
		xor	a
		ld	(002e9h),a
		bit	7,c
		ld	b,004h
		jp	nz,_57d3
		ld	a,(002ffh)
		dec	a
		ld	(002ffh),a
		cp	006h
		jp	z,_59d4
		or	a
		jp	nz,_5997
		ld	b,002h
		jp	_57d3

_5a35:		ld	a,(002e9h)
		xor	0ffh
		ld	(002e9h),a
		jp	nz,_5997
		in	a,(0e5h)
		ld	(iy+01h),a
		ld	bc,00a00h
_5a48:		dec	bc
		ld	a,c
		or	b
		jr	nz,_5a48
		jp	_580f

_5a50:		ld	a,(00304h)
		or	a
		ret	nz
_5a55:		ld	a,(002e8h)
		cp	004h
		jr	z,_5a81
		cp	000h
		ret	z
		ld	hl,(002edh)
		ld	a,h
		or	l
		ret	z
		ld	hl,(002fbh)
		ld	de,(002f5h)
		add	hl,de
		ld	b,h
		ld	c,l
		ld	de,(002f9h)
		or	a
		sbc	hl,de
		ret	z
		ld	hl,00c00h
		add	hl,de
		or	a
		sbc	hl,bc
		ret	z
		jr	_5a8c

_5a81:		ld	hl,(002f9h)
		ld	de,(002fbh)
		or	a
		sbc	hl,de
		ret	z
_5a8c:		ld	a,001h
		ld	(00304h),a
		ld	bc,(002f5h)
		ld	hl,(002fbh)
		ei	
		ld	a,(002e8h)
		cp	004h
		jr	nz,_5aa5
		call	_7710
		jr	_5aa8

_5aa5:		call	_775c
_5aa8:		di	
		xor	a
		ld	(00304h),a
		ld	hl,(002edh)
		dec	hl
		ld	(002edh),hl
		ld	de,(002f5h)
		ld	l,(ix+03h)
		ld	h,(ix+02h)
		add	hl,de
		ld	(ix+03h),l
		ld	(ix+02h),h
		jr	nc,_5aca
		inc	(ix+01h)
_5aca:		ld	hl,(002fbh)
		add	hl,de
		ld	(002fbh),hl
		ld	de,01231h
		or	a
		sbc	hl,de
		jr	c,_5adf
		ld	hl,00631h
		ld	(002fbh),hl
_5adf:		ld	a,(00305h)
		or	a
		jp	z,_580f
		jp	_5a55

_5ae9:		ld	(iy+09h),000h
		ld	hl,_5af8
		ld	(002fdh),hl
		ld	a,00eh
		out	(0e4h),a
		ret	

_5af8:		in	a,(0e4h)
		and	040h
		jr	z,_5b02
		set	4,(iy+09h)
_5b02:		ld	a,(0016fh)
		and	07fh
		ld	(0016fh),a
		out	(0efh),a
		ld	a,(0016fh)
		or	040h
		ld	(0016fh),a
		out	(0efh),a
		ld	hl,_5b27
		ld	(002fdh),hl
		ld	hl,00306h
		call	_7902
		ld	a,0c0h
		out	(0e4h),a
		ret	

_5b27:		in	a,(0e4h)
		and	09ch
		jr	z,_5b58
		ld	hl,_5b48
		ld	(002fdh),hl
		ld	a,(0016fh)
		or	080h
		ld	(0016fh),a
		out	(0efh),a
		ld	hl,00306h
		call	_7902
		ld	a,0c0h
		out	(0e4h),a
		ret	

_5b48:		in	a,(0e4h)
		and	09ch
		ld	b,002h
		jp	nz,_57d3
		set	1,(iy+09h)
		jp	_5bca

_5b58:		ld	a,(00309h)
		ld	(_5c3f),a
		ld	a,001h
		out	(0e7h),a
		ld	hl,_5b6d
		ld	(002fdh),hl
		ld	a,01bh
		out	(0e4h),a
		ret	

_5b6d:		in	a,(0e4h)
		inc	(iy+01h)
		ld	hl,_5b8d
		ld	(002fdh),hl
		ld	a,(0016fh)
		or	080h
		ld	(0016fh),a
		out	(0efh),a
		ld	hl,00306h
		call	_7902
		ld	a,0c0h
		out	(0e4h),a
		ret	

_5b8d:		in	a,(0e4h)
		and	09ch
		jr	z,_5bb9
		ld	hl,_5bae
		ld	(002fdh),hl
		ld	a,(0016fh)
		and	07fh
		ld	(0016fh),a
		out	(0efh),a
		ld	hl,00306h
		call	_7902
		ld	a,0c0h
		out	(0e4h),a
		ret	

_5bae:		in	a,(0e4h)
		and	09ch
		ld	b,002h
		jp	nz,_57d3
		jr	_5bca

_5bb9:		ld	a,(_5c3f)
		or	a
		ld	b,002h
		jp	nz,_57d3
		set	0,(iy+09h)
		set	1,(iy+09h)
_5bca:		ld	a,(00309h)
		ld	b,a
		inc	b
		ld	hl,00040h
_5bd2:		add	hl,hl
		djnz	_5bd2
		ld	(iy+04h),l
		ld	(iy+05h),h
		bit	1,(iy+09h)
		ld	hl,_5c40
		jr	z,_5be7
		ld	hl,_5c44
_5be7:		ld	c,a
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
		jr	z,_5c20
		inc	a
_5c20:		ld	(iy+08h),a
		ld	(ix+12h),a
		ld	a,(iy+09h)
		ld	(ix+13h),a
		ld	hl,00000h
		ld	(002ebh),hl
		ld	(002edh),hl
		ld	(iy+00h),001h
		ld	a,000h
		ld	(00164h),a
		ret	

_5c3f:		nop	
_5c40:		ld	a,(de)
		dec	c
		ex	af,af'
		inc	b
_5c44:		inc	(hl)
		ld	a,(de)
		djnz	_5c4f+1
_5c48:		call	_76e8
		ld	ix,00024h
_5c4f:		ld	de,(00191h)
		add	ix,de
		ld	(00199h),ix
		xor	a
		ld	(00347h),a
		ld	(ix+14h),a
		dec	a
		ld	(00339h),a
		ld	hl,_5fcf
		ld	(00343h),hl
		ld	a,00ah
		ld	(00346h),a
		call	_63b7
		ld	hl,_5c8a
		call	_7890
		ld	iy,00349h
		ld	de,000bah
		ld	b,004h
_5c81:		ld	(iy+00h),000h
		add	iy,de
		djnz	_5c81
		ret	

_5c8a:		defb	0c1h,00eh
		defb	0c4h,028h
		defb	0c4h,003h
		defb	000h
_5c91:		ld	hl,_52f2
		ld	a,(hl)
		or	a
		ret	z
		ld	a,(00347h)
		or	a
		jp	nz,_5db8
		call	_76e8
		ld	ix,(00199h)
		in	a,(0cfh)
		bit	7,a
		jp	nz,_5e7a
		bit	1,a
		jp	nz,_5e3a
		bit	0,(ix+14h)
		jp	z,_5e15
		di	
		ld	a,001h
		ld	(00347h),a
		dec	(hl)
		ld	(ix+17h),000h
		ld	a,(ix+14h)
		ld	b,a
		and	00ch
		ld	(00336h),a
		ld	a,b
		cpl	
		cp	(ix+15h)
		jp	nz,_5dd7
		ld	a,(00339h)
		ld	b,(ix+16h)
		cp	b
		jp	z,_5d21
		ld	a,b
		cp	004h
		ld	b,020h
		jp	nc,_609a
		ld	(00339h),a
		push	af
		ld	iy,00349h
		ld	de,000bah
_5cf1:		or	a
		jr	z,_5cf9
		add	iy,de
		dec	a
		jr	_5cf1

_5cf9:		ld	(00334h),iy
		pop	af
		rlca	
		rlca	
		rlca	
		or	020h
		ld	a,a
		ld	(0014eh),a
		out	(0ceh),a
		ld	h,(iy+18h)
		ld	l,(iy+19h)
		srl	h
		rr	l
		srl	h
		rr	l
		ld	a,l
		ld	(00348h),a
		ld	a,a
		ld	(00149h),a
		out	(0c9h),a
_5d21:		ld	iy,(00334h)
		in	a,(0cfh)
		ld	(ix+1bh),a
		push	af
		push	hl
		ld	hl,_5e5c+14
		call	hexstr
		pop	hl
		pop	af
		ld	b,004h
		bit	1,a
		jp	nz,_5e3a
		and	040h
		jp	z,_5e59
		ld	a,0aah
		out	(0cah),a
		in	a,(0cah)
		cp	0aah
		jp	nz,_5df6
		ld	a,001h
		out	(0cah),a
		ei	
		ld	hl,00004h
		ld	(0033bh),hl
		ld	a,(00336h)
		cp	000h
		jr	z,_5da1
		bit	0,(iy+00h)
		ld	b,008h
		jp	z,_609a
		ld	h,(ix+04h)
		ld	l,(ix+05h)
		ld	(0033bh),hl
		ld	h,(ix+06h)
		ld	l,(ix+07h)
		ld	(0033fh),hl
		ld	e,(iy+02h)
		ld	d,(iy+03h)
		or	a
		sbc	hl,de
		ld	b,020h
		jp	nc,_609a
		ld	a,(ix+09h)
		ld	(00341h),a
		cp	(iy+08h)
		jp	nc,_609a
		ld	a,(ix+0bh)
		ld	(0033dh),a
		cp	(iy+06h)
		jp	nc,_609a
		call	_6469
_5da1:		xor	a
		ld	(00338h),a
		ld	a,00ah
		ld	(00346h),a
		ld	a,004h
		ld	(00345h),a
		ld	hl,_6001
		ld	(00343h),hl
		jp	_5fb1

_5db8:		call	panic
		ascii	10,13,'<< *** DIAG:0HDBSY *** >>',0
_5dd7:		call	panic
		ascii	10,13,'<< *** DIAG:HDXCSR *** >>',0
_5df6:		call	panic
		ascii	10,13,'<< *** DIAG:0HDCTC *** >>',0
_5e15:		call	printimm
		ascii	10,13,'<< *** DIAG:0HDNGO *** >>',0
		ld	hl,_52f2
		ld	(hl),000h
		ret	

_5e3a:		call	_5e99
		ascii	10,13,'<< *** DIAG:0HDCIP *** >>',0
_5e59:		call	_5e99
_5e5c:		ascii	10,13,'<< *** DIAG:00HDNRDY *** >>',0
_5e7a:		call	_5e99
		ascii	10,13,'<< *** DIAG:HDHBSY *** >>',0
_5e99:		pop	hl
		ld	(_5f3b),hl
		ld	a,010h
		ld	(00141h),a
		out	(0c1h),a
		call	_5f3f
		out	(0c1h),a
		call	_5f3f
		out	(0c1h),a
		call	_5f3f
		out	(0c1h),a
		call	_5f3f
		ld	a,00eh
		ld	(00141h),a
		out	(0c1h),a
		in	a,(0cfh)
		and	0c2h
		xor	040h
		jp	nz,_5f08
		xor	a
		ld	(_52f2),a
		out	(0cdh),a
		in	a,(0cch)
		inc	a
		out	(0cch),a
		ld	a,001h
		out	(0cbh),a
		ld	a,(00149h)
		out	(0c9h),a
		ld	a,(0014eh)
		out	(0ceh),a
		ld	hl,_5ef3
		ld	(00343h),hl
		ld	a,00ah
		ld	(00346h),a
		ld	a,070h
		ld	(0014fh),a
		out	(0cfh),a
		ei	
		ret	

_5ef3:		ld	a,00eh
		ld	(00141h),a
		out	(0c1h),a
		in	a,(0cfh)
		and	0c2h
		xor	040h
		jp	nz,_5f08
		ld	b,004h
		jp	_609a

_5f08:		ld	hl,(_5f3b)
_5f0b:		ld	a,(hl)
		or	a
		jr	z,_5f15
		call	putc
		inc	hl
		jr	_5f0b

_5f15:		call	panic
		ascii	10,13,'<< *** Z80 Hardware Fault *** >>',0
_5f3b:		nop	
		nop	
		nop	
		nop	
_5f3f:		ld	b,028h
_5f41:		djnz	_5f41
		ret	

_5f44:		push	af
		push	bc
		push	de
		push	hl
		push	ix
		push	iy
		ld	a,(0015eh)
		ld	h,a
		ld	a,(0015fh)
		ld	l,a
		push	hl
		call	_5433
		ei	
		call	_5fb1
		di	
		pop	hl
		ld	a,l
		ld	(0015fh),a
		out	(0dfh),a
		ld	a,h
		ld	(0015eh),a
		out	(0deh),a
		pop	iy
		pop	ix
		pop	hl
		pop	de
		pop	bc
		pop	af
		ei	
		ret	

_5f74:		ld	a,(00347h)
		or	a
		jp	z,_5fb0
		ld	a,(00346h)
		or	a
		jp	z,_5fb0
		ld	ix,(00199h)
		ld	iy,(00334h)
		dec	a
		ld	(00346h),a
		jp	nz,_5fb0
		call	_5e99
		ascii	13,10,'<< *** DIAG:HDETIME ***>>',0
_5fb0:		ret	

_5fb1:		call	_76e8
		ld	ix,(00199h)
		ld	iy,(00334h)
		ld	hl,(00343h)
		call	jphl
		ld	a,00ah
		ld	(00346h),a
		ld	hl,(0033bh)
		ld	a,h
		or	l
		ret	nz
		jr	_5fcf

_5fcf:		di	
		ld	a,(00347h)
		or	a
		jr	z,_5fff
		xor	a
		ld	(00347h),a
		ld	hl,00000h
		ld	(0033bh),hl
		set	5,(ix+14h)
		res	0,(ix+14h)
		ld	ix,(00191h)
		ld	de,00004h
		add	ix,de
		inc	(ix+03h)
		ld	a,(0015eh)
		or	020h
		out	(0deh),a
		and	0dfh
		out	(0deh),a
_5fff:		ei	
		ret	

_6001:		ld	hl,(0033bh)
		ld	a,h
		or	l
		ret	z
		bit	7,h
		jp	nz,_5fcf
		ld	a,(00336h)
		cp	000h
		jp	z,_61ee
		ld	a,00eh
		ld	(00141h),a
		out	(0c1h),a
		call	_64c6
		ld	a,(00336h)
		cp	004h
		jp	z,_607c
		res	4,(ix+13h)
		ld	a,(00339h)
		ld	b,a
		inc	b
		in	a,(0c0h)
		and	0f0h
_6033:		rlca	
		djnz	_6033
		jp	nc,_6042
		set	4,(ix+13h)
		ld	b,010h
		jp	_609a

_6042:		ld	a,0d7h
		out	(0c4h),a
		ld	a,001h
		out	(0c4h),a
		ld	hl,_60cb
		ld	(00343h),hl
		ld	a,00eh
		ld	(00141h),a
		out	(0c1h),a
		ld	a,030h
		ld	(0014fh),a
		out	(0cfh),a
		ld	l,0c8h
		ld	bc,001ffh
		call	_7806
		ld	hl,001ffh
		call	_7862
		di	
		ld	l,0c8h
		ld	bc,00001h
		call	_7806
		ld	hl,001ffh
		call	_7879
		ret	

_607c:		ld	a,0d7h
		out	(0c4h),a
		ld	a,001h
		out	(0c4h),a
		ld	hl,_60cb
		ld	(00343h),hl
		di	
		ld	a,00eh
		ld	(00141h),a
		out	(0c1h),a
		ld	a,020h
		ld	(0014fh),a
		out	(0cfh),a
		ret	

_609a:		call	_63b7
		in	a,(0c9h)
		ld	(ix+1ah),a
		in	a,(0cdh)
		ld	(ix+06h),a
		in	a,(0cch)
		ld	(ix+07h),a
		in	a,(0ceh)
		and	007h
		ld	(ix+09h),a
		in	a,(0cbh)
		ld	(ix+0bh),a
		ld	(ix+17h),b
		set	6,(ix+14h)
		ld	a,b
		cp	001h
		ret	z
		ld	a,0ffh
		ld	(00339h),a
		jp	_5fcf

_60cb:		ld	a,00eh
		ld	(00141h),a
		out	(0c1h),a
		ld	a,(00336h)
		cp	008h
		ld	b,048h
		jr	nz,_60dd
		ld	b,040h
_60dd:		in	a,(0cfh)
		ld	(ix+1bh),a
		xor	b
		and	041h
		jp	z,_60fe
		call	_63b7
		xor	a
		ld	(00338h),a
		ld	a,(00345h)
		dec	a
		ld	(00345h),a
		jp	nz,_6001
		ld	b,002h
		jp	_609a

_60fe:		ld	a,(00336h)
		cp	008h
		jr	nz,_6119
		bit	0,(ix+19h)
		jr	z,_6119
		ld	a,(00338h)
		xor	0ffh
		ld	(00338h),a
		jp	nz,_607c
		call	_63b7
_6119:		ld	a,(00345h)
		cp	003h
		jr	nc,_6125
		ld	b,001h
		call	_609a
_6125:		ld	hl,(0033bh)
		dec	hl
		ld	(0033bh),hl
		ld	a,(00336h)
		cp	000h
		jr	z,_61b0
		cp	004h
		jr	nz,_6169
		push	hl
		ld	l,0c8h
		ld	bc,00200h
		call	_77ab
		pop	hl
		in	a,(0cfh)
		and	0c2h
		xor	040h
		jr	z,_6169
		call	_5e99
		ascii	13,10,'<< *** DIAG:HDREAD *** >>>',0
_6169:		ld	a,h
		or	l
		jr	z,_61b0
		ld	a,004h
		ld	(00345h),a
		ld	hl,00200h
		call	_7862
		ld	a,(0033dh)
		inc	a
		ld	(0033dh),a
		cp	(iy+06h)
		jr	c,_61ad
		xor	a
		ld	(0033dh),a
		ld	a,(00341h)
		inc	a
		ld	(00341h),a
		cp	(iy+08h)
		jr	c,_61ad
		xor	a
		ld	(00341h),a
		ld	hl,(0033fh)
		inc	hl
		ld	(0033fh),hl
		ld	e,(iy+02h)
		ld	d,(iy+03h)
		or	a
		sbc	hl,de
		ld	b,020h
		jp	nc,_609a
_61ad:		call	_6469
_61b0:		jp	_6001

		call	printimm
		ascii	' ',10,13,'<<Busy or Cip at HDRdWrtIntr; status',0
		call	preqhex
		call	printimm
		ascii	'>>',10,13,0
		ld	b,004h
		jp	_609a

_61ee:		ld	a,(0033bh)
		ld	b,a
		cp	00bh
		jp	nc,_620e
		add	a,a
		ld	e,a
		ld	d,000h
		ld	hl,_6204
		add	hl,de
		ld	e,(hl)
		inc	hl
		ld	d,(hl)
		ex	de,hl
		jp	(hl)

_6204:		word	_620e
		word	_631b
		word	_62c4
		word	_6296
		word	_6232
_620e:		call	_53a8
		call	printimm
_6214:		ascii	' << *** DIAG:HDSTAT *** >>',0
		call	_53f7
_6232:		ld	a,00eh
		ld	(00141h),a
		out	(0c1h),a
		call	_63b7
		ld	(ix+13h),000h
		ld	a,(00339h)
		ld	b,a
		inc	b
		in	a,(0c0h)
		and	0f0h
_6249:		rlca	
		djnz	_6249
		jr	nc,_6252
		set	4,(ix+13h)
_6252:		bit	0,(iy+00h)
		jp	nz,_5fcf
		jp	nz,_5fcf
		in	a,(0cfh)
		bit	6,a
		ld	b,004h
		jp	z,_609a
		ld	a,0aah
		out	(0cah),a
		in	a,(0cah)
		cp	0aah
		jp	nz,_609a
		ld	a,001h
		out	(0cah),a
		ld	hl,(0033bh)
		dec	hl
		ld	(0033bh),hl
		ld	a,0d7h
		out	(0c4h),a
		ld	a,001h
		out	(0c4h),a
		in	a,(0cch)
		inc	a
		out	(0cch),a
		ld	hl,_6001
		ld	(00343h),hl
		ld	a,070h
		ld	(0014fh),a
		out	(0cfh),a
		ret	

_6296:		ld	a,00eh
		ld	(00141h),a
		out	(0c1h),a
_629d:		in	a,(0cfh)
		and	011h
		jr	z,_629d
		in	a,(0ceh)
		and	0f8h
		ld	a,a
		ld	(0014eh),a
		out	(0ceh),a
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
		jp	_607c

_62c4:		ld	a,00eh
		ld	(00141h),a
		out	(0c1h),a
		push	iy
		pop	hl
		ld	de,0000ah
		add	hl,de
		push	hl
		ld	bc,048c8h
		inir	
		pop	hl
		call	_63b7
		ld	e,(hl)
		inc	hl
		ld	d,(hl)
		ld	hl,_7017+23
		or	a
		sbc	hl,de
		jp	z,_6310
		ld	(iy+10h),001h
		ld	(iy+11h),000h
		ld	(iy+12h),000h
		ld	(iy+13h),004h
		ld	(iy+14h),000h
		ld	(iy+15h),010h
		ld	(iy+16h),002h
		ld	(iy+17h),000h
		ld	(iy+18h),000h
		ld	(iy+19h),080h
_6310:		ld	a,003h
		ld	a,a
		ld	(0014bh),a
		out	(0cbh),a
		jp	_607c

_631b:		push	iy
		pop	hl
		ld	de,00052h
		add	hl,de
		push	hl
		ld	bc,_68c6+2
		inir	
		pop	hl
		call	_63b7
		ld	e,(hl)
		inc	hl
		ld	d,(hl)
		ld	hl,_6214+26
		or	a
		sbc	hl,de
		jr	z,_6347
		ld	(iy+58h),000h
		ld	(iy+59h),000h
		ld	(iy+56h),000h
		ld	(iy+57h),000h
_6347:		ld	h,(iy+56h)
		ld	l,(iy+57h)
		ld	d,(iy+12h)
		ld	e,(iy+13h)
		call	_78a8
		ld	a,h
		or	l
		sub	001h
		ccf	
		ld	h,(iy+10h)
		ld	l,(iy+11h)
		sbc	hl,bc
		ld	(iy+02h),l
		ld	(iy+03h),h
		ld	(ix+0dh),l
		ld	(ix+0ch),h
		ld	h,(iy+16h)
		ld	l,(iy+17h)
		ld	(ix+0fh),l
		ld	(ix+0eh),h
		ld	(iy+04h),l
		ld	(iy+05h),h
		ld	h,(iy+14h)
		ld	l,(iy+15h)
		ld	(ix+10h),h
		ld	(ix+11h),l
		ld	(iy+06h),l
		ld	(iy+07h),h
		ld	l,(iy+13h)
		ld	(ix+12h),l
		ld	(iy+08h),l
		ld	h,(iy+18h)
		ld	l,(iy+19h)
		srl	h
		rr	l
		srl	h
		rr	l
		ld	a,l
		ld	a,a
		ld	(00149h),a
		out	(0c9h),a
		dec	(iy+00h)
		jp	_5fcf

_63b7:		ld	a,00eh
		ld	(00141h),a
		out	(0c1h),a
		in	a,(0cfh)
		and	002h
		ret	z
		ld	a,010h
		out	(0c1h),a
		call	_5f3f
		ld	a,00eh
		out	(0c1h),a
		ld	a,(0014eh)
		out	(0ceh),a
		ld	a,(00348h)
		ld	(00149h),a
		out	(0c9h),a
		ret	

_63dc:		ld	a,(_52f5)
		or	a
		ret	z
		xor	a
		ld	(_52f5),a
		ld	de,(00191h)
		ld	hl,00002h
		add	hl,de
		ld	a,(hl)
		and	07fh
		cp	05ah
		ret	nz
		ld	(_6468),a
		ld	a,(hl)
		and	080h
		jr	z,_643b
		ld	iy,00349h
		ld	de,000bah
		ld	b,004h
		ld	c,000h
_6406:		ld	a,(iy+00h)
		or	a
		jr	z,_6436
		ld	a,00eh
		out	(0c1h),a
		ld	a,c
		rlca	
		rlca	
		rlca	
		or	020h
		ld	a,a
		ld	(0014eh),a
		out	(0ceh),a
		ld	h,(iy+08h)
		ld	l,(iy+09h)
		dec	hl
		ld	a,l
		out	(0cch),a
		ld	a,h
		out	(0cdh),a
		ld	a,070h
		ld	(0014fh),a
		out	(0cfh),a
_6430:		in	a,(0cfh)
		and	011h
		jr	z,_6430
_6436:		inc	c
		add	iy,de
		djnz	_6406
_643b:		call	printimm
		ascii	'**  ',0
		call	_53b8
		ascii	'Normal System Shutdown',0
		call	printimm
		ascii	'  **',13,10,0
		ret	

_6468:		nop	
_6469:		push	iy
		pop	hl
		ld	de,0005ah
		add	hl,de
		ld	b,(iy+59h)
		ld	a,(00341h)
		ld	c,a
		ld	de,(0033fh)
_647b:		ld	a,b
		or	a
		jr	z,_64ac
		ld	a,(hl)
		inc	hl
		sub	d
		ld	a,(hl)
		inc	hl
		inc	hl
		jr	nz,_648e
		sub	e
		jr	nz,_648e
		ld	a,c
		cp	(hl)
		jr	z,_6492
_648e:		inc	hl
		dec	b
		jr	_647b

_6492:		ld	a,(iy+59h)
		sub	b
		ld	l,a
		ld	h,000h
		ld	d,(iy+12h)
		ld	e,(iy+13h)
		call	_78a8
		ld	a,l
		ld	l,(iy+02h)
		ld	h,(iy+03h)
		add	hl,bc
		ex	de,hl
		ld	c,a
_64ac:		in	a,(0ceh)
		and	0f8h
		or	c
		ld	a,a
		ld	(0014eh),a
		out	(0ceh),a
		ld	a,e
		ld	a,a
		ld	(0014ch),a
		out	(0cch),a
		ld	a,d
		ld	a,a
		ld	(0014dh),a
		out	(0cdh),a
		ret	

_64c6:		ld	a,(00341h)
		ld	hl,(0033fh)
		or	l
		or	h
		ld	a,(0033dh)
		jr	z,_64e0
		ld	c,(iy+06h)
		add	a,a
		cp	c
		jr	c,_64e0
		sub	c
		bit	0,c
		jr	nz,_64e0
		inc	a
_64e0:		inc	a
		ld	a,a
		ld	(0014bh),a
		out	(0cbh),a
		ret	

_64e8:		ld	hl,_6583
		call	_7890
		ld	hl,_663a
		call	_7890
		ld	hl,_664e
		call	_7890
		ld	a,047h
		out	(0f1h),a
		ld	a,0ffh
		out	(0f1h),a
		ld	b,00fh
_6504:		djnz	_6504
		in	a,(0f1h)
		cp	0fch
		sbc	a,a
		ld	(002e4h),a
		jr	nz,_6518
		ld	a,0c7h
		out	(0f1h),a
		ld	a,001h
		out	(0f1h),a
_6518:		in	a,(0fch)
		call	_76e8
		ld	ix,_6e9a
		ld	de,(00191h)
		ld	bc,00004h
		ld	a,00ah
_652a:		ld	l,(ix+02h)
		ld	h,(ix+03h)
		add	hl,de
		ld	(ix+02h),l
		ld	(ix+03h),h
		add	ix,bc
		dec	a
		jr	nz,_652a
		ld	ix,000b4h
		add	ix,de
		ld	(0019dh),ix
		xor	a
		ld	(ix+00h),a
		ld	(ix+01h),a
		ld	(ix+02h),a
		ld	(002e2h),a
		ld	(002e3h),a
		inc	a
		ld	(002e1h),a
		ld	de,00050h
		ld	hl,(00191h)
		add	hl,de
		ex	de,hl
		ld	a,00ah
_6564:		ld	bc,0000ah
		ld	hl,_6579
		ldir	
		dec	a
		jr	nz,_6564
		ld	hl,(_6e9c)
		ld	de,00009h
		add	hl,de
		ld	(hl),007h
		ret	

_6579:		nop	
		nop	
		nop	
		nop	
		djnz	_657f
_657f:		dec	c
		nop	
		nop	
		nop	
_6583:		defb	0f0h,020h
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
		defb	074h,000h
		defb	064h,008h
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
		defb	077h,047h
		defb	067h,047h
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
		defb	0e3h,032h
		defb	0e3h,00fh
		defb	0e3h,007h
		defb	0e0h,000h
		defb	0e0h,008h
		defb	0e0h,000h
		defb	000h
_663a:		defb	0f6h,018h
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
_664e:		defb	0f7h,018h
		defb	0f7h,004h
		defb	0f7h,044h
		defb	0f7h,005h
		defb	0f7h,068h
		defb	0f7h,001h
		defb	0f7h,017h
		defb	0f7h,003h
		defb	0f7h,0c1h
		defb	0f7h,002h
		defb	0f7h,010h
		defb	000h
		nop	
_6666:		push	af
		push	bc
		push	de
		push	hl
		push	ix
		push	iy
		ld	a,(0015fh)
		ld	d,a
		ld	a,(0015eh)
		ld	e,a
		push	de
		call	_76e8
		ld	a,002h
		out	(0f7h),a
		in	a,(0f7h)
		ld	ix,(_6ea4)
		ld	iy,_6de2
		bit	3,a
		jr	z,_6694
		ld	ix,(_6ea0)
		ld	iy,_6dcb
_6694:		ld	c,(iy+07h)
		ld	b,(iy+06h)
		ld	hl,_66b2
		push	hl
		bit	1,a
		jr	z,_66aa
		bit	2,a
		jp	z,_66db
		jp	_6715

_66aa:		bit	2,a
		jp	z,_673f
		jp	_66ca

_66b2:		pop	de
		ld	a,d
		ld	(0015fh),a
		out	(0dfh),a
		ld	a,e
		ld	(0015eh),a
		out	(0deh),a
		pop	iy
		pop	ix
		pop	hl
		pop	de
		pop	bc
		pop	af
		ei	
		reti	

_66ca:		ld	c,(iy+07h)
		in	a,(c)
		and	001h
		ret	z
		dec	c
		dec	c
		in	a,(c)
		call	_6947
		jr	_66ca

_66db:		ld	a,010h
		out	(c),a
		ld	e,000h
		in	a,(c)
		bit	5,a
		jr	z,_66e9
		set	1,e
_66e9:		bit	3,a
		jr	z,_66ef
		set	0,e
_66ef:		bit	4,a
		jr	z,_66f5
		set	2,e
_66f5:		bit	7,a
		jr	z,_6702
		set	5,b
		dec	c
		dec	c
		in	a,(c)
		call	_6947
_6702:		ld	a,e
		cp	(ix+09h)
		ld	(ix+09h),a
		ret	z
		bit	2,(ix+08h)
		ret	z
		set	7,b
		call	_6947
		ret	

_6715:		in	a,(c)
		bit	0,a
		ret	z
		push	bc
		ld	a,001h
		out	(c),a
		in	a,(c)
		and	030h
		jr	z,_6731
		bit	4,a
		jr	z,_672b
		set	4,b
_672b:		bit	5,a
		jr	z,_6731
		set	6,b
_6731:		dec	c
		dec	c
		in	a,(c)
		call	_6947
		pop	bc
		ld	a,030h
		out	(c),a
		jr	_6715

_673f:		ld	a,028h
		out	(c),a
		jp	_6923

_6746:		push	ix
		push	iy
		ld	ix,(_6eac)
		ld	iy,_6e10
		jr	_679a

_6754:		push	ix
		push	iy
		ld	ix,(_6eb0)
		ld	iy,_6e27
		jr	_679a

_6762:		push	ix
		push	iy
		ld	ix,(_6eb4)
		ld	iy,_6e3e
		jr	_679a

_6770:		push	ix
		push	iy
		ld	ix,(_6eb8)
		ld	iy,_6e55
		jr	_679a

_677e:		push	ix
		push	iy
		ld	ix,(_6ebc)
		ld	iy,_6e6c
		jr	_679a

_678c:		push	ix
		push	iy
		ld	ix,(_6ec0)
		ld	iy,_6e83
		jr	_679a

_679a:		push	af
		push	bc
		push	de
		push	hl
		call	_67e7
		ld	a,(0015fh)
		ld	d,a
		ld	a,(0015eh)
		ld	e,a
		push	de
		call	_76e8
_67ad:		ld	c,(iy+07h)
		in	d,(c)
		ld	a,(iy+05h)
		or	a
		ld	a,002h
		jr	z,_67bc
		ld	a,003h
_67bc:		and	d
		jr	z,_67d0
		ld	hl,_67e9
		ld	a,002h
		and	d
		jr	nz,_67ca
		ld	hl,_6822
_67ca:		call	jphl
		jp	_67ad

_67d0:		pop	de
		ld	a,d
		ld	(0015fh),a
		out	(0dfh),a
		ld	a,e
		ld	(0015eh),a
		out	(0deh),a
		pop	hl
		pop	de
		pop	bc
		pop	af
		pop	iy
		pop	ix
		ei	
		ret	

_67e7:		reti	

_67e9:		ld	e,000h
		ld	b,(iy+06h)
		dec	c
		in	e,(c)
		inc	c
		ld	a,038h
		and	d
		jr	z,_680f
		xor	a
		bit	5,d
		jr	z,_67fe
		or	020h
_67fe:		bit	3,d
		jr	z,_6804
		or	010h
_6804:		bit	4,d
		jr	z,_680a
		or	040h
_680a:		or	b
		ld	b,a
		call	_6814
_680f:		ld	a,e
		call	_6947
		ret	

_6814:		push	bc
		ld	b,000h
		ld	hl,00080h
		add	hl,bc
		ld	a,(hl)
		or	010h
		out	(c),a
		pop	bc
		ret	

_6822:		call	_69c9
		ret	z
		ld	b,a
		ld	a,(iy+05h)
		or	a
		jr	z,_6832
		dec	c
		out	(c),b
		inc	c
		ret	

_6832:		ld	a,b
		ld	b,000h
		ld	hl,00080h
		add	hl,bc
		dec	c
		out	(c),a
		ld	b,(hl)
		res	0,b
		ld	(hl),b
		inc	c
		out	(c),b
		ret	

_6844:		ld	e,a
		bit	7,a
		jr	z,_685d
		sub	0a1h
		cp	006h
		ld	hl,_688e
		jr	c,_6870
		sub	01eh
		cp	002h
		ld	hl,_6894
		jr	c,_6870
		jr	_6875

_685d:		or	a
		jr	z,_687b
		sub	01ch
		cp	004h
		jr	nc,_6875
		push	af
		ld	a,01bh
		call	_6947
		pop	af
		ld	hl,_688a
_6870:		ld	e,a
		ld	d,000h
		add	hl,de
		ld	e,(hl)
_6875:		xor	a
		ld	(_6889),a
		ld	a,e
		ret	

_687b:		ld	a,(_6889)
		cpl	
		ld	(_6889),a
		or	a
		ld	a,011h
		ret	z
		ld	a,013h
		ret	

_6889:		nop	
_688a:		ld	b,h
		ld	b,e
		ld	b,c
		ld	b,d
_688e:		ld	a,h
		ld	h,b
		dec	e
		ld	e,01fh
		inc	e
_6894:		ld	e,h
		nop	
_6896:		push	af
		push	bc
		push	de
		push	hl
		push	ix
		push	iy
		ld	a,(0015fh)
		ld	d,a
		ld	a,(0015eh)
		ld	e,a
		push	de
		call	_76e8
		in	a,(0ffh)
		and	080h
		jr	z,_68be
		in	a,(0fch)
		ld	ix,(_6e9c)
		ld	b,000h
		call	_6844
		call	_6947
_68be:		pop	de
		ld	a,d
		ld	(0015fh),a
		out	(0dfh),a
		ld	a,e
_68c6:		ld	(0015eh),a
		out	(0deh),a
		pop	iy
		pop	ix
		pop	hl
		pop	de
		pop	bc
		pop	af
		ei	
		reti	

_68d6:		push	af
		push	bc
		push	de
		push	hl
		push	ix
		push	iy
		ld	a,(0015fh)
		ld	d,a
		ld	a,(0015eh)
		ld	e,a
		push	de
		call	_76e8
		ld	a,003h
		out	(0e3h),a
		ld	ix,(_6ea8)
		ld	iy,_6df9
		call	_6911
		pop	de
		ld	a,d
		ld	(0015fh),a
		out	(0dfh),a
		ld	a,e
		ld	(0015eh),a
		out	(0deh),a
		pop	iy
		pop	ix
		pop	hl
		pop	de
		pop	bc
		pop	af
		ei	
		reti	

_6911:		in	a,(0e0h)
		and	0e0h
		ret	nz
		call	_69c9
		ret	z
		push	af
		ld	a,083h
		out	(0e3h),a
		pop	af
		out	(0e1h),a
		ret	

_6923:		ld	c,(iy+07h)
		ld	b,(iy+06h)
		in	a,(c)
		and	004h
		ret	z
		call	_69c9
		ret	z
		dec	c
		dec	c
		out	(c),a
		ret	

		ld	c,(iy+07h)
		ld	b,000h
		ld	hl,00080h
		add	hl,bc
		ld	a,(hl)
		set	0,a
		ld	(hl),a
		out	(c),a
		ret	

_6947:		bit	0,(ix+07h)
		ret	nz
		push	bc
		push	de
		push	hl
		push	ix
		ld	ix,(0019dh)
		ld	c,a
		ld	a,(ix+00h)
		sub	(ix+01h)
		cp	0ffh
		jr	z,_69be
		cp	063h
		jr	z,_69be
		ld	a,(002e2h)
		or	b
		ld	b,a
		ld	a,000h
		ld	(002e2h),a
		ld	a,(002e3h)
		inc	a
		jr	z,_6977
		ld	(002e3h),a
_6977:		ld	h,000h
		ld	l,(ix+00h)
		add	hl,hl
		ld	de,00004h
		add	hl,de
		push	ix
		pop	de
		add	hl,de
		ld	(hl),b
		inc	hl
		ld	(hl),c
		ld	a,(ix+00h)
		inc	a
		cp	064h
		jr	nz,_6992
		ld	a,000h
_6992:		ld	(ix+00h),a
		sub	(ix+01h)
		jr	c,_699c
		add	a,064h
_699c:		ld	hl,002e1h
		cp	(hl)
		jr	nc,_69a9
		ld	a,c
		and	07fh
		cp	013h
		jr	nz,_69c3
_69a9:		bit	4,(ix+02h)
		jr	nz,_69c3
		bit	2,(ix+02h)
		jr	z,_69c3
		set	4,(ix+02h)
		call	_6d9c
		jr	_69c3

_69be:		ld	a,040h
		ld	(002e2h),a
_69c3:		pop	ix
		pop	hl
		pop	de
		pop	bc
		ret	

_69c9:		bit	0,(ix+04h)
		ret	z
		bit	0,(iy+00h)
		ret	z
		bit	1,(ix+07h)
		jr	z,_69ec
		ld	a,(iy+05h)
		or	a
		jr	z,_69ec
		dec	a
		sub	(ix+05h)
		neg	
		ld	(ix+05h),a
		ld	(iy+05h),001h
_69ec:		ld	a,(iy+05h)
		or	a
		jr	z,_6a07
		ld	l,(iy+0eh)
		ld	h,(iy+0fh)
		ld	a,(hl)
		inc	hl
		ld	(iy+0eh),l
		ld	(iy+0fh),h
		dec	(iy+05h)
		ret	nz
		ld	l,000h
		inc	l
_6a07:		push	af
		set	4,(ix+04h)
		res	0,(ix+04h)
		ld	(iy+00h),000h
		bit	2,(ix+04h)
		call	nz,_6d9c
		pop	af
		ret	

_6a1d:		call	_76e8
		ld	ix,(0019dh)
		ld	a,(002e3h)
		cp	032h
		ld	b,020h
		jr	nc,_6a35
		cp	010h
		ld	b,010h
		jr	nc,_6a35
		ld	b,001h
_6a35:		ld	a,b
		ld	(002e1h),a
		xor	a
		ld	(002e3h),a
		bit	4,(ix+02h)
		jr	nz,_6a4e
		set	4,(ix+02h)
		bit	2,(ix+02h)
		call	nz,_6d9c
_6a4e:		ret	

_6a4f:		call	_76e8
		ld	ix,_6e9a
		ld	b,00ah
_6a58:		ld	e,(ix+00h)
		ld	d,(ix+01h)
		push	de
		pop	iy
		ld	e,(ix+02h)
		ld	d,(ix+03h)
		push	de
		ex	(sp),ix
		ld	l,(iy+14h)
		ld	h,(iy+15h)
		call	jphl
		call	_6a80
		pop	ix
		ld	de,00004h
		add	ix,de
		djnz	_6a58
		ret	

_6a80:		push	bc
		push	de
		push	hl
		ld	l,(iy+08h)
		ld	h,(iy+09h)
		ld	a,(hl)
		or	a
		jp	z,_6b0a
		ld	a,(iy+00h)
		or	a
		jp	nz,_6acb
		bit	0,(ix+04h)
		jp	z,_6ae3
		di	
		dec	(iy+00h)
		dec	(hl)
		ld	a,(ix+05h)
		cp	020h
		jr	c,_6aaa
		ld	a,01fh
_6aaa:		ld	(iy+05h),a
		ld	l,(iy+10h)
		ld	(iy+0eh),l
		ld	h,(iy+11h)
		ld	(iy+0fh),h
		ld	c,a
		ld	b,000h
		call	_775c
		ld	l,(iy+12h)
		ld	h,(iy+13h)
		call	jphl
		ei	
		jr	_6b0a

_6acb:		nop	
		call	printimm
		ascii	'<<  *** DIAG:SBSY',0
		jr	_6af9

_6ae3:		dec	(hl)
		call	printimm
		ascii	'<<  *** DIAG:SNGO',0
_6af9:		ld	a,(iy+06h)
		call	preqhex
		call	printimm
		ascii	' *** >>',0
_6b0a:		pop	hl
		pop	de
		pop	bc
		ret	

		push	bc
		push	de
		push	hl
		ld	l,(iy+0ch)
		ld	h,(iy+0dh)
		ld	a,(hl)
		or	a
		jp	z,_6be0
		ld	a,(iy+00h)
		or	a
		jp	nz,_6be0
		dec	(hl)
		ld	e,(ix+07h)
		ld	d,(ix+08h)
		ld	l,(ix+06h)
		ld	a,(iy+01h)
		cp	e
		jr	nz,_6b40
		ld	a,(iy+02h)
		cp	d
		jr	nz,_6b40
		ld	a,(iy+04h)
		cp	l
		jp	z,_6c17
_6b40:		ld	(iy+01h),e
		ld	(iy+02h),d
		ld	a,0c1h
		ld	h,068h
		bit	5,e
		jr	z,_6b52
		ld	a,041h
		ld	h,028h
_6b52:		ld	b,a
		ld	a,h
		bit	0,d
		jr	z,_6b5a
		or	002h
_6b5a:		bit	1,d
		jr	z,_6b60
		or	080h
_6b60:		bit	4,e
		jr	z,_6b66
		or	010h
_6b66:		ld	h,a
		ld	a,l
		push	hl
		push	bc
		cp	010h
		jr	nc,_6b73
		call	_6c24
		jr	nz,_6b86
_6b73:		ld	a,(iy+04h)
		ld	(ix+06h),a
		call	_6c24
		jr	nz,_6b86
		ld	a,00dh
		ld	(ix+06h),a
		call	_6c24
_6b86:		ld	(_6c1c),a
		inc	hl
		ld	a,(hl)
		pop	bc
		pop	hl
		bit	5,e
		jr	z,_6b93
		or	001h
_6b93:		bit	6,e
		jr	nz,_6b99
		or	002h
_6b99:		or	004h
		bit	7,e
		jr	z,_6ba1
		or	00ch
_6ba1:		ld	e,a
		ld	d,b
		di	
		ld	c,(iy+07h)
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
		cp	(iy+04h)
		jr	z,_6bdf
		ld	a,(_6c1c)
		ld	b,a
		ld	a,(iy+06h)
		cp	002h
		jr	z,_6bda
		ld	c,0f0h
		call	_6c1d
		ld	c,0f1h
		ld	a,(002e4h)
		or	a
		call	nz,_6c1d
		jr	_6bdf

_6bda:		ld	c,0f2h
		call	_6c1d
_6bdf:		ei	
_6be0:		ld	c,(iy+07h)
		ld	a,(iy+03h)
		and	0f8h
		in	e,(c)
		bit	5,e
		jr	z,_6bf0
		or	002h
_6bf0:		bit	3,e
		jr	z,_6bf6
		or	001h
_6bf6:		bit	4,e
		jr	z,_6bfc
		or	004h
_6bfc:		di	
		cp	(iy+03h)
		jr	z,_6c17
		ld	(ix+09h),a
		ld	(iy+03h),a
		bit	2,(ix+08h)
		jr	z,_6c17
		ld	b,(iy+06h)
		set	7,b
		xor	a
		call	_6947
_6c17:		ei	
		pop	hl
		pop	de
		pop	bc
		ret	

_6c1c:		nop	
_6c1d:		ld	a,047h
		out	(c),a
		out	(c),b
		ret	

_6c24:		push	bc
		add	a,a
		ld	c,a
		ld	b,000h
		ld	hl,_6c31
		add	hl,bc
		ld	a,(hl)
		or	a
		pop	bc
		ret	

_6c31:		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		nop	
		ret	nc
		add	a,b
		ret	nc
		ld	b,b
		ld	l,b
		ld	b,b
		ld	b,l
		ld	b,b
		inc	(hl)
		ld	b,b
		ld	a,(de)
		ld	b,b
		dec	c
		ld	b,b
		nop	
		nop	
		nop	
		nop	
		push	bc
		push	de
		push	hl
		ld	l,(iy+0ch)
		ld	h,(iy+0dh)
		ld	a,(hl)
		or	a
		jp	z,_6ce3
		ld	a,(iy+00h)
		or	a
		jp	nz,_6ce3
		dec	(hl)
		ld	b,(ix+06h)
		ld	c,(ix+08h)
		ld	e,(ix+07h)
		ld	a,(iy+04h)
		cp	b
		jr	nz,_6c83
		ld	a,(iy+02h)
		cp	c
		jr	nz,_6c83
		ld	a,(iy+01h)
		cp	e
		jp	z,_6ce3
_6c83:		ld	a,00eh
		bit	5,e
		jr	z,_6c91
		ld	a,01ah
		bit	6,e
		jr	nz,_6c91
		or	020h
_6c91:		or	040h
		bit	7,e
		jr	z,_6c99
		or	0c0h
_6c99:		ld	l,a
		ld	a,015h
		bit	4,e
		jr	z,_6ca2
		or	008h
_6ca2:		bit	0,c
		jr	z,_6ca8
		or	020h
_6ca8:		bit	1,c
		jr	z,_6cae
		or	002h
_6cae:		ld	h,a
		ld	(iy+02h),c
		ld	(iy+01h),e
		ex	de,hl
		ld	c,(iy+07h)
		di	
		ld	a,040h
		out	(c),a
		nop	
		nop	
		out	(c),e
		nop	
		nop	
		out	(c),d
		res	0,d
		dec	c
		xor	a
		out	(c),a
		inc	c
		out	(c),d
		ld	a,d
		ld	e,c
		ld	d,000h
		ld	hl,00080h
		add	hl,de
		ld	(hl),a
		ld	a,b
		cp	(iy+04h)
		ld	(iy+04h),a
		call	nz,_6d15
		ei	
_6ce3:		ld	c,(iy+07h)
		in	e,(c)
		ld	a,(iy+03h)
		and	0f8h
		or	003h
		bit	7,e
		jr	z,_6cf5
		or	004h
_6cf5:		cp	(iy+03h)
		jr	z,_6d11
		ld	(ix+09h),a
		ld	(iy+03h),a
		bit	2,(ix+08h)
		jr	z,_6d11
		di	
		ld	b,(iy+06h)
		set	7,b
		xor	a
		call	_6947
		ei	
_6d11:		pop	hl
		pop	de
		pop	bc
		ret	

_6d15:		ld	c,(iy+06h)
		ld	a,(iy+04h)
		cp	011h
		ret	nc
		add	a,a
		ld	e,a
		ld	d,000h
		ld	hl,_6d48
		add	hl,de
		ld	e,(hl)
		inc	hl
		ld	d,(hl)
		ld	a,d
		or	e
		ret	z
		ld	a,c
		cp	00ah
		ret	nc
		sub	004h
		ld	c,a
		add	a,a
		add	a,c
		ld	c,a
		ld	b,000h
		ld	hl,_6d68
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

_6d48:		word	00000h
		word	009c4h
		word	00683h
		word	00470h
		word	00000h
		word	00341h
		word	00000h
		word	001a1h
		word	000d0h
		word	00068h
		word	00000h
		word	00034h
		word	0001ah
		word	0000dh
		word	00000h
		word	00000h
_6d68:		defb	073h,036h,070h
		defb	073h,076h,071h
		defb	073h,0b6h,072h
		defb	063h,036h,060h
		defb	063h,076h,061h
		defb	063h,0b6h,062h
		defb	03ah,0b9h,06dh
		defb	0b7h,0c8h,0cdh
		defb	0c9h,069h,0c4h
		defb	080h,070h,0c9h
_6d86:		ld	iy,_6df9
		ld	a,(iy+00h)
		or	a
		ret	z
		call	_76e8
		ld	ix,(_6ea8)
		di	
		call	_6911
		ei	
		ret	

_6d9c:		ld	ix,(00191h)
		ld	de,00004h
		add	ix,de
		inc	(ix+00h)
_6da8:		ld	a,(0015eh)
		or	040h
		out	(0deh),a
		and	0bfh
		out	(0deh),a
		ret	

_6db4:		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
_6db9:		defb	000h			
		defb	000h			
		defb	000h			
		defb	0f6h			
		defb	052h			
		defb	000h			
		defb	053h			
		defb	00ah			
		defb	053h			
		defb	000h			
		defb	000h			
		defb	0c1h			
		defb	002h			
		defb	07ah			
		defb	06dh			
		defb	011h			
		defb	054h			
		defb	000h			
_6dcb:		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	001h			
		defb	0f6h			
		defb	0f7h			
		defb	052h			
		defb	001h			
		defb	053h			
		defb	00bh			
		defb	053h			
		defb	000h			
		defb	000h			
		defb	0a1h			
		defb	001h			
		defb	023h			
		defb	069h			
		defb	00eh			
		defb	06bh			
		defb	000h			
_6de2:		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	002h			
		defb	0f7h			
		defb	0f8h			
		defb	052h			
		defb	002h			
		defb	053h			
		defb	00ch			
		defb	053h			
		defb	000h			
		defb	000h			
		defb	0c1h			
		defb	001h			
		defb	023h			
		defb	069h			
		defb	00eh			
		defb	06bh			
		defb	000h			
_6df9:		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	003h			
		defb	000h			
		defb	0f9h			
		defb	052h			
		defb	003h			
		defb	053h			
		defb	00dh			
		defb	053h			
		defb	000h			
		defb	000h			
		defb	0a1h			
		defb	002h			
		defb	011h			
		defb	069h			
		defb	011h			
		defb	054h			
		defb	000h			
_6e10:		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	004h			
		defb	079h			
		defb	0fah			
		defb	052h			
		defb	004h			
		defb	053h			
		defb	00eh			
		defb	053h			
		defb	000h			
		defb	000h			
		defb	0e1h			
		defb	001h			
		defb	037h			
		defb	069h			
		defb	051h			
		defb	06ch			
		defb	000h			
_6e27:		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	005h			
		defb	07bh			
		defb	0fbh			
		defb	052h			
		defb	005h			
		defb	053h			
		defb	00fh			
		defb	053h			
		defb	000h			
		defb	000h			
		defb	001h			
		defb	002h			
		defb	037h			
		defb	069h			
		defb	051h			
		defb	06ch			
		defb	000h			
_6e3e:		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	006h			
		defb	07dh			
		defb	0fch			
		defb	052h			
		defb	006h			
		defb	053h			
		defb	010h			
		defb	053h			
		defb	000h			
		defb	000h			
		defb	021h			
		defb	002h			
		defb	037h			
		defb	069h			
		defb	051h			
		defb	06ch			
		defb	000h			
_6e55:		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	007h			
		defb	069h			
		defb	0fdh			
		defb	052h			
		defb	007h			
		defb	053h			
		defb	011h			
		defb	053h			
		defb	000h			
		defb	000h			
		defb	041h			
		defb	002h			
		defb	037h			
		defb	069h			
		defb	051h			
		defb	06ch			
		defb	000h			
_6e6c:		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	008h			
		defb	06bh			
		defb	0feh			
		defb	052h			
		defb	008h			
		defb	053h			
		defb	012h			
		defb	053h			
		defb	000h			
		defb	000h			
		defb	061h			
		defb	002h			
		defb	037h			
		defb	069h			
		defb	051h			
		defb	06ch			
		defb	000h			
_6e83:		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	009h			
		defb	06dh			
		defb	0ffh			
		defb	052h			
		defb	009h			
		defb	053h			
		defb	013h			
		defb	053h			
		defb	000h			
		defb	000h			
		defb	081h			
		defb	002h			
		defb	037h			
		defb	069h			
		defb	051h			
		defb	06ch			
		defb	000h			
_6e9a:		defb	0b4h			
		defb	06dh			
_6e9c:		defb	050h			
		defb	000h			
		defb	0cbh			
		defb	06dh			
_6ea0:		defb	05ah			
		defb	000h			
		defb	0e2h			
		defb	06dh			
_6ea4:		defb	064h			
		defb	000h			
		defb	0f9h			
		defb	06dh			
_6ea8:		defb	06eh			
		defb	000h			
		defb	010h			
		defb	06eh			
_6eac:		defb	078h			
		defb	000h			
		defb	027h			
		defb	06eh			
_6eb0:		defb	082h			
		defb	000h			
		defb	03eh			
		defb	06eh			
_6eb4:		defb	08ch			
		defb	000h			
		defb	055h			
		defb	06eh			
_6eb8:		defb	096h			
		defb	000h			
		defb	06ch			
		defb	06eh			
_6ebc:		defb	0a0h			
		defb	000h			
		defb	083h			
		defb	06eh			
_6ec0:		defb	0aah			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
_6eea:		ld	a,(_6db9)
		or	a
		ret	z
		ld	a,(017c1h)
		or	a
		ret	nz
		dec	a
		ld	(017c1h),a
		call	_76e8
		ld	ix,(_6e9c)
		ld	iy,_6db4
		ld	b,005h
		ld	a,(_6db9)
		cp	00fh
		jr	c,_6f14
		ld	b,005h
		cp	019h
		jr	c,_6f14
		ld	b,00ah
_6f14:		push	bc
		di	
		call	_69c9
		ei	
		pop	bc
		jr	z,_6f22
		call	putc
		djnz	_6f14
_6f22:		xor	a
		ld	(017c1h),a
		ret	

_6f27:		ld	de,(00191h)
		ld	hl,00040h
		add	hl,de
		ld	(0019fh),hl
		ld	hl,00004h
		add	hl,de
		ld	(00195h),hl
		ret	

_6f3a:		ld	a,(_52f4)
		or	a
		ret	z
		ld	a,(017c1h)
		or	a
		ret	nz
		dec	a
		ld	(017c1h),a
		call	_76e8
		ld	ix,(0019fh)
		ld	iy,(00195h)
		ld	bc,00000h
		bit	0,(ix+0ch)
		jp	z,_6fd2
		ld	b,001h
		ld	c,040h
		ld	a,(ix+0ch)
		ld	(_7079),a
		add	a,(ix+0dh)
		inc	a
		jp	nz,_7032
		ld	a,(_7079)
		and	00ch
		cp	00ch
		jp	z,_6fcc
		cp	004h
		jp	z,_6fef
		or	a
		jp	z,_6fcc
		call	_704f
		ld	b,002h
		ld	de,(_707c)
		ld	a,d
		or	e
		jp	z,_6fef
		ld	hl,(_707a)
		add	hl,de
		ex	de,hl
		ld	hl,00780h
		or	a
		sbc	hl,de
		jp	c,_6fef
_6f9d:		ld	hl,(_707e)
		ld	de,(_707c)
		ld	a,d
		or	e
		jr	z,_6fcc
		add	hl,de
		jr	nc,_6fc2
		ld	(_707c),hl
		ex	de,hl
		or	a
		sbc	hl,de
		ld	b,h
		ld	c,l
		ld	hl,(_707e)
		call	_7005
		ld	hl,0f800h
		ld	(_707e),hl
		jr	_6f9d

_6fc2:		ld	hl,(_707e)
		ld	bc,(_707c)
		call	_7005
_6fcc:		ld	bc,00000h
		xor	a
		jr	_6fef

_6fd2:		call	printimm
		ascii	'<< *** DIAG:0SRNGO *** >>',0
_6fef:		xor	a
		ld	(_52f4),a
		ld	(017c1h),a
		ld	(ix+0fh),b
		ld	(ix+0ch),c
		inc	(iy+01h)
		di	
		call	_6da8
		ei	
		ret	

_7005:		ld	a,h
		and	0f0h
		cp	0f0h
		jr	nz,_7014
		push	bc
		call	_775c
		pop	hl
		jp	_7862

_7014:		call	panic
_7017:		ascii	'<< *** DIAG:SRBADDR *** >>',0
_7032:		call	panic
		ascii	'<< *** DIAG:SRXCSR *** >>',0
_704f:		ld	hl,(00070h)
		ld	a,h
		or	0f8h
		ld	h,a
		ld	d,(ix+0ah)
		ld	e,(ix+0bh)
		ld	(_707a),de
		add	hl,de
		jr	nc,_706b
		ld	de,0f800h
		add	hl,de
		ld	a,h
		or	0f8h
		ld	h,a
_706b:		ld	(_707e),hl
		ld	d,(ix+06h)
		ld	e,(ix+07h)
		ld	(_707c),de
		ret	

_7079:		defb	000h			
_707a:		defb	000h			
		defb	000h			
_707c:		defb	000h			
		defb	000h			
_707e:		defb	000h			
		defb	000h			
putc:		push	af
		push	bc
		push	de
		push	hl
		ld	hl,_7098
		bit	0,(hl)
		ld	(hl),000h
		call	nz,_74dd
		and	07fh
		ld	hl,(00074h)
		push	hl
		ld	hl,(00072h)
		ret	

_7098:		defb	0ffh
_7099:		pop	hl
		pop	de
		pop	bc
		pop	af
		ret	

_709e:		cp	020h
		jp	nc,_7108
		cp	00dh
		jr	z,_70cc
		cp	00ah
		jr	z,_70d1
		cp	008h
		jr	z,_70d5
		cp	009h
		jr	z,_70de
		cp	00ch
		jp	z,_7190
		cp	007h
		jr	z,_70e6
		cp	01bh
		jr	nz,_70c9
		ld	hl,_71a6
		ld	(00074h),hl
		jp	_7099

_70c9:		jp	_7099

_70cc:		ld	l,000h
		jp	_712b

_70d1:		inc	h
		jp	_712b

_70d5:		ld	a,l
		or	a
		jp	z,_712b
		dec	l
		jp	_712b

_70de:		ld	a,l
		or	007h
		inc	a
		ld	l,a
		jp	_712b

_70e6:		ld	a,(00120h)
		and	001h
		jr	nz,_712b
		ld	a,001h
		ld	(00120h),a
		out	(0a0h),a
		ld	a,008h
		push	hl
		ld	hl,_7100
		call	_765c
		pop	hl
		jr	_712b

_7100:		ld	a,000h
		ld	(00120h),a
		out	(0a0h),a
		ret	

_7108:		push	hl
		ld	b,a
		call	_74ab
		ld	a,(00076h)
		bit	1,a
		jr	z,_711d
		ld	a,b
		sub	05eh
		jr	c,_711d
		dec	a
		and	07fh
		ld	b,a
_711d:		ld	a,(00076h)
		bit	2,a
		jr	z,_7126
		set	7,b
_7126:		ld	(hl),b
		pop	hl
		inc	l
		jr	_712b

_712b:		ld	de,_709e
		ld	(00074h),de
		ld	a,l
		cp	050h
		jr	c,_713a
		ld	l,000h
		inc	h
_713a:		ld	a,h
		cp	018h
		jr	c,_7156
		ld	h,017h
		push	hl
		ld	hl,(00070h)
		ld	de,00050h
		add	hl,de
		call	_74c2
		ld	hl,01700h
		ld	bc,00050h
		call	_7173
		pop	hl
_7156:		call	_715c
		jp	_7099

_715c:		push	hl
		ld	(00072h),hl
		call	_7497
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

_7173:		push	de
		push	hl
		call	_74ab
		ld	d,020h
_717a:		ld	(hl),d
		inc	l
		jp	nz,_7185
		inc	h
		jp	nz,_7185
		ld	h,0f8h
_7185:		dec	c
		jp	nz,_717a
		dec	b
		jp	p,_717a
		pop	hl
		pop	de
		ret	

_7190:		ld	hl,0f800h
		ld	de,0f801h
		ld	bc,0077fh
		ld	(hl),020h
		ldir	
		ld	hl,00000h
		call	_74c2
		jp	_712b

_71a6:		sub	041h
		cp	01bh
		jp	nc,_712b
		push	hl
		ld	hl,_71bc
		add	a,a
		ld	c,a
		ld	b,000h
		add	hl,bc
		ld	a,(hl)
		inc	hl
		ld	h,(hl)
		ld	l,a
		ex	(sp),hl
		ret	

_71bc:		word	_7205
		word	_720e
		word	_71fb
		word	_71f2
		word	_7190
		word	_712b
		word	_712b
		word	_7218
		word	_712b
		word	_7245
		word	_7239
		word	_7291
		word	_72b5
		word	_712b
		word	_712b
		word	_7261
		word	_727a
		word	_7227
		word	_712b
		word	_712b
		word	_712b
		word	_712b
		word	_712b
		word	_712b
		word	_721e
		word	_712b
		word	_7230
_71f2:		ld	a,l
		or	a
		jp	z,_712b
		dec	l
		jp	_712b

_71fb:		ld	a,l
		cp	04fh
		jp	z,_712b
		inc	l
		jp	_712b

_7205:		ld	a,h
		or	a
		jp	z,_712b
		dec	h
		jp	_712b

_720e:		ld	a,h
		cp	017h
		jp	z,_712b
		inc	h
		jp	_712b

_7218:		ld	hl,00000h
		jp	_712b

_721e:		ld	hl,_72db
		ld	(00074h),hl
		jp	_7099

_7227:		ld	hl,_72fe
		ld	(00074h),hl
		jp	_7099

_7230:		ld	hl,_7354
		ld	(00074h),hl
		jp	_7099

_7239:		ld	a,050h
		sub	l
		ld	c,a
		ld	b,000h
		call	_7173
		jp	_712b

_7245:		ld	a,l
		or	h
		jp	z,_7190
		ld	a,050h
		sub	l
		ld	e,a
		ld	d,000h
		ld	a,017h
		sub	h
		push	hl
		call	line_offset
		add	hl,de
		ld	b,h
		ld	c,l
		pop	hl
		call	_7173
		jp	_712b

_7261:		push	hl
		ld	a,04fh
		sub	l
		ld	c,a
		ld	b,000h
		ld	l,04fh
		call	_74ab
		ld	d,h
		ld	e,l
		dec	hl
		call	_745d
		inc	hl
		ld	(hl),020h
		pop	hl
		jp	_712b

_727a:		push	hl
		ld	a,04fh
		sub	l
		ld	c,a
		ld	b,000h
		call	_74ab
		ld	d,h
		ld	e,l
		inc	hl
		call	_7427
		dec	hl
		ld	(hl),020h
		pop	hl
		jp	_712b

_7291:		push	hl
		ld	a,017h
		sub	h
		call	line_offset
		ld	b,h
		ld	c,l
		ld	hl,0174fh
		call	_74ab
		ld	d,h
		ld	e,l
		ld	hl,0ffb0h
		add	hl,de
		call	_745d
		pop	hl
		ld	l,000h
		ld	bc,00050h
		call	_7173
		jp	_712b

_72b5:		push	hl
		ld	a,017h
		sub	h
		push	hl
		call	line_offset
		ld	b,h
		ld	c,l
		pop	hl
		ld	l,000h
		call	_74ab
		ld	d,h
		ld	e,l
		ld	hl,00050h
		add	hl,de
		call	_7427
		ld	hl,01700h
		ld	bc,00050h
		call	_7173
		pop	hl
		jp	_712b

_72db:		sub	020h
		cp	018h
		jp	nc,_712b
		ld	h,a
		ld	(00072h),hl
		ld	de,_72f0
		ld	(00074h),de
		jp	_7099

_72f0:		sub	020h
		cp	050h
		jp	nc,_712b
		ld	l,a
		ld	(00072h),hl
		jp	_712b

_72fe:		push	hl
		ld	hl,00076h
		cp	040h
		jr	z,_731e
		cp	044h
		jr	z,_7322
		cp	043h
		jr	z,_7326
		cp	063h
		jr	z,_7334
		cp	047h
		jr	z,_7346
		cp	067h
		jr	z,_734a
_731a:		pop	hl
		jp	_712b

_731e:		res	2,(hl)
		jr	_731a

_7322:		set	2,(hl)
		jr	_731a

_7326:		ld	a,(_7353)
		ld	(_7350+1),a
		ld	hl,_734e
		call	_7890
		jr	_731a

_7334:		ld	a,(_7353)
		and	01fh
		or	020h
		ld	(_7350+1),a
		ld	hl,_734e
		call	_7890
		jr	_731a

_7346:		set	1,(hl)
		jr	_731a

_734a:		res	1,(hl)
		jr	_731a

_734e:		defb	0fch,00ah
_7350:		defb	0fdh,069h
		defb	000h
_7353:		ld	l,c
_7354:		cp	03fh
		jr	nz,_7361
		ld	hl,_736d
		ld	(00074h),hl
		jp	_7099

_7361:		ld	(_73d0),a
		ld	hl,_73c2
		ld	(00074h),hl
		jp	_7099

_736d:		cp	033h
		jp	nz,_712b
		ld	hl,_737b
		ld	(00074h),hl
		jp	_7099

_737b:		cp	033h
		jp	nz,_712b
		ld	hl,_7389
		ld	(00074h),hl
		jp	_7099

_7389:		cp	068h
		jr	z,_7394
		cp	06ch
		jr	z,_73ac
		jp	_712b

_7394:		ld	a,(_7353)
		and	01fh
		or	060h
		ld	(_7353),a
		ld	(_7350+1),a
		push	hl
		ld	hl,_734e
		call	_7890
		pop	hl
		jp	_712b

_73ac:		ld	a,(_7353)
		and	01fh
		ld	(_7353),a
		ld	(_7350+1),a
		push	hl
		ld	hl,_734e
		call	_7890
		pop	hl
		jp	_712b

_73c2:		cp	020h
		jp	nz,_712b
		ld	hl,_73d1
		ld	(00074h),hl
		jp	_7099

_73d0:		ld	e,a
_73d1:		cp	071h
		jp	nz,_712b
		ld	a,(_73d0)
		cp	05fh
		jr	z,_73e4
		cp	07fh
		jr	z,_7401
		jp	_712b

_73e4:		ld	a,(_7353)
		and	060h
		or	009h
		ld	(_7353),a
		ld	(_7420+1),a
		ld	a,009h
		ld	(_7424+1),a
		push	hl
		ld	hl,_741e
		call	_7890
		pop	hl
		jp	_712b

_7401:		ld	a,(_7353)
		and	060h
		or	001h
		ld	(_7353),a
		ld	(_7420+1),a
		ld	a,008h
		ld	(_7424+1),a
		push	hl
		ld	hl,_741e
		call	_7890
		pop	hl
		jp	_712b

_741e:		defb	0fch,00ah
_7420:		defb	0fdh,009h
		defb	0fch,00bh
_7424:		defb	0fdh,009h
		defb	000h
_7427:		ld	a,b
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
		jr	nc,_7441
		xor	a
		sub	l
		ld	c,a
		ld	a,000h
		sbc	a,h
		ld	b,a
_7441:		ex	de,hl
		push	hl
		add	hl,bc
		pop	hl
		jr	nc,_744e
		xor	a
		sub	l
		ld	c,a
		ld	a,000h
		sbc	a,h
		ld	b,a
_744e:		pop	hl
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
		jr	_7427

_745d:		ld	a,b
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
		jr	nc,_747e
		ld	b,h
		ld	c,l
_747e:		ex	de,hl
		push	hl
		or	a
		sbc	hl,bc
		pop	hl
		jr	nc,_7488
		ld	b,h
		ld	c,l
_7488:		pop	hl
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
		jr	_745d

_7497:		push	bc
		ld	a,h
		ld	c,l
		ld	b,000h
		call	line_offset
		add	hl,bc
		ld	bc,(00070h)
		add	hl,bc
		ld	a,h
		and	03fh
		ld	h,a
		pop	bc
		ret	

_74ab:		call	_7497
		ld	a,h
		or	0f8h
		ld	h,a
		ret	

; Return HL = A * 80 (i.e., offset to line A of video display).
line_offset:	push	de
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

_74c2:		ld	a,i
		push	af
		di	
		ld	(00070h),hl
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

_74dd:		push	af
		ld	hl,00000h
		ld	(00070h),hl
		ld	(00072h),hl
		ld	hl,_709e
		ld	(00074h),hl
		ld	a,000h
		ld	(00120h),a
		out	(0a0h),a
		xor	a
		ld	(00076h),a
		ld	hl,_750f
		ld	b,010h
_74fd:		ld	a,010h
		sub	b
		out	(0fch),a
		ld	a,(hl)
		out	(0fdh),a
		inc	hl
		djnz	_74fd
		call	printimm
		ascii	12,0
		pop	af
		ret	

_750f:		defb	063h			
		defb	050h			
		defb	054h			
		defb	00fh			
		defb	019h			
		defb	000h			
		defb	018h			
		defb	018h			
		defb	000h			
		defb	009h			
		defb	069h			
		defb	009h			
		defb	000h			
		defb	000h			
		defb	000h			
		defb	000h			
; Wait until a key is pressed and return scancode in A.
; (Apparently unused)
waitkey:	call	havekey
		jr	z,waitkey
		in	a,(0fch)
		and	07fh
		ret	

; Return NZ if keyboard input is available.
havekey:	in	a,(0ffh)
		and	080h
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

; Display A register as '=HEX '
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

; Display HL register as '=HEX '
; (Apparently unused)
preqhex16:	push	af
		ld	a,03dh
		call	putc
		call	puthex16
		ld	a,020h
		call	putc
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

; Convert low nybble of A into ASCII hexadecimal '0' .. '9' 'A' .. 'F'
hexdig:		and	00fh
		add	a,090h
		daa	
		adc	a,040h
		daa	
		ret	

_7591:		push	af
		ld	a,(00181h)
		inc	a
		ld	(00181h),a
		ld	a,0ffh
		ld	(00180h),a
		in	a,(0feh)
		push	hl
		ld	hl,(_75ac)
		inc	hl
		ld	(_75ac),hl
		pop	hl
		pop	af
		retn	

_75ac:		nop	
		nop	
_75ae:		ld	a,(00180h)
		or	a
		ret	z
		xor	a
		ld	(00180h),a
		call	_76e8
		call	_7696
		ld	ix,(00193h)
		ld	b,(ix+00h)
		bit	0,b
		ret	nz
		ld	hl,00181h
		xor	a
		bit	1,b
		jr	nz,_75d1
		ld	(hl),a
		ret	

_75d1:		inc	a
		dec	(hl)
		jr	nz,_75d1
		ld	(ix+01h),a
		set	0,(ix+00h)
		di	
		ld	a,(0015eh)
		or	010h
		out	(0deh),a
		and	0efh
		out	(0deh),a
		ei	
		ret	

_75ea:		ld	hl,_75ea
		ld	a,01eh
		call	_765c
		ld	a,(00181h)
		cp	096h
		jr	c,_760e
		ld	a,(_6468)
		or	a
		jr	nz,_760e
		call	panic
		ascii	'68k crashed',0
_760e:		call	_6a1d
		ei	
		nop	
		nop	
		di	
		call	_5f74
		ei	
		nop	
		nop	
		di	
		jp	_56fa

_761f:		call	_76e8
		ld	ix,(00191h)
		ld	de,00000h
		add	ix,de
		ld	(00193h),ix
		xor	a
		ld	(ix+00h),a
		ld	(00181h),a
		dec	a
		ld	(00182h),a
		ld	hl,_7659
		ld	de,00066h
		ld	bc,00003h
		ldir	
		ld	a,(0017fh)
		or	020h
		ld	(0017fh),a
		out	(0ffh),a
		in	a,(0feh)
		ld	hl,_75ea
		ld	a,003h
		jp	_765c

_7659:		jp	_7591

_765c:		push	hl
		ld	c,a
		ld	hl,00182h
		xor	a
_7662:		add	a,(hl)
		cp	c
		jr	nc,_766f
		inc	(hl)
		jr	z,_766e
		inc	hl
		inc	hl
		inc	hl
		jr	_7662

_766e:		dec	(hl)
_766f:		sub	(hl)
		ld	b,a
		ld	a,c
		sub	b
		ld	c,a
		ld	a,(hl)
		cp	0ffh
		jr	z,_767b
		sub	c
		ld	(hl),a
_767b:		ld	a,c
		push	hl
		ex	de,hl
		ld	hl,0018eh
		or	a
		sbc	hl,de
		ld	b,h
		ld	c,l
		ld	hl,0018dh
		ld	de,00190h
		lddr	
		pop	hl
		ld	(hl),a
		inc	hl
		pop	de
		ld	(hl),e
		inc	hl
		ld	(hl),d
		ret	

_7696:		ld	a,(00182h)
		cp	0ffh
		ret	z
		dec	a
		ld	(00182h),a
		ret	nz
_76a1:		ld	a,(00182h)
		or	a
		ret	nz
		ld	de,_76af
		push	de
		ld	hl,(00183h)
		di	
		jp	(hl)

_76af:		ei	
		ld	hl,00185h
		ld	de,00182h
		ld	bc,0000ch
		ldir	
		jr	_76a1

_76bd:		push	bc
		ld	b,(ix+02h)
		ld	c,(ix+03h)
		set	7,b
		res	6,b
		push	bc
		ld	b,(ix+02h)
		rl	b
		ld	a,(ix+01h)
		rl	a
		ld	(0015fh),a
		out	(0dfh),a
		ld	a,(0015eh)
		rla	
		rl	b
		rra	
		ld	(0015eh),a
		out	(0deh),a
		pop	ix
		pop	bc
		ret	

_76e8:		push	af
		ld	a,(0015eh)
		and	07fh
		ld	(0015eh),a
		out	(0deh),a
		xor	a
		ld	(0015fh),a
		out	(0dfh),a
		pop	af
		ret	

_76fb:		ld	a,(0015eh)
		add	a,080h
		ld	(0015eh),a
		out	(0deh),a
		ret	nc
		ld	a,(0015fh)
		inc	a
		ld	(0015fh),a
		out	(0dfh),a
		ret	

_7710:		push	ix
		push	bc
		push	de
		push	hl
		ld	a,(0015fh)
		ld	d,a
		ld	a,(0015eh)
		ld	e,a
		push	de
		call	_76bd
		push	ix
		pop	de
_7724:		push	hl
		push	bc
		ld	hl,0ffffh
		or	a
		sbc	hl,de
		res	7,h
		res	6,h
		inc	hl
		sbc	hl,bc
		jr	nc,_7738
		add	hl,bc
		ld	b,h
		ld	c,l
_7738:		pop	hl
		or	a
		sbc	hl,bc
		ex	(sp),hl
		ldir	
		pop	bc
		call	_76fb
		res	6,d
		ld	a,c
		or	b
		jr	nz,_7724
		pop	de
		ld	a,d
		ld	(0015fh),a
		out	(0dfh),a
		ld	a,e
		ld	(0015eh),a
		out	(0deh),a
		pop	hl
		pop	de
		pop	bc
		pop	ix
		ret	

_775c:		push	ix
		push	bc
		push	de
		push	hl
		ld	a,(0015fh)
		ld	d,a
		ld	a,(0015eh)
		ld	e,a
		push	de
		call	_76bd
		push	ix
		pop	de
_7770:		push	hl
		push	bc
		ld	hl,0ffffh
		or	a
		sbc	hl,de
		res	7,h
		res	6,h
		inc	hl
		or	a
		sbc	hl,bc
		jr	nc,_7785
		add	hl,bc
		ld	b,h
		ld	c,l
_7785:		pop	hl
		or	a
		sbc	hl,bc
		ex	(sp),hl
		ex	de,hl
		ldir	
		ex	de,hl
		pop	bc
		call	_76fb
		res	6,d
		ld	a,c
		or	b
		jr	nz,_7770
		pop	de
		ld	a,d
		ld	(0015fh),a
		out	(0dfh),a
		ld	a,e
		ld	(0015eh),a
		out	(0deh),a
		pop	hl
		pop	de
		pop	bc
		pop	ix
		ret	

_77ab:		push	ix
		push	bc
		push	de
		push	hl
		ld	a,(0015fh)
		ld	d,a
		ld	a,(0015eh)
		ld	e,a
		push	de
		call	_76bd
		push	ix
		pop	de
_77bf:		push	hl
		push	bc
		ld	hl,0ffffh
		or	a
		sbc	hl,de
		res	7,h
		res	6,h
		inc	hl
		sbc	hl,bc
		jr	nc,_77d3
		add	hl,bc
		ld	b,h
		ld	c,l
_77d3:		pop	hl
		or	a
		sbc	hl,bc
		ex	(sp),hl
		ex	de,hl
		ld	a,b
		ld	b,c
		ld	c,e
_77dc:		dec	b
		inc	b
		jr	nz,_77e4
		or	a
		jr	z,_77e8
		dec	a
_77e4:		inir	
		jr	_77dc

_77e8:		ex	de,hl
		pop	bc
		call	_76fb
		res	6,d
		ld	a,c
		or	b
		jr	nz,_77bf
		pop	de
		ld	a,d
		ld	(0015fh),a
		out	(0dfh),a
		ld	a,e
		ld	(0015eh),a
		out	(0deh),a
		pop	hl
		pop	de
		pop	bc
		pop	ix
		ret	

_7806:		push	ix
		push	bc
		push	de
		push	hl
		ld	a,(0015fh)
		ld	d,a
		ld	a,(0015eh)
		ld	e,a
		push	de
		call	_76bd
		push	ix
		pop	de
_781a:		push	hl
		push	bc
		ld	hl,0ffffh
		or	a
		sbc	hl,de
		res	7,h
		res	6,h
		inc	hl
		or	a
		sbc	hl,bc
		jr	nc,_782f
		add	hl,bc
		ld	b,h
		ld	c,l
_782f:		pop	hl
		or	a
		sbc	hl,bc
		ex	(sp),hl
		ex	de,hl
		ld	a,b
		ld	b,c
		ld	c,e
_7838:		dec	b
		inc	b
		jr	nz,_7840
		or	a
		jr	z,_7844
		dec	a
_7840:		otir	
		jr	_7838

_7844:		ex	de,hl
		pop	bc
		call	_76fb
		res	6,d
		ld	a,c
		or	b
		jr	nz,_781a
		pop	de
		ld	a,d
		ld	(0015fh),a
		out	(0dfh),a
		ld	a,e
		ld	(0015eh),a
		out	(0deh),a
		pop	hl
		pop	de
		pop	bc
		pop	ix
		ret	

_7862:		ld	a,(ix+03h)
		add	a,l
		ld	(ix+03h),a
		ld	a,(ix+02h)
		adc	a,h
		ld	(ix+02h),a
		ld	a,(ix+01h)
		adc	a,000h
		ld	(ix+01h),a
		ret	

_7879:		ld	a,(ix+03h)
		sub	l
		ld	(ix+03h),a
		ld	a,(ix+02h)
		sbc	a,h
		ld	(ix+02h),a
		ld	a,(ix+01h)
		sbc	a,000h
		ld	(ix+01h),a
		ret	

_7890:		push	bc
		ld	b,000h
_7893:		ld	a,(hl)
		inc	hl
		or	a
		jr	z,_78a6
		ld	c,a
		ld	a,(hl)
		inc	hl
		push	hl
		ld	hl,00080h
		add	hl,bc
		ld	(hl),a
		out	(c),a
		pop	hl
		jr	_7893

_78a6:		pop	bc
		ret	

_78a8:		ld	bc,00000h
		or	a
_78ac:		sbc	hl,de
		jp	c,_78b4
		inc	bc
		jr	_78ac

_78b4:		add	hl,de
		ret	

		push	bc
		push	de
		ex	de,hl
		ld	hl,00000h
_78bc:		ld	a,b
		or	c
		jr	z,_78c4
		add	hl,de
		dec	bc
		jr	_78bc

_78c4:		pop	de
		pop	bc
		ret	

_78c7:		ld	a,(002e5h)
		or	a
		ret	nz
		or	0ffh
		ld	(002e5h),a
		xor	a
		ret	

_78d3:		xor	a
		ld	(002e5h),a
		push	bc
		push	hl
		ld	hl,_78e4
		ld	bc,004f8h
		otir	
		pop	hl
		pop	bc
		ret	

_78e4:		defb	083h			
		defb	08bh			
		defb	0afh			
		defb	0c3h			
_78e8:		ld	(_78f5),hl
		ld	hl,_78f4
		ld	bc,00ef8h
		otir	
		ret	

_78f4:		defb	079h			
_78f5:		defb	000h			
		defb	000h			
		defb	0e0h			
		defb	02eh			
		defb	014h			
		defb	028h			
		defb	0c5h			
		defb	0e7h			
		defb	08ah			
		defb	0cfh			
		defb	005h			
		defb	0cfh			
		defb	087h			
_7902:		ld	(_7915),hl
		ld	hl,_790e
		ld	bc,00cf8h
		otir	
		ret	

_790e:		defb	06dh			
		defb	0e7h			
		defb	000h			
		defb	004h			
		defb	02ch			
		defb	010h			
		defb	0cdh			
_7915:		defb	000h			
		defb	000h			
		defb	08ah			
		defb	0cfh			
		defb	087h			
_end		equ	$

		end	_start
