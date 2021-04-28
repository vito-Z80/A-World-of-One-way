        device zxspectrum48

; MACHINE = 48 	
MACHINE = 16
//--------------------------------------------------------------------------
	include "code/struct.asm"

	if MACHINE == 48
		include "code/basic.asm" 	; for basic loader
        endif

        if MACHINE == 16
		include "code/rom.asm" 		; for cartrige
	endif

        display "level CELLS address: ",/A,levelCells
        display "screenAddresses address: ",/A,screenAddresses
        display "getDrawData address: ",/A,getDrawData
        display "object data size: ",/A,OBJECT_DATA_SIZE
        display "OBJECTS DATA : ",/A,objectsData


        display "LEVELS_MAP: ",/A,LEVELS_MAP
        display "LEVELS_BEGIN: ",/A,LEVELS_BEGIN

        display "SPRITE_STORAGE: ",/A,SPRITE_MAP


        display "::::::::: ",/A,OBJECTS.targetCell
        display "::::::::: ",/A,lastKeyPresed
        display "::::::::: ",/A,MAIN_MENU.init

	display "SPRITE STORAGE SIZE = ",/A, ess - ss
	display "ALL LEVELS SIZE = ",/A, elds - lds
        display "CODE SIZE = ",/A, ess - SYSTEM.run
        display "FULL SIZE = ",/A, $ - SYSTEM.run
        display "LAST ADDRESS = ",/A, $
        display "vars length max 64bytes, or change memory address = ",/A, varsEnd - varsStart
