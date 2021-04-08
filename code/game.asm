	module GAME
init:
	call clearScreen
	ld a,7
	call clearAttributes
	call LEVEL.build 	
	; current HL for next call
	call OBJECTS.create
	xor a
	ld (isLevelPassed),a
	ld a,SYSTEM.GAME_UPDATE
	ret
;-----------------------------------------------
update:
	call OBJECTS.draw
	call CONTROL.update
	call OBJECTS.update

	call returnKey
	ld a,l
	or a
	ret nz 		; to main menu

	; check level passed
	ld a,(isLevelPassed)
	cp SYSTEM.GAME_INIT
	ret z

	ld a,(delta)
	inc a
	ld (delta),a
	
	ld a,SYSTEM.GAME_UPDATE
	ret
;-----------------------------------------------
returnKey:		
	ld l,0
	ld bc,#EFFE
	in a,(c)
	bit 0,a 	; 0 = exit to main menu
	ret nz
	ld l,SYSTEM.MAIN_MENU_INIT
	ret
;-----------------------------------------------
setNextLevel:
	ld a,(ix+oData.spriteId)
	cp HERO_FACE_00_PBM_ID
	ret nz
	push hl
	ld hl,currentLevel
	inc (hl)
	inc hl 	; isLevelPassed label
	ld (hl),SYSTEM.GAME_INIT
	pop hl
	ret
	endmodule
