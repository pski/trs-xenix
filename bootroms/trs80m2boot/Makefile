ALL: boot_v1.bin boot_v2.bin boot_v3.bin boot_v4.bin boot_v5.bin

%.lst %.p: %.asm m2.inc
	asl -cpu z80 -L -C $<

%.hex: %.p
	p2hex $<

%.bin: %.hex
	srec_cat $< -intel -fill 0xff 0x0000 0x0800 -output $@ -binary

boot_v5.bin: boot_v5.hex
	srec_cat $< -intel -fill 0x00 0x0000 0x0800 -output $@ -binary
