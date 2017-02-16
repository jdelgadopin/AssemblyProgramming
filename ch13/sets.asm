	SECTION .bss
cjnts	resq	156250		; 10 x 10^6 bits are 156250 qwords
cmmand	resb	256		; commands are at most 6 chars long, but
				;  a 256 byte wide field helps to deal
				;  with wrong inputs
param1  resq	1
param2	resq	1

        SECTION .data
cmndstr	db	"%s",0
inp	db	"%d",0
outp	db	"%d ",0
prompt1 db	"Enter command (add, union, print, quit): ",0
prompt2 db	"Enter parameters: ",0
linefd	db	0xa,0
	
union	db	"union",0
print	db	"print",0
quit	db	"quit",0
ad	db	"add",0
	
	SECTION .text
        global  _start
	
        extern  printf
	extern  scanf
	
;;; -------------------------------------------------------

read_command:
	push 	rbp
	mov	rbp, rsp
beg_rc: ;; print command prompt
	lea	rdi, [prompt1]
	xor	eax, eax
	call 	printf
	;; initialize the 256 bytes of command to 0
	xor	al, al
	mov	ecx, 256
	lea	rdi, [cmmand]
	rep	stosd
	;; read command
	lea	rdi, [cmndstr]
	lea	rsi, [cmmand]
	xor	eax, eax
	call	scanf
	;; check what command has been given
	;; has it been 'add'?
	lea	rsi, [cmmand]	; address of name
	lea	rdi, [ad]	; address of the constant string 'add\0'
	mov	rcx, 5		; chars in 'add\0' + 1
	repe	cmpsb		; compare both strings
	cmp	rcx, 0
	jne	lb_un		; if not equal check 'union' 
	mov	rax, 0
	jmp 	end_rc
lb_un:	;; has it been 'union'?
	lea	rsi, [cmmand]	; address of name
	lea	rdi, [union]	; address of the constant string 'union\0'
	mov	rcx, 7		; chars in 'union\0' + 1
	repe	cmpsb		; compare both strings
	cmp	rcx, 0
	jne	lb_pr		; if not equal check 'print' 
	mov	rax, 1
	jmp 	end_rc
lb_pr:	;; has it been 'print'?
	lea	rsi, [cmmand]	; address of name
	lea	rdi, [print]	; address of the constant string 'print\0'
	mov	rcx, 7		; chars in 'print\0' + 1
	repe	cmpsb		; compare both strings
	cmp	rcx, 0
	jne	lb_qu		; if not equal check 'quit' 
	mov	rax, 2
	jmp 	end_rc
lb_qu:	;; has it been 'quit'?
	lea	rsi, [cmmand]	; address of name
	lea	rdi, [quit]	; address of the constant string 'quit\0'
	mov	rcx, 6		; chars in 'quit\0' + 1
	repe	cmpsb		; compare both strings
	cmp	rcx, 0
	jne	beg_rc		; if not equal start again 
	mov	rax, 3
end_rc:	
	leave
	ret
	
;;; -------------------------------------------------------
	
_add:
	push 	rbp
	mov	rbp, rsp
	push	rbx
	;; read parameters
	lea	rdi, [prompt2]
	xor	eax, eax
	call 	printf
	lea	rdi, [inp]
	lea 	rsi, [param1]
	xor	eax, eax
	call 	scanf
	;; check if [param1] is in range {0,1,2,3,4,5,6,7,8,9}
	;; if not, start again
	cmp	qword [param1], 0
	jl	e_add
	cmp	qword [param1], 9
	jg	e_add
	;; now we know [param1] is a set number	
	lea	rdi, [inp]
	lea 	rsi, [param2]
	xor	eax, eax
	call 	scanf
	;; check if [param2] is in range 0 <= [param2] <= 999999
	;; if not, start again
	cmp	qword [param2], 0
	jl	e_add
	cmp	qword [param2], 999999
	jg	e_add
	;; now we know [param2] is an element of a set
	mov	rax, [param1]
	mov 	rbx, 15625		
	mul 	rbx		   	; result in rax (we will assume rdx is zero)
	lea	rbx, [cjnts + 8*rax]
	mov	rax, rbx		; rax contains now the address of the set
	mov	rbx, [param2]
	shr	rbx, 6			; divide by 64 (bits per qword)
	mov 	rcx, [param2]
	and	rcx, 0x3F		; remainder
	bts	[rax+8*rbx], rcx
