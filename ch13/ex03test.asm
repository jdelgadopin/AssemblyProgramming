
;;; Every qword represents 18 digits (7 bits per 2 decimal digits)
;;; Thus, in this representation
;;; max: 999999999999999999 in decimal repr is 0xDE0B6B3A763FFFF in hex
;;; but 999999999999999999 in my representation is 0x63C78F1E3C78F1E3
;;; since 99 = 1100011 (99 + 99 = 198 = 0xc6 = 1|1000110)
;;; ---------------------------------------------------------------------

	SECTION .bss
string_read:	resb	1024
zero:		resq	1
one:		resq	1
	
	struc BigInt
b_size:		resq	1 	; integer size (in qwords)
b_num:		resq	1	; address of the qword array
	endstruc

;;; ---------------------------------------------------------------------

        SECTION .data

boundaries	db	0,7,14,21,28,35,42,49,56

_inp		db	"%s",0
_out		db	"%02u",0
_ret		db	0xa,0	
_pro		db	"Enter a number: ",0
_prn		db	"===> ",0
_ove		db	" with overflow",0
_sum		db	"sum: ",0	

		
;;; ---------------------------------------------------------------------

	SECTION .text
        global  main		; MUST be linked with gcc (not ld)
	
        extern  scanf, printf, malloc, free, atol

;;; ---------------------------------------------------------------------

convert_string_to_num:
	;; convert a null-delimited string whose address is in rdi to our representation
	;; no error control, i.e. we are assuming the string represents a number 
	;; address of BigInt result in rax
	push 	rbp
	mov	rbp, rsp
	push	rbx
	push	r12
	push	r13
	push	r14
	
	mov	rbx, rdi		; rbx <-- address of the string to convert

	mov	rdi, BigInt_size 	; reserve memory for the BigInt result of the conversion
	call	malloc
	mov	r12, rax		; assume everything went ok and save the address in r12, now r12 <--address of the BigInt result of the conversion

	xor	rax, rax
.next_zero:				; skip leading zeroes
	cmp	byte [rbx+rax], 0
	je	.compute_size
	cmp	byte [rbx+rax], 0x30 	; 0x30 = '0' char
	jne	.compute_size
	inc 	rax
	jmp	.next_zero
	
.compute_size:
	add	rbx, rax		; real address, where there is the first, most-significative, non-zero digit
	xor	rax, rax		; find string size 
.next_char:
	cmp	byte [rbx+rax], 0
	je	.size
	inc 	rax
	jmp	.next_char
.size:					; rax <-- string size
	mov	r14, rax
	mov	rcx, 18
	xor	rdx, rdx
	div	rcx			; rax <-- (string size) / 18 with reminder in rdx
	cmp	rdx, 0
	je	.save
	inc 	rax			; if size is not a multiple of 18, one more qword is needed
.save:
	cmp	rax, 0
	jne	.not_zero
	mov	r12, [zero]
	jmp	.end_conversion
.not_zero:
	mov	r13, rdx		; save reminder of string size/18
	mov	qword [r12+b_size], rax ; BigInt size, in qwords: (string size) / 18 (+ 1 if reminder > 0)
	shl	rax, 3			; how many bytes do I need to convert the string to a BigInt? -> (size/18 [+ 1]) x 8
	mov	rdi, rax
	call	malloc
	mov	qword [r12+b_num], rax  ; address of the array of b_size qwords that make the number - little-endian

	;; Now we have: rbx <-- address of the string to convert
	;; 		r12 <-- address of the BigInt result of the conversion
	;; 		[r12 + b_size] <-- size (in qwords) of the qwords array
	;; 		[r12 + b_num ] <-- address of the array of [r12 + b_size] qwords
	;; 		r13 <-- reminder of string size / 18
	;; 		r14 <-- size of the string to convert
	
	SECTION .bss
.temp:		resb	19	

	SECTION .text

	xor	r8, r8			; r8  <-- BigInt qword's counter
	sub	r14, 18			; r14 <-- index of the string to be transformed to a number
