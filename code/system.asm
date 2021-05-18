	module SYSTEM
;------------------------------------
run:

	ld sp,#8000
	call SOUND_PLAYER.SET_SOUND.mute
	xor a
; 	inc a 		; remove later
	out (254),a
	;----------------------------test code

	


; 	ld hl,#5900
; 	ld de,#5901
; 	ld bc,#ff
; 	ld (hl),99
; 	ldir

; 	ld hl,#48ff
; 	ld (hl),#FF
; 	call getCellIdByScrAddr
; 	ld c,a
; 	call getScrAddrByCellId
; 	ld a,%01010101
; 	ld (de),a
; 	jr $

; 	ld a,9
; 	and  15
; 	add  a,#90
; 	daa
; 	adc  a,#40
; 	daa


	
	;----------------------------test code
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
	call int
	push bc
	jp (hl)
;------------------------------------
int:
	ld iy,#5C3A
	ei
	halt
	di
	ret
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
PASS_INIT: 		equ 7
			dw PASS.init
PASS_UPDATE: 		equ 8
			dw PASS.update

SHOP_INIT: 		equ 9
			dw SHOP.init
SHOP_UPDATE: 		equ 10
			dw SHOP.update
;------------------------------------
	endmodule
