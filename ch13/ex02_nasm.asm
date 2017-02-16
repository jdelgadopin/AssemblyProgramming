;;; ---------------------------------------------------------------------

	SECTION .bss
cmnd		resb	256	; input string
element		resq	1
set1		resq	1
set2		resq	1
_sets		resq	1	; address of the set of sets
	
;;; ---------------------------------------------------------------------
	
        SECTION .bss
	
	struc Set
s_size:		resq	1 	; set size
s_set:		resq	1	; address of the bit-array
	endstruc

	struc Sets
sts_size	resq	1
sts_sets	resq	1
	endstruc
	
;;; ---------------------------------------------------------------------

        SECTION .data
		
readcmnd	db	"%255s",0
param		db	"%d",0	
prompt 		db	"Enter command (add, remove, test, union, intersect, print, quit): ",0
promptelem	db	"Enter element: ",0
promptset	db	"Enter set: ",0
printelem	db	"%d ",0
linefd		db	0xa,0

_add		db	"add",0
_added		db	"%d added to set %d",0xa,0	
_remove		db	"remove",0
_removed	db	"%d removed from set %d",0xa,0
_test		db	"test",0
_belongs	db	"%d belongs to the set %d",0xa,0
_notbelongs	db	"%d not belongs to the set %d",0xa,0
_union		db	"union",0
_joined		db	"the elements of set %d now also belong to set %d",0xa,0
_intersect	db	"intersect",0
_intersected	db	"set %d has been intersected with set %d",0xa,0
_print		db	"print",0
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
	lea	rdi, [cmnd]
	rep	stosb
	;; read command
	lea	rdi, [readcmnd]
	lea	rsi, [cmnd]
	xor	eax, eax
	call	scanf
	;; check what command has been given
	;; has it been 'add'?
	lea	rsi, [cmnd] 	; address of name
	lea	rdi, [_add]	; address of the constant string 'add\0'
	mov	rcx, 5		; chars in 'add\0' + 1
	repe	cmpsb		; compare both strings
	cmp	rcx, 0
	jne	.lb_rem		; if not equal check 'remove' 
	mov	rax, 0
	jmp 	.end_rc
.lb_rem:;; has it been 'remove'?
	lea	rsi, [cmnd]	; address of name
	lea	rdi, [_remove]	; address of the constant string 'remove\0'
	mov	rcx, 8		; chars in 'remove\0' + 1
	repe	cmpsb		; compare both strings
	cmp	rcx, 0
	jne	.lb_tst		; if not equal check 'test' 
	mov	rax, 1
	jmp 	.end_rc
.lb_tst:;; has it been 'test'?
	lea	rsi, [cmnd]	; address of name
	lea	rdi, [_test]	; address of the constant string 'test\0'
	mov	rcx, 6		; chars in 'test\0' + 1
	repe	cmpsb		; compare both strings
	cmp	rcx, 0
	jne	.lb_uni		; if not equal check 'union' 
	mov	rax, 2
	jmp 	.end_rc
.lb_uni:;; has it been 'union'?
	lea	rsi, [cmnd]	; address of name
	lea	rdi, [_union]	; address of the constant string 'union\0'
	mov	rcx, 7		; chars in 'union\0' + 1
	repe	cmpsb		; compare both strings
	cmp	rcx, 0
	jne	.lb_int		; if not equal check 'intersect' 
	mov	rax, 3
	jmp 	.end_rc
.lb_int:;; has it been 'intersect'?
	lea	rsi, [cmnd]	; address of name
	lea	rdi, [_intersect] ; address of the constant string 'intersect\0'
	mov	rcx, 11		; chars in 'intersect\0' + 1
	repe	cmpsb		; compare both strings
	cmp	rcx, 0
	jne	.lb_pri		; if not equal check 'print' 
	mov	rax, 4
	jmp 	.end_rc
.lb_pri:;; has it been 'print'?
	lea	rsi, [cmnd]	; address of name
	lea	rdi, [_print]	; address of the constant string 'print\0'
	mov	rcx, 7		; chars in 'print\0' + 1
	repe	cmpsb		; compare both strings
	cmp	rcx, 0
	jne	.lb_qu		; if not equal check 'quit' 
	mov	rax, 5
	jmp 	.end_rc
