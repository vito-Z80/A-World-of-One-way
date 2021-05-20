	module GAME
init:
	call fadeOutFull
	call clearScreen
	call LEVEL.build 	
	; current HL for next call
	call OBJECTS.create
	ld a,SYSTEM.GAME_UPDATE
	ret
;-----------------------------------------------
update:
	BORDER 1
	call OBJECTS.draw
	BORDER 2
	push ix
	call POP_UP_INFO.show
	pop ix
	BORDER 3
	call CONTROL.update
	BORDER 4
	call OBJECTS.update
	BORDER 5
	call returnKey
	ld a,l
	or a
	ret nz 		; to main menu
	call rebuildLvl
	ret nz 		; rebuild level
; 	; check level passed
	call nextLevel
	ret z 		; next level
	ld a,(delta)
	inc a
	ld (delta),a
	BORDER 0
	ld a,SYSTEM.GAME_UPDATE 	; loop
	ret
;-----------------------------------------------
rebuildLvl:
	ld hl,rebuildLevel
	ld a,(hl)
	or a
	ret z
	scf
	ret
	cp SYSTEM.SHOP_INIT
	ret nz
	ld (hl),0
	ld d,a
	ld a,(lives)
	or a
	ld a,SYSTEM.MAIN_MENU_INIT
	ret z
	ld a,d
	cp d
	ret
; 	jr nextLevel + 3
nextLevel:
	ld a,(isLevelPassed)
	cp SYSTEM.SHOP_INIT
	ret nz
	ld c,a
	call POP_UP_INFO.isFinish
	cpl 
	ld a,c
	ret
;-----------------------------------------------
returnKey:		
	ld l,0
	call CONTROL.caps
	ret nz
	call CONTROL.enter
	ret nz
	ld l,SYSTEM.MAIN_MENU_INIT
	ret
;-----------------------------------------------
	endmodule
