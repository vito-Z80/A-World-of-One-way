;--------------------------------------------------------------------
printText2x1V:
	; HL - text address (multiply symbol)
	; DE - screen address	
	ld a,1
	jr printText2x1 + 1
printText2x1:
	; HL - text address (multiply symbol)
	; DE - screen address
	xor a
	ld (textAxis),a
printTextLoop:
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
	pop hl
	inc e
	ld a,(textAxis)
	or a
	jr z,printTextLoop
	dec e
	ex de,hl
	call nextLine16
	ex de,hl
	jr printTextLoop
;--------------------------------------------------------------------
charAddr: 
        ; calc address of char in font
        ld l,a,h,0      ; a=char
        add hl,hl,hl,hl,hl,hl
        if MACHINE == 48 || MACHINE == 9
		ld bc,#3D00 - 256
	endif
        if MACHINE == 16
		ld bc,cartrigeFont - 256
	endif
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
	ld bc,#2FF
	ld (hl),a
	ldir
	ret
;--------------------------------------------------------------------
nextLine:
        ; next screen line address
        inc d
        ld  a,d
        and 7
        ret nz
        ld  a,e
        add a,32
        ld  e,a
        ret c
        ld  a,d
        sub 8
        ld  d,a
        ret
;------------------------------------------
nextLine16:
	; HL - screen address
	; return HL = screen address + 16 lines (2 symbols)
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
preLine24:
	; HL - screen address
	; return HL = screen address - 24 lines
	ld a,l
	sub #60
	ld l,a
	ret nc
	ld a,h
	sub #08
	ld h,a
	ret
;---------------------------------------------------------
getScrAddrByCoords:
	; L = Y; E = X
	; return HL > screen address
	ld a,l
	and 7
	ld h,a
	ld a,l
	rrca
	rrca
	rrca
	and %00011000
	or #40
	add h
	ld h,a
	ld a,l
	rlca
	rlca
	and %11100000
	ld l,a
	ld a,e
	rrca
	rrca
	rrca
	and #1F
	add l
	ld l,a
	ret
;---------------------------------------------------------
sortObjectIds:
	; Sorts an array of 10 bytes in ascending order. ~ 3500t (byte value range 0..254)
	ld b,MAX_OBJECTS
	ld hl,testS
.main:
	push bc
	push hl
	; B - counter
	; HL - buffer address
	ld c,#FF
.nB:
	ld a,(hl)
	cp c
	jr nc,.next
	ld c,a
	ld e,l
.next:	
	inc hl
	djnz .nB
	; C > value; E > low buffer address 
	pop hl
	ld a,(hl)
	ld d,h
	ld (de),a
	ld (hl),c
	inc hl
	pop bc
	djnz .main
	ret
;---------------------------------------------------------
getDrawData:
	; Preparing the object for rendering.
	; screen address by coordinates
	; sprite address
	call setRemoveSides
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
	ret
setRemoveSides:
; 	ld a,(ix+oData.direction)
; 	or a
; 	ret z
	ld a,(ix+oData.clearSide)
	ld l,(ix+oData.scrAddrL)
	ld h,(ix+oData.scrAddrH)
	rrca 
	jr c,.clearRight
	rrca
	jr c,.clearLeft
	rrca
	jr c,.clearDown
	rrca
	jr c,.clearUp
	ret
.clearDown:
	ld a,h
	and #F8
	ld h,a
	ld a,l
	add 64
	ld l,a
	jr nc,.clearLeft
	ld a,h
	add 8
	ld h,a

	jr .clearLeft

.clearUp:
	ld a,h
	and #F8
	ld h,a
.clearLeft:
	ld (ix+oData.clrScrAddrL),l
	ld (ix+oData.clrScrAddrH),h
	ret
.clearRight:
	inc l
	inc l
	jr .clearLeft
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
setIYtoIX:
	ld a,iyl
	ld ixl,a
	ld a,iyh
	ld ixh,a
	ret
delta7:
	ld a,(ix+oData.delta)
	inc a
	ld (ix+oData.delta),a
	and 7
	ret
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
	jr gsbc
