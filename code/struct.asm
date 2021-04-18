MAP_WIDTH:			equ 16
MAP_HEIGHT:			equ 12
MAX_OBJECTS: 			equ 10
ACCELERATE_STEP:		equ 13
MAX_SPEED:			equ 6
OBJECT_DATA_SIZE:		equ oData
FONT:				equ #3D00
TEXT_END:			equ 0

     	struct oData
x		byte	// 0
y		byte	// 1
preX		byte	// 2
preY		byte	// 3
cellId		byte	
spriteId	byte	
direction	byte	
launchTime	byte 	; время до начала движения объекта
color		byte	
delta		byte
accelerate	byte
isMovable	byte 	; 0 - false, !=0 - true
isDestroyed	byte	; !=0 == object destroyed
exec		dw 	; The address of the procedure executed every frame for the current object. #0000 = not called.
bit:		byte 	; bit 0-7 of X coordinate
scrAddrL:	byte
scrAddrH:	byte
sprAddrL:	byte
sprAddrH:	byte


isRemove:	byte
clearSide:	byte 	; сторона с которой требуется отчистка хвоста спрайта. 0 = не чистить
clrScrAddrL:	byte 	; адрес экрана где будет происходить отчистка.
clrScrAddrH:	byte 	; 

		; ввести переменную drawOnce ? к примеру для двери выхода - это объект и нет смысла ее печатать каждый кадр
		; достаточно при инициализации уровня.

drawMethod:	byte 	; !=0 = 3x2, ==0 = 2x2
animationId 	byte
endToEnd	byte	; объект сквозной. То есть при коллизии этого объекта с другим - другой продолжает путь дальше. 
			
id		byte	; id of this object in objects map
		block 4
     	ends



	struct DIRECTION
NONE:	byte
LEFT:	byte
RIGHT:	block 2
UP:	block 4
DOWN:	
	ends


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