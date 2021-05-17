	module OBJECTS

;----------------------------------------------------------------
draw:
	ld hl,renderData
.mLoop:
	ld a,(hl)
	cp #FF
	ret z
	push hl
	ld ixh,a
	inc hl
	ld a,(hl)
	ld ixl,a
	or ixh
	jr z,.nnn
	ld a,(ix+oData.x) 		; X не может быть = 0, значит объект уничтожен.
	or a
	jr z,.nnn
	call .clear
	ld e,(ix+oData.scrAddrL) 	; scr addr low
	ld d,(ix+oData.scrAddrH) 	; scr addr high
	push de
	call .go
	pop de
	call .paint
.nnn:
	pop hl
	inc hl
	inc hl
	jr .mLoop
.go:	
	ld a,d
	or e
	ret z
.dStart:
	ld l,(ix+oData.sprAddrL) 	; spr addr low
	ld h,(ix+oData.sprAddrH) 	; spr addr high
	; FIXME draw method
.draw:
	ld a,(ix+oData.drawMethod)
	or a
	jp z,printSpr + 3
.d3x2:
	ld a,(ix+oData.bit)
	or a
	jp z,printSprite3x2as2x2
	jp printSprite3x2
.oneObject
	call .clear
	ld e,(ix+oData.scrAddrL) 	; scr addr low
	ld d,(ix+oData.scrAddrH) 	; scr addr high
	jr .dStart
.paint:

	call scrAddrToAttrAddr
	ex de,hl
	ld a,(ix+oData.launchTime)
	or a
	jr nz,.normal		; не красить вперед пока не стартовал
	ld a,(ix+oData.direction)
	rrca
	jr c,.normal
	inc l
	rrca
	jr c,.normal
	dec l
	rrca
	jr c,.normal
	rrca
	jr nc,.normal
	ld bc,32
	add hl,bc
.normal:
	ld a,(ix+oData.color)
	jp fillAttr2x2
.clear:
	ld a,(ix+oData.accelerate)
	cp 2
	jr nc,.spriteTail
	; КОСТЫЛИНА !!!!!!!!! clear after object stopped 
	ld a,(ix+oData.direction)
	or a
	ret nz
	ld a,(ix+oData.clearSide)
	or a
	ret z
; 	ex af,af
; 	call SOUND_PLAYER.SET_SOUND.key
; 	ex af,af
	ld l,(ix+oData.scrAddrL)
	ld h,(ix+oData.scrAddrH)	
	inc l
	inc l
	rrca 
	jr c,.st 	; for clear right
	dec l
	dec l
	dec l
	rrca
	jr c,.st 	; for clear left
	ex af,af
	inc l
	call nextLine16
	ex af,af
	rrca
	jr c,.st 	; for clear bottom
	ex af,af
	call preLine24
	ex af,af
	rrca
	jr c,.st 	; for clear top
	ret
.spriteTail:
	ld l,(ix+oData.clrScrAddrL)
	ld h,(ix+oData.clrScrAddrH)
.st:	

	ld a,(ix+oData.clearSide)
	ld (ix+oData.clearSide),0
	rrca 
	jr c,.clearHoriz
	rrca 
	jr c,.clearHoriz
	rrca 
	jr c,.clearVert
	rrca
	jr c,.clearVert
	ret

.clearHoriz:
	ld b,2
	ld de,32
.clearHorizSides:
	xor a
	ld (hl),a
	inc h
	ld (hl),a
	inc h
	ld (hl),a
	inc h
	ld (hl),a
	inc h
	ld (hl),a
	inc h
	ld (hl),a
	inc h
	ld (hl),a
	inc h
	ld (hl),a
	ld a,h
	sub 7
	ld h,a
	add hl,de
	djnz .clearHorizSides
	ret
.clearVert:
	ld b,8
	xor a
.nLine:
	ld (hl),a
	inc l
	ld (hl),a
	dec l
	inc h
	djnz .nLine
	ret
;----------------------------------------------------------------
getRenderDataAddress:
	; return D = positive or negative direction
	; return HL - renderData address (positive = renderData + MAX_OBJECTS * 2 - 2; negative = renderData)
	ld hl,renderData
	ld a,(global_direction)
	and DIRECTION.LEFT or DIRECTION.UP 
	ld d,a 		; D = if (positive direction) #00 else #FF 
	ret nz
	ld hl,renderData + (MAX_OBJECTS * 2) - 2
	ret
nextRenderAddress:
	; D - positive or negative direction
	ld a,d
	or a
	jr z,.positive
	inc hl
	inc hl
	ret
.positive:
	dec hl
	dec hl
	ret
