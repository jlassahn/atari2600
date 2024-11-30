
	processor 6502
	include vcs.h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	SEG.U RAM
	org $80
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
scanline: BYTE -1
road_seg: BYTE -1
road_cnt: BYTE -1
road_lo: BYTE -1
road_hi: BYTE -1
road_col: BYTE -1
ground_col: BYTE -1
p0_pix: BYTE -1
p1_pix: BYTE -1
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
	sta GRP1
	lda #0
	sta HMP0
	sta HMP1
	lda #$FF
	sta COLUP0
	sta COLUP1
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
	lda #0
	sta road_lo
	sta road_hi

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
	lda #$70 ;+2
	sta HMP0 ;+3
	sta HMP1 ;+3
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
	nop
	sta RESP1 ; this puts P1 at pixel 62
	; completes at clock44
	
	; vblank 20
	sta  WSYNC
	sta HMOVE
	lda 0 ;+3
	lda 0 ;+3
	lda 0 ;+3
	lda 0 ;+3
	lda 0 ;+3
	lda 0 ;+3
	lda 0 ;+3
	lda #0
	sta HMP0
	sta HMP1

	sta WSYNC
	; start of active frame (line 21)
	lda  #0       ; +2  2
	sta  VBLANK   ; +3  5
	ldy #30       ; +2  7
	sty scanline  ; +3  10
	lda road_hi   ; +3  13
	sta road_seg  ; +3  16
	lda road_lo   ; +3  19
	rol           ; +2  21
	rol           ; +2  23
	rol           ; +2  25
	and #3        ; +2  27
	eor #3        ; +2  29
	sta road_cnt  ; +3  32
	clc           ; +2  34
	lda road_lo   ; +3  37
	adc #$F0      ; +2  39
	sta road_lo   ; +3  42
	lda road_hi   ; +3  45
	adc #$FF      ; +2  47
	sta road_hi   ; +3  50
	lda #0        ; +2  52
	sta p0_pix    ; +3  55
	sta p1_pix    ; +3  58

/* Playfield control by masking foreground color */
LineLoop:
	sta WSYNC
	;;;;;;;;;;;;;;;;;;;;;; line 0  (Draw P1, Write Playfield)
	SUBROUTINE
	sta HMOVE     ; +3  3
	ldx p1_pix    ; +3  6
	lda SpritePix,X ; +4 10
	sta GRP1      ; +3  13
	beq .skip_p1  ; +2/+3 15
	lda SpriteCol,X ; +4 19
	sta COLUP1    ; +3 22
	inc p1_pix    ; +5 27
	jmp .p1_done  ; +3 30
.skip_p1            ; 16
	lda scanline    ; +3  19 XXXXXX
	lda scanline    ; +3  22 XXXXXX
	lda scanline    ; +3  25 XXXXXX
	lda scanline    ; +3  28 XXXXXX
	nop             ; +2  30 XXXXXX
.p1_done:
	nop           ; +2  32 XXXXXX
	lda ground_col; +3  35
	sta COLUPF    ; +3  38 Start of active playfield

	ldx road_seg  ; +3  41 Road pattern update...
	lda Road0,X   ; +4  45 ...
	sta PF2       ; +3  48 ...
	lda Road1,X   ; +4  52 ...
	sta PF0       ; +3  55 ...
	lda scanline  ; +3  58 XXXXXX
	nop           ; +2  60 XXXXXX
	lda road_col  ; +3  63
	sta COLUPF    ; +3  66 End of active playfield
	lda Road2,X   ; +4  70 ...
	sta PF1       ; +3  73 ...
	lda scanline  ; +3  76 XXXXXX

	;;;;;;;;;;;;;;;;;;;;;; line 1  (Draw P0, NOOP)
	SUBROUTINE
	sta HMOVE     ; +3  3
	ldx p0_pix    ; +3  6
	lda SpritePix,X ; +4 10
	sta GRP0      ; +3  13
	beq .skip_p0  ; +2/+3 15
	lda SpriteCol,X ; +4 19
	sta COLUP0    ; +3 22
	inc p0_pix    ; +5 27
	jmp .p0_done  ; +3 30
