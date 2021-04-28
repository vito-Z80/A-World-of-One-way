        org #5CCB
basic:
        dw #00,endB - startLine
startLine:
	db #F9,#C0 		; RANDOMIZE USR
	db '23774'		; ADDR
	db #3A,#EA,#0E 		; : REM
	db #00,#00
	; ADDR value
	dw code
	db #00
code:
        include "includes.asm"
        include "variables.asm"
        db #0D
        display "Launch address: ",/A,code
endB:
	EMPTYTAP Wow.tap
	SAVETAP "Wow.tap", BASIC,"Wow", basic, endB-basic, 0
	TAPOUT Wow.tap
	TAPEND
