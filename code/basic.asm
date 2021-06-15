        org #5CCB
basic:
        dw #00,endB - startLine
startLine:
	db #F9,#C0 		; RANDOMIZE USR
	db '23774'		; ADDR
	db #3A,#EA 		; : REM
	db #0E,#00,#00
	; ADDR value
	dw code
	db #00
code: 	; 23774
        include "includes.asm"
vars:
        db #0D
        display "Launch address: ",/A,code
        display "vars address: ",/A,vars
        display "listener: ",/A,CONTROL.digListener
endB:
	EMPTYTAP Wow.tap
	SAVETAP "Wow.tap", BASIC,"Wow", basic, endB-basic, 0
	TAPOUT Wow.tap
	TAPEND

        include "variables.asm"