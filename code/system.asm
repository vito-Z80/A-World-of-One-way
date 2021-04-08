	org #6000
	module SYSTEM
;------------------------------------
run:
; 	ld hl,#5b08
; 	ld (attrScrollAddr),hl
; 	ld a,7
; .loop:
; 	ei
; 	halt

; 	ld hl,#5800
; 	ld de,#5801
; 	ld bc,767
; 	ld (hl),7
; 	ldir

; 	call attrScoreShow


; 	jr .loop

; 	jr $
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
;------------------------------------
	endmodule