.skip_p0            ; 16
	lda scanline    ; +3  19 XXXXXX
	lda scanline    ; +3  22 XXXXXX
	lda scanline    ; +3  25 XXXXXX
	lda scanline    ; +3  28 XXXXXX
	nop             ; +2  30 XXXXXX
.p0_done:
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

	;;;;;;;;;;;;;;;;;;;;;; line 2  (Draw P1, NOOP)
	SUBROUTINE
	sta HMOVE     ; +3  3
	ldx p1_pix    ; +3  6
	lda SpritePix,X ; +4 10
	sta GRP1      ; +3  13
	beq .skip_p1  ; +2/+3 15
	lda SpriteCol,X ; +4 19
	sta COLUP1    ; +3 22
	inc p1_pix    ; +5 27
	jmp .p1_done  ; +3 30
.skip_p1            ; 16
	lda scanline    ; +3  19 XXXXXX
	lda scanline    ; +3  22 XXXXXX
	lda scanline    ; +3  25 XXXXXX
	lda scanline    ; +3  28 XXXXXX
	nop             ; +2  30 XXXXXX
.p1_done:
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

	;;;;;;;;;;;;;;;;;;;;;; line 3  (Draw P0, Plan Player)
	SUBROUTINE
	sta HMOVE     ; +3  3
	ldx p0_pix    ; +3  6
	lda SpritePix,X ; +4 10
	sta GRP0      ; +3  13
	beq .skip_p0  ; +2/+3 15
	lda SpriteCol,X ; +4 19
	sta COLUP0    ; +3 22
	inc p0_pix    ; +5 27
	jmp .p0_done  ; +3 30
.skip_p0            ; 16
	lda scanline    ; +3  19 XXXXXX
	lda scanline    ; +3  22 XXXXXX
	lda scanline    ; +3  25 XXXXXX
	lda scanline    ; +3  28 XXXXXX
	nop             ; +2  30 XXXXXX
.p0_done:
	nop           ; +2  32 XXXXXX
	lda ground_col; +3  35
	sta COLUPF    ; +3  38
	lda scanline  ; +3  41 Check player position...
	cmp #10       ; +2  43 ...
	bne .p1_nomatch ; +2/+3 45
	lda #1          ; +2  47
	sta p1_pix      ; +3  50
	jmp .p1_done    ; +3  53
.p1_nomatch: ; 46
	lda scanline    ; +3  49 XXXXXX
	nop             ; +2  51 XXXXXX
	nop             ; +2  53 XXXXXX
.p1_done:
	lda scanline  ; +3  56 XXXXXX
	nop           ; +2  58 XXXXXX
	nop           ; +2  60 XXXXXX
	lda road_col  ; +3  63
	sta COLUPF    ; +3  66
	lda scanline  ; +3  69 XXXXXX
	lda scanline  ; +3  72 XXXXXX
	nop           ; +2  74 XXXXXX
	nop           ; +2  76 XXXXXX

	;;;;;;;;;;;;;;;;;;;;;; line 4  (Draw P1, FAKE Plan P0)
	SUBROUTINE
	sta HMOVE     ; +3  3
	ldx p1_pix    ; +3  6
	lda SpritePix,X ; +4 10
	sta GRP1      ; +3  13
	beq .skip_p1  ; +2/+3 15
	lda SpriteCol,X ; +4 19
	sta COLUP1    ; +3 22
	inc p1_pix    ; +5 27
	jmp .p1_done  ; +3 30
.skip_p1            ; 16
	lda scanline    ; +3  19 XXXXXX
	lda scanline    ; +3  22 XXXXXX
	lda scanline    ; +3  25 XXXXXX
	lda scanline    ; +3  28 XXXXXX
	nop             ; +2  30 XXXXXX
