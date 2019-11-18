	.globl _start

	.text

_start:
	b reset
	b undefined
	b swi
	b pref_abort
	b data_abort
	b wtf_is_this
	b irq
	b fiq

reset:
	ldr r0, testaddr
	ldr r1, testval
	ldr r1, [r1]
	str r1, [r0]
	b reset
	mov r0, r0
	mov r0, r0
	

undefined:
	movs pc, r14
swi:
	movs pc, r14
pref_abort:
	subs pc, r14, #4
data_abort:
	subs pc, r14, #8
wtf_is_this:
	subs pc, r14, #4
irq:
	subs pc, r14, #4
fiq:
	subs pc, r14, #4

.align 4
testaddr:
	.long 0x00001234
testval:
	.long 0xdeadbeef
