; z80dasm 1.1.0
; command line: z80dasm -a -l -g 0 -t M12_cpu_fc86.bin

; Version 4

;Source: Model II Technical Reference Manual 26-4921
;	 Model II Technical Reference Manual 26-4921 Revised Floppy Disk Controller SUPPLEMENT
;	 TRS Times Januari/February 1994

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

l0000h:
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
	out (0e3h),a		;0022	d3 e3 		? alias of Printer, FDD, FDC Interrupt Status
	out (0e2h),a		;0024	d3 e2 		? alias of Printer, FDD, FDC Interrupt Status
	ld a,018h		;0026	3e 18 	
	out (0f6h),a		;0028	d3 f6 		SIOAC
	out (0f7h),a		;002a	d3 f7 		SIOBC
	ld bc,l07ffh		;002c	01 ff 07 	Set up copy
	ld de,0fffeh		;002f	11 fe ff 	a value to
	ld hl,0ffffh		;0032	21 ff ff 	video memory
	ld (hl),0a0h		;0035	36 a0 		a white block
	lddr			;0037	ed b8 		do the copy
	ld bc,00ffch		;0039	01 fc 0f 	b: CRTC addr register value, c: CRTC address register
	ld hl,l037eh		;003c	21 7e 03 	Set up CTRC register
l003fh:
	ld a,(hl)		;003f	7e 		values copy action:
	out (c),b		;0040	ed 41 		- select register
	out (0fdh),a		;0042	d3 fd 		- copy value
	dec hl			;0044	2b 		- select next value
	dec b			;0045	05 		- select next register
	jp p,l003fh		;0046	f2 3f 00 	until all registers are set
	xor a			;0049	af 		0
	ld bc,l0386h		;004a	01 86 03 	
	ld hl,l0000h		;004d	21 00 00 	 
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
	jp nz,l027fh		;005a	c2 7f 02 	Jump if sum != 0; KC error
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
	bit 7,a			;0099	cb 7f 		Check video RAM enabled
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
	ld bc,l0438h		;00b9	01 38 04 	. 8 . 
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
	sub 008h		;00d5	d6 08 		
	ld c,a			;00d7	4f 		
	djnz l00bch		;00d8	10 e2 		Try again
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
	jp z,l01b5h		;0102	ca b5 01 	. . . 
	ld d,015h		;0105	16 15 	. . 
l0107h:
	in a,(0cfh)		;0107	db cf 		WD1002 Status Register
	bit 6,a			;0109	cb 77 		Ready bit
	jr nz,l011bh		;010b	20 0e 	  	Continue if true
	call sub_02e8h		;010d	cd e8 02 	. . . 
	jp z,l01b5h		;0110	ca b5 01 	. . . 
	call sub_02c8h		;0113	cd c8 02 	. . . 
	dec d			;0116	15 	. 
	jr nz,l0107h		;0117	20 ee 	  	loop
	jr l0170h		;0119	18 55 	. U 
l011bh:
	call sub_02e8h		;011b	cd e8 02 	. . . 
	jp z,l01b5h		;011e	ca b5 01 	. . . 
	ld a,01fh		;0121	3e 1f 	> . 
	out (0cfh),a		;0123	d3 cf 	. . 
	call sub_02f7h		;0125	cd f7 02 	. . . 
	jr nz,l018eh		;0128	20 64 	  d 
	ld hl,l0000h		;012a	21 00 00 	! . . 
	ld bc,l01cah+1		;012d	01 cb 01 	. . . 
l0130h:
	ld d,h			;0130	54 	T 
	ld e,l			;0131	5d 	] 
	out (c),b		;0132	ed 41 	. A 
	ld a,020h		;0134	3e 20 	>   
	out (0cfh),a		;0136	d3 cf 	. . 
	call sub_02f7h		;0138	cd f7 02 	. . . 
	jr nz,l0174h		;013b	20 37 	  7 
l013dh:
	in a,(0cfh)		;013d	db cf 		WD1002 Status Register
	bit 3,a			;013f	cb 5f 		DRQ?
	jr z,l013dh		;0141	28 fa 		Wait until Data Request bit is set
	call sub_02e8h		;0143	cd e8 02 	Check keyboard for ESC & ETX
	jr z,l01b5h		;0146	28 6d 		Jump to floppy boot
	inc b			;0148	04 	. 
	push bc			;0149	c5 	. 
	ld a,002h		;014a	3e 02 	> . 
	ld bc,000c8h		;014c	01 c8 00 	. . . 
	inir		;014f	ed b2 	. . 
	inir		;0151	ed b2 	. . 
	push hl			;0153	e5 	. 
	ld hl,l0340h		;0154	21 40 03 	! @ . 
	ld b,00eh		;0157	06 0e 	. . 
	call sub_02e0h		;0159	cd e0 02 	. . . 
	pop hl			;015c	e1 	. 
	pop bc			;015d	c1 	. 
	jr nz,l0130h		;015e	20 d0 	  . 
	ld bc,l0000h		;0160	01 00 00 	. . . 
	call sub_02c8h		;0163	cd c8 02 	Video enabled, ESC or ETX pressed?
	call sub_02e8h		;0166	cd e8 02 	Some delay
	jr z,l01b5h		;0169	28 4a 		
	xor a			;016b	af 	. 
	out (0c1h),a		;016c	d3 c1 	. . 
	ex de,hl			;016e	eb 	. 
	jp (hl)			;016f	e9 	. 
l0170h:
	ld e,054h		;0170	1e 54 	. T 
	jr l019ah		;0172	18 26 	. & 
l0174h:
	bit 6,a		;0174	cb 77 	. w 
	ld e,043h		;0176	1e 43 	. C 
	jr nz,l019ah		;0178	20 20 	    
	bit 5,a		;017a	cb 6f 	. o 
	ld e,049h		;017c	1e 49 	. I 
	jr nz,l019ah		;017e	20 1a 	  . 
	bit 4,a		;0180	cb 67 	. g 
	ld e,04eh		;0182	1e 4e 	. N 
	jr nz,l019ah		;0184	20 14 	  . 
	bit 2,a		;0186	cb 57 	. W 
	ld e,041h		;0188	1e 41 	. A 
	jr nz,l019ah		;018a	20 0e 	  . 
	bit 1,a		;018c	cb 4f 	. O 
l018eh:
	ld e,030h		;018e	1e 30 	. 0 
	jr nz,l019ah		;0190	20 08 	  . 
	bit 0,a		;0192	cb 47 	. G 
	ld e,04dh		;0194	1e 4d 	. M 
	jr nz,l019ah		;0196	20 02 	  . 
	ld e,044h		;0198	1e 44 	. D 
l019ah:
	ld d,048h		;019a	16 48 	. H 
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
	ld bc,l07ffh		;01d1	01 ff 07 	Set up block
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
	ld de,01a28h		;0208	11 28 1a 	
	ld bc,08001h		;020b	01 01 80 	
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
	ld c,0e7h		;0223	0e e7 		
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
	inc c			;024a	0c 		
	ld e,028h		;024b	1e 28 		
	dec d			;024d	15 		
	jr nz,l0211h		;024e	20 c1 	  	
	ld hl,l034eh+1		;0250	21 4f 03 	
	ld de,01000h		;0253	11 00 10 	
	ld b,004h		;0256	06 04 		
	call sub_02e0h		;0258	cd e0 02 	
	jr nz,l0298h		;025b	20 3b 	  ; 	Jump to RS = 'Diskette not RS format error' routine
	ld hl,0036bh		;025d	21 6b 03 	
	ld de,01400h		;0260	11 00 14 	
	ld b,004h		;0263	06 04 	 
	call sub_02e0h		;0265	cd e0 02 	
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
	in a,(0ffh)		;02b3	db ff 		Get Video state
	bit 7,a			;02b5	cb 7f 		If video RAM disabled
	jr z,l02c3h		;02b7	28 0a 		Jump to HALT
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
sub_02e0h:
	ld a,(de)		;02e0	1a 	. 
	cp (hl)			;02e1	be 	. 
	ret nz			;02e2	c0 	. 
	inc hl			;02e3	23 	# 
	inc de			;02e4	13 	. 
	djnz sub_02e0h		;02e5	10 f9 	. . 
	ret			;02e7	c9 	. 
