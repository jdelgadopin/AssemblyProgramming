	SECTION .data
	c	dq	15
	c2	dq	0
	a	dq	1	; 0^2 + c^2 is always a (no) solution
	b	dq	1
	
	SECTION .text
        global  _start
_start:
	;; compute c^2 once
	mov	r8, [c]		
	imul	r8, [c]
	mov	[c2], r8
	
	;; loop for a = 1...
	mov	rax, [a]
stra:	cmp	rax, [c]
	jge	enda
	mov	r8, rax		; compute a^2
	imul	r8, rax
	
	;; loop for b = 1...
	mov	rbx, [b]
strb:	cmp	rbx, [c]
	jge	endb
	;; given values for a and b, compute a^2 + b^2
	mov	r10, r8
	mov	r9, rbx
	imul	r9, rbx	
	add	r10, r9
	;; compare c^2 with a^2 + b^2 (in r10)
	cmp	r10, [c2]
	je	found		; stop if found
	inc 	rbx
	jmp	strb
endb:	
	inc 	rax
	jmp	stra
enda:
	jmp 	end
	
found:	mov	[a], rax
	mov	[b], rbx
end:	
        xor     rdi,rdi
        push    0x3c
        pop     rax
        syscal
