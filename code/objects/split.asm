	module SPLIT
init:
	SET_EXEC_IX update
	xor a
	ld (ix+oData.isMovable),a
	ld (ix+oData.accelerate),a
	ld (ix+oData.drawMethod),a
	ld (ix+oData.color),3
	jp OBJECTS.setObjectId

update:
	call blinkBrightness
	ret


	endmodule
