        SECTION .data
fmt     db      'max(%ld,%ld) = %ld',0xa,0

	SECTION .text
        global  main
        extern  printf

; void print_max ( long a, long b )
; {
a       equ     0
b       equ     8
print_max:
        push    rbp;         ; normal stack frame
        mov     rbp, rsp
        sub  	rsp, 32
;       leave space for a, b and max
;       int max;
max     equ     16
        mov     [rsp+a], rdi ; save a
        mov     [rsp+b], rsi ; save b
;       max = a;
        mov     [rsp+max], rdi
;       if ( b > max ) max = b;
        cmp     rsi, rdi
        jng     skip
        mov     [rsp+max], rsi
skip:
;       printf ( "max(%ld,%ld) = %ld\n", a, b, max );
        lea     rdi, [fmt]
        mov     rsi, [rsp+a]
        mov     rdx, [rsp+b]
        mov     rcx, [rsp+max]
        xor     eax, eax
        call    printf
; }
        leave
        ret

main:
        push    rbp
        mov     rbp, rsp
;       print_max ( 100, 200 );
        mov     rdi, 100    ; first parameter
        mov     rsi, 200    ; second parameter
        call 	print_max
        xor     eax, eax    ; to return 0
        leave
        ret
