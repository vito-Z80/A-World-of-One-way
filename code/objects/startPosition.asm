	module START_POSITION
init:
	ld (ix+oData.color),2
	xor a
	ld (ix+oData.isMovable),a
	ld (ix+oData.accelerate),a
	ld (ix+oData.drawMethod),a 	; for 2x2 draw
	call OBJECTS.setObjectId
	ret

update:

	ret

	endmodule
