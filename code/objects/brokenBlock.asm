	module BROKEN_BLOCK
init:
	SET_EXEC_IX update
	ld (ix+oData.color),%01000110
	xor a
	ld (ix+oData.isMovable),a
	ld (ix+oData.accelerate),a
	ld (ix+oData.drawMethod),a 	; for 2x2 draw
	jp OBJECTS.setObjectId
update:
	ld a,(ix+oData.isDestroyed)
	or a
	jp nz,OBJECTS.resetObjectIX
	ret

	endmodule
