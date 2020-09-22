
		.include "jaguar.inc"
		.include "skunk.inc"

; From eeprom.s
		.extern eeRawWriteBank
		.extern eeValidateChecksum

; Begin startup code.  Don't use startup.s, don't clobber the stack, and don't
; even set up Tom/Jerry or Video.  This code is meant to run from the skunk boot
; screen only, and returns back to the skunk polling loop when done.

		.68000
		.text
start:
		movem.l	a0/d0,-(sp)
		bsr	skunkRESET
		bsr	skunkNOP
		bsr	skunkNOP

		lea	filename,a0		; Open eeprom.e2p in read mode
		move.l	#1,d0
		jsr	skunkFILEOPEN

		lea	e2pscrch,a0
		move.l	#128,d0
		jsr	skunkFILEREAD
		jsr	skunkFILECLOSE
		cmp.l	#128,d0
		beq	.gotdata

		lea	fileermsg,a0
		jsr	skunkCONSOLEWRITE
		bra	.done

.gotdata:
		lea	e2pscrch,a0		; Write scratch buffer to e2p
		jsr	eeRawWriteBank

		tst.w	d0			; Was there an error?
		beq	.success

		lea	e2permsg,a0		; There was! Report to console
		bsr	skunkCONSOLEWRITE
		bra	.done

.success:
		lea	e2pgoodmsg,a0		; No! Report success to console
		bsr	skunkCONSOLEWRITE

.done:
		movem.l	(sp)+,a0/d0
		rts

		.data
		.long
filename:	dc.b	'eeprom.e2p'
		.long
fileermsg:	dc.b	'ERROR! Failed to read EEPROM data from host.',13,10,0
		.long
e2permsg:	dc.b	'ERROR! Failed to write EEPROM.',13,10,0
		.long
e2pgoodmsg:	dc.b	'EEPROM content updated.',13,10,0

		.bss
		.long

e2pscrch:	.ds.w	64			; Working copy of eeprom content

