; x320boot Boot Track Disassembly
;
; Can be reassembled with zmac.  Suggested workflow is to make changes
; and verify that file still assembles to the original.  Under windows:
;
;	zmac x320boot.asm
;	fc /b zout/x320boot.cim x320boot
;
; For Mac and Linux:
;
;	zmac x320boot.asm
;	cmp zout/x320boot.cim x320boot
;
; If a code section needs to be converted to data, consult zout/x320boot.lst
; to easily determine the data bytes.
;
; Current Status:
;	Not completely clear the entry point is $1004.  Check out boot ROM.
;
;	I think all the data and addresses have been identified but there
;	are some bits of code doing table lookup where the location of the
;	table is not clear.
;
;	Of course, save enough to "patch" if your changes use up exactly
;	the same space as the original code.

		org	$80
port_shadow:	defs	$100

sh_a0		equ	$120	; port shadow for $A0 - speaker
sh_de		equ	$15e	; port shadow for $DE - tranfer control latch
sh_df		equ	$15f	; port shadow for $DF - upper address latch


		org	00e00h
		ascii	'Tue Mar  3 13:51:14 CST 1987',10,0
		dc	482,0

		ascii	'BOOT'
v_putc:		jp	putc

v_waitkey:	jp	waitkey

		jp	havekey

v_printimm:	jp	printimm

		jp	_1200

		jp	_1221

		jp	pal_ntsc_detect

v_print:	jp	print

_101c:		jp	_1243

_101f:		jp	_12de

v_getline:	jp	getline

_1025:		defb	000h

putc:		push	af
		push	bc
		push	de
		push	hl
		ld	hl,do_hz_detect
		bit	0,(hl)
		ld	(hl),000h
		call	nz,pal_ntsc_detect
		and	07fh
		ld	hl,(00074h)
		push	hl
		ld	hl,(00072h)
		ret	

do_hz_detect:	defb	0ffh

_103f:		pop	hl
		pop	de
		pop	bc
		pop	af
		ret	

_1044:		cp	020h
		jp	nc,_107b
		cp	00dh
		jr	z,_1061
		cp	00ah
		jr	z,_1066
		cp	008h
		jr	z,_106a
		cp	009h
		jr	z,_1073
		cp	00ch
		jp	z,cls
		jp	_103f

_1061:		ld	l,000h
		jp	_1085

_1066:		inc	h
		jp	_1085

_106a:		ld	a,l
		or	a
		jp	z,_1085
		dec	l
		jp	_1085

_1073:		ld	a,l
		or	007h
		inc	a
		ld	l,a
		jp	_1085

_107b:		push	hl
		ld	b,a
		call	_1114
		ld	(hl),b
		pop	hl
		inc	l
		jr	_1085

_1085:		ld	de,_1044
		ld	(00074h),de
		ld	a,l
		cp	050h
		jr	c,_1094
		ld	l,000h
		inc	h
_1094:		ld	a,h
		cp	018h
		jr	c,_10b0
		ld	h,017h
		push	hl
		ld	hl,(00070h)
		ld	de,00050h
		add	hl,de
		call	_112b
		ld	hl,_1700
		ld	bc,00050h
		call	_10cd
		pop	hl
_10b0:		call	_10b6
		jp	_103f

_10b6:		push	hl
		ld	(00072h),hl
		call	_1100
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

_10cd:		push	de
		push	hl
		call	_1114
		ld	d,020h
_10d4:		ld	(hl),d
		inc	l
		jp	nz,_10df
		inc	h
		jp	nz,_10df
		ld	h,0f8h
_10df:		dec	c
		jp	nz,_10d4
		dec	b
		jp	p,_10d4
		pop	hl
		pop	de
		ret	

cls:		ld	hl,0f800h
		ld	de,0f801h
		ld	bc,0077fh
		ld	(hl),020h
		ldir	
		ld	hl,00000h
		call	_112b
		jp	_1085

_1100:		push	bc
		ld	a,h
		ld	c,l
		ld	b,000h
		call	mult80
		add	hl,bc
		ld	bc,(00070h)
		add	hl,bc
		ld	a,h
		and	03fh
		ld	h,a
		pop	bc
		ret	

