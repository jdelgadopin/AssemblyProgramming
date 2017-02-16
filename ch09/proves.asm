
maxsize equ 	10			; max array size
	
	SECTION .bss
arr	resq	maxsize
sze	resq	1



	SECTION .data
inp		db	"%d",0
prompt		db	"Enter array (end it with any non-numerical character): ",0
pr_write	db	"%d ",0
linefd		db	0xa,0

	SECTION .text
        global  _start
	
        extern  printf
	extern  scanf
	extern	rand

;;; ---------------------------------------------------------------------	
	
read_data:
	;; Parameter: array address (rdi)
	;; Return: size (rax)
	push 	rbp		; normal stack frame
	mov	rbp, rsp
	push 	rbx		; save rbx
	push 	r12		; save r12
	mov	r12, rdi	; r12 keeps the initial address of the array
	xor	rbx, rbx	; rbx <- 0
for_rd: 
	lea	rdi, [inp]	; set arg 1 for scanf
	lea	rsi, [r12+rbx*8]; set arg 2 for scanf
	xor	eax, eax	; 0 float parameters
	call	scanf
	cmp	rax, 0		; is scanf ok?
	jle	end_frd		; if not, jump to the end
	inc 	rbx		; rbx++    increment size counter
	cmp	rbx, maxsize	; not allowed to read more than maxsize elements!
	jge 	end_frd
	jmp	for_rd
end_frd:
	mov	rax, rbx	; return value: size of array
	pop	r12		; restore r12
	pop	rbx		; restore rbx
	leave
	ret

;;; ---------------------------------------------------------------------
	
print_data:
	;; Parameter: array address (rdi), size (rsi)
	;; Return: void
	push 	rbp		; normal stack frame
	mov	rbp, rsp
	push 	r12		; save r12
	push 	rbx		; save rbx
	push	rsi		; save rsi (size at [rsp])
	mov	r12, rdi
	xor	rbx, rbx	; rbx <- 0
for_pd:	cmp 	rbx, [rsp]
	jge	end_fpd
	lea	rdi, [pr_write]	; address of pr_write
	mov	rsi, [r12+rbx*8]; next data
        xor     eax, eax	; 0 float parameters
        call    printf
	inc	rbx		; rbx++
	jmp	for_pd
end_fpd:	
	lea	rdi, [linefd]	; address of pr_read
        xor     eax, eax	; 0 float parameters
        call    printf
	pop	rsi		; this value need not be restored, but I must
				; pop it from the stack anyway
	pop	rbx		; restore rbx
	pop	r12		; restore r12
	leave
	ret

;;; ---------------------------------------------------------------------
	
_start:
	
	lea	rdi, [prompt]	; address of prompt
        xor     eax, eax	; 0 float parameters
        call    printf
	
	lea	rdi, [arr]
	call 	read_data
	mov 	[sze], rax

	lea	rdi, [arr]
	mov	rsi, [sze]
	call 	print_data
	
	mov	eax, 60	     	; exit
	xor	edi, edi
	syscall
