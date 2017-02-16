	SECTION .bss
	fibs	resq	100	; 100 is an approx. upper bound
				; to the max fib numbers I can compute
				; with quad-words
	SECTION .data
	numfibs	dq	0	; 0x5c = 92
	lastfib dq	0	; 7540113804746346429
				; 0x68a3dd8e61eccfbd
	
	SECTION .text
        global  _start

_start:
	xor 	r8, r8		; fib_0 (r8 is fib_{n-2})
	mov 	r9, 1		; fib_1 (r9 is fib_{n-1})
	mov	[fibs+8], r9

	mov	rcx, 16		; counter
iter:
	mov	rax, r9
	add	rax, r8		; unsigned addition
	jo 	end		; stop if overflow
	mov	[fibs+rcx], rax
	mov	r8,  r9
	mov 	r9,  rax
	add	rcx, 8
	jmp 	iter
end:
	shr	rcx, 3
	dec	rcx
	mov 	[numfibs], rcx
	mov 	[lastfib], r9
	
        xor     rdi,rdi
        push    0x3c
        pop     rax
        syscall
