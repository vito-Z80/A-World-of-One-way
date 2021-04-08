	module DEGBUG

grid:
	ld hl,#5800
	ld bc,(%01000111 * 256) + %01000000
.loop:
	ld (hl),b
	inc hl
	ld a,l
	and #1f
	jr z,.loop
	ld a,b
	xor c
	ld b,a
	ld a,h
	cp #5b
	jr c,.loop
	ret

	endmodule