sub_02e8h:
	in a,(0ffh)		;02e8	db ff 		Get Video status
	xor 080h		;02ea	ee 80 		
	bit 7,a			;02ec	cb 7f 		Is video RAM enabled?
	ret nz			;02ee	c0 		Return if true
	in a,(0fch)		;02ef	db fc 		Read keyboard
	cp 01bh			;02f1	fe 1b 		Is it ESC?
	ret z			;02f3	c8 		Return if so
	cp 003h			;02f4	fe 03 		Is it ETX?
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
	ld bc,l0000h		;032a	01 00 00 	. . . 
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
l0340h:
	cpl			;0340	2f 	/ 
	ld hl,(04520h)		;0341	2a 20 45 	*   E 
	ld c,(hl)			;0344	4e 	N 
	ld b,h			;0345	44 	D 
	jr nz,l038ah		;0346	20 42 	  B 
	ld c,a			;0348	4f 	O 
	ld c,a			;0349	4f 	O 
	ld d,h			;034a	54 	T 
	jr nz,l0377h		;034b	20 2a 	  * 
	cpl			;034d	2f 	/ 
l034eh:
	jr nz,l0392h		;034e	20 42 	  B 
	ld c,a			;0350	4f 	O 
	ld c,a			;0351	4f 	O 
	ld d,h			;0352	54 	T 
	jr nz,l039ah		;0353	20 45 	  E 
	ld d,d			;0355	52 	R 
	ld d,d			;0356	52 	R 
	ld c,a			;0357	4f 	O 
	ld d,d			;0358	52 	R 
	jr nz,l037bh		;0359	20 20 	    
	ld c,c			;035b	49 	I 
	ld c,(hl)			;035c	4e 	N 
	ld d,e			;035d	53 	S 
	ld b,l			;035e	45 	E 
	ld d,d			;035f	52 	R 
	ld d,h			;0360	54 	T 
	jr nz,l03a7h		;0361	20 44 	  D 
	ld c,c			;0363	49 	I 
	ld d,e			;0364	53 	S 
	ld c,e			;0365	4b 	K 
	ld b,l			;0366	45 	E 
	ld d,h			;0367	54 	T 
	ld d,h			;0368	54 	T 
	ld b,l			;0369	45 	E 
	jr nz,l03b0h		;036a	20 44 	  D 
	ld c,c			;036c	49 	I 
	ld b,c			;036d	41 	A 
	ld b,a			;036e	47 	G 
				; 	CRTC register values
	ld h,e			;036f	63 	0  Horizontal Total
	ld d,b			;0370	50 	1  Horizontal Displayed (80 char.)
	ld d,l			;0371	55 	2  H. Sync Position
	ex af,af'		;0372	08 	3  H. Sync Width
	add hl,de		;0373	19 	4  Vertical Total (25 lines)
	nop			;0374	00 	5  V. Total Adjust
	jr l038fh		;0375	18 18 	7  V.Sync Position, 6  Vertical Displacement
l0377h:
	nop			;0377	00 	8  Interlace Mode
	add hl,bc		;0378	09 	9  Max Scan Line Address
	ld h,l			;0379	65 	a  Cursor Start
	add hl,bc		;037a	09 	b  Cursor End
l037bh:
	nop			;037b	00 	c  Start Address (H)
	nop			;037c	00 	d  Start Address (L)
	inc bc			;037d	03 	e  Cursor (H)
l037eh:
	jp (hl)			;037e	e9 	f  Cursor (L)

	inc b			;037f	04 	Version?
	add a,d			;0380	82 	YY?
	ld de,01318h		;0381	11 18 13 	MM? DD? 
	jr nc,l0396h		;0384	30 10 	0 . 
l0386h:
	rst 38h			;0386	ff 	. 
	rst 38h			;0387	ff 	. 
	rst 38h			;0388	ff 	. 
	rst 38h			;0389	ff 	. 
l038ah:
	rst 38h			;038a	ff 	. 
	rst 38h			;038b	ff 	. 
	rst 38h			;038c	ff 	. 
	rst 38h			;038d	ff 	. 
	rst 38h			;038e	ff 	. 
l038fh:
	rst 38h			;038f	ff 	. 
	rst 38h			;0390	ff 	. 
	rst 38h			;0391	ff 	. 
l0392h:
	rst 38h			;0392	ff 	. 
	rst 38h			;0393	ff 	. 
	rst 38h			;0394	ff 	. 
	rst 38h			;0395	ff 	. 
l0396h:
	rst 38h			;0396	ff 	. 
	rst 38h			;0397	ff 	. 
	rst 38h			;0398	ff 	. 
	rst 38h			;0399	ff 	. 
l039ah:
	rst 38h			;039a	ff 	. 
	rst 38h			;039b	ff 	. 
	rst 38h			;039c	ff 	. 
	rst 38h			;039d	ff 	. 
	rst 38h			;039e	ff 	. 
	rst 38h			;039f	ff 	. 
	rst 38h			;03a0	ff 	. 
	rst 38h			;03a1	ff 	. 
	rst 38h			;03a2	ff 	. 
	rst 38h			;03a3	ff 	. 
	rst 38h			;03a4	ff 	. 
	rst 38h			;03a5	ff 	. 
	rst 38h			;03a6	ff 	. 
l03a7h:
	rst 38h			;03a7	ff 	. 
	rst 38h			;03a8	ff 	. 
	rst 38h			;03a9	ff 	. 
	rst 38h			;03aa	ff 	. 
	rst 38h			;03ab	ff 	. 
	rst 38h			;03ac	ff 	. 
	rst 38h			;03ad	ff 	. 
	rst 38h			;03ae	ff 	. 
	rst 38h			;03af	ff 	. 
