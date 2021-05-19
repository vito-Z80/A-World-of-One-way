	module SHOP
levelText:		db "Level:         ",TEXT_END
userCoins:		db "Coins:         ",TEXT_END
userLives:		db "Lives:         ",TEXT_END
continuations: 		db "1 - Life:             55",TEXT_END
; invulnerable:		db "Invulnerable:     75",TEXT_END
; skipLevel:		db "Skip level:      100",TEXT_END
currentLevelPassword:	db "2 - Password:        120",TEXT_END
complete:		db "fire to complete",TEXT_END
notMoney:		db "not enough money",TEXT_END
successfulPurchase:	db "successful  purchase",TEXT_END	
pricelist:		db "Pricelist:",TEXT_END
;---------------------------------------------
	; FIXME защита от дурака не работает если купить пароль, далее играть и умереть, после смерти в магазине можно опять купить тот-же пароль.
	; 
	;
	;
	;




init:
	call PASS.clearData
	call fadeOutFull
	call clearScreen
	call displayShop
	ld a,SYSTEM.SHOP_UPDATE
	ret
;---------------------------------------------
update:
	ld de,#0e08 	; Y,X
	ld bc,#0210 	; height, width	
	call blinkArea

	ld a,(delta2)
	inc a
	cp 75
	jr c,.m2
	push af
	call hideMessage
	pop af
	dec a
.m2:
	ld (delta2),a
	call showCoinsLives
	ld a,(lastKeyPresed)
	push af
	call CONTROL.digListener
	pop bc
	ld a,(de)
	ld (lastKeyPresed),a 	; save last key pressed
	cp b
 	jr nz,.more

 	; space key
	ld bc,#7FFE
	in a,(c)
	bit 0,a
	jr z,.toGame

	ld a,SYSTEM.SHOP_UPDATE
 	ret
.more:
	cp '1'
	push af
	call z,addLife
	pop af
	cp '2'
	push af
	call z,showPassword
	pop af
	cp '0'
	jr z,.toGame
	cp '5'
	jr z,.toGame
	ld a,SYSTEM.SHOP_UPDATE
	ret nz
.toGame:
	ld a,SYSTEM.GAME_INIT
	ret
;---------------------------------------------
hideMessage:
	xor a
	ld de,#1206 	; Y,X
	ld bc,#0214 	; height, width	
	jp fillArea
;---------------------------------------------
sucPurchaseShow:
	call resetDelta2
	call SOUND_PLAYER.SET_SOUND.coin
	ld hl,#4404
	ld (textColor),hl
	ld hl,successfulPurchase
	ld de,#5046
	jp printText2x1
;---------------------------------------------
notMoneyShow:
	call hideMessage
	call resetDelta2
	call SOUND_PLAYER.SET_SOUND.eat
	ld hl,#4202
	ld (textColor),hl
	ld hl,notMoney
	ld de,#5048
	jp printText2x1
;---------------------------------------------
addLife:
	ld hl,(coins)
	ld de,55
	or a
	sbc hl,de
	jr c,notMoneyShow
	ld (coins),hl
	ld hl,(lives)
	inc hl
	ld (lives),hl
	call sucPurchaseShow
	ret
;---------------------------------------------
showPassword:
	ld a,(passData)
	or a
	jr nz,.show 	; защита от дурака, что бы не купил этот-же пароль еще раз.
	ld hl,(coins)
	ld de,120
	or a
	sbc hl,de
	jr c,notMoneyShow
	ld (coins),hl
	call sucPurchaseShow
	ld a,(currentLevel)
	call PASS.setLevPass
.show:	
; 	call SOUND_PLAYER.SET_SOUND.key
	ld hl,passData
	ld de,#48c8
	jp printText2x1
;---------------------------------------------
displayShop:

	ld hl,#4507
	ld (textColor),hl

	ld hl,levelText
	ld de,#4006
	call printText2x1

	ld hl,userLives
	ld de,#4046
	call printText2x1
	ld hl,userCoins
	ld de,#4086
	call printText2x1


	ld hl,#4344
	ld (textColor),hl
	ld hl,pricelist
	ld de,#480b
	call printText2x1


	ld hl,#4645
	ld (textColor),hl
	ld hl,continuations
	ld de,#4844
	call printText2x1
	ld hl,currentLevelPassword
	ld de,#4884
	call printText2x1

	ld hl,#0141
	ld (textColor),hl
	ld hl,complete
	ld de,#50c8
	call printText2x1
	ret
;---------------------------------------------
showCoinsLives:
	call convertCoin
	ld hl,(lives)
	ld de,livesText
	call asciiConvert
	ld a,(currentLevel)
	inc a
	ld l,a
	ld h,0
	ld de,levelNumberText
	call asciiConvert
	ld hl,#4445
	ld (textColor),hl
	ld hl,levelNumberText
	ld de,#4006+20-5
	call printText2x1
	ld hl,livesText
	ld de,#4046+20-5
	call printText2x1
	ld hl,coinsText
	ld de,#4086+20-5
	jp printText2x1




	endmodule