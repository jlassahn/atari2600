
	processor 6502
	include vcs.h

	MACRO DrawP1       ; +22 TOTAL
	ldx p1_pix         ; +3  3
	lda SpritePix,X    ; +4  7
	sta GRP1           ; +3  10
	lda SpriteCol,X    ; +4  14
	sta COLUP1         ; +3  17
	inc p1_pix         ; +5  22
	ENDM

	MACRO DrawP0       ; +27 TOTAL
	ldx p0_pix         ; +3  3
	lda SpritePix,X    ; +4  7
	sta GRP0           ; +3  10
	lda SpriteCol,X    ; +4  14
	sta COLUP0         ; +3  17
	beq .skip_p0       ; A +2 19 / B +3 20
	inc p0_pix         ; A +5 24
	jmp .p0_done       ; A +3 27
.skip_p0               ; B +3 20
	lda 0              ; B +3 23 XXXXXX
	nop                ; B +2 25 XXXXXX
	nop                ; B +2 27 XXXXXX
.p0_done:
	ENDM

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
p0_x: BYTE -1
p1_x: BYTE -1
vol: BYTE -1
opp_line: BYTE -1
opp_pix: BYTE -1
player_seg: BYTE -1
player_move: ds.b 15
player_pix: ds.b 15
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

	lda #$02
	sta COLUBK
	sta road_col
	lda #$D2
	sta ground_col

	lda #0
	sta road_lo
	sta road_hi

	; set up player graphics
	; index 1 through go from bottom to top of the screen.
	; index 0 wraps around to the very top and should always contain
	; zeros.

	; player car image gets initialized here.
	lda #PixPlayerLo
	sta player_pix+4 ; player
	lda #PixPlayerHi
	sta player_pix+5 ; player

	; FAKE smoke screen and bullet images
	lda #PixSmoke2
	sta player_pix+1 ; smoke
	sta player_pix+2 ; smoke
	lda #PixSmoke1
	sta player_pix+3 ; smoke
	lda #PixBullet1
	sta player_pix+6 ; bullet
	lda #PixBullet2
	sta player_pix+7 ; bullet
	sta player_pix+8 ; bullet

	; The move and size values for smoke are always the same so initialize
	; them here.
	lda #$07
	sta player_move+1 ; smoke
	lda #$67
	sta player_move+2 ; smoke
	lda #$77
	sta player_move+3 ; smoke

	; FAKE initial values for player and opponent positions
	lda #12
	sta opp_line
	lda #PixCar1
	sta opp_pix
	lda #0
	sta p0_x
	sta p1_x

	; Frequency tables at:
	; https://7800.8bitdev.org/index.php/Atari_2600_VCS_Sound_Frequency_and_Waveform_Guide
	; lda #1 ; buzzy, but good note (div 15)
	; lda #2 ; beating buzz, at low frequency migth be a good gravel sound
	; lda #3 ; noisy but somwhat pitched, buzzy discordant note.
	; lda #4 ; pure tone high (div 2)  C5
	; lda #5 ; same as #4
	; lda #6 ; pure tone very low (div 31)
	; lda #7 ; buzzy tone, rougher than #1?
	; lda #8 ; noise, some pitch and buzz at higher frequencies
	; lda #9 ;  buzzy tone, similar to 7
	; lda #10 ; pure tone  same as #6
	; lda #11 ; no sound
	; lda #12 ; pure tone (div 6)   F3
	; lda #13 ; same as #12
	; lda #14 ; very low pitch (div 93)
	; lda #15 ; buzzy tone low
	; sta AUDC0
	; lda #2
	; sta AUDV0
	; lda #23; A #19; C  #16; Eb #29;  F
	; sta AUDF0

FrameLoop: SUBROUTINE
	; vblank 1
	sta  WSYNC
	lda  #2
	sta  VBLANK

	; FAKE read inputs
	; lda INPT4 ; LEFT joy button, $80 means not pressed, $00 means pressed
	; lda INPT5 ; RIGHT joy button, $80 means not pressed, $00 means pressed
	lda SWCHA
	rol
	bcs .no_right
	inc p1_x  ; 1 pixel per frame sideways is a good max turn rate
.no_right:
	rol
	bcs .no_left
	dec p1_x
.no_left:
	rol
	bcs .no_down

.no_down:
	rol
	bcs .no_up

