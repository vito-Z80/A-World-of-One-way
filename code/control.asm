/*
Полуряд	DEC	HEX	BIN
Space...B	32766	7FFE	01111111 11111110
Enter...H	49150	BFFE	10111111 11111110
P...Y	57342	DFFE	11011111 11111110
0...6	61438	EFFE	11101111 11111110
1...5	63486	F7FE	11110111 11111110
Q...T	64510	FBFE	11111011 11111110
A...G	65022	FDFE	11111101 11111110
CS...V	65278	FEFE	11111110 11111110
*/
	module CONTROL


update:
	xor a
	ld hl,global_direction
	or (hl)
	ret nz
	ld bc,#DFFE
	in a,(c)
	bit 0,a
	jr z,toRight
	bit 1,a
	jr z,toLeft
	ld b,#FB
	in a,(c)
	bit 0,a
	jr z,toUp
	ld b,#FD
	in a,(c)
	bit 0,a
	ret nz
toDown:
	ld (hl),DIRECTION.DOWN
	jp OBJECTS.clearCellsForMovableObjects
toUp:
	ld (hl),DIRECTION.UP
	jp OBJECTS.clearCellsForMovableObjects
toLeft:
	ld (hl),DIRECTION.LEFT
	jp OBJECTS.clearCellsForMovableObjects
toRight:
	ld (hl),DIRECTION.RIGHT
	jp OBJECTS.clearCellsForMovableObjects

	endmodule