_1114:		call	_1100
		ld	a,h
		or	0f8h
		ld	h,a
		ret	

mult80:		push	de
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

_112b:		ld	a,i
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

; Figure out if we have a 60 Hz (NTSC) or 50 Hz (PAL) display.
; Seems like it my be deciding this by looking at the BOOT ROM.
; Or something set up by the boot ROM.  Mysterious.  Though it
; sure does look like it is growling around looking for the
; CRTC setup parameters in the boot ROM.

pal_ntsc_detect:
		push	af
		ld	bc,00800h
		ld	hl,00000h
_114d:		ld	a,018h
		cpir	
		jp	m,_1170
		ld	d,h
		ld	e,l
		inc	hl
		dec	bc
		ld	a,(hl)
		cp	000h
		jr	nz,_114d
		inc	hl
		dec	bc
		ld	a,(hl)
		cp	009h
		jr	nz,_114d
		dec	de
		dec	de
		dec	de
		ld	a,(de)
		cp	019h
		jr	z,_1184
		cp	01eh
		jr	z,_1174
_1170:		ld	a,0b6h
		jr	_1181

_1174:		ld	de,crtc_reg_init+4
		ld	hl,crtc_pal_change
		ld	bc,00004h
		ldir	
		ld	a,035h
_1181:		ld	(hz_msg+1),a
_1184:		ld	a,(hz_msg+1)		; Save PAL flag for z80ctl
		ld	(07fffh),a
		xor	a
		out	(0f9h),a
		ld	hl,00000h
		ld	(00070h),hl
		ld	(00072h),hl
		ld	hl,_1044
		ld	(00074h),hl
		ld	a,000h
		ld	(sh_a0),a
		out	(0a0h),a
		ld	hl,crtc_reg_init
		ld	b,010h
_11a8:		ld	a,010h
		sub	b
		out	(0fch),a
		ld	a,(hl)
		out	(0fdh),a
		inc	hl
		djnz	_11a8
		call	printimm
		ascii	12,0
		ld	hl,hz_msg
		ld	de,0f84ah
		ld	bc,hz_msg_end - hz_msg
		ldir	
		pop	af
		ret	

crtc_reg_init:	defb	063h,050h,054h,00fh,019h,000h,018h,018h,000h,009h,069h,009h,000h,000h,000h,000h

crtc_pal_change:
		defb	01eh,002h,018h,01bh

hz_msg:		ascii	'[60hz]'
hz_msg_end:	ascii	0		; nul not actually needed

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

print:		ld	a,(hl)
		inc	hl
		or	a
		ret	z
		call	putc
		jr	print

_1200:		push	af
		ld	a,03dh
		call	putc
		pop	af
		push	af
		call	_1212
		ld	a,020h
		call	putc
		pop	af
		ret	

_1212:		push	af
		rrca	
		rrca	
		rrca	
		rrca	
		call	_121b
		pop	af
_121b:		call	_123a
		jp	putc

_1221:		push	af
		ld	a,03dh
		call	putc
		call	_1231
		ld	a,020h
		call	putc
		pop	af
		ret	

_1231:		push	hl
		ld	a,h
_1233:		call	_1212
		pop	hl
		ld	a,l
		jr	_1212

_123a:		and	00fh
		add	a,090h
		daa	
		adc	a,040h
		daa	
		ret	

_1243:		push	bc
		push	de
		push	hl
		ex	de,hl
		ld	(out_F8_1+7),hl
		ld	hl,out_F8_0
		ld	bc,004f8h
		otir	
		ld	hl,00010h
		add	hl,de
		ld	a,l
		and	00fh
		inc	a
		out	(0e6h),a
		add	hl,hl
		add	hl,hl
		in	a,(0e0h)
		and	002h
		jr	nz,_1268
		add	hl,hl
		xor	a
		jr	_1269

_1268:		ld	a,l
_1269:		and	040h
		or	080h
		xor	040h
		ld	b,a
		ld	a,(0016fh)
		and	00fh
		or	b
		out	(0efh),a
		ld	(0016fh),a
		add	hl,hl
		ld	b,005h
