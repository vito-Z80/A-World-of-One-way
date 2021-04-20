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
	include "code/popUpInfo.asm"
	include "code/object.asm"
	include "code/objects/hero.asm"
	include "code/objects/chupa.asm"
	include "code/objects/exitDoor.asm"
	include "code/objects/enemySkull.asm"
	include "code/objects/explosion.asm"
	include "code/audio/soundPlayer.asm"
	include "utils/utils.asm"
ss:
	include "sprites/storage.asm"
ess
//---------------------------------VARIABLES---------------------------------
global_direction:	db DIRECTION.NONE
; tmp_direction:		db DIRECTION.NONE
textColor:		db 0,0
//---------------------------------SPACE--------------------------------
				align 256
buffer256: 		block 256, 0 	; буфер восстановления аттибуртов для информационной бегущей строки вверх и еще чего нибудь :)
	
	; #00 > 	free way
	; #01-#0A > 	object ID`s
	; #FF > 	wall
	; #FE > 	breakable wall
	; 	общее:
	; объекты на карте со значением 0 = пустая ячейка (свободный путь)
	; объекты на карте со значением (128-255) = не возможно пересеч (стена)
	; объекты на карте со значением (1-127) = объекты взаимодействия
	;
levelCells:			block MAP_WIDTH * MAP_HEIGHT 	; level cells for collision 	  192 bytes
		; забить данными не более 64 байта, что бы floorCells LOW = 0	
globalSeed:			dw 0
		; две переменных ниже должны следовать друг за другом !!!
currentLevel:			db 0
isLevelPassed:			db 0 	; 1 - true; 0 - false

floorColor:			db 0
		; pop up variables
popupAttrAddr:			dw #0000 ; адрес рисования атрибутов информационной бегущей строки вверх 
popupPreAttrAddr:		dw #0000 ; 
popupBitmapAddr:		dw #0000 ; bitmap address	
popupBitmapColor:		db 0 	; цвет атрибутов информационной бегущей строки вверх
bitmapWidth:			db 0 	; bitmap width in bytes
		;-----------------
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

; fillStack:			; место для стека заливки пустотой внутри уровня
; 				equ $
        savetap "main.tap", SYSTEM.run




        display "level CELLS address: ",/A,levelCells
        display "floor CELLS address: ",/A,floorCells
        display "screenAddresses address: ",/A,screenAddresses
        display "getDrawData address: ",/A,getDrawData
        display "object data size: ",/A,OBJECT_DATA_SIZE
        display "OBJECTS DATA : ",/A,objectsData


        display "LEVELS_MAP: ",/A,LEVELS_MAP
        display "LEVELS_BEGIN: ",/A,LEVELS_BEGIN

        display "SPRITE_STORAGE: ",/A,SPRITE_MAP


        display "::::::::: ",/A,OBJECTS.setLaunchTime
        display "::::::::: ",/A,POP_UP_INFO.show

	display "SPRITE STORAGE SIZE = ",/A, ess - ss
	display "ALL LEVELS SIZE = ",/A, elds - lds
        display "CODE SIZE = ",/A, ess - SYSTEM.run
        display "FULL SIZE = ",/A, $ - SYSTEM.run
        display "LAST ADDRESS = ",/A, $
