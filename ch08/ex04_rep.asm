	SECTION .bss
	temp	resb	50
	
	SECTION .data
	strng	db	"q"		; string = byte sequence + size 
	sz	dq	1
	pal	db	0		; pal = false
	
	SECTION .text
        global  _start
_start:
	mov	rcx, [sz]
	lea	rdx, [strng + rcx - 1] 	; rdx: address of the last byte
	lea	rbx, [temp]

	;; reverse string
	;; rdx: source address (to be decremented)
	;; rbx: destination address (to be incremented)
more:	mov	al, byte [rdx]
	mov	byte [rbx], al
	dec	rdx
	inc 	rbx
	dec	rcx
	jnz	more

	;; temp:  address of the reversed string
	;; strng: address of the string
	mov	rcx, [sz]
	lea	rsi, [temp]
	lea	rdi, [strng]
	repe	cmpsb
	cmp	rcx, 0		; if rcx = 0 then it is a palindrome
	jnz	end

	inc	byte [pal]
end:	
        xor     rdi,rdi
        push    0x3c
        pop     rax
        syscall
