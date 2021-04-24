	module GAME
init:
	call clearScreen
	xor a
	call clearAttributes
	call LEVEL.build 	
	; current HL for next call
	call OBJECTS.create
; 	call POP_UP_INFO.reset
	xor a
	ld (isLevelPassed),a
	ld (rebuildLevel),a
	ld a,SYSTEM.GAME_UPDATE
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
	call POP_UP_INFO.show
	pop ix

	BORDER 7

; 	call charsDead
; 	ld a,c
; 	or a
; 	ret nz 		; all characters were dead


	call returnKey
	ld a,l
	or a
	ret nz 		; to main menu


	call rebuildLvl
	ret z 		; rebuild level

	; check level passed
	call nextLevel
	ret z 		; next level

	ld a,(delta)
	inc a
	ld (delta),a
	
	ld a,SYSTEM.GAME_UPDATE 	; loop
	ret
;-----------------------------------------------
rebuildLvl:
	ld a,(rebuildLevel)
	jr nextLevel + 3
nextLevel:
	ld a,(isLevelPassed)
	cp SYSTEM.GAME_INIT
	ret nz
	ld d,a
	call POP_UP_INFO.isFinish
	jr z,.next 
	ret
.next:
	ld a,SYSTEM.FADE_OUT
	ret
;-----------------------------------------------
returnKey:		
	ld l,0
	ld bc,#EFFE
	in a,(c)
	bit 0,a 	; 0 = exit to main menu
	ret nz
	ld l,SYSTEM.FADE_OUT
	ld d,SYSTEM.MAIN_MENU_INIT
	ret
;-----------------------------------------------
setNextLevel:
	ld a,(ix+oData.spriteId)
	cp HERO_FACE_00_PBM_ID
	ret nz
; 	ld (hl),0 	; need reset cell, where ? ...if 2 characters going to exit
	ld (ix+oData.isLeave),1
	call POP_UP_INFO.setMore
	call howMuchChars
	ld a,c
	dec a
	ret nz 		; more 1 character on level
	push hl
	ld hl,currentLevel
	inc (hl)
	inc hl 	; isLevelPassed label
	ld (hl),SYSTEM.GAME_INIT
	call POP_UP_INFO.setDone
	call SOUND_PLAYER.SET_SOUND.done
	pop hl
	ret
;-----------------------------------------------
; charsDead:
; 	ld hl,objectsData + oData.spriteId
; 	ld de,OBJECT_DATA_SIZE
; 	ld bc,MAX_OBJECTS * 256
; .loop:
; 	ld a,(hl)
; 	cp HERO_FACE_00_PBM_ID
; 	ret z 		; if characters exists on level
; 	add hl,de
; 	djnz .loop
; 	call POP_UP_INFO.isFinish
; 	ret nz 		; if pop up info not finish
; 	ld c,SYSTEM.FADE_OUT  		; set fade out system
; 	ld d,SYSTEM.MAIN_MENU_INIT 	; set system after fade out
; 	ret
;-----------------------------------------------
howMuchChars:
	; how much characters on level
	; return C = characters counter
	push hl
	ld hl,objectsData + oData.spriteId
	ld de,OBJECT_DATA_SIZE
	ld bc,MAX_OBJECTS * 256
.loop:
	ld a,(hl)
	cp HERO_FACE_00_PBM_ID
	jr nz,.next
	inc c
.next
	add hl,de
	djnz .loop
	pop hl
	ret
;-----------------------------------------------
	endmodule
