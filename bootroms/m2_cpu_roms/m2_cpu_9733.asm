; z80dasm 1.1.0
; command line: z80dasm -a -l -g 0 -t /home/fjkraan/kryten/site/comp/trs80m2/marmotking/Z80 CPU Board, Model II, 16 (Tandy)/Z80 CPU Board [ROM]/cpu_9733.bin

	org	00000h

l0000h:
	di			;0000	f3 	. 
	ld sp,02800h		;0001	31 00 28 	1 . ( 
	ld a,080h		;0004	3e 80 	> . 
	out (0ffh),a		;0006	d3 ff 	. . 
	ld a,083h		;0008	3e 83 	> . 
	out (0f8h),a		;000a	d3 f8 	. . 
l000ch:
	ld a,0c3h		;000c	3e c3 	> . 
	out (0f8h),a		;000e	d3 f8 	. . 
	out (0f8h),a		;0010	d3 f8 	. . 
	out (0f8h),a		;0012	d3 f8 	. . 
	out (0f8h),a		;0014	d3 f8 	. . 
	out (0f8h),a		;0016	d3 f8 	. . 
	ld a,003h		;0018	3e 03 	> . 
	out (0f0h),a		;001a	d3 f0 	. . 
	out (0f1h),a		;001c	d3 f1 	. . 
	out (0f2h),a		;001e	d3 f2 	. . 
	out (0f3h),a		;0020	d3 f3 	. . 
	out (0e3h),a		;0022	d3 e3 	. . 
	out (0e2h),a		;0024	d3 e2 	. . 
	ld a,018h		;0026	3e 18 	> . 
	out (0f6h),a		;0028	d3 f6 	. . 
	out (0f7h),a		;002a	d3 f7 	. . 
	ld bc,l07ffh		;002c	01 ff 07 	. . . 
	ld de,0fffeh		;002f	11 fe ff 	. . . 
	ld hl,0ffffh		;0032	21 ff ff 	! . . 
	ld (hl),0a0h		;0035	36 a0 	6 . 
	lddr		;0037	ed b8 	. . 
	ld bc,00ffch		;0039	01 fc 0f 	. . . 
	ld hl,l0398h		;003c	21 98 03 	! . . 
l003fh:
	ld a,(hl)			;003f	7e 	~ 
	out (c),b		;0040	ed 41 	. A 
	out (0fdh),a		;0042	d3 fd 	. . 
	dec hl			;0044	2b 	+ 
	dec b			;0045	05 	. 
	jp p,l003fh		;0046	f2 3f 00 	. ? . 
	ld a,055h		;0049	3e 55 	> U 
	cpl			;004b	2f 	/ 
	or a			;004c	b7 	. 
	and a			;004d	a7 	. 
	ld b,a			;004e	47 	G 
	ld c,b			;004f	48 	H 
	ld d,c			;0050	51 	Q 
	ld e,d			;0051	5a 	Z 
	ld h,e			;0052	63 	c 
	ld l,h			;0053	6c 	l 
	inc l			;0054	2c 	, 
	dec l			;0055	2d 	- 
	ex de,hl			;0056	eb 	. 
	ex af,af'			;0057	08 	. 
	ld a,e			;0058	7b 	{ 
	exx			;0059	d9 	. 
	ld b,a			;005a	47 	G 
	ld c,b			;005b	48 	H 
	ld d,c			;005c	51 	Q 
	ld e,d			;005d	5a 	Z 
	ld h,e			;005e	63 	c 
	ld l,h			;005f	6c 	l 
	ld a,l			;0060	7d 	} 
	ld i,a		;0061	ed 47 	. G 
	ld a,i		;0063	ed 57 	. W 
	ld l,a			;0065	6f 	o 
	ex af,af'			;0066	08 	. 
	cp l			;0067	bd 	. 
	jp nz,l0291h		;0068	c2 91 02 	. . . 
	ld bc,07000h		;006b	01 00 70 	. . p 
	ld hl,01000h		;006e	21 00 10 	! . . 
	ld d,h			;0071	54 	T 
	ld e,l			;0072	5d 	] 
l0073h:
	ld a,(de)			;0073	1a 	. 
	cpl			;0074	2f 	/ 
	ld (de),a			;0075	12 	. 
	cp (hl)			;0076	be 	. 
	cpl			;0077	2f 	/ 
	ld (hl),a			;0078	77 	w 
	jp nz,l0296h		;0079	c2 96 02 	. . . 
	ldi		;007c	ed a0 	. . 
	jp pe,l0073h		;007e	ea 73 00 	. s . 
	ld d,0c8h		;0081	16 c8 	. . 
