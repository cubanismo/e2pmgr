
		.include "jaguar.inc"
		.include "skunk.inc"

; From eeprom.s
		.extern eeReadBank
		.extern eeValidateChecksum

; Begin startup code.  Don't use startup.s, don't clobber the stack, and don't
; even set up Tom/Jerry or Video.  This code is meant to run from the skunk boot
; screen only, and returns back to the skunk polling loop when done.

		.68000
		.text
start:
		bsr	skunkRESET
		bsr	skunkNOP
		bsr	skunkNOP

		lea	e2pscrch,a0		; Read e2p to scratch buffer
		jsr	eeReadBank

		tst.w	d0			; Was there an error?
		beq	.gotdata

		lea	e2permsg,a0		; There was! Report to console
		bsr	skunkCONSOLEWRITE
		bra	.done

.gotdata:
		lea	filename,a0		; Open eeprom.e2p in write mode
		move.l	#0,d0
		jsr	skunkFILEOPEN

		lea	e2pscrch,a0		; Write e2p content to file
		move.l	#128,d0
		jsr	skunkFILEWRITE
		jsr	skunkFILECLOSE

		lea	e2pgoodmsg,a0
		jsr	skunkCONSOLEWRITE

.done:
		rts

		.data
		.long
filename:	dc.b	'eeprom.e2p'
		.long
e2permsg:	dc.b	'ERROR! Failed to read EEPROM.',13,10,0
		.long
e2pgoodmsg:	dc.b	'EEPROM content saved.',13,10,0

		.bss
		.long

e2pscrch:	.ds.w	64			; Working copy of eeprom content