l03b0h:
	rst 38h			;03b0	ff 	. 
	rst 38h			;03b1	ff 	. 
	rst 38h			;03b2	ff 	. 
	rst 38h			;03b3	ff 	. 
	rst 38h			;03b4	ff 	. 
	rst 38h			;03b5	ff 	. 
	rst 38h			;03b6	ff 	. 
	rst 38h			;03b7	ff 	. 
	rst 38h			;03b8	ff 	. 
	rst 38h			;03b9	ff 	. 
	rst 38h			;03ba	ff 	. 
	rst 38h			;03bb	ff 	. 
	rst 38h			;03bc	ff 	. 
	rst 38h			;03bd	ff 	. 
	rst 38h			;03be	ff 	. 
	rst 38h			;03bf	ff 	. 
	rst 38h			;03c0	ff 	. 
	rst 38h			;03c1	ff 	. 
	rst 38h			;03c2	ff 	. 
	rst 38h			;03c3	ff 	. 
	rst 38h			;03c4	ff 	. 
	rst 38h			;03c5	ff 	. 
	rst 38h			;03c6	ff 	. 
	rst 38h			;03c7	ff 	. 
	rst 38h			;03c8	ff 	. 
	rst 38h			;03c9	ff 	. 
	rst 38h			;03ca	ff 	. 
	rst 38h			;03cb	ff 	. 
	rst 38h			;03cc	ff 	. 
	rst 38h			;03cd	ff 	. 
	rst 38h			;03ce	ff 	. 
	rst 38h			;03cf	ff 	. 
	rst 38h			;03d0	ff 	. 
	rst 38h			;03d1	ff 	. 
	rst 38h			;03d2	ff 	. 
	rst 38h			;03d3	ff 	. 
	rst 38h			;03d4	ff 	. 
	rst 38h			;03d5	ff 	. 
	rst 38h			;03d6	ff 	. 
	rst 38h			;03d7	ff 	. 
	rst 38h			;03d8	ff 	. 
	rst 38h			;03d9	ff 	. 
	rst 38h			;03da	ff 	. 
	rst 38h			;03db	ff 	. 
	rst 38h			;03dc	ff 	. 
	rst 38h			;03dd	ff 	. 
	rst 38h			;03de	ff 	. 
	rst 38h			;03df	ff 	. 
	rst 38h			;03e0	ff 	. 
	rst 38h			;03e1	ff 	. 
	rst 38h			;03e2	ff 	. 
	rst 38h			;03e3	ff 	. 
	rst 38h			;03e4	ff 	. 
	rst 38h			;03e5	ff 	. 
	rst 38h			;03e6	ff 	. 
	rst 38h			;03e7	ff 	. 
	rst 38h			;03e8	ff 	. 
	rst 38h			;03e9	ff 	. 
	rst 38h			;03ea	ff 	. 
	rst 38h			;03eb	ff 	. 
	rst 38h			;03ec	ff 	. 
	rst 38h			;03ed	ff 	. 
	rst 38h			;03ee	ff 	. 
	rst 38h			;03ef	ff 	. 
	rst 38h			;03f0	ff 	. 
	rst 38h			;03f1	ff 	. 
	rst 38h			;03f2	ff 	. 
	rst 38h			;03f3	ff 	. 
	rst 38h			;03f4	ff 	. 
	rst 38h			;03f5	ff 	. 
	rst 38h			;03f6	ff 	. 
	rst 38h			;03f7	ff 	. 
	rst 38h			;03f8	ff 	. 
	rst 38h			;03f9	ff 	. 
	rst 38h			;03fa	ff 	. 
	rst 38h			;03fb	ff 	. 
	rst 38h			;03fc	ff 	. 
	rst 38h			;03fd	ff 	. 
	rst 38h			;03fe	ff 	. 
	rst 38h			;03ff	ff 	. 
	rst 38h			;0400	ff 	. 
	rst 38h			;0401	ff 	. 
	rst 38h			;0402	ff 	. 
	rst 38h			;0403	ff 	. 
	rst 38h			;0404	ff 	. 
	rst 38h			;0405	ff 	. 
	rst 38h			;0406	ff 	. 
	rst 38h			;0407	ff 	. 
	rst 38h			;0408	ff 	. 
	rst 38h			;0409	ff 	. 
	rst 38h			;040a	ff 	. 
	rst 38h			;040b	ff 	. 
	rst 38h			;040c	ff 	. 
	rst 38h			;040d	ff 	. 
	rst 38h			;040e	ff 	. 
	rst 38h			;040f	ff 	. 
	rst 38h			;0410	ff 	. 
	rst 38h			;0411	ff 	. 
	rst 38h			;0412	ff 	. 
	rst 38h			;0413	ff 	. 
	rst 38h			;0414	ff 	. 
	rst 38h			;0415	ff 	. 
	rst 38h			;0416	ff 	. 
	rst 38h			;0417	ff 	. 
	rst 38h			;0418	ff 	. 
	rst 38h			;0419	ff 	. 
	rst 38h			;041a	ff 	. 
	rst 38h			;041b	ff 	. 
	rst 38h			;041c	ff 	. 
	rst 38h			;041d	ff 	. 
	rst 38h			;041e	ff 	. 
	rst 38h			;041f	ff 	. 
	rst 38h			;0420	ff 	. 
	rst 38h			;0421	ff 	. 
	rst 38h			;0422	ff 	. 
	rst 38h			;0423	ff 	. 
	rst 38h			;0424	ff 	. 
	rst 38h			;0425	ff 	. 
	rst 38h			;0426	ff 	. 
	rst 38h			;0427	ff 	. 
	rst 38h			;0428	ff 	. 
	rst 38h			;0429	ff 	. 
	rst 38h			;042a	ff 	. 
	rst 38h			;042b	ff 	. 
	rst 38h			;042c	ff 	. 
	rst 38h			;042d	ff 	. 
	rst 38h			;042e	ff 	. 
	rst 38h			;042f	ff 	. 
	rst 38h			;0430	ff 	. 
	rst 38h			;0431	ff 	. 
	rst 38h			;0432	ff 	. 
	rst 38h			;0433	ff 	. 
	rst 38h			;0434	ff 	. 
	rst 38h			;0435	ff 	. 
	rst 38h			;0436	ff 	. 
	rst 38h			;0437	ff 	. 
