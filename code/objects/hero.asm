	module HERO

init:
	SET_EXEC_IX update
	ld a,1
; 	ld (ix+oData.operated),a 	; объект управляется с клавиатуры
	ld (ix+oData.accelerate),a  	; начальное ускорение объекта при движении, если оно есть.
	ld (ix+oData.drawMethod),a
	ld (ix+oData.isMovable),a
	ld (ix+oData.color),5
	ret
;----------------------------------------------------
update:
	; IX = object data address

; 	call OBJECTS.moveObject

	call OBJECTS.objMove
	call OBJECTS.collision
	call getDrawData
; 	call OBJECTS.cellContents
	ret

	endmodule
