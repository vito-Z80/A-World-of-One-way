	module EXIT_DOOR

init:
; 	ld de,update
; 	ld (ix+oData.exec),e
; 	ld (ix+oData.exec + 1),d
	ld (ix+oData.color),1
	xor a
	ld (ix+oData.isMovable),a
	ld (ix+oData.accelerate),a
	ld (ix+oData.drawMethod),a 	; for 2x2 draw
	jp OBJECTS.setObjectId



; update:

; 	ret



	endmodule