	DISP #0000


	ld a,#3F
	ld i,a
	im 1
	ei
	jp .startRom
	db "Serdjuk 2021 for ASM 2021.",TEXT_END
.beforeIM1 = $
	block #38 - .beforeIM1
	if .beforeIM1 > #38 
		display "IM1 memory was crashed !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
 		stop
 	else
 		display "Free space before IM1 = ", #38 - .beforeIM1, " bytes."
	endif
	; #0038 IM1
	ei
	ret
.startRom:
	include "includes.asm"
cartrigeFont:
	incbin "font/font.SpecCHR"
	savebin "Wow.bin",#0000,#4000
	org #5B00
	include "variables.asm"