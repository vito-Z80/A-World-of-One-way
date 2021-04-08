	module OBJECTS


;----------------------------------------------------------------
draw:
	; FIXME for stack... or not :)
	ld ix,objectsData
	ld b,MAX_OBJECTS
.loop:
	push bc
	ld a,(ix+oData.id)
	inc a
	jr z,.end 			; #FF = empty object
	ld e,(ix+oData.scrAddrL) 	; scr addr low
	ld d,(ix+oData.scrAddrH) 	; scr addr high
	ld a,d
	or e
	jr z,.end
	push de
	call paint
	ld l,(ix+oData.sprAddrL) 	; spr addr low
	ld h,(ix+oData.sprAddrH) 	; spr addr high
	; FIXME draw method
	pop de
	ld a,(ix+oData.bit)		; bit for sprite number (animated)
	call .draw 		
.end:
	ld bc,OBJECT_DATA_SIZE 
	add ix,bc
	pop bc
	djnz .loop
	ret
.draw:
	ld a,(ix+oData.drawMethod)
	or a
	jp z,printSpr + 3
.d3x2:
	ld a,(ix+oData.bit)
	or a
	jp z,printSprite3x2as2x2
	jp printSprite3x2
;----------------------------------------------------------------
paint:
	ld a,(ix+oData.color) 	
	inc a
	ret z 	; if color == #FF > no paint
	call scrAddrToAttrAddr 	; convert screen address to attribute address
	ex de,hl
	ld bc,#20
	ld a,(ix+oData.direction)
	or a
	jr z,.paint2x2
	rrca 		
	jr c,.paint2x2	; left
	rrca 		
	jr nc,.pUp
	inc l		; right
	jr .paint2x2
.pUp:
	rrca 		; up
	jr c,.paint2x2
	add hl,bc 	
.paint2x2:
	ld a,(ix+oData.color)
	ld (hl),a
	inc l
	ld (hl),a
	add hl,bc
	ld (hl),a
	dec l
	ld (hl),a
	ret
;----------------------------------------------------------------
update:
	xor a
	ld (tmp_direction),a
	ld ix,objectsData
	ld b,MAX_OBJECTS
.loop:
	push bc
	ld l,(ix+oData.exec)
	ld a,(ix+oData.exec + 1)
	ld h,a
	or l
	jr z,.more
	ld bc,.more
	push bc
	jp (hl)
.more:
	ld a,(ix+oData.direction)
	ld hl,tmp_direction
	or (hl)
	ld (hl),a
	ld de,OBJECT_DATA_SIZE
	add ix,de 	; next object data
	pop bc
	djnz .loop
	ld a,(tmp_direction)
	or a
	ret nz
	ld (global_direction),a
	ret
;----------------------------------------------------------------
cellContents:
	; HL - level cell
	ld a,(hl)
	or a
	ret z
	push hl
	call getObjDataById
	pop hl
	ld a,(iy+oData.spriteId)
	cp CHUPA_001_PBM_ID
	jp z,CHUPA.transform
	cp EXIT_DOOR_PBM_ID
	jp z,GAME.setNextLevel
	cp BOOM_01_PBM_ID
	jp z,CHUPA.destroy
	//.......
	ret
;----------------------------------------------------------------

checkForRemoveSide:
	; E - x || y
	; D - preX || preY
	ld a,d
	and %11111000
	ld d,a
	ld a,e
	and %11111000
	sub d
	jr z,.cfrs
	ld a,(ix+oData.direction)
.cfrs:
	ld (ix+oData.isRemove),a
	ret
;------------------------------------
accelerate:
	ld a,(ix+oData.delta)
	add ACCELERATE_STEP 		; ACCELERATE_STEP
	ld (ix+oData.delta),a
	ret nc
	ld a,(ix+oData.accelerate)
	inc a
	cp MAX_SPEED  		;MAX_SPEED
	ret nc
	ld (ix+oData.accelerate),a
	ret

;-------------------------------------------------
create:
	; HL - objects level data
	ld ix,objectsData 	; objects data storage
	xor a 		; object ID
.nextObject
	inc a 				; next object ID
	ld (ix+oData.id),a 		; save object ID
	ex af,af
	ld a,(hl) 	; cell id
	cp #FF
	ret z 		; exit if #FF
	inc hl
	ld (ix+oData.cellId),a 		; cell id in levelCells
	; set coordinates
	ld c,a
	call getCoordsByCellId
	ld (ix+oData.x),e
	ld (ix+oData.preX),e
	ld (ix+oData.dstX),e
	ld (ix+oData.y),d
	ld (ix+oData.preY),d
	ld (ix+oData.dstY),d
	; set screen address for draw
	call getScreenAddrByCellId
	ld (ix+oData.scrAddrL),e
	ld (ix+oData.scrAddrH),d
	; set sprite ID
	ld a,(hl) 	
	ld (ix+oData.spriteId),a
	push hl
	push af
	call findObj
	pop af
	pop hl
	inc hl
	push hl
	call getSpriteAddr
	ld (ix+oData.sprAddrL),l
	ld (ix+oData.sprAddrH),h
	pop hl
	ld bc,OBJECT_DATA_SIZE
	add ix,bc 			; next object data address
	ex af,af
	jr .nextObject 
;----------------------------------------------------------------
findObj:
	cp ENEMY_FACE_00_PBM_ID
	jp z,ENEMY_SKULL.init
	cp HERO_FACE_00_PBM_ID
	jp z,HERO.init
	cp CHUPA_001_PBM_ID
	jp z,CHUPA.init
	cp EXIT_DOOR_PBM_ID
	jp z,EXIT_DOOR.init


	ret

;----------------------------------------------------------------
setObjectId:
	; object ID to level cell
	ld a,(ix+oData.id)
	ld l,(ix+oData.cellId)
	ld h,high levelCells
	ld (hl),a
	ret
;----------------------------------------------------------------
objMove:
	; for movable objects
	ld a,(global_direction)
	ld (ix+oData.direction),a
	rrca
	jr c,stepLeft
	rrca 
	jr c,stepRight
	rrca 
	jr c,stepUp
	rrca
	ret nc
;-------
stepDown:
	call accelerate
	ld a,(ix+oData.y)
	ld (ix+oData.preY),a
	add (ix+oData.accelerate)
	ld (ix+oData.y),a
	ret
;-------
stepUp:
	call accelerate
	ld a,(ix+oData.y)
	ld (ix+oData.preY),a
	sub (ix+oData.accelerate)
	ld (ix+oData.y),a
	ret
;-------
stepLeft:
	call accelerate
	ld a,(ix+oData.x)
	ld (ix+oData.preX),a
	sub (ix+oData.accelerate)
	ld (ix+oData.x),a
	ret
;-------
stepRight:
	call accelerate
	ld a,(ix+oData.x)
	ld (ix+oData.preX),a
	add (ix+oData.accelerate)
	ld (ix+oData.x),a
	ret
;----------------------------------------------------------------
collision:
	ld a,(ix+oData.direction)
	or a
	ret z
	ld h,high levelCells
	ld e,(ix+oData.x)
	ld d,(ix+oData.y)


	ex af,af
	call getCellIDByCoords
	ld l,a 		; cell ID
	ex af,af
	rrca
	jr c,checkLeft
	rrca
	jr c,checkRight
	rrca
	jr c,checkUp
	rrca
	ret nc
checkDown:
	ld bc,MAP_WIDTH
	add hl,bc
	ld a,(hl)
	or a
	ret z 		; free way
	call nz,targetCell
	ld a,(hl)
	or a
	ret z 		; free way
	; stop
	ld bc,#10000 - MAP_WIDTH 
	jr checkVertical
;-------
checkLeft:
	ld a,(hl)
	or a
	ret z 		; free way
	call nz,targetCell
	ld a,(hl)
	or a
	ret z 		; free way
	; stop
	inc l
setCollisionData:
	ld c,l
	call getCoordsByCellId
	ld (ix+oData.x),e
	ld (ix+oData.y),d
	ld (ix+oData.cellId),l
	ld (ix+oData.accelerate),1
	ld (ix+oData.direction),0
	ld a,(ix+oData.id)
	ld (hl),a 	; когда объект остановлен - заносим его object ID в €чейку карты. 
	ret
;-------
checkRight:
	inc l
	ld a,(hl)
	or a
	ret z 		; free way
	call nz,targetCell
	ld a,(hl)
	or a
	ret z 		; free way
	; stop
	dec l
	jr setCollisionData
;-------
checkUp:
	ld a,(hl)
	or a
	ret z 		; free way
	call nz,targetCell
	ld a,(hl)
	or a
	ret z 		; free way
	; stop
	ld bc,MAP_WIDTH
checkVertical:
	add hl,bc
	jr setCollisionData
;-----------------
targetCell:
	; HL - level cell
	; A - object ID
	ex de,hl
	call getObjDataById  	; get IY - target object address
	ex de,hl
	ld a,(iy+oData.spriteId)
	cp CHUPA_001_PBM_ID
	jp z,CHUPA.transform
	cp EXIT_DOOR_PBM_ID
	jp z,EXIT_DOOR.toNextLevel
	cp BOOM_01_PBM_ID
	jp z,CHUPA.destroy

	cp ENEMY_FACE_00_PBM_ID
	jp z,ENEMY_SKULL.target
	//.......
	ret
;----------------------------------------------------------------
clearCellsForMovableObjects:
	ld ix,objectsData 
	ld h,high levelCells
	ld b,MAX_OBJECTS
.loop:
	ld a,(ix+oData.isMovable)
	or a
	jr z,.next
	ld l,(ix+oData.cellId)
	ld (hl),0
.next:
	ld de,OBJECT_DATA_SIZE
	add ix,de
	djnz .loop
	ret
;----------------------------------------------------------------
/*
	когда объект остановлен - заносим в €чейку карты на месте остановки объекта object ID

	как только объект начинает движение - эта €чейка очищаетс€ !!
	перед пунктом выше требуетс€ проверить один раз каждый объект, с целью вы€снить разрешено ли движение в требуемом направлении ?
	  примеру могут сто€ть 2 врага р€дом по горизонтали (движение влево)
		слева от них стена = сто€т оба
		справа от них стена = оба движут€с€

		тут будет кос€к...... переработать.



	приминимо только к передвигаемым объектам - isMovable
*/
;----------------------------------------------------------------

	; TODO разобратьс€ что нужно обнул€ть, что нет !!!
	; после прохода ƒ¬ќ…Ќќ√ќ спрайта врага через бомбу, оставшийс€ спрайт не завершает движение и управление не доступно !!!!
resetObjectIX:
; 	push ix
; 	pop hl
; 	ld e,l
; 	ld d,h
; 	inc de
; 	ld bc,OBJECT_DATA_SIZE - 1
; 	ld (hl),0
; 	ldir
; 	ret

	xor a
	ld (ix+oData.scrAddrL),a
	ld (ix+oData.scrAddrH),a
	ld (ix+oData.sprAddrL),a
	ld (ix+oData.sprAddrH),a
	ld (ix+oData.exec),a
	ld (ix+oData.exec + 1),a
	dec a
	; set #FF
	ld (ix+oData.id),a
	ld (ix+oData.spriteId),a
	ret
resetObjectIY:
; 	push iy
; 	pop hl
; 	ld e,l
; 	ld d,h
; 	inc de
; 	ld bc,OBJECT_DATA_SIZE - 1
; 	ld (hl),0
; 	ldir
; 	ret

	xor a
	ld (iy+oData.scrAddrL),a
	ld (iy+oData.scrAddrH),a
	ld (iy+oData.sprAddrL),a
	ld (iy+oData.sprAddrH),a
	ld (iy+oData.exec),a
	ld (iy+oData.exec + 1),a
	dec a
	; set #FF
	ld (iy+oData.id),a
	ld (iy+oData.spriteId),a
	ret
	endmodule
