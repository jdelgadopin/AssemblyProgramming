	SECTION .data
search_int	dd	0
	
pr_write	db	"%d ",0
linefd		db	0xa,0
inp		db	"%d",0
prompt		db	"Enter number (in [0,999]): ",0	
found		db	"Index of %d: %d",0xa,0
notfound	db	"%d is not in the array",0xa,0
	
	SECTION .text
        global  main		; MUST be linked with gcc (not ld)
	
        extern  printf, rand, malloc, atol, qsort, scanf

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
	mov	r8, 1000	  	; we want random numbers in [0,1000]
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

compare:
	;; Parameters: integer address
	push	rbp
	mov	rbp, rsp
	mov	eax, dword [rdi]
	sub	eax, dword [rsi]
	leave
	ret
	
sort_data:
	;; qsort, calling the C function
	;; Parameter: array address (rdi), size (rsi)
	;; Return: void
	push 	rbp			; normal stack frame
	mov	rbp, rsp
	;; rdi and rsi are already correct
	mov	rdx, 4
	lea	rcx, [compare]
	call	qsort
	leave
	ret

;;; ----------------------------------------------------------------------------
	
print_data:
	;; Parameter: array address (rdi), size (rsi)
	;; Return: void
.array	equ 	0
.size	equ	8
.r12	equ	16
	push 	rbp			; normal stack frame
	mov	rbp, rsp
	sub	rsp, 32			; space for address, size, r12 and alignment
	mov	[rsp+.r12], r12		; save r12
	mov	[rsp+.size], rsi	; save size
	mov	[rsp+.array], rdi	; save address
	xor	r12, r12		; r12 <- 0
.for:
	cmp 	r12, [rsp+.size]
	jge	.end
	mov	rcx, [rsp+.array] 	; since printf will modify rcx
	lea	rdi, [pr_write]		; address of pr_write
	mov	rsi, [rcx+4*r12]	; next data
        xor     eax, eax		; 0 float parameters
        call    printf
	inc	r12
	jmp	.for
.end:	
	lea	rdi, [linefd]		; address of pr_read
        xor     eax, eax		; 0 float parameters
        call    printf
	mov	r12, [rsp+.r12]		; restore r12
	leave
	ret

;;; ----------------------------------------------------------------------------

binary_search:
.array	equ 	0
.size	equ	8
.srch	equ	16
.r12	equ	24
	push 	rbp			; normal stack frame
	mov	rbp, rsp
	sub	rsp, 32			; space for address, size, search_int and r12
	mov	[rsp+.r12], r12		; save r12
	mov	[rsp+.srch], rdx	; save locally [search_int]
	mov	[rsp+.size], rsi	; save size
	mov	[rsp+.array], rdi	; save address
	
	mov	rax, -1			; initialize result with "not found"

	xor	r8, r8			; left (index)  = 0
	mov	r9, [rsp+.size]
	dec	r9			; right (index) = size - 1
.loop_bs:
	cmp	r8, r9
	jg	.end_bs			; if left > right, not found
	mov	rcx, r9
	sub	rcx, r8
	shr	rcx, 1
	add	rcx, r8			; middle (rcx) <- left + (right - left)/2
					; (to avoid overflows in very large arrays)
	movsxd	r12, dword [rdi+4*rcx] ; rdi still has the array base address
	cmp	r12, [rsp+.srch]
	jge	.great
.less:
	mov	r8, rcx			; [rdi + 4*rcx] < [rsp+.srch]
	inc	r8			; left <- middle + 1
	jmp	.loop_bs
.great:
	cmp	r12, [rsp+.srch]
	je	.equal
	
	mov	r9, rcx			; [rdi + 4*rcx] > [rsp+.srch]
	dec	r9			; right <- middle -1
	jmp	.loop_bs
.equal:
	mov	rax, rcx
.end_bs:
	mov	r12, [rsp+.r12]		; restore r12
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

	mov	rdi, [rsp]
	mov	rsi, [rsp+8]
	call	print_data	
.search:	
	;; Ask for numbers to search...
	lea	rdi, [prompt]
	xor	eax, eax
	call	printf
	lea	rdi, [inp]	; set arg 1 for scanf
	lea	rsi, [search_int]
	xor	eax, eax	; 0 float parameters
	call	scanf
	cmp	rax, 0		; is scanf ok?
	jle	.end		; if not, jump to the end
	;; check if [search_int] is in range 0 <= [search_int] <= 999
	;; if not, ask again
	cmp	dword [search_int], 0
	jl	.search
	cmp	dword [search_int], 999
	jg	.search
	;; now,  0 <= [search_int] <= 999
	
	mov	rdi, [rsp]
	mov	rsi, [rsp+8]
	movsxd	rdx, dword [search_int]
	call	binary_search
	;; rax should contain the index of the element, or -1 if not found
	
	cmp	rax, 0
	jl	.not_f
	
	lea	rdi, [found]
	movsxd	rsi, dword [search_int]
	mov	rdx, rax
	xor	eax, eax
	call 	printf
	jmp	.search
.not_f:
	lea	rdi, [notfound]
	movsxd	rsi, dword [search_int]
	xor 	eax, eax
	call 	printf
	jmp	.search
.end:	
	leave
	ret
	
