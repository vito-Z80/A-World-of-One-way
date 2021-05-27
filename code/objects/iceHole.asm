	module ICE_HOLE
init:
	SET_EXEC_IX update
	xor a
	ld (ix+oData.isMovable),a
	ld (ix+oData.accelerate),a
	ld (ix+oData.drawMethod),a
	inc a
	ld (ix+oData.needDraw),a
	ld (ix+oData.color),5
	ld c,(ix+oData.cellId)
	call getAttrAddrByCellId
	ld (ix+oData.clrScrAddrL),e
	ld (ix+oData.clrScrAddrH),d
	jp OBJECTS.setObjectId
;-------------------------------------
update:
	ld c,%01000100
	jp BOMB.blink

	endmodule
