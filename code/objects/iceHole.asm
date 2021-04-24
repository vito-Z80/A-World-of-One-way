	module ICE_HOLE
init:
	SET_EXEC_IX update
	xor a
	ld (ix+oData.isMovable),a
	ld (ix+oData.accelerate),a
	ld (ix+oData.drawMethod),a
	ld (ix+oData.color),5
	ld hl,colorData
	ld (ix+oData.colorDataL),l
	ld (ix+oData.colorDataH),h
	jp OBJECTS.setObjectId

update:
	ld l,(ix+oData.colorDataL)
	ld h,(ix+oData.colorDataH)
	ld a,(hl)
	or a
	jr nz,.next
	ld hl,colorData
	ld a,(hl)
.next:
	ld (ix+oData.color),a
	inc hl
	ld (ix+oData.colorDataL),l
	ld (ix+oData.colorDataH),h
	ret
targetDestroy:
	; IX - target object data
	; IY - this object data
	ld (ix+oData.color),7
	ld (ix+oData.isDestroyed),1
	jp SOUND_PLAYER.SET_SOUND.ice
colorData:
	db PAPER.BLACK or INK.CYAN
	db PAPER.BLACK or INK.BLUE or BRIGHTNESS
	db PAPER.BLACK or INK.CYAN or BRIGHTNESS
	db PAPER.BLACK or INK.BLUE
	db 0

	endmodule
