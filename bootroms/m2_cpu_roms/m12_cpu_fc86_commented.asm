; z80dasm 1.1.0
; command line: z80dasm -a -l -g 0 -t M12_cpu_fc86.bin

; Version 4

; Reassemble with: zmac m12_cpu_fc86_commented.asm
; Then zout/m12_cpu_fc86_commented.cim should be same as ../pskiroms/fc86.bin

; Boot ROM operation (roughly):
;	Minimal hardware init
;	Checksum ROM
;	Z-80 test
;	RAM test
;	Flush keyboard input
;	Seek all hard drives to cylinder 0
;	Seek all floppy drives to track 0
;	If hard drive detected:
;		Attempt to boot from hard drive
;		Go to floppy boot if ESC or BREAK key pressed during attempt
;	Attempt floppy boot
;
; Hard drive boot reads 512 byte sectors from drive 0, cylinder 0, head 0 into
; memory starting at address 0.  When it finds a sector that starts with the 14
; byte string "/* END BOOT */" it jumps to 14 bytes into that sector.
;
; Floppy drive boot reads all of drive 0, track 0 (26 x 256 byte sectors) into
; memory starting at 0xE00.  If sector 3 (loaded at 0x1000) starts with "BOOT"
; and sector 7 (loaded at 0x1400) starts with "DIAG" it calls 0x1404 (sector 7)
; and jumps to 0x1004 (sector 1) if that returns.
; If not then it throws a RS error (diskette not in Radio Shack format) and
; probably halts.  There's some broken code that looks like it wants to jump
; to the boot sector (0x1004) if ESC or BREAK is pressed but it fails to
; read the keyboard data.

;Source: Model II Technical Reference Manual 26-4921
;	 Model II Technical Reference Manual 26-4921 Revised Floppy Disk Controller SUPPLEMENT
;	 TRS Times January/February 1994

; HDA board
HDWRP:	equ	0xC0 ; Write  Protect Register - Read Only   
		     ;   bit 4 - Soft reset
		     ;   bit 3 - Device enable
		     ;   bit 2 - Wait state enable
		     ;   bit 1 - Set during a write
		     ;   bit 0 - Set during a read
HDCLR:	equ	0xC1 ; Control Register - Read/Write  
		     ;   bit 7 - Master drive 0 hardware write protect
		     ;   bit 6 - Slave drive 1 hardware write protect
		     ;   bit 5 - Slave drive 2 hardware write protect
		     ;   bit 4 - Slave drive 3 hardware write protect
		     ;   bit 3 - 
		     ;   bit 2 - 
		     ;   bit 1 - Hard disk write protect logic
		     ;   bit 0 - Interrupt request
HDDPR:	equ	0xC2 ; Device Present Register - Read Only
		     ;   bit 0 - Master drive 0
		     ;   bit 1 - Slave drive 1
		     ;   bit 2 - Slave drive 2
		     ;   bit 3 - Slave drive 3
HDSCB:	equ	0xC8 ; WD1002 Sector Buffer
HDERW:	equ	0xC9 ; WD1002 Error Reg./Write Precomp
HDSCT:	equ	0xCA ; WD1002 Sector Count
HDSCN:	equ	0xCB ; WD1002 Sector Number
HDCYL:	equ	0xCC ; WD1002 Cylinder Low
HDCYH:	equ	0xCD ; WD1002 Cylinder High
HDSDH:	equ	0xCE ; WD1002 Size/Drive/Head
HDCSTR:	equ	0xCF ; WD1002 Comamnd / Status Register
; FDC board
FDDFC:	equ	0xE0 ; Printer, FDD, FDC Interrupt Status
		     ;   bit 0: 0 = FDC is not interrupting, 1 = FDC is interrupting
		     ;   bit 1: 0 = single sided, 1 = double sided floppy disk
		     ;   bit 2: 0 = drive door not opened, 1 door openend
		     ;   bit 3: high to low transition resets some printers
		     ;   bit 4: 0 = printer fault, 1 = printer not fault
		     ;   bit 5: 0 = printer selected, 1 = printer not selected
		     ;   bit 6: 0 = printer paper not empty, 1 = paper empty 
		     ;   bit 7: 0 = printer ready, 1 = printer busy
FDCSC:	equ	0xE4 ; Command / Status Register
FDCTR:	equ	0xE5 ; Track Register
FDCSR:	equ	0xE6 ; Sector Register
FDCDT:	equ	0xE7 ; Data register
FDCSL:	equ	0xEF ; Drive select, Density select, and Side select
		     ;   bits 0-3 the drive select bits, active low.  
		     ;   bit 6 side select, High = side 0, Low = side 1
		     ;   bit 7 is 0 for FM, 1 for MFM. 
