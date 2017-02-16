        segment .data
	
strd  	db	11111111b
rslt  	dd      0
	
        segment .text
        global  _start
_start:	
        push    rbp
        mov     rbp, rsp

	xor	rax, rax
	
	mov	rax, 0x1	; bit 0
	movzx   rbx, byte [strd]
	and 	rax, rbx
	add 	[rslt], rax
	shr	byte [strd], 1
	mov	rax, 0x1	; bit 1
	movzx   rbx, byte [strd]
	and 	rax, rbx
	add 	[rslt], rax
	shr	byte [strd], 1
	mov	rax, 0x1	; bit 2
	movzx   rbx, byte [strd]
	and 	rax, rbx
	add 	[rslt], rax
	shr	byte [strd], 1
	mov	rax, 0x1	; bit 3
	movzx   rbx, byte [strd]
	and 	rax, rbx
	add 	[rslt], rax
	shr	byte [strd], 1
	mov	rax, 0x1	; bit 4
	movzx   rbx, byte [strd]
	and 	rax, rbx
	add 	[rslt], rax
	shr	byte [strd], 1
	mov	rax, 0x1	; bit 5
	movzx   rbx, byte [strd]
	and 	rax, rbx
	add 	[rslt], rax
	shr	byte [strd], 1
	mov	rax, 0x1	; bit 6
	movzx   rbx, byte [strd]
	and 	rax, rbx
	add 	[rslt], rax
	shr	byte [strd], 1
	mov	rax, 0x1	; bit 7
	movzx   rbx, byte [strd]
	and 	rax, rbx
	add 	[rslt], rax
	shr	byte [strd], 1

	xor     rax, rax
        leave
        ret
