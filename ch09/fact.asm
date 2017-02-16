        segment .data
x       dq      0
prompt: db     "Enter n: ",0
scanf_format   db    "%ld",0
printf_format  db    "fact(%ld) = %ld",0x0a,0

        segment .text
        global  main                ; let the linker know about main
        global  fact                ; tell the world about fact
        extern  scanf               ; resolve write and exit from libc
        extern  printf
main:
        push    rbp
        mov     rbp, rsp
        frame   2, 0, 3
        sub     rsp, frame_size
;
;       printf("Enter n: ");
;
        segment .text
        lea     rdi, [prompt]      ; set arg 1 for printf
        xor     eax, eax            ; 0 float parameters
        call    printf
;
;       scanf("%ls", x);
;
        lea     rdi, [scanf_format] ; set arg 1 for scanf
        lea     rsi, [x]            ; set arg 2 for scanf
        xor     eax, eax            ; set rax to 0 (2 byte instruction)
        call    scanf

;
;       printf("fact(%ld) = %ld\n",x,fact(x));
;
        mov     rdi, [x]            ; move the value of x to rdi for fact call
        call    fact
        lea     rdi, [printf_format]    ; set arg 1 for printf
        mov     rsi, [x]            ; set arg 2 for printf
        mov     rdx, rax            ; set arg 3 to be x!
        xor     eax, eax            ; set rax to 0
        call    printf

;
;       return 0
;
        xor     eax, eax            ; set rax to 0 for return value
        leave
        ret

;   long fact ( long n )
;
fact:                               ; recursive factorial function
n       equ     local1
        push    rbp
        mov     rbp, rsp
        frame   1, 1, 1             ; need 1 local variable
        sub     rsp, frame_size
;
;       if ( n < 1 ) return 1;
;
        cmp     rdi, 1              ; compare argument with 1
        jg      greater             ; if n <= 1, return 1
        mov     eax, 1              ; set return value to 1
        leave
        ret
;
;       else return fact(n-1) * n;
;
greater:
        mov     [rbp+n], rdi        ; save n
        dec     rdi                 ; call fact with n-1
        call    fact
        mov     rdi, [rsp+n]        ; restore original n
        imul    rax, rdi           ; multiply fact(n-1)*n
        leave
        ret

