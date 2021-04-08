; 	если герой собирает чупу, то ему +N очков, если моб собирает чупу, то он превращается в бомбу
;	бомба появляется на месте чупы


	module CHUPA
init:
	SET_EXEC_IX update
	xor a
	ld (ix+oData.isMovable),a
	ld (ix+oData.drawMethod),a 	; for 2x2 draw
	ld (ix+oData.accelerate),1
	ld a,r
	and 7
	ld (ix+oData.color),a
	ld a,r
	ld (ix+oData.animationId),a
	call OBJECTS.setObjectId
	ret
;------------------------------------
update:

	ld a,(ix+oData.delta)
	inc a
	ld (ix+oData.delta),a
	push af
	and 3
	call z,rotateColor
	pop af
	and 7
	or a
	ret nz

	ld a,(ix+oData.spriteId)
	call getSpriteAddr

	ld a,(ix+oData.animationId)
	and 3
	push af
	rrca
	rrca
	rrca
	add a,l
	ld l,a
	adc a,h
	sub l
	ld h,a
	ld (ix+oData.sprAddrL),l
	ld (ix+oData.sprAddrH),h
	pop af
	inc a
	cp 4
	jr c,.updAnim
	xor a
.updAnim:
	ld (ix+oData.animationId),a

	ret
;--------------------------------------
rotateColor:
	ld a,(ix+oData.color)
	inc a
	and 7
	ld (ix+oData.color),a
	ret
;--------------------------------------
moveUp:
	dec (ix+oData.y) 		; move up
	call getScrAddrByCoords 	; save screen address
	ld (ix+oData.color),#FF 	; reset color
	ret
;--------------------------------------
transform:
	; HL - level cell
	; transform this object to BOMB or SCORE
	ld a,(ix+oData.spriteId)
	cp HERO_FACE_00_PBM_ID
	jr z,.showScore
	cp ENEMY_FACE_00_PBM_ID
	ret nz
.showBomb:
	call LEVEL.drawFloorCellIX
	; convert chupa to bomb
	call OBJECTS.resetObjectIX
	; установка в spriteId работает только с анимированными объектами, так как обращается к переменной для получения начального адреса анимации
	; то есть, если спрайт состит из 1 кадра, то новый адрес спрайта нужно заносить в (sprAddrHL)
	ld (iy+oData.spriteId),BOOM_01_PBM_ID
	ret
.showScore:
	; convert chupa to score and move
	; set 0 to cell for free move 
	ld (hl),0 	
	; set score sprite for chupa sprite
	SET_SPRITE_ADDR_IY SCORE_PBM
	; set exec "moveUp"
	SET_EXEC_IY CHUPA.moveUp
	ret
destroy:
	; destroy bomb and object
	ld (hl),0
	call LEVEL.drawFloorCellIX
	call OBJECTS.resetObjectIX
	call LEVEL.drawFloorCellIY
	call OBJECTS.resetObjectIY
	ret


	endmodule
