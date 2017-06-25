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
;	Disassembly largely complete.  Should be able to reassemble at will.
;	Still need some labels and commentary but major pieces documented.
;
; The main areas of the code are display routines, floppy-disc sector reading
; and file loading from the UNIX file system.  Pretty clear that it is
; dealing with a classic inode file system with pointers to direct blocks,
; indirect blocks and double-indrect blocks.  The disassembly glosses over
; the details but file-system specifics could be gleaned.  Wikipedia entry
; on inode pointer structure will help in understanding:
;	https://en.wikipedia.org/wiki/Inode_pointer_structure
;
; Details of the floppy disk sector loading and how file system blocks
; map to floppy track and sector have not been exposed.
;
; The console display code is clearly related to that in diskutil and z80ctl.
; More like that in diskutil but perhaps even less functionality.

		org	$80
port_shadow:	defs	$100

sh_a0		equ	$120	; $A0 - speaker
sh_de		equ	$15e	; $DE - tranfer control latch
sh_df		equ	$15f	; $DF - upper address latch
sh_e5		equ	$165	; $E5 - FDC track but not always used
sh_ef		equ	$16f	; $EF - floppy select

inode_sector	equ	$181	; storage of inode data (512 bytes)
tmp_sector	equ	$381	; tmp for when loading to 68k
idx_sector	equ	$581	; sector of indexes
file_sector	equ	$781	; current data sector of file (512 bytes)
file_idx	equ	$981	; 13 x 4 byte indexes to disk blocks

		org	00e00h
		ascii	'Tue Mar  3 13:51:14 CST 1987',10,0
		dc	482,0

		ascii	'BOOT'
v_putc:		jp	putc

v_waitkey:	jp	waitkey

		jp	havekey

v_printimm:	jp	printimm

		jp	puthex_spc

		jp	puthex16_spc

		jp	pal_ntsc_detect

v_print:	jp	print

v_fdc_read_sector:
		jp	fdc_read_sector

v_uh_fdc_t0s1:	jp	uh_fdc_t0s1

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

; Display A register as "=HEX "

puthex_spc:	push	af
		ld	a,'='
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

; Display HL register as "=HEX "

puthex16_spc:	push	af
		ld	a,'='
		call	putc
		call	puthex16
		ld	a,' '
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

; Convert low nybble of A into ASCII hexadecimal '0' .. '9' 'A' .. 'F'

hexdig:		and	00fh
		add	a,090h
		daa	
		adc	a,040h
		daa	
		ret	

; Wildly guessing this will read track H, sector L from floppy drive.
; Reads to buffer at DE.

fdc_read_sector:
		push	bc
		push	de
		push	hl
		ex	de,hl
		ld	(out_F8_1+7),hl
		ld	hl,out_F8_0
		ld	bc,004f8h
		otir			; have DMA do something
		ld	hl,00010h
		add	hl,de
		ld	a,l
		and	00fh
		inc	a
		out	(0e6h),a	; FDC sector
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
		ld	a,(sh_ef)
		and	00fh
		or	b
		out	(0efh),a	; FDC select
		ld	(sh_ef),a
		add	hl,hl
		ld	b,005h
_127e:		dec	b
		call	z,v_hrdioe
		in	a,(0e5h)	; FDC track
		cp	h
		jr	z,_129e
		ld	a,h
		out	(0e7h),a	; FDC data register
		ld	a,(00065h)
		or	01ch
		out	(0e4h),a	; FDC command register (seek?)
_1291:		in	a,(0e0h)
		and	001h
		jr	z,_1291
		in	a,(0e4h)	; FDC status register
		and	098h
		jp	nz,_127e
_129e:		ld	b,005h
_12a0:		dec	b
		call	z,v_hrdioe
		push	hl
		push	bc
		ld	hl,out_F8_1
		ld	bc,00cf8h
		otir			; DMA do something
		pop	bc
		pop	hl
		ld	a,080h
		out	(0e4h),a	; FDC command register