_127e:		dec	b
		call	z,_1407
		in	a,(0e5h)
		cp	h
		jr	z,_129e
		ld	a,h
		out	(0e7h),a
		ld	a,(00065h)
		or	01ch
		out	(0e4h),a
_1291:		in	a,(0e0h)
		and	001h
		jr	z,_1291
		in	a,(0e4h)
		and	098h
		jp	nz,_127e
_129e:		ld	b,005h
_12a0:		dec	b
		call	z,_1407
		push	hl
		push	bc
		ld	hl,out_F8_1
		ld	bc,00cf8h
		otir	
		pop	bc
		pop	hl
		ld	a,080h
		out	(0e4h),a
_12b4:		in	a,(0e0h)
		and	001h
		jr	z,_12b4
		in	a,(0e4h)
		and	09ch
		jr	nz,_12a0
		push	af
		ld	hl,out_F8_0
		ld	bc,004f8h
		otir	
		pop	af
		pop	hl
		pop	de
		pop	bc
		ret	

out_F8_0:	defb	0c3h,083h,08bh,0afh
out_F8_1:	defb	06dh,0e7h,000h,002h,02ch,010h,0cdh,000h,000h,08ah,0cfh,087h

_12de:		push	hl
		ld	a,04eh
		ld	(0016fh),a
		out	(0efh),a
		ld	a,0d8h
		out	(0e4h),a
		ld	a,0d0h
		out	(0e4h),a
		ld	hl,003e8h
_12f1:		dec	hl
		ld	a,h
		or	l
		jr	nz,_12f1
		in	a,(0e7h)
		in	a,(0e0h)
		ld	hl,00000h
_12fd:		dec	hl
		ld	a,h
		or	l
		call	z,_1407
		in	a,(0e4h)
		and	080h
		jr	nz,_12fd
		ld	a,(00065h)
		or	008h
		out	(0e4h),a
_1310:		in	a,(0e0h)
		and	001h
		jr	z,_1310
		in	a,(0e4h)
		ld	a,000h
		ld	(00165h),a
		out	(0e5h),a
		pop	hl
		ret	

; Read a line of input from the keyboard into a buffer at HL.
; If user gives an empty line then buffer is filled with default value at DE.
; Buffer at HL is terminated with '#'.
; Returns Z=1 if an empty line was entered (which means the default was used).

getline:	ld	c,000h
_1323:		ld	(hl),000h
		call	waitkey
		cp	13
		jr	z,_135d
		cp	'?'
		jr	z,_1364
		cp	'!'
		jr	c,_1364
		cp	'A'
		jr	c,_1345
		cp	'Z'+1
		jr	nc,_1345
		push	af
		ld	a,001h
		ld	(_1025),a
		pop	af
		add	a,020h
_1345:		ld	(hl),a
		call	putc
		inc	c
		inc	hl
		ld	a,(hl)
		cp	'#'		; check if end of input buffer
		jr	nz,_1323
_1350:		dec	hl
		dec	c
		ld	(hl),000h
		call	printimm
		ascii	8,' ',8,0
		jr	_1323

_135d:		ld	a,c
		or	a
		call	z,_13b0
		xor	a
		ret	

_1364:		ld	b,a
		ld	a,c
		or	a
		ld	a,b
		jr	nz,_1385
		cp	002h
		jr	z,_137d
		cp	'?'
		jr	z,_139b
		cp	004h
		jr	nz,_1323
		ld	a,c
		or	a
		call	z,_13b0
		jr	_1323

_137d:		cp	c
		call	printimm
		ascii	13,10,0
		ret	

_1385:		cp	008h
		jr	z,_1350
		cp	015h
		jp	nz,_1323
		ld	b,c
_138f:		call	printimm
		ascii	8,' ',8,0
		dec	hl
		djnz	_138f
		jr	getline

_139b:		push	ix
_139d:		ld	a,(ix+00h)
		or	a
		jp	z,_13ab
		call	putc
		inc	ix
		jr	_139d

_13ab:		pop	ix
		jp	getline

_13b0:		push	de
_13b1:		ld	a,(de)
		or	a
		ld	(hl),a
		jr	z,_13be
		call	putc
		inc	hl
		inc	de
		inc	c
		jr	_13b1

_13be:		pop	de
		ret	

