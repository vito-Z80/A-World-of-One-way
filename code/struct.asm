PASS_LENGTH:			equ 16
MAP_WIDTH:			equ 16
MAP_HEIGHT:			equ 12
MAX_OBJECTS: 			equ 10
ACCELERATE_STEP:		equ 13
MAX_SPEED:			equ 6
OBJECT_DATA_SIZE:		equ oData
; FONT:	if MACHINE == 48		
; 		equ #3D00
; 	endif
; 	if MACHINE == 48		
; 		equ cartrigeFont - 256
; 	endif
TEXT_END:			equ 0
ATTR_ADDR:			equ #5800
     	struct oData
x		byte	// 0
y		byte	// 1
preX		byte	// 2
preY		byte	// 3
cellId		byte	
spriteId	byte	
direction	byte	
launchTime	byte 	; время до начала движения объекта
color		byte	; color (8 bit)
colorDataL:	byte 	; color sequence address (if want to)
colorDataH:	byte 	; ------//-------
delta		byte 	; delta for velocity
accelerate	byte 	; velocity for object (FIXME rename to velocity)
step:		byte 	; step for delta
isMovable	byte 	; 0 - false, !=0 - true
isLeave:	byte 	; 
isDestroyed	byte	; object destroyed
exec		dw 	; The address of the procedure executed every frame for the current object. #0000 = not called.
bit:		byte 	; bit 0-7 of X coordinate
scrAddrL:	byte
scrAddrH:	byte
sprAddrL:	byte
sprAddrH:	byte


clearSide:	byte 	; сторона с которой требуется отчистка хвоста спрайта. 0 = не чистить
clrScrAddrL:	byte 	; адрес экрана где будет происходить отчистка.
clrScrAddrH:	byte 	; 

		; ввести переменную drawOnce ? к примеру для двери выхода - это объект, но нет смысла ее печатать каждый кадр
		; достаточно при инициализации уровня.

drawMethod:	byte 	; !=0 = 3x2, ==0 = 2x2
animationId: 	byte
n1:		byte 	; for any		
id:		byte	; id of this object in objects map
		block 1
     	ends



	struct DIRECTION
NONE:	byte
LEFT:	byte
RIGHT:	block 2
UP:	block 4
DOWN:	
	ends

	//-------------------------------------------------------------
	module INK
BLACK	equ 0
BLUE	equ 1
RED	equ 2
PURPLE	equ 3
GREEN	equ 4
CYAN	equ 5
YELLOW 	equ 6
WHITE	equ 7
	endmodule

	module PAPER
BLACK	equ INK.BLACK << 3
BLUE	equ INK.BLUE << 3
RED	equ INK.RED << 3
PURPLE	equ INK.PURPLE << 3
GREEN	equ INK.GREEN << 3
CYAN	equ INK.CYAN << 3
YELLOW 	equ INK.YELLOW << 3
WHITE	equ INK.WHITE << 3
	endmodule
BRIGHTNESS equ %01000000
	//-------------------------------------------------------------

	; macros for set update procedure of object
	macro SET_EXEC_IX address
	ld (ix+oData.exec),low address
	ld (ix+oData.exec + 1),high address
	endm
	macro SET_EXEC_IY address
	ld (iy+oData.exec),low address
	ld (iy+oData.exec + 1),high address
	endm

	macro SET_SPRITE_ADDR_IX address
	ld (ix+oData.sprAddrL),low address
	ld (ix+oData.sprAddrH),high address
	endm

	macro SET_SPRITE_ADDR_IY address
	ld (iy+oData.sprAddrL),low address
	ld (iy+oData.sprAddrH),high address
	endm




	; for DEBUG

	macro BORDER color
	ld a,color
	out (254),a
	endm