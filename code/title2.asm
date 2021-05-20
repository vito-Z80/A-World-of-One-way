objectsData: 	; moved from variables since this part of the program is used only 1 time at start !!! takes 344 bytes, 320 is required!
;	Concurso juegos ASM 2021
	module TITLE_2
run:
	ld a,1
	call clearAttributes
	call clearScreen

	ld hl,path
	ld (pathAddress),hl
	ld a,#80
	ld (byteValue),a
	ld hl,#5900
	ld de,#5901	
	ld bc,#ff
	ld (hl),e
	ldir
	call process
;-------------------------------------------------------------
	ld hl,#0406
	ld (textColor),hl
	ld de,#5028
	ld hl,text
	call printText2x1
aPoint:
	ld hl,#4242
	ld (#5942),hl
	ld hl,#4842
	ld a,%00001111
	ld c,%11110000
	ld b,8
.aP:
	ei 
	halt
	ld (hl),a
	inc l
	ld (hl),c
	dec l
	inc h
	djnz .aP
	call waitAnyKey
	ld a,SYSTEM.MAIN_MENU_INIT
	ret
;-------------------------------------------------------------
process:
	ld ix,(pathAddress)
	ld b,8
	ld a,(byteValue) 	; top-left bit
	cp %11111111 		; full byte
	jr nz,.loop - 1
	inc ix
	ld (pathAddress),ix 	; next address of path
	dec ix
	ld c,a
.loop:
	ei 
	halt
	halt
; 	halt
	ld a,(ix) 		; get cell (symbol)
	or a
	ret z
	push bc
	call .fillPath
	pop bc
	ld a,c
	rrca
	jr z,.fin
	or c
	ld c,a
	djnz .loop
.fin:
	ld a,(byteValue)
	ld c,a
	rrca
	or c
	ld (byteValue),a
	jr process

.fillPath:
	ld a,(ix)
	inc ix
	or a
	ret z
	ld l,a
	ld b,c
	ld h,#48
	call .symbol
	ld c,b
	sla c
	jr nz,.fillPath
	ret
.symbol:
	ld a,h
	cpl
	and 7
	add #48 	; high byte of second third
	ld d,a
	ld e,l
	push hl
	ld a,c
; reverse bits in A
; 17 bytes / 66 cycles
; Posted by John Metcalf
; http://www.retroprogramming.com/2014/01/fast-z80-bit-reversal.html
	ld l,a    ; a = 76543210
	rlca
	rlca      ; a = 54321076
	xor l
	and 0xAA
	xor l     ; a = 56341270
	ld l,a
	rlca
	rlca
	rlca      ; a = 41270563
	rrc l     ; l = 05634127
	xor l
	and 0x66
	xor l     ; a = 01234567
; end of reverse bits in A
	ld l,a
	ld a,(de)
	or l
	ld (de),a
	pop hl
	ld a,(hl)
	or c
	ld (hl),a
	inc h
	sla c
	ret z
	jr .symbol
; template:
; 	db 0,1,1,1,1,0,1,1,1,1,1,1,0,0,0,1,0,1,1,1,0,1,1,1,0,1,1,1,0,0,1,0
; 	db 0,1,0,0,1,0,1,0,0,0,0,0,1,0,1,1,0,0,0,1,0,1,0,1,0,0,0,1,0,1,1,0
; 	db 0,1,1,1,1,0,1,1,1,1,0,0,0,1,0,1,0,1,1,1,0,1,0,1,0,1,1,1,0,0,1,0
; 	db 0,1,0,0,1,0,0,0,0,1,0,1,0,0,0,1,0,1,0,0,0,1,0,1,0,1,0,0,0,0,1,0
; 	db 0,1,0,0,1,0,0,0,0,1,0,1,0,0,0,1,0,1,0,0,0,1,0,1,0,1,0,0,0,0,1,0
; 	db 0,1,0,0,1,1,1,1,1,1,0,1,0,0,0,1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1,1
; 	db 0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
; 	db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

	; addresses of low byte screen symbol (cell)
path:
	db 161,129,97,65,33,1,2,3,4,36,68,100,132,164 			; A
	db 165,166,167,168,169,137,105,73,72,71,70,38,6,7,8,9,10,11	; S
	db 44,77,46,15,47,79,111,143,175 				; M
	db 179,178,177,145,113,81,82,83,51,19,18,17			; 2
	db 21,53,85,117,149,181,182,183,151,119,87,55,23,22,21 		; 0
	db 25,26,27,59,91,90,89,121,153,185,186,187 			; 2
	db 189,190,191,158,126,94,62,30,61 				; 1
	; bottom line + piece of M
	db 255,254,253,252,251,250,249,248,247,246,245,244,243,242,241,240
	db 239,238,237,236,235,203,234,171,233,139,232,107,231,230,229,228,227,226,225
	db 0 	; end of path
text:
	db "Concurso juegos ASM 2021",TEXT_END

	display "TITLE code may used after start program !!!"
	display "TITLE start address: ",/A,run
	display "TITLE code length: ",/A,$ - run
	endmodule