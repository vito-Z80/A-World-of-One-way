	module SHOP
userCoins:		db "Your coins:     "
coins:			db "   0",TEXT_END
continuations: 		db "Continuations:    50",TEXT_END
invulnerable:		db "Invulnerable:     75",TEXT_END
; skipLevel:		db "Skip level:      100",TEXT_END
currentLevelPassword:	db "Password:        150",TEXT_END
complete:		db "complete.",TEXT_END
;	магазин появляется после прохождения очередного уровня.
; 	можно купить:
; 		пароль на текущий уровень
; 		пропустить текущий уровень
; 		неуязвимость на одно столкновение с врагом или бомбой
; 		continue
;

;---------------------------------------------
init:
	call clearScreen
	call displayShop
	ld a,SYSTEM.SHOP_UPDATE
	ret
;---------------------------------------------
update:
	call waitAnyKey
	ld a,SYSTEM.FADE_OUT
	ld d,SYSTEM.GAME_INIT
	ret
;---------------------------------------------
displayShop:

	ld hl,#4507
	ld (textColor),hl
	ld hl,userCoins
	ld de,#4086
	call printText2x1


	ld hl,#4645
	ld (textColor),hl
	ld hl,continuations
	ld de,#4806
	call printText2x1
	ld hl,invulnerable
	ld de,#4846
	call printText2x1
	ld hl,currentLevelPassword
	ld de,#4886
	call printText2x1

	ld hl,complete
	ld de,#5046
	call printText2x1
	ret
;---------------------------------------------


	endmodule