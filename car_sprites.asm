
; FIXME need a better way to generate symbols for sprite offsets
	org $F700
SpritePix:
	BYTE 0
	BYTE 0
	BYTE 0
	BYTE 0
	BYTE 0
	BYTE 0
	BYTE 0
	BYTE 0
PixPlayerHi = . - SpritePix
	BYTE %01111110
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11000011
	BYTE %10000001
	BYTE %10111101
	BYTE %11111111
PixPlayerLo = . - SpritePix
	BYTE %11111111
	BYTE %11111111
	BYTE %11000011
	BYTE %11011011
	BYTE %11011011
	BYTE %01011010
	BYTE %01111110
	BYTE %01000010
PixBullet1 = . - SpritePix
	BYTE %01000000
	BYTE %01000000
	BYTE %01000000
	BYTE %01000000
	BYTE %01000000
	BYTE 0
	BYTE 0
	BYTE 0
PixBullet2 = . - SpritePix
	BYTE %00000010
	BYTE %00000010
	BYTE %00000010
	BYTE %00000010
	BYTE %00000010
	BYTE 0
	BYTE 0
	BYTE 0
PixSmoke1 = . - SpritePix
	BYTE %00100000
	BYTE %01110000
	BYTE %11111000
	BYTE %11111000
	BYTE %11111000
	BYTE %11111000
	BYTE %11111000
	BYTE %11111000
PixSmoke2 = . - SpritePix
	BYTE %01111110
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111
	BYTE %11111111

PixCar1 = . - SpritePix
	BYTE %00000000
	BYTE %00000000
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
PixCar2 = . - SpritePix
	BYTE %00000000
	BYTE %00000000
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
PixCar3 = . - SpritePix
	BYTE %00000000
	BYTE %00000000
	BYTE %01111110
	BYTE %11111111
	BYTE %11111111
	BYTE %01111110
	BYTE %01111110
	BYTE %01000010
	BYTE %00011000
	BYTE %01111110
	BYTE %01111110
	BYTE %01000010
	BYTE %11111111
	BYTE %11111111
	BYTE %01111110
	BYTE %01100110
	BYTE 0

	org $F800
SpriteCol:
	BYTE 0
	BYTE 0
	BYTE 0
	BYTE 0
	BYTE 0
	BYTE 0
	BYTE 0
	BYTE 0

	BYTE $0A
	BYTE $0C
	BYTE $0C
	BYTE $0C
	BYTE $0C
	BYTE $0C
	BYTE $0C
	BYTE $0E

	BYTE $0E
	BYTE $0E
	BYTE $0C
	BYTE $0C
	BYTE $0C
	BYTE $0C
	BYTE $0A
	BYTE $44

	BYTE $1E
	BYTE $2C
	BYTE $3A
	BYTE $48
	BYTE $46
	BYTE 0
	BYTE 0
	BYTE 0

	BYTE $1E
	BYTE $2C
	BYTE $3A
	BYTE $48
	BYTE $46
	BYTE 0
	BYTE 0
	BYTE 0

	BYTE $06
	BYTE $08
	BYTE $08
	BYTE $08
	BYTE $08
	BYTE $08
	BYTE $08
	BYTE $08

	BYTE $08
	BYTE $08
	BYTE $08
	BYTE $08
	BYTE $08
	BYTE $08
	BYTE $08
	BYTE $08

	BYTE 1
	BYTE 1
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
	BYTE 1
	BYTE 1
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
	BYTE 1
	BYTE 1
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
