; half-row	DEC	HEX	BIN
; Space...B	32766	7FFE	01111111 11111110
; Enter...H	49150	BFFE	10111111 11111110
; P...Y		57342	DFFE	11011111 11111110
; 0...6		61438	EFFE	11101111 11111110
; 1...5		63486	F7FE	11110111 11111110
; Q...T		64510	FBFE	11111011 11111110
; A...G		65022	FDFE	11111101 11111110
; CS...V	65278	FEFE	11111110 11111110
	module CONTROL
update:
	xor a
	ld hl,global_direction
	or (hl)
	ret nz
	ld e,DIRECTION.LEFT
	ld bc,#DFFE
	in a,(c)
	bit 1,a
	jr z,set
	rlc e 		; DIRECTION.RIGHT
	bit 0,a
	jr z,set
	rlc e 		; DIRECTION.UP
	ld b,#FB
	in a,(c)
	bit 0,a
	jr z,set
	rlc e 		; DIRECTION.DOWN
	ld b,#FD
	in a,(c)
	bit 0,a
	ret nz
set:
	ld (hl),e 	; set direction to "global_direction"
	call OBJECTS.identifyMoving
	; reg E does not deteriorate from the call above, and is passed on to the call below.
	jp OBJECTS.setLaunchTime 
;-------------------------------------------
enter:
	ld bc,#BFFE
	jr caps + 3
;-------------------------------------------
caps:
	ld bc,#FEFE
	in a,(c)
	bit 0,a
	ret
;-------------------------------------------
data:	db "1234509876",0
digListener:
	; return DE = address of digital char [(DE) == 0 = not pressed]
	ld hl,#0505
	ld de,data
	ld bc,#F7FE 	; 1-5
.pass:
	in a,(c)
	cpl
.half
	rrca
	ret c
	inc de
	dec l
	jr nz,.half
	rlc b 		; BC = #EFFE ; 0-6
; 	xor a
	cp h
	ret z
	ld l,h
	ld h,a
	jr .pass
	endmodule