; Pretty sure this is a "pad to $1400" deal.  I've filled the data
; explicitly instead of doing an "org" so we're not dependent on the
; what the build system decides to put in the empty space.

		dc	$1400-$,0

		ascii	'DIAG'
; TODO: This entry point is just a guess.  Boot ROM will tell us for sure.
_start:		di	
		jr	_140a

_1407:		jp	_198d

_140a:		ld	sp,01b31h
		call	v_printimm
		ascii	'Tandy 68000/XENIX Boot      Version is 3(31)  3-Mar-87 ',13,10,'Copyright 1987 Tandy Corporation.  All Rights Reserved.',13,10,13,10,13,10,0
		ld	a,0c9h		; "ret" opcode
		ld	(00066h),a	; Just ignore real-time clock interrupts.
		ld	a,0c3h
		ld	(000fdh),a
		ld	hl,_14dc
		ld	(000feh),hl
		xor	a
		ld	(07ffeh),a	; let some other problem know we ran?
		ld	a,002h
		ld	(00065h),a
		call	setup_hardware
		ld	bc,00400h
_14a6:		dec	bc
		ld	a,b
		or	c
		jr	nz,_14a6
		ld	hl,unknown_intr
		ld	(02500h),hl
		ld	hl,02500h
		ld	de,02502h
		ld	bc,00080h
		ldir	
		ld	a,025h
		ld	i,a
		im	2
		ei	
		xor	a
		out	(0fch),a
		ld	c,07ch
		in	b,(c)
		inc	a
		out	(0fch),a
		in	a,(c)
		cp	b
		jr	z,_14dc
		call	bughlt
		ascii	'IoCyc7',0
_14dc:		ld	sp,01b31h
_14df:		call	v_printimm
		ascii	'Xenix Boot> ',0
		ld	de,default_kernel_name
		ld	hl,kernel_name
		ld	ix,kernel_boot_help_msg
		call	v_getline
		ld	ix,kernel_boot_help_msg+91
		jr	z,_1538
		call	v_printimm
		ascii	'Z80 Driver> ',0
		ld	de,default_z80ctl_name
		ld	hl,z80ctl_name
		call	v_getline
		jr	nz,_14df
		call	v_printimm
		ascii	13,10,'Kernel> ',0
		ld	de,default_kernel_name
		ld	hl,kernel_name
		call	v_getline
		jr	nz,_14df
		jr	_1545

_1538:		ld	hl,z80ctl_name
		ld	de,default_z80ctl_name
_153e:		ld	a,(de)
		ld	(hl),a
		or	a
		inc	de
		inc	hl
		jr	nz,_153e
_1545:		ld	hl,kernel_name
		call	_16a8
		jr	nz,_156d
		ld	a,(_1622)
		or	a
		jr	z,_1564
		ld	hl,z80ctl_name
		call	_16b1
		jr	nz,_156d
		ld	a,(_1622)
		or	a
		jr	nz,_1587
		call	_1625
_1564:		ld	a,000h
		ld	(00077h),a	; Hmmm, telling z80ctl someting
		ld	hl,(_1623)
		jp	(hl)

_156d:		call	v_printimm
		ascii	'Program not found',13,10,0
		jp	_14df

_1587:		call	bugchk
		ascii	'BadCtl',13,10,0
		jp	_14df

; The '#' here are important to mark the end of the input buffer.

kernel_name:	ascii	'xxxxxxxxxxxxxxx#'
z80ctl_name:	ascii	'xxxxxxxxxxxxxxx#'

default_kernel_name:
		ascii	'xenix',0
default_z80ctl_name:
		ascii	'z80ctl',0
kernel_boot_help_msg:
		ascii	'?Press <Enter> to boot xenix, or enter one of the',13,10,'following:',9,'xenix',9,9,'diskutil',13,10,'Xenix Boot> ',0
_161f:		nop	
		nop	
		nop	
_1622:		nop	
_1623:		nop	
		nop	
_1625:		call	v_printimm
		ascii	'System loaded ...',0
