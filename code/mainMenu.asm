	module MAIN_MENU
init:
	ld hl,#FFFF
	ld (setFF2),hl
	ld a,l
	ld (setFF1),a

	call fadeOutFull
	call clearScreen
	call clearAttributesBlack
	ld hl,0
	call csBlink
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
; 	ld hl,#0202
; 	call showJoy
	ld hl,#4203
	ld (textColor),hl
	ld hl,info
	ld de,#50c6
	call printText2x1
	ld a,SYSTEM.MAIN_MENU_UPDATE
	ret
;------------------------------------------------
update:
	call SOUND_PLAYER.play
	ld hl,0
	ld a,(delta)
	inc a
	ld (delta),a
	and #3F
	cp #20
	jr c,.noBlink
	ld hl,#0101
.noBlink:
	call csBlink
	call CONTROL.digListener
	ld hl,lastKeyPresed
	ld a,(de)
	cp (hl)
	jr z,.endUpd
	ld (hl),a
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
; 	ld a,29
	ld (currentLevel),a
	ld a,SYSTEM.GAME_INIT
	ret
.continue:
	cp '2'
	jr nz,.kempston
	call SOUND_PLAYER.SET_SOUND.key
	ld a,SYSTEM.PASS_INIT
	ret
.kempston:
; 	cp '3'
; 	jr nz,.endUpd
; 	ld hl,#4404
; 	ld a,(kempstonState)
; 	xor 1
; 	ld (kempstonState),a
; 	jr nz,.joyEnable
; 	ld hl,#0202
; .joyEnable:
; 	call showJoy 
; 	call SOUND_PLAYER.SET_SOUND.key
.endUpd:
	ld a,SYSTEM.MAIN_MENU_UPDATE
	ret
;------------------------------------------------
csBlink:
	ld (textColor),hl
	ld hl,capsSpace
	ld de,#5045
	jp printText2x1
; showJoy:
; 	ld (textColor),hl
; 	ld hl,joystick
; 	ld de,#488a
; 	jp printText2x1
title:
	db "A World of One-Way",TEXT_END
startGameText:
	db "1 - Start",TEXT_END
continueText:
	db "2 - Continue",TEXT_END
info:
	db "Serdjuk for ASM-2021",TEXT_END
; joystick:
; 	db "3 - KEMPSTON",TEXT_END
capsSpace:
	db "CapsEnter to main menu",TEXT_END
	endmodule