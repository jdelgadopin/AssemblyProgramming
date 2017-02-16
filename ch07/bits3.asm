        segment .data
sample  dq      0x0123456789abcdef
field   dq      0
        segment .text
        global  main
main:
        push    rbp
        mov     rbp, rsp
        mov     rax, [sample]      ; move quad-word into rax
        shr     rax, 23            ; shift to align bit 23 at 0
        and     rax, 0x1fffffff    ; select the 29 low bits
        mov     [field], rax       ; save the field
        xor     rax, rax
        leave
        ret