_163a:		call	v_printimm
		ascii	13,10,'Change root disk if desired;',0
		call	v_printimm
		ascii	13,10,'type <enter> to proceed or <break> to abort ',0
		call	v_waitkey
		cp	003h
		jr	z,_16a0
		cp	00dh
		jr	nz,_163a
		call	v_printimm
		ascii	13,10,0
		ret	

_16a0:		call	v_printimm
		ascii	12,0
		jp	_start

_16a8:		call	v_printimm
		ascii	13,10,0
		call	v_putc
_16b1:		ld	ix,_161f
		call	_101f
		call	_170c
		jr	nz,_1705
		call	_18ae
		ld	de,00781h
		call	_184c
		jr	nz,_1705
		call	_1741
		ld	b,009h
		call	_182d
		jr	nz,_1704
		ld	de,00581h
		call	_184c
		jr	nz,_1704
		ex	de,hl
		ld	b,080h
		call	_182d
		jr	nz,_1704
		ex	de,hl
		ld	de,00781h
		call	_184c
		jr	nz,_1704
		ex	de,hl
		ld	b,080h
_16ee:		ld	de,00581h
		call	_184c
		jr	nz,_1704
		push	bc
		push	hl
		ex	de,hl
		ld	b,080h
		call	_182d
		pop	hl
		pop	bc
_1700:		jr	nz,_1704
		djnz	_16ee
_1704:		xor	a
_1705:		push	af
		ld	a,0ffh
		out	(0efh),a
		pop	af
		ret	

_170c:		ld	(_173f),hl
		ld	hl,00002h
		call	_18ae
_1715:		ld	de,00781h
		call	_184c
		ret	nz
		push	hl
		ex	de,hl
		ld	b,020h
_1720:		ld	d,(hl)
		inc	hl
		ld	e,(hl)
		inc	hl
		ld	a,e
		or	d
		jr	z,_1733
		push	de
		ld	de,(_173f)
		call	strcmp
		pop	de
		jr	z,_173c
_1733:		ld	de,0000eh
		add	hl,de
		djnz	_1720
		pop	hl
		jr	_1715

_173c:		pop	hl
		ex	de,hl
		ret	

_173f:		nop	
		nop	
_1741:		push	bc
		push	de
		push	hl
		ld	(ix+00h),000h
		ld	(ix+01h),000h
		ld	(ix+02h),000h
		ld	(ix+03h),0ffh
		ld	de,(00781h)
		ld	hl,00602h
		or	a
		sbc	hl,de
		call	nz,_198d
		ld	bc,00020h
		ld	de,(00783h)
		ld	h,e
		ld	l,d
		add	hl,bc
		ld	b,h
		ld	c,l
		ld	a,(0079dh)
		and	03fh
		cp	005h
		jr	z,_1795
		cp	006h
		call	nz,_198d
		ld	hl,(007abh)
		ld	(ix+00h),h
		ld	(ix+01h),l
		ld	(ix+02h),000h
		ld	(ix+03h),000h
		ld	de,(0079bh)
		ld	h,e
		ld	l,d
		ld	(_1623),hl
_1795:		ld	hl,00200h
		or	a
		sbc	hl,bc
		push	hl
		ld	hl,00781h
		add	hl,bc
		pop	bc
		push	bc
		bit	0,(ix+03h)
		jr	z,_180b
		push	bc
		push	hl
		ld	bc,(08000h)
		ld	de,_1233+1
		ld	(08000h),de
		ld	hl,(08000h)
		or	a
		sbc	hl,de
		jr	nz,_17f9
		ld	a,(sh_de)
		or	001h
		out	(0deh),a
		ld	hl,(08000h)
		and	0feh
		out	(0deh),a
		or	a
		sbc	hl,de
		ld	(08000h),bc
; Make this "jr _1804" to disable check for new PAL with burst mode.
		jr	z,_1804
		call	bughlt
		ascii	'NewPal - Hardware Change Required',0
_17f9:		call	bughlt
		ascii	'No68k',13,10,0
_1804:		pop	hl
		pop	bc
		call	_1931
		jr	_1813

_180b:		ld	e,(ix+00h)
		ld	d,(ix+01h)
		ldir	
