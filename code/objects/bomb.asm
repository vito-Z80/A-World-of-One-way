;	бомба взрывается при взаимодействии с любым объектом
; 	задевая соседние клетки по 4 сторонам

	module BOMB
init:
	call LEVEL.drawFloorCellIX
	; convert chupa to bomb
	call OBJECTS.resetObjectIX
	; установка в spriteId работает только с анимированными объектами, так как обращается к переменной для получения начального адреса анимации
	; то есть, если спрайт состит из 1 кадра, то новый адрес спрайта нужно заносить в (sprAddrHL)
	ld (iy+oData.spriteId),BOOM_01_PBM_ID
	ret




update:

	ret




	endmodule
