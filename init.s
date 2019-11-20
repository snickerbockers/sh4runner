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
.globl get_romfont_pointer

.text

! gcc's sh calling convention (I'm sticking to this even though I don't use C)
! r0 - return value, not preseved
! r1 - not preserved
! r2 - not preserved
! r3 - not preserved
! r4 - parameter 0, not preserved
! r5 - parameter 1, not preserved
! r6 - parameter 2, not preserved
! r7 - parameter 3, not preserved
! r8 - preserved
! r9 - preserved
! r10 - preserved
! r11 - preserved
! r12 - preserved
! r13 - preserved
! r14 - base pointer, preserved
! r15 - stack pointer, preserved

_start:
	! put a pointer to the top of the stack in r15
	mov.l stack_top_addr, r15

	! get a cache-free pointer to configure_cache (OR with 0xa0000000)
	mova configure_cache, r0
	mov.l nocache_ptr_mask, r2
	mov.l nocache_ptr_val, r1
	and r2, r0
	or r1, r0
	jsr @r0
	nop

	mov.l main_addr, r0
	jsr @r0
	nop

	.align 4
configure_cache:
	mov.l ccr_addr, r0
	mov.l ccr_val, r1
	mov.l r1, @r0
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rts
	nop

	.align 4
ccr_addr:
	.long 0xff00001c
ccr_val:
	! disable both i-cache and o-cache
	! Otherwise I get some issues reading back data from the ARM7 on real
	! hardware.
	! I'm not sure why that is since I use the 0xa0000000 prefix, which
	! *should* disable caching.  Apparently it's not working the way I
	! thought it does because killing the cache here fixes many problems
	!
	! Anyways, this isn't a performance test, so killing the sh4 cache isn't
	! that big of a deal.  It may be prudent to only do this when accessing
	! aica memory, though.
	.long 0x010c


	mov.l main_addr, r0
	jsr @r0
	nop

	.align 4
main_addr:
	.long dcmain
nocache_ptr_mask:
	.long 0x1fffffff
nocache_ptr_val:
	.long 0xa0000000

	.align 4
get_romfont_pointer:
	mov.l romfont_fn_ptr, r1
	mov.l @r1, r1

	! TODO: not sure if all these registers here need to be saved, or if the
	! bios function can be counted on to do the honorable thing.
	! I do know that at the very least pr needs to be saved since the jsr
	! instruction will overwrite it
	mov.l r8, @-r15
	mov.l r9, @-r15
	mov.l r10, @-r15
	mov.l r11, @-r15
	mov.l r12, @-r15
	mov.l r13, @-r15
	mov.l r14, @-r15
	sts.l pr, @-r15
	mova stack_ptr_bkup, r0
	mov.l r15, @r0

	jsr @r1
	xor r1, r1

	mov.l stack_ptr_bkup, r15
	lds.l @r15+, pr
	mov.l @r15+, r14
	mov.l @r15+, r13
	mov.l @r15+, r12
	mov.l @r15+, r11
	mov.l @r15+, r10
	mov.l @r15+, r9
	rts
	mov.l @r15+, r8

	.align 4
stack_ptr_bkup:
	.long 0
romfont_fn_ptr:
	.long 0x8c0000b4

stack_top_addr:
	.long stack_top

! 4 kilobyte stack
	.align 8
stack_bottom:
	.space 4096
stack_top:
	.long 4