_1813:		pop	bc
		ld	l,(ix+00h)
		ld	h,(ix+01h)
		add	hl,bc
		ld	(ix+00h),l
		ld	(ix+01h),h
		ld	a,(ix+02h)
		adc	a,000h
		ld	(ix+02h),a
		pop	hl
		pop	de
		pop	bc
		ret	

_182d:		push	de
		push	bc
_182f:		inc	hl
		ld	a,(hl)
		inc	hl
		ld	d,(hl)
		inc	hl
		ld	e,(hl)
		inc	hl
		push	hl
		ld	l,a
		or	d
		or	e
		ld	a,l
		pop	hl
		jr	z,_1847
		ex	de,hl
		call	_186b
		ex	de,hl
		djnz	_182f
		or	0ffh
_1847:		xor	0ffh
		pop	bc
		pop	de
		ret	

_184c:		push	bc
		push	de
		push	de
		inc	hl
		ld	a,(hl)
		inc	hl
		ld	d,(hl)
		inc	hl
		ld	e,(hl)
		inc	hl
		ex	(sp),hl
		push	hl
		ld	l,a
		or	e
		or	d
		ld	a,l
		ex	de,hl
		pop	de
		jr	z,_1865
		call	_101c
		or	0ffh
_1865:		xor	0ffh
		pop	hl
		pop	de
		pop	bc
		ret	

_186b:		push	bc
		push	de
		push	hl
		bit	0,(ix+03h)
		jr	z,_1883
		ld	de,00381h
		call	_101c
		ld	bc,00200h
		ex	de,hl
		call	_1931
		jr	_188c

_1883:		ld	e,(ix+00h)
		ld	d,(ix+01h)
		call	_101c
_188c:		ld	l,(ix+01h)
		ld	h,(ix+02h)
		ld	bc,00002h
		add	hl,bc
		ld	(ix+01h),l
		ld	(ix+02h),h
		pop	hl
		pop	de
		pop	bc
		ret	

_18a0:		xor	a
		ld	(de),a
		inc	de
		push	bc
		ldi	
		ldi	
		ldi	
		pop	bc
		djnz	_18a0
		ret	

_18ae:		dec	hl
		push	hl
		srl	h
		rr	l
		srl	h
		rr	l
		srl	h
		rr	l
		inc	hl
		inc	hl
		xor	a
		ld	de,00181h
		call	_101c
		pop	hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	h,000h
		add	hl,hl
		ld	de,0018dh
		add	hl,de
		ld	b,00dh
		ld	de,00981h
		push	de
		call	_18a0
		pop	hl
		ret	

_18dd:		in	a,(0cfh)
		push	bc
		ld	b,a
		in	a,(0cfh)
		cp	b
		pop	bc
		jr	nz,_18dd
		and	080h
		jr	nz,_18dd
		ret	

		jp	(hl)

a_reti:		reti	

; Follow big-endian 32 bit pointer at PG:ix
; 
; Returns with PG:bc pointing at the new location.
; 
; Only 23 bits are significant so it ignores the highest byte at (ix+0).

deref_PG_ix:	push	bc
		ld	b,(ix+01h)
		ld	c,(ix+00h)
		set	7,b
		res	6,b
		push	bc
		ld	b,(ix+01h)
		rl	b
		ld	a,(ix+02h)
		rl	a
		ld	(sh_df),a
		out	(0dfh),a
		ld	a,(sh_de)
		rla	
		rl	b
		rra	
; Make this "or 0" to disable burst mode usage.
		or	001h
		ld	(sh_de),a
		out	(0deh),a
		pop	ix
		pop	bc
		ret	

; Increment PG register.
page_inc:	ld	a,(sh_de)
		add	a,080h
		ld	(sh_de),a
		out	(0deh),a
		ret	nc
		ld	a,(sh_df)
		inc	a
		ld	(sh_df),a
		out	(0dfh),a
		ret	

_1931:		push	ix
		push	bc
		push	de
		push	hl
		call	deref_PG_ix
		push	ix
		pop	de
_193c:		push	hl
		push	bc
		ld	hl,0ffffh
		or	a
		sbc	hl,de
		res	7,h
		res	6,h
		inc	hl
		sbc	hl,bc
		jr	nc,_1950
		add	hl,bc
		ld	b,h
		ld	c,l
