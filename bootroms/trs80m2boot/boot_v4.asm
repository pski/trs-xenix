; TRS-80 Model II boot ROM, rev 4, reconstructed source code
; Copyright 2012 Eric Smith <eric@brouhaha.com>
; 21-FEB-2012
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

	ld	sp,hd_stack_init

	ld	a,nmi_ram_en_video_ram	; enable video, video RAM,
	out	(nmi_ram_reg),a		; and select memory bank 0

	ld	a,083h
	out	(0f8h),a

; initialize DMA chip on CPU board
; send reset command multiple times, in case the chip was in the midst
; of a load sequence
	ld	a,dma_cmd_reset
	out	(dma_reg),a
	out	(dma_reg),a
	out	(dma_reg),a
	out	(dma_reg),a
	out	(dma_reg),a

; initialize CTC chip on CPU board
	ld	a,ctc_reset+ctc_control
	out	(ctc_reg),a
	out	(ctc_reg+1),a
	out	(ctc_reg+2),a
	out	(ctc_reg+3),a

; initialize PIO chip on FDC board
; as luck would have it, the same initialization value used for a CTC
; channel happens to be the PIO command to disable interrupts
; BUG - the disable interrupt command should be sent twice to each channel,
; in case the channel is in the midst of a two-byte load sequence
	out	(fdc_pio_reg+3),a
	out	(fdc_pio_reg+2),a

; initialize SIO chip on CPU board
; BUG - the reset command should be sent twice to each channel, in case
; the channel has a register other than WR0 selected
	ld	a,sio_cmd_channel_reset
	out	(sio_ctl_reg),a
	out	(sio_ctl_reg+1),a

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
	xor	a
	ld	bc,rom_end-rom_start	; byte count
	ld	hl,rom_start
rom_checksum_loop:
	add	a,(hl)
	ld	d,a
	inc	hl
	dec	bc
	ld	a,b
	or	c
	ld	a,d
	jr	nz,rom_checksum_loop
	or	a
	jp	nz,ck_err

; rudimentary Z80 CPU test
	ld	a,055h
	cpl
	or	a
	and	a
	ld	b,a
	ld	c,b
	ld	d,c
	ld	e,d
	ld	h,e
	ld	l,h
	inc	l
	dec	l
	ex	de,hl
	ex	af,af'
	ld	a,e
	exx
	ld	b,a
	ld	c,b
	ld	d,c
	ld	e,d
	ld	h,e
	ld	l,h
	ld	a,l
	ld	i,a
	ld	a,i
	ld	l,a
	ex	af,af'
	cp	l
	jp	nz,z8_err

; rudimentary RAM test - can't test RAM overlaid by ROM
	ld	bc,ram_size-max_rom_size
	ld	hl,max_rom_size
	ld	d,h
	ld	e,l
ram_test_loop:
	ld	a,(de)
	cpl
	ld	(de),a
	cp	(hl)
	cpl
	ld	(hl),a
	jp	nz,mf_err
	ldi
	jp	pe,ram_test_loop

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

; reset HDC and check for drive presence
	xor	a
	out	(hdc_control_reg),a
	ld	a,0			; possible BUG - should be hdc_control_soft_reset
	out	(hdc_control_reg),a
	ld	a,hdc_control_deven+hdc_control_wait_enable+hdc_control_intrq_enable+hdc_control_dma_enable
	out	(hdc_control_reg),a

	in	a,(hdc_drive_id_45)	; check ID of drive 4
	and	00fh
	jr	z,fd_seek_5		;   zero, no drive 4

hd_seek_5:
; attempt to seek to track 5 on all four hard drives
; B is counter, C is SDH value
	ld	bc,(4*256)+(hdc_sdh_sect_size_512)+(3*8)
hd_seek_5_loop:
; select drive
	ld	a,c
	out	(hdc_size_drive_head_reg),a

; restore
	ld	a,hdc_command_restore+hdc_command_step_rate_7p5_ms
	out	(hdc_command_reg),a
	call	hd_wait_not_busy

; seek to cylinder 5
	xor	a
	out	(hdc_cylinder_high_reg),a
	ld	a,5
	out	(hdc_cylinder_low_reg),a
	ld	a,hdc_command_seek+hdc_command_step_rate_1p5_ms
	out	(hdc_command_reg),a
	call	hd_wait_not_busy

	ld	a,c	; decrement drive field
	sub	8
	ld	c,a
	djnz	hd_seek_5_loop

