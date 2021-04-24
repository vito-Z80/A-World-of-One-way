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
; 	or a
	ret nz
	call clear2x2
	jp OBJECTS.resetObjectIX 	; object was destroyed
;-------------------------------------------
target:
	; IY - this object
	; IX - other object
	ld a,(ix+oData.spriteId)
	cp HERO_FACE_00_PBM_ID
	ret nz
	ld (ix+oData.isDestroyed),1
	call SOUND_PLAYER.SET_SOUND.dead
	ret


;-------------------------------------------
	




	endmodule
