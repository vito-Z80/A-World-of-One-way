		; ���������� ���� ������ ��������� ���� �� ������ !!!
currentLevel:			db 0
isLevelPassed:			db 0 	; 1 - true; 0 - false
rebuildLevel:			db 0
        display "������� ������� ���� �� ALIGN 256 = ",/A, low $
			align 256

buffer256: 		block 256, 0 	; ����� �������������� ���������� ��� �������������� ������� ������ ����� � ��� ���� ������ :)
	
	; #00 > 	free way
	; #01-#0A > 	object ID`s
	; #FF > 	wall
	; 	�����: 
	; ������� �� ����� �� ��������� 0 = ������ ������ (��������� ����)
	; ������� �� ����� �� ��������� (128-255) = �� �������� ������� (�����)
	; ������� �� ����� �� ��������� (1-127) = ������� ��������������
				; low address byte = 0
levelCells:			block MAP_WIDTH * MAP_HEIGHT 	; level cells for collision 	  192 bytes
		; ���� ������ 64 ����� ���������� ��� �� screenAddresses LOW = 0
		; ������ ���� �� ��������� ����������. ���� ���� �������� align ��� ����� objectsData 
varsStart:
global_direction:		db DIRECTION.NONE
textColor:			db 0,0
lastKeyPresed:			db 0
lives:				dw #0000
livesText:			db "00000",TEXT_END
coins:				dw #0000	
coinsText:			db "00000",TEXT_END
levelNumberText:		db "00000",TEXT_END
passData:			block PASS_LENGTH + 1,0

globalSeed:			dw 0
globalSeedTmp:			dw 0
		; pop up variables
popupAttrAddr:			dw #0000 ; ����� ��������� ��������� �������������� ������� ������ ����� 
popupPreAttrAddr:		dw #0000 ; 
popupBitmapAddr:		dw #0000 ; bitmap address	
popupBitmapColor:		db 0 	; ���� ��������� �������������� ������� ������ �����
bitmapWidth:			db 0 	; bitmap width in bytes
		;-----------------
delta:				db 0	; ������ ���� +1 � GAME.update
delta2: 			db 0
; title data
byteValue:			db 0 	; used for title (after title used for fill inside level start address > 2 bytes) 
pathAddress:			dw 0 	;  --//--
		;------------------
fillStack: 			dw 0 	; stack any cell for fill
tmpStack: 			dw 0 	;  ----//-----
		;------------------
varsEnd:
; 				align 256
				; low address byte = 0
screenAddresses:		block 192 * 2, 0 			; table of left side screen addresses 384 bytes
objectsData:			block OBJECT_DATA_SIZE * MAX_OBJECTS 	; space for objects data