.no_up:
	nop


	; vblank 2
	sta  WSYNC

	; FAKE audio processing
	lda vol
	clc
	adc #-8
	and #127
	sta vol
	lsr
	lsr
	lsr
	lsr
	; sta AUDV0

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

	; Lines 18 and 19 strobe RESPx for player and opponent X positions...
	; some ideas here borrowed from
	; https://bumbershootsoft.wordpress.com/2018/08/30/an-arbitrary-sprite-positioning-routine-for-the-atari-2600/
	; x == 0 --> strobe at clock 37 --> left edge at pixel 48

	; vblank 18  (strobe P1 which is opponent)
	sta  WSYNC
	lda p1_x           ; +3  3
	clc                ; +2  5
	adc #6             ; +2  7  Offset to zero out position
	sec                ; +2  9
	nop                ; +2  11 XXXXXX
	nop                ; +2  13 XXXXXX
	nop                ; +2  15 XXXXXX
	nop                ; +2  17 XXXXXX
p1_strobe_loop:
	sbc #15            ; +2  19 + N*5   0 <= N <= 4
	bcs p1_strobe_loop ; +2  21 + N*5
	eor #7             ; +2  23 + N*5   A = (-A - 1) + 8
	asl                ; +2  25 + N*5
	asl                ; +2  27 + N*5
	asl                ; +2  29 + N*5
	asl                ; +2  31 + N*5
	sta HMP1           ; +3  34 + N*5
	sta RESP1          ; +3  37 + N*5 <= 57

	; vblank 19  (strobe P0 which is player)
	sta  WSYNC
	lda p0_x           ; +3  3
	clc                ; +2  5
	adc #6             ; +2  7  Offset to zero out position
	sec                ; +2  9
	nop                ; +2  11 XXXXXX
	nop                ; +2  13 XXXXXX
	nop                ; +2  15 XXXXXX
	nop                ; +2  17 XXXXXX
p0_strobe_loop:
	sbc #15            ; +2  19 + N*5   0 <= N <= 4
	bcs p0_strobe_loop ; +2  21 + N*5
	eor #7             ; +2  23 + N*5   A = (-A - 1) + 8
	asl                ; +2  25 + N*5
	asl                ; +2  27 + N*5
	asl                ; +2  29 + N*5
	asl                ; +2  31 + N*5
	sta HMP0           ; +3  34 + N*5
	sta RESP0          ; +3  37 + N*5 <= 57

	; FAKE move player 0 around
	lda p0_x           ; <= 60
	clc                ; <= 62
	adc #1             ; <= 64
	and #63            ; <= 66
	sta p0_x           ; <= 69

	; vblank 20
	sta  WSYNC
	sta HMOVE          ; +3  3
	nop                ; +2  5  XXXXXX
	nop                ; +2  7  XXXXXX
	nop                ; +2  9  XXXXXX
	nop                ; +2  11 XXXXXX
	nop                ; +2  13 XXXXXX
	nop                ; +2  15 XXXXXX
	nop                ; +2  17 XXXXXX
	nop                ; +2  19 XXXXXX
	nop                ; +2  21 XXXXXX
	lda 0              ; +3  24 XXXXXX
	lda #0             ; +2  28
	sta HMP0           ; +3  31
	sta HMP1           ; +3  34

	sta WSYNC
	; start of active frame (line 21)
	lda #0             ; +2  2
	sta VBLANK         ; +3  5
	ldy #30            ; +2  7
	sty scanline       ; +3  10
	lda road_hi        ; +3  13
	sta road_seg       ; +3  16
	lda road_lo        ; +3  19  Extract high two bits of road_lo
	rol                ; +2  21  ...
	rol                ; +2  23  ...
	rol                ; +2  25  ...
	and #3             ; +2  27  ...
	eor #3             ; +2  29  and negate
	sta road_cnt       ; +3  32
	clc                ; +2  34
	lda road_lo        ; +3  37
	adc #$D0           ; +2  39 Speed $FFFC is very slow $FFD0 is pretty fast
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
	DrawP1             ; +22 25
	lda 0              ; +3  28 XXXXXX
	nop                ; +2  30 XXXXXX
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
	DrawP0             ; +27 30
	nop                ; +2  32 XXXXXX
	lda ground_col     ; +3  35
	sta COLUPF         ; +3  38
	nop                ; +2  40 XXXXXX
	nop                ; +2  42 XXXXXX
	nop                ; +2  44 XXXXXX
	nop                ; +2  46 XXXXXX
	nop                ; +2  48 XXXXXX
	nop                ; +2  50 XXXXXX
	nop                ; +2  52 XXXXXX
	nop                ; +2  54 XXXXXX
	nop                ; +2  56 XXXXXX
	nop                ; +2  58 XXXXXX
	nop                ; +2  60 XXXXXX
	lda road_col       ; +3  63
	sta COLUPF         ; +3  66
	nop                ; +2  68 XXXXXX
	nop                ; +2  70 XXXXXX
	nop                ; +2  72 XXXXXX
	nop                ; +2  74 XXXXXX
	nop                ; +2  76 XXXXXX

	;;;;;;;;;;;;;;;;;;;;;; line 2  (Draw P1, NOOP)
	SUBROUTINE
	sta HMOVE          ; +3  3
	DrawP1             ; +22 25
	lda 0              ; +3  28 XXXXXX
	nop                ; +2  30 XXXXXX
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
	DrawP0             ; +27 30
	lda #1             ; +2  32
	ldx ground_col     ; +3  35
	stx COLUPF         ; +3  38
	ldx player_seg     ; +3  41
	bit scanline       ; +3  44
	bne .player_skip   ; A +2 46 /B +3 47
	ldy player_move,X  ; A +4 50
	sty HMP1           ; A +3 53
	lda player_pix,X   ; A +4 57
	sta p1_pix         ; A +4 60
	lda road_col       ; A +3 63
	sta COLUPF         ; A +3 66
	sty NUSIZ1         ; A +3 69
	nop                ; A +2 71 XXXXXX
	nop                ; A +2 73 XXXXXX
	jmp Line4          ; A +3 76
