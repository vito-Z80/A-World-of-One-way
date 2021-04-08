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
	ret
;-------------------------------------------
update:
	ld a,(ix+oData.color)
	add 4
	and 7
	ld (ix+oData.color),a
	call OBJECTS.objMove
	call OBJECTS.collision
	call getDrawData
	ret
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
