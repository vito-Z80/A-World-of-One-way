	module SPLIT
; 	разделяет проходящий свозь объект на 2 объекта.
; 	один из объектов получает инвертированное направление движения.
; 	контроль за превышением лимита объектов на карте не осуществляется.
;----------------------------------------------------------
init:
	SET_EXEC_IX update
	xor a
	ld (ix+oData.isMovable),a
	ld (ix+oData.accelerate),a
	ld (ix+oData.drawMethod),a
	ld (ix+oData.color),3
	jp OBJECTS.setObjectId

;----------------------------------------------------------
update:
	ld a,(ix+oData.isDestroyed)
	or a
	jp nz,ENEMY_SKULL.destroyThis



	ret
;----------------------------------------------------------
splitObject:
	; IY - this object
	; IX - other object
	ld (hl),0 		; reset split on cell
	ld (iy+oData.isDestroyed),1
	ld (iy+oData.color),7
	call findEmptyObject 	; new IY
	ld a,iyh
	or a
	ret z 		; WARNING - no empty objects !!!!!!
	; duplicate object 
	push iy
	pop de
	push ix
	pop hl
	ld bc,OBJECT_DATA_SIZE 
	ldir

; 	ld (iy+oData.color),4
; 	inc (iy+oData.id)

	ld (iy+oData.accelerate),1
	ld a,(ix+oData.x)
	ld (iy+oData.x),a
	ld a,(ix+oData.y)
	ld (iy+oData.y),a

; 	0,1,2,4,8 
;	0,2,1,8,4
	; inverse direction (direction necessarily exists)
	ld c,%00000011
	ld a,(iy+oData.direction)
	cp DIRECTION.UP
	jr c,.next
	rlc c
	rlc c
.next:
	xor c
	ld (iy+oData.direction),a
	ret
;----------------------------------------------------------
findEmptyObject:
	; return IY = address of first empty object, or IY = 0 
	; if IY == 0 -> no empty objects
	ld iy,objectsData 
	ld de,OBJECT_DATA_SIZE
	ld b,MAX_OBJECTS
	xor a
.loop:
	cp (iy+oData.cellId) 	; cell ID == 0 if object is empty. 
	ret z
	add iy,de
	djnz .loop
	ld iyh,a 
	ret
;----------------------------------------------------------

	endmodule
