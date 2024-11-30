
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
	lda #$D2
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
	;; lda #$70 ;+2
	lda #$00 ;+2
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
	lda #0             ; +2  2
	sta VBLANK         ; +3  5
	ldy #30            ; +2  7
	sty scanline       ; +3  10
	lda road_hi        ; +3  13
	sta road_seg       ; +3  16
	lda road_lo        ; +3  19
	rol                ; +2  21
	rol                ; +2  23
	rol                ; +2  25
	and #3             ; +2  27
	eor #3             ; +2  29
	sta road_cnt       ; +3  32
	clc                ; +2  34
	lda road_lo        ; +3  37
	adc #$F0           ; +2  39
	sta road_lo        ; +3  42
	lda road_hi        ; +3  45
	adc #$FF           ; +2  47
	sta road_hi        ; +3  50
	lda #0             ; +2  52
	sta p0_pix         ; +3  55
	sta p1_pix         ; +3  58
	jmp LineLoop

; The main display code is a loop that runs in batches of eight scanlines
; These are divided into two groups of four, with each group aligned to
; be inside it's own ROM page.  This guarantees that local branches in a
; scanline don't cross page boundaries.
; Scanline code is exactly 76 clocks per line, so no WSYNC is needed between
; lines, except at the beginning of the loop.

	ALIGN 256, $FF
LineLoop:
	sta WSYNC
	;;;;;;;;;;;;;;;;;;;;;; line 0  (Draw P1, Write Playfield)
	SUBROUTINE
	sta HMOVE          ; +3  3
	ldx p1_pix         ; +3  6
	lda SpritePix,X    ; +4 10
	sta GRP1           ; +3  13
	beq .skip_p1       ; A +2 15 / B +3
	lda SpriteCol,X    ; A +4 19
	sta COLUP1         ; A +3 22
	inc p1_pix         ; A +5 27
	jmp .p1_done       ; A +3 30
.skip_p1               ; B +3  16
	lda scanline       ; B +3  19 XXXXXX
	lda scanline       ; B +3  22 XXXXXX
	lda scanline       ; B +3  25 XXXXXX
	lda scanline       ; B +3  28 XXXXXX
	nop                ; B +2  30 XXXXXX
.p1_done:
	nop                ; +2  32 XXXXXX
	lda ground_col     ; +3  35
	sta COLUPF         ; +3  38 Start of active playfield

	ldx road_seg       ; +3  41 Road pattern update...
	lda Road0,X        ; +4  45 ...
	sta PF2            ; +3  48 ...
	lda Road1,X        ; +4  52 ...
	sta PF0            ; +3  55 ...
	lda scanline       ; +3  58 XXXXXX
	nop                ; +2  60 XXXXXX
	lda road_col       ; +3  63
	sta COLUPF         ; +3  66 End of active playfield
	lda Road2,X        ; +4  70 ...
	sta PF1            ; +3  73 ...
	lda scanline       ; +3  76 XXXXXX

	;;;;;;;;;;;;;;;;;;;;;; line 1  (Draw P0, NOOP)
	SUBROUTINE
	sta HMOVE          ; +3  3
	ldx p0_pix         ; +3  6
	lda SpritePix,X    ; +4  10
	sta GRP0           ; +3  13
	beq .skip_p0       ; A +2 15 / B +3
	lda SpriteCol,X    ; A +4 19
	sta COLUP0         ; A +3 22
	inc p0_pix         ; A +5 27
	jmp .p0_done       ; A +3 30
.skip_p0               ; B +3 16
	lda scanline       ; B +3  19 XXXXXX
	lda scanline       ; B +3  22 XXXXXX
	lda scanline       ; B +3  25 XXXXXX
	lda scanline       ; B +3  28 XXXXXX
	nop                ; B +2  30 XXXXXX
.p0_done:
	nop                ; +2  32 XXXXXX
	lda ground_col     ; +3  35
	sta COLUPF         ; +3  38
	lda scanline       ; +3  41 XXXXXX
	lda scanline       ; +3  44 XXXXXX
	lda scanline       ; +3  47 XXXXXX
	lda scanline       ; +3  50 XXXXXX
	lda scanline       ; +3  53 XXXXXX
	lda scanline       ; +3  56 XXXXXX
	nop                ; +2  58 XXXXXX
	nop                ; +2  60 XXXXXX
	lda road_col       ; +3  63
	sta COLUPF         ; +3  66
	lda scanline       ; +3  69 XXXXXX
	lda scanline       ; +3  72 XXXXXX
	nop                ; +2  74 XXXXXX
	nop                ; +2  76 XXXXXX

	;;;;;;;;;;;;;;;;;;;;;; line 2  (Draw P1, NOOP)
	SUBROUTINE
	sta HMOVE          ; +3  3
	ldx p1_pix         ; +3  6
	lda SpritePix,X    ; +4 10
	sta GRP1           ; +3  13
	beq .skip_p1       ; +2/+3 15
	lda SpriteCol,X    ; +4 19
	sta COLUP1         ; +3 22
	inc p1_pix         ; +5 27
	jmp .p1_done       ; +3 30
