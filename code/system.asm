	org #5E00
	module SYSTEM
;------------------------------------
run:




	call SOUND_PLAYER.SET_SOUND.mute
	ld sp,#8000
	;----------------------------test code
	ld hl,0
	ld bc,100
	ld a,#18
	cpir

	
	;----------------------------test code
	xor a
	inc a 		; remove later
	out (254),a
	ld bc,$
	; A - system ID
	rlca
	add a,low rooms
	ld l,a
	adc a,high rooms
	sub l
	ld h,a
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
	exx
	call SOUND_PLAYER.play
	exx
	BORDER 0
	ei
	halt
	push bc
	jp (hl)
;------------------------------------
	; system indices and addresses
rooms:	
TITLE:			equ 0
			dw TITLE_2.run
MAIN_MENU_INIT:		equ 1
			dw MAIN_MENU.init
MAIN_MENU_UPDATE:	equ 2
			dw MAIN_MENU.update
GAME_INIT:		equ 3
			dw GAME.init
GAME_UPDATE:		equ 4
			dw GAME.update
INFO_INIT:		equ 5
			dw 0
INFO_UPDATE:		equ 6
			dw 0
			; fade out and next system ID
FADE_OUT:		equ 7
			dw fadeOutFull
;------------------------------------
	endmodule
