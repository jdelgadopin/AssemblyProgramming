	SECTION .bss
strchar		resb	80		; 80 chars max per line
collisions	resd	99991
results		resd	1000
	
	SECTION .data
multipliers	dd	123456789, 234567891, 345678912, 456789123, 567891234, 678912345, 789123456, 891234567
	
prompt		db	"%d",0xa,0
inp		db	"%79s",0
indexvalue	db	"%d hashes with %d collisions",0xa,0
	
	SECTION .text
        global  main			; MUST be linked with gcc (not ld)
	
        extern  printf, scanf

;;; ----------------------------------------------------------------------------

hash:	;; Parameters: 	rdi <- string address
	;; Returns:	rax <- hash (string)
	push	rbp
	mov	rbp, rsp
	push	rbx		; save rbx
	push	r12		; save r12
	mov	r12, rdi	; r12 <- string base address
	xor 	rbx, rbx	; h = 0
	xor	rcx, rcx	; i = 0
.loop_hash:
	cmp	byte [r12+rcx], 0 	; end of string?
	je	.end_hash	  	; jump to the end
	mov	 r9, rcx	  	;  r9 <- i
	and	 r9, 0x7	  	;  r9 <- i % 8
	lea	r10, [multipliers+4*r9]
	mov	r9d, [r10]	 	;  r9 <- multipliers[i % 8]
	xor	rdx, rdx	    	; rdx <- 0
	movzx	rax, byte [r12+rcx] 	; rax <- string[i]
	mul	 r9			; rax <- string[i] * multipliers[i % 8]
	add	rbx, rax		; h +=  string[i] * multipliers[i % 8]
	inc 	rcx
	jmp	.loop_hash
.end_hash:
	xor	rdx, rdx
	mov	rax, rbx	; rax <- h
	mov	rcx, 99991	; rcx <- 99991
	div	rcx		
	mov 	rax, rdx	; rax <- h % 99991
	pop	r12		; restore r12
	pop	rbx		; restore rbx
	leave
	ret

;;; ----------------------------------------------------------------------------
	
main:
	push	rbp
	mov	rbp, rsp
	;; save must-preserve registers
	push	rbx			; save rbx
	push	r12			; save r12
	push 	r13			; save r13
	
	lea	rbx, [collisions]	; rbx <- base address of the integers table
.loop_reading:
	;; read new data (one line)
	lea	rdi, [inp]
	lea	rsi, [strchar]
	xor	eax, eax
	call	scanf			; it will read (maxsize-1) chars + '\0'
	cmp	rax, 1			; is scanf ok?
	jne	.end_reading		; if not, jump to the end
	;; compute hash(string)
	lea	rdi, [strchar]
	call	hash
	;; rax <- hash(string)  0 <= rax < 99991
	inc	dword [rbx+4*rax]
	jmp	.loop_reading
.end_reading:
	mov	 r8, 999
	lea	r12, [results]		; r12 <- base address of the results table
	xor	rcx, rcx		; rcx/i <- 0
.loop_counting:
	cmp	rcx, 99991		; loop thru the collisions array
	je	.end_counting
	mov 	edx, [rbx+4*rcx]  	; rdx <- collisions [i]
	cmp	rdx, 1000
	cmovge  rdx, r8		  	; if rdx > 999 then rdx <- 999
	inc	dword [r12+4*rdx] 	; results[rdx]++
	inc 	rcx			; rcx/i++
	jmp	.loop_counting
.end_counting:
	xor	rbx, rbx
.loop_results:
	cmp	rbx, 1000		; loop thru the counting results array
	je	.end
	cmp	dword [r12+4*rbx], 0
	je	.cont
	lea	rdi, [indexvalue]
	mov 	esi, dword [r12+4*rbx]
	mov	rdx, rbx
	xor	eax, eax
	call  	printf
.cont:
	inc 	rbx
	jmp	.loop_results
.end:
	;; restore must-preserve registers
	pop	r13			; restore r13
	pop	r12			; restore r12
	pop	rbx			; restore rbx
	
	leave
	ret
	
