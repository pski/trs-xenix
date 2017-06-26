; TRS-80 Model II boot ROM, rev 1, reconstructed source code
; Copyright 2012 Eric Smith <eric@brouhaha.com>
; 20-FEB-2012
; Based in part on a disassembly by Fred Jan Kraan
	
; This program is free software: you can redistribute it and/or modify
; it under the terms of version 3 of the GNU General Public License as
; published by the Free Software Foundation.
;
; This program is distributed in the hope that it will be useful, but
; WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
; General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.

; This source code uses long symbols, won't assemble with some common
; assemblers that only consider the first six characters to be
; significant.  It will assemble with "Macro Assembler AS":
;     http://www.alfsembler.de/

	listing	off
	include	m2.inc
	listing	on

	org	rom_start

	di

	ld	a,nmi_ram_en_video_ram	; enable video, video RAM,
	out	(nmi_ram_reg),a		; and select memory bank 0

	ld	sp,fd_stack_init

; set all screen memory to inverse spaces
	ld	bc,screen_size-1		; number of chars for block move
	ld	de,screen_start+screen_size-2	; next-to-last loc
	ld	hl,screen_start+screen_size-1	; last loc
	ld	(hl),' '+inverse		; set last char
	lddr					; copy downward to start

; init CRTC
	ld	bc,((crtc_init_table_len-1)*100h)+crtc_addr_reg
	ld	hl,crtc_init_table+crtc_init_table_len-1
crtc_init_loop:
	ld	a,(hl)
	out	(c),b			; write CRTC addr reg
	out	(crtc_data_reg),a
	dec	hl
	dec	b
	jp	p,crtc_init_loop

; ROM checksum test, only first 512 bytes
	ld	hl,rom_start
	ld	de,(rom_end-rom_start)-1 	; byte count
	xor	a
rom_checksum_loop:
	ld	b,(hl)
	add	a,b
	inc	hl
	dec	de
	ld	c,a
	ld	a,d
	or	e
	ld	a,c
	jr	nz,rom_checksum_loop

	cpl
	cp	(hl)
	ld	hl,(ck_err_msg)
	jp	nz,boot_err

; rudimentary Z80 CPU test
	ld	a,055h
	cpl
	or	a
	and	a
	ex	af,af'
	ex	af,af'
	ld	b,a
	ld	c,b
	ld	d,c
	ld	e,d
	ld	h,e
	ld	l,h
	ex	de,hl
	exx
	exx
	inc	l
	dec	l
	cp	l
	ld	hl,(z8_err_msg)
	jp	nz,boot_err

; rudimentary RAM test
	ld	hl,rom_start+max_rom_size
ram_test_loop:
	ld	a,(hl)
	cpl
	ld	(hl),a
	cp	(hl)
	cpl
	ld	(hl),a
	jp	nz,mf_err
	inc	hl
	ld	a,h
	cp	(ram_start+ram_size)/256
	jr	nz,ram_test_loop

; clear keyboard
	ld	d,200
clear_keyboard_loop:
	in	a,(nmi_status_reg)
	bit	nmi_status_bit_kbd_int,a
	jr	z,clear_kbd_no_key
	in	a,(kbd_data_reg)
clear_kbd_no_key:
	ld	bc,128
	call	delay_bc
	dec	d
	jr	nz,clear_keyboard_loop

; select drive 0, side 0
	ld	a,fdc_sel_side_0+fdc_sel_dr_0
	out	(fdc_select_reg),a

; display "insert disk" message
	ld	hl,insert_disk_msg
	ld	de,0fb8eh
	ld	b,000h
	ld	c,(hl)		; get message length byte
	inc	hl		; and skip past it to start of actual message
	ldir

fd_wait_for_ready:
	call	terminate_fdc_cmd
	bit	7,a
	jr	nz,fd_wait_for_ready

; clear screen (all 020h)
	ld	bc,screen_size-1		; number of chars for block move
	ld	de,screen_start+screen_size-2	; next-to-last loc
	ld	hl,screen_start+screen_size-1	; last loc
	ld	(hl),' '
	lddr

	call	terminate_fdc_cmd
	ld	a,fdc_cmd_restore+fdc_cmd_verify_track+fdc_cmd_step_rate_10ms
	out	(fdc_cmd_reg),a

