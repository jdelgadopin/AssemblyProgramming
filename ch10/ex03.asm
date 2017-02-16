	;; constant
maxsize		equ	80
prime		equ	65521
	
	SECTION .bss
strchar		resb	maxsize		; 80 chars max per line
	
	SECTION .data
prompt		db	"%d",0xa,0
	
	SECTION .text
        global  main			; MUST be linked with gcc (not ld)
	
        extern  printf, fgets, stdin

main:
	push	rbp
	mov	rbp, rsp
	;; save must-preserve registers
	push	rbx			; save rbx
	push	r12			; save r12
	push 	r13			; save r13
	;; initialize rbx with base address of the array
	lea	rbx, [strchar]
	;; initialize the adler32 algorithm
	xor	r12, r12
	inc	r12d		; a = 1
	xor	r13, r13	; b = 0 
.again:
	;; read new data (one line)
	lea	rdi, [strchar]
	mov	rsi, maxsize		; it will read (maxsize-1) chars + '\0'
	mov	rdx, [stdin] 
	call	fgets
	cmp	al, 0
	jz	.end

	xor	rcx, rcx		; i = 0 
.loop:
	;; loop through the data
	cmp	byte [rbx + rcx], 0
	je	.end_loop
	cmp	rcx, maxsize
	jge	.end_loop

	movzx	r8, byte [rbx+rcx]
	add	r12d, r8d	  	; a = a + data[i]
	mov	r8, prime	
	xor	edx, edx
	mov	eax, r12d
	idiv	r8d
	mov	r12d, edx		; a = a % 65521 (prime)
	add	r13d, r12d		; b = b + a
	xor	edx, edx
	mov	eax, r13d
	idiv	r8d
	mov	r13d, edx		; b = b % 65521 (prime)
	
	inc	rcx			; i++
	jmp	.loop
	
.end_loop:
	;; run to the end of available data, jump to read more...
	jmp .again

.end:
	;; compute (b << 16) | a
	mov	eax, r13d
	shl	eax, 16
	or	eax, r12d
	;; rax contains the result, print it
	lea	rdi, [prompt]
	xor	rsi, rsi
	mov	esi, eax 
	xor	eax, eax      
	call	printf        
	;; restore must-preserve registers
	pop	r13			; restore r13
	pop	r12			; restore r12
	pop	rbx			; restore rbx
	
	leave
	ret
	
