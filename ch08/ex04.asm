	SECTION .data
	strng	db	"qwertyuiopoiuytrewq"	; string = byte sequence + size 
	sz	dq	19
	pal	db	0		; pal = false
	
	SECTION .text
        global  _start

_start:

	lea	rax, [strng]	; left index
	mov 	rbx, rax
	add 	rbx, [sz]
	dec	rbx		; right index
	
chck:	cmp	rax, rbx
	jge	pali		; jump if left index >= right index

	mov 	dl, byte [rax]
	cmp	dl, byte [rbx]
	jne	end		; if strng[lindex] != strng[rindex] then
				; it is not palindrome 
	inc	rax
	dec	rbx

	jmp	chck
	
pali:	inc	byte [pal]
	
end:	
        xor     rdi,rdi
        push    0x3c
        pop     rax
        syscall
