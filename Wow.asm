        device zxspectrum48

        ; Compile from this file with sjasmplus !!!!!!!!!!!

DEBUG = 0
MACHINE = 9 		; 9k version with basic loader
; MACHINE = 16 		; 16k cartrige version
; MACHINE = 48  	; 48k full version
//--------------------------------------------------------------------------

	include "code/struct.asm"

   	if MACHINE == 9
		include "code/basic.asm" 	; for basic loader
    endif

    if MACHINE == 16
		include "code/rom.asm" 		; for cartrige
	endif

    display "level CELLS address: ",/A,levelCells
    display "getDrawData address: ",/A,getDrawData
    display "object data size: ",/A,OBJECT_DATA_SIZE
    display "OBJECTS DATA : ",/A,objectsData

    display "LEVELS_MAP: ",/A,LEVELS_MAP
    display "LEVELS_BEGIN: ",/A,LEVELS_BEGIN

    display "SPRITE_STORAGE: ",/A,SPRITE_MAP


    display "::::::::: ",/A,PASS.input.printNext

	display "SPRITE STORAGE SIZE = ",/A, ess - ss
	display "ALL LEVELS SIZE = ",/A, elds - lds

	if MACHINE == 48 || MACHINE == 9
        display "CODE SIZE = ",/A, vars - basic
        display "FULL SIZE = ",/A, $ - basic
    endif

    display "LAST ADDRESS = ",/A, $

   	if MACHINE == 9 && __ERRORS__ == 0
		SHELLEXEC "P:\ZX\Emulators\ue\unreal.exe Wow.tap" 
    endif

    if MACHINE == 16 && __ERRORS__ == 0
		SHELLEXEC "P:\ZX\Emulators\xpeccy_0.6.20210407_win32\xpeccy.exe Wow.bin" 
	endif

