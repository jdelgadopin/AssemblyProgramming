	SECTION .bss
parens	resb	80

	
        SECTION .data
prompt  db	"Enter parentheses string (max 80): ",0
strng	db	"%s",0
blncd	db	"Good!",0xa,0
nblncd	db	"Bad @ char %d",0xa,0
	

	SECTION .text
        global  _start
	
        extern  printf
	extern  scanf
	
;;; -------------------------------------------------------

read_parens:	
	push 	rbp
	mov	rbp, rsp
	;; print prompt
	lea	rdi, [prompt]
	xor	eax, eax
	call 	printf
	;; read parentheses string
	lea	rdi, [strng]
	lea	rsi, [parens]
	xor	eax, eax
	call	scanf
	leave
	ret
	
;;; -------------------------------------------------------
	
balanced:
	push 	rbp
	mov	rbp, rsp
	push 	rdi		; save index
	mov	rcx, [rsp]
	cmp	byte [rcx], 0x0	; is index pointing to null?
	je	e_bc
	cmp	byte [rcx], 0x29 ; is index pointing to ')' (0x29 ascii code for ')')
	jne	rec_case
e_bc:	mov	rax, [rsp]	; return index in rax
	leave
	ret
rec_case: 			; now, index IS pointing to '(' (0x28 ascii code for '(')
	inc	rcx		; next char, 1 byte per char
	mov	rdi, rcx
	call	balanced
	cmp	byte [rax], 0x29
	jne	e_rc
	inc 	rax
	mov	rdi, rax
	call 	balanced
	leave
	ret
e_rc:	mov	rax, [rsp]
	leave
	ret
	
;;; -------------------------------------------------------
	
_start:
	call 	read_parens
	;; I am assuming the string contains ONLY '(', ')', or '\0'
	lea	rdi, [parens]
	call	balanced
	cmp	byte [rax], 0x0
	jne	bad
	lea	rdi, [blncd]
	xor	eax, eax
	call	printf
	jmp 	end
bad:	lea	rdi, [nblncd]
	lea	rcx, [parens - 1]
	sub	rax, rcx
	mov	rsi, rax
	xor	eax, eax
	call	printf
end:	mov	eax, 60	     	; exit
	xor	edi, edi
	syscall
