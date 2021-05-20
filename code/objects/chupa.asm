	module CHUPA
init:
	SET_EXEC_IX update
; 	call getCurrentLevelNumber
; 	ld a,CHUPA_001_PBM_ID
; 	call numberObjectsType
	xor a
; 	ld hl,coinsInLevelVar
; 	ld (hl),a
; 	inc hl
; 	ld (hl),e
; 	ld h,a
; 	ld l,a
; 	ld (pointsPerLevel),hl
	ld (ix+oData.isMovable),a
	ld (ix+oData.drawMethod),a 	; for 2x2 draw
	ld (ix+oData.accelerate),1
	
	ld (ix+oData.color),%01000110
	ld a,r
	and 3
	ld (ix+oData.animationId),a
	ld c,(ix+oData.cellId)
	call getAttrAddrByCellId
	ld (ix+oData.clrScrAddrL),e
	ld (ix+oData.clrScrAddrH),d
	call OBJECTS.setObjectId
	ret
;------------------------------------
update:
	ld c,%00000011
	call BOMB.blink
	call delta7
	ret nz
	ld hl,CHUPA_001_PBM
	ld c,4
	jp animation2x2
;--------------------------------------
	endmodule
