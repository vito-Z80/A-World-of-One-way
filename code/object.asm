	module OBJECTS


;----------------------------------------------------------------
clear:
	ld ix,objectsData
	ld b,MAX_OBJECTS
	ld de,32
.loop:
	push bc


	ld a,(ix+oData.clearSide)
	or a
	jr z,.next


	ld l,(ix+oData.clrScrAddrL)
	ld h,(ix+oData.clrScrAddrH)
	rrca
	call c,.clearLeft
	rrca 
	call c,.clearRight
	rrca 
	call c,.clearUp
	rrca 
	call c,.clearDown
.next:
	ld bc,OBJECT_DATA_SIZE
	add ix,bc
	pop bc
	djnz .loop
	ret
.clearUp:
	ld a,(ix+oData.y)
	sub (ix+oData.preY)
	jr z,.clearFlagAndSide
	ld b,a
	ex de,hl
.nextLine:
	xor a
	ld (de),a
	inc e
	ld (de),a
	dec e
	call nextLine
	djnz .nextLine
	jr .clearFlagAndSide
.clearDown:
	ld l,(ix+oData.scrAddrL)
	ld h,(ix+oData.scrAddrH)
	call nextLine16
	ld a,(ix+oData.preY)
	sub (ix+oData.y)
	jr .nextLine - 4

.clearLeft:

; 	dec l
	ld b,2
.clearSymbol:
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
	djnz .clearSymbol
.clearFlagAndSide:
	xor a
	ld (ix+oData.clearSide),a
	ret

.clearRight:

	; нужен фикс !!!!!!!!!!!!!!!!!!!!!!!
	; когда объект останоавливается упираясь в препядствие, не происходит отчистки хвоста с правого края объекта !!!!!!!
	; 

	
	; сраный костыль
	ld a,(ix+oData.accelerate)
	dec a
	jr z,.cutIncL





	inc l
.cutIncL:
	inc l


	jr .clearSymbol - 2
;----------------------------------------------------------------
draw:
	ld ix,objectsData
	ld b,MAX_OBJECTS
.loop:
	push bc
; 	ld a,(ix+oData.id)
; 	inc a
; 	jr z,.end 			; #FF = empty object
	ld e,(ix+oData.scrAddrL) 	; scr addr low
	ld d,(ix+oData.scrAddrH) 	; scr addr high
	ld a,d
	or e
	jr z,.end
	push de
	call paint 			; FIXME перенести в update каждого объекьа !!!!!!!!
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
	ld a,(ix+oData.spriteId)
	cp CHUPA_001_PBM_ID
	jp z,circularGradient
	cp BOOM_01_PBM_ID
	jp z,flashRedYellow
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
	ld ix,objectsData
	ld b,MAX_OBJECTS
.loop:
	push bc
	ld l,(ix+oData.exec)
	ld a,(ix+oData.exec + 1)
	ld h,a
	or l
	jr z,.next
	ld bc,.next
	push bc
	jp (hl)
.next:
	ld de,OBJECT_DATA_SIZE
	add ix,de 	; next object data
	pop bc
	djnz .loop
	ret
;----------------------------------------------------------------
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
setLaunchTime:
	; called after "identifyMoving" from CONTROL.update
	; E = DIRECTION
	; Установка времени до начала движения объекта осуществляется следующим образом:
	; Вычисляется самый дайльний объект/ы по направлению движения, время на запуск для него/них будет = 0 (моментальный старт) 
	; Остальным объектам задается время равное +1 на каждую ячейку (16х16) в противоположную сторону от дальнего объекта.


 	; TODO
	; можно сделать следующее: не опрашивать объект если перед ним 100% стена, тогда отсчет времени до запуска проскочит его
	; иначе такой объект будет стоять на дальней позиции, а более близкие объекты будут стартовать с заметным запозданием.

	ld a,e
	and DIRECTION.LEFT or DIRECTION.UP 
	neg
	ld d,a
	; D = if (positive direction) #00 else #FF 

	ld ix,objectsData
	ld b,MAX_OBJECTS
.loop:
	push bc
	ld a,(ix+oData.isMovable)
	or a
	jr z,.next
	ld a,(ix+oData.isDestroyed)
	or a
	jr nz,.next
	call .findDistantObject
.next:
	ld bc,OBJECT_DATA_SIZE
	add ix,bc
	pop bc
	djnz .loop
	; D = maximum coordination unit
	xor a
	cp d
	ret z 		; если не было передвигаемых объектов
	; set launch time to any movable object
	ld ix,objectsData
	ld b,MAX_OBJECTS