fd_seek_5:
	ld	b,4		; drive count
	ld	de,(fdc_sel_side_0*256)+(0f0h+fdc_sel_dr_3)
				; D = basic FD select reg contents (w/o drive)
				; E = drive mask, only one bit low
fd_seek_5_loop
	push	bc
	push	de
	ld	a,e
	and	00fh
	or	d
	out	(0efh),a
	
	call	terminate_fdc_cmd

	xor	a
	out	(fdc_track_reg),a
	ld	a,5
	out	(fdc_data_reg),a
	ld	a,fdc_cmd_seek+fdc_cmd_step_rate_15ms
	out	(fdc_cmd_reg),a
	call	fdc_seek_wait
	pop	de
	rrc	e
	pop	bc
	djnz	fd_seek_5_loop

	in	a,(hdc_drive_id_45)	; check ID of drive 4
	and	00fh
	jp	z,floppy_boot		;   zero, no drive 4

	ld	d,21	; loop up to 21 times waiting for controller ready
hd_wait_ready:
; Check if controller is ready
; POSSIBLE BUG!  WD1000 documentation says that no other bits or registers
; are valid if the busy bit of the status register is set, so it should
; be checked here.
	in	a,(hdc_status_reg)
	bit	hdc_status_bit_ready,a
	jr	nz,hd_is_ready

; HD not ready. Is the user trying to abort the HD boot?
	call	check_escape_key	; escape key pressed?
	jp	z,floppy_boot		;   yes, skip HD and boot FD

	call	delay_bc		; POSSIBLE BUG - what's in BC?

	dec	d
	jr	nz,hd_wait_ready
	jr	ht_err

hd_is_ready:
	call	check_escape_key	; escape key pressed?
	jp	z,floppy_boot		;   yes, skip HD and boot FD

; restore
	ld	a,hdc_command_restore+hdc_command_step_rate_7p5_ms
	out	(hdc_command_reg),a
	call	hd_wait_not_busy
	jr	nz,hd_tr0_not_found

	ld	hl,hd_load_addr	; start loading HD sectors into memory at 0000
			; if we load 17 sectors, they'll occupy 0000-21ff
			; we MUST load at least 9 sectors, because we can't
			; detect the end signature below 1000 since the
			; RAM from 0000-0fff is overlaid by this boot ROM
	ld	bc,(1*256)+hdc_sector_number_reg	; start w/ sector 1

hd_read_sector:
	ld	d,h		; copy HL into DE for signature check
	ld	e,l
	out	(c),b		; write sector register
	ld	a,hdc_command_read_sector_pio
	out	(hdc_command_reg),a
	call	hd_wait_not_busy
	jr	nz,hd_err_from_err_reg

hd_wait_for_drq:
	in	a,(hdc_status_reg)
	bit	hdc_status_bit_data_request,a
	jr	z,hd_wait_for_drq
	call	check_escape_key
	jr	z,floppy_boot

	inc	b		; advance sector number
	push	bc		; and save it for next iteration
	ld	a,2		; leftover from older version, not needed
	ld	bc,(0*256)+hdc_data_reg
	inir
	inir

	push	hl			; check for end boot sig
	ld	hl,hd_boot_end_sig
	ld	b,hd_boot_end_sig_len
	call	check_disk_signature
	pop	hl
	pop	bc
	jr	nz,hd_read_sector	; end boot sig not found, continue read

	ld	bc,0
	call	delay_bc
	call	check_escape_key
	jr	z,floppy_boot

	xor	a			; disable HD
	out	(hdc_control_reg),a

	ex	de,hl			; jump to location after end sig
	jp	(hl)

ht_err:
	ld	e,'T'
	jr	hard_disk_err

hd_err_from_err_reg:
	bit	hdc_error_bit_crc_data,a
	ld	e,'C'
	jr	nz,hard_disk_err

	bit	hdc_error_bit_crc_id,a
	ld	e,'I'
	jr	nz,hard_disk_err

	bit	hdc_error_bit_id_not_found,a
	ld	e,'N'
	jr	nz,hard_disk_err

	bit	hdc_error_bit_aborted_cmd,a
	ld	e,'A'
	jr	nz,hard_disk_err

	bit	hdc_error_bit_track_0_not_found,a
hd_tr0_not_found:
	ld	e,'0'
	jr	nz,hard_disk_err

	bit	hdc_error_bit_data_mark_not_found,a
	ld	e,'M'
	jr	nz,hard_disk_err

	ld	e,'D'	; other error

