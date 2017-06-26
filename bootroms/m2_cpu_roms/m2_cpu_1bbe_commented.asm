; z80dasm 1.1.0
; command line: z80dasm -a -l -g 0 -t cpu_1bbe.bin

; Version 3

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
HDCSTR:	equ	0xCF ; WD1002 Command / Status Register
; FDC board
FDDFC:	equ	0xE0 ; Printer, FDD, FDC Interrupt Status.
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
	ld bc,l07ffh		;0008	01 ff 07 	Set up copy
	ld de,0fffeh		;000b	11 fe ff 	a value to
	ld hl,0ffffh		;000e	21 ff ff 	video memory
l0011h:
	ld (hl),0a0h		;0011	36 a0 		a white block
	lddr			;0013	ed b8 		do the copy
	ld bc,00ffch		;0015	01 fc 0f 	b: CRTC addr register value, c: CRTC address register
	ld hl,l00311h		;0018	21 11 03 	Set up CTRC register
l001bh:
	ld a,(hl)		;001b	7e 		 values copy action:
	out (c),b		;001c	ed 41 		- select register (CRTC address register)
	out (0fdh),a		;001e	d3 fd 		- copy value to Load CRTC Data Register
	dec hl			;0020	2b 		- select next value
	dec b			;0021	05 		- select next register
	jp p,l001bh		;0022	f2 1b 00 	until all registers are set
	xor a			;0025	af 	. 
	ld bc,l0319h		;0026	01 19 03 	Size of boot ROM code
	ld hl,l0000h		;0029	21 00 00 	Start of boot ROM code
l002ch:
	add a,(hl)		;002c	86 		calculate ROM checksum 
	ld d,a			;002d	57 		.
	inc hl			;002e	23 		.
	dec bc			;002f	0b 		.
	ld a,b			;0030	78 		.
	or c			;0031	b1 		. 
	ld a,d			;0032	7a 		. 
	jr nz,l002ch		;0033	20 f7 	  	Loop until BC == 0
	or a			;0035	b7 	
	jp nz,l0229h		;0036	c2 29 02 	Jump if sum != 0; KC error
	ld a,055h		;0039	3e 55 		CPU Test
	cpl			;003b	2f 		.
	or a			;003c	b7 		.
	and a			;003d	a7 		.
	ld b,a			;003e	47 		.
	ld c,b			;003f	48 		.
	ld d,c			;0040	51 		.
	ld e,d			;0041	5a 		.
	ld h,e			;0042	63 		.
	ld l,h			;0043	6c 		.
	inc l			;0044	2c 		.
	dec l			;0045	2d 		.
	ex de,hl		;0046	eb 		.
	ex af,af'		;0047	08 		.
	ld a,e			;0048	7b 		.
	exx			;0049	d9 		.
	ld b,a			;004a	47 		.
	ld c,b			;004b	48 		.
	ld d,c			;004c	51 		.
	ld e,d			;004d	5a 		.
	ld h,e			;004e	63 		.
	ld l,h			;004f	6c 		.
	ld a,l			;0050	7d 		.
	ld i,a			;0051	ed 47 		.
	ld a,i			;0053	ed 57 		.
	ld l,a			;0055	6f 		.
	ex af,af'		;0056	08 		.
	cp l			;0057	bd 		.
	jp nz,l022eh		;0058	c2 2e 02 	Jump to Z8 - Defective CPU message routine
	ld bc,07000h		;005b	01 00 70 	Start memory test
	ld hl,01000h		;005e	21 00 10 	.
	ld d,h			;0061	54 		.
	ld e,l			;0062	5d 		.
l0063h:
	ld a,(de)		;0063	1a 		.
	cpl			;0064	2f 		.
	ld (de),a		;0065	12 		. 
	cp (hl)			;0066	be 		.
	cpl			;0067	2f 		.
	ld (hl),a		;0068	77 		.
	jp nz,l0233h		;0069	c2 33 02 	Jump to MF = Memory failure message routine
	ldi			;006c	ed a0 		Block copy
	jp pe,l0063h		;006e	ea 63 00 	loop
	ld d,0c8h		;0071	16 c8 		
l0073h:
	in a,(0ffh)		;0073	db ff 		Get video status
	bit 7,a			;0075	cb 7f 		Check video RAM enabled
	jr z,l007bh		;0077	28 02 		
	in a,(0fch)		;0079	db fc 		Get keyboard data