.loop2:
	push bc
	ld a,(ix+oData.isMovable)
	or a
	jr z,.next2
	call .setTimeToObject
.next2:
	ld bc,OBJECT_DATA_SIZE
	add ix,bc
	pop bc
	djnz .loop2
	ret
;-------
.setTimeToObject:
	ld a,e
	rrca
	jr c,.timeToLeftDirObj
	rrca
	jr c,.timeToRightDirObj
	rrca
	jr c,.timeToUpDirObj
	rrca
	ret nc
; time for down direction object
	ld a,d
	sub (ix+oData.y)
.convToTime:
	; convert to launch timer
	rrca
	rrca
; 	rrca
; 	rrca
	ld (ix+oData.launchTime),a
	ret
.timeToLeftDirObj:
	ld a,(ix+oData.x)
	sub d
	jr .convToTime
.timeToRightDirObj:
	ld a,d
	sub (ix+oData.x)
	jr .convToTime
.timeToUpDirObj:
	ld a,(ix+oData.y)
	sub d
	jr .convToTime

;-------
.findDistantObject:
	; IX = objectsData 
	; E = DIRECTION
	; return D if D < A or set A to D for positive direction
	; return D if D > A or set A to D for negative direction
	ld a,e
	rrca
	jr c,.negativeLeft
	rrca
	jr c,.positiveRight
	rrca 
	jr c,.negativeUp
	rrca
	ret nc
; positive down
	ld a,(ix+oData.y)
	jr .positiveRight + 3
.negativeLeft:
	ld a,(ix+oData.x)
	cp d
	ret nc 		; D >= A
	; set D min (D < A)
	ld d,a
	ret
.positiveRight:
	ld a,(ix+oData.x)
	cp d
	ret c 		; D < A
	; set D max (D >= A)
	ld d,a
	ret
.negativeUp:
	ld a,(ix+oData.y)
	jr .negativeLeft + 3
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
	ld (ix+oData.y),d
	ld (ix+oData.preY),d
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
	cp ICEHOLE_PBM_ID
	jp z,ICE_HOLE.init
	cp SPLIT_PBM_ID
	jp z,SPLIT.init

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
copyAddrForClear:
	; клпируем адрес экранной области рисования спрайта для последующей отчистки этой области.
	ld a,(ix+oData.scrAddrL)
	ld (ix+oData.clrScrAddrL),a
	ld a,(ix+oData.scrAddrH)
	ld (ix+oData.clrScrAddrH),a
	ret
;----------------------------------------------------------------
objMove:
	; for movable objects


	; wait process for launch
	ld a,(ix+oData.launchTime)
	or a
	jr z,.startMove
	dec a
	ld (ix+oData.launchTime),a
	ret
.startMove:
	ld a,(ix+oData.direction)
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
	call copyAddrForClear
	ld (ix+oData.clearSide),DIRECTION.UP
	ret
;-------
stepUp:
	call accelerate
	ld a,(ix+oData.y)
	ld (ix+oData.preY),a
	sub (ix+oData.accelerate)
	ld (ix+oData.y),a
	call copyAddrForClear
	ld (ix+oData.clearSide),DIRECTION.DOWN
	ret
;-------
stepLeft:
	call accelerate
	ld a,(ix+oData.x)
	ld (ix+oData.preX),a
	sub (ix+oData.accelerate)
	ld (ix+oData.x),a
	call copyAddrForClear
	ld (ix+oData.clearSide),DIRECTION.RIGHT
	ret
;-------
stepRight:
	call accelerate
	ld a,(ix+oData.x)
	ld (ix+oData.preX),a
	add (ix+oData.accelerate)
	ld (ix+oData.x),a
	call copyAddrForClear
	ld (ix+oData.clearSide),DIRECTION.LEFT
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
zeroMotion:
	ld c,l
	; выровнять координаты по ячейке
	call getCoordsByCellId
	ld (ix+oData.x),e
	ld (ix+oData.y),d
; 	ld (ix+oData.preX),e
; 	ld (ix+oData.preY),d

	; костыль нужен что бы не проигрывался звук SOUND_PLAYER.SET_SOUND.impact
	; так как при уничтожении объекты имеют разные звуки.
	ld a,(ix+oData.isDestroyed)
	or a
	ret nz

	ld (ix+oData.cellId),l
	ld (ix+oData.accelerate),1 	
	ld (ix+oData.direction),0
	ld (ix+oData.delta),0
	ld a,(ix+oData.id)
	ld (hl),a 	; когда объект остановлен - заносим его object ID в ячейку карты. 
