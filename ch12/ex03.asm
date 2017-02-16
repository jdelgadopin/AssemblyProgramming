
	;; files will be read in chunks of blocksize size
blocksize	equ	512

;;; ---------------------------------------------------------------------
	
	SECTION .bss
fdinput		resd	1
buffer		resb	blocksize	
pattern		resq 	1	; address of the pattern
patternsize	resq	1
linecounter	resq 	1
	
;;; ---------------------------------------------------------------------
	
	SECTION .data
printerror	db	"read failure",0xa,0
prnt_line	db	"line %d -- %s",0	
;; ---------------- DEBUG -----------------------
;; prnt_pattern	db	"pattern size: %d (%s)",0xa,0 
;; ---------------- DEBUG -----------------------

;;; ---------------------------------------------------------------------

	SECTION .text
        global  main		; MUST be linked with gcc (not ld)
	
        extern  printf, open, read, lseek, close, malloc, free

;;; --- function search_pattern -----------------------------------------

search_pattern:
	;; Parameters: rdi (text address), rsi (text size)
	;; Return: rax <-- 1 if found, rax <-- 0 if not found
	push	rbp
	mov	rbp, rsp
	push	rbx		; save rbx
	push	r12		; save r12
	push	r13		; save r13
	sub	rsp, 16
	mov	[rsp+8], rsi	; save rsi parameter -- text size
	mov	[rsp], rdi	; save rdi parameter -- text address

	SECTION .data
.preproc:	dq	0	; address of the preprocessing table

	SECTION	.text

	;; space for the preprocessing table
	mov 	rdi, [patternsize]
	add	rdi, 2
	shl	rdi, 2				; indices are dwords, thus x 4
	call 	malloc
	mov	qword [.preproc], rax		; rax <-- address of reserved space
	
	;; computing the preprocessing table	
	xor	r8, r8				; i = 0
	mov	r9, -1				; j = -1
	mov	r12, qword [.preproc]		; r12 <-- address of the preprocessing table
	mov	rbx, qword [pattern]		; rbx <-- address of the pattern
	mov	dword [r12+4*r8], r9d		; b[0] = -1
.wppext:					; while (i < m) ...
	cmp	r8, qword [patternsize]		; is i < m ?
	jge	.ewppext			; no, jump out of the outer loop
.wppint:					; while (j >= 0 && p[i] != p[j]) ...
	cmp	r9, 0				; is j >= 0?
	jge	.jgt0				
	jmp 	.ewppint	      		; no, jump out of the inner loop
.jgt0:
	mov	dl, byte [rbx+r8] 		; yes, and now, is p[i] != p[j] ?
	cmp	dl, byte [rbx+r9] 
	je	.ewppint			; if not, jump out of the inner loop
						; at this point it is true that j>=0 && p[i] != p[j]
	movsxd	r9, dword [r12+4*r9]	 	; j = b[j]
	jmp	.wppint
.ewppint:
	inc	r8				; i++
	inc	r9				; j++
	mov	dword [r12+4*r8], r9d		; b[i] = j	
	jmp 	.wppext
.ewppext:
	
	;; searching with KMP
	xor	rax, rax	  		; result: rax <-- not found
	mov	r12, qword [.preproc]		; r12 <-- address of the preprocessing table
	mov	r13, qword [rsp]		; r13 <-- address of the line
	mov	rbx, qword [pattern]		; rbx <-- address of the pattern
	xor	r8, r8				; i = 0
	xor	r9, r9				; j = 0
.wsext:						; while (i < m) ...
	cmp	r8, qword [rsp+8]		; is i < n ?
	jge	.endkmp				; no, jump out of the outer loop
.wsint:						; while (j >= 0 && t[i] != p[j]) ...
	cmp	r9, 0				; is j >= 0?
	jge	.jsgt0				
	jmp 	.ewsint		      		; no, jump out of the inner loop
.jsgt0:
	mov	dl, byte [r13 + r8] 		; yes, and now, is t[i] != p[j] ?
	cmp	dl, byte [rbx + r9] 
	je	.ewsint				; if not, jump out of the inner loop
						; at this point it is true that j>=0 && t[i] != p[j]
	movsxd	r9, dword [r12+4*r9] 		; j = b[j]
	jmp	.wsint
