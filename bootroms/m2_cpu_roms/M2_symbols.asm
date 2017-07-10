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