l007bh:
	ld bc,00080h		;007b	01 80 00 	
	call sub_0282h		;007e	cd 82 02 	Delay
	dec d			;0081	15 	. 
	jr nz,l0073h		;0082	20 ef 	  	Again
	xor a			;0084	af 		0 - clear Control Register
	out (0c1h),a		;0085	d3 c1 		HDA Control register
	ld a,010h		;0087	3e 10 		Soft reset
	out (0c1h),a		;0089	d3 c1 		HDA Control register
	ld a,00fh		;008b	3e 0f 		Device Enable, Wait state enable, Write & Read bit set
	out (0c1h),a		;008d	d3 c1 		HDA Control register
	in a,(0c2h)		;008f	db c2 		Device Present Register
	and 00fh		;0091	e6 0f 		Mask the non-device bits
	jp z,l0152h		;0093	ca 52 01 	Jump to floppy boot if no HD present
	ld d,015h		;0096	16 15 		
l0098h:
	call sub_0282h		;0098	cd 82 02 	Some delay
	in a,(0cfh)		;009b	db cf 		WD1002 Status Register
	bit 6,a			;009d	cb 77 		Ready
	jr nz,l00ach		;009f	20 0b 	 	Continue HD boot if so
	call sub_02a2h		;00a1	cd a2 02 	Video enabled and keyboart ESC/ETX check
	jp z,l0152h		;00a4	ca 52 01 	Jump to floppy boot
	dec d			;00a7	15 	
	jr nz,l0098h		;00a8	20 ee 	  	Retry
	jr l010dh		;00aa	18 61 		Jump to boot error routine
l00ach:
	ld a,020h		;00ac	3e 20 		Drive 0, Head 0, 512 byte sector
	out (0ceh),a		;00ae	d3 ce 		WD1002 Size/Drive/Head
	xor a			;00b0	af 		0
	out (0cdh),a		;00b1	d3 cd 		WD1002 Cylinder High
	ld a,005h		;00b3	3e 05 		5
	out (0cch),a		;00b5	d3 cc 		WD1002 Cylinder Low
	ld a,07fh		;00b7	3e 7f 		Seek (TSR:7.5ms)
	out (0cfh),a		;00b9	d3 cf 		WD1002 Command Register
	call sub_02b1h		;00bb	cd b1 02 	. . . 
	ld a,01fh		;00be	3e 1f 		Restore (TSR:7.5ms)
	out (0cfh),a		;00c0	d3 cf 		WD1002 Command Register
	call sub_02b1h		;00c2	cd b1 02 	Wait for SEEK COMPLETE
	jr nz,l012bh		;00c5	20 64 	 
	ld hl,l0000h		;00c7	21 00 00 	
	ld bc,l01cbh		;00ca	01 cb 01 	B: 1, C: WD1002 Sector Number
l00cdh:
	ld d,h			;00cd	54 	
	ld e,l			;00ce	5d 	
	out (c),b		;00cf	ed 41 		Select Sector 
	ld a,020h		;00d1	3e 20 		Read Sector, Programmed Mode, Normal Transfer, Single Sector
	out (0cfh),a		;00d3	d3 cf 		WD1002 Command Register
	call sub_02b1h		;00d5	cd b1 02 	Wait for Seek complete
	jr nz,l0111h		;00d8	20 37 	  	Jump to status bit check
l00dah:
	in a,(0cfh)		;00da	db cf 		WD1002 Status Register
	bit 3,a			;00dc	cb 5f 		
	jr z,l00dah		;00de	28 fa 		Wait until Data Request bit is set
	call sub_02a2h		;00e0	cd a2 02 	Check keyboard for ESC & ETX
	jr z,l0152h		;00e3	28 6d 		Jump to floppy boot
	inc b			;00e5	04 	. 
	push bc			;00e6	c5 	. 
	ld a,002h		;00e7	3e 02 	> . 
	ld bc,000c8h		;00e9	01 c8 00 	B: 256, C: WD1002 Sector Buffer
	inir			;00ec	ed b2 		Copy 1st 256 bytes 
	inir			;00ee	ed b2 		Copy 2nd 256 bytes 
	push hl			;00f0	e5 	. 
	ld hl,l02d3h		;00f1	21 d3 02 	! . . 
	ld b,00eh		;00f4	06 0e 	. . 
	call sub_029ah		;00f6	cd 9a 02 	. . . 
	pop hl			;00f9	e1 	. 
	pop bc			;00fa	c1 	. 
	jr nz,l00cdh		;00fb	20 d0 	  	Try sector read again
	ld bc,l0000h		;00fd	01 00 00 	 
	call sub_0282h		;0100	cd 82 02 	Some delay
	call sub_02a2h		;0103	cd a2 02 	Check keyboard for ESC & ETX
	jr z,l0152h		;0106	28 4a 		Jump to floppy boot
	xor a			;0108	af 	. 
	out (0c1h),a		;0109	d3 c1 		HDA Control Register, deselect drive
	ex de,hl		;010b	eb 	. 
	jp (hl)			;010c	e9 	. 
