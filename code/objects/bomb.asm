;	����� ���������� ��� �������������� � ����� ��������
; 	������� �������� ������ �� 4 ��������

	module BOMB
init:
	call LEVEL.drawFloorCellIX
	; convert chupa to bomb
	call OBJECTS.resetObjectIX
	; ��������� � spriteId �������� ������ � �������������� ���������, ��� ��� ���������� � ���������� ��� ��������� ���������� ������ ��������
	; �� ����, ���� ������ ������ �� 1 �����, �� ����� ����� ������� ����� �������� � (sprAddrHL)
	ld (iy+oData.spriteId),BOOM_01_PBM_ID
	ret




update:

	ret




	endmodule
