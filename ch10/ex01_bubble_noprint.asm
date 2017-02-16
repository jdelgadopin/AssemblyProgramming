	SECTION .data
	
	SECTION .text
        global  main		; MUST be linked with gcc (not ld)
	
        extern  rand, malloc, atol

;;; ----------------------------------------------------------------------------
	
create_data:
	;; Parameter: array size (rdi)
	;; Return: array address
.array	equ 	0
.size	equ	8
.r12	equ	16
.rbx	equ	24
	push 	rbp		  	; normal stack frame
	mov	rbp, rsp
	sub	rsp, 32		  	; space for address, size, r12 and rbx
	mov	[rsp+.rbx], rbx		; save rbx
	mov	[rsp+.r12], r12		; save r12
	mov	[rsp+.size], rdi  	; save size
	shl	rdi, 2		  	; array of double words => size x 4 bytes
	call	malloc
	mov	[rsp+.array], rax 	; save array address
	mov	rbx, [rsp+.array]	; rbx <- array base address
	xor	r12, r12	  	; r12 <- 0
.for:
	cmp 	r12, [rsp+.size]  	; r12 < size? 
	jge	.end		  	; if not, end the loop
	call 	rand		  	; assuming the returning value goes to rax
	xor	rdx, rdx	  	; rax has a number in [0,RAND_MAX], too big
	mov	r8, 10000	  	; we want random numbers in [0,10000]
	idiv 	r8		  	; we divide by 1000
	mov	dword [rbx+4*r12], edx	; remainder is in edx
	inc	r12			; r12++
	jmp	.for
.end:
	mov	rax, [rsp+.array] 	; return value
	mov	r12, [rsp+.r12]		; restore r12
	mov	rbx, [rsp+.rbx]		; restore rbx
	leave
	ret
	
;;; ----------------------------------------------------------------------------
	
sort_data:
	;; Bubble sort
	;; Parameter: array address (rdi), size (rsi)
	;; Return: void
	push 	rbp			; normal stack frame
	mov	rbp, rsp
	sub	rsp, 16			; space for address and r12
	mov	[rsp + 8], r12
	mov	[rsp], rdi		; [rsp] <- array address
	dec 	rsi			; size - 1
	shl	rsi, 2			; (size-1) x 4
	add 	rdi, rsi		; rdi <- array address + (size-1) x 4
s_do:	xor	ax, ax			; swapped = false (rax = swapped)
	mov 	rcx, [rsp]		; i = "0"  (rcx = i)
s_for:	cmp	rcx, rdi
	jge	e_do			; jump if i == size-1
	mov 	r12d, dword [rcx+4]	; r12 <- a[i+1]
	cmp	dword [rcx], r12d
	jle	e_for			; jump if a[i] <= a[i+1]
	xor	r12d, dword [rcx]	; swap a[i] and a[i+1]
	xor	dword [rcx], r12d
	xor	r12d, dword[rcx]
	mov	dword [rcx+4], r12d
	or 	ax, 0x1			; swapped = true
e_for:	add	rcx, 4
	jmp 	s_for
e_do:	bt	ax, 0
	jc	s_do
	mov	r12, [rsp + 8]
	leave
	ret

;;; ----------------------------------------------------------------------------
	
main:
	push	rbp
	mov	rbp, rsp
	sub	rsp, 16
	mov	rcx, rsi
	add	rcx, 8		; assuming argc=2, rcx is the address of argv[1]
	mov	rdi, [rcx]	; rdi <- content of argv[1]
	call	atol
	push 	rax		; save size
	mov	rdi, rax
	call	create_data
	push	rax		; save address
	;; now --> [rsp+8] = size and [rsp] = address
	mov	rdi, [rsp]
	mov	rsi, [rsp+8]
	call	sort_data
	leave
	ret
	
