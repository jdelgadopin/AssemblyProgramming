;;; I will work with global variables. It's simpler (yeah, yeah, I know...)
	
	SECTION .bss
set_sum		resw	20		; max 20 16-bit words (one word per signed int)
sum		resw	1		; first element of the array
sizeset		resb	1

solution	resw	20		; numbers in set_sum that are a solution

Q		resq	1		; address of the aux table for the DP algorithm
Qrows		resq	1
Qcols		resq	1

auxneg		resq	1
auxpos		resq	1

	SECTION .data
outp		db	"%d ",0
inp		db	"%d",0
nosol		db	"There is no solution",0
sol		db	"%d is the sum of: ",0
lnfd		db	0xa,0	
	
	SECTION .text
        global  main			; MUST be linked with gcc (not ld)
	
        extern  printf, scanf, malloc

;;; ----------------------------------------------------------------------------

read_data:
	push 	rbp		; normal stack frame
	mov	rbp, rsp
	push	rbx 		; save rbx
	push	r12		; save r12

	lea	rdi, [inp]	; set arg 1 for scanf
	lea	rsi, [sum]	; first element of input data is the sum
	xor	eax, eax	; 0 float parameters
	call	scanf
	cmp	rax, 1		; is scanf ok?
	jne	.end_frd	; if not, jump to the end
	xor	bl, bl		; bl <- 0
	lea	r12, [set_sum]
.for_rd:
	lea	rdi, [inp]	; set arg 1 for scanf
	mov	rsi, r12
	xor	eax, eax	; 0 float parameters
	call	scanf
	cmp	rax, 1		; is scanf ok?
	jne	.end_frd	; if not, jump to the end
	inc 	bl		; bl++    increment size counter
	add	r12, 2		; r12 += 2 increment address in a word (2 bytes)
	jmp	.for_rd
.end_frd:
	mov	byte [sizeset], bl ; return value: size of array

	pop	r12		; restore r12
	pop	rbx		; restore rbx
	leave
	ret
	
;;; ----------------------------------------------------------------------------

initialize:
	push 	rbp			 ; normal stack frame
	mov	rbp, rsp
	push	rbx 			 ; save rbx
	push	r12			 ; save r12

	lea	rdi, [set_sum]
	movzx	rsi, byte [sizeset]
	xor	rax, rax		 ; pos
	xor	rbx, rbx		 ; neg
	xor	rcx, rcx
.loop:
	cmp	rcx, rsi
	je	.end_loop
	
	mov	word [solution+2*rcx], 0 ; solution[i] = 0

	movsx	r10, word [rdi+2*rcx]	 ; tmp (r10) <- set_sum[i]
	cmp	word [rdi+2*rcx], 0  
	jg	.positive		 ; jump if set_sum[i] > 0
	add	rbx, r10		 ; neg += set_sum[i] if set_sum[i] < 0
	jmp	.cont
.positive:
	add	rax, r10		 ; pos += set_sum[i] if set_sum[i] > 0
.cont:
	inc	rcx
	jmp	.loop
.end_loop:
	mov	[auxneg], rbx
	mov	[auxpos], rax
	
	mov 	[Qrows],  rsi
	sub	rax, rbx
	inc	rax
	mov	[Qcols],  rax
	xor 	rdx, rdx
	mul	rsi
	mov	rbx, rax
	mov	rdi, rax		 ; assume rdx is 0 and rax = Qcols x Qrows
	call 	malloc			 ; assume everything goes ok
	mov	[Q], rax		 ; Q <- address of the DP table

	xor	rcx, rcx		 ; Initialize Q[i][j] <-- 0
.initQ:
	cmp	rcx, rbx
	jge	.endinitQ
	mov	byte [rax+rcx], 0
	inc	rcx
	jmp	.initQ
.endinitQ:
	
	pop	r12			 ; restore r12
	pop	rbx			 ; restore rbx
	leave
	ret
	
;;; ----------------------------------------------------------------------------
	
compute_Q:
	push 	rbp			; normal stack frame
	mov	rbp, rsp
	push	rbx 			; save rbx
	push	r12			; save r12

	;; initialization of the first row of Q
	mov	rdi, [Q]		; rdi <-- base address of DP table
	xor	r9, r9			; j = 0
.init_row:
	cmp	r9, [Qcols]		; j < Qcols?
	jge	.end_init_row
	mov	rbx, [auxneg]
	add	rbx, r9			; rbx <--j+auxneg
	cmp	bx, word [set_sum]	; set[0] == (j+auxneg)?
	jne	.cont_init_row
	or	byte [rdi+r9], 0x1
.cont_init_row:
	inc	r9			; ++j
	jmp	.init_row
.end_init_row:

	;; main loop to compute Q
	xor	r8, r8
	inc	r8			; i = 1
.looprows:
	cmp	r8, [Qrows]
	jge	.endrows
	xor	r9, r9			; j = 0
.loopcols:
	cmp	r9, [Qcols]
	jge	.endcols
	;; r10 <-- Q[i-1][j]
	xor	r10, r10
	mov	rax, r8			; 0 < i < Qrows
	dec	rax			; rax <-- i-1
	xor	rdx, rdx
	mul	qword [Qcols]		; rax <-- (i-1) x Qcols
	add  	rax, r9			; rax <-- (i-1) x Qcols + j
	mov	r10b, byte [rdi+rax]
	;; r11 <-- (set[i] == (j+neg)) ? 1 : 0;
	xor	r11, r11
	mov	rbx, [auxneg]
	add	rbx, r9			; rbx <--j+auxneg
	cmp	bx, word [set_sum+2*r8]	; set[i] == (j+auxneg)?
	jne	.cont2ndterm
	or	r11b, 0x1