.lb_qu:	;; has it been 'quit'?
	lea	rsi, [cmnd]	; address of name
	lea	rdi, [_quit]	; address of the constant string 'quit\0'
	mov	rcx, 6		; chars in 'quit\0' + 1
	repe	cmpsb		; compare both strings
	cmp	rcx, 0
	jne	.beg_rc		; if not equal start again 
	mov	rax, 6
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

	;; read parameters
	lea	rdi, [promptelem]
	xor	eax, eax
	call 	printf
	lea	rdi, [param]
	lea 	rsi, [element]
	xor	eax, eax
	call 	scanf
	;; check if [element] is in range
	;; if not, start again
	mov	rbx, [_sets]
	mov	rbx, [rbx+sts_sets] 	; assuming there is at least 1 set, rbx is pointing at that set
	mov	rbx, [rbx+s_size]
	mov	r12, qword [element]
	cmp	r12, 0
	jl	.end_add
	cmp	r12, rbx
	jge	.end_add
	;; now we know [element] is a set element
	lea	rdi, [promptset]
	xor	eax, eax
	call 	printf
	lea	rdi, [param]
	lea 	rsi, [set1]
	xor	eax, eax
	call 	scanf	
	;; check if [set1] is in range
	;; if not, start again
	mov	rbx, [_sets]
	mov	rbx, [rbx+sts_size]
	mov	r12, qword [set1]
	cmp	r12, 0
	jl	.end_add
	cmp	r12, rbx
	jge	.end_add
	;; now we know [set1] is a set number

	mov	rbx, qword [_sets]
	mov	rbx, qword [rbx+sts_sets]
	xor 	rdx, rdx
	mov	rax, qword [set1]
	mov	rcx, Set_size
	mul	rcx
	add	rbx, rax			; rbx <-- Sets.sts_sets + set1 x Set_size
	mov	rdx, [rbx + s_set]
	
	;; let's add [element] to set [set1]
	mov	rax, [element]
	shr	rax, 6			; rax <-- [element]/64 
	mov	r12, [element]
	and	r12, 0x3F		; r12 <-- reminder of [element]/64	
	mov	r13, qword [rdx+8*rax]	
	bt	r13, r12
	jc	.end_add	

	bts	qword [rdx+8*rax], r12	; the element is added
	lea	rdi, [_added]
	mov	rsi, [element]
	mov	rdx, [set1]
	xor	eax, eax
	call 	printf

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

	;; read parameters
	lea	rdi, [promptelem]
	xor	eax, eax
	call 	printf
	lea	rdi, [param]
	lea 	rsi, [element]
	xor	eax, eax
	call 	scanf
	;; check if [element] is in range
	;; if not, start again
	mov	rbx, [_sets]
	mov	rbx, [rbx+sts_sets] 	; assuming there is at least 1 set, rbx is pointing at that set
	mov	rbx, [rbx+s_size]
	mov	r12, qword [element]
	cmp	r12, 0
	jl	.end_remove
	cmp	r12, rbx
	jge	.end_remove
	;; now we know [element] is a set element
	lea	rdi, [promptset]
	xor	eax, eax
	call 	printf
	lea	rdi, [param]
	lea 	rsi, [set1]
	xor	eax, eax
	call 	scanf	
	;; check if [set1] is in range
	;; if not, start again
	mov	rbx, [_sets]
	mov	rbx, [rbx+sts_size]
	mov	r12, qword [set1]
	cmp	r12, 0
	jl	.end_remove
	cmp	r12, rbx
	jge	.end_remove
	;; now we know [set1] is a set number

	mov	rbx, qword [_sets]
	mov	rbx, qword [rbx+sts_sets]
	xor 	rdx, rdx
	mov	rax, qword [set1]
	mov	rcx, Set_size
	mul	rcx
	add	rbx, rax			; rbx <-- Sets.sts_sets + set1 x Set_size
	mov	rdx, [rbx + s_set]

	;; let's remove [element] from the set [set1]
	mov	rax, [element]
	shr	rax, 6			; rax <-- [element]/64 
	mov	r12, [element]
	and	r12, 0x3F		; r12 <-- reminder of [element]/64	
	mov	r13, qword [rdx+8*rax]	
	bt	r13, r12
	jnc	.end_remove
	
	btr	qword [rdx+8*rax], r12	; the element is removed
	lea	rdi, [_removed]
	mov	rsi, [element]
	mov	rdx, [set1]
	xor	eax, eax
	call 	printf

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

	;; read parameters
	lea	rdi, [promptelem]
	xor	eax, eax
	call 	printf
	lea	rdi, [param]
	lea 	rsi, [element]
	xor	eax, eax
	call 	scanf
	;; check if [element] is in range
	;; if not, start again
	mov	rbx, [_sets]
	mov	rbx, [rbx+sts_sets] 	; assuming there is at least 1 set, rbx is pointing at that set
	mov	rbx, [rbx+s_size]
	mov	r12, qword [element]
	cmp	r12, 0
	jl	.end_test
	cmp	r12, rbx
	jge	.end_test
	;; now we know [element] is a set element
	lea	rdi, [promptset]
	xor	eax, eax
	call 	printf
	lea	rdi, [param]
	lea 	rsi, [set1]
	xor	eax, eax
	call 	scanf	
	;; check if [set1] is in range
	;; if not, start again
	mov	rbx, [_sets]
	mov	rbx, [rbx+sts_size]
	mov	r12, qword [set1]
	cmp	r12, 0
	jl	.end_test
	cmp	r12, rbx
	jge	.end_test
	;; now we know [set1] is a set number

	mov	rbx, qword [_sets]
	mov	rbx, qword [rbx+sts_sets]
	xor 	rdx, rdx
	mov	rax, qword [set1]
	mov	rcx, Set_size
	mul	rcx
	add	rbx, rax			; rbx <-- Sets.sts_sets + set1 x Set_size
	mov	rdx, [rbx + s_set]

	;; let's test whether [element] belongs to the set [set1]
	mov	rax, [element]
	shr	rax, 6			; rax <-- [element]/64 
	mov	r12, [element]
	and	r12, 0x3F		; r12 <-- reminder of [element]/64	
	mov	r13, qword [rdx+8*rax]	
	bt	r13, r12
	jnc	.is_not_there		; the element wasn't there
	lea	rdi, [_belongs]
	jmp	.write
