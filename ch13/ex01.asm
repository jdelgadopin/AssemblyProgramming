;;; ---------------------------------------------------------------------

	SECTION .bss
cmand		resb	256	; input string
element		resq	1	; input element
_set		resq	1	; address of the set instance
	
;;; ---------------------------------------------------------------------
	
        SECTION .data
	
	struc Set
s_size		resq	1 	; set size
s_set		resq	1	; address of the bit-array
	endstruc
	
	
inp		db	"%s %d",0
prompt 		db	"Enter command (add, remove, test, quit) and an element: ",0
linefd		db	0xa,0

	
_add		db	"add",0
_added		db	"%d added",0xa,0	
_remove		db	"remove",0
_removed	db	"%d removed",0xa,0
_test		db	"test",0
_belongs	db	"%d belongs to the set",0xa,0
_notbelongs	db	"%d not belongs to the set",0xa,0
_quit		db	"quit",0

;;; ---------------------------------------------------------------------

	SECTION .text
        global  main		; MUST be linked with gcc (not ld)
	
        extern  scanf, printf, malloc, free, atol

;;; ---------------------------------------------------------------------

read_command:
	push 	rbp
	mov	rbp, rsp
.beg_rc: ;; print command prompt
	lea	rdi, [prompt]
	xor	eax, eax
	call 	printf
	;; initialize the 256 bytes of command to 0
	xor	al, al
	mov	rcx, 256
	lea	rdi, [cmand]
	rep	stosb
	;; read command
	lea	rdi, [inp]
	lea	rsi, [cmand]
	lea	rdx, [element]
	xor	eax, eax
	call	scanf
	;; check what command has been given
	;; has it been 'add'?
	lea	rsi, [cmand]	; address of name
	lea	rdi, [_add]	; address of the constant string 'add\0'
	mov	rcx, 5		; chars in 'add\0' + 1
	repe	cmpsb		; compare both strings
	cmp	rcx, 0
	jne	.lb_rem		; if not equal check 'remove' 
	mov	rax, 0
	jmp 	.end_rc
.lb_rem:;; has it been 'remove'?
	lea	rsi, [cmand]	; address of name
	lea	rdi, [_remove]	; address of the constant string 'remove\0'
	mov	rcx, 8		; chars in 'remove\0' + 1
	repe	cmpsb		; compare both strings
	cmp	rcx, 0
	jne	.lb_tst		; if not equal check 'test' 
	mov	rax, 1
	jmp 	.end_rc
.lb_tst:;; has it been 'test'?
	lea	rsi, [cmand]	; address of name
	lea	rdi, [_test]	; address of the constant string 'test\0'
	mov	rcx, 6		; chars in 'test\0' + 1
	repe	cmpsb		; compare both strings
	cmp	rcx, 0
	jne	.lb_qu		; if not equal check 'quit' 
	mov	rax, 2
	jmp 	.end_rc
.lb_qu:	;; has it been 'quit'?
	lea	rsi, [cmand]	; address of name
	lea	rdi, [_quit]	; address of the constant string 'quit\0'
	mov	rcx, 6		; chars in 'quit\0' + 1
	repe	cmpsb		; compare both strings
	cmp	rcx, 0
	jne	.beg_rc		; if not equal start again 
	mov	rax, 3
.end_rc:	
	leave
	ret
	
;;; ---------------------------------------------------------------------

fun_add:
	push 	rbp
	mov	rbp, rsp
	push	rbx
	push	r12
	push	r13

	mov	rbx, [_set]
	mov	rdx, [rbx + s_set]
	
	;; check if 0 <= [element] < s_size
	;; if not, quit
	cmp	qword [element], 0
	jl	.ret_wrong
	mov	rcx, qword [rbx+s_size]
	cmp	rcx, qword [element]
	jle	.ret_wrong

	;; now we know [element] is a set element	
	mov	rax, [element]
	shr	rax, 6			; rax <-- [element]/64 
	mov	r12, [element]
	and	r12, 0x3F		; r12 <-- reminder of [element]/64	
	mov	r13, qword [rdx+8*rax]	
	bt	r13, r12
	jc	.ret_wrong		; the element was already there
	bts	qword [rdx+8*rax], r12	; the element is added
	mov	rax, 0x1
	jmp	.end_add
	
.ret_wrong:
	xor	rax, rax
	
.end_add:	
	pop	r13
	pop 	r12
	pop	rbx
	leave
	ret
	
;;; ---------------------------------------------------------------------