_1950:		pop	hl
		or	a
		sbc	hl,bc
		ex	(sp),hl
		push	bc
		push	de
		push	hl
		ldir	
		pop	hl
		pop	de
		pop	bc
		call	_1a59
		pop	bc
		call	page_inc
		res	6,d
		ld	a,c
		or	b
		jr	nz,_193c
		pop	hl
		pop	de
		pop	bc
		pop	ix
		ret	

; Compare nul-terminated strings at (DE) and (HL).
; Returns Z=1 if equal, Z=0 (i.e., NZ) if different.

strcmp:		push	hl
		push	de
_1972:		ld	a,(de)
		cp	(hl)
		jr	nz,_197d
		or	a
		jr	z,_197d
		inc	hl
		inc	de
		jr	_1972

_197d:		pop	de
		pop	hl
		ret	

		ld	bc,00000h
		or	a
_1984:		sbc	hl,de
		jr	c,_198b
		inc	bc
		jr	_1984

_198b:		add	hl,de
		ret	

_198d:		call	bughlt
		ascii	"HRDIOE - Can't load Xenix",0

setup_hardware:	in	a,(0feh)
		in	a,(0fch)
		ld	b,006h
_19b0:		call	a_reti		; ack any pending interrupts
		djnz	_19b0
		ld	hl,_19bc
		call	send_portz
		ret	

_19bc:		defb	0f8h,0c3h
		defb	0f8h,0c3h
		defb	0f8h,0c3h
		defb	0f8h,0c3h
		defb	0f8h,0c3h
		defb	0f8h,0c3h
		defb	0f8h,083h
		defb	0deh,00ch	; reset 68000
		defb	0ffh,080h
		defb	0dfh,000h
		defb	041h,008h
		defb	0e2h,0cfh
		defb	0e2h,0f7h
		defb	0e2h,037h
		defb	0e2h,0feh
		defb	0e3h,003h
		defb	0e3h,00fh
		defb	0f0h,003h
		defb	0f1h,003h
		defb	0f2h,003h
		defb	0f3h,003h
		defb	0c4h,003h
		defb	0efh,00fh
		defb	041h,000h
		defb	074h,003h
		defb	075h,003h
		defb	076h,003h
		defb	077h,003h
		defb	064h,003h
		defb	065h,003h
		defb	066h,003h
		defb	067h,003h
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
		defb	0deh,004h	; halt 68000
		defb	0f6h,018h
		defb	0f6h,030h
		defb	0f6h,028h
		defb	0f6h,010h
		defb	0f7h,018h
		defb	0f7h,030h
		defb	0f7h,028h
		defb	0f7h,010h
		defb	083h,000h
		defb	000h

send_portz:	push	bc
		ld	b,000h
_1a44:		ld	a,(hl)
		inc	hl
		or	a
		jr	z,_1a57
		ld	c,a
		ld	a,(hl)
		inc	hl
		push	hl
		ld	hl,port_shadow
		add	hl,bc
		ld	(hl),a
		out	(c),a
		pop	hl
		jr	_1a44

_1a57:		pop	bc
		ret	

_1a59:		ld	a,(de)
		cpi	
		jr	nz,_1a63
		inc	de
		jp	pe,_1a59
		ret	

_1a63:		call	bughlt
		ascii	'68kMem - Memory Error',0
		jp	_1aae

		call	v_printimm
		ascii	13,10,'Buginf: ',0
_1a8d:		jp	v_printimm

bugchk:		call	v_printimm
		ascii	'Bugchk: ',0
		jr	_1a8d

bughlt:		call	v_printimm
		ascii	'Bughlt: ',0
		pop	hl
		call	v_print
_1aae:		call	v_printimm
		ascii	13,10,0
		di	
freeze:		halt	
		jr	freeze

unknown_intr:	push	af
		push	hl
		call	bugchk
		ascii	'UnkInt',0
		pop	hl
		pop	af
		ei	
		reti	

		ascii	'fdiv'

; These $e5 bytes are typically seen in a new sector and surely have
; no special meaning just padding out to a sector boundary.  So
; I've captured that in a macro.  Might mean to pad to a certain number
; of sectors instead.

		dc	256-low($),$e5

		end	_start
