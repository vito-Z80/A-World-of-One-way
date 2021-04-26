	module HERO

init:
	SET_EXEC_IX update
	ld a,1
	ld (ix+oData.isMovable),a
	ld (ix+oData.accelerate),a  	; начальное ускорение объекта при движении, если оно есть.
	ld (ix+oData.drawMethod),a
	ld (ix+oData.color),5
	jp OBJECTS.setObjectId
;----------------------------------------------------
update:
	; IX = this object data address

	ld a,(ix+oData.isLeave)
	or a
	jr nz,.toExit

	ld a,(ix+oData.isDestroyed)
	or a
	jr nz,.lifeLost

	call OBJECTS.objMove
	call OBJECTS.collision
	call getDrawData
	ret

.lifeLost:
	cp 1
	set 1,(ix+oData.isDestroyed)
	call z,POP_UP_INFO.setWasted
	call POP_UP_INFO.isFinish
	ret nz
	ld hl,lives
	dec (hl)
	ld a,SYSTEM.SHOP_INIT
	ld (rebuildLevel),a
	jp OBJECTS.resetObjectIX
; 	jp ENEMY_SKULL.destroyThis
.toExit:
	call POP_UP_INFO.isFinish
	ret nz
	ld a,SYSTEM.GAME_INIT
	ld (rebuildLevel),a
	jp ENEMY_SKULL.destroyThis
;----------------------------------------------------
destroy:
	; IY - this object
	; IX - other object
	ld a,(ix+oData.spriteId)
	cp ENEMY_FACE_00_PBM_ID
	ret nz
	ld (iy+oData.isDestroyed),1
	call SOUND_PLAYER.SET_SOUND.dead
	ret

	endmodule
