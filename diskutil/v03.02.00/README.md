# diskutil v03.02.00

This is the version of diskutil that comes with XENIX 3.2.0

# WD2010 Support

XENIX 3.2.0 will support the WD2010 disk controller.

See http://nemesis.lonestar.org/computers/tandy/hardware/storage/mfm.html 

To patch this version of diskutil to use a WD2010 controller:

patch /diskutil
byte offset ( to exit) ? 16be [ENTER]
16be: 04 |.| > 08 [ENTER]
16bf: b7 |.| > q [ENTER]
byte offset ( to exit) ? [ENTER]



