	module HERO

init:
	SET_EXEC_IX update
	ld a,1
	ld (ix+oData.isMovable),a
	ld (ix+oData.accelerate),a  	; the initial acceleration of the object during movement, if any.
	ld (ix+oData.drawMethod),a
	ld (ix+oData.color),INK.YELLOW | PAPER.BLACK | BRIGHTNESS
	ld a,l
	and 15
	ld (ix+oData.step),a
	jp OBJECTS.setObjectId
;----------------------------------------------------
getCoin:
	; IY - coin data address
	ld hl,(coins)
	ld bc,10
	add hl,bc
	ld (coins),hl
	call POP_UP_INFO.setPlus10
	ld hl,SOUND_PLAYER.DATA.coin
	call OBJECTS.preDestructionOther
	jp OBJECTS.resetObjectIY
;----------------------------------------------------
update:
	; IX = this object data address
	; IY = target object data address or IY = #0000

	ld a,(ix+oData.isDestroyed)
	or a
	jr nz,dead


	call OBJECTS.collision 		
	; return IY target object data address or IY = 0
	call getDrawData

	xor a
	cp iyh
	ret z

	call OBJECTS.isSameObject
	jp z,OBJECTS.alignToCell

	cp ENEMY_FACE_00_PBM_ID
	jp z,dead

	cp BOOM_01_PBM_ID
; 	jp z,dead
	jp z,BOMB.setExplosion


	cp CHUPA_001_PBM_ID
	jp z,getCoin

	cp ICEHOLE_PBM_ID
	jr z,dead

	cp BROKEN_BLOCK_PBM_ID
	jp z,OBJECTS.alignToCell

	cp BOX_PBM_ID
	jp z,OBJECTS.alignToCell


	cp EXIT_DOOR_PBM_ID
	ret nz
	call OBJECTS.alignToCell
	call OBJECTS.draw.oneObject
	call SOUND_PLAYER.SET_SOUND.done

	ld a,(ix+oData.spriteId)
	call countObjectsSameType
	dec a
	jr z,.leaveLevel
	; stay on level
	call POP_UP_INFO.setMore
	jr finish
.leaveLevel:	
	call POP_UP_INFO.setDone
	ld hl,currentLevel
	inc (hl)
	inc hl 	; isLevelPassed label
	ld (hl),SYSTEM.SHOP_INIT

finish:
	call SYSTEM.int
	ld c,(ix+oData.cellId)
	call getAttrAddrByCellId
	ld a,(ix+oData.color)
	call colorRotate
	ld (ix+oData.color),a
	ex de,hl
	call fillAttr2x2
	push ix
	call POP_UP_INFO.show
	pop ix
	call SOUND_PLAYER.play
	call POP_UP_INFO.isFinish
	jr nz,finish
	jp OBJECTS.resetObjectIX
dead:
	call SOUND_PLAYER.SET_SOUND.dead
	call POP_UP_INFO.setWasted
	call OBJECTS.alignToCell
	call OBJECTS.draw.oneObject
	ld (ix+oData.isDestroyed),1
	call finish
	ld hl,(lives)
	dec hl
	ld (lives),hl
	ld a,l
	or h
	ld a,SYSTEM.MAIN_MENU_INIT
	ld (rebuildLevel),a
	ret z
	ld a,SYSTEM.SHOP_INIT
	ld (rebuildLevel),a
	ret
;----------------------------------------------------

	endmodule
