; z80dasm 1.1.0
; command line: z80dasm -a -l -g 0 -t cpu_c8ff.bin

; Version 1 ?

;Source: Model II Technical Reference Manual 26-4921

; HDA board
; No Hard disk support

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
	ld a,080h		;0001	3e 80 	> . 
	out (0ffh),a		;0003	d3 ff 	. . 
l0005h:
	ld sp,02000h		;0005	31 00 20 	1 .   
	ld bc,l07ffh		;0008	01 ff 07 	. . . 
l000bh:
	ld de,0fffeh		;000b	11 fe ff 	. . . 
	ld hl,0ffffh		;000e	21 ff ff 	! . . 
	ld (hl),0a0h		;0011	36 a0 	6 . 
	lddr		;0013	ed b8 	. . 
	ld bc,00ffch		;0015	01 fc 0f 	. . . 
	ld hl,l01f9h		;0018	21 f9 01 	Set up CTRC register
l001bh:
	ld a,(hl)			;001b	7e 	~ 
	out (c),b		;001c	ed 41 	. A 
	out (0fdh),a		;001e	d3 fd 	. . 
	dec hl			;0020	2b 	+ 
	dec b			;0021	05 	. 
	jp p,l001bh		;0022	f2 1b 00 	. . . 
	ld hl,l0000h		;0025	21 00 00 	! . . 
	ld de,l01ffh		;0028	11 ff 01 	. . . 
	xor a			;002b	af 	. 
l002ch:
	ld b,(hl)			;002c	46 	F 
	add a,b			;002d	80 	. 
	inc hl			;002e	23 	# 
	dec de			;002f	1b 	. 
	ld c,a			;0030	4f 	O 
	ld a,d			;0031	7a 	z 
	or e			;0032	b3 	. 
	ld a,c			;0033	79 	y 
	jr nz,l002ch		;0034	20 f6 	  . 
	cpl			;0036	2f 	/ 
	cp (hl)			;0037	be 	. 
	ld hl,(l01d0h)		;0038	2a d0 01 	* . . 
	jp nz,l00e3h		;003b	c2 e3 00 	. . . 
	ld a,055h		;003e	3e 55 	> U 
	cpl			;0040	2f 	/ 
	or a			;0041	b7 	. 
	and a			;0042	a7 	. 
	ex af,af'			;0043	08 	. 
	ex af,af'			;0044	08 	. 
	ld b,a			;0045	47 	G 
	ld c,b			;0046	48 	H 
	ld d,c			;0047	51 	Q 
	ld e,d			;0048	5a 	Z 
	ld h,e			;0049	63 	c 
	ld l,h			;004a	6c 	l 
	ex de,hl			;004b	eb 	. 
	exx			;004c	d9 	. 
	exx			;004d	d9 	. 
	inc l			;004e	2c 	, 
	dec l			;004f	2d 	- 
	cp l			;0050	bd 	. 
	ld hl,(l01cch)		;0051	2a cc 01 	* . . 
	jp nz,l00e3h		;0054	c2 e3 00 	. . . 
	ld hl,01000h		;0057	21 00 10 	! . . 
l005ah:
	ld a,(hl)			;005a	7e 	~ 
	cpl			;005b	2f 	/ 
	ld (hl),a			;005c	77 	w 
	cp (hl)			;005d	be 	. 
	cpl			;005e	2f 	/ 
	ld (hl),a			;005f	77 	w 
	jp nz,l00cch		;0060	c2 cc 00 	. . . 
	inc hl			;0063	23 	# 
	ld a,h			;0064	7c 	| 
	cp 080h		;0065	fe 80 	. . 
	jr nz,l005ah		;0067	20 f1 	  . 
	ld d,0c8h		;0069	16 c8 	. . 
