	module ENEMY_SKULL

init:
	SET_EXEC_IX update
	ld a,1
	ld (ix+oData.isMovable),a
	ld (ix+oData.accelerate),a
	ld (ix+oData.drawMethod),a
	ld a,r
	and 7
	ld (ix+oData.color),a
	jp OBJECTS.setObjectId
;-------------------------------------------
update:
; 	ld a,(ix+oData.color)
; 	add 4
; 	and 7
	ld a,(ix+oData.id)
	inc a
	ret z


	ld a,(ix+oData.isDestroyed)
	or a
	jr nz,destroyThis

	ld a,2
	ld (ix+oData.color),a


	call OBJECTS.objMove
	call OBJECTS.collision
	call getDrawData
	ret
;-------------------------------------------
destroyThis:
	call fadeOut2x2
	or a
	ret nz
	call clear2x2
	jp OBJECTS.resetObjectIX 	; object was destroyed
;-------------------------------------------
target:
	ld a,(ix+oData.spriteId)
	cp HERO_FACE_00_PBM_ID
	jr z,killHero

	ret
;-------
killHero:
	call OBJECTS.resetObjectIX
	ret


;-------------------------------------------
	




	endmodule