.next_qword:
	cmp	r14, 0
	jl	.done
	
	push	r8
	lea	rsi, [rbx+r14]		; copy chars from rbx+r14 to rbx+r14+17 (18 chars), to .temp  
	lea	rdi, [.temp]
	mov	rcx, 18
	rep	movsb
	pop	r8
	mov	byte [.temp+18], 0	; the 19th byte in .temp must be 0

	push	r8
	lea	rdi, [.temp]
	call	atol				; convert the string to a number...
	mov	rdi, rax
	call	convert_num_to_num 		; ...and transform it to our representation
	pop	r8
	mov	r9, [r12+b_num]
	mov	qword [r9+8*r8], rax		; save it in the current BigInt

	inc	r8
	sub	r14, 18
	jmp	.next_qword
.done:
	;; now we have the first r13 digits to convert
	cmp	r13, 0
	je	.end_conversion
	push	r8
	lea	rsi, [rbx]		; copy chars from rbx to rbx+r13, to .temp  
	lea	rdi, [.temp]
	mov	rcx, r13
	rep	movsb
	mov	byte [.temp+r13], 0
	lea	rdi, [.temp]
	call	atol			; convert the string to a number...
	mov	rdi, rax
	call	convert_num_to_num 	; ...and transform it to our representation
	pop	r8
	mov	r9, [r12+b_num]
	mov	qword [r9+8*r8], rax		; save it in the current BigInt
.end_conversion:
	mov	rax, r12
	pop	r14
	pop 	r13
	pop 	r12
	pop	rbx
	leave
	ret
	
;;; ---------------------------------------------------------------------

convert_num_to_num:
	;; convert the number in rdi (in decimal representation) to our representation
	;; this number must be <= 999999999999999999 (in base 10)
	;;                     <=  0xDE0B6B3A763FFFF
	;; result in rax
	push 	rbp
	mov	rbp, rsp
	push	rbx
	push	r12

	mov	rax, rdi
	xor	r12, r12
	xor	rbx, rbx
.next:
	cmp	rax, 0
	je	.done
	cmp	rbx, 9
	jge	.done
	mov	rcx, 100
	xor	rdx, rdx
	div	rcx
	;; rax <-- quotient
	;; rdx <-- reminder in [0,99]
	movzx	rcx, byte [boundaries+rbx]		
	ror	r12, cl
	or	r12b,dl
	rol	r12, cl
	inc 	rbx
	jmp	.next
.done:
	mov	rax, r12
.end:
	pop 	r12
	pop	rbx
	leave
	ret
	
;;; ---------------------------------------------------------------------

print_num:	
	;; print the number in rdi
	push 	rbp
	mov	rbp, rsp
	push	rbx			   ; save rbx
	push	r12			   ; save r12
	push	r13			   ; save r13

	mov	r12, rdi
	mov	r13, rsi		   ; flag for printing (or not) zeroes
	mov	rbx, 8	
.next:
	cmp	rbx, 0
	jl	.done
	movzx	rcx, byte [boundaries+rbx]
	ror	r12, cl			   ; rotate to the right as many bits as indicated by the corresp. boundary
	movzx	rsi, r12b		   ; move the byte to a temporal place
	btr	rsi, 7			   ; reset the 8th bit, only interested in the lowest 7 bits
	cmp	rsi, 0
	jne	.go_pr
	cmp	r13, 0
	je	.go_no
.go_pr:	
	or	r13, 0x1
	lea	rdi, [_out]
	xor	eax, eax
	call	printf
.go_no:
	movzx	rcx, byte [boundaries+rbx]
	rol	r12, cl
	dec	rbx
	jmp	.next	
.done:
	mov	rax, r13
	pop	r13			   ; restore r13
	pop 	r12			   ; restore r12
	pop	rbx			   ; restore rbx
	leave
	ret
	
;;; ---------------------------------------------------------------------

print_BigInt:	
	;; print the BigInt number whose address is in rdi
	;; returns this rdi in rax
	push 	rbp
	mov	rbp, rsp
	push	rbx
	push	r12
	push	r13
	push	rdi

	mov	r12, [rdi+b_size]	; r12 <-- size (in qwords) of the BigInt
	mov	r13, [rdi+b_num]	; r13 <-- address of the array of b_size qwords

	SECTION .data
