	module PASS
; 	get passwords from ROM
;--------------------------------------------------
; testPass:
; 	ld hl,0
; 	ld b,22
; .nextP:
; 	push bc
; 	call .onePass
; 	pop bc
; 	djnz .nextP
; 	jr $


; .onePass:
; 	ld de,data
; 	ld b,16
; .loop:
; 	ld a,(hl)
; 	xor l
; 	and 15
; 	cp #0A
; 	jr c,.next
; 	sub 6
; .next:
; 	add #30
; 	ld (de),a
; 	inc hl
; 	inc de
; 	djnz .loop
; 	push hl
; 	ld de,data
; 	ld bc,32
; 	call #203c
; 	pop hl
; 	ret

;--------------------------------------------------



	; FIXME сдвинуть адрес начала генерации паролей за #0038 IM1 либо забить данными до IM1


clearData:
	ld hl,passData
	ld de,passData + 1
	ld bc,PASS_LENGTH
	ld (hl),0
	ldir
	ret
;--------------------------------------------------
setLevPass:
	; A - level number
	ld b,PASS_LENGTH
	ld de,passData
	ld l,a
	ld h,0
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
.loop:
	ld a,(hl)
	xor l
	and 15
	cp #0A
	jr c,.next
	sub 6
.next:
	add #30
	ld (de),a
	inc hl
	inc de
	djnz .loop
	ret	
;--------------------------------------------------
checkPass:
	ld de,0
	ld c,e
	ld b,(LEVELS_BEGIN - LEVELS_MAP) / 2 	; number of levels
.nextPass:
	ld hl,passData
	push bc
	push de

	ld b,PASS_LENGTH
.nextChar:
	ld a,(de)
	xor e
	and 15
	cp #0A
	jr c,.next
	sub 6
.next:
	add #30
	cp (hl)
	jr nz,.nextP
	inc hl
	inc de
	djnz .nextChar
	pop de
	pop bc
	ret

.nextP:
	pop hl
	ld bc,PASS_LENGTH
	add hl,bc
	ex de,hl
	pop bc
	inc c 		; next level number
	djnz .nextPass
	ld c,#FF

	ret
;--------------------------------------------------
init:
	call fadeOutFull
	call clearData
	call clearScreen
	ld a,SYSTEM.PASS_UPDATE
	ret
;--------------------------------------------------
update:


	call input
	call checkPass
	ld a,c
	cp #FF
	ld a,SYSTEM.MAIN_MENU_INIT
	ret z
	ld a,c
	ld (currentLevel),a
	ld a,SYSTEM.SHOP_INIT
	ret
;--------------------------------------------------
inputEnd:
	pop de
	pop hl
	ret
	ld hl,passData
	ld bc,PASS_LENGTH
	xor a
	cpir
	dec hl
	cp (hl)
	ret nz
	call SOUND_PLAYER.SET_SOUND.dead
input:
	call clearData
	call clearScreen
	ld hl,#0141
	ld (textColor),hl
	ld hl,text
	ld de,#40C9 - #40
	call printText2x1
	ld hl,#0405
	ld (textColor),hl
	ld de,#4808
	ld hl,passData
.loop:
	push hl
	push de
.listen:
	halt
	exx
	call SOUND_PLAYER.play
	exx
	call CONTROL.digListener
	ld hl,lastKeyPresed
	call CONTROL.enter
	jr z,inputEnd
	ld a,(de) 	; current key
	cp (hl) 	
	jr z,.listen 	; if current key == last key
	or a
	ld (hl),a 	; save last key pressed
	jr z,.listen
	cp '0'
	jr nz,.notCaps
	ex af,af
	call CONTROL.caps
	jr nz,.notCaps - 1
	; remove last char
	pop de
	pop hl
	ld a,e
	cp #09 		; first input low byte on screen
	jr c,.loop
	dec e
	ld (hl),0
	dec hl
	ld (hl),' '
	push hl
	push de
	call printText2x1
	call SOUND_PLAYER.SET_SOUND.impact
	pop de
	pop hl
	jr .loop
	ex af,af
.notCaps:
	pop de
	pop hl
	ex af,af
	ld a,e
	cp #08 + #10
	jr z,.loop
	ex af,af
	ld (hl),a
.print:
	push hl
	push de
	call printText2x1
	call SOUND_PLAYER.SET_SOUND.key
	pop de
	inc e
	pop hl
	inc hl
	jr .loop
	ret
;--------------------------------------------------
text: 	db "Enter password",TEXT_END
	endmodule