; 	ld d,a
; 	ld a,c
; 	and #F0
; 	sla a
; 	sla a
; 	ld e,a
; 	ld a,c
; 	and #0f
; 	add a
; 	add e
; 	ld e,a
; 	ret
;---------------------------------------------------------
getScrAddrByCellId:
	; C = cell ID (cells 16x16)
	; return DE = screen address
	ld a,c
	and #C0
	rrca
	rrca
	rrca
	or #40 	
gsbc:	
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
	; Convert screen address to attribute address
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
getCellIdByScrAddr:
	; HL - screen address
	; return A > cell ID (16x16 tile ID 0-191) 
	ld a,h
	rlca
	rlca
	rlca
	and %11000000
	ld h,a

	ld a,l
	rrca
	rrca
	and #30
	add h
	ld h,a

	ld a,l
	rrca
	and #0F
	add h
	ret
;------------------------------------------------------------
getObjDataById:
	; A - object ID
	; return IY = object data address by ID
	dec a
	push hl 
	push bc
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
	pop bc
	pop hl
	ret
;------------------------------------------------------------
printSpr:
	; print sprite 2
	; HL - sprite address
	; C - cell ID
	call getScrAddrByCellId
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
; attrRect:
; 	; HL - attribute address
; 	; E - radius 	(1 - 7)
; 	; D - color
; 	ld d,#FF ; color
; 	ld a,e
; 	rrca
; 	rrca
; 	rrca
; 	add e
; 	ld c,a
; 	ld b,0
; 	add hl,bc
; 	rlc e
; 	ld bc,#10000 - 32
; 	ld a,e
; .up:
; 	ld (hl),d
; 	add hl,bc
; 	dec a
; 	jr nz,.up
; 	ld a,e
; .left:
; 	ld (hl),d
; 	dec l
; 	dec a
; 	jr nz,.left
; 	ld bc,32
; 	ld a,e
; .down:
; 	ld (hl),d
; 	add hl,bc
; 	dec a
; 	jr nz,.down
; 	ld a,e
; .right:
; 	ld (hl),d
; 	inc l
; 	dec a
; 	ret z
; 	jr .right
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
; blinkBrixghtness:
; 	ld a,(ix+oData.color)
; 	xor BRIGHTNESS
; 	ld (ix+oData.color),a
; 	ret
;------------------------------------------
resetDelta2:
	xor a
	ld (delta2),a
	ret
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
clear2x2:
	ld l,(ix+oData.scrAddrL)
	ld h,(ix+oData.scrAddrH)
	push hl
	call clear1x2
	pop hl
	inc l
	jp clear1x2
;------------------------------------------
animation2x2:
	; for sprites 2x2
	; C - total frames
	; HL - addresses of first animation sprite
	ld a,(ix+oData.animationId)
	inc a
	cp c
	jr c,.nextFrame
	xor a
.nextFrame:
	ld (ix+oData.animationId),a
	rrca
	rrca
	rrca
	add a,l
	ld l,a
	adc a,h
	sub l
	ld h,a	
	ld (ix+oData.sprAddrL),l
	ld (ix+oData.sprAddrH),h
	ret
;--------------------------------------
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
getCurrentLevelAddress:
	; return HL = level data address (walls)
	ld a,(currentLevel)
	rlca
	add a,low LEVELS_MAP
	ld l,a
	adc a,high LEVELS_MAP
	sub l
	ld h,a
	ld c,(hl)
	inc hl
	ld b,(hl)
	; BC = offset of level addresses map
	ld hl,LEVELS_BEGIN
	add hl,bc
	ret
;------------------------------------------
countObjectsSameType:
	; count objects of the same type (sprite ID)
	; A - sprite ID for search
	; return A > number of objects
	ld de,OBJECT_DATA_SIZE
	ld hl,objectsData + oData.spriteId
	ld bc,MAX_OBJECTS * 256 	; C = 0 as counter
.search:
	cp (hl)
	jr nz,.next
	inc c
.next
	add hl,de
	djnz .search
	ld a,c
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