_12b4:		in	a,(0e0h)
		and	001h
		jr	z,_12b4		; wait for FDC interrupt
		in	a,(0e4h)	; FDC status register
		and	09ch
		jr	nz,_12a0
		push	af
		ld	hl,out_F8_0
		ld	bc,004f8h
		otir			; DMA do something
		pop	af
		pop	hl
		pop	de
		pop	bc
		ret	

out_F8_0:	defb	0c3h,083h,08bh,0afh
out_F8_1:	defb	06dh,0e7h,000h,002h,02ch,010h,0cdh,000h,000h,08ah,0cfh,087h

; Talking to the floppy, surely, but will display a HRDIOE message if it fails.
; Maybe that means "HaRD I/O Error" rather than "HaRD drive I/O Error".

; Tenatively saying this seeks the floppy to track 0, side 1.

uh_fdc_t0s1:	push	hl
		ld	a,04eh
		ld	(sh_ef),a
		out	(0efh),a	; FM, side 1, drive 0
		ld	a,0d8h
		out	(0e4h),a	; FDC command
		ld	a,0d0h
		out	(0e4h),a	; FDC command
		ld	hl,003e8h
_12f1:		dec	hl
		ld	a,h
		or	l
		jr	nz,_12f1
		in	a,(0e7h)	; FDC data register
		in	a,(0e0h)	; clear FDC error?
		ld	hl,00000h
_12fd:		dec	hl
		ld	a,h
		or	l
		call	z,v_hrdioe	; error on timeout
		in	a,(0e4h)	; FDC status (clear FDC intr?)
		and	080h
		jr	nz,_12fd	; keep trying if not ready
		ld	a,(00065h)
		or	008h
		out	(0e4h),a	; FDC command
_1310:		in	a,(0e0h)
		and	001h
		jr	z,_1310		; wait until FDC interrupt signalled.
		in	a,(0e4h)	; FDC status (clear FDC intr?)
		ld	a,000h
		ld	(sh_e5),a
		out	(0e5h),a	; select track 0
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
		jr	z,print_help
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

print_help:	push	ix
phlp:		ld	a,(ix)
		or	a
		jp	z,phlpdn
		call	putc
		inc	ix
		jr	phlp

phlpdn:		pop	ix
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
start:
restart:	di	
		jr	splash

v_hrdioe:	jp	hrdioe

splash:		ld	sp,01b31h
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
		call	cr_read_file
		jr	nz,_156d
		ld	a,(file_type)
		or	a
		jr	z,_1564		; skip Z80 ctl if "kernel" was Z-80
		ld	hl,z80ctl_name
		call	read_file
		jr	nz,_156d
		ld	a,(file_type)
		or	a
		jr	nz,_1587	; z80ctl better not be a 68k file
		call	continue_prompt
_1564:		ld	a,000h
		ld	(00077h),a	; Hmmm, telling z80ctl someting
		ld	hl,(z80ctl_entry)
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

; IX points here during file load.
; Frist 3 bytes are load address (24 bits needed for 68k loads).
; 3rd byte is flag to indicate z80/68k load.

f_load0		equ	0
f_load1		equ	1
f_load2		equ	2
f_type		equ	3

file_info:	nop	
		nop	
		nop	
file_type:	nop	

z80ctl_entry:	word	0

continue_prompt:
		call	v_printimm
		ascii	'System loaded ...',0
cp_again:	call	v_printimm
		ascii	13,10,'Change root disk if desired;',0
		call	v_printimm
		ascii	13,10,'type <enter> to proceed or <break> to abort ',0
		call	v_waitkey
		cp	3
		jr	z,abort
		cp	13
		jr	nz,cp_again
		call	v_printimm
		ascii	13,10,0
		ret	

abort:		call	v_printimm
		ascii	12,0
		jp	restart

; Returns NZ if error, Z otherwise.

