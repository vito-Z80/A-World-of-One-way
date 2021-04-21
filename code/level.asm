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
	push hl
;----------------------------------------------
	ld b,7
.paint:
	push bc
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

	ld a,(hl)
	inc a
	call z,.paintWall
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
	pop bc
	djnz .paint

	pop hl
	ret

.paintWall:
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
; 	dec a
	cp (hl)
	jr c,.ns1
	inc (hl)
.ns1:
	inc de
	inc hl
	ld a,(de)
; 	dec a
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
wallColors:
	db 3,1,3,3
	db 6,4,6,6
	db 2,2,1,2
	db 4,4,4,6

	db 1,2,1,1
	db 5,3,5,5
	db 3,3,5,3
	db 1,2,3,4
	endmodule