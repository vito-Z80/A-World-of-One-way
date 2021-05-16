	
	include "code/system.asm" 	; любые подгрузки после, так как тут запуск приложения
; 	include "code/debug.asm" 	; remove before release!!!
lds:
	include "maps/levelsData.asm"
elds:
	include "code/level.asm"
	include "code/title2.asm"
	include "code/game.asm"
	include "code/mainMenu.asm"
	include "code/control.asm"
	include "code/popUpInfo.asm"
	include "code/object.asm"
	include "code/pass.asm"
	include "code/shop.asm"
	include "code/objects/hero.asm"
	include "code/objects/chupa.asm"
	include "code/objects/exitDoor.asm"
	include "code/objects/enemySkull.asm"
	include "code/objects/brokenBlock.asm"
	include "code/objects/iceHole.asm"
	include "code/objects/split.asm"
	include "code/audio/soundPlayer.asm"
	include "utils/utils.asm"
ss:
	include "sprites/storage.asm"
ess