l0083h:
	in a,(0ffh)		;0083	db ff 	. . 
	bit 7,a		;0085	cb 7f 	.  
	jr z,l008bh		;0087	28 02 	( . 
	in a,(0fch)		;0089	db fc 	. . 
l008bh:
	ld bc,00080h		;008b	01 80 00 	. . . 
	call sub_02d5h		;008e	cd d5 02 	. . . 
	dec d			;0091	15 	. 
	jr nz,l0083h		;0092	20 ef 	  . 
	ld b,004h		;0094	06 04 	. . 
	ld de,040f7h		;0096	11 f7 40 	. . @ 
l0099h:
	push bc			;0099	c5 	. 
	push de			;009a	d5 	. 
	ld a,e			;009b	7b 	{ 
	and 00fh		;009c	e6 0f 	. . 
	or d			;009e	b2 	. 
	out (0efh),a		;009f	d3 ef 	. . 
	call sub_02dbh		;00a1	cd db 02 	. . . 
	xor a			;00a4	af 	. 
	out (0e5h),a		;00a5	d3 e5 	. . 
	ld a,005h		;00a7	3e 05 	> . 
	out (0e7h),a		;00a9	d3 e7 	. . 
	ld a,013h		;00ab	3e 13 	> . 
	out (0e4h),a		;00ad	d3 e4 	. . 
	call sub_0333h		;00af	cd 33 03 	. 3 . 
	pop de			;00b2	d1 	. 
	rrc e		;00b3	cb 0b 	. . 
	pop bc			;00b5	c1 	. 
	djnz l0099h		;00b6	10 e1 	. . 
	ld a,00fh		;00b8	3e 0f 	> . 
	out (0efh),a		;00ba	d3 ef 	. . 
	xor a			;00bc	af 	. 
	out (0c1h),a		;00bd	d3 c1 	. . 
	ld a,010h		;00bf	3e 10 	> . 
	out (0c1h),a		;00c1	d3 c1 	. . 
	ld a,00eh		;00c3	3e 0e 	> . 
	out (0c1h),a		;00c5	d3 c1 	. . 
	ld a,0aah		;00c7	3e aa 	> . 
	out (0cah),a		;00c9	d3 ca 	. . 
	in a,(0cah)		;00cb	db ca 	. . 
	cp 0aah		;00cd	fe aa 	. . 
	jp nz,l01c7h		;00cf	c2 c7 01 	. . . 
	ld d,01eh		;00d2	16 1e 	. . 
	ld bc,l0000h		;00d4	01 00 00 	. . . 
l00d7h:
	in a,(0cfh)		;00d7	db cf 	. . 
	bit 6,a		;00d9	cb 77 	. w 
	jr nz,l00e3h		;00db	20 06 	  . 
	call sub_02d5h		;00dd	cd d5 02 	. . . 
	dec d			;00e0	15 	. 
	jr nz,l00d7h		;00e1	20 f4 	  . 
l00e3h:
	ld a,0aah		;00e3	3e aa 	> . 
	out (0cah),a		;00e5	d3 ca 	. . 
	in a,(0cah)		;00e7	db ca 	. . 
	cp 0aah		;00e9	fe aa 	. . 
	jp nz,l0182h		;00eb	c2 82 01 	. . . 
	ld bc,l0438h		;00ee	01 38 04 	. 8 . 
l00f1h:
	ld a,c			;00f1	79 	y 
	out (0ceh),a		;00f2	d3 ce 	. . 
	in a,(0cfh)		;00f4	db cf 	. . 
	bit 6,a		;00f6	cb 77 	. w 
	jr z,l010fh		;00f8	28 15 	( . 
	ld a,01fh		;00fa	3e 1f 	> . 
	out (0cfh),a		;00fc	d3 cf 	. . 
	call sub_0304h		;00fe	cd 04 03 	. . . 
	xor a			;0101	af 	. 
	out (0cdh),a		;0102	d3 cd 	. . 
	ld a,005h		;0104	3e 05 	> . 
	out (0cch),a		;0106	d3 cc 	. . 
	ld a,073h		;0108	3e 73 	> s 
	out (0cfh),a		;010a	d3 cf 	. . 
	call sub_0304h		;010c	cd 04 03 	. . . 
l010fh:
	ld a,c			;010f	79 	y 
	sub 008h		;0110	d6 08 	. . 
	ld c,a			;0112	4f 	O 
	djnz l00f1h		;0113	10 dc 	. . 
	call sub_02f5h		;0115	cd f5 02 	. . . 
	jp z,l01c7h		;0118	ca c7 01 	. . . 
	ld a,01fh		;011b	3e 1f 	> . 
	out (0cfh),a		;011d	d3 cf 	. . 
	ld d,01eh		;011f	16 1e 	. . 
l0121h:
	call sub_0304h		;0121	cd 04 03 	. . . 
	jr z,l0137h		;0124	28 11 	( . 
	call sub_02f5h		;0126	cd f5 02 	. . . 
	jp z,l01c7h		;0129	ca c7 01 	. . . 
	call sub_02d5h		;012c	cd d5 02 	. . . 
	dec d			;012f	15 	. 
	jr nz,l0121h		;0130	20 ef 	  . 
	ld a,001h		;0132	3e 01 	> . 
	or a			;0134	b7 	. 
	jr l01a0h		;0135	18 69 	. i 
l0137h:
	xor a			;0137	af 	. 
	out (0cch),a		;0138	d3 cc 	. . 
	out (0cdh),a		;013a	d3 cd 	. . 
	ld hl,l0000h		;013c	21 00 00 	! . . 
	ld bc,l01cbh		;013f	01 cb 01 	. . . 
l0142h:
	ld d,h			;0142	54 	T 
	ld e,l			;0143	5d 	] 
	out (c),b		;0144	ed 41 	. A 
	ld a,020h		;0146	3e 20 	>   
	out (0cfh),a		;0148	d3 cf 	. . 
	call sub_0304h		;014a	cd 04 03 	. . . 
	jr nz,l0186h		;014d	20 37 	  7 
l014fh:
	in a,(0cfh)		;014f	db cf 	. . 
	bit 3,a		;0151	cb 5f 	. _ 
	jr z,l014fh		;0153	28 fa 	( . 
	call sub_02f5h		;0155	cd f5 02 	. . . 
	jr z,l01c7h		;0158	28 6d 	( m 
	inc b			;015a	04 	. 
	push bc			;015b	c5 	. 
	ld a,002h		;015c	3e 02 	> . 
	ld bc,000c8h		;015e	01 c8 00 	. . . 
	inir		;0161	ed b2 	. . 
	inir		;0163	ed b2 	. . 
	push hl			;0165	e5 	. 
	ld hl,l035ah		;0166	21 5a 03 	! Z . 
	ld b,00eh		;0169	06 0e 	. . 
	call sub_02edh		;016b	cd ed 02 	. . . 
	pop hl			;016e	e1 	. 
	pop bc			;016f	c1 	. 
	jr nz,l0142h		;0170	20 d0 	  . 
	ld bc,l0000h		;0172	01 00 00 	. . . 
	call sub_02d5h		;0175	cd d5 02 	. . . 
	call sub_02f5h		;0178	cd f5 02 	. . . 
	jr z,l01c7h		;017b	28 4a 	( J 
	xor a			;017d	af 	. 
	out (0c1h),a		;017e	d3 c1 	. . 
	ex de,hl			;0180	eb 	. 
	jp (hl)			;0181	e9 	. 
l0182h:
	ld e,054h		;0182	1e 54 	. T 
	jr l01ach		;0184	18 26 	. & 
l0186h:
	bit 6,a		;0186	cb 77 	. w 
	ld e,043h		;0188	1e 43 	. C 
	jr nz,l01ach		;018a	20 20 	    
	bit 5,a		;018c	cb 6f 	. o 
	ld e,049h		;018e	1e 49 	. I 
	jr nz,l01ach		;0190	20 1a 	  . 
	bit 4,a		;0192	cb 67 	. g 
	ld e,04eh		;0194	1e 4e 	. N 
	jr nz,l01ach		;0196	20 14 	  . 
	bit 2,a		;0198	cb 57 	. W 
	ld e,041h		;019a	1e 41 	. A 
	jr nz,l01ach		;019c	20 0e 	  . 
	bit 1,a		;019e	cb 4f 	. O 
l01a0h:
	ld e,030h		;01a0	1e 30 	. 0 
	jr nz,l01ach		;01a2	20 08 	  . 
	bit 0,a		;01a4	cb 47 	. G 
	ld e,04dh		;01a6	1e 4d 	. M 
	jr nz,l01ach		;01a8	20 02 	  . 
	ld e,044h		;01aa	1e 44 	. D 
l01ach:
	ld d,048h		;01ac	16 48 	. H 
	ld hl,0fb9ah		;01ae	21 9a fb 	! . . 
	ld (hl),d			;01b1	72 	r 
	inc hl			;01b2	23 	# 
	ld (hl),e			;01b3	73 	s 
	inc hl			;01b4	23 	# 
	ld (hl),020h		;01b5	36 20 	6   
	ld hl,l0368h		;01b7	21 68 03 	! h . 
	ld de,0fb8eh		;01ba	11 8e fb 	. . . 
	ld bc,l000ch		;01bd	01 0c 00 	. . . 
	ldir		;01c0	ed b0 	. . 
l01c2h:
	call sub_02f5h		;01c2	cd f5 02 	. . . 
	jr nz,l01c2h		;01c5	20 fb 	  . 
l01c7h:
	ld sp,02000h		;01c7	31 00 20 	1 .   
	xor a			;01ca	af 	. 
l01cbh:
	out (0c1h),a		;01cb	d3 c1 	. . 
	ld a,04eh		;01cd	3e 4e 	> N 
	out (0efh),a		;01cf	d3 ef 	. . 
	ld hl,00374h		;01d1	21 74 03 	! t . 
	ld de,0fb8eh		;01d4	11 8e fb 	. . . 
	ld bc,00011h		;01d7	01 11 00 	. . . 
	ldir		;01da	ed b0 	. . 
l01dch:
	call sub_02dbh		;01dc	cd db 02 	. . . 
	bit 7,a		;01df	cb 7f 	.  
	jr nz,l01dch		;01e1	20 f9 	  . 
	ld bc,l07ffh		;01e3	01 ff 07 	. . . 
	ld de,0fffeh		;01e6	11 fe ff 	. . . 
	ld hl,0ffffh		;01e9	21 ff ff 	! . . 
	ld (hl),020h		;01ec	36 20 	6   
	lddr		;01ee	ed b8 	. . 
	call sub_02dbh		;01f0	cd db 02 	. . . 
	ld a,00bh		;01f3	3e 0b 	> . 
	out (0e4h),a		;01f5	d3 e4 	. . 
	ld d,007h		;01f7	16 07 	. . 
l01f9h:
	call sub_02d5h		;01f9	cd d5 02 	. . . 
	in a,(0e4h)		;01fc	db e4 	. . 
	bit 0,a		;01fe	cb 47 	. G 
	jr z,l0205h		;0200	28 03 	( . 
	dec d			;0202	15 	. 
	jr nz,l01f9h		;0203	20 f4 	  . 
l0205h:
	in a,(0e4h)		;0205	db e4 	. . 
	push af			;0207	f5 	. 
	xor 004h		;0208	ee 04 	. . 
	and 015h		;020a	e6 15 	. . 
	jr nz,l0282h		;020c	20 74 	  t 
	pop af			;020e	f1 	. 
	bit 7,a		;020f	cb 7f 	.  
	jr nz,l0287h		;0211	20 74 	  t 
	bit 3,a		;0213	cb 5f 	. _ 
	jr nz,l028ch		;0215	20 75 	  u 
	ld hl,00e00h		;0217	21 00 0e 	! . . 
	ld de,01a28h		;021a	11 28 1a 	. ( . 
	ld bc,08001h		;021d	01 01 80 	. . . 
	ld a,080h		;0220	3e 80 	> . 
	ex af,af'			;0222	08 	. 
l0223h:
	push hl			;0223	e5 	. 
	push de			;0224	d5 	. 
	push bc			;0225	c5 	. 
	call sub_02dbh		;0226	cd db 02 	. . . 
	ld a,c			;0229	79 	y 
	out (0e6h),a		;022a	d3 e6 	. . 
	ex af,af'			;022c	08 	. 
	out (0e4h),a		;022d	d3 e4 	. . 
	ex af,af'			;022f	08 	. 
	call sub_02d2h		;0230	cd d2 02 	. . . 
	pop bc			;0233	c1 	. 
	push bc			;0234	c5 	. 
	ld c,0e7h		;0235	0e e7 	. . 
l0237h:
	in a,(0e4h)		;0237	db e4 	. . 
	bit 1,a		;0239	cb 4f 	. O 
	jr z,l0241h		;023b	28 04 	( . 
	ini		;023d	ed a2 	. . 
	jr z,l0245h		;023f	28 04 	( . 
l0241h:
	bit 0,a		;0241	cb 47 	. G 
	jr nz,l0237h		;0243	20 f2 	  . 
l0245h:
	pop bc			;0245	c1 	. 
	pop de			;0246	d1 	. 
	in a,(0e4h)		;0247	db e4 	. . 
	and 01ch		;0249	e6 1c 	. . 
	jr z,l025bh		;024b	28 0e 	( . 
	pop hl			;024d	e1 	. 
	dec e			;024e	1d 	. 
	jr nz,l0223h		;024f	20 d2 	  . 
	bit 4,a		;0251	cb 67 	. g 
	jr nz,l029bh		;0253	20 46 	  F 
	bit 3,a		;0255	cb 5f 	. _ 
	jr nz,l028ch		;0257	20 33 	  3 
	jr l02a0h		;0259	18 45 	. E 
l025bh:
	pop af			;025b	f1 	. 
	inc c			;025c	0c 	. 
	ld e,028h		;025d	1e 28 	. ( 
	dec d			;025f	15 	. 
	jr nz,l0223h		;0260	20 c1 	  . 
	ld hl,l0368h+1		;0262	21 69 03 	! i . 
	ld de,01000h		;0265	11 00 10 	. . . 
	ld b,004h		;0268	06 04 	. . 
	call sub_02edh		;026a	cd ed 02 	. . . 
	jr nz,l02a5h		;026d	20 36 	  6 
	ld hl,00385h		;026f	21 85 03 	! . . 
	ld de,01400h		;0272	11 00 14 	. . . 
	ld b,004h		;0275	06 04 	. . 
	call sub_02edh		;0277	cd ed 02 	. . . 
	jr nz,l02a5h		;027a	20 29 	  ) 
	call 01404h		;027c	cd 04 14 	. . . 
	jp 01004h		;027f	c3 04 10 	. . . 
l0282h:
	ld de,04443h		;0282	11 43 44 	. C D 
	jr l02a8h		;0285	18 21 	. ! 
l0287h:
	ld de,04430h		;0287	11 30 44 	. 0 D 
	jr l02a8h		;028a	18 1c 	. . 
l028ch:
	ld de,05343h		;028c	11 43 53 	. C S 
	jr l02a8h		;028f	18 17 	. . 
l0291h:
	ld de,05a38h		;0291	11 38 5a 	. 8 Z 
	jr l02ach		;0294	18 16 	. . 
l0296h:
	ld de,04d46h		;0296	11 46 4d 	. F M 
	jr l02ach		;0299	18 11 	. . 
l029bh:
	ld de,0544bh		;029b	11 4b 54 	. K T 
	jr l02a8h		;029e	18 08 	. . 
l02a0h:
	ld de,04c44h		;02a0	11 44 4c 	. D L 
	jr l02a8h		;02a3	18 03 	. . 
l02a5h:
	ld de,05253h		;02a5	11 53 52 	. S R 
l02a8h:
	ld a,04fh		;02a8	3e 4f 	> O 
	out (0efh),a		;02aa	d3 ef 	. . 
l02ach:
	ld hl,0fb9ah		;02ac	21 9a fb 	! . . 
	ld (hl),d			;02af	72 	r 
	inc hl			;02b0	23 	# 
	ld (hl),e			;02b1	73 	s 
	inc hl			;02b2	23 	# 
	ld (hl),020h		;02b3	36 20 	6   
	ld hl,l0368h		;02b5	21 68 03 	! h . 
	ld de,0fb8eh		;02b8	11 8e fb 	. . . 
	ld bc,l000ch		;02bb	01 0c 00 	. . . 
	ldir		;02be	ed b0 	. . 
	in a,(0ffh)		;02c0	db ff 	. . 
	bit 7,a		;02c2	cb 7f 	.  
	jr z,l02d0h		;02c4	28 0a 	( . 
	cp 01bh		;02c6	fe 1b 	. . 
	jp z,01004h		;02c8	ca 04 10 	. . . 
	cp 003h		;02cb	fe 03 	. . 
	jp z,01004h		;02cd	ca 04 10 	. . . 
l02d0h:
	halt			;02d0	76 	v 
	rst 0			;02d1	c7 	. 
sub_02d2h:
	ld bc,00005h		;02d2	01 05 00 	. . . 
sub_02d5h:
	dec bc			;02d5	0b 	. 
	ld a,b			;02d6	78 	x 
	or c			;02d7	b1 	. 
	jr nz,sub_02d5h		;02d8	20 fb 	  . 
	ret			;02da	c9 	. 
sub_02dbh:
	push bc			;02db	c5 	. 
	ld a,0d8h		;02dc	3e d8 	> . 
	out (0e4h),a		;02de	d3 e4 	. . 
	ld a,0d0h		;02e0	3e d0 	> . 
	out (0e4h),a		;02e2	d3 e4 	. . 
	call sub_0333h		;02e4	cd 33 03 	. 3 . 
	in a,(0e7h)		;02e7	db e7 	. . 
	in a,(0e4h)		;02e9	db e4 	. . 
	pop bc			;02eb	c1 	. 
	ret			;02ec	c9 	. 
sub_02edh:
	ld a,(de)			;02ed	1a 	. 
	cp (hl)			;02ee	be 	. 
	ret nz			;02ef	c0 	. 
	inc hl			;02f0	23 	# 
	inc de			;02f1	13 	. 
	djnz sub_02edh		;02f2	10 f9 	. . 
	ret			;02f4	c9 	. 
sub_02f5h:
	in a,(0ffh)		;02f5	db ff 	. . 
	xor 080h		;02f7	ee 80 	. . 
	bit 7,a		;02f9	cb 7f 	.  
	ret nz			;02fb	c0 	. 
	in a,(0fch)		;02fc	db fc 	. . 
	cp 01bh		;02fe	fe 1b 	. . 
	ret z			;0300	c8 	. 
	cp 003h		;0301	fe 03 	. . 
	ret			;0303	c9 	. 
sub_0304h:
	push bc			;0304	c5 	. 
	ld bc,07fffh		;0305	01 ff 7f 	. .  
l0308h:
	in a,(0cfh)		;0308	db cf 	. . 
	bit 7,a		;030a	cb 7f 	.  
	jr nz,l0312h		;030c	20 04 	  . 
	bit 4,a		;030e	cb 67 	. g 
	jr nz,l031fh		;0310	20 0d 	  . 
l0312h:
	ex (sp),ix		;0312	dd e3 	. . 
	ex (sp),ix		;0314	dd e3 	. . 
	dec bc			;0316	0b 	. 
	ld a,b			;0317	78 	x 
	or c			;0318	b1 	. 
	jr nz,l0308h		;0319	20 ed 	  . 
	or 008h		;031b	f6 08 	. . 
	pop bc			;031d	c1 	. 
	ret			;031e	c9 	. 
l031fh:
	pop bc			;031f	c1 	. 
	bit 0,a		;0320	cb 47 	. G 
	ret z			;0322	c8 	. 
	bit 1,a		;0323	cb 4f 	. O 
	jr z,l032fh		;0325	28 08 	( . 
	ld a,010h		;0327	3e 10 	> . 
	out (0c1h),a		;0329	d3 c1 	. . 
	ld a,00eh		;032b	3e 0e 	> . 
	out (0c1h),a		;032d	d3 c1 	. . 
l032fh:
	in a,(0c9h)		;032f	db c9 	. . 
	or a			;0331	b7 	. 
	ret			;0332	c9 	. 
sub_0333h:
	push af			;0333	f5 	. 
	in a,(0e4h)		;0334	db e4 	. . 
	push bc			;0336	c5 	. 
	ld bc,00005h		;0337	01 05 00 	. . . 
l033ah:
	rra			;033a	1f 	. 
	jr c,l0344h		;033b	38 07 	8 . 
	dec bc			;033d	0b 	. 
	ld a,b			;033e	78 	x 
	or c			;033f	b1 	. 
	in a,(0e4h)		;0340	db e4 	. . 
	jr nz,l033ah		;0342	20 f6 	  . 
l0344h:
	ld bc,l0000h		;0344	01 00 00 	. . . 
l0347h:
	dec bc			;0347	0b 	. 
	ld a,b			;0348	78 	x 
	or c			;0349	b1 	. 
	jr z,l0354h		;034a	28 08 	( . 
	in a,(0e4h)		;034c	db e4 	. . 
	rra			;034e	1f 	. 
	jr c,l0347h		;034f	38 f6 	8 . 
	pop bc			;0351	c1 	. 
	pop af			;0352	f1 	. 
	ret			;0353	c9 	. 
l0354h:
	pop af			;0354	f1 	. 
	pop af			;0355	f1 	. 
	pop af			;0356	f1 	. 
	jp l0282h		;0357	c3 82 02 	. . . 
l035ah:
	cpl			;035a	2f 	/ 
	ld hl,(04520h)		;035b	2a 20 45 	*   E 
	ld c,(hl)			;035e	4e 	N 
	ld b,h			;035f	44 	D 
	jr nz,l03a4h		;0360	20 42 	  B 
	ld c,a			;0362	4f 	O 
	ld c,a			;0363	4f 	O 
	ld d,h			;0364	54 	T 
	jr nz,l0391h		;0365	20 2a 	  * 
	cpl			;0367	2f 	/ 
l0368h:
	jr nz,l03ach		;0368	20 42 	  B 
	ld c,a			;036a	4f 	O 
	ld c,a			;036b	4f 	O 
	ld d,h			;036c	54 	T 
	jr nz,l03b4h		;036d	20 45 	  E 
	ld d,d			;036f	52 	R 
	ld d,d			;0370	52 	R 
	ld c,a			;0371	4f 	O 
	ld d,d			;0372	52 	R 
	jr nz,l0395h		;0373	20 20 	    
	ld c,c			;0375	49 	I 
	ld c,(hl)			;0376	4e 	N 
	ld d,e			;0377	53 	S 
	ld b,l			;0378	45 	E 
	ld d,d			;0379	52 	R 
	ld d,h			;037a	54 	T 
	jr nz,l03c1h		;037b	20 44 	  D 
	ld c,c			;037d	49 	I 
	ld d,e			;037e	53 	S 
	ld c,e			;037f	4b 	K 
	ld b,l			;0380	45 	E 
	ld d,h			;0381	54 	T 
	ld d,h			;0382	54 	T 
	ld b,l			;0383	45 	E 
	jr nz,l03cah		;0384	20 44 	  D 
	ld c,c			;0386	49 	I 
	ld b,c			;0387	41 	A 
	ld b,a			;0388	47 	G 
	ld h,e			;0389	63 	c 
	ld d,b			;038a	50 	P 
	ld d,l			;038b	55 	U 
	ex af,af'			;038c	08 	. 
	add hl,de			;038d	19 	. 
	nop			;038e	00 	. 
	jr l03a9h		;038f	18 18 	. . 
l0391h:
	nop			;0391	00 	. 
	add hl,bc			;0392	09 	. 
	ld h,l			;0393	65 	e 
	add hl,bc			;0394	09 	. 
l0395h:
	nop			;0395	00 	. 
	nop			;0396	00 	. 
	inc bc			;0397	03 	. 
l0398h:
	jp (hl)			;0398	e9 	. 
	dec b			;0399	05 	. 
	add a,e			;039a	83 	. 
	rlca			;039b	07 	. 
	add hl,hl			;039c	29 	) 
	dec d			;039d	15 	. 
	nop			;039e	00 	. 
	nop			;039f	00 	. 
	nop			;03a0	00 	. 
	nop			;03a1	00 	. 
	nop			;03a2	00 	. 
	nop			;03a3	00 	. 
l03a4h:
	nop			;03a4	00 	. 
	nop			;03a5	00 	. 
	nop			;03a6	00 	. 
	nop			;03a7	00 	. 
	nop			;03a8	00 	. 
l03a9h:
	nop			;03a9	00 	. 
	nop			;03aa	00 	. 
	nop			;03ab	00 	. 
l03ach:
	nop			;03ac	00 	. 
	nop			;03ad	00 	. 
	nop			;03ae	00 	. 
	nop			;03af	00 	. 
	nop			;03b0	00 	. 
	nop			;03b1	00 	. 
	nop			;03b2	00 	. 
	nop			;03b3	00 	. 
l03b4h:
	nop			;03b4	00 	. 
	nop			;03b5	00 	. 
	nop			;03b6	00 	. 
	nop			;03b7	00 	. 
	nop			;03b8	00 	. 
	nop			;03b9	00 	. 
	nop			;03ba	00 	. 
	nop			;03bb	00 	. 
	nop			;03bc	00 	. 
	nop			;03bd	00 	. 
	nop			;03be	00 	. 
	nop			;03bf	00 	. 
	nop			;03c0	00 	. 
l03c1h:
	nop			;03c1	00 	. 
	nop			;03c2	00 	. 
	nop			;03c3	00 	. 
	nop			;03c4	00 	. 
	nop			;03c5	00 	. 
	nop			;03c6	00 	. 
	nop			;03c7	00 	. 
	nop			;03c8	00 	. 
	nop			;03c9	00 	. 
l03cah:
	nop			;03ca	00 	. 
	nop			;03cb	00 	. 
	nop			;03cc	00 	. 
	nop			;03cd	00 	. 
	nop			;03ce	00 	. 
	nop			;03cf	00 	. 
	nop			;03d0	00 	. 
	nop			;03d1	00 	. 
	nop			;03d2	00 	. 
	nop			;03d3	00 	. 
	nop			;03d4	00 	. 
	nop			;03d5	00 	. 
	nop			;03d6	00 	. 
	nop			;03d7	00 	. 
	nop			;03d8	00 	. 
	nop			;03d9	00 	. 
	nop			;03da	00 	. 
	nop			;03db	00 	. 
	nop			;03dc	00 	. 
	nop			;03dd	00 	. 
	nop			;03de	00 	. 
	nop			;03df	00 	. 
	nop			;03e0	00 	. 
	nop			;03e1	00 	. 
	nop			;03e2	00 	. 
	nop			;03e3	00 	. 
	nop			;03e4	00 	. 
	nop			;03e5	00 	. 
	nop			;03e6	00 	. 
	nop			;03e7	00 	. 
	nop			;03e8	00 	. 
	nop			;03e9	00 	. 
	nop			;03ea	00 	. 
	nop			;03eb	00 	. 
	nop			;03ec	00 	. 
	nop			;03ed	00 	. 
	nop			;03ee	00 	. 
	nop			;03ef	00 	. 
	nop			;03f0	00 	. 
	nop			;03f1	00 	. 
	nop			;03f2	00 	. 
	nop			;03f3	00 	. 
	nop			;03f4	00 	. 
	nop			;03f5	00 	. 
	nop			;03f6	00 	. 
	nop			;03f7	00 	. 
	nop			;03f8	00 	. 
	nop			;03f9	00 	. 
	nop			;03fa	00 	. 
	nop			;03fb	00 	. 
	nop			;03fc	00 	. 
	nop			;03fd	00 	. 
	nop			;03fe	00 	. 
	nop			;03ff	00 	. 
	nop			;0400	00 	. 
	nop			;0401	00 	. 
	nop			;0402	00 	. 
	nop			;0403	00 	. 
	nop			;0404	00 	. 
	nop			;0405	00 	. 
	nop			;0406	00 	. 
	nop			;0407	00 	. 
	nop			;0408	00 	. 
	nop			;0409	00 	. 
	nop			;040a	00 	. 
	nop			;040b	00 	. 
	nop			;040c	00 	. 
	nop			;040d	00 	. 
	nop			;040e	00 	. 
	nop			;040f	00 	. 
	nop			;0410	00 	. 
	nop			;0411	00 	. 
	nop			;0412	00 	. 
	nop			;0413	00 	. 
	nop			;0414	00 	. 
	nop			;0415	00 	. 
	nop			;0416	00 	. 
	nop			;0417	00 	. 
	nop			;0418	00 	. 
	nop			;0419	00 	. 
	nop			;041a	00 	. 
	nop			;041b	00 	. 
	nop			;041c	00 	. 
	nop			;041d	00 	. 
	nop			;041e	00 	. 
	nop			;041f	00 	. 
	nop			;0420	00 	. 
	nop			;0421	00 	. 
	nop			;0422	00 	. 
	nop			;0423	00 	. 
	nop			;0424	00 	. 
	nop			;0425	00 	. 
	nop			;0426	00 	. 
	nop			;0427	00 	. 
	nop			;0428	00 	. 
	nop			;0429	00 	. 
	nop			;042a	00 	. 
	nop			;042b	00 	. 
	nop			;042c	00 	. 
	nop			;042d	00 	. 
	nop			;042e	00 	. 
	nop			;042f	00 	. 
	nop			;0430	00 	. 
	nop			;0431	00 	. 
	nop			;0432	00 	. 
	nop			;0433	00 	. 
	nop			;0434	00 	. 
	nop			;0435	00 	. 
	nop			;0436	00 	. 
	nop			;0437	00 	. 
l0438h:
	nop			;0438	00 	. 
	nop			;0439	00 	. 
	nop			;043a	00 	. 
	nop			;043b	00 	. 
	nop			;043c	00 	. 
	nop			;043d	00 	. 
	nop			;043e	00 	. 
	nop			;043f	00 	. 
	nop			;0440	00 	. 
	nop			;0441	00 	. 
	nop			;0442	00 	. 
	nop			;0443	00 	. 
	nop			;0444	00 	. 
	nop			;0445	00 	. 
	nop			;0446	00 	. 
	nop			;0447	00 	. 
	nop			;0448	00 	. 
	nop			;0449	00 	. 
	nop			;044a	00 	. 
	nop			;044b	00 	. 
	nop			;044c	00 	. 
	nop			;044d	00 	. 
	nop			;044e	00 	. 
	nop			;044f	00 	. 
	nop			;0450	00 	. 
	nop			;0451	00 	. 
	nop			;0452	00 	. 
	nop			;0453	00 	. 
	nop			;0454	00 	. 
	nop			;0455	00 	. 
	nop			;0456	00 	. 
	nop			;0457	00 	. 
	nop			;0458	00 	. 
	nop			;0459	00 	. 
	nop			;045a	00 	. 
	nop			;045b	00 	. 
	nop			;045c	00 	. 
	nop			;045d	00 	. 
	nop			;045e	00 	. 
	nop			;045f	00 	. 
	nop			;0460	00 	. 
	nop			;0461	00 	. 
	nop			;0462	00 	. 
	nop			;0463	00 	. 
	nop			;0464	00 	. 
	nop			;0465	00 	. 
	nop			;0466	00 	. 
	nop			;0467	00 	. 
	nop			;0468	00 	. 
	nop			;0469	00 	. 
	nop			;046a	00 	. 
	nop			;046b	00 	. 
	nop			;046c	00 	. 
	nop			;046d	00 	. 
	nop			;046e	00 	. 
	nop			;046f	00 	. 
	nop			;0470	00 	. 
	nop			;0471	00 	. 
	nop			;0472	00 	. 
	nop			;0473	00 	. 
	nop			;0474	00 	. 
	nop			;0475	00 	. 
	nop			;0476	00 	. 
	nop			;0477	00 	. 
	nop			;0478	00 	. 
	nop			;0479	00 	. 
	nop			;047a	00 	. 
	nop			;047b	00 	. 
	nop			;047c	00 	. 
	nop			;047d	00 	. 
	nop			;047e	00 	. 
	nop			;047f	00 	. 
	nop			;0480	00 	. 
	nop			;0481	00 	. 
	nop			;0482	00 	. 
	nop			;0483	00 	. 
	nop			;0484	00 	. 
	nop			;0485	00 	. 
	nop			;0486	00 	. 
	nop			;0487	00 	. 
	nop			;0488	00 	. 
	nop			;0489	00 	. 
	nop			;048a	00 	. 
	nop			;048b	00 	. 
	nop			;048c	00 	. 
	nop			;048d	00 	. 
	nop			;048e	00 	. 
	nop			;048f	00 	. 
	nop			;0490	00 	. 
	nop			;0491	00 	. 
	nop			;0492	00 	. 
	nop			;0493	00 	. 
	nop			;0494	00 	. 
	nop			;0495	00 	. 
	nop			;0496	00 	. 
	nop			;0497	00 	. 
	nop			;0498	00 	. 
	nop			;0499	00 	. 
	nop			;049a	00 	. 
	nop			;049b	00 	. 
	nop			;049c	00 	. 
	nop			;049d	00 	. 
	nop			;049e	00 	. 
	nop			;049f	00 	. 
	nop			;04a0	00 	. 
	nop			;04a1	00 	. 
	nop			;04a2	00 	. 
	nop			;04a3	00 	. 
	nop			;04a4	00 	. 
	nop			;04a5	00 	. 
	nop			;04a6	00 	. 
	nop			;04a7	00 	. 
	nop			;04a8	00 	. 
	nop			;04a9	00 	. 
	nop			;04aa	00 	. 
	nop			;04ab	00 	. 
	nop			;04ac	00 	. 
	nop			;04ad	00 	. 
	nop			;04ae	00 	. 
	nop			;04af	00 	. 
	nop			;04b0	00 	. 
	nop			;04b1	00 	. 
	nop			;04b2	00 	. 
	nop			;04b3	00 	. 
	nop			;04b4	00 	. 
	nop			;04b5	00 	. 
	nop			;04b6	00 	. 
	nop			;04b7	00 	. 
	nop			;04b8	00 	. 
	nop			;04b9	00 	. 
	nop			;04ba	00 	. 
	nop			;04bb	00 	. 
	nop			;04bc	00 	. 
	nop			;04bd	00 	. 
	nop			;04be	00 	. 
	nop			;04bf	00 	. 
	nop			;04c0	00 	. 
	nop			;04c1	00 	. 
	nop			;04c2	00 	. 
	nop			;04c3	00 	. 
	nop			;04c4	00 	. 
	nop			;04c5	00 	. 
	nop			;04c6	00 	. 
	nop			;04c7	00 	. 
	nop			;04c8	00 	. 
	nop			;04c9	00 	. 
	nop			;04ca	00 	. 
	nop			;04cb	00 	. 
	nop			;04cc	00 	. 
	nop			;04cd	00 	. 
	nop			;04ce	00 	. 
	nop			;04cf	00 	. 
	nop			;04d0	00 	. 
	nop			;04d1	00 	. 
	nop			;04d2	00 	. 
	nop			;04d3	00 	. 
	nop			;04d4	00 	. 
	nop			;04d5	00 	. 
	nop			;04d6	00 	. 
	nop			;04d7	00 	. 
	nop			;04d8	00 	. 
	nop			;04d9	00 	. 
	nop			;04da	00 	. 
	nop			;04db	00 	. 
	nop			;04dc	00 	. 
	nop			;04dd	00 	. 
	nop			;04de	00 	. 
	nop			;04df	00 	. 
	nop			;04e0	00 	. 
	nop			;04e1	00 	. 
	nop			;04e2	00 	. 
	nop			;04e3	00 	. 
	nop			;04e4	00 	. 
	nop			;04e5	00 	. 
	nop			;04e6	00 	. 
	nop			;04e7	00 	. 
	nop			;04e8	00 	. 
	nop			;04e9	00 	. 
	nop			;04ea	00 	. 
	nop			;04eb	00 	. 
	nop			;04ec	00 	. 
	nop			;04ed	00 	. 
	nop			;04ee	00 	. 
	nop			;04ef	00 	. 
	nop			;04f0	00 	. 
	nop			;04f1	00 	. 
	nop			;04f2	00 	. 
	nop			;04f3	00 	. 
	nop			;04f4	00 	. 
	nop			;04f5	00 	. 
	nop			;04f6	00 	. 
	nop			;04f7	00 	. 
	nop			;04f8	00 	. 
	nop			;04f9	00 	. 
	nop			;04fa	00 	. 
	nop			;04fb	00 	. 
	nop			;04fc	00 	. 
	nop			;04fd	00 	. 
	nop			;04fe	00 	. 
	nop			;04ff	00 	. 
	nop			;0500	00 	. 
	nop			;0501	00 	. 
	nop			;0502	00 	. 
	nop			;0503	00 	. 
	nop			;0504	00 	. 
	nop			;0505	00 	. 
	nop			;0506	00 	. 
	nop			;0507	00 	. 
	nop			;0508	00 	. 
	nop			;0509	00 	. 
	nop			;050a	00 	. 
	nop			;050b	00 	. 
	nop			;050c	00 	. 
	nop			;050d	00 	. 
	nop			;050e	00 	. 
	nop			;050f	00 	. 
	nop			;0510	00 	. 
	nop			;0511	00 	. 
	nop			;0512	00 	. 
	nop			;0513	00 	. 
	nop			;0514	00 	. 
	nop			;0515	00 	. 
	nop			;0516	00 	. 
	nop			;0517	00 	. 
	nop			;0518	00 	. 
	nop			;0519	00 	. 
	nop			;051a	00 	. 
	nop			;051b	00 	. 
	nop			;051c	00 	. 
	nop			;051d	00 	. 
	nop			;051e	00 	. 
	nop			;051f	00 	. 
	nop			;0520	00 	. 
	nop			;0521	00 	. 
	nop			;0522	00 	. 
	nop			;0523	00 	. 
	nop			;0524	00 	. 
	nop			;0525	00 	. 
	nop			;0526	00 	. 
	nop			;0527	00 	. 
	nop			;0528	00 	. 
	nop			;0529	00 	. 
	nop			;052a	00 	. 
	nop			;052b	00 	. 
	nop			;052c	00 	. 
	nop			;052d	00 	. 
	nop			;052e	00 	. 
	nop			;052f	00 	. 
	nop			;0530	00 	. 
	nop			;0531	00 	. 
	nop			;0532	00 	. 
	nop			;0533	00 	. 
	nop			;0534	00 	. 
	nop			;0535	00 	. 
	nop			;0536	00 	. 
	nop			;0537	00 	. 
	nop			;0538	00 	. 
	nop			;0539	00 	. 
	nop			;053a	00 	. 
	nop			;053b	00 	. 
	nop			;053c	00 	. 
	nop			;053d	00 	. 
	nop			;053e	00 	. 
	nop			;053f	00 	. 
	nop			;0540	00 	. 
	nop			;0541	00 	. 
	nop			;0542	00 	. 
	nop			;0543	00 	. 
	nop			;0544	00 	. 
	nop			;0545	00 	. 
	nop			;0546	00 	. 
	nop			;0547	00 	. 
	nop			;0548	00 	. 
	nop			;0549	00 	. 
	nop			;054a	00 	. 
	nop			;054b	00 	. 
	nop			;054c	00 	. 
	nop			;054d	00 	. 
	nop			;054e	00 	. 
	nop			;054f	00 	. 
	nop			;0550	00 	. 
	nop			;0551	00 	. 
	nop			;0552	00 	. 
	nop			;0553	00 	. 
	nop			;0554	00 	. 
	nop			;0555	00 	. 
	nop			;0556	00 	. 
	nop			;0557	00 	. 
	nop			;0558	00 	. 
	nop			;0559	00 	. 
	nop			;055a	00 	. 
	nop			;055b	00 	. 
	nop			;055c	00 	. 
	nop			;055d	00 	. 
	nop			;055e	00 	. 
	nop			;055f	00 	. 
	nop			;0560	00 	. 
	nop			;0561	00 	. 
	nop			;0562	00 	. 
	nop			;0563	00 	. 
	nop			;0564	00 	. 
	nop			;0565	00 	. 
	nop			;0566	00 	. 
	nop			;0567	00 	. 
	nop			;0568	00 	. 
	nop			;0569	00 	. 
	nop			;056a	00 	. 
	nop			;056b	00 	. 
	nop			;056c	00 	. 
	nop			;056d	00 	. 
	nop			;056e	00 	. 
	nop			;056f	00 	. 
	nop			;0570	00 	. 
	nop			;0571	00 	. 
	nop			;0572	00 	. 
	nop			;0573	00 	. 
	nop			;0574	00 	. 
	nop			;0575	00 	. 
	nop			;0576	00 	. 
	nop			;0577	00 	. 
	nop			;0578	00 	. 
	nop			;0579	00 	. 
	nop			;057a	00 	. 
	nop			;057b	00 	. 
	nop			;057c	00 	. 
	nop			;057d	00 	. 
	nop			;057e	00 	. 
	nop			;057f	00 	. 
	nop			;0580	00 	. 
	nop			;0581	00 	. 
	nop			;0582	00 	. 
	nop			;0583	00 	. 
	nop			;0584	00 	. 
	nop			;0585	00 	. 
	nop			;0586	00 	. 
	nop			;0587	00 	. 
	nop			;0588	00 	. 
	nop			;0589	00 	. 
	nop			;058a	00 	. 
	nop			;058b	00 	. 
	nop			;058c	00 	. 
	nop			;058d	00 	. 
	nop			;058e	00 	. 
	nop			;058f	00 	. 
	nop			;0590	00 	. 
	nop			;0591	00 	. 
	nop			;0592	00 	. 
	nop			;0593	00 	. 
	nop			;0594	00 	. 
	nop			;0595	00 	. 
	nop			;0596	00 	. 
	nop			;0597	00 	. 
	nop			;0598	00 	. 
	nop			;0599	00 	. 
	nop			;059a	00 	. 
	nop			;059b	00 	. 
	nop			;059c	00 	. 
	nop			;059d	00 	. 
	nop			;059e	00 	. 
	nop			;059f	00 	. 
	nop			;05a0	00 	. 
	nop			;05a1	00 	. 
	nop			;05a2	00 	. 
	nop			;05a3	00 	. 
	nop			;05a4	00 	. 
	nop			;05a5	00 	. 
	nop			;05a6	00 	. 
	nop			;05a7	00 	. 
	nop			;05a8	00 	. 
	nop			;05a9	00 	. 
	nop			;05aa	00 	. 
	nop			;05ab	00 	. 
	nop			;05ac	00 	. 
	nop			;05ad	00 	. 
	nop			;05ae	00 	. 
	nop			;05af	00 	. 
	nop			;05b0	00 	. 
	nop			;05b1	00 	. 
	nop			;05b2	00 	. 
	nop			;05b3	00 	. 
	nop			;05b4	00 	. 
	nop			;05b5	00 	. 
	nop			;05b6	00 	. 
	nop			;05b7	00 	. 
	nop			;05b8	00 	. 
	nop			;05b9	00 	. 
	nop			;05ba	00 	. 
	nop			;05bb	00 	. 
	nop			;05bc	00 	. 
	nop			;05bd	00 	. 
	nop			;05be	00 	. 
	nop			;05bf	00 	. 
	nop			;05c0	00 	. 
	nop			;05c1	00 	. 
	nop			;05c2	00 	. 
	nop			;05c3	00 	. 
	nop			;05c4	00 	. 
	nop			;05c5	00 	. 
	nop			;05c6	00 	. 
	nop			;05c7	00 	. 
	nop			;05c8	00 	. 
	nop			;05c9	00 	. 
	nop			;05ca	00 	. 
	nop			;05cb	00 	. 
	nop			;05cc	00 	. 
	nop			;05cd	00 	. 
	nop			;05ce	00 	. 
	nop			;05cf	00 	. 
	nop			;05d0	00 	. 
	nop			;05d1	00 	. 
	nop			;05d2	00 	. 
	nop			;05d3	00 	. 
	nop			;05d4	00 	. 
	nop			;05d5	00 	. 
	nop			;05d6	00 	. 
	nop			;05d7	00 	. 
	nop			;05d8	00 	. 
	nop			;05d9	00 	. 
	nop			;05da	00 	. 
	nop			;05db	00 	. 
	nop			;05dc	00 	. 
	nop			;05dd	00 	. 
	nop			;05de	00 	. 
	nop			;05df	00 	. 
	nop			;05e0	00 	. 
	nop			;05e1	00 	. 
	nop			;05e2	00 	. 
	nop			;05e3	00 	. 
	nop			;05e4	00 	. 
	nop			;05e5	00 	. 
	nop			;05e6	00 	. 
	nop			;05e7	00 	. 
	nop			;05e8	00 	. 
	nop			;05e9	00 	. 
	nop			;05ea	00 	. 
	nop			;05eb	00 	. 
	nop			;05ec	00 	. 
	nop			;05ed	00 	. 
	nop			;05ee	00 	. 
	nop			;05ef	00 	. 
	nop			;05f0	00 	. 
	nop			;05f1	00 	. 
	nop			;05f2	00 	. 
	nop			;05f3	00 	. 
	nop			;05f4	00 	. 
	nop			;05f5	00 	. 
	nop			;05f6	00 	. 
	nop			;05f7	00 	. 
	nop			;05f8	00 	. 
	nop			;05f9	00 	. 
	nop			;05fa	00 	. 
	nop			;05fb	00 	. 
	nop			;05fc	00 	. 
	nop			;05fd	00 	. 
	nop			;05fe	00 	. 
	nop			;05ff	00 	. 
	nop			;0600	00 	. 
	nop			;0601	00 	. 
	nop			;0602	00 	. 
	nop			;0603	00 	. 
	nop			;0604	00 	. 
	nop			;0605	00 	. 
	nop			;0606	00 	. 
	nop			;0607	00 	. 
	nop			;0608	00 	. 
	nop			;0609	00 	. 
	nop			;060a	00 	. 
	nop			;060b	00 	. 
	nop			;060c	00 	. 
	nop			;060d	00 	. 
	nop			;060e	00 	. 
	nop			;060f	00 	. 
	nop			;0610	00 	. 
	nop			;0611	00 	. 
	nop			;0612	00 	. 
	nop			;0613	00 	. 
	nop			;0614	00 	. 
	nop			;0615	00 	. 
	nop			;0616	00 	. 
	nop			;0617	00 	. 
	nop			;0618	00 	. 
	nop			;0619	00 	. 
	nop			;061a	00 	. 
	nop			;061b	00 	. 
	nop			;061c	00 	. 
	nop			;061d	00 	. 
	nop			;061e	00 	. 
	nop			;061f	00 	. 
	nop			;0620	00 	. 
	nop			;0621	00 	. 
	nop			;0622	00 	. 
	nop			;0623	00 	. 
	nop			;0624	00 	. 
	nop			;0625	00 	. 
	nop			;0626	00 	. 
	nop			;0627	00 	. 
	nop			;0628	00 	. 
	nop			;0629	00 	. 
	nop			;062a	00 	. 
	nop			;062b	00 	. 
	nop			;062c	00 	. 
	nop			;062d	00 	. 
	nop			;062e	00 	. 
	nop			;062f	00 	. 
	nop			;0630	00 	. 
	nop			;0631	00 	. 
	nop			;0632	00 	. 
	nop			;0633	00 	. 
	nop			;0634	00 	. 
	nop			;0635	00 	. 
	nop			;0636	00 	. 
	nop			;0637	00 	. 
	nop			;0638	00 	. 
	nop			;0639	00 	. 
	nop			;063a	00 	. 
	nop			;063b	00 	. 
	nop			;063c	00 	. 
	nop			;063d	00 	. 
	nop			;063e	00 	. 
	nop			;063f	00 	. 
	nop			;0640	00 	. 
	nop			;0641	00 	. 
	nop			;0642	00 	. 
	nop			;0643	00 	. 
	nop			;0644	00 	. 
	nop			;0645	00 	. 
	nop			;0646	00 	. 
	nop			;0647	00 	. 
	nop			;0648	00 	. 
	nop			;0649	00 	. 
	nop			;064a	00 	. 
	nop			;064b	00 	. 
	nop			;064c	00 	. 
	nop			;064d	00 	. 
	nop			;064e	00 	. 
	nop			;064f	00 	. 
	nop			;0650	00 	. 
	nop			;0651	00 	. 
	nop			;0652	00 	. 
	nop			;0653	00 	. 
	nop			;0654	00 	. 
	nop			;0655	00 	. 
	nop			;0656	00 	. 
	nop			;0657	00 	. 
	nop			;0658	00 	. 
	nop			;0659	00 	. 
	nop			;065a	00 	. 
	nop			;065b	00 	. 
	nop			;065c	00 	. 
	nop			;065d	00 	. 
	nop			;065e	00 	. 
	nop			;065f	00 	. 
	nop			;0660	00 	. 
	nop			;0661	00 	. 
	nop			;0662	00 	. 
	nop			;0663	00 	. 
	nop			;0664	00 	. 
	nop			;0665	00 	. 
	nop			;0666	00 	. 
	nop			;0667	00 	. 
	nop			;0668	00 	. 
	nop			;0669	00 	. 
	nop			;066a	00 	. 
	nop			;066b	00 	. 
	nop			;066c	00 	. 
	nop			;066d	00 	. 
	nop			;066e	00 	. 
	nop			;066f	00 	. 
	nop			;0670	00 	. 
	nop			;0671	00 	. 
	nop			;0672	00 	. 
	nop			;0673	00 	. 
	nop			;0674	00 	. 
	nop			;0675	00 	. 
	nop			;0676	00 	. 
	nop			;0677	00 	. 
	nop			;0678	00 	. 
	nop			;0679	00 	. 
	nop			;067a	00 	. 
	nop			;067b	00 	. 
	nop			;067c	00 	. 
	nop			;067d	00 	. 
	nop			;067e	00 	. 
	nop			;067f	00 	. 
	nop			;0680	00 	. 
	nop			;0681	00 	. 
	nop			;0682	00 	. 
	nop			;0683	00 	. 
	nop			;0684	00 	. 
	nop			;0685	00 	. 
	nop			;0686	00 	. 
	nop			;0687	00 	. 
	nop			;0688	00 	. 
	nop			;0689	00 	. 
	nop			;068a	00 	. 
	nop			;068b	00 	. 
	nop			;068c	00 	. 
	nop			;068d	00 	. 
	nop			;068e	00 	. 
	nop			;068f	00 	. 
	nop			;0690	00 	. 
	nop			;0691	00 	. 
	nop			;0692	00 	. 
	nop			;0693	00 	. 
	nop			;0694	00 	. 
	nop			;0695	00 	. 
	nop			;0696	00 	. 
	nop			;0697	00 	. 
	nop			;0698	00 	. 
	nop			;0699	00 	. 
	nop			;069a	00 	. 
	nop			;069b	00 	. 
	nop			;069c	00 	. 
	nop			;069d	00 	. 
	nop			;069e	00 	. 
	nop			;069f	00 	. 
	nop			;06a0	00 	. 
	nop			;06a1	00 	. 
	nop			;06a2	00 	. 
	nop			;06a3	00 	. 
	nop			;06a4	00 	. 
	nop			;06a5	00 	. 
	nop			;06a6	00 	. 
	nop			;06a7	00 	. 
	nop			;06a8	00 	. 
	nop			;06a9	00 	. 
	nop			;06aa	00 	. 
	nop			;06ab	00 	. 
	nop			;06ac	00 	. 
	nop			;06ad	00 	. 
	nop			;06ae	00 	. 
	nop			;06af	00 	. 
	nop			;06b0	00 	. 
	nop			;06b1	00 	. 
	nop			;06b2	00 	. 
	nop			;06b3	00 	. 
	nop			;06b4	00 	. 
	nop			;06b5	00 	. 
	nop			;06b6	00 	. 
	nop			;06b7	00 	. 
	nop			;06b8	00 	. 
	nop			;06b9	00 	. 
	nop			;06ba	00 	. 
	nop			;06bb	00 	. 
	nop			;06bc	00 	. 
	nop			;06bd	00 	. 
	nop			;06be	00 	. 
	nop			;06bf	00 	. 
	nop			;06c0	00 	. 
	nop			;06c1	00 	. 
	nop			;06c2	00 	. 
	nop			;06c3	00 	. 
	nop			;06c4	00 	. 
	nop			;06c5	00 	. 
	nop			;06c6	00 	. 
	nop			;06c7	00 	. 
	nop			;06c8	00 	. 
	nop			;06c9	00 	. 
	nop			;06ca	00 	. 
	nop			;06cb	00 	. 
	nop			;06cc	00 	. 
	nop			;06cd	00 	. 
	nop			;06ce	00 	. 
	nop			;06cf	00 	. 
	nop			;06d0	00 	. 
	nop			;06d1	00 	. 
	nop			;06d2	00 	. 
	nop			;06d3	00 	. 
	nop			;06d4	00 	. 
	nop			;06d5	00 	. 
	nop			;06d6	00 	. 
	nop			;06d7	00 	. 
	nop			;06d8	00 	. 
	nop			;06d9	00 	. 
	nop			;06da	00 	. 
	nop			;06db	00 	. 
	nop			;06dc	00 	. 
	nop			;06dd	00 	. 
	nop			;06de	00 	. 
	nop			;06df	00 	. 
	nop			;06e0	00 	. 
	nop			;06e1	00 	. 
	nop			;06e2	00 	. 
	nop			;06e3	00 	. 
	nop			;06e4	00 	. 
	nop			;06e5	00 	. 
	nop			;06e6	00 	. 
	nop			;06e7	00 	. 
	nop			;06e8	00 	. 
	nop			;06e9	00 	. 
	nop			;06ea	00 	. 
	nop			;06eb	00 	. 
	nop			;06ec	00 	. 
	nop			;06ed	00 	. 
	nop			;06ee	00 	. 
	nop			;06ef	00 	. 
	nop			;06f0	00 	. 
	nop			;06f1	00 	. 
	nop			;06f2	00 	. 
	nop			;06f3	00 	. 
	nop			;06f4	00 	. 
	nop			;06f5	00 	. 
	nop			;06f6	00 	. 
	nop			;06f7	00 	. 
	nop			;06f8	00 	. 
	nop			;06f9	00 	. 
	nop			;06fa	00 	. 
	nop			;06fb	00 	. 
	nop			;06fc	00 	. 
	nop			;06fd	00 	. 
	nop			;06fe	00 	. 
	nop			;06ff	00 	. 
	nop			;0700	00 	. 
	nop			;0701	00 	. 
	nop			;0702	00 	. 
	nop			;0703	00 	. 
	nop			;0704	00 	. 
	nop			;0705	00 	. 
	nop			;0706	00 	. 
	nop			;0707	00 	. 
	nop			;0708	00 	. 
	nop			;0709	00 	. 
	nop			;070a	00 	. 
	nop			;070b	00 	. 
	nop			;070c	00 	. 
	nop			;070d	00 	. 
	nop			;070e	00 	. 
	nop			;070f	00 	. 
	nop			;0710	00 	. 
	nop			;0711	00 	. 
	nop			;0712	00 	. 
	nop			;0713	00 	. 
	nop			;0714	00 	. 
	nop			;0715	00 	. 
	nop			;0716	00 	. 
	nop			;0717	00 	. 
	nop			;0718	00 	. 
	nop			;0719	00 	. 
	nop			;071a	00 	. 
	nop			;071b	00 	. 
	nop			;071c	00 	. 
	nop			;071d	00 	. 
	nop			;071e	00 	. 
	nop			;071f	00 	. 
	nop			;0720	00 	. 
	nop			;0721	00 	. 
	nop			;0722	00 	. 
	nop			;0723	00 	. 
	nop			;0724	00 	. 
	nop			;0725	00 	. 
	nop			;0726	00 	. 
	nop			;0727	00 	. 
	nop			;0728	00 	. 
	nop			;0729	00 	. 
	nop			;072a	00 	. 
	nop			;072b	00 	. 
	nop			;072c	00 	. 
	nop			;072d	00 	. 
	nop			;072e	00 	. 
	nop			;072f	00 	. 
	nop			;0730	00 	. 
	nop			;0731	00 	. 
	nop			;0732	00 	. 
	nop			;0733	00 	. 
	nop			;0734	00 	. 
	nop			;0735	00 	. 
	nop			;0736	00 	. 
	nop			;0737	00 	. 
	nop			;0738	00 	. 
	nop			;0739	00 	. 
	nop			;073a	00 	. 
	nop			;073b	00 	. 
	nop			;073c	00 	. 
	nop			;073d	00 	. 
	nop			;073e	00 	. 
	nop			;073f	00 	. 
	nop			;0740	00 	. 
	nop			;0741	00 	. 
	nop			;0742	00 	. 
	nop			;0743	00 	. 
	nop			;0744	00 	. 
	nop			;0745	00 	. 
	nop			;0746	00 	. 
	nop			;0747	00 	. 
	nop			;0748	00 	. 
	nop			;0749	00 	. 
	nop			;074a	00 	. 
	nop			;074b	00 	. 
	nop			;074c	00 	. 
	nop			;074d	00 	. 
	nop			;074e	00 	. 
	nop			;074f	00 	. 
	nop			;0750	00 	. 
	nop			;0751	00 	. 
	nop			;0752	00 	. 
	nop			;0753	00 	. 
	nop			;0754	00 	. 
	nop			;0755	00 	. 
	nop			;0756	00 	. 
	nop			;0757	00 	. 
	nop			;0758	00 	. 
	nop			;0759	00 	. 
	nop			;075a	00 	. 
	nop			;075b	00 	. 
	nop			;075c	00 	. 
	nop			;075d	00 	. 
	nop			;075e	00 	. 
	nop			;075f	00 	. 
	nop			;0760	00 	. 
	nop			;0761	00 	. 
	nop			;0762	00 	. 
	nop			;0763	00 	. 
	nop			;0764	00 	. 
	nop			;0765	00 	. 
	nop			;0766	00 	. 
	nop			;0767	00 	. 
	nop			;0768	00 	. 
	nop			;0769	00 	. 
	nop			;076a	00 	. 
	nop			;076b	00 	. 
	nop			;076c	00 	. 
	nop			;076d	00 	. 
	nop			;076e	00 	. 
	nop			;076f	00 	. 
	nop			;0770	00 	. 
	nop			;0771	00 	. 
	nop			;0772	00 	. 
	nop			;0773	00 	. 
	nop			;0774	00 	. 
	nop			;0775	00 	. 
	nop			;0776	00 	. 
	nop			;0777	00 	. 
	nop			;0778	00 	. 
	nop			;0779	00 	. 
	nop			;077a	00 	. 
	nop			;077b	00 	. 
	nop			;077c	00 	. 
	nop			;077d	00 	. 
	nop			;077e	00 	. 
	nop			;077f	00 	. 
	nop			;0780	00 	. 
	nop			;0781	00 	. 
	nop			;0782	00 	. 
	nop			;0783	00 	. 
	nop			;0784	00 	. 
	nop			;0785	00 	. 
	nop			;0786	00 	. 
	nop			;0787	00 	. 
	nop			;0788	00 	. 
	nop			;0789	00 	. 
	nop			;078a	00 	. 
	nop			;078b	00 	. 
	nop			;078c	00 	. 
	nop			;078d	00 	. 
	nop			;078e	00 	. 
	nop			;078f	00 	. 
	nop			;0790	00 	. 
	nop			;0791	00 	. 
	nop			;0792	00 	. 
	nop			;0793	00 	. 
	nop			;0794	00 	. 
	nop			;0795	00 	. 
	nop			;0796	00 	. 
	nop			;0797	00 	. 
	nop			;0798	00 	. 
	nop			;0799	00 	. 
	nop			;079a	00 	. 
	nop			;079b	00 	. 
	nop			;079c	00 	. 
	nop			;079d	00 	. 
	nop			;079e	00 	. 
	nop			;079f	00 	. 
	nop			;07a0	00 	. 
	nop			;07a1	00 	. 
	nop			;07a2	00 	. 
	nop			;07a3	00 	. 
	nop			;07a4	00 	. 
	nop			;07a5	00 	. 
	nop			;07a6	00 	. 
	nop			;07a7	00 	. 
	nop			;07a8	00 	. 
	nop			;07a9	00 	. 
	nop			;07aa	00 	. 
	nop			;07ab	00 	. 
	nop			;07ac	00 	. 
	nop			;07ad	00 	. 
	nop			;07ae	00 	. 
	nop			;07af	00 	. 
	nop			;07b0	00 	. 
	nop			;07b1	00 	. 
	nop			;07b2	00 	. 
	nop			;07b3	00 	. 
	nop			;07b4	00 	. 
	nop			;07b5	00 	. 
	nop			;07b6	00 	. 
	nop			;07b7	00 	. 
	nop			;07b8	00 	. 
	nop			;07b9	00 	. 
	nop			;07ba	00 	. 
	nop			;07bb	00 	. 
	nop			;07bc	00 	. 
	nop			;07bd	00 	. 
	nop			;07be	00 	. 
	nop			;07bf	00 	. 
	nop			;07c0	00 	. 
	nop			;07c1	00 	. 
	nop			;07c2	00 	. 
	nop			;07c3	00 	. 
	nop			;07c4	00 	. 
	nop			;07c5	00 	. 
	nop			;07c6	00 	. 
	nop			;07c7	00 	. 
	nop			;07c8	00 	. 
	nop			;07c9	00 	. 
	nop			;07ca	00 	. 
	nop			;07cb	00 	. 
	nop			;07cc	00 	. 
	nop			;07cd	00 	. 
	nop			;07ce	00 	. 
	nop			;07cf	00 	. 
	nop			;07d0	00 	. 
	nop			;07d1	00 	. 
	nop			;07d2	00 	. 
	nop			;07d3	00 	. 
	nop			;07d4	00 	. 
	nop			;07d5	00 	. 
	nop			;07d6	00 	. 
	nop			;07d7	00 	. 
	nop			;07d8	00 	. 
	nop			;07d9	00 	. 
	nop			;07da	00 	. 
	nop			;07db	00 	. 
	nop			;07dc	00 	. 
	nop			;07dd	00 	. 
	nop			;07de	00 	. 
	nop			;07df	00 	. 
	nop			;07e0	00 	. 
	nop			;07e1	00 	. 
	nop			;07e2	00 	. 
	nop			;07e3	00 	. 
	nop			;07e4	00 	. 
	nop			;07e5	00 	. 
	nop			;07e6	00 	. 
	nop			;07e7	00 	. 
	nop			;07e8	00 	. 
	nop			;07e9	00 	. 
	nop			;07ea	00 	. 
	nop			;07eb	00 	. 
	nop			;07ec	00 	. 
	nop			;07ed	00 	. 
	nop			;07ee	00 	. 
	nop			;07ef	00 	. 
	nop			;07f0	00 	. 
	nop			;07f1	00 	. 
	nop			;07f2	00 	. 
	nop			;07f3	00 	. 
	nop			;07f4	00 	. 
	nop			;07f5	00 	. 
	nop			;07f6	00 	. 
	nop			;07f7	00 	. 
	nop			;07f8	00 	. 
	nop			;07f9	00 	. 
	nop			;07fa	00 	. 
	nop			;07fb	00 	. 
	nop			;07fc	00 	. 
	nop			;07fd	00 	. 
	nop			;07fe	00 	. 
l07ffh:
	nop			;07ff	00 	. 