._zero:	db	"00",0
._size:	db	"%d -- ",0
	SECTION .text
	lea	rdi, [._size]
	mov	rsi, r12
	xor	eax, eax
	call	printf	

	xor	rbx, rbx
	
	dec	r12
.next_qword:
	cmp	r12, 0
	jl	.end_qword
	mov	rdi, qword [r13+8*r12]
	mov	rsi, rbx
	call	print_num
	mov	rbx, rax
	dec	r12
	jmp	.next_qword
.end_qword:
	cmp	rbx, 0			; if the BigInt is zero... print '00'
	jne	.end			; (otherwise it would print nothing)
	lea	rdi, [._zero]
	xor	eax, eax
	call	printf	
.end:
	pop	rax
	pop 	r13
	pop 	r12
	pop	rbx
	leave
	ret
	
;;; ---------------------------------------------------------------------

equal:	
	;; compare BigInt's with addresses in rdi and rsi
	;; return 1 in rax if equal
	push 	rbp
	mov	rbp, rsp
	push	rbx			; save rbx, r12-r15
	push	r12
	push	r13
	push	r14
	push	r15
	xor	rax, rax	
	mov	r12, [rdi+b_size]
	mov	r13, [rdi+b_num]
	mov	r14, [rsi+b_size]
	mov	r15, [rsi+b_num]
	cmp	r12, r14
	jne	.end
	xor	rbx, rbx
.next_qword:
	cmp	rbx, r12
	jge	.end_qword
	mov	r8, qword [r13+8*rbx]
	cmp	r8, qword [r15+8*rbx]
	jne	.end	
	inc	rbx
	jmp	.next_qword
.end_qword:
	mov	rax, 0x1
.end:
	pop	r15			; now, restore rbx, r12-r15
	pop	r14
	pop	r13
	pop 	r12
	pop	rbx
	leave
	ret

;;; ---------------------------------------------------------------------

prod_BigInt:	
	;; multiply BigInt's with addresses in rdi and rsi
	;; return address of a new BigInt (*rdi x *rsi, so to say) in rax
	push 	rbp
	mov	rbp, rsp
	push	rbx			; save rbx, r12-r15
	push	r12
	push	r13
	push	r14
	push	r15

	mov	r13, rdi
	mov	r12, [rdi+b_size]
	mov	r15, rsi
	mov	r14, [rsi+b_size]
	cmp	r14, r12
	jge	.go_on
	mov	r13, rsi
	mov	r12, [rsi+b_size]
	mov	r15, rdi
	mov	r14, [rdi+b_size]
.go_on:
	;; r12 <-- min (r12, r14) = min size, r13 corresp. BigInt address
	;; r14 <-- max (r12, r14) = max size, r15 corresp. BigInt address

	SECTION .data
.result:	dq	1

	SECTION .text
	;; create a BigInt with 0 value, to keep the result
	mov	rdi, BigInt_size
	call	malloc
	mov	[.result], rax
	mov	r8, [.result]
	mov	qword [r8+b_size], 0x1 ; 1 qword
	mov	rdi, 8
	call 	malloc
	mov	r8, [.result]
	mov	qword [r8+b_num], rax 
	mov	qword [rax], 0x0
	;; create a counter BigInt with 0 value
	mov	rdi, BigInt_size
	call	malloc
	mov	rbx, rax
	mov	qword [rbx+b_size], 0x1 ; 1 qword
	mov	rdi, 8
	call 	malloc
	mov	qword [rbx+b_num], rax 
	mov	qword [rax], 0x0
	;; rbx <-- counter, to go from 0 to the BigInt pointed by r12	
