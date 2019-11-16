!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
! Copyright (c) 2019, snickerbockers <snickerbockers@washemu.org>
! All rights reserved.
!
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! * Redistributions of source code must retain the above copyright notice, this
!   list of conditions and the following disclaimer.
! * Redistributions in binary form must reproduce the above copyright notice,
!   this list of conditions and the following disclaimer in the documentation
!   and/or other materials provided with the distribution.
! * Neither the name of the copyright holder nor the names of its
!   contributors may be used to endorse or promote products derived from
!   this software without specific prior written permission.
!
! THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
! AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
! IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
! ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
! LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
! CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
! SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
! INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
! CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
! ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
! POSSIBILITY OF SUCH DAMAGE.
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

.globl _start
.text

! hardcode for 476i 60Hz NTSC
! SPG_HBLANK_INT: 03450000
! SPG_VBLANK_INT: 00150104
! SPG_HBLANK: 007E0345
! SPG_VBLANK: 00240204
! SPG_LOAD: 020C0359
! SPG_CONTROL: 00000150
! SPG_WIDTH: 0x07d6c63f

_start:
! put a pointer to the bottom of the stack in r15
	mova stack_bottom, r0
	xor r1, r1
	add #1, r1
	shll8 r1
	shll2 r1
	shll2 r1
	add r1, r0
	mov r0, r15

	! configure SPG
	mova spg_base_addr, r0
	mov.l @r0, r1
	mova spg_vals, r0
	mov r0, r2
	xor r0, r0
spg_loop:
	mov.l @(r0, r2), r3
	mov.l r3, @r1
	add #4, r1
	add #4, r0
	cmp/eq 	#28, r0
	bf spg_loop

	! skip TEXT_CONTROL
	add #4, r0
	add #4, r1

spg_loop_second:
	mov.l @(r0, r2), r3
	mov.l r3, @r1

	add #4, r0
	add #4, r1
	cmp/eq #44, r0
	bf spg_loop_second

spg_done:
	! configure FB_R_CTRL
	mova fb_r_ctrl_addr, r0
	mov.l @r0, r0
	mov #5, r1
	mov.l r1, @r0

sh4runner_loop_forever:
	bra sh4runner_loop_forever
	nop

	.align 4
fb_r_ctrl_addr:
	.long 0xa05f8044

! seven 4-byte registers
spg_base_addr:
	.long 0xa05f80c8

spg_vals:
	! SPG_HBLANK_INT
	.long 0x03450000
	! SPG_VBLANK_INT
	.long 0x00150104
	! SPG_CONTROL
	.long 0x00000150
	! SPG_HBLANK
	.long 0x007E0345
	! SPG_LOAD
	.long 0x020C0359
	! SPG_VBLANK
	.long 0x00240204
	! SPG_WIDTH
	.long 0x07d6c63f
	! TEXT_CONTROL (skipped)
	.long 0
	! VO_CONTROL
	.long 0x00160000
	! VO_STARTX
	.long 0x000000a4
	! VO_STARTY
	.long 0x00120012

! 4 kilobyte stack
	.align 8
stack_bottom:
	.space 4096
