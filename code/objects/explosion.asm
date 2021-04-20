	module EXPLOSION
init:
	; HL - cell ID

	ld (iy+oData.spriteId),EXPLOSION_01_PBM_ID
	SET_EXEC_IY update
; 	SET_SPRITE_ADDR_IY EXPLOSION_02_PBM
; 	ld (iy+oData.color),%01000111
	ld (iy+oData.animationId),0
	ld (iy+oData.delta),1
	ld (iy+oData.spriteCounter),5
	ret
.setToCell:
	; C - object ID
	ld a,(hl)
	or a
	ret nz
	ld (hl),c
	ret
;---------------------------------------------
update:

	; нужно печатать еще 4 спрайта вокруг этого, там где это возможно (нет стены)
	; печать должна идти по очереди, каждый следующий страйт в следующем кадре.
	; все 5 спрайтов или даже 2 нельзя печать за 1 кадр !!!

	ld a,(ix+oData.delta)
	inc a
	and 3
	ld (ix+oData.delta),a
; 	jr z,.paintAttr
	ret nz
	ld a,(ix+oData.spriteId)
	ld c,a
	add a
	add a,low animationData
	ld l,a
	adc a,high animationData
	sub l
	ld h,a
	ld a,(hl)
	ld (ix+oData.sprAddrL),a
	inc hl
	ld a,(hl)
	ld (ix+oData.sprAddrH),a
	ld a,c
	inc a
	cp 5
	jr c,$+3
	xor a	
	ld (ix+oData.spriteId),a





; .paintAttr:
	ret
print:



;---------------------------------------------
animationData:
	dw EXPLOSION_02_PBM
	dw EXPLOSION_01_PBM
	dw EXPLOSION_02_PBM
	dw EXPLOSION_03_PBM
	dw EXPLOSION_04_PBM
	db 0
	endmodule