.next:
	;; compare the counter with r13, and quit if they are equal
	mov 	rdi, rbx
	mov	rsi, r13
	call	equal
	cmp	rax, 1
	je	.stop
	
	;; add r15 to the current [.result]:  [.result] <-- [.result] + r15
	mov	rdi, qword [.result]
	mov	rsi, r15
	call	add_BigInt
	;; now update [.result]
	mov	r10, qword [.result]
	mov	qword [.result], rax
	push	r10
	mov	rdi, [r10+b_num]
	call	free
	pop	r10
	mov 	rdi, r10
	call	free

	;; increment the counter: [rbx] <-- [rbx] + 1
	mov	rdi, rbx
	mov	rsi, [one]
	call	add_BigInt
	;; now update the counter
	mov	r10, rbx
	mov	rbx, rax
	push	r10
	mov	rdi, [r10+b_num]
	call	free
	pop	r10
	mov 	rdi, r10
	call	free

	jmp	.next
.stop:
	;; free the space for the counter
	mov	rdi, [rbx+b_num]
	call	free
	mov 	rdi, rbx
	call	free

	mov	rax, [.result]
	pop	r15			; now, restore rbx, r12-r15
	pop	r14
	pop	r13
	pop 	r12
	pop	rbx
	leave
	ret

;;; ---------------------------------------------------------------------

add_BigInt:	
	;; add BigInt's with addresses in rdi and rsi
	;; return address of a new BigInt (*rdi + *rsi, so to say) in rax
	push 	rbp
	mov	rbp, rsp
	push	rbx			; save rbx, r12-r15
	push	r12
	push	r13
	push	r14
	push	r15

	mov	r12, [rdi+b_size]
	mov	r13, [rdi+b_num]
	mov	r14, [rsi+b_size]
	mov	r15, [rsi+b_num]
	cmp	r14, r12
	jge	.go_on
	mov	r12, [rsi+b_size]
	mov	r13, [rsi+b_num]
	mov	r14, [rdi+b_size]
	mov	r15, [rdi+b_num]
.go_on:
	;; r12 <-- min (r12, r14) = min size, r13 corresp. address
	;; r14 <-- max (r12, r14) = max size, r15 corresp. address

	SECTION .data
.result:	dq	1

	SECTION .text

	;; create the BigInt result of the sum with max-size qwords
	mov	rdi, BigInt_size
	call	malloc
	mov	[.result], rax
	mov	rbx, rax
	mov	rdi, r14
	mov	qword [rbx+b_size], rdi ; max qwords
	shl	rdi, 3			; max x 8 bytes
	call 	malloc
	mov	qword [rbx+b_num], rax 

	;; first pass: add the qwords up to min size
	xor	rdx, rdx		; initial carry = 0
	xor	rbx, rbx		; qwords counter
.next_qword_1stpass:
	cmp	rbx, r12
	jge	.end_qword_1stpass
	mov	rdi, qword [r13+8*rbx]
	mov	rsi, qword [r15+8*rbx]
	;; we already have the right carry in rdx
	call	add_num
	mov	rcx, [.result]
	mov	rcx, [rcx+b_num]
	mov	qword [rcx+8*rbx], rax
	inc	rbx
	jmp	.next_qword_1stpass
.end_qword_1stpass:
	;; second pass: add the qwords up to max size
.next_qword_2ndpass:
	cmp	rbx, r14
	jge	.end_qword_2ndpass
	mov	rdi, 0x0
	mov	rsi, qword [r15+8*rbx]
	;; we already have the right carry in rdx
	call	add_num
	mov	rcx, [.result]
	mov	rcx, [rcx+b_num]
	mov	qword [rcx+8*rbx], rax
	inc	rbx
	jmp	.next_qword_2ndpass
.end_qword_2ndpass:
	;; now, if there is carry, we need a new qword for our result!
	cmp	rdx, 0
	je	.end
	mov	r12, [.result]
	mov	r13, [r12+b_num] 	; address of the result qwords we are going to substitute
	mov	rcx, r14
	inc	rcx
	mov	qword [r12+b_size], rcx
	shl	rcx, 3			; (max size + 1) x 8 bytes for the new array
	mov	rdi, rcx
	call	malloc
	mov	qword [r12+b_num], rax
	xor	rbx, rbx		; qwords counter
.next_qword:
	cmp	rbx, r14
	jge	.end_qword
	mov	rdi, qword [r13+8*rbx]
	mov	qword [rax+8*rbx], rdi
	inc	rbx
	jmp	.next_qword
