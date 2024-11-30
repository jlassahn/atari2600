
	processor 6502
	include vcs.h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	SEG.U RAM
	org $80
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
scanline: BYTE -1
road_seg: BYTE -1
road_col: BYTE -1
ground_col: BYTE -1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




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
	lda #255
	sta PF1
	lda #$A5
	sta GRP0
	lda #0
	sta HMP0
	lda #$FF
	sta COLUP0
	sta COLUPF

	lda #0
	sta COLUBK
	sta road_col
	lda #80
	sta ground_col
	lda Road0
	sta PF2
	lda Road1
	sta PF0
	lda Road2
	sta PF1

FrameLoop: SUBROUTINE
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
	lda #0
	sta  VSYNC

	; vblank 7
	sta  WSYNC

	; vblank 8
	sta  WSYNC

	; vblank 9
	sta  WSYNC

	; vblank 10
	sta  WSYNC

	; vblank 11
	sta  WSYNC

	; vblank 12
	sta  WSYNC

	; vblank 13
	sta  WSYNC

	; vblank 14
	sta  WSYNC

	; vblank 15
	sta  WSYNC

	; vblank 16
	sta  WSYNC

	; vblank 17
	sta  WSYNC

	; vblank 18
	sta  WSYNC

	; vblank 19
	sta  WSYNC

	; vblank 20
	sta  WSYNC
	lda #$70 ;+2
	sta HMP0 ;+3
	lda 0 ;+3
	lda 0 ;+3
	lda 0 ;+3
	lda 0 ;+3
	lda 0 ;+3
	lda 0 ;+3
	lda 0 ;+3
	lda 0 ;+3
	lda 0 ;+3
	nop   ;+2
	nop   ;+2
	; clock 36
	sta RESP0 ; this puts P0 at pixel 47 (one pixel left of active region)
	; completes at clock39

	; start of active frame (line 21)
	sta  WSYNC
	lda  #0
	sta  VBLANK

	ldy #30
	sty scanline

/* Playfield control by masking foreground color */
	sta WSYNC

SyncLineLoop:
	sta WSYNC
LineLoop:
	;;;;;;;;;;;;;;;;;;;;;; line 0
	sta HMOVE     ; +3  3
	lda scanline  ; +3  6  XXXXXX
	lda scanline  ; +3  9  XXXXXX
	lda scanline  ; +3  12 XXXXXX
	lda scanline  ; +3  15 XXXXXX
	lda scanline  ; +3  18 XXXXXX
	lda scanline  ; +3  21 XXXXXX
	lda scanline  ; +3  24 XXXXXX
	lda scanline  ; +3  27 XXXXXX
	lda scanline  ; +3  30 XXXXXX
	nop           ; +2  32 XXXXXX
	lda ground_col; +3  35
	sta COLUPF    ; +3  38
	lda scanline  ; +3  41 XXXXXX
	lda scanline  ; +3  44 XXXXXX
	lda scanline  ; +3  47 XXXXXX
	lda scanline  ; +3  50 XXXXXX
	lda scanline  ; +3  53 XXXXXX
	lda scanline  ; +3  56 XXXXXX
	nop           ; +2  58 XXXXXX
	nop           ; +2  60 XXXXXX
	lda road_col  ; +3  63
	sta COLUPF    ; +3  66
	lda scanline  ; +3  69 XXXXXX
	lda scanline  ; +3  72 XXXXXX
	nop           ; +2  74 XXXXXX
	nop           ; +2  76 XXXXXX

	;;;;;;;;;;;;;;;;;;;;;; line 1
	sta HMOVE     ; +3  3
	lda scanline  ; +3  6  XXXXXX
	lda scanline  ; +3  9  XXXXXX
	lda scanline  ; +3  12 XXXXXX
	lda scanline  ; +3  15 XXXXXX
	lda scanline  ; +3  18 XXXXXX
	lda scanline  ; +3  21 XXXXXX
	lda scanline  ; +3  24 XXXXXX
	lda scanline  ; +3  27 XXXXXX
	lda scanline  ; +3  30 XXXXXX
	nop           ; +2  32 XXXXXX
	lda ground_col; +3  35
	sta COLUPF    ; +3  38
	lda scanline  ; +3  41 XXXXXX
	lda scanline  ; +3  44 XXXXXX
	lda scanline  ; +3  47 XXXXXX
	lda scanline  ; +3  50 XXXXXX
	lda scanline  ; +3  53 XXXXXX
	lda scanline  ; +3  56 XXXXXX
	nop           ; +2  58 XXXXXX
	nop           ; +2  60 XXXXXX
	lda road_col  ; +3  63
	sta COLUPF    ; +3  66
	lda scanline  ; +3  69 XXXXXX
	lda scanline  ; +3  72 XXXXXX
	nop           ; +2  74 XXXXXX
	nop           ; +2  76 XXXXXX

	;;;;;;;;;;;;;;;;;;;;;; line 2
	sta HMOVE     ; +3  3
	sta WSYNC     ; +3  6...76

	;;;;;;;;;;;;;;;;;;;;;; line 3
	sta HMOVE     ; +3  3
	sta WSYNC     ; +3  6...76

	;;;;;;;;;;;;;;;;;;;;;; line 4
	sta HMOVE     ; +3  3
	sta WSYNC     ; +3  6...76

	;;;;;;;;;;;;;;;;;;;;;; line 5
	sta HMOVE     ; +3  3
	sta WSYNC     ; +3  6...76

	;;;;;;;;;;;;;;;;;;;;;; line 6
	sta HMOVE     ; +3  3
	sta WSYNC     ; +3  6...76

	;;;;;;;;;;;;;;;;;;;;;; line 7
	sta HMOVE     ; +3  3
	dec scanline  ; +5  8
	bne SyncLineLoop  ; +3  11

