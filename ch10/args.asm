        segment .data
format  db      "%s",0x0a,0
        segment .text
        global  main              ; let the linker know about main
        extern  printf            ; resolve printf from libc
main:
        push    rbp               ; prepare stack frame for main
        mov     rbp, rsp
        frame   2, 1, 2
        sub     rsp, frame_size
        mov     rcx, rsi          ; move argv to rcx
        mov     rsi, [rcx]        ; get first argv string
start_loop:
        lea     rdi, [format]
        mov     [rbp+local1], rcx ; save argv
        xor     eax, eax
        call    printf
        mov     rcx, [rbp+local1] ; restore rsi
        add     rcx, 8            ; advance to the next pointer in argv
        mov     rsi, [rcx]        ; get next argv string
        cmp     rsi, 0            ; it's sad that mov doesn't also test
        jnz     start_loop        ; end with NULL pointer
end_loop:
        xor     eax, eax
        leave
        ret
