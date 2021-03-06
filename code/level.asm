	module LEVEL
;------------------------------------------------------------
build:
	call POP_UP_INFO.reset
	call clearData
	call buildLevel
	ret
;------------------------------------------------------------
clearData:
	; clear objects data
	xor a
	ld hl,objectsData
	ld de,objectsData + 1
	ld bc,(OBJECT_DATA_SIZE * MAX_OBJECTS) - 1
	ld (hl),a
	ldir
	; clear level cells data
	ld hl,levelCells
	ld de,levelCells + 1
	ld bc,(MAP_WIDTH * MAP_HEIGHT) - 1
	inc a
	ld (hl),a
	ldir
	dec a
	ld (isLevelPassed),a
	ld (rebuildLevel),a
	ld (global_direction),a 	; set direction NONE
	ret
;------------------------------------------------------------
buildLevel:
	; parse level walls
	; level walls data = 24 bytes
	; displayed wall cells = 192 pcs.
	xor a 			; cell ID
	exa
	ld ix,levelCells

	call getCurrentLevelAddress  	; HL = level data address (walls)
	ld (levelAddr),hl
	ld (globalSeedTmp),hl 	; set random seed for this level
	ld (globalSeed),hl
	push hl
	call fillWalls
	pop hl

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
	jr nc,.emptyCell 	
	ld (ix),255 		; fill cells for collision
	push hl
	exa
	ld c,a
	exa
	ld hl,BLOCK_PBM 	; TODO render random walls by seed
	call rnd16
	and 3
	jr nz,.notBlockD
	ld hl,BLOCK_D_PBM
.notBlockD:
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
	push hl
	
	call cutInsideRooms
	ld b,7
.paint:
	push bc
	ld hl,(globalSeedTmp)
	ld de,ATTR_ADDR
	ld hl,levelCells
	ld b,12
.rows:
	push bc
	push de
	ld b,16
.columns:
	push bc
	push de
	push hl
	call .paintWall
	pop hl
	inc l
	pop de
	inc e
	inc e

	pop bc
	djnz .columns

	pop de
	ex de,hl
	ld bc,64
	add hl,bc
	ex de,hl
	pop bc
	djnz .rows
	ei
	halt
	halt
	halt
	halt
	pop bc
	djnz .paint
	pop hl
	ret
.paintWall:

	ld a,(hl)
	inc a
	jr z,.pwn
	dec a
	cp 1
	jr z,.setColor
	xor a
.pwb:
	ex de,hl
	jp fillAttr2x2
.setColor:
	ld a,(globalSeedTmp)
	rrca
	and 3
	jr nz,.pwb
	inc a
	jr .pwb
.pwn:
	push de
	call rnd16
	pop hl
	and 7
	rlca
	rlca
	add a,low wallColors
	ld e,a
	adc a,high wallColors
	sub e
	ld d,a
.pw2:
	ld b,2
.pw:
	push bc
	ld a,(de)
	dec a
	cp (hl)
	jr c,.ns1
	inc (hl)
.ns1:
	inc de
	inc hl
	ld a,(de)
	dec a
	cp (hl)
	jr c,.ns2
	inc (hl)
.ns2
	dec hl
	inc de
	ld bc,32
	add hl,bc
	pop bc
	djnz .pw
	ret
;----------------------------------------------
cutInsideRooms:
	; put plugs on all doors so that the fill does not go beyond the level
	; put stubs on all heroes as start points of the fill
	; filling starts from the place where the hero is located.
	push hl
	push hl
	; install door plugs on the card.
	ld c,#FD
	ld e,EXIT_DOOR_PBM_ID
	call .blockDoors
	pop hl
	; entering on the card all heroes under the set value.
	ld c,#FE
	ld e,HERO_FACE_00_PBM_ID
	call .blockDoors
	call .fill
	pop hl
	ret
.fill:
	; look for a value, replace it with 1 and fill the area with zeros from the found value until the map runs out of the desired values.
	ld hl,levelCells
	ld a,#FE
	ld bc,#C0
	cpir
	xor a
	cp c
	ret z
	dec l
	ld (hl),1
	call fillInsideLevel
	jr .fill
	ret
.blockDoors:	
	; C > value
	; E > id of the desired sprite
	; HL > objects (after 24 level bytes)
.nextDoor:
	ld a,(hl)
	cp #FF
	ret z
	inc hl
	ld a,(hl) 	; first byte = cell id, second byte = sprite id
	inc hl
	cp e
	jr nz,.nextDoor
	push hl
	dec hl
	dec hl
	ld l,(hl)
	ld h,high levelCells
	ld (hl),c 
	pop hl
	jr .nextDoor
;----------------------------------------------
fillWalls:
	ld c,#C0
	call getFloorSprite
.loop:
	push bc
	push hl
	dec c
	call printSpr
	pop hl
	pop bc
	dec c
	jr nz,.loop
	ld a,l
	cp low FLOOR_0004_PBM
	ret nz

	ld b,24
.loop2:
	push bc
	call rnd16
	and #BF
	ld c,a
	call rnd16
	and 1
	rrca
	rrca
	rrca
	add a,low FLOOR_0001_PBM
	ld l,a
	adc a,high FLOOR_0001_PBM
	sub l
	ld h,a	
	call printSpr
	pop bc
	djnz .loop2
	ret
;----------------------------------------------
wallColors:
	db 4,6,6,6
	db 6,4,4,4
	db 5,4,4,4
	db 4,5,5,5

	db 6,6,6,6
	db 5,5,5,5
	db 4,4,4,4
	db 3,3,3,3
;----------------------------------------------
getFloorSprite:
	; A - number 0-3
	ld hl,FLOOR_0003_PBM
	call rnd16
	rrca
	ret c
	ld hl,FLOOR_0004_PBM
	ret
;----------------------------------------------



	endmodule