;----------------------------------------------------------------
disableIXObject:
	; HL - sound data address
	; BC - (pop-up info) execute address
	ld a,(ix+oData.isDestroyed)
	or a
	ret z
	rrca 			; A = 1
	jr c,.setDefault
	rrca  			
	ret nc
	; A = 2
.fadeOut:
	ld a,(ix+oData.delta)
	sub 1
	jr nc,.fo
	call POP_UP_INFO.isFinish
	ret nz
; 	rrc (ix+oData.isDestroyed)
	call clear2x2
	; reset object from object data map
	jp resetObjectIX
.fo:
	ld (ix+oData.delta),a
	ld a,(ix+oData.color)
	dec a
	ld (ix+oData.color),a
	rrca
	jr c,.fo2
	or #40
.fo2:
	and %01001111
	ld c,(ix+oData.cellId)
	ex af,af
	call getAttrAddrByCellId
	ex af,af
	ex de,hl
	jp fillAttr2x2
.setDefault:
	push bc
	call SOUND_PLAYER.init
	call alignToCell
	call draw.oneObject
	rlc (ix+oData.isDestroyed)
	ld (ix+oData.isMovable),0
	ld (ix+oData.color),16
	ld (ix+oData.delta),16
	ld l,(ix+oData.cellId)
	ld h,high levelCells
	ld (hl),0
	ret
 	; go to pop-up info address
;----------------------------------------------------------------
preDestructionOther:
	; HL - sound data
	call SOUND_PLAYER.init
	ld (iy+oData.isDestroyed),1
	ld (iy+oData.isMovable),0
	ld (iy+oData.color),7
	ld l,(iy+oData.cellId)
	jr dt
preDestructionThis:
	; HL - sound data
	call SOUND_PLAYER.init
	ld (ix+oData.isDestroyed),1
	ld (ix+oData.color),7
	ld (ix+oData.isMovable),0
	ld l,(ix+oData.cellId)
dt:
	ld h,high levelCells
	ld (hl),0
	ret
;----------------------------------------------------------------
update:
	BORDER 6
	call sortObjects
	BORDER 4
	call getRenderDataAddress
.loop
	ld a,(hl)
	or a
	jr z,.n2
	inc a
	ret z
	dec a
	push hl
	push de
	ld ixh,a
	inc hl
	ld a,(hl)
	ld ixl,a
	call moveObject 
; 	; get execute
	ld l,(ix+oData.exec)
	ld a,(ix+oData.exec + 1)
	ld h,a
	or l
	jr z,.next
	ld bc,.next
	push bc
	jp (hl)	
.next:
	pop de
	pop hl
.n2:
	call nextRenderAddress
	jr .loop
;----------------------------------------------------------------
isSameObject:
	ld a,(iy+oData.spriteId)
	cp (ix+oData.spriteId)
	ret
;----------------------------------------------------------------
sortObjects:
	ld a,MAX_OBJECTS
	ld de,testS
	ld hl,objectsData+oData.cellId
	ld bc,OBJECT_DATA_SIZE
.sendCell:
	ex af,af
	ld a,(hl)
	ld (de),a
	inc de
	add hl,bc
	ex af,af
	dec a
	jr nz,.sendCell
	call sortObjectIds 	; сортировка идентификаторов ячеек
	;  отчистка буфера адресов объектов для рендера
	ld hl,renderData
	ld de,renderData + 1
	ld bc,(MAX_OBJECTS * 2) - 1
	ld (hl),0
	ldir

	;  создание адресов объектов для ренддера: слева на право сверху вниз.
	ld ix,objectsData
	ld de,objectsData + oData.cellId
	ld bc,MAX_OBJECTS * 256
.mLoop:
	push bc
	push de
	ld c,0
	ld hl,testS - 1
	ld a,(de)
	or a
	jr z,.skip
.nextId:
	inc hl
	inc c
	cp (hl)
	jr nz,.nextId
	dec c
	ld a,c
	rlca
	add a,low renderData
	ld l,a
	adc a,high renderData
	sub l
	ld h,a
	ld a,ixh
	ld (hl),a
	inc hl
	ld a,ixl
	ld (hl),a
	; TODO еще проверить, хз че происходит
; 	ld bc,OBJECT_DATA_SIZE
; 	add ix,bc
.skip:
	ld bc,OBJECT_DATA_SIZE
	add ix,bc
	pop hl
; 	ld bc,OBJECT_DATA_SIZE
	add hl,bc
	ex de,hl
	pop bc
	djnz .mLoop
	ret
;-------------------------------------------------------------------
; 	Определяет начальное движение подвижного объекта, если по направлению движеня не стена - то движется.
identifyMovingObjects:
	call getRenderDataAddress
	; HL > renderData address
	; D > positive or negative direction
	ld c,0 		; launch time
