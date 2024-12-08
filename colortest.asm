
	processor 6502
	include vcs.h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	SEG.U RAM
	org $80
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
framecount: BYTE -1


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
	ldy #13

.vblank_loop:
	sta WSYNC
	dey
	bne .vblank_loop
	
	; start of active frame (line 21)
	sta  WSYNC
	lda #0             ; +2  2
	sta VBLANK         ; +3  5
	ldy # 241
	lda framecount
	eor #1
	sta framecount
	beq .even_frame
.odd_frame:
	lda #$02
	sta COLUBK
	lda #$C4
	sta COLUPF
	lda #$0F
	sta PF1
	sta PF2
	jmp .end_frame
.even_frame:
	lda #$02
	sta COLUBK
	lda #$08
	sta COLUPF
	lda #$00
	sta PF1
	lda #$FF
	sta PF2
.end_frame:

.line_loop:
	sta WSYNC
	;  sty COLUBK
	dey
	bne .line_loop

	jmp FrameLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Reset and Interrupt vectors
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	org $FFFC
	.word Start
	.word Start

