	module LEVEL
;------------------------------------------------------------
build:
	call POP_UP_INFO.reset
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
	inc a
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

	call getCurrentLevelNumber

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

	push hl
	; заливка требуется что бы визуально очистить ячейки внутри уровня.
	; find exit door cell id
	; the exit door must exist !!!  ...otherwise &!@^@#$!()
	ld a,EXIT_DOOR_PBM_ID
	call findCellIdBySpriteId
	ld (hl),#FF 	; делаем заглушку для двери, иначе заливка выйдет за пределы уровня
	ld (byteValue),hl ; save "exit door" cell for replace to 0

	pop hl
	ld a,HERO_FACE_00_PBM_ID
	call findCellIdBySpriteId
	; HL come from call above
	call fillInsideLevel
	ld hl,(byteValue)
	ld (hl),0


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
;----------------------------------------------

;----------------------------------------------



	endmodule