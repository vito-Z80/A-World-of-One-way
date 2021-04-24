; Beeper engine
; Copyright (C) 2021 by Juan J. Martinez <jjm@usebox.net>
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in
; all copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
; THE SOFTWARE.
;
; .globl beeper_init
; .globl beeper_queue
; .globl beeper_play


        module SOUND_PLAYER

        module SET_SOUND
mute:
	ld hl,SOUND_PLAYER.DATA.mute
	jr SOUND_PLAYER.init
coin:
	ld hl,SOUND_PLAYER.DATA.coin
	jr SOUND_PLAYER.init
explosion:
	ld hl,SOUND_PLAYER.DATA.explosion
	jr SOUND_PLAYER.init
impact:
	ld hl,SOUND_PLAYER.DATA.impact
	jr SOUND_PLAYER.init
eat:
	ld hl,SOUND_PLAYER.DATA.eat
	jr SOUND_PLAYER.init
key:
	ld hl,SOUND_PLAYER.DATA.key
	jr SOUND_PLAYER.init
ice:
        ld hl,SOUND_PLAYER.DATA.ice
        jr SOUND_PLAYER.init
done:
        ld hl,SOUND_PLAYER.DATA.done
        jr SOUND_PLAYER.init
dead:
        ld hl,SOUND_PLAYER.DATA.dead
        jr SOUND_PLAYER.init
        endmodule

init:
        di
        ld (sfx_data), hl
        ld a,1
        ld (sfx_type), a
        ld de,sfx_type
        ld bc,5
        ldir
        ei
        ret

; beeper_queue::
;         di
;         ld a, l
;         call queue_next
;         ei
;         ret

queue_next:
        ld (sfx_type), a
        or a
        ret z

        dec a

        ld hl, (sfx_data)
        ld c, l
        ld b, h

        ld h, #0
        ld l, a
        ld d, h
        ld e, l
        add hl, hl
        add hl, hl
        add hl, de
        add hl, bc

        ld de, sfx_type
        ld bc, #5
        ldir
        ret

play:
        ld a, (sfx_type)
        or a
        ret z

        dec a
        jr z, tone

        dec a
        ; shouldn't happen!
        ret nz

        ; noise
        ld a, (sfx_freq)
        ld d, a

        ld b, #0

noise_loop:
        call rnd
        and 0x10
        ; FIXME: border ?
        out (0xfe), a

        ld c, d
noise_freq_loop:
        dec b
        jr z, noise_done
        dec c
        jr nz, noise_freq_loop
        jr noise_loop

tone:
        ld a, (sfx_freq)
        ld d, a

        xor a
        ld b, a

tone_loop:
        ; FIXME: border ?
        out (0xfe), a
        xor 0x10

        ld c, d
freq_loop:
        dec b
        jr z, tone_done
        dec c
        jr nz, freq_loop
        jr tone_loop

tone_done:
noise_done:
        ld a, (sfx_next)
        ld hl, sfx_frames
        dec (hl)
        jr z, queue_next

        ; freq change (slide)
        ld a, (sfx_freq_chg)
        add d
        ld (sfx_freq), a

        ret

rnd:
        ld hl, 0xf3a1
        ld a, h
        rra
        ld a, l
        rra
        xor h
        ld h, a
        ld a, l
        rra
        ld a, h
        rra
        xor l
        ld l, a
        xor h
        ld h, a
        ld (rnd + 1), hl
        ret

sfx_type:       db 0
sfx_frames:     db 0
sfx_freq:       db 0
sfx_freq_chg:   db 0
sfx_next:       db 0

sfx_data:       block 2

        module DATA
mute:	
	db 0,0,0,0,0
coin:
        db 1,6,32,-8,2, 1,6,48,-12,0
explosion:
        db 2,32,1,-1,0
impact:
	db 2,2,5,-33,0
eat:
	db 1,8,33,78,0
key:
	db 1,1,4,0,0
ice:
        db 2,6,22,66,0
done:
        db 1,32,99,-3,0
dead:
        db 1,32,1,-64,0
        endmodule

        endmodule