.end_qword:
	mov	qword [rax+8*r14], 0x1
	mov	rdi, r13
	call 	free
.end:
	mov	rax, [.result]
	pop	r15			; now, restore rbx, r12-r15
	pop	r14
	pop	r13
	pop 	r12
	pop	rbx
	leave
	ret
	
;;; ---------------------------------------------------------------------

add_num:	
	;; add the number in rdi with the number in rsi and carry in rdx
	;; return sum in rax, and carry in rdx (0/1)
	push 	rbp
	mov	rbp, rsp
	push	rbx
	push	r12
	push	r13
	push	r14
	push	r15

	;; Adding two two-digits at boundary bl and keep carry
	;; r8[b,b+6] <-- r12[b,b+6] + r13[b,b+6] + carry
	;; assume bl contains the boundary (in {0,1,2,3,4,5,6,7,8})
	;; assume r12 contains one qword with digits to be added to...
	;; ...r13, that contains the other qword to add
	SECTION .data
.carry:		db	0

	SECTION .text
	
	xor	r8, r8
	mov	r12, rdi
	mov	r13, rsi
	mov	byte [.carry], dl
	
	xor	rbx, rbx
.next:
	cmp	rbx, 9
	jge	.done
	movzx	rcx, byte [boundaries+rbx]
	ror	r12, cl			   ; rotate to the right as many bits as indicated by the corresp. boundary
	movzx	r14, r12b		   ; move the byte to a temporal place
	btr	r14, 7			   ; reset the 8th bit, only interested in the lowest 7 bits
	rol	r12, cl			   ; leave r12 unmodified
	ror	r13, cl
	movzx	r15, r13b
	btr	r15, 7
	rol	r13, cl			   ; leave r13 unmodified
	add	r14b, r15b		   ; add the two 7 bit numbers
	movzx	rdx, byte [.carry]
	add	r14b, dl		   ; add carry
	mov	r9, 100
	mov	rax, r14
	xor	rdx, rdx
	div 	r9
	mov	byte [.carry], al
	mov	r14, rdx	
	ror	r8, cl
	shr	r8, 7
	shl	r8, 7			   ; zero-ing the first 7 bits of rdx
	or	r8b, r14b		   ; put the 7 bits in place
	rol	r8, cl
	inc	rbx
	jmp	.next
.done:
	mov	rax, r8
	movzx	rdx, byte [.carry]
.end:	
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

	;; ----- create a 'zero' BigInt ---------
	mov	rdi, BigInt_size 	; reserve memory for the BigInt result of the conversion
	call	malloc
	mov	qword [zero], rax	; assume everything went ok and save the address in r12, now r12 <--address of the BigInt result of the conversion
	mov	r12, rax
	mov	qword [r12+b_size], 0x1 ; size 1 qword
	mov	rdi, 8			; reserve space for 8 bytes = 1 qword
	call 	malloc
	mov	qword [r12+b_num], rax
	mov	qword [rax], 0x0
	;; -------------------------------------
	;; ----- create a 'one' BigInt ---------
	mov	rdi, BigInt_size 	; reserve memory for the BigInt result of the conversion
	call	malloc
	mov	qword [one], rax	; assume everything went ok and save the address in r12, now r12 <--address of the BigInt result of the conversion
	mov	r12, rax
	mov	qword [r12+b_size], 0x1 ; size 1 qword
	mov	rdi, 8			; reserve space for 8 bytes = 1 qword
	call 	malloc
	mov	qword [r12+b_num], rax
	mov	qword [rax], 0x1
	;; -------------------------------------
	;; ----- read one BigInt ---------------	
	lea	rdi, [_pro]
	xor	eax, eax
	call 	printf
        lea     rdi, [_inp]
        lea     rsi, [string_read]
        xor     eax, eax
        call    scanf
	lea	rdi, [string_read]
	call	convert_string_to_num
	mov	r12, rax
	;; -------------------------------------




	;; ----- COMPUTE THE FACTORIAL ---------
	;; r12 <-- number I want to compute the factorial
	SECTION .data