; wait a long time, 8 times the maximum for delay_bc subroutine
; BC value at this point is left over from lddr
	ld	d,7
fd_restore_wait:
	call	delay_bc
	dec	d
	jr	nz,fd_restore_wait

; check all the various error bits of the FDC status
	in	a,(fdc_status_reg)
	bit	fdc_status_bit_busy,a
	jr	nz,dc_err
	bit	fdc_status_bit_seek_err,a
	jr	nz,dc_err
	bit	fdc_status_bit_track_zero,a
	jr	z,dc_err
	bit	fdc_status_bit_not_ready,a
	jr	nz,d0_err
	bit	fdc_status_bit_crc_err,a
	jr	nz,sc_err
	jr	fd_read_boot

dc_err:
	ld	hl,(dc_err_msg)
	jr	boot_err

mf_err:
	ld	hl,(mf_err_msg)
	jr	boot_err

d0_err:
	ld	hl,(d0_err_msg)
	jr	boot_err

tk_err:
	ld	hl,(tk_err_msg)
	jr	boot_err

sc_err:
	ld	hl,(sc_err_msg)
	jr	boot_err

ld_err:
	ld	hl,(ld_err_msg)

boot_err:
	ld	de,0fb99h
	ex	de,hl
	ld	(hl),e
	inc	hl
	ld	(hl),d
	inc	hl
	ld	(hl),' '

	ld	de,0fb8eh
	ld	hl,boot_err_msg
	ld	bc,boot_err_msg_len
	ldir

	in	a,(nmi_status_reg)
	bit	nmi_status_bit_kbd_int,a
	jr	z,panic
	in	a,(kbd_data_reg)
	cp	key_escape
	jr	nz,panic
	jp	fd_boot_sig_0_loc+fd_boot_sig_0_len

panic:
	call	terminate_fdc_cmd
	ld	a,fdc_cmd_restore+fdc_cmd_step_rate_10ms
	out	(fdc_cmd_reg),a
	ld	bc,0
	call	delay_bc
	call	terminate_fdc_cmd
	ld	a,fdc_sel_side_0+fdc_sel_dr_none
	out	(fdc_select_reg),a
	di		; not really necessary, as interrupts never enabled
	halt
	rst	0	; should never get here!

; report a failure to read the bootstrap
; on entry, FDC status in A
fd_read_fail:
	bit	fdc_status_bit_rec_not_found,a
	jr	nz,tk_err
	bit	fdc_status_bit_crc_err,a
	jr	nz,sc_err
	jr	ld_err

; read the bootstrap code from track zero of the floppy (single density)
fd_read_boot:
	ld	hl,fd_load_addr	; HL = buffer
	ld	de,(fd_load_sector_count*256)+fd_retry_count
						; D = sector count
						; E = retry count
	ld	bc,(fd_load_sector_size*256)+1	; B = sector size
						; C = sector number (1)

	ld	a,fdc_cmd_read_sector	; keep an FDC read command in A'
	ex	af,af'

fd_read_sector:
	push	hl		; save copies of the arguments
	push	de
	push	bc

	call	terminate_fdc_cmd	; ensure that FDC is ready for a cmd

	ld	a,c			; give FDC the sector number
	out	(fdc_sector_reg),a

	ex	af,af'			; give FDC command from A'
	out	(fdc_cmd_reg),a
	ex	af,af'

	call	delay_bc_5
	pop	bc			; get original sector size, number back
	push	bc

	ld	c,fdc_data_reg		; prepare for ini instruction

fd_read_data_loop:
	in	a,(fdc_status_reg)	; is DRQ set
	bit	fdc_status_bit_drq,a
	jr	z,fd_read_data_no_drq	; no, make sure we're still busy

	ini				; read a byte into buffer
	jr	z,fd_read_data_done	; transfer complete?

fd_read_data_no_drq:
	bit	fdc_status_bit_busy,a	; still busy
	jp	nz,fd_read_data_loop	;   yes, continue reading