.cont2ndterm:
	;; r12 <-- Q[i-1][j-set[i]] if ((0 <= (j-set[i])) && ((j-set[i]) < Qcols))
	xor	r12, r12
	mov	rax, r8			; 0 < i < Qrows
	dec	rax			; rax <-- i-1
	xor	rdx, rdx
	mul	qword [Qcols]		; rax <-- (i-1) x Qcols
	mov	rbx, r9
	movsx	rcx, word [set_sum+2*r8]
	sub	rbx, rcx		; rbx <-- j-set[i]
	cmp	rbx, 0
	jl	.cont3rdterm
	cmp	rbx, [Qcols]
	jge	.cont3rdterm
	add  	rax, rbx		; rax <-- (i-1) x Qcols + (j-set[i])
	mov	r12b, byte [rdi+rax]
.cont3rdterm:	
	;; r10 <-- r10 || r11 || r12
	or	r10b, r11b
	or	r10b, r12b
	mov	rax, r8			; 0 < i < Qrows
	xor	rdx, rdx
	mul	qword [Qcols]		; rax <-- i x Qcols
	add  	rax, r9			; rax <-- i x Qcols + j
	mov	byte [rdi+rax], r10b	; Q[i][j] = r10b || r11b || r12b
	inc	r9			; ++j
	jmp	.loopcols
.endcols:
	inc	r8			; ++i
	jmp	.looprows
.endrows:	
	pop	r12			 ; restore r12
	pop	rbx			 ; restore rbx
	leave
	ret
	
;;; ----------------------------------------------------------------------------

find_solution:
	push 	rbp			; normal stack frame
	mov	rbp, rsp
	push	rbx 			; save rbx
	push	r12			; save r12

	mov	rdi, [Q]		; rdi <-- base address of DP table	
	movsx	r12, word [sum]
	mov	r8, r12
	sub	r8, [auxneg]		; r8 (partial) <-- sum-auxneg 
	xor	r9, r9			; r9 (tmp) <-- 0
	mov	rcx, [Qrows]
	dec	rcx			; rcx (i) <-- n-1
.do:					; do {
.while:
	cmp	rcx, 0			; while ((i >= 0) && ...
	jl	.endwhile
	mov	rax, rcx		; 0 <= i < Qrows
	xor	rdx, rdx
	mul	qword [Qcols]			; rax <-- i x Qcols
	add 	rax, r8 		; rax <-- i x Qcols + partial	
	cmp	byte [rdi+rax], 0
	je	.endwhile		; ... && (Q[i][partial]))
	dec	rcx			; --i
	jmp	.while
.endwhile:
	inc	rcx			; ++i
	movsx	rax, word [set_sum+2*rcx]
	mov	word [solution+2*rcx], ax
	sub	r8, rax
	add	r9, rax	
	cmp	rcx, 0
	jle	.enddo
	cmp	r9, r12
	je	.enddo			; } while ((i>0) && (tmp != sum))
	jmp	.do
.enddo:		
	pop	r12			; restore r12
	pop	rbx			; restore rbx
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

	call	read_data
	;; At this point we have set_sum, sizeset and sum initialized
	
	call	initialize
	;; Now we have initialized solutions, auxneg, auxpos, Qrows,
	;; Qcols and allocated space for Q (Qrows x Qcols bytes) 

	movsx	r12, word [sum]
	cmp 	r12, [auxneg]		; is sum < auxneg?
	jl	.nosolution		; if true, there is no solution 
	cmp	r12, [auxpos]		; is sum > auxpos?
	jg	.nosolution		; if true, there is no solution 
	
	;; Ready to go...
	call	compute_Q

	;; It's over -- print the solution, if there is one...
	;; First, find if Q[n-1][sum-neg] == 0
	cmp	qword [Qrows], 0
	je	.nosolution
	mov 	rcx, [Qcols]
	mov	rax, [Qrows]
	dec	rax
	xor	rdx, rdx
	mul	rcx			; assuming rdx = 0, rax = (n-1) x Qcols
	movsx	rcx, word [sum]	
	sub	rcx, [auxneg]		; rcx = sum-neg
	add	rax, rcx		; rax = (n-1) x Qcols + (sum-neg)
	mov	rdi, [Q]
	cmp	byte [rdi + rax], 0
	je	.nosolution		; if Q[n-1][sum-neg] == 0 there is no solution

	;; Q[n-1][sum-neg] == 1, so there is a solution, find it...
	call 	find_solution
	;; Now 'solution' has been computed and
	;; solution[i] != 0 iff set[i] belongs to the solution

	;; print the elements != 0 of 'solution'
	lea	rdi, [sol]
	movsx	rsi, word [sum]
	xor	eax, eax
	call 	printf

	xor 	rbx, rbx 	
.solution:
	cmp	bl, byte [sizeset]
	jge	.end
	cmp	word [solution+2*rbx],0
	je	.noprint
	lea	rdi, [outp]
	movsx	rsi, word [solution+2*rbx]
	xor	eax, eax
	call 	printf
.noprint:	
	inc	rbx
	jmp	.solution
	
.nosolution:
	lea	rdi, [nosol]
	xor	eax, eax
	call 	printf	
.end:
	lea	rdi, [lnfd]
	xor	eax, eax
	call 	printf
	
	;; restore must-preserve registers
	pop	r13			; restore r13
	pop	r12			; restore r12
	pop	rbx			; restore rbx
	
	leave
	ret
	
