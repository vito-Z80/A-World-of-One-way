	module HERO

init:
	SET_EXEC_IX update
	ld a,1
	ld (ix+oData.isMovable),a
	ld (ix+oData.accelerate),a  	; ��������� ��������� ������� ��� ��������, ���� ��� ����.
	ld (ix+oData.drawMethod),a
	ld (ix+oData.color),5
	jp OBJECTS.setObjectId
;----------------------------------------------------
update:
	; IX = this object data address

	ld a,(ix+oData.isDestroyed)
	or a
	jr nz,.lifeLost

	call OBJECTS.objMove
	call OBJECTS.collision
	call getDrawData
	ret
.lifeLost:
	call SOUND_PLAYER.SET_SOUND.explosion
	call POP_UP_INFO.setWasted


	; FIX ������� ���������� ������, ����� ������� ������� wasted, � ������ ����� ������� �����. 
	ld a,SYSTEM.GAME_INIT
	ld (rebuildLevel),a



	jp OBJECTS.resetObjectIX


	endmodule
