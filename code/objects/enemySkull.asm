	module ENEMY_SKULL

init:
	SET_EXEC_IX update
	ld a,1
	ld (ix+oData.isMovable),a
	ld (ix+oData.accelerate),a
	ld (ix+oData.drawMethod),a
	ld (ix+oData.color),2
	jp OBJECTS.setObjectId
;-------------------------------------------
update:

	ld a,(ix+oData.isDestroyed)
	or a
	jr nz,destroyThis
	
	call OBJECTS.collision
	call getDrawData

	xor a
	cp iyh
	ret z
	; IX - this object
	; IY - target object

	call OBJECTS.isSameObject
	jp z,OBJECTS.alignToCell

	cp CHUPA_001_PBM_ID
	jr z,convertToBomb

	cp BOOM_01_PBM_ID
	jp z,CHUPA.setExplosion

	cp HERO_FACE_00_PBM_ID
	jr z,killHero
	

	ret
;-------------------------------------------
killHero:
; 	ld (iy+oData.isDestroyed),1
; 	ret
	ld a,iyl
	ld ixl,a
	ld a,iyh
	ld ixh,a
	jp HERO.dead
	ld (ix+oData.isDestroyed),1
	ld hl,SOUND_PLAYER.DATA.dead
	ld bc,POP_UP_INFO.setWasted
	jp OBJECTS.disableIXObject



convertToBomb:
	ld (ix+oData.isDestroyed),a
	call OBJECTS.alignToCell
	jp CHUPA.setBobm

destroyThis:
	ld hl,SOUND_PLAYER.DATA.eat
	ld bc,POP_UP_INFO.setFear
	jp OBJECTS.disableIXObject
;-------------------------------------------


;-------------------------------------------
	




	endmodule
