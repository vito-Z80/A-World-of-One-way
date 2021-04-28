;--------------------------------------------------------------------
printText2x1:
	; HL - text address (multiply symbol)
	; DE - screen address
	ld a,(hl)
	or a
	ret z 	 	; 0 == end of text (TEXT_END)
	inc hl
	push hl
	push de
	call charAddr
	inc hl
	ld c,%01010101

	push de
	call scrAddrToAttrAddr
	ld a,(textColor)
	ld (de),a
	pop de

	ld a,(hl)
	ld (de),a
	inc d
	inc d
	inc hl
	ld a,(hl)
	ld (de),a
	inc d
	inc d

	inc hl
	ld b,2
.fourth:
	ld a,(hl)
	and c
	rrc c
	ld (de),a
	inc d
	ld a,(hl)
	and c
	rrc c
	ld (de),a
	inc d
	inc hl
	djnz .fourth
	dec d
	call nextLine
	push de
	call scrAddrToAttrAddr
	ld a,(textColor+1)
	ld (de),a
	pop de
	ld b,4
.fourth2:
	ld a,(hl)
	ld (de),a
	inc d
	ld a,(hl)
	ld (de),a
	inc d
	inc hl
	djnz .fourth2
	pop de
	inc e
	pop hl
	jr printText2x1
;--------------------------------------------------------------------
charAddr: 
        ; calc address of char in font
        ld l,a,h,0      ; a=char
        add hl,hl,hl,hl,hl,hl
        ld bc,FONT-256
        add hl,bc       ; hl=address in font
        ret
