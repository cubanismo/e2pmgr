; Copyright 2020, James Jones
; SPDX-License-Identifier: CC0-1.0

		.include "jaguar.inc"
		.include "skunk.inc"

; From eeprom.s
		.extern eeRawWriteBank
		.extern eeValidateChecksum
		.extern eeInit128
		.extern eeInit2048

eeprom_size	.equ	128

; Begin startup code.  Don't use startup.s, don't clobber the stack, and don't
; even set up Tom/Jerry or Video.  This code is meant to run from the skunk boot
; screen only, and returns back to the skunk polling loop when done.

		.68000
		.text
start:
		movem.l	a0/d0,-(sp)
		jsr	skunkRESET
		jsr	skunkNOP
		jsr	skunkNOP

.if (eeprom_size = 2048)
		jsr	eeInit2048
.else
		jsr	eeInit128
.endif

		lea	filename,a0		; Open eeprom.e2p in read mode
		move.l	#1,d0
		jsr	skunkFILEOPEN

		lea	e2pscrch,a0		; Read file to scratch buffer
		move.l	#eeprom_size,d0
		jsr	skunkFILEREAD
		jsr	skunkFILECLOSE
		cmp.l	#eeprom_size,d0
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
		jsr	skunkCONSOLEWRITE
		bra	.done

.success:
		lea	e2pgoodmsg,a0		; No! Report success to console
		jsr	skunkCONSOLEWRITE

.done:
		jsr	skunkCONSOLECLOSE
		movem.l	(sp)+,a0/d0
		rts

		.data
		.long
filename:	dc.b	'eeprom.e2p',0
		.long
fileermsg:	dc.b	'ERROR! Failed to read EEPROM data from host.',13,10,0
		.long
e2permsg:	dc.b	'ERROR! Failed to write EEPROM.',13,10,0
		.long
e2pgoodmsg:	dc.b	'EEPROM content updated.',13,10,0

		.bss
		.long

e2pscrch:	.ds.w	eeprom_size>>1	; Working copy of eeprom content
