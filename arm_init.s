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
	ldr r13, stack_top_addr

	bl init_fib_msg

	ldr r0, fib_msg_addr
	mov r1, #69
	bl xmit_pkt

forever_loop:
	b forever_loop

	.align 4
stack_top_addr:
	.long stack_top

init_fib_msg:
	# fills fib_msg with a fibonacci sequence
	# we send this to the sh4 to prove to it that
	# the ARM is working and has a sane environment.
	# It doesn't need to be this complicated, but I like the idea
	# of having it do some runtime calculation with a known answer
	# to establish that it's alive

	# push r4 onto the stack
	sub r13, r13, #4
	str r4, [r13]

	ldr r0, fib_msg_addr
	mov r1, #1
	mov r2, #1
	mov r3, #2

	str r1, [r0]
	add r0, r0, #4
	str r2, [r0]
	add r0, r0, #4

fib_loop:
	add r4, r1, r2

	str r4, [r0]
	add r0, r0, #4

	mov r1, r2
	mov r2, r4

	add r3, r3, #1
	cmp r3, #52/4
	bne fib_loop

	# restore r4 from the stack
	ldr r4, [r13]
	add r13, r13, #4

	# return
	mov r15, r14

fib_msg_addr:
	.long fib_msg


xmit_pkt:
	# r0 points to a 52-byte message string
	# r1 contains the opcode

	# push r4 onto the stack
	sub r13, r13, #4
	str r4, [r13]

	# first write out the opcode
	ldr r2, pkt_out_addr
	add r3, r2, #8
	str r1, [r3]

	# now write the 52-byte message
	add r3, r3, #4
	mov r4, #0
put_long:
	ldr r1, [r0]

	str r1, [r3]

	add r3, r3, #4
	add r0, r0, #4
	add r4, r4, #1
	cmp r4, #52/4
	bne put_long

	# now write out the sequence number
	ldr r0, next_seqno
	str r0, [r2]
	add r0, r0, #1
	str r0, next_seqno

	# restore r4 from the stack
	ldr r4, [r13]
	add r13, r13, #4

	# return
	mov r15, r14

	# communication protocol:
	# outbound packets (from ARM's perspective) are placed at
	# 0x00100000 (1MB)
	# first four bytes: sequence number (zero is considered invalid)
	# second four bytes: sequence number ack (sh4 writes to this)
	# third four bytes: opcode
	# other 52 bytes: message data
	.align 4
pkt_out_addr:
	.long 0x00100000
next_seqno:
	.long 1



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
fib_msg:
	.space 52

	# 4 kilobyte stack
	.align 8
stack_bottom:
	.space 4096
stack_top:
