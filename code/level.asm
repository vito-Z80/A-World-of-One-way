	module LEVEL
;------------------------------------------------------------
build:
	call fillWalls
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
	ret
;------------------------------------------------------------
buildLevel:
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
	ld (globalSeedTmp),hl 	; set random seed for this level
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
	push hl
;----------------------------------------------
	ld b,7
.paint:
	push bc
	ld hl,(globalSeedTmp)
	ld (globalSeed),hl
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

; 	ld a,(hl)
; 	inc a
; 	call z,.paintWall
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
	push hl
	; find exit door cell id
	; the exit door must exist !!!  ...otherwise BUG
.nextObject:
	ld c,(hl)
	inc hl
	ld a,(hl)
	inc hl
	cp EXIT_DOOR_PBM_ID
	jr nz,.nextObject
.done:
	ld l,a
	ld h,high levelCells
	ld (hl),#FF

	pop hl
	ret

.paintWall:

	ld a,(hl)
	inc a
	jr z,.pwn
	push de
	pop hl
	ld de,red
	jr .pw-2
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
fillWalls:

	ld c,#C0
.loop:
	push bc
	ld hl,FLOOR_0003_PBM 
	dec c
	call printSpr

	pop bc
	dec c
	jr nz,.loop

	ret

;----------------------------------------------
wallColors:
	db 5,3,3,3
	db 3,2,2,2
	db 5,4,4,4
	db 2,3,3,3

	db 6,6,6,6
	db 5,5,5,5
	db 4,4,4,4
	db 1,1,1,1
red: 
	db 2,2,2,2
	endmodule