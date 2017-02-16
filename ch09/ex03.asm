
	SECTION .data
prompt		db	"Pythagorean triples (a,b,c) up to c = 500",0xa,0
triple		db	" (%d,%d,%d) ",0
linefd		db	0xa,0

	SECTION .text
        global  _start
	
        extern  printf

;;; ---------------------------------------------------------------------	

test_pythagorean:
	push	rbp
	mov	rbp, rsp
	xor	al, al		; result = false
	mov	r8, rdi		; compute a^2
	imul	r8, rdi
	mov	r9, rsi		; compute b^2
	imul	r9, rsi	
	add	r8, r9		; r8 <- a^2 + b^2
	mov	r10, rdx		
	imul	r10, rdx	; r10 <- c^2
	cmp	r8, r10
	je	true
	leave
	ret
true:	or	al, 0x1		; result = true
	leave
	ret

;;; ---------------------------------------------------------------------	

pythagorean:
	push	rbp
	mov	rbp, rsp
	push	r12		; save r12
	push	rbx		; save rbx
	push 	rdi		; save c
	;; loop for a = 1...
	mov	r12, 1
stra:	cmp	r12, [rsp]
	jge	enda
	;; loop for b = a...
	mov	rbx, r12
strb:	cmp	rbx, [rsp]
	jge	endb
	mov	rdi, r12	; a
	mov	rsi, rbx	; b
	mov	rdx, [rsp]	; c
	call 	test_pythagorean
	cmp	al, 0
	je	notpy	
	lea	rdi, [triple]	; if found, print the triple (a,b,c)
	mov	rsi, r12
	mov	rdx, rbx
	mov	rcx, [rsp]
	xor	eax, eax
	call	printf
notpy:
	inc 	rbx
	jmp	strb
endb:	
	inc 	r12
	jmp	stra
enda:
	pop	rdi		; pop
	pop	rbx		; restore rbx
	pop 	r12		; restore r12
	leave
	ret

;;; ---------------------------------------------------------------------
	
_start:
	
	lea	rdi, [prompt]	; address of prompt
        xor     eax, eax	; 0 float parameters
        call    printf
	mov	rbx, 1
loop_c:	cmp	rbx, 500
	jg	end
	mov	rdi, rbx
	call	pythagorean
	inc 	rbx
	jmp	loop_c
end:
	lea	rdi, [linefd]
	xor	eax, eax
	call	printf
	mov	eax, 60	     	; exit
	xor	edi, edi
	syscall