l010dh:
	ld e,054h		;010d	1e 54 	. T 
	jr l0137h		;010f	18 26 		
l0111h:
	bit 6,a			;0111	cb 77 		Uncorrectable Error 
	ld e,043h		;0113	1e 43 		C 
	jr nz,l0137h		;0115	20 20 	    	Jump to BOOT ERROR message routine
	bit 5,a			;0117	cb 6f 		CRC Error ID Field
	ld e,049h		;0119	1e 49 		I
	jr nz,l0137h		;011b	20 1a 	 	Jump to BOOT ERROR message routine
	bit 4,a			;011d	cb 67 		ID Not Found
	ld e,04eh		;011f	1e 4e 		N
	jr nz,l0137h		;0121	20 14 	 	Jump to BOOT ERROR message routine
	bit 2,a			;0123	cb 57 		Aborted Command
	ld e,041h		;0125	1e 41 		A
	jr nz,l0137h		;0127	20 0e 	  	Jump to BOOT ERROR message routine
	bit 1,a			;0129	cb 4f 		TK000 Error
l012bh:
	ld e,030h		;012b	1e 30 		0 
	jr nz,l0137h		;012d	20 08 	  	Jump to BOOT ERROR message routine
	bit 0,a			;012f	cb 47 		DAM not found
	ld e,04dh		;0131	1e 4d 		M 
	jr nz,l0137h		;0133	20 02 	  	Jump to BOOT ERROR message routine
	ld e,044h		;0135	1e 44 		D 
l0137h:
	ld d,048h		;0137	16 48 		H 
	ld hl,0fb9ah		;0139	21 9a fb 	Point to somewhere in video memory
	ld (hl),d		;013c	72 		Print H
	inc hl			;013d	23 	
	ld (hl),e		;013e	73 		Print C
	inc hl			;013f	23 	
	ld (hl),020h		;0140	36 20 		Print space
	ld hl,l02e1h		;0142	21 e1 02 	Point to 'BOOT ERROR'
	ld de,0fb8eh		;0145	11 8e fb 	 Point to somewhere in video memory
	ld bc,0000ch		;0148	01 0c 00 	 message size
	ldir			;014b	ed b0 		Do the block copy
l014dh:
	call sub_02a2h		;014d	cd a2 02 	Check keyboard for ESC & ETX
	jr nz,l014dh		;0150	20 fb 	  	Check again
l0152h:
	ld sp,02000h		;0152	31 00 20 	 
	xor a			;0155	af 		0
	out (0c1h),a		;0156	d3 c1 		HDA Control register
	ld a,04eh		;0158	3e 4e 		
	out (0efh),a		;015a	d3 ef 		Select drive 0, FM mode, side 0
	ld hl,002edh		;015c	21 ed 02 	Point to 'INSERT DISKETTE'
	ld de,0fb8eh		;015f	11 8e fb 	 Point to somewhere in video memory
	ld bc,l0011h		;0162	01 11 00 	 message size
	ldir			;0165	ed b0 		Do the block copy
l0167h:
	call sub_0288h		;0167	cd 88 02 	Reset FDC
	bit 7,a			;016a	cb 7f 		Test NOT READY
	jr nz,l0167h		;016c	20 f9 	  	If not ready, reset again
	ld bc,l07ffh		;016e	01 ff 07 	Set up block
	ld de,0fffeh		;0171	11 fe ff 	 fill action
	ld hl,0ffffh		;0174	21 ff ff 	 of video memory
	ld (hl),020h		;0177	36 20 		 with spaces
	lddr			;0179	ed b8 		Clear screen
	call sub_0288h		;017b	cd 88 02 	Reset FDC
	ld b,005h		;017e	06 05 		Retry count