/* Playfield control by resetting PF0, PF1, PF2

LineLoop:
	sta WSYNC     ; +3  0  Start of line
	sta HMOVE     ; +3  3
	lda #255      ; +2  5  Clear center & right road segment...
	sta PF0       ; +3  8  Clear center road segment by clock 22
	sta PF1       ; +3  11 Clear right road segment by clock 28
	ldx road_seg  ; +3  14 Set road segments...
	lda Road0,X   ; +4  18 Set left road segment by clock 38
	sta PF2       ; +3  21 Set left road segment by clock 38
	lda Road1,X   ; +4  25 Set center road segment clock 28 ... 48
	sta PF0       ; +3  28 Set center road segment clock 28 ... 48
	lda Road2,X   ; +4  32 Set right road segment clock 39 ... 54
	ldy #255      ; +2  34 Clear left road segment clock 50 ... 65
	nop           ; +2  36 XXXXXX

	; latest dispatch for setting RESP0 strobe
	; lda scanline        +3 25
	; cmp next_y_position +3 28
	; bne .skip           +3 31
	; jmp (next_x_step)   +5 36

	sta PF1       ; +3  39 Set right road segment clock 39 ... 54
	;  lda scanline  ; +3  39 XXXXXX strobe RESP0 for position 0 clock 39
	nop           ; +2  41 XXXXXX
	lda scanline  ; +3  44 XXXXXX strobe RESP0 for position 1 clock 44
	nop           ; +2  46 XXXXXX
	lda scanline  ; +3  49 XXXXXX strobe RESP0 for position 2 clock 49
	nop           ; +2  51 XXXXXX
	lda scanline  ; +3  54 XXXXXX strobe RESP0 for position 3 clock 54
	nop           ; +2  56 XXXXXX
	lda scanline  ; +3  59 XXXXXX strobe RESP0 for position 4 clock 59

	sty PF2       ; +3  62 Clear left road segment clock 50 ... 65
	lda scanline  ; +3  65 XXXXXX

	dec scanline  ; +5  70
	bne LineLoop  ; +3  73
*/

/* Playfield color experiment
LineLoop:
	sta WSYNC
	sta HMOVE   ;+3
	lda scanline ;+3
	sta COLUBK  ;+3
	lda #0      ;+2
	sta COLUPF  ;+3
	lda 0       ;+3
	lda 0       ;+3
	lda 0       ;+3
	lda 0       ;+3
	lda 0       ;+3
	nop         ;+2
	nop         ;+2
	lda #80     ;+2
	; clock 35
	sta COLUPF ; Sets playfield color at pixel 46
	; completes at clock 38
	lda #0
	sta HMP0
	dec scanline
	bne LineLoop
*/

	; end of active frame
	sta WSYNC
	jmp FrameLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Data Tables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	org $F400
Road0:
	BYTE  %00000010  ; mirrored

	org $F500
Road1:
	BYTE  %10000000  ; mirrored, upper nybble only

	org $F600
Road2:
	BYTE  %00000010

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Reset and Interrupt vectors
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	org $FFFC
	.word Start
	.word Start

