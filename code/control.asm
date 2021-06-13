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
	ld hl,objectsData + oData.direction
	ld b,MAX_OBJECTS
	ld de,OBJECT_DATA_SIZE
.checkDirection:
	ld a,(hl)
	or a
	ret nz
	add hl,de
	djnz .checkDirection
	ld hl,global_direction
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
	jr nz,sinclairs
set:
	ld a,e
	ld (hl),a 	; set direction to "global_direction"
	ld (preDir),a
	jp OBJECTS.identifyMovingObjects
;-------------------------------------------
enter:
	ld bc,#BFFE
	jr caps + 3
space:
	ld bc,#7FFE
	jr caps + 3
caps:
	ld bc,#FEFE
	in a,(c)
	bit 0,a
	ret
;-------------------------------------------
sinclairs:
	; without fire button
	push hl
	call digListener
	pop hl
	ld a,(de)
	or a
	ret z
	ld e,DIRECTION.LEFT
	; sinclair I
	cp '1'
	jr z,set
	rlc e
	cp '2'
	jr z,set
	rlc e
	cp '4'
	jr z,set
	rlc e
	cp '3'
	jr z,set
	; sinclair II
	ld e,DIRECTION.LEFT
	cp '6'
	jr z,set
	rlc e
	cp '7'
	jr z,set
	rlc e
	cp '9'
	jr z,set
	rlc e
	cp '8'
	jr z,set
	ret
; ;-------------------------------------------
; kempston:
; 	ld a,(kempstonState)
; 	or a
; 	ret z
; 	ld c,0
; 	in a,(#1f)
; 	rrca
; 	jr nc,
; ;-------------------------------------------
numbers:	db "1234509876",0
digListener:
	; return DE = address of digital char [(DE) == 0 = not pressed]
	ld hl,#0505
	ld de,numbers
	ld bc,#F7FE 	; 1-5
.pass:
	in a,(c)
	cpl
	and %00011111
.half
	rrca
	ret c
	inc de
	dec l
	jr nz,.half
	rlc b 		; BC = #EFFE ; 0-6
	cp h
	ret z
	ld l,h
	ld h,a
	jr .pass
	endmodule
