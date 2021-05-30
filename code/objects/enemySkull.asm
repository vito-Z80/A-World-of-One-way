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

	ld a,(ix+oData.isMovable)
	or a
	jr z,stoneStill
	
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
	jp z,BOMB.setExplosion 		; FIXME rebuild

	cp HERO_FACE_00_PBM_ID
	jr z,killHero

	cp ICEHOLE_PBM_ID
	jp z,OBJECTS.alignAndDestroy

	cp BROKEN_BLOCK_PBM_ID
	jp z,OBJECTS.alignToCell

	cp BOX_PBM_ID
	jp z,destroyBox

	
	cp EXIT_DOOR_PBM_ID
	ret nz
	call OBJECTS.alignToCell
	call OBJECTS.draw.oneObject
	ld (ix+oData.needDraw),1
	ld (ix+oData.isMovable),0
	call POP_UP_INFO.setFear
	jp SOUND_PLAYER.SET_SOUND.eat
;-------------------------------------------

stoneStill:
	ld a,#40
	xor (ix+oData.color)
	ld (ix+oData.color),a
	ret
;-------------------------------------------
destroyBox:
	call SOUND_PLAYER.SET_SOUND.impact
	jp OBJECTS.setDestroyIY
killHero:
	call setIYtoIX
	jp HERO.dead

convertToBomb:
	ld (ix+oData.isDestroyed),1
	call setIYtoIX
	jp BOMB.init
destroyThis:
	ld hl,SOUND_PLAYER.DATA.eat
	ld bc,POP_UP_INFO.setFear
	jp OBJECTS.disableIXObject
;-------------------------------------------
	endmodule