.p1_done:
	nop           ; +2  32 XXXXXX
	lda ground_col; +3  35
	sta COLUPF    ; +3  38
	lda scanline  ; +3  41 FAKE check opponent position...
	cmp #28       ; +2  43 ...
	bne .p0_nomatch ; +2/+3 45
	lda #18         ; +2  47   FAKE choose different sprite
	sta p0_pix      ; +3  50
	jmp .p0_done    ; +3  53
.p0_nomatch: ; 46
	lda scanline    ; +3  49 XXXXXX
	nop             ; +2  51 XXXXXX
	nop             ; +2  53 XXXXXX
.p0_done:
	lda scanline  ; +3  56 XXXXXX
	nop           ; +2  58 XXXXXX
	nop           ; +2  60 XXXXXX
	lda road_col  ; +3  63
	sta COLUPF    ; +3  66
	lda scanline  ; +3  69 XXXXXX
	lda scanline  ; +3  72 XXXXXX
	nop           ; +2  74 XXXXXX
	nop           ; +2  76 XXXXXX

	;;;;;;;;;;;;;;;;;;;;;; line 5  (Draw P0, NOOP)
	SUBROUTINE
	sta HMOVE     ; +3  3
	ldx p0_pix    ; +3  6
	lda SpritePix,X ; +4 10
	sta GRP0      ; +3  13
	beq .skip_p0  ; +2/+3 15
	lda SpriteCol,X ; +4 19
	sta COLUP0    ; +3 22
	inc p0_pix    ; +5 27
	jmp .p0_done  ; +3 30
.skip_p0            ; 16
	lda scanline    ; +3  19 XXXXXX
	lda scanline    ; +3  22 XXXXXX
	lda scanline    ; +3  25 XXXXXX
	lda scanline    ; +3  28 XXXXXX
	nop             ; +2  30 XXXXXX
.p0_done:
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

	;;;;;;;;;;;;;;;;;;;;;; line 6  (Draw P1, NOOP)
	SUBROUTINE
	sta HMOVE     ; +3  3
	ldx p1_pix    ; +3  6
	lda SpritePix,X ; +4 10
	sta GRP1      ; +3  13
	beq .skip_p1  ; +2/+3 15
	lda SpriteCol,X ; +4 19
	sta COLUP1    ; +3 22
	inc p1_pix    ; +5 27
	jmp .p1_done  ; +3 30
.skip_p1            ; 16
	lda scanline    ; +3  19 XXXXXX
	lda scanline    ; +3  22 XXXXXX
	lda scanline    ; +3  25 XXXXXX
	lda scanline    ; +3  28 XXXXXX
	nop             ; +2  30 XXXXXX
.p1_done:
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

	;;;;;;;;;;;;;;;;;;;;;; line 7  (Draw P0, Road state update)
	SUBROUTINE
	sta HMOVE     ; +3  3
	ldx p0_pix    ; +3  6
	lda SpritePix,X ; +4 10
	sta GRP0      ; +3  13
	beq .skip_p0  ; +2/+3 15
	lda SpriteCol,X ; +4 19
	sta COLUP0    ; +3 22
	inc p0_pix    ; +5 27
	jmp .p0_done  ; +3 30
.skip_p0            ; 16
	lda scanline    ; +3  19 XXXXXX
	lda scanline    ; +3  22 XXXXXX
	lda scanline    ; +3  25 XXXXXX
	lda scanline    ; +3  28 XXXXXX
	nop             ; +2  30 XXXXXX
.p0_done:
	nop           ; +2  32 XXXXXX
	lda ground_col; +3  35
	sta COLUPF    ; +3  38 Start of active playfield
	dec road_cnt  ; +5  43 Road state update...
	bpl .no_road_update ; +2 45 ...
	lda #3              ; +2 47 ...
	sta road_cnt        ; +3 50 ...
	inc road_seg        ; +5 55 ...
.road_update_end:
	lda road_col  ; +3  58
	dec scanline  ; +5  63
	sta COLUPF    ; +3  66 End of active playfield
	beq LineLoopEnd ; +3  69
	jmp LineLoop  ; +3 72
