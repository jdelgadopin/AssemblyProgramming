        segment .data
a	dw      0x34CD
b       dw      0x12AB
c       dw      0x56EF
r1	dq	0
r2	dq	0
r3	dq	0
r4	dq	0
	
        segment .text
        global  _start
_start:
	movzx 	rax, word [a]
	mov 	rbx, rax
	mov 	rcx, rax
	mov 	rdx, rax
	
	add 	ax, [b]
	sub 	bx, [b]
	add 	cx, [c]
	sub 	dx, [c]

	mov	[r1], rax
	mov	[r2], rbx
	mov	[r3], rcx
	mov	[r4], rdx
	
	xor 	rax, rax     ; what for?
        ret
