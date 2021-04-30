; 	если герой собирает чупу, то ему +N очков, если моб собирает чупу, то он превращается в бомбу
;	бомба появляется на месте чупы


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
	ld a,r
	and 7
	ld (ix+oData.color),a
	ld a,r
	ld (ix+oData.animationId),a
	call OBJECTS.setObjectId
	ret
;------------------------------------
update:
	ld a,(ix+oData.isDestroyed)
	or a
	jp nz,OBJECTS.resetObjectIX
	ld a,(ix+oData.delta)
	inc a
	ld (ix+oData.delta),a
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
moveUp:
	dec (ix+oData.y) 		; move up
	ld e,(ix+oData.x)
	ld l,(ix+oData.y)
	call getScrAddrByCoords 	; save screen address
	ld (ix+oData.scrAddrL),l
	ld (ix+oData.scrAddrH),h
	ld (ix+oData.color),#FF 	; reset color
	ret
;--------------------------------------
getCoin:
	; HL - level cell

	; transform this object to BOMB or SCORE
	ld a,(ix+oData.spriteId)
	cp HERO_FACE_00_PBM_ID
	jr z,.showScore 	; coin eat by hero
	cp ENEMY_FACE_00_PBM_ID
	ret nz
.showBomb:
	; IY - this object
	; IX - other object
	; coin eat by enemy
	; convert coin to bomb
	; установка в spriteId работает только с анимированными объектами, так как обращается к переменной для получения начального адреса анимации
	; то есть, если спрайт состит из 1 кадра, то новый адрес спрайта нужно заносить в (sprAddrHL)
	ld (iy+oData.spriteId),BOOM_01_PBM_ID 	; the coin became a bomb
	ld (ix+oData.isDestroyed),1 		; destroy other object
	ld (ix+oData.color),7 			; set other object color
	ld (iy+oData.color),2 			; set bomb color 
	call POP_UP_INFO.setFear
	jp SOUND_PLAYER.SET_SOUND.eat
.showScore:
	; IY - this object
	; IX - other object
	; convert chupa to score and move
	; set 0 to cell for free move 
	ld (hl),0 	
	ld (iy+oData.isDestroyed),1 		; destroy this (coin)
	call POP_UP_INFO.setPlus10
	ld hl,coinsInLevelVar
	inc (hl)

	ld bc,10

	
; 	ld hl,(pointsPerLevel)
; 	add hl,bc
; 	ld (pointsPerLevel),hl

	ld hl,(coins)
	add hl,bc
	ld (coins),hl
	jp SOUND_PLAYER.SET_SOUND.coin

explosion:
	; IY - this object
	; IX - other object
	ld (ix+oData.isDestroyed),1 		; destroy other object
	call POP_UP_INFO.setExplosion

; 	ld (iy+oData.spriteId),EXPLOSION_01_PBM_ID
	SET_EXEC_IY .showExplosion
	ld (iy+oData.animationId),0
	ld (iy+oData.delta),0
	jp SOUND_PLAYER.SET_SOUND.explosion

.showExplosion: 	; replaces update
	; IX - this object
	ld a,(ix+oData.isDestroyed)
	or a
	jp nz,OBJECTS.resetObjectIX

	ld c,(ix+oData.color)
	ld a,(ix+oData.delta)
	inc a
	cp 32
	jr nc,.destroy
	ld (ix+oData.delta),a
	and 3
	jr nz,.cont

	ld a,c
	call colorRotate
	ld c,a
	ld (ix+oData.color),a
.cont:
	ld c,a
	rlc c
	rlc c
	rlc c
	or c
	; A` - color
.begin:
	ex af,af
	ld h,high levelCells
	ld l,(ix+oData.cellId)
	; HL - cell ID
	ld e,(ix+oData.scrAddrL)
	ld d,(ix+oData.scrAddrH)
	call scrAddrToAttrAddr
	; DE - attribute address
	push de
	push de
	push de
	push de
	call .setColor
	pop de
	; left
	dec e
	dec e
	dec l
	ld a,(hl)
	inc a
	call .setColor
	pop de
	; top
	ld a,l
	sub 15
	ld l,a
	ex de,hl
	ld bc,#10000 - 64
	add hl,bc
	ex de,hl
	ld a,(hl)
	inc a
	call .setColor
	pop de
	; right
	ld a,l
	add 17
	ld l,a
	ex de,hl
	inc l
	inc l
	ex de,hl
	ld a,(hl)
	inc a
	call .setColor
	pop de
	; bottom
	ld a,l
	add 15
	ld l,a
	ex de,hl
	ld bc,64
	add hl,bc
	ex de,hl
.setColor:
	ld a,(hl)
	inc a 		; #FF = WALL; inc a = #00
	ret z
	call .resetWithoutThis
	ex af,af
	ex de,hl
	call fillAttr2x2 	; required: HL - attribute address
	ex de,hl
	ex af,af
	ret
.destroy:
	ld (ix+oData.isDestroyed),1
	xor a
	call .begin
	ret
.resetWithoutThis:
	; set "isDestroyed" for all objects without this object (bomb)
 	push hl
 	ld a,(hl)
 	call getObjDataById
 	ld a,(iy+oData.spriteId)
 	cp BOOM_01_PBM_ID
 	jr z,$+6
 	ld (iy+oData.isDestroyed),1
 	pop hl
	ret

; explosion:
; 	ld (ix+oData.isDestroyed),1 		; destroy other object
; 	call POP_UP_INFO.setExplosion
; 	call EXPLOSION.init
; 	jp SOUND_PLAYER.SET_SOUND.explosion


	endmodule