.skip_p1               ; 16
	lda scanline       ; +3  19 XXXXXX
	lda scanline       ; +3  22 XXXXXX
	lda scanline       ; +3  25 XXXXXX
	lda scanline       ; +3  28 XXXXXX
	nop                ; +2  30 XXXXXX
.p1_done:
	nop                ; +2  32 XXXXXX
	lda ground_col     ; +3  35
	sta COLUPF         ; +3  38
	lda scanline       ; +3  41 XXXXXX
	lda scanline       ; +3  44 XXXXXX
	lda scanline       ; +3  47 XXXXXX
	lda scanline       ; +3  50 XXXXXX
	lda scanline       ; +3  53 XXXXXX
	lda scanline       ; +3  56 XXXXXX
	nop                ; +2  58 XXXXXX
	nop                ; +2  60 XXXXXX
	lda road_col       ; +3  63
	sta COLUPF         ; +3  66
	lda scanline       ; +3  69 XXXXXX
	lda scanline       ; +3  72 XXXXXX
	nop                ; +2  74 XXXXXX
	nop                ; +2  76 XXXXXX

	;;;;;;;;;;;;;;;;;;;;;; line 3  (Draw P0, Plan Player)
	SUBROUTINE
	sta HMOVE          ; +3  3
	ldx p0_pix         ; +3  6
	lda SpritePix,X    ; +4 10
	sta GRP0           ; +3  13
	beq .skip_p0       ; +2/+3 15
	lda SpriteCol,X    ; +4 19
	sta COLUP0         ; +3 22
	inc p0_pix         ; +5 27
	jmp .p0_done       ; +3 30
.skip_p0               ; 16
	lda scanline       ; +3  19 XXXXXX
	lda scanline       ; +3  22 XXXXXX
	lda scanline       ; +3  25 XXXXXX
	lda scanline       ; +3  28 XXXXXX
	nop                ; +2  30 XXXXXX
.p0_done:
	nop                ; +2  32 XXXXXX
	lda ground_col     ; +3  35
	sta COLUPF         ; +3  38
	lda scanline       ; +3  41 Check player position...
	cmp #10            ; +2  43 ...
	bne .p1_nomatch    ; +2/+3 45
	lda #1             ; +2  47
	sta p1_pix         ; +3  50
	jmp .p1_done       ; +3  53
.p1_nomatch: ; 46
	lda scanline       ; +3  49 XXXXXX
	nop                ; +2  51 XXXXXX
	nop                ; +2  53 XXXXXX
.p1_done:
	lda scanline       ; +3  56 XXXXXX
	nop                ; +2  58 XXXXXX
	nop                ; +2  60 XXXXXX
	lda road_col       ; +3  63
	sta COLUPF         ; +3  66
	lda scanline       ; +3  69 XXXXXX
	nop                ; +2  71 XXXXXX
	nop                ; +2  73 XXXXXX
	jmp Line4          ; +3  76

	ALIGN 256, $FF
Line4:
	;;;;;;;;;;;;;;;;;;;;;; line 4  (Draw P1, FAKE Plan P0)
	SUBROUTINE
	sta HMOVE          ; +3  3
	ldx p1_pix         ; +3  6
	lda SpritePix,X    ; +4 10
	sta GRP1           ; +3  13
	beq .skip_p1       ; +2/+3 15
	lda SpriteCol,X    ; +4 19
	sta COLUP1         ; +3 22
	inc p1_pix         ; +5 27
	jmp .p1_done       ; +3 30
.skip_p1               ; 16
	lda scanline       ; +3  19 XXXXXX
	lda scanline       ; +3  22 XXXXXX
	lda scanline       ; +3  25 XXXXXX
	lda scanline       ; +3  28 XXXXXX
	nop                ; +2  30 XXXXXX
.p1_done:
	nop                ; +2  32 XXXXXX
	lda ground_col     ; +3  35
	sta COLUPF         ; +3  38
	lda scanline       ; +3  41 FAKE check opponent position...
	cmp #28            ; +2  43 ...
	bne .p0_nomatch    ; +2/+3 45
	lda #18            ; +2  47   FAKE choose different sprite
	sta p0_pix         ; +3  50
	jmp .p0_done       ; +3  53
.p0_nomatch:           ; 46
	lda scanline       ; +3  49 XXXXXX
	nop                ; +2  51 XXXXXX
	nop                ; +2  53 XXXXXX
.p0_done:
	lda scanline       ; +3  56 XXXXXX
	nop                ; +2  58 XXXXXX
	nop                ; +2  60 XXXXXX
	lda road_col       ; +3  63
	sta COLUPF         ; +3  66
	lda scanline       ; +3  69 XXXXXX
	lda scanline       ; +3  72 XXXXXX
	nop                ; +2  74 XXXXXX
	nop                ; +2  76 XXXXXX

	;;;;;;;;;;;;;;;;;;;;;; line 5  (Draw P0, NOOP)
	SUBROUTINE
	sta HMOVE          ; +3  3
	ldx p0_pix         ; +3  6
	lda SpritePix,X    ; +4 10
	sta GRP0           ; +3  13
	beq .skip_p0       ; +2/+3 15
	lda SpriteCol,X    ; +4 19
	sta COLUP0         ; +3 22
	inc p0_pix         ; +5 27
	jmp .p0_done       ; +3 30
