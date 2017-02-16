	SECTION .bss
name	resq	65		; customer name (scanf adds 1 null byte)
kwh	resq	1		; kilowatt hours consumption
	
        SECTION .data
inp	db	"%s %d",0
outp    db      "Consumer %s - %d dollars and %d cents",0xa,0
prompt	db	"Enter name and kwh (write 'stop' to finish): ",0
stop	db	"stop",0
	
	SECTION .text
        global  _start
	
        extern  printf
	extern  scanf
	
read_data:
	;; Parameter: string inp, name address, kilowatts hour address
	;; Return: void (name and kwh are at [name] and [kwh] resp.)
	push 	rbp		; normal stack frame
	mov	rbp, rsp
	sub	rsp, 8		; alignment
	lea     rdi, [prompt]   ; set arg 1 for printf
        xor     eax, eax        ; 0 float parameters
        call    printf
	lea	rdi, [inp]	; set arg 1 for scanf
	lea	rsi, [name]	; set arg 2 for scanf
	lea	rdx, [kwh]	; set arg 3 for scanf
	xor	eax, eax	; 0 float parameters
	call	scanf
	leave
	ret
	
compute_bill:
	;; Parameter: kilowatts hour consumed (at [kwh])
	;; Return: dollars (rax) and cents (rdx)
	push 	rbp		; normal stack frame
	mov	rbp, rsp
	sub	rsp, 8		; space for kwph
	mov	r8, [kwh]
	mov	[rsp], r8	; save kwh
	;; compute [rsp] <- 2000 + Theta(kwh - 1000) cents
	xor	r9, r9
	sub	r8, 1000
	cmovl	r8, r9		; since it is 1 cent per kwh consumed over 1000
	add	r8, 2000	; add $20 in cents
	mov	[rsp], r8	; save calculation	
	;; now, compute rax <- dollars, rdx <- cents
	mov	rax, [rsp]
	xor	rdx, rdx
	mov	r8,  100	; divide by 100
	idiv	r8		; rax <- dollars, rdx <- cents
	leave
	ret

print_data:
	;; Parameter at name (name address), dollars (rdi), cents (rsi)
	;; Return: void
	;; printf ("Consumer %s - %05ld dollars and %03ld cents",...)
	push 	rbp		; normal stack frame
	mov	rbp, rsp
	sub	rsp, 16		; space for dollars and cents
	mov	[rsp], rdi	; save dollars
	mov	[rsp + 8], rsi	; save cents
        lea     rdi, [outp]
	lea	rsi, [name]
        mov     rdx, [rsp]
        mov     rcx, [rsp + 8]
        xor     eax, eax	; 0 float parameters
        call    printf
        leave
        ret
	
_start:
	
again:	call 	read_data

	;; check for stop
	lea	rsi, [name]	; address of name
	lea	rdi, [stop]	; address of the constant string 'stop\0'
	mov	rcx, 5		; chars in 'stop\0'
	repe	cmpsb		; compare both strings
	cmp	rcx, 0
	jz	end		; if equal terminate the program
	;; end check for stop

	call 	compute_bill	; if not, continue
	
	mov	rdi, rax
	mov	rsi, rdx
	call 	print_data

	jmp	again	

end:	mov	eax, 60	     	; exit
	xor	edi, edi
	syscall