.is_not_there:
	lea	rdi, [_notbelongs]
.write:
	mov	rsi, [element]
	mov	rdx, [set1]
	xor	eax, eax
	call 	printf

.end_test:
	pop	r13
	pop 	r12
	pop	rbx
	leave
	ret
	
;;; ---------------------------------------------------------------------

fun_union:
	push 	rbp
	mov	rbp, rsp
	push	rbx
	push	r12
	push	r13

	;; read parameters
	lea	rdi, [promptset]
	xor	eax, eax
	call 	printf
	lea	rdi, [param]
	lea 	rsi, [set1]
	xor	eax, eax
	call 	scanf
	;; check if [set1] is in range
	;; if not, start again
	mov	rbx, [_sets]
	mov	rbx, [rbx+sts_size]
	mov	r12, qword [set1]
	cmp	r12, 0
	jl	.end_union
	cmp	r12, rbx
	jge	.end_union
	;; now we know [set1] is a set number
	lea	rdi, [promptset]
	xor	eax, eax
	call 	printf
	lea	rdi, [param]
	lea 	rsi, [set2]
	xor	eax, eax
	call 	scanf	
	;; check if [set2] is in range
	;; if not, start again
	mov	rbx, [_sets]
	mov	rbx, [rbx+sts_size]
	mov	r12, qword [set2]
	cmp	r12, 0
	jl	.end_union
	cmp	r12, rbx
	jge	.end_union
	;; now we know [set2] is a set number

	mov	rbx, qword [_sets]
	mov	rbx, qword [rbx+sts_sets]
	mov	r12, rbx
	xor 	rdx, rdx
	mov	rax, qword [set1]
	mov	rcx, Set_size
	mul	rcx
	add	rbx, rax		; rbx <-- Sets.sts_sets + set1 x Set_size
	xor 	rdx, rdx
	mov	rax, qword [set2]
	mov	rcx, Set_size
	mul	rcx	
	add	r12, rax		; r12 <-- Sets.sts_sets + set2 x Set_size

	;; get to the data
	mov	r13, [rbx+s_size]
	shr	r13, 3			
	inc	r13			; r13 <-- s_size/8 + 1 -- bytes in every set size
	mov	rbx, [rbx+s_set]
	mov	r12, [r12+s_set]

	xor 	rcx, rcx
