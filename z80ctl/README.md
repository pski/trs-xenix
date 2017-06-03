# z80ctl

## TRS-XENIX Z80 Control Program

z80ctl is a z80 application that has the following responsibilities:

1. Bootstrapping TRS-XENIX
2. Handles all I/O with disks, serial, video, etc.

z80ctl's main job is to handle all I/O for the 68000 subsystem.  It does this by communicating with the MC68000 using shared memory locations and interrupts.

z80ctl is still very poorly understood.  One of the goals of the TRS-Xenix Project is to reverse engineer z80ctl so that modern systems can be integrated with TRS-XENIX, such as solid state storage solutions and networking adapters.
