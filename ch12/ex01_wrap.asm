	SECTION .bss
fileinput	resq	1
fdinput		resd	1
fileoutput	resq	1
fdoutput	resd	1
buffsize	resq	1	

	SECTION .data
printerror	db	"copy failure",0xa,0
	
	SECTION .text
        global  main		; MUST be linked with gcc (not ld)
	
        extern  printf, malloc, atol, open, read, write, close

;;; ----------------------------------------------------------------------------
		
main:
	push	rbp
	mov	rbp, rsp
	push	rbx		; save rbx
	push	r12		; save r12
	;; read command line parameters
	lea	rcx, [rsi+8]	; address of argv[1]
	mov	rcx, [rcx]	; rcx <- content of argv[1] (string address)
	mov	[fileinput], rcx
	lea	rcx, [rsi+16]	; address of argv[2]
	mov	rcx, [rcx]	; rcx <- content of argv[2] (string address)
	mov	[fileoutput], rcx
	lea	rcx, [rsi+24]
	mov	rdi, [rcx]
	call	atol
	mov	[buffsize], rax	; save size
	;; now everything is in place
	;; let's copy the files...
	mov	rdi, [buffsize]
	call	malloc		; reserve space for buffer
	mov	rbx, rax	; rbx <-- buffer address (assuming everything is ok)
	;; open files
	mov	rdi, [fileinput]
	mov	esi, 0x0	; fileinput is read-only
	call	open
	cmp	eax, 0
	jl	.error
	mov	[fdinput], eax
	mov	rdi, [fileoutput]
	mov	esi, 0x42	; fileoutput is read-write | create
	mov	rdx, 600o	; read-write mode for user
	call	open
	cmp	eax, 0
	jl	.error
	mov	[fdoutput], eax
	;; now copy... iterate thru reads of buffsize size and write them to fileoutput
.loop:
	mov	rdi, [fdinput]
	mov	rsi, rbx
	mov	rdx, [buffsize]
	call	read
	cmp	rax, 0		; end the loop by not having anything to read (or error)
	jle	.close
	mov	r12, rax	; r12 <-- number of bytes read
	mov	rdi, [fdoutput]
	mov	rsi, rbx
	mov	rdx, r12
	call	write
	jmp	.loop
.close:
	;; close files and go to the end
	mov	edi, [fdinput]
	call	close
	mov	edi, [fdoutput]
	call	close
	jmp	.end	
.error:
	lea	rdi, [printerror]
	xor	eax, eax
	call 	printf	
.end:	
	pop	r12
	pop	rbx
	leave
	ret
	