.player_skip           ; B +3 47
	lda scanline       ; B +3 50
	lsr                ; B +2 52
	sta player_seg     ; B +3 55
	nop                ; B +2 57 XXXXXX
	lda scanline       ; B +3 60 XXXXXX
	ldy road_col       ; B +3 63
	sty COLUPF         ; B +3 66
	lda scanline       ; B +3 69
	nop                ; B +2 71 XXXXXX
	nop                ; B +2 73 XXXXXX
	jmp Line4          ; B +3 76
	ALIGN 256, $FF
Line4:
	;;;;;;;;;;;;;;;;;;;;;; line 4  (Draw P1, Plan P0)
	SUBROUTINE
	sta HMOVE          ; +3  3
	DrawP1             ; +22 25
	lda 0              ; +3  28 XXXXXX
	nop                ; +2  30 XXXXXX
	nop                ; +2  32 XXXXXX
	lda ground_col     ; +3  35
	sta COLUPF         ; +3  38
	lda scanline       ; +3  41
	cmp opp_line       ; +3  44 ...
	bne .p0_nomatch    ; A +2 46 /B +3 47
	lda opp_pix        ; A +3 49
	sta p0_pix         ; A +3 52
	jmp .p0_done       ; A +3 55
.p0_nomatch:           ; B 47
	nop                ; B +2 49 XXXXXX
	nop                ; B +2 51 XXXXXX
	nop                ; B +2 53 XXXXXX
	nop                ; B +2 55 XXXXXX
.p0_done:
	lda scanline       ; +3  58 XXXXXX
	nop                ; +2  60 XXXXXX
	lda road_col       ; +3  63
	sta COLUPF         ; +3  66
	lda #0             ; +2  68
	sta HMP1           ; +3  71 Clear P1 move set in Line3
	lda scanline       ; +3  74 XXXXXX
	nop                ; +2  76 XXXXXX

	;;;;;;;;;;;;;;;;;;;;;; line 5  (Draw P0, NOOP)
	SUBROUTINE
	sta HMOVE          ; +3  3
	DrawP0             ; +27 30
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
	DrawP1             ; +22 25
	lda 0              ; +3  28 XXXXXX
	nop                ; +2  30 XXXXXX
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
	DrawP0             ; +27 30
	nop                ; +2  32 XXXXXX
	lda ground_col     ; +3  35
	sta COLUPF         ; +3  38 Start of active playfield
	dec road_cnt       ; +5  43 Road state update...
	bpl .no_road_update ;A +2 45 / B +3 46  ...
	lda #3             ; A +2 47 ...
	sta road_cnt       ; A +3 50 ...
	inc road_seg       ; A +5 55 ...
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

.no_road_update:         ; B    46
	nop                  ; B +2 48 XXXXXX
	nop                  ; B +2 50 XXXXXX
	nop                  ; B +2 52 XXXXXX
	jmp .road_update_end ; B +3 55

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

