	module EXIT_DOOR

init:
	ld (ix+oData.color),%01000100
	ld (ix+oData.color),INK.GREEN | PAPER.BLUE | BRIGHTNESS
	xor a
	ld (ix+oData.isMovable),a
	ld (ix+oData.accelerate),a
	ld (ix+oData.drawMethod),a 	; for 2x2 draw
	inc a
	ld (ix+oData.needDraw),a
	jp OBJECTS.setObjectId

	endmodule