e_add:
	pop	rbx
	leave
	ret

;;; -------------------------------------------------------

_union:
	push 	rbp
	mov	rbp, rsp
	push 	r12			
	push	rbx
	;; read parameters
	lea	rdi, [prompt2]
	xor	eax, eax
	call 	printf
	lea	rdi, [inp]
	lea 	rsi, [param1]
	xor	eax, eax
	call 	scanf
	;; check if [param1] is in range {0,1,2,3,4,5,6,7,8,9}
	;; if not, start again
	cmp	qword [param1], 0
	jl	e_union
	cmp	qword [param1], 9
	jg	e_union
	;; now we know [param1] is a set number	
	lea	rdi, [inp]
	lea 	rsi, [param2]
	xor	eax, eax
	call 	scanf
	;; check if [param2] is in range {0,1,2,3,4,5,6,7,8,9}
	;; if not, start again
	cmp	qword [param2], 0
	jl	e_union
	cmp	qword [param2], 9
	jg	e_union
	;; now we know [param2] is a set number	
	mov	rax, [param1]
	mov 	rbx, 15625	
	mul 	rbx		   	; result in rax (we will assume rdx is zero)
	lea	rbx, [cjnts + 8*rax]
	mov 	r8, rbx			; r8 contains now the address of the set [param1]
	mov	rax, [param2]
	mov 	rbx, 15625	
	mul 	rbx		   	; result in rax (we will assume rdx is zero)
	lea	rbx, [cjnts + 8*rax]
	mov 	r9, rbx			; r9 contains now the address of the set [param2]
	xor 	rcx, rcx
un_loop:				; or [param1], [param2] - qword a qword 
	cmp	rcx, 15625
	je	e_union
	mov	r12, qword [r9+8*rcx]
	or	qword [r8+8*rcx], r12	
	inc 	rcx
	jmp	un_loop	
e_union:
	pop	rbx
	pop	r12
	leave
	ret

;;; -------------------------------------------------------

_print:
	push 	rbp
	mov	rbp, rsp
	push	r14		; save r12, r13, r14, rbx
	push	r13
	push 	r12
	push	rbx
	;; read parameter
	lea	rdi, [prompt2]
	xor	eax, eax
	call 	printf
	lea	rdi, [inp]
	lea 	rsi, [param1]
	xor	eax, eax
	call 	scanf
	;; check if [param1] is in range {0,1,2,3,4,5,6,7,8,9}
	;; if not, start again
	cmp	qword [param1], 0
	jl	again
	cmp	qword [param1], 9
	jg	again
	;; now we know [param1] is a set number	
	mov	rax, [param1]
	mov 	rbx, 15625	
	mul 	rbx		   	; result in rax (we will assume rdx is zero)
	lea	rbx, [cjnts + 8*rax]	; rbx contains the address of the set
	xor 	r12, r12		; qword counter
	xor	r14, r14		; bit counter
pr_loop:				 
	cmp	r12, 15625
	je	e_print
	xor	r13, r13
bit_lp:	cmp	r13, 64
	jge	e_bit
	bt	qword [rbx+8*r12], r13
	jnc	ct_bit
	lea	rdi, [outp]
	mov	rsi, r14
	xor	eax, eax
	call 	printf
ct_bit:	inc	r13
	inc	r14
	jmp	bit_lp
e_bit:	inc 	r12
	jmp	pr_loop	
e_print:
	lea	rdi, [linefd]
	xor	eax, eax
	call 	printf
	pop	rbx			; restore r12, r13, r14, rbx
	pop	r12
	pop	r13
	pop	r14
	leave
	ret

;;; -------------------------------------------------------
	
_start:
	
again:	call 	read_command
	;; rax contains 0, 1, 2 or 3
	;; check for quit
	cmp	rax, 3
	je	end
nxt_ad:	cmp	rax, 0
	jne	nxt_un
	call	_add
	jmp  	again	
nxt_un:	cmp 	rax, 1
	jne 	nxt_pr
	call	_union
	jmp 	again
nxt_pr: ;; no need to check if rax = 2, sure it is
	call	_print
	jmp	again	
end:	mov	eax, 60	     	; exit
	xor	edi, edi
	syscall