l0438h:
	rst 38h			;0438	ff 	. 
	rst 38h			;0439	ff 	. 
	rst 38h			;043a	ff 	. 
	rst 38h			;043b	ff 	. 
	rst 38h			;043c	ff 	. 
	rst 38h			;043d	ff 	. 
	rst 38h			;043e	ff 	. 
	rst 38h			;043f	ff 	. 
	rst 38h			;0440	ff 	. 
	rst 38h			;0441	ff 	. 
	rst 38h			;0442	ff 	. 
	rst 38h			;0443	ff 	. 
	rst 38h			;0444	ff 	. 
	rst 38h			;0445	ff 	. 
	rst 38h			;0446	ff 	. 
	rst 38h			;0447	ff 	. 
	rst 38h			;0448	ff 	. 
	rst 38h			;0449	ff 	. 
	rst 38h			;044a	ff 	. 
	rst 38h			;044b	ff 	. 
	rst 38h			;044c	ff 	. 
	rst 38h			;044d	ff 	. 
	rst 38h			;044e	ff 	. 
	rst 38h			;044f	ff 	. 
	rst 38h			;0450	ff 	. 
	rst 38h			;0451	ff 	. 
	rst 38h			;0452	ff 	. 
	rst 38h			;0453	ff 	. 
	rst 38h			;0454	ff 	. 
	rst 38h			;0455	ff 	. 
	rst 38h			;0456	ff 	. 
	rst 38h			;0457	ff 	. 
	rst 38h			;0458	ff 	. 
	rst 38h			;0459	ff 	. 
	rst 38h			;045a	ff 	. 
	rst 38h			;045b	ff 	. 
	rst 38h			;045c	ff 	. 
	rst 38h			;045d	ff 	. 
	rst 38h			;045e	ff 	. 
	rst 38h			;045f	ff 	. 
	rst 38h			;0460	ff 	. 
	rst 38h			;0461	ff 	. 
	rst 38h			;0462	ff 	. 
	rst 38h			;0463	ff 	. 
	rst 38h			;0464	ff 	. 
	rst 38h			;0465	ff 	. 
	rst 38h			;0466	ff 	. 
	rst 38h			;0467	ff 	. 
	rst 38h			;0468	ff 	. 
	rst 38h			;0469	ff 	. 
	rst 38h			;046a	ff 	. 
	rst 38h			;046b	ff 	. 
	rst 38h			;046c	ff 	. 
	rst 38h			;046d	ff 	. 
	rst 38h			;046e	ff 	. 
	rst 38h			;046f	ff 	. 
	rst 38h			;0470	ff 	. 
	rst 38h			;0471	ff 	. 
	rst 38h			;0472	ff 	. 
	rst 38h			;0473	ff 	. 
	rst 38h			;0474	ff 	. 
	rst 38h			;0475	ff 	. 
	rst 38h			;0476	ff 	. 
	rst 38h			;0477	ff 	. 
	rst 38h			;0478	ff 	. 
	rst 38h			;0479	ff 	. 
	rst 38h			;047a	ff 	. 
	rst 38h			;047b	ff 	. 
	rst 38h			;047c	ff 	. 
	rst 38h			;047d	ff 	. 
	rst 38h			;047e	ff 	. 
	rst 38h			;047f	ff 	. 
	rst 38h			;0480	ff 	. 
	rst 38h			;0481	ff 	. 
	rst 38h			;0482	ff 	. 
	rst 38h			;0483	ff 	. 
	rst 38h			;0484	ff 	. 
	rst 38h			;0485	ff 	. 
	rst 38h			;0486	ff 	. 
	rst 38h			;0487	ff 	. 
	rst 38h			;0488	ff 	. 
	rst 38h			;0489	ff 	. 
	rst 38h			;048a	ff 	. 
	rst 38h			;048b	ff 	. 
	rst 38h			;048c	ff 	. 
	rst 38h			;048d	ff 	. 
	rst 38h			;048e	ff 	. 
	rst 38h			;048f	ff 	. 
	rst 38h			;0490	ff 	. 
	rst 38h			;0491	ff 	. 
	rst 38h			;0492	ff 	. 
	rst 38h			;0493	ff 	. 
	rst 38h			;0494	ff 	. 
	rst 38h			;0495	ff 	. 
	rst 38h			;0496	ff 	. 
	rst 38h			;0497	ff 	. 
	rst 38h			;0498	ff 	. 
	rst 38h			;0499	ff 	. 
	rst 38h			;049a	ff 	. 
	rst 38h			;049b	ff 	. 
	rst 38h			;049c	ff 	. 
	rst 38h			;049d	ff 	. 
	rst 38h			;049e	ff 	. 
	rst 38h			;049f	ff 	. 
	rst 38h			;04a0	ff 	. 
	rst 38h			;04a1	ff 	. 
	rst 38h			;04a2	ff 	. 
	rst 38h			;04a3	ff 	. 
	rst 38h			;04a4	ff 	. 
	rst 38h			;04a5	ff 	. 
	rst 38h			;04a6	ff 	. 
	rst 38h			;04a7	ff 	. 
	rst 38h			;04a8	ff 	. 
	rst 38h			;04a9	ff 	. 
	rst 38h			;04aa	ff 	. 
	rst 38h			;04ab	ff 	. 
	rst 38h			;04ac	ff 	. 
	rst 38h			;04ad	ff 	. 
	rst 38h			;04ae	ff 	. 
	rst 38h			;04af	ff 	. 
	rst 38h			;04b0	ff 	. 
	rst 38h			;04b1	ff 	. 
	rst 38h			;04b2	ff 	. 
	rst 38h			;04b3	ff 	. 
	rst 38h			;04b4	ff 	. 
	rst 38h			;04b5	ff 	. 
	rst 38h			;04b6	ff 	. 
	rst 38h			;04b7	ff 	. 
	rst 38h			;04b8	ff 	. 
	rst 38h			;04b9	ff 	. 
	rst 38h			;04ba	ff 	. 
	rst 38h			;04bb	ff 	. 
	rst 38h			;04bc	ff 	. 
	rst 38h			;04bd	ff 	. 
	rst 38h			;04be	ff 	. 
	rst 38h			;04bf	ff 	. 
	rst 38h			;04c0	ff 	. 
	rst 38h			;04c1	ff 	. 
	rst 38h			;04c2	ff 	. 
	rst 38h			;04c3	ff 	. 
	rst 38h			;04c4	ff 	. 
	rst 38h			;04c5	ff 	. 
	rst 38h			;04c6	ff 	. 
	rst 38h			;04c7	ff 	. 
	rst 38h			;04c8	ff 	. 
	rst 38h			;04c9	ff 	. 
	rst 38h			;04ca	ff 	. 
	rst 38h			;04cb	ff 	. 
	rst 38h			;04cc	ff 	. 
	rst 38h			;04cd	ff 	. 
	rst 38h			;04ce	ff 	. 
	rst 38h			;04cf	ff 	. 
	rst 38h			;04d0	ff 	. 
	rst 38h			;04d1	ff 	. 
	rst 38h			;04d2	ff 	. 
	rst 38h			;04d3	ff 	. 
	rst 38h			;04d4	ff 	. 
	rst 38h			;04d5	ff 	. 
	rst 38h			;04d6	ff 	. 
	rst 38h			;04d7	ff 	. 
	rst 38h			;04d8	ff 	. 
	rst 38h			;04d9	ff 	. 
	rst 38h			;04da	ff 	. 
	rst 38h			;04db	ff 	. 
	rst 38h			;04dc	ff 	. 
	rst 38h			;04dd	ff 	. 
	rst 38h			;04de	ff 	. 
	rst 38h			;04df	ff 	. 
	rst 38h			;04e0	ff 	. 
	rst 38h			;04e1	ff 	. 
	rst 38h			;04e2	ff 	. 
	rst 38h			;04e3	ff 	. 
	rst 38h			;04e4	ff 	. 
	rst 38h			;04e5	ff 	. 
	rst 38h			;04e6	ff 	. 
	rst 38h			;04e7	ff 	. 
	rst 38h			;04e8	ff 	. 
	rst 38h			;04e9	ff 	. 
	rst 38h			;04ea	ff 	. 
	rst 38h			;04eb	ff 	. 
	rst 38h			;04ec	ff 	. 
	rst 38h			;04ed	ff 	. 
	rst 38h			;04ee	ff 	. 
	rst 38h			;04ef	ff 	. 
	rst 38h			;04f0	ff 	. 
	rst 38h			;04f1	ff 	. 
	rst 38h			;04f2	ff 	. 
	rst 38h			;04f3	ff 	. 
	rst 38h			;04f4	ff 	. 
	rst 38h			;04f5	ff 	. 
	rst 38h			;04f6	ff 	. 
	rst 38h			;04f7	ff 	. 
	rst 38h			;04f8	ff 	. 
	rst 38h			;04f9	ff 	. 
	rst 38h			;04fa	ff 	. 
	rst 38h			;04fb	ff 	. 
	rst 38h			;04fc	ff 	. 
	rst 38h			;04fd	ff 	. 
	rst 38h			;04fe	ff 	. 
	rst 38h			;04ff	ff 	. 
	rst 38h			;0500	ff 	. 
	rst 38h			;0501	ff 	. 
	rst 38h			;0502	ff 	. 
	rst 38h			;0503	ff 	. 
	rst 38h			;0504	ff 	. 
	rst 38h			;0505	ff 	. 
	rst 38h			;0506	ff 	. 
	rst 38h			;0507	ff 	. 
	rst 38h			;0508	ff 	. 
	rst 38h			;0509	ff 	. 
	rst 38h			;050a	ff 	. 
	rst 38h			;050b	ff 	. 
	rst 38h			;050c	ff 	. 
	rst 38h			;050d	ff 	. 
	rst 38h			;050e	ff 	. 
	rst 38h			;050f	ff 	. 
	rst 38h			;0510	ff 	. 
	rst 38h			;0511	ff 	. 
	rst 38h			;0512	ff 	. 
	rst 38h			;0513	ff 	. 
	rst 38h			;0514	ff 	. 
	rst 38h			;0515	ff 	. 
	rst 38h			;0516	ff 	. 
	rst 38h			;0517	ff 	. 
	rst 38h			;0518	ff 	. 
	rst 38h			;0519	ff 	. 
	rst 38h			;051a	ff 	. 
	rst 38h			;051b	ff 	. 
	rst 38h			;051c	ff 	. 
	rst 38h			;051d	ff 	. 
	rst 38h			;051e	ff 	. 
	rst 38h			;051f	ff 	. 
	rst 38h			;0520	ff 	. 
	rst 38h			;0521	ff 	. 
	rst 38h			;0522	ff 	. 
	rst 38h			;0523	ff 	. 
	rst 38h			;0524	ff 	. 
	rst 38h			;0525	ff 	. 
	rst 38h			;0526	ff 	. 
	rst 38h			;0527	ff 	. 
	rst 38h			;0528	ff 	. 
	rst 38h			;0529	ff 	. 
	rst 38h			;052a	ff 	. 
	rst 38h			;052b	ff 	. 
	rst 38h			;052c	ff 	. 
	rst 38h			;052d	ff 	. 
	rst 38h			;052e	ff 	. 
	rst 38h			;052f	ff 	. 
	rst 38h			;0530	ff 	. 
	rst 38h			;0531	ff 	. 
	rst 38h			;0532	ff 	. 
	rst 38h			;0533	ff 	. 
	rst 38h			;0534	ff 	. 
	rst 38h			;0535	ff 	. 
	rst 38h			;0536	ff 	. 
	rst 38h			;0537	ff 	. 
	rst 38h			;0538	ff 	. 
	rst 38h			;0539	ff 	. 
	rst 38h			;053a	ff 	. 
	rst 38h			;053b	ff 	. 
	rst 38h			;053c	ff 	. 
	rst 38h			;053d	ff 	. 
	rst 38h			;053e	ff 	. 
	rst 38h			;053f	ff 	. 
	rst 38h			;0540	ff 	. 
	rst 38h			;0541	ff 	. 
	rst 38h			;0542	ff 	. 
	rst 38h			;0543	ff 	. 
	rst 38h			;0544	ff 	. 
	rst 38h			;0545	ff 	. 
	rst 38h			;0546	ff 	. 
	rst 38h			;0547	ff 	. 
	rst 38h			;0548	ff 	. 
	rst 38h			;0549	ff 	. 
	rst 38h			;054a	ff 	. 
	rst 38h			;054b	ff 	. 
	rst 38h			;054c	ff 	. 
	rst 38h			;054d	ff 	. 
	rst 38h			;054e	ff 	. 
	rst 38h			;054f	ff 	. 
	rst 38h			;0550	ff 	. 
	rst 38h			;0551	ff 	. 
	rst 38h			;0552	ff 	. 
	rst 38h			;0553	ff 	. 
	rst 38h			;0554	ff 	. 
	rst 38h			;0555	ff 	. 
	rst 38h			;0556	ff 	. 
	rst 38h			;0557	ff 	. 
	rst 38h			;0558	ff 	. 
	rst 38h			;0559	ff 	. 
	rst 38h			;055a	ff 	. 
	rst 38h			;055b	ff 	. 
	rst 38h			;055c	ff 	. 
	rst 38h			;055d	ff 	. 
	rst 38h			;055e	ff 	. 
	rst 38h			;055f	ff 	. 
	rst 38h			;0560	ff 	. 
	rst 38h			;0561	ff 	. 
	rst 38h			;0562	ff 	. 
	rst 38h			;0563	ff 	. 
	rst 38h			;0564	ff 	. 
	rst 38h			;0565	ff 	. 
	rst 38h			;0566	ff 	. 
	rst 38h			;0567	ff 	. 
	rst 38h			;0568	ff 	. 
	rst 38h			;0569	ff 	. 
	rst 38h			;056a	ff 	. 
	rst 38h			;056b	ff 	. 
	rst 38h			;056c	ff 	. 
	rst 38h			;056d	ff 	. 
	rst 38h			;056e	ff 	. 
	rst 38h			;056f	ff 	. 
	rst 38h			;0570	ff 	. 
	rst 38h			;0571	ff 	. 
	rst 38h			;0572	ff 	. 
	rst 38h			;0573	ff 	. 
	rst 38h			;0574	ff 	. 
	rst 38h			;0575	ff 	. 
	rst 38h			;0576	ff 	. 
	rst 38h			;0577	ff 	. 
	rst 38h			;0578	ff 	. 
	rst 38h			;0579	ff 	. 
	rst 38h			;057a	ff 	. 
	rst 38h			;057b	ff 	. 
	rst 38h			;057c	ff 	. 
	rst 38h			;057d	ff 	. 
	rst 38h			;057e	ff 	. 
	rst 38h			;057f	ff 	. 
	rst 38h			;0580	ff 	. 
	rst 38h			;0581	ff 	. 
	rst 38h			;0582	ff 	. 
	rst 38h			;0583	ff 	. 
	rst 38h			;0584	ff 	. 
	rst 38h			;0585	ff 	. 
	rst 38h			;0586	ff 	. 
	rst 38h			;0587	ff 	. 
	rst 38h			;0588	ff 	. 
	rst 38h			;0589	ff 	. 
	rst 38h			;058a	ff 	. 
	rst 38h			;058b	ff 	. 
	rst 38h			;058c	ff 	. 
	rst 38h			;058d	ff 	. 
	rst 38h			;058e	ff 	. 
	rst 38h			;058f	ff 	. 
	rst 38h			;0590	ff 	. 
	rst 38h			;0591	ff 	. 
	rst 38h			;0592	ff 	. 
	rst 38h			;0593	ff 	. 
	rst 38h			;0594	ff 	. 
	rst 38h			;0595	ff 	. 
	rst 38h			;0596	ff 	. 
	rst 38h			;0597	ff 	. 
	rst 38h			;0598	ff 	. 
	rst 38h			;0599	ff 	. 
	rst 38h			;059a	ff 	. 
	rst 38h			;059b	ff 	. 
	rst 38h			;059c	ff 	. 
	rst 38h			;059d	ff 	. 
	rst 38h			;059e	ff 	. 
	rst 38h			;059f	ff 	. 
	rst 38h			;05a0	ff 	. 
	rst 38h			;05a1	ff 	. 
	rst 38h			;05a2	ff 	. 
	rst 38h			;05a3	ff 	. 
	rst 38h			;05a4	ff 	. 
	rst 38h			;05a5	ff 	. 
	rst 38h			;05a6	ff 	. 
	rst 38h			;05a7	ff 	. 
	rst 38h			;05a8	ff 	. 
	rst 38h			;05a9	ff 	. 
	rst 38h			;05aa	ff 	. 
	rst 38h			;05ab	ff 	. 
	rst 38h			;05ac	ff 	. 
	rst 38h			;05ad	ff 	. 
	rst 38h			;05ae	ff 	. 
	rst 38h			;05af	ff 	. 
	rst 38h			;05b0	ff 	. 
	rst 38h			;05b1	ff 	. 
	rst 38h			;05b2	ff 	. 
	rst 38h			;05b3	ff 	. 
	rst 38h			;05b4	ff 	. 
	rst 38h			;05b5	ff 	. 
	rst 38h			;05b6	ff 	. 
	rst 38h			;05b7	ff 	. 
	rst 38h			;05b8	ff 	. 
	rst 38h			;05b9	ff 	. 
	rst 38h			;05ba	ff 	. 
	rst 38h			;05bb	ff 	. 
	rst 38h			;05bc	ff 	. 
	rst 38h			;05bd	ff 	. 
	rst 38h			;05be	ff 	. 
	rst 38h			;05bf	ff 	. 
	rst 38h			;05c0	ff 	. 
	rst 38h			;05c1	ff 	. 
	rst 38h			;05c2	ff 	. 
	rst 38h			;05c3	ff 	. 
	rst 38h			;05c4	ff 	. 
	rst 38h			;05c5	ff 	. 
	rst 38h			;05c6	ff 	. 
	rst 38h			;05c7	ff 	. 
	rst 38h			;05c8	ff 	. 
	rst 38h			;05c9	ff 	. 
	rst 38h			;05ca	ff 	. 
	rst 38h			;05cb	ff 	. 
	rst 38h			;05cc	ff 	. 
	rst 38h			;05cd	ff 	. 
	rst 38h			;05ce	ff 	. 
	rst 38h			;05cf	ff 	. 
	rst 38h			;05d0	ff 	. 
	rst 38h			;05d1	ff 	. 
	rst 38h			;05d2	ff 	. 
	rst 38h			;05d3	ff 	. 
	rst 38h			;05d4	ff 	. 
	rst 38h			;05d5	ff 	. 
	rst 38h			;05d6	ff 	. 
	rst 38h			;05d7	ff 	. 
	rst 38h			;05d8	ff 	. 
	rst 38h			;05d9	ff 	. 
	rst 38h			;05da	ff 	. 
	rst 38h			;05db	ff 	. 
	rst 38h			;05dc	ff 	. 
	rst 38h			;05dd	ff 	. 
	rst 38h			;05de	ff 	. 
	rst 38h			;05df	ff 	. 
	rst 38h			;05e0	ff 	. 
	rst 38h			;05e1	ff 	. 
	rst 38h			;05e2	ff 	. 
	rst 38h			;05e3	ff 	. 
	rst 38h			;05e4	ff 	. 
	rst 38h			;05e5	ff 	. 
	rst 38h			;05e6	ff 	. 
	rst 38h			;05e7	ff 	. 
	rst 38h			;05e8	ff 	. 
	rst 38h			;05e9	ff 	. 
	rst 38h			;05ea	ff 	. 
	rst 38h			;05eb	ff 	. 
	rst 38h			;05ec	ff 	. 
	rst 38h			;05ed	ff 	. 
	rst 38h			;05ee	ff 	. 
	rst 38h			;05ef	ff 	. 
	rst 38h			;05f0	ff 	. 
	rst 38h			;05f1	ff 	. 
	rst 38h			;05f2	ff 	. 
	rst 38h			;05f3	ff 	. 
	rst 38h			;05f4	ff 	. 
	rst 38h			;05f5	ff 	. 
	rst 38h			;05f6	ff 	. 
	rst 38h			;05f7	ff 	. 
	rst 38h			;05f8	ff 	. 
	rst 38h			;05f9	ff 	. 
	rst 38h			;05fa	ff 	. 
	rst 38h			;05fb	ff 	. 
	rst 38h			;05fc	ff 	. 
	rst 38h			;05fd	ff 	. 
	rst 38h			;05fe	ff 	. 
	rst 38h			;05ff	ff 	. 
	rst 38h			;0600	ff 	. 
	rst 38h			;0601	ff 	. 
	rst 38h			;0602	ff 	. 
	rst 38h			;0603	ff 	. 
	rst 38h			;0604	ff 	. 
	rst 38h			;0605	ff 	. 
	rst 38h			;0606	ff 	. 
	rst 38h			;0607	ff 	. 
	rst 38h			;0608	ff 	. 
	rst 38h			;0609	ff 	. 
	rst 38h			;060a	ff 	. 
	rst 38h			;060b	ff 	. 
	rst 38h			;060c	ff 	. 
	rst 38h			;060d	ff 	. 
	rst 38h			;060e	ff 	. 
	rst 38h			;060f	ff 	. 
	rst 38h			;0610	ff 	. 
	rst 38h			;0611	ff 	. 
	rst 38h			;0612	ff 	. 
	rst 38h			;0613	ff 	. 
	rst 38h			;0614	ff 	. 
	rst 38h			;0615	ff 	. 
	rst 38h			;0616	ff 	. 
	rst 38h			;0617	ff 	. 
	rst 38h			;0618	ff 	. 
	rst 38h			;0619	ff 	. 
	rst 38h			;061a	ff 	. 
	rst 38h			;061b	ff 	. 
	rst 38h			;061c	ff 	. 
	rst 38h			;061d	ff 	. 
	rst 38h			;061e	ff 	. 
	rst 38h			;061f	ff 	. 
	rst 38h			;0620	ff 	. 
	rst 38h			;0621	ff 	. 
	rst 38h			;0622	ff 	. 
	rst 38h			;0623	ff 	. 
	rst 38h			;0624	ff 	. 
	rst 38h			;0625	ff 	. 
	rst 38h			;0626	ff 	. 
	rst 38h			;0627	ff 	. 
	rst 38h			;0628	ff 	. 
	rst 38h			;0629	ff 	. 
	rst 38h			;062a	ff 	. 
	rst 38h			;062b	ff 	. 
	rst 38h			;062c	ff 	. 
	rst 38h			;062d	ff 	. 
	rst 38h			;062e	ff 	. 
	rst 38h			;062f	ff 	. 
	rst 38h			;0630	ff 	. 
	rst 38h			;0631	ff 	. 
	rst 38h			;0632	ff 	. 
	rst 38h			;0633	ff 	. 
	rst 38h			;0634	ff 	. 
	rst 38h			;0635	ff 	. 
	rst 38h			;0636	ff 	. 
	rst 38h			;0637	ff 	. 
	rst 38h			;0638	ff 	. 
	rst 38h			;0639	ff 	. 
	rst 38h			;063a	ff 	. 
	rst 38h			;063b	ff 	. 
	rst 38h			;063c	ff 	. 
	rst 38h			;063d	ff 	. 
	rst 38h			;063e	ff 	. 
	rst 38h			;063f	ff 	. 
	rst 38h			;0640	ff 	. 
	rst 38h			;0641	ff 	. 
	rst 38h			;0642	ff 	. 
	rst 38h			;0643	ff 	. 
	rst 38h			;0644	ff 	. 
	rst 38h			;0645	ff 	. 
	rst 38h			;0646	ff 	. 
	rst 38h			;0647	ff 	. 
	rst 38h			;0648	ff 	. 
	rst 38h			;0649	ff 	. 
	rst 38h			;064a	ff 	. 
	rst 38h			;064b	ff 	. 
	rst 38h			;064c	ff 	. 
	rst 38h			;064d	ff 	. 
	rst 38h			;064e	ff 	. 
	rst 38h			;064f	ff 	. 
	rst 38h			;0650	ff 	. 
	rst 38h			;0651	ff 	. 
	rst 38h			;0652	ff 	. 
	rst 38h			;0653	ff 	. 
	rst 38h			;0654	ff 	. 
	rst 38h			;0655	ff 	. 
	rst 38h			;0656	ff 	. 
	rst 38h			;0657	ff 	. 
	rst 38h			;0658	ff 	. 
	rst 38h			;0659	ff 	. 
	rst 38h			;065a	ff 	. 
	rst 38h			;065b	ff 	. 
	rst 38h			;065c	ff 	. 
	rst 38h			;065d	ff 	. 
	rst 38h			;065e	ff 	. 
	rst 38h			;065f	ff 	. 
	rst 38h			;0660	ff 	. 
	rst 38h			;0661	ff 	. 
	rst 38h			;0662	ff 	. 
	rst 38h			;0663	ff 	. 
	rst 38h			;0664	ff 	. 
	rst 38h			;0665	ff 	. 
	rst 38h			;0666	ff 	. 
	rst 38h			;0667	ff 	. 
	rst 38h			;0668	ff 	. 
	rst 38h			;0669	ff 	. 
	rst 38h			;066a	ff 	. 
	rst 38h			;066b	ff 	. 
	rst 38h			;066c	ff 	. 
	rst 38h			;066d	ff 	. 
	rst 38h			;066e	ff 	. 
	rst 38h			;066f	ff 	. 
	rst 38h			;0670	ff 	. 
	rst 38h			;0671	ff 	. 
	rst 38h			;0672	ff 	. 
	rst 38h			;0673	ff 	. 
	rst 38h			;0674	ff 	. 
	rst 38h			;0675	ff 	. 
	rst 38h			;0676	ff 	. 
	rst 38h			;0677	ff 	. 
	rst 38h			;0678	ff 	. 
	rst 38h			;0679	ff 	. 
	rst 38h			;067a	ff 	. 
	rst 38h			;067b	ff 	. 
	rst 38h			;067c	ff 	. 
	rst 38h			;067d	ff 	. 
	rst 38h			;067e	ff 	. 
	rst 38h			;067f	ff 	. 
	rst 38h			;0680	ff 	. 
	rst 38h			;0681	ff 	. 
	rst 38h			;0682	ff 	. 
	rst 38h			;0683	ff 	. 
	rst 38h			;0684	ff 	. 
	rst 38h			;0685	ff 	. 
	rst 38h			;0686	ff 	. 
	rst 38h			;0687	ff 	. 
	rst 38h			;0688	ff 	. 
	rst 38h			;0689	ff 	. 
	rst 38h			;068a	ff 	. 
	rst 38h			;068b	ff 	. 
	rst 38h			;068c	ff 	. 
	rst 38h			;068d	ff 	. 
	rst 38h			;068e	ff 	. 
	rst 38h			;068f	ff 	. 
	rst 38h			;0690	ff 	. 
	rst 38h			;0691	ff 	. 
	rst 38h			;0692	ff 	. 
	rst 38h			;0693	ff 	. 
	rst 38h			;0694	ff 	. 
	rst 38h			;0695	ff 	. 
	rst 38h			;0696	ff 	. 
	rst 38h			;0697	ff 	. 
	rst 38h			;0698	ff 	. 
	rst 38h			;0699	ff 	. 
	rst 38h			;069a	ff 	. 
	rst 38h			;069b	ff 	. 
	rst 38h			;069c	ff 	. 
	rst 38h			;069d	ff 	. 
	rst 38h			;069e	ff 	. 
	rst 38h			;069f	ff 	. 
	rst 38h			;06a0	ff 	. 
	rst 38h			;06a1	ff 	. 
	rst 38h			;06a2	ff 	. 
	rst 38h			;06a3	ff 	. 
	rst 38h			;06a4	ff 	. 
	rst 38h			;06a5	ff 	. 
	rst 38h			;06a6	ff 	. 
	rst 38h			;06a7	ff 	. 
	rst 38h			;06a8	ff 	. 
	rst 38h			;06a9	ff 	. 
	rst 38h			;06aa	ff 	. 
	rst 38h			;06ab	ff 	. 
	rst 38h			;06ac	ff 	. 
	rst 38h			;06ad	ff 	. 
	rst 38h			;06ae	ff 	. 
	rst 38h			;06af	ff 	. 
	rst 38h			;06b0	ff 	. 
	rst 38h			;06b1	ff 	. 
	rst 38h			;06b2	ff 	. 
	rst 38h			;06b3	ff 	. 
	rst 38h			;06b4	ff 	. 
	rst 38h			;06b5	ff 	. 
	rst 38h			;06b6	ff 	. 
	rst 38h			;06b7	ff 	. 
	rst 38h			;06b8	ff 	. 
	rst 38h			;06b9	ff 	. 
	rst 38h			;06ba	ff 	. 
	rst 38h			;06bb	ff 	. 
	rst 38h			;06bc	ff 	. 
	rst 38h			;06bd	ff 	. 
	rst 38h			;06be	ff 	. 
	rst 38h			;06bf	ff 	. 
	rst 38h			;06c0	ff 	. 
	rst 38h			;06c1	ff 	. 
	rst 38h			;06c2	ff 	. 
	rst 38h			;06c3	ff 	. 
	rst 38h			;06c4	ff 	. 
	rst 38h			;06c5	ff 	. 
	rst 38h			;06c6	ff 	. 
	rst 38h			;06c7	ff 	. 
	rst 38h			;06c8	ff 	. 
	rst 38h			;06c9	ff 	. 
	rst 38h			;06ca	ff 	. 
	rst 38h			;06cb	ff 	. 
	rst 38h			;06cc	ff 	. 
	rst 38h			;06cd	ff 	. 
	rst 38h			;06ce	ff 	. 
	rst 38h			;06cf	ff 	. 
	rst 38h			;06d0	ff 	. 
	rst 38h			;06d1	ff 	. 
	rst 38h			;06d2	ff 	. 
	rst 38h			;06d3	ff 	. 
	rst 38h			;06d4	ff 	. 
	rst 38h			;06d5	ff 	. 
	rst 38h			;06d6	ff 	. 
	rst 38h			;06d7	ff 	. 
	rst 38h			;06d8	ff 	. 
	rst 38h			;06d9	ff 	. 
	rst 38h			;06da	ff 	. 
	rst 38h			;06db	ff 	. 
	rst 38h			;06dc	ff 	. 
	rst 38h			;06dd	ff 	. 
	rst 38h			;06de	ff 	. 
	rst 38h			;06df	ff 	. 
	rst 38h			;06e0	ff 	. 
	rst 38h			;06e1	ff 	. 
	rst 38h			;06e2	ff 	. 
	rst 38h			;06e3	ff 	. 
	rst 38h			;06e4	ff 	. 
	rst 38h			;06e5	ff 	. 
	rst 38h			;06e6	ff 	. 
	rst 38h			;06e7	ff 	. 
	rst 38h			;06e8	ff 	. 
	rst 38h			;06e9	ff 	. 
	rst 38h			;06ea	ff 	. 
	rst 38h			;06eb	ff 	. 
	rst 38h			;06ec	ff 	. 
	rst 38h			;06ed	ff 	. 
	rst 38h			;06ee	ff 	. 
	rst 38h			;06ef	ff 	. 
	rst 38h			;06f0	ff 	. 
	rst 38h			;06f1	ff 	. 
	rst 38h			;06f2	ff 	. 
	rst 38h			;06f3	ff 	. 
	rst 38h			;06f4	ff 	. 
	rst 38h			;06f5	ff 	. 
	rst 38h			;06f6	ff 	. 
	rst 38h			;06f7	ff 	. 
	rst 38h			;06f8	ff 	. 
	rst 38h			;06f9	ff 	. 
	rst 38h			;06fa	ff 	. 
	rst 38h			;06fb	ff 	. 
	rst 38h			;06fc	ff 	. 
	rst 38h			;06fd	ff 	. 
	rst 38h			;06fe	ff 	. 
	rst 38h			;06ff	ff 	. 
	rst 38h			;0700	ff 	. 
	rst 38h			;0701	ff 	. 
	rst 38h			;0702	ff 	. 
	rst 38h			;0703	ff 	. 
	rst 38h			;0704	ff 	. 
	rst 38h			;0705	ff 	. 
	rst 38h			;0706	ff 	. 
	rst 38h			;0707	ff 	. 
	rst 38h			;0708	ff 	. 
	rst 38h			;0709	ff 	. 
	rst 38h			;070a	ff 	. 
	rst 38h			;070b	ff 	. 
	rst 38h			;070c	ff 	. 
	rst 38h			;070d	ff 	. 
	rst 38h			;070e	ff 	. 
	rst 38h			;070f	ff 	. 
	rst 38h			;0710	ff 	. 
	rst 38h			;0711	ff 	. 
	rst 38h			;0712	ff 	. 
	rst 38h			;0713	ff 	. 
	rst 38h			;0714	ff 	. 
	rst 38h			;0715	ff 	. 
	rst 38h			;0716	ff 	. 
	rst 38h			;0717	ff 	. 
	rst 38h			;0718	ff 	. 
	rst 38h			;0719	ff 	. 
	rst 38h			;071a	ff 	. 
	rst 38h			;071b	ff 	. 
	rst 38h			;071c	ff 	. 
	rst 38h			;071d	ff 	. 
	rst 38h			;071e	ff 	. 
	rst 38h			;071f	ff 	. 
	rst 38h			;0720	ff 	. 
	rst 38h			;0721	ff 	. 
	rst 38h			;0722	ff 	. 
	rst 38h			;0723	ff 	. 
	rst 38h			;0724	ff 	. 
	rst 38h			;0725	ff 	. 
	rst 38h			;0726	ff 	. 
	rst 38h			;0727	ff 	. 
	rst 38h			;0728	ff 	. 
	rst 38h			;0729	ff 	. 
	rst 38h			;072a	ff 	. 
	rst 38h			;072b	ff 	. 
	rst 38h			;072c	ff 	. 
	rst 38h			;072d	ff 	. 
	rst 38h			;072e	ff 	. 
	rst 38h			;072f	ff 	. 
	rst 38h			;0730	ff 	. 
	rst 38h			;0731	ff 	. 
	rst 38h			;0732	ff 	. 
	rst 38h			;0733	ff 	. 
	rst 38h			;0734	ff 	. 
	rst 38h			;0735	ff 	. 
	rst 38h			;0736	ff 	. 
	rst 38h			;0737	ff 	. 
	rst 38h			;0738	ff 	. 
	rst 38h			;0739	ff 	. 
	rst 38h			;073a	ff 	. 
	rst 38h			;073b	ff 	. 
	rst 38h			;073c	ff 	. 
	rst 38h			;073d	ff 	. 
	rst 38h			;073e	ff 	. 
	rst 38h			;073f	ff 	. 
	rst 38h			;0740	ff 	. 
	rst 38h			;0741	ff 	. 
	rst 38h			;0742	ff 	. 
	rst 38h			;0743	ff 	. 
	rst 38h			;0744	ff 	. 
	rst 38h			;0745	ff 	. 
	rst 38h			;0746	ff 	. 
	rst 38h			;0747	ff 	. 
	rst 38h			;0748	ff 	. 
	rst 38h			;0749	ff 	. 
	rst 38h			;074a	ff 	. 
	rst 38h			;074b	ff 	. 
	rst 38h			;074c	ff 	. 
	rst 38h			;074d	ff 	. 
	rst 38h			;074e	ff 	. 
	rst 38h			;074f	ff 	. 
	rst 38h			;0750	ff 	. 
	rst 38h			;0751	ff 	. 
	rst 38h			;0752	ff 	. 
	rst 38h			;0753	ff 	. 
	rst 38h			;0754	ff 	. 
	rst 38h			;0755	ff 	. 
	rst 38h			;0756	ff 	. 
	rst 38h			;0757	ff 	. 
	rst 38h			;0758	ff 	. 
	rst 38h			;0759	ff 	. 
	rst 38h			;075a	ff 	. 
	rst 38h			;075b	ff 	. 
	rst 38h			;075c	ff 	. 
	rst 38h			;075d	ff 	. 
	rst 38h			;075e	ff 	. 
	rst 38h			;075f	ff 	. 
	rst 38h			;0760	ff 	. 
	rst 38h			;0761	ff 	. 
	rst 38h			;0762	ff 	. 
	rst 38h			;0763	ff 	. 
	rst 38h			;0764	ff 	. 
	rst 38h			;0765	ff 	. 
	rst 38h			;0766	ff 	. 
	rst 38h			;0767	ff 	. 
	rst 38h			;0768	ff 	. 
	rst 38h			;0769	ff 	. 
	rst 38h			;076a	ff 	. 
	rst 38h			;076b	ff 	. 
	rst 38h			;076c	ff 	. 
	rst 38h			;076d	ff 	. 
	rst 38h			;076e	ff 	. 
	rst 38h			;076f	ff 	. 
	rst 38h			;0770	ff 	. 
	rst 38h			;0771	ff 	. 
	rst 38h			;0772	ff 	. 
	rst 38h			;0773	ff 	. 
	rst 38h			;0774	ff 	. 
	rst 38h			;0775	ff 	. 
	rst 38h			;0776	ff 	. 
	rst 38h			;0777	ff 	. 
	rst 38h			;0778	ff 	. 
	rst 38h			;0779	ff 	. 
	rst 38h			;077a	ff 	. 
	rst 38h			;077b	ff 	. 
	rst 38h			;077c	ff 	. 
	rst 38h			;077d	ff 	. 
	rst 38h			;077e	ff 	. 
	rst 38h			;077f	ff 	. 
	rst 38h			;0780	ff 	. 
	rst 38h			;0781	ff 	. 
	rst 38h			;0782	ff 	. 
	rst 38h			;0783	ff 	. 
	rst 38h			;0784	ff 	. 
	rst 38h			;0785	ff 	. 
	rst 38h			;0786	ff 	. 
	rst 38h			;0787	ff 	. 
	rst 38h			;0788	ff 	. 
	rst 38h			;0789	ff 	. 
	rst 38h			;078a	ff 	. 
	rst 38h			;078b	ff 	. 
	rst 38h			;078c	ff 	. 
	rst 38h			;078d	ff 	. 
	rst 38h			;078e	ff 	. 
	rst 38h			;078f	ff 	. 
	rst 38h			;0790	ff 	. 
	rst 38h			;0791	ff 	. 
	rst 38h			;0792	ff 	. 
	rst 38h			;0793	ff 	. 
	rst 38h			;0794	ff 	. 
	rst 38h			;0795	ff 	. 
	rst 38h			;0796	ff 	. 
	rst 38h			;0797	ff 	. 
	rst 38h			;0798	ff 	. 
	rst 38h			;0799	ff 	. 
	rst 38h			;079a	ff 	. 
	rst 38h			;079b	ff 	. 
	rst 38h			;079c	ff 	. 
	rst 38h			;079d	ff 	. 
	rst 38h			;079e	ff 	. 
	rst 38h			;079f	ff 	. 
	rst 38h			;07a0	ff 	. 
	rst 38h			;07a1	ff 	. 
	rst 38h			;07a2	ff 	. 
	rst 38h			;07a3	ff 	. 
	rst 38h			;07a4	ff 	. 
	rst 38h			;07a5	ff 	. 
	rst 38h			;07a6	ff 	. 
	rst 38h			;07a7	ff 	. 
	rst 38h			;07a8	ff 	. 
	rst 38h			;07a9	ff 	. 
	rst 38h			;07aa	ff 	. 
	rst 38h			;07ab	ff 	. 
	rst 38h			;07ac	ff 	. 
	rst 38h			;07ad	ff 	. 
	rst 38h			;07ae	ff 	. 
	rst 38h			;07af	ff 	. 
	rst 38h			;07b0	ff 	. 
	rst 38h			;07b1	ff 	. 
	rst 38h			;07b2	ff 	. 
	rst 38h			;07b3	ff 	. 
	rst 38h			;07b4	ff 	. 
	rst 38h			;07b5	ff 	. 
	rst 38h			;07b6	ff 	. 
	rst 38h			;07b7	ff 	. 
	rst 38h			;07b8	ff 	. 
	rst 38h			;07b9	ff 	. 
	rst 38h			;07ba	ff 	. 
	rst 38h			;07bb	ff 	. 
	rst 38h			;07bc	ff 	. 
	rst 38h			;07bd	ff 	. 
	rst 38h			;07be	ff 	. 
	rst 38h			;07bf	ff 	. 
	rst 38h			;07c0	ff 	. 
	rst 38h			;07c1	ff 	. 
	rst 38h			;07c2	ff 	. 
	rst 38h			;07c3	ff 	. 
	rst 38h			;07c4	ff 	. 
	rst 38h			;07c5	ff 	. 
	rst 38h			;07c6	ff 	. 
	rst 38h			;07c7	ff 	. 
	rst 38h			;07c8	ff 	. 
	rst 38h			;07c9	ff 	. 
	rst 38h			;07ca	ff 	. 
	rst 38h			;07cb	ff 	. 
	rst 38h			;07cc	ff 	. 
	rst 38h			;07cd	ff 	. 
	rst 38h			;07ce	ff 	. 
	rst 38h			;07cf	ff 	. 
	rst 38h			;07d0	ff 	. 
	rst 38h			;07d1	ff 	. 
	rst 38h			;07d2	ff 	. 
	rst 38h			;07d3	ff 	. 
	rst 38h			;07d4	ff 	. 
	rst 38h			;07d5	ff 	. 
	rst 38h			;07d6	ff 	. 
	rst 38h			;07d7	ff 	. 
	rst 38h			;07d8	ff 	. 
	rst 38h			;07d9	ff 	. 
	rst 38h			;07da	ff 	. 
	rst 38h			;07db	ff 	. 
	rst 38h			;07dc	ff 	. 
	rst 38h			;07dd	ff 	. 
	rst 38h			;07de	ff 	. 
	rst 38h			;07df	ff 	. 
	rst 38h			;07e0	ff 	. 
	rst 38h			;07e1	ff 	. 
	rst 38h			;07e2	ff 	. 
	rst 38h			;07e3	ff 	. 
	rst 38h			;07e4	ff 	. 
	rst 38h			;07e5	ff 	. 
	rst 38h			;07e6	ff 	. 
	rst 38h			;07e7	ff 	. 
	rst 38h			;07e8	ff 	. 
	rst 38h			;07e9	ff 	. 
	rst 38h			;07ea	ff 	. 
	rst 38h			;07eb	ff 	. 
	rst 38h			;07ec	ff 	. 
	rst 38h			;07ed	ff 	. 
	rst 38h			;07ee	ff 	. 
	rst 38h			;07ef	ff 	. 
	rst 38h			;07f0	ff 	. 
	rst 38h			;07f1	ff 	. 
	rst 38h			;07f2	ff 	. 
	rst 38h			;07f3	ff 	. 
	rst 38h			;07f4	ff 	. 
	rst 38h			;07f5	ff 	. 
	rst 38h			;07f6	ff 	. 
	rst 38h			;07f7	ff 	. 
	rst 38h			;07f8	ff 	. 
	rst 38h			;07f9	ff 	. 
	rst 38h			;07fa	ff 	. 
	rst 38h			;07fb	ff 	. 
	rst 38h			;07fc	ff 	. 
	rst 38h			;07fd	ff 	. 
	rst 38h			;07fe	ff 	. 
l07ffh:
	rst 38h			;07ff	ff 	. 