fun_remove:
	push 	rbp
	mov	rbp, rsp
	push	rbx
	push	r12
	push	r13

	mov	rbx, [_set]
	mov	rdx, [rbx + s_set]
	
	;; check if 0 <= [element] < s_size
	;; if not, quit
	cmp	qword [element], 0
	jl	.ret_wrong
	mov	rcx, qword [rbx+s_size]
	cmp	rcx, qword [element]
	jle	.ret_wrong

	;; now we know [element] is a set element	
	mov	rax, [element]
	shr	rax, 6			; rax <-- [element]/64 
	mov	r12, [element]
	and	r12, 0x3F		; r12 <-- reminder of [element]/64	
	mov	r13, qword [rdx+8*rax]	
	bt	r13, r12
	jnc	.ret_wrong		; the element wasn't there
	btr	qword [rdx+8*rax], r12	; the element is removed
	mov	rax, 0x1
	jmp	.end_remove
	
.ret_wrong:
	xor	rax, rax

.end_remove:
	pop	r13
	pop 	r12
	pop	rbx
	leave
	ret
	
;;; ---------------------------------------------------------------------

fun_test:
	push 	rbp
	mov	rbp, rsp
	push	rbx
	push	r12
	push	r13

	mov	rbx, [_set]
	mov	rdx, [rbx + s_set]
	
	;; check if 0 <= [element] < s_size
	;; if not, quit
	cmp	qword [element], 0
	jl	.ret_wrong
	mov	rcx, qword [rbx+s_size]
	cmp	rcx, qword [element]
	jle	.ret_wrong

	;; now we know [element] is a set element	
	mov	rax, [element]
	shr	rax, 6			; rax <-- [element]/64 
	mov	r12, [element]
	and	r12, 0x3F		; r12 <-- reminder of [element]/64	
	mov	r13, qword [rdx+8*rax]	
	bt	r13, r12
	jnc	.ret_wrong		; the element wasn't there
	mov	rax, 0x1
	jmp	.end_test
	
.ret_wrong:
	xor	rax, rax

.end_test:
	pop	r13
	pop 	r12
	pop	rbx
	leave
	ret
	
;;; ---------------------------------------------------------------------

main:
	push	rbp
	mov	rbp, rsp
	push	rbx		; save rbx
	push	r12		; save r12

	;; create an instance of Set from the set size entered in the command line
	;; -----------------------------------------------------------------------
	;; read set size from command line
	mov	rcx, rsi
	add	rcx, 8		; assuming argc=2, rcx is the address of argv[1]
	mov	rdi, [rcx]	; rdi <- content of argv[1]
	call	atol
	mov	r12, rax	; save set size in r12
	;; create an instance of Set
	mov	rdi, Set_size
	call	malloc
	mov	[_set], rax	; save set address
	;; save set size in the corresp. field
	mov	rbx, [_set]
	mov	[rbx+s_size], r12
	;; now I reserve memory for the bit-array
	mov	rdi, r12       	; how many bytes do I need?
	shr	rdi, 3	       	; rdi <-- s_size/8
	inc	rdi		; rdi <-- s_size/8 + 1 (bytes I need)
	call	malloc
	mov	rbx, [_set]
	mov	[rbx+s_set], rax
	;; now, the instance of Set is complete
	;; ------------------------------------

.again:
	call 	read_command
	;; rax contains 0, 1, 2 or 3
	;; check for quit
	cmp	rax, 3
	je	.end
.nxt_ad:
	cmp	rax, 0
	jne	.nxt_re
	call	fun_add
	cmp	rax, 1
	jne	.again
	lea	rdi, [_added]	; the element has been successfully added
	mov	rsi, [element]	; (silent if the element already belongs to the set)
	xor	eax, eax
	call 	printf
	jmp  	.again	
.nxt_re:
	cmp 	rax, 1
	jne 	.nxt_te
	call	fun_remove
	cmp	rax, 1		; the element has been successfully removed
	jne	.again		; (silent if the element did not belong to the set)
	lea	rdi, [_removed]
	mov	rsi, [element]
	xor	eax, eax
	call 	printf
	jmp 	.again
.nxt_te: ;; no need to check if rax = 2, sure it is
	call	fun_test
	cmp	rax, 1		
	jne	.notbel
	lea	rdi, [_belongs]	   ; the element belongs to the set
	jmp	.decided
.notbel:
	lea	rdi, [_notbelongs] ; the element does not belong to the set
.decided:
	mov	rsi, [element]
	xor	eax, eax
	call 	printf
	
	jmp	.again	
	
.end:
	mov	rdi, [_set]
	call	free
	
	pop	r12		; restore r12
	pop	rbx		; restore rbx
	leave
	ret
	