.result:	dq	1
	SECTION .text
	;; create a BigInt with value 1, to keep the result
	mov	rdi, BigInt_size
	call	malloc
	mov	qword [.result], rax
	mov	r13, rax
	mov	qword [r13+b_size], 0x1 ; 1 qword
	mov	rdi, 8
	call 	malloc
	mov	qword [r13+b_num], rax 
	mov	qword [rax], 0x1
	;; create a counter BigInt with value 1
	mov	rdi, BigInt_size
	call	malloc
	mov	rbx, rax
	mov	qword [rbx+b_size], 0x1 ; 1 qword
	mov	rdi, 8
	call 	malloc
	mov	qword [rbx+b_num], rax 
	mov	qword [rax], 0x1
	;; rbx <-- counter, to go from 0 to the BigInt pointed by r12



	;; multiply rbx by the current [.result]:  [.result] <-- [.result] x rbx
	mov	rdi, rbx
	mov	rsi, qword [.result]
	call	prod_BigInt
	;; now update [.result]
	mov	r13, qword [.result] 
	mov	qword [.result], rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free

	;; increment the counter: [rbx] <-- [rbx] + 1
	mov	rdi, rbx
	mov	rsi, [one]
	call	add_BigInt
	;; now update the counter	
	mov	r13, rbx
	mov	rbx, rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free
	;; multiply rbx by the current [.result]:  [.result] <-- [.result] x rbx
	mov	rdi, rbx
	mov	rsi, qword [.result]
	call	prod_BigInt
	;; now update [.result]
	mov	r13, qword [.result] 
	mov	qword [.result], rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free

	;; increment the counter: [rbx] <-- [rbx] + 1
	mov	rdi, rbx
	mov	rsi, [one]
	call	add_BigInt
	;; now update the counter	
	mov	r13, rbx
	mov	rbx, rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free
	;; multiply rbx by the current [.result]:  [.result] <-- [.result] x rbx
	mov	rdi, rbx
	mov	rsi, qword [.result]
	call	prod_BigInt
	;; now update [.result]
	mov	r13, qword [.result] 
	mov	qword [.result], rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free

	;; increment the counter: [rbx] <-- [rbx] + 1
	mov	rdi, rbx
	mov	rsi, [one]
	call	add_BigInt
	;; now update the counter	
	mov	r13, rbx
	mov	rbx, rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free
	;; multiply rbx by the current [.result]:  [.result] <-- [.result] x rbx
	mov	rdi, rbx
	mov	rsi, qword [.result]
	call	prod_BigInt
	;; now update [.result]
	mov	r13, qword [.result] 
	mov	qword [.result], rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free

	;; increment the counter: [rbx] <-- [rbx] + 1
	mov	rdi, rbx
	mov	rsi, [one]
	call	add_BigInt
	;; now update the counter	
	mov	r13, rbx
	mov	rbx, rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free
	;; multiply rbx by the current [.result]:  [.result] <-- [.result] x rbx
	mov	rdi, rbx
	mov	rsi, qword [.result]
	call	prod_BigInt
	;; now update [.result]
	mov	r13, qword [.result] 
	mov	qword [.result], rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free

	;; increment the counter: [rbx] <-- [rbx] + 1
	mov	rdi, rbx
	mov	rsi, [one]
	call	add_BigInt
	;; now update the counter	
	mov	r13, rbx
	mov	rbx, rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free
	;; multiply rbx by the current [.result]:  [.result] <-- [.result] x rbx
	mov	rdi, rbx
	mov	rsi, qword [.result]
	call	prod_BigInt
	;; now update [.result]
	mov	r13, qword [.result] 
	mov	qword [.result], rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free

	;; increment the counter: [rbx] <-- [rbx] + 1
	mov	rdi, rbx
	mov	rsi, [one]
	call	add_BigInt
	;; now update the counter	
	mov	r13, rbx
	mov	rbx, rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free
	;; multiply rbx by the current [.result]:  [.result] <-- [.result] x rbx
	mov	rdi, rbx
	mov	rsi, qword [.result]
	call	prod_BigInt
	;; now update [.result]
	mov	r13, qword [.result] 
	mov	qword [.result], rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free

	;; increment the counter: [rbx] <-- [rbx] + 1
	mov	rdi, rbx
	mov	rsi, [one]
	call	add_BigInt
	;; now update the counter	
	mov	r13, rbx
	mov	rbx, rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free
	;; multiply rbx by the current [.result]:  [.result] <-- [.result] x rbx
	mov	rdi, rbx
	mov	rsi, qword [.result]
	call	prod_BigInt
	;; now update [.result]
	mov	r13, qword [.result] 
	mov	qword [.result], rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free

	;; increment the counter: [rbx] <-- [rbx] + 1
	mov	rdi, rbx
	mov	rsi, [one]
	call	add_BigInt
	;; now update the counter	
	mov	r13, rbx
	mov	rbx, rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free
	;; multiply rbx by the current [.result]:  [.result] <-- [.result] x rbx
	mov	rdi, rbx
	mov	rsi, qword [.result]
	call	prod_BigInt
	;; now update [.result]
	mov	r13, qword [.result] 
	mov	qword [.result], rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free

	;; increment the counter: [rbx] <-- [rbx] + 1
	mov	rdi, rbx
	mov	rsi, [one]
	call	add_BigInt
	;; now update the counter	
	mov	r13, rbx
	mov	rbx, rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free
	;; multiply rbx by the current [.result]:  [.result] <-- [.result] x rbx
	mov	rdi, rbx
	mov	rsi, qword [.result]
	call	prod_BigInt
	;; now update [.result]
	mov	r13, qword [.result] 
	mov	qword [.result], rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free

	;; increment the counter: [rbx] <-- [rbx] + 1
	mov	rdi, rbx
	mov	rsi, [one]
	call	add_BigInt
	;; now update the counter	
	mov	r13, rbx
	mov	rbx, rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free
	;; multiply rbx by the current [.result]:  [.result] <-- [.result] x rbx
	mov	rdi, rbx
	mov	rsi, qword [.result]
	call	prod_BigInt
	;; now update [.result]
	mov	r13, qword [.result] 
	mov	qword [.result], rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free

	;; increment the counter: [rbx] <-- [rbx] + 1
	mov	rdi, rbx
	mov	rsi, [one]
	call	add_BigInt
	;; now update the counter	
	mov	r13, rbx
	mov	rbx, rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free
	;; multiply rbx by the current [.result]:  [.result] <-- [.result] x rbx
	mov	rdi, rbx
	mov	rsi, qword [.result]
	call	prod_BigInt
	;; now update [.result]
	mov	r13, qword [.result] 
	mov	qword [.result], rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free

	;; increment the counter: [rbx] <-- [rbx] + 1
	mov	rdi, rbx
	mov	rsi, [one]
	call	add_BigInt
	;; now update the counter	
	mov	r13, rbx
	mov	rbx, rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free
	;; multiply rbx by the current [.result]:  [.result] <-- [.result] x rbx
	mov	rdi, rbx
	mov	rsi, qword [.result]
	call	prod_BigInt
	;; now update [.result]
	mov	r13, qword [.result] 
	mov	qword [.result], rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free

	;; increment the counter: [rbx] <-- [rbx] + 1
	mov	rdi, rbx
	mov	rsi, [one]
	call	add_BigInt
	;; now update the counter	
	mov	r13, rbx
	mov	rbx, rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free
	;; multiply rbx by the current [.result]:  [.result] <-- [.result] x rbx
	mov	rdi, rbx
	mov	rsi, qword [.result]
	call	prod_BigInt
	;; now update [.result]
	mov	r13, qword [.result] 
	mov	qword [.result], rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free

	;; increment the counter: [rbx] <-- [rbx] + 1
	mov	rdi, rbx
	mov	rsi, [one]
	call	add_BigInt
	;; now update the counter	
	mov	r13, rbx
	mov	rbx, rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free
	;; multiply rbx by the current [.result]:  [.result] <-- [.result] x rbx
	mov	rdi, rbx
	mov	rsi, qword [.result]
	call	prod_BigInt
	;; now update [.result]
	mov	r13, qword [.result] 
	mov	qword [.result], rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free

	;; increment the counter: [rbx] <-- [rbx] + 1
	mov	rdi, rbx
	mov	rsi, [one]
	call	add_BigInt
	;; now update the counter	
	mov	r13, rbx
	mov	rbx, rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free
	;; multiply rbx by the current [.result]:  [.result] <-- [.result] x rbx
	mov	rdi, rbx
	mov	rsi, qword [.result]
	call	prod_BigInt
	;; now update [.result]
	mov	r13, qword [.result] 
	mov	qword [.result], rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free

	;; increment the counter: [rbx] <-- [rbx] + 1
	mov	rdi, rbx
	mov	rsi, [one]
	call	add_BigInt
	;; now update the counter	
	mov	r13, rbx
	mov	rbx, rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free
	;; multiply rbx by the current [.result]:  [.result] <-- [.result] x rbx
	mov	rdi, rbx
	mov	rsi, qword [.result]
	call	prod_BigInt
	;; now update [.result]
	mov	r13, qword [.result] 
	mov	qword [.result], rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free

	;; increment the counter: [rbx] <-- [rbx] + 1
	mov	rdi, rbx
	mov	rsi, [one]
	call	add_BigInt
	;; now update the counter	
	mov	r13, rbx
	mov	rbx, rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free
	;; multiply rbx by the current [.result]:  [.result] <-- [.result] x rbx
	mov	rdi, rbx
	mov	rsi, qword [.result]
	call	prod_BigInt
	;; now update [.result]
	mov	r13, qword [.result] 
	mov	qword [.result], rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free

	;; increment the counter: [rbx] <-- [rbx] + 1
	mov	rdi, rbx
	mov	rsi, [one]
	call	add_BigInt
	;; now update the counter	
	mov	r13, rbx
	mov	rbx, rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free
	;; multiply rbx by the current [.result]:  [.result] <-- [.result] x rbx
	mov	rdi, rbx
	mov	rsi, qword [.result]
	call	prod_BigInt
	;; now update [.result]
	mov	r13, qword [.result] 
	mov	qword [.result], rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free

	;; increment the counter: [rbx] <-- [rbx] + 1
	mov	rdi, rbx
	mov	rsi, [one]
	call	add_BigInt
	;; now update the counter	
	mov	r13, rbx
	mov	rbx, rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free
	;; multiply rbx by the current [.result]:  [.result] <-- [.result] x rbx
	mov	rdi, rbx
	mov	rsi, qword [.result]
	call	prod_BigInt
	;; now update [.result]
	mov	r13, qword [.result] 
	mov	qword [.result], rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free

	;; increment the counter: [rbx] <-- [rbx] + 1
	mov	rdi, rbx
	mov	rsi, [one]
	call	add_BigInt
	;; now update the counter	
	mov	r13, rbx
	mov	rbx, rax
	mov	rdi, [r13+b_num]
	call	free
	mov 	rdi, r13
	call	free









	;; -------------------------------------
	;; ----- print result ------------------	
	lea	rdi, [_prn]
	xor	eax, eax
	call 	printf
	mov	rdi, [.result]
	call	print_BigInt
	lea	rdi, [_ret]	; add a new line in the output
	xor	eax, eax
	call	printf
	lea	rdi, [_ret]	; add a new line in the output
	xor	eax, eax
	call	printf
	;; -------------------------------------
	;; ----- remove/free the BigInts --------	
	mov	rdi, [rbx+b_num]
	call	free
	mov	rdi, rbx
	call	free
	mov	rdi, [r12+b_num]
	call	free
	mov	rdi, r12
	call	free
	mov	r13, [.result]
	mov	rdi, [r13+b_num]
	call	free
	mov	rdi, r13
	call	free
	;; -------------------------------------
	;; ----- remove/free the consant BigInt's ---
	mov	rcx, [zero]
	mov	rdi, [rcx+b_num]
	call	free
	mov	rdi, [zero]
	call	free
	mov	rcx, [one]
	mov	rdi, [rcx+b_num]
	call	free
	mov	rdi, [zero]
	call	free
	;; -------------------------------------
	
.end:
	pop	r13		; restore r13
	pop	r12		; restore r12
	pop	rbx		; restore rbx
	leave
	ret
	

