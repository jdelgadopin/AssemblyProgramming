	;; Knuth-Morris-Pratt Algorithm for pattern matching
	;; (http://www.inf.fh-flensburg.de/lang/algorithmen/pattern/kmpen.htm)
	;; ---------> Small texts only (size < 256) <---------
	
	SECTION .bss
	;; required preprocessing table
	preproc		resb	7			; sizep + 1 (+ 1 sentinel)
	;; Sorted table with indices of found patterns
	rplcdi		resb	100			; a priori unknown
							; should be ...
	;; original text with found patterns replaced
	rplcdtx		resb	250			; a priori unknown
	
	SECTION .data
	;; original text
	text	db	"123456789012345678901234567890123456789012345678901234567890"
	sizet	db	60			; aka n. It could be computed...
	;; pattern to be replaced
	patt	db	"67890"
	sizep	db	5			; aka m. It could be computed...
	;; text to replace pattern
	repl	db	"a"
	sizer	db	1			; It could be computed...
	
	SECTION .text
        global  _start

_start:
	;; Computing the preprocessing table
	;; ---------------------------------
	
	xor	r8, r8				; i = 0
	mov	r9, -1				; j = -1
	mov	byte [preproc + r8], r9b	; b[i] = j
wppext:						; while (i < m) ...
	cmp	r8b, byte [sizep]		; is i < m ?
	jge	ewppext				; no, jump out of the outer loop
wppint:						; while (j >= 0 && p[i] != p[j]) ...
	cmp	r9, 0				; is j >= 0?
	jge	jgt0				
	jmp 	ewppint		      		; no, jump out of the inner loop
jgt0:	mov	dl, byte [patt + r8] 		; yes, and now, is p[i] != p[j] ?
	cmp	dl, byte [patt + r9] 
	je	ewppint				; if not, jump out of the inner loop
						; at this point it is true that j>=0 && p[i] != p[j]
	movsx	r9, byte [preproc + r9] 	; j = b[j]
	jmp	wppint
ewppint:
	inc	r8				; i++
	inc	r9				; j++
	mov	byte [preproc + r8], r9b	; b[i] = j	
	jmp 	wppext
ewppext:
	
	;; Searching with KMP
	;; ------------------
	
	xor 	rbx, rbx	  		; index to the table of results
	mov	byte [rplcdi], -1		; sentinel, number that cannot be an index
	xor	r8, r8				; i = 0
	xor	r9, r9				; j = 0
wsext:						; while (i < m) ...
	cmp	r8b, byte [sizet]		; is i < n ?
	jge	ewsext				; no, jump out of the outer loop
wsint:						; while (j >= 0 && t[i] != p[j]) ...
	cmp	r9, 0				; is j >= 0?
	jge	jsgt0				
	jmp 	ewsint		      		; no, jump out of the inner loop
jsgt0:	mov	dl, byte [text + r8] 		; yes, and now, is t[i] != p[j] ?
	cmp	dl, byte [patt + r9] 
	je	ewsint				; if not, jump out of the inner loop
						; at this point it is true that j>=0 && t[i] != p[j]
	movsx	r9, byte [preproc + r9] 	; j = b[j]
	jmp	wsint
ewsint:
	inc	r8				; i++
	inc	r9				; j++
	cmp	r9b, byte [sizep]		; is (j==m)?
	jne	wsext				; no, jump to the beginning of the outer loop
	mov	byte [rplcdi + rbx], r8b
	sub	byte [rplcdi + rbx], r9b	; rplcdi[rbx] <- i-j
	inc	rbx
	movsx	r9, byte [preproc + r9] 	; j = b[j]	
	jmp 	wsext
ewsext:
	movzx	r10, byte[sizet]
	inc 	r10
	mov	byte [rplcdi + rbx], r10b    	; add sentinel to rplcdi
	
	
	;; Copying original text replacing pattern
	;; ---------------------------------------
	jmp 	start				; jump the function(s)

	;;    "function" to copy the pattern where indicated by r9
	;;    -----------------------------------
cpypt:	xor	r10, r10	   		; l <- 0 : index of the pattern
wpt:	cmp	r10b, byte [sizer] 		; while (l < m) ...
	jge	ecpypt				; if l >= m the function stops
	mov	r11b, byte [repl + r10]
	mov	byte [rplcdtx + r9], r11b 	; rplcdtxt[j] <- patt[l]
	inc 	r10				; l++
	inc 	r9				; j++
	jmp	wpt
	;;    -----------------------------------

start:	xor	r8, r8				; i <- 0 : index of the text
	xor	r9, r9				; j <- 0 : index of the copy
	xor	rcx, rcx			; k <- 0 : index in the replacement table
cpyng:	cmp	r8b, byte [sizet]		; while (i < n) ...
	jge	end				; if i >= n the program ends
wlt:	cmp	r8b, byte [rplcdi + rcx] 	; while (i > rplcdi[k])...
	jle	rightk				; if i <= rplcdi[rcx] keep going...
	inc	rcx				; if not, this rplcdi element is not useful
	jmp	wlt
rightk:	cmp 	r8b, byte [rplcdi + rcx]	; is rplcdi[k] == i?
	jne 	kcpy				; no, keep copying, but we know rplcdi[k] > i
	jmp	cpypt				; yes, copy pattern in rplcdtx[j,...,j+sizep-1]
ecpypt:	add	r8b, byte [sizep]		; i <- i + sizep, since we replaced the pattern
	inc 	rcx				; k++, next replacement
	jmp	cpyng				; go back to check if we are finished
kcpy:	mov	r11b, byte [text + r8]
	mov	byte [rplcdtx + r9], r11b 	; rplcdtxt[j] <- text[i]
	inc	r8				; i++
	inc 	r9				; j++
	jmp	cpyng
	
end:						; rplcdtx should have the replaced text
        xor     rdi,rdi
        push    0x3c
        pop     rax
        syscall
