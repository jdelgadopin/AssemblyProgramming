        segment .data
a   		db      0
b		db      0	
prompt: 	db     "Enter a, b (0 <= a,b <= 255): ",0
scanf_format   	db    "%d %d",0
printf_format  	db    "gcd(%d,%d) = %d",0x0a,0

        segment .text
        global  _start                	
        extern  scanf               	
        extern  printf

gcd:
	push	rbp
	mov	rbp, rsp
	push	rdi			; save first parameter: a
	push	rsi			; save second parameter: b
	cmp	byte [rsp], 0		; b = 0?
	jne	rec_case
	movzx	rax, byte [rsp+8]
	leave
	ret
rec_case:
	mov	cl, byte [rsp]
	mov	ax, word [rsp+8]	; only AL has significant bits
	div	cl
	shr	ax, 8			; now AL has (a mod b)
	movzx	rdi, byte [rsp]
	movzx	rsi, al
	call	gcd
	leave
	ret
	
_start
;
;       printf("Enter a, b (0 <= a,b <= 255): ");
;
        lea     rdi, [prompt]      ; set arg 1 for printf
        xor     eax, eax            ; 0 float parameters
        call    printf
;
;       scanf("%d %d", a, b);
;
        lea     rdi, [scanf_format] ; set arg 1 for scanf
        lea     rsi, [a]            ; set arg 2 for scanf
        lea     rdx, [b]            ; set arg 2 for scanf
        xor     eax, eax            ; set rax to 0 (2 byte instruction)
        call    scanf
;
;       printf("gcd(%d,%d) = %d\n",a,b,gcd(a,b));
;
        movzx   rdi, byte [a]
	movzx	rsi, byte [b]
        call    gcd
;
;	rax = gcd(a,b)
;
        lea     rdi, [printf_format]    ; set arg 1 for printf
        movzx   rsi, byte [a]          	; set arg 2 for printf
        movzx   rdx, byte [b]         	; set arg 3 for printf
        movzx   rcx, al            	; set arg 4 to be gcd(a,b) 
        xor     eax, eax            	; set rax to 0
        call    printf
;
;       return 0
;
end:	mov	eax, 60	     	; exit
	xor	edi, edi
	syscall