hard_disk_err:
	ld	d,'H'
	ld	hl,0fb9ah
	ld	(hl),d
	inc	hl
	ld	(hl),e
	inc	hl
	ld	(hl),' '

	ld	hl,boot_err_msg
	ld	de,0fb8eh
	ld	bc,boot_err_msg_len
	ldir

wait_for_escape_key
	call	check_escape_key
	jr	nz,wait_for_escape_key

floppy_boot:
	ld	sp,fd_stack_init
	xor	a
	out	(hdc_control_reg),a

; select drive 0, side 0
	ld	a,fdc_sel_side_0+fdc_sel_dr_0
	out	(fdc_select_reg),a

; display "insert disk" message
	ld	hl,insert_disk_msg
	ld	de,0fb8eh
	ld	bc,insert_disk_msg_len
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
	ld	a,fdc_cmd_restore+fdc_cmd_head_load+fdc_cmd_step_rate_15ms
	out	(fdc_cmd_reg),a

; wait a long time, 8 times the maximum for delay_bc subroutine
; BC value at this point is left over from lddr
	ld	d,7
fd_restore_wait:
	call	delay_bc
	in	a,(fdc_status_reg)
	bit	fdc_status_bit_busy,a
	jr	z,fd_restore_done
	dec	d
	jr	nz,fd_restore_wait

fd_restore_done:
; check all the various error bits of the FDC status
	in	a,(fdc_status_reg)
	push	af
	xor	fdc_status_track_zero	; error when zero
	and	fdc_status_seek_err+fdc_status_track_zero+fdc_status_busy
	jr	nz,dc_err
	pop	af
	bit	fdc_status_bit_not_ready,a
	jr	nz,d0_err
	bit	fdc_status_bit_crc_err,a
	jr	nz,sc_err

; read the bootstrap code from track zero of the floppy (single density)
fd_read_boot:
	ld	hl,fd_load_addr	; HL = buffer
	ld	de,(fd_load_sector_count*256)+fd_retry_count
						; D = sector count
						; E = retry count
	ld	bc,(fd_load_sector_size*256)+1	; B = sector size (128)
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
	jr	nz,fd_read_data_loop	;   yes, continue reading

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

; read fail - retries exhausted
	bit	fdc_status_bit_rec_not_found,a
	jr	nz,tk_err
	bit	fdc_status_bit_crc_err,a
	jr	nz,sc_err
	jr	ld_err

fd_read_ok:
	pop	af			; discard original buffer pointer
	inc	c			; increment sector number
	ld	e,fd_retry_count	; restore retry count
	dec	d			; decrement sector count
	jr	nz,fd_read_sector	; if more sectors, loop

	ld	hl,fd_boot_sig_0
	ld	de,01000h
	ld	b,fd_boot_sig_0_len
	call	check_disk_signature
	jr	nz,rs_err

	ld	hl,fd_boot_sig_1
	ld	de,01400h
	ld	b,fd_boot_sig_1_len
	call	check_disk_signature
	jr	nz,rs_err

	call	fd_boot_sig_1_loc+fd_boot_sig_1_len
	jp	fd_boot_sig_0_loc+fd_boot_sig_0_len

dc_err:
	ld	de,'DC'
	jr	boot_err_deselect_fd

d0_err:
	ld	de,'D0'
	jr	boot_err_deselect_fd

sc_err:
	ld	de,'SC'
	jr	boot_err_deselect_fd

ck_err:
	ld	de,'CK'
	jr	boot_err

z8_err:
	ld	de,'Z8'
	jr	boot_err

mf_err:
	ld	de,'MF'
	jr	boot_err

tk_err:
	ld	de,'TK'
	jr	boot_err_deselect_fd

ld_err:
	ld	de,'LD'
	jr	boot_err_deselect_fd

rs_err:
	ld	de,'RS'

boot_err_deselect_fd:
	ld	a,fdc_sel_side_0+fdc_sel_dr_none
	out	(fdc_select_reg),a

boot_err:
	ld	hl,0fb9ah
	ld	(hl),d
	inc	hl
	ld	(hl),e
	inc	hl
	ld	(hl),' '

	ld	hl,boot_err_msg
	ld	de,0fb8eh
	ld	bc,boot_err_msg_len
	ldir

; The following sequence should just be:
;	call	check_escape_key
;	jp	z,fd_boot_sig_0_loc+fd_boot_sig_0_len
; But instead we have the following buggy sequence:
	in	a,(nmi_status_reg)
	bit	nmi_status_bit_kbd_int,a
	jr	z,panic
