
		; переменные ниже должны следовать друг за другом !!!
currentLevel:			db 0
isLevelPassed:			db 0 	; 1 - true; 0 - false
rebuildLevel:			db 0

levelAddr: 			dw #0000 	; адрес карты

coinsInLevelVar:		db 0 	; VAR, VAL. in that order
coinsInLevelVal:		db 0
pointsPerLevel:			dw #0000 	; очки заработанные за уровень - сбором монет.
preDir: 			db 0 		; previous direction
; kempstonState:			db 0
        display "Current low byte address (for ALIGN 256) = ",/A, low $, " | address = ",/A, $
			align 256
	display "buffer256 address: ",/A,$
buffer256: 		block 256, 0 	; буфер восстановления аттибуртов для информационной бегущей строки вверх и еще чего нибудь :)
	; #00 > 	free way
	; #01-#0A > 	object ID`s
	; #FF > 	wall
	; 	общее: 
	; объекты на карте со значением 0 = пустая ячейка (свободный путь)
	; объекты на карте со значением (128-255) = не возможно пересеч (стена)
	; объекты на карте со значением (1-127) = объекты взаимодействия
				; low address byte = 0
levelCells:			block MAP_WIDTH * MAP_HEIGHT 	; level cells for collision 	  192 bytes
		; ниже забить 64 байта переменных что бы screenAddresses LOW = 0
		; больше сюда не добавлять переменных. Либо выше верхнего align или после objectsData 
varsStart:
global_direction:		db DIRECTION.NONE
textColor:			db 0,0
lastKeyPresed:			db 0
lives:				dw #0000
livesText:			db 0,0,0,0,0,TEXT_END
coins:				dw #0000	
coinsText:			db 0,0,0,0,0,TEXT_END
levelNumberText:		db 0,0,0,0,0,TEXT_END
passData:			block PASS_LENGTH + 1,0

globalSeed:			dw 0
globalSeedTmp:			dw 0
		; pop up variables
popupAttrAddr:			dw #0000 ; адрес рисования атрибутов информационной бегущей строки вверх 
popupPreAttrAddr:		dw #0000 ; 
popupBitmapAddr:		dw #0000 ; bitmap address	
popupBitmapColor:		db 0 	; цвет атрибутов информационной бегущей строки вверх
bitmapWidth:			db 0 	; bitmap width in bytes
		;-----------------
delta:				db 0	; каждый кадр +1 в GAME.update
delta2: 			db 0
; title data
byteValue:			db 0 	; used for title (after title used for fill inside level start address > 2 bytes) 
pathAddress:			dw 0 	;  --//--
		;------------------
fillStack: 			dw 0 	; stack any cell for fill
tmpStack: 			dw 0 	;  ----//-----
		;------------------
varsEnd:

	; objectsData перенесено в TITLE_2, так как оно юзается только при старте программы и потом свободно более 320 байт, что хватит на 10 объектов
; objectsData:			block OBJECT_DATA_SIZE * MAX_OBJECTS 	; space for objects data 320 bytes

testS: 				block MAX_OBJECTS,0
setFF2:
				db 0,0
renderData:			block MAX_OBJECTS * 2,0
setFF1:
				db 0
endRenderData: 			equ $