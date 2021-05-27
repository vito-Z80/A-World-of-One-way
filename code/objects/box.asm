	module BOX
init:
	SET_EXEC_IX BROKEN_BLOCK.update
	ld (ix+oData.color),%01000011
	xor a
	ld (ix+oData.isMovable),a
	ld (ix+oData.accelerate),a
	ld (ix+oData.drawMethod),a 	; for 2x2 draw
	inc a
	ld (ix+oData.needDraw),a
	jp OBJECTS.setObjectId

	endmodule
