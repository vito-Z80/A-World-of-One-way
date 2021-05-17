	module BOMB
init:
	SET_EXEC_IX update
	xor a
	ld (ix+oData.isMovable),a
	ld (ix+oData.drawMethod),a 	; for 2x2 draw
	ld (ix+oData.accelerate),1
	ld (ix+oData.color),%01000010
	ld a,r
	and 3
	ld (ix+oData.animationId),a
	ld c,(ix+oData.cellId)
	call getAttrAddrByCellId
	ld (ix+oData.clrScrAddrL),e
	ld (ix+oData.clrScrAddrH),d
	ld (ix+oData.spriteId),BOOM_01_PBM_ID
	jp OBJECTS.setObjectId
;-------------------------------------
update:
	ld a,(ix+oData.isDestroyed)
	or a
	jr nz,explosion

	ld c,%00000100
	call blink
	call delta7
	ret nz
	ld hl,BOOM_01_PBM
	ld c,4
	jp animation2x2
;-------------------------------------
blink:
	; C = XOR value
	ld a,(ix+oData.color)
	xor c
	ld (ix+oData.color),a
	ld l,(ix+oData.clrScrAddrL)
	ld h,(ix+oData.clrScrAddrH)
	jp fillAttr2x2
;-------------------------------------
cellOffset:	db #00,#01,#FF,#10,#F0
explosion:
	ld d,high levelCells
.mLoop:
	call SYSTEM.int
	ld a,(ix+oData.color)
	sub 1
	jp c,OBJECTS.resetObjectIX
	xor #40
	ld (ix+oData.color),a
	ld b,5
	ld e,(ix+oData.cellId)
	ld hl,cellOffset
.loop:
	push bc
	push hl
	push de
	ld a,e
	add (hl)
	ld e,a
	ld c,a
	ld a,(de)
	inc a
	jr z,.noDestroyCell
	dec a
	exx
	call getObjDataById	
	ld (iy+oData.isDestroyed),1
	exx
	call getAttrAddrByCellId
	ex de,hl
	ld a,(ix+oData.color)
	call fillAttr2x2
.noDestroyCell:
	pop de
	pop hl
	inc hl
	pop bc
	djnz .loop
	exx
	push ix
	call SOUND_PLAYER.play
	call POP_UP_INFO.show
	pop ix
	exx
	jr .mLoop
;-------------------------------------
setExplosion:
	; IX - other object
	; IY - this object
	call OBJECTS.alignToCell
	call OBJECTS.draw.oneObject
	ld (ix+oData.isDestroyed),1
	ld (iy+oData.isDestroyed),1
	ld (iy+oData.color),#40
	call POP_UP_INFO.setExplosion
	jp SOUND_PLAYER.SET_SOUND.explosion
;-------------------------------------
	endmodule
