
	;; files will be read in chunks of blocksize size
blocksize	equ	512

;;; ---------------------------------------------------------------------
	
	SECTION .bss
fdinput		resd	1
buffer		resb	blocksize	
lines		resq	1
words		resq	1
bytes		resq	1

;;; ---------------------------------------------------------------------
	
	SECTION .data
printerror	db	"read failure",0xa,0
results		db	"%s -- %d lines -- %d words -- %d bytes",0xa,0	

;;; ---------------------------------------------------------------------

	SECTION .text
        global  main		; MUST be linked with gcc (not ld)
	
        extern  printf, open, read, close		
main:
	push	rbp
	mov	rbp, rsp
	push	rbx		; save rbx
	push	r12		; save r12
	push	r13		; save r13
	
	mov	rbx, rsi	; save argv address
	add	rbx, 8		; start with argv[1]
.start_loop:
	mov	rsi, [rbx]	; address of the i-th string (content of argv[i])
	cmp	rsi, 0
	je	.end_loop
	mov	rdi, rsi	; address of filename
	mov	esi, 0x0	; open as read-only
	call	open
	cmp	eax, 0
	jl	.next_file
	mov	[fdinput], eax	; save file descriptor
	;; now the file is open, let's process it...
	mov	qword [lines], 0
	mov	qword [words], 0
	mov	qword [bytes], 0
	xor	r13, r13	; boolean for "previous byte was a non-space?"
.next_chunk:
	mov	rdi, [fdinput]
	lea	rsi, [buffer] 
	mov	rdx, blocksize
	call	read
	cmp	eax, 0		; end the loop by not having anything to read (or error)
	jle	.close_file
	mov	r12, rax	; r12 <-- number of bytes read
	add	qword [bytes], r12
	xor	rcx, rcx
.next_byte:
	cmp	rcx, r12
	jge	.end_chunk
.skip_spaces:
	;; skip spaces
	cmp	byte [buffer+rcx], 0x20
	jne	.not_a_space
	cmp	r13, 0x0
	je	.after_space_1
	xor	r13, r13
	inc	qword [words]
.after_space_1:
	inc	rcx
	jmp 	.next_byte
.not_a_space:
	cmp	byte [buffer+rcx], 0xa
	jne	.not_new_line
	cmp	r13, 0x0
	je	.after_space_2
	xor	r13, r13
	inc	qword [words]
.after_space_2:
	inc	qword [lines]
	jmp 	.cont
.not_new_line:
	mov	r13, 0x1
.cont:	
	inc	rcx
	jmp	.next_byte
.end_chunk:
	jmp	.next_chunk
.close_file:
	mov	edi, [fdinput]
	call	close	
	;; print results
	lea	rdi, [results]
	mov	rsi, [rbx]
	mov	rdx, [lines]
	mov	rcx, [words]
	mov	r8,  [bytes]
	xor	eax, eax
	call 	printf
.next_file:	
	add	rbx, 8
	jmp	.start_loop
.end_loop:
	pop	r13
	pop	r12
	pop	rbx
	leave
	ret
	