;--------------------------------------------------------------------
waitAnyKey:
        ; wait any key
        xor a
        in a,(#fe)
        cpl
        and #1f
        jr z,$-6
        ret
;--------------------------------------------------------------------
clearScreen:
	ld hl,#4000
	ld de,#4001
	ld bc,#17ff
	ld (hl),l
	ldir
	ret
clearAttributesBlack:
	xor a
clearAttributes:
	; A - color
	ld hl,#5800
	ld de,#5801
	ld bc,#3FF
	ld (hl),a
	ldir
	ret
;--------------------------------------------------------------------
nextLine:
        ; next screen line address
        inc d
        ld  a,d
        and 7
        jr  nz,$+12
        ld  a,e
        add a,32
        ld  e,a
        jr  c,$+6
        ld  a,d
        sub 8
        ld  d,a
        ret
;------------------------------------------
nextLine16:
	; HL - screen address
	; return HL = screen address + 16 lines (2 symblos)
	; thanks to Sergei Smirnov
	ld a,l
	add #40
	ld l,a
	sbc a,a
	and #08
	add a,h
	ld h,a
	ret
;---------------------------------------------------------
getScrAddrByCoords:
	; L = Y; E = X
	; return Hl = screen address
	ld a,high screenAddresses
	rlc l
	adc 0
	ld h,a
	res 0,l
	ld c,l
; 	ld b,h

	ld a,(hl)
	inc l
	ld h,(hl)
	ld l,a
	ld a,e
	rrca
	rrca
	rrca
	and #1F
	add a,l
	ld l,a
	ret
;---------------------------------------------------------
getDrawData:
	; screen address by coordinates
	; sprite address
	ld e,(ix+oData.x)
	ld l,(ix+oData.y)
	call getScrAddrByCoords
	ld (ix+oData.scrAddrL),l
	ld (ix+oData.scrAddrH),h
	ld a,(ix+oData.spriteId)
	call getSpriteAddr
	ld a,e
	and 7
	ld (ix+oData.bit),a
	or a
	jr z,.end2
	; A * 48 = BC
	call mul48
	add hl,bc
.end2:
	; hl - sprite address
	ld (ix+oData.sprAddrL),l
	ld (ix+oData.sprAddrH),h

	; 



	ret



;---------------------------------------------------------
clear1x2: 	; width = 1 symbol, height = 2 symbols
	xor a
	ld b,2
.clear:
	push bc
	push hl
	dup 8
	ld (hl),a
	inc h
	edup
	pop hl
	ld bc,32
	add hl,bc
	pop bc
	djnz .clear
	ret
;---------------------------------------------------------
clear2x1: 	; width = 2 symbols, height = 1 symbol
	xor a
	dup 4
	ld (hl),a
	inc l
	ld (hl),a
	inc h
	ld (hl),a
	dec l
	ld (hl),a
	inc h
	edup
	ret
;---------------------------------------------------------
mul48:
	; A = multiplier
	; return BC = A * 48 (9 bit)
	rrca
	rrca
	rrca
	ld c,a
	rrca
	add c
	ld c,a
	adc 0
	sub c
	ld b,a
	ret
;---------------------------------------------------------
getAttrAddrByCellId:
	; C = cell ID (cells 16x16)
	; return DE = attributes address
	ld a,c
	and #C0
	rlca
	rlca
	or #58
	ld d,a
	ld a,c
	and #F0
	sla a
	sla a
	ld e,a
	ld a,c
	and #0f
	add a
	add e
	ld e,a
	ret
;---------------------------------------------------------
getScreenAddrByCellId:
	; C = cell ID (cells 16x16)
	; return DE = screen address
	ld a,c
	and #C0
	rrca
	rrca
	rrca
	or #40 		
	ld d,a
	ld a,c
	and #F0
	sla a
	sla a
	ld e,a
	ld a,c
	and #0f
	add a
	add e
	ld e,a
	ret
;------------------------------------------------------------
getCoordsByCellId:
	; C = cell ID (cells 16x16)
	; return DE = Y,X
	ld a,c
	and #F0
	ld d,a 		; Y
	ld a,c
	and 15
	rlca
	rlca
	rlca
	rlca
	ld e,a 		; X
	ret
;------------------------------------------------------------
getCellIDByCoords:
	; DE - Y,X
	; return A = cell ID
	; corrupt D
	ld a,d
	and #F0
	ld d,a
	ld a,e
	rrca
	rrca
	rrca
	rrca
	and #0F
	add d
	ret
;------------------------------------------------------------
scrAddrToAttrAddr:
	; DE = screen address
	; return DE = attributes address
	ld a,d
	and #58
	rrca
	rrca
	rrca
	or #58
	ld d,a
	ret
;------------------------------------------------------------
paint2x2:
	; only static cell
	; C - color
	; HL - attributes address
	ld (hl),c
	inc l
	ld (hl),c
	ld a,l
	add 32
	ld l,a
	ld (hl),c
	dec l
	ld (hl),c
	ret
;------------------------------------------------------------
getObjDataById:
	; A - object ID
	; return IY = object data address by ID
	dec a
	ld h,0
	ld l,a
	ld bc,objectsData 		; 16,32,64.... bytes for 1 object
	; generate 
	if OBJECT_DATA_SIZE >= 16
		add hl,hl
		add hl,hl
		add hl,hl
		add hl,hl
	endif
	if OBJECT_DATA_SIZE >= 32
		add hl,hl
	endif
	if OBJECT_DATA_SIZE == 64
		add hl,hl
	endif
	;
	add hl,bc
	push hl
	pop iy
	ret
;------------------------------------------------------------
printSpr:
	; HL - sprite address
	; C - cell ID
	call getScreenAddrByCellId
	ld b,16
sprLine:
	push bc
	ldi
	ldi
	dec de
	dec de
	call nextLine
	pop bc
	djnz sprLine
	ret
;-------------------------------------------------
printSprite3x2:
	ld b,16
.sprLine:
	push bc
	ldi
	ldi
	ldi
	dec de
	dec de
	dec de
	call nextLine
	pop bc
	djnz .sprLine
	ret
;-------------------------------------------------
printSprite3x2as2x2:
	ld b,16
.sprLine:
	push bc
	ldi
	ldi
	dec de
	dec de
	inc hl
	call nextLine
	pop bc
	djnz .sprLine
	ret
;-------------------------------------------------
; left side of screen
createYAdressess:
	ld de,#4000
	ld hl,screenAddresses
	ld b,192
.position:
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl
	call nextLine
	djnz .position
	ret
;-------------------------------------------------
getSpriteAddr:
	; A - sprite ID
	; return HL = sprite address
	add a
	add a,low SPRITE_MAP
	ld l,a
	adc a,high SPRITE_MAP
	sub l
	ld h,a
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
	ld bc,EMPTY_PBM
	add hl,bc
	ret
;-------------------------------------------------
; 16-bit xorshift pseudorandom number generator by John Metcalf
; 20 bytes, 86 cycles (excluding ret)

; returns   hl = pseudorandom number
; corrupts   a

; generates 16-bit pseudorandom numbers with a period of 65535
; using the xorshift method:

; hl ^= hl << 7
; hl ^= hl >> 9
; hl ^= hl << 8

; some alternative shift triplets which also perform well are:
; 6, 7, 13; 7, 9, 13; 9, 7, 13.
rnd16:
	push hl
.xrnd:
	ld hl,(globalSeed)       ; seed must not be 0
	ld a,h
	rra
	ld a,l
	rra
	xor h
	ld h,a
	ld a,l
	rra
	ld a,h
	rra
	xor l
	ld l,a
	xor h
	ld h,a
	ld (globalSeed),hl
	pop hl
 	ret	
;------------------------------------------
attrRect:
	; HL - attribute address
	; E - radius 	(1 - 7)
	; D - color
	ld d,#FF ; color
	ld a,e
	rrca
	rrca
	rrca
	add e
	ld c,a
	ld b,0
	add hl,bc
	rlc e
	ld bc,#10000 - 32
	ld a,e
.up:
	ld (hl),d
	add hl,bc
	dec a
	jr nz,.up
	ld a,e
.left:
	ld (hl),d
	dec l
	dec a
	jr nz,.left
	ld bc,32
	ld a,e
.down:
	ld (hl),d
	add hl,bc
	dec a
	jr nz,.down
	ld a,e
.right:
	ld (hl),d
	inc l
	dec a
	ret z
	jr .right
;------------------------------------------
colorRotate:
	; rotate 'A' (1-7) without 0
	dec a
	jr nz,.rc
	dec a
.rc:
	and 7
	ret
;------------------------------------------
convertScrToAttr:
	; return HL - attribute address
	ld e,(ix+oData.scrAddrL)
	ld d,(ix+oData.scrAddrH)
	call scrAddrToAttrAddr
	ex de,hl
	ret
;------------------------------------------
blinkBrightness:
	ld a,(ix+oData.color)
	xor BRIGHTNESS
	ld (ix+oData.color),a
	ret
;------------------------------------------
flashRedYellow:
	call convertScrToAttr
	ld a,(ix+oData.color)
	xor 4
	ld (ix+oData.color),a
	ld a,(ix+oData.delta)
	and 3
	jr z,fillAttr2x2
	ld a,#40
	xor (ix+oData.color)


	jr fillAttr2x2
;------------------------------------------
circularGradient:
	ld a,(ix+oData.delta)
	and 1
	ret nz
	call convertScrToAttr
	ld a,(ix+oData.color)
	push af
	ld (hl),a
	inc l
	call colorRotate
	ld (hl),a
	ld bc,32
	add hl,bc
	call colorRotate
	ld (hl),a
	dec l
	call colorRotate
	ld (hl),a
	pop af
	dec a
	call colorRotate
	ld (ix+oData.color),a
	ret
;------------------------------------------
resetDelta2:
	xor a
	ld (delta2),a
	ret
;------------------------------------------
clearArea:


;------------------------------------------
blinkArea:
	; DE - Y, X
	; BC - height, wifth
	ld a,(byteValue)
	call colorRotate
	ld (byteValue),a
fillArea:
	; A - color
	; DE - Y, X
	; BC - height, wifth
	ld l,d
	ld h,0
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld d,#58
	add hl,de
	ld de,#20
.line:
	push bc
	push hl
.symbol:
	ld (hl),a
	inc hl
	dec c
	jr nz,.symbol
	pop hl
	add hl,de
	pop bc
	djnz .line
	ret
;------------------------------------------
fillAttr2x2:
	; A - color
	; HL - attribute address
	ld (hl),a
	inc l
	ld (hl),a
	ld bc,32
	add hl,bc
	ld (hl),a
	dec l
	ld (hl),a
	ret
;------------------------------------------
fadeOutFull:
	; A - system ID after fade out
	push af
	call SOUND_PLAYER.SET_SOUND.mute
.again:
	ld hl,#5800
	ld e,l
.loop:
	ld a,(hl)
	and %00000111
	jr z,.next
	ld e,1
	dec a
	ld (hl),a
.next
	inc hl
	ld a,h
	cp #5B
	jr c,.loop
	halt
	halt
	rrc e
	jr c,.again
	pop af
	ret
;------------------------------------------
fadeOut2x2:
	call convertScrToAttr
	ld a,(ix+oData.color)
	call fillAttr2x2
	dec a
	ld (ix+oData.color),a
	ret
;------------------------------------------
clear2x2:
	ld l,(ix+oData.scrAddrL)
	ld h,(ix+oData.scrAddrH)
	push hl
	call clear1x2
	pop hl
	inc l
	jp clear1x2
;------------------------------------------
	; http://map.grauw.nl/sources/external/z80bits.html#5.1
	; 16-bit Integer to ASCII (decimal)
 	; Input: HL = number to convert, DE = location of ASCII string
	; Output: ASCII string at (DE)
convertCoin:
	ld hl,(coins)
	ld de,coinsText
asciiConvert:
Num2Dec	
	ld	bc,-10000
	call	Num1
	ld	bc,-1000
	call	Num1
	ld	bc,-100
	call	Num1
	ld	c,-10
	call	Num1
	ld	c,b
Num1	ld	a,'0'-1
Num2	inc	a
	add	hl,bc
	jr	c,Num2
	sbc	hl,bc
	ld	(de),a
	inc	de
	ret
;------------------------------------------
findCellIdBySpriteId:
	; find first sprite ID in level data (after walls data)
	; A - sprite ID
	; HL - Level objects data (after walls data)
	; return HL > level cell by sprite ID
	ld bc,#C0
	cpir
	dec l
	dec l
	; > (HL) cell id 
	ld l,(hl)
	ld h,high levelCells
	ret
;------------------------------------------
; my paste Fill algorithm: https://pastebin.com/4X4C8e62
fillInsideLevel:
	; HL strart cell for begin fill
	ld (fillStack),sp
	ld sp,buffer256 + 254
	ld de,MAP_WIDTH    	//  line size
	jr fillProced
return
	ld sp,(fillStack)
	ret
//---------------------------------
fillProced
	ld c,0 
	ld b,(hl)   //  B = find ID
	push hl
again
	ld (tmpStack),sp
	ld a,(tmpStack)
	cp low buffer256 + 254
    	jr z,return    //  stack is over
	pop hl
	ld a,(hl)
	cp b
	jp nz,again   	//  does not need processing
	ld a,b      	//  find ID
	ld (hl),c
	ex af,af
	ld a,l
	exx 
	ld c,a
	ld hl,EMPTY_PBM
	call printSpr
	exx
	ex af,af
left
	dec l
	cp (hl)
	jp nz,down
	push hl
down
	inc l
	add hl,de
	cp (hl)
	jp nz,right
	push hl
right
	inc l
	or a
	sbc hl,de
	cp (hl)
	jp nz,up
	push hl
up
	dec l
	or a
	sbc hl,de
	cp (hl)
	jp nz,again
	push hl
	jp again