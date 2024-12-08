
	processor 6502
	include vcs.h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	SEG.U RAM
	org $80
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; framecount: BYTE -1


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	SEG ROM
	org $F000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Start:

Init: SUBROUTINE
	sei
	cld
	ldx #$FF
	txs
	lda #0
.clear:
	sta 0,X
	dex
	bne .clear

FrameLoop:

	; vblank 1
	sta  WSYNC
	lda  #2
	sta  VBLANK

	; vblank 2
	sta  WSYNC

	; vblank 3
	sta  WSYNC

	; vblank 4 vsync 1
	sta  WSYNC
	lda  #2
	sta  VSYNC

	; vblank 5 vsync 2
	sta  WSYNC

	; vblank 6 vsync 3
	sta  WSYNC

	; vblank 7
	sta  WSYNC
	lda #0
	sta  VSYNC
	ldy #14

.vblank_loop:
	sta WSYNC
	dey
	bne .vblank_loop
	
	; start of active frame (line 21)
	sta  WSYNC
	lda #0
	sta VBLANK
	ldy #120

.line_loop:
	sta WSYNC
	lda #$0F
	sta PF1
	sta PF2
	lda #$02
	sta COLUBK
	lda #$C4
	sta COLUPF

	sta WSYNC
	lda #$F0
	sta PF1
	lda #$FF
	sta PF2
	lda #$02
	sta COLUBK
	lda #$D2
	sta COLUPF
	dey
	bne .line_loop

	jmp FrameLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Reset and Interrupt vectors
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	org $FFFC
	.word Start
	.word Start

