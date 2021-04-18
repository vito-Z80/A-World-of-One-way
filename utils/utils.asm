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





	ld a,(ix+oData.drawMethod)
	ret z  		; рисование 2х2 не требует стирания и сдвига адресов спрайтов


	;----------------
	ld a,(ix+oData.isRemove)
	or a
	jr z,.notRemove
; 	ld a,(oData.direction)
	rrca
	jr nc,.checkRightRemove
	; move left, erase right
	ld a,(ix+oData.direction)
	or a
	jr z,$ + 3
	inc l
	inc l
	inc l
	call clear1x2	
	jr .notRemove
.checkRightRemove:
	rrca
	jr nc,.checkUpRemove
	; move right, erase left
	dec l
	call clear1x2
	jr .notRemove


.checkUpRemove:
	rrca 
	jr nc,.checkDownRemove
	; move up, erase down
	ld a,c
	and %11110000
	ld l,a
	ld h,b
	ld bc,16
.vert:
	ld a,(ix+oData.direction)
	or a
	jr z,.cur
	add hl,bc
.cur:
	add hl,bc
	add hl,bc
	ld a,(hl)
	inc l
	ld h,(hl)
	ld l,a
	ld a,(ix+oData.x)
	rrca
	rrca
	rrca
	and #1F
	add a,l
	ld l,a
	call clear2x1
	jr .notRemove


.checkDownRemove:
	rrca
	jr nc,.notRemove
	ld a,c
	and %11110000
	ld l,a
	ld h,b
	ld bc,#10000 - 16
	jr .cur + 1


.notRemove:
	
	ld (ix+oData.isRemove),0
	ld a,(ix+oData.spriteId)
	call getSpriteAddr

	ld a,e
	and 7
	ld (ix+oData.bit),a
	or a
	jr z,.end
	; A * 48 = BC
	call mul48
	add hl,bc
.end:
	; hl - sprite address
	ld (ix+oData.sprAddrL),l
	ld (ix+oData.sprAddrH),h
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
; 	out (254),a
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
attrScoreShow:
	; DE - bitmap
	; C - width (in bytes)
	; TODO save under attributes and return
	ld c,2
	ld de,bitmapPlus10


	ld hl,(attrScrollAddr)
	ld a,h
	cp #57
	ret c 	; exit if scroll draw address =  -1 third
	push hl
	; set top color and convert to paper
	ld a,(attrBitmapColor)
	inc a
	and 7
	ld (attrBitmapColor),a
	rlca
	rlca
	rlca
	ex af,af
	ld b,5 	; lines count
.full:
	push bc
	push hl
	ld b,c 	; line count bytes
.line:
	ld a,h
	cp #58
	jr c,.skipLine
	cp #5B
	jr nc,.l1
	push bc
	ld a,(de)
	ld b,8
.byte:
	rlca
	jr nc,.con
	ex af,af
	ld (hl),a
	ex af,af
.con:
	inc l
	djnz .byte
	inc de
	pop bc
	djnz .line
.l1:
	; shift next line color
	ex af,af
	rrca
	rrca
	rrca
	inc a
	rlca
	rlca
	rlca
	ex af,af
	pop hl
	ld bc,32
	add hl,bc
	pop bc
	djnz .full
	pop hl
	ld bc,#10000 - 32
	add hl,bc
	ld (attrScrollAddr),hl
	ret
.skipLine:
	ex de,hl
	ld b,0
	add hl,bc
	ex de,hl
	jr .l1 
bitmapPlus10:
	db %00000100, %01110000
	db %01001100, %10001000
	db %11100100, %10001000
	db %01000100, %10001000
	db %00001110, %01110000
;------------------------------------------
; run
;     ld (return+1),sp
;     ld sp,fillStack
;     ld hl,levelCells     //  start point
;     ld de,32    //  line size
;     jp code
; return
;     ld sp,0
;     ret
; //---------------------------------
; code
;     ld c,#ff    //  C = fill color
;     ld b,(hl)   //  B = find color
;     push hl
; again
;     pause
; aga2
;     pop hl
;     ld a,l
;     cp low fillStack + 1
;     jp nc,return    //  stack is over
;     ld a,(hl)
;     cp c
;     jp z,aga2   //  does not need processing
;     ld a,b      //  find color
;     ld (hl),c   //  fill color
; left
;     dec hl
;     cp (hl)
;     jp nz,down
;     push hl
; down
;     inc hl
;     add hl,de
;     cp (hl)
;     jp nz,right
;     push hl
; right
;     inc hl
;     or a
;     sbc hl,de
;     cp (hl)
;     jp nz,up
;     push hl
; up
;     dec hl
;     or a
;     sbc hl,de
;     cp (hl)
;     jp nz,again
;     push hl
;     jp again