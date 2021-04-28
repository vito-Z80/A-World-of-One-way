	DISP #0000
	jp .startRom	
	block #38 - $
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