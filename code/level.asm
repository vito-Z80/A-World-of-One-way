	module LEVEL
;------------------------------------------------------------
build:
	call clearData
	call buildLevel
	ret
;------------------------------------------------------------
clearData:
	; objects data
	xor a
	ld hl,objectsData
	ld de,objectsData + 1
	ld bc,(OBJECT_DATA_SIZE * MAX_OBJECTS) - 1
	ld (hl),a
	ldir
	; levelCells data
	ld hl,levelCells
	ld de,levelCells + 1
	ld bc,MAP_WIDTH * MAP_HEIGHT - 1
	ld (hl),a
	ldir
	; set direction NONE
	ld (global_direction),a
	ld a,(currentLevel)
	and 1
	inc a
	ld (floorColor),a
	ret
;------------------------------------------------------------
buildLevel:
; 	call .fillFloor
	; parse level walls
	; level walls data = 24 bytes
	; displayed wall cells = 192 pcs.
	xor a 			; cell ID
	exa
	ld ix,levelCells

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
	ld (globalSeed),hl 	; set random seed for this level
	ld b,24 		; 12 rows, 2 columns
.nextHalf:
	push bc
	ld a,(hl)
	; half screen line (8 cells 16x16 from byte)
	ld b,8
.byteToHalfLine:
	push bc
	rlca
	push af
	jr nc,.emptyCell 	; TODO replace to floor cell
	ld (ix),255 		; fill cells for collision
	push hl
	ld hl,BLOCK_PBM 	; TODO render random walls by seed
	exa
	ld c,a
	exa
	call printSpr
	pop hl
.emptyCell:
	inc ix
	exa 
	inc a
	exa
	pop af
	pop bc
	djnz .byteToHalfLine
	inc hl
	pop bc
	djnz .nextHalf
	ret
;----------------------------------------------
.fillFloor:
	; TODO get two random floor sprites ?
; 	ld de,#4000
	ld b,#C0
.loop:
	push bc
	ld c,b
	dec c
	ld hl,FLOOR_0004_PBM
	call printSpr
	pop bc
	djnz .loop

	ret
;----------------------------------------------
.drawFloor:
	; TODO сохранять идентификатор пола в карте пола (начало с первой картинки пола = это пустота)
	push hl
	exa
	ld c,a
	push bc
	exa
	call getScreenAddrByCellId
	push de
	call scrAddrToAttrAddr
	ex de,hl
	; fill attribute 2x2
	ld a,(floorColor)
	ld c,a
	call paint2x2

	call .getFloorSprite
	ld a,e 		; floor sprite ID
	pop de
	pop bc
	ld b,high floorCells
	ld (bc),a 	; save floor sprite ID to floorCells
	call printSpr + 3	
	pop hl
	jr .emptyCell
.getFloorSprite:
	; получение спрайта пола (16х16) или пустоты, все они должны быть расположены по порядку
	call rnd16
	ld e,1 		; floor sprite id from first EMPTY_PBM
	ld bc,32
	ld hl,EMPTY_PBM
	cp 200
	ret c
	inc e
	add hl,bc
	cp 220
	ret c
	inc e
	add hl,bc
	cp 240
	ret c
	inc e
	add hl,bc
	cp 250
	ret c
	inc e
	add hl,bc
	ret
;----------------------------------------------

	endmodule