.un_loop:				; or [set1], [set2] - byte a byte 
	cmp	rcx, r13
	jge	.prt_union
	mov	r8b, byte [r12+rcx]
	or	byte [rbx+rcx], r8b	
	inc 	rcx
	jmp	.un_loop	

.prt_union:	
	lea	rdi, [_joined]
	mov	rsi, [set2]
	mov	rdx, [set1]
	xor	eax, eax
	call 	printf
	
.end_union:
	pop	r13
	pop 	r12
	pop	rbx
	leave
	ret
	
;;; ---------------------------------------------------------------------

fun_intersection:
	push 	rbp
	mov	rbp, rsp
	push	rbx
	push	r12
	push	r13

	;; read parameters
	lea	rdi, [promptset]
	xor	eax, eax
	call 	printf
	lea	rdi, [param]
	lea 	rsi, [set1]
	xor	eax, eax
	call 	scanf
	;; check if [set1] is in range
	;; if not, start again
	mov	rbx, [_sets]
	mov	rbx, [rbx+sts_size]
	mov	r12, qword [set1]
	cmp	r12, 0
	jl	.end_intersection
	cmp	r12, rbx
	jge	.end_intersection
	;; now we know [set1] is a set number
	lea	rdi, [promptset]
	xor	eax, eax
	call 	printf
	lea	rdi, [param]
	lea 	rsi, [set2]
	xor	eax, eax
	call 	scanf	
	;; check if [set2] is in range
	;; if not, start again
	mov	rbx, [_sets]
	mov	rbx, [rbx+sts_size]
	mov	r12, qword [set2]
	cmp	r12, 0
	jl	.end_intersection
	cmp	r12, rbx
	jge	.end_intersection
	;; now we know [set2] is a set number

	mov	rbx, qword [_sets]
	mov	rbx, qword [rbx+sts_sets]
	mov	r12, rbx
	xor 	rdx, rdx
	mov	rax, qword [set1]
	mov	rcx, Set_size
	mul	rcx
	add	rbx, rax		; rbx <-- Sets.sts_sets + set1 x Set_size
	xor 	rdx, rdx
	mov	rax, qword [set2]
	mov	rcx, Set_size
	mul	rcx	
	add	r12, rax		; r12 <-- Sets.sts_sets + set2 x Set_size

	;; get to the data
	mov	r13, [rbx+s_size]
	shr	r13, 3			
	inc	r13			; r13 <-- s_size/8 + 1 -- bytes in every set size
	mov	rbx, [rbx+s_set]
	mov	r12, [r12+s_set]

	xor 	rcx, rcx
.in_loop:				; and [set1], [set2] - byte a byte 
	cmp	rcx, r13
	jge	.pr_intersection
	mov	r8b, byte [r12+rcx]
	and	byte [rbx+rcx], r8b	
	inc 	rcx
	jmp	.in_loop	

.pr_intersection:	
	lea	rdi, [_intersected]
	mov	rsi, [set1]
	mov	rdx, [set2]
	xor	eax, eax
	call 	printf
	
.end_intersection:
	pop	r13
	pop 	r12
	pop	rbx
	leave
	ret
	
;;; ---------------------------------------------------------------------
	
fun_print:
	push 	rbp
	mov	rbp, rsp
	push	rbx
	push	r12
	push	r13
	push	r14
	push	r15

	;; read parameters
	lea	rdi, [promptset]
	xor	eax, eax
	call 	printf
	lea	rdi, [param]
	lea 	rsi, [set1]
	xor	eax, eax
	call 	scanf
	;; check if [set1] is in range
	;; if not, start again
	mov	rbx, [_sets]
	mov	rbx, [rbx+sts_size]
	mov	r12, qword [set1]
	cmp	r12, 0
	jl	.end_print
	cmp	r12, rbx
	jge	.end_print
	;; now we know [set1] is a set number

	mov	rbx, qword [_sets]
	mov	rbx, qword [rbx+sts_sets]
	xor 	rdx, rdx
	mov	rax, qword [set1]
	mov	rcx, Set_size
	mul	rcx
	add	rbx, rax		; rbx <-- Sets.sts_sets + set1 x Set_size

	;; get to the data
	mov	r15, [rbx+s_size]
	shr	r15, 3			
	inc	r15			; r15 <-- s_size/8 + 1 -- bytes in every set size

	xor 	r12, r12		; byte counter
	xor	r14, r14		; bit counter
