        section .data
msg:    db      "Hello World!",0x0a,0

        section .text
        global  main
        extern  printf
main:
        push    rbp
        mov     rbp, rsp
        lea     rdi, [msg]  ; parameter 1 for printf
        xor     eax, eax    ; 0 floating point parameters
        call    printf
        xor     eax, eax    ; return 0
        pop     rbp
        ret
