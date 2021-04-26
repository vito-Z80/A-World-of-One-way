	module MAIN_MENU
init:
	call fadeOutFull
	call clearScreen
	call clearAttributesBlack
	call createYAdressess
	ld hl,#0446
	ld (textColor),hl
	ld hl,startGameText
	ld de,#4808
	call printText2x1
	ld hl,infoText
	ld de,#4848
	call printText2x1
	ld hl,continueText
	ld de,#4888
	call printText2x1
	ld a,SYSTEM.MAIN_MENU_UPDATE
	ret
;------------------------------------------------
update:
	call keys
	ld a,l
	or a
	ret nz
	ld a,SYSTEM.MAIN_MENU_UPDATE
	ret
;------------------------------------------------
keys:		
	ld l,0
	ld bc,#FDFE
	in a,(c)
	bit 1,a
	jr nz,.keyI
	call SOUND_PLAYER.SET_SOUND.key
	ld hl,34532
	ld (coins),hl
	inc l
	inc l
	ld (lives),hl
	xor a
	ld (currentLevel),a
	ld l,SYSTEM.GAME_INIT
	ret
.keyI:
	ld b,#DF
	in a,(c)
	bit 2,a
	jr nz,.keyP
	call SOUND_PLAYER.SET_SOUND.key
	ld l,SYSTEM.INFO_INIT
	ret
.keyP:
	bit 0,a
	ret nz
	call SOUND_PLAYER.SET_SOUND.key
	ld l,SYSTEM.PASS_INIT
	ret
;------------------------------------------------

startGameText:
	db "Start",TEXT_END
infoText
	db "Info",TEXT_END
continueText:
	db "Continue",TEXT_END

	endmodule