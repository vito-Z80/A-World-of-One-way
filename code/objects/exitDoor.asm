	module EXIT_DOOR

init:
	ld (ix+oData.color),%01000100
	xor a
	ld (ix+oData.isMovable),a
	ld (ix+oData.accelerate),a
	ld (ix+oData.drawMethod),a 	; for 2x2 draw
	jp OBJECTS.setObjectId

	endmodule