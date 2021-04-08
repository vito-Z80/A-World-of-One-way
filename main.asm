        device zxspectrum48


//--------------------------------------------------------------------------
	include "code/struct.asm"
	include "code/system.asm" 	; любые подгрузки после, так как тут начальлный ORG
	include "code/debug.asm" 	; remove before release!!!
lds:
	include "maps/levelsData.asm"
elds:
	include "code/level.asm"
	include "code/title2.asm"
	include "code/game.asm"
	include "code/mainMenu.asm"
	include "code/control.asm"
	include "code/object.asm"
	include "code/objects/hero.asm"
	include "code/objects/chupa.asm"
	include "code/objects/startPosition.asm"
	include "code/objects/exitDoor.asm"
	include "code/objects/enemySkull.asm"
	include "utils/utils.asm"
ss:
	include "sprites/storage.asm"
ess
//---------------------------------VARIABLES---------------------------------
global_direction:	db DIRECTION.NONE
tmp_direction:		db DIRECTION.NONE
textColor:		db 0,0
//---------------------------------SPACE--------------------------------
				align 256
attrBufferScroll: 		block 256, 0 	; буфер восстановления аттибуртов для информационной бегущей строки вверх
levelCells:			block MAP_WIDTH * MAP_HEIGHT 	; level cells for collision 	  192 bytes
		; забить данными не более 64 байта, что бы floorCells LOW = 0	
globalSeed:			dw 0
currentLevel:			db 0
isLevelPassed:			db 0 	; 1 - true; 0 - false
floorColor:			db 0
attrScrollAddr:			dw #0000 ; адрес рисования атрибутов информационной бегущей строки вверх 
attrBitmapColor:		db 0 	; цвет атрибутов информационной бегущей строки вверх
delta:				db 0	; каждый кадр +1 в GAME.update
; title data
byteValue:			db 0
pathAddress:			dw 0

strips:				block MAX_OBJECTS + MAX_OBJECTS / 2, 0 
				align 256
floorCells:			block MAP_WIDTH * MAP_HEIGHT 		; floor cells for back to screen
objectsData:			block OBJECT_DATA_SIZE * MAX_OBJECTS 	; space for objects data
				; low address byte = 0
screenAddresses:		block 192 * 2, 0 			; table of left side screen addresses 384 bytes
        savetap "main.tap", SYSTEM.run




        display "level CELLS address: ",/A,levelCells
        display "floor CELLS address: ",/A,floorCells
        display "screenAddresses address: ",/A,screenAddresses
        display "getDrawData address: ",/A,getDrawData
        display "object data size: ",/A,OBJECT_DATA_SIZE


        display "LEVELS_MAP: ",/A,LEVELS_MAP
        display "LEVELS_BEGIN: ",/A,LEVELS_BEGIN

        display "SPRITE_STORAGE: ",/A,SPRITE_MAP


        display "::::::::: ",/A,OBJECTS.stepUp
        display "::::::::: ",/A,GAME.update

	display "SPRITE STORAGE SIZE = ",/A, ess - ss
	display "ALL LEVELS SIZE = ",/A, elds - lds
        display "FULL SIZE = ",/A, $ - SYSTEM.run
        display "LAST ADDRESS = ",/A, $