; 	call SOUND_PLAYER.SET_SOUND.key
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
; 	ld (ix+oData.clearSide),0
	jr zeroMotion
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
	jr zeroMotion
;-----------------
targetCell:
	; HL - level cell
	; A - object ID
	cp #FF
	ret z 		; wall on way
	push hl
	push iy
	call .targetCellExe
	pop iy
	pop hl
	ret
.targetCellExe:

	ex de,hl
	call getObjDataById  	; get IY - target object address
	ex de,hl
	; IX > current object
	; IY > target object
	; HL > level cell
	; этими данными можно пользоваться для взаимодействия объектов.
	ld a,(iy+oData.spriteId)
	cp EXIT_DOOR_PBM_ID
	jp z,GAME.setNextLevel


	cp HERO_FACE_00_PBM_ID
	jp z,HERO.destroy

	cp CHUPA_001_PBM_ID
	jp z,CHUPA.getCoin


	cp ICEHOLE_PBM_ID
	jp z,ICE_HOLE.targetDestroy


	cp BOOM_01_PBM_ID
	jp z,CHUPA.explosion


	cp SPLIT_PBM_ID
	jp z,SPLIT.splitObject



	cp ENEMY_FACE_00_PBM_ID
	jp z,ENEMY_SKULL.target




	//.......
	ret
;----------------------------------------------------------------
; 	Возможно ли движение в указанном направлении ?
; 	
; 	Получаем ячейку объекта, проверяем соседнюю ячейку по направлению движения.
;		Движение разрешено если:
;			соседняя ячейка содержит #00 (free way)
;		Движение запрещено если:
;			соседняя ячейка содержит #FF,#FE (wall, breakable wall)
;
;		Если ячейка содержит #01-#0A (object ID`s)
; 			Нужно проверить следующую ячейку по тому-же направлению, пока не встретим #00,#FF,#FE
;			#00 > 		установить всем сопутствующим объектам направление движения
;			#FF,#FE >	обнулить всем сопутствующим объектам направление движения
;
;
;
identifyMoving:
	; E - DIRECTION (from control)
	ld ix,objectsData
	ld h,high levelCells

	ld b,MAX_OBJECTS
.loop:
	push bc
	ld a,(ix+oData.isMovable)
	or a
	jr z,.next
	ld a,(ix+oData.isDestroyed)
	or a
	jr nz,.next
	ld l,(ix+oData.cellId)
	ld d,l 		; save cell ID to D
	ld a,e
	rrca
	call c,.whoLeft
	rrca
	call c,.whoRight
	rrca
	call c,.whoUp
	rrca
	call c,.whoDown
.next:
	ld bc,OBJECT_DATA_SIZE
	add ix,bc
	pop bc
	djnz .loop
	ret
.whoLeft:
	dec l
	ld a,(hl)
	or a
	jr z,.setDirection  	; (hl) == #00 > free way
	jp p,.whoLeft 		; next cell if (hl) <= #7F
	jr .resetDirection 	; (hl) > #7F
.whoRight:
	inc l
	ld a,(hl)
	or a
	jr z,.setDirection  	; (hl) == #00 > free way
	jp p,.whoRight		; next cell if (hl) <= #7F
	jr .resetDirection
.whoUp:
	ld a,l
	sub MAP_WIDTH
	ld l,a
	ld a,(hl)
	or a
	jr z,.setDirection  	; (hl) == #00 > free way
	jp p,.whoUp		; next cell if (hl) <= #7F
	jr .resetDirection
.whoDown:
	ld a,l
	add MAP_WIDTH
	ld l,a
	ld a,(hl)
	or a
	jr z,.setDirection  	; (hl) == #00 > free way
	jp p,.whoDown		; next cell if (hl) <= #7F
	jr .resetDirection
.setDirection:
	; clear cell and set direction
	ld l,d 		; return cell ID
	ld (hl),0
	ld (ix+oData.direction),e
	ret
.resetDirection:
	; reset direction and set object ID to cell
	ld l,d 		; return cell ID
	ld a,(ix+oData.id)
	ld (hl),a
	ld (ix+oData.direction),0
	ret
;----------------------------------------------------------------
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
	ld h,high levelCells
	ld (hl),0
	call resetObject
; 	ld (ix+oData.id),#FF
	ret
resetObject:
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
	ld h,high levelCells
	ld (hl),0
	call resetObject
; 	ld (iy+oData.id),#FF
	ret
	endmodule