cr_read_file:	call	v_printimm
		ascii	13,10,0
		call	v_putc
read_file:	ld	ix,file_info
		call	v_uh_fdc_t0s1
		call	open_file
		jr	nz,_1705
		call	fdc_read_inode
		ld	de,file_sector
		call	fd_read_block
		jr	nz,_1705
		call	process_header
		; Here we're just reading the file data.
		; First there are 9 more indices which point to data blocks
		; so read them each in turn.
		ld	b,009h
		call	_182d
		jr	nz,_1704
		; Next index is 1-level indirect so load that block of indices
		; and then go through all 128 from the sector.
		ld	de,idx_sector
		call	fd_read_block
		jr	nz,_1704
		ex	de,hl
		ld	b,080h
		call	_182d
		jr	nz,_1704
		ex	de,hl
		; Finally we end up with a 2-level indirect where we point
		; to a block of pointers to block of pointers to data sectors.
		ld	de,file_sector
		call	fd_read_block
		jr	nz,_1704
		ex	de,hl
		ld	b,080h
_16ee:		ld	de,idx_sector
		call	fd_read_block
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

; Read through the the root directory and "open" the file by returning
; its inode number in HL.  Return NZ if not found.

open_file:	ld	(_173f),hl
		ld	hl,2			; root directory inode
		call	fdc_read_inode
_1715:		ld	de,file_sector
		call	fd_read_block
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
		jr	z,_1733		; 0 inode means directory entry empty
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

_173f:		word	0

; TODO - can determine what most of the header bytes mean.

process_header:	push	bc
		push	de
		push	hl
		ld	(ix+f_load0),0
		ld	(ix+f_load1),0
		ld	(ix+f_load2),0
		ld	(ix+f_type),$ff	; file_type 68k
		ld	de,(file_sector)
		ld	hl,00602h
		or	a
		sbc	hl,de
		call	nz,hrdioe	; error if file does not start with $0206
		ld	bc,00020h	; minimal header size
		ld	de,(file_sector + 2)
		ld	h,e
		ld	l,d		; little endian extra header space?
		add	hl,bc
		ld	b,h
		ld	c,l		; BC is header size
		ld	a,(file_sector + 28)
		and	03fh
		cp	005h
		jr	z,_1795		; type 5 must be 58k kernel
		cp	006h
		call	nz,hrdioe	; must be type 5 or 6
		ld	hl,(file_sector + 42)
		ld	(ix+f_load0),h	; saving load address
		ld	(ix+f_load1),l
		ld	(ix+f_load2),0
		ld	(ix+f_type),0	; file_type Z-80
		ld	de,(file_sector + 26)
		ld	h,e
		ld	l,d		; Z-80 execution address in little endian
		ld	(z80ctl_entry),hl
_1795:		ld	hl,00200h
		or	a
		sbc	hl,bc
		push	hl		; data bytes left in sector
		ld	hl,file_sector
		add	hl,bc		; start of data
		pop	bc
		push	bc
		bit	0,(ix+f_type)	; file_type
		jr	z,_180b		; if Z-80 type then no PAL check
		push	bc
		push	hl
		ld	bc,(08000h)
		ld	de,$1234
		ld	(08000h),de
		ld	hl,(08000h)
		or	a
		sbc	hl,de
		jr	nz,no68k	; can't read 68000 mem?
		ld	a,(sh_de)
		or	001h		; enable burst mode
		out	(0deh),a
		ld	hl,(08000h)
		and	0feh
		out	(0deh),a
		or	a
		sbc	hl,de		; if != 0 then PAL is swapping, not bursting
		ld	(08000h),bc
; Make this "jr _1804" to disable check for new PAL with burst mode.
		jr	z,_1804
		call	bughlt
		ascii	'NewPal - Hardware Change Required',0
no68k:		call	bughlt
		ascii	'No68k',13,10,0