LineLoopEnd:
	; end of active frame
	sta WSYNC
	jmp FrameLoop

.no_road_update:         ;     46
	nop                  ; +2  48 XXXXXX
	nop                  ; +2  50 XXXXXX
	nop                  ; +2  52 XXXXXX
	jmp .road_update_end ; +3  55

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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Data Tables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	org $F400
Road0:
	BYTE  %00000000  ; mirrored
	BYTE  %00000001  ; mirrored
	BYTE  %00000011  ; mirrored
	BYTE  %00000111  ; mirrored
	BYTE  %00001111  ; mirrored
	BYTE  %00011111  ; mirrored
	BYTE  %00111111  ; mirrored
	BYTE  %01111111  ; mirrored
	BYTE  %11111111  ; mirrored

	org $F500
Road1:
	BYTE  %10000000  ; mirrored, upper nybble only
	BYTE  %10000000  ; mirrored, upper nybble only
	BYTE  %10000000  ; mirrored, upper nybble only
	BYTE  %10000000  ; mirrored, upper nybble only
	BYTE  %10000000  ; mirrored, upper nybble only
	BYTE  %10000000  ; mirrored, upper nybble only
	BYTE  %10000000  ; mirrored, upper nybble only
	BYTE  %10000000  ; mirrored, upper nybble only
	BYTE  %10000000  ; mirrored, upper nybble only

	org $F600
Road2:
	BYTE  %00000010
	BYTE  %00000010
	BYTE  %00000010
	BYTE  %00000010
	BYTE  %00000010
	BYTE  %00000010
	BYTE  %00000010
	BYTE  %00000010
	BYTE  %00000010

; FIXME need a better way to generate symbols for sprite offsets
	org $F700
SpritePix:
	BYTE 0
	BYTE %01111110
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11000011
	BYTE %10000001
	BYTE %10111101
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11000011
	BYTE %11011011
	BYTE %11011011
	BYTE %01011010
	BYTE %01111110
	BYTE %01000010
	BYTE 0
	BYTE %11011011
	BYTE %11111111
	BYTE %11100111
	BYTE %11111111
	BYTE %10000001
	BYTE %00111100
	BYTE %01111110
	BYTE %01111110
	BYTE %00111100
	BYTE %10000001
	BYTE %11100111
	BYTE %11111111
	BYTE %01111110
	BYTE %11011011
	BYTE %11111111 ;;;;;;;;
	BYTE %01111110
	BYTE %01111110
	BYTE %01111110
	BYTE %01111110
	BYTE %01111110
	BYTE %01000010
	BYTE %00011000
	BYTE %01111110
	BYTE %01111110
	BYTE %01000010
	BYTE %01111110
	BYTE %01111110
	BYTE %01111110
	BYTE %01100110
	BYTE %11111111 ;;;;;;;;

	org $F800
SpriteCol:
	BYTE 0
	BYTE $0F
	BYTE $0F
	BYTE $0F
	BYTE $0F
	BYTE $0F
	BYTE $0F
	BYTE $0F
	BYTE $0F
	BYTE $0F
	BYTE $0F
	BYTE $0F
	BYTE $0F
	BYTE $0F
	BYTE $0F
	BYTE $0F
	BYTE $44
	BYTE 0
	BYTE $70
	BYTE $72
	BYTE $72
	BYTE $72
	BYTE $72
	BYTE $92
	BYTE $92
	BYTE $92
	BYTE $92
	BYTE $72
	BYTE $72
	BYTE $72
	BYTE $72
	BYTE $04
	BYTE 0
	BYTE $92
	BYTE $92
	BYTE $92
	BYTE $92
	BYTE $92
	BYTE $92
	BYTE $72
	BYTE $72
	BYTE $72
	BYTE $72
	BYTE $92
	BYTE $92
	BYTE $92
	BYTE $94
	BYTE 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Reset and Interrupt vectors
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	org $FFFC
	.word Start
	.word Start

