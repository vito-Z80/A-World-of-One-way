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
	
; 	BORDER 6
; 	call OBJECTS.clear
	BORDER 1
	call OBJECTS.draw
	BORDER 2
	push ix
	call POP_UP_INFO.show
	pop ix
	BORDER 3
	call CONTROL.update
	BORDER 4
; 	push  iy
	call OBJECTS.update
; 	pop iy
; 	xor a
; 	ld (global_direction),a
	BORDER 5


; 	BORDER 7

; 	call charsDead
; 	ld a,c
; 	or a
; 	ret nz 		; all characters were dead


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
; 	ld bc,#EFFE
; 	in a,(c)
; 	bit 0,a 	; 0 = exit to main menu
; 	ret nz
	ld l,SYSTEM.MAIN_MENU_INIT
	ret
;-----------------------------------------------
; setNextLevel:
; 	ld a,(ix+oData.spriteId)
; 	cp HERO_FACE_00_PBM_ID
; 	ret nz
; ; 	ld (hl),0 	; need reset cell, where ? ...if 2 characters going to exit
; 	ld (ix+oData.isLeave),1
; 	call POP_UP_INFO.setMore
; 	call howMuchChars
; 	ld a,c
; 	dec a
; 	ret nz 		; more 1 character on level
; 	push hl
; 	ld hl,currentLevel
; 	inc (hl)
; 	inc hl 	; isLevelPassed label
; 	ld (hl),SYSTEM.SHOP_INIT
; 	call POP_UP_INFO.setDone
; 	call SOUND_PLAYER.SET_SOUND.done
; 	pop hl
; 	ret
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
; howMuchChars:
; 	; how much characters on level
; 	; return C = characters counter
; 	push hl
; 	ld hl,objectsData + oData.spriteId
; 	ld de,OBJECT_DATA_SIZE
; 	ld bc,MAX_OBJECTS * 256
; .loop:
; 	ld a,(hl)
; 	cp HERO_FACE_00_PBM_ID
; 	jr nz,.next
; 	inc c
; .next
; 	add hl,de
; 	djnz .loop
; 	pop hl
; 	ret
;-----------------------------------------------
	endmodule
