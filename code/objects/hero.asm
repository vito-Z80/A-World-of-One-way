	module HERO

init:
	SET_EXEC_IX update
	ld a,1
	ld (ix+oData.isMovable),a
	ld (ix+oData.accelerate),a  	; начальное ускорение объекта при движении, если оно есть.
	ld (ix+oData.drawMethod),a
	ld (ix+oData.color),5
	jp OBJECTS.setObjectId
;----------------------------------------------------
update:
	; IX = this object data address



	call OBJECTS.objMove
	call OBJECTS.collision
	call getDrawData



	ret

	endmodule
