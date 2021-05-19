	module POP_UP_INFO

;------------------------------------------
reset:
	ld hl,popupAttrAddr
	ld de,popupAttrAddr + 1
	ld bc,7 	; 8 байт переменных для всплывающей информации
	ld (hl),0
	ldir
	ret
;------------------------------------------
isFinish:
	; return 0 = finish; !0 = continue
	ld a,(popupAttrAddr)
	or a
	ret
;------------------------------------------
setExplosion:
	ld hl,#5b04
	ld de,POP_UP_INFO.bitmapExplosion
	ld bc,3 * 256 + %00010010
	jr set
setDone:
	ld hl,#5b04
	ld de,POP_UP_INFO.bitmapDone
	ld bc,3 * 256 + %00110110
	jr set
setPlus10:
	ld hl,#5b08
	ld de,POP_UP_INFO.bitmapPlus10
	ld bc,2 * 256 + %00100100
	jr set
setWasted:
	ld hl,#5b04
	ld de,POP_UP_INFO.bitmapWasted
	ld bc,3 * 256 + %01010010
	jr set
setMore:
	ld hl,#5b04
	ld de,POP_UP_INFO.bitmapMore
	ld bc,3 * 256 + %01100100
	jr set

setFear:
	ld hl,#5b04
	ld de,POP_UP_INFO.bitmapFear
	ld bc,3 * 256 + %00010010
set:
	; пока один мессадж не заверщен, другой вызывать нельзя (не подчищается предыдущий мессадж на атрибутах, можно исправить)
	call isFinish 	
	ret nz
	; HL - start attributes address (outside the scope of attributes)
	; DE - bitmap address
	; B - bitmap width
	; C - attribute color
	ld (popupAttrAddr),hl
	ld (popupBitmapAddr),de
	ld (popupBitmapColor),bc
	ret
;------------------------------------------
show:
	ld a,(bitmapWidth)
	or a
	ret z
	ld c,a 		; pop-up width
	ld de,(popupBitmapAddr)
	ld ix,buffer256 	; buffer for save backgroud attributes
	ld hl,(popupPreAttrAddr)
	ld a,l
	or h
	jr z,.onlyPaint
	; restore background 
	push de
	push bc
	ld a,c
	rlca
	rlca
	rlca 
	sub 32
	neg
	ld e,a
	ld d,0
	; de = число прибавляемое к адресу атрибутов что бы получить следующую строку.
	ld b,5

.restoreFull:
	push bc
	ld b,c
	ld a,h
	cp #58
	jr nc,.more
	; skip attributes line
	push bc
	ld bc,32
	add hl,bc
	pop bc
	jr .next + 1
.more:
	cp #5B
	jr nc,.next
.restoreLine:

	ld a,1
.restoreByte:
	ex af,af
	ld a,(ix)
	ld (hl),a
	inc ixl
	inc l
	ex af,af
	rlca
	jr nc,.restoreByte
	djnz .restoreLine
.next:	
	add hl,de
	pop bc
	djnz .restoreFull

	pop bc
	pop de
.onlyPaint:
	; paint
	ld ixl,0
	ld hl,(popupAttrAddr)
	ld (popupPreAttrAddr),hl
	ld a,h
	cp #57
	jp c,reset
	push hl
	; set top color and convert to paper
	ld a,(popupBitmapColor)
	ex af,af
	ld b,5 	; lines count
.full:
	push bc
	push hl
	ld b,c 	; line count bytes
.line:
	ld a,h
	cp #58
	jr c,.skipBitmapLine
	cp #5B
	jr nc,.l1
	push bc
	ld a,(de)
	ld b,8
.byte:
	rlca
	ld c,(hl)
	jr nc,.con
	ex af,af
	ld (hl),a
	ex af,af
.con:
	inc l
	ld (ix),c
	inc ixl
	djnz .byte
	inc de
	pop bc
	djnz .line
.l1:
	pop hl
	ld bc,32
	add hl,bc
	pop bc
	djnz .full
	pop hl

	; brightness set/res for current message
	ld a,(popupBitmapColor)
	xor #40
	ld (popupBitmapColor),a

	; get line above
	ld bc,#10000 - 32
	add hl,bc
	ld (popupAttrAddr),hl
	ret
.skipBitmapLine:
	ld a,(bitmapWidth)
	add e
	ld e,a
	adc a,d
	sub e
	ld d,a
	jr .l1 
;------------------------------------------
bitmapPlus10:
	db %00000100, %01110000
	db %01001100, %10001000
	db %11100100, %10001000
	db %01000100, %10001000
	db %00001110, %01110000
bitmapFear:
	db %11110111, %10011100, %11110001
	db %10000100, %00100010, %10001001
	db %11100111, %00111110, %11110001
	db %10000100, %00100010, %10001000
	db %10000111, %10100010, %10001001
bitmapDone:
	db %11110001, %11001000, %10111110
	db %10001010, %00101100, %10100000
	db %10001010, %00101010, %10111000
	db %10001010, %00101001, %10100000
	db %11110001, %11001000, %10111110
bitmapExplosion:
	db %11110001, %11000111, %00100010
	db %10001010, %00101000, %10110110
	db %11110010, %00101000, %10101010
	db %10001010, %00101000, %10100010
	db %11110001, %11000111, %00100010
bitmapWasted:
	db %10001001, %00011011, %10110110
	db %10001010, %10100001, %00100101
	db %10101011, %10010001, %00110101
	db %10101010, %10001001, %00100101
	db %01010010, %10110001, %00110110
bitmapMore:
	db %01000100, %11100111, %10011110
	db %01101101, %00010100, %01010000
	db %01010101, %00010111, %10011000
	db %01000101, %00010100, %01010000
	db %01000100, %11100100, %01011110

;------------------------------------------


	endmodule
