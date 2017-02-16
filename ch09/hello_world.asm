        section .data
msg:    db      "Hello World!",0x0a,0

        section .text
        global  main
        extern  printf
main
	push	rbp
	mov	rbp, rsp
	sub	rsp, 8
        lea     rdi, [msg]  ; parameter 1 for printf
        xor     eax, eax    ; 0 floating point parameters
        call    printf
        xor     eax, eax    ; return 0
	leave
	ret

	;; mov	eax, 60
	;; xor	edi, edi
	;; syscall