l006bh:
	in a,(0ffh)		;006b	db ff 	. . 
	bit 7,a		;006d	cb 7f 	.  
	jr z,l0073h		;006f	28 02 	( . 
	in a,(0fch)		;0071	db fc 	. . 
l0073h:
	ld bc,l0080h		;0073	01 80 00 	. . . 
	call sub_018bh		;0076	cd 8b 01 	. . . 
	dec d			;0079	15 	. 
	jr nz,l006bh		;007a	20 ef 	  . 
	ld a,04eh		;007c	3e 4e 	> N 
	out (0efh),a		;007e	d3 ef 	. . 
l0080h:
	ld hl,l01d4h		;0080	21 d4 01 	! . . 
	ld de,0fb8eh		;0083	11 8e fb 	. . . 
	ld b,000h		;0086	06 00 	. . 
	ld c,(hl)			;0088	4e 	N 
	inc hl			;0089	23 	# 
	ldir		;008a	ed b0 	. . 
l008ch:
	call sub_0191h		;008c	cd 91 01 	. . . 
	bit 7,a		;008f	cb 7f 	.  
	jr nz,l008ch		;0091	20 f9 	  . 
	ld bc,l07ffh		;0093	01 ff 07 	. . . 
	ld de,0fffeh		;0096	11 fe ff 	. . . 
	ld hl,0ffffh		;0099	21 ff ff 	! . . 
	ld (hl),020h		;009c	36 20 	6   
	lddr		;009e	ed b8 	. . 
	call sub_0191h		;00a0	cd 91 01 	. . . 
	ld a,006h		;00a3	3e 06 	> . 
	out (0e4h),a		;00a5	d3 e4 	. . 
	ld d,007h		;00a7	16 07 	. . 
l00a9h:
	call sub_018bh		;00a9	cd 8b 01 	. . . 
	dec d			;00ac	15 	. 
	jr nz,l00a9h		;00ad	20 fa 	  . 
	in a,(0e4h)		;00af	db e4 	. . 
	bit 0,a		;00b1	cb 47 	. G 
	jr nz,l00c7h		;00b3	20 12 	  . 
	bit 4,a		;00b5	cb 67 	. g 
	jr nz,l00c7h		;00b7	20 0e 	  . 
	bit 2,a		;00b9	cb 57 	. W 
	jr z,l00c7h		;00bb	28 0a 	( . 
	bit 7,a		;00bd	cb 7f 	.  
	jr nz,l00d1h		;00bf	20 10 	  . 
	bit 3,a		;00c1	cb 5f 	. _ 
	jr nz,l00dbh		;00c3	20 16 	  . 
	jr l0128h		;00c5	18 61 	. a 
l00c7h:
	ld hl,(001c2h)		;00c7	2a c2 01 	* . . 
	jr l00e3h		;00ca	18 17 	. . 
l00cch:
	ld hl,(001ceh)		;00cc	2a ce 01 	* . . 
	jr l00e3h		;00cf	18 12 	. . 
l00d1h:
	ld hl,(l01c6h)		;00d1	2a c6 01 	* . . 
	jr l00e3h		;00d4	18 0d 	. . 
l00d6h:
	ld hl,(l01c4h)		;00d6	2a c4 01 	* . . 
	jr l00e3h		;00d9	18 08 	. . 
l00dbh:
	ld hl,(001c8h)		;00db	2a c8 01 	* . . 
	jr l00e3h		;00de	18 03 	. . 
l00e0h:
	ld hl,(l01cah)		;00e0	2a ca 01 	* . . 
l00e3h:
	ld de,0fb99h		;00e3	11 99 fb 	. . . 
	ex de,hl			;00e6	eb 	. 
	ld (hl),e			;00e7	73 	s 
	inc hl			;00e8	23 	# 
	ld (hl),d			;00e9	72 	r 
	inc hl			;00ea	23 	# 
	ld (hl),020h		;00eb	36 20 	6   
	ld de,0fb8eh		;00ed	11 8e fb 	. . . 
	ld hl,l01b7h		;00f0	21 b7 01 	! . . 
	ld bc,l000bh		;00f3	01 0b 00 	. . . 
	ldir		;00f6	ed b0 	. . 
	in a,(0ffh)		;00f8	db ff 	. . 
	bit 7,a		;00fa	cb 7f 	.  
	jr z,l0107h		;00fc	28 09 	( . 
	in a,(0fch)		;00fe	db fc 	. . 
	cp 01bh		;0100	fe 1b 	. . 
	jr nz,l0107h		;0102	20 03 	  . 
	jp 01004h		;0104	c3 04 10 	. . . 
l0107h:
	call sub_0191h		;0107	cd 91 01 	. . . 
	ld a,002h		;010a	3e 02 	> . 
	out (0e4h),a		;010c	d3 e4 	. . 
	ld bc,l0000h		;010e	01 00 00 	. . . 
	call sub_018bh		;0111	cd 8b 01 	. . . 
	call sub_0191h		;0114	cd 91 01 	. . . 
	ld a,04fh		;0117	3e 4f 	> O 
	out (0efh),a		;0119	d3 ef 	. . 
	di			;011b	f3 	. 
	halt			;011c	76 	v 
	rst 0			;011d	c7 	. 
l011eh:
	bit 4,a		;011e	cb 67 	. g 
	jr nz,l00d6h		;0120	20 b4 	  . 
	bit 3,a		;0122	cb 5f 	. _ 
	jr nz,l00dbh		;0124	20 b5 	  . 
	jr l00e0h		;0126	18 b8 	. . 
l0128h:
	ld hl,00e00h		;0128	21 00 0e 	! . . 
	ld de,01a28h		;012b	11 28 1a 	. ( . 
	ld bc,08001h		;012e	01 01 80 	. . . 
	ld a,080h		;0131	3e 80 	> . 
	ex af,af'			;0133	08 	. 
l0134h:
	push hl			;0134	e5 	. 
	push de			;0135	d5 	. 
	push bc			;0136	c5 	. 
	call sub_0191h		;0137	cd 91 01 	. . . 
	ld a,c			;013a	79 	y 
	out (0e6h),a		;013b	d3 e6 	. . 
	ex af,af'			;013d	08 	. 
	out (0e4h),a		;013e	d3 e4 	. . 
	ex af,af'			;0140	08 	. 
	call sub_0188h		;0141	cd 88 01 	. . . 
	pop bc			;0144	c1 	. 
	push bc			;0145	c5 	. 
	ld c,0e7h		;0146	0e e7 	. . 
l0148h:
	in a,(0e4h)		;0148	db e4 	. . 
	bit 1,a		;014a	cb 4f 	. O 
	jr z,l0152h		;014c	28 04 	( . 
	ini		;014e	ed a2 	. . 
	jr z,l0157h		;0150	28 05 	( . 
l0152h:
	bit 0,a		;0152	cb 47 	. G 
	jp nz,l0148h		;0154	c2 48 01 	. H . 
l0157h:
	pop bc			;0157	c1 	. 
	pop de			;0158	d1 	. 
	in a,(0e4h)		;0159	db e4 	. . 
	and 01ch		;015b	e6 1c 	. . 
	jr z,l0165h		;015d	28 06 	( . 
	pop hl			;015f	e1 	. 
	dec e			;0160	1d 	. 
	jr nz,l0134h		;0161	20 d1 	  . 
	jr l011eh		;0163	18 b9 	. . 
l0165h:
	pop af			;0165	f1 	. 
	inc c			;0166	0c 	. 
	ld e,028h		;0167	1e 28 	. ( 
	dec d			;0169	15 	. 
	jr nz,l0134h		;016a	20 c8 	  . 
	ld hl,l01b7h		;016c	21 b7 01 	! . . 
	ld de,01000h		;016f	11 00 10 	. . . 
	ld b,004h		;0172	06 04 	. . 
	call sub_01a8h		;0174	cd a8 01 	. . . 
	ld hl,001e6h		;0177	21 e6 01 	! . . 
	ld de,01400h		;017a	11 00 14 	. . . 
	ld b,004h		;017d	06 04 	. . 
	call sub_01a8h		;017f	cd a8 01 	. . . 
	call 01404h		;0182	cd 04 14 	. . . 
	jp 01004h		;0185	c3 04 10 	. . . 
sub_0188h:
	ld bc,l0005h		;0188	01 05 00 	. . . 
sub_018bh:
	dec bc			;018b	0b 	. 
	ld a,b			;018c	78 	x 
	or c			;018d	b1 	. 
	jr nz,sub_018bh		;018e	20 fb 	  . 
	ret			;0190	c9 	. 
sub_0191h:
	push bc			;0191	c5 	. 
	ld a,0d0h		;0192	3e d0 	> . 
	out (0e4h),a		;0194	d3 e4 	. . 
	call sub_0188h		;0196	cd 88 01 	. . . 
	in a,(0e7h)		;0199	db e7 	. . 
	in a,(0e4h)		;019b	db e4 	. . 
	ld a,0d0h		;019d	3e d0 	> . 
	out (0e4h),a		;019f	d3 e4 	. . 
	call sub_0188h		;01a1	cd 88 01 	. . . 
	in a,(0e4h)		;01a4	db e4 	. . 
	pop bc			;01a6	c1 	. 
	ret			;01a7	c9 	. 
sub_01a8h:
	ld a,(de)			;01a8	1a 	. 
	cp (hl)			;01a9	be 	. 
	jr nz,l01b1h		;01aa	20 05 	  . 
	inc hl			;01ac	23 	# 
	inc de			;01ad	13 	. 
	djnz sub_01a8h		;01ae	10 f8 	. . 
	ret			;01b0	c9 	. 
l01b1h:
	ld hl,(l01d2h)		;01b1	2a d2 01 	* . . 
	jp l00e3h		;01b4	c3 e3 00 	. . . 
l01b7h:
	ld b,d			;01b7	42 	B 
	ld c,a			;01b8	4f 	O 
	ld c,a			;01b9	4f 	O 
	ld d,h			;01ba	54 	T 
	jr nz,l0202h		;01bb	20 45 	  E 
	ld d,d			;01bd	52 	R 
	ld d,d			;01be	52 	R 
	ld c,a			;01bf	4f 	O 
	ld d,d			;01c0	52 	R 
	jr nz,l0207h		;01c1	20 44 	  D 
	ld b,e			;01c3	43 	C 
l01c4h:
	ld d,h			;01c4	54 	T 
	ld c,e			;01c5	4b 	K 
l01c6h:
	ld b,h			;01c6	44 	D 
	jr nc,l021ch		;01c7	30 53 	0 S 
	ld b,e			;01c9	43 	C 
l01cah:
	ld c,h			;01ca	4c 	L 
	ld b,h			;01cb	44 	D 
l01cch:
	ld e,d			;01cc	5a 	Z 
	jr c,l021ch		;01cd	38 4d 	8 M 
	ld b,(hl)			;01cf	46 	F 
l01d0h:
	ld b,e			;01d0	43 	C 
	ld c,e			;01d1	4b 	K 
l01d2h:
	ld d,d			;01d2	52 	R 
	ld d,e			;01d3	53 	S 
l01d4h:
	ld de,04920h		;01d4	11 20 49 	.   I 
	ld c,(hl)			;01d7	4e 	N 
	ld d,e			;01d8	53 	S 
	ld b,l			;01d9	45 	E 
	ld d,d			;01da	52 	R 
	ld d,h			;01db	54 	T 
	jr nz,l0222h		;01dc	20 44 	  D 
	ld c,c			;01de	49 	I 
	ld d,e			;01df	53 	S 
	ld c,e			;01e0	4b 	K 
	ld b,l			;01e1	45 	E 
	ld d,h			;01e2	54 	T 
	ld d,h			;01e3	54 	T 
	ld b,l			;01e4	45 	E 
	jr nz,l022bh		;01e5	20 44 	  D 
	ld c,c			;01e7	49 	I 
	ld b,c			;01e8	41 	A 
	ld b,a			;01e9	47 	G 
				; Set up CTRC register
	ld h,e			;01ea	63 	c 
	ld d,b			;01eb	50 	P 
	ld d,l			;01ec	55 	U 
	ex af,af'			;01ed	08 	. 
	add hl,de			;01ee	19 	. 
	nop			;01ef	00 	. 
	jr l020ah		;01f0	18 18 	. . 
	nop			;01f2	00 	. 
	add hl,bc			;01f3	09 	. 
	ld h,l			;01f4	65 	e 
	add hl,bc			;01f5	09 	. 
	nop			;01f6	00 	. 
	nop			;01f7	00 	. 
	inc bc			;01f8	03 	. 
l01f9h:
	jp (hl)			;01f9	e9 	. 

	ld bc,0ffffh		;01fa	01 ff ff Version?
	rst 38h			;01fd	ff 	. 
	rst 38h			;01fe	ff 	. 
l01ffh:
	ld a,(0ffffh)		;01ff	3a ff ff 	: . . 
l0202h:
	rst 38h			;0202	ff 	. 
	rst 38h			;0203	ff 	. 
	rst 38h			;0204	ff 	. 
	rst 38h			;0205	ff 	. 
	rst 38h			;0206	ff 	. 
l0207h:
	rst 38h			;0207	ff 	. 
	rst 38h			;0208	ff 	. 
	rst 38h			;0209	ff 	. 
l020ah:
	rst 38h			;020a	ff 	. 
	rst 38h			;020b	ff 	. 
	rst 38h			;020c	ff 	. 
	rst 38h			;020d	ff 	. 
	rst 38h			;020e	ff 	. 
	rst 38h			;020f	ff 	. 
	rst 38h			;0210	ff 	. 
	rst 38h			;0211	ff 	. 
	rst 38h			;0212	ff 	. 
	rst 38h			;0213	ff 	. 
	rst 38h			;0214	ff 	. 
	rst 38h			;0215	ff 	. 
	rst 38h			;0216	ff 	. 
	rst 38h			;0217	ff 	. 
	rst 38h			;0218	ff 	. 
	rst 38h			;0219	ff 	. 
	rst 38h			;021a	ff 	. 
	rst 38h			;021b	ff 	. 
l021ch:
	rst 38h			;021c	ff 	. 
	rst 38h			;021d	ff 	. 
	rst 38h			;021e	ff 	. 
	rst 38h			;021f	ff 	. 
	rst 38h			;0220	ff 	. 
	rst 38h			;0221	ff 	. 
l0222h:
	rst 38h			;0222	ff 	. 
	rst 38h			;0223	ff 	. 
	rst 38h			;0224	ff 	. 
	rst 38h			;0225	ff 	. 
	rst 38h			;0226	ff 	. 
	rst 38h			;0227	ff 	. 
	rst 38h			;0228	ff 	. 
	rst 38h			;0229	ff 	. 
	rst 38h			;022a	ff 	. 
l022bh:
	rst 38h			;022b	ff 	. 
	rst 38h			;022c	ff 	. 
	rst 38h			;022d	ff 	. 
	rst 38h			;022e	ff 	. 
	rst 38h			;022f	ff 	. 
	rst 38h			;0230	ff 	. 
	rst 38h			;0231	ff 	. 
	rst 38h			;0232	ff 	. 
	rst 38h			;0233	ff 	. 
	rst 38h			;0234	ff 	. 
	rst 38h			;0235	ff 	. 
	rst 38h			;0236	ff 	. 
	rst 38h			;0237	ff 	. 
	rst 38h			;0238	ff 	. 
	rst 38h			;0239	ff 	. 
	rst 38h			;023a	ff 	. 
	rst 38h			;023b	ff 	. 
	rst 38h			;023c	ff 	. 
	rst 38h			;023d	ff 	. 
	rst 38h			;023e	ff 	. 
	rst 38h			;023f	ff 	. 
	rst 38h			;0240	ff 	. 
	rst 38h			;0241	ff 	. 
	rst 38h			;0242	ff 	. 
	rst 38h			;0243	ff 	. 
	rst 38h			;0244	ff 	. 
	rst 38h			;0245	ff 	. 
	rst 38h			;0246	ff 	. 
	rst 38h			;0247	ff 	. 
	rst 38h			;0248	ff 	. 
	rst 38h			;0249	ff 	. 
	rst 38h			;024a	ff 	. 
	rst 38h			;024b	ff 	. 
	rst 38h			;024c	ff 	. 
	rst 38h			;024d	ff 	. 
	rst 38h			;024e	ff 	. 
	rst 38h			;024f	ff 	. 
	rst 38h			;0250	ff 	. 
	rst 38h			;0251	ff 	. 
	rst 38h			;0252	ff 	. 
	rst 38h			;0253	ff 	. 
	rst 38h			;0254	ff 	. 
	rst 38h			;0255	ff 	. 
	rst 38h			;0256	ff 	. 
	rst 38h			;0257	ff 	. 
	rst 38h			;0258	ff 	. 
	rst 38h			;0259	ff 	. 
	rst 38h			;025a	ff 	. 
	rst 38h			;025b	ff 	. 
	rst 38h			;025c	ff 	. 
	rst 38h			;025d	ff 	. 
	rst 38h			;025e	ff 	. 
	rst 38h			;025f	ff 	. 
	rst 38h			;0260	ff 	. 
	rst 38h			;0261	ff 	. 
	rst 38h			;0262	ff 	. 
	rst 38h			;0263	ff 	. 
	rst 38h			;0264	ff 	. 
	rst 38h			;0265	ff 	. 
	rst 38h			;0266	ff 	. 
	rst 38h			;0267	ff 	. 
	rst 38h			;0268	ff 	. 
	rst 38h			;0269	ff 	. 
	rst 38h			;026a	ff 	. 
	rst 38h			;026b	ff 	. 
	rst 38h			;026c	ff 	. 
	rst 38h			;026d	ff 	. 
	rst 38h			;026e	ff 	. 
	rst 38h			;026f	ff 	. 
	rst 38h			;0270	ff 	. 
	rst 38h			;0271	ff 	. 
	rst 38h			;0272	ff 	. 
	rst 38h			;0273	ff 	. 
	rst 38h			;0274	ff 	. 
	rst 38h			;0275	ff 	. 
	rst 38h			;0276	ff 	. 
	rst 38h			;0277	ff 	. 
	rst 38h			;0278	ff 	. 
	rst 38h			;0279	ff 	. 
	rst 38h			;027a	ff 	. 
	rst 38h			;027b	ff 	. 
	rst 38h			;027c	ff 	. 
	rst 38h			;027d	ff 	. 
	rst 38h			;027e	ff 	. 
	rst 38h			;027f	ff 	. 
	rst 38h			;0280	ff 	. 
	rst 38h			;0281	ff 	. 
	rst 38h			;0282	ff 	. 
	rst 38h			;0283	ff 	. 
	rst 38h			;0284	ff 	. 
	rst 38h			;0285	ff 	. 
	rst 38h			;0286	ff 	. 
	rst 38h			;0287	ff 	. 
	rst 38h			;0288	ff 	. 
	rst 38h			;0289	ff 	. 
	rst 38h			;028a	ff 	. 
	rst 38h			;028b	ff 	. 
	rst 38h			;028c	ff 	. 
	rst 38h			;028d	ff 	. 
	rst 38h			;028e	ff 	. 
	rst 38h			;028f	ff 	. 
	rst 38h			;0290	ff 	. 
	rst 38h			;0291	ff 	. 
	rst 38h			;0292	ff 	. 
	rst 38h			;0293	ff 	. 
	rst 38h			;0294	ff 	. 
	rst 38h			;0295	ff 	. 
	rst 38h			;0296	ff 	. 
	rst 38h			;0297	ff 	. 
	rst 38h			;0298	ff 	. 
	rst 38h			;0299	ff 	. 
	rst 38h			;029a	ff 	. 
	rst 38h			;029b	ff 	. 
	rst 38h			;029c	ff 	. 
	rst 38h			;029d	ff 	. 
	rst 38h			;029e	ff 	. 
	rst 38h			;029f	ff 	. 
	rst 38h			;02a0	ff 	. 
	rst 38h			;02a1	ff 	. 
	rst 38h			;02a2	ff 	. 
	rst 38h			;02a3	ff 	. 
	rst 38h			;02a4	ff 	. 
	rst 38h			;02a5	ff 	. 
	rst 38h			;02a6	ff 	. 
	rst 38h			;02a7	ff 	. 
	rst 38h			;02a8	ff 	. 
	rst 38h			;02a9	ff 	. 
	rst 38h			;02aa	ff 	. 
	rst 38h			;02ab	ff 	. 
	rst 38h			;02ac	ff 	. 
	rst 38h			;02ad	ff 	. 
	rst 38h			;02ae	ff 	. 
	rst 38h			;02af	ff 	. 
	rst 38h			;02b0	ff 	. 
	rst 38h			;02b1	ff 	. 
	rst 38h			;02b2	ff 	. 
	rst 38h			;02b3	ff 	. 
	rst 38h			;02b4	ff 	. 
	rst 38h			;02b5	ff 	. 
	rst 38h			;02b6	ff 	. 
	rst 38h			;02b7	ff 	. 
	rst 38h			;02b8	ff 	. 
	rst 38h			;02b9	ff 	. 
	rst 38h			;02ba	ff 	. 
	rst 38h			;02bb	ff 	. 
	rst 38h			;02bc	ff 	. 
	rst 38h			;02bd	ff 	. 
	rst 38h			;02be	ff 	. 
	rst 38h			;02bf	ff 	. 
	rst 38h			;02c0	ff 	. 
	rst 38h			;02c1	ff 	. 
	rst 38h			;02c2	ff 	. 
	rst 38h			;02c3	ff 	. 
	rst 38h			;02c4	ff 	. 
	rst 38h			;02c5	ff 	. 
	rst 38h			;02c6	ff 	. 
	rst 38h			;02c7	ff 	. 
	rst 38h			;02c8	ff 	. 
	rst 38h			;02c9	ff 	. 
	rst 38h			;02ca	ff 	. 
	rst 38h			;02cb	ff 	. 
	rst 38h			;02cc	ff 	. 
	rst 38h			;02cd	ff 	. 
	rst 38h			;02ce	ff 	. 
	rst 38h			;02cf	ff 	. 
	rst 38h			;02d0	ff 	. 
	rst 38h			;02d1	ff 	. 
	rst 38h			;02d2	ff 	. 
	rst 38h			;02d3	ff 	. 
	rst 38h			;02d4	ff 	. 
	rst 38h			;02d5	ff 	. 
	rst 38h			;02d6	ff 	. 
	rst 38h			;02d7	ff 	. 
	rst 38h			;02d8	ff 	. 
	rst 38h			;02d9	ff 	. 
	rst 38h			;02da	ff 	. 
	rst 38h			;02db	ff 	. 
	rst 38h			;02dc	ff 	. 
	rst 38h			;02dd	ff 	. 
	rst 38h			;02de	ff 	. 
	rst 38h			;02df	ff 	. 
	rst 38h			;02e0	ff 	. 
	rst 38h			;02e1	ff 	. 
	rst 38h			;02e2	ff 	. 
	rst 38h			;02e3	ff 	. 
	rst 38h			;02e4	ff 	. 
	rst 38h			;02e5	ff 	. 
	rst 38h			;02e6	ff 	. 
	rst 38h			;02e7	ff 	. 
	rst 38h			;02e8	ff 	. 
	rst 38h			;02e9	ff 	. 
	rst 38h			;02ea	ff 	. 
	rst 38h			;02eb	ff 	. 
	rst 38h			;02ec	ff 	. 
	rst 38h			;02ed	ff 	. 
	rst 38h			;02ee	ff 	. 
	rst 38h			;02ef	ff 	. 
	rst 38h			;02f0	ff 	. 
	rst 38h			;02f1	ff 	. 
	rst 38h			;02f2	ff 	. 
	rst 38h			;02f3	ff 	. 
	rst 38h			;02f4	ff 	. 
	rst 38h			;02f5	ff 	. 
	rst 38h			;02f6	ff 	. 
	rst 38h			;02f7	ff 	. 
	rst 38h			;02f8	ff 	. 
	rst 38h			;02f9	ff 	. 
	rst 38h			;02fa	ff 	. 
	rst 38h			;02fb	ff 	. 
	rst 38h			;02fc	ff 	. 
	rst 38h			;02fd	ff 	. 
	rst 38h			;02fe	ff 	. 
	rst 38h			;02ff	ff 	. 
	rst 38h			;0300	ff 	. 
	rst 38h			;0301	ff 	. 
	rst 38h			;0302	ff 	. 
	rst 38h			;0303	ff 	. 
	rst 38h			;0304	ff 	. 
	rst 38h			;0305	ff 	. 
	rst 38h			;0306	ff 	. 
	rst 38h			;0307	ff 	. 
	rst 38h			;0308	ff 	. 
	rst 38h			;0309	ff 	. 
	rst 38h			;030a	ff 	. 
	rst 38h			;030b	ff 	. 
	rst 38h			;030c	ff 	. 
	rst 38h			;030d	ff 	. 
	rst 38h			;030e	ff 	. 
	rst 38h			;030f	ff 	. 
	rst 38h			;0310	ff 	. 
	rst 38h			;0311	ff 	. 
	rst 38h			;0312	ff 	. 
	rst 38h			;0313	ff 	. 
	rst 38h			;0314	ff 	. 
	rst 38h			;0315	ff 	. 
	rst 38h			;0316	ff 	. 
	rst 38h			;0317	ff 	. 
	rst 38h			;0318	ff 	. 
	rst 38h			;0319	ff 	. 
	rst 38h			;031a	ff 	. 
	rst 38h			;031b	ff 	. 
	rst 38h			;031c	ff 	. 
	rst 38h			;031d	ff 	. 
	rst 38h			;031e	ff 	. 
	rst 38h			;031f	ff 	. 
	rst 38h			;0320	ff 	. 
	rst 38h			;0321	ff 	. 
	rst 38h			;0322	ff 	. 
	rst 38h			;0323	ff 	. 
	rst 38h			;0324	ff 	. 
	rst 38h			;0325	ff 	. 
	rst 38h			;0326	ff 	. 
	rst 38h			;0327	ff 	. 
	rst 38h			;0328	ff 	. 
	rst 38h			;0329	ff 	. 
	rst 38h			;032a	ff 	. 
	rst 38h			;032b	ff 	. 
	rst 38h			;032c	ff 	. 
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
	rst 38h			;033a	ff 	. 
	rst 38h			;033b	ff 	. 
	rst 38h			;033c	ff 	. 
	rst 38h			;033d	ff 	. 
	rst 38h			;033e	ff 	. 
	rst 38h			;033f	ff 	. 
	rst 38h			;0340	ff 	. 
	rst 38h			;0341	ff 	. 
	rst 38h			;0342	ff 	. 
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
