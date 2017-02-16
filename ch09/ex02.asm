	;; Calling C external functions may change the value
	;; in some registers. Be aware!!!
	
	maxsize equ 	100			; max array size

	SECTION .bss
arr	resq	maxsize
sze	resq	1
	
	SECTION .data
inp		db	"%d",0
prompt		db	"Enter array size (0 to stop, max %d): ",0
pr_write	db	"%d ",0
linefd		db	0xa,0
	
	SECTION .text
        global  _start
	
        extern  printf
	extern  scanf
	extern	rand

create_data:
	;; Parameter: array address (rdi), size (rsi)
	;; Return: void
	push 	rbp		; normal stack frame
	mov	rbp, rsp
	sub	rsp, 24		; space for address, size and r12
	mov	[rsp + 16], r12
	mov	[rsp], rdi	; save address
	shl	rsi, 3		; every element array is a quad-word
	add	rsi, rdi	; [rsi] <- array address + 8 x size
	mov	[rsp + 8], rsi	; [rsp+8] <- array address + 8 x size
	mov	r12, [rsp]	; r12 <- array address
for_rd:	cmp 	r12, [rsp + 8]
	jge	end_frd
	call 	rand		; assuming the returning value goes to rax
	xor	rdx, rdx	; rax has a number in [0,RAND_MAX], too big
	mov	r8, 1000	; we want random numbers in [0,1000]
	idiv 	r8		; we divide by 1000
	mov	[r12], rdx	; remainder is in rdx
	add	r12, 8
	jmp	for_rd
end_frd:
	mov	r12, [rsp + 16]
	leave
	ret
	
sort_data:
	;; Bubble sort
	;; Parameter: array address (rdi), size (rsi)
	;; Return: void
	push 	rbp			; normal stack frame
	mov	rbp, rsp
	sub	rsp, 16			; space for the address and r12
	mov	[rsp + 8], r12
	mov	[rsp], rdi		; [rsp] <- array address
	dec 	rsi			; size - 1
	shl	rsi, 3			; (size-1) x 8
	add 	rdi, rsi		; rdi <- array address + (size-1) x 8
s_do:	xor	ax, ax			; swapped = false (rax = swapped)
	mov 	rcx, [rsp]		; i = "0"  (rcx = i)
s_for:	cmp	rcx, rdi
	jge	e_do			; jump if i == size-1
	mov 	r12, [rcx + 8]
	cmp	[rcx], r12
	jle	e_for			; jump if a[i] <= a[i+1]
	xor	r12, [rcx]		; swap a[i] and a[i+1]
	xor	[rcx], r12
	xor	r12, [rcx]
	mov	[rcx + 8], r12
	or 	ax, 0x1			; swapped = true
e_for:	add	rcx, 8
	jmp 	s_for
e_do:	bt	ax, 0
	jc	s_do
	mov	r12, [rsp + 8]
	leave
	ret

print_data:
	;; Parameter: array address (rdi), size (rsi)
	;; Return: void
	push 	rbp		; normal stack frame
	mov	rbp, rsp
	sub	rsp, 24		; space for address, size and r12
	mov	[rsp + 16], r12
	mov	[rsp], rdi	; save address
	shl	rsi, 3		; every element array is a quad-word
	add	rsi, rdi  	; rsi <- array address + 8 x size
	mov	[rsp + 8], rsi	; [rsp+8] <- array address + 8 x size
	mov	r12, [rsp]	; r12 <- array address
for_pd:	cmp 	r12, [rsp + 8]
	jge	end_fpd
	lea	rdi, [pr_write]	; address of pr_write
	mov	rsi, [r12]	; next data
        xor     eax, eax	; 0 float parameters
        call    printf
	add	r12, 8
	jmp	for_pd
end_fpd:	
	lea	rdi, [linefd]	; address of pr_read
        xor     eax, eax	; 0 float parameters
        call    printf
	mov	r12, [rsp + 16]
	leave
	ret
	
_start:
	
again:
	lea	rdi, [prompt]	; address of prompt
	mov	rsi, maxsize	; maxsize
        xor     eax, eax	; 0 float parameters
        call    printf
	lea	rdi, [inp]	; set arg 1 for scanf
	lea	rsi, [sze]	; set arg 2 for scanf
	xor	eax, eax	; 0 float parameters
	call	scanf
	mov	r8, [sze]	; cmp doesn't like [sze] as operand 1 :(
	cmp	r8, 0
	je	end		; if 0 terminate the program
	cmp	r8, maxsize
	jg	again		; if > maxsize, ask again
	
	lea	rdi, [arr]
	mov	rsi, [sze]
	call 	create_data	

	lea	rdi, [arr]
	mov	rsi, [sze]
	call 	print_data
	
	lea	rdi, [arr]
	mov	rsi, [sze]
	call	sort_data
	
	lea	rdi, [arr]
	mov	rsi, [sze]
	call 	print_data

	jmp	again	

end:	mov	eax, 60	     	; exit
	xor	edi, edi
	syscall