_1804:		pop	hl
		pop	bc
		call	copy_to_68k	; rest of sector to 68k
		jr	_1813

_180b:		ld	e,(ix+f_load0)	; get load address
		ld	d,(ix+f_load1)
		ldir			; copy in data from sector
_1813:		pop	bc
		ld	l,(ix+f_load0)
		ld	h,(ix+f_load1)
		add	hl,bc		; new load address
		ld	(ix+f_load0),l
		ld	(ix+f_load1),h
		ld	a,(ix+f_load2)
		adc	a,0
		ld	(ix+f_load2),a
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

; Guessing we take the 4 byte index at HL and read the associated
; sector into a buffer at DE.
; A 0 index results in Z=0 (NZ) on return.
; Otherwise returns Z indicating successful read.

fd_read_block:	push	bc
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
		call	v_fdc_read_sector
		or	0ffh
_1865:		xor	0ffh	; if jp then Z=0, fall through gives Z=1
		pop	hl
		pop	de
		pop	bc
		ret	

_186b:		push	bc
		push	de
		push	hl
		bit	0,(ix+f_type)	; file_type
		jr	z,_1883		; jump if Z80
		ld	de,tmp_sector	; for 68K must read to temp sector
		call	v_fdc_read_sector
		ld	bc,00200h
		ex	de,hl
		call	copy_to_68k	; and then load it into 68K memory
		jr	_188c

_1883:		ld	e,(ix+f_load0)	; Z-80 can read directly to load address
		ld	d,(ix+f_load1)
		call	v_fdc_read_sector
_188c:		ld	l,(ix+f_load1)
		ld	h,(ix+f_load2)
		ld	bc,2
		add	hl,bc		; add 512 to load address
		ld	(ix+f_load1),l
		ld	(ix+f_load2),h
		pop	hl
		pop	de
		pop	bc
		ret	

expand_idx:	xor	a
		ld	(de),a
		inc	de
		push	bc
		ldi	
		ldi	
		ldi	
		pop	bc
		djnz	expand_idx
		ret	

; Wildly guessing this reads inode HL from the floppy drive.
; Looks like we have 512 byte sectors and inodes are 64 bytes
; each.  Thus we divide by 8 to map from inode # to sector.
; And (inode# * 64) % 512 gives the position in the sector.
;
; Appears to ignore the first 12 bytes of the inode.  Then
; reads 13 sector pointers, 24 bits each.
;
; Returns HL pointing to the 13 sector pointers.

fdc_read_inode:	dec	hl		; From 1-based to 0 based index
		push	hl
		srl	h
		rr	l
		srl	h
		rr	l
		srl	h
		rr	l		; HL /= 8
		inc	hl
		inc	hl		; HL += 2
		xor	a
		ld	de,inode_sector
		call	v_fdc_read_sector
		pop	hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl		; HL *= 32
		ld	h,000h
		add	hl,hl		; HL *= 64 % 512
		ld	de,inode_sector + 12
		add	hl,de
		ld	b,00dh
		ld	de,file_idx
		push	de
		call	expand_idx
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

; Load 24 bit pointer at IX into PG:bc.
; Unlike z80ctl, this is a little-endian pointer.

load24:		push	bc
		ld	b,(ix+f_load1)
		ld	c,(ix+f_load0)
		set	7,b
		res	6,b
		push	bc
		ld	b,(ix+f_load1)
		rl	b
		ld	a,(ix+f_load2)
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

; Copy BC bytes from HL to 24 bit pointer at IX.

copy_to_68k:	push	ix
		push	bc
		push	de
		push	hl
		call	load24
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

hrdioe:		call	bughlt
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

		ascii	'fdiv'	; Frank Durda IV's "signature"

; These $e5 bytes are typically seen in a new sector and surely have
; no special meaning just padding out to a sector boundary.  So
; I've captured that in a macro.  Might mean to pad to a certain number
; of sectors instead.

		dc	256-low($),$e5

		end	start