.loop:
	ld a,(hl)
	cp #FF
	ret z
	push hl
	push de
	ld ixh,a
	inc hl
	or (hl)
	jr z,.next
	ld a,(hl)
	ld ixl,a
	ld h,high levelCells
	ld l,(ix+oData.cellId)
	ld a,e
	rrca
	jr c,.checkLeft
	rrca 
	jr c,.checkRight
	rrca 
	jr c,.checkUp
	rrca
	ret nc
.checkDown:
	ld a,l
	ld b,l
	add MAP_WIDTH
	ld l,a
	ld a,(hl)
	ld l,b
	inc a
	jr nz,.procced
.next:
	pop de
	pop hl
	call nextRenderAddress
	jr .loop
.checkLeft:
	dec l
	ld a,(hl)
	inc l
	inc a 		
	jr z,.next
	jr .procced
.checkRight:
	inc l
	ld a,(hl)
	dec l
	inc a 		
	jr z,.next
; 	jr .procced
.procced:
	ld a,(ix+oData.isMovable)
	or a
	jr z,.next
	ld (hl),0
	ld (ix+oData.launchTime),c
	ld (ix+oData.direction),e
	ld a,c
	add MAX_SPEED - 1
	ld c,a
	jr .next
.checkUp:
	ld a,l
	ld b,l
	sub MAP_WIDTH
	ld l,a
	ld a,(hl)
	ld l,b
	inc a
	jr z,.next
	jr .procced
;--------------------------------------------------------------------------
collision:
	; return IY target object data address or IY = 0
	ld iy,0
	ld h,high levelCells
	ld a,(ix+oData.direction)
	or a
	ret z
	ld (ix+oData.clearSide),a
	rrca
	jr c,.moveNegative 	; to left
	rrca 
	jr c,.moveRight 	; to right
	rrca 
	jr c,.moveNegative 	; to up
	rrca 
	ret nc
.moveDown:
	ld e,(ix+oData.x)
	ld a,(ix+oData.y)
	add MAP_WIDTH
	ld d,a
	jr .mr