.pr_loop:				 
	cmp	r12, r15
	jge	.e_print
	xor	r13, r13
.bit_lp:
	cmp	r13, 8
	jge	.e_bit
	cmp	r14, [rbx+s_size]
	jge	.e_print
	mov	rdx, [rbx+s_set]
	movzx	rdx, byte [rdx+r12]
	bt	rdx, r13
	jnc	.ct_bit
	lea	rdi, [printelem]
	mov	rsi, r14
	xor	eax, eax
	call 	printf
.ct_bit:
	inc	r13
	inc	r14
	jmp	.bit_lp
.e_bit:
	inc 	r12
	jmp	.pr_loop	
.e_print:
	lea	rdi, [linefd]
	xor	eax, eax
	call 	printf
	
.end_print:	
	pop	r15
	pop	r14
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
	push	r13		; save r13
	push	r14		; save r14

	;; create an instance of Sets from the sets size entered in the command line
	;; -----------------------------------------------------------------------
	;; read sets size from command line
	mov	rbx, rsi
	add	rbx, 8		; assuming argc=3, rbx is the address of argv[1]
	mov	rdi, [rbx]	; rdi <- content of argv[1]
	call	atol
	mov	r12, rax	; save number of sets in r12
	add	rbx, 8		; assuming argc=3, rbx is the address of argv[2]
	mov	rdi, [rbx]	; rdi <- content of argv[2]
	call	atol
	mov	r13, rax	; save each set size in r13
	;; create an instance of Sets
	mov	rdi, Sets_size
	call	malloc
	mov	[_sets], rax	; save set address
	;; save set size in the corresp. field
	mov	rbx, [_sets]
	mov	[rbx+sts_size], r12
	;; now I reserve memory for every set
	xor	rdx, rdx
	mov	rax, r12
	mov	rcx, Set_size
	mul	rcx		; rax <-- number of sets x size of a set
	mov	rdi, rax
	call 	malloc
	mov	[rbx+sts_sets], rax
	;; now, the instance of Sets is complete, we must initialize every set
	xor	r14, r14
	mov	r12, [rbx+sts_sets]
.loop:
	cmp	r14, qword [rbx+sts_size]
	jge	.again
	mov	[r12+s_size], r13
	mov	rdi, r13       	; how many bytes do I need?
	shr	rdi, 3	       	; rdi <-- s_size/8
	inc	rdi		; rdi <-- s_size/8 + 1 (bytes I need)	
	call	malloc
	mov	[r12+s_set], rax
	add	r12, Set_size
	inc	r14
	jmp	.loop
	;; now, the instance of Sets is complete, with every set initialized
	;; -----------------------------------------------------------------
	
.again:
	call 	read_command
	;; rax contains 0, 1, 2, 3, 4, 5 or 6
	;; check for quit
	cmp	rax, 6
	je	.end
.nxt_ad:
	cmp	rax, 0
	jne	.nxt_re
	call	fun_add
	jmp  	.again	
.nxt_re:
	cmp 	rax, 1
	jne 	.nxt_te
	call	fun_remove
	jmp 	.again
.nxt_te:
	cmp	rax, 2
	jne 	.nxt_un
	call	fun_test
	jmp	.again	
.nxt_un:
	cmp 	rax, 3
	jne 	.nxt_in
	call	fun_union
	jmp 	.again
.nxt_in:
	cmp 	rax, 4
	jne 	.nxt_pr
	call	fun_intersection
	jmp 	.again
.nxt_pr:  ;; no need to check if rax = 5, sure it is
	call	fun_print
	jmp 	.again
.end:
	
	;; we should free all mallocs
	;; first, free each individual set
	mov	rbx, [_sets]
	mov	r12, [rbx+sts_sets]
	xor	r14, r14
.loopf:
	cmp	r14, qword [rbx+sts_size]
	jge	.freeSets
	mov	rdi, [r12+s_set]
	call	free
	add	r12, Set_size
	inc	r14
	jmp	.loopf
	;; then, free the Sets structure
.freeSets:
	mov	rdi, [_sets]
	call	free
	
	pop	r14		; restore r14
	pop	r13		; restore r13
	pop	r12		; restore r12
	pop	rbx		; restore rbx
	leave
	ret
	