; read command data transfer complete
fd_read_data_done:
	pop	bc			; restore original sector, sector count
	pop	de			; etc.

	in	a,(fdc_status_reg)	; any errors?
	and	01ch
	jr	z,fd_read_ok		; no

; read error
	pop	hl			; restore original buffer pointer
	dec	e			; any retries left?
	jr	nz,fd_read_sector	; yes, go do it agin
	jr	fd_read_fail		; no, report failure

fd_read_ok:
	pop	af			; discard original buffer pointer
	inc	c			; increment sector number
	ld	e,fd_retry_count	; reset retry count
	dec	d			; decrement sector count
	jr	nz,fd_read_sector	; if more sectors, loop

	ld	hl,fd_boot_sig_0
	ld	de,fd_boot_sig_0_loc
	ld	b,fd_boot_sig_0_len
	call	check_disk_signature

	ld	hl,fd_boot_sig_1
	ld	de,fd_boot_sig_1_loc
	ld	b,fd_boot_sig_1_len
	call	check_disk_signature

	call	fd_boot_sig_1_loc+fd_boot_sig_1_len
	jp	fd_boot_sig_0_loc+fd_boot_sig_0_len

delay_bc_5:
	ld	bc,5
delay_bc:
	dec	bc
	ld	a,b
	or	c
	jr	nz,delay_bc
	ret


; use the FDC's FORCE INTERRUPT command to terminate anything in progress
; returns FDC status regster in A
terminate_fdc_cmd:
	push	bc
	ld	a,fdc_cmd_force_int
	out	(fdc_cmd_reg),a
	call	delay_bc_5
	in	a,(fdc_data_reg)	; to reset DRQ, presumably
	in	a,(fdc_status_reg)
	ld	a,fdc_cmd_force_int
	out	(fdc_cmd_reg),a
	call	delay_bc_5
	in	a,(fdc_status_reg)
	pop	bc
	ret


; on entry:
;   HL = pointer to expected signature value constant (ROM)
;   DE = pointer to disk buffer location to check for signature
;   B = byte count
; returns if signature good
; jumps to rs_err if signature bad
check_disk_signature:
	ld	a,(de)
	cp	(hl)
	jr	nz,rs_err
	inc	hl
	inc	de
	djnz	check_disk_signature
	ret

rs_err:
	ld hl,(rs_err_msg)
	jp boot_err

fd_boot_sig_0_loc	equ	1000h
fd_boot_sig_0:	; the first four bytes of the boot error message
		; double as the first signature for a bootable disk
fd_boot_sig_0_len	equ	4

boot_err_msg:
	db	"BOOT ERROR "
boot_err_msg_len	equ	$-boot_err_msg

dc_err_msg:
	db	"DC"

tk_err_msg:
	db	"TK"

d0_err_msg:
	db	"D0"

sc_err_msg:
	db	"SC"

ld_err_msg:
	db	"LD"

z8_err_msg:
	db	"Z8"

mf_err_msg:
	db	"MF"

ck_err_msg:
	db	"CK"

rs_err_msg:
	db	"RS"

insert_disk_msg:
	db	insert_disk_msg_len
	db	" INSERT DISKETTE "
insert_disk_msg_len	equ	$-(insert_disk_msg+1)

fd_boot_sig_1_loc	equ	1400h
fd_boot_sig_1:
	db	"DIAG"
fd_boot_sig_1_len	equ	$-fd_boot_sig_1

; CRC init table
crtc_init_table:
	db	99	; horizontal total
	db	80	; horizontal displayed
	db	85	; H sync position
	db	8	; H sync width
	db	25	; vertical total
	db	0	; V total adjust
	db	24	; vertical displayed
	db	24	; V sync position
	db	0	; interlace mode - no interlace
	db	10-1	; max scan line address
	db	crtc_cursor_blink_enable+crtc_cursor_blink_slow+5	; cursor start
	db	9	; cursor end
	db	0	; start address (H)
	db	0	; start address (L)
	db	3	; cursor (H)
	db	233	; cursor (L)
crtc_init_table_len	equ	$-crtc_init_table

	db	001h		; version

	db	0ffh,0ffh,0ffh	; no date

	db	0ffh		; ???

	db	03ah		; checksum

rom_end	equ	$

; fill remainter of ROM with 0ffh