; 	call getCellIDByCoords
; 	ld l,a
; 	ld a,(hl)
; 	inc a
; 	jr z,alignToCellPositive 	; #FF > wall
; 	dec a
; 	ret z 			; #00 > free way
; 	jp getObjDataById 	; ID`s > #01-#0A convert to object data address
.moveNegative:
	ld e,(ix+oData.x)
	ld d,(ix+oData.y)
	call getCellIDByCoords
	ld l,a
	ld a,(hl)
	inc a
	jr z,alignToCellNegative 	; #FF > wall
	dec a
	ret z 			; #00 > free way
	jp getObjDataById 	; #01-#0A convert to object data address to IY
.moveRight:
	ld a,(ix+oData.x)
	add 16
	ld e,a
	ld d,(ix+oData.y)
.mr:
	call getCellIDByCoords
	ld l,a
	ld a,(hl)
	inc a
	jr z,alignToCellPositive 	; #FF > wall
	dec a
	ret z 			; #00 > free way
	jp getObjDataById 	; #01-#0A convert to object data address
; .moveUp:
; 	ld e,(ix+oData.x)
; 	ld d,(ix+oData.y)
; 	call getCellIDByCoords
; 	ld l,a
; 	ld a,(hl)
; 	inc a
; 	jr z,alignToCellNegative 	; #FF > wall
; 	dec a
; 	ret z 			; #00 > free way
; 	jp getObjDataById 	; #01-#0A convert to object data address


alignToCellPositive:
	ld a,(ix+oData.x)
	and %11110000
	ld (ix+oData.x),a
	ld (ix+oData.preX),a
	ld e,a
	ld a,(ix+oData.y)
	jr atcn
; 	and %11110000
; 	ld (ix+oData.y),a
; 	ld (ix+oData.preY),a
; 	ld d,a
; 	call getCellIDByCoords
; 	ld l,a
; 	ld (ix+oData.cellId),a
; 	ld a,(ix+oData.id)
; 	ld h,high levelCells
; 	ld (hl),a
; 	jr resetMovable
alignToCellNegative:
	ld a,(ix+oData.preX)
	and %11110000
	ld (ix+oData.x),a
	ld (ix+oData.preX),a
	ld e,a
	ld a,(ix+oData.preY)
atcn:
	and %11110000
	ld (ix+oData.y),a
	ld (ix+oData.preY),a
	ld d,a
	call getCellIDByCoords
	ld l,a
	ld (ix+oData.cellId),a
	ld a,(ix+oData.id)
	ld h,high levelCells
	ld (hl),a
resetMovable:
	ld a,(ix+oData.direction)
	ld (ix+oData.direction),0
	ld (ix+oData.delta),0
	ld (ix+oData.accelerate),1
	jp getDrawData
alignToCell:

	; создать тоже самое без ресета для прохождения сквозь объекта но с выравниванием по ячейке
	; если объект не проходной то юзать данную процу.
	;
	;



	ld a,(ix+oData.direction)
	and DIRECTION.LEFT or DIRECTION.UP 
	; if (positive direction) #00 else #FF 
	jr z,alignToCellPositive
	jr alignToCellNegative 
;---------------------------------------------------------

moveObject:
	; return > IY = target object address or IY = #0000
	ld a,(ix+oData.isDestroyed)
	or a
	ret nz
	ld a,(ix+oData.direction)
	or a
	ret z
	ex af,af
	ld a,(ix+oData.launchTime)
	sub 1
	jr c,.start
	ld (ix+oData.launchTime),a
	ret
.moveLeft:
	ld a,(ix+oData.x)
	ld (ix+oData.preX),a
	sub b
	ld (ix+oData.x),a
	ret
.start:
	call accelerate 		; B > step value
	ex af,af
	rrca
	jr c,.moveLeft
	rrca
	jr c,.moveRight
	rrca
	jp c,.moveUp
	rrca 
	ret nc
.moveDown:
	ld a,(ix+oData.y)
	ld (ix+oData.preY),a
	add b
	ld (ix+oData.y),a
	ret
.moveRight:
	ld a,(ix+oData.x)
	ld (ix+oData.preX),a
	add b
	ld (ix+oData.x),a
	ret
.moveUp:
	ld a,(ix+oData.y)
	ld (ix+oData.preY),a
	sub b
	ld (ix+oData.y),a
	ret
;--------------------------------------------------------------------------
accelerate:
	ld a,(ix+oData.delta)
	add ACCELERATE_STEP 		; ACCELERATE_STEP
	ld (ix+oData.delta),a
	ld b,(ix+oData.accelerate)
	ret nc
	ld a,b
	inc a
	ld b,a
	cp MAX_SPEED  		;MAX_SPEED
	ret nc
	ld (ix+oData.accelerate),a
	ret
;-------------------------------------------------
create:
	; HL - objects level data
	ld ix,objectsData 	; objects data storage
	xor a 			; object ID
.nextObject
	inc a 				; next object ID
	ld (ix+oData.id),a 		; save object ID
	ex af,af
	ld a,(hl)
	inc hl
	ld (ix+oData.cellId),a 		; cell id in levelCells
	; set coordinates
	ld c,a
	call getCoordsByCellId
	ld (ix+oData.x),e
	ld (ix+oData.preX),e
	ld (ix+oData.y),d
	ld (ix+oData.preY),d
	; set screen address for draw
	call getScrAddrByCellId
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
	ld a,(hl) 	; cell id
	cp #FF
	ret z 		; exit if #FF
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
	cp ICEHOLE_PBM_ID
	jp z,ICE_HOLE.init
; 	cp SPLIT_PBM_ID
; 	jp z,SPLIT.init
	cp BOOM_01_PBM_ID
	jp z,BOMB.init
	cp BOX_PBM_ID
	jp z,BOX.init

	cp BROKEN_BLOCK_PBM_ID
	jp z,BROKEN_BLOCK.init
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
setDestroyIX:
	ld (ix+oData.isDestroyed),1
	ret
setDestroyIY:
	ld (iy+oData.isDestroyed),1
	ret
/*
	когда объект остановлен - заносим в ячейку карты на месте остановки объекта object ID

	как только объект начинает движение - эта ячейка очищается !!
	перед пунктом выше требуется проверить один раз каждый объект, с целью выяснить разрешено ли движение в требуемом направлении ?
	К примеру могут стоять 2 врага рядом по горизонтали (движение влево)
		слева от них стена = стоят оба
		справа от них стена = оба движутяся

	приминимо только к передвигаемым объектам - isMovable
*/
;----------------------------------------------------------------
resetObjectIX:
	call clear2x2
	ld e,ixl
	ld d,ixh
	ld l,(ix+oData.cellId)
; 	call resetObject
; 	ret
resetObject:
	ld h,high levelCells
	ld (hl),0
	ld h,d
	ld l,e
	inc de
	ld bc,OBJECT_DATA_SIZE - 1
	ld (hl),#00
	ldir
	ret
resetObjectIY:
	ld e,iyl
	ld d,iyh
	ld l,(iy+oData.cellId)
	call resetObject
	ret

	endmodule