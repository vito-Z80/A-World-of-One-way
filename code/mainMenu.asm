	module MAIN_MENU
init:
	call fadeOutFull
	call clearScreen
	call clearAttributesBlack

	ld hl,#4347
	ld (textColor),hl
	ld hl,title
	ld de,#4007
	call printText2x1

	ld hl,#0446
	ld (textColor),hl
	ld hl,startGameText
	ld de,#480a
	call printText2x1
	ld hl,continueText
	ld de,#484a
	call printText2x1

	ld hl,#4203
	ld (textColor),hl
	ld hl,info
	ld de,#50c6
	call printText2x1
	ld a,SYSTEM.MAIN_MENU_UPDATE
	ret
;------------------------------------------------
update:
	call CONTROL.digListener
	ld a,(de)
	or a
	jr z,.endUpd
	cp '1'
	jr nz,.continue
	call SOUND_PLAYER.SET_SOUND.key
	ld hl,1
	ld (lives),hl
	dec l
	ld (coins),hl
	; start level number
	xor a
	ld a,0 			; remove later
	ld (currentLevel),a
	ld a,SYSTEM.GAME_INIT
	ret
.continue:
	cp '2'
	jr nz,.endUpd
	call SOUND_PLAYER.SET_SOUND.key
	ld a,SYSTEM.PASS_INIT
	ret
.endUpd:
	ld a,SYSTEM.MAIN_MENU_UPDATE
	ret
;------------------------------------------------
title:
	db "A World of One-Way",TEXT_END
startGameText:
	db "1 - Start",TEXT_END
continueText:
	db "2 - Continue",TEXT_END
info:
	db "Serdjuk for ASM-2021",TEXT_END
	endmodule