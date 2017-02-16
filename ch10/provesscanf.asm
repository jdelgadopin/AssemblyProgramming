
	SECTION .bss
strng1	resb	30
strng2	resb	10

	SECTION .data
inp1		db	"%29s",0
inp2		db	 "%9s",0
prompt1		db	"Enter string (30 max): ",0
prompt2		db	"Enter string (10 max): ",0
pr_write	db	"===> %s -- %s",0xa,0

	SECTION .text
        global  _start
	
        extern  printf
	extern  scanf

_start:
	
.again:
	lea	rdi, [prompt1]	; address of prompt
        xor     eax, eax	; 0 float parameters
        call    printf
	lea	rdi, [inp1]	; set arg 1 for scanf
	lea	rsi, [strng1]	; set arg 2 for scanf
	xor	eax, eax	; 0 float parameters
	call	scanf

	lea	rdi, [prompt2]	; address of prompt
        xor     eax, eax	; 0 float parameters
        call    printf
	lea	rdi, [inp2]	; set arg 1 for scanf
	lea	rsi, [strng2]	; set arg 2 for scanf
	xor	eax, eax	; 0 float parameters
	call	scanf
	
	lea	rdi, [pr_write]
	lea	rsi, [strng1]
	lea	rdx, [strng2]
	xor	eax, eax
	call 	printf

	jmp	.again
	
	mov	eax, 60	     	; exit
	xor	edi, edi
	syscall
