	SECTION .data
v1	dd	23, -4,  10
v2	dd	12, 12, -22
dim	dw	3			; vector dimension
pe	dq	0			; result = 8
	SECTION .text
        global  _start

_start:
	shl	word [dim], 2
	
	xor 	r8,  r8 		; accumulator
	xor	rcx, rcx		; counter
iter:	
	cmp 	cx, word [dim]		; if cl >= [dim] jump to end
	jge	end
	movsxd	rax, dword [v1+rcx]
	movsxd	rbx, dword [v2+rcx]
	imul	rbx			; rax <- v1[i]*v2[i]
	add 	r8, rax
	add	cx, 4
	jmp	iter
end:
	mov	[pe], r8		; [pe] is the result
	
        xor     rdi,rdi
        push    0x3c
        pop     rax
        syscall