.skip_p0               ; 16
	lda scanline       ; +3  19 XXXXXX
	lda scanline       ; +3  22 XXXXXX
	lda scanline       ; +3  25 XXXXXX
	lda scanline       ; +3  28 XXXXXX
	nop                ; +2  30 XXXXXX
.p0_done:
	nop                ; +2  32 XXXXXX
	lda ground_col     ; +3  35
	sta COLUPF         ; +3  38
	lda scanline       ; +3  41 XXXXXX
	lda scanline       ; +3  44 XXXXXX
	lda scanline       ; +3  47 XXXXXX
	lda scanline       ; +3  50 XXXXXX
	lda scanline       ; +3  53 XXXXXX
	lda scanline       ; +3  56 XXXXXX
	nop                ; +2  58 XXXXXX
	nop                ; +2  60 XXXXXX
	lda road_col       ; +3  63
	sta COLUPF         ; +3  66
	lda scanline       ; +3  69 XXXXXX
	lda scanline       ; +3  72 XXXXXX
	nop                ; +2  74 XXXXXX
	nop                ; +2  76 XXXXXX

	;;;;;;;;;;;;;;;;;;;;;; line 6  (Draw P1, NOOP)
	SUBROUTINE
	sta HMOVE          ; +3  3
	ldx p1_pix         ; +3  6
	lda SpritePix,X    ; +4 10
	sta GRP1           ; +3  13
	beq .skip_p1       ; +2/+3 15
	lda SpriteCol,X    ; +4 19
	sta COLUP1         ; +3 22
	inc p1_pix         ; +5 27
	jmp .p1_done       ; +3 30
.skip_p1               ; 16
	lda scanline       ; +3  19 XXXXXX
	lda scanline       ; +3  22 XXXXXX
	lda scanline       ; +3  25 XXXXXX
	lda scanline       ; +3  28 XXXXXX
	nop                ; +2  30 XXXXXX
.p1_done:
	nop                ; +2  32 XXXXXX
	lda ground_col     ; +3  35
	sta COLUPF         ; +3  38
	lda scanline       ; +3  41 XXXXXX
	lda scanline       ; +3  44 XXXXXX
	lda scanline       ; +3  47 XXXXXX
	lda scanline       ; +3  50 XXXXXX
	lda scanline       ; +3  53 XXXXXX
	lda scanline       ; +3  56 XXXXXX
	nop                ; +2  58 XXXXXX
	nop                ; +2  60 XXXXXX
	lda road_col       ; +3  63
	sta COLUPF         ; +3  66
	lda scanline       ; +3  69 XXXXXX
	lda scanline       ; +3  72 XXXXXX
	nop                ; +2  74 XXXXXX
	nop                ; +2  76 XXXXXX

	;;;;;;;;;;;;;;;;;;;;;; line 7  (Draw P0, Road state update)
	SUBROUTINE
	sta HMOVE          ; +3  3
	ldx p0_pix         ; +3  6
	lda SpritePix,X    ; +4 10
	sta GRP0           ; +3  13
	beq .skip_p0       ; +2/+3 15
	lda SpriteCol,X    ; +4 19
	sta COLUP0         ; +3 22
	inc p0_pix         ; +5 27
	jmp .p0_done       ; +3 30
.skip_p0               ; 16
	lda scanline       ; +3  19 XXXXXX
	lda scanline       ; +3  22 XXXXXX
	lda scanline       ; +3  25 XXXXXX
	lda scanline       ; +3  28 XXXXXX
	nop                ; +2  30 XXXXXX
.p0_done:
	nop                ; +2  32 XXXXXX
	lda ground_col     ; +3  35
	sta COLUPF         ; +3  38 Start of active playfield
	dec road_cnt       ; +5  43 Road state update...
	bpl .no_road_update ; +2 45 ...
	lda #3             ; +2 47 ...
	sta road_cnt       ; +3 50 ...
	inc road_seg       ; +5 55 ...
.road_update_end:
	lda road_col       ; +3  58
	dec scanline       ; +5  63
	sta COLUPF         ; +3  66 End of active playfield
	beq LineLoopEnd    ; +3  69
	jmp LineLoop       ; +3  72
LineLoopEnd:
	; end of active frame
	sta WSYNC
	jmp FrameLoop

.no_road_update:         ;     46
	nop                  ; +2  48 XXXXXX
	nop                  ; +2  50 XXXXXX
	nop                  ; +2  52 XXXXXX
	jmp .road_update_end ; +3  55

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Data Tables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include car_road.asm
	include car_sprites.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Reset and Interrupt vectors
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	org $FFFC
	.word Start
	.word Start