l0180h:
	ld a,05bh		;0180	3e 5b 		Step In, Load Head, No Verify, Step Rate ?	
	out (0e4h),a		;0182	d3 e4 		FDC Command Register
	push bc			;0184	c5 	. 
	ld bc,00c03h		;0185	01 03 0c 	. . . 
	call sub_0282h		;0188	cd 82 02 	Some delay
	pop bc			;018b	c1 	. 
	djnz l0180h		;018c	10 f2 		Try again
	call sub_0288h		;018e	cd 88 02 	Reset FDC
	ld a,00bh		;0191	3e 0b 		Restore, Load Head, No Verify, Step Rate ?
	out (0e4h),a		;0193	d3 e4 		FDC Command Register
	ld d,007h		;0195	16 07 	. . 
l0197h:
	call sub_0282h		;0197	cd 82 02 	Some delay 
	dec d			;019a	15 	. 
	jr nz,l0197h		;019b	20 fa 	  	Try again
	in a,(0e4h)		;019d	db e4 		FDC Status Register
	push af			;019f	f5 	
	xor 004h		;01a0	ee 04 	 
	and 015h		;01a2	e6 15 	
	jr nz,l021ah		;01a4	20 74 	  	Jump to DC = 'Floppy disk controller error' message
	pop af			;01a6	f1 	
	bit 7,a			;01a7	cb 7f 	
	jr nz,l021fh		;01a9	20 74 	  	Jump to D0 = 'Drive not ready' message
	bit 3,a			;01ab	cb 5f 	
	jr nz,l0224h		;01ad	20 75 	  	Jump to SC = 'CRC Error' message
	ld hl,00e00h		;01af	21 00 0e 	Point to boot sector load location
	ld de,01a28h		;01b2	11 28 1a 	. ( . 
	ld bc,08001h		;01b5	01 01 80 	B: number of bytes to read, C: sector to read
	ld a,080h		;01b8	3e 80 		Read Sector Command
	ex af,af'		;01ba	08 	
l01bbh:
	push hl			;01bb	e5 	. 
	push de			;01bc	d5 	. 
	push bc			;01bd	c5 	. 
	call sub_0288h		;01be	cd 88 02 	Some delay
	ld a,c			;01c1	79 		01
	out (0e6h),a		;01c2	d3 e6 		FDC Sector Register
	ex af,af'		;01c4	08 		Read Sector
	out (0e4h),a		;01c5	d3 e4 		FDC Command Register
	ex af,af'		;01c7	08 	. 
	call sub_027fh		;01c8	cd 7f 02 	Some delay
l01cbh:
	pop bc			;01cb	c1 	. 
	push bc			;01cc	c5 	. 
	ld c,0e7h		;01cd	0e e7 		FDC Data register
l01cfh:
	in a,(0e4h)		;01cf	db e4 		FDC Status Register
	bit 1,a			;01d1	cb 4f 		Data Request
	jr z,l01d9h		;01d3	28 04 		 
	ini			;01d5	ed a2 		Block read sector
	jr z,l01ddh		;01d7	28 04 		Continue
l01d9h:
	bit 0,a			;01d9	cb 47 		BUSY
	jr nz,l01cfh		;01db	20 f2 	  	Try again
l01ddh:
	pop bc			;01dd	c1 	. 
	pop de			;01de	d1 	. 
	in a,(0e4h)		;01df	db e4 		FDC Status Register
	and 01ch		;01e1	e6 1c 		00011100b keep only error bits
	jr z,l01f3h		;01e3	28 0e 		Jump if no error
	pop hl			;01e5	e1 	. 
	dec e			;01e6	1d 	. 
	jr nz,l01bbh		;01e7	20 d2 	  	Retry reading sector	
	bit 4,a			;01e9	cb 67 		SEEK ERROR
	jr nz,l0238h		;01eb	20 4b 	  	Jump to 'TK = Record not found bootstrap track error' routine
	bit 3,a			;01ed	cb 5f 		CRC ERROR
	jr nz,l0224h		;01ef	20 33 	  	Jump to SC = 'CRC Error' message routine
	jr l023dh		;01f1	18 4a 		Jump to LD = 'Lost data during read' message routine
l01f3h:
	pop af			;01f3	f1 	 	
	inc c			;01f4	0c 	 	
	ld e,028h		;01f5	1e 28 	 	
	dec d			;01f7	15 	 	
	jr nz,l01bbh		;01f8	20 c1 	   	
	ld hl,l02e1h+1		;01fa	21 e2 02 	 
	ld de,01000h		;01fd	11 00 10 	 
	ld b,004h		;0200	06 04 	 	
	call sub_029ah		;0202	cd 9a 02 	
	jr nz,l0242h		;0205	20 3b 	  	Jump to RS = 'Diskette not RS format error' routine
	ld hl,002feh		;0207	21 fe 02 	! . . 
	ld de,01400h		;020a	11 00 14 	. . . 
	ld b,004h		;020d	06 04 	. . 
	call sub_029ah		;020f	cd 9a 02 	. . . 
	jr nz,l0242h		;0212	20 2e 	  	Jump to RS = 'Diskette not RS format' error routine
	call 01404h		;0214	cd 04 14 	. . . 
	jp 01004h		;0217	c3 04 10 	. . . 
l021ah:
	ld de,04443h		;021a	11 43 44 	. C D ; DC = Floppy disk controller error.
	jr l0245h		;021d	18 26 	. & 
l021fh:
	ld de,04430h		;021f	11 30 44 	. 0 D ; D0 = Drive not ready
	jr l0245h		;0222	18 21 	. ! 
l0224h:
	ld de,05343h		;0224	11 43 53 	. C S ; SC = CRC Error
	jr l0245h		;0227	18 1c 	. . 
l0229h:
	ld de,0434bh		;0229	11 4b 43 	. K C ; CK = ROM checksum error
	jr l0259h		;022c	18 2b 	. + 
l022eh:
	ld de,05a38h		;022e	11 38 5a 	. 8 Z ; Z8 = Defective CPU
	jr l0259h		;0231	18 26 	. & 
l0233h:
	ld de,04d46h		;0233	11 46 4d 	. F M ; MF = Memory failure
	jr l0259h		;0236	18 21 	. ! 
l0238h:
	ld de,0544bh		;0238	11 4b 54 	. K T ; TK = Record not found bootstrap track
	jr l0245h		;023b	18 08 	. . 
l023dh:
	ld de,04c44h		;023d	11 44 4c 	. D L ; LD = Lost data during read
	jr l0245h		;0240	18 03 	. . 
l0242h:
	ld de,05253h		;0242	11 53 52 	. S R ; RS = Diskette not RS format
l0245h:
	call sub_0288h		;0245	cd 88 02 	. . . 
	ld a,002h		;0248	3e 02 	> . 
	out (0e4h),a		;024a	d3 e4 		
	ld bc,l0000h		;024c	01 00 00 	. . . 
	call sub_0282h		;024f	cd 82 02 	. . . 
	call sub_0288h		;0252	cd 88 02 	. . . 
	ld a,04fh		;0255	3e 4f 	> O 
	out (0efh),a		;0257	d3 ef 		Deselect floppy drives 
l0259h:
	ld hl,0fb9ah		;0259	21 9a fb 	Load target location in video memory
	ld (hl),d		;025c	72 		Copy first character
	inc hl			;025d	23 	
	ld (hl),e			;025e	73 	Copy next character
	inc hl			;025f	23 	# 
	ld (hl),020h		;0260	36 20 		Copy a space
	ld hl,l02e1h		;0262	21 e1 02 	Set up block
	ld de,0fb8eh		;0265	11 8e fb 	copy of 
	ld bc,0000ch		;0268	01 0c 00 	'BOOT ERROR'
	ldir			;026b	ed b0 		message
	in a,(0ffh)		;026d	db ff 		Get Video state
	bit 7,a			;026f	cb 7f 		If video RAM disabled
	jr z,l027dh		;0271	28 0a		Jump to HALT
	cp 01bh			;0273	fe 1b 		If 40 char mode & MEM bank B selected
	jp z,01004h		;0275	ca 04 10 	Jump to boot sector?
	cp 003h			;0278	fe 03 		If MEM bank 3 selected
	jp z,01004h		;027a	ca 04 10 	Jump to boot sector?
l027dh:
	halt			;027d	76 		halt here
	rst 0			;027e	c7 	. 
sub_027fh:
	ld bc,00005h		;027f	01 05 00 	. . . 
sub_0282h:
	dec bc			;0282	0b 		Some delay
	ld a,b			;0283	78 	
	or c			;0284	b1 	
	jr nz,sub_0282h		;0285	20 fb 	  
	ret			;0287	c9 	
sub_0288h:			;		Reset FDC
	push bc			;0288	c5 	
	ld a,0d8h		;0289	3e d8 		Force Interrupt, immediate
	out (0e4h),a		;028b	d3 e4 		to FDC Command Register
	ld a,0d0h		;028d	3e d0 		Force Interrupt, reset busy, clear Load Command and Read Status Registers
	out (0e4h),a		;028f	d3 e4 		to FDC Command Register
	call sub_027fh		;0291	cd 7f 02 	Short delay
	in a,(0e7h)		;0294	db e7 		FDC Data Register
	in a,(0e4h)		;0296	db e4 		FDC Status Register
	pop bc			;0298	c1 	. 
	ret			;0299	c9 	. 
sub_029ah:
	ld a,(de)			;029a	1a 	. 
	cp (hl)			;029b	be 	. 
	ret nz			;029c	c0 	. 
	inc hl			;029d	23 	# 
	inc de			;029e	13 	. 
	djnz sub_029ah		;029f	10 f9 	. . 
	ret			;02a1	c9 	. 
sub_02a2h:
	in a,(0ffh)		;02a2	db ff 	 	Get Video status
	xor 080h		;02a4	ee 80 	 	
	bit 7,a			;02a6	cb 7f 		Is video RAM enabled?
	ret nz			;02a8	c0 		Return if true
	in a,(0fch)		;02a9	db fc 		Read keyboard
	cp 01bh			;02ab	fe 1b 		Is it ESC?
	ret z			;02ad	c8 		Return if so
	cp 003h			;02ae	fe 03 		Is it ETX?
	ret			;02b0	c9 		
sub_02b1h:
	push bc			;02b1	c5 	. 
	ld bc,l0000h		;02b2	01 00 00 	. . . 
l02b5h:
	in a,(0cfh)		;02b5	db cf 		WD1002 Status Register
	bit 7,a			;02b7	cb 7f 		 Busy?
	jr nz,l02bfh		;02b9	20 04 	  . 
	bit 4,a			;02bb	cb 67 		 Seek complete?
	jr nz,l02cch		;02bd	20 0d 	  . 
l02bfh:
	ex (sp),ix		;02bf	dd e3 		Very short delay?
	ex (sp),ix		;02c1	dd e3 		..
	dec bc			;02c3	0b 	. 
	ld a,b			;02c4	78 	x 
	or c			;02c5	b1 	. 
	jr nz,l02b5h		;02c6	20 ed 	  . 
	or 008h		;02c8	f6 08 	. . 
	pop bc			;02ca	c1 	. 
	ret			;02cb	c9 	. 
l02cch:
	pop bc			;02cc	c1 	. 
	bit 0,a		;02cd	cb 47 	. G 
	ret z			;02cf	c8 	. 
	in a,(0c9h)		;02d0	db c9 	. . 
	ret			;02d2	c9 	. 
l02d3h: 			; /* END BOOT */
	cpl			;02d3	2f 	/ 
	ld hl,(04520h)		;02d4	2a 20 45 	*   E 
	ld c,(hl)		;02d7	4e 	N 
	ld b,h			;02d8	44 	D 
	jr nz,l031dh		;02d9	20 42 	  B 
	ld c,a			;02db	4f 	O 
	ld c,a			;02dc	4f 	O 
	ld d,h			;02dd	54 	T 
	jr nz,l030ah		;02de	20 2a 	  * 
	cpl			;02e0	2f 	/ 
l02e1h:
	jr nz,l0325h		;02e1	20 42 	  B 
	ld c,a			;02e3	4f 	O 
	ld c,a			;02e4	4f 	O 
	ld d,h			;02e5	54 	T 
	jr nz,l032dh		;02e6	20 45 	  E 
	ld d,d			;02e8	52 	R 
	ld d,d			;02e9	52 	R 
	ld c,a			;02ea	4f 	O 
	ld d,d			;02eb	52 	R 
	jr nz,l030eh		;02ec	20 20 	    
	ld c,c			;02ee	49 	I 
	ld c,(hl)			;02ef	4e 	N 
	ld d,e			;02f0	53 	S 
	ld b,l			;02f1	45 	E 
	ld d,d			;02f2	52 	R 
	ld d,h			;02f3	54 	T 
	jr nz,l033ah		;02f4	20 44 	  D 
	ld c,c			;02f6	49 	I 
	ld d,e			;02f7	53 	S 
	ld c,e			;02f8	4b 	K 
	ld b,l			;02f9	45 	E 
	ld d,h			;02fa	54 	T 
	ld d,h			;02fb	54 	T 
	ld b,l			;02fc	45 	E 
	jr nz,l0343h		;02fd	20 44 	  D 
	ld c,c			;02ff	49 	I 
	ld b,c			;0300	41 	A 
	ld b,a			;0301	47 	G 
				; 	CRTC register values
	ld h,e			;0302	63 	0  Horizontal Total
	ld d,b			;0303	50 	1  Horizontal Displayed (80 char.)
	ld d,l			;0304	55 	2  H. Sync Position
	ex af,af'		;0305	08 	3  H. Sync Width
	add hl,de		;0306	19 	4  Vertical Total (25 lines)
	nop			;0307	00 	5  V. Total Adjust
	jr l0322h		;0308	18 18 	7  V.Sync Position, 6  Vertical Displacement
l030ah:
	nop			;030a	00 	8  Interlace Mode
	add hl,bc		;030b	09 	9  Max Scan Line Address
	ld h,l			;030c	65 	a  Cursor Start
	add hl,bc		;030d	09 	b  Cursor End
l030eh:
	nop			;030e	00 	c  Start Address (H)
	nop			;030f	00 	d  Start Address (L)
	inc bc			;0310	03 	e  Cursor (H)
l0311h: 
	jp (hl)			;0311	e9 	f  Cursor (L)

	inc bc			;0312	03 	Version?
	add a,d			;0313	82 	YY?
	dec b			;0314	05 	MM?
	rlca			;0315	07 	DD?
	ld (de),a		;0316	12 	
	ld b,e			;0317	43 	
	sub l			;0318	95 	
l0319h:	; End of ROM code and checksum area
	rst 38h			;0319	ff 	. 
	rst 38h			;031a	ff 	. 
	rst 38h			;031b	ff 	. 
	rst 38h			;031c	ff 	. 
l031dh:
	rst 38h			;031d	ff 	. 
	rst 38h			;031e	ff 	. 
	rst 38h			;031f	ff 	. 
	rst 38h			;0320	ff 	. 
	rst 38h			;0321	ff 	. 
l0322h:
	rst 38h			;0322	ff 	. 
	rst 38h			;0323	ff 	. 
	rst 38h			;0324	ff 	. 
l0325h:
	rst 38h			;0325	ff 	. 
	rst 38h			;0326	ff 	. 
	rst 38h			;0327	ff 	. 
	rst 38h			;0328	ff 	. 
	rst 38h			;0329	ff 	. 
	rst 38h			;032a	ff 	. 
	rst 38h			;032b	ff 	. 
	rst 38h			;032c	ff 	. 
l032dh:
	rst 38h			;032d	ff 	. 
	rst 38h			;032e	ff 	. 
	rst 38h			;032f	ff 	. 
	rst 38h			;0330	ff 	. 
	rst 38h			;0331	ff 	. 
	rst 38h			;0332	ff 	. 
	rst 38h			;0333	ff 	. 
	rst 38h			;0334	ff 	. 
	rst 38h			;0335	ff 	. 
	rst 38h			;0336	ff 	. 
	rst 38h			;0337	ff 	. 
	rst 38h			;0338	ff 	. 
	rst 38h			;0339	ff 	. 
l033ah:
	rst 38h			;033a	ff 	. 
	rst 38h			;033b	ff 	. 
	rst 38h			;033c	ff 	. 
	rst 38h			;033d	ff 	. 
	rst 38h			;033e	ff 	. 
	rst 38h			;033f	ff 	. 
	rst 38h			;0340	ff 	. 
	rst 38h			;0341	ff 	. 
	rst 38h			;0342	ff 	. 
l0343h:
	rst 38h			;0343	ff 	. 
	rst 38h			;0344	ff 	. 
	rst 38h			;0345	ff 	. 
	rst 38h			;0346	ff 	. 
	rst 38h			;0347	ff 	. 
	rst 38h			;0348	ff 	. 
	rst 38h			;0349	ff 	. 
	rst 38h			;034a	ff 	. 
	rst 38h			;034b	ff 	. 
	rst 38h			;034c	ff 	. 
	rst 38h			;034d	ff 	. 
	rst 38h			;034e	ff 	. 
	rst 38h			;034f	ff 	. 
	rst 38h			;0350	ff 	. 
	rst 38h			;0351	ff 	. 
	rst 38h			;0352	ff 	. 
	rst 38h			;0353	ff 	. 
	rst 38h			;0354	ff 	. 
	rst 38h			;0355	ff 	. 
	rst 38h			;0356	ff 	. 
	rst 38h			;0357	ff 	. 
	rst 38h			;0358	ff 	. 
	rst 38h			;0359	ff 	. 
	rst 38h			;035a	ff 	. 
	rst 38h			;035b	ff 	. 
	rst 38h			;035c	ff 	. 
	rst 38h			;035d	ff 	. 
	rst 38h			;035e	ff 	. 
	rst 38h			;035f	ff 	. 
	rst 38h			;0360	ff 	. 
	rst 38h			;0361	ff 	. 
	rst 38h			;0362	ff 	. 
	rst 38h			;0363	ff 	. 
	rst 38h			;0364	ff 	. 
	rst 38h			;0365	ff 	. 
	rst 38h			;0366	ff 	. 
	rst 38h			;0367	ff 	. 
	rst 38h			;0368	ff 	. 
	rst 38h			;0369	ff 	. 
	rst 38h			;036a	ff 	. 
	rst 38h			;036b	ff 	. 
	rst 38h			;036c	ff 	. 
	rst 38h			;036d	ff 	. 
	rst 38h			;036e	ff 	. 
	rst 38h			;036f	ff 	. 
	rst 38h			;0370	ff 	. 
	rst 38h			;0371	ff 	. 
	rst 38h			;0372	ff 	. 
	rst 38h			;0373	ff 	. 
	rst 38h			;0374	ff 	. 
	rst 38h			;0375	ff 	. 
	rst 38h			;0376	ff 	. 
	rst 38h			;0377	ff 	. 
	rst 38h			;0378	ff 	. 
	rst 38h			;0379	ff 	. 
	rst 38h			;037a	ff 	. 
	rst 38h			;037b	ff 	. 
	rst 38h			;037c	ff 	. 
	rst 38h			;037d	ff 	. 
	rst 38h			;037e	ff 	. 
	rst 38h			;037f	ff 	. 
	rst 38h			;0380	ff 	. 
	rst 38h			;0381	ff 	. 
	rst 38h			;0382	ff 	. 
	rst 38h			;0383	ff 	. 
	rst 38h			;0384	ff 	. 
	rst 38h			;0385	ff 	. 
	rst 38h			;0386	ff 	. 
	rst 38h			;0387	ff 	. 
	rst 38h			;0388	ff 	. 
	rst 38h			;0389	ff 	. 
	rst 38h			;038a	ff 	. 
	rst 38h			;038b	ff 	. 
	rst 38h			;038c	ff 	. 
	rst 38h			;038d	ff 	. 
	rst 38h			;038e	ff 	. 
	rst 38h			;038f	ff 	. 
	rst 38h			;0390	ff 	. 
	rst 38h			;0391	ff 	. 
	rst 38h			;0392	ff 	. 
	rst 38h			;0393	ff 	. 
	rst 38h			;0394	ff 	. 
	rst 38h			;0395	ff 	. 
	rst 38h			;0396	ff 	. 
	rst 38h			;0397	ff 	. 
	rst 38h			;0398	ff 	. 
	rst 38h			;0399	ff 	. 
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
	rst 38h			;03a7	ff 	. 
	rst 38h			;03a8	ff 	. 
	rst 38h			;03a9	ff 	. 
	rst 38h			;03aa	ff 	. 
	rst 38h			;03ab	ff 	. 
	rst 38h			;03ac	ff 	. 
	rst 38h			;03ad	ff 	. 
	rst 38h			;03ae	ff 	. 
	rst 38h			;03af	ff 	. 
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
	add a,a			;04cc	87 	. 
	add a,a			;04cd	87 	. 
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
	nop			;0583	00 	. 
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
	ld b,0ffh		;05c8	06 ff 	. . 
	rst 38h			;05ca	ff 	. 
	rst 38h			;05cb	ff 	. 
	add a,(hl)			;05cc	86 	. 
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
	nop			;0783	00 	. 
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
	inc b			;07c8	04 	. 
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