; BUG - the following IN instruction is missing!
;	in	a,(kbd_data_reg)
	cp	key_escape
	jp	z,fd_boot_sig_0_loc+fd_boot_sig_0_len
	cp	key_break
	jp	z,fd_boot_sig_0_loc+fd_boot_sig_0_len

panic:
	halt
	rst	0	; should never get here!


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
	ld	a,fdc_cmd_force_int+fdc_cmd_force_int_immediate
	out	(fdc_cmd_reg),a
	ld	a,fdc_cmd_force_int
	out	(fdc_cmd_reg),a
	call	fdc_seek_wait
	in	a,(fdc_data_reg)	; to reset DRQ, presumably
	in	a,(fdc_status_reg)
	pop	bc
	ret


; on entry:
;   HL = pointer to expected signature value constant (ROM)
;   DE = pointer to disk buffer location to check for signature
;   B = byte count
; on return, zero flag set if match, clear if no match
check_disk_signature:
	ld	a,(de)
	cp	(hl)
	ret	nz
	inc	hl
	inc	de
	djnz	check_disk_signature
	ret


; on return, zero flag set if escape or break pressed, clear if not
check_escape_key:
	in	a,(nmi_status_reg)
	xor	080h
	bit	nmi_status_bit_kbd_int,a
	ret	nz
	in	a,(kbd_data_reg)
	cp	key_escape
	ret	z
	cp	key_break
	ret

; returns with Z set and hdc_status_reg in A for no error
; returns with Z clear and hdc_error_reg in A for HDC error
; returns with Z clear and 008h in A for timeout
hd_wait_not_busy:
	push	bc
	ld	bc,32767	; retry counter
hd_wait_not_busy_loop:
	in	a,(hdc_status_reg)
	bit	hdc_status_bit_busy,a
	jr	nz,hd_busy
	bit	hdc_status_bit_seek_complete,a
	jr	nz,hd_seek_complete

hd_busy:
	ex	(sp),ix		; short delay
	ex	(sp),ix
	dec	bc		; decrement retry counter
	ld	a,b		; count expired?
	or	c
	jr	nz,hd_wait_not_busy_loop	;   no, try again
	or	008h		; pretend we got an "id not found" error
	pop	bc
	ret

hd_seek_complete:
	pop	bc
	bit	hdc_status_bit_error,a	; any error
	ret	z		; no, return with Z set
	in	a,(hdc_error_reg)
	ret


; wait for an FDC seek command to complete
; first wait briefly fo rthe 
fdc_seek_wait:
	push	af
	in	a,(fdc_status_reg)
	push	bc

	ld	bc,5		; set retry count to 5

fdc_wait_for_busy:
	rra			; rotate busy status bit into carry
	jr	c,fdc_busy

	dec	bc		; not yet busy, decrement retry count
	ld	a,b		; check for zero
	or	c

	in	a,(fdc_status_reg)	; reload 
	jr	nz,fdc_wait_for_busy

; POSSIBLE BUG - at this point we've polled the FDC five times, and it has
; never gone busy. This should probably be treated as an error condition,
; yet we actually ignore it, and fall into the loop waiting for the FDC to
; go non-busy.

fdc_busy:
	ld	bc,0		; set retry count to 65536

fdc_busy_loop:
	dec	bc		; decrement retry count
	ld	a,b
	or	c
	jr	z,fdc_timeout	; underflow

	in	a,(fdc_status_reg)	; reload status register
	rra
	jr	c,fdc_busy_loop	; still busy

	pop	bc		; not busy, we're done
	pop	af
	ret

fdc_timeout:
	pop	af
	pop	af
	pop	af
	jp	dc_err


hd_boot_end_sig:
	db	"/* END BOOT */"
hd_boot_end_sig_len	equ	$-hd_boot_end_sig

boot_err_msg:
	db	" BOOT ERROR "
boot_err_msg_len	equ	$-boot_err_msg

fd_boot_sig_0_loc	equ	1000h
fd_boot_sig_0		equ	boot_err_msg+1
fd_boot_sig_0_len	equ	4

insert_disk_msg:
	db	" INSERT DISKETTE "
insert_disk_msg_len	equ	$-insert_disk_msg

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

	db	004h		; version
	db	082h,011h,018h	; 18-NOV-1982

	db	013h,030h	; ???

	db	010h		; checksum

rom_end	equ	$

; fill remainter of ROM with 0ffh