.ewsint:
	inc	r8				; i++
	inc	r9				; j++
	cmp	r9, [patternsize]		; is (j==m)?
	jne	.wsext				; no, jump to the beginning of the outer loop
	mov	rax, 1				; match found
						; result: rax <-- found
.endkmp:
	add	rsp, 16
	pop	r13		; restore r13
	pop	r12		; restore r12
	pop	rbx		; restore rbx
	leave
	ret

;;; --- end function ----------------------------------------------------
		
main:
	push	rbp
	mov	rbp, rsp
	push	rbx		; save rbx
	push	r12		; save r12

	mov	rbx, rsi	   ; save argv address
	add	rbx, 8		   ; start with argv[1]
	mov	rsi, [rbx]	
	mov	[pattern], rsi	   ; save the address of the pattern to search
	;; compute the size of the pattern
	xor 	rcx, rcx
.compute_size:
	cmp	byte [rsi+rcx], 0x0
	je	.size_computed
	inc 	rcx
	jmp	.compute_size
.size_computed:
	mov	[patternsize], rcx ; save the size of the pattern
	
	;; open the file
	add	rbx, 8		; now, to argv[2]	
	mov	rdi, [rbx]	; address of filename
	mov	esi, 0x0	; open as read-only
	call	open
	cmp	eax, 0
	jl	.end		; no file open, just leave
	mov	[fdinput], eax	; save file descriptor

	mov	qword [linecounter], 0
.next_line:
	;; Now, the file is positioned at the beginning of the file OR just after
	;; a 0xa byte, that is, at the beginning of a line.
	xor	rbx, rbx	; rbx <-- 0 -- counter of bytes read
	inc	qword [linecounter]
.next_chunk:
	xor	r12, r12
	mov	rdi, [fdinput]
	lea	rsi, [buffer] 
	mov	rdx, blocksize
	call	read
	xor 	rcx, rcx
	cmp	eax, 0		; nothing more read
	jle	.newline_found	; process the current line
	mov	r12, rax	; r12 <-- number of bytes read
	;; I look for a 0xa
.next_byte:
	cmp	rcx, r12
	jge	.end_chunk
	cmp	byte [buffer+rcx], 0xa
	je	.newline_found
	inc 	rcx
	jmp	.next_byte
.end_chunk:
	add	rbx, rcx
	jmp	.next_chunk
.newline_found:
	mov	rdx, rbx
	add	rdx, r12	; rdx <-- total bytes read up to this point
	add	rbx, rcx
	inc	rbx		; rbx <-- bytes until (included) 0xa

	;; go back to the beginning of the line (rdx bytes back)
	neg	rdx		
	mov	rdi, [fdinput]
	mov	rsi, rdx  
	mov	rdx, 1		; whence = 1, relative to the current position
	call	lseek

	;; reserve memory for the line that will be read (rbx bytes)
	mov	rdi, rbx
	inc	rdi		    ; reserve one more byte to end the string with a 0x0
	call 	malloc
	mov	r12, rax	    ; rax <-- address returned by malloc
	mov	byte [r12+rbx], 0x0 ; put a 0x0 at the end, just to be sure the string ends with a 0x0

	;; read (again) up to the newline (rbx bytes)
	mov	rdi, [fdinput]
	mov	rsi, r12 
	mov	rdx, rbx
	call	read
	cmp	eax, 0
	jle	.close

	;; search the pattern in the line
	mov	rdi, r12	   ; address of the line
	mov	rsi, rbx	   ; size of the line
	call	search_pattern
	cmp	rax, 0
	je	.not_found

	;; print the line if pattern was found in the line
	lea	rdi, [prnt_line]
	mov	rsi, [linecounter]
	mov	rdx, r12
	xor 	eax, eax
	call 	printf
	
.not_found:
	;; next line
	mov	rdi, r12	; free the previous malloc, since we do not need the line anymore
	call 	free
	jmp 	.next_line

.close:
	mov	rdi, r12	; free the last malloc
	call 	free
	mov	edi, [fdinput]
	call	close	
.end:
	pop	r12		; restore r12
	pop	rbx		; restore rbx
	leave
	ret
	