FDCRS:	equ	0xE8 ;   bit 0: Reset FDC on write (later WD1791 based boards)
; CPU board
CTC0:	equ	0xF0
CTC1:	equ	0xF1
CTC2:	equ	0xF2
CTC3:	equ	0xF3
SIOAD:	equ	0xF4
SIOBD:	equ	0xF5
SIOAC:	equ	0xF6
SIOBC:	equ	0xF7
DMA:	equ	0xF8
ROMEN:	equ	0xF9
; KBD/VDU board
KBD:	equ	0xFC	; Read Keyboard Data/Clear Keyboard interrupt (read only)
			; Load CRTC Address Register (write only)
CRTCD:	equ	0xFD	; CRTC Data Register 
RTCC:	equ	0xFE	; Clear Real Time Clock (RTC) Interrupt (read only)
KBVIDC:	equ	0xFF	; Non-maskable Interrupt Mask Register and Bank Select Register; 
			;   bit 7: (write only) RAM at F800h to FFFFh. 0 = Bank RAM, 1 = Video RAM
			;   bit 7: (read only)  Keyboard Interrupt.    0 = disable,  1 = enable
			;   bit 6: Video display.         0 = on, 1 = off
			;   bit 5: RTC interrupts.        0 = disabled, 1 = enabled
			;   bit 4: Character mode.        0 = 80 characters per line, 1 = 40 characters 
			;   bit 0 - 3: (write only) memory bank select, Bank 1 to 16.
; MEM board
MEMBNK:	equ	0xFF	;   bit 0 - 3: (write only) memory bank select, Bank 1 to 16.

	org	00000h

