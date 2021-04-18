	module GAME
init:
	call clearScreen
	ld a,7
	call clearAttributes
	call LEVEL.build 	
	; current HL for next call
	call OBJECTS.create
	call clearAttrScrAddr
	xor a
	ld (isLevelPassed),a
	ld a,SYSTEM.GAME_UPDATE
	ret
;-----------------------------------------------
clearAttrScrAddr:
	ld hl,0
	ld (attrScrollAddr),hl
	ld (preAttrScrollAddr),hl
	ret
;-----------------------------------------------
update:
	BORDER 6
	call OBJECTS.clear
	BORDER 1
	call OBJECTS.draw

	BORDER 3
	xor a
	ld hl,objectsData + oData.direction
	ld b,MAX_OBJECTS
.checkDirection:
	or (hl)
	ld de,OBJECT_DATA_SIZE
	add hl,de
	djnz .checkDirection
	ld (global_direction),a
	BORDER 4
	call CONTROL.update
	BORDER 2
	call OBJECTS.update
	BORDER 5

	push ix
	call showGameInfo
	pop ix

	BORDER 7


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