prog_start:
	di			;0000	f3 	. 
	ld sp,02800h		;0001	31 00 28 	1 . ( 
	ld a,080h		;0004	3e 80 	> . 
	out (0ffh),a		;0006	d3 ff 		Select video memory
	ld a,083h		;0008	3e 83 		Select DMA Write Register Group 6
	out (0f8h),a		;000a	d3 f8 		DMA
l000ch:
	ld a,0c3h		;000c	3e c3 		Generic Reset Interrupt and Bus Request Logic
	out (0f8h),a		;000e	d3 f8 		DMA
	out (0f8h),a		;0010	d3 f8 		DMA
	out (0f8h),a		;0012	d3 f8 		DMA
	out (0f8h),a		;0014	d3 f8 		DMA
	out (0f8h),a		;0016	d3 f8 		DMA
	ld a,003h		;0018	3e 03 	
	out (0f0h),a		;001a	d3 f0 		CTC0
	out (0f1h),a		;001c	d3 f1 		CTC1
	out (0f2h),a		;001e	d3 f2 		CTC2
	out (0f3h),a		;0020	d3 f3 		CTC3
	out (0e3h),a		;0022	d3 e3 		PIO Port B control
	out (0e2h),a		;0024	d3 e2 		PIO Port A control
	ld a,018h		;0026	3e 18 	
	out (0f6h),a		;0028	d3 f6 		SIOAC
	out (0f7h),a		;002a	d3 f7 		SIOBC
	ld bc,800h-1		;002c	01 ff 07 	Set up copy
	ld de,0fffeh		;002f	11 fe ff 	a value to
	ld hl,0ffffh		;0032	21 ff ff 	video memory
	ld (hl),0a0h		;0035	36 a0 		a white block
	lddr			;0037	ed b8 		do the copy
	ld bc,00ffch		;0039	01 fc 0f 	b: CRTC addr register value, c: CRTC address register
	ld hl,37eh		;003c	21 7e 03 	Set up CTRC register
l003fh:
	ld a,(hl)		;003f	7e 		values copy action:
	out (c),b		;0040	ed 41 		- select register
	out (0fdh),a		;0042	d3 fd 		- copy value
	dec hl			;0044	2b 		- select next value
	dec b			;0045	05 		- select next register
	jp p,l003fh		;0046	f2 3f 00 	until all registers are set
	xor a			;0049	af 		0
	ld bc,prog_end-prog_start ;004a	01 86 03 	
	ld hl,prog_start	;004d	21 00 00 	 
l0050h:
	add a,(hl)		;0050	86 		calculate ROM checksum
	ld d,a			;0051	57 		.
	inc hl			;0052	23 		.
	dec bc			;0053	0b 		.
	ld a,b			;0054	78 		.
	or c			;0055	b1 		. 
	ld a,d			;0056	7a 		.
	jr nz,l0050h		;0057	20 f7 	  	Loop until BC == 0
	or a			;0059	b7 	. 
	jp nz,l027fh		;005a	c2 7f 02 	Jump if sum != 0; CK error
	ld a,055h		;005d	3e 55 		CPU Test
	cpl			;005f	2f 		.
	or a			;0060	b7 		.
	and a			;0061	a7 		.
	ld b,a			;0062	47 		
	ld c,b			;0063	48 		.
	ld d,c			;0064	51 		.
	ld e,d			;0065	5a 		.
	ld h,e			;0066	63 		.
	ld l,h			;0067	6c 		.
	inc l			;0068	2c 		.
	dec l			;0069	2d 		.
	ex de,hl		;006a	eb 		. 
	ex af,af'		;006b	08 		. 
	ld a,e			;006c	7b 		.
	exx			;006d	d9 		. 
	ld b,a			;006e	47 		.
	ld c,b			;006f	48 		.
	ld d,c			;0070	51 		.
	ld e,d			;0071	5a 		.
	ld h,e			;0072	63 		.
	ld l,h			;0073	6c 		.
	ld a,l			;0074	7d 		.
	ld i,a			;0075	ed 47 		. 
	ld a,i			;0077	ed 57 		. 
	ld l,a			;0079	6f 		. 
	ex af,af'		;007a	08 		. 
	cp l			;007b	bd 		. 
	jp nz,l0284h		;007c	c2 84 02 	Jump to Z8 - Defective CPU message routine
	ld bc,07000h		;007f	01 00 70 	Start memory test
	ld hl,01000h		;0082	21 00 10 	.
	ld d,h			;0085	54 		.
	ld e,l			;0086	5d 		.
l0087h:
	ld a,(de)		;0087	1a 		. 
	cpl			;0088	2f 		.
	ld (de),a		;0089	12 		. 
	cp (hl)			;008a	be 		. 
	cpl			;008b	2f 		.
	ld (hl),a		;008c	77 		.
	jp nz,l0289h		;008d	c2 89 02 	Jump to MF = Memory failure message routine
	ldi			;0090	ed a0 		Block copy
	jp pe,l0087h		;0092	ea 87 00 	loop
	ld d,0c8h		;0095	16 c8 	
l0097h:
	in a,(0ffh)		;0097	db ff 		Get video status
	bit 7,a			;0099	cb 7f 		Check key available
	jr z,l009fh		;009b	28 02 		
	in a,(0fch)		;009d	db fc 		Get keyboard data
l009fh:
	ld bc,00080h		;009f	01 80 00 	
	call sub_02c8h		;00a2	cd c8 02 	Delay
	dec d			;00a5	15 	. 
	jr nz,l0097h		;00a6	20 ef 	  . 
	xor a			;00a8	af 	. 
	out (0c1h),a		;00a9	d3 c1 		HDA Control register
	ld a,000h		;00ab	3e 00 	> . 
	out (0c1h),a		;00ad	d3 c1 		HDA Control register
	ld a,00fh		;00af	3e 0f 	> . 
	out (0c1h),a		;00b1	d3 c1 		HDA Control register
	in a,(0c2h)		;00b3	db c2 		Device Present Register
	and 00fh		;00b5	e6 0f 	. . 
	jr z,l00dah		;00b7	28 21 		
	ld bc,0438h		;00b9	01 38 04 	C: head 000, drive 11, sector size 01
l00bch:
	ld a,c			;00bc	79 	y 
	out (0ceh),a		;00bd	d3 ce 		WD1002 Size/Drive/Head
	ld a,01fh		;00bf	3e 1f 		Restore (TSR:40ms)
	out (0cfh),a		;00c1	d3 cf 		WD1002 Command Register
	call sub_02f7h		;00c3	cd f7 02 	
	xor a			;00c6	af 	. 	0
	out (0cdh),a		;00c7	d3 cd 		WD1002 Cylinder High
	ld a,005h		;00c9	3e 05 		5
	out (0cch),a		;00cb	d3 cc 		WD1002 Cylinder Low
	ld a,073h		;00cd	3e 73 		Seek, Update Tr, (TSR: 1.5 ms)
	out (0cfh),a		;00cf	d3 cf 		WD1002 Command Register
	call sub_02f7h		;00d1	cd f7 02 	Wait for SEEK COMPLETE
	ld a,c			;00d4	79 		
	sub 008h		;00d5	d6 08 		Select next drive
	ld c,a			;00d7	4f 		
	djnz l00bch		;00d8	10 e2 		Try again for 4 drives
l00dah:
	ld b,004h		;00da	06 04 	. . 
	ld de,040f7h		;00dc	11 f7 40 	. . @ 
l00dfh:
	push bc			;00df	c5 	. 
	push de			;00e0	d5 	. 
	ld a,e			;00e1	7b 	{ 
	and 00fh		;00e2	e6 0f 	. . 
	or d			;00e4	b2 	. 
	out (0efh),a		;00e5	d3 ef 		? Alias FDC register
	call sub_02ceh		;00e7	cd ce 02 	. . . 
	xor a			;00ea	af 	. 
	out (0e5h),a		;00eb	d3 e5 		FDC Track Register
	ld a,005h		;00ed	3e 05 	> . 
	out (0e7h),a		;00ef	d3 e7 		FDC Data Register
	ld a,013h		;00f1	3e 13 	> . 
	out (0e4h),a		;00f3	d3 e4 		FDC Status Register
	call sub_0319h		;00f5	cd 19 03 	
	pop de			;00f8	d1 	. 
	rrc e			;00f9	cb 0b 	. . 
	pop bc			;00fb	c1 	. 
	djnz l00dfh		;00fc	10 e1 	. . 
	in a,(0c2h)		;00fe	db c2 		HDA Device Present Register - Read Only
	and 00fh		;0100	e6 0f 	. . 
	jp z,l01b5h		;0102	ca b5 01 	Jump to floppy boot
	ld d,015h		;0105	16 15 	. . 
l0107h:
	in a,(0cfh)		;0107	db cf 		WD1002 Status Register
	bit 6,a			;0109	cb 77 		Ready bit
	jr nz,l011bh		;010b	20 0e 	  	Continue if true
	call sub_02e8h		;010d	cd e8 02 	Check keyboard for ESC or BREAK
	jp z,l01b5h		;0110	ca b5 01 	Jump to floppy boot
	call sub_02c8h		;0113	cd c8 02 	. . . 
	dec d			;0116	15 	. 
	jr nz,l0107h		;0117	20 ee 	  	loop
	jr l0170h		;0119	18 55 	. U 
l011bh:
	call sub_02e8h		;011b	cd e8 02 	Check keyboard for ESC or BREAK
	jp z,l01b5h		;011e	ca b5 01 	Jump to floppy boot
	ld a,01fh		;0121	3e 1f 	> . 
	out (0cfh),a		;0123	d3 cf 	. . 
	call sub_02f7h		;0125	cd f7 02 	. . . 
	jr nz,l018eh		;0128	20 64 	  d 
	ld hl,0			;012a	21 00 00 	! . . 
	ld bc,01cbh		;012d	01 cb 01 	. . . 
; Read sectors 1 and up from the current track into address 0 and up.  Stop
; when we find one that starts with "/* END BOOT */".  Start executing code
; right after that marker message (i.e., 14 bytes into the sector)
l0130h:
	ld d,h			;0130	54 	T 
	ld e,l			;0131	5d 	] 
	out (c),b		;0132	ed 41 	. A 	WD1002 sector
	ld a,020h		;0134	3e 20 	>   
	out (0cfh),a		;0136	d3 cf 	. . 	WD1002 command (read sector?)
	call sub_02f7h		;0138	cd f7 02 	. . . 
	jr nz,l0174h		;013b	20 37 	  7 
l013dh:
	in a,(0cfh)		;013d	db cf 		WD1002 Status Register
	bit 3,a			;013f	cb 5f 		DRQ?
	jr z,l013dh		;0141	28 fa 		Wait until Data Request bit is set
	call sub_02e8h		;0143	cd e8 02 	Check keyboard for ESC or BREAK
	jr z,l01b5h		;0146	28 6d 		Jump to floppy boot
	inc b			;0148	04 	. 
	push bc			;0149	c5 	. 
	ld a,002h		;014a	3e 02 	> . 
	ld bc,000c8h		;014c	01 c8 00 	WD1002 Data Register
	inir		;014f	ed b2 	. . 
	inir		;0151	ed b2 	. . 
	push hl			;0153	e5 	. 
	ld hl,end_boot_str	;0154	21 40 03 	! @ . 
	ld b,00eh		;0157	06 0e 	. . 
	call memcmp		;0159	cd e0 02 	. . . 
	pop hl			;015c	e1 	. 
	pop bc			;015d	c1 	. 
	jr nz,l0130h		;015e	20 d0 	  . 
	ld bc,0			;0160	01 00 00 	. . . 
	call sub_02c8h		;0163	cd c8 02	Some delay
	call sub_02e8h		;0166	cd e8 02	ESC or BREAK pressed?
	jr z,l01b5h		;0169	28 4a 		
	xor a			;016b	af 	. 
	out (0c1h),a		;016c	d3 c1 	. . 
	ex de,hl		;016e	eb 	. 	DE = 14 bytes into last sector
	jp (hl)			;016f	e9 	. 
l0170h:
	ld e,054h		;0170	1e 54 	. T 
	jr l019ah		;0172	18 26 	. & 
l0174h:
	bit 6,a		;0174	cb 77 	. w 
	ld e,'C'		;0176	1e 43 	. C 
	jr nz,l019ah		;0178	20 20 	    
	bit 5,a		;017a	cb 6f 	. o 
	ld e,'I'		;017c	1e 49 	. I 
	jr nz,l019ah		;017e	20 1a 	  . 
	bit 4,a		;0180	cb 67 	. g 
	ld e,'N'		;0182	1e 4e 	. N 
	jr nz,l019ah		;0184	20 14 	  . 
	bit 2,a		;0186	cb 57 	. W 
	ld e,'A'		;0188	1e 41 	. A 
	jr nz,l019ah		;018a	20 0e 	  . 
	bit 1,a		;018c	cb 4f 	. O 
l018eh:
	ld e,'0'		;018e	1e 30 	. 0 
	jr nz,l019ah		;0190	20 08 	  . 
	bit 0,a		;0192	cb 47 	. G 
	ld e,'M'		;0194	1e 4d 	. M 
	jr nz,l019ah		;0196	20 02 	  . 
	ld e,'D'		;0198	1e 44 	. D 
l019ah:
	ld d,'H'		;019a	16 48 	. H 
	ld hl,0fb9ah		;019c	21 9a fb 	! . . 
	ld (hl),d			;019f	72 	r 
	inc hl			;01a0	23 	# 
	ld (hl),e			;01a1	73 	s 
	inc hl			;01a2	23 	# 
	ld (hl),020h		;01a3	36 20 	6   
	ld hl,l034eh		;01a5	21 4e 03 	! N . 
	ld de,0fb8eh		;01a8	11 8e fb 	. . . 
	ld bc,l000ch		;01ab	01 0c 00 	. . . 
	ldir		;01ae	ed b0 	. . 
l01b0h:
	call sub_02e8h		;01b0	cd e8 02 	. . . 
	jr nz,l01b0h		;01b3	20 fb 	  . 
l01b5h:
	ld sp,02000h		;01b5	31 00 20 	1 .   
	xor a			;01b8	af 	. 
	out (0c1h),a		;01b9	d3 c1 		HDA Control Register - Read/Write
	ld a,04eh		;01bb	3e 4e 	> N 
	out (0efh),a		;01bd	d3 ef 		Select drive 0, FM mode, side 0
	ld hl,0035ah		;01bf	21 5a 03 	Point to 'INSERT DISKETTE'
	ld de,0fb8eh		;01c2	11 8e fb 	Point to somewhere in video memory
	ld bc,00011h		;01c5	01 11 00 	message size 
	ldir			;01c8	ed b0 		Copy it
l01cah:
	call sub_02ceh		;01ca	cd ce 02 	Reset FDC
	bit 7,a			;01cd	cb 7f 	. 	FDC Status Register NOT READY
	jr nz,l01cah		;01cf	20 f9 	  	loop
	ld bc,800h-1		;01d1	01 ff 07 	Set up block
	ld de,0fffeh		;01d4	11 fe ff 	copy to clear
	ld hl,0ffffh		;01d7	21 ff ff 	video memory
	ld (hl),020h		;01da	36 20 		with spaces
	lddr			;01dc	ed b8 		Copy it
	call sub_02ceh		;01de	cd ce 02 	Reset FDC
	ld a,00bh		;01e1	3e 0b 		? Write Sector, multiple records?
	out (0e4h),a		;01e3	d3 e4 		FDC Command Register
	ld d,007h		;01e5	16 07 	. . 
l01e7h:
	call sub_02c8h		;01e7	cd c8 02 	Some delay
	in a,(0e4h)		;01ea	db e4 		FDC Status Register
	bit 0,a			;01ec	cb 47 		BUSY ?
	jr z,l01f3h		;01ee	28 03 		Continue if not
	dec d			;01f0	15 	 	
	jr nz,l01e7h		;01f1	20 f4 	  	loop
l01f3h:
	in a,(0e4h)		;01f3	db e4 		FDC Status Register
	push af			;01f5	f5 	. 
	xor 004h		;01f6	ee 04 	. . 
	and 015h		;01f8	e6 15 	. . 
	jr nz,l0270h		;01fa	20 74 	  	Jump to DC = 'Floppy disk controller error' message routine
	pop af			;01fc	f1 	. 
	bit 7,a		;01fd	cb 7f 			NOT READY
	jr nz,l0275h		;01ff	20 74 	  	Jump to D0 = 'Drive not ready' message routine
	bit 3,a		;0201	cb 5f 			CRC ERROR
	jr nz,l027ah		;0203	20 75 	  	Jump to SC = 'CRC Error' message routine
	ld hl,00e00h		;0205	21 00 0e 	
	ld de,01a28h		;0208	11 28 1a 	D = # of sectors (full track)
	ld bc,08001h		;020b	01 01 80 	C = sector #
	ld a,080h		;020e	3e 80 		
	ex af,af'		;0210	08 		
l0211h:
	push hl			;0211	e5 		
	push de			;0212	d5 		
	push bc			;0213	c5 		
	call sub_02ceh		;0214	cd ce 02 	Reset FDC
	ld a,c			;0217	79 		1
	out (0e6h),a		;0218	d3 e6 		FDC Sector Register
	ex af,af'		;021a	08 		Read Sector
	out (0e4h),a		;021b	d3 e4 		FDC Command Register
	ex af,af'		;021d	08 	. 
	call sub_02c5h		;021e	cd c5 02 	Some delay
	pop bc			;0221	c1 		
	push bc			;0222	c5 		
	ld c,0e7h		;0223	0e e7 		FDC Data Register
l0225h:
	in a,(0e4h)		;0225	db e4 		FDC Status Register
	bit 1,a			;0227	cb 4f 		DRQ
	jr z,l022fh		;0229	28 04 		
	ini			;022b	ed a2 		Block read sector to 0e00h?
	jr z,l0233h		;022d	28 04 		Continue 
l022fh:
	bit 0,a			;022f	cb 47 		BUSY
	jr nz,l0225h		;0231	20 f2 	  	Try again
l0233h:
	pop bc			;0233	c1 		
	pop de			;0234	d1 		
	in a,(0e4h)		;0235	db e4 		FDC Status Register
	and 01ch		;0237	e6 1c 		00011100b keep only error bits
	jr z,l0249h		;0239	28 0e 		
	pop hl			;023b	e1 		
	dec e			;023c	1d 		
	jr nz,l0211h		;023d	20 d2 	  	
	bit 4,a			;023f	cb 67 		SEEK ERROR
	jr nz,l028eh		;0241	20 4b 	  	Jump to 'TK = Record not found bootstrap track error' routine
	bit 3,a			;0243	cb 5f 		CRC ERROR
	jr nz,l027ah		;0245	20 33 	  	Jump to SC = 'CRC Error' message routine
	jr l0293h		;0247	18 4a 		Jump to LD = 'Lost data during read' message routine
l0249h:
	pop af			;0249	f1 		
	inc c			;024a	0c 		next sector
	ld e,028h		;024b	1e 28 		
	dec d			;024d	15 		
	jr nz,l0211h		;024e	20 c1 	  	
	ld hl,l034fh		;0250	21 4f 03 	"BOOT"
	ld de,01000h		;0253	11 00 10 	sector 3
	ld b,004h		;0256	06 04 		
	call memcmp		;0258	cd e0 02 	
	jr nz,l0298h		;025b	20 3b 	  ; 	Jump to RS = 'Diskette not RS format error' routine
	ld hl,l036bh		;025d	21 6b 03 	"DIAG"
	ld de,01400h		;0260	11 00 14 	sector 7
	ld b,004h		;0263	06 04 	 
	call memcmp		;0265	cd e0 02 	
	jr nz,l0298h		;0268	20 2e 	  	Jump to RS = 'Diskette not RS format' error routine
	call 01404h		;026a	cd 04 14 	
	jp 01004h		;026d	c3 04 10 	
l0270h:
	ld de,04443h		;0270	11 43 44 	C D ; DC = Floppy disk controller error.
	jr l029bh		;0273	18 26 		
l0275h:
	ld de,04430h		;0275	11 30 44 	0 D ; D0 = Drive not ready
	jr l029bh		;0278	18 21 	
l027ah:
	ld de,05343h		;027a	11 43 53 	. C S ; SC = CRC Error
	jr l029bh		;027d	18 1c 	. . 
l027fh:
	ld de,0434bh		;027f	11 4b 43 	. K C ; CK = ROM checksum error
	jr l029fh		;0282	18 1b 	. . 
l0284h:
	ld de,05a38h		;0284	11 38 5a 	. 8 Z ; Z8 = Defective CPU
	jr l029fh		;0287	18 16 	. . 
l0289h:
	ld de,04d46h		;0289	11 46 4d 	. F M ; MF = Memory failure
	jr l029fh		;028c	18 11 	. . 
l028eh:
	ld de,0544bh		;028e	11 4b 54 	. K T ; TK = Record not found bootstrap track
	jr l029bh		;0291	18 08 	. . 
l0293h:
	ld de,04c44h		;0293	11 44 4c 	. D L ; LD = Lost data during read
	jr l029bh		;0296	18 03 	. . 
l0298h:
	ld de,05253h		;0298	11 53 52 	. S R ; RS = Diskette not RS format
l029bh:
	ld a,04fh		;029b	3e 4f 	> O 
	out (0efh),a		;029d	d3 ef 	. . 	Deselect floppy drives
l029fh:
	ld hl,0fb9ah		;029f	21 9a fb 	! . . 
	ld (hl),d			;02a2	72 	r 
	inc hl			;02a3	23 	# 
	ld (hl),e			;02a4	73 	s 
	inc hl			;02a5	23 	# 
	ld (hl),020h		;02a6	36 20 	6   
	ld hl,l034eh		;02a8	21 4e 03 	! N . 
	ld de,0fb8eh		;02ab	11 8e fb 	. . . 
	ld bc,l000ch		;02ae	01 0c 00 	. . . 
	ldir		;02b1	ed b0 	. . 
	in a,(0ffh)		;02b3	db ff 		
	bit 7,a			;02b5	cb 7f 		Keyboard input available?
	jr z,l02c3h		;02b7	28 0a 		No key, jump to HALT
; Seems like a bug here where they meant to "in a,(0fch)" to get a keyboard
; scan code.  Comparing for ESC and BREAK keys makes way more sense.
	cp 01bh			;02b9	fe 1b 		If 40 char mode & MEM bank B selected
	jp z,01004h		;02bb	ca 04 10 	Jump to boot sector?
	cp 003h			;02be	fe 03 		If MEM bank 3 selected
	jp z,01004h		;02c0	ca 04 10 	Jump to boot sector?
l02c3h:
	halt			;02c3	76 	v 
	rst 0			;02c4	c7 	. 
sub_02c5h:
	ld bc,00005h		;02c5	01 05 00 	. . . 
sub_02c8h:					; Delay
	dec bc			;02c8	0b 	. 
	ld a,b			;02c9	78 	x 
	or c			;02ca	b1 	. 
	jr nz,sub_02c8h		;02cb	20 fb 	  . 
	ret			;02cd	c9 	. 
sub_02ceh:			;		Reset FDC
	push bc			;02ce	c5 		
	ld a,0d8h		;02cf	3e d8 		Force Interrupt, immediate
	out (0e4h),a		;02d1	d3 e4 		to FDC Command Register
	ld a,0d0h		;02d3	3e d0 		Force Interrupt, reset busy, clear Load Command and Read Status Registers
	out (0e4h),a		;02d5	d3 e4 		to FDC Command Register
	call sub_0319h		;02d7	cd 19 03 	Short delay
	in a,(0e7h)		;02da	db e7 		FDC Data Register
	in a,(0e4h)		;02dc	db e4 		FDC Status Register
	pop bc			;02de	c1 		
	ret			;02df	c9 	
; Compare B bytes at HL and DE.  Return Z if equal, NZ otherwise.
memcmp:
	ld a,(de)		;02e0	1a 	. 
	cp (hl)			;02e1	be 	. 
	ret nz			;02e2	c0 	. 
	inc hl			;02e3	23 	# 
	inc de			;02e4	13 	. 
	djnz memcmp		;02e5	10 f9 	. . 
	ret			;02e7	c9 	. 
sub_02e8h:
	in a,(0ffh)		;02e8	db ff 		Keyboard data available?
	xor 080h		;02ea	ee 80 		
	bit 7,a			;02ec	cb 7f
	ret nz			;02ee	c0 		Return if no key
	in a,(0fch)		;02ef	db fc 		Read keyboard
	cp 01bh			;02f1	fe 1b 		Is the ESC key.
	ret z			;02f3	c8 		Return if so
	cp 003h			;02f4	fe 03 		Is the BREAK key?
	ret			;02f6	c9 	. 
sub_02f7h:
	push bc			;02f7	c5 	. 
	ld bc,07fffh		;02f8	01 ff 7f 	. .  
l02fbh:
	in a,(0cfh)		;02fb	db cf 		WD1002 Status Register
	bit 7,a			;02fd	cb 7f 		Busy?
	jr nz,l0305h		;02ff	20 04 	 
	bit 4,a			;0301	cb 67 		Seek complete?
	jr nz,l0312h		;0303	20 0d 	  . 
l0305h:
	ex (sp),ix		;0305	dd e3 	. . 
	ex (sp),ix		;0307	dd e3 	. . 
	dec bc			;0309	0b 	. 
	ld a,b			;030a	78 	x 
	or c			;030b	b1 	. 
	jr nz,l02fbh		;030c	20 ed 	  . 
	or 008h		;030e	f6 08 	. . 
	pop bc			;0310	c1 	. 
	ret			;0311	c9 	. 
l0312h:
	pop bc			;0312	c1 	. 
	bit 0,a		;0313	cb 47 	. G 
	ret z			;0315	c8 	. 
	in a,(0c9h)		;0316	db c9 	. . 
	ret			;0318	c9 	. 
sub_0319h:
	push af			;0319	f5 	. 
	in a,(0e4h)		;031a	db e4 	. . 
	push bc			;031c	c5 	. 
	ld bc,00005h		;031d	01 05 00 	. . . 
l0320h:
	rra			;0320	1f 	. 
	jr c,l032ah		;0321	38 07 	8 . 
	dec bc			;0323	0b 	. 
	ld a,b			;0324	78 	x 
	or c			;0325	b1 	. 
	in a,(0e4h)		;0326	db e4 	. . 
	jr nz,l0320h		;0328	20 f6 	  . 
l032ah:
	ld bc,0			;032a	01 00 00 	. . . 
l032dh:
	dec bc			;032d	0b 	. 
	ld a,b			;032e	78 	x 
	or c			;032f	b1 	. 
	jr z,l033ah		;0330	28 08 	( . 
	in a,(0e4h)		;0332	db e4 	. . 
	rra			;0334	1f 	. 
	jr c,l032dh		;0335	38 f6 	8 . 
	pop bc			;0337	c1 	. 
	pop af			;0338	f1 	. 
	ret			;0339	c9 	. 
l033ah:
	pop af			;033a	f1 	. 
	pop af			;033b	f1 	. 
	pop af			;033c	f1 	. 
	jp l0270h		;033d	c3 70 02 	. p . 
end_boot_str:
	ascii	"/* END BOOT */"
l034eh:
	ascii	" "
l034fh:
	ascii	"BOOT ERROR  INSERT DISKETTE "
l036bh:
	ascii	"DIAG"
				; 	CRTC register values
	defb	99		;036f	63 	0  Horizontal Total
	defb	80		;0370	50 	1  Horizontal Displayed (80 char.)
	defb	85		;0371	55 	2  H. Sync Position
	defb	8		;0372	08 	3  H. Sync Width
	defb	25		;0373	19 	4  Vertical Total (25 lines)
	defb	0		;0374	00 	5  V. Total Adjust
	defb	18h		;0375	18 	7  V.Sync Position,
	defb	18h		;0376	18 	6  Vertical Displacement
	defb	0		;0377	00 	8  Interlace Mode
	defb	9		;0378	09 	9  Max Scan Line Address
	defb	65h		;0379	65 	a  Cursor Start
	defb	9		;037a	09 	b  Cursor End
	defb	0		;037b	00 	c  Start Address (H)
	defb	0		;037c	00 	d  Start Address (L)
	defb	3		;037d	03 	e  Cursor (H)
	defb	0e9h		;037e	e9 	f  Cursor (L)

	defb	4		;037f	04 	Version?
	defb	82h		;0380	82 	YY?
	defb	11h,18h,13h	;0381	11 18 13 	MM? DD? 
	defb	30h,10h		;0384	30 10 	0 . 
prog_end:
	dc	800h-$,0ffh	; pad rest of 2K ROM